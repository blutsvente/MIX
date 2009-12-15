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
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/CDS/Parser/Table.pm,v 1.1 2003/02/03 13:18:28 wig Exp $                                                         |
# +-----------------------------------------------------------------------+
#
# +-------------------------------------------------------------+
# |                                                             |
# | PROPRIETARY INFORMATION, PROPERTY OF CADENCE DESIGN SYSTEMS |
# |                                                             |
# +-------------------------------------------------------------+
#

package CDS::Parser::Table;
require Exporter;

@CDS::Parser::Table::ISA=qw(Exporter);
@CDS::Parser::Table::EXPORT=qw();
@CDS::Parser::Table::EXPORT_OK=qw(
			  &Parse_Con_Table
			  &Parse_I2C_Table
			  &Parse_Pad_Table
			  &Parse_Hier_Table
			 );

use strict;
use constant MAX_MUX_SIZE => 7;
use constant OFFSET => 0;
use Cwd;

use Log::Agent;
use Log::Agent::Priorities qw(:LEVELS);

####################################################################
##
####################################################################
sub Parse_I2C_Table($$$){
  my ($rows, $OutHash, $dummy)=@_;
  my %signal;
  for(my $i=1; $i<=$#$rows; $i++){
    my @cols=@{$rows->[$i]};
    next if(!defined $cols[1] || $cols[1] eq "");
    next if(defined($cols[1]) && defined($cols[2]) && lc($cols[1]) eq lc($cols[2]));
    # handshaking
    for(my $j=7; $j<15; $j++){
      next if(!defined $cols[$j] || $cols[$j] eq "");
      my ($dir, $src, @tgtnames);
      if($cols[3]=~/R/i){
	$src=$cols[2];
	@tgtnames=($cols[1]);
      } elsif($cols[3]=~/W/i){
	$src=$cols[1];
	@tgtnames=split(/\s*,\s*/, $cols[2]);
      } else {
	logdie "IIC:What mode do you mean in line $i?";
      }
      if($cols[$j]=~/(\w+)\.(\d+)/){
	my $pin=$1;
	my $sig=lc($src)."_".lc($pin);
	my $pos=$2;
	if(exists $signal{$sig}){
	  logdie "IIC: Pin mismatch for pin $cols[$j]" if(ref($signal{$sig}->{wdth}) ne "ARRAY");
	  if($signal{$sig}->{src} ne $src){
	    logdie "IIC: Source block mismatch: $src <-> $signal{$sig}->{src} in line $i (".join("/", @cols).")";
	  }
	  $signal{$sig}->{wdth}->[0]=$pos if($signal{$sig}->{wdth}->[0]<$pos);
	  $signal{$sig}->{wdth}->[1]=$pos if($signal{$sig}->{wdth}->[1]>$pos);
	}else{
	  my @tgts;
	  my $srcpin=lc($pin);
	  $srcpin=lc($pin)."_iic" if($cols[3]=~/R/i);
	  my $tgtpin=lc($pin);;
	  $tgtpin=lc($pin)."_iic" if($cols[3]=~/W/i);
	  foreach my $t (@tgtnames){push(@tgts, [$t, $tgtpin])};
	  $signal{$sig}={ wdth => [$pos, $pos],
			  src => $src,
			  srcpin => $srcpin,
			  tgt => \@tgts,
			  tgtpin => $tgtpin};
	}
      }else{
	my $pin=$cols[$j];
	my $sig=lc($src)."_".lc($cols[$j]);
	my $sigpin=lc($cols[$j])."_iic";
	if(exists $signal{$sig}){
	  logdie "IIC: Pin mismatch for pin $cols[$j]!" if(ref($signal{$sig}->{wdth}) eq "ARRAY");
	  logdie "IIC: Source block mismatch: $src <-> $signal{$sig}->{src} in line $i (".join("/", @cols).")" 
	    if($signal{$sig}->{src} ne $src);
	} else {
	  my @tgts;
	  my $srcpin=lc($pin);
	  $srcpin=lc($pin)."_iic" if($cols[3]=~/R/i);
	  my $tgtpin=lc($pin);
	  $tgtpin=lc($pin)."_iic" if($cols[3]=~/W/i);
	  foreach my $t (@tgtnames){push(@tgts, [$t, $tgtpin])};
	  $signal{$sig}={ wdth => 1,
			  src  => $src,
			  srcpin => $srcpin,
			  tgt  => \@tgts,
			  tgtpin => $tgtpin};
	}
      }
    }
  }
  foreach my $sig (keys(%signal)){
    if(ref($signal{$sig}{wdth}) ne "ARRAY"){
      my $sign=uc($sig);
      if(!exists($$OutHash{signal}{$sign})){
	$$OutHash{signal}{$sign}={type => "std_ulogic",
				  wdth => undef,
				  src  => [uc($signal{$sig}{src}), uc($signal{$sig}{srcpin}), undef, undef, "std_ulogic", "O"],
				  tgt  => []};
      } else {
	$$OutHash{signal}{$sign}{src} = [uc($signal{$sig}{src}), uc($signal{$sig}{srcpin}), undef, undef, "std_ulogic", "O"];
	logtrc(INFO, "Generated I2C signal $sign already exists in interconnect sheet!");
      }
      foreach my $t (@{$signal{$sig}{tgt}}){
	push(@{$$OutHash{signal}{$sign}{tgt}}, [uc($t->[0]), uc($t->[1]), undef, undef, "std_ulogic", "I"]);
      }
    } else {
      foreach(my $i=$signal{$sig}{wdth}[1]; $i<=$signal{$sig}{wdth}[0]; $i++){
	my $sign=uc($sig.".".$i);
	if(!exists($$OutHash{signal}{$sign})){
	  $$OutHash{signal}{$sign}={type => "std_ulogic_vector",
				    wdth => $i.":".$i,
				    src  => [uc($signal{$sig}{src}), uc($signal{$sig}{srcpin}), $i, $i, "std_ulogic_vector", "O"],
				    tgt  => []};
	} else {
	  $$OutHash{signal}{$sign}{src} = [uc($signal{$sig}{src}), uc($signal{$sig}{srcpin}), $i, $i, "std_ulogic_vector", "O"];
	  logerr("Generated I2C Signal $sign already exists in Top-Level Sheet!");
	}
	foreach my $t (@{$signal{$sig}{tgt}}){
	  push(@{$$OutHash{signal}{$sign}{tgt}}, [uc($t->[0]), uc($t->[1]), $i, $i, "std_ulogic_vector", "I"]);
	}
      }
    }
  }
}

##################################################################################
### Parse_Pad_Table ()
###
### returns: $result
##################################################################################

sub Parse_Pad_Table ($$$){
  my ($PadRow, $OutHash, $BlockHash) = @_;
  my (@rows, @list, $pad, @PadL, $level, $entry, $padn, $muxni, $muxno);
  my (%PadH, %MuxH, %DmuxH, $sig_i, $sig_o, $sig_en, $muxlevel, $col, @select_signals);


  ## generate default tie signals
  $$OutHash{signal}{"TIE_ZERO"}{val}    = '\'0\'';
  $$OutHash{signal}{"TIE_ZERO"}{type}   = "std_ulogic";
  $$OutHash{signal}{"TIE_ZERO"}{wdth}   = undef;
  $$OutHash{signal}{"TIE_ZERO"}{tgt}    = [];
  $$OutHash{signal}{"TIE_ONE"}{val}    = '\'1\'';
  $$OutHash{signal}{"TIE_ONE"}{type}   = "std_ulogic";
  $$OutHash{signal}{"TIE_ONE"}{wdth}   = undef;
  $$OutHash{signal}{"TIE_ONE"}{tgt}    = [];

  for my $i (0 ..$#{$PadRow}) {
    $rows[$i] = $PadRow->[$i] if (defined ($PadRow->[$i]));
  }

  @select_signals = @{$rows[0]};

  ## get pad/mux and its connections out of each row
  for(my $i=1; $i<$#rows; $i++)   {
    @list  = @{$rows[$i]};
    next if ($list[0] =~ /^\s*\#\s*$/); # skip comment line
    next unless(defined($list[5]) && length($list[5])); # pad cell has to be defined

    ## remove leading/trailling white spaces
    foreach my $j (0..$#list){
      $list[$j] =~ s/^\s*(\S+)\s*$/$1/;
    }

    ## set pad name
    if ($list[6] =~ /^(.*)\.(\d+)$/) {
      $pad = $1."_".$2;
    }else{
      $pad = $list[6];
    }

    ## create pad
    $padn  = "PAD_".$list[4]."/".$list[5];
    my $padi  = "PAD_".$list[4];

    if (exists $PadH{$padn})  {
      logtrc(WARN, " Warning: Pad $padn already exists");
      # next;
    }
    $PadH{$padn}{dir} = $list[7];
    $PadH{$padn}{sig} = $pad;
    $PadH{$padn}{DO}  = 0 if($list[7] =~ /O/);
    $PadH{$padn}{EN}  = 0 if($list[7] =~ /IO/);

    ## check for identical signal names in all multiplex options
    my $sig_name = $list[8];
    my $sig_mode = $list[9];
    foreach $muxlevel (0..MAX_MUX_SIZE-1) {
      $col = 8 + 2*$muxlevel;
      $sig_name = "" if ($list[$col] ne $sig_name); 
      $sig_mode = "" if ($list[$col+1] ne $sig_mode); 
    }

    if ($sig_name ne "" && $sig_mode ne "") {
      logtrc(INFO, "No mux required for signal $sig_name");
      ## extract signal names
      if ($sig_mode eq 'IO') {
	($sig_i, $sig_o, $sig_en) = split(/\//, $sig_name);
      } elsif ($sig_mode eq 'OE') {
	($sig_o, $sig_en) = split(/\//, $sig_name);
	$sig_i = "";
      } else {
	$sig_i = $sig_name;
	$sig_o = $sig_name;
	$sig_en = "TIE_ONE";
      }
      ## directly connect top-level signals to pad
      if ($sig_mode =~ /I/) {
	unless(exists $$OutHash{signal}{$sig_i}){
	  logerr("Signal $sig_i does not exist");
	}
	$$OutHash{signal}{$sig_i}{type}   = "std_ulogic";
	$$OutHash{signal}{$sig_i}{wdth}   = undef;
	$$OutHash{signal}{$sig_i}{src}    = [uc($padi), "DI", undef, undef,'std_ulogic', 'O'];
      }
      if ($sig_mode =~ /O/) {
	unless(exists $$OutHash{signal}{$sig_o}){
	  logerr("Signal $sig_o does not exist");
	}
	unless(exists $$OutHash{signal}{$sig_en}){
	  logerr("Signal $sig_en does not exist");
	}
	push (@{$$OutHash{signal}{$sig_o}{tgt}}, [uc($padi), "DO", undef, undef, 'std_ulogic', 'I']);
	if ($sig_en eq "TIE_ONE") {
	  $sig_en = $padi . "_EN";
	  $$OutHash{signal}{$sig_en}{type}   = "std_ulogic";
	  $$OutHash{signal}{$sig_en}{wdth}   = undef;
	  $$OutHash{signal}{$sig_en}{src}    = ["BSR", "ONE", undef, undef,'std_ulogic', 'O'];
	}
	push (@{$$OutHash{signal}{$sig_en}{tgt}}, [uc($padi), "EN", undef, undef, 'std_ulogic', 'I']);
	$PadH{$padn}{DO} = 1;
	$PadH{$padn}{EN} = 1;
      }
      next;  ## skip multiplexor generation
    }

    ## create multiplexors
    foreach $muxlevel (0..MAX_MUX_SIZE-1) {

      $col = 8 + 2*$muxlevel;

      if ($list[$col+1] eq 'IO') {
	($sig_i, $sig_o, $sig_en) = split(/\//, $list[$col]);
      } elsif ($list[$col+1] eq 'OE') {
	($sig_o, $sig_en) = split(/\//, $list[$col]);
	$sig_i = "";
      } else {
	$sig_i = $list[$col];
	$sig_o = $list[$col];
	$sig_en = '1';
      }

      $muxni = $sig_i."/INDMUX";
      $muxni =~ s/\.//g;
      $muxno = "MUXO_".$list[4]."/OUTMUX";
      $muxno = "MUXO_".$list[4]."/OUTENMUX" if($list[7] eq "IO");

      if ($list[$col+1] =~ /I/) {
	unless(exists $DmuxH{$muxni}) {
	  $DmuxH{$muxni}{Z} = $sig_i; # block name
	  $DmuxH{$muxni}{S} = [];
	  $DmuxH{$muxni}{C} = [];
	  $DmuxH{$muxni}{P} = $list[4];
	  $DmuxH{$muxni}{N} = "MUXI_".$list[4]."_".$sig_i;
	  $DmuxH{$muxni}{N} =~ s/\.//g;
	  for(my $i=0; $i<MAX_MUX_SIZE; $i++) {
	    $DmuxH{$muxni}{C}[$i] = undef;
	    $DmuxH{$muxni}{S}[$i] = undef;
	  }
	}
	$DmuxH{$muxni}{C}[$muxlevel] = $padi;
	$DmuxH{$muxni}{S}[$muxlevel] = $select_signals[$col];
      }
      if ($list[$col+1] =~ /O/) {
	unless(exists $MuxH{$muxno}) {
	  $MuxH{$muxno}{X} = $padi;
	  $PadH{$padn}{DO} = 1;
	  if($muxno =~ /OUTENMUX$/){
	    $MuxH{$muxno}{Y} = $padi;
	    $PadH{$padn}{EN} = 1;
	  }
	  for(my $i=0; $i<MAX_MUX_SIZE; $i++) {
	    $MuxH{$muxno}{A}[$i] = '0';
	    $MuxH{$muxno}{S}[$i] = '0';
	    $MuxH{$muxno}{E}[$i] = '0';
	  }
	}
	$MuxH{$muxno}{A}[$muxlevel] = $sig_o;  # block name
	$MuxH{$muxno}{S}[$muxlevel] = $select_signals[$col];
	$MuxH{$muxno}{E}[$muxlevel] = $sig_en;
      }
    }  # muxlevel
  } # rows

  ## generate the signals out of the hashes
  ### DMUX HASH
  foreach my $zz (keys %DmuxH) {
    my($inst, $mod)=split(/\//, $zz);
    $$BlockHash{$DmuxH{$zz}{N}}=$mod unless(exists($$BlockHash{$DmuxH{$zz}{N}}));

    #generation of mux2core signals
    my($signal, $signame);
    $signal = $signame = uc($DmuxH{$zz}{Z});
    my($type, $wdth)=("std_ulogic", undef);
    if($signal=~/.*\.(\d+)/){
      $wdth=$1.":".$1;
      $type="std_ulogic_vector";
      $signame=~s/\.//g;
    }
    if(!exists($$OutHash{signal}{$signal})){
      logerr("Signal $signal for inmux connection does not exists, generating dummy signal width no target!");
      $$OutHash{signal}{$signal}{type}   = $type;
      $$OutHash{signal}{$signal}{wdth}   = $wdth;
      $$OutHash{signal}{$signal}{tgt}    = [];
    }
    $$OutHash{signal}{$signal}{src}    = [$DmuxH{$zz}{N}, "Z", undef, undef, 'std_ulogic', "O"];

    for(my $i=0; $i<MAX_MUX_SIZE; $i++){
      #generation of pad2mux signals
      if(defined($DmuxH{$zz}{C}[$i])){
	$signal=$DmuxH{$zz}{C}[$i]."_DI";
	unless(exists $$OutHash{signal}{$signal}){
	  $$OutHash{signal}{$signal}{type}   = "std_ulogic";
	  $$OutHash{signal}{$signal}{wdth}   = undef;
	  $$OutHash{signal}{$signal}{src}    = [uc($DmuxH{$zz}{C}[$i]), "DI", undef, undef,'std_ulogic', 'O'];;
	  $$OutHash{signal}{$signal}{tgt}    = [];
	}
	push (@{$$OutHash{signal}{$signal}{tgt}}, [$DmuxH{$zz}{N}, uc("C_$i"), undef, undef, 'std_ulogic', 'I']);
      } else {
	$signal = "TIE_ZERO";
	push (@{$$OutHash{signal}{$signal}{tgt}}, [$DmuxH{$zz}{N}, uc("C_$i"), undef, undef, 'std_ulogic', 'I']);
      }
      #generation of mux select signals
      if(defined($DmuxH{$zz}{S}[$i])){
	$signal = "TEST_SEL_".uc($DmuxH{$zz}{S}[$i]);
	unless (exists $$OutHash{signal}{$signal}) {
	  $$OutHash{signal}{$signal}{type}   = "std_ulogic";
	  $$OutHash{signal}{$signal}{wdth}   = undef;
	  $$OutHash{signal}{$signal}{src}    = ["MODSEL", uc($DmuxH{$zz}{S}[$i]), undef, undef, 'std_ulogic', 'O'];;
	  $$OutHash{signal}{$signal}{tgt}    = [];
	}
	push (@{$$OutHash{signal}{$signal}{tgt}}, [$DmuxH{$zz}{N}, uc("S_$i"), undef, undef, 'std_ulogic', 'I']);
      } else {
	$signal = "TIE_ZERO";
	push (@{$$OutHash{signal}{$signal}{tgt}}, [$DmuxH{$zz}{N}, uc("S_$i"), undef, undef, 'std_ulogic', 'I']);
      }
    }
  }
  ### MUX HASH
  foreach my $zz (keys %MuxH) {
    #generation of mux2pad data signals
    my ($inst,$mod)=split(/\//, $zz);
    $$BlockHash{$inst}=$mod unless(exists($$BlockHash{$inst}));
    my $signal=uc($MuxH{$zz}{X})."_DO";
    unless(exists $$OutHash{signal}{$signal}){
      $$OutHash{signal}{$signal}{type}   = "std_ulogic";
      $$OutHash{signal}{$signal}{wdth}   = undef;
      $$OutHash{signal}{$signal}{src}    = [uc($inst), 'X', undef, undef, 'std_ulogic', 'O'];;
      $$OutHash{signal}{$signal}{tgt}    = [];
    }
    push (@{$$OutHash{signal}{$signal}{tgt}}, [uc($MuxH{$zz}{X}), "DO", undef, undef, 'std_ulogic', 'I']);
    #generation of mux2pad enable signals
    if(exists($MuxH{$zz}{Y})){
      $signal=$MuxH{$zz}{Y}."_EN";
      unless(exists $$OutHash{signal}{$signal}){
	$$OutHash{signal}{$signal}{type}   = "std_ulogic";
	$$OutHash{signal}{$signal}{wdth}   = undef;
	$$OutHash{signal}{$signal}{src}    = [uc($inst), 'Y', undef, undef, 'std_ulogic', 'O'];;
	$$OutHash{signal}{$signal}{tgt}    = [];
      }
      push (@{$$OutHash{signal}{$signal}{tgt}}, [uc($MuxH{$zz}{Y}), "EN", undef, undef, 'std_ulogic', 'I']);
    }
    for(my $n=0; $n<MAX_MUX_SIZE; $n++){
      #generation of mux2core signals
      if ($MuxH{$zz}{A}[$n] eq '0') {
	push (@{$$OutHash{signal}{TIE_ZERO}{tgt}}, [uc($inst), "A_${n}", undef, undef, 'std_ulogic', 'I']);
      } else {
	my $signal = uc($MuxH{$zz}{A}[$n]);
	my($type, $wdth)=("std_ulogic", undef);
	if($signal=~/.*\.(\d+)/){
	  $wdth=$1.":".$1;
	  $type="std_ulogic_vector";
	}
	unless (exists $$OutHash{signal}{$signal}) {
	  logerr("Signal $signal for outmux connection does not exists, generating dummy signal width no source!");
	  $$OutHash{signal}{$signal}{type}   = $type;
	  $$OutHash{signal}{$signal}{wdth}   = $wdth;
	  $$OutHash{signal}{$signal}{src}    = [];
	  $$OutHash{signal}{$signal}{tgt}    = [];
	}
	push (@{$$OutHash{signal}{$signal}{tgt}}, [uc($inst), "A_${n}", undef, undef, 'std_ulogic', 'I']);
      }
      #generation of select signals
      my $pin    = uc($MuxH{$zz}{S}[$n]);
      my $signal;
      if($pin eq '0'){
	$signal = "TEST_SEL_ZERO";
	unless(exists $$OutHash{signal}{$signal}) {
	  $$OutHash{signal}{$signal}{type}   = "std_ulogic"; 
	  $$OutHash{signal}{$signal}{val}    = '\'0\'';
	  $$OutHash{signal}{$signal}{wdth}   = undef;
	  $$OutHash{signal}{$signal}{tgt}    = [];
	}
	push (@{$$OutHash{signal}{$signal}{tgt}}, [uc($inst), "S_${n}", undef, undef, 'std_ulogic', 'I']);
      }else {
	$signal = uc("TEST_SEL_$pin");
	unless(exists $$OutHash{signal}{$signal}) {
	  $$OutHash{signal}{$signal}{type}   = "std_ulogic"; 
	  $$OutHash{signal}{$signal}{wdth}   = undef;
	  $$OutHash{signal}{$signal}{src}    = ["MODSEL", $pin, 1, 1, 'std_ulogic', 'O'];
	  $$OutHash{signal}{$signal}{tgt}    = [];
	}
	push (@{$$OutHash{signal}{$signal}{tgt}}, [uc($inst), "S_${n}", undef, undef, 'std_ulogic', 'I']);
      }
      #generation of enable signals
      if($MuxH{$zz}{E}[$n] eq '0'){
	$signal ="TIE_ZERO";
      } elsif($MuxH{$zz}{E}[$n] eq '1') {
	$signal = "TIE_ONE";
      } else {
	$signal = $MuxH{$zz}{E}[$n];
      }
      unless (exists $$OutHash{signal}{$signal}) {
	$$OutHash{signal}{$signal}{type}   = "std_ulogic";
	$$OutHash{signal}{$signal}{val}    = $MuxH{$zz}{E}[$n], ;
	$$OutHash{signal}{$signal}{wdth}   = undef;
	$$OutHash{signal}{$signal}{tgt}    = [];
      }
      push (@{$$OutHash{signal}{$signal}{tgt}}, [uc($inst), "E_${n}", undef, undef, 'std_ulogic', 'I']);
    }
  }

  ### PAD HASH
  my $border = "TOPLEVEL_UNIT";
  foreach my $zz (keys %PadH) {
    my ($ipad, $epad)=split(/\//, $zz);
    $$BlockHash{$ipad}=$epad unless(exists($$BlockHash{$ipad}));
    my $signal = uc($PadH{$zz}{sig});
    $signal =~ s/^(.*)\.(\d+)/$1_$2/;
    #generation of chiplevel signals
    $$OutHash{signal}{$signal}{type}   = "std_logic";
    $$OutHash{signal}{$signal}{wdth}   = undef;
    $$OutHash{signal}{$signal}{tgt}    = [];
    if ($PadH{$zz}{dir} =~ /^I/) {
      my $idir='I';
      $idir='IO' if ($PadH{$zz}{dir} =~ /IO/);
      my $odir='O';
      $odir='IO' if ($PadH{$zz}{dir} =~ /IO/);
      $$OutHash{signal}{$signal}{src}=[uc($border), uc($signal), undef, undef, 'std_logic', $odir];
      push (@{$$OutHash{signal}{$signal}{tgt}}, [uc($ipad), "PAD", undef, undef, 'std_ulogic', $idir]);
    } elsif ($PadH{$zz}{dir} =~ /^O/) {
      $$OutHash{signal}{$signal}{src}=[uc($ipad), "PAD", undef, undef, 'std_ulogic', 'O'];
      push (@{$$OutHash{signal}{$signal}{tgt}}, [uc($border), uc($signal), undef, undef, 'std_logic', 'I']);
    }
    #connect open pins
    foreach my $t ("DO", "EN"){
      if(exists($PadH{$zz}{$t}) && $PadH{$zz}{$t}==0){
	$signal = "TIE_ZERO";
	push (@{$$OutHash{signal}{$signal}{tgt}}, [uc($zz), uc($t), undef, undef, 'std_ulogic', 'I']);
      }
    }
  }
}

####################################################################
## Parse_Con_Table()
##
## returns: $OutRef
####################################################################

sub Parse_Con_Table($$$){
  my($RowRef,$OutHash, $BlockHash) = @_;
  my(@rows, @line, @emptycol, $inst, $modul);
  ## load row out of the reference
  for my $i (0..$#{$RowRef}) {
    $rows[$i] = $RowRef->[$i];
  }

  ## get all modules out of this line
  foreach my $entry (@{$rows[OFFSET]}) {
    next if (($entry eq 'Top-Level') || ($entry eq 'CHIPLEVEL') || ($entry eq ''));
    if ($entry =~ /(\w+)\/(\w+)/) {
      $inst   = uc($1);
      $modul  = uc($2);
    } else {
      $modul = $inst = $entry;
    }
    if ($entry =~ /\#/) {
      logwarn("Instance $inst commented out, it will be ignored!\n");
    } else {  
      # check if this module already exists
      if (exists $$BlockHash{$inst}) {
	die " module already exists, please check module name $inst ($entry)!\n";
      } else {
	$$BlockHash{$inst} = $modul unless (exists $$BlockHash{$inst});
      }
    }
  }

  ## check row by row for signals and their information
  for (my $i=2+OFFSET; $i<=$#rows; $i++) {
    my(@PinL, @sig);
    my $has_driver=0;
    my $type="std_ulogic";
    @line=@{$rows[0]};
    my @blocks=@line[8..$#line];
    @line=@{$rows[$i]};
    ## ignore empty rows
    next if($#line<0);
    ## ignore rows with certain information not containing signals
    next if($line[1]=~/^(GRP)/);
    ## get signal information
    @sig=splice(@line, 0, 8);
    #fill HSig hash
    my $Signal = uc($sig[7]);
    $Signal=~s/^\s*(\S+)\s*$/$1/;
    $type = $sig[2] if (defined($sig[2]));
    if ($sig[0] =~ /^TIE/) {
      unshift(@PinL, [$sig[1]]) ;
      $has_driver=1;
    }
    my $idx=0;
    my $jdx=0;
    ## get source/destination information, loops over the rest of row
    while ($#line>0) {
      my $pins=splice(@line, 0, 1);
      my ($block,$ref)=split(/\//, splice(@blocks, 0, 1));
      next if ($block =~ /\#/);
      next if ((!defined $pins) or ($pins eq ""));

      ## cuts out information block wise and
      # gets signal information for the actual block
      $pins =~ s/\n//;
      my @pinlist = split(/,/, $pins);
      if ($#pinlist > 0) {
      	logtrc(INFO, "$Signal connected to pins: $pins of instance $block\n");
      }
      foreach my $pin (@pinlist) {
	my ($port, $mode) = split(/\//,$pin);
	my ($name, $high, $low);
	if ($port =~ /(\w+)\((\d+):(\d+)\)/) {
	  $name=$1; $high=$2; $low=$3;
	} elsif ($port =~ /(\w+)\((\d+)\)/) {
	  $name=$1; $high=$low=$2;
	} else {
	  $name=$port; $high=$low=undef;
	}
	my @PortInfo=($block, $name, $high, $low, $type, $mode);
	# and checks if the information is input, output, I/O
      SWITCH:
	{
	  $PortInfo[5] =~ /^\s*I\s*$/ && do 	{
	    push(@PinL, \@PortInfo);
	    last SWITCH;
	  };
	  $PortInfo[5] =~ /^\s*O\s*$/ && do 	{
	    unshift(@PinL, \@PortInfo);
	    $has_driver=1;
	    last SWITCH;
	  };
	  $PortInfo[5] =~ /^\s*I\/O\s*$/ && do 	{
	    unshift(@PinL, \@PortInfo);
	    $has_driver=1;
	    last SWITCH;
	  };
	}
	$idx++; $jdx++;
      }                         # pinlist
    }				# line
    if ($#PinL>=0) {
      if (defined($sig[3]) && $sig[3]=~/^\s*\d+\s*$/ &&
	  defined($sig[4]) && $sig[4]=~/^\s*\d+\s*$/ ) {
	# bit blast busses
	foreach my $p (@PinL) {
	  # set ranges of pins to range high
	  if (defined $p->[2] && $p->[2]=~/^\s*\d+\s*$/) {
	    # range defined, set both to upper
	    $p->[3]=$p->[2];
	  } else {
	    # range taken from signal
	    $p->[3]=$p->[2]=$sig[3];
	    logsay("Range adapted for Signal $Signal");
	  }
	}
	my $SrcInfoR = shift(@PinL) if($has_driver);
	for (my $x=$sig[3]; $x>=$sig[4]; $x--) {
	  # run thru all indices of the signal range
	  my $Sig=$Signal.".".$x;
	  $$OutHash{signal}{$Sig}{wdth}  = "$x:$x";
	  $$OutHash{signal}{$Sig}{type}  = $type; 
	  if (defined $SrcInfoR) {
	    print "$Signal: @{ $PinL[0] } , @{ $PinL[1] } \n" unless ref($SrcInfoR) eq 'ARRAY';
	    my @SrcInfo = @{$SrcInfoR};
	    if ($#SrcInfo ==5) {
	      @{$$OutHash{signal}{$Sig}{src}}  = ($SrcInfo[0],$SrcInfo[1],
						  $SrcInfo[2],$SrcInfo[3],
						  $SrcInfo[4],$SrcInfo[5]);
	      # count range down
	      $SrcInfoR->[3]--;
	      $SrcInfoR->[2]--;
	    } else {
	      $SrcInfo[0]=~s/^\s*(\S+)\s*$/$1/g;
	      $$OutHash{signal}{$Sig}{val}  = $SrcInfo[0];
	    }
	  }
	  foreach my $p (@PinL) {
	    my @TgtInfo=@{$p};
	    push(@{$$OutHash{signal}{$Sig}{tgt}}, \@TgtInfo);
	    # count range down
	    $p->[3]--;
	    $p->[2]--;
	  }
	}
      } else {
	$$OutHash{signal}{$Signal}{type}  = $type; 
	if ($has_driver) {
	  my @SourceInfo = @{shift(@PinL)};
	  if ($#SourceInfo ==5) {
	    @{$$OutHash{signal}{$Signal}{src}} = ($SourceInfo[0],$SourceInfo[1],
						  $SourceInfo[2],$SourceInfo[3],
						  $SourceInfo[4],$SourceInfo[5]);
	  } else {
	    $SourceInfo[0]=~s/^\s*(\S+)\s*$/$1/g;
	    $$OutHash{signal}{$Signal}{val}  = $SourceInfo[0];
	  }
	}
	$$OutHash{signal}{$Signal}{tgt} = \@PinL if($#PinL>=0);
      }
    }				# line
  }				# rows
}

########################################################
sub findMuxes($){
  my($BlockHash)=@_;
  my(@muxes, @l);
  foreach my $i (keys %$BlockHash){
    if($i=~/^MUX[IO]_(\d+)/){
      my $idx=$1;
      if(defined $l[$idx]){
	push(@{$l[$idx]}, $i);
      } else {
	$l[$idx]=[$i],
      }
    }
  }
  for(my $i=0; $i<=$#l; $i++){
    push(@muxes, $l[$i]) if(defined($l[$i]));
  }
  return(@muxes);
}

##################################################################################
### write_con_xml ()
###
### returns: $result
##################################################################################

sub Parse_Hier_Table($$$$){
  my ($Hier,$OutHash,$BlockHash,$design) = @_;
  ## filling output hash
  $$OutHash{design} = $design;
  #### add hierarchy info and fill hash for top and unit information
  # add modules defined in up to now
  foreach my $inst (keys %$BlockHash){
    my $mod = $$BlockHash{$inst};
    next if($mod =~/^\s*$/); # target/source modules of the padsheet should be already defined
    next if(exists $$OutHash{modul}{$mod});
    $$OutHash{modul}{$mod}{loc}   = ".";
  }
  my $topic='top';
  ## get unit and its modules out of each row
  for(my $i=1; $i<=$#{$Hier}; $i++) {
    next unless defined ($Hier->[$i]);
    next unless defined ($Hier->[$i]->[0]);
    my @col = @{$Hier->[$i]};
    my $unit = shift(@col);
    $$OutHash{$topic}{$unit}{loc} = ".";
    $$OutHash{$topic}{$unit}{inst}=[];
    ## check if all modules are implemented
    logwarn("Module $unit defined as hierarchical and functional unit!") if(exists($$OutHash{modul}{$unit}));
    foreach my $i (@col){
      next unless defined($i);
      my ($inst, @dummy)=split(/\//, $i);
      if ($inst =~ /\@(\w+)/){
	my $metablock = $1;
	if ($metablock =~ /mux(\d)/i) {
	  my $num = $1;
	  my $munit = "MUXFRAME";
	  push(@{$$OutHash{$topic}{$unit}{inst}} , $munit);
	  my @muxes=findMuxes($BlockHash);
	  $$OutHash{$topic}{$munit}{inst}=[];
	  #now create the mux blocks according to $num
	  my $musize = ($#muxes + 1)/$num;
	  $musize = (int($musize) + 1) if ($musize gt (int($musize)));
	  for my $n (1..$num) {
	    my $muxunit = "MUXUNIT".$n;
	    push(@{$$OutHash{$topic}{$munit}{inst}}, $muxunit);
	    $$OutHash{$topic}{$muxunit}{loc} = ".";
	    $$OutHash{$topic}{$muxunit}{inst}=[];
	    # instantiate the mux blocks
	    for my $i (1..$musize) {
	      next if ($#muxes == -1);
	      foreach my $mux (@{shift(@muxes)}){
		push(@{$$OutHash{$topic}{$muxunit}{inst}}, $mux);
	      }
	    }
	  }
	} elsif($metablock =~ /pad/i) {
	  my @pads=grep(/^PAD_/, keys(%$BlockHash));
	  push(@{$$OutHash{$topic}{$unit}{inst}}, sort(@pads));
	} else {
	  logerr("Unsupported metablock ($metablock) found.");
	}
      } else {
#	logerr("Inst $inst only defined in hierarchy, skipped") unless(exists($$BlockHash{$inst}));
	push(@{$$OutHash{$topic}{$unit}{inst}}, $inst);
      }
    }
    $topic='unit';
  }
}


1;
