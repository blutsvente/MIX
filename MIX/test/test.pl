#!/bin/sh -- # -*- perl -*- -w
# TODO: Get better startup (look in FAQ ...)

eval 'exec $M_PERL -S $0 ${1+"$@"}'
if 0; # dynamic perl startup; suppress preceding line in perl

# eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}' || eval 'exec perl -S $0 $argv'
# if 0; # dynamic perl startup

#
# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright Micronas GmbH, Inc. 2002.                                 |
# |     All Rights Reserved.                                              |
# |                                                                       |
# |                                                                       |
# | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF MICRONAS GMBH          |
# | The copyright notice above does not evidence any actual or intended   |
# | publication of such source code.                                      |
# |                                                                       |
# +-----------------------------------------------------------------------+

# --------------------------------------------------------------------------

#******************************************************************************
# Other required packages
#******************************************************************************

use strict;
use Cwd;
use File::Basename;
use Getopt::Long qw(GetOptions);
use Pod::Text;
# use diagnostics; # -> will be set by -debug option

# These packages need to be installed, too
# use lib 'h:\work\x2v\lib\perl'; ##TODO: Rewrite that to a generic place ....

use vars qw($pgm $base $pgmpath $dir);

$dir = "";
($^O=~/Win32/) ? ($dir=getcwd())=~s,/,\\,g : ($dir=getcwd());

# Set library search path to:
#   \PATH\PA\prg
#    use lib \PATH\PA\lib\perl
#    use lib \PATH\lib\perl
#    use lib `cwd`\lib\perl
#    use lib `cwd`..\lib\perl
# ...
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

use lib "$base/";
use lib "$base/lib/perl";
use lib "$pgmpath/";
use lib "$pgmpath/lib/perl";
use lib "$dir/lib/perl";
use lib "$dir/../lib/perl";
#TODO: Which "use lib path" if $0 was found in PATH?

use Log::Agent;
use Log::Agent::Priorities qw(:LEVELS);
use Log::Agent::Driver::File;

use Micronas::MixUtils;
use Micronas::MixParser;
use Micronas::MixIOParser;
use Micronas::MixWriter;
use Micronas::MixUtils::IO;

##############################################################################
# Prototypes (generated by "grep ^sub PROG | sed -e 's/$/;/'")

#t.b.d...

#******************************************************************************
# Global Variables
#******************************************************************************

$::VERSION = '$Revision: 1.1 $'; # RCS Id
$::VERSION =~ s,\$,,go;

# %EH comes from Mic::MixUtils ; All the configuration E-nvironment will be there
logconfig(
        -driver => Log::Agent::Driver::File->make(
        # -prefix      => $0,
        -showpid       => 1,
        -duperr        => 1,   #Send errors to OUTPUT and ERROR channel ...
        -channels    => {
        # 'error'  => "$0.err",
            'output' => "$pgm.out",
            'debug'  => "$pgm.dbg",
            },
        )
);

