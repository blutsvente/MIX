###############################################################################
#  RCSId: $Id: RegUtils.pm,v 1.13 2007/07/25 07:56:25 lutscher Exp $
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
#  Revision 1.13  2007/07/25 07:56:25  lutscher
#  added _add_instance_verilog
#
#  Revision 1.12  2007/06/26 13:02:20  lutscher
#  removed exception for clock ports, postfix is now attached
#
#  Revision 1.11  2007/03/05 18:29:35  lutscher
#  fixed bug in _val2hex, it could not handle negative values
#
#  Revision 1.10  2006/11/20 17:08:12  lutscher
#  added parameters for vr_ad_reg
#
#  Revision 1.9  2006/09/01 15:21:15  lutscher
#  added return value for _add* functions
#
#  Revision 1.8  2006/08/30 08:02:49  lutscher
#  fixed bitwidth calculations
#
#  Revision 1.7  2006/07/06 14:43:53  lutscher
#  added _nxt_pow2() and _ld()
#
#  Revision 1.6  2006/03/14 14:19:30  lutscher
#  changed logger wrap methods
#
#  Revision 1.5  2006/03/14 08:10:33  wig
#  No changes, got deleted accidently
#
#  Revision 1.4  2006/02/15 08:44:02  lutscher
#  changed type for add_conn to always be string
#
#  Revision 1.3  2005/12/09 14:27:26  lutscher
#  reverted change in _add_primary_input()
#
#  Revision 1.2  2005/11/23 13:30:49  lutscher
#  added _get_pragma_pos() and _attach_file_to_list()
#
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
   _fatal
   _debug
   _tie_input_to_constant
   _add_generic
   _add_generic_value
   _add_connection
   _add_primary_input
   _add_primary_output
   _get_signal_type
   _add_instance_verilog
   _pad_column
   _max
   _pad_str
   _val2hex
   _get_pragma_pos
   _attach_file_to_list
   _bitwidth
   _clone_name
  );
use strict;
use Log::Log4perl qw(get_logger);
use Micronas::MixParser qw( %hierdb %conndb add_inst add_conn);
# use Micronas::MixChecker qw(mix_check_case);
# use Micronas::MixUtils qw(%EH);

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

my $logger = get_logger( 'MIX::MixUtils::RegUtils' );
# wrap logwarn for errors
sub _error {
	my @ltxt = @_;
	$logger->error('__E_REG ', join("",@ltxt));			
};

sub _warning {
	my @ltxt = @_;
	$logger->warn('__W_REG ', join("",@ltxt));			
};

sub _info {
	my @ltxt = @_;
	$logger->info('__I_REG ', join("",@ltxt));
};

sub _fatal {
	my @ltxt = @_;
	$logger->fatal('__F_REG ', join("",@ltxt));
};

sub _debug {
	my @ltxt = @_;
	$logger->debug('__D_REG ', join("",@ltxt));
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
			  '::type' => "string",
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
			  '::type' => "string",
			  '::mode' => "P"
			 );
	add_conn(%hconn);

	%hconn = (
			  '::name' => "",
			  '::out'  => "%GENERIC%/$default",
			  '::in'   => "$destination/$name",
			  '::type' => "string",
			  '::mode' => "G"
			 );
	add_conn(%hconn);
};

# function to add a connection, returns signal name
sub _add_connection {
	my($name, $msb, $lsb, $source, $destination) = @_;
	my (%hconn, $src, $dest);	
	
	$hconn{'::name'} = $name;
	$hconn{'::in'} = $destination;
	$hconn{'::out'} = $source;
	_get_signal_type($msb, $lsb, 0, \%hconn);
	add_conn(%hconn);
    return $name;
};

# function to add top-level input, returns port name
sub _add_primary_input {
	my ($name, $msb, $lsb, $destination) = @_;
	my %hconn;
	my $postfix = "%POSTFIX_PORT_IN%";

	if ($name =~ m/\%POSTFIX_/g) {
		$hconn{'::name'} = "${name}";
	} else {
		$hconn{'::name'} = "${name}${postfix}"; # add postfix only if not already there
	};
    # $name = mix_check_case("port", $name);
	$hconn{'::in'} = $destination;
	$hconn{'::mode'} = "i";
	_get_signal_type($msb, $lsb, 0, \%hconn);
	add_conn(%hconn);
    return $hconn{'::name'};
};

# function to add output to top-level, returns port name
sub _add_primary_output {
	my ($name, $msb, $lsb, $is_reg, $source) = @_;
	my %hconn;
	my $postfix = "%POSTFIX_PORT_OUT%";
    my $type = $is_reg ? "'reg":"'wire";

	if ($name =~ m/\%POSTFIX_/g) {
		$hconn{'::name'} = "${name}";
	} else {
		$hconn{'::name'} = "${name}${postfix}"; # add postfix only if not already there
	};
    # $name = mix_check_case("port", $name);
	$hconn{'::out'} = $source.$type;
	$hconn{'::mode'} = "o";
	_get_signal_type($msb, $lsb, $is_reg, \%hconn);
	add_conn(%hconn);
    return $hconn{'::name'};
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
            $href->{'::type'} = "std_logic_vector";
		};
	} else {
		if ($msb == $lsb) { # numeric range
			delete $href->{'::high'};
			delete $href->{'::low'};
		} else {
			$href->{'::high'} = $msb;
			$href->{'::low'} = $lsb;
            $href->{'::type'} = "std_logic_vector";
		};
	};
};

# helper function to call add_inst() - note: there is also a member function of Micronas::Reg of the same name
sub _add_instance_verilog {
	my($name, $parent, $comment, $udc) = @_;
	return add_inst
	  (
	   '::entity' => $name,
	   '::inst'   => '%PREFIX_INSTANCE%%::entity%%POSTFIX_INSTANCE%',
	   '::descr'  => $comment,
	   '::parent' => $parent,
	   '::lang'   => "verilog",
       '::udc'    => $udc
	  );
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
			$result = "$ch[$val & 0xf]${result}";
			$val = $val>>4;
		};
		return $result;
	};
};

# find the position of a pragma in a list of lines
sub _get_pragma_pos {
	my($pragma, $lref) = @_;
	my($i,$result);
	
	$result = -1;
	for ($i=0; $i < scalar(@$lref); $i++) {
		if ($lref->[$i] =~ m/$pragma/i) {
			$result = $i;
		}
	}
	return $result;
};

# _attach_file_to_list()
# Attaches lines in a text-file to a given list
# input: filename
#        list reference
# returns 0 if not successful
sub _attach_file_to_list{
  my($filename,$lref)=@_;
  my($line);

  open(INFILE,"$filename") || return 0;
  while (<INFILE>) {
    push @$lref,$_;
  }
  close(INFILE);
  chomp @$lref;
  1;
};

# returns the number of bits needed to encode <n> values
sub _bitwidth {
    my $n = _ld(shift(@_));
    if ($n<1.0) {
        return 1;
    } else {
        if ($n > int($n)) {
            return int($n+1);
        } else {
            return $n;
        };
    };
};

sub _ld {
	my ($n) = shift(@_);
	return log($n)/log(2);
};

# create a new name according to $pattern
# $pattern - see Globals.pm
# $n_max, $n - maximum number and current number used for replacing %N in pattern
# $domain - string for replacing %D in pattern
# $reg    - string for replacing %R in pattern
# $field  - string for replacing %F in pattern
sub _clone_name {
	my ($pattern, $n_max, $n, $domain, $reg, $field) = @_;
	
	$pattern =~ s/[\'\"]//g; # strip quotes from pattern

    # create a number padded with leading zeros
	my($digits) = $n_max < 10 ? 1 : ($n_max < 100 ? 2 : ($n_max < 1000 ? 3 : 4)); # max 4 digits, should be enough (or we would never have had the Millenium Bug)
	$digits = sprintf("%0${digits}d", $n);

    # take the pattern and fill in the passed object names
	my($name) = $pattern;
    my $uc_domain = uc($domain);
    my $uc_reg= uc($reg);
    my $uc_field = uc($field);
    my $lc_domain= lc($domain);
    my $lc_reg   = lc($reg);  
    my $lc_field = lc($field);
	$name =~ s/%uD/$uc_domain/g;
	$name =~ s/%uR/$uc_reg/g;
	$name =~ s/%uF/$uc_field/g;
	$name =~ s/%lD/$lc_domain/g;
	$name =~ s/%lR/$lc_reg/g;
	$name =~ s/%lF/$lc_field/g;
	$name =~ s/%D/$domain/g;
	$name =~ s/%R/$reg/g;
	$name =~ s/%F/$field/g;
	$name =~ s/%[u|l]*N/$digits/g;
	return $name;
};

1;
