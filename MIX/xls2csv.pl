# -*-* perl -*- -w
#  header for MS-Win! Remove for UNIX ...
#!/bin/sh --
#!/bin/sh -- # -*- perl -*- -w
eval 'exec ${PERL:-`[ ! -d "$HOME/bin/perl" -a -x "$HOME/bin/perl" ] && echo "$HOME/bin/perl" || { [ -x /usr/bin/perl ] && echo /usr/bin/perl || echo /usr/local/bin/perl ; } `} -x -S $0 ${1+"$@"} ;'
if 0; # dynamic perl startup; suppress preceding line in perl
#line 8
#!/usr/bin/perl -w

#
#******************************************************************************
#
# $Id: xls2csv.pl,v 1.6 2006/04/12 15:37:35 wig Exp $
#
# read in XLS file and print out a csv and and a sxc version of all sheets
#
# (C)2004 wilfried.gaensheimer@micronas.com
#******************************************************************************
#
# Primitive option parsing added: -[no]sxc, -[no]csv
#                    -sep ,  (default: ;)
#                    -sheet 'PERL-RE'
#					 -[no]verbose
#					 -[no]head
#					 -noquotes
#					 -quote X
#                    -[no]single
#                    -[no]accumulate
#					 -column|(c)range A:B,C   select columns (by EXCEL numbering or digit)
#					 -row|rrange N:M		select rows
#					 -matchc "REG_matching header"
#					 -matchr "RE_matching first cell contents in row"
#		Possible ranges are:   A..C,EE-FA,G:I,14,16-70
#			(alpha only for column headers)
#			Repeated options are ORed (tried one after the other)
#			If column or row selector options are set, only matching data will be printed
#
#  Define seperator:
#
# $Log: xls2csv.pl,v $
# Revision 1.6  2006/04/12 15:37:35  wig
# Use new Mix core, added colum and row select options.
#
# Revision 1.5  2005/11/30 14:05:41  wig
# Not changed.
#
# Revision 1.4  2005/04/14 06:53:00  wig
# Updates: fixed import errors and adjusted I2C parser
#
# Revision 1.3  2005/01/26 14:00:33  wig
# added -autoquote option
#
# Revision 1.2  2005/01/21 12:18:27  wig
#
# 	xls2csv.pl - added some options -nohead -noquote ...
#
# Revision 1.1  2005/01/21 11:51:05  wig
#
# 	xls2csv.pl
#
#

use strict;
use warnings;
use Cwd;
use File::Basename;
use Getopt::Long qw(GetOptions);
use Pod::Text;

use FindBin;

# use lib "$FindBin::Bin/..";
use lib "$FindBin::Bin";
use lib "$FindBin::Bin/lib/perl";
use lib "$FindBin::Bin/../lib/perl";
use lib "$FindBin::Bin/../../lib/perl";
use lib './lib/perl';
use lib './../lib/perl';


# use lib "$pgmpath/../../lib/perl";
#!wig20060223: logging made easy -> replacing Log::Agent!
use Log::Log4perl qw(:easy get_logger :levels);

use Micronas::MixUtils qw( $eh %OPTVAL mix_init mix_getopt_header );
use Micronas::MixUtils::IO;

sub convert_selcolumn	($);
sub filter_sheet 		($);
sub set_filenames		($);


#******************************************************************************
# Global Variables
#******************************************************************************

$::VERSION = '$Revision: 1.6 $'; # RCS Id
$::VERSION =~ s,\$,,go;

#
# Global access to logging and environment
#
if ( -r $FindBin::Bin . '/mixlog.conf' ) {
	Log::Log4perl->init( $FindBin::Bin . '/mixlog.conf' );
}
# Local overload:
if ( -r getcwd() . '/mixlog.conf' ) {
	Log::Log4perl->init( getcwd() . '/mixlog.conf' );
}

my $logger = get_logger('XLS2CSV'); # Start with XLS2CSV namespace

mix_init();

$eh->set( 'intermediate.keep', 0 );

#
# xls2csv shares option handling with mix_0.pl now
#
my %opts = (
	'csv' => -1,
	'sxc' => -1,
	'head' => 1,
	# 'verbose' => 1,
	'sep'	=> ';',
	'sheet' => [],
);
# Get our defaults into OPTVAL ...
for my $o ( keys %opts ) {
	$OPTVAL{$o} = $opts{$o};
}

# Add your options here ....
#   (but there are also some generic ones in MixUtils)
#
mix_getopt_header(
qw(
    csv!
    sep=s
    head!
    sxc!
	quote=s
	noquote
	autoq|autoquote
	single!
	accumulate|accu!
	sheet=s@
	column|col|columns|crange|range=s@
	row|rows|rrange=s@
	matchc=s@
	matchr=s@
	
    dir=s
    out=s
    conf|config=s@
    cfg=s
    listconf
    delta!
    bak!
    ));

sub print_usage () {
	print "Usage: $0 <-[no]csv|-[no]sxc> <-sep SEP> <-sheet REGEX> <excel-file> <excel-file2 ...>\n";
	print <<EOM;
	
	Convert ExCEL sheets to csv and/or sxc format.

    Options:
	-[no]csv      Don/t generate CSV formatter file (on by default)
	-[no]sxc      Don/t generate sxc formatted output file (on by default)
	-autoq[uote]  Do quoting the ExCEL style
	-q[uote] X    Use X as quoting char (default: ")
	-sep X        Use X as column seperator (default: ;)
	-noquote      Do not quote the output
	-sheet RE     Select only sheets matching the RE
	-[no]single   Write each sheet into a seperate output csv; extend name by sheet name.
                  Default is to write a single csv and/or sxc file per input excel file with
                  seperating the sheets by the sheet header (see -[no]head). With -single
                  no sheet seperator head will be printed.
	-[no]accu[mulate] Combine all excel files into a sinlge output csv or sxc file.
                  Default is to convert a single csv and/or sxc file per input excel file.
                  Basename is taken from the first excel file name. 
	-[no]head     Do not print sheet seperator head (\"=:=:=:=> SHEETNAME\" by default)
	-[no]verbose  Print more messages
	
	-column|(c)range A:B,C   select columns (by EXCEL numbering or digit)
	-row|rrange N:M		select rows
	-matchc \"REG_matching header\"
	-matchr \"RE_matching first cell contents in row\"
	Possible ranges are:   A..C,EE-FA,G:I,14,16-70
			(alpha only for column headers)
			Repeated options are ORed (tried one after the other)
			If column or row selector options are set, only matching data will be printed

	-conf mix.conf.key=val  Set the global configuration to \"val\". See the mix documentation
	        for a detailed list.

	-delta		Do not overwrite output files, just create the a diff.
EOM

# " for the syntax highlight

	return;
}

if ( $OPTVAL{'help'} ) {
	print_usage;
	exit 0;
}

if ( scalar(@ARGV) < 1 ) {
    $logger->fatal( '__F_BAD_USAGE', "\tUsage: $0 <-[no]csv|-[no]sxc> <-[auto|no]quote>  <-quote X> <-sep SEP> <-nohead> <-[no]verbose> <-sheet REGEX> -single -accu[mulate] <excel-file> ..." );
    die;
}

# If no option -> do both!
if ( $OPTVAL{csv} == -1 and $OPTVAL{sxc} == -1 ) {
	$OPTVAL{csv} = 1;
	$OPTVAL{sxc} = 1;
}
if ( $OPTVAL{csv} == -1 ) {
	$OPTVAL{csv} = 0;
}
if ( $OPTVAL{sxc} == -1 ) {
	$OPTVAL{sxc} = 0;
}

# Did the user specify a filter?
my $filter_flag = 0;



for my $o ( qw( column row matchc matchr ) ) {
	if ( $OPTVAL{$o} ) {
		# Need to normalize the column specific options A:C -> 0..2
		$OPTVAL{$o} = convert_selcolumn( $OPTVAL{$o} );
		$filter_flag = 1;
	}
}

# Take Perl-Regex to match against sheetnames ...
my $sel = '';
if ( scalar( @{$OPTVAL{sheet}} ) ) {
	$sel = '^(' . join( '|', @{$OPTVAL{sheet}} ) . ')$';
}

if ( exists( $OPTVAL{sep} ) ) {
	$eh->set( 'format.csv.cellsep', $OPTVAL{'sep'} ); 
}

unless ( $OPTVAL{head} or not $OPTVAL{single} ) {
	$eh->set( 'format.csv.sheetsep', '' );
}

#
if ( exists( $OPTVAL{noq} ) or exists( $OPTVAL{noquote} ) ) {
	$eh->set( 'format.csv.quoting', '' );
	$eh->set( 'format.csv.style', 'classic' );
} elsif ( exists( $OPTVAL{q} ) ) {
	$eh->set( 'format.csv.quoting', $OPTVAL{q} );
} elsif ( exists( $OPTVAL{quote} ) ) {
	$eh->set( 'format.csv.quoting', $OPTVAL{quote} );
}

# Prepare the place to write to:
mix_utils_io_create_path();

#
# main loop: convert all xls files from input
#
for my $file ( @ARGV ) {

	if( $file !~ m/\.xls/) {
	    $file = $file . '.xls';
	}
	unless( -r $file ) {
		print "WARNING: Cannot read file $file\n";
		next;
	}

	unless( -r $file ) {
	    $logger->error('__E_FILEREAD', "\tCannot read input file $file. Skip it!");
	    next;
	}

	my $oBook = Spreadsheet::ParseExcel::Workbook->Parse($file);
	
	unless( $oBook ) {
	    $logger->fatal('__F_FILEPARSE', "File <$file> not parsed by ParseExcel");
	}
	
	my $sheet;
	my $sname = '';
	my @data = ();
	my $ref;
	
	for(my $i=0; $i<$oBook->{SheetCount}; $i++) {
	
	    $sheet = $oBook->{Worksheet}[$i];
	    $sname = $sheet->{Name};
		my ( $cfile, $sfile ) = set_filenames( $file );	
	
	    if ( $sel and $sname !~ m/$sel/ ){
			$logger->info('__I_SHEET_NONSEL', "\tSheet " . $file . "::" . $sname . " not selected for conversion" ) if ( $OPTVAL{'verbose'} );
			next;
	    }
	
		# Get all data from that file:
	    @data = open_xls($file, $sname, 0);
	    $ref = pop(@data);       # get the first sheet of the name $sname which was found

	    # Filter referenced data:
	    if ( $filter_flag ) {
	    	$ref = filter_sheet( $ref );
	    }
		if ( $OPTVAL{single} ) { # Make unique filename (could be combined with -nohead!)
			( my $snamean = $sname ) =~ s/\W+/_/g; #
			$snamean =~ s/:/_/g;
			$cfile =~ s/\.csv$/--$snamean.csv/;
			$sfile =~ s/\.sxc$/--$snamean.sxc/;
		}
		if ( $eh->get( 'output.generate.delta' ) ) {
			if ( $OPTVAL{csv} ) {
	    		$logger->info('__I_SHEET_DPRINT', "\tPrint out sheet " . $cfile . "::" . $sname );
				write_delta_sheet( $cfile, $sname, $ref );
			}
			if ( $OPTVAL{sxc} ) {
	    		$logger->info('__I_SHEET_DPRINT', "\tPrint out sheet " . $sfile . "::" . $sname );
				write_delta_sheet( $sfile, $sname, $ref );
			}
		} else {
			if ( $OPTVAL{csv} ) {
				$logger->info('__I_SHEET_PRINT', "\tPrint out sheet " . $cfile . "::" . $sname );
				write_csv($cfile, $sname, $ref);
			}
			if ( $OPTVAL{sxc} ) {
				$logger->info('__I_SHEET_PRINT', "\tPrint out sheet " . $sfile . "::" . $sname );
				write_sxc($sfile, $sname, $ref);
			}
		}
	}
} # End of main while loop

sub filter_col ($) {
	my $datar = shift;

	my @result = ();
	# Iterate over all of array
	if ( $OPTVAL{column} ) {	
		for my $line ( @$datar ) {
			my $nelem = scalar( @$line );
			$nelem--;
			my @ltmp = ();	
			for my $r ( @{$OPTVAL{column}} ) {
				# For "rows" it's a simple array copy operation
				$r =~ m/(.+):(.+)/;
				my $f = $1; $f--;
				my $t = $2; $t--;
				next if ( $f > $nelem );
				$t = $nelem  if ( $t > $nelem );
				push( @ltmp, @$line[$f..$t] );
			}
			push( @result, [ @ltmp ] );
		}
	} else { # Take all ...
		@result = @$datar;
	}

	my @result2 = ();
	# Select columns by match (have a look into the first cell)
	if ( $OPTVAL{matchc} ) {
		for my $line ( @result ) {
			for my $m ( @{$OPTVAL{matchc}} ) {
				if ( defined( $line->[0] ) and $line->[0] =~ m/^$m$/ ) {
					# Take it ...
					pushd( @result2, [ $line ] );
				}
			}
		}
	} else { 
		@result2 = @result;
	}
	return \@result2;
} # End of filter_col

#
# Apply column/row filters ...
# fixed order:
sub filter_sheet ($) {
	my $datar = shift;

	# Filter out column data upfront
	if ( $OPTVAL{column} or $OPTVAL{matchc} ) {
		$datar = filter_col($datar);
	}
	
	my $maxr = scalar( @$datar );
	$maxr--; # Array from 0..maxr-1
	my @result = ();
	
	# Apply filters: ROWS
	if ( $OPTVAL{row} ) {
		# take only selected rows:
		for my $r ( @{$OPTVAL{row}} ) {
			# For "rows" it's a simple array copy operation
			$r =~ m/(.+):(.+)/;
			my $f = $1; $f--;
			my $t = $2; $t--;
			next if ( $f > $maxr );
			$t = $maxr  if ( $t > $maxr );
			push( @result, @$datar[$f..$t] );
		}
	} else {
		@result = @$datar;
	}

	my @result2 = ();
	# Select rows by match (have a look into the first cell)
	if ( $OPTVAL{matchr} ) {
		for my $l ( @result ) {
			for my $m ( @{$OPTVAL{matchr}} ) {
				if ( defined( $l->[0] ) and $l->[0] =~ m/^$m$/ ) {
					# Take it ...
					pushd( @result2, [ $l ] );
				}
			}
		}
	} else { 
		@result2 = @result;
	}
	
	return \@result2;	
} # End of filter_sheet


#
# Read in range selector arguments and convert into
# a unique format -> N:M ...
#
# TODO : should we detect overlapping sections? Overlap allows for duplication
#   (It's not a bug, it's a feature :-)
sub convert_selcolumn ($) {
	my $optref = shift;

	my @ranges = ();
	for my $i ( @$optref ) {
		for my $r ( split( /,+/, $i ) ) {
			# Get all parts:
			$r =~ s/\.\./:/g;
			$r =~ s/-/:/g;
			my @collect = ();
			$r =~ s/^:/0:/; # Extend   :N to 0:N
			$r =~ s/:$/:100000000/; # Very, very large number (ExCEL < 64000 )
			for my $s ( split( /:+/, $r ) ) {
				# Convert alpha (A,BB, ZZZ) to num (allow up to three chars)
				if ( $s =~ m/^[a-zA-Z]{1,3}$/ ) {
					$s = Spreadsheet::ParseExcel::Utility::col2int( $s );
					if ( $s > 255 ) { # Just to inform the user:
						$logger->error( '__E_RANGECONV', "\tColumn selector in $r exceeds Excel limit of 255!" );
					}
					$s++; # A -> 0, but we consider column A to be "1"; will be decreased later on
				}
				if ( $s =~ m/^\d+$/ ) {
					push( @collect, $s);
				} else {
					print("ERROR: do not understand value $s in options!\n");
				}
			}
			if ( scalar( @collect ) > 2 ) {
				$logger->error( '__E_RANGECONV', "\tBad range selector $r detected! Skipped!" );
			} elsif ( scalar( @collect ) == 2 ) {
				push( @ranges, join( ':', @collect ));
			} elsif ( scalar( @collect ) == 1 ) {
				push( @ranges, $collect[0] . ':' . $collect[0] );
			} else {
				$logger->error( '__E_RANGECONV', "\rBad range selector $r detected! Skipped!" );
			}
		}
	}
	# Sort by start number
	@ranges = sort( { ( my $c = $a ) =~ s/:.*//; ( my $d = $b ) =~ s/:.*//; $c <=> $d; } @ranges );
	
	return \@ranges;
} # End of convert_selcolumn

#
# Create filenames for csv and sxc
#
sub set_filenames ($) {
	my $file = shift;
	
	my $cfile = 'DEFAULT_' . $file;
	my $sfile = 'DEFAULT_' . $file;
		
	if( $file=~ m/\.xls$/ ) {
		if ( $OPTVAL{'accumulate'} ) {
			unless( $OPTVAL{'_accu_'} ) { # First time only ...
				$OPTVAL{'_accu_'} = $file;
			}
	        ( $cfile = $OPTVAL{'_accu_'} )=~  s/\.xls$/.csv/;
	        ( $sfile = $OPTVAL{'_accu_'} )=~  s/\.xls$/.sxc/;
		} else {
	        ( $cfile = $file )=~  s/\.xls$/.csv/;
	        ( $sfile = $file )=~  s/\.xls$/.sxc/;
		}
	} 
	#wig: what is this for ????
	elsif( $file !~ m/.csv$/) { 
	    $cfile = $file . '.csv';
	    $sfile = $file . '.sxc';
	}

	return( $cfile, $sfile )
}

#!End