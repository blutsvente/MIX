#!/usr/bin/perl
#
#  test.pl
#  Run test scripts ...
#  Simple wrapper ...

$dir = "";
($^O=~/Win32/) ? ($dir=cwd())=~s,/,\\,g : ($dir=cwd());

# Set library search path to:
#   \PATH\PA\prg
#    use lib \PATH\PA\lib\perl
#    use lib \PATH\lib\perl
#    use lib `cwd`\lib\perl
#    use lib `cwd`..\lib\perl
# ...
# BEGIN{
#     ($^O=~/Win32/) ? ($dir=cwd())=~s,/,\\,g : ($dir=cwd());    
# 
#     ($pgm=$0) =~s;^.*(/|\\);;g;
#     if ( $0 =~ m,[/\\],o ) { #$0 has path ...
#         ($base=$0) =~s;^(.*)[/\\]\w+[/\\][\w\.]+$;$1;g;
#         ($pgmpath=$0) =~ s;^(.*)[/\\][\w\.]+$;$1;g;
#     } else {
#         ( $base = $dir ) =~ s,^(.*)[/\\][\w\.]+$,$1,g;
#         $pgmpath = $dir;
#     }
# }

# use lib "$base/";
# use lib "$base/lib/perl";
# use lib "$pgmpath/";
# use lib "$pgmpath/lib/perl";
# use lib "$dir/lib/perl";
# use lib "$dir/../lib/perl";
#TODO: Which "use lib path" if $0 was found in PATH?
use lib "h:/work/mix/lib/perl";

use Cwd;
use Log::Agent;
use Log::Agent::Priorities qw(:LEVELS);
use Log::Agent::Driver::File;

$::VERSION = '$Revision: 1.2 $'; # RCS Id
$::VERSION =~ s,\$,,go;

my $home = "h:/work/mix/t";
my $sumres = 0;

# %EH comes from Mic::MixUtils ; All the configuration E-nvironment will be there
logconfig(-driver =>
    Log::Agent::Driver::File->make(
         # -prefix      => $0,
         -showpid       => 1,
         -duperr        => 1,   #Send errors to OUTPUT and ERROR channel ...
         -channels    => {
             # 'error'  => "$0.err",
             'output' => "$home/t.out",
             'debug'  => "$home/t.dbg",
         },
                                   )
);


@tests = qw (
	bitsplice/bitsplice.bat
	bitsplice/verilog/bitsplice.bat
	sigport/sigport.bat
	sigport/use/sigport.bat
	sigport/verilog/sigport.bat
	highlow/highlow.bat
	highlow/verilog/highlow.bat
	mde_tests/conn_nreset/mde_tests.bat
	mde_tests/conn_nr_vhdl/mde_tests.bat
	constant/constant.bat
	constant/verilog/constant.bat
	case/case.bat
	case/force/force.bat
	case/check/case.bat
	io/io.bat
	io/verilog/io.bat
	generic/generic.bat
	generic/verilog/generic.bat
	genwidth/genwidth.bat
	genwidth/verilog/genwidth.bat
	nreset2/nreset2.bat
	open/open.bat
	open/verilog/open.bat
	macro/macro.bat
	verilog/verilog.bat
	verilog/vhdl/verilog.bat
	verilog/mixed/verilog.bat
	conf/conf.bat
	configuration/configuration.bat
	padio/padio.bat
	padio/names/padio.bat
	padio/bus/padio.bat
	padio/given/padio.bat
	padio2/padio2.bat
	typecast/typecast.bat
	init/init.bat
	autoopen/autoopen.bat
	autoopen/aaa/autoopen.bat
);
# init.bat: not a real testcase!!

use Getopt::Long qw(GetOptions); 
my %opts = ();
my $status = GetOptions( \%opts, qw (
	update!
	release!
	purge!
	)
);
# -update -> update all tests, do not check
# -release -> purge directories, excel sheets, run in update mode ...
# -release -> purge directories, excel sheets, ....

my $cwd = cwd();

for my $test ( @tests ) {

	my $path = ".";
	my $cmd  = "null.bat";
	my $testname = "testing";
	if ( $test =~ m,^(.*)[/\\]+(.*?)$, ) {
		$path = $1;
		$cmd  = $2;
		( $testname = $cmd ) =~ s,\..*,,;
	}
	chdir( $path );
	if ( -r "$testname-t.out" ) {
		rename( "$testname-t.out", "$testname-t.out.0" )
			or print "rename of $testname-t.out failed"
			and exit 1;
	}
	if ( defined( $opts{'update'} ) ) {
		$cmd =~ s/\.bat$/-update.bat/;
	}
	if ( defined( $opts{'purge'} ) ) {
		# TODO: remove mix_0.pl.out, *.diff, ....
		#
		unlink "mix_0.pl.out";
		unlink <*.diff>;
	} else {
	
		$status = system( "$cmd >$testname-t.out 2>&1" );
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
				close( LOG );
			} else {
				$cf = -1;
				$ci = -1;
			}
			$sumres++;
			logwarn "ERROR: test $test failed (I:$ci/F:$cf)\n";
		} else {
			# print "OK: test $test o.k.\n";
			logwarn "OK: test $test o.k.\n";
		}
	}
	chdir( $cwd );
}
print "\n#### Final result: $sumres of " . scalar( @tests ) .
	" tests failed!\n";
exit $sumres;

#!End
