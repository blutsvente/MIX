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
# $Id: xls2csv.pl,v 1.12 2006/07/19 07:34:08 wig Exp $
#
# read in XLS file and print out a csv and and a sxc version of all sheets
#
# (C)2004 wilfried.gaensheimer@micronas.com
#******************************************************************************
#
# Primitive option parsing added: -[no]sxc, -[no]csv
#                    -sep ,  (default: ;)
#                    -sheet 'PERL-RE'
#					 -xsheet 'RE'
#					 -[no]verbose
#					 -[no]head
#					 -noquotes
#					 -quote X
#                    -[no]single
#                    -[no]accumulate
#					 -sel[ect]head [::]A,[::B.*]
#							select columns based on MIX header ::names matching ::A or ::B.*
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
# Revision 1.12  2006/07/19 07:34:08  wig
# Added new output sort order.
#
# Revision 1.10  2006/07/12 15:23:41  wig
# Added [no]sel[ect]head switch to xls2csv to support selection based on headers and variants.
#
# Revision 1.9  2006/05/16 12:13:11  wig
# Added documentation.
#
# Revision 1.8  2006/05/16 12:02:13  wig
# Added -xsheet <exclude_re>
#
# Revision 1.7  2006/04/19 07:35:27  wig
# Added formet.csv.sortrange config parameter.
#
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

use Micronas::MixUtils qw( $eh %OPTVAL mix_init mix_getopt_header
		convert_in db2array select_variant);
use Micronas::MixUtils::IO;

sub convert_selcolumn	($);
sub filter_sheet 		($);
sub filter_col			($);
sub set_filenames		($);
sub parse_selheadopt	($);
sub selbyhead				($$);

#******************************************************************************
# Global Variables
#******************************************************************************

$::VERSION = '$Revision: 1.12 $'; # RCS Id
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
	'xsheet' => [],
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
	xsheet=s@
	column|col|columns|crange|range=s@
	row|rows|rrange=s@
	matchc=s@
	matchr=s@
	selhead|colhead|selecthead=s@
	noselhead|nocolhead|noselecthead=s@
	variant=s
    dir=s
    out=s
    conf|config=s@
    cfg=s
    listconf
    delta!
    bak!
    ));

=head1 XLS2CSV XLS to CSV/SXC CONVERTER

    Usage: xls2csv.pl B<-[no]csv|-[no]sxc> B<-sep SEP> B<-sheet REGEX>
    	<-xsheet REGEX> <excel-file> <excel-file2 ...>\n
	
	Convert ExCEL sheets to csv and/or sxc format.

    Options:
	-[no]csv      Don/t generate CSV formatter file (on by default)
	-[no]sxc      Don/t generate sxc formatted output file (on by default)
	-autoq[uote]  Do quoting the ExCEL style
	-q[uote] X    Use X as quoting char (default: ")
	-sep X        Use X as column seperator (default: ;)
	-noquote      Do not quote the output
	-sheet RE     Select only sheets matching the RE (default: select all sheets)
	-xsheet RE	  Exclude sheets matching RE (default: no sheet excluded)
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
			The column and row selectors will be sorted unless format.csv.sortrange is set
			to 0 on the commandline.

	-sel[ect]head [::]A,[::]B.*
						select columns based on MIX header ::names matching ::A or ::B.*
	-nosel[ect]head [::]C,[::]D.*
						remove columns matching the arguments here
	-variant A		select only rows, which ::variants column matches "A"
	-conf mix.conf.key=val  Set the global configuration to \"val\". See the mix documentation
	        for a detailed list.

	-delta		Do not overwrite output files, just create the a diff.

=cut

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
my $xsel = '';
if ( scalar( @{$OPTVAL{sheet}} ) ) {
	$sel = '^(' . join( '|', @{$OPTVAL{sheet}} ) . ')$';
}
if ( scalar( @{$OPTVAL{xsheet}} ) ) {
	$xsel = '^(' . join( '|', @{$OPTVAL{xsheet}} ) . ')$';
}

if ( exists( $OPTVAL{sep} ) ) {
	$eh->set( 'format.csv.cellsep', $OPTVAL{'sep'} ); 
}

if ( $OPTVAL{single} ) {
	if ( not $OPTVAL{head} ) {
		$eh->set( 'format.csv.sheetsep', '' );
		$eh->set( 'format.csv.mixhead', 0 );
		$eh->set( 'format.sxc.mixhead', 0 );
		$eh->set( 'format.ods.mixhead', 0 );
	}
} else {
	if ( not $OPTVAL{head} ) {
		$eh->set( 'format.csv.sheetsep', '' );
				$logger->info( '__I_', "Multiple sheets will not be seperated in CVS files by MIX header!" );
		$eh->set( 'format.csv.mixhead', 0 );
		$eh->set( 'format.sxc.mixhead', 0 );
		$eh->set( 'format.ods.mixhead', 0 );
	}
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
# Currently: handle each sheet on it's own seperate!
for my $file ( @ARGV ) {

	if( $file !~ m/\.xls/) {
	    $file = $file . '.xls';
	}

	unless( -r $file ) {
	    $logger->error('__E_FILEREAD', "\tCannot read input file $file. Skip it!");
	    next;
	}

	my $oBook = Spreadsheet::ParseExcel::Workbook->Parse($file);
	
	unless( $oBook ) {
	    $logger->fatal('__F_FILEPARSE', "File <$file> not parsed by ParseExcel");
	    exit 1;
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
			$logger->info('__I_SHEET_NONSEL', "\tSheet " . $file . '::' . $sname . ' not selected for conversion' ) if ( $OPTVAL{'verbose'} );
			next;
	    }
	    if ( $xsel and $sname =~ m/$xsel/ ) {
	    	$logger->info('__I_SHEET_XSEL', "\tSheet " . $file . '::' . $sname . ' excluded' ) if ( $OPTVAL{'verbose'} );
			next;
	    }
	
		# Get all data from that sheet:
	    @data = open_xls($file, $sname, '', 0);
	    $ref = pop(@data);       # get the first sheet of the name $sname which was found

	    # Filter referenced data:
	    # Apply column and row filter first
	    if ( $filter_flag ) {
	    	$ref = filter_sheet( $ref );
	    }

		# If -selhead is active, convert input data to arrayhash format,
		#   do the filtering and print out the rest
		$ref = selbyhead( $ref, $sname );
			
		if ( $OPTVAL{single} ) { # Make unique filename (could be combined with -nohead!)
			( my $snamean = $sname ) =~ s/\W+/_/g; #
			$snamean =~ s/:/_/g;
			$cfile =~ s/\.csv$/--$snamean.csv/;
			$sfile =~ s/\.sxc$/--$snamean.sxc/;
		}
		if ( $eh->get( 'output.generate.delta' ) ) {
			if ( $OPTVAL{csv} ) {
	    		$logger->info('__I_SHEET_DPRINT', "\tPrint out sheet " . $cfile . '::' . $sname );
				write_delta_sheet( $cfile, $sname, $ref );
			}
			if ( $OPTVAL{sxc} ) {
	    		$logger->info('__I_SHEET_DPRINT', "\tPrint out sheet " . $sfile . '::' . $sname );
				write_delta_sheet( $sfile, $sname, $ref );
			}
		} else {
			if ( $OPTVAL{csv} ) {
				$logger->info('__I_SHEET_PRINT', "\tPrint out sheet " . $cfile . '::' . $sname );
				write_csv($cfile, $sname, $ref);
			}
			if ( $OPTVAL{sxc} ) {
				$logger->info('__I_SHEET_PRINT', "\tPrint out sheet " . $sfile . '::' . $sname );
				write_sxc($sfile, $sname, $ref);
			}
		}
	}
} # End of main while loop

#
# select/deselect lines based on ::header lines
#  and -variants switch
#
# TODO :
#   - columns ::ign and ::comment are getting added by the "default" template
#		should they be removed later on?
#		-> if you select "input" as print order, everything is o.k.
#	- what about extra colmns? Skip or add/print?
#		-> can be configured by the input.<type>.columns (???) -> see Globals.pm
#	- if multiple sheets are renedered, new columns on previous sheets are printed
#   out on following sheets, too (reset the template? Or accumulate?)
#   - columns with missing headers are ignored now; maybe they should get
#     a usefull name (make a switch) -> see Globals.pm confg section for input.format (?)
#		or format.<type>.mixhead (???)
sub selbyhead ($$) {
		my $ref = shift;
		my $sname = shift;
		if ( $OPTVAL{selhead} or $OPTVAL{noselhead} or $OPTVAL{variant} ) {
			# Select columns based on ::head:
			
	    	$eh->inc( 'default.parsed' );
	    	my $icomms	= $eh->get( 'input.ignore.comments' );
			my $ivar	= $eh->get( 'input.ignore.variant' ) || '#__I_VARIANT';   	    	
 	    	my @ahashd = convert_in( 'default', $ref ); # Normalize and read in
 	    	if ( $OPTVAL{variant} ) {
 	    		select_variant( \@ahashd, $sname );
 	    		# Get rid of variant #__I_VARIANTS tagged lines
 	    		my @rest = ();
 	    		for my $d ( @ahashd ) {
 	    			unless ( ref( $d ) eq 'HASH' and $d->{'::ign'} and
 	    				( $d->{'::ign'} =~ m/$icomms/ or $d->{'::ign'} =~ m/$ivar/ ) ) {
 	    				push( @rest, $d );
 	    			}
 	    		} 
 	    		@ahashd = @rest;
 	    	}
 	    	
 	    	my $selhead = parse_selheadopt( $OPTVAL{selhead} );
 	    	my $noselhead = parse_selheadopt( $OPTVAL{noselhead} );

 	    	# Convert back to arrayarray format:
 	    	# Attention: using 'csv' format, might be problematic with sxc files (large cells)!
 	    	my $fref = db2array( \@ahashd, 'default', 'csv', '' ,$selhead, $noselhead );
 	    	# Last but not least: replace macros %UNDEF_\d%
 	    	replace_simple_mac( $fref );
 	    	return $fref;
		}
		return $ref;
} # End of selbyhead

#
# Do some simple macro replacement
# TODO : use the MixUtils macro parser!
sub replace_simple_mac ($) {
	my $ref = shift;
	
	for my $i ( @$ref ) {
		for my $ii ( @$i ) {
			$ii =~ s/%UNDEF_\d%//;
		}
	}
} # End of replace_simple_mac

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
# Overlapping sections are allowed for duplication
#  but by default output order is sorted 
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
	if ( $eh->get( 'format.csv.sortrange' ) ) {
		@ranges = sort( { ( my $c = $a ) =~ s/:.*//; ( my $d = $b ) =~ s/:.*//; $c <=> $d; } @ranges );
	}
	
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

#
# Combine the -selhead options:
# 	    	
sub parse_selheadopt ($) {
	my $opt = shift;
	
	if ( defined( $opt ) ) {
		# Attach (:\d+)? to each selector:
		my $select = '^((' . join( '|', @$opt ) . ')(:\d+)?)$';
		return $select;
	} else {
		return '';
	}
} #End of parse_selheadopt

#!End