#!/usr/bin/perl

#******************************************************************************
#
# read in XLS file and print out a csv and and a sxc version of all sheets
#
# (C)2004 wilfried.gaensheimer@micronas.com
#******************************************************************************


use strict;
use Cwd;
use File::Basename;
use Getopt::Long qw(GetOptions);
use Pod::Text;

=head 4 old

use vars qw($pgm $base $pgmpath $dir);

$dir = "";
($^O=~/Win32/) ? ($dir=getcwd())=~s,/,\\,g : ($dir=getcwd());

BEGIN{
    ($^O=~/Win32/) ? ($dir=getcwd())=~s,/,\\,g : ($dir=getcwd());    

    ($pgm=$0) =~s;^.*(/|\\);;g;
    if ( $0 =~ m,[/\\],o ) { #$0 has path ...
        ($base=$0) =~s;^(.*)[/\\]\w+[/\\][\w\.]+$;$1;g;
        ($pgmpath=$0) =~ s;^(.*)[/\\][\w\.]+$;$1;g;
    } else {
        ( $base = $dir ) =~ s,^(.*)[/\\][\w\.]+$,$1,g;
        $pgmpath = $dir;
    }
}

=cut

use FindBin;

# use lib "$FindBin::Bin/..";
use lib "$FindBin::Bin/../lib/perl";
use lib "$FindBin::Bin/../../lib/perl";
# use lib "$FindBin::Bin";
# use lib "$FindBin::Bin/lib/perl";
# use lib "$FindBin::Bin/lib";
use lib getcwd() . "/lib/perl";
use lib getcwd() . "/../lib/perl";


# use lib "$pgmpath/../../lib/perl";

use Log::Agent;
use Log::Agent::Priorities qw(:LEVELS);
use Log::Agent::Driver::File;

use Micronas::MixUtils;
use Micronas::MixUtils::IO;

#******************************************************************************
# Global Variables
#******************************************************************************

$::VERSION = '$Revision: 1.2 $'; # RCS Id
$::VERSION =~ s,\$,,go;

if(scalar(@ARGV) < 1 ) {
    logwarn "usage: xls2csv.pl <excel-file> ...";
    die;
}

mix_init();

$Micronas::MixUtils::EH{'intermediate'}{'keep'}=0;

for my $file ( @ARGV ) {

	my $cfile;
	my $sfile;
	if(not $file=~ m/\.xls/) {
	    $file = $file . ".xls";
	}
	
	if( $file=~ m/\.xls$/ ) {
	    ( $cfile = $file )=~  s/\.xls$/.csv/;
	    ( $sfile = $file )=~  s/\.xls$/.sxc/;
	} 
	elsif( $file !~ m/.csv$/) { 
	    $cfile = $file . ".csv";
	    $sfile = $file . ".sxc";
	}

	unless( -r $file ) {
	    print("ERROR: Cannot read input file $file!");
	    next;
	}

	my $oBook = Spreadsheet::ParseExcel::Workbook->Parse($file);
	
	if(!$oBook) {
	    logwarn("ERROR: File <$file> not found");
	    die;
	}
	
	my $sheet;
	my $sname = "";
	my @data = ();
	
	my $ref;
	
	
	for(my $i=0; $i<$oBook->{SheetCount}; $i++) {
	
	    $sheet = $oBook->{Worksheet}[$i];
	    $sname = $sheet->{Name};
	
	    @data = open_xls($file, $sname, 0);
	    $ref = pop(@data);       # get the first sheet of the name $sname which was found
	    write_csv($cfile, $sname, $ref);
	    write_sxc($sfile, $sname, $ref);
	}

}

#!End
