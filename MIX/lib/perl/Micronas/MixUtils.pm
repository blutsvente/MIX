# -*- perl -*---------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright Micronas GmbH, Inc. 2002.                        |
# |     All Rights Reserved.                     |
# |                                                                       |
# |                                                                       |
# | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF MICRONAS GMBH |
# | The copyright notice above does not evidence any actual or intended   |
# | publication of such source code.                                      |
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# | Project:    Micronas - MIX                                    |
# | Modules:    $RCSfile: MixUtils.pm,v $                                     |
# | Revision:   $Revision: 1.7 $                                             |
# | Author:     $Author: wig $                                  |
# | Date:       $Date: 2003/02/20 15:07:13 $                                   |
# |                                                                       |
# | Copyright Micronas GmbH, 2002                                |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/MixUtils.pm,v 1.7 2003/02/20 15:07:13 wig Exp $                                                         |
# +-----------------------------------------------------------------------+
#
# + A lot of the functions here are taken from mway_1.0/lib/perl/Banner.pm +
#

# +-----------------------------------------------------------------------+
# |
# | Changes:
# | $Log: MixUtils.pm,v $
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
	init_ole
	open_input
	db2array
	write_excel
        );
# @Micronas::MixUtils::EXPORT_OK=qw(
@EXPORT_OK = qw(
                %EH
		$ex
	     );

our $VERSION = '0.01';

use strict;
use File::Basename;
use Getopt::Long qw(GetOptions);

# Caveat: relies on proper setting of base, pgmpath and dir in main program!
use lib "$main::base/";
use lib "$main::base/lib/perl";
use lib "$main::pgmpath/";
use lib "$main::pgmpath/lib/perl";
use lib "$main::dir/lib/perl";
use lib "$main::dir/../lib/perl";
#TODO: Which "use lib path" if $0 was found in PATH?
# use lib 'h:\work\x2v\lib\perl'; ##TODO: Rewrite that to a generic place ....

use Cwd;
use Log::Agent;
use Log::Agent::Priorities qw(:LEVELS);

use Storable;

#
# Prototypes
#
sub select_variant ($);

##############################################################
# Global variables
##############################################################

use vars qw(
    %OPTVAL %EH %MACVAL $ex
);

sub mix_getopt_header(@)
{
    my $no_exit  = @_ && ($_[0] eq '-NO_EXIT') && shift;
    my @appopts  = @_;          # Application options

    # Get the options and macros
    unless (mix_getopt(@appopts)) {
        mix_usage();
        exit 1;
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
    # if (defined $MACVAL{'M_IGNORE_ERRORS'}) {
    #     $EH{'ERROR'} = $EH{'error_no_exit'}; # hidden emergency switch
    # }
    if (defined $OPTVAL{'out'}) {
	$EH{'out'} = $OPTVAL{'out'};
    } elsif ( exists( $ARGV[$#ARGV] ) )  {
	# Output file will be written to current directory.
	# Name will become name of last input file foo-mixed.ext
	$EH{'out'} = $ARGV[$#ARGV] ;
	$EH{'out'} =~ s,(\.[^.]+)$,-mixed$1,;
    } else {
	$EH{'out'} = "";
    }

    if (defined $OPTVAL{'int'}) {
	$EH{'dump'} = $OPTVAL{'int'};
    } else {
	# Is there a *-mixed file in the current directory ?
	#TODO:
	$EH{'dump'} = "NO_DUMP_FILE_DEFINED";
    }

    # Specify top cell on command line or use TESTBENCH as default
    if (defined $OPTVAL{'top'} ) {
	$EH{'top'} = $OPTVAL{'top'};
    } else {
	$EH{'top'} = 'TESTBENCH';
    }

    # Specify variant to be selected in hierachy sheet(s)
    # Default or empty cell will be selected always.
    if (defined $OPTVAL{'variant'} ) {
	$EH{'variant'} = $OPTVAL{'variant'};
    } else {
	$EH{'variant'} = 'Default';
    }

    # Write entities into file
    if (defined $OPTVAL{'outenty'} ) {
	$EH{'outenty'} = $OPTVAL{'outenty'};
    } elsif ( exists( $ARGV[$#ARGV] ) )  {
	# Output file will be written to current directory.
	# Name will become name of last input file foo-mixed.ext
	$EH{'outenty'} = $ARGV[$#ARGV] ;
	$EH{'outenty'} =~ s,(\.[^.]+)$,-e.vhd,;
    } else {
	$EH{'outenty'} = "mix-e.vhd";
    }

    # Write architecture into file
    if (defined $OPTVAL{'outarch'} ) {
	$EH{'outarch'} = $OPTVAL{'outarch'};
    } elsif ( exists( $ARGV[$#ARGV] ) )  {
	# Output file will be written to current directory.
	# Name will become name of last input file foo-mixed.ext
	$EH{'outarch'} = $ARGV[$#ARGV] ;
	$EH{'outarch'} =~ s,(\.[^.]+)$,-a.vhd,;
    } else {
	$EH{'outarch'} = "mix-a.vhd";
    }

   # Write configuration into file
    if (defined $OPTVAL{'outconf'} ) {
	$EH{'outconf'} = $OPTVAL{'outconf'};
    } elsif ( exists( $ARGV[$#ARGV] ) )  {
	# Output file will be written to current directory.
	# Name will become name of last input file foo-mixed.ext
	$EH{'outconf'} = $ARGV[$#ARGV] ;
	$EH{'outconf'} =~ s,(\.[^.]+)$,-c.vhd,;
    } else {
	$EH{'outconf'} = "mix-c.vhd";
    }

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

Print the SYNOPSIS section of the script's POD documentation.

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

    select(STDOUT);
    $| = 1;                     # unbuffer STDOUT

    print <<"EOF";
#######################################################################
##### $NAME (Revision $VERSION)
#####
##### $FLOW $FLOW_VERSION
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
# Initialize environement, variables, configurations ...
#
##############################################################################

=head2 mix_init()

Initialize the %EH variable with all the configuration we have/need

  %EH = ( ..... );

No input arguments (today).

=cut

sub mix_init () {

$ex = undef; # Container for OLE server

%EH = (
    'template' => {
	'vhdl' =>{
	    # Actual values are set in MixWriter
	    'conf' => { 'head' => "## VHDL Configuration Template String t.b.d.", },
	    'arch' => { 'head' => "## VHDL Architecture Template String t.b.d.", },
	    'enty' => { 'head' => "## VHDL Entity Template String t.b.d.", },
	},
	'verilog' =>{
	    'wrap' => "Verilog Wrapper Template String",
	    'file' => "Verilog File Template String",
	},
    },
    'output' => {
	'path' => ".",		# Path to store backend data
	'order' => 'input',		# Field order := as in input or predefined
	'format' => 'ext',		# Output format derived from filename extension ???
	'generate' =>
	    { 'arch' => 'noleaf',
	      'enty' => 'leaf',
	      'conf' => 'leaf',
	    },	
    },
    'intermediate' => {
	'path' => ".",
	'order' => 'input',		# Field order := as in input or predefined
	'format' => "perl", # Intermediate format := perl|xls|csv|xml ...
    },
    'postfix' => {
	    qw(
		    POSTFIX_PORT_OUT	_o
		    POSTFIX_PORT_IN	_i
		    POSTFIX_PORT_IO	_io
		    PREFIX_PORT_GEN	p_mix_
		    POSTFIX_GENERIC	_g
		    POSTFIX_SIGNAL	_s
		    POSTFIX_CONSTANT	_c
		    POSTFIX_PARAMETER	_p
		    PREFIX_INSTANCE	i_
		    POSTFIX_ARCH	%EMPTY%
		    POSTFILE_ARCH	-a
		    POSTFIX_ENTY	%EMPTY%
		    POSTFILE_ENTY	-e
		    POSTFIX_CONF	%EMPTY%
		    POSTFILE_CONF	-c
		    PREFIX_CONST	mix_const_
		    PREFIX_GENERIC	mix_generic_
		    PREFIX_PARAMETER	mix_parameter_
	    )
	    # POSTFIX_ARCH _struct-a
	    # POSTFIX_ENTY _struct-e
	    # POSTFIX_CONF _struct-c
    },
    'pad' => {
	qw(
	    PAD_DEFAULT_DO	0
	    PAD_ACTIVE_EN	 	1
	    PAD_ACTIVE_PU	 	1
	    PAD_ACTIVE_PD	 	1
	)
    },
    # Definitions regarding the CONN sheets:    
    'conn' => { 
	'xls' => 'CONN',
	'field' => {
	    #Name   	=>		Inherits
	    #						Multiple
	    #							Required: 0 = no, 1=yes, 2= init to ""
	    #								Defaultvalue
	    #									PresetOrder
	    #                                  0      1      2	3       4
	    '::ign' 		=> [ qw(	0	0	1	%NULL% 	1 ) ],
	    '::gen'		=> [ qw(	0	0	1	%NULL% 	2 ) ],
	    '::bundle'	=> [ qw(	1	0	1	WARNING_NOT_SET	3 ) ],
	    '::class'		=> [ qw(	1	0	1	WARNING_NOT_SET	4 )],
	    '::clock'		=> [ qw(	1	0	1	WARNING_NOT_SET	5 )],
	    '::type'		=> [ qw(	1	0	1	%SIGNAL%	6 )],
	    '::high'		=> [ qw(	1	0	0	%NULL% 	7 )],
	    '::low'		=> [ qw(	1	0	0	%NULL% 	8 )],
	    '::mode'		=> [ qw(	1	0	1	%DEFAULT_MODE%	9 )],
	    '::name'		=> [ qw(	0	0	1	ERROR_NO_NAME	10 )],
	    '::shortname'	=> [ qw(	0	0	0	%EMPTY% 	11 )],
	    '::out'		=> [ qw(	1	0	0	%SPACE% 	12 )],
	    '::in'		=> [ qw(	1	0	0	%NULL% 	13 )],
	    '::descr'		=> [ qw(	1	0	0	%NULL% 	14 )],
	    '::comment'	=> [ qw(	1	1	2	%EMPTY% 	15 )],
	    '::default'	=> [ qw(	1	1	0	%NULL% 	0 )],
	    "::debug"	=> [ qw(	1	0	0	%NULL%	0 )],
	    '::skip'		=> [ qw(	0	1	0	%NULL% 	0 )],
	    'nr'		=> 16, # Number of next field to print
	},
    },
    'hier' => {
        'xls' => 'HIER',
	'field' => {
	    #Name   	=>		Inherits
	    #						Multiple
	    #							Required
	    #								Defaultvalue
	    #									PrintOrder
	    #                                  0      1       2	3       4
	    '::ign' 		=> [ qw(	0	0	1	%NULL% 	1 ) ],
	    '::gen'		=> [ qw(	0	0	1	%NULL% 	2 ) ],		
	    '::variants'	=> [ qw(	1	0	0	Default	3 )],
	    '::parent'	=> [ qw(	1	0	1	W_NO_PARENT	4 )],
	    '::inst'		=> [ qw(	0	0	1	W_NO_INST	5 )],
	    '::lang'		=> [ qw(	1	0	0	VHDL	7 )],
	    '::entity'		=> [ qw(	1	0	1	W_NO_ENTITY	8 )],
	    '::arch'		=> [ qw(	1	0	0	RTL			9 )],
	    "::config"	=> [ qw(	1	0	1	W_NO_CONFIG	10 )],
	    "::comment"	=> [ qw(	1	0	2	%EMPTY%	11 )],
	    "::shortname"	=> [ qw(	0	0	0	%EMPTY%	6 )],
	    "::default"	=> [ qw(	1	1	0	%NULL%	0 )],
	    "::hierachy"	=> [ qw(	1	0	0	%NULL%	0 )],
	    "::debug"	=> [ qw(	1	0	0	%NULL%	0 )],
	    '::skip'		=> [ qw(	0	1	0	%NULL% 	0 )],
	    'nr'		=> 12,  # Number of next field to print
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
	'field' => {
	    #Name   	=>		Inherits
	    #						Multiple
	    #							Required
	    #								Defaultvalue
	    #									PrintOrder
	    #                                  0      1       2	3       4
	    '::ign' 		=> [ qw(	0	0	1	%NULL% 	1 ) ],
	    '::type'		=> [ qw(	0	0	1	%TBD%	2 ) ],	
	    '::variants'	=> [ qw(	1	0	0	Default	3 )],
	    '::inst'		=> [ qw(	0	0	1	W_NO_INST	4 )],
	    "::comment"	=> [ qw(	1	0	2	%EMPTY%	6 )],
	    "::shortname"	=> [ qw(	0	0	0	%EMPTY%	5 )],
	    "::b"		=> [ qw(	0	1	1	%NULL%	7 )],
	    "::default"	=> [ qw(	1	1	0	%NULL%	0 )],
	    "::hierachy"	=> [ qw(	1	0	0	%NULL%	0 )],
	    "::debug"	=> [ qw(	1	0	0	%NULL%	0 )],
	    '::skip'		=> [ qw(	0	1	0	%NULL% 	0 )],
	    'nr'		=> 12,  # Number of next field to print
	},
    }, 
    "macro" => {
	    "%SPACE%" 	=> " ",
	    "%EMPTY%"	=> "",
	    "%NULL%"	=> "0",
	    "%TAB%"	=> "\t",
	    "%IOCR%"	=> "\n",
	    "%SIGNAL%"	=> "std_ulogic",
	    "%BUS_TYPE"	=> "std_ulogic_vector",
	    "%DEFAULT_MODE%" => "S",
	    "%OPEN%"	=> "__OPEN__",			#open signal
	    "%UNDEF%"	=> "ERROR_UNDEF",	#should be 'undef',  #For debugging??  
	    "%UNDEF_1%"	=> "ERROR_UNDEF_1",	#should be 'undef',  #For debugging??
	    "%UNDEF_2%"	=> "ERROR_UNDEF_2",	#should be 'undef',  #For debugging??
	    "%UNDEF_3%"	=> "ERROR_UNDEF_3",	#should be 'undef',  #For debugging??
	    "%UNDEF_4%"	=> "ERROR_UNDEF_4",	#should be 'undef',  #For debugging??
	    "%TBD%"	=> "W_TO_BE_DEFINED",
	    "%HIGH%"	=> lc("MIX_LOGIC1"),  # VHDL does not like leading/trailing __
	    "%LOW%"	=> lc("MIX_LOGIC0"),  # dito.
	    "%HIGH_BUS%"	=> lc("MIX_LOGIC1_BUS"), # dito.
	    "%LOW_BUS%"	=> lc("MIX_LOGIC0_BUS"), # dito.
	    "%CONST%"		=> "__CONST__", # Meta instance, used to apply constant values
	    "%TOP%"		=> "__TOP__", # Meta instance, TOP cell
	    "%PARAMETER%"	=> "__PARAMETER__",	# Meta instance: stores paramter
	    "%GENERIC%"		=> "__GENERIC__", # Meta instance, stores generic default
	    "%BUFFER%"		=> "buffer",
	    '%H%'		=> '$',			# RCS keyword saver ...
    },
    "ERROR" => "__ERROR__",
    "WARN" => "__WARNING__",
    "CONST_NR" => 0,
    "GENERIC_NR" => 0,

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

#TODO: collect more EH{'macro'} from other modules
#
# Look into MixWriter.pm for EH templates for writer/backend
#

}

####################################################################
## ??? BEGIN function
## initialise OLE
####################################################################

=head2

init_ole () {

Start OLE server (to read ExCEL spread sheets in our case)
Returns a OLE handle or undef if that fails.

=cut

sub init_ole () {

# Start Excel/OLE Server, do it in eval ....
  unless ( eval "use Win32::OLE;" ) {  
	eval {
	  use Win32::OLE qw(in valof with);
          use Win32::OLE::Const 'Microsoft Excel';
          use Win32::OLE::NLS qw(:DEFAULT :LANG :SUBLANG);
          my $lgid = MAKELANGID(LANG_ENGLISH, SUBLANG_DEFAULT);
          $Win32::OLE::LCID = MAKELCID($lgid);
          $Win32::OLE::Warn = 3;

# 527d535
# usefull statements from the OLE tutorial ..
# < # 	  my $Excel = Win32::OLE->GetActiveObject('Excel.Application')
# < #       || Win32::OLE->new('Excel.Application', 'Quit');
# < 
#$Excel->{DisplayAlerts}=0; #Turn off popups ...
 
          unless( $ex=Win32::OLE->GetActiveObject('Excel.Application') ) {
	    # Try to start a new OLE server:
		unless ( $ex=Win32::OLE->new('Excel.Application', sub {$_[0]->Quit;}) ) {
		    return undef; # Did not work :-(
		}
          }
          return $ex;  # Return OLE ExCEL object ....
	}
    } else {
    logdie "Error: Cannot fire up OLE server: $!\n";
    return undef;
  }
}

####################################################################
## init_open
## open all input files and read in the worksheets needed
## do basic checks and conversion 
####################################################################

=head2

open_input (@) {

Open all input files and read in their CONN and HIER sheets
Returns two arrays with hashes ...

=cut

sub open_input (@) {
    my @in = @_;

    my $aconn = [];
    my $ahier = [];
    
    for my $i ( @in ) {
	unless ( -r $i ) {
	    logwarn("Cannot read input file $i");
	    next;
	}
	# For ExCEL we need to provide absolute pathes!!
	#TODO: Read CONN* ... (several CONN sheets per workbook)
	my $sheet = open_excel( $i, $EH{'conn'}{'xls'} );
	my @conn = convert_in( "conn", $sheet );

	$sheet = open_excel( $i, $EH{'hier'}{'xls'} );
	my @hier = convert_in( "hier", $sheet );

	#
	# Remove all lines not selected by our variant
	#
	select_variant( \@hier );
	
	push( @$aconn, @conn );	# Append
	push( @$ahier,   @hier );	# Append
    }

    return( $aconn, $ahier );

}

####################################################################
## select_variant
## remove all lines that have ::variant not matching the selected variant
####################################################################

=head2

select_variant ($) {

Remove all lines not matching the selected variant. Variant defaults to <S default>.

=cut

sub select_variant ($) {
    my $r_data = shift;

    unless ( defined $r_data ) {
	    logdie("select_variant called with bad argument!");
    }

    for my $i ( 0..$#$r_data ) {
	if ( exists( $r_data->[$i]{'::variants'} ) ) {
	    my $var = $r_data->[$i]{'::variants'};	    
	    if ( defined( $var ) and $var !~ m/^\s*$/o and $var !~ m/^default/io ) {
		$var =~ s/[ \t]+/|/g;
		$var = "(" . $var . ")";
		if ( $EH{'variant'} !~ m/$var/ ) {
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
	    logdie("convert_in called with bad arguments!");
    }

    # my $reh = \$EH{$kind}; # field definitions ...
    
    my @d = ();
    my @order = ();  # Field number to name
    my %order = ();  # Field name to number
    my $hflag = 0;
    my $required = $EH{$kind}{'field'}; # Shortcut into EH->fields

    for my $i ( 0..$#{$r_data} ) { # Read each row
	my @r = @{$r_data->[$i]};
	@r = map { defined( $_ ) ? $_ : "" } @r ;		#Fill up undefined fields??
	my $all = join( '', @r );
	next if ( $all =~ m/^\s*$/o ); 			#If a line is complete empty, skip it
	next if ( $all =~ m,^\s*(#|//), );			#If line starts with comment, skip it

	unless ( $hflag ) { # We are still looking for our ::MARKER header line
	    next unless ( $all =~ m/^::/ );			#Still no header ...
	    %order = parse_header( $kind, \$EH{$kind}, @r );		#Check header, return field number to name
	    # foreach my $ii ( 0..$#order ) {
	    # $d[0]{$order[$ii]} = $order[$ii];
	    # $order{$order[$ii]} = $ii;
	    # $reh->{'input'}{$order[$ii]} = $ii; 	# Remember all input fields, needed??? 
	    # }
	    $hflag = 1;
	    next;
	}
	# Skip ::ign marked with # or // comments, again ...
	next if ( defined( $order{'::ign'}) and $r[$order{'::ign'}] =~ m,^(#|//), );

	# Copy rest to an 'another' array ....
	my $n = $#d + 1;
	foreach my $ii ( keys( %order ) ) {
	    if ( defined( $r[$order{$ii}] ) ) {
		$d[$n]{$ii} = $r[$order{$ii}];
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
	logdie "ERROR: parse header started with missing arguments!\n";
    }
    my %rowh = ();
    for my $i ( 0..$#row ) {
	unless ( $row[$i] )  {
	    logwarn("empty header in column $i, skip");
	    push( @{$rowh{"::skip"}}, $i);
	    $row[$i] = "::skip";
	    next;
	}
	if ( $row[$i] and $row[$i] !~ m/^::/o ) { #Header not starting with ::
	    logwarn("bad name in header row: $row[$i] $i");
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
		    logwarn("multiple input header not allowed for $i!");
		    # exit;
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
	    $$templ->{'field'}{$head} = $$templ->{'field'}{'::default'}; #Check: does this really copy everything
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

    #
    # Finally, got the field name list ... return now
    #
    return %or;
}
		
####################################################################
## open_excel
## open excel file and get contents
####################################################################

=head2

open_excel ($$) {

Open a excel file, select the appropriate worksheets and return

Arguments: $filename, $sheet

=cut
sub open_excel($$){
    my ($file, $sheetname)=@_;

    my $openflag = 0;
    
    #old: logdie "Cannot use Excel OLE interface!" unless($use_csv);
    $ex->{DisplayAlerts}=0;

    unless( $file =~ m/\.xls$/ ) {
	$file .= ".xls";
    }
    unless( -r $file ) {
      logwarn( "cannot read $file in open_excel!" );
      return undef;
    }

    $file = path_excel( $file );
    my $basename = $file;
    $basename =~ s,.*[/\\],,; #Strip off / and \ 

    my $book;    
    #TODO: unless( $ex->Workbook-> ...) if already open ....
    # If it exists, it could be open, too?
    foreach my $bk ( in $ex->{Workbooks} ) {
	if ( $bk->{'Name'} eq $basename ) {
	    $openflag = 1;
	    $bk->Activate;
	    $book = $bk;
	    last;
	    # Already open ...
	    # Warning: Path might be different!
	}
    }

    unless ( $openflag ) {
        $book = $ex->Workbooks->Open({FileName=>$file, ReadOnly=>1});
    } # else {
    #    $book = $ex->Workbook->Activate($file);
    # }
    #old my $book  =$ex->Workbooks->Open({FileName=>$file, ReadOnly=>1}); 

#  my $book  =$ex->Workbooks->Open(
#				  $file.".xls",   # filename
#				  0,              # update links
#				  FALSE,          # readonly
#				  undef,          # format
#				  undef,          # password
#				  undef,          # writeResPassword
#				  TRUE,           # ingnoreReadOnlyRecommennded
#				  undef,          # origin
#				  FALSE,          # delimiter
#				  FALSE,          # editable
#				  FALSE           # notify
#				 );
#  my $sheet =$book->Worksheets($sheetnumber);

    #TODO: use regular expression to match sheet names (would allow several
    # to be opened, but that creates another load of problems (columns might not be matching!)
    my $flag = 0;
    foreach my $sh ( in $book->{Worksheets} ) {
	if ( $sh->{'Name'} eq $sheetname ) {
		$flag = 1;
		last;
        }
    }
    unless( $flag ) { logwarn("Cannot locate a worksheet $sheetname in $file");
	    return undef;
    }
    
    $ex->ActiveWorkbook->Sheets($sheetname)->Activate;
    my $sheet =$book->ActiveSheet;
    my $row=$sheet->UsedRange->{Value};

    unless( $openflag ) {
	$book->Close or logdie "Cannot close $file spreadsheet";
    }
    #TODO: Keep open until all opes are done (avoid reopening ...)

    return($row);

}	

####################################################################
## path_excel
## convert "normal" filename to absolute path, usable for OLE server
####################################################################

=head2

path_excel ($) {

Take input file name with/out path name and convert it to absolute path
Replace all / (I prefer to use) by  \ (ExCEL needs)

Arguments: $filename

=cut
sub path_excel ($) {
    my $file = shift;
    #
    # Make filename a absolute one (we are on MS ground)
    # Has to start like
    # 	N:\bla\blubber or N:/path/....
    if ( $file =~ m,^[\\/], ) {
    # Missing the letter for a drive
        $file = $EH{'drive'} . $file;
    } elsif ( $file !~ m,^\w:, ) {
	$file = $EH{'cwd'} . "/" . $file;
    }
 
    #
    # Convert / to \ :-(, otherwise OLE will get confused
    # As we will open Excel on MSWin only, there is no need to rethink that.
    $file =~ s,/,\\,go;

    return $file
}

####################################################################
## mix_store
## dump data (hash) on disk
####################################################################

=head2

mix_store ($%) {

Dump input data into a disk file

=cut
sub mix_store ($%){
    my $file = shift;
    my $r_data = shift;

    if ( -r $file ) {
	logwarn("file $file already exists! Will be overwritten!");
    }

    #TODO: would we want to use nstore instead ?
    unless( store( $r_data, $file ) ) {
	logdie("Cannot store date into $file: $!!\n");
	exit 1;
    }

    #
    # Use Data::Dumper while debugging ...
    #    output is man-readable ....
    if ( $OPTVAL{'adump'} ) {
	use Data::Dumper;
	$file .= "a";
	unless( open( DUMP, ">$file" ) ) {
	    logdie("Cannot open file $file for dumping: $!\n");
	}
	print( DUMP Dumper( $r_data ) );
	unless( close( DUMP ) ) {
	    logdie("Cannot close file $file: $!\n");
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
	    logwarn( "Dumped data does not have $i hash!" );
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

db2array ($$) {

convert the datastructure to a flat array

Arguments: $ref    := hash reference
		$type  := (hier|conn)

=cut
sub db2array ($$) {
    my $ref = shift;
    my $type = shift;
    
    unless( $ref ) { logwarn("called db2array without db argument!"); return }
    unless ( $type =~ m/^(hier|conn)/o ) {
	logwarn("bad db type $type, ne hier or conn!");
	return;
    }
    $type = $1;

    my @o = ();
    # Get order to print fields ...
    #TODO: check if fields do overlap!
    for my $ii ( keys( %{$EH{$type}{'field'}} ) ) {
	next unless ( $ii =~ m/^::/o );
	$o[$EH{$type}{'field'}{$ii}[4]] = $ii;
    }

    my @a = ();
    my $n = 0;

    # Print header
    for my $ii ( 1..$#o ) {
	$a[$n][$ii-1] = $o[$ii];
    }
    $n++;
    for my $i ( sort( keys( %$ref ) ) ) {
	for my $ii ( 1..$#o ) { # 0 contains fields to skip
	    if ( $o[$ii] =~ m/^::(in|out)\s*$/o ) {
		$a[$n][$ii-1] = inout2array( $ref->{$i}{$o[$ii]} );
	    } else {
		$a[$n][$ii-1] = defined( $ref->{$i}{$o[$ii]} ) ? $ref->{$i}{$o[$ii]} : "%UNDEF_1%";
		#TODO: do that in debugging mode, only
	    }
	}
    $n++;
    }
    #TODO: check if we have printed all potential fields
    
    return \@a;

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
sub inout2array ($) {
    my $f = shift;

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
#                   }
#                 ],    

    for my $i ( @$f ) {

	unless( defined( $i->{'inst'} ) ) {
	    # TODO: Print only if that indicates an real error ????
	    # logwarn( "Converting empty array slice, Skip!" );
	    next;
	}
	# Constants are working a different way:
	#: m,^\s*(__CONST__|%CONST%|__GENERIC__|__PARAMETER__|%GENERIC%|%PARAMETER%),o ) {

	if ( $i->{'inst'} =~
	    m,^\s*(__CONST__|%CONST%),o ) {
	    $s .= $i->{'port'} . ", %IOCR%";
	} elsif ( defined $i->{'sig_t'} ) {
	# inst/port($port_f:$port_t) = ($sig_f:$sig_t)
	    $s .= $i->{'inst'} . "/" . $i->{'port'} . "(" .
		    $i->{'port_f'} . ":" . $i->{'port_t'} . ") = (" .
		    $i->{'sig_f'} . ":" . $i->{'sig_t'} . "), %IOCR%"
	} else {
	    $s .= $i->{'inst'} . "/" . $i->{'port'} . ", %IOCR%";
	}
    }

    $s =~ s/,\s*%IOCR%\s*$//o;
    # parse_mac already done !!!
    $s =~ s,%IOCR%,$EH{'macro'}{'%IOCR%'},g;
    
    return $s;
}


####################################################################
## write_excel
## write intermediate data to excel sheet
####################################################################

=head2

write_excel ($$$) {

self explanatory

Arguments: $file   := filename
		$type  := sheetname (CONN|HIER)
		$ref_a := reference to array with data

=cut
sub write_excel ($$$) {
    my $file = shift;
    my $sheet = shift;
    my $r_a = shift;

    my $book;
    my $newflag = 0;
    my $openflag = 0;
    
    unless ( $file =~ m/\.xls$/ ) {
	$file .= ".xls";
    }

    my $efile = path_excel( $file );
    my $basename = $file;
    $basename =~ s,.*[/\\],,; #TODO: check if Name is basename of filename, always??
    
    if ( -r $file ) {
	logwarn("File $file already exists! Contents will be changed");

	# If it exists, it could be open, too?
	foreach my $bk ( in $ex->{Workbooks} ) {
	    if ( $bk->{'Name'} eq $basename ) {
		$openflag = 1;
		$bk->Activate;
		$book = $bk;
		last;
		# Already open ...
		# Warning: Path might be different!
	    }
	}
	
	#my $Sheet = $Book->Worksheets("Sheet1");
	#       $Sheet->Activate();       
	unless ( $openflag ) {
	    $book = $ex->Workbooks->Open($efile);
	} # else {
	#    $book = $ex->Workbook->Activate($efile);
	# }
	
	#
    	# rename $sheet to $sheet_O, $sheet_O will get deleted
	#
	foreach my $sh ( in $book->{Worksheets} ) {
	    if ( $sh->{'Name'} eq ( $sheet . "_O" ) ) {
		logwarn("Removing backup copies of sheet $sheet (_O)!");
		$sh->Delete;
		last;
	    }
	}	
	foreach my $sh ( in $book->{Worksheets} ) {
	    if ( $sh->{'Name'} eq $sheet ) {
		logwarn("Replacing sheet $sheet contents by new!");
		# $book->Worksheet->Delete($sheet);
		# XXXX $book->Worksheet->Delete($sheet . "_O");
		$sh->{'Name'} = $sheet . "_O";
		last;
	    }
	}
    } else {
	# Create new workbook
	$book = $ex->Workbooks->Add();
	$book->SaveAs($efile);
	$newflag=1;
    }

    #TODOs: Do not close file if it was already open!
    #Print out available sheets:
    #    foreach my $Sheet(in $Book->{Worksheets}){
    #  print "\t" .$Sheet->{Name} ."\n";
    #}
    # my $Book = $Excel->Workbooks->Add();
    #    $Book->SaveAs($excelfile); #Good habit when working with OLE, save often.
    

# my $Sheet = $Book->Worksheets(1);
# my $Range = $Sheet->Range("A2:C7");
# my $Chart = $Excel->Charts->Add;
#my $Sheet = $Book->Worksheets("Sheet1");
#       $Sheet->Activate();       
#       $Sheet->{Name} = "DidItInPerl";
    my $sheetr = undef;

    # Create output worksheet:
    $sheetr = $book->Worksheets->Add() || logwarn( "Cannot create worksheet $sheet in $file:$!");
    $sheetr->{'Name'} = $sheet;
    #old $sheetr = $book->Worksheets("$sheet");
    $sheetr->Activate();
# oder so:
#   $ex->ActiveWorkbook->Sheets($sheet)->Activate;
# oder so:
#    $sheetr = $book->ActiveSheet;
#
#	$sheetr =$book->ActiveSheet;
    $sheetr->Unprotect;
#        $sheetr->UsedRange->Delete;
#    } else {
#	    #TODO Add sheets ...
#    }


    my $x=$#{$r_a->[0]}+1;
    my $y=$#{$r_a}+1;
    my $c1=$sheetr->Cells(1,1)->Address;
    my $c2=$sheetr->Cells($y,$x)->Address;
    my $rng=$sheetr->Range($c1.":".$c2);
    $rng->{Value}=$r_a;
    #!wig: $rng->Columns->AutoFit;
    #!wig: $sheetr->Protect;
    #TODO: pretty formating
    #TODO: Print nice header (on a sheet ..)
    $book->Save;
    $book->Close unless ( $openflag ); #TODO: only close if not open before ....

}

# This module returns 1, as any good module does.
1;

#!End		    