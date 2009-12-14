#!/tools/perl_5.8.0/sparc-solaris28/bin/perl -w

#
# Generate differences of two VHDL files
#
# Strip away comments
# replace all \s+ by a single space
# lowercase everything
# sort content
# diff ....

# $/ = undef;
# my $n = 0;

use Text::Diff;

my %data = ();
my @files = @ARGV;

if ( $#ARGV != 1 ) {
	print "Usage: $0 file1.vhd file2.vhd\n";
	exit 1;
}

# Strip 
while ( <> ) {
	$_ =~ s/--.*$//o;
	$_ =~ s/\s+/ /og;

	next if ( m/^\s*$/o );
	push( @{$data{$ARGV}}, lc( $_ ) );

}

# Sort
for my $i ( 0..$#files ) {
	@{$data{$files[$i]}} = sort( @{$data{$files[$i]}} );
}

# Diff
my $diff = "";
diff $data{$files[0]}, $data{$files[1]},
	{ STYLE => "Table",
	  # STYLE => "Context",
	  FILENAME_A => $files[0],
	  FILENAME_B => $files[1],
	  CONTEXT => 0,
	  OUTPUT     => \*STDOUT,
	};



#!End
