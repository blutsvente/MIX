# -*-* perl -*- -w
#  header for MS-Win! Remove for UNIX ...
#!/bin/sh --
#! -- # -*- perl -*- -w
eval 'exec ${PERL:-`[ ! -d "$HOME/bin/perl" -a -x "$HOME/bin/perl" ] && echo "$HOME/bin/perl" || { [ -x /usr/bin/perl ] && echo /usr/bin/perl || echo /usr/local/bin/perl ; } `} -x -S $0 ${1+"$@"} ;'
if 0; # dynamic perl startup; suppress preceding line in perl
#line 8

# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright Micronas GmbH, Munich 2002/2003/2004/2005/2006            |
# |     All Rights Reserved.                                              |
# |                                                                       |
# | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF MICRONAS GMBH          |
# | The copyright notice above does not evidence any actual or intended   |
# | publication of such source code.                                      |
# |                                                                       |
# +-----------------------------------------------------------------------+

# +-----------------------------------------------------------------------+
# | Id           : $Id: mix_0.pl,v 1.49 2008/05/28 14:01:48 herburger Exp $  |
# | Name         : $Name:  $                                              |
# | Description  : $Description:$                                         |
# | Parameters   : -                                                      | 
# | Version      : $Revision: 1.49 $                                      |
# | Mod.Date     : $Date: 2008/05/28 14:01:48 $                           |
# | Author       : $Author: herburger $                                      |
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
# | Revision 1.49  2008/05/28 14:01:48  herburger
# | *** empty log message ***
# |
# | Revision 1.48  2008/05/09 07:32:20  lutscher
# | changed call to parse_register_master and mix_utils_open_input
# |
# | Revision 1.47  2006/11/15 09:55:05  wig
# | Added ImportVerilogInclude module: read defines and replace in input data.
# |
# | Revision 1.46  2006/06/16 07:47:41  lutscher
# | changed parameter to mix_report() call
# |
# | Revision 1.45  2006/05/03 12:10:33  wig
# | Improved top handling, fixed generated format
# |
# | Revision 1.44  2006/03/14 08:15:27  wig
# | Change to Log::Log4perl and replaces %EH by MixUtils::Globals.pm
# |
# | Revision 1.43  2005/12/09 13:15:47  lutscher
# | changed parse_i2c_init() to parse_register_master() in package Reg.pm
# |
# | Revision 1.42  2005/11/23 13:34:53  mathias
# | added parameter to mix_report
# |
# | Revision 1.41  2005/11/21 14:51:16  mathias
# | correct highlighting in Emacs
# |                                                                       |
# | ........                                                              |
# |                                                                       |
# |                                                                       |
# |                                                                       |
# +-----------------------------------------------------------------------+

# --------------------------------------------------------------------------

#******************************************************************************
# Other required packages
#******************************************************************************

# regular perl modules
use strict;
use warnings;
use Cwd;
use File::Basename;
use Getopt::Long qw(GetOptions);
use Pod::Text;
# use diagnostics; # -> will be set by -debug option

use FindBin;
use lib "$FindBin::Bin/..";
use lib "$FindBin::Bin/../lib/perl";
use lib "$FindBin::Bin";
use lib "$FindBin::Bin/lib/perl";
use lib getcwd() . "/lib/perl";
use lib getcwd() . "/../lib/perl";

#!wig20060223: logging made easy -> replacing Log::Agent!
use Log::Log4perl qw(:easy get_logger :levels);

# log4perl.logger                    = DEBUG, FileApp, ScreenApp

#    log4perl.appender.FileApp          = Log::Log4perl::Appender::File
#    log4perl.appender.FileApp.filename = test.log
#    log4perl.appender.FileApp.layout   = PatternLayout
#    log4perl.appender.FileApp.layout.ConversionPattern = %d> %m%n

#    log4perl.appender.ScreenApp          = Log::Log4perl::Appender::Screen
#    log4perl.appender.ScreenApp.stderr   = 0
#    log4perl.appender.ScreenApp.layout   = PatternLayout
#    log4perl.appender.ScreenApp.layout.ConversionPattern = %d> %m%n

# our own modules
use Micronas::MixUtils qw( $eh mix_init mix_getopt_header write_sum );
use Micronas::MixUtils::IO qw( init_ole mix_utils_open_input );
use Micronas::MixUtils::Globals;
use Micronas::MixParser;
use Micronas::MixIOParser;
# use Micronas::MixI2CParser; # replaced by Micronas::Reg
use Micronas::Reg;
use Micronas::MixWriter;
use Micronas::MixReport;


##############################################################################
# Prototypes (generated by "grep ^sub PROG | sed -e 's/$/;/'")

#******************************************************************************
# Global Variables
#******************************************************************************

$::VERSION = '$Revision: 1.49 $'; # RCS Id '
$::VERSION =~ s,\$,,go;

#
# Global access to logging and environment
#
if ( -r $FindBin::Bin . '/mixlog.conf' ) {
	Log::Log4perl->init( $FindBin::Bin . '/mixlog.conf' );
}
# Local overload:
if ( -r getcwd() . '/mixlog.conf' ) {
	Log::Log4perl->init( getcwd() . '/mixlog.conf' );
}

my $logger = get_logger('MIX'); # Start with MIX namespace

#
# Step 0: Init the global $eh (not visible here, stays in MixUtils namespace)
#
mix_init();               # Presets ...

=head1 DEBUG
# Testing the loggers:
$logger->all('__A_TAG', 'We want to ALL');
$logger->fatal('__F_TAG', 'This tests fatal');

$logger->error('__E_TAG', 'This is an error message level');
$logger->warn('__W_TAG', 'And an warn level message');
$logger->info('__I_TAG', 'info is sufficient');
$logger->debug('__D_TAG', 'debugging made easy');

$logger->fatal('no tag for this fatal');

=cut

##############################################################################
#
# Step 1: Read arguments, option processing,
#
# parse command line, print banner, print help (if requested),
# set quiet, verbose
#

=head2 options

=over 4

=item *

-dir DIRECTORY            write output data to DIRECTORY (default: cwd())

=item *

-out OUTPUTFILE.ext       defines intermediate output filename and type

=item *

-outenty OUT-e.vhd        filename for entity. If argument is ENTY[NAME], each entity
                                  will be written into a file calles entityname-e.vhd
=item *

-verifyentity PATH[:PATH] compare entities against entities found in PATH
                          alias: checkentity | ve

=item *

-verifyentitymode MODE    define the mode: entity|module|arch[itecture]|conf[iguration]|all,
                                   all|inpath,ignorecase

=item *

-combine                  combine entitiy, architecture and configuration into one file

=item *

-top TOPCELL              use TOPCELL as top. Default is TESTBENCH or daughter of TESTBENCH

=item *

-adump                    dump internal data in ASCII format, too (debugging, use with small data set).

=item *

-debug                    Dump more information for debugging

=item *

-variant                  <to be documented>

=item *

-vinc VERILOG_INCLUDE_FILE    import verilog defines from this file and resolve all occurences

=item *

-conf key.key.key=value   Overwrite $EH{key}{key}{key} with value

=item *

-cfg CONF.cfg             Read configuration from file CONF.cfg instead of mix.cfg (default)

=item *

-listconf                 Print out all available/predefined configurations options

=item *

-sheet SHEET=MATCH        SHEET can be one of "hier", "conn", "vi2c"

=item *

-delta                    Enable delta mode: Print diffs instead of full files.
                                  Maybe we can set a return value of 1 if no changes occured!

=item *

-strip                    Remove extra worksheets from intermediate output
                                  Please be catious when using that option.

=item *

-bak                      Shift previous generated output to file.v[hd].bak. When combined
                                  with -delta you get both .diff, .bak and new files :-)
=item *

-init                     Initialize MIX working area

=item *

-import FILE              Try to import data from HDL files

=item *

-report portlist,reglist  Report portlist, register list, (t.b.d.)  

=item *

-domain DOMAIN            Domain name for register view generation

=back

=cut

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
	vinc|veriloginc=s@
    adump!
    conf|config=s@
    cfg=s
    sheet=s@
    listconf
    delta!
    strip!
    bak!
    init
    import=s@
    report=s@
	domain=s
    ));

if ( $#ARGV < 0 ) { # Need  at least one sheet!!
    $logger->fatal('__F_MISSARG', 'No input file specified!');
    exit 1;
}

##############################################################################
#
# Step 2: Open input files one by one and retrieve the tables
# Do a first simple conversion from Excel arrays into array of hashes
#



my( $r_connin, $r_hierin, $r_ioin, $r_i2cin, $r_xml);
($r_connin, $r_hierin, $r_ioin, $r_i2cin, $r_xml) = mix_utils_open_input( @ARGV ); #Fetches HIER, CONN and register-master sheet(s) and XML database


##############################################################################
#
# Step 3: Retrieve generator statements (generators, macros) from the input data
# The information will be removed from the input data fields (masking ::comment field)
# 
my $r_connmacros = parse_conn_macros( $r_connin );
my $r_conngen = parse_conn_gen( $r_connin );
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

# Parse Register-master



my $o_space = Micronas::Reg::parse_register_master( $r_i2cin , $r_xml);


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

# mix_report($r_i2cin);
mix_report($o_space);

#
# BACKEND add for debugging:
#
write_entities();

write_architecture();

write_configuration();

my $status = ( write_sum() ) ? 1 : 0; # If write_sum returns > 0 -> exit status 1

exit $status;

#!End
