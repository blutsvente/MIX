###############################################################################
#  RCSId: $Id: RegUtils.pm,v 1.1 2005/11/16 08:59:09 lutscher Exp $
###############################################################################
#                                  
#  Related Files :  Reg.pm
#
#  Author(s)     :  Thorsten Lutscher                                      
#  Email         :  thorsten.lutscher@micronas.com                          
#
#  Project       :  MIX                                                
#
#  Creation Date :  15.02.2002
#
#  Contents      :  Helper functions for Reg.pm class; contains functions 
#                   which are also useful for other mix tools.
#
###############################################################################
#                               Copyright
###############################################################################
#
#       Copyright (C) 2005 Micronas GmbH, Munich, Germany 
#
#     All rights reserved. Reproduction in whole or part is prohibited
#          without the written permission of the copyright owner.
#
###############################################################################
#                                History
###############################################################################
#
#  $Log: RegUtils.pm,v $
#  Revision 1.1  2005/11/16 08:59:09  lutscher
#  package with helper functions
#
#  
###############################################################################

package Micronas::MixUtils::RegUtils;

#------------------------------------------------------------------------------
# Used packages and exported functions
#------------------------------------------------------------------------------
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw
  (
   _error
   _warning
   _info
   _tie_input_to_constant
   _add_generic
   _add_generic_value
   _add_connection
   _add_primary_input
   _add_primary_output
   _get_signal_type
   _pad_column
   _max
   _pad_str
   _val2hex
  );
use strict;
use Log::Agent;
use Log::Agent::Priorities qw(:LEVELS);
use Micronas::MixParser qw( %hierdb %conndb add_inst add_conn);
use Micronas::MixUtils qw(%EH);

# use FindBin qw($Bin);
# use lib "$Bin";
# use lib "$Bin/..";
# use lib "$Bin/lib";

#------------------------------------------------------------------------------
# Global variables
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# non-OO helper functions
#------------------------------------------------------------------------------

# wrap logwarn for errors
sub _error {
	my @ltxt = @_;
	logwarn("ERROR: ".join("",@ltxt));
	if (defined (%EH)) { $EH{'sum'}{'errors'}++;};				
};

sub _warning {
	my @ltxt = @_;
	logwarn("WARNING: ".join("",@ltxt));
	if (defined (%EH)) { $EH{'sum'}{'warnings'}++;};				
};

sub _info {
	my @ltxt = @_;
	logwarn("INFO: ".join("",@ltxt));
};

# function to create a constant for tying unused inputs
sub _tie_input_to_constant {
	my ($name, $value, $msb, $lsb) = @_;
	my %hconn;
	
	%hconn = ( 
			  '::name' => "tie${value}_".($msb - $lsb + 1),
			  '::out' => "$value",
			  '::in'  => "$name",
			  '::type' => "integer",
			  '::mode' => "C",
			  '::msb' => $msb,
			  '::lsb' => $lsb
			 );
	add_conn(%hconn);
};

# function to add an integer generic/parameter where default value and instantiation value are the same
# note: the name will be generated uniquely by MIX
sub _add_generic {
	my($name, $value, $destination) = @_;
	my %hconn;

	%hconn = (
			  '::name' => "",
			  '::out'  => "%PARAMETER%/$value",
			  '::in'   => "$destination/$name",
			  '::type' => "integer",
			  '::mode' => "P"
			 );
	add_conn(%hconn);
	
	$hconn{'::out'} = "%GENERIC%/$value";
	$hconn{'::mode'} = "G";
	add_conn(%hconn);
};

# function to add an integer generic/parameter with a default value and a instantiation value
# note: the name will be generated uniquely by MIX
sub _add_generic_value {
	my($name, $default, $value, $destination) = @_;
	my %hconn;

	%hconn = (
			  '::name' => "",
			  '::out'  => "%PARAMETER%/$value",
			  '::in'   => "$destination/$name",
			  '::type' => "integer",
			  '::mode' => "P"
			 );
	add_conn(%hconn);
	
	%hconn = (
			  '::name' => "",
			  '::out'  => "%GENERIC%/$default",
			  '::in'   => "$destination/$name",
			  '::type' => "integer",
			  '::mode' => "G"
			 );
	add_conn(%hconn);
};

# function to add a connection
sub _add_connection {
	my($name, $msb, $lsb, $source, $destination) = @_;
	my (%hconn, $src, $dest);	
	
	$hconn{'::name'} = $name;
	$hconn{'::in'} = $destination;
	$hconn{'::out'} = $source;
	#$hconn{'::in'} = $dest;
	#$hconn{'::out'} = $src;
	_get_signal_type($msb, $lsb, 0, \%hconn);
	add_conn(%hconn);
};

# function to add top-level input
sub _add_primary_input {
	my ($name, $msb, $lsb, $destination) = @_;
	my %hconn;
	my $postfix = ($name =~ m/^clk/) ? "" : "%POSTFIX_PORT_IN%";
	
	if ($name =~ m/\%POSTFIX_/g) {
		$hconn{'::name'} = "${name}";
	} else {
		$hconn{'::name'} = "${name}${postfix}"; # add postfix only if not already there
	};
	$hconn{'::in'} = $destination;
	$hconn{'::mode'} = "i";
	_get_signal_type($msb, $lsb, 0, \%hconn);
	add_conn(%hconn);
};

# function to add output to top-level
sub _add_primary_output {
	my ($name, $msb, $lsb, $is_reg, $source) = @_;
	my %hconn;
	my $postfix = ($name =~ m/^clk/) ? "" : "%POSTFIX_PORT_OUT%";
	my $type = $is_reg ? "'reg":"'wire";

	if ($name =~ m/\%POSTFIX_/g) {
		$hconn{'::name'} = "${name}";
	} else {
		$hconn{'::name'} = "${name}${postfix}"; # add postfix only if not already there
	};
	$hconn{'::out'} = $source.$type;
	$hconn{'::mode'} = "o";
	_get_signal_type($msb, $lsb, $is_reg, \%hconn);
	add_conn(%hconn);
};

# function to set ::type, ::high, ::low for add_conn()
sub _get_signal_type {
	my($msb, $lsb, $is_reg, $href) = @_;

	$href->{'::type'} = "";
	if ($msb =~ m/[a-zA-Z_]+/g or $lsb =~ m/[a-zA-Z_]+/g) { # alphanumeric range
		if ($msb eq $lsb) {
			delete $href->{'::high'};
			delete $href->{'::low'};
		} else {
			$href->{'::high'} = $msb;
			$href->{'::low'} = $lsb;
		};
	} else {
		if ($msb == $lsb) { # numeric range
			delete $href->{'::high'};
			delete $href->{'::low'};
		} else {
			$href->{'::high'} = $msb;
			$href->{'::low'} = $lsb;
		};
	};
};

#------------------------------------------------------------------------------
# Pads the specified column $i (0..n) of an array @$lref containing lines with
# whitespaces to align it to the widest column;
# Leading white spaces are added according to indentation level $nindent and
# indentation symbol indent;
# comment lines and empty lines will be skipped;
# Input strings that contain \n must use ^n instead, will later be replaced
#------------------------------------------------------------------------------
sub _pad_column {
	my($col, $indent, $nindent, $lref) = @_;
	my($line, @buf, $max_len, $i);
	
	# get width of widest column
	$max_len = -1;
	foreach $line (@$lref) {
		#$line =~ s/^\s+//;
		if ($line !~ m/^--/ and $line !~ m/^\/\// and $line !~ m/^\#/ and $line !~ m/^\s+/ and $line ne ""){
			# # if $line contains a range, change spaces to '_' to avoid splitting the range
			# $line =~ s/(\s)downto(\s)/_downto_/ig;
			@buf = split(/\s+/, $line);
			if (scalar(@buf) >= $col+1 and $col >= 0) {
				$max_len =  _max($max_len, length($buf[$col]));
			}
		}
	}
	
	# concatenate leading whitespace string
	$indent = $indent x $nindent;
	
	# pad columns with whitespace and insert leading indentation
	$i=0;
	foreach $line (@$lref) {
		if ($line !~ m/^--/ and $line !~ m/^\/\// and $line !~ m/^\#/ and $line !~ m/^\s+/ and $line ne ""){
			$line =~ s/^\s+//;
			# # if $line contains a range, change spaces to '_' to avoid splitting the range
			#$line =~ s/(\s)downto(\s)/_downto_/ig;
			@buf = split(/\s+/, $line);
			if (scalar(@buf) > $col and $col >= 0) {
				_pad_str($max_len, \$buf[$col]);
			}
			$line = "${indent}".join(' ',@buf);
			# $line =~ s/_downto_/ DOWNTO /ig;
			$line =~ s/\^n/\n/g; # replace ^n with \n
			$$lref[$i] = $line; 
		}elsif ($line ne "") {
			$$lref[$i] = "${indent}".$line;
		}
		$i++;
	}
}

# max() - get max value of two values
sub _max {
  my(@c)=@_;
  if ($c[0] >= $c[1]) {
    return $c[0];
  }else {
    return $c[1];
  }
};

# pad_str - add whitespaces to end of str until it has specified size
sub _pad_str {
  my($size, $ref) = @_;
  my($i);
  for ($i=length($$ref); $i < $size; $i++) {
    $$ref = $$ref." ";
  }
  1;
}

# convert a number to hex string (w/o prefix)
{
	my(@ch)=('0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f');

	sub _val2hex {
		my($size, $val)=@_;
		my($result)="";
		my($i);
		
		$size = ($size < 4) ? 4 : $size;
		my($hsize) = (($size+3) >> 2) - 1;
		for ($i=0; $i<=$hsize; $i++) {
			$result = "$ch[$val%16]${result}";
			$val/=16;
		};
		return $result;
	};
};

1;
