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
# | Modules:    $RCSfile:  tb2vhdlent.pl                                  |
# | Revision:   $Revision: 1.0                                            |
# | Author:     $Author:   Eyck Jentzsch                                  |
# | Date:       $Date:     06/22/01                                       |
# |                                                                       |
# | Copyright Cadence Design Systems, 2001                                |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/CDS/XML/Writer.pm,v 1.1 2003/02/03 13:18:28 wig Exp $                                                         |
# +-----------------------------------------------------------------------+
#
# +-------------------------------------------------------------+
# |                                                             |
# | PROPRIETARY INFORMATION, PROPERTY OF CADENCE DESIGN SYSTEMS |
# |                                                             |
# +-------------------------------------------------------------+
#

package CDS::XML::Writer;
require Exporter;

@CDS::XML::Writer::ISA=qw(Exporter);
@CDS::XML::Writer::EXPORT=qw();
@CDS::XML::Writer::EXPORT_OK=qw(
			 &write_con_xml
			 &write_reg_xml
			 &write_pad_xml
			);

use strict;
use Log::Agent;


##################################################################################
### write_con_xml ()
###
### returns: $result
##################################################################################

sub write_con_xml($$$){
  my ($designN, $OutHash, $BlockHash) = @_;
  my ($result);

  # output is collected in $result
  # output of modules
  foreach my $module (sort keys %{$$OutHash{modul}}){
    my $name = uc($module);
    $result .= "  <module name=\"$name\">\n";
    $result .= "    <loc>$$OutHash{modul}{$module}{loc}</loc>\n"    if(defined($$OutHash{modul}{$module}{loc}));
    $result .= "    <ent>$$OutHash{modul}{$module}{ent}</ent>\n"    if(defined($$OutHash{modul}{$module}{ent}));
    $result .= "    <arch>$$OutHash{modul}{$module}{arch}</arch>\n" if(defined($$OutHash{modul}{$module}{arch}));
    $result .= "    <cfg>$$OutHash{modul}{$module}{cfg}</cfg>\n"    if(defined($$OutHash{modul}{$module}{cfg}));
    $result .= "    <comp>$$OutHash{modul}{$module}{comp}</comp>\n" if(defined($$OutHash{modul}{$module}{comp}));
    $result .= "    <pkg>$$OutHash{modul}{$module}{pkg}</pkg>\n"    if(defined($$OutHash{modul}{$module}{pkg}));
    $result .= "  </module>\n";    
  }

  #output of top
  my @topnames=keys(%{$$OutHash{top}});
  my $top=$topnames[0];
  $result .= "  <top name=\"$top\">\n";
  ## loop over all instances
  foreach my $inst (@{$$OutHash{top}{$top}{inst}}){
    $result .= "    <inst";
    if (defined($$BlockHash{$inst}) && ($inst ne $$BlockHash{$inst}) ){
      $result .= " name=\"$inst\" ref=\"$$BlockHash{$inst}\"";
    } else {
      $result .= " name=\"$inst\" ref=\"$inst\"";
    }
    $result .= "/>\n";
  }
  $result .= "    <pkg>$$OutHash{top}{$top}{pkg}</pkg>\n" if(defined($$OutHash{top}{$top}{pkg}));
  $result .= "    <loc>$$OutHash{top}{$top}{loc}</loc>\n" if(defined($$OutHash{top}{$top}{loc}));
  $result .= "  </top>\n";

  #output of unit
  foreach my $unit (sort keys(%{$$OutHash{unit}})) {
    $result .= "  <unit name=\"$unit\">\n";
    foreach my $inst (@{$$OutHash{unit}{$unit}{inst}}) {
      $result .= "    <inst";
      if (defined($$BlockHash{$inst}) && ($inst ne $$BlockHash{$inst}) ){
	$result .= " name=\"$inst\" ref=\"$$BlockHash{$inst}\"";
      } else {
	$result .= " name=\"$inst\" ref=\"$inst\"";
      }
      $result .= "/>\n";
    }
    $result .= "    <pkg>$$OutHash{unit}{$unit}{pkg}</pkg>\n" if(defined($$OutHash{unit}{$unit}{pkg}));
    $result .= "    <loc>$$OutHash{unit}{$unit}{loc}</loc>\n" if(defined($$OutHash{unit}{$unit}{loc}));
    $result .= "  </unit>\n";
  }
  #output of sig
  ## loop over all signals(Core)
  foreach my $signal (sort keys(%{$$OutHash{signal}})) {
    ## get info about name,width,type
    my $signame=$signal;
    $signame=$1 if($signal =~ /^(.*)\.(\d+)$/);
    $result .= "  <sig name=\"$signame\" ";
    if (exists $$OutHash{signal}{$signal}{val}) {
      my $out=$$OutHash{signal}{$signal}{val};
      $out=~s/\'/&apos;/g;
      $out=~s/\"/&quot;/g;
      $result .= "value=\"$out\" " ;
      $result .= ">\n";			  
    } else {
      $result .= "wdth=\"$$OutHash{signal}{$signal}{wdth}\" " if(defined($$OutHash{signal}{$signal}{wdth})&&
								 ($$OutHash{signal}{$signal}{wdth} ne "")&&
								 ($$OutHash{signal}{$signal}{wdth} ne ":"));
      $result .= "type=\"$$OutHash{signal}{$signal}{type}\" ";
      $result .= ">\n";			  
      ## get info about the source signal with its attributes
      if(defined($$OutHash{signal}{$signal}{src})){
	my @SourceInfo = @{$$OutHash{signal}{$signal}{src}};
	if ($#SourceInfo >= 0)      {
	  if($#SourceInfo > 0){
	    $result .= "    <src blk=\"$SourceInfo[0]\" ";
	    $result .= "pin=\"$SourceInfo[1]\" ";
	    $result .= "wdth=\"$SourceInfo[2]:$SourceInfo[3]\" " if(defined $SourceInfo[2] && $SourceInfo[2] ne "");
	    $result .= "type=\"$SourceInfo[4]\" ";
	    $result .= "dir=\"$SourceInfo[5]\"/>\n";
	  } else {
	    $result .= "    <src val=\"$SourceInfo[0]\"/>";
	  }
	}
      } else {
	logerr("No source information for signal $signal");
      }
    }
    ## get info about the destination signals with their attributes
    if(defined($$OutHash{signal}{$signal}{tgt})){
      my @TgtInfo = @{$$OutHash{signal}{$signal}{tgt}};
      if ($#TgtInfo >= 0) {
	for my $i (0 .. $#TgtInfo){
	  my @target = splice( @{$TgtInfo[$i]} , 0, 6);
	  $result .= "    <tgt blk=\"$target[0]\" ";
	  $result .= "pin=\"$target[1]\" ";
	  $result .= "wdth=\"$target[2]:$target[3]\" " if(defined $target[2] && $target[2] ne "");
	  $result .= "type=\"$target[4]\" " unless ($target[4] eq "");
	  $result .= "dir=\"$target[5]\" />\n";
	}
      }
    }
    $result .= "  </sig>\n";
  }
  return($result);
}

##################################################################################
### write_reg_xml ($)
###
### returns: $result
##################################################################################
sub write_reg_xml($){
  my($rows) = @_;
  my(%reg, $j);
  my $out="";
  my $b0offs=14;
  my $start_section_done=0;
  my (%upper_reg_link);
  # find registers belonging together
  for(my $i=1; $i<=$#$rows; $i++){
    my @cols=@{$rows->[$i]};
    if(defined($cols[1]) && length($cols[1])){
      if(defined $cols[0] && length($cols[0])){
	for(my $j=7; $j<15; $j++){
	  if(defined($cols[$j]) && length($cols[$j]) && $cols[$j]=~/^\s*(\w+)\.(\d+)\s*$/){
	    my $signal=$1;
	    my $upper=$2;
	    my $lower=$2;
	    for(; $j<15; $j++){
	      if(defined($cols[$j]) && length($cols[$j]) && $cols[$j]=~/^\s*$signal\.(\d+)\s*$/){
		$lower=$1;
	      } else {
		last;
	      }
	    }
	    $reg{$signal}{$cols[3].$cols[0]}=[$upper, $lower];
	  }
	}
      } else {
	logerr("No address for line ".($i+1)." defined, generated data may be corrupt!");
      }
    }
  }
  foreach $j (keys %reg){
    my %addr=%{$reg{$j}};
    my @ranges=sort({
		     if(substr($a, 0, 1) ne substr($b, 0, 1)){
		       return(-1) if(substr($a, 0, 1) eq 'W');
		       return(1)  if(substr($b, 0, 1) eq 'W');
		       logerr("Error in sort_regkeys for $a vs. $b");
		     } else {
		       return($reg{$j}{$a}[0]-$reg{$j}{$b}[0]);
		     }
		    } keys(%addr));
    for(my $k=0; $k<$#ranges; $k++){
      $upper_reg_link{lc($j)}{$ranges[$k]}=substr($ranges[$k+1], 1);
    }
  }
  for(my $i=1; $i<=$#$rows; $i++){
    my @cols=@{$rows->[$i]};
    if(defined $cols[1] && length($cols[1])){
      my %signal;
      my $hs;
      unless($start_section_done){
	$out.="  <section name=\"default\">\n";
	$start_section_done=1;
      }
      for(my $j=7; $j<15; $j++){
	next if(!defined $cols[$j] || $cols[$j] eq "");
	if($cols[$j]=~/(\w+)\.(\d+)/){
	  my $sig=lc($1);
	  my $pos=$2;
	  if(exists $signal{$sig}){
	    logdie "Signal mismatch" unless(ref($signal{$sig}->{width}) eq "ARRAY");
	    $signal{$sig}->{width}->[0]=$pos if($signal{$sig}->{width}->[0]<$pos);
	    $signal{$sig}->{width}->[1]=$pos if($signal{$sig}->{width}->[1]>$pos);
	    $signal{$sig}->{pos}->[0]=$b0offs-$j     if($signal{$sig}->{pos}->[0]<$b0offs-$j);
	    $signal{$sig}->{pos}->[1]=$b0offs-$j     if($signal{$sig}->{pos}->[1]>$b0offs-$j);
	  }else{
	    $signal{$sig}={width => [$pos, $pos],
			   pos   => [$b0offs-$j, $b0offs-$j]};
	  }
	}else{
	  my $sig=lc($cols[$j]);
	  $sig=lc($cols[$j]) if($cols[1] eq $cols[2]);
	  if(exists $signal{$sig}){
	    logdie "Signal mismatch!" if(ref($signal{$sig}->{width}) eq "ARRAY");
	  } else {
	    $signal{$sig}={width => 1,
			   pos   => $b0offs-$j};
	  }
	}
      }
      $out.="    <reg addr=\"$cols[0]\" parent=\"$cols[1]\" ais=\"";
      if($cols[17] =~ /a/i){$out.="1";} else {$out.="0";}
      $out.="\" hs=\"";
      if($cols[20] =~ /y/i){$out.="1";} else {$out.="0";}
      $out.="\"";
      $out.=" rdwr=\"$cols[3]\" rst=\"$cols[16]\"";
      $out.=" vsync=\"";
      $out.=$cols[5] if(defined($cols[5]) && $cols[5] ne "NTO");
      $out.="\" used=\"$cols[2]\"";
      my @k=keys(%signal);
      if($#k == 0){
	$out.=" upper=\"$upper_reg_link{$k[0]}{$cols[3].$cols[0]}\"" if(exists($upper_reg_link{$k[0]}{$cols[3].$cols[0]}));
      }
      $out.=">\n";
      foreach my $sig (keys %signal) {
	if(ref($signal{$sig}->{width}) eq "ARRAY"){
	  $out.="      <conn pos=\"".$signal{$sig}->{pos}->[0].":".$signal{$sig}->{pos}->[1].
	    "\" name=\"".uc($sig)."\" wdth=\"".$signal{$sig}->{width}->[0].":".$signal{$sig}->{width}->[1]."\"/>\n";
	} else {
	  $out.="      <conn pos=\"$signal{$sig}->{pos}\" name=\"".uc($sig)."\" wdth=\"$signal{$sig}->{width}\"/>\n";
	}
      }
      if(defined $cols[22] && length($cols[22])){
	$out.="      <rem>".quote_non_ascii($cols[22])."</rem>\n";
      }
      $out.="    </reg>\n";
    } else {
    }
  }
  if($start_section_done){
    $out.="  </section>\n";
  }
  return($out);
}

##################################################################################
### write_pad_xml ($)
###
### returns: $result
##################################################################################
sub write_pad_xml($){
  my($rows) = @_;
  my $out="";
  my (%variants, %packages, $idx);
  for(my $i=1; $i<$#$rows; $i++){
    my @line=@{$rows->[$i]};
    next if($line[2]==0);
    foreach $i (0..CDS::Parser::Table::MAX_MUX_SIZE-1) {
      my $col = 8 + 2*$i;
      next unless(defined($rows->[0]->[$col]));
      my $var=$rows->[0]->[$col];
      if(exists $variants{$var}){
	push(@{$variants{$var}}, [$line[6], $line[$col], $line[$col+1], $line[3], $line[1]]);
      }else{
	$variants{$var}=[[$line[6], $line[$col], $line[$col+1], $line[3], $line[1]]]; #pin name, sig name, dir, pin no, class
      }
    }
  }
  my %type=(S=>'SUPPLY', D=>'DATA', I=>'IN', O=>'OUT', IO=>'IN/OUT', OE=>'OUT/EN');
  foreach my $variant (sort keys %variants){
    $out.="  <variant name=\"$variant\">\n";
    my @pd=(@{$variants{$variant}});
    foreach my $i (@pd){
      my @cols=@{$i};
      my $type="SUPPLY";
      $type=$type{$cols[2]} if(defined($cols[2]) && length($cols[2]));
      $out.="    <pin name=\"$cols[0]\" type=\"$type\" connect=\"X\"";
      $out.=" function=\"$cols[1]\"" if(defined($cols[1]));
      $out.=">\n";
      $out.="      <package name=\"TQFP144\" pinno=\"$cols[3]\" />\n";
      $out.="    </pin>\n";
    }
    $out.="  </variant>\n";
  }
  return($out);
}

##################################################################################
### quote_non_ascii ($)
###
### returns: $result
##################################################################################
sub quote_non_ascii($){
  my $ret="";
  foreach my $i (split(//, $_[0])){
    if($i eq '&'){
      $ret.="&amp;";
    }elsif($i eq '<'){
      $ret.="&lt;";
    }elsif($i eq '>'){
      $ret.="&gt;";
    }elsif($i eq '"'){
      $ret.="&quot;";
    }elsif($i eq '\''){
      $ret.="&apos;";
    }elsif(ord($i)>=128){
      $ret.="&#".ord($i).";";
    }else{
      $ret.=$i;
    }
  }
  return($ret);
}

1;
