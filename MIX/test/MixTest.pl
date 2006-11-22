#!/bin/sh --
#! -*- perl -*- -w
eval 'exec ${PERL:-`[ ! -d $HOME/bin/perl -a -x $HOME/bin/perl ] && echo $HOME/bin/perl || { [ -x /usr/bin/perl ] && echo /usr/bin/perl || echo /usr/local/bin/perl ; } `} -x -S $0 ${1+"$@"} ;'
if 0; # dynamic perl startup; suppress preceding line in perl
#line 6

#######################################################################
#                MixTest - Test script for Mix                        #
#######################################################################

#######################################################################
#                                                                     #
#    MixTest should make it a little more easy to debug Mix. For      #
#    verification of result, some Perl Test:: packages are used       #
#                                                                     #
#######################################################################

#######################################################################
#               required packages and base path                       #
#######################################################################

use strict;
use warnings;
use Cwd;
use DirHandle;
use File::Basename;
use File::Copy;
use Getopt::Long qw(GetOptions);
use Time::HiRes qw(gettimeofday tv_interval);


$::VERSION = '$Revision: 0.1 ';
$::VERSION =~ s,\$,,go;

use FindBin;

use lib "$FindBin::Bin/..";
use lib "$FindBin::Bin/../lib/perl";
use lib "$FindBin::Bin/../../lib/perl";
use lib "$FindBin::Bin";
use lib "$FindBin::Bin/lib/perl";
use lib "$FindBin::Bin/lib";
use lib getcwd() . "/lib/perl";
use lib getcwd() . "/../lib/perl";

use Test::More 'no_plan' ; # tests => qw(no_plan);
use Test::Differences;

use Log::Agent;
use Log::Agent::Priorities qw(:LEVELS);
use Log::Agent::Driver::File;

my %opts = ();
my $common_path = getcwd();
# Where is mix_0.pl ->
#   mswin -> take off last part of common_path (  test is subdirectory )
#  will only work if we are in the test directory ... else use the -mix flag ..
my $mix = dirname( $common_path ) . "/mix_0.pl";

my $cmd_ext = ( $^O =~ m/ms-win/io ) ? '.bat' : '.sh';

my $status = GetOptions( \%opts, qw (
	update!
	bak!
	debug!
	release!
	purge!
	export!
	import!
	list!
	xls!
	sxc!
	csv!
	mix=s
	options=s@
    )
);

if ( $opts{'mix'} ) {
    if ( -x $opts{'mix'} ) {
		$mix = $opts{'mix'};
    } else {
		logwarn("WARNING: mix option does not point to executable! Ignored!");
    }
}

my $numTests = 0;
my @inType;
my $testRE = '';

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
	  'options' => '',
	},
	{
	  'name' => "bitsplice",
	  'path' => "bitsplice/verilog",
	  'options' => '',
	},
	{
	  'name' => "bitsplice",
	  'path' => "bitsplice/vhdportsort",
	  'options' => '',
	},
	{
	  'name' => "bitsplice",
	  'path' => "bitsplice/verportsort",
	  'options' => '',
	},
	{
	  'name' => "bitsplice",
	  'path' => "bitsplice/rfe20060904a",
	  'options' => '',
	},
	{
	  'name' => "bitsplice",
	  'path' => "bitsplice/connport",
	  'options' => '',
	},
	{
	  'name' => "sigport",
	  'path' => "sigport",
	  'options' => '',
	},
	{
	  'name' => "sigport",
	  'path' => "sigport/use",
	  'options' => '',
	},
	{
	  'name' => "sigport",
	  'path' => "sigport/verilog",
	  'options' => '',
	},
	{
	  'name' => "highlow",
	  'path' => "highlow",
	  'options' => '',
	},
	{
	  'name' => "highlow",
	  'path' => "highlow/verilog",
	  'options' => '',
	},
	{
	  'name' => "highlow",
	  'path' => "highlow/lownobus",
	  'options' => '',
	},
	{
	  'name' => "mde_tests",
	  'path' => "mde_tests/conn_nreset",
	  'options' => '',
	},
	{
	  'name' => "mde_tests",
	  'path' => "mde_tests/conn_nr_vhdl",
	  'options' => '',
	},
	{
	  'name' => "mde_tests",
	  'path' => "mde_tests/nreset2",
	  'options' => '',
	  'skip'	=> 1, #!wig20050929: has no CONN sheet!!
	},
	{
	  'name' => "constant",
	  'path' => "constant",
	  'options' => '',
	},
	{
	  'name' => "constant",
	  'path' => "constant/verilog",
	  'options' => '',
	},
	{
	  'name' => "case",
	  'path' => "case",
	  'options' => '',
	  # 'skip' => 1,
	},
		{
	  'name' => "case",
	  'path' => "case/check",
	  'options' => '',
	  # 'skip' => 1,
	},
	{
	  'name' => "case",
	  'path' => "case/force",
	  'options' => '',
	  # 'skip' => 1,
	},

	{
	  'name' => "io",
	  'path' => "io",
	  'options' => '',
	},
	{
	  'name' => "io",
	  'path' => "io/verilog",
	  'options' => '',
	},
	{ # VHDL Generics/Parameters
	  'name' => "generic",
	  'path' => "generic",
	  'options' => '',
	},
	{ # Verilog Parameters
	  'name' => "generic",
	  'path' => "generic/verilog",
	  'options' => '',
	},
	{ # Verilog over VHD with Parameters
	  'name' => "generic",
	  'path' => "generic/veriovhd",
	  'options' => '',
	},
	{ # Verilot2001 style (no defparams!)
	  'name' => "generic",
	  'path' => "generic/nodefparam",
	  'options' => '',
	},
	{
	  'name' => "genwidth",
	  'path' => "genwidth",
	  'options' => '',
	},
	{
	  'name' => "genwidth",
	  'path' => "genwidth/verilog",
	  'options' => '',
	},
	{
	  'name' => "nreset2",
	  'path' => "nreset2",
	  'options' => '',
	},
	{
	  'name' => "open",
	  'path' => "open",
	  'options' => '',
	},
	{
	  'name' => "open",
	  'path' => "open/verilog",
	  'options' => '',
	},
	{
	  'name' => "open",
	  'path' => "open/verilog_ndmy",
	  'options' => '',
	},
	{
	  'name' => "macro",
	  'path' => "macro",
	  'options' => '',
	},
	{
	  'name' => "macro",
	  'path' => "macro/splice",
	  'options' => "-sheet HIER=HIER_SPLICE -sheet CONN=CONN_SPLICE",
	},
	{ # macro/generator enable/disable with ::variant
	  'name' => "macro",
	  'path' => "macro/variant",
	  'options' => "-variant Calculate",
	},
	{
	  'name' => "verilog",
	  'path' => "verilog",
	  'options' => '',
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
	  'name' => "verilog",
	  'path' => "verilog/uamn",
	  'options' => "-sheet HIER=HIER_UAMN",
	},
	{
	  'name' => "verilog",
	  'path' => "verilog/useconfname",
	  'options' => "-sheet HIER=HIER_MIXED",
	},
	{
	  'name' => "verilog",
	  'path' => "verilog/leaforeg",
	  'options' => '',
	},
	{
	  'name' => "verilog",
	  'path' => "verilog/seloreg",
	  'options' => '',
	},
	{ #!wig20051024: adding cstyle header
	  'name' => "verilog",
	  'path' => "verilog/v2001",
	  'options' => '',
	},
	{ #!wig20060411: adding verilog module head ifdef exclude feature
	  'name' => "verilog",
	  'path' => "verilog/verimap",
	  'options' => '',
	},
	{ #!wig20060922: adding axismux feature
	  'name' => "verilog",
	  'path' => "verilog/emumuxall",
	  'options' => '',
	},
	{ #!wig20061115: adding verilog include file import
	  'name' => "verilog",
	  'path' => "verilog/vinc",
	  'options' => '',
	},
	{
	  'name' => "conf",
	  'path' => "conf",
	  'options' => '',
	  'skip' => 1, #!wig20051004, cannot work with combined output!
	},
	{
	  'name' => "configuration",
	  'path' => "configuration",
	  'options' => '',
	},
	{	# Repeat configuration, but set two macros from cmd line
		# Added by wig 20060316
		'name' => "configuration",
		'path' => "configuration/cmdline",
		'options' => "-conf 'macro.%VHDL_USE_ENTY%=Overwritten vhdl_enty from cmdline' -conf macro.%VHDL_HOOK_ARCH_BODY%='Use macro vhdl_hook_arch_body' -conf macro.%ADD_MY_OWN%='overloading my own macro'",
	},
	{	# Repeat configuration, but use extra.cfg file to read data
		# Added by wig 20060316
		'name' => "configuration",
		'path' => "configuration/cfgfile",
		'options' => "-cfg extra.cfg",
	},
	{
	  'name' => "padio",
	  'path' => "padio",
	  'options' => '',
	},
	{
	  'name' => "padio",
	  'path' => "padio/names",
	  'options' => '',
	},
	{
	  'name' => "padio",
	  'path' => "padio/bus",
	  'options' => '',
	},
	{
	  'name' => "padio",
	  'path' => "padio/given",
	  'options' => '',
	},
	{
	  'name' => "padio2",
	  'path' => "padio2",
	  'options' => '',
	},
	{ # Typecast in port maps (old default)
	  'name' => "typecast",
	  'path' => "typecast",
	  'options' => '',
	},
	{ # Typecast via intermediate signales
	  'name' => "typecast",
	  'path' => "typecast/intsig",
	  'options' => '',
	},
	{ # tyepcast for busses, only ...
	  'name' => "typecast",
	  'path' => "typecast/intbus",
	  'options' => '',
	},
	{
	  'name' => "init",
	  'path' => "init",
	  'options' => "-import inst_aa_e-e.vhd ddrv4-e.vhd",
	},
	{
	  'name' => "autoopen",
	  'path' => "autoopen",
	  'options' => '',
	},
	{
	  'name' => "autoopen",
	  'path' => "autoopen/aaa",
	  'options' => '',
	},
	{
	  'name' => "autoopen",
	  'path' => "autoopen/simple",
	  'options' => '',
	},
	{
	  'name' => "autoopen",
	  'path' => "autoopen/noaopen",
	  'options' => '',
	},
	{ #!wig20060329: adding auto hierachy feature:
		'name' => 'hier',
		'path' => 'hier/auto',
		'options' => '',
	},
	{ #!wig20060410: adding portlist:
		'name' => 'portlist',
		'path' => 'portlist',
		'options' => '-report portlist',
	},
	{ #!wig20060410: adding portlist:
		'name' => 'portlist',
		'path' => 'portlist/low',
		'options' => '-report portlist',
	},
	{
	  'name' => "bugver",
	  'path' => "bugver/ramd",
	  'options' => '',
	},
	{ # Bug with constant busses ...
	  'name' => "bugver",
	  'path' => "bugver/constbug",
	  'options' => '',
	},
	{ # Bug with generics/0 ...
	  'name' => "bugver",
	  'path' => "bugver/20051004c",
	  'options' => '',
	},
	{ # Bug with generics/0 ...
	  'name' => "bugver",
	  'path' => "bugver/20051014b",
	  'options' => '',
	},
	{ # Bug with wiring of mic32_top_ramd_oe signal ...
	  'name' => "bugver",
	  'path' => "bugver/20051018d",
	  'options' => '',
	},
	{ # Trailing ; in entity port map
	  'name' => "bugver",
	  'path' => "bugver/20051121a",
	  'options' => '',
	},
	{ # Fail to create two intermediate ports
	  'name' => "bugver",
	  'path' => "bugver/20051221a",
	  'options' => '',
	},
	{ # Create duplicate port for partially connected signals
	  'name' => "bugver",
	  'path' => "bugver/20060404c",
	  'options' => '',
	},
	{ # Create duplicate port for partially connected signals
	  'name' => "bugver",
	  'path' => "bugver/20060424a",
	  'options' => '',
	},
	{ # recognize that DATA9 and data9 are the same (in verilog!)
	  'name' => 'bugver2006',
	  'path' => 'bugver2006/20060522a',
	  'options' => '',
	},
	{ # port gets assigned a constant value and a signal!
	  'name' => 'bugver2006',
	  'path' => 'bugver2006/20060522b',
	  'options' => '',
	},
	{ # signal with ::low only defintion!
	  'name' => 'bugver2006',
	  'path' => 'bugver2006/20061017a',
	  'options' => '',
	},
	{ # missing ::out column in output
	  'name' => 'bugver2006',
	  'path' => 'bugver2006/20061113a',
	  'options' => '',
	},
	#{ # port gets assigned a constant value and a signal!
	#  'name' => "bugver2006",
	#  'path' => "bugver2006/20060522b",
	#  'options' => '',
	#},
	{ # Create simple logic ...
	  'name' => 'logic',
	  'path' => 'logic',
	  'options' => '',
	},
	{ # Create simple logic/verilog ...
	  'name' => 'logic',
	  'path' => 'logic/verilog',
	  'options' => '',
	},
	{ # Add arbitrary text in hooks: ::udc
		'name' => 'udc',
		'path' => 'udc',
		'options' => '',
	},
	{ # Add arbitrary text in hooks: ::udc + verilog code
		'name' => 'udc',
		'path' => 'udc/verilog',
		'options' => '',
	},
	{ # Split intermediate CONN sheet
		'name' => 'intra',
		'path' => 'intra',
		'options' => '',
	},
	{ # Split intermediate CONN sheet into one for each instance
		'name' => 'intra',
		'path' => 'intra/instance',
		'options' => '',
	},
	{ 
		'name' => 'reg_shell',
		'path' => 'reg_shell/scd', # single-clock-domain
		'options' => '',
	    'skip' => 1,
	},
	{ 
		'name' => 'reg_shell',
		'path' => 'reg_shell/mcd', # multi-clock-domain
		'options' => '',
	    'skip' => 1,
	},
	{ 
		'name' => 'reg_shell',
		'path' => 'reg_shell/no_clock_gating', # with disabled clock-gating
		'options' => '',
	    'skip' => 1,
	},
	{ 
		'name' => 'reg_shell',
		'path' => 'reg_shell/read_pipeline', # with inferring a read-pipeline
		'options' => '',
	    'skip' => 1,
	},
	{ 
		'name' => 'duplicate',
		'path' => 'duplicate', # try various duplicate wireing tricks
		'options' => '',
	},
);

my $numberOfTests = scalar @tests;
my $elapsed_sum = 0;
my $elapsed_cnt = 0;
my $elapsed_min = 1_000_000; # Dummy large value ...
my $elapsed_max = 0;

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
			  'output' => getcwd() . "/test.out",
			  'debug'  => getcwd() . "/test.dbg", 
		 },
	     )
    );

    print "running Test:";
    if(defined( $opts{'sxc'})) {
      print " sxc,";
      $numTests += $numberOfTests;
      push(@inType, 'sxc');
    }
    if(defined( $opts{'xls'})) {
      print " xls,";
      $numTests += $numberOfTests;
      push(@inType, 'xls');
    }
    if(defined( $opts{'csv'})) {
      print " csv,";
      $numTests += $numberOfTests;
      push(@inType, 'csv');
    }

    if ( scalar( @ARGV ) ) {
	# Only run the tests matching the ARGS in ARGV
	$testRE = '^(' . join( "|", @ARGV ) . ')$';
    }

    if(scalar(@inType)==0) {
		print " ALL\n";
		@inType = ('sxc', 'xls', 'csv');
		$numTests = $numberOfTests * 3;
    } else {
      print "\n";
    }

    
}

#######################################################################
#                          initExcel - function                       #
#######################################################################
#!wig20031218: obsolete
# sub initExcel() {
# 
#   $excel = Win32::OLE->GetActiveObject('Excel.Application')
#     || Win32::OLE->new('Excel.Application', 'Quit');
# 
#   $excel->{DisplayAlerts} = 0;
# }

#######################################################################
#                         gotScript                                   #
#######################################################################
=head2 gotScript
    returns true if directory contains a start script, else false
=cut

sub gotScript($$) {

    my $dir = shift;
    my $name = shift;

    if ( opendir(DIR, $dir) ) {
		while( defined( $_ = readdir(DIR ) ) ) {
	    	if ( $_ =~ m/^$name$/ ) {
				close( DIR );
				return 1;
	    	}
		}
    } else {
		logwarn( "WARNING, Cannot open directory $dir: $!" );
    }
    return 0;
} # End of gotScript

#######################################################################
#                         runMix - function                           #
#######################################################################
=head2 runMix()
    run Mix using input files located in directory test
=cut

sub runMix($) {

    my $type = shift;

    my $failsum = 0;
    my $wdir = getcwd() || die "Cannot change to ";
    my $time = 0;

    for(my $i=0; $i<$numberOfTests; $i++) {

		my $command = '';
		my $options = '';
		my $path = '';
		my $find = '';
	
		$options = $tests[$i]->{'options'};
		if ( $opts{'options'} ) {
			$options .= join( ' ', @{$opts{'options'}});
		}
	    my $testpath = $tests[$i]->{'path'};
	    $path = $wdir . "/$tests[$i]->{'path'}";
	    
	    my $testname = $tests[$i]->{'name'};
	
		if ( $testRE and $testpath !~ m/$testRE/io or
			     exists $tests[$i]->{'skip'} and $tests[$i]->{'skip'} ) {
				# this test is not selected ...
				print( "Skipped test $testname ($testpath)\n" );
				next;
		}
	
		if ( $opts{'list'} ) {
			print( "Selected test $testname ($testpath)\n" );
			next;
		}
	
		if ( defined( $opts{'import'} ) ) { # Create test directory from scratch (import directory)
			doImport( $type, $tests[$i]->{'name'}, $tests[$i]->{'path'} );
			next;
		}
	
	    if( defined( $opts{'update'} ) ) {
	    	$options .= ' -nodelta';
	    	#!wig20060216: combine with bak
	    	if( defined( $opts{'bak'} ) ) {
	    		$options .= ' -bak';
	    	}
	    }
	    
	    # Purge and strip out all extra sheets from intermediate data
	    if( defined( $opts{'export'} ) ) {
	    	$options .= ' -strip -nodelta';
	    }
	
		# Do not use built-in, but external command
	    if( gotScript($path, "$tests[$i]->{'name'}$cmd_ext") == 1 ) {
	    	for my $opt ( qw( export debug purge update ) ) {
	    		if( defined $opts{$opt}) {
	    			$ENV{'MIXTEST_OPT'} .= $opt . ' '; 
	    			if ( -x ( $path . '/' . $tests[$i]->{'name'} . '-' . $opt . $cmd_ext) ) {
	    				$command = $tests[$i]->{'name'}. '-' . $opt . $cmd_ext;
	    			} else {
	    				$command = $tests[$i]->{'name'}. $cmd_ext;
	    			}
	        	}
	    	}
	    	unless( -x $path . '/' . $command ) {
	    		print( "Warning: Missing script $command in path $path, use default instead!\n" );
	    		$command = '';
	    	}
	    	# Create some environment variables:
	    	# MIX_CMD, MIX_OPT
	    	$ENV{'MIXTEST_CMD'} = $mix || 'mix_0.pl';
	    }
	    unless ( $command ) {
	        while($tests[$i]->{'path'} =~ /\//g) {
	    		$find = $find . "../";
	    	}
			$mix = $mix || 'mix_0.pl'; # Default ...
			# Define the mix_0.pl to run
			# $command  = "h:/work/mix_new/mix/mix_0.pl $options $find../$tests[$i]->{'name'}.$type";
	    	$command  = 'perl -x ' . ( $opts{'debug'} ? '-d ' : '' ) .
				"\"$mix\" $options \"$find../$tests[$i]->{'name'}.$type\"" ;
	    }

		# chdir to work directory and run:	    
		my $cf = 1; # Number of differing files
		my $ci = 1; # Number of diffs in intermediate
		my $cl = 1; # Number of missing/added files
		my $ce = 1; # Number of error code diffs
		my $elapsed = -1;
	    if ( chdir( $path ) ) {
	    	# Start testcase
	    	if ( -r "$testname-t.out" and not $opts{'debug'} ) {
		    	rename( "$testname-t.out", "$testname-t.out.0" )
		       	      or print "rename of $testname-t.out failed"
	    	          and exit 1;
	    	}
	
	    	if ( defined( $opts{'purge'} ) ) {
	        	unlink <*.diff>;
	    		unlink <*.out.0>;
	    		unlink <*.out>;
	    		unlink <*.pld>; #!wig20031218: no longer created ...
	    		print( "Purged test $testname\n" );
	    		next;
	    	} else {
	        	# "export", "update" and non-opt mode will create new output data:
		    	my $status;
		    	my $t0;
	
		    	# measure elapsed time 
		    	$t0 = [gettimeofday];
		    
		 		if ( $opts{'debug'} ) {
	     		    $status = system( "$command" );
				} else {
					$status = system( "$command >$testname-t.out 2>&1" );
		   		}

		    	$elapsed = tv_interval ($t0, [gettimeofday]);
		    	if ( $status / 256 != 0 ) {
		    		$cf = $ci = $ce = -2;
	    			# 03/07/15 17:02:49 140: WARNING: SUM: Number of changes in intermediate: 1
	    			# 03/07/15 17:02:49 140: WARNING: SUM: Number of changed files: 0
	 
	    			$failsum++;
	    			logtrc( "WARNING", "$testname.$type in directory $tests[$i]->{'path'} failed, time: " .
	    				sprintf( "%.2fs changes: i/l/f/e %s/%s/%s/%s", $elapsed, $ci, $cl, $cf, $ce  ) );
	    		} else {
					# Timers average / min / max ..
					$elapsed_sum += $elapsed;
					$elapsed_cnt++;
					$elapsed_min = $elapsed if ( $elapsed < $elapsed_min );
					$elapsed_max = $elapsed if ( $elapsed > $elapsed_max );
					logsay( "$testname.$type in directory $tests[$i]->{'path'}, time : " .
						sprintf( "%.2fs", $elapsed ) );
		    	}
	   			if ( not $opts{debug} and open( LOG, "< $testname-t.out" ) ) {
	   		    	while ( <LOG> ) {
	  		        	chomp;
	   					if( m/SUM:\s+Number\s+of\s+changed\s+files:\s*(\d+)/i ) {
	   			    		$cf = $1;
	   			    		next;
	   					}
	   					if( m/SUM:\s+Number\s+of\s+changes.*intermediate:\s*(\d+)/i ) {
	   			    		$ci = $1;
	   					}
	   					if( m/SUM:\s+Number\s+of\s+unexpected\s+errors.*:\s*(\d+)/i ) {
	   			    		$ce = $1;
	   					}
	   					if( m/SUM:\s+Filelist\s+compare\s+result:\s*(\d+)/i ) {
	   			    		$cl = $1;
	   					}
	   		    	}
	   		    	close( LOG);
	   			} else {
	   		    	$cf = $ci = $ce = $cl = -1;
	   			}
	    	}
	   		if ( $opts{debug} ) {
	   			$cf = $ci = $ce = $cl = 0;
	   		}
	    } else {
	    	logwarn("ERROR: Directory <$path> not found!");
	    	$cf = $ci = $ce = $cl = -2;
	    	$status = 256;
	    }
	    ok( $status/256 == 0, "$testname.$type in directory $tests[$i]->{'path'}, time: " .
		    		sprintf( "%.2fs changes: i/l/f/e %s/%s/%s/%s", $elapsed, $ci, $cl, $cf, $ce  ) );
	    chdir( $wdir );
	}
    $failstat{$type} = $failsum;
} # End of runMix

#######################################################################
#                         mkdirRec - function                         #
#######################################################################
=head2 mkdirRec()

    make directory, recursively if needed
    
=cut

sub mkdirRec ($) {
    my $path = shift;

    my $uppath = $path;

    while( $uppath = dirname( $uppath ) ) {
	if ( -d $uppath ) { # Got it ...
	    last;
	}
    }
    unless( $uppath ) {
		print( "ERROR: No start path found for $path! Cannot create!\n" );
		return undef;
    }

    my $pp = "/";
    # my $npath = substr( $path, length( $uppath )  ); # Get rest ...
    ( my $npath = $path ) =~ s,^\Q$uppath\E,,;
    $npath =~ s,^/+,,;
    for my $p ( split( /\//, $npath ) ) {
	unless( mkdir( $uppath . $pp . $p, 0777 ) ) {
	    print( "ERROR: Cannot create " . $uppath . $pp . $p . ": " . $! . "\n" );
	    return undef;
	}
	$pp .= $p . "/";
    }
    return $uppath . $pp;
}

#######################################################################
#                         print_elapsed - function                         #
#######################################################################
=head2 print_elapsed()

    print out elased times for sucessfull run test

=cut

sub print_elapsed () {

    logsay( "SUM: Sucessfully timed tests: $elapsed_cnt" );
    logsay( "SUM: Overall run time: " . sprintf( "%.2fs" , $elapsed_sum )  );
    logsay( "SUM: Average run time: " .
	   (( $elapsed_cnt ) ? sprintf( "%.2fs", $elapsed_sum / $elapsed_cnt ) : "n/a") );
    logsay( "SUM: Minimum run time: " .
	   (( $elapsed_min != 1_000_000 ) ? sprintf( "%.2fs", $elapsed_min ) : "n/a" ) );
    logsay( "SUM: Maximum run time: " .
	   (( $elapsed_max ) ? sprintf( "%.2fs", $elapsed_max ): "n/a" ) );

}

#######################################################################
#                         print_arch - function                         #
#######################################################################
=head2 print_arch()

    print out architecture, hostname, ...

=cut
sub print_arch () {

    use Sys::Hostname;
    my $host = hostname;

    my $arch = "ARCH";
    my $clock = "CLOCK";
    my $os = $^O;
    
    logsay( "SUM: host: $host; arch: ARCH; clock: CLOCK; os: $os" );

}
#######################################################################
#                         doImport - function                         #
#######################################################################
=head2 doImport()

    purge all files from test target directory and import templated from
	the results directory tree
=cut

sub doImport ($$$) {
	my $type = shift; # xls or csv or sxc
	my $test = shift; # testname "bitsplice" ...
	my $path = shift; # testpath "bitsplice/verilog ...."

	# Check availability of "import" directory:
	my $store_cwd = getcwd();
	my $import_path = dirname( $store_cwd ) . "/results/" . $path;
	
	unless( -d $import_path ) {
		print( "ERROR: Missing results for test $test in $import_path!\n" );
		return;
	}

	# Copy input file:
	if ( -r dirname( $store_cwd ) . "/results/" . $test . "." . $type ) {
		copy( dirname( $store_cwd ) . "/results/" . $test . "." . $type, $test . "." . $type )
			or print( "ERROR: Cannot copy $test.$type to target $store_cwd: $!\n" );
	} else {
		print( "ERROR: Missing input file $test.$type, skipped!\n" );
		return;
	}

	# Create test directory if needed ...
	unless( -d $path ) {
	    mkdirRec( $path ) or die( "ERROR: Cannot create test directory $path" );
	}

	# Remove all files in $path (!! Has no backup !!)
	if ( chdir( $path ) ) {
		my $d = new DirHandle ".";
		if ( defined $d ) {
		    while (defined($_ = $d->read)) {
				next if ( -d $_ );
				unlink( $_ ) or
					print( "ERROR: Cannot delete $path/$_: $!\n" );
		    }
		} else {
			print ( "ERROR: Cannot open directory $path\n" );
			return;ed fil
		}

		# Copy over all needed parts from import ...
		# *.vhd[l], *.v, *-mixed.(csv|xls|sxc), *.bat
		# Use *.bat on MS
		for my $f ( glob( $import_path . "/*.v" ),
					glob( $import_path . "/*.vhd*" ),
					glob( $import_path . "/*mixed*.$type" ),
					glob( $import_path . "/*.bat" ),
					glob( $import_path . "/*.sh" ),
					glob( $import_path . "/mix.cfg" ),
				) {
			copy ( $f, basename( $f ) ) or print( "ERROR: Cannot import $f: $!\n" );
		}
	}
    chdir( $store_cwd ) or print( "ERROR: Cannot chdir to $store_cwd: $!\n" );
}


#######################################################################
#                            'main'                                   #
#######################################################################

init();

# run tests
foreach my $i (@inType) {
    logtrc( "INFO", "testing: $i-input" );
    chdir $i."_input" || die "Cannot change to " . $i . "_input";
    runMix( $i);
    chdir $FindBin::Bin;
}

my $summary = 0;

# print out statistics
print "\n\tStatistics:\n";
foreach my $i (@inType) {
    print "\tType: $i, ". $failstat{$i} ." of $numberOfTests Tests failed\n";
    $summary += $failstat{$i};
}
print "\naltogether: $summary of all $numTests Tests failed!\n";

print_elapsed();
print_arch();

exit;

=head2 MixTest.pl

B<MixTest.pl> S<[-cvs|-xls|-sxc]> S<[-import|-list|-export|-update|-purge]> S<[testname-re]>

Run tests in the test hierachy and help to maintain the test hierachy.

=over 4
=item -cvs
	Select csv tests (comma seperated values)

=item -xls
	Select ExCEL tests

=item -sxc
	Select OpenOffice tests

=item -import
	Instead of running the test, remove all files from the test directory and
	copy in test files from the /results/S<testname> directory

=item -list
	Instead of running the test, only list the selected tests.

=item -export
	Run the tests, remove all extra files and all extra worksheets from test results.
	The output of the export stage is ready to be used as templates for further
	regression tests and could be copied over to the /results hierachy.

=item -update
	Update the test output files inplace

=item -purge
	Remove extra files from the test directories.

=item -debug
	Start selected testcases in perl debugger.

=item S<testname-re>

	Select only tests which path matches the perl style regular expression.

=back

=head2 EXAMPLES

=over 4

=item MixTest.pl
	Runs all tests.

=item MixTest.pl -xls
	Runs all ExCEL tests.

=item MixTest.pl 'bitsplice.*'
	Runs all bitsplice files tests (e.g. bitsplice/verilog)

=item MixTest.pl -import -xls
	Import all ExCEL test cases from the S</results> tree.

=item MixTest.pl -list
	Lists all available test cases.

=item MixTest.pl -list -sxc bitsplice
	Will return a "selected bitsplice" message and a list of skipped test cases.

=item MixTest.pl -update -sxc bitsplice
	Update the bitsplice testcase in-place. Do this only after you have verified that the
	results are what you expect.

=item MixTest.pl -debug -sxc bitsplice
	Starts perl debugger with testcase S<bitsplice>. All other testcases are skipped.

=cut

#!End
