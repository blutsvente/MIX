# -*-* perl -*- -w
#  header for MS-Win! Remove for UNIX ...
#!/bin/sh --
#!/bin/sh -- # -*- perl -*- -w
eval 'exec ${PERL:-`[ ! -d "$HOME/bin/perl" -a -x "$HOME/bin/perl" ] && echo "$HOME/bin/perl" || { [ -x /usr/bin/perl ] && echo /usr/bin/perl || echo /usr/local/bin/perl ; } `} -x -S $0 ${1+"$@"} ;'
if 0; # dynamic perl startup; suppress preceding line in perl
#line 6

use strict;
use warnings;
use Cwd;
use File::Basename;
use Getopt::Long qw(GetOptions);
use Pod::Text;
# use diagnostics; # -> will be set by -debug option
# use English;       # -> not need this, just consumes performance

# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright Micronas GmbH, Inc. 2005.                                 |
# |     All Rights Reserved.                                              |
# |                                                                       |
# |                                                                       |
# | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF MICRONAS GMBH          |
# | The copyright notice above does not evidence any actual or intended   |
# | publication of such source code.                                      |
# |                                                                       |
# +-----------------------------------------------------------------------+

# +-----------------------------------------------------------------------+
# | Id           : $Id: address_join.pl,v 1.1 2007/09/04 07:31:30 wig Exp $  |
# | Name         : $Name:  $                                              |
# | Description  : $Description:$                                         |
# | Parameters   : -                                                      | 
# | Version      : $Revision: 1.1 $                                      |
# | Mod.Date     : $Date: 2007/09/04 07:31:30 $                           |
# | Author       : $Author: wig $                                      |
# | Phone        : $Phone: +49 89 54845 7275$                             |
# | Fax          : $Fax: $                                                |
# | Email        : $Email: wilfried.gaensheimer@micronas.com$             |
# |                                                                       |
# | Copyright (c)2005 Micronas GmbH. All Rights Reserved.                 |
# | MIX proprietary and confidential information.                         |
# |                                                                       |
# +-----------------------------------------------------------------------+

# +-----------------------------------------------------------------------+
# |                                                                       |
# | Changes:                                                              |
# | $Log: address_join.pl,v $
# | Revision 1.1  2007/09/04 07:31:30  wig
# | Added %::COL% feature to -outname option. Renamed from vgch_join.
# |
# | Revision 1.10  2006/07/12 15:28:51  wig
# | Updates to reflect changes of db2array interface.
# |
# | Revision 1.9  2006/07/12 15:23:40  wig
# | Added [no]sel[ect]head switch to xls2csv to support selection based on headers and variants.
# |
# | Revision 1.8  2006/05/03 12:10:33  wig
# | Improved top handling, fixed generated format
# |
# | Revision 1.7  2006/04/19 07:39:55  wig
# | 	adress_join.pl : fixed problem with -sheet option
# |
# | Revision 1.6  2006/03/14 08:15:27  wig
# | Change to Log::Log4perl and replaces %EH by MixUtils::Globals.pm
# |
# | Revision 1.5  2005/11/29 09:20:31  wig
# | Support mulitple domain per input sheet.
# |
# | Revision 1.3  2005/10/25 12:14:34  wig
# | Implemented RFE 20051024a.
# |
# | Revision 1.2  2005/10/18 15:27:52  wig
# | Primary releaseable address_join.pl
# |
# | Revision 1.1  2005/10/18 09:35:31  wig
# | Merge register sheets from VGCH project.
# |                                                                |
# |                                                                       |
# +-----------------------------------------------------------------------+

# --------------------------------------------------------------------------

#******************************************************************************
# Other required packages
#******************************************************************************

use FindBin;

use lib "$FindBin::Bin/..";
use lib "$FindBin::Bin/../lib/perl";
use lib "$FindBin::Bin";
use lib "$FindBin::Bin/lib/perl";
use lib getcwd() . "/lib/perl";
use lib getcwd() . "/../lib/perl";

use Log::Log4perl qw(:easy get_logger :levels);

use Micronas::MixUtils qw( mix_init $eh %OPTVAL mix_getopt_header
	convert_in db2array replace_mac);
use Micronas::MixUtils::IO qw(init_ole open_infile write_outfile);
# use Micronas::MixParser;
# use Micronas::MixIOParser;
# use Micronas::MixI2CParser;
# use Micronas::MixWriter;
# use Micronas::MixReport;


##############################################################################
# Prototypes (generated by "grep ^sub PROG | sed -e 's/$/;/'")
#
# functions in here:
sub fix_sheet ($$);
sub get_sheet ($);
sub get_client ($$);
sub parse_address_top ($);
sub replace_macros ($);
sub base_interface ($);
sub blocksplit($$$);

#
#******************************************************************************
# Global Variables
#******************************************************************************

$::VERSION = '$Revision: 1.1 $'; # RCS Id
$::VERSION =~ s,\$,,go;

# Our local variables

#
# Global access to logging and environment
#
if ( -r $FindBin::Bin . '/joinlog.conf' ) {
	Log::Log4perl->init( $FindBin::Bin . '/joinlog.conf' );
} elsif ( -r $FindBin::Bin . '/mixlog.conf' ) {
	Log::Log4perl->init( $FindBin::Bin . '/mixlog.conf' );
}
# Local overload:
if ( -r getcwd() . '/joinlog.conf' ) {
	Log::Log4perl->init( getcwd() . '/joinlog.conf' );
} elsif ( -r getcwd() . '/mixlog.conf' ) {
	Log::Log4perl->init( getcwd() . '/mixlog.conf' );
}

my $logger = get_logger( 'MIX_JOIN' );

#
# Step 0: Init $0
#
mix_init();               # Presets ....



##############################################################################
#
# Step 1: Read arguments, option processing,
#
# parse command line, print banner, print help (if requested),
# set quiet, verbose
#

=head 4 options

Available options for address_join.pl

-dir DIRECTORY            write output data to DIRECTORY (default: cwd())
-out FILENAME				print results into FILENAME
							if out contains "%::block%" (generally: <%::columnname%>),
							create a seperate csv file for each block
							the keyword "%::block%" will be replaced by the actual block name
-conf key.key.key=value   Overwrite $EH->{key}{key}{key} with value
-listconf                 Print out all available/predefined configurations options
-sheet SHEET_RE			  Alternative: select all sheets matching SHEET_RE
-delta                    Enable delta mode: Print diffs instead of full files.
                                  Maybe we can set a return value of 1 if no changes occured!
-strip                    Remove extra worksheets from intermediate output
                                  Please be catious when using that option.
-bak                      Shift previous generated output to file.v[hd].bak. When combined
                                  with -delta you get both .diff, .bak and new files :-)
-top TOP					read top level address information from file TOP
-[no]listtop				print out reworked top sheet (default: no)

=cut

my %xls = ();
my $top = '';

$xls{'top'} = '.*';
$xls{'top_sheet'} = "Sheet1";

# TODO : promote that settings to some other place ...
$xls{'others'} = 'peri.*'; # Take the default.xls config key
$eh->set( 'default.xls', '.*' ); # Read in all sheets ....
$eh->set( 'macro.%UNDEF_1%', '' );
# Remove NL and CR
$eh->set( 'format.csv.style', 'stripnl,doublequote,autoquote,maxwidth' );
$eh->set( 'input.ignore.comments', '::ignany' ); # Skip all lines with s.th. \S in ::ign

# Add your options here ....
mix_getopt_header( qw(
    dir=s
    out=s
    conf|config=s@
    sheet=s@
    top=s
    listtop!
    listconf
    delta!
    strip!
    bak!
    ));

if ( scalar( @ARGV ) < 1 ) { # Need  at least one sheet!!
    $logger->fatal('__F_INPUT_MISS', "\tNo input file specified!\n");
    die();
}

##############################################################################
#
# Step 2: Open input files one by one and retrieve the required tables
# Do a first simple conversion from Excel arrays into array of hashes
#

my %sheets = ();

my $outname = $OPTVAL{'out'} || 'address_joined_register-master.xls';
my $outtype;
my $blocksplit = 0;
if ( $outname =~ m/%(::\w+)%/ ) { # Use this column name to split output
	$blocksplit = $1;
}
if ( $outname =~ m/\.(xls|sxc|ods|csv)/ ) {
	$outtype = $1;
} else {
	$outtype = 'xls';
}

# Assume top is defined as option:
if ( $OPTVAL{'top'} ) {
	$top = $OPTVAL{'top'};
	unshift( @ARGV, $top );
} else {
	# Else it has to be the first argument ... (or the first??)
	$top = $ARGV[0];
}

# GLOBAL variables:
my %all = ( '_COMMON_' => [] );
my $sub_order = '';
my $sub_addr = '';
my $sub_key = '';
my $ignore_flag = 0; # Set if the Ignore line seen once ..

#
# open the top file first,
#   then one after next one ...
#
for my $files ( @ARGV ) {
	# Open all files and retrieve sheet(s)
	my $sel = $eh->get( 'default.xls' );
	my $nosel = $eh->get( 'default.xxls' );
	my $type = 'default';
	
	if ( $files eq $top ) {
		$sel = $xls{'top'};
		$nosel = '';
		$type = 'join';
	}
	my $conn = open_infile( $files,
			$sel, # Select sheets ... default: .* (all)
			$nosel, # Ignore sheets matching $nosel (if set)
			$eh->get( $type . '.req' ) . ',hash' );
		
	# Convert to hashes ...
	for my $sheetname ( keys %$conn ) {
		#!wig20070816: allow to split output files by comment lines like
		my @arrayhash = convert_in ($type, $conn->{$sheetname} );
		$sheets{$files}{$sheetname} = \@arrayhash;
	}

	if ( $files eq $top ) {
		# Find the top sheet -> address_top.xls -> Sheet1
		# Parse all addresses from ::client -> ::sub
		( $sub_order, $sub_addr, $sub_key ) = parse_address_top( $sheets{$top}{$xls{top_sheet}} );
		# sub_order: hash with numbers ...
		# sub_addr: array with more/all infos from top
		# sub_key: hash of arrays: point definitions to matching instances
		next;
	}

	# If the sheets matches a client from the top, print out ...
	for my $s ( keys( %{$sheets{$files}} )) {
		
		# If $optctl{'sheet'} -> try this
		my @topclient = ();
		if ( exists $OPTVAL{'sheet'} and scalar ( @{$OPTVAL{'sheet'}} ) ) {
			# Is this sheetname matched:
			for my $ms ( @{$OPTVAL{'sheet'}} ) {
				if ( $s =~ m/^$ms$/ ) {
					# Hit!
					@topclient = ( -1 );
					last;
				}
			}
			next unless ( scalar( @topclient ) );
		} else {
			@topclient = get_client( $s, $sub_key );
		}
		if ( scalar( @topclient ) < 1 ) {
			$logger->warn( '__W_SHEET_EXTRA', "\tSheet name $s from file $files does not match any client!" );
			push( @{$all{'_COMMON_'}}, { '::ign' => '# # # =:=:=:=> Sheet: ' . $s .
				' from file ' . $files . ' does not match any client !!!' } );
			next;
		}

		# @topclient -> convert into client list
		for my $thisclient ( @topclient ) {
			my $client;
			my $def;
			if ( $thisclient != -1 ) {
				$sub_addr->[$thisclient]{'used'}++; # Increase it ...
				$client	= $sub_addr->[$thisclient];
				$def 	= $client->{'definition'};
				$logger->info( '__I_APPLY_SHEET', "\tApply sheet $s from file $files to client " .
					$client->{'client'} . '(' . $def . ')' );
			} else {
				$client = $sub_addr->[0]; # Has to be defined anyway!!
				$def	= $client->{'definition'};
				# Create dummy client, will be handeled by fix_sheet
				$logger->info( '__I_SHEET_PROCESS', "\tProcess sheet $s from file $files" );
			}
			

			push( @{$all{'_COMMON_'}}, { '::ign' => '# # # =:=:=:=> Sheet: ' . $s . ' from file '
				. $files .
				' for definition of ' . $client->{'client'} . '(' . $def . ')' } );
			my $data = fix_sheet( $client, $sheets{$files}{$s} );
			# if $out has a ::<column>, split $data according to that column
			# push( @all, @$data );
			if ( $blocksplit ) {
				blocksplit( $blocksplit, \%all, $data );
			} else {
				push( @{$all{'_COMMON_'}}, @$data );
			}
			
			# Note this success on the TOP Sheet:
			my $line = $client->{'inputline'};
			$sheets{$top}{$xls{top_sheet}}->[$line]{'::comment'} .=
				'MIX mapped ' . $files . ':' . $s; 
			
		}
		delete( $sheets{$files}{$s} ); # Get rid of this sheet now
	}
	Micronas::MixUtils::IO::mix_utils_io_del_abook ();	# Remove cached data ....
	Micronas::MixUtils::IO::mix_utils_io_create_path();		# create directories
}

#
# Split data into seperate sheets, based on the contents of the $split column
#
sub blocksplit ($$$) {
	my $split	= shift;
	my $allref	= shift;
	my $data	= shift;

	# See if $data->[N]->{$split} exists 
	for my $i ( 0 .. scalar( @$data ) - 1 ) {
		if ( exists( $data->[$i]->{$split} ) ) {
			push( @{$all{$data->[$i]->{$split}}}, $data->[$i] );
		} else {
			push( @{$all{'_REST_BLOCKSPLIT_'}}, $data->[$i] );
		}
	}
}# End of blocksplit

##############################################################################
#
# Step 3: Merge the sheets into one,
#    fix some fields (::sub)
#
#
# Write back the collected data:
#
# Did we get definitions for all data in top:
#  Read out the sub_addr->{'used'}
for my $k ( @$sub_addr ) {
	if ( not exists $k->{'used'} or $k->{'used'} < 1 ) {
		# Never got it
		$logger->warn('__W_MASTER_MISSING', "\tDid not find registermaster for $k->{'client'}");
	}
}

	
# Convert back to table and print out ...

# Print TOP sheet ->
my $end_table = ();

if( $OPTVAL{'listtop'} ) {
	$end_table = db2array( $sheets{$top}{$xls{'top_sheet'}}, 'join', $outtype, '' );
	replace_macros( $end_table );
	my $ton = $outname;
	if ( $blocksplit ) {
		$ton =~ s/%::\w+%/_COMMON_/;
	}
	write_outfile( $ton , 'ADDRESS_TOP', $end_table );
} else {
	# Remove the sheet seperator head ...
	$eh->set( 'format.csv.sheetsep', '' );
}

if ( $blocksplit ) {
	for my $block ( keys %all ) {
		$end_table = db2array( $all{$block}, 'default', $outtype, '');
		replace_macros( $end_table );
		( my $ton = $outname ) =~ s/%::\w+%/$block/;
		write_outfile( $ton, "ADDRESS_TOP $block", $end_table );
	}
} else {
	$end_table = db2array( $all{'_COMMON_'}, 'default', $outtype, '' );
	replace_macros( $end_table );
	write_outfile( $outname , "ADDRESS_TOP", $end_table );
}

# TODO : Rewrite write_sum for this ...
#n my $status = ( write_sum() ) ? 1 : 0; # If write_sum returns > 0 -> exit status 1

# Overall run-time
$logger->info( 'SUM: runtime: ' . ( time() - $eh->get( 'macro.%STARTTIME%' ) ) .
              ' seconds' );

my $status = 0;
exit $status;

#
# Inplace replacement of macros %...%
#
sub replace_macros ($) {
	my $dref = shift;
	
	# Duplicate array
	for my $i ( @$dref ) {
		for my $ii ( @$i ) {
			if ( defined ( $ii ) ) {
				$ii = replace_mac( $ii, $eh->get( 'macro' ) );
			}
		}
	}
} # End of replace_macros

#
# Sum up hex numbers of adresses ...
#!wig20051128: use the ::interface column as additional hint to find the
#		appropriate base address
sub fix_sheet ($$) {
	my $client = shift;
	my $inref = shift;
	
	my $base = hex($client->{'sub'}); # Get it hexadecimal ....
	
	my @outdata = ();
	
	# If 'client' does not match 'definition'
	my $postblock = '';
	if ( $client->{'client'} ne $client->{'definition'} ) {
		# Get diff
		( $postblock = $client->{'client'} ) =~ s/$client->{'definition'}//;
	}	
	for my $i ( @$inref ) {
		
		#!wig20051025: Special for the "Ignore" line ->
		next if ( $i->{'::ign'} =~ m/^Ignore/io and $ignore_flag );
		$ignore_flag++ if ( $i->{'::ign'} =~ m/^Ignore/io );

		#!wig20051128: if ::interface ne client
		my @base_this = ();
		if ( exists( $i->{'::interface'} ) and $i->{'::interface'} and
			$i->{'::interface'} ne $client->{'definition'} ) {
				# Search another definition in "sub" list
				@base_this = base_interface( $i->{'::interface'} );
		} else {
			push( @base_this, $base );
		}		
		push( @outdata, { %$i } ); # Make sure data gets >copied<
		my $sub;
		if ( $i->{'::sub'} =~ m/^(0x)?[0-9a-f]+$/io ) { #Data is in HEX format!
			$sub = hex($i->{'::sub'});
		} else {
			$sub = $i->{'::sub'}; # 
		}

		if ( $postblock ne '' ) {
			if ( exists $outdata[-1]{'::block'} and
					$outdata[-1]{'::block'} ne '' ) {
				$outdata[-1]{'::block'} .= $postblock;
			}
		} 
		# Rewrite ::sub : add base to input ::sub
		if ( $sub =~ m/^\d+$/o and $base_this[0] =~ m/^\d+$/o ) {
			$outdata[-1]{'::sub'} = sprintf( '0x%lx', $sub + $base_this[0]);
		} else {
			$outdata[-1]{'::sub'} = $sub . " + " . $base_this[0];
		}
		
		if ( scalar( @base_this ) > 1 ) {
			# Repeat the last line
			for my $if ( 1..(scalar(@base_this) - 1) ) {
				push( @outdata, { %$i } );
				if ( $sub =~ m/^\d+$/o and $base_this[$if] =~ m/^\d+$/o) {
					$outdata[-1]{'::sub'} = sprintf( '0x%lx', $sub + $base_this[$if]);
				} else {
					$outdata[-1]{'::sub'} = $sub . " + " . $base_this[$if];
				}
			}
		} 
	}
	
	return \@outdata;
} # End of fix_sheet

#
# find base address for another interface ...
# Returns array with potential base addresses.
#
#!! Uses global variables :
#
sub base_interface ($) {
	my $interface = shift;

	my @bases = ();
	if ( exists( $sub_key->{$interface} ) ) {
		for my $i ( @{$sub_key->{$interface}} ) {
			my $sa = $sub_addr->[$i];
			push( @bases, hex($sa->{'sub'}) );
		}
	} else {
		# Print warning:
		$logger->error('__E_SUB_ADDRESS',
			"\tCannot locate sub address for interface $interface");
		push( @bases, '__E_MISS_INTERFACEBASE' );
	}
	
	return @bases;
		
}

#
# Get a matching sheet name:
#
sub get_sheet ($) {
	my $client = shift;

	$client =~ s/^sci_//;
	$client = lc( $client );	
	for my $f ( keys %sheets ) {
		for my $s ( keys %{$sheets{$f}} ) {
			if ( $s =~ m/$client/i ) {
				$logger->info( '__I_SHEET_MATCH', "\tFound sheet $s in file $f for client $client" );
				return ($f, $s);
			}
			# add the sheet name as comment to ::ign

		}
	}
	$logger->warn('__W_SHEET_MATCH', "\tCannot allocate matching sheet for client $client!");
} # End of get_sheet

#
# Get matching top description for a given sheet name
# Key 
# 
# Input:
#	sheetname
#	hash with "definition"
#
# Output:
#	matching definition array
#
sub get_client ($$) {
	my $sheetname	= shift;
	my $topref		= shift;
	# my $topaddr		= shift;

	for my $k ( keys( %$topref ) ) {
		( my $key = lc($k) ) =~ s/sci_//;
		# $key =~ s/_[ms]$//; # Another variant: sheetname is i2c, client i2c_m
		$key =~ s/_shared//; # for mded_peri_shared ...
		if ( $sheetname =~ m/$key$/i ) {# Match a sheet if the name ends correct!
			return @{$topref->{$k}};
		}
	}
	return ();	
}

	
# ::ign	::client ::definition ::group ::group_id ::grp_awidth ::group_addr
#		::subwidth ::sub ::cpu1_addr ::cpu2_addr ::xls_def
# Ignore	Group Description		Instance Name	Definition	Group	ID in Group	Group Address Width	Client Addr Space [kB]	Group Address [hex]	Physical Interconnect Address width	Physical Interconnect  Address [hex]	CPU1 Address [hex]	CPU2 Address [hex]	Contact	Client Definition Xls - Path

sub parse_address_top ($) {
	my $sheet = shift;
	
	# Use array to keep order
	# Additional hash to reference ...
	my @map = ();
	my %map = ();
	my %defmap = ();
	my $n = 0;
	my $l = 0; # Current line
	for my $i ( @$sheet ) {
		$l++;
		next if $i->{'::ign'} =~ m/^\s*#/;
		
		# Get client name (primary key!)
		my $client = $i->{'::client'};
		next if $client =~ m/^\W+$/;
		
		$map{$client} = $n;
		$map[$n]{'client'} = $client;
		$map[$n]{'cpu1'} = $i->{'::cpu1_addr'};
		$map[$n]{'cpu2'} = $i->{'::cpu2_addr'};
		$map[$n]{'definition'} = $i->{'::definition'};
		$map[$n]{'sub'} = $i->{'::sub'};
		$map[$n]{'inputline'} = $l - 1;
	
		push( @{$defmap{$i->{'::definition'}}}, $n );
				
		$n++;
	}

	
	return \%map, \@map, \%defmap;
} # End of parse_address_top
				
#!End
