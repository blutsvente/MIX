#!/usr/bin/perl -w

#
# diff filter: take all of the files and postprocess diff output
#  to ease the testcase update process

use Cwd;
use strict;
use warnings;
use diagnostics;
use FileHandle;
use File::Basename;

my $cwd = getcwd();
my $fh = new FileHandle;

my $golden = $cwd;
unless ( $cwd =~ m/_input/ ) {
	$cwd .= "/xls_input";
	$golden .= "/results";
} else {
	$golden =~ s/(xls|sxw|cvs)_input/results/;
}

my $dir = $cwd;
my $base = basename( $cwd );
my @cases = ();
if ( scalar( @ARGV ) > 0 ) { # Iterate through ARGV
	@cases = grep( !/\.(\w+)$/, @ARGV);
	map( { $_ =~ s,.*xls_input/,,; } @cases );
} else {
	push( @cases, $base );
	$dir = dirname( $base );
	$golden = dirname( $golden );
}

for my $c ( sort( @cases ) ) {
	my $comm_only  = 0;
	my $mix_out_ap = 0;
	my $delta = -1;
	my $change_i = -1;
	my $change_f = -1;

	next if ( $c =~ m/META-INF/ );
	next if ( $c =~ m/xls2csv/ );

	unless ( -d ( $dir . "/" . $c ) ) {
		warn( "Cannot read test case directory $dir/$c!" );
		next;
	}
	unless ( -d ( $golden . "/" . $c ) ) {
		warn( "Cannot read reference case directory $dir/$c!" );
		next;
	}

	my $diffs = "";
	if ( open( $fh, "diff -r $dir/$c $golden/$c | " ) ) {
		# read 
		local $/ = undef;
		$diffs = <$fh>; # Read all of it.
		close $fh;
	} else {
		warn( "Could not start diff for $dir/$c!" );
		next;
	}
			
	print "###### Start with $c: removed $comm_only comm_only, got $mix_out_ap mix_out_ap!\n";
	while ( $diffs =~ s/^(diff(.*)\n)
		(^\d+(,\d+)?c\d+(,\d+)?\n
		^((<\s--|---|>\s--).*\n)+)+/$1/mx )
		{
			# do nothing
			$comm_only++;
			# print "debug: match comments only: $1\n";
		}
	while ( $diffs =~ s!^(diff(.*)\n)
		(^\d+(,\d+)?c\d+(,\d+)?\n
		^((<\s//|---|>\s//).*\n)+)+!$1!mx )
		{
			# do nothing
			$comm_only++;
			# print "debug: match comments only: $1\n";
		}

	# Open mix_0.pl.out and see what the end was:
	my $mix0 = "";
	# Read all mix_0.pl.out here:
	my @mix0files = `find $dir/$c -name mix_0.pl.out -print`;
	for my $mo ( @mix0files ) {
		chomp( $mo );
		$delta = -1;
		$change_i = -1;
		$change_f = -1;
		if ( open( $fh, "<$mo" ) ) {
			local $/ = undef;
			$mix0 = <$fh>;
			close( $fh );
		} else {
			print "ERROR: cannot open $dir/$c/mix_0.pl.out: $!\n";
		}
		#
		#05/07/13 17:29:56 WARNING: SUM: Number of changes in intermediate: 0
		#05/07/13 17:29:56 WARNING: SUM: Number of changed files: 0
		# 
		if ( $mix0 =~ m/^.*WARNING:\sSUM:\sNumber\sof\schanges\sin\sintermediate:\s(\d+)\s+
			 	^.*WARNING:\sSUM:\sNumber\sof\schanged\sfiles:\s(\d+)\s*\z/mx ) {+
			$delta    = 1;
			$change_i = $1;
			$change_f = $2;
		}
		# 05/07/13 17:29:56 WARNING: SUM: conf 0
		# 05/07/13 17:29:56 WARNING: SUM: hier 1
		# 05/07/13 17:29:56 WARNING: SUM: conn 1
		# 05/07/13 17:29:56 WARNING: SUM: io 0
		# 05/07/13 17:29:56 WARNING: SUM: i2c 0
		if ( $mix0 =~ m/^.*WARNING:\sSUM:\s\w+\s(\d+)\s+\z/mx ) {
			$delta = 0;
			$change_f = $change_i = "<NA>";
		}
		print "## Subtestcase success: $mo: delta: $delta, change_i: $change_i, change_f: $change_f\n";
	}

	while ( $diffs =~ s/^diff.*mix_0\.pl\.out\n+
		^\d+(,\d+)?d\d+(,\d+)?\n
		(<\s.*\n)+//mx )
		{
			# do nothing
			$mix_out_ap++;
			# print "debug: match extended mix_0.pl.out\n";
		}

		while ( $diffs =~ s/^Only in.*(\.swp|CVS|out|out\.0)\n//m ) {
		# print "debug: match swp\n";
	};
	while ( $diffs =~ s/^Only in.*CVS\n//m ) {
		# print "debug: match CVS\n";
	};
	 
	# Left over to print -> print into summary file:
	if ( open( $fh, "> $dir/$c/$c.alldiff" ) ) {
		print $fh $diffs;
		close $fh;
	} else {
		die "Cannot print out diffs: $!";
	}
	print "###### Done with $c: removed $comm_only comm_only, got $mix_out_ap mix_out_ap!\n";
	print "# Results $c: delta: $delta, files: $change_f, intermeditate: $change_i!\n";
	print "\n";
}
