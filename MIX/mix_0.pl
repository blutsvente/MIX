# -*-* perl -*- -w
#  header for MS-Win! Remove for UNIX ...
#!/bin/sh --
#! -- # -*- perl -*- -w
eval 'exec ${PERL:-`[ ! -d "$HOME/bin/perl" -a -x "$HOME/bin/perl" ] && echo "$HOME/bin/perl" || { [ -x /usr/bin/perl ] && echo /usr/bin/perl || echo /usr/local/bin/perl ; } `} -x -S $0 ${1+"$@"} ;'
if 0; # dynamic perl startup; suppress preceding line in perl

use strict;
use warnings;
use Cwd;
use File::Basename;
use Getopt::Long qw(GetOptions);
use Pod::Text;
# use diagnostics; # -> will be set by -debug option
# use English;       # -> not need this, just consumes performance

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
# | Id           : $Id: mix_0.pl,v 1.36 2005/07/13 15:41:21 wig Exp $  |
# | Name         : $Name:  $                                              |
# | Description  : $Description:$                                         |
# | Parameters   : -                                                      | 
# | Version      : $Revision: 1.36 $                                      |
# | Mod.Date     : $Date: 2005/07/13 15:41:21 $                           |
# | Author       : $Author: wig $                                      |
# | Phone        : $Phone: +49 89 54845 7275$                             |
# | Fax          : $Fax: $                                                |
# | Email        : $Email: wilfried.gaensheimer@micronas.com$             |
# |                                                                       |
# | Copyright (c)2002 Micronas GmbH. All Rights Reserved.                 |
# | MIX proprietary and confidential information.                         |
# |                                                                       |
# +-----------------------------------------------------------------------+

# +-----------------------------------------------------------------------+
# |                                                                       |
# | Changes:                                                              |
# | $Log: mix_0.pl,v $
# | Revision 1.36  2005/07/13 15:41:21  wig
# | Remove pid from log output
# |
# | Revision 1.35  2005/06/23 13:14:42  wig
# | Update repository, not yet verified
# |
# | Revision 1.34  2005/04/14 06:53:00  wig
# | Updates: fixed import errors and adjusted I2C parser
# |                                                    |
# | Revision 1.33  2004/11/10 09:46:20  wig                               |
# | added verilog includes                                                |
# |                                                                       |
# | Revision 1.32  2004/06/16 08:36:45  wig                               |
# | Removed comments.                                                     |
# |                                                                       |
# | Revision 1.30  2004/04/14 11:08:55  wig
# | minor code clearing
# |
# | Revision 1.29  2004/04/07 15:11:40  wig
# | Modified Files:
# | 	mix_0.pl
# |
# | Revision 1.28  2004/03/25 11:21:11  wig
# | Added -verifyentity option
# |
# | Revision 1.26  2003/12/22 08:22:44  wig
# | Added output.generate.xinout feature
# |
# | Revision 1.25  2003/12/18 16:48:14  wig
# | removed init_ole
# |
# | Revision 1.24  2003/12/10 15:00:48  abauer
# | *** empty log message ***
# |
# | Revision 1.23  2003/12/10 10:17:32  abauer
# | *** empty log message ***
# |
# | Revision 1.22  2003/12/04 14:39:20  abauer
# | *** empty log message ***
# |
# | Revision 1.21  2003/12/04 14:39:10  abauer
# | *** empty log message ***
# |                                                                       |
# | Revision 1.20  2003/11/27 13:18:33  abauer                            |
# | *** empty log message ***                                             |
# |                                                                       |
# | Revision 1.19  2003/11/27 10:24:29  abauer                            |
# | added i2c a_clk spreadsheet                                           |
# |                                                                       |
# | Revision 1.18  2003/11/27 09:08:25  abauer                            |
# | moved sheet handling into extra package                               |
# | added StarOffice Spreadsheet reader/writer                            |
# | added comma seperated value reader/writer                             |
# | removed OLE sheet handling                                            |
# | added native perl Excel-sheet reader                                  |
# | converted test cases                                                  |
# | moved documentation mix_doc -> doc                                    |
# |                                                                       |
# | Revision 1.17  2003/10/23 11:59:37  abauer                            |
# | .                                                                     |
# |                                                                       |
# | Revision 1.16  2003/10/14 10:18:41  wig                               |
# | Added -bak command line option                                        |
# | Added ::descr to port maps (just a try)                               |
# |                                                                       |
# | Revision 1.14  2003/07/29 15:48:03  wig                               |
# | Lots of tiny issued fixed:                                            |
# | - Verilog constants                                                   |
# | - IO port                                                             |
# | - reconnect                                                           |
# |                                                                       |
# | Revision 1.13  2003/07/09 07:52:43  wig                               |
# | Adding first version of Verilog support.                              |
# | Fixing lots of tiny issues (see TODO).                                |
# | Adding first release of documentation.                                |
# |                                                                       |
# | Revision 1.12  2003/06/04 15:52:42  wig                               |
# | intermediate release, before releasing alpha IOParser                 |
# |                                                                       |
# | Revision 1.11  2003/04/29 08:27:02  wig                               |
# | Minor issue: Revision ID in mix_0.pl                                  |
# |                                                                       |
# | Revision 1.10  2003/04/29 07:22:35  wig                               |
# | Fixed %OPEN% bit/bus problem.                                         |
# |                                                                       |
# | Revision 1.9  2003/04/01 14:27:58  wig                                |
# | Added IN/OUT Top Port Generation                                      |
# |                                                                       |
# | Revision 1.8  2003/03/21 17:00:08  wig                                |
# | Preliminary working version for bus splices                           |
# |                                                                       |
# | Revision 1.7  2003/03/14 14:51:58  wig                                |
# | Added -delta mode for backend.                                        |
# |                                                                       |
# | Revision 1.6  2003/03/13 14:05:04  wig                                |
# | Releasing major reworked version                                      |
# | Now handles bus splices much better                                   |
# |                                                                       |
# | Revision 1.5  2003/02/28 15:04:14  wig                                |
# | Intermediate version with lots of fixes.                              |
# | Signal issue still open.                                              |
# | Saved because of pending holiday.                                     |
# |                                                                       |
# | Revision 1.4  2003/02/21 16:05:27  wig                                |
# | Added options:                                                        |
# | -conf                                                                 |
# | -sheet                                                                |
# | -listconf                                                             |
# | see TODO.txt, 20030220/21                                             |
# |                                                                       |
# | Revision 1.3  2003/02/20 15:05:42  wig                                |
# | Extended TODO list                                                    |
# |                                                                       |
# | Revision 1.2  2003/02/04 07:28:44  wig                                |
# | Fixed header of modules                                               |
# |                                                                       |
# | Revision 1.1.1.1  2003/02/03 12:56:44  wig                            |
# | Importing pilot release of MIX tools                                  |
# |                                                                       |
# |                                                                       |
# +-----------------------------------------------------------------------+

# --------------------------------------------------------------------------

#******************************************************************************
# Other required packages
#******************************************************************************

use FindBin;

use lib "$FindBin::Bin/..";
use lib "$FindBin::Bin/../lib/perl";
use lib "$FindBin::Bin";
use lib "$FindBin::Bin/lib/perl";
use lib getcwd() . "/lib/perl";
use lib getcwd() . "/../lib/perl";

use Log::Agent;
use Log::Agent::Priorities qw(:LEVELS);
use Log::Agent::Driver::File;

use Micronas::MixUtils qw( mix_init %EH mix_getopt_header);
use Micronas::MixUtils::IO qw(init_ole mix_utils_open_input write_sum);
use Micronas::MixParser;
use Micronas::MixIOParser;
use Micronas::MixI2CParser;
use Micronas::MixWriter;


##############################################################################
# Prototypes (generated by "grep ^sub PROG | sed -e 's/$/;/'")

#t.b.d...

#******************************************************************************
# Global Variables
#******************************************************************************

$::VERSION = '$Revision: 1.36 $'; # RCS Id
$::VERSION =~ s,\$,,go;

logconfig(
        -driver => Log::Agent::Driver::File->make(
        # -prefix      => $0,
        -showpid       => 0,
        -duperr        => 1,   #Send errors to OUTPUT and ERROR channel ...
        -channels    => {
        # 'error'  => "$0.err",
            'output' => $FindBin::Script . ".out",
            'debug'  => $FindBin::Script . ".dbg",
            },
        )
);

#
# Step 0: Init $0
#
mix_init();               # Presets ....


##############################################################################
#
# Step 1: Read arguments, option processing,
#
# parse command line, print banner, print help (if requested),
# set quiet, verbose
#

#
#TODO: Add that to application note
# -dir DIRECTORY            write output data to DIRECTORY (default: cwd())
# -out OUTPUTFILE.ext       defines intermediate output filename and type
# -outenty OUT-e.vhd        filename for entity. If argument is ENTY[NAME], each entity
#                                   will be written into a file calles entityname-e.vhd
# -verifyentity PATH[:PATH] compare entities against entities found in PATH
#                           alias: checkentity | ve
# -verifyentitymode MODE    define the mode: entity|module|arch[itecture]|conf[iguration]|all,
#                                    all|inpath,ignorecase
# -combine                  combine entitiy, architecture and configuration into one file
# -top TOPCELL              use TOPCELL as top. Default is TESTBENCH or daughter of TESTBENCH
# -adump                    dump internal data in ASCII format, too (debugging, use with small data set).
# -variant
# -conf key.key.key=value   Overwrite $EH{key}{key}{key} with value
# -listconf                 Print out all available/predefined configurations options
# -sheet SHEET=MATCH        SHEET can be one of "hier", "conn", "vi2c"
# -delta                    Enable delta mode: Print diffs instead of full files.
#                                   Maybe we can set a return value of 1 if no changes occured!
# -strip                    Remove extra worksheets from intermediate output
#                                   Please be catious when using that option.
# -bak                      Shift previous generated output to file.v[hd].bak. When combined
#                                   with -delta you get both .diff, .bak and new files :-)
#
# -init                     Initialize MIX working area
# -import FILE              Try to import data from HDL files
# -report HIER|ENTY|SIGN    Report hierachy, entities and/or signals  
#

# Add your options here ....
mix_getopt_header( qw(
    dir=s
    out=s
    outenty=s
    outarch=s
    outconf=s
    verifyentity|checkentity|ve=s@
    verifyentitymode|checkentitymode|vem=s
    combine!
    top=s
    variant=s
    adump!
    conf|config=s@
    sheet=s@
    listconf
    delta!
    strip!
    bak!
    init
    import=s@
    ));

if ( $#ARGV < 0 ) { # Need  at least one sheet!!
    logdie("ERROR: No input file specified!\n");
}

##############################################################################
#
# Step 2: Open input files one by one and retrieve the tables
# Do a first simple conversion from Excel arrays into array of hashes
#

#!wig20031217: now in write_xls (only used there) 
# if( ( $^O=~ m/MSWin/ && join( " ", @ARGV)=~ m/\.xls/) || $EH{'format'}{'out'}=~ m/^xls$/ ) {
#    init_ole();
#}

my( $r_connin, $r_hierin, $r_ioin, $r_i2cin);
( $r_connin, $r_hierin, $r_ioin, $r_i2cin ) = mix_utils_open_input( @ARGV ); #Fetches HIER and CONN sheet(s)

##############################################################################
#
# Step 3: Retrieve generator statements (generators, macros) from the input data
# The information will be removed from the input data fields (masking ::comment field)
# 
my $r_connmacros = parse_conn_macros( $r_connin );
my $r_conngen = parse_conn_gen( $r_connin );
# my $r_hiergen = parse_hier_gen( $r_hierin );
my $r_hiergen = parse_conn_gen( $r_hierin );

##############################################################################
#
# Step 4: Initialize Hierachy DB and convert to internal format
#
parse_hier_init( $r_hierin ); #, $r_connmacros, $r_conngen, $r_hiergen );

##############################################################################
#
# Step 5: Parse connectivity and convert to internal format
#
parse_conn_init( $r_connin );

# Parse IO
parse_io_init( $r_ioin );

# Parse I2C
parse_i2c_init( $r_i2cin );

apply_conn_macros( $r_connin, $r_connmacros );

apply_hier_gen( $r_hiergen );

apply_conn_gen( $r_conngen );

#
# Get rid of some "artefacts"
#
purge_relicts();

#
# Replace %MAC% before output
#
parse_mac();

#
# Add conections and ports if needed (hierachy traversal)
# Add connections to TOPLEVEL for connections without ::in or ::out
# Replace OPEN and %OPEN% 
#
add_portsig();

#
# Replace %MAC% before output
#
#!do before signal expansion ..... parse_mac();

#
# Get rid of some "artefacts", again (add_portsig and add_sign2hier might have
# added something ....
#
purge_relicts();

#
# Add a list of all signals for each instance
#
add_sign2hier();

#
# Checks go here ...
#
# 1. Get everything lowercased (depends on configuration!)
# check_cases();

#
# Backend jobs ...located here because I want to dump it with -adump!
#
generate_entities();

#
##############################################################################
#
# Step LAST: Dump intermediate data
# mix_store_db knows which data to dump
#
#mix_store_db( "dump",
#                    "internal",
#                {   'conn_macros' => $r_connmacros,
#                    'conn_gen' => $r_conngen,
#                    'hier_gen' => $r_hiergen,
#                    'entities'  => \%Micronas::MixWriter::entities,
#                },
#    );
#
# Write intermediate data ...
#
mix_store_db( "out", "auto", {} );

#
# BACKEND add for debugging:
#
write_entities();

write_architecture();

write_configuration();

my $status = ( write_sum() ) ? 1 : 0; # If write_sum returns > 0 -> exit status 1

exit $status;

#!End
