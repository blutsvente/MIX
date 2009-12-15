#
# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright Cadence Design Systems, Inc. 2001.                        |
# |     All Rights Reserved.       Licensed Software.                     |
# |                                                                       |
# |                                                                       |
# | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF CADENCE DESIGN SYSTEMS |
# | The copyright notice above does not evidence any actual or intended   |
# | publication of such source code.                                      |
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# | Project:    Micronas - IDEAS 2001                                     |
# | Modules:    $RCSfile:  XmlParser.pm                                   |
# | Revision:   $Revision: 1.0                                            |
# | Author:     $Author:   John Armitage                                  |
# | Date:       $Date:     06/22/01                                       |
# |                                                                       |
# | Copyright Cadence Design Systems, 2001                                |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/CDS/XML/Parser.pm,v 1.1 2003/02/03 13:18:28 wig Exp $ |
# +-----------------------------------------------------------------------+
#
# +-------------------------------------------------------------+
# |                                                             |
# | PROPRIETARY INFORMATION, PROPERTY OF CADENCE DESIGN SYSTEMS |
# |                                                             |
# +-------------------------------------------------------------+
#
package CDS::XML::Parser;
require Exporter;

@CDS::XML::Parser::ISA=qw(Exporter);
@CDS::XML::Parser::EXPORT=qw();
@CDS::XML::Parser::EXPORT_OK=qw(&parsefile);

# required Packages
use strict;
# package global variables
use vars qw(
	    %block
	    %sig
	    %regs
	    %gen
	    %pins
	    $top
	   );
use Log::Agent;

use XML::Twig;
# package local variables
my $src_ar=[];
my $tgt_ar=[];
my $con_ar=[];
my $rem="";
my $pkg=(); #pointer to a hash holding package info

my $twig=new XML::Twig(TwigHandlers => {module  => \&ref_handler,
					top     => \&top_handler,
					unit    => \&unit_handler,
					sig     => \&sig_handler,
					src     => \&src_handler,
					tgt     => \&tgt_handler,
					generic => \&gen_handler,
                                        reg     => \&reg_handler,
					conn    => \&con_handler,
				        rem     => \&rem_handler,
				        pin     => \&pin_handler,
				        package => \&pkg_handler,},
		       KeepEncoding => 1); # Added 08/02/2001 jimmyh to print strings w/original encoding


# the routines
sub parsefile($){
  $twig->parsefile($_[0]);
  my $root=$twig->root;
  # build a tree 
  foreach my $k (sort keys %block){
    if(exists $block{$k}->{inst}){
      foreach my $j (@{$block{$k}->{inst}}){
	$j->{ref}=$block{$j->{ref}};
      }
    }
  }
  # change all module names to lowercase 
  foreach my $k (sort keys %block){
    my $temp = $block{$k};
    delete $block{$k};
    $block{lc$k} = $temp;
  }
}

# package private data
# push the data of the ref tag into the block hash
sub ref_handler($$) {
  my( $twig, $elt)= @_;
  my $chld = $elt->first_child;
  my %desc;
  do{
  SWITCH:{
      $chld->gi=~/pkg/ && do {
	if(exists $desc{'pkg'}){
	  push(@{$desc{'pkg'}}, $chld->text);
	} else {
	  $desc{'pkg'}=($chld->text);
	}
	last SWITCH;
      };
      $chld->gi=~/.*/ && do {
	logdie "$chld->gi defined twice" if(exists $desc{$chld->gi});
	$desc{$chld->gi}=($chld->text);
	last SWITCH;
      };
    }
  } while (defined ($chld=$chld->next_sibling));
  $block{$elt->{att}->{name}}=\%desc;
}

# save the top module and treat top tag as hier tag
sub top_handler($$) {
  my( $twig, $elt)= @_;
  $top=lc$elt->{att}->{name};
  unit_handler(@_);
}

# push data of the hier tag into hier hash
sub unit_handler($$) {
  my( $twig, $elt)= @_;
  my $chld = $elt->first_child;
  my %desc;
  do{
  SWITCH:{
      $chld->gi=~/inst/ && do {
	my $name;
	if(length($chld->{att}->{name})){
	  $name = lc$chld->{att}->{name};
	} else {
	  $name = lc$chld->{att}->{ref};
	}
	if(exists $desc{'inst'}){
	  push(@{$desc{'inst'}}, {name=>$name, ref=>$chld->{att}->{ref}});
	} else {
	  @{$desc{'inst'}}={name=>$name, ref=>$chld->{att}->{ref}};
	}
	last SWITCH;
      };
      $chld->gi=~/pkg/ && do {
	if(exists $desc{'pkg'}){
	  push(@{$desc{'pkg'}}, $chld->text);
	} else {
	  $desc{'pkg'}=($chld->text);
	}
	last SWITCH;
      };
      $chld->gi=~/loc/ && do {
	logdie "Location defined twice" if(exists $desc{'loc'});
	$desc{'loc'}=($chld->text);
	last SWITCH;
      };
    }
  } while (defined ($chld=$chld->next_sibling));
  logdie "No instances for hierarchy defined" unless exists $desc{inst};
  $block{$elt->{att}->{name}}=\%desc;
}

# store the src data
sub src_handler($$) {
  my( $twig, $elt)= @_;
  my($width)=1;
  $width=$elt->{att}->{wdth} if(defined $elt->{att}->{wdth});
  push(@$src_ar, [lc$elt->{att}->{blk},lc$elt->{att}->{pin}, lc$width,$elt->{att}->{type},lc$elt->{att}->{dir}]);
}

# store the tgt data
sub tgt_handler($$) {
  my( $twig, $elt)= @_;
  my($width)=1;
  $width=$elt->{att}->{wdth} if(defined $elt->{att}->{wdth});
  push(@$tgt_ar, [lc$elt->{att}->{blk},lc$elt->{att}->{pin}, $width ,lc$elt->{att}->{type},lc$elt->{att}->{dir}]);
}

# process the signal data
sub sig_handler($$) {
 my( $twig, $elt)= @_;
 my($name, $width, $type, $dir, $value)=("", 1, "std_ulogic", "uni", "");
 my $cur_line=$twig->{twig_parser}->current_line;
 $name =lc$elt->{att}->{name};
 $name.=".".$elt->{att}->{wdth} if(defined $elt->{att}->{wdth} && $elt->{att}->{wdth} =~ /\d+:\d+/);
 $width=$elt->{att}->{wdth}   if(defined $elt->{att}->{wdth});
 $type =lc$elt->{att}->{type} if(defined $elt->{att}->{type});
 $dir  =lc$elt->{att}->{dir}  if(defined $elt->{att}->{dir});
 $value=$elt->{att}->{value}  if(defined $elt->{att}->{value});
 # check the width's
 foreach my $j (@$tgt_ar, @$src_ar){
   if(ref($j->[2]) eq ref($width)){
     if(ref($j->[2]) eq 'ARRAY'){
       logdie "Pin width mismatch for signal ".$name." at ".$cur_line." (end of <SIG> tag)!" 
	 unless(($j->[2]->[0]-$j->[2]->[1]) == ($width->[0]-$width->[1]));
     }
   }
 }
 # store into the data structure
 if( exists $sig{$name}){
   push(@{$sig{$name}->{src}}, @$src_ar);
   push(@{$sig{$name}->{tgt}}, @$tgt_ar);
   if(ref($sig{$name}->{wdth}) eq ref($width)){
     push(@{$sig{$name}->{wdth}}, @$width)
       if(ref($sig{$name}->{wdth}) eq 'ARRAY');
   } else {
     logdie "Signal width redefined for signal ".$name." at ".$cur_line." (end of <SIG> tag)!";
   }
   logdie "Signal direction redefined for signal ".$name." at ".$cur_line." (end of <SIG> tag)!" if ($sig{$name}->{dir} ne  $dir);
   logdie "Signal type redefined for signal ".$name." at ".$cur_line." (end of <SIG> tag)!" if ($sig{$name}->{type} ne $type);
 } else {
   $sig{$name}={src   => $src_ar,
		tgt   => $tgt_ar,
		wdth  => $width,
		type  => $type,
		value => $value,
		dir   => $dir};
 }
 # initialize array ref's
 $src_ar=[];
 $tgt_ar=[];
}

# process the generic data
sub gen_handler($$) {
  my( $twig, $elt)= @_;
}

sub get_pos ($$$) {
  my ($pos, $width, $field) = @_;
  my ($upper, $lower, $scale);

  if ($field eq "parameter") {
    # For a parameter, only look at the width field
    if ($width =~ /(\d+):(\d+)/) {
      return "[".$1."]" if ($1 == $2);
      return "[".$1.":".$2."]";
    }elsif ($width =~ /(\d+)/) {
      # parameter has only 1 bit, don't need a vector
      return "";
    } else {
      logdie "Unrecognizable width: $width !";
    }
  } elsif ($field eq "register") {
    # look at the pos field to determine the position within the register
    if ($pos =~ /(\d+):(\d+)/) { 
      ($upper, $lower) = ($1, $2);
    } elsif ($pos =~ /(\d+)/) {
      ($upper, $lower) = ($1, $1);
    } else {
      logdie "Unrecognizable position: $pos !";
    }
    
    $scale = 0;
    if ($width =~ /(\d+):(\d+)/) {
      if ($1 >= 8) {
	# use the width field to determine if the register is an upper
	# register or not.  Scale by appropriate factor of 8
	$scale = int($1 / 8)*8;
	$upper += $scale;
	$lower += $scale;    
      }
      return "[".$upper."]" if ($upper == $lower);
      return "[".$upper.":".$lower."]";
    } elsif ($width =~ /(\d+)/) {
      if ($1 >= 8) {
	# use the width field to determine if the register is an upper
	# register or not.  Scale by appropriate factor of 8
	$scale = int($1 / 8)*8;
	$upper += $scale;
      } 
      return "[".$upper."]";
    } else {
      logdie "Unrecognizable width: $width !";
    }
  } else {
    logdie "The field is neither a parameter nor a register: $field !";
  }
}
    


sub reg_handler ($$) {
  my ($twig, $elt) = @_;

  my($ais, $rst, $hs)=("0","0","0");
  my($addr, $par, $rdwr, $vsync, $used, $upper, $section, $reg_pos, $param_pos, $rem_str);
  $addr  =lc$elt->{att}->{addr};
  $rst   =lc$elt->{att}->{rst} if(defined $elt->{att}->{hs});
  $ais   =$elt->{att}->{ais};
  $hs    =$elt->{att}->{hs} if(defined $elt->{att}->{hs});
  $par   =lc($elt->{att}->{parent});
  $rdwr  =lc($elt->{att}->{rdwr});
  $vsync =lc($elt->{att}->{vsync});
  $used  =lc($elt->{att}->{used});
  $upper =lc$elt->{att}->{upper} if(defined $elt->{att}->{upper});
  $section = $elt->{parent}->{att}->{name};

  $reg_pos = get_pos($con_ar->[0]->{pos}, $con_ar->[0]->{wdth}, "register");
  $param_pos = get_pos($con_ar->[0]->{pos}, $con_ar->[0]->{wdth}, "parameter");
  $rem_str = $reg_pos." - ".$con_ar->[0]->{name}.$param_pos.": ".$rem;
  
  if(! exists $regs{$section}{$par}{$addr}){
    $regs{$section}{$par}{$addr}={con   => $con_ar,
				  rdwr  => $rdwr,
				  ais   => $ais,
				  vsync => $vsync,
				  rst   => $rst,
				  hs    => $hs,
				  used  => $used,
				  upper => $upper,
				  rem   => $rem_str };
  } else {
    push(@{$regs{$section}{$par}{$addr}{con}}, @{$con_ar});
    $regs{$section}{$par}{$addr}{rst} = $regs{$section}{$par}{$addr}{rst} ."/".$rst;
    $regs{$section}{$par}{$addr}{rem}.="\n".$rem_str;
    $regs{$section}{$par}{$addr}{upper} = $regs{$section}{$par}{$addr}{upper}."/".$upper if defined $upper;
  }
  $con_ar = [];
  $rem   = "";
}

sub rem_handler($$) {
  my ($twig, $elt) = @_;
  $rem = convert_encodings($elt->{first_child}->{pcdata});
}

sub con_handler ($$) {
  my ($twig,$elt)= @_;
  my %con_h;

  $con_h{pos}  = $elt->{att}->{pos};
  $con_h{name} = lc$elt->{att}->{name};
  $con_h{wdth} = $elt->{att}->{wdth};
  push(@$con_ar, \%con_h);
}

sub convert_encodings($) {

  my $string = shift;
  my %base_ent = ( '&gt;'   => '>',
		   '&lt;'   => '<',
		   '&amp;'  => '&',
		   '&apos;' => "'",
		   '&quot;' => '"',
		 );

  $string =~ s/(&gt;|&lt;|&amp;|&apos;|&quot;)/$base_ent{$1}/g;
  $string =~ s/&#(\d+);/sprintf("%c", $1)/eg;
  return $string;
}
  
sub pkg_handler($$) {
  my ($twig, $elt) = @_;
  $pkg->{name}  = $elt->{att}->{name};
  $pkg->{pinno} = $elt->{att}->{pinno};
}

sub pin_handler($$){
  my ($twig, $elt) = @_;
  
  my $name = lc$elt->{att}->{name};
  my $type = $elt->{att}->{type};
  my $connect = $elt->{att}->{connect} if(defined $elt->{att}->{connect});
  my $function = $elt->{att}->{function} if(defined $elt->{att}->{function});
  my $var = lc$elt->{parent}->{att}->{name};
  my $package_name = $pkg->{name};
  my $package_pinno = $pkg->{pinno};

  $pins{$var}{$package_name}{$package_pinno}={
				     type     => $type,
				     connect  => $connect,
				     function => $function,
				     rem      => $rem,
				     name     => $name,
				    };
  $rem="";
  $pkg=();
}

1;
