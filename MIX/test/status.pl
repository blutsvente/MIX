#!/usr/bin/perl

#use Cwd;


#my $path = cwd();
#chdir(test) || die("error");
#chdir(init) || die("error");

my $status = system( "/usr/bin/perl /home/abauer/src/MIX_new_struct/mix_0.pl $ARGV[0]  >init-t.out 2>&1" );

print "exit status: ".($status/256)."\n";















