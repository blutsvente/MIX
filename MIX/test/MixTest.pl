#!/usr/bin/perl

#######################################################################
#                MixTest - Test script for Mix                        #
#######################################################################

#######################################################################
#                                                                     #
#    MixTest should make it a little more easy to debug Mix. For      #
#    verification of result, some Perl Test:: package has been used   #
#                                                                     #
#######################################################################

#######################################################################
#               required packages and base path                       #
#######################################################################

use strict;
use Cwd;

$::VERSION = '$Revision: 0.1 ';
$::VERSION =~ s,\$,,go;

use vars qw($pgm $base $pgmpath $cwd);

BEGIN{
    ($^O=~/Win32/) ? ($cwd=getcwd())=~s,/,\\,g : ($cwd=getcwd());

    ($pgm=$0) =~s;^.*(/|\\);;g;
    if ( $0 =~ m,[/\\],o ) { #$0 has path ...
        ($base=$0) =~s;^(.*)[/\\]\w+[/\\][\w\.]+$;$1;g;
        ($pgmpath=$0) =~ s;^(.*)[/\\][\w\.]+$;$1;g;
    } else {
        ($base=$cwd) =~ s,^(.*)[/\\][\w\.]+$,$1,g;
        $pgmpath=$cwd;
    }
}

use lib "$pgmpath/../lib/perl";
use lib "$pgmpath/lib";

use Test::More tests => qw(no_plan);
use Test::Differences;

use Log::Agent;
use Log::Agent::Priorities qw(:LEVELS);
use Log::Agent::Driver::File;

use Getopt::Long qw(GetOptions);

my %opts = ();

my $status = GetOptions( \%opts, qw (
	update!
	release!
	purge!
	xls!
	sxc!
	csv!
    )
);

my $numTests = 0;
my @inType;

my %failstat = ();

# TODO: move @tests to extra file

#######################################################################
#                          local variables                            #
#######################################################################

my $excel;

my @tests = (
	{
	  'name' => "bitsplice",
	  'path' => "bitsplice",
	  'options' => "",
	},
	{
	  'name' => "bitsplice",
	  'path' => "bitsplice/verilog",
	  'options' => "",
	},
	{
	  'name' => "sigport",
	  'path' => "sigport",
	  'options' => "",
	},
	{
	  'name' => "sigport",
	  'path' => "sigport/use",
	  'options' => "",
	},
	{
	  'name' => "sigport",
	  'path' => "sigport/verilog",
	  'options' => "",
	},
	{
	  'name' => "highlow",
	  'path' => "highlow",
	  'options' => "",
	},
	{
	  'name' => "highlow",
	  'path' => "highlow/verilog",
	  'options' => "",
	},
	{
	  'name' => "mde_tests",
	  'path' => "mde_tests/conn_nreset",
	  'options' => "",
	},
	{
	  'name' => "constant",
	  'path' => "constant",
	  'options' => "",
	},
	{
	  'name' => "constant",
	  'path' => "constant/verilog",
	  'options' => "",
	},
	{
	  'name' => "case",
	  'path' => "case",
	  'options' => ""
	},
	{
	  'name' => "io",
	  'path' => "io",
	  'options' => "",
	},
	{
	  'name' => "io",
	  'path' => "io/verilog",
	  'options' => "",
	},
	{
	  'name' => "generic",
	  'path' => "generic",
	  'options' => "",
	},
	{
	  'name' => "generic",
	  'path' => "generic/verilog",
	  'options' => "",
	},
	{
	  'name' => "genwidth",
	  'path' => "genwidth",
	  'options' => "",
	},
	{
	  'name' => "genwidth",
	  'path' => "genwidth/verilog",
	  'options' => "",
	},
	{
	  'name' => "nreset2",
	  'path' => "nreset2",
	  'options' => "",
	},
	{
	  'name' => "open",
	  'path' => "open",
	  'options' => "",
	},
	{
	  'name' => "open",
	  'path' => "open/verilog",
	  'options' => "",
	},
	{
	  'name' => "macro",
	  'path' => "macro",
	  'options' => "",
	},
	{
	  'name' => "verilog",
	  'path' => "verilog",
	  'options' => "",
	},
	{
	  'name' => "verilog",
	  'path' => "verilog/vhdl",
	  'options' => "-sheet HIER=HIER_VHDL",
	},
	{
	  'name' => "verilog",
	  'path' => "verilog/mixed",
	  'options' => "-sheet HIER=HIER_MIXED",
	},
	{
	  'name' => "conf",
	  'path' => "conf",
	  'options' => "",
	},
	{
	  'name' => "configuration",
	  'path' => "configuration",
	  'options' => "",
	},
	{
	  'name' => "padio",
	  'path' => "padio",
	  'options' => "",
	},
	{
	  'name' => "padio",
	  'path' => "padio/names",
	  'options' => "",
	},
	{
	  'name' => "padio",
	  'path' => "padio/bus",
	  'options' => "",
	},
	{
	  'name' => "padio",
	  'path' => "padio/given",
	  'options' => "",
	},
	{
	  'name' => "padio2",
	  'path' => "padio2",
	  'options' => "",
	},
	{
	  'name' => "typecast",
	  'path' => "typecast",
	  'options' => "",
	},
	{
	  'name' => "init",
	  'path' => "init",
	  'options' => "-import inst_aa_e-e.vhd ddrv4-e.vhd",
	},
	{
	  'name' => "autoopen",
	  'path' => "autoopen",
	  'options' => "",
	},
);

my $numberOfTests = scalar @tests;

#######################################################################
#                          init - function                            #
#######################################################################
sub init() {

    logconfig(-driver =>
	     Log::Agent::Driver::File->make(
		 # -prefix      => $0,
		 # -verbose     => 0,
		 -showpid       => 1,
		 -duperr        => 1,   #Send errors to OUTPUT and ERROR channel ...
		 -channels    => {
			  # 'error'  => "$0.err",
			  'output' => "$cwd/test.out",
			  'debug'  => "$cwd/test.dbg", 
		 },
	     )
    );

    print "running Test:";
    if(defined( $opts{'sxc'})) {
      print " sxc,";
      $numTests += $numberOfTests;
      push(@inType, "sxc");
    }
    if(defined( $opts{'xls'})) {
      print " xls,";
      $numTests += $numberOfTests;
      push(@inType, "xls");
    }
    if(defined( $opts{'csv'})) {
      print " csv,";
      $numTests += $numberOfTests;
      push(@inType, "csv");
    }

    if(scalar(@inType)==0) {
	print " ALL\n";
	@inType = ("sxc", "xls", "csv");
	$numTests = $numberOfTests * 3;
    }
    else {
      print "\n";
    }
}

#######################################################################
#                          initExcel - function                       #
#######################################################################
sub initExcel() {

  $excel = Win32::OLE->GetActiveObject('Excel.Application')
    || Win32::OLE->new('Excel.Application', 'Quit');

  $excel->{DisplayAlerts} = 0;
}

#######################################################################
#                         gotScript                                   #
#######################################################################
=head2 gotScript
    returns true if directory contains a start script, else false
=cut
sub gotScript($$) {

    my $dir = shift;
    my $name = shift;

    opendir(DIR, $dir);
    my @content = readdir(DIR);
    close(DIR);

    for(my $i=0; defined $content[$i]; $i++) {
	if($content[$i]=~ m/$name/) {
	    return 1;
	}
    }
    return 0;
}

#######################################################################
#                         runMix - function                           #
#######################################################################
=head2 runMix()
    run Mix using input files located in directory test
=cut

sub runMix($) {

    my $type = shift;
    my $command;
    my $options;
    my $path;
    my $find;

    my $failsum = 0;
    my $wdir = getcwd();

    for(my $i=0; $i<$numberOfTests; $i++) {

	$command;
	$options = $tests[$i]->{'options'};
        $path = getcwd() . "/$tests[$i]->{'path'}";
	$find = "";

	if( defined( $opts{'update'} ) ) {
		$options = "$options -nodelta";
	}

	if( gotScript($path, "$tests[$i]->{'name'}.bat")==1) {
	    if( !defined $opts{'update'}) {
		$command = $tests[$i]->{'name'}.".bat";
	    }
	    else {
		$command = $tests[$i]->{'name'}."-update.bat";
	    }
	}
	else {
	    while($tests[$i]->{'path'} =~ /\//g) {
		$find = $find . "../";
	    }
	    $command  = "mix_0.pl $tests[$i]->{'options'} $find../$tests[$i]->{'name'}.$type";
	}
        my $testname = @tests[$i]->{'name'};

	chdir( $path) || logwarn("ERROR: Directory <$path> not found!");

        if ( -r "$testname-t.out" ) {
	    rename( "$testname-t.out", "$testname-t.out.0" )
	      or print "rename of $testname-t.out failed"
	        and exit 1;
        }
	if ( defined( $opts{'purge'} ) ) {
	    # TODO: remove mix_0.pl.out, *.diff, ....
	    #
	    unlink "mix_0.pl.out";
	    unlink <*.diff>;
	} 
	else {

 	    my $status = system( "$command >$testname-t.out 2>&1" );
	    if ( $status / 256 != 0 ) {
	        my $cf = 0;
		my $ci = 0;
		# 03/07/15 17:02:49 140: WARNING: SUM: Number of changes in intermediate: 1
		# 03/07/15 17:02:49 140: WARNING: SUM: Number of changed files: 0
		if ( open( LOG, "< $testname-t.out" ) ) {
  		    while ( <LOG> ) {
		        chomp;
			if( m/SUM:\s+Number\s+of\s+changed\s+files:\s*(\d+)/i ) {
			    $cf = $1;
			}
			if( m/SUM:\s+Number\s+of\s+changes.*intermediate:\s*(\d+)/i ) {
			    $ci = $1;
			}
		    }
		    close( LOG);
		}
		else {
		    $cf = -1;
		    $ci = -1;
		}
		$failsum++;
	    }
	    ok( $status/256 == 0, "$testname.$type in directory $tests[$i]->{'path'}");
	    chdir( $wdir);
	}
    }
    $failstat{$type} = $failsum;
}

#######################################################################
#                            'main'                                   #
#######################################################################

init();

# run tests
foreach my $i (@inType) {
    logwarn "testing: $i-input";
    chdir $i."_input";
    runMix( $i);
    chdir "$pgmpath";
}

my $summary = 0;

# print out statistics
print "\n\tStatistics:\n";
foreach my $i (@inType) {
    print "\tType: $i, ". $failstat{$i} ." of $numberOfTests Tests failed\n";
    $summary += $failstat{$i};
}
print "\naltogether: $summary of all $numTests Tests failed!\n";

exit;

#!End
