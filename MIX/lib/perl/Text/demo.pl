#! /usr/local/bin/perl -w

# TRY DOING *THIS* WITH format!

use Text::Autoformat qw(form break_with);

my $text = join "", map "line $_\n", (1..20);

@lines = form { 
	pagelen=>6,
	header => sub { "Page $_[0]\n" },
	footer => sub { return "" if $_[1];
			"-"x50 . "\n" . form ">"x50, "...".($_[0]+1);
		      },
	pagefeed => "\n"x10
	},
"      [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[\n",
       \$text;

print @lines;

