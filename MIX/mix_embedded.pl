#! /usr/bin/perl -w
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

# +-----------------------------------------------------------------------+
# | Id           : $Id: mix_embedded.pl,v 1.1 2004/02/18 15:16:32 abauer Exp $     |
# | Name         : $Name:  $                                   |
# | Description  : $Description: simple wrapper script for embedding MIX $|
# | Parameters   : -                                                      | 
# | Version      : $Revision: 1.1 $                                       |
# | Mod.Date     : $Date: 2004/02/18 15:16:32 $                           |
# | Author       : $Author: abauer $                                      |
# | Email        : $Email: Alexander.Bauer@micronas.com$                  |
# |                                                                       |
# | Copyright (c)2002 Micronas GmbH. All Rights Reserved.                 |
# | MIX proprietary and confidential information.                         |
# |                                                                       |
# +-----------------------------------------------------------------------+

# +-----------------------------------------------------------------------+
# | Changes:
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

# Todo: get appropriate MIX path from config file

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

use Micronas::MixUtils qw( mix_init %EH mix_getopt_header);
use Micronas::MixUtils::IO qw(init_ole mix_utils_open_input write_sum);
use Micronas::MixParser;
use Micronas::MixIOParser;
use Micronas::MixI2CParser;
use Micronas::MixWriter;


#******************************************************************************
# Global Variables
#******************************************************************************

$::VERSION = '$Revision: 1.1 $'; # RCS Id
$::VERSION =~ s,\$,,go;

mix_init(); # load Presets ....


sub readSpreadsheet(@) {

    my $argv = shift;

    my( $r_connin, $r_hierin, $r_ioin, $r_i2cin);
    my $r_connmacros;
    my( $r_conngen, $r_hiergen);
    
     #Fetches HIER, CONN, IO and I2C sheet(s)
    ( $r_connin, $r_hierin, $r_ioin, $r_i2cin) = mix_utils_open_input( @ARGV);

    # parse Data
    $r_connmacros = parse_conn_macros( $r_connin);
    $r_conngen = parse_conn_gen( $r_connin);
    $r_hiergen = parse_conn_gen( $r_hierin);

    parse_hier_init( $r_hierin );
    parse_conn_init( $r_connin );
    parse_io_init( $r_ioin );
    parse_i2c_init( $r_i2cin );

    # Parse connectivity and convert to internal format
    apply_conn_macros( $r_connin, $r_connmacros );
    apply_hier_gen( $r_hiergen );
    apply_conn_gen( $r_conngen );

    # Get rid of some "artefacts"
    purge_relicts();

    # Replace %MAC% before output
    parse_mac();

    # Add conections and ports if needed (hierachy traversal)
    # Add connections to TOPLEVEL for connections without ::in or ::out
    # Replace OPEN and %OPEN% 
    add_portsig();

    # Replace %MAC% before output
    #!do before signal expansion ..... parse_mac();

    # Get rid of some "artefacts", again (add_portsig and add_sign2hier might have
    # added something ....
    purge_relicts();

    # Add a list of all signals for each instance
    add_sign2hier();

}


sub getIntFromEH($) {

    my @keys = shift;

}


sub getStringFromEH($) {

    my @keys = shift;

    return ;
}


1;

__END__
