# -*- perl -*---------------------------------------------------------------
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
#
# +-----------------------------------------------------------------------+
# | Project:    Micronas - MIX                                            |
# | Modules:    $RCSfile: MixUtils.pm,v $                                 |
# | Revision:   $Revision: 1.41 $                                         |
# | Author:     $Author: wig $                                         |
# | Date:       $Date: 2003/12/22 08:33:11 $                              |
# |                                                                       |
# | Copyright Micronas GmbH, 2002                                         |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/MixUtils.pm,v 1.41 2003/12/22 08:33:11 wig Exp $ |
# +-----------------------------------------------------------------------+
#
# + A lot of the functions here are taken from mway_1.0/lib/perl/Banner.pm +
#
# +-----------------------------------------------------------------------+
# |
# | Changes:
# | $Log: MixUtils.pm,v $
# | Revision 1.41  2003/12/22 08:33:11  wig
# | Added output.generate.xinout feature
# |
# | Revision 1.40  2003/12/18 16:49:15  wig
# | added OLE, again
# | fixed misc. minor issues regarding delta mode
# |
# | Revision 1.37  2003/12/10 14:37:17  abauer
# | *** empty log message ***
# |
# | Revision 1.36  2003/12/04 14:56:32  abauer
# | corrected cvs problems
# |
# | Revision 1.35  2003/11/27 13:18:40  abauer
# | *** empty log message ***
# |
# | Revision 1.34  2003/11/27 09:08:56  abauer
# | *** empty log message ***
# |
# | Revision 1.33  2003/11/10 09:30:57  wig
# | Adding testcase for verilog: create dummy open wires
# |
# | Revision 1.32  2003/10/29 13:34:49  abauer
# | new Documentation
# |
# | Revision 1.31  2003/10/23 12:10:54  wig
# | added counter for macro evaluation cmacros
# |
# | Revision 1.30  2003/10/23 11:27:28  abauer
# | added strip
# |
# | Revision 1.29  2003/10/14 10:18:42  wig
# | Added -bak command line option
# | Added ::descr to port maps (just a try)
# |
# | Revision 1.27  2003/09/08 15:14:23  wig
# | Fixed Verilog, extended path checking
# |
# | Revision 1.24  2003/08/11 07:16:24  wig
# | Added typecast
# | Fixed Verilog issues
# |
# | Revision 1.23  2003/07/29 15:48:05  wig
# | Lots of tiny issued fixed:
# | - Verilog constants
# | - IO port
# | - reconnect
# |
# | Revision 1.21  2003/07/17 12:10:43  wig
# | fixed minor bugs:
# | - Verilog `define before module
# | - Verilog open
# | - signals(NN) in IO-Parser failed (bad reg-ex)
# |
# | Revision 1.16  2003/06/04 15:52:43  wig
# | intermediate release, before releasing alpha IOParser
# |
# | Revision 1.15  2003/04/29 07:22:36  wig
# | Fixed %OPEN% bit/bus problem.
# |
# | Revision 1.14  2003/04/28 06:40:37  wig
# | Added %OPEN% (to allow ports without connection, use VHDL open keyword)
# | Started parseIO (not operational, would be a branch instead)
# | Fixed nreset2 issue (20030424a bug)
# |
# | Revision 1.13  2003/04/01 14:27:59  wig
# | Added IN/OUT Top Port Generation
# |
# | Revision 1.12  2003/03/21 16:59:19  wig
# | Preliminary working version for bus splices
# |
# | Revision 1.11  2003/03/14 14:52:11  wig
# | Added -delta mode for backend.
# |
# | Revision 1.10  2003/03/13 14:05:19  wig
# | Releasing major reworked version
# | Now handles bus splices much better
# |
# | Revision 1.9  2003/02/28 15:03:44  wig
# | Intermediate version with lots of fixes.
# | Signal issue still open.
# |
# | Revision 1.8  2003/02/21 16:05:14  wig
# | Added options:
# | -conf
# | -sheet
# | -listconf
# | see TODO.txt, 20030220/21
# |
# | Revision 1.7  2003/02/20 15:07:13  wig
# | Fixed: port signal assignment direction bus
# | Capitalization (folding is still missing)
# | Added ::arch column and created output
# |
# | Revision 1.6  2003/02/19 16:28:00  wig
# | Added generics.
# | Renamed generated objects
# |
# | Revision 1.5  2003/02/12 15:40:47  wig
# | Improved handling of bus splicing (but still a way to go)
# | Added seom meta instances.
# |
# | Revision 1.4  2003/02/07 13:18:44  wig
# | no changes
# |
# | Revision 1.3  2003/02/06 15:48:30  wig
# | added constant handling
# | rewrote bit splice handling
# |
# | Revision 1.2  2003/02/04 07:19:24  wig
# | Fixed header of modules
# |
# |
# |
# +-----------------------------------------------------------------------+
package  Micronas::MixUtils;
require Exporter;

# %EXPORT_TAGS = tag => [...];  

# @Micronas::MixUtils::ISA=qw(Exporter);
@ISA=qw(Exporter);

# @Micronas::MixUtils::EXPORT=qw(
@EXPORT  = qw(
        mix_getopt_header
        mix_usage
        mix_getops
        mix_banner
        mix_help
	mix_init
	mix_store
	mix_load
	mix_utils_open
	mix_utils_print
	mix_utils_printf
	mix_utils_close
	mix_list_econf
	is_absolute_path
	replace_mac
	db2array
	write_sum
	convert_in
	select_variant
	two2one
	one2two
        );
# @Micronas::MixUtils::EXPORT_OK=qw(
@EXPORT_OK = qw(
		%OPTVAL
                %EH
	     );

our $VERSION = '0.01';

use strict;

# Caveat: relies on proper setting of base, pgmpath and dir in main program!
use lib "$main::base/";
use lib "$main::base/lib/perl";
use lib "$main::pgmpath/";
use lib "$main::pgmpath/lib/perl";
use lib "$main::dir/lib/perl";
use lib "$main::dir/../lib/perl";
#TODO: Which "use lib path" if $0 was found in PATH?

use File::Basename;
use File::Copy;
use IO::File;
use Getopt::Long qw(GetOptions);

use Cwd;
use Log::Agent;
use Log::Agent::Priorities qw(:LEVELS);

use Storable;
# use Micronas::MixParser qw( mix_parser_importhdl );

# use Data::Dumper; # Will be evaled if -adump option is on
# use Text::Diff;  # Will be eval'ed down there if -delta option is given!
# use Win32::OLE; # etc.# Will be eval'd down there if excel comes into play

#
# Prototypes
#
sub select_variant ($);
sub mix_list_conf ();
sub mix_list_econf ($);
sub _mix_list_conf ($$;$);
sub _mix_apply_conf ($$$);
sub mix_store ($$;$);
sub mix_utils_open($;$);
sub mix_utils_print($@);
sub mix_utils_printf($@);
sub mix_utils_close($$);
sub replace_mac ($$);
sub one2two ($);
sub two2one ($);
sub is_absolute_path ($);
sub mix_utils_split_cell ($);

##############################################################
# Global variables
##############################################################

use vars qw(
    %OPTVAL %EH %MACVAL
);

####################################################################
#
# Our local variables

#
# RCS Id, to be put into output templates
#
my $thisid		=	'$Id: MixUtils.pm,v 1.41 2003/12/22 08:33:11 wig Exp $';
my $thisrcsfile	        =	'$RCSfile: MixUtils.pm,v $';
my $thisrevision        =      '$Revision: 1.41 $';

# Revision:   $Revision: 1.41 $   
$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?

##############################################################
# Basic functions used in MIX ....
##############################################################

#
# mix_getopt_header
#
# Option processing (command line switches)
#

sub mix_getopt_header(@) {
    my $no_exit  = @_ && ($_[0] eq '-NO_EXIT') && shift;
    my @appopts  = @_;          # Application options

    # Get the options and macros
    unless (mix_getopt(@appopts)) {
        mix_usage();
        exit 1;
    }

    #
    # CONF options set -> overload built-in configuration (needs to be first!!!!)
    #
    if ($OPTVAL{'conf'}) {
	mix_overload_conf( $OPTVAL{'conf'} );
    }

    # Evaluate options
    if ($OPTVAL{'quiet'}) {
        $EH{'NOTE'} = $EH{'quiet'}; # be quiet, suppress printing notes.
        $EH{'PRINTTIMING'} = 0;
    }
    if ($OPTVAL{'verbose'}) {
        $EH{'VERBOSE'} = $EH{'verbose'}; # be verbose, printing notes.
    }
    if (defined $OPTVAL{'debug'}) {
        $EH{'DEBUG'} = $EH{'debug'}; # printing debug notes.
        eval 'package main; use diagnostics;'; # enable perl diagnostics
    }

    #
    # Change output pathes for internal, intermediate and backend data
    # Create it if needed.
    #
    if ( defined $OPTVAL{'dir'} ) {
	unless( -d $OPTVAL{'dir'} ) {
	    unless( mkdir( $OPTVAL{'dir'} ) ) {
		logwarn( "ERROR: Cannot create output directory " . $OPTVAL{'dir'} . "!" );
		exit 1;
	    }
	    logwarn( "INFO: Created output directory " . $OPTVAL{'dir'} . "!" );
	}
	$EH{'output'}{'path'} = $OPTVAL{'dir'};
	$EH{'intermediate'}{'path'} = $OPTVAL{'dir'};
	$EH{'internal'}{'path'} = $OPTVAL{'dir'};
    }
    
    # if (defined $MACVAL{'M_IGNORE_ERRORS'}) {
    #     $EH{'ERROR'} = $EH{'error_no_exit'}; # hidden emergency switch
    # }
    if (defined $OPTVAL{'out'}) {
	$EH{'out'} = $OPTVAL{'out'};
    } elsif ( exists( $ARGV[$#ARGV] ) )  {
	# Output file will be written to current directory.
	# Name will become name of last input file foo-mixed.ext
	$EH{'out'} = $ARGV[$#ARGV] ;
	$EH{'out'} =~ s,(\.[^.]+)$,-$EH{'output'}{'ext'}{'intermediate'}$1,;
	# if ( $EH{'output'}{'path'} eq "." ) {
	    $EH{'out'} = basename( $EH{'out'} ); # Strip off pathname
	# }
    } else {
	$EH{'out'} = "";
    }

    # Internal and intermediate data are written to:
    if (defined $OPTVAL{'int'}) {
	$EH{'dump'} = $OPTVAL{'int'};
    } elsif ( exists( $ARGV[$#ARGV] ) )  {
	# Output file will be written to current directory.
	# Name will become name of last input file foo-mixed.ext
	$EH{'dump'} = $ARGV[$#ARGV];
	$EH{'dump'} =~ s,\.([^.]+)$,,; # Strip away extension
	$EH{'dump'} .= "." . $EH{'output'}{'ext'}{'internal'};
	# if ( $EH{'internal'}{'path'} eq "." ) {
	$EH{'dump'} = basename( $EH{'dump'} ); # Strip off pathname
	# }
    } else {
	$EH{'dump'} = "mix" . "." . $EH{'output'}{'ext'}{'internal'};
    }
	# Is there a *-mixed file in the current directory ?
	#TODO:
	# $EH{'dump'} = "NO_DUMP_FILE_DEFINED";
        # }

    # Specify top cell on command line or use TESTBENCH as default
    if (defined $OPTVAL{'top'} ) {
	$EH{'top'} = $OPTVAL{'top'};
    } else {
	$EH{'top'} = 'TESTBENCH'; #TODO: put into %EH
    }

    # Specify variant to be selected in hierachy sheet(s)
    # Default or empty cell will be selected always.
    if (defined $OPTVAL{'variant'} ) {
	$EH{'variant'} = $OPTVAL{'variant'};
    } # else {
	# $EH{'variant'} = 'Default';
    # }

    # remove old and diff sheets when set
    if (defined $OPTVAL{'strip'}) {
        $EH{'intermediate'}{'strip'} = $OPTVAL{'strip'};
    } 

    # Write entities into file
    if (defined $OPTVAL{'outenty'} ) {
	$EH{'outenty'} = $OPTVAL{'outenty'};
    } elsif ( defined( $EH{'outenty'} ) ) {
	# outenty defined by -conf or config file, do not change
    } elsif ( exists( $ARGV[$#ARGV] ) )  {
	# Output file will be written to current directory.
	# Name will become name of last input file foo-e.vhd
	$EH{'outenty'} = $ARGV[$#ARGV];
	$EH{'outenty'} =~ s,(\.[^.]+)$,,; # Remove extension
	$EH{'outenty'} .= $EH{'postfix'}{'POSTFILE_ENTY'} . "." . $EH{'output'}{'ext'}{'vhdl'};
	# if ( $EH{'output'}{'path'} eq "." ) {
	$EH{'outenty'} = basename( $EH{'outenty'} ); # Strip off pathname
	# }
    } else {
	$EH{'outenty'} = "mix" . $EH{'postfix'}{'POSTFILE_ENTY'} . "." . $EH{'output'}{'ext'}{'vhdl'};
    }

    # Write architecture into file
    if (defined $OPTVAL{'outarch'} ) {
	$EH{'outarch'} = $OPTVAL{'outarch'};
    } elsif ( defined( $EH{'outarch'} ) ) {
	# outarch defined by -conf or config file, do not change
    } elsif ( exists( $ARGV[$#ARGV] ) )  {
	# Output file will be written to current directory.
	# Name will become name of last input file foo-a.vhd
	$EH{'outarch'} = $ARGV[$#ARGV] ;
	$EH{'outarch'} =~ s,(\.[^.]+)$,,;
	$EH{'outarch'} .= $EH{'postfix'}{'POSTFILE_ARCH'} . "." . $EH{'output'}{'ext'}{'vhdl'};
	# if ( $EH{'output'}{'path'} eq "." ) {
	$EH{'outarch'} = basename( $EH{'outarch'} ); # Strip off pathname
	# }
    } else {
	$EH{'outarch'} = "mix" . $EH{'postfix'}{'POSTFILE_ARCH'} . "." . $EH{'output'}{'ext'}{'vhdl'};
    }

   # Write configuration into file
    if (defined $OPTVAL{'outconf'} ) {
	$EH{'outconf'} = $OPTVAL{'outconf'};
    } elsif ( defined( $EH{'outconf'} ) ) {
	# outconf defined by -conf or config file, do not change
    } elsif ( exists( $ARGV[$#ARGV] ) )  {
	# Output file will be written to current directory.
	# Name will become name of last input file foo-c.vhd
	$EH{'outconf'} = $ARGV[$#ARGV] ;
	$EH{'outconf'} =~ s,(\.[^.]+)$,,;
	$EH{'outconf'} .= $EH{'postfix'}{'POSTFILE_CONF'} . "." . $EH{'output'}{'ext'}{'vhdl'};
	# if ( $EH{'output'}{'path'} eq "." ) {
	$EH{'outconf'} = basename( $EH{'outconf'} ); # Strip off pathname
	# }
    } else {
	$EH{'outconf'} = "mix" . $EH{'postfix'}{'POSTFILE_CONF'} . "." . $EH{'output'}{'ext'}{'vhdl'};
    }

    #
    # -combine option -> overwrite outarch/outenty/outconf ...
    #
    if ( defined $OPTVAL{'combine'} ) {
	$EH{'output'}{'generate'}{'combine'} = $OPTVAL{'combine'};
    }
    if ( $EH{'output'}{'generate'}{'combine'} ) { # Overload outxxx if combine is active
	$EH{'outenty'} = $EH{'outarch'} = $EH{'outconf'} = 'COMB';
    }

    #
    # SHEET selector -> overload built-in configuration
    #
    if ($OPTVAL{'sheet'}) {
	mix_overload_sheet( $OPTVAL{'sheet'} );
    }


    #
    # -listconf
    # Dump %EH ... and stop
    #
    if ( $OPTVAL{'listconf'} ) {
	mix_list_conf();
    }

    #
    # -delta
    # Enable delta mode (generate a diff instead of a full version)
    # Delta mode can be enabled by -delta switch of by configuration variable
    # like -conf output.generate.delta=1 or enabled in mix.cfg file
    #
    if ( exists( $OPTVAL{delta} ) ) { # -delta |-nodelta
	if ( $OPTVAL{delta} ) {
	# Eval use Text::Diff
	    if ( eval "use Text::Diff;" ) {
		logwarn( "ERROR: Cannot load Text::Diff module for -delta mode: $@" );
		exit(1);
	    }
	    $EH{'output'}{'generate'}{'delta'} = 1;
	} else { # Switch off delta mode
	    $EH{'output'}{'generate'}{'delta'} = 0;
	}
    } else {
	if ( $EH{'output'}{'generate'}{'delta'} ) { # Delta on by -conf or FILE.cfg
	# Eval use Text::Diff
	    if ( eval "use Text::Diff;" ) {
		logwarn( "ERROR: Cannot load Text::Diff module for -conf *delta* mode: $@" );
		exit(1);
	    }
	    $EH{'output'}{'generate'}{'delta'} = 1;
	    $OPTVAL{delta} = 1;
	} else {
	    $EH{'output'}{'generate'}{'delta'} = 0;
	}
    }

    #
    # -bak
    # Shift previously generated files to FILE.V.bak
    # Backup mode can be enabled by -bak switch of by configuration variable
    # like -conf output.generate.bak=1 or enabled in mix.cfg file
    #
    if ( exists( $OPTVAL{bak} ) ) { # -bak |-nobak
	if ( $OPTVAL{bak} ) {
	    $EH{'output'}{'generate'}{'bak'} = 1;
	} else { # Switch off backup mode
	    $EH{'output'}{'generate'}{'bak'} = 0;
	}
    } else {
	if ( $EH{'output'}{'generate'}{'bak'} ) { # Backup on by -conf or FILE.cfg
	    $EH{'output'}{'generate'}{'bak'} = 1;
	    $OPTVAL{bak} = 1;
	} else {
	    $EH{'output'}{'generate'}{'bak'} = 0;
	}
    }

=head DEL

    #
    # Create a starting point ...
    #
    if ( $OPTVAL{init} ) {
	mix_utils_init_file("init");
    }
    #
    # Import some HDL files
    #
    if ( $OPTVAL{import} ) {
	mix_utils_init_file("import");
    }

=cut

    # Print banner
    if ($OPTVAL{help}) {
        if (defined($OPTVAL{verbose})) {
            mix_banner();
        }
        mix_help();
         if (! $no_exit) {
             exit(0);
         }
    } elsif (! defined($OPTVAL{quiet}) and ! defined($OPTVAL{nobanner})) {
        mix_banner();
    }

    #
    # Create a starting point ...
    #
    if ( $OPTVAL{init} ) {
	mix_utils_init_file("init");
    }
    #
    # Import some HDL files
    #
    if ( $OPTVAL{import} ) {
	mix_utils_init_file("import");
    }

}

##############################################################################
# Option parsing
##############################################################################

=head2 mix_getopt(@opts)

Parse the command line for option (-option value) and make macro settings
(NAME=VALUE).
All options found are stored in the hash %OPTVAL by default.
All makros found are stored in the global hash %MACVAL.
All other command line words remain in @ARGV.

See above for more details. This function does not print the standard
header nor does it influence the msghandle() behaviour.

=cut

sub mix_getopt(@)
{
    # Application options
    my @appopts = @_;
    # Standard options
    my @stdopts = qw(help|h! verbose|v! quiet|q! nobanner!  debug:i  makeopts=s@ gmakeopts=s@);
    my $status;
    my @ret = ();

    # Get the options
    Getopt::Long::Configure('noignore_case');
    $status = GetOptions( \%OPTVAL, @stdopts, @appopts);

    # Get the make makros
    while (@ARGV > 0) {
        my $arg = shift(@ARGV);
        if ($arg =~ /^(\w+)=(.*)?/) {
            $MACVAL{$1} = $2;
        } else {
            push(@ret, $arg);
        }
    }

    # The remaining arguments
    unshift (@ARGV, @ret) if @ret > 0;
    #  quiet and verbose are exclusive
    $OPTVAL{'verbose'} = 0 if $OPTVAL{'quiet'};

    return($status);
}

=head2 mix_usage()

Print the SYNOPSIS section of the script's POD documentation. #'

=cut

sub mix_usage(@)
{
    my $start  = 0;
    my $usage  = 'Usage: ';
    my $indent = '';

    print (@_, "\n") if @_;

    #$ENV{PATH} = dirname($^X) . ":$ENV{PATH}";
    $ENV{PATH} = dirname(dirname(dirname($^X))) . "/bin:$ENV{PATH}";
    #TODO: MSWin32 -> we do not have nroff here :-(
    if ( $^O =~ m,mswin,io ) {
	open(PIPE, "pod2text --lax $0 |") || die "can't open pipe: $!";
    } else {
	open(PIPE, "pod2man --lax $0 | nroff -man |") || die "can't open pipe: $!";
    }
    while (<PIPE>) {
        # Process backspaces
        while (s/[^\b][\b]//g) {
        }
        if (/^\s*$/) {
            # Skip empty lines
            next;
        } elsif (/^SYNOPSIS/) {
            $start = 1;
        } elsif (/^\w/) {
            $start = 0;
        } elsif ($start == 1) {
            ($indent) = /^(\s*)/;
            s/^$indent/$usage/;
            $usage =~ s/./ /g;
            $start = 2;
            print STDERR $_;
        } elsif ($start == 2) {
            s/^$indent/$usage/;
            print STDERR $_;
        }
    }
    close PIPE;
    $EH{'PRINTTIMING'} = 0;
    1;
}

##############################################################################
# Banner handler
#
# suppress print of timing if a true argument is given
##############################################################################

=head2 mix_banner($timing)

Print the standard Mix script header. The scripts must contain the
following line in the top 100 lines in order to get the version id:

  $::VERSION = "...";

If I<$timing> is true, information about script start and end time will
be printed.

Note: This is automatically called from
L<mix_getopt_header(@opts)|"mix_getopt_header(@opts)">.

=cut

sub mix_banner(;$)
{
    if ($_[0] || !defined $EH{'PRINTTIMING'} ) {
        $EH{'PRINTTIMING'} = 1;
    }

    my $NAME = basename($0);
    my $VERSION = $::VERSION || 'undef';

    my $flow = 'MIX';
    my $FLOW = 'MIX';
    my $FLOW_VERSION = $ENV{"${flow}_VERSION"} || '';
    if ($FLOW_VERSION eq 'development' && $ENV{"${flow}_DEV_VERSION"}) {
        $FLOW_VERSION = $ENV{"${flow}_DEV_VERSION"} . " ($FLOW_VERSION)";
    }
    $FLOW_VERSION = "Release $FLOW_VERSION" if $FLOW_VERSION;
    $FLOW_VERSION = "Release $FLOW_VERSION" if $FLOW_VERSION;

    #!wig20030724: add versions of included modules:
    # NON portable !!!
    my $MOD_VERSION = "";
    $MOD_VERSION .= ( "\n#####   MixUtils    " . $Micronas::MixUtils::VERSION )
	if ( defined( $Micronas::MixUtils::VERSION ) );
    $MOD_VERSION .= ( "\n#####   MixUtils::IO    " . $Micronas::MixUtils::IO::VERSION )
	if ( defined( $Micronas::MixUtils::IO::VERSION ) );
    $MOD_VERSION .= ( "\n#####   MixParser   " . $Micronas::MixParser::VERSION )
	if ( defined( $Micronas::MixParser::VERSION ) );
    $MOD_VERSION .= ( "\n#####   MixWriter   " . $Micronas::MixWriter::VERSION )
	if ( defined( $Micronas::MixWriter::VERSION ) );
    $MOD_VERSION .= ( "\n#####   MixChecker  " . $Micronas::MixChecker::VERSION )
	if ( defined( $Micronas::MixChecker::VERSION ) );
    $MOD_VERSION .= ( "\n#####   MixIOParser " . $Micronas::MixIOParser::VERSION )
	if ( defined( $Micronas::MixIOParser::VERSION ) );

    select(STDOUT);
    $| = 1;                     # unbuffer STDOUT

    print <<"EOF";
#######################################################################
##### $NAME ($VERSION)
#####
##### $FLOW $FLOW_VERSION $MOD_VERSION
#######################################################################
EOF
##### Copyright(c) Micronas GmbH 2002 ALL RIGHTS RESERVED
    if ($EH{'PRINTTIMING}'} ) {
        print "NOTE ($NAME): Execution started " . localtime() . "\n\n";
    }
    1;
}

##############################################################################
# Help handler
##############################################################################

=head2 mix_help()

Print the script\'s entire POD documentation.

=cut

sub mix_help()
{
    my $head = "MIX Reference Manual";
    my $foot = "MIX Release ".($ENV{MWAY_VERSION} || "");

    #$ENV{PATH} = dirname($^X) . ":$ENV{PATH}";
    $ENV{PATH} = dirname(dirname(dirname($^X))) . "/bin:$ENV{PATH}";
    #TODO: Win32 ??
    my $cmd = "";
    if ( $^O =~ m,mswin,io ) {
	# $cmd = "pod2text --center '$head' --release '$foot' --lax $0 |";
	$cmd = "pod2text $0";
    } else {
	$cmd = "pod2man --center '$head' --release '$foot' --lax $0 | nroff -man";
    }
    my $help = `$cmd`;

    logtrc($EH{'ERROR'}, "'$cmd' failed.") if $?;

    # Save one head and foot line
    my ($headline) = $help =~ /([^\n]*$head[^\n]*\n)/ || "";
    my ($footline) = $help =~ /([^\n]*$foot[^\n]*\n)/ || "";

    # Skip head and foot lines
    $help =~ s/^.*($head|$foot)[^\n]*\n//mg;

    # Add exacly one head and foot line
    $help = "$headline$help$footline";

    # Skip multiple empty lines
    $help =~ s/(^\s*\n)+/\n/mg;

    if ( ! -t STDOUT ) {
        # Not a tty
        print $help;
    } elsif ($ENV{TERM} && $ENV{TERM} =~ /dumb|emacs/) {
        # Dumb Emacs shell-mode buffer
        # Use no control characters and no pager
        # Process backspaces
        while ($help =~ s/[^\b][\b]//g) {
        }
        ;
        print $help;
    } else {
        # Select pager similiar to perldoc
        my @pagers = ();
        push @pagers, $ENV{PERLDOC_PAGER} if $ENV{PERLDOC_PAGER};
        push @pagers, $ENV{PAGER} if $ENV{PAGER};
        push @pagers, "/usr/local/bin/less" if -x "/usr/local/bin/less";
        push @pagers, qw(less more pg view cat);
        if ( $^O =~ m,^mswin,io ) {
	    @pagers = qw(more);
	};
        foreach my $pager (@pagers) {
            open (PAGER, "| $pager") or next;
            print PAGER $help;
            close(PAGER) or next;
            return 1;
        }
        print $help;
    }
    1;
}

# Perform the action

##############################################################################
# Initialize environment, variables, configurations ...
#
##############################################################################
#!wig20031217: if intermediate is xls and we are on Win32, change %IOCR% to \n (is " " by default)
#
=head2 mix_init()

Initialize the %EH variable with all the configuration we have/need

  %EH = ( ..... );

No input arguments (today).

=cut

sub mix_init () {

%EH = (
    'template' => {
	'vhdl' =>{
	    # Actual values are set in MixWriter
	    'conf' => { 'head' => "## VHDL Configuration Template String t.b.d.", },
	    'arch' => { 'head' => "## VHDL Architecture Template String t.b.d.", },
	    'enty' => { 'head' => "## VHDL Entity Template String t.b.d.", },
	},
	'verilog' =>{
	    'conf' => { 'head' => "## Verilog Configuration Template String t.b.d.", },
	    'arch' => { 'head' => "## Verilog Architecture Template String t.b.d.", },
	    'enty' => { 'head' => "## Verilog Entity Template String t.b.d.", },
	    'wrap' => "## Verilog Wrapper Template String t.b.d.",
	    'file' => "##Verilog File Template String t.b.d.",
	},
    },
    'output' => {
	'path' => ".",		# Path to store backend data. Other values are a path, CWD or INPUT
	'order' => 'input',		# Field order := as in input or predefined
	'format' => 'ext',		# Output format derived from filename extension ???
	'filename' => 'useminus', # Convert _ to - in filenames
	'generate' =>
	    { 'arch' => 'noleaf',
	      'enty' => 'noleaf', # no leaf cells: [no]leaf,alt,
	      'conf' => 'noleaf', # one of: [leaf|noleaf],verilog no leaf cells, defaults
				      # is "noleaf". The verilog keyword will add configuration
				      #   records for verilog subblocks (who wants that?)
	      'use' => 'enty',     # apply ::use libraries to entity files, if not specified otherwise
					# values: <enty|conf|arch|all>
	      'inout' => 'mode,noxfix',	# Generate IO ports for %TOP% cell (or daughter of testbench)
					# controlled by ::mode I|O
					# noxfix: do not attach pre/postfix to signal names at %TOP%
              'xinout'  => '',       # list of comma seperated signals to exclude from automatic wiring to %TOP%
              '_re_xinout' => '',   # keeps converted content of xinout ...
	      # 'port' => 'markgenerated',	# attach a _gIO to generated ports ...
	      'delta' => 0,	    	# allows to use mix.cfg to preset delta mode
	      'bak' => 0,		# Create backup of output HDL files
	      'combine' => 0,	# Combine enty,arch and conf into one file, -combine switch
	      'portdescr' => '%::descr%',	# Definitions for port map descriptions:
		      #   %::descr% (contents of thsi signal's descr. field, %::ininst% (list of load instances),
		      #   %::outinst% (list of driving instances), %::comment%
	      'portdescrlength' => 100, # Limit length of comment to 100 characters!
	      'fold' => 'signal',	# If set to [signal|hier], tries to collect ::comments, ::descr and ::gen
					# like TEXT_FOO_BAR (X10), if TEXT_FOO_BAR appears several times
					#TODO: Implement for hier
	      'workaround' => {
		  'verilog' => 'dummyopen', # dummyopen := create a dummy signal for open port splices 
		},
	  },
	'ext' =>      {   'vhdl' => 'vhd',
			  'verilog' => 'v' ,
			  'intermediate' => 'mixed', # not a real extension!
			  'internal' => 'pld',
			  'delta' => '.diff',	# delta mode
	},
	'comment' => {	'vhdl' => '--',
			'verilog' => '//',
			'intermediate' => '#',
			'internal' => '#',
			'delta' => '#',
			'default' => '#',
	},
	# 'warnings' => 'load,drivers',	# Warn about missing loads/drivers
	'warnings' => '',
	'delta' => 'sort', # Controlling delta output mode:
				    # space: not consider whitespace
				    # sort:   sort lines
				    # comment: not remove all comments before compare
				    # remove: remove empyt diff files
    },
    'input' => {
	'ext' =>	{
	    'excel' =>	"xls",
	    'soffice' => "sxc",
	    'csv'   =>	"csv",
	},
    },
    'internal' => {
	'path' => ".",
	'order' => 'input',		# Field order := as in input or predefined
	'format' => "perl", 	# Internal intermediate format := perl|xls|csv|xml ...
    },
    'intermediate' => {
	'path' => ".",
	'order' => 'input',
	'keep' => '3',	# Number of old sheets to keep
	'format' => 'prev', # One of: prev(ious), auto or n(o|ew)
	# If set, previous uses old sheet format, auto applies auto-format and the others do nothing.
	'strip' => '0',   # remove old and diff sheets
	'ext' => '', # default intermediate-output extension
    },
    'check' => { # Checks enable/disable: Usually the keywords to use are
		    # na (or empty), check (check and warn),
		    # force (check and force compliance),
		    # Available (built-in) rules are:
		    # lc (lower case everything), postfix, prefix,
		    # t.b.d.: uniq (make sure name apears only once!
		    #
	'name' => {
	    #TODO: 'all' => '',	# Sets all others .... ->
	    'pad' => 'check,lc',
	    'conn' => 'check,lc', # check signal names ...
	    'enty' => 'check,lc',
	    'inst' => 'check,lc',   # check instance names ...
	    'port' => 'check,lc',
	    'conf' => 'check,lc',
	},
	'keywords' => { #These keywords will trigger warnings and get replaced
	    'vhdl'	=> '(open|instance|entity|signal)', #TODO: Give me more keywords
	    'verilog' 	=> '(register|net|wire|in|out|inout)', #TODO: give me more
	},
	'defs' => '',  # 'inst,conn',    # make sure elements are only defined once:
		    # possilbe values are: inst,conn
	'signal' => 'load,driver,check,top_open',
						# reads: checks if all signals have appr. loads
						# and drivers.
						# If "top_open" is in this list, will wire unused
						# signals to open.
	'inst' => 'nomulti',	# check and mark multiple instantiations
    },
    # Autmatically try conversion to TYPE from TYPE by using function ...
    'typecast' => { # add typecast functions ...
	'std_ulogic_vector' => {
	    'std_logic_vector' => "std_ulogic_vector( %signal% );" ,
	},
	'std_logic_vector' => {
	    'std_ulogic_vector' => "std_logic_vector( %signal% );" ,
	},
	'std_ulogic' => {
	    'std_logic' => 'std_ulogic( %signal% );',
	},
	'std_logic' => {
	    'std_ulogic' => 'std_logic( %signal% );',
	},
    },
    'postfix' => {
	    qw(
		    POSTFIX_PORT_OUT	_o
		    POSTFIX_PORT_IN	_i
		    POSTFIX_PORT_IO	_io
		    PREFIX_PORT_GEN	p_mix_
		    POSTFIX_PORT_GEN	_g%IO%
		    PREFIX_PAD_GEN	pad_
		    POSTFIX_PAD_GEN	%EMPTY%
		    PREFIX_IOC_GEN	ioc_
		    POSTFIX_IOC_GEN	%EMPTY%
		    PREFIX_SIG_INT	s_int_
		    POSTFIX_SIGNAL	_s
		    PREFIX_INSTANCE	i_
		    POSTFIX_INSTANCE	%EMPTY%
		    POSTFIX_ARCH	%EMPTY%
		    POSTFILE_ARCH	-a
		    POSTFIX_ENTY	%EMPTY%
		    POSTFILE_ENTY	-e
		    POSTFIX_CONF	%EMPTY%
		    POSTFILE_CONF	-c
		    PREFIX_CONST	mix_const_
		    PREFIX_GENERIC	mix_generic_
		    POSTFIX_GENERIC	_g
		    PREFIX_PARAMETER	mix_parameter_
		    PREFIX_KEYWORD	mix_key_
		    POSTFIX_CONSTANT	_c
		    POSTFIX_PARAMETER	_p
		)
    },
    'pad' => {
	'name' => '%PREFIX_PAD_GEN%%::pad%',  # generated pad with prefix and ::pad
		    # '%PREFIX_PAD_GEN%%::name%',  # generated pad with prefix and ::name
		    # '%PREFIX_PAD_GEN%_%::pad%'
	qw(
	    PAD_DEFAULT_DO	0
	    PAD_ACTIVE_EN	 	1
	    PAD_ACTIVE_PU	 	1
	    PAD_ACTIVE_PD	 	1
	)
    },
    'port' => {
	'generate' => {   # Options related to generated port names. Please see also inout value
	    'name' => 'postfix', # Take the postfix definitions: p_mix_SIGNAL_g[io], see descr. there
				  # signal := take the signal name, not post/prefix!
	    'width' => 'auto',    # auto := find out number of required connections and generate that
				  # full := always generate a port for the full signal width
	},
    },
    'iocell' => {
	'name' => '%::iocell%_%::pad%',  # generated pad name with prefix and ::pad
		    # '%PREFIX_IOC_GEN%%::name%',  # generated pad name with prefix and ::name
		    # '%PREFIX_IOC_GEN%_%::pad%'
	'auto' => 'bus', 	# Generate busses if required autimatically ...
	'bus' => '_vector', # auto -> extend signals by _vector if required ....
	'defaultdir'	=> 'in', 	# Default signal direction to iocell (seen towards chip core!!)
	'in'	=> 'do,en,pu,pd,xout',	# List of inwards signals (towards chip core!!)
	'inout' => '__NOINOUT__',	# List of inout ports ...
	'out'	=> 'di,xin',		# List of outwards ports (towards chip core!!)
					# di is a chip input, driven by the iocell towards the core.
	'select' => 'onehot,auto', # Define select lines: onehot vs. bus vs. given
					# 
					# bus -> use signal in ::muxopt:0 column (first)
					# given  -> use signals as defined by the %SEL% lines,
					#     but calculate width 2^N ... -> 3 signals give a mux width of
					#  8 ... (alternativ take width argument from signal name
					# minimum -> wire bits only if used (minimal bus) t.b.d.
					# auto := choose width accordingly to wired io busses
					# const := use %SEL% defined width

    },
    #
    # Possibly read configuration details from the CONF sheet, see -conf option
    #
    'conf' => {
	'xls' => 'CONF',
	'req' => 'optional',
	'parsed' => 0,
	'field' => {},
    },

    #
    # Definitions regarding the CONN sheets:
    #
    'conn' => {
	'xls' => 'CONN',
	'req' => 'mandatory',
	'parsed' => 0,
	'key' => '::name', # Primary key to %conndb
	'field' => {
	    #Name   	=>		Inherits
	    #						Multiple
	    #							Required: 0 = no, 1=yes, 2= init to ""
	    #								Defaultvalue
	    #									PresetOrder
	    #                                   0       1       2	3               4
	    '::ign' 		=> [ qw(	0	0	1	%EMPTY% 	1 ) ],
	    '::gen'		=> [ qw(	0	0	1	%EMPTY% 	2 ) ],
	    '::bundle'	        => [ qw(	1	0	1	WARNING_NOT_SET	3 ) ],
	    '::class'		=> [ qw(	1	0	1	WARNING_NOT_SET	4 ) ],
	    '::clock'		=> [ qw(	1	0	1	WARNING_NOT_SET	5 ) ],
	    '::type'		=> [ qw(	1	0	1	%SIGNAL%	6 ) ],
	    '::high'		=> [ qw(	1	0	0	%EMPTY% 	7 ) ],
	    '::low'		=> [ qw(	1	0	0	%EMPTY% 	8 )],
	    '::mode'		=> [ qw(	1	0	1	%DEFAULT_MODE%	9 )],
	    '::name'		=> [ qw(	0	0	1	ERROR_NO_NAME	10 )],
	    '::shortname'	=> [ qw(	0	0	0	%EMPTY% 	11 )],
	    '::out'		=> [ qw(	1	0	0	%SPACE% 	12 )],
	    '::in'		=> [ qw(	1	0	0	%SPACE% 	13 )],
	    '::descr'		=> [ qw(	1	0	0	%EMPTY% 	14 )],
	    '::comment'	        => [ qw(	1	1	2	%EMPTY% 	15 )],
	    '::default'	        => [ qw(	1	1	0	%EMPTY% 	0 )],
	    "::debug"	        => [ qw(	1	0	0	%NULL%	        0 )],
	    '::skip'		=> [ qw(	0	1	0	%NULL% 	        0 )],
	    'nr'		=> 16, # Number of next field to print
	},
    },

    #
    #	 hierachy sheet basic definition
    #
    'hier' => {
        'xls' => 'HIER',
	'req' => 'mandatory',
	'parsed' => 0,
	'key' => '::inst', # Primary key to %hierdb
	'field' => {
	    #Name   	=>		Inherits
	    #						Multiple
	    #							Required
	    #								Defaultvalue
	    #									PrintOrder
	    #                                   0       1       2   	   3            4
	    '::ign' 		=> [ qw(	0	0	1	%EMPTY% 	1 )],
	    '::gen'		=> [ qw(	0	0	1	%EMPTY% 	2 )],
	    '::variants'	=> [ qw(	1	0	0	Default	        3 )],
	    '::parent'	        => [ qw(	1	0	1	W_NO_PARENT	4 )],
	    '::inst'		=> [ qw(	0	0	1	W_NO_INST	5 )],
	    '::lang'		=> [ qw(	1	0	0	%LANGUAGE%	7 )],
	    '::entity'		=> [ qw(	1	0	1	W_NO_ENTITY	8 )],
	    '::arch'		=> [ qw(	1	0	0	rtl		9 )],
	    "::config"	        => [ qw(	1	0	1	%DEFAULT_CONFIG% 11 )],
	    '::use'		=> [ qw(	1	0	0	%EMPTY%		10 )],
	    "::comment"	        => [ qw(	1	0	2	%EMPTY%	        12 )],
	    "::descr"	        => [ qw(	1	0	0	%EMPTY%	        13 )],
	    "::shortname"	=> [ qw(	0	0	0	%EMPTY%	        6 )],
	    "::default"	        => [ qw(	1	1	0	%EMPTY%	        0 )],
	    "::hierachy"	=> [ qw(	1	0	0	%EMPTY%	        0 )],
	    "::debug"	        => [ qw(	1	0	0	%NULL%	        0 )],
	    '::skip'		=> [ qw(	0	1	0	%NULL% 	        0 )],
	    'nr'		=> 14,  # Number of next field to print
	},
    },
    'variant' => 'Default', # Select default as default variant :-)

    #
    # IO sheet basic definitions
    # PAD is he primary key (but pad names might be added on demand)
    #
    #
    'io' => {
        'xls' => 'IO',
	'req' => 'optional',
	'parsed' => 0,
	'field' => {
	    #Name   	=>		    Inherits
	    #					    Multiple
	    #						    Required
	    #							   Defaultvalue
	    #								    PrintOrder
	    #                                   0       1       2	3       4
	    '::ign' 		=> [ qw(	0	0	1	%EMPTY% 	1 )],
	    '::class'		=> [ qw(	1	0	1	WARNING_NOT_SET	2 )],
	    '::ispin'		=> [ qw(	0	0	1	%EMPTY%	        3 )],
	    '::pin'		=> [ qw(	0	0	1	WARNING_PIN_NR	4 )],
	    '::pad'		=> [ qw(	0	0	1	WARNING_PAD_NR	5 )],
	    '::type'		=> [ qw(	1	0	1	DEFAULT_PIN	6 )],
	    '::iocell'		=> [ qw(	1	0	1	DEFAULT_IO	7 )],
	    '::port'		=> [ qw(	1	0	1	%EMPTY%	        8 )],
	    '::name'		=> [ qw(	0	0	1	PAD_NAME	9 )],
	    '::muxopt'	=> [ qw(	1	1	1	%EMPTY%	        10 )],
	    "::comment"	=> [ qw(	1	0	2	%EMPTY%	        11 )],
            "::default"	=> [ qw(	1	1	0	%EMPTY%	0 )],	    
	    '::debug'	=> [ qw(	1	0	0	%NULL%	        0 )],
	    '::skip'		=> [ qw(	0	1	0	%NULL% 	        0 )],
	    'nr'		=> 12,  # Number of next field to print
	},
    },
    #
    # I2C sheet basic definitions
    #
    'i2c' => {
        'xls' => 'I2C',
	'req' => 'optional',
	'parsed' => 0,
	'field' => {
	    #Name   	=>	  	    Inherits
	    #					    Multiple
	    #						    Required
	    #							  Defaultvalue
	    #								    PrintOrder
	    #                                   0       1       2	3       4
	    '::ign' 		=> [ qw(	0	0	1	%EMPTY%     1 )],
	    '::variants'	=> [ qw(	1	0	0	Default	   2 )],
	    '::width'		=> [ qw(	0	0	1	16         3 )],
	    '::dev'             => [ qw(        0       0       1       %EMPTY%     4)],
	    '::sub'             => [ qw(        0       0       1       %EMPTY%     5)],
	    '::interface'       => [ qw(        0       0       1       %EMPTY%     6)],	  
	    '::block'           => [ qw(        0       0       1       %EMPTY%     7)],
	    '::dir'             => [ qw(        0       0       1       RW          8)],
	    '::spec'            => [ qw(        0       0       0       NTO         9)],
	    '::clock'           => [ qw(        0       0       1       %EMPTY%     10)],
	    '::reset'           => [ qw(        0       0       0       %EMPTY%     11)],
	    '::busy'            => [ qw(        0       0       0       %EMPTY%     12)],
	    # '::readDone'        => [ qw(        0       0       0       %EMPTY%     13)],
	    '::b'		=> [ qw(	0	1	1	%EMPTY%	    13 )],
	    '::init'            => [ qw(        0       0       0       0           14)],
	    '::rec'             => [ qw(        0       0       0       0           15)],
	    # '::range'	         => [ qw(	1	0	0	%EMPTY%	   17 )],
	    # '::name'		 => [ qw(	0	1	0	%EMPTY%	   18 )],
	    '::comment'	        => [ qw(	1	0	2	%EMPTY%	   16 )],
            "::default"	=> [ qw(	1	1	0	%EMPTY%	0 )],	    
	    '::debug'	=> [ qw(	1	0	0	%NULL%	        0 )],
	    '::skip'		=> [ qw(	0	1	0	%NULL% 	        0 )],            
	    'nr'		=> 17,  # Number of next field to print
	},
    },
    # VI2C Definitions:
    # ::ign	::type	::width	::dev	::sub	::addr
    # ::interface	::block	::inst	::dir	::auto	::sync
    # ::spec	::clock	::reset	::busy	::readDone	::new
    # ::b	::b	::b	::b	::b	::b	::b	::b	::b	::b	::b
    # ::b	::b	::b	::b	::b	::init	::rec	::range	::view
    # ::vi2c	::name	::comment
    #TODO: Define default fields:
    'vi2c' => {
        'xls' => 'VI2C',
	'req' => 'optional',
	'parsed' => 0,
	'field' => {
	    #Name   	=>	  	   Inherits
	    #					    Multiple
	    #						    Required
	    #							  Defaultvalue
	    #								    PrintOrder
	    #                                  0      1       2	3       4
	    '::ign' 		=> [ qw(	0	0	1	%NULL% 1 ) ],
	    '::type'		=> [ qw(	0	0	1	%TBD%  2 ) ],
	    '::variants'	=> [ qw(	1	0	0	Default	3 )],
	    '::inst'		=> [ qw(	0	0	1	W_NO_INST 4 )],
	    "::comment"	        => [ qw(	1	0	2	%EMPTY%	6 )],
	    "::shortname"	=> [ qw(	0	0	0	%EMPTY%	5 )],
	    "::b"		=> [ qw(	0	1	1	%NULL%	7 )],
	    "::default"	        => [ qw(	1	1	0	%NULL%	0 )],
	    "::hierachy"	=> [ qw(	1	0	0	%NULL%	0 )],
	    "::debug"	        => [ qw(	1	0	0	%NULL%	0 )],
            "::default"	=> [ qw(	1	1	0	%EMPTY%	0 )],	    
	    '::skip'		=> [ qw(	0	1	0	%NULL% 	0 )],
	    'nr'		=> 12,  # Number of next field to print
	},
    },
    "macro" => {
	    "%SPACE%" 	=> " ",
	    "%EMPTY%"	=> "",
	    "%NULL%"	=> "0",
	    "%TAB%"	=> "\t",
	    "%S%"	=> "\t", # Output field ident ....
	    "%IOCR%"	=> " ", # Will be set to \n if we are writting ExCEL on MSWin32 ...
	    "%SIGNAL%"	=> "std_ulogic",
	    "%BUS_TYPE%"	=> "std_ulogic_vector",
	    "%PAD_TYPE%"	=> "__E_DEFAULT_PAD__",	# Default pad entity
	    "%PAD_CLASS%"	=> "PAD",	# Default pad class
	    "%IOCELL_TYPE%"	=> "__E_DEFAULT_IOCELL__", # Default iocell entity
	    "%IOCELL_SELECT_PORT%"	=> "__I_default_select", 		# Default iocell port
	    "%NOSEL%"		=>  "__I_NOSEL__", #internal: no mux select
	    "%NOSELPORT%"	=>  "__I_NOSELPORT__", #internal: name of not used sel port
	    "%IOCELL_CLK%"	=>  "CLK", # Default clk for iocells, may be changed by %REG(clkb)
	    "%DEFAULT_MODE%"	=> "S",
	    "%LANGUAGE%"	=> lc("VHDL"), # Default language, could be verilog
	    "%DEFAULT_CONFIG%"	=>	"%::entity%_%::arch%_conf",
	    "%NO_CONFIG%"	=>	"NO_CONFIG", # Set this in ::conf if you want to not
									    # get configurations for this instance
	    "%NO_COMPONENT_DECLARATION%"	=>	"__NOCOMPDEC__",
	    "%NO_COMP%"	=>	"__NOCOMPDEC__", # If this keyword is found in ::use -> no component decl ..
	    "%NCD%"		=>	"__NOCOMPDEC__", # dito.
	    "%VHDL_USE_DEFAULT%"	=>
		"library IEEE;\nuse IEEE.std_logic_1164.all;\n",
		# "Library IEEE;\nUse IEEE.std_logic_1164.all;\nUse IEEE.std_logic_arith.all;",
	    "%VHDL_USE%"	=> "-- No project specific VHDL libraries", #Used internally
	    "%VHDL_NOPROJ%"	=> "-- No project specific VHDL libraries", # Overwrite this ...
	    "%VHDL_USE_ENTY%"	=>	"%VHDL_USE_DEFAULT%\n%VHDL_USE%",
	    "%VHDL_USE_ARCH%"	=>	"%VHDL_USE_DEFAULT%\n%VHDL_USE%",
	    "%VHDL_USE_CONF%"	=>	"%VHDL_USE_DEFAULT%\n%VHDL_USE%",
	    "%VERILOG_TIMESCALE%"	=>	"`timescale 1ns / 1ps",
	    "%VERILOG_USE_ARCH%"	=>	'%EMPTY%',
	    "%VERILOG_DEFINES%"	=>	'	// No `defines in this module', # Used internally
	    "%OPEN%"	=> "open",			#open signal
	    "%UNDEF%"	=> "ERROR_UNDEF",	#should be 'undef',  #For debugging??  
	    "%UNDEF_1%"	=> "ERROR_UNDEF_1",	#should be 'undef',  #For debugging??
	    "%UNDEF_2%"	=> "ERROR_UNDEF_2",	#should be 'undef',  #For debugging??
	    "%UNDEF_3%"	=> "ERROR_UNDEF_3",	#should be 'undef',  #For debugging??
	    "%UNDEF_4%"	=> "ERROR_UNDEF_4",	#should be 'undef',  #For debugging??
	    "%TBD%"	=> "__W_TO_BE_DEFINED",
	    "%HIGH%"	=> lc("MIX_LOGIC1"),  # VHDL does not like leading/trailing __
	    "%LOW%"	=> lc("MIX_LOGIC0"),  # dito.
	    "%HIGH_BUS%"	=> lc("MIX_LOGIC1_BUS"), # dito.
	    "%LOW_BUS%"	=> lc("MIX_LOGIC0_BUS"), # dito.
	    "%CONST%"		=> "__CONST__", # Meta instance, used to apply constant values
	    "%TOP%"		=> "__TOP__", # Meta instance, TOP cell
	    "%PARAMETER%"	=> "__PARAMETER__",	# Meta instance: stores paramter
	    "%GENERIC%"		=> "__GENERIC__", # Meta instance, stores generic default
	    "%IMPORT%"		=> "__IMPORT__", # Meta instance for import mode
	    "%IMPORT_I%"	=> "I", # Meta instance for import mode
	    "%IMPORT_O%"	=> "O", # Meta instance for import mode
	    "%IMPORT_CLK%"	=> "__IMPORT_CLK__", # import mode, default clk
	    "%IMPORT_BUNDLE%" => "__IMPORT_BUNDLE__", #
	    "%BUFFER%"		=> "buffer",
	    '%H%'		=> '$',		# 'RCS keyword saver ...
    },
    # Counters and generic messages
    'ERROR' => '__ERROR__',
    'WARN' => '__WARNING__',
    'CONST_NR' => 0,   # Some global counters
    'GENERIC_NR' => 0,
    'DELTA_NR' => 0,
    'DELTA_INT_NR' => 0,
    'sum' => { # Counters for summary
	'warnings' => 0,
	'errors' => 0,

	## Inventory
	'inst' => 0,		# number of instances
	'conn' => 0,	# number of connections
	'genport' => 0, 	# number of generated ports

	'cmacros' => 0,	# Number of matched connection macro's

	'noload' => 0,   	# signals with missing loads ...
	'nodriver' => 0,	# signals without driver
	'multdriver' => 0,	# signals with multiple drivers
	'openports' => 0,

	'checkwarn' => 0,
	'checkforce' => 0,
	'checkunique' => 0,

    },
    'script' => { # Set for pre and post execution script execution
	'pre' => '',
	'post' => '',
	'excel' => {
	    'alerts' => 'off', # Switch off ExCEL display alerts; could be on, to...
	},
    },
    'format' => { # in - out file settings
       'csv' => {
           'cellsep' => ';', # cell seperator
           'sheetsep' => ':=:=:=>', # sheet seperator
           'quoting' => '"', # quoting character
       },
       'out' => '',
    },
);

#
# Generate some data dynamically
#
    $EH{'cwd'} = cwd() || "ERROR_CANNOT_GET_CWD";
    if ( $^O =~ m/^MSWin/io ) {
        ( $EH{'drive'} = $EH{'cwd'} ) =~ s,(^\w:).*,$1/,;
    } else {
        $EH{'drive'} = "";
    }

    $EH{'macro'}{'%ARGV%'} = "$0 " . join( " ", @ARGV );

    $EH{'macro'}{'%VERSION%'} = $::VERSION;
    $EH{'macro'}{'%0%'} = $::pgm;
    $EH{'macro'}{'%DATE%'} = "" . localtime();
    $EH{'macro'}{'%USER%'} = "W_UNKNOWN_USERNAME";
    if ( $^O =~ m,^mswin,io ) {
	if ( defined( $ENV{'USERNAME'} ) ) {
	        $EH{'macro'}{'%USER%'} = $ENV{'USERNAME'};
	}
    } elsif ( defined( $ENV{'LOGNAME'} ) ) {
		$EH{'macro'}{'%USER%'} = $ENV{'LOGNAME'};
    }

    #
    # Define HOME:
    #
    if ( $^O =~ m,^mswin,io ) {
	if ( defined( $ENV{'HOMEDRIVE'} ) and defined( $ENV{'HOMEPATH'} ) ) {
	    $EH{'macro'}{'%HOME%'} = $ENV{'HOMEDRIVE'} . $ENV{'HOMEPATH'};
	}elsif ( defined( $ENV{'USERPROFILE'} ) ) {
            $EH{'macro'}{'%HOME%'} = $ENV{'USERPROFILE'};
	} else {
	    $EH{'macro'}{'%HOME%'} = "C:\\"; #TODO: is that a good idea?
	} 
    } elsif ( defined( $ENV{'HOME'} ) ) {
		$EH{'macro'}{'%HOME%'} = $ENV{HOME};
    } else {
	$EH{'macro'}{'%HOME%'} = "/home/" . $ENV{'LOGNAME'};
    }

    #
    # Define PROJECT path
    #
    if ( $ENV{'PROJECT'} ) {
	$EH{'macro'}{'%PROJECT%'} = $ENV{'PROJECT'};
    } else {
	$EH{'macro'}{'%PROJECT%'} = "NO_PROJECT_SET";
    }

    #
    # Set %IOCR% to \n if intermediate is xls and we are on Win32
    if ( $^O=~ m/MSWin/ && $EH{'macro'}{'%ARGV%'}=~ m/\.xls$/ ) {
        $EH{'macro'}{'%IOCR%'} = "\n";
    }

#}
#
# If there is a file called mix.cfg, try to read that ....
# Configuraation parameters have to be written like
#	MIXCFG key value
#	key can be key.key.key ... (see %EH structure or use -listconf to dump current values)
# !!Caveat: there will be no checks whatsoever on the values or keys !!
# Locations to be checked are:
# $HOME, $PROJECT, cwd()
#
foreach my $conf (
    $EH{'macro'}{'%HOME%'}, $EH{'macro'}{'%PROJECT%'}, "."
    ) {
    if ( -r $conf . "/" . "mix.cfg" ) {
	logtrc( "INFO", "Reading extra configurations from $conf/mix.cfg\n" );

	unless( open( CFG, "< $conf/mix.cfg" ) ) {
	    logwarn("Cannot open $conf/mix.cfg for reading: $!\n");
	} else {
	    while( <CFG> ) {
		chomp;
		$_ =~ s,\r$,,;
		next if ( m,^\s*#,o );
		if ( m,^\s*MIXCFG\s+(\S+)\s*(.*), ) { # MIXCFG key.key.key value
		    _mix_apply_conf( $1, $2, "file:mix.cfg" );
		}
	    }
	    close( CFG );
	}
    }
}

#
# Post configuration processing
#!wig20031219
if ( $EH{'output'}{'generate'}{'xinout'} ) { # Convert comma seperated list into PERL-RE
    my @si = split( "," , $EH{'output'}{'generate'}{'xinout'} );
    $EH{'output'}{'generate'}{'_re_xinout'} = '^(' . join( "|", @si ) . ')$';
} else {
    $EH{'output'}{'generate'}{'_re_xinout'} = '^__NOEXCLUDESIGNAL__$';
}

} # End of mix_init

#############################################################################
# mix_list_conf
#
# print out current contents of %EH
##############################################################################

=head2 mix_list_conf()

Triggered by -listconf command line switch. Print out current contents of
%EH configuration hash and exit. Format is suitable to be dumped into a
file mix.cfg and reread after edit.

Lines starting with MIXCFG indicate possible configuration parameters.

=cut

sub mix_list_conf () {

    my @configs = ();
    # (Recursively) retrieve the configuration settings:
    foreach my $i ( sort ( keys( %EH ) )  ) {
	push( @configs, _mix_list_conf( "$i", $EH{$i} ));
    }
    # Now print the current configuration
    foreach my $i ( @configs ) {
	print( join( " ", @$i ) . "\n" );
    }

    print( "\nCAVEAT: The list seen here might be different from the final configuration!!\n" );
    print( "CAVEAT: Because it is dumped before CONF sheet evaluation!!\n" );
    print( "CAVEAT: Run MIX and check the CONF sheet of the intermediate workbook.\n" );

    exit 0;
}

#
# Prepare configuration data to be dumped to excel format
#
sub mix_list_econf ($) {

    my $format = shift || "xls";

    my @configs = ();
    
    foreach my $i ( sort( keys( %EH ) ) ) {
	push( @configs , _mix_list_conf( "$i", $EH{$i}, $format ) );
    }

    return \@configs;
}

#
# (recursive) print of configuration options values
#
sub _mix_list_conf ($$;$) {

    my $name = shift;
    my $ref = shift;
    my $out = shift || "STDOUT";

    my @conf = ();
    if ( ref( $ref ) eq "HASH" ) {
	foreach my $i ( sort( keys %$ref )  ) {
	    push( @conf, _mix_list_conf( "$name.$i", $ref->{$i}, $out ) );
	}
    } elsif ( ref( $ref ) eq "ARRAY" ) {
	return ( [ "MIXNOCFG", $name, "ARRAY" ] );
    } elsif ( ref( $ref ) )  {
	return ( [ "MIXNOCFG", $name, "REF" ] );
    } else {
	$ref =~ s,\n,\\n,go;
	$ref =~ s,\t,\\t,go;
	return ( [ "MIXCFG", $name, $ref ] );
    }
    return @conf;
}
    
##############################################################################
# mix_overload_conf
#
# take -conf ARGUMENTS and transfer that into %EH (overloading values there)
##############################################################################

=head2 mix_overload_conf($OPTVAL{'conf'})

Started if option -conf keys=value is given on command line. key is combined from
the keys of the %EH configuration hash. Examples are

=over 4

= item -conf generate.output.arch=noleaf

Suppress generation of architecture files for leaf blocks.

=back

Apply -listconf to get a list of all possible values. Several -conf options may be
given on one command line. Apart from the command line you might change the
configuration by a file "mix.cfg" in the current working directory or by adding
values in a ExCEL sheet "CONF" in a form of <S MIXCONF key value>.
Order is built-in, mix.cfg, CONF sheet and command line has highest priority.

=cut

sub mix_overload_conf ($) {

    my $confs = shift;

    my $e = "";
    my ( $k, $v );

    for my $i ( @$confs ) {
	( $k, $v ) = split( /=/, $i ); # Split key=value
	unless( $k and $v ) {
	    logwarn("Illegal key or value given: $i\n");
	    next;
	}
	my $loga ='logtrc( "INFO", "Adding configuration ' . $i . '");';
	my $logo ='logtrc( "INFO", "Overloading configuration ' . $i . '");';
	$k =~ s,[^%.\w],,og; # Remove anything unreasonable from the key ...
	$k =~ s/\./'}{'/og;
	$k = '{\'' . $k . '\'}';

	# Mask % and other wildcards:

	#TODO: Prevent overloading of non-scalar values!!
	$e = "if ( exists( \$EH" . $k . " ) ) { \$EH" . $k . " = '" . $v . "'; " . $logo .
	    "} else { \$EH" . $k . " = '" . $v . "'; " . $loga . " }";
	unless ( eval $e ) {
                logwarn("Evaluation of configuration $k=$v failed: $@") if ( $@ );
                next;
        }
    }
}

# Similiar to _mix_overload_conf!!
sub _mix_apply_conf ($$$) {

    my $k = shift; # Key
    my $v = shift; # Value
    my $s = shift; # Source

    unless( $k and $v ) {
	    unless( $k ) { $k = ""; }
	    unless( $v ) { $v = ""; }
	    logwarn("Illegal key or value given in $s: key:$k val:$v\n");
	    return undef;
    }
    my $loga ='logtrc( "INFO", "Adding ' . $s . ' configuration ' . $k . "=" . $v . '");';
    my $logo ='logtrc( "INFO", "Overloading ' . $s . 'configuration ' . $k . "=" . $v . '");';
    $k =~ s,[^.%\w],,g; # Remove all characters not being ., % and \w ...
    $k =~ s/\./'}{'/og;
    $k = '{\'' . $k . '\'}';

    #TODO: Prevent overloading of non-scalar values!!
    my $e = "if ( exists( \$EH$k ) ) { \$EH$k = '$v'; $logo } else { \$EH$k = '$v'; $loga }";
    unless ( eval $e ) {
	    if ( $@ ) { # S.th. went wrong??
	        logwarn("Eval of configuration overload from $s $k=$v failed: $@");
	    }
    }
}

##############################################################################
# mix_overload_sheet
#
# take -sheet SHEET=MATCH_OP and transfer that into %EH (overloading values there)
##############################################################################

=head2 mix_overload_sheet($OPTVAL{'sheet'})

Started if option -sheet SHEET=match_op is given on command line. SHEET can be one of
<I hier>, <I conn>, <I vi2c>, <I conf> or <I i2c>

=over 4

= item -sheet SHEET=match_op

Replace the default match operator for the sheet type. match_op can be any perl
regular expression.match_op shoud match the sheet names of the design descriptions.

=back

=cut

sub mix_overload_sheet ($) {

    my $sheets = shift;

    my $e = "";
    my ( $k, $v );

    # %EH = ...
    #		'vi2c' => {
    #		'xls' => 'VI2C', ...

    for my $i ( @$sheets ) {
	( $k, $v ) = split( /=/, $i ); # Split key=value
	unless( $k and $v ) {
	    logwarn("Illegal argument for overload sheet given: $i\n");
	    next;
	}

	$k = lc( $k ); # $k := conn, hier, vi2c, conf, ...

	if ( exists( $EH{$k}{'xls'} ) ) {
	    logtrc( "INFO", "Overloading sheet match $i");
	    $EH{$k}{'xls'} = $v;
	} else {
	    logwarn( "Illegal sheet selector $k found in $i\n" );
	}
    }
}

####################################################################
## mix_utils_open
## Our interface for file output
## Will return a file handle object
####################################################################

=head2

mix_utils_open ($;$) {

Open file for writing. If the "delta" mode is active, then a diff will be generated
instead of a full file!

The first argument is the file to open, the second contains flags like:
    COMB (combine mode)

=cut

####
# extra block starts here
{
# Block around the mix_utils_functions .... to keep ocont, ncont and this_delta intact ...

my @ocont = (); # Keep (filtered) contents of original file
my @ncont = (); # Keep (filtered) contents of new file to feed into diff
my %this_delta = (); # Remember for which files we could delta ....
my %bfh = ();		# Keep backup file handle ....


sub mix_utils_open ($;$){
    my $file= shift;
    my $flags = shift || ""; # Could be "COMB" for combined mode

    #
    # if output.path is set, write to this path (unless file name is absolute path)
    # wig20030703
    #
    if ( $EH{'output'}{'path'} ne "." ) {
	unless( is_absolute_path( $file ) ) {
	    $file = $EH{'output'}{'path'} . "/" . $file;
	}
    }

    my $ofile = $file;

    # Print out diff's
    if ( $EH{'output'}{'generate'}{'delta'} ) { # Delta mode!
	my $ext;
	my $c = "__NOCOMMENT";
	( $ext = $file ) =~ s/.*\.//;
	for my $k ( keys ( %{$EH{'output'}{'ext'}} )) {
	    if ( $EH{'output'}{'ext'}{$k} eq $ext ) {
		$c = $EH{'output'}{'comment'}{$k} || "__NOCOMMENT";
		last;
	    }
	}
	if ( -r $file ) {
	# read in file
	    my $ofh = new IO::File;
	    unless( $ofh->open($file) ) {
		logwarn( "ERROR: Cannot open org $file in delta mode: $!" );
		return undef, undef;
	    }
	    @ocont = <$ofh>; #Slurp in file to compare against
	    chomp( @ocont );
	    # remove comments: -- for VHDL, // for Verilog
	    #TODO: make that dependant on the file extension
	    map( { s/\Q$c\E.*//o; } @ocont ) if ( $EH{'output'}{'delta'} !~ m,comment,io );
	    if ( $EH{'output'}{'delta'} !~ m,space,io ) {
		map( { s/\s+/ /og; s/^\s*//og; s/\s*$//og; } @ocont );
		@ocont = grep( !/^$/,  @ocont );
	    }
	    ( @ocont = sort( @ocont ) ) if ( $EH{'output'}{'delta'} =~ m,sort,io );

	    close( $ofh ) or logwarn( "ERROR: Cannot close org $file in delta mode: $!" )
		and $EH{'sum'}{'errors'}++;
	    $ofile .= $EH{'output'}{'ext'}{'delta'}; # Attach a .diff to file name

	    @ncont = (); # Reset new contents
	} else {
	    logwarn( "Info: Cannot run delta mode vs. $file. Will create like normal" );
	    $this_delta{"$file"} = 0;
	}
    }

    # Save one backup
    if ( $EH{'output'}{'generate'}{'bak'} ) {
	# Shift previous version to file.bak ....
	if ( -r $file ) {
	    rename( $file, $file . ".bak" ) or
		logwarn( "ERROR: Cannot rename $file to $file.bak" ) and $EH{'sum'}{'errors'}++;
	}
    }

    # Append or create a new file?
    # Append will be used if we get a "COMB" flag (combine mode)
    my $mode = O_CREAT|O_WRONLY|O_TRUNC;
    if ( $flags =~ m,^COMB, ) {
	$mode = O_CREAT|O_WRONLY|O_APPEND;
    }
    # $fh -> keep main file handle
    my $fh = new IO::File;
    unless( $fh->open( $ofile, $mode) ) {
	logwarn( "ERROR: Cannot open $ofile: $!" );
	return undef;
    }

    # Remember if delta mode is active for this file ...
    if ( $ofile ne $file ) {
	$this_delta{"$fh"} = $file;
    } else {
	$this_delta{"$fh"} = 0;
    }

    # If -delta and -bak -> create a new original file ...
    if ( $EH{'output'}{'generate'}{'bak'} and $EH{'output'}{'generate'}{'delta'} ) {
	# Append or create a new file?
	# $bfh -> backup file handle (will get new data!)
	my $bfh = new IO::File;
	unless( $bfh->open( $file, $mode) ) {
	    logwarn( "ERROR: Cannot open $file: $!" );
		$EH{'sum'}{'errors'}++;
		    $bfh{"$fh"} = undef;
	} else {
	    $bfh{"$fh"} = $bfh;
	}
    } else {
	$bfh{"$fh"} = 0;
    }
    return $fh;
}

#
# is_absolute_path
#  returns true/1 if the given path is a absolute one
#  /path/bla
# A:/bla
# A:\bla\ ...
#
sub is_absolute_path ($) {
    my $path = shift;

    if ( $^O=~/Win32/ ) {
	if ( $path =~ m,^[/\\], or $path =~ m,^[a-zA-Z]:[/\\], ) {
	    return 1;
	} else {
	    return 0;
	}
    } else {
	if ( $path =~ m,^/, ) {
	    return 1;
	} else {
	    return 0;
	}
    }

}

#
# print into file handle or save for later diff
#
sub mix_utils_print ($@) {
    my $fh = shift;
    my @args = @_;

    if ( $this_delta{"$fh"} ) {
	push( @ncont, split( /\n/, sprintf( "%s", @args ) ) );
    } else {
	print( $fh @args );
    }
    if ( $bfh{"$fh"} ) {
	print( {$bfh{"$fh"}} @args );
    }
}

#
# printf into file handle or save for later diff
#
sub mix_utils_printf ($@) {
    my $fh = shift;
    my @args = @_;

    if ( $this_delta{"$fh"} ) {
	push( @ncont, split( /\n/, sprintf( @args ) ) );
    } else {
	printf( $fh @args );
    }
    if ( $bfh{"$fh"} ) {
	printf( {$bfh{"$fh"}} @args );
    }
}

#
# Close that file-handle
# If in delta mode, run the diff and print before closing!
#
sub mix_utils_close ($$) {
    my $fh = shift;
    my $file = shift;

    my $close_flag = 1;

    # Prepend PATH
    if ( $EH{'output'}{'path'} ne "." and not is_absolute_path( $file ) ) {
	$file = $EH{'output'}{'path'} . "/" . $file;
    }

    my $ext;
    my $c = "__NOCOMMENT";
    ( $ext = $file ) =~ s/.*\.//;
    for my $k ( keys ( %{$EH{'output'}{'ext'}} )) {
	if ( $EH{'output'}{'ext'}{$k} eq $ext ) {
	    $c = $EH{'output'}{'comment'}{$k} || "__NOCOMMENT";
	    last;
	}
    }

    if ( $this_delta{"$fh"} ) {
    # Sort/map new content and compare .... print out to $fh
	map( { s/\Q$c\E.*//o; } @ncont ) if ( $EH{'output'}{'delta'} !~ m,comment,io );
	if ( $EH{'output'}{'delta'} !~ m,space,io ) {
	    map( { s/\s+/ /og; s/^\s+//o; s/\s+$//o; } @ncont );
	    @ncont = grep( !/^$/,  @ncont );
	}
	@ncont = sort( @ncont ) if ( $EH{'output'}{'delta'} =~ m,sort,io );

	# Print header to $fh ... (usual things like options, ....)
	# TODO: Add that header to header definitions
my $head =
"$c ------------- delta mode for file $file ------------- --
$c
$c Generated
$c  by:  %USER%
$c  on:  %DATE%
$c  cmd: %ARGV%
$c  delta mode (comment/space/sort/remove): $EH{'output'}{'delta'}
$c
$c ------------- CHANGES START HERE ------------- --
";
	print( $fh replace_mac( $head, $EH{'macro'} ));

	# Diff it ...
	my $diff = diff( \@ncont, \@ocont,
	    { STYLE => "Table",
	    # STYLE => "Context",
	    FILENAME_A => 'NEW', #TODO: get new file name in here!
	    FILENAME_B => "OLD $file",
	    CONTEXT => 0,
	    # OUTPUT     => $fh,
	    }
	);

	# Was there a difference? If yes, report and sum up.
	if ( $diff ) {
	    print $fh $diff;
	    logwarn("Info: file $file has changes!");
	    $EH{'DELTA_NR'}++;
	} else {
	    logtrc( "INFO:4", "Info: unchanged file $file" );
	    if ( $EH{'output'}{'delta'} =~ m,remove,io ) {
		# Remove empty diff files (removal before closing ????)
		if ( $close_flag and not $fh->close ) {
		    logwarn( "ERROR: Cannot close file $file: $!" );
		    $EH{'sum'}{'errors'}++;
		}
		$close_flag = 0;
		unlink( "$file" . $EH{'output'}{'ext'}{'delta'} ) or
		    logwarn( "WARNING: Cannot remove empty diff file $file" .
			     $EH{'output'}{'ext'}{'delta'} . "!" ) and
			    $EH{'sum'}{'warnings'}++;
	    }
	}
    }

    if ( $close_flag and not $fh->close ) {
	logwarn( "ERROR: Cannot close file $file: $!" );
	$EH{'sum'}{'errors'}++;
	return undef;
    }

    # Close new file if in -bak mode and close_flag is set ...
    if ( $close_flag and $bfh{"$fh"} ) {
	my $bfh = $bfh{"$fh"};
	$bfh->close or logwarn( "ERROR: Cannot close file $file: $!" )
	    and $EH{'sum'}{'errors'}++
	    and return undef;
    }

    return;
}

} # End of mix_util_FILE block ....
####

#
# Do some text replacements
#
sub replace_mac ($$) {
    my $text = shift;
    my $rmac = shift;

    if ( keys( %$rmac ) > 0 ) {
        my $mkeys = "(" . join( '|', keys( %$rmac ) ) . ")";
        $text =~ s/$mkeys/$rmac->{$1}/mg;
    } else {
	# Do nothing if there are no keys defined ...
        # Strange, why would one call a replace functions without replacement
        # keys ?
        logtrc( "INFO", "Called replace mac without macros for string " .
                substr( $text, 0, 15 ) . " ..." );
    }
    return $text;
}

####################################################################
## select_variant
## remove all lines that have ::variant not matching the selected variant
####################################################################

=head2

select_variant ($) {

Remove all lines not matching the selected variant. Variant defaults to <S default>.
if ::variants is not defined, this row is always selected. If a row is marked as default,
is will be selected only if no variant is choosen.
Matching is done case insensitive!

=cut

sub select_variant ($) {
    my $r_data = shift;

    unless ( defined $r_data ) {
	    logwarn("FATAL: select_variant called with bad argument!");
	    exit 1;
    }

    for my $i ( 0..$#$r_data ) {
	if ( exists( $r_data->[$i]{'::variants'} ) ) {
	    my $var = $r_data->[$i]{'::variants'};	    
	    # if ( defined( $var ) and $var !~ m/^\s*$/o and $var !~ m/^default/io ) {
	    if ( defined( $var ) and $var !~ m/^\s*$/o ) {
		$var =~ s/[ \t,]+/|/g; # Convert into Perl RE (Var1|Var2|Var3)
		$var = "(" . $var . ")";
		if ( $EH{'variant'} !~ m/^$var$/i ) {
		    $r_data->[$i]{'::ign'} = "# Variant not selected!"; # Mark for deletion ...
		    # delete( $r_data->[$i] ); ### XXXXX remove from array
		}
	    }
	}
    }
}

####################################################################
## convert_in
## read in a excel spreadsheet array and convert into a array of hashes
## do basic checks and conversion 
####################################################################

=head2

convert_in ($$) {

Do basic conversion:

=over 4

=item *

Remove empty lines and comment lines, e.g. marked by a # in the ::ign column.

=item *

Find header line

=item *

Check if headers are complete

=item *

Convert rest of array to hash

=back

=cut

sub convert_in ($$) {
    my $kind = shift;
    my $r_data = shift;

    unless ( defined $kind and defined $r_data ) {
	    logwarn("WARNING: skipping convert_in, called with bad arguments!");
	    return ();
    }

    my @d = ();
    my @order = ();  # Field number to name
    my %order = ();  # Field name to number
    my $hflag = 0;
    my $required = $EH{$kind}{'field'}; # Shortcut into EH->fields

    for my $i ( @$r_data ) { # Read each row
	# my @r = @{$r_data->[$i]};
	$i = [ map { defined( $_ ) ? $_ : "" } @$i ];		#Fill up undefined fields??
	my $all = join( '', @$i );
	next if ( $all =~ m/^\s*$/o ); 			#If a line is complete empty, skip it
	next if ( $all =~ m,^\s*(#|//), );			#If line starts with comment, skip it

	unless ( $hflag ) { # We are still looking for our ::MARKER header line
	    next unless ( $all =~ m/^::/ );			#Still no header ...
	    %order = parse_header( $kind, \$EH{$kind}, @$i );		#Check header, return field number to name
	    $hflag = 1;
	    next;
	}
	# Skip ::ign marked with # or // comments, again ...
	next if ( defined( $order{'::ign'}) and $i->[$order{'::ign'}] =~ m,^(#|//), );

	# Copy rest to 'another' array ....
	my $n = $#d + 1;
	foreach my $ii ( keys( %order ) ) {
	    if ( defined( $i->[$order{$ii}] ) ) {
		$d[$n]{$ii} = $i->[$order{$ii}];
	    } else {
		# Could be "semi-required" field
		if ( $required->{$ii}[2] > 1 ) {
		    $d[$n]{$ii} = $required->{$ii}[3];
		} else {
		    $d[$n]{$ii} = "%UNDEF%";
		}
	    }#TODO: Set to default ? If field is undefined, set to ""
	}
    }
    unless( $hflag ) {
	logwarn("WARNING: Failed to detect header in worksheet of type $kind");
	$EH{'sum'}{'warnings'}++;
    }
    return @d;
}

####################################################################
## parse_header
## check the ::TYPE input line
####################################################################
=head2

parse_header ($$@) {

See if the header line is complete, check if we all required fields and if we have extra fields
Convert multiple ::head to ::head, ::head:2, ....

I guess multiple headers are kind of evil (keep an eye on them)

Arguments: $kind, \$eh{$kind}, @header_row

Returns: %order (keys are the ::head items)
=cut

sub parse_header($$@){
    my $kind = shift;
    my $templ = shift;
    my @row = @_;

    unless( defined $kind and defined $templ and $#row >= 0 ) {
	logwarn( "ERROR: parse header started with missing arguments!\n" );
	exit 1;
    }

    my %rowh = ();

    for my $i ( 0 .. ( scalar( @row ) - 1 ) ) {
	unless ( $row[$i] )  {
	    logtrc("INFO:4" , "WARNING: Empty header in column $i, sheet-type $kind, skipping!");
	    # $EH{'sum'}{'warnings'}++;
	    push( @{$rowh{"::skip"}}, $i);
	    $row[$i] = "::skip";
	    next;
	}
	if ( $row[$i] and $row[$i] !~ m/^::/o ) { #Header not starting with ::
	    logwarn("WARNING: Bad name in header row: $row[$i] $i, type $kind, skipping!");
	    $EH{'sum'}{'warnings'}++;
	    push( @{$rowh{"::skip"}}, $i);
	    next;
	}
	# Get multiple columns and such ... in %rowh
	push( @{$rowh{$row[$i]}}, $i );
    }
    #
    # Are all required fields in @row, multiple rows?
    #
    for my $i ( keys( %{$$templ->{'field'}} ) ) {
	    next unless( $i =~ m/^::/o );
	    if( $$templ->{'field'}{$i}[2] > 0 ) { #required field
		if ( not defined( $rowh{$i} ) ) {
		    if ( $$templ->{'field'}{$i}[2] > 1 ) { # 2 -> needs to be initialized silently
			logtrc(INFO, "Info: appended optional data field $i.");
			push ( @row, $i );
			push( @{$rowh{$i}} ,$#row );
			#TODO: do not print out such fields -> ... ???
		    } else {
			logwarn("Missing required field $i in input array!");
			# exit;
		    }
		}
	    }
	    if ( defined( $rowh{$i} ) and $#{$rowh{$i}} >= 1 and $$templ->{'field'}{$i}[1] <= 0 ) {
		logwarn("WARNING: Multiple input header not allowed for $i!");
		$EH{'sum'}{'warnings'}++;
	    }
    }

    #
    # Initialize new fields from ::default
    # This will catch multiply defined fields, too (together with the split code below)
    #
    for my $i ( 0..$#row ) {
	my $head = $row[$i];	
	unless ( defined( $$templ->{'field'}{$head} ) ) {
	    logtrc(INFO, "Added new column header $head");
	    @{$$templ->{'field'}{$head}} = @{$$templ->{'field'}{'::default'}}; #Check: does this really copy everything
	    $$templ->{'field'}{$head}[4] = $$templ->{'field'}{'nr'};
	    $$templ->{'field'}{'nr'}++;
	}
    }

    #
    # Split/rename muliple headers ::head becomes ::head, ::head:1 ::head:2, ::head:3 ...
    #
    my %or = (); # "flattened" ordering
    for my $i ( keys( %rowh ) ) {
	next if ( $i =~ m/^::skip/ ); #Ignore bad fields
	if ( $#{$rowh{$i}} > 0 ) {
	    $or{$i} = $rowh{$i}[0]; # Save first field, rest will be seperated by name ...
	     for my $ii ( 1..$#{$rowh{$i}} ) {
		    unless( defined( $$templ->{'field'}{$i . ":" . $ii} ) ) {
			logtrc(INFO, "Split multiple column header $i to $i:$ii");
			$$templ->{'field'}{$i. ":". $ii} = $$templ->{'field'}{$i}; #Check: do a real copy ...
			#Remember print order no longer is unique
		    }
		    $or{$i. ":". $ii} = $rowh{$i}[$ii];
	     }
	} else {
		$or{$i} = $rowh{$i}[0];
	}
    }

    # Finally, got the field name list ... return now
    return %or;
}


####################################################################
## mix_store
## dump data (hash) on disk
##
## use $EH{'internal'}{'path'} to define a directry != cwd()
####################################################################

=head2

mix_store ($$;$) {

Dump input data into a disk file.
Set $EH{'internal'}{'path'} to change output directory.

=cut
sub mix_store ($$;$){
    my $file = shift;
    my $r_data = shift;
    my $flag = shift || "internal";

    #
    # attach $EH{$flag}{'path'} ...
    #
    my $predir = "";
    if( $EH{$flag}{'path'} ne "." and not is_absolute_path( $file ) ) {
	$predir = $EH{$flag}{'path'} . "/";
    }
    if ( -r ( $predir . $file ) ) {
	logwarn("file $predir$file already exists! Will be overwritten!");
    }

    #TODO: would we want to use nstore instead ?
    unless( store( $r_data, $predir . $file ) ) {
	logwarn("FATAL: Cannot store date into $predir$file: " . $! . "!\n");
	exit 1;
    }

    #
    # Use Data::Dumper while debugging ...
    #    output is man-readable ....
    #

    if ( $OPTVAL{'adump'} ) {
	use Data::Dumper;
	$file .= "a";
	unless( open( DUMP, ">$predir$file" ) ) {
	    logwarn("FATAL: Cannot open file $predir$file for dumping: $!\n");
	    exit 1;
	}
	print( DUMP Dumper( $r_data ) );
	unless( close( DUMP ) ) {
	    logwarn("FATAL: Cannot close file $predir$file: $!\n");
	    exit 1;
	}
    }

    return;
}

####################################################################
## mix_load
## load data (hash) from disk
####################################################################

=head2

mix_load ($%) {

Load dumped data from a disk file. Return undef if something goes wrong.

=cut
sub mix_load ($%){
    my $file = shift;
    my $r_data = shift;

    my $r_d;
    my $flag = 1;
    $r_d = retrieve( $file );

    foreach my $i ( keys( %$r_data ) ) {
	if ( exists( $r_d->{$i} ) ) {
	    $r_data->{$i} = $r_d->{$i};
	}
	else {
	    logwarn( "WARNING: Dumped data does not have $i hash!" );
	    $EH{'sum'}{'warnings'}++;
	    $flag = undef;
	}
    }
    return $flag;
}

####################################################################
## db2array
## convert internal db structure to array
####################################################################

=head2

db2array ($$$) {

convert the datastructure to a flat array

Arguments: $ref    := hash reference
		$type  := (hier|conn)
		$filter := Perl_RE,if it matches a key of ref, do not print that out
			    if $filter is an sub ref, will be used in grep

=cut
sub db2array ($$$) {
    my $ref = shift;
    my $type = shift;
    my $filter = shift;

    unless( $ref ) { logwarn("WARNING: Called db2array without db argument!");
	    $EH{'sum'}{'warnings'}++;
	    return;
    }
    unless ( $type =~ m/^(hier|conn)/io ) {
	logwarn("WARNING: Bad db type $type, ne HIER or CONN!");
	$EH{'sum'}{'warnings'}++;
	return;
    }
    $type = lc($1);

    my @o = ();
    my $primkeynr = 0; # Primary key identifier
    my $commentnr = "";
    # Get order for printing fields ...
    #TODO: check if fields do overlap!
    for my $ii ( keys( %{$EH{$type}{'field'}} ) ) {
	next unless ( $ii =~ m/^::/o );
	$o[$EH{$type}{'field'}{$ii}[4]] = $ii;
	if ( $EH{$type}{'key'} eq $ii ) {
	    $primkeynr = $EH{$type}{'field'}{$ii}[4];
	} elsif ( $ii eq "::comment" ) {
	    $commentnr = $EH{$type}{'field'}{$ii}[4];
	}
    }

    my @a = ();
    my $n = 0;

    # Print header
    for my $ii ( 1..$#o ) {
	$a[$n][$ii-1] = $o[$ii];
    }
    $n++;
    # Print comment: generator, args, date
    # First column is ::ign :-)
    # As we are lazy, we will leave the rest of the line undefined ...
    my %comment = ( qw( by %USER% on %DATE% cmd %ARGV% ));
    $a[$n++][0] = "# Generated Intermediate Conn/Hier Data";
    for my $c ( qw( by on cmd ) ) {
	$a[$n++][0] = "# $c: " . $EH{'macro'}{$comment{$c}};
    }

    my @keys = ();
    if ( $filter ) { # Filter the keys ....
	if ( ref( $filter ) eq "CODE" ) {
	    @keys = grep( &$filter, keys( %$ref ) );
	} else {
	    @keys = grep( !/$filter/, keys( %$ref ) );
	}
    } else {
	@keys = keys( %$ref );
    }

    # Now comes THE data
    for my $i ( sort( @keys ) ) {
	my $split_flag = 0; # If split_flag 
	for my $ii ( 1..$#o ) { # 0 contains fields to skip
	    #wig20031106: split on all non key fields!
	    if ( $o[$ii] =~ m/^::(in|out)\s*$/o ) { # ::in and ::out are special
		$a[$n][$ii-1] = inout2array( $ref->{$i}{$o[$ii]}, $i );
	    } else {
		$a[$n][$ii-1] = defined( $ref->{$i}{$o[$ii]} ) ? $ref->{$i}{$o[$ii]} : "%UNDEF_1%";
	    }
	    if ( length( $a[$n][$ii-1] ) > 1023 ) {
		# Line too long! Split it!
		# Assumes that the cell to be split are accumulated when reused later on.
		# Will not check if that is not true!
		if ( $ii - 1 == $primkeynr ) {
		    logwarn( "WARNING: Splitting key of table: " . substr( $a[$n][$ii-1], 0, 32 ) );
		    $EH{'sum'}{'warnings'}++;
		}
		$split_flag=1;
		my @splits = mix_utils_split_cell( $a[$n][$ii-1] );

		# Prefill the split data .... key will be added later
		#Caveat: order should not matter!!
		for my $splitn ( 0..(scalar( @splits ) - 1 )  ) {
			$a[$n + $splitn][$ii-1] = $splits[$splitn];
		}
		$split_flag = scalar( @splits ) if ( $split_flag < scalar( @splits ) );	
	    }
	}
	#This was a split cell?
	if ( $split_flag > 1 ) {
	    # Set primary key in cells, add comments
	    for my $sn ( 1..( $split_flag - 1 ) ) {
		$a[$n + $sn][$primkeynr-1] = $a[$n][$primkeynr-1];
		if ( $commentnr ne "" ) { # Add split comment
		    $a[$n + $sn][$commentnr-1] .= "# __I_SPLIT_CONT_$sn";
		}
                # Make sure all cells are defined
                for my $ssn ( 0..(scalar( @{$a[$n]} ) - 1) ) {
                    $a[$n + $sn][$ssn] = "" unless defined( $a[$n + $sn][$ssn] );
                }                    
	    }
	    $n += $split_flag; # Goto next free line ...
	} else {
	    $n++;
	}
    }

    return \@a;

}

#####################################################################
## Split cells longer than 1024 characters into chunks suitable for excel
## to swallow
##
## Input: cell content
## Return value: @chunks
##
## Caveat: if cell does not contain %IOCR% markers, will split somewhere in the middle!
## Might lead to troubles if read back.
##!wig20031216: use 1023 as limit
####################################################################
sub mix_utils_split_cell ($) {

    my $data = shift;
    my $flaga = 0;

    # Get pieces up to 1023 characters, seperated by ", %IOCR%"
    my $iocr = $EH{'macro'}{'%IOCR%'};
    my @chunks = ();

    while( length( $data ) > 1023 ) {
	my $tmp = substr( $data, 0, 1023 ); # Take 1023 chars
	# Stuff back up to last %IOCR% ...
	my $ri = rindex( $tmp, $iocr ); # Read back until next <CR>
	if ( $ri <= 0 ) { # No $iocr in string -> split at arbitrary location ??
	    push( @chunks, $tmp );
	    substr( $data, 0, 1023 ) = "";
	    logtrc( "INFO:4",  "INFO: Split cell at arbitrary location: " . substr( $tmp, 0, 32 ) )
		unless $flaga;
	    $flaga = 1;
	} else {
	    if ( $flaga ) {
		logwarn( "WARNING: Cell split might produce bad results, iocr detection failed: " .
		    substr( $chunks[0], 0, 32 ) );
		$EH{'sum'}{'warnings'}++;
	    }
	    substr( $data, 0, $ri ) = ""; # Take away leading chars
	    push ( @chunks,  substr( $tmp, 0, $ri ) ); # Chunk found ...
	}
    }
    # Rest ...
    push( @chunks, $data );

    return @chunks;
}

####################################################################
## inout2array
## convert internal in/out db structure to array
####################################################################

=head2

inout2array ($$) {

convert the in/out datastructure to a flat array

Arguments: $ref    := hash reference
		$type  := (hier|conn)

=cut
sub inout2array ($;$) {
    my $f = shift;
    my $o = shift || "";

    unless( defined( $f ) ) { return "%UNDEF_2%"; };

    my $s = "";

#       '::out' => [
#
#                     'sig_t' => undef,
#                     'port' => '%name%',
#                     'sig_f' => undef,
#                     'inst' => 'u_ddrv4',
#	               'port_t' => undef,
#                     'port_f' => undef
#		    	'cast' => cast_func ....
#                   }
#                 ],

    for my $i ( @$f ) {

	my $cast = "";
	unless( defined( $i->{'inst'} ) ) {
	    next;
	}
	if ( exists( $i->{'cast'} ) ) {
	    $cast = "'" . $i->{'cast'};
	}
	# Constants are working a different way:
	#: m,^\s*(__CONST__|%CONST%|__GENERIC__|__PARAMETER__|%GENERIC%|%PARAMETER%),o ) {
	#TODO: make sure sig_t/sig_f and port_t/port_f are defined in pairs!!
	if ( $i->{'inst'} =~
	    m,^\s*(__CONST__|%CONST%),o ) {
	    $s .= $i->{'port'} . $cast . ", %IOCR%";
	} elsif ( defined $i->{'sig_t'} and $i->{'sig_t'} ne '' ) {
	# inst/port($port_f:$port_t) = ($sig_f:$sig_t)
	    if ( defined $i->{'port_t'} and $i->{'port_t'} ne '' ) {
		$s .= $i->{'inst'} . "/" . $i->{'port'} . $cast . "(" .
			$i->{'port_f'} . ":" . $i->{'port_t'} . ")=(" .
			$i->{'sig_f'} . ":" . $i->{'sig_t'} . "), %IOCR%";
	    } else {
		# TODO inst/port = (sf:st)  vs. inst/port(0:0) = (sf:st)
		$s .= $i->{'inst'} . "/" . $i->{'port'} . $cast . "=(" .
			$i->{'sig_f'} . ":" . $i->{'sig_t'} . "), %IOCR%";
	    }
	} else {
	    if ( defined $i->{'port_t'} and $i->{'port_t'} ne '' ) {
		$s .= $i->{'inst'} . "/" . $i->{'port'} . $cast . "(" .
			$i->{'port_f'} . ":" . $i->{'port_t'} . # ")=(" .
			# $i->{'sig_f'} . ":" . $i->{'sig_t'} .
			"), %IOCR%";
	    } else {
		# If this is %OPEN% and neither port nor signal defined -> set to (0)
		if ( $o eq '%OPEN%' ) {
		    $s .= $i->{'inst'} . "/" . $i->{'port'} . $cast . "(0:0)=(0:0)" . ", %IOCR%";
		} else {
		    $s .= $i->{'inst'} . "/" . $i->{'port'} . $cast . ", %IOCR%";
		}
	    }
	}
    }

    if ( ( $s =~ m,\(:,o ) or ( $s =~ m,\(:,o ) ) {
	logwarn( "WARNING: inout2array bad branch (: ! File bug report!" );
    }

    $s =~ s/,\s*%IOCR%\s*$//o; #Remove trailing CR
    # convert macros (parse_mac already done )!!!
    $s =~ s,%IOCR%,$EH{'macro'}{'%IOCR%'},g;

    return $s;
}


####################################################################
## convert two dim. input arry into a one-dim. array.
## by concatenation the cells with \tX\t
####################################################################
#wig20030716: use first line as header descriptions, field seperator!!
sub two2one ($) {
    my $ref = shift;

    my @out = ();
 
    no warnings; # switch of warnings here, values might be undefined ...
    # Convert two dim. input array into one-dimensional
    for my $n ( @$ref ) {
	my $l = join( '@@@', @$n ); # Use @@@ as field seperator ...
	$l =~ s/\t+/\t/g;# Remove multiple \t
	$l =~ s/\t$//; # Convert \t to space ....
	push( @out, $l );
    }
    if ( $EH{'output'}{'delta'} !~ m/space/ ) {
	@out = grep( !/^\s*$/ , @out ); # Get rid of "space only" elements
    }
    return @out;
}

#####################################################################
## create a two-dim. array from a one-dim. one
## suitable to be fed to ExCEL
## possibly undo Text::Diff table format -> ExCEL
#####################################################################
sub one2two ($) {
    my $ref = shift;

    my @out = ();
    my @fields = ();
    my $tline = '';
    my $match = '';
    my $difflines = -1;
    if ( @fields = split( /\+/, $ref->[0] ) ) {
	$tline = $ref->[0];
	# @fields has lengthes, now ....
	unless( $fields[0] ) { shift @fields; }; #Take away the first if empty
	if ( scalar( @fields ) < 1 or scalar( @fields ) > 4 ) {
	    logwarn( "WARNING: Bad number of fields found in write_delta_excel!" );
	}
	my @w = map( { length( $_ ) }@fields );
	for my $i ( @w ) {
	    if ( $i > 1024 * 10 ) { # reg expression seems to be limited to 32766 chars ..
		logwarn( "WARNING: Cannot split field with $i chars in delta mode!\n" );
		$match .= '[*|]([^*|]+)';
	    } else {
		$match .= '[*|](.{' . $i . '})';
	    }
	}
    }
    for my $n ( 0..$#{$ref} ) {
	if ( $tline ) {
	    if ( $ref->[$n] =~ m/\Q$tline/ ) {
		$out[$n][0] = '--------------------------';
	    } elsif ( $ref->[$n] =~ m/$match/ ) {
		my $n1 = $1 || " ";
		my $n2 = $3 || " ";
		my $nval = $2 || " ";
		my $oval = $4 || " ";
		# Only three fields -> Table does not have second line number column
		if ( scalar( @fields ) == 3 ) {
		    $oval = $n2;
		    $n2 = "";
		}
		$nval =~ s/ +/ /og; # Compress <space>
		$oval =~ s/ +/ /og; # Compress <space>
		@{$out[$n]} = ( $n1, $nval, $n2, $oval );
		# Initialize difflines, but only count lines not starting with a # or a //
		if ( $difflines == -1 ) { $difflines = 0; };
		if ( $nval !~ m,^\s*(#|//), or $oval !~ m,^\s*(#|//), ) {
		    unless( $n1 =~ m,^\s*$, and $n2 =~ m,^\s*$,
			    and $nval =~  m,^\s*NEW\s*$, ) {
			$difflines++;
		    }
		}
	    } else {
		$out[$n][0] = $ref->[$n];
	    }
	} else {
	    $out[$n][0] = $ref->[$n];
	}
    }
    return $difflines, @out;
}


####################################################################
## write_sum
## write out summary informations
####################################################################

=head2

write_sum ()

write out various summary information like number of changed files, generated wires

=cut

sub write_sum () {

    #TODO: use different log**** call !!
    #TODO: Shift function to other module ... ??

    # Parsed input sheets:
    logwarn( "============= SUMMARY =================" );
    logwarn( "SUM: Summary of checks and created items:" );
    for my $i ( sort( keys( %{$EH{'sum'}} ) ) ) {
        logwarn( "SUM: $i $EH{'sum'}{$i}" );
    }
    logwarn( "SUM: Number of parsed input tables:" );
    for my $i ( qw( conf hier conn io i2c ) ) {
        logwarn( "SUM: $i $EH{$i}{'parsed'}" );
    }

    # Delta mode: return status equals number of changes
    if ( $EH{'output'}{'generate'}{'delta'} ) {
        #TODO: Do not use logwarn channel!
        logwarn( "SUM: Number of changes in intermediate: $EH{'DELTA_INT_NR'}");
        logwarn( "SUM: Number of changed files: $EH{'DELTA_NR'}");
        return $EH{'DELTA_NR'} + $EH{'DELTA_INT_NR'};
    }

    return 0;

}

##############################################################################
# mix_utils_init_file($)
##############################################################################

=head2 mix_utils_init_file($)

In init mode:

Take the provided templates and create a MIX startup file.

This will give
    - appropriate XLS and/or CVS files you can put your
      design description into.
    - mix.cfg template

If available some data will be put into already (If you provide HD
input files).

In import mode:

Extend the already existing files by data retrieved from the provided HDL
files arguments.

=cut

sub mix_utils_init_file($) {
    my $mode = shift || "init";

    my @hdlimport = ();
    my @descr = ();
    if ( exists( $OPTVAL{'import'} ) ) {
	push ( @hdlimport,  @{$OPTVAL{'import'}} );
    }

    my $inext = join( "|", values( %{$EH{'input'}{'ext'}} ) );
    my $outext = join( "|", values( %{$EH{'output'}{'ext'}} ) );
    my $output = "";
    my $input = "";

    #
    # Sort remaining file arguments
    #
    for my $i ( @ARGV ) {
	if ( $i =~ m,\.($outext)$, ) { # HDL file ...
	    push( @hdlimport, $i );
	    next;
	} elsif ( $i =~ m,\.($inext)$, ) { # HDL file ...
	    push( @descr, $i );
	    next;
	} else {
	    logwarn( "INFO: Found file $i not matching my extension set. Skipped!" );
	}
    }

    if ( scalar( @descr ) > 1 ) {
	logwarn( "WARNING: Ignoring all but last mix input files!" );
	$output = pop( @descr );
    } elsif ( scalar( @descr ) < 1 ) {
	# User has not given an output file name -> take directory name
	if ( defined $OPTVAL{'dir'} and $OPTVAL{'dir'} ne "." ) {
	    $output = $OPTVAL{'dir'} . "/" . basename( $OPTVAL{'dir'} );
	} else {
	    $output = $EH{'cwd'} . "/" . basename( $EH{'cwd'} );
	}

	# Extension: MS-Win -> xls, else csv
	if ( $^O =~ m,^mswin,io || $EH{'intermediate'}{'ext'}=~ m/^xls$/) {
	    $output .= ".xls";
	}
	elsif( $EH{'intermediate'}{'ext'}=~ m/^sxc$/) {
	    $output .= ".sxc";
	}
	else {
	    $output .= ".csv";
	}
	logwarn( "WARNING: Setting project name to $output" );
	$EH{'sum'}{'warnings'}++;
    } else {
	$output = pop( @descr );
    }

    ( my $ext = $output ) =~ s,.*\.,,;
    unless( $ext ) {
	logwarn( "FATAL: Cannot detect appropriate extension for output from $output" );
	exit 1;
    }

    # Get template and mix.cfg in place if "init"
    # In -init mode we will die if the output file already exists ...

    if ( $mode eq "init" ) {
	if ( -r $output ) {
	    logwarn( "FATAL: Output file $output already existing!" );
	    exit 1;
	}
	( $input = $main::pgmpath ."/template/mix." . $ext ) =~ s,\\,/,g;
	if ( ! -r $input ) {
	    logwarn( "FATAL: Cannot init mix from $input" );
	    exit 1;
	}
	# Get mix.cfg template inplace:
	if ( -r ( dirname( $output ) . "/mix.cfg" ) ) {
	    logwarn( "WARNING: Existing config file mix.cfg will not be changed!" );
	} else {
	    copy( dirname( $input ) . "/mix.cfg" , dirname( $output ) . "/mix.cfg" )
		or logwarn( "WARNING: Copying mix.cfg failed: " . $! . "!" );
	}

	# Get template in place ...
	copy( $input, $output ) or
	    logwarn( "FATAL: Copying $input to $output failed: " . $! . "!" )
	    and exit 1;
    }

    # If user provided HDL files, we try to scan these and add to the template ...
    if ( scalar( @hdlimport ) ) {

        #OFF: only Utils knows about that ... my $ole = init_ole(); # Start OLE Object ... for windows, only
        Micronas::MixUtils::IO::mix_utils_open_input( $output );
        #Gets format from file to import too.

	Micronas::MixParser::mix_parser_importhdl( $output, \@hdlimport ); # Found in MixParser ...
    }

    # Done ...
    exit 0;

}


#
# This module returns 1, as any good module does.
#
1;

#!End
