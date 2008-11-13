# -*-* perl -*- -w
#  header for MS-Win! Remove for UNIX ...
#!/bin/sh --
#! -- # -*- perl -*- -w
eval 'exec ${PERL:-`[ ! -d "$HOME/bin/perl" -a -x "$HOME/bin/perl" ] && echo "$HOME/bin/perl" || { [ -x /usr/bin/perl ] && echo /usr/bin/perl || echo /usr/local/bin/perl ; } `} -x -S $0 ${1+"$@"} ;'
if 0; # dynamic perl startup; suppress preceding line in perl
#line 8


# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright Micronas GmbH, Munich 2002-2008                           |
# |     All Rights Reserved.                                              |
# |                                                                       |
# | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF MICRONAS GMBH          |
# | The copyright notice above does not evidence any actual or intended   |
# | publication of such source code.                                      |
# |                                                                       |
# +-----------------------------------------------------------------------+

# +-----------------------------------------------------------------------+
# | Id           : $Id: mix_1.pl,v 1.1 2008/11/13 11:54:49 lutscher Exp $  |
# | Version      : $Revision: 1.1 $                                      |
# | Mod.Date     : $Date: 2008/11/13 11:54:49 $                           |
# |                                                                       |
# +-----------------------------------------------------------------------+

# +-----------------------------------------------------------------------+
# |                                                                       |
# | Changes:                                                              |
# | $Log: mix_1.pl,v $
# | Revision 1.1  2008/11/13 11:54:49  lutscher
# | initial release
# |
# | Revision 1.4  2008/11/13 11:51:51  lutscher
# | initial release
# |
# | Revision 1.2  2008/11/13 11:50:31  lutscher
# | execute perm.
# |
# | Revision 1.1  2008/11/11 15:43:49  lutscher
# | initial release
# |
# +-----------------------------------------------------------------------+

#
# This is the new frontend for mix, using the Micronas::Mix package
# 

#******************************************************************************
# Other required packages
#******************************************************************************

# regular perl modules
use strict;
use warnings;
use Cwd;
use Pod::Text;

use FindBin;
use lib "$FindBin::Bin/..";
use lib "$FindBin::Bin/../lib/perl";
use lib "$FindBin::Bin";
use lib "$FindBin::Bin/lib/perl";
use lib getcwd() . "/lib/perl";
use lib getcwd() . "/../lib/perl";

# our package
use Micronas::Mix;

#******************************************************************************
# Global Variables
#******************************************************************************

$::VERSION = '$Revision: 1.1 $'; # RCS Id '
$::VERSION =~ s,\$,,go;

#
# init Mix object and specify commandline options
#
our($mix) = Micronas::Mix->new(options => 
                               [qw(
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
                                 )]);

=head1 MIX

=cut

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

-domain DOMAIN            Domain name for register view generation

=back

=cut


#
# process input
#
$mix->read_input();
$mix->parse_macros();
$mix->parse_hier();
$mix->parse_conn();
$mix->parse_io();
$mix->parse_registers();
$mix->gen_modules();

my $status = $mix->write_output();
exit $status;

#!End
