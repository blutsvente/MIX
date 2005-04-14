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
# $Id: xls2csv.pl,v 1.4 2005/04/14 06:53:00 wig Exp $
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
#
#  Define seperator:
#
# $Log: xls2csv.pl,v $
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
use lib "./lib/perl";
use lib "./../lib/perl";


# use lib "$pgmpath/../../lib/perl";

use Log::Agent;
use Log::Agent::Priorities qw(:LEVELS);
use Log::Agent::Driver::File;

use Micronas::MixUtils;
use Micronas::MixUtils::IO;

#******************************************************************************
# Global Variables
#******************************************************************************

$::VERSION = '$Revision: 1.4 $'; # RCS Id
$::VERSION =~ s,\$,,go;

mix_init();

$Micronas::MixUtils::EH{'intermediate'}{'keep'}=0;

#
# read in arguments with -
my %opts = (
	'csv' => -1,
	'sxc' => -1,
	'head' => 1,
	'verbose' => 1,
	'sep'	=> ";",
	'sheet' => [],
);

unless( GetOptions( \%opts, 'help!', 'csv!', 'sep=s', 'head!', 'sxc!', 'verbose|v!',
	'quote|q=s', 'autoq|autoquote', 'single!', 'accumulate|accu!', 
	'noquote|noq', 'sheet=s@' ) ) {
	logerr "Illegal option detected!";
	exit 1;
}

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
	-[no]head     Do not print sheet seperator head ("=:=:=:=> SHEETNAME" by default)
	-[no]verbose  Print more messages

EOM

	return;
}

if ( $opts{'help'} ) {
	print_usage;
	exit 0;
}

if (scalar(@ARGV) < 1 ) {
    logwarn "Usage: $0 <-[no]csv|-[no]sxc> <-[auto|no]quote>  <-quote X> <-sep SEP> <-nohead> <-[no]verbose> <-sheet REGEX> -single -accu[mulate] <excel-file> ...";
    die;
}


# If no option -> do both!
if ( $opts{csv} == -1 and $opts{sxc} == -1 ) {
	$opts{csv} = 1;
	$opts{sxc} = 1;
}
if ( $opts{csv} == -1 ) {
	$opts{csv} = 0;
}
if ( $opts{sxc} == -1 ) {
	$opts{sxc} = 0;
}

# Take Perl-Regex to match against sheetnames ...
my $sel = "";
if ( scalar( @{$opts{sheet}} ) ) {
	$sel = '^(' . join( '|', @{$opts{sheet}} ) . ')$';
}

if ( exists( $opts{sep} ) ) {
	$Micronas::MixUtils::EH{'format'}{'csv'}{'cellsep'} = $opts{sep};
}

unless ( $opts{head} or not $opts{single} ) {
	$Micronas::MixUtils::EH{'format'}{'csv'}{'sheetsep'} = "";
}
# if ( exists( $opts{autoq} ) ) {
# } -> on by default!
if ( exists( $opts{noquote} ) ) {
	$Micronas::MixUtils::EH{'format'}{'csv'}{'quoting'} = "";
	$Micronas::MixUtils::EH{'format'}{'csv'}{'style'} = "classic";
} elsif ( ( exists( $opts{quote} ) ) ) {
	$Micronas::MixUtils::EH{'format'}{'csv'}{'quoting'} = $opts{quote};
}

#
# main loop: convert all xls files from input
#

my $accu = ""; # Remember first filename for accumlated output

for my $file ( @ARGV ) {

	my $cfile;
	my $sfile;
	if( $file !~ m/\.xls/) {
	    $file = $file . ".xls";
	}

	unless( -r $file ) {
		print "WARNING: Cannot read file $file\n";
		next;
	}
	
	if( $file=~ m/\.xls$/ ) {
		if ( $opts{'accumulate'} ) {
			unless( $accu ) { # First time only ...
				$accu = $file;
			}
	        ( $cfile = $accu )=~  s/\.xls$/.csv/;
	        ( $sfile = $accu )=~  s/\.xls$/.sxc/;
		} else {
	        ( $cfile = $file )=~  s/\.xls$/.csv/;
	        ( $sfile = $file )=~  s/\.xls$/.sxc/;
		}
	} 
	#wig: what is this for ????
	elsif( $file !~ m/.csv$/) { 
	    $cfile = $file . ".csv";
	    $sfile = $file . ".sxc";
	}

	unless( -r $file ) {
	    logwarn("ERROR: Cannot read input file $file. Skip it!");
	    next;
	}

	my $oBook = Spreadsheet::ParseExcel::Workbook->Parse($file);
	
	if(!$oBook) {
	    logdie("ERROR: File <$file> not found");
	}
	
	my $sheet;
	my $sname = "";
	my @data = ();
	
	my $ref;
	
	
	for(my $i=0; $i<$oBook->{SheetCount}; $i++) {
	
	    $sheet = $oBook->{Worksheet}[$i];
	    $sname = $sheet->{Name};
	
	    if ( $sel and $sname !~ m/$sel/ ){
		logsay("INFO: Sheet " . $file . "::" . $sname . " not selected for conversion" ) if ( $opts{'verbose'} );
		next;
	    }
	
	    @data = open_xls($file, $sname, 0);
	    $ref = pop(@data);       # get the first sheet of the name $sname which was found
	    logsay("INFO: Print out sheet " . $file . "::" . $sname ) if ( $opts{'verbose'} );
		if ( $opts{single} ) {
			my $snamean =~ s/\W+/_/g; #
			$cfile =~ s/\.csv$/-$snamean.csv/;
			$sfile =~ s/\.sxc$/-$snamean.sxc/;			
		    write_csv($cfile, $sname, $ref) if $opts{csv};
	        write_sxc($sfile, $sname, $ref) if $opts{sxc};
		} else {
	        write_csv($cfile, $sname, $ref) if $opts{csv};
	        write_sxc($sfile, $sname, $ref) if $opts{sxc};
		}
	}

}

#!End
