#!/bin/perl -w

#
# find \begin_inset ERT ....
#

sub convert_inset ($);

$/=undef;

my $lines = <>; # Read all of file
my $out = ();

while( $lines =~ m,(.*?)(\\begin_inset ERT(.*?)\\end_inset),imsg ) {
    print "********* found inset: ********\n";
    print "$3\n"; 
    my $insetconv = convert_inset( $3 );
	print "******** converted **********\n";
	print $insetconv . "\n";
    $out .= $1 . $insetconv;
}

unless( open( WRITE, "> converted.lyx" ) ) {
	die "Cannot open output file converted.lyx";
}
print WRITE $out; 

## end of main ..
sub convert_inset ($) {
	my $inset = shift;

	my $ret = "";
	if ( $inset =~ m/.*status\s+\w+\s+\\layout\s+Standard\s+(.*)/ims ) {
		my $body = $1;
		if ( $body =~ m/.*\\backslash\s+newpage\s+/ims ) {
			$ret = '\pagebreak_top' . "\n";
		} elsif ( $body =~ m/\\backslash\s+
                                     begin{(tt|bf|it)}(.*)\s+
                                     \\backslash\s+
                                     end{(tt|bf|it)}/xms ) {
			if ( $1 eq "tt" ) {
				$ret = "\\family typewriter\n$2\n\\family default";
			} elsif ( $1 eq "bf" ) {
				$ret = "\\series bold\n$2\n\\series default";
			} else {
				$ret = "\\emph on\n$2\n\\emph default";
			}
		} elsif ( $body =~ m/.*\\backslash\s+hspace/ims ) {
			# Do nothing;
		} else {
			print "unknown inset: $body";
		}
		$ret =~ s/\\backslash\s+_/_/g;
		
	} else {
		print "Cannot detect inset: $inset\n";
	}

	if ( $ret ) {
	     return $ret;
	} else {
	     return "\\begin_inset ERT" . $inset . "\\end_inset";
	}
}

__END__

**1:
status Collapsed

\layout Standard

\backslash
newpage

==>
\pagebreak_above

**2:
status Collapsed

\layout Standard

\backslash
begin{tt}mix
\backslash
_simple-mixed.xls
\backslash
end{tt}

->
\family typewriter 
$ mix foo.xls
\family default 

**3:
\backslash_  -> \_
#!Done
