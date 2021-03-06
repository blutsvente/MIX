# -*- perl -*--------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright 2002 Trident Microsystems (Europe) GmbH, Germany
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# | Project:    Micronas - MIX                                            |
# | Modules:    $RCSfile: MixUtils.pm,v $                                 |
# | Revision:   $Revision: 1.150 $                                        |
# | Author:     $Author: lutscher $                                            |
# | Date:       $Date: 2009/12/15 13:11:39 $                              |
# |                                                                       |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/MixUtils.pm,v 1.150 2009/12/15 13:11:39 lutscher Exp $ |
# +-----------------------------------------------------------------------+
#
# + Some of the functions here are taken from mway_1.0/lib/perl/Banner.pm +
#
# +-----------------------------------------------------------------------+
# |
# | Changes:
# | $Log: MixUtils.pm,v $
# | Revision 1.150  2009/12/15 13:11:39  lutscher
# | *** empty log message ***
# |
# | Revision 1.149  2009/12/14 10:58:17  lutscher
# | changed copyright
# |
# | Revision 1.148  2009/12/02 14:26:41  lutscher
# | removed a debug statement
# |
# | Revision 1.147  2009/11/24 15:44:57  lutscher
# | fixed a bug in _mix_utils_reorder
# |
# | Revision 1.146  2009/11/19 12:26:18  lutscher
# | added top-level sheet input and vi2c-xml view
# |
# | Revision 1.145  2008/12/10 11:51:27  lutscher
# | added code to strip %sheet-name from filename
# |
# | Revision 1.144  2008/04/24 16:57:56  lutscher
# | added xml to write_sum()
# |
# | Revision 1.143  2008/04/24 12:01:36  lutscher
# | added namespace to call of nstore function
# |
# | Revision 1.142  2007/11/15 13:07:01  wig
# | Improved HDL import:
# | 	- Handle parantheses in VHDL comments
# | 	- Extend intermdiate.order: row:(alpha|input),col:(alpha,input,template)
# |
# | Revision 1.141  2007/03/05 12:54:06  wig
# | Fixed split_flag bad preset in MixUtils::db2array
# |
# | Revision 1.140  2007/03/03 17:24:06  wig
# | Updated testcase for case matches. Added filename serialization.
# |
# | Revision 1.139  2007/03/01 16:28:37  wig
# | Implemented emulation mux insertion
# |
# | Revision 1.138  2006/11/21 16:51:10  wig
# | Improved generator execution (now in order!)
# |
# | Revision 1.137  2006/11/16 15:21:44  wig
# |  	MixUtils.pm : do not use import, but init()
# |
# | Revision 1.136  2006/11/15 09:54:28  wig
# | Added ImportVerilogInclude module: read defines and replace in input data.
# |
# | Revision 1.135  2006/11/14 16:49:00  wig
# | extended add_ports to handle `define ports!
# |
# | Revision 1.134  2006/11/09 11:12:35  wig
# | 	MixUtils.pm : speedup in replace_mac
# |
# | Revision 1.133  2006/11/02 15:37:48  wig
# |  	MixChecker.pm MixUtils.pm MixWriter.pm : added basic caching, improved performance
# |
# | Revision 1.132  2006/10/30 15:34:59  wig
# | extended handling of `define port/signal definitions
# |
# | Revision 1.131  2006/10/23 08:31:06  wig
# | Fixed problem with ::b ::b:1 output / missing ::b:1
# |
# | .....
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
    mix_get_eh
	mix_init
	mix_store
	mix_load
	mix_utils_open
	mix_utils_print
	mix_utils_printf
	mix_utils_close
	mix_list_econf
	is_absolute_path
	is_integer
	is_integer2
	replace_mac
	db2array
	db2array_intra
	write_sum
	convert_in
	select_variant
	two2one
	one2two
	mix_apply_conf
    mix_overload_sheet
    mix_use_on_demand
    );
# @Micronas::MixUtils::EXPORT_OK=qw(
@EXPORT_OK = qw(
	%OPTVAL
    $eh
    mix_utils_diff
    mix_utils_clean_data
);

our $VERSION = '0.01';

use strict;

use Cwd;
use File::Basename;
use File::Copy;
use DirHandle;
use IO::File;
use Getopt::Long qw(GetOptions);

use Log::Log4perl qw(get_logger);
# Directely access mix_utils_open_input
# use Micronas::MixUtils::IO qw();
use Micronas::MixUtils::InComments; # Some extra for comments in input data
use Micronas::MixUtils::Globals;
use Storable;

# use Data::Dumper; # Will be evaled if -adump option is on
# use Text::Diff;  # Will be eval'ed down there if -delta option is given!
# use Win32::OLE; # etc.# Will be eval'd down there if excel comes into play

#
# Prototypes
#
sub mix_get_eh			();
sub select_variant		($;$);
sub mix_list_conf		();
sub mix_list_econf		($);
sub mix_apply_conf		($$$);
# sub _mix_list_conf ($$;$);
sub mix_store			($$;$);
sub mix_utils_open		($;$);
sub mix_utils_print		($@);
sub mix_utils_printf	($@);
sub mix_utils_close		($$);
sub replace_mac			($$;$);
sub one2two				($);
sub two2one 			($);
sub is_absolute_path	($);
sub mix_utils_split_cell	($);
sub mix_utils_loc_templ	($$);
sub _mix_utils_loc_templ	($$);
sub mix_utils_loc_sum	();
sub mix_utils_open_diff	($;$);
sub mix_utils_diff		($$$$;$);
sub mix_utils_clean_data	($$;$);
#!wig20060712: changed interface!
sub db2array			($$$$;$$);
sub _filter_sheets		($$;$);
sub db2array_intra		($$$$$);
sub _mix_utils_im_header	($$$);
sub _inoutjoin			($);
sub _mix_utils_extract_verihead ($$$);
sub _init_logic_eh		($);
sub _init_loglimit_eh	($);
sub _sum_loglimit_eh	($);
sub mix_use_on_demand	($);
sub mix_is_integer		($);
sub mix_is_integer2		($$);
sub mix_utils_report_hdlfiles ();
sub _get_deltalist 		();
sub _sum_filediff		();
sub _sum_errdiff 		();
sub _mix_special_input	($);
sub _mix_utils_readcfg	($);

##############################################################
# Global variables
##############################################################

use vars qw(
    %OPTVAL %EH $eh %MACVAL
);

####################################################################
#
# Our local variables
my $logger = get_logger( 'MIX::MixUtils' );
#
# RCS Id, to be put into output templates
#
my $thisid		=	'$Id: MixUtils.pm,v 1.150 2009/12/15 13:11:39 lutscher Exp $';
my $thisrcsfile	        =	'$RCSfile: MixUtils.pm,v $';
my $thisrevision        =      '$Revision: 1.150 $';         #'

# Revision:   $Revision: 1.150 $   
$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,;

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
	#	CFG -> read in before doing anything else
	#
	if ( $OPTVAL{'cfg'} ) {
		_mix_utils_readcfg( 'CMDLINE' );
		# Redo that:
		post_configset( $eh );
	}

    #
    # CONF options set -> overload built-in configuration (needs to be first!!!!)
    #
    if ($OPTVAL{'conf'}) {
		mix_overload_conf( $OPTVAL{'conf'} );
    }

    # Evaluate options
    if ($OPTVAL{'quiet'}) {
        $eh->set( 'NOTE', $OPTVAL{'quiet'} ); # be quiet, suppress printing notes.
        $eh->set('PRINTTIMING', 0 );
    }
    if ($OPTVAL{'verbose'}) {
        $eh->set( 'VERBOSE', $OPTVAL{'verbose'} ); # be verbose, printing notes.
    }
    if (defined $OPTVAL{'debug'}) {
        $eh->set( 'DEBUG', $OPTVAL{'debug'} ); # printing debug notes.
        eval 'package main; use diagnostics;'; # enable perl diagnostics
    }

    #
    # Change output pathes for internal, intermediate and backend data
    # Create it if needed.
    #!wig20051005: Creation now done in IO.pm ....
    if ( defined $OPTVAL{'dir'} ) {
        $OPTVAL{'dir'} =~ s,\\,/,g if ( $eh->get('iswin') );
		$eh->set('output.path' , $OPTVAL{'dir'} );
		$eh->set('intermediate.path' , $OPTVAL{'dir'} );
		$eh->set('internal.path', $OPTVAL{'dir'} );
		$eh->set('report.path' ,$OPTVAL{'dir'} );
    }
    
    if (defined $OPTVAL{'out'}) {
        $OPTVAL{'out'} =~ s,\\,/,g if ( $eh->get('iswin') );
		$eh->set( 'out', $OPTVAL{'out'} );
    } elsif ( exists( $ARGV[$#ARGV] ) )  {
		# Output file will be written to current directory.
		# Name will become name of last input file foo-mixed.ext
		my $ext = $eh->get( 'output.ext.intermediate' );
		my $a = $ARGV[$#ARGV];
        $a =~ s/\%\w+$//; # strip optional sheet-name from filename
        $a =~ s,(\.[^.]+)$,-$ext$1,;
		$a = basename( $a );
		$eh->set( 'out', $a );
    } else {
		$eh->set( 'out', '' );
    }

    # Internal and intermediate data are written to:
    if (defined $OPTVAL{'int'}) {
        $OPTVAL{'int'} =~ s,\\,/,g if ($eh->get('iswin') );
		$eh->set('dump', $OPTVAL{'int'});
    } elsif ( exists( $ARGV[$#ARGV] ) )  {
		# Output file will be written to current directory.
		# Name will become name of last input file foo-mixed.ext
		my $d = $ARGV[$#ARGV];
        $d =~ s/\%\w+$//;     # strip optional sheet-name
		$d =~ s,\.([^.]+)$,,; # Strip away extension
		$d .= '.' . $eh->get( 'output.ext.internal' );
		$eh->set( 'dump', basename( $d )); # Strip off pathname
    } else {
		$eh->set( 'dump', 'mix.' . $eh->get( 'output.ext.internal' ) );
    }

    # Specify top cell on command line or use %TOP% as default
    if (defined $OPTVAL{'top'} ) {
		$eh->set( 'top', $OPTVAL{'top'} );
    } else {
		$eh->set( 'top', '%TOP%' );
    }

    # Specify variant to be selected in hierachy sheet(s)
    # Default or empty cell will be selected always.
    if (defined $OPTVAL{'variant'} ) {
		$eh->set( 'variant', $OPTVAL{'variant'} );
    }
    
    # remove old and diff sheets when set
    if (defined $OPTVAL{'strip'}) {
        $eh->set( 'intermediate.strip', $OPTVAL{'strip'} );
    } 

	for my $t ( qw( enty arch conf ) ) {
    # Write entities/architecture/configuration into file
    	if (defined $OPTVAL{'out' . $t} ) {
			$eh->set( 'out' . $t, $OPTVAL{'out' . $t} );
    	} elsif ( defined( $eh->get('out' . $t) ) ) {
			# outxxxx defined by -conf or config file, do not change
    	} elsif ( exists( $ARGV[$#ARGV] ) )  {
			# Output file will be written to current directory.
			# Name will become name of last input file foo-e.vhd 
			my $e = $ARGV[$#ARGV];
            $e =~ s/\%\w+$//;     # strip optional sheet-name
			$e =~ s,(\.[^.]+)$,,; # Remove extension
			$eh->set( 'out' . $t, basename( $e .
								$eh->get( 'postfix.POSTFILE_' . uc( $t) ) .
								'.' . $eh->get( 'output.ext.vhdl' ) ) );
    	} else {
			$eh->set( 'outenty', 'mix' . 
								$eh->get( 'postfix.POSTFILE_' . uc( $t ) ) .
								'.' . $eh->get( 'output.ext.vhdl' ) );
    	}
	}

    # Compare entities in this PATH[es]...
    #!wig20040217
    if ( defined $OPTVAL{'verifyentity'} ) {
        $eh->set( 'check.hdlout.path', join( ":", @{$OPTVAL{'verifyentity'}} ));
    }
    if ( $eh->get( 'check.hdlout.path' ) ) {
        # check if PATH[:PATH] is readable, get all *.vhd[l] files
        for my $p ( split( ':', $eh->get( 'check.hdlout.path' ) ) ) {
            # If on mswin: change \ to /
            ( $p =~ s,\\,/,g ) if ( $eh->get('iswin') );
            unless ( -d $p ) {
            	$logger->warn( "__W_VERIFY_PATH", "\tCannot search through entity verify path $p, skipped!" );
            } else {
                $eh->set( 'check.hdlout.__path__.' . $p, '' );
                # Will get a list of matching file names later on ...
            }
        }
    }
    
    # verify mode: which objects are verified? which strategy?
    if ( defined $OPTVAL{'verifyentitymode'} ) {
        $eh->set( 'check.hdlout.mode', $OPTVAL{'verifyentitymode'} );
    }

    #
    # -combine option -> overwrite outarch/outenty/outconf ...
    #
    if ( defined $OPTVAL{'combine'} ) {
		$eh->set( 'output.generate.combine' ,$OPTVAL{'combine'} );
    }
    if ( $eh->get( 'output.generate.combine' ) ) {
    	# Overload outxxx if combine is active
		$eh->set( 'outenty', 'COMB' );
		$eh->set( 'outarch', 'COMB' );
		$eh->set( 'outconf', 'COMB' );
    }

    #
    # SHEET selector -> overload built-in configuration
    #
    if ($OPTVAL{'sheet'}) {
		mix_overload_sheet( $OPTVAL{'sheet'} );
    }


    #
    # -listconf
    # Dump $eh ... and stop
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
			$eh->set( 'output.generate.delta', 1 );
	    	$eh->set( 'report.delta', 1 );
		} else { # Switch off delta mode
	    	$eh->set( 'output.generate.delta' , 0 );
	    	$eh->set( 'report.delta', 0 );
		}
    } else {
		if ( $eh->get( 'output.generate.delta' ) ) { # Delta on by -conf or FILE.cfg
	    	$eh->set( 'output.generate.delta', 1 );
	    	$OPTVAL{delta} = 1;
		} else {
	    	$eh->set( 'output.generate.delta', 0 );
		}
    }
    if ( $eh->get( 'output.generate.delta' ) or
    	 $eh->get( 'check.hdlout.path' ) or
    	 $eh->get( 'report.delta' ) ) {
	# Eval use Text::Diff
		unless( mix_use_on_demand( 'use Text::Diff;' ) ) {
			$logger->fatal( "__F_USE_TEXT_DIFF",
					"\tCannot load Text::Diff module for -conf *delta* mode: $@" );
			exit(1);
	    }

    }

	# Preload list of files if in delta mode:
	# Either use list of hdl files (as defined by output.generate.deltadesc) or read
	#   filelist "mixfiles.delta"
	#   file=foo.list
    if ( $eh->get( 'output.generate.delta' ) ) {
    	_get_deltalist();
    }

    #
    # -bak
    # Shift previously generated files to FILE.V.bak
    # Backup mode can be enabled by -bak switch of by configuration variable
    # like -conf output.generate.bak=1 or enabled in mix.cfg file
    #
    if ( exists( $OPTVAL{bak} ) ) { # -bak |-nobak
		if ( $OPTVAL{bak} ) {
	    	$eh->set( 'output.generate.bak', 1 );
		} else { # Switch off backup mode
	    	$eh->set( 'output.generate.bak', 0 );
		}
    } else {
		if ( $eh->get( 'output.generate.bak' ) ) { # Backup on by -conf or FILE.cfg
	    	$eh->set( 'output.generate.bak', 1 );
	    	$OPTVAL{bak} = 1;
		} else {
	    	$eh->set( 'output.generate.bak', 0 );
		}
    }

    # Print banner
    if ($OPTVAL{help}) {
        if (defined($OPTVAL{verbose})) {
            mix_banner();
        }
        mix_help();
        if ( not $no_exit ) {
             exit(0);
         }
    } elsif ( not defined($OPTVAL{quiet}) and not defined($OPTVAL{nobanner})) {
        mix_banner();
    }

    #
    # Create a starting point ...
    #
    if ( $OPTVAL{init} ) {
		mix_utils_init_file('init');
    }
    #
    # Import some HDL files
    #
    if ( $OPTVAL{import} ) {
		mix_utils_init_file('import');
    }

	#
	# Read in verilog defines
	# -vinc foo -vinc bar ...
	if ($OPTVAL{'vinc'} ) {
		$eh->set( 'import.vinc', $OPTVAL{'vinc'} );
	}
	mix_read_vinc( $eh->get( 'import.vinc') );
	
	# Redo some configs: delete unneeded log limit values:
	_init_loglimit_eh($eh);
	
}

sub mix_read_vinc ($) {
	my $optref = shift;
	
	return unless $optref;
	# Create a verilog include container and store it in the globals:
	unless ( mix_use_on_demand( 'use Micronas::MixUtils::ImportVerilogInclude;' ) ) {
            $logger->error('__E_USE_IMPORTVERIINC',
            	"\tCannot load Micronas::MixUtils::ImportVerilogInclude module: $@");
            return;
	}
	
	my $vinc = new Micronas::MixUtils::ImportVerilogInclude;
	$vinc->init( $optref );
	
	# Store for later usage ...
	$eh->set( 'import._vincref', $vinc );
	
} # End of mix_read_vinc

#
# Read in list of files, which later is used to compare against the list of created
# files
#!wig20060523    
sub _get_deltalist () {
    my $filedesc = $eh->get( 'output.generate.deltadesc' );
    my $outdir   = $eh->get( 'output.path' );
    # Read in file list from file:
    if ( $filedesc =~ m/file=(.+)/ ) {
    	# Read in filelist
    	my $filelist = $1;
    	my $f = ( $filelist =~ m,^/, ) ? $filelist : ( $outdir . '/' . $filelist );
    	if ( -r $f ) {
    		my $fh = new FileHandle;
    		if ( open( $fh, "< $f" ) ) {
    			my @list = grep( !/^\s*#/, <$fh> );
    			# Remove leading/trailing whitespace
    			chomp @list;
    			map( { s/^\s+//; s/\s+$//; } @list );
    			$fh->close();
    			$eh->set( 'output.generate.deltafiles', \@list );
    		} else {
    			$logger->error( "__E_READ_DELTAFILELIST", "Cannot open $f: $!" );
    		}
    	} else {
    		$logger->error( "__E_MISSING_DELTAFILELIST", "No such file: $f" );
    	}
    } elsif ( $filedesc =~ m/(glob=)(.+)/ ) {
    	# Glob (shell like expression)
    	my @list = ();  
    } elsif ( $filedesc =~ m/(re=)?(.+)/ ) {
    	my $dirre = $2;
    	# Apply regular expression to all files in output directory
    	my $dirlist = new DirHandle "$outdir";
    	if ( defined $dirlist ) {
    		my @list = ();
    		while( defined( $_ = $dirlist->read() )) {
    			next if ( $_ eq '.' or $_ eq '..' );
    			next if ( -d ( $outdir . '/' . $_ ) );
    			if ( $_ =~ m/^$dirre$/ ) {
    				push( @list, $_ );
    			}
    		}
    		$dirlist->close();
    		$eh->set( 'output.generate.deltafiles', \@list );
    	} else {
    		$logger->error( '__E_OPENOUTDIR', "Cannot open $outdir: $!" );
    	}
    }
} # End of _get_deltalist
    	
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
    # TODO MSWin32 -> we do not have nroff here :-(
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
    $eh->set('PRINTTIMING') = 0;
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
    if ($_[0] || not defined ( $eh->get('PRINTTIMING') ) ) {
        $eh->set('PRINTTIMING', 1 );
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
    $MOD_VERSION .= ( "\n#####   MixReport " . $Micronas::MixReport::VERSION )
		if ( defined( $Micronas::MixReport::VERSION ) );
    $MOD_VERSION .= ( "\n#####   Reg " . $Micronas::Reg::VERSION )
		if ( defined( $Micronas::Reg::VERSION ) );
    # TODO add plugin interface, plugin should register it's version here ...


    select(STDOUT);
    $| = 1;                     # unbuffer STDOUT

#     print <<"EOF";
# #######################################################################
# ##### $NAME ($VERSION)
# #####
# ##### $FLOW $FLOW_VERSION $MOD_VERSION
# ##### Copyright 2002-2009 Trident Microsystems (Europe) GmbH, Germany
# ##### This program comes with ABSOLUTELY NO WARRANTY.
# ##### This is free software, and you are welcome to redistribute it
# ##### under certain conditions.
# #######################################################################
# EOF

	# Store the header the log file, too:
	$logger->info(
"
#######################################################################
##### $NAME ($VERSION)
#####
##### $FLOW $FLOW_VERSION $MOD_VERSION
##### Copyright 2002-2009 Trident Microsystems (Europe) GmbH, Germany
##### This program comes with ABSOLUTELY NO WARRANTY.
##### This is free software, and you are welcome to redistribute it
##### under certain conditions.
#######################################################################" );

    if ( $eh->get('PRINTTIMING' ) ) {
        # print "NOTE ($NAME): Execution started " . localtime() . "\n\n";
        $logger->info( "__I_TIME_START", "\t($NAME): Execution started " . localtime() );
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
    my $foot = "MIX Release ".($::VERSION || "");

    #$ENV{PATH} = dirname($^X) . ":$ENV{PATH}";
    $ENV{PATH} = dirname(dirname(dirname($^X))) . "/bin:$ENV{PATH}";
    # TODO Win32 ??
    my $cmd = "";
    if ( $^O =~ m,mswin,io ) {
	# $cmd = "pod2text --center '$head' --release '$foot' --lax $0 |";
		$cmd = "pod2text $0";
    } else {
		$cmd = "pod2man --center '$head' --release '$foot' --lax $0 | nroff -man";
    }	
    my $help = `$cmd`;

    $logger->error("__E_CMD_FAILED", "\t'$cmd' failed.") if $?;

    # Save one head and foot line
    my $headline = '';
    if ( $help =~ /([^\n]*$head[^\n]*\n)/ ) {
    	$headline = $1;
    };
    my $footline = '';
    if( $help =~ /([^\n]*$foot[^\n]*\n)/ ) {
    	$footline = $1;
    }

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

# Start the show here ...

#
# Returns the eh handle ...
#
sub mix_get_eh () {
	
	return $eh;

} # End of mix_get_eh

##############################################################################
# Initialize environment, variables, configurations ...
#
##############################################################################
#!wig20031217: if intermediate is xls and we are on Win32, change %IOCR% to \n (is " " by default)
#
=head2 mix_init()

Initialize the $eh variable with all the configuration we have/need

  $eh->set ( ..... );

No input arguments (today).

=cut

sub mix_init () {

	$eh = new Micronas::MixUtils::Globals;
	$eh->init();

	# Print out some of the collected data:
	$logger->info('#' x 72); # Print to ALL
	$logger->info('CMDLINE: ' . $eh->get('macro.%ARGV%') ); # Print to ALL
	# All the rest can be found in the CONF dump section ....

	# 
	# If there is a file called mix.cfg, try to read that ....
	# Configuration parameters have to be written like
	#	MIXCFG key value
	#	key can be key.key.key ... (see Globals.pm structure or use -listconf to dump current values)
	# !!Caveat: there will be no checks whatsoever on the values or keys !!
	# Locations to be checked are:
	# $HOME, $PROJECT, $WORKAREA, cwd(), -cfg FILE (LATER!)
	#	
	foreach my $conf (
    	$eh->get('macro.%HOME%'), 
    	$eh->get('macro.%PROJECT%'),
    	$eh->get('macro.%WORKAREA%'),
    	$eh->get('macro.%WORKAREA%') . '/setup', # The MSD ...
    	$eh->get('macro.%WORKAREA%') . '/env',	 # The mway ...
    	'.',
    	'CMDLINE', # SPECIAL: replace the key by the -cfg FILE.cfg name
    ) {
		_mix_utils_readcfg( $conf );
    }

	post_configset( $eh );

	return $eh;	
} # End of mix_init

#
# Read mix.cfg file
#    
sub _mix_utils_readcfg ($) {
	my $conf = shift;
   	# If the key is CMDLINE and $extracfg is set
   	my $cfgfile = $conf . '/' . 'mix.cfg';
   	if ( $conf eq 'CMDLINE' ) {
		if ( exists( $OPTVAL{'cfg'} ) ) {
			$cfgfile = $OPTVAL{'cfg'};
			unless ( -r $cfgfile ) {
				$logger->warn( '__W_CFG_FILE',
					"\tCannot read cfg file $cfgfile! Ignore it!");
				$cfgfile = '__E_NOCFG_FILE';
			}
		}
   	}
    next unless $cfgfile;
    if ( -r $cfgfile ) {
		$logger->info( "__I_READ_CFG",
			"\tReading extra configurations from $cfgfile" );
		unless( open( CFG, "< $cfgfile" ) ) {
	   		$logger->warn('__W_READ_CFG',
	   			"\tCannot open $cfgfile for reading: $!");
		} else {
			my $prev = '';
	   		while( <CFG> ) {
				chomp;
				$_ =~ s,\r$,,;
				$_ = $prev . $_; # prepend previous line
				next if ( m,^\s*#,o );
				# Add next line if line ends with \
				if ( $_ =~ s/\\$// ) {
					$prev = $_ . "\n"; # Add a line break ...
    				next;
    			}
    			$prev = '';
		
				if ( m,^\s*MIXCFG\s+(\S+)\s*(.*),s ) { # MIXCFG key.key.key value
	    			mix_apply_conf( $1, $2, 'file:mix.cfg' );
				} elsif ( m,^\s*MIXCFGRE\s+(\S+)\s*(.*),s ) { # MIXCFGRE key.key.key value
	    			mix_apply_confre( $1, $2, 'file:mix.cfg' );
				} 
				# Other lines are discarded silently
    		}
   			close( CFG ) or
   				$logger->warn('__W_CLOSE_CFG',
   					"\tCannot close config file $cfgfile: $!" );
		}
	}
} # End of _mix_utils_readcfg

#
# set config options and $eh derived from config settings
# Obviously some parameters cannot be set a second time
#   (e.g. PROJECT derived mix.cfg location
#
sub post_configset ($) {
	my $eh = shift;
	#
	# Post configuration processing
	#!wig20031219
	#
	if ( my $t = $eh->get('output.generate.xinout') ) { # Convert comma seperated list into PERL-RE
    	my @si = split( /,/ , $t );
    	$eh->set('output.generate._re_xinout', '^(' . join( "|", @si ) . ')$' );
	} else {
    	$eh->set('output.generate._re_xinout', '^__NOEXCLUDESIGNAL__$' );
	}

	_init_logic_eh( $eh );

	if ( my $t = $eh->get( 'intermediate.topmap' ) ) {
		my $re = '^(';
		$re .= join( '|', split( /[\s,]+/, $t ));
		$eh->set( 'intermediate.__topmap_re_', $re . ')$' );
	}

	#!wig: expand check.name.all to all other checks ...
 	if ( my $allchk = $eh->get( 'check.name.all' ) ) {
 		# Overwrite all others!
 		my $chk = $eh->get( 'check.name' );
 		for my $k ( keys %$chk ) {
 			next if ( $k eq 'all' );
 			if ( $chk->{$k} =~ m/__default__/ ) {
 				$chk->{$k} = $allchk;
 			}
 		} 
 	}

	_init_loglimit_eh( $eh );

} # End of post_configset

#
# Remove all limits set to -1
#
sub _init_loglimit_eh ($) {
	my $eh = shift;
	
	my $loglimit = $eh->get( 'log.limit' );
	for my $category ( qw( re tag level test ) ) {
		next unless( exists $loglimit->{$category} );
		if ( ref( $loglimit->{$category} ) ne 'HASH' ) {
			delete $loglimit->{$category}; # Crashes later!
			$logger->error( '__E_INIT_LOGLIMIT', "\tIllegal usage of log.limit." .
					$category . ". Not a hash!" );
		} else {
			for my $k ( keys %{$loglimit->{$category}} ) {
				if ( $loglimit->{$category}->{$k} == -1 ) {
					delete $loglimit->{$category}->{$k};
				}
			}
		}
	}
} # End of _init_loglimit_eh

=head2 _init_logic_eh ($)

#
# parse/convert the output.generate.logic configuration into
#   the internal represenation
#
# input: $eh  (Globals object)
# output: n/a
#

=cut

sub _init_logic_eh ($) {
	my $eh = shift; # Environment hash object
    # Get the _logic_ list ...
    #!wig20050519:
    #  split into list and seperate (M:N)
    #    M = number of outputs
    #    N = number of inputs
    my @logic = split( /[,\s+]/, $eh->get('output.generate.logic') );
    my @names = ();
    for my $i ( @logic ) {
    	if ( $i =~ m/^(\w+)\(([NM\d]+)(:([NM\d]+))?\)/ ) {
    		my $omax = $4 || "N";
    		$eh->set( 'output.generate._logiciocheck_.' . $1 . '.omax', $omax);
    		$eh->set( 'output.generate._logiciocheck_.' . $1 .'.imax', $2 );
    		push( @names, $1 );
    	} else {
    		$eh->set( 'output.generate._logiciocheck_.' . $i. '.imax', 'N' );
    		$eh->set( 'output.generate._logiciocheck_.' . $i . '.omax' , 'N' );
    		push( @names, $i );
		}
	}
    	
	$eh->set( 'output.generate._logicre_' ,
    	'^(__|%)?(' . join( '|', @names ) . ')(__|%)?$' );
 
	# Create LOGIC macros:
	# for my $log ( split(/[,\s+]/, $eh->get( 'output.generate.logic' ) ) ) {
	# 	$log =~ s/^(\w+).*/$1/; # Take real part, strip off (x:y) ...
	# 	$eh->set( 'output.generate._logic_map_.%' . uc( $log ) . '%', $log );
	# }
	return;
} # End of _init_logic_eh

#############################################################################
# mix_list_conf
#
# print out current contents of %EH
##############################################################################

=head2 mix_list_conf()

Triggered by -listconf command line switch. Print out current contents of
$eh configuration object and exit. Format is suitable to be dumped into a
file mix.cfg and reread after edit.

Lines starting with MIXCFG indicate possible configuration parameters.

=cut

sub mix_list_conf () {

    my @configs = $eh->conf2array();
    # Now print the current configuration
    foreach my $i ( @configs ) {
		print( join( " ", @$i ) . "\n" );
    }

    print( "\nCAVEAT: The list here might be different from the final configuration!!\n" );
    print( "CAVEAT: Because it is dumped before CONF sheet evaluation!!\n" );
    print( "CAVEAT: Run MIX and check the CONF sheet of the intermediate workbook.\n" );

    exit 0;
}

#
# Prepare configuration data to be dumped to excel format
#
sub mix_list_econf ($) {
    my $format = shift || 'xls';
    my @configs = $eh->conf2array();

    return \@configs;
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

    my $e = '';
    my ( $k, $v );

    for my $i ( @$confs ) {
		( $k, $v ) = split( /=/, $i ); # Split key=value
		if ( $k eq '' or $v eq '' ) {
	    	$logger->error("__E_CFG_KEY_ILLEGAL", "\tIllegal key or value given: $i\n");
	    	next;
		}
 
     	$v = _mix_special_input($v);
		$eh->set( $k, $v );

    }
} # End of mix_overload_conf

#############################################################################
## mix_apply_conf
## Similiar to MixUtils::mix_overload_conf!!
#############################################################################
=head2 mix_apply_conf($$$)

apply configuration

=over 4
=item $key Key
=item $value Value
=item $source Source

=back

#!wig20060424: map  &sp; or <SP> to a space, <TAB> or &tab; to \t, &nl; or <NL> to newline,
	&nil; or <NIL> to an empty string

=cut

sub mix_apply_conf($$$) {
    my $key		= shift; # Key
    my $value	= shift; # Value
    my $source	= shift; # Source

    unless( $key and defined($value) ) {
	    unless( $key ) { $key = ''; }
	    unless( defined( $value ) ) { $value = ''; }
	    $logger->warn('__W_CONF_KEY',
	    	"\tIllegal key or value given in $source: key:$key val:$value");
	    return undef;
    }

	$value = _mix_special_input( $value );

    unless( defined( $eh->set( $key, $value ) ) ) {
    	$logger->error('__E_CONF_KEY', "\tApplying key $key from source $source failed" );
    }
} # End of mix_apply_conf

#############################################################################
## mix_apply_confre
## derived from mix_apply_conf; supports regular expressions as keys!!
#############################################################################
=head2 mix_apply_confre($$$)

apply configuration

=over 4
=item $key Key
=item $value Value
=item $source Source

=back

=cut

sub mix_apply_confre($$$) {
    my $key		= shift; # Key
    my $value	= shift; # Value
    my $source	= shift; # Source

    unless( $key and defined($value) ) {
	    unless( $key ) { $key = ''; }
	    unless( defined( $value ) ) { $value = ''; }
	    $logger->warn('__W_CONF_KEY',
	    	"\tIllegal key or value given in $source: key:$key val:$value");
	    return undef;
    }

	$value = _mix_special_input( $value );

    unless( defined( $eh->setre( $key, $value ) ) ) {
    	$logger->error('__E_CONF_KEYRE', "\tApplying key $key from source $source failed" );
    }
} # End of mix_apply_confre

##############################################################################
## _mix_special_input ($)
##############################################################################
=head2 _mix_special_input($)

Convert specially encoding input data to real representation.

#
# _mix_special_input: Convert special encodings for whitespace
#  <SP> &sp; , <TAB> &tab; , <NL> &nl; , <NIL> &nil;
#

=over 4

=item <TAB> &tab; converted to tab

=item <SP> &sp;  gives space character

=item <NL> &nl;  converted to newline

=item <NIL> &nil; converted to null (empty string)

=back

=cut

sub _mix_special_input ($) {
	my $value = shift;
	
	my %msi = (
		'sp' => ' ',
		'tab' => "\t",
		'nl'  => "\n",
		'nil' => '',
	);
	
	$value =~ s/&(sp|tab|nl|nil);/$msi{lc($1)}/ig;
	$value =~ s/<(SP|TAB|NL|NIL)>/$msi{lc($1)}/ig;

	return $value;
} # End of _mix_special_input

##############################################################################
## mix_overload_sheet
##
## take -sheet SHEET=MATCH_OP and transfer that into $eh (overloading values there)
##############################################################################
=head2 mix_overload_sheet($)

Started if option -sheet SHEET=match_op is given on command line. SHEET can be one of
<I hier>, <I conn>, <I vi2c> or <I conf>

=over 4

=item $sheets worksheets to process

=back
=over2

= item -sheet SHEET=match_op

Replace the default match operator for the sheet type. match_op can be any perl
regular expression. match_op should match the sheet names of the design descriptions.

=back

=cut

sub mix_overload_sheet ($) {
    my $sheets = shift;

    my $e = '';
    my ( $k, $v );

    # %EH = ...
    #		'vi2c' => {
    #		'xls' => 'VI2C', ...

    for my $i ( @$sheets ) {
		( $k, $v ) = split( /=/, $i ); # Split key=value
		unless( $k and $v ) {
	    	$logger->warn("__W_CFG_SHEET_OVL",
	    		"\tIllegal argument for overload sheet given: $i\n");
	    	next;
		}

		$k = lc( $k ); # $k := conn, hier, vi2c, conf, ...

		if ( defined( $eh->get( $k . '.xls' ) ) ) {
	    	$logger->info( "__I_CFG_SHEET_MATCH", "\tOverloading sheet match $i");
	    	$eh->set( $k. '.xls' , $v );
		} else {
	    	$logger->warn( "__W_CFG_SHEET_ILLEGAL", "\tIllegal sheet selector $k found in $i\n" );
		}
    }
} # End of mix_overload_sheet

####
# extra block starts here
{
# Block around the mix_utils_functions .... to keep ocont, ncont and this_delta intact ...

my @ocont = (); # Keep (filtered) contents of original file
my @ncont = (); # Keep (filtered) contents of new file to feed into diff
my @ccont = (); # Keep (filtered) contents of template entity for check

my %fhcasemap = ();
my %fhstore = ();   # Store all possiblefilehandles/ names
                            # -> file / delta / check / tmpl / back; prim. key is filename!
my $loc_flag  = 0;
my %loc_files = ();

#
# Return name of all created HDLfiles
#
sub mix_utils_report_hdlfiles () {

	my @list = keys %fhstore;
	return \@list;
}

#
# Streamline data for delta/diff purposes ...
#
sub mix_utils_clean_data ($$;$) {
    my $d = shift;                              # Data, array ref
    my $c = shift || '__NO_COMMENT';  			# The current comment string
    my $conf = shift || $eh->get( 'output.delta' ); # Which rules to apply ...
    
    # remove comments: -- for VHDL, // for Verilog
    # 	only if "comment" is not set
    map( { s/\Q$c\E.*//; } @$d ) if ( $conf !~ m/\bcomment\b/i );
    
    #!wig20051121: strip comment head (up to first non-comment line!)
	if ( $conf =~ m/\b(i|ignore)head\b/io ) { 
    	for my $dl ( @$d ) {
    		last if ( $dl !~ m/^$c/i );
    		$dl = '';
    	}
	}
    
    #
    # remove verilog body, only check the module header
    # 
    #!wig20060118
    if ( $c eq '//' and $conf =~ m/\b(veri|mod(ule)?)head\b/io ) {
    	# module A ( ... ) input bar; inout bar; output foo; wire blub;
    	# Force pagebreaks for each ';'
    	$d = _mix_utils_extract_verihead ($d, $c, $conf);
	}

    # condense whitespace, remove empty lines ...
    #wig20040420: remove \s after ( and before )
    if ( $conf !~ m,\bspace\b,io ) {
		map( { s/\s+/ /og; s/^\s+//og; s/\s+$//og; s/\s*([\(\)])\s*/$1/g; } @$d );
    }
	#!wig20060314: Ignore empty lines always!
	$d = [ grep( !/^$/, @$d ) ];
    
    #  remove trailing ";"
    if ( $conf =~ m,\bisc|ignoresemicolon\b,io ) {
    	map( { s/;$//; } @$d );
    }

    # ignore case -> make everything lowercase ....
    $d = [ map( { lc( $_ ); } @$d ) ] if ( $conf =~ m,\b(ic|ignorecase)\b,io );

	# mangle std_ulogic to std_logic (but not _vector!)
    if ( $conf =~ m,\bmanglestd\b,io ) {
		map( { s/\bstd_ulogic\b/std_logic/iog; } @$d );
    }
    # sort lines before compare
    ( $d = [ sort( @$d ) ] ) if ( $conf =~ m,\bsort\b,io );

    return $d;

} # End of mix_utils_clean_data

#
# Strip off all lines but the verilog module header
# TODO : replace by a CPAN Verilog reader!
#
# Input:
#	$d		array ref with file contents
#	$c		current comment ( // for verilog
#	$conf	switches
#
# Return:
#	$d		array ref, verilog header only
#
#!wig20060118
sub _mix_utils_extract_verihead ($$$) {
	my $d	= shift;
	my $c	= shift;
	my $conf = shift;
	
	# Join all data into on string, replace ';' by newlines
	( my $t = join( "\n", @$d ) ) =~ s/;/;\n/g;
	$t =~ s/^$//mg; # Remove empty lines
	
	if ( $t =~ m/(.*)(module\s*\([^\)]*\))(.*)/ ) {
		my $start = $1 . $2;
		# Iterate over rest
		for my $l ( split( /\n/, $3 ) ) {
			if ( $l =~ m/^\s*(input|output|inout|wire|register)/ ) {
				$start .= $l . "\n";
			} elsif ( $l =~ m/^\s*$c/ ) {
				$start .= $l . "\n";
			} elsif ( $l =~ m/^\s*$/ ) {
				next;
			} else {
				# Leave it now ...
				last;
			}
		}
		$t = $start;
	} else {
		$logger->warn( '__W_VERI_HEADDETECT',
			"\t" . 'Cannot detect verilog module, take full content to delta' );
	}
	$d = [ split( /\n/, $t ) ];
	return $d;
} # End of _mix_utils_extract_verihead

#
# Open a file and read in the contents for comparison ...
# e.g. in delta mode or for verify purposes ...
# flag: if set to verify, this will be a verify run;
#   else we are in real delta-mode
#
sub mix_utils_open_diff ($;$) {
    my $file = shift;
    my $flag = shift || "delta";

    my @ocont = ();
    my $ocontr = '';

    my $ext;
    my $c = '__NOCOMMENT';
    ( $ext = $file ) =~ s/.*\.//;
    my $keh = $eh->get( 'output.ext' ); 
    for my $k ( keys ( %$keh )) {
	    if ( $keh->{$k} eq $ext ) {
		    $c = $eh->get( 'output.comment.' . $k ) || "__NO_COMMENT";
		    last;
	    }
    }    
    if ( -r $file ) {
    	# read in file
		my $ofh = new IO::File;
		unless( $ofh->open($file) ) {
	    	$logger->error( '__E_FILE_OPEN_ORG',
	    		"\tCannot open org $file in $flag mode: $!" );
	    	return undef, undef;
		}
		@ocont = <$ofh>; #Slurp in file to compare against
		chomp( @ocont );
		close( $ofh ) or $logger->error( '__E_FILE_CLOSE',
			"\tCannot close org $file in delta mode: $!" );
    } else {
		$logger->error( '__E_FILE_READ', "\tCannot read $file" );
    }
    return \@ocont;
} # End of mix_utils_open_diff

####################################################################
## mix_utils_open
## Our interface for file output
## Will return a file handle object
####################################################################

=head2

mix_utils_open ($;$) {

Open file for writing/reading/.... If the "delta" mode is active, then a diff will be generated
instead of a full file!

The first argument is the file to open, the second contains flags like:
    COMB (combine mode)

#!wig20070303: map filenames to lc() in all cases, because some filesystems
do not distinguish case! In case a second file gets opened with the same
name, but different case, create a different name, e.g. by adding a number!
	this gets controlled by the output.casefilename (which is set to lc on MS-Win and
	to ic (ignorecase) on UNIX-like systems. The real name is kept in $fhstore{$file}{'casename'}
	
=cut

sub mix_utils_open ($;$){
    my $file	= shift;
    my $flags	= shift || ''; # Could be "COMB" for combined mode or ..._CHK_(ENT|LEAF)

    #
    # if output.path is set, write to this path (unless file name is absolute path)
    # wig20030703
    #

    if ( $eh->get( 'output.path' ) ne '.' ) {
		unless( is_absolute_path( $file ) ) {
	    	$file = $eh->get( 'output.path' ) . '/' . $file;
		}
	}	

    my $ofile = $file;

	#
	# Check for case conflicts
	# (if $eh->get('output.casefilename')
	if ( $eh->get('output.casefilename') =~ m/\blc/ ) {
		$file  = lc( $file );
		if ( exists( $fhstore{$file} ) ) {
			if ( $file ne $fhstore{$file}{'casename'} ) {
				# Conflict, file with different case already in place
				$logger->error('__E_OPEN_HDL', "\tFilename $file conflicts with previously written $ofile! Number will be injected!" );
				# Update filename ... e.g. by adding a number
				my ( $base, $ext ) = $file =~ m/(.+)(\..+)$/;
				my $n = 0;
				while ( 1 ) {
					if ( $n > 9 ) {
						$logger->error('__F_OPEN_HDL', "\tToo many file names with case conflicts! Die here!" );
						die;
					}
					next if ( exists( $fhstore{$base . '_' . ++$n . $ext} ) );
					# Found a available name
					$file = $base . '_' . $n . $ext;
					$logger->info('__I_OPEN_HDL', "\tWrite contens of $ofile into $file to have unique name!" );
					last;
				}	
			}
		}
	}
	
    #
    # Did we open that file already?
    #
    unless ( exists( $fhstore{$file} ) ) {
        $eh->inc( 'sum.hdlfiles' );
    }

	$fhcasemap{$ofile} = $file;
	$fhstore{$file}{'casename'} = $ofile; # Remember original case
	$ofile = $file;
	
    # Search a file with this name in EH{check}{hdlout} ...
    # TODO better algo: preparse check.hdlout.path and keep a list of all entities around ... 
    my $mode = O_CREAT|O_WRONLY|O_TRUNC;
    if ( $flags =~ m,COMB, ) {
        $mode = O_CREAT|O_WRONLY|O_APPEND;
    }
    if ( $flags =~ m/_CHK_(\w+)/io ) {
        my $leaf_flag = $1; #
        my $templ = mix_utils_loc_templ( 'ent', $file );
        if ( $templ ) { # Got a template file ...
            @ccont = @{mix_utils_open_diff( $templ, 'verify' )}; # Get template contents, filtered  ...
            @ncont = (); # Reset new contents ...

            $fhstore{$file}{'tmpl'} = $templ;
            $fhstore{$file}{'tmplmode'} = $leaf_flag;

            # $fh -> keep main file handle
            my $fh = new IO::File;
            $fhstore{$file}{'tmplname'} = $file . $eh->get( 'output.ext.verify' );
            unless( $fh->open( $fhstore{$file}{'tmplname'}, $mode) ) {
                $logger->error( '__E_FILE_OPEN', "\tCannot open " .
                	$fhstore{$file}{'tmplname'} . ": $!" );
            } else {
                $fhstore{$file}{'tmplout'} = $fh;
            }
        } else {
            # No template/verification example found ....create a .ediff file ...
            $fhstore{$file}{'tmpl'} = "__E_CANNOT_LOCATE";
            my $fh = new IO::File;
            $fhstore{$file}{'tmplname'} = $file . $eh->get( 'output.ext.verify' );
            unless( $fh->open( $fhstore{$file}{'tmplname'}, $mode) ) {
                $logger->error( '__E_FILE_OPEN', "\t" . 'Cannot open ' . $fhstore{$file}{'tmplname'} . ": $!" );
            } else {
                $fh->print( "WARNING: cannot locate $file in template directories\n" );
                $fh->print( 'Template path: ' . $eh->get( 'check.hdlout.path' ) . "\n" );
                $fh->close() or
                    $logger->error( '__E_FILE_CLOSE',
                    	"\t" . 'Cannot close ' . $fhstore{$file}{'tmplname'} . ": $!" );
            }
        }
    }

    if ( $flags =~ m/^0/ ) {
        # no further file to write ...
        return $ofile; # return file name...
    }

    #
    # Prepare for printing out diff's
    #
    if ( $eh->get( 'output.generate.delta' ) ) { # Delta mode!
        if ( -r $file ) {
            @ocont = @{mix_utils_open_diff( $file )};
            $ofile .= $eh->get( 'output.ext.delta' ); # Attach a .diff to file name
	    	@ncont = (); # Reset new contents
        } else {
	    	$logger->info( '__I_DELTA_FILE', "\tCannot run delta mode vs. $file. Will create like normal" );
	    	$fhstore{$file}{'delta'} = 0; # Key is the "file name" ....
		}
    }

    #
    # Prepare for one backup
    #
    if ( $eh->get( 'output.generate.bak' ) ) {
		# Shift previous version to file.bak ....
        # Simply overwrite preexisting bak-files ....
		if ( -r $file ) {
	    	rename( $file, $file . '.bak' ) or
			$logger->error( '__E_FILE_RENAME', "\tCannot rename $file to $file.bak" );
		}
    }

    #
    # Append or create a new file?
    # Append will be used if we get a "COMB" flag (combine mode)
    #    
    $mode = O_CREAT|O_WRONLY|O_TRUNC;
    if ( $flags =~ m,COMB, ) {
		$mode = O_CREAT|O_WRONLY|O_APPEND;
    }
    my $fh = new IO::File;
    unless( $fh->open( $ofile, $mode) ) { # Write output to this file, either HDL or HDL.diff
		$logger->error( '__E_FILE_OPEN', "\tCannot open $ofile: $!" );
		return $file;
    }

    #
    # Remember if delta mode is active for this file ...
    #
    if ( $ofile ne $file ) {
        $fhstore{$file}{'delta'} = $fh;
        $fhstore{$file}{'deltaname'} = $ofile;
        $fhstore{$file}{'out'} = 0;
    } else {
        $fhstore{$file}{'delta'} = 0;
        $fhstore{$file}{'out'} = $fh; # Remember file name and IO handle ...
    }
 
    #
    # If -delta and -bak -> create a new original file ...
    #
    if ( $eh->get( 'output.generate.bak' ) and $eh->get( 'output.generate.delta' ) ) {
	# Append or create a new file?
	# $bfh -> backup file handle (will get new data! Named like the real file, the old one got renamed!
		my $bfh = new IO::File;
		unless( $bfh->open( $file, $mode) ) {
	    	$logger->error( '__E_FILE_OPEN', "\tCannot open $file: $!" );
			$fhstore{$file}{'back'} = undef(); # Not possilbe
		} else {
			$fhstore{$file}{'back'} = $bfh;
		}
    } else {
        $fhstore{$file}{'back'} = 0; # Not selected ...
    }
    return $file;
} # End of mix_utils_open

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
} # End of is_absolute_path

#
# Look at input value and return a 1 if it's an
# integer only
#
#!wig20060517
sub is_integer ($) {
	my $value = shift;
	
	if ( $value =~ m/^\d+$/o ) {
		return 1;
	}
	return 0;
} # End of is_integer
#
# Look at input values and return a 1 if it's an
# integer only
#
#!wig20060517
sub is_integer2 ($$) {
	my $value = shift;
	my $valu2 = shift;
	
	if ( $value =~ m/^\d+$/o and $valu2 =~ m/^\d+$/o ) {
		return 1;
	}
	return 0;
} # End of is_integer2

#
# print into file handle and/or save for later diff
#
sub mix_utils_print ($@) {
    my $fn = shift;
    my @args = @_;

    # $fn either is a real file handle (if this_delta is set) or a file name
    # in this_check ....
    #WRONG $fn = $fhcasemap{$fn}; # Run through casemap!
    if ( $fhstore{$fn}{'delta'} or $fhstore{$fn}{'tmpl'} ) {
		push( @ncont, split( /\n/, sprintf( '%s', @args ) ) );
    }

    if ( $fhstore{$fn}{'out'} ) {
        $fhstore{$fn}{'out'}->print( join( "\n", @args)  );
    }

    # Print to file if backup requested ....
    if ( $fhstore{$fn}{'back'} ) {
		$fhstore{$fn}{'back'}->print( join( "\n", @args ) );
    }
} # End of mix_utils_print

#
# printf into file handle or save for later diff
# first argument has to be format string
#
sub mix_utils_printf ($@) {
    my $fn = shift;
    my @args = @_;

	#WRONG: $fn = $fhcasemap{$fn}; # Run through casemap!
    if ( $fhstore{$fn}{'delta'} or $fhstore{$fn}{'tmpl'} ) {
		push( @ncont, split( /\n/, sprintf( @args ) ) );
    }

    if ( $fhstore{$fn}{'out'} ) {    
		$fhstore{$fn}{'out'}->print( join( "\n", @args ) );
    }

    if ( $fhstore{$fn}{'back'} ) {
		$fhstore{$fn}{'back'}->print( join( "\n", @args ) );
    }
} # End of mix_utils_printf

#
# Close that file-handle
# If in delta mode, run the diff and print before closing!
# In reality MIX writes the files here, up to now everything happened in memory
#
sub mix_utils_close ($$) {
    my $fn = shift;
    my $file = shift;

    my $close_flag = 1;
	#WRONG: $fn = $fhcasemap{$fn}; # Run through casemap
    # Prepend PATH
    if ( $eh->get( 'output.path' ) ne '.' and not is_absolute_path( $file ) ) {
		$file = $eh->get( 'output.path' ) . '/' . $file;
    }

    # Find the actual comment marker ( // vs. -- vs. # )
    my $ext;
    my $c = "__NOCOMMENT";
    ( $ext = $file ) =~ s/.*\.//;
    for my $k ( keys ( %{$eh->get( 'output.ext' ) } )) {
		if ( $eh->get( 'output.ext.' . $k ) eq $ext ) {
	    	$c = $eh->get( 'output.comment.' .$k ) || "__NO_COMMENT";
	    	last;
		}
    }

    #
    # verify mode on
    # Check against existing entity selected ...
    #
    if ( $fhstore{$fn}{'tmplout'}  ) {
		# if check.hdlout.delta contents differs from output.delta,
		# we need to parse @ncont with differentely ...
		my $switches = ( $eh->get( 'check.hdlout.delta' ) ) ?
			$eh->get( 'check.hdlout.delta' ) : $eh->get( 'output.delta' );
		my @vncont = @ncont; # Copy output data ...
        my $diff = mix_utils_diff( \@vncont, \@ccont, $c, $file, $switches );
		# Compare new content and template

        my $head =
"$c ------------- verify mode for file $file ------------- --
$c
$c Generated
$c  by:  %USER%
$c  on:  %DATE%
$c  cmd: %ARGV%
$c  verify mode (comment/space/sort/remove/manglestd): $switches
$c
$c  compare  file (NEW): $fn
$c  template file (OLD): $fhstore{$fn}{'tmpl'}
$c ------------- CHANGES START HERE ------------- --
";

    	my $fht = $fhstore{$fn}{'tmplout'};
		print( $fht &replace_mac( $head, $eh->get( 'macro' )));

    	#
		# Was there a difference? If yes, report and sum up.
    	#
		if ( $diff ) {
	    	$fht->print( $diff );
	    	$logger->warn('__W_VEC_MISMATCH', "\tMismatch file $fn vs. template!");
			$eh->inc('sum.verify_mismatch'); # Count mismatches ..
			$eh->inc('DELTA_VER_NR');
		} else {
	    	$logger->info( '__I_VEC_OK', "\tFile $fn in sync with template" );
        	$eh->inc( 'sum.verify_ok' ); # Count matches ..
	    	if ( $eh->get( 'output.delta' ) =~ m,\bremove\b,io ) {
				# Remove empty diff files, close before remove ...
				unless ( $fht->close ) {
                	$logger->error( '__E_FILE_CLOSE', "\tCannot close file " . $fhstore{$fn}{'tmplname'} . ": $!" );
            	}
            	$fhstore{$fn}{'tmplout'} = 0;
				unlink( $fhstore{$fn}{'tmplname'} ) or
		    	$logger->warn( '__F_FILE_RM',
		    		"\tCannot remove empty template verify file " .
                	$fhstore{$fn}{'tmplname'} . ": " . $! ); #OLD and
	    	}
		}
	}

	#
	# Delta mode on
	#
    if ( $fhstore{$fn}{'delta'} ) {
    # Sort/map new content and compare .... print out to $fh
        my $diff = mix_utils_diff( \@ncont, \@ocont, $c, $file ); # Compare new content and previous
        my $fh = $fhstore{$fn}{'delta'};

        # Print header to $fh ... (usual things like options, ....)
        # TODO Add that header to header definitions
my $head =
"$c ------------- delta mode for file $file ------------- --
$c
$c Generated
$c  by:  %USER%
$c  on:  %DATE%
$c  cmd: %ARGV%
$c  delta mode (comment/space/sort/remove): " . $eh->get( 'output.delta' ) .
"$c
$c  to create file (NEW)
$c  existing  file (OLD): $file
$c ------------- CHANGES START HERE ------------- --
";

		$fh->print( replace_mac( $head, $eh->get( 'macro' )));

		# Was there a difference? If yes, report and sum up.

		if ( $diff ) {
	    	$fh->print( $diff );
	    	$logger->warn('__W_DIFF_DETECTED', "\tFile $file has changes!");
	    	$eh->inc( 'DELTA_NR' );
		} else {
	    	$logger->info( '__I_DIFF_NOT', "\tUnchanged file $file" );
	    	if ( $eh->get( 'output.delta' ) =~ m,remove,io ) {
			# Remove empty diff files (removal before closing ????)
				unless( $fhstore{$fn}{'delta'}->close ) {
					$logger->error( '__E_FILE_CLOSE',
						"\tCannot close delta file $fn: $!" );
                }
                $fhstore{$fn}{'delta'} = 0;
				unlink( $fhstore{$fn}{'deltaname'} ) or
					$logger->warn( '__W_FILE_RM',
						"\tCannot remove empty diff file " .
                        $fhstore{$fn}{'deltaname'} . ": " . $! );
	    	}
		}
    }

    #
    # Do we need to close the output file?
    #
    if ( $fhstore{$fn}{'out'} ) {
        unless ( $fhstore{$fn}{'out'}->close ) {
            $logger->error( '__E_FILE_CLOSE', "\tCannot close file $fn: $!" );
            $fhstore{$fn}{'out'} = 0;
        }
        $fhstore{$fn}{'out'} = 0;
    }

    #
    # Do we need to close the delta file?
    #
    if ( $fhstore{$fn}{'tmplout'} ) {
        unless ( $fhstore{$fn}{'tmplout'}->close ) {
            $logger->error( '__E_FILE_CLOSE',
            	"\tCannot close file $fhstore{$fn}{'tmplname'}: $!" );
        }
        $fhstore{$fn}{'tmplout'} = 0;
    }
    #
    # Do we need to close the diff file?
    # TODO Close in the delta-if branch above ...
    #
    if ( $fhstore{$fn}{'delta'} ) {
        unless ( $fhstore{$fn}{'delta'}->close ) {
            $logger->error( '__E_FILE_CLOSE',
            	"\tCannot close file $fhstore{$fn}{'deltaname'}: $!" );
        }
        $fhstore{$fn}{'delta'} = 0;
    }
    #
    # Close new file if in -bak mode and close_flag is set ...
    #
    if ( $fhstore{$fn}{'back'} ) {
		my $bfh = $fhstore{$fn}{'back'};
        $fhstore{$fn}{'back'} = 0;
		$bfh->close or $logger->error( '__E_FILE_CLOSE', "\tCannot close file $fn bak: $!" )
	    	and return undef;
    }
    return;
} # End of mix_utils_close

#
# Compare two array refs
# !! $oc needs to be preformatted !!
# Arguments:
#   ref to array with new contents
#   ref to array with old contents
#   current comment delimiter
#   current file name
#   string with swtiches to apply ..
# Returns:
#   array ref with diffs
#
sub mix_utils_diff ($$$$;$) {
    my $nc = shift;
    my $oc = shift;
    my $c  = shift;
    my $file = shift;
	my $switches = shift || '';

    # strip off comments and such (from generated data)
    $oc = mix_utils_clean_data( $oc, $c, $switches );    
    $nc = mix_utils_clean_data( $nc, $c, $switches );

    # Diff it ...
    my $diff = diff( $nc, $oc,
	    { STYLE => "Table",
	      # STYLE => "Context",
	      FILENAME_A => 'NEW',
	      FILENAME_B => "OLD $file",
	      CONTEXT => 0,
	    }
    );

    return $diff;
} # End of mix_utils_diff
        
#
# Locate a matching *.vhd file in the check.hdlout path
#
#!wig20040217
#!wig20050128: what if we get a verilog file?
#
#    $d = new DirHandle ".";
#    if (defined $d) {
#        while (defined($_ = $d->read)) { something($_); }
#        $d->rewind;
#        while (defined($_ = $d->read)) { something_else($_); }
#        undef $d;
#    }

sub mix_utils_loc_templ ($$) {
    my $flag = shift;
    my $file = shift;

    $file = basename( $file );
    my $ic = ( $eh->get( 'check.hdlout.mode' ) =~
    	m/\b(ignorecase|ic)\b/ ) ? 1 : 0;
    my $dh;

    $file = lc( $file ) if $ic;

    # Strategy: if "inpath" is set, take all files found in hdlout.path
    if ( $eh->get( 'check.hdlout.mode' ) =~ m/\binpath\b/o ) {
        _mix_utils_loc_templ("__ALL__", $ic) unless $loc_flag; # Scan once
        $loc_flag = 1;
        if ( $loc_files{$file} ) {
            my $tmpl = $loc_files{$file};
            delete $loc_files{$file}; # Unset ... we no longer need it
            return $tmpl;
        } else {
            # no match found :-(    
            $logger->warn( '__W_VEC_MATCH',
            	"\tCould not find matching entity file $file!" );
            $eh->inc( 'sum.verify_missing' );
            $eh->inc( 'DELTA_VER_NR' );
            return '';
        }
    } else {
        #find the first match
        return( _mix_utils_loc_templ($file, $ic) );
    }
} # End of mix_utils_loc_templ

#
# scan check.hdlout.path and store/return matching files
#if __ALL__ is given, scan all path components and store results ...
#
sub _mix_utils_loc_templ ($$) {
    my $file = shift;
    my $ic = shift;

    my $dh;
    
    my $pref = $eh->get( 'check.hdlout.__path__' );
    for my $p ( keys( %$pref )  ) {
        if ( $dh = new DirHandle( $p ) ){
            while( defined( $_ = $dh->read ) ) {
                if ( $file eq "__ALL__" ) {
                    next if ( -d $p . "/" . $_ ); # Skip all directories
                    # next unless ( -f $_ ); # Skip all non files ..
                    my $f = ( $ic ) ? lc( $_ ) : $_;
                    if ( defined( $loc_files{$f} ) ) {
                        $logger->warn( '__W_TMPL_DUPL',
                        	"\tDuplicate tmplate file: $_ in $p!" );
                    } else {
                        $loc_files{$f} = $p . "/" . $_;
                    }
                } elsif ( $_ eq $file or ( $ic and lc( $_ ) eq $file ) ) {
                    #Return here, first come, first reported ....
                    $dh->close();
                    return( $p . "/" . $_ ); # Return real file name
                } 
            }
            $dh->close();
        } else {
            $logger->warn( '__W_FILE_OPEN', "\tCannot open $p for reading: $!" );
        }
    }
    if ( $file eq "__ALL__" ) {
        return '';
    }

    # We are still here -> no match found :-(    
    $logger->warn( '__W_VEC_FINDMATCH', "\tCould not find matching entity file $file!" );
    $eh->inc( 'sum.verify_missing' );
    $eh->inc( 'DELTA_VER_NR' );
    return '';
} # End of _mix_utils_loc_templ

#
# Summarize left-over hdl files in verify path (only for "inpath" mode
#
sub mix_utils_loc_sum () {
    for my $h ( sort( keys( %loc_files )) ) {
        # TODO Apply filter ... (or better upfront ...)
        $logger->warn( '__W_VPATH_EXTRA', "\tUnmatched hdl file in verify path: $h!" );
        $eh->inc( 'sum.verify_leftover' );
        $eh->inc( 'DELTA_VER_NR' );
    }
} # End of mix_utils_loc_sum

} # End of mix_util_FILE block ....
####

#
# Do some text replacements
#
#wig20061102: performance tuning ...
sub replace_mac ($$;$) {
    my $text = shift;
    my $rmac = shift;
    my $emac = shift; # Extra macro definitions

	# Shortcut: if there is no %...% in text -> return immediatley
	# but a replacement without %...% could happen, too
	# return $text unless ( $text =~ m/%/o );

	#!wig20050111: %OPEN_NN% could be around ... -> hard coded to %OPEN%
    $text =~ s/%OPEN_\d+%/%OPEN%/gio;

	#!wig20060617: create seperate high/low signals for high/low
	while ( $text =~ m/%(HIGH|LOW)(_BUS)?(_\d+)?%/og ) {
		my $hl  = $1;
		my $bus = ( $2 ) ? $2 : '';
		my $n   = ( $3 ) ? $3 : '';
		if ( exists( $rmac->{'%' . $hl . $bus . '%'} ) ) { # Convert high/low bus, keep number
			#!wig20061102: Optimze this replacement:
			$text =~ s/%$hl$bus$n%/$rmac->{'%' . $hl . $bus . '%'}$n/g;
		}
	}
		
    if ( ( keys( %$rmac ) + keys( %$emac ) ) > 0 ) {
        #ORG: my $mkeys = "(" . join( '|', keys( %$rmac ) ) . ")";
        #ORG: $text =~ s/$mkeys/$rmac->{$1}/mg;
		#!wig20061102: Would that be faster?
		for my $r ( keys( %$rmac ) ) {
			my $replace = $rmac->{$r};
			$text =~ s/$r/$replace/mg;
		}
		for my $r ( keys( %$emac ) ) {
			$text =~ s/$r/$emac->{$r}/mg;
		}
    } else {
	# Do nothing if there are no keys defined ...
        # Strange, why would one call a replace functions without replacement
        # keys ?
        $logger->info( '__I_REPLACE_MAC', "\tCalled replace mac without macros for string " .
                substr( $text, 0, 15 ) . " ..." );
    }
    return $text;
} # End of replace_mac

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

Several variants can be selected by adding the appropriate variant names
to the ::variants columns, seperated by space or ,. 

The lines not selected by a variant will be marked by
adding a "#__I_VARIANT ..." to the ::ign column. A later parser run removes
that lines then (see parse_*_init)

Input
	excel sheet converted into array of hashes
	type string (hier, conn, ...; optional)

Returns
	- (works on input array ref)
=cut

sub select_variant ($;$) {
    my $r_data	= shift;
	my $type	= shift || 'default';

    unless ( defined $r_data ) {
	    $logger->fatal('__F_BAD_VARIANT', "\tselect_variant called with bad argument!");
	    die;
    }

	my $n = 0;
	my $variant = $eh->get( 'variant' );
   
    for my $i ( 0..$#$r_data ) {
		if ( exists( $r_data->[$i]{'::variants'} ) ) {
	    	my $var = $r_data->[$i]{'::variants'};	   
	    	if ( defined( $var ) and $var !~ m/^\s*$/o ) {
				$var =~ s/[ \t,]+/|/g; # Convert into Perl RE (Var1|Var2|Var3)
				$var = '(' . $var . ')';
				if ( $variant !~ m/^$var$/i ) { # Match variant (case insensitive).
		    		$r_data->[$i]{'::ign'} = '#__I_VARIANT Variant not selected!'; # Mark for deletion ...
		    		$n++;
				}
	    	}
		}
    }
    if ( $variant ne 'Default' or $n ) {
    	$logger->info( '__I_VARIANT',
    		"\tTagged $n lines for removal in input sheet $type for variant $variant" );
    }
} # End of select_variant

####################################################################
## convert_in
## read in a (excel) spreadsheet array and convert into a array of hashes
## do basic checks and conversion 
####################################################################

=head2

convert_in ($$) {

Do basic conversion for input tabular (excel) data:
Find :: header and then convert array/array to array/hash. 

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
	    $logger->error('__E_CONVERT_IN', "\tSkipping convert_in, called with bad arguments!");
	    return ();
    }

    my @d = ();
    my @order = ();  # Field number to name
    my %order = ();  # Field name to number
    my $hflag = 0;
    my @holdincom = (); # tmp storage for linked comments
    my $required = $eh->get( $kind . '.field' ); # Shortcut into EH->fields
	my $vinc = $eh->get( 'import._vincref' );

	#
	# Skip ::ign marked with # or // comments, again ...
	#			or if the whole line only has leading # or //
	#!wig20060706: acccept # as first char on line if followed by ::
	my $mapign = $eh->get( 'input.ignore.map' ) =~ m/\bhashtoign/;
	my $ignorelines_match = $eh->get( 'input.ignore.lines' ) ||
			'^\s*(#|//)';
	my $ignoreignore_match = $eh->get( 'input.ignore.comments' ) ||
			'^\s*(#|//)';
	if ( $ignoreignore_match =~ m/::ignany\b/ ) {
		$ignoreignore_match = '\S+';
	}
	my $kindcomment = $eh->get( $kind . '.comments' ) || '';
	my $header_type = $eh->get( 'input.header' ) || 'mix';
	
    for my $i ( @$r_data ) { # Read row by row
		$i = [ map { defined( $_ ) ? $_ : '' } @$i ];		#Fill up undefined fields??
		my $all = join( ' ', @$i );
		$all =~ s/\n//g; # Remove extra newlines ..
		next if ( $all =~ m/^\s*$/o ); 	# If a line is totally empty, skip it

		#
		# Skip all lines before the ::foo ::bar line!
		#
		unless ( $hflag ) { # We are still looking for our ::MARKER header line
			
			if ( $mapign ) { $all =~ s/^\s*#\s+::/::ign ::/; };
			
			# Skip if it's a comment:
			next if ( $all =~ m,$ignorelines_match, );
			
			# Skip if we need "MIX" type header and it's not starting with ::					
	    	next unless ( $header_type =~ m/mix/ and $all =~ m/^\s?::/ ); #Still no header ...
	    	%order = parse_header( $kind, $eh->get( $kind ), @$i );		#Check header, return field number to name
	    	$hflag = 1;
	    	next;
		}
		
		# Store comments into ::incom
		if ( $all =~ m,$ignorelines_match, or
			( defined( $order{'::ign'}) and
				$i->[$order{'::ign'}] =~ m,$ignoreignore_match, ) ) {
			# Skip only if <kind>.comments is not set
			if ( $kindcomment ) {
				my $relation = ( $kindcomment =~ m/\bpre/io ) ? 'pre' : 'post';
				# Other values: post, successor
				# Link the comment to the previous/next line
				# create a primary key entry (if not set!)
				my $comt = join( ' ', $all );
				$comt =~ s/\s+$//;
				$comt =~ s/^\s+//;
				my $incom = new Micronas::MixUtils::InComments(
					{	'text'		=> $comt,
						'relation'	=> $relation,
					 }
					);
				if ( $relation eq 'pre' ) { # Attach to predecessor
					if ( scalar( @d ) ) {
						push( @{$d[-1]{'::incom'}}, $incom );
					} else {
						push( @{$d[0]{'::incom'}}, $incom );
					}
				} elsif ( $relation eq 'post' ) {
					push( @holdincom, $incom ); # Save until we have another line
				}					
			} 
			next;
		}

		# Copy rest to 'another' array (indexed by ::headers ..)
		my $n = scalar( @d ); # next row
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
	    	}
		}
		# Replace verilog defines
		if ( $vinc ) {
			my $cl = $d[-1];
			$vinc->apply( $cl );
			# Check if ::high has a A:B --> split to ::high/::low
			if ( exists( $cl->{'::high'} ) and
				$cl->{'::high'} =~ m/(.+):(.+)/ ) {
				if ( not defined $cl->{'::low'} or
					$cl->{'::low'} eq '' or
					$cl->{'::low'} eq $cl->{'::high'} ) {
						  $cl->{'::low'} = $2;
						  $cl->{'::high'} = $1;
				}
			}
		}
		if ( scalar( @holdincom ) ) { # Attach post comments to previous ...
			@{$d[$n]{'::incom'}} = @holdincom;
			@holdincom = ();
		}
    }
    unless( $hflag ) {
		$logger->warn('__W_DETECT_HEADER', "\tFailed to detect header in worksheet of type $kind");
    }
    return @d;
}

####################################################################
## parse_header
## check the ::TYPE input line
####################################################################
=head2

parse_header ($$@)

See if the header line is complete, check if we all required fields and if we have extra fields
Convert multiple ::head to ::head, ::head:2, ....
	If the _multoder_ flag is set to RL, the :N numbers are assigned from right
	to left, defaults is left to right. A "F" in _multorder_ maps the first (left
	or right) column header to ::head:0, default is to leave that name as-is.

I guess multiple headers are kind of evil (keep an eye on them)

Arguments: $kind, $eh{$kind}, @header_row

Returns: %order (keys are the ::head items)

20050708wig: add _multorder_ handling
20050614: remove extra whitespace around the keywords
20051024: make sure multiple fields are printed in one block
20060706: consider $eh->get('input.ignore.columns')
20060717: keep order of occurance ($eh->get('intermediate.order'))
20061114: TODO : make sure predefined headers are in taken into account (::shortname!)
=cut

sub parse_header($$@){
    my $kind = shift;
    my $templ = shift;
    my @row = @_;

    unless( defined $kind and defined $templ and $#row >= 0 ) {
		$logger->fatal( '__F_PARSE_HEADER', "\tParsing header started with missing arguments!\n" );
		die;
    }

    my %rowh = ();

	my $extran = 0;
	my $skip_empty = $eh->get( 'input.ignore.columns' );
	# Possible values: 		#	nohead	:= ignore empty (default)	
							#	join	:= join all headless together into one ::extra
							#	extran	:= create a column for each 
	my $mixheader  = $eh->get( 'input.header' );
	# can be "mix", "mix,strict" and "any"
	
    for my $i ( 0 .. ( scalar( @row ) - 1 ) ) {
		if ( not defined( $row[$i] ) or $row[$i] =~ /^\s*$/ ) {
	    	$logger->warn('__I_EMPTY_HEADERC' ,
	    		"\tEmpty header in column $i, sheet-type $kind (strategy: $skip_empty)!");
	    	if ( $skip_empty =~ m/\bnohead/ ) {
	    		push( @{$rowh{'::skip'}}, $i);
	    		$row[$i] = '::skip';
	    		next;
	    	} elsif ( $skip_empty =~ m/\bextran/ ) {
	    		$row[$i] = '::__MIX_EMPTY__:' . sprintf( '%04d', $extran++);
	    	} else { # join!
	    		$row[$i] = '::__MIX_EMPTY__';
	    	}
		}
		#!wig20050614: get rid of extra whitespace
		$row[$i] =~ s/^\s+(::)/::/; # Remove leading whitespace
		if ( defined( $1 ) ) {
			$row[$i]  =~ s/\s+$//;  # Remove trailing whitespace
		}
		if ( $mixheader =~ m/strict/ and $row[$i] and $row[$i] !~ m/^::/o ) { #Header not starting with ::
	    	$logger->warn('__W_HEADER_NAME', "\tBad name in header row: $row[$i] $i, type $kind, skipping!");
	    	push( @{$rowh{'::skip'}}, $i);
	    	next;
		}
		# Get multiple columns and such ... in %rowh
		push( @{$rowh{$row[$i]}}, $i );
    }
    #
    # Are all required fields in @row, multiple rows?
    #
    for my $i ( keys( %{$templ->{'field'}} ) ) {
	    next if ( $mixheader =~ m/\bstrict/ and $i !~ m/^::/o );
		next unless ( ref( $templ->{'field'}{$i} ) eq 'ARRAY' ); # Skip if not a field template
	    if( $templ->{'field'}{$i}[2] > 0 ) { #required field
			if ( not defined( $rowh{$i} ) ) {
		    	if ( $templ->{'field'}{$i}[2] > 1 ) { # 2 -> needs to be initialized silently
					$logger->info('__I_APPEND_FIELD', "\tAppending optional data field $i.");
					push ( @row, $i );
					push ( @{$rowh{$i}} ,$#row );
		    	} else {
		    		unless ( $i =~ m/:\d+$/ ) { # Ignore ::key:N fields! 
						$logger->warn('__W_REQUIRED_HEADER', "\tMissing required field $i in input array!");
		    		}
		    	}
			}
	    }
	    if ( defined( $rowh{$i} ) and $#{$rowh{$i}} >= 1 and $templ->{'field'}{$i}[1] <= 0 ) {
			$logger->warn('__W_HEADER_MULT', "\tMultiple input header not allowed for $i!");
	    }
    }

    #
    # Initialize new fields from ::default
    # This will catch multiply defined fields, too
    #		(together with the split code below)
    #
    for my $i ( 0..(scalar( @row ) - 1 ) ) {
	    my $head = $row[$i];	
	    unless ( defined( $templ->{'field'}{$head} ) ) {
	        $logger->info('__I_HEAD_NEW', "\tAdded new column header $head");
	        @{$templ->{'field'}{$head}} = @{$templ->{'field'}{'::default'}};
	        $templ->{'field'}{$head}[4] = $templ->{'field'}{'nr'};
	        $templ->{'field'}{'nr'}++;
	    }
	    #!wig20050715: map -1 rows to get printed at end ...
	    if ( $templ->{'field'}{$head}[4] == -1 ) {
	    	$templ->{'field'}{$head}[4] = $templ->{'field'}{'nr'};
	        $templ->{'field'}{'nr'}++;
	    }
	    $templ->{'field'}{$head}[5] =$i; #!wig20060717: sort by input order ...
    }

    #
    # Split/rename muliple headers ::head becomes ::head, ::head:1 ::head:2, ::head:3 ...
    #
    my %or = (); # "flattened" ordering
    my @resort = ();
    for my $i ( keys( %rowh ) ) { # Iterate through multiple headers ...
		next if ( $mixheader =~ m/\bstrict/ and $i =~ m/^::skip/ ); #Ignore bad fields
		if ( scalar( @{$rowh{$i}} ) > 1 ) { # Multiple field header:
			my $colorder = $templ->{'field'}{'_multorder_'} || '0';
			my $reverse = 0;
			if ( $colorder =~ m/(1|RL)/o ) { # From right to left
				$reverse = 1;
			}
			my $nummultcols = scalar( @{$rowh{$i}} ) - 1;
			my @range = 0..$nummultcols;
			@range = reverse( @range ) if $reverse;
			
			# do not uniquify the first/last occurance:
			unless ( $colorder =~ m/F/o ) { #
				push( @resort, $i );
				$or{$i} = $rowh{$i}[$range[0]];
				$templ->{'field'}{$i}[5] = $rowh{$i}[$range[0]];
				shift @range;
			}
				
	    	for my $ii ( @range ) {
				my $funique = "$i:$ii";
				unless( defined( $templ->{'field'}{$funique} ) ) {
					$logger->debug('__D_SPLIT_HEAD', "\tSplit multiple column header $i to $funique");
					@{$templ->{'field'}{$funique}} = @{$templ->{'field'}{$i}};
					#lu20050624 disable required-attribute for the additional
					# headers because they do not occur in input
					$templ->{'field'}{$funique}[2] = 0;
					# Remember print order no longer is unique
					# Increase print order:
					#!wig20051025: use same number as templ, will be changed in sort
					$templ->{'field'}{$funique}[4] = $templ->{'field'}{$i}[4];
					$templ->{'field'}{'nr'}++
				}
				push( @resort, $funique );
				$or{$funique} = $rowh{$i}[$ii];
				
				#!wig20060718: getting input order:
				$templ->{'field'}{$funique}[5] = $rowh{$i}[$ii];
			}
			# Remember number of multiple header columns
			if ( not exists( $templ->{'_mult_'}{$i} ) ) {
					$templ->{'_mult_'}{$i} = $nummultcols;
			} else {
				if ( $templ->{'_mult_'}{$i} ne $nummultcols ) {
					$logger->warn('__W_HEAD_MULT_CMISM', "\tMultiple column header $i in $kind count mismatch: " .
					$nummultcols . " now, " . $templ->{'_mult_'}{$i} . " previously" );
				}
				if ( $templ->{'_mult_'}{$i} < $nummultcols ) {
					$templ->{'_mult_'}{$i} = $nummultcols;
				}
			}
		} else {
			$or{$i} = $rowh{$i}[0];
			push( @resort, $i );
		}
	}
	
    $eh->set( $kind . '.ext', scalar(keys(%or)) );
	
	if ( exists $templ->{'_mult_'} ) {
 		_mix_utils_reorder( $templ, \@resort, \%or );
	}
		
    # Finally, got the field name list ... return now
    return %or;
} # End of parse_header

#
# Multiple header are uniquified now, but print order
#   needs to be serialized
#
# Global:
#	changes $eh-> ... {$type}{'field'} ... print order
#
#!wig20061114: make sure all default fields are on-board
#  (see bug20061113a)
sub _mix_utils_reorder ($$$) {
	my $templ = shift;
	my $resortar = shift;
	my $order = shift;

	# Make sure all default fields are listed (esp. if not in input,
	# but predefined (::shortname, ::arch, ...)
	my %inlist = ();
	for my $i ( %{$templ->{'field'}} ) {
		next unless ( $i =~ m/^::/ );
		next unless ( ref( $templ->{field}{$i} ) eq 'ARRAY' );
		$inlist{$i} = 1 if ( $templ->{field}{$i}[4] > 0 and
			not $templ->{field}{$i}[5] );
	}
	for my $i ( @$resortar ) {
		delete $inlist{$i} if exists $inlist{$i};
	}
	
	# Left over in inlist -> push on $resortar
    my %temp_order = %$order;
	for my $i ( keys %inlist ) {
        #lu20091124 add to order hash as well (value ?), but do not modify the passed order hash
        $temp_order{$i} = -1;
		push( @$resortar, $i );
	}
	
	# highest multiple field with
	#  find conflicting print order the start number 
	# for my ( keys( %$order ) ) {
	# }
	my @atend = ();
	my $print_start = 1;
	for my $k ( sort { $templ->{'field'}{$a}[4] <=> $templ->{'field'}{$b}[4] or
				$temp_order{$a} <=> $temp_order{$b}; } @$resortar ) {
		next if ( $templ->{'field'}{$k}[4] == 0 );
		if ( $templ->{'field'}{$k} < 0 ) { # Save for later usage
			push( @atend , $k );
		} else {
			$templ->{'field'}{$k}[4] = $print_start++;
		}
	}

	for my $k ( @atend ) {
		$templ->{'field'}{$k}[4] = $print_start++;
	}
		
	return;
} # End of _mix_utils_reorder

####################################################################
## mix_store
## dump data (hash) on disk
##
## use $eh->get( 'internal.path' ) to define a directry != cwd()
####################################################################

=head2

mix_store ($$;$) {

Dump input data into a disk file.
Set $eh->get( 'internal.path' ) to change output directory.

=cut
sub mix_store ($$;$){
    my $file = shift;
    my $r_data = shift;
    my $flag = shift || "internal";

    #
    # attach $eh->get( $flag . '.path' ) ...
    #
    my $predir = '';
    if( $eh->get( $flag . '.path' ) ne '.' and not is_absolute_path( $file ) ) {
		$predir = $eh->get( $flag . '.path' ) . '/';
    }
    if ( -r ( $predir . $file ) ) {
		$logger->warn('__W_FILE_OVERWRITE', "\tFile $predir$file already exists! Will be overwritten!");
    }

    # Dump the data here:
    unless( Storable::nstore( $r_data, $predir . $file ) ) {
		$logger->fatal('__F_STORE', "\tCannot store date into $predir$file: " . $! . "!\n");
		exit 1;
    }

    #
    # Use Data::Dumper while debugging ...
    #    output is man-readable ....
    #
    if ( $OPTVAL{'adump'} ) {
		unless ( mix_use_on_demand( 'use Data::Dumper;' ) ) {
            $logger->error('__E_USE_DATADUMPER', "\tCannot load Data::Dumper module: $@");
            $OPTVAL{'adump'} = '';
            return;
		}
		$file .= 'a';
		unless( open( DUMP, ">$predir$file" ) ) {
	    	$logger->fatal('__F_FILE_OPEN_DUMP', "\tCannot open file $predir$file for dumping: $!");
	    	exit 1;
		}
		print( DUMP Dumper( $r_data ) );
		unless( close( DUMP ) ) {
	    	$logger->fatal('__F_FILE_CLOSE_DUMP', "\tCannot close file $predir$file: $!");
	    	exit 1;
		}
    }
    return;
}

#############################################################################
##
## load perl modules in demand ....
##
## Input: string (usually "use some::modules; use foo::bar;")
##
## Output:	0	-> failure  
##			1	-> o.k.
##
sub mix_use_on_demand ($) {
	my $module = shift;

    eval $module;
    if ($@) {
        $logger->error('__E_USE_ONDEMAND', "\tCannot load module $module; reason:\n$@");
        return 0;
	} else { 
        return 1;
    };
} # End of use_on_demand
	
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
		} else {
	    	$logger->warn( '__W_READ_BADHASH', "\tDumped data does not have $i hash!" );
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

db2array ($$$$;S$) {

convert the datastructure to a flat array
adds the header line as defined in the $eh->get( $type . '.field' ) ..

Arguments: 	$ref		:= hash reference
							-> keys are the sheet names
			$type		:= (hier|conn) sheet type
			$otype		:= output file type (xls|csv|sxc|ods)
			$filter		:= Perl_RE,if it matches a key of ref, do not print that out
			    			if $filter is an sub ref, will be used in grep
			    			e.g. used to supress printing of internal instances
			$sfilter	:= Perl_RE matching column headers to select
			$ifilter	:= Perl_RE matching column headers to remove
							Please make sure $s|ifilter also accepts trailing :N extensions
							for multiply defined columns (see xls2csv re constructor)!
			
#!wig20051014: adding output of array->hash (instead of hash->hash)
	This allows to print out an arry of hashes
#!wig20060717: sort columns by input sheet column order
#!wig20071115: sort columns by char and sort rows by alpha or input order

=cut

sub db2array ($$$$;$$) {
    my $ref		= shift;
    my $type	= shift;
    my $otype	= shift || 'xls';
    my $filter	= shift	|| '';
    my $sfilter = shift || '';
    my $ifilter = shift || '';

    unless( $ref ) {
    	$logger->error('__E_DB2ARRAY_ARGS', "\tCalled db2array without db argument!");
	    return;
    }
    $type = lc( $type );
    unless ( ref( $ref ) eq 'ARRAY' ) {
    	unless ( $type =~ m/^(hier|conn)/io ) {
			$logger->error('__E_BAD_DBTYPE', "\tBad db type $type, ne HIER or CONN!");
			return;
    	}
    	$type = ( defined( $1 ) and $1 ) ? lc($1) : lc( $type );
    }

    my @o = ();
    my %o = (); # Check for overlap ...
    my $primkeynr = 0; # Primary key identifier; defaults to ::ign 
    my $commentnr = ''; # which column has the ::comments line?
    
    # Get order for printing fields ...
    #  and the number of the comment and primary data field
    #  $eh->get( $type . '.field' ) holds headers for all detected columns!
    #
    # TODO : check if fields do overlap!
    # REFACTOR: check the returned data (ref to hash!)
    my $fields = $eh->get( $type . '.field' );
    my $printorder = $eh->get( 'intermediate.order' );
    my $mixheader  = $eh->get( 'input.header' );
    
	# Warning: we assume that $eh{$type.field} matches the incoming data hash
	# There will be no checks to prevent mismatch!
    for my $ii ( sort( keys( %$fields ) ) ) {
    	# Ignore non mix-headers if it does not start with ::
		next if ( $mixheader =~ m/\bstrict/ and $ii !~ m/^::/o );
		next unless ( ref( $fields->{$ii} ) eq 'ARRAY' ); # Skip if not a field template
		# If hfilter is set -> Skip if $ii matches
		next if ( $sfilter and $ii !~ m/$sfilter/ );
		next if ( $ifilter and $ii =~ m/$ifilter/ );

		if ( $printorder =~ m/\b(col:)?template/ ) {		
			# Sort by template order
			if ( $fields->{$ii}[4] > 0 ) { # and exists( $fields->{$ii}[5] ) )
				if ( exists( $o{$fields->{$ii}[4]} ) ) {
					$logger->warn('__W_', "\tintermediate output column conflict!");
				} else {
					$o{$fields->{$ii}[4]} = $ii;
				}
				# Take print order for all fields used ...
				$o[$fields->{$ii}[4]] = $ii; # Print Order ...
			}
			if ( $eh->get( $type . '.key' ) eq $ii ) {
	    		$primkeynr = $fields->{$ii}[4];
			} elsif ( $ii eq '::comment' ) {
	    		$commentnr = $fields->{$ii}[4];
			}
		} elsif ( $printorder =~ m/\b(col:)?alpha/ ) {
			#!wig20071115: sort columns by char:
			push( @o, $ii );
			if ( $eh->get( $type . '.key' ) eq $ii ) {
	    		$primkeynr = scalar( @o ) - 1;
			} elsif ( $ii eq '::comment' ) {
	    		$commentnr = scalar( @o ) - 1;
			}
		} else {
			# Sort by input order (saved in [5])
			if ( exists( $fields->{$ii} ) and ref( $fields->{$ii} ) eq 'ARRAY' ) {
				if ( defined( $fields->{$ii}[5] ) ) {
					$o[$fields->{$ii}[5]] = $ii;
					if ( $eh->get( $type . '.key' ) eq $ii ) {
	    				$primkeynr = $fields->{$ii}[5];
					} elsif ( $ii eq '::comment' ) {
	    				$commentnr = $fields->{$ii}[5];
					}
				} else {
					$logger->info( '__I_DBARRAY_ORDER', "\tWill not print column: $ii" );
				}
			}
		}	
    }
	
	#!wig20060712: remove empty/filtered columns
	my @oo = ( undef() );
	for my $o ( @o ) {
	 	push( @oo, $o ) if ( defined( $o ) );
	}
	@o = @oo;

    my @a = ();
    my $n = 0;

	( $n , @a ) = _mix_utils_im_header( uc($type) , $otype, \@o );

	my @keys = _filter_sheets ( $ref, $filter, ( $type eq 'conn' ) ? $printorder : '' );

    #WORKAROUND
    #wig20040322: adding ugly ::workaround back to originating column,
    # if the workaround field is set, push value back into defining column
    # see below for undo ...
    my $wa_flag = 0;
    unless( ref( $ref ) eq 'ARRAY' ) {
    	for my $i ( @keys ) { # Skipped if input is array-ref
        	if( $ref->{$i}{'::workaround'} ) {
            	$wa_flag = 1;
            	for my $wa ( split( /,/, $ref->{$i}{'::workaround'} ) ) {
                	my ( $n, $col, $val ) = split( /::/, $wa, 3 ); #  ::col::val,::colb::valb
                    	if ( $val =~ m,__(\w+)__,o ) { # Convert back __KEY__ -> %KEY%
                        	$val = "%" . $1 . "%";
                    	}
                    	$ref->{$i}{"::" . $col} .= $val;
            	}
        	}
    	}
    }

    # Maximum cell length:
    my $maxlength = $eh->get( 'format.' . $otype . '.maxcelllength' ); # 0 -> unlimited
    unless( defined( $maxlength ) ) {
    	$maxlength = $eh->get( 'format.xls.maxcellllength' );
    }
    # Now comes THE data
    for my $i ( @keys ) {
		my $split_flag = 0; # If split_flag 
		my $refdata = '';
		if ( ref( $ref ) eq 'ARRAY' ) {
			$refdata = $ref->[$i];
		} else {
			$refdata = $ref->{$i};
		}
		for my $ii ( 1..(scalar( @o ) - 1 ) ) { # 0 contains fields to skip
	    	next unless defined( $o[$ii] ); #!wig20051014: Bad field detected
	    	
	    	if ( $o[$ii] =~ m/^::(in|out)\s*$/o and
	    		  ref( $refdata->{$o[$ii]} ) eq 'ARRAY'  ) {
	    		  # ::in and ::out are special
	    		  # TODO -> get that into objects
				$a[$n][$ii-1] = inout2array( $refdata->{$o[$ii]}, $i );
	    	} else {
				$a[$n][$ii-1] = defined( $refdata->{$o[$ii]} ) ? $refdata->{$o[$ii]} : "%UNDEF_1%";
	    	}
	    	
	    	if ( $maxlength and ( length( $a[$n][$ii-1] ) > $maxlength ) ) {
				# Line too long! Split it!
				# Assumes that the cell to be split are accumulated when reused later on.
				# Will not check if that is not true!
				if ( $ii - 1 == $primkeynr ) {
		    		$logger->warn( '__W_SPLIT_KEY', "\tSplitting key of table: " .
		    			substr( $a[$n][$ii-1], 0, 32 ) );
				}
				#BAD: $split_flag=1;
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
	    		if ( $primkeynr ) {
					$a[$n + $sn][$primkeynr-1] = $a[$n][$primkeynr-1];
	    		}
				if ( $commentnr ne '' ) { # Add split comment
		    		$a[$n + $sn][$commentnr-1] .= "# __I_SPLIT_CONT_$sn";
				}
                # Make sure all cells are defined
                for my $ssn ( 0..(scalar( @{$a[$n]} ) - 1) ) {
                    $a[$n + $sn][$ssn] = '' unless defined( $a[$n + $sn][$ssn] );
                }                    
	    	}
	    	$n += $split_flag; # Goto next free line ...
		} else {
	    	$n++;
		}
    }

    # WORKAROUND :
    # undo the change above ....
    #wig20040322:
    if ( $wa_flag ) {
        for my $i ( @keys ) {
            if( $ref->{$i}{'::workaround'} ) {
                for my $wa ( split( /,/, $ref->{$i}{'::workaround'} ) ) {
                    my ( $n, $col, $val ) = split( /::/, $wa, 3 ); #  ::col::val,::colb::valb
                        if ( $val =~ m,__(\w+)__,o ) { # Convert back __KEY__ -> %KEY%
                            $val = "%" . $1 . "%";
                        }
                        $ref->{$i}{"::" . $col} =~ s,$val,,; #Remove it ...
                }
            }
        }
    }
    
    return \@a;

} # End of db2array
 
#
# Select sheets to print based on $filter
#!wig20060712	
#!wig20071115: add row sort order switch row:alpha (default) or row:input
#		for CONN sheets, only
#
sub _filter_sheets ($$;$) {
	my $ref		= shift;
	my $filter	= shift;
	my $order	= shift || '';
		
	# Prepare keys (if $ref is HASH ref)
    my @keys = ();
    if ( ref( $ref ) eq 'HASH' ) {
		if ( $filter ) { # Filter the keys ....
			if ( ref( $filter ) eq "CODE" ) {
	    		@keys = grep( &$filter, keys( %$ref ) );
			} else {
	    		@keys = grep( !/$filter/, keys( %$ref ) );
			}
		} else {
			@keys = keys( %$ref );
		}
		# Define output sort order:
		if ( $order =~ m/\brow:input/ ) {
			# sort by ::connnr (if type == CONN)
			@keys = sort( { $ref->{$a}{'::connnr'} <=> $ref->{$b}{'::connnr'} } @keys );
		} else { # row:alpha
			@keys = sort( @keys );
		}
    } elsif ( ref( $ref ) eq 'ARRAY' ) {
    	@keys = 0..(scalar(@$ref) - 1 ); # array from 0..N
    } else {
		# CANNOT continue here
		$logger->fatal( '__F_BAD_REF',
			"\tincoming data \$ref is neither ref to HASH nor ARRAY, but:" .
				( ref($ref) || '' ) );
		exit 1;
	}
    return @keys;
} # End of _filter_sheets

####################################################################
## db2array_intra
## convert internal db structure to array
####################################################################

=head2

db2array_intra ($$$$$) {

convert the datastructure to a hash with flat array
adds the header line as defined in the $eh->get( $type . '.field' ) ..

Currently for "CONN" sheets, only!

Arguments: 	$ref    := hash reference
			$type   := (hier|conn)
			$filter := Perl_RE,if it matches a key of ref, do not print that out
			    		if $filter is an sub ref, will be used in grep

Global:
	$eh->get( 'intermediate.intra' )
		keys for splitting ...
	# 'intra'	=> '',	# if set create seperate conn sheets for instances:
	#	INTRA		-> CONN and INTRA_CONN
	#	TOP			-> CONN_<TOP> and CONN
	#	TOP,INTRA	-> CONN_<TOP> and CONN_INTRA
	#	INST[ANCE]	-> create one conn sheet for each instance, named: CONN_<instance>

TODO
	Merge back with db2array
				
=cut

sub db2array_intra ($$$$$) {
    my $ref		= shift;
    my $type	= shift;
    my $tops	= shift; # List ref with top hierdb tree objects
    my $hierref	= shift;
    my $filter	= shift;

    unless( $ref and ref( $ref ) ) {
    	$logger->error( '__E_FUNC_ARGS', "\tCalled db2array_intra without db argument!");
	    return;
    }
    unless ( $type =~ m/^(conn)/io ) {
		$logger->error('__E_BADDBTYPE', "\tBad db type $type, ne CONN!");
		return;
    }
    $type = lc($1);

    my @o = ();
    my $primkeynr = 0; # Primary key identifier
    my $commentnr = '';
    
    # Get order for printing fields ...
    # TODO check if fields do overlap!
    my $field = $eh->get( $type . '.field' );
    for my $ii ( keys( %$field ) ) {
		next unless ( $ii =~ m/^::/o );
		# Only print if PrintOrder > 0:
		if ( $field->{$ii}[4] > 0 ) {
			$o[$field->{$ii}[4]] = $ii; # Print Order ...
		}
		if ( $eh->get( $type . '.key' ) eq $ii ) {
	    	$primkeynr = $field->{$ii}[4];
		} elsif ( $ii eq '::comment' ) {
	    	$commentnr = $field->{$ii}[4];
		}
    }

	#
	# Define split mode:
	#
	# 'intra'	=> '',	# if set create seperate conn sheets for instances:
	#	INTRA		-> CONN and INTRA
	#	TOP			-> CONN_<TOP> and CONN
	#	TOP,INTRA	-> CONN_<TOP> and CONN_INTRA
	#	INST[ANCE]	-> create one conn sheet for each instance, named: CONN_<instance>
	#					rest goes to CONN_MIX_REST
	my %names = ();
	my $intra = $eh->get( 'intermediate.intra' );
	my $splitmode = 'all';

	my $top = $tops->[0]->name; # Name of top instance
	my $topre = '^(';			# Regular expression matching all tops (should be one!)
	for my $t ( @$tops ) {
		$topre .= $t->name . '|';
	}
	$topre =~ s/\|$//;
	$topre .= ')$';
	
	if ( $intra =~ m/\btop\b/io and $intra =~ m/\bintra\b/io ) {
		$names{'top'} = 'CONN_' . $top;
		$names{'intra'} = 'CONN_INTRA';
		$splitmode = 'top';
	} elsif ( $intra =~ m/\btop\b/io ) {
		$names{'top'} = 'CONN_' . $top;
		$names{'intra'} = 'CONN';
		$splitmode = 'top';
	} elsif ( $intra =~ m/\bintra\b/io ) {
		$names{'top'} = 'CONN';
		$names{'intra'} = 'INTRA';
		$splitmode = 'top';
	} else { # Not really needed, go to mode 'all'
		$names{'top'} = 'CONN_TOP';
		$names{'intra'} = 'INTRA';
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

    #WORKAROUND: repace __MAC__ by a %MAC% before writing out and undo after!
    #wig20040322: adding ugly '::workaround' back to originating column,
    # if the workaround field is set, push value back into defining column
    # see below for undo ...
    my $wa_flag = 0;
    for my $i ( sort( @keys ) ) {
        if( $ref->{$i}{'::workaround'} ) {
            $wa_flag = 1;
            for my $wa ( split( /,/, $ref->{$i}{'::workaround'} ) ) {
                my ( $n, $col, $val ) = split( /::/, $wa, 3 ); #  ::col::val,::colb::valb
                    if ( $val =~ m,__(\w+)__,o ) { # Convert back __KEY__ -> %KEY%
                        $val = "%" . $1 . "%";
                    }
                    $ref->{$i}{"::" . $col} .= $val;
            }
        }
    }

    # Now comes THE data
    my %a = (); # has with split tables
    my %n = ();  # lines in split tables
    
    for my $i ( sort( @keys ) ) {

		my $apply = inout2intra( $splitmode, $topre, \%names, 
			$i, $ref->{$i}{'::out'}, $ref->{$i}{'::in'} );

		for my $a ( keys %$apply ) { # Iterate over all tables (instances) ...
			my $istop = exists( $apply->{$a}->{'istop'} ) ? 1 : 0;
			unless ( exists $a{$a} ) { # New table
				my $instances = join( ' ', keys %{$apply->{$a}{'name'}} );
				my $title = $instances . ' (' . $type . ')';
				if ( $istop ) {
					( my $toplist = $topre ) =~ s/\|/ /;
					$toplist =~ s/^\^\(//;
					$toplist =~ s/\)\$$//;
					$title .= ", top: " . $toplist; 
				}
				( $n{$a} , @{$a{$a}} ) = _mix_utils_im_header( $title , 'xls', \@o );
			}

			my $split_flag = 0; # If split_flag
			# Read ::in and ::out if available ...
			
			for my $ii ( 1..$#o ) { # 0 contains fields to skip
	    		#wig20031106: split on all non key fields! 
	    		if ( $o[$ii] =~ m/^::(in|out)\s*$/o ) {
	    			# use the data from inout2intra
					$a{$a}[$n{$a}][$ii-1] = defined( $apply->{$a}->{$1} ) ?
						$apply->{$a}->{$1} : '';
	    		} else {
					$a{$a}[$n{$a}][$ii-1] = defined( $ref->{$i}{$o[$ii]} ) ?
							$ref->{$i}{$o[$ii]} : "%UNDEF_1%";
					# Map I,O,IO on top sheet to other values
					if ( $istop and $o[$ii] eq '::mode'
	    				and $eh->get( 'intermediate.topmap' ) ) {
	    				# Does this signal match the list?
	    				my $meh = $eh->get( 'intermediate.__topmap_re__');
	    				if ( $eh->get( 'intermediate.topmap' ) eq 'ALL' or
	    					$ref->{$i}{'::name'} =~ m/$meh/ ) {
	    						$a{$a}[$n{$a}][$ii-1] =~ s/(\w+)/%TM_$1%/;
	    				}
					}
	    		}
	    		if ( length( $a{$a}[$n{$a}][$ii-1] ) > $eh->get( 'format.xls.maxcelllength' ) ) {
					# Line too long! Split it!
					# Assumes that the cell to be split are accumulated when reused later on.
					if ( $ii - 1 == $primkeynr ) {
		    			$logger->warn( '__W_SPLIT_KEY',
		    					"\tSplitting key of table: " .
		    					substr( $a{$a}[$n{$a}][$ii-1], 0, 32 ) );
					}
					$split_flag=1;
					my @splits = mix_utils_split_cell( $a{$a}[$n{$a}][$ii-1] );

					# Prefill the split data .... key will be added later
					#Caveat: order should not matter!!
					for my $splitn ( 0..(scalar( @splits ) - 1 )  ) {
						$a{$a}[$n{$a} + $splitn][$ii-1] = $splits[$splitn];
					}
					$split_flag = scalar( @splits ) if ( $split_flag < scalar( @splits ) );	
	    		}
			}
			#This was a split cell?
			if ( $split_flag > 1 ) {
	    		# Set primary key in cells, add comments
	    		for my $sn ( 1..( $split_flag - 1 ) ) {
					$a{$a}[$n{$a} + $sn][$primkeynr-1] = $a{$a}[$n{$a}][$primkeynr-1];
					if ( $commentnr ne '' ) { # Add split comment
		    			$a{$a}[$n{$a} + $sn][$commentnr-1] .= "# __I_SPLIT_CONT_$sn";
					}
                	# Make sure all cells are defined
                	for my $ssn ( 0..(scalar( @{$a{$a}[$n{$a}]} ) - 1) ) {
                    	$a{$a}[$n{$a} + $sn][$ssn] = '' unless defined( $a{$a}[$n{$a} + $sn][$ssn] );
                	}                    
	    		}
	    		$n{$a} += $split_flag; # Goto next free line ...
			} else {
	    		$n{$a}++;
			}
    	}
    }
    
    #WORKAROUND:
    # undo the change above ....
    #wig20040322:
    if ( $wa_flag ) {
        for my $i ( sort( @keys ) ) {
            if( $ref->{$i}{'::workaround'} ) {
                for my $wa ( split( /,/, $ref->{$i}{'::workaround'} ) ) {
                    my ( $n, $col, $val ) = split( /::/, $wa, 3 ); #  ::col::val,::colb::valb
                        if ( $val =~ m,__(\w+)__,o ) { # Convert back __KEY__ -> %KEY%
                            $val = "%" . $1 . "%";
                        }
                        $ref->{$i}{"::" . $col} =~ s,$val,,; #Remove it ...
                }
            }
        }
    }
    
    return \%a;

}

#
# inout2intra:
#  Parse inout and create inout per instance or top/non-top
#
# Input:
#   <see below>
#
# Output:
#	hash with conn names and split ::out/::in fields
#
# Global: n/a
#
# TODO : handling of generics, parameters and constants
#		constants -> need to be written on the driver sheet		
sub inout2intra ($$$$$$) {
	my $mode	= shift; # top or all ...
	my $topre	= shift; # if mode is top -> use this to see if instance matches top or not
	my $namem	= shift; # Name map for top -> top and intra
	my $signal	= shift; # Signal name here
	my $r_out	= shift; # 
	my $r_in	= shift; # 

	my %split = ();
	my %ssplit = ();
	# Get
	my %string = (); 
	@{$string{'out'}} = inout2array( $r_out, $signal, 1 );
	@{$string{'in'}}  = inout2array( $r_in,  $signal, 1 );
	
	# Split the strings and sort them into the right hash slice:
	for my $io ( qw( out in )) {
		for my $ios ( @{$string{$io}} ) {
			# Get instance:
			my $inst = "OTHERS";
			if ( $ios =~ m,^([^/]+)/, ) {
				$inst = $1;
			}
			# TODO : Handle constants!!
			if ( $mode eq 'top' ) {
				if ( $inst =~ m/$topre/ ) {
					push( @{$split{$namem->{'top'}}{$io}}, $ios); # TODO : get correct nl back
					$ssplit{$namem->{'top'}}{'istop'} = 1;
					$ssplit{$namem->{'top'}}{'name'}{$inst} = 1;				
				} else {
					push( @{$split{$namem->{'intra'}}{$io}}, $ios);
					$ssplit{$namem->{'intra'}}{'name'}{$inst} = 1;
				}
			} elsif ( $mode eq 'all' ) {
				my $conn_inst = $eh->get( 'intermediate.instpre' ) . $inst;
				push( @{$split{$conn_inst}{$io}}, $ios );
				$ssplit{$conn_inst}{'name'}{$inst} = 1;
				if ( $inst =~ m/$topre/ ) {
					$ssplit{$conn_inst}{'istop'} = 1;
				}	
			}
		}
	}

	# Rework the stringe and join ...
	for my $inst ( keys %split ) {
		for my $io ( qw ( out in ) ) {
			if ( exists ( $split{$inst}{$io} ) ) {
				$ssplit{$inst}{$io} = _inoutjoin( $split{$inst}{$io} );
			}
		}
	}
	return \%ssplit;

}

#
# Create an array to be used as table header in intermediate data output
#
# Input:
#	$o	.= ref to ordered input fields ( the ::a ::b header)
#
# Output:
#	$n   number of lines
#   @a   array(array)
#
#!wig20051012
#!wig20051018: undo the :N extension for multiple fields
#!wig20060717: skip MIX header if format.$outtype.mixhead is not set
sub _mix_utils_im_header ($$$) {
	my $title = shift;
	my $outtype = shift || 'xls';
 	my $o = shift;

	my @a = ();
	my $n	= 0;

	my $headon = 1;
	if ( $outtype =~ m/^(xls|csv|ods|sxc)$/ ) {
		$headon = $eh->get( 'format.' . $1 . '.mixhead' );
	}
	 
	# Check if there is one multiple header ( ::HEAD:\d )
	my $hasmult = 0;
	for my $hm ( @$o ) {
		if ( defined $hm and $hm =~ m/:\d+$/ ) {
			$hasmult = 1;
			$n++;	# Switch to next line immediately!
			last;
		}
	}
	
	# Print duplicate header line:
    for my $ii ( 1..(scalar @$o - 1) ) {
    	if ( $hasmult ) {
			( $a[$n-1][$ii-1] = $o->[$ii] ) =~ s/:\d+$//o;
			$a[$n][$ii-1] = '# ' . $o->[$ii];	
    	} else {
    		$a[$n][$ii-1] = $o->[$ii];
    	}
    }
    $n++;

    # Print comment: generator, args, date
    # Assume: first column is ::ign :-)
    # As we are lazy, we will leave the rest of the line undefined ...
	if ( $headon =~ m/\b(1|yes|on|true)\b/ ) {
    	my %comment = ( qw( by %USER% on %DATE% cmd %ARGV% ));
    	$a[$n++][0] = "# Generated Intermediate Data: $title";
    	for my $c ( qw( by on cmd ) ) {
			$a[$n++][0] = "# $c: " . $eh->get( 'macro.' . $comment{$c} );
    	}
	}

	# Even remove duplicate header if $headon eq nomulthead!
	#!wig20060718
	if ( $hasmult == 1 and $headon =~ m/\bnomulthead/ ) {
		$n = 1;
		$logger->info( '__I_WRITE_HEADER', "\tRemoving explanatory header: " .
			join( ' ', @{$a[1]} ) );
		delete( $a[1] );
	}
	
	return $n, @a;
} # End of _mix_utils_im_header

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
##!wig20050713: limit to maxcelllength ...!
####################################################################
sub mix_utils_split_cell ($) {

    my $data = shift;
    my $flaga = 0;

	my $maxlengthexcel = $eh->get( 'format.xls.maxcelllength' );
    # Get pieces up to 1023/500 characters, seperated by ", %IOCR%"
    my $iocr = $eh->get( 'macro.%IOCR%' );
    my @chunks = ();

    while( length( $data ) > $maxlengthexcel ) {
		my $tmp = substr( $data, 0, $maxlengthexcel ); # Take 1023 chars
		# Stuff back up to last %IOCR% ...
		my $ri = rindex( $tmp, $iocr ); # Read back until next <CR>
		if ( $ri <= 0 ) { # No $iocr in string -> split at arbitrary location ??
	    	push( @chunks, $tmp );
	    	substr( $data, 0, $maxlengthexcel ) = "";
	    	$logger->info( '__I_SPLIT_CELL', "\tSplit cell at arbitrary location: " . substr( $tmp, 0, 32 ) )
				unless $flaga;
	    	$flaga = 1;
		} else {
	    	if ( $flaga ) {
				$logger->warn( '__W_SPLIT_CELL', "\tCell split might produce bad results, iocr detection failed: " .
		    		substr( $chunks[0], 0, 32 ) );
	    	}
	    	substr( $data, 0, $ri ) = ''; # Take away leading chars
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

inout2array ($;$$) {

convert the in/out datastructure to a string (comma seperated)

Input:
	$ref    := hash reference
	$type  := (hier|conn)
	$aflag := if set, return array instead of simple string
	
Output:
	inout_string
	
=cut
sub inout2array ($;$$) {
    my $f = shift;
    my $o = shift || '';
    my $aflag = shift || 0;

    unless( defined( $f ) ) { return "%UNDEF_2%"; };

    my @s = (); # Holds data, ready to be sorted in a final step ...

#       '::out' => [
#
#                     'sig_t' => undef,
#                     'port' => '%name%',
#                     'sig_f' => undef,
#                     'inst' => 'u_ddrv4',
#	               'port_t' => undef,
#                     'port_f' => undef
#		    	'cast' => cast_func ....
#				'rorw' => "reg" or "wire"
#                   }
#                 ],

    #!wig20040628: define output sort order
    for my $i ( @$f ) {
		my $cast = "";
		unless( defined( $i->{'inst'} ) ) {
	    	next;
		}
		if ( exists( $i->{'cast'} ) ) {
	    	$cast = "'" . $i->{'cast'};
		}
		#!wig20051024: adding 'reg|wire back again:
		if ( exists( $i->{'rorw'} ) ) {
			$cast .= "'" . $i->{'rorw'};
		}
		
		# Constants are working a different way:
		#: m,^\s*(__CONST__|%CONST%|__GENERIC__|__PARAMETER__|%GENERIC%|%PARAMETER%),o ) {
		# TODO make sure sig_t/sig_f and port_t/port_f are defined in pairs!!
		if ( $i->{'inst'} =~ m,^\s*(__CONST__|%CONST%),o ) {
            # TODO !wig20040330: print out "rvalue" instead of "port"??
            #!wig20040817: write back partial asisgnment's, too.
           	if ( defined $i->{'sig_t'} and defined $i->{'sig_f'} ) {
               	my $pf = $i->{'port_f'} || "";
               	my $pt = $i->{'port_t'} || "";
               	my $p = "";
               	if ( $pf ) {
                   	$pt = $pt || 0; # Set to zero!
                   	$p = "(" . $pf . ":" . $pt . ")";
               	}
               	my $s = "=(" . $i->{'sig_f'} . ":" . $i->{'sig_t'} . ")";
               	push( @s,  $i->{'port'} . $cast . $p . $s . ", %IOCR%" );
           	} else {
               	push( @s,  $i->{'port'} . $cast . ", %IOCR%" );
           	}
		} elsif ( defined $i->{'sig_t'} and $i->{'sig_t'} ne '' ) {
		# inst/port($port_f:$port_t) = ($sig_f:$sig_t)
    		if ( defined $i->{'port_t'} and $i->{'port_t'} ne '' ) {
				push( @s, $i->{'inst'} . "/" . $i->{'port'} . $cast . "(" .
					$i->{'port_f'} . ":" . $i->{'port_t'} . ")=(" .
					$i->{'sig_f'} . ":" . $i->{'sig_t'} . "), %IOCR%" );
    		} else {
			# TODO inst/port = (sf:st)  vs. inst/port(0:0) = (sf:st)
				push( @s,  $i->{'inst'} . "/" . $i->{'port'} . $cast . "=(" .
					$i->{'sig_f'} . ":" . $i->{'sig_t'} . "), %IOCR%" );
    		}
		} else {
    		if ( defined $i->{'port_t'} and $i->{'port_t'} ne '' ) {
				push( @s,$i->{'inst'} . "/" . $i->{'port'} . $cast . "(" .
					$i->{'port_f'} . ":" . $i->{'port_t'} . # ")=(" .
					"), %IOCR%" );
    		} else {
			# If this is %OPEN% and neither port nor signal defined -> set to (0)
				if ( $o =~ m,%OPEN(_\d+)?%,o ) {
	    			push( @s, $i->{'inst'} . "/" . $i->{'port'} . $cast . "(0:0)=(0:0)" . ", %IOCR%" );
				} else {
	    			push( @s,  $i->{'inst'} . "/" . $i->{'port'} . $cast . ", %IOCR%" );
				}
    		}
		}
   	}

    # If called with array_flag -> return array
    #!wig20051012
    if ( $aflag ) {
    	return @s;
    }

	return( _inoutjoin( \@s ) );
}
    
#
# Join an array of inout strings and return string
#
# Input:
#	array_ref
#
# Output:
#	joined string
#
# Global:
#	reads/writes %EH (%IOCR%)!
#	
sub _inoutjoin ($) {

	my $aref = shift;
    # Join the data    
    my $s = join( '', @$aref );

	#  find a single :) or (: and error
    if ( ( $s =~ m,\(:,o ) or ( $s =~ m,:\),o ) ) {
		$logger->error( '__E_INOUT_BAD_BRANCH',
			"\tinout2array missing ::high or ::low definition: " . $s );
    }

	# Replace the <cr> if any
    $s =~ s/,\s*%IOCR%\s*$//o; #Remove trailing CR
    # convert macros (parse_mac already done )!!!
    my $iocr = $eh->get( 'macro.%IOCR%' );
    $s =~ s,%IOCR%,$iocr,g;

    return $s;
}


####################################################################
## convert two dim. input arry into a one-dim. array.
## by concatenation the cells with \t@@@\t
####################################################################
#wig20030716: use first line as header descriptions, field seperator!!
#wig20040324: if we read in FOO-mixed.xls and are not writing xls (e.g. not on mswin)
#wig20040628: sort cells that contain ","
#wig20050926: remove duplicate , ....
#   -> remove \n in in/out ...
sub two2one ($) {
    my $ref = shift;

    my @out = ();
 
    no warnings; # switch of warnings here, values might be undefined ...
    # Convert two dim. input array into one-dimensional
    for my $n ( @$ref ) {            
		my $l = join( '@@@', map { join( ",", sort( split( /[\s\n]*,[\s\n]*/ ) ))} @$n ); # Use @@@ as field seperator ...
		$l =~ s/\t+/\t/og;	# Remove multiple \t
		$l =~ s/\t$//o; 	# Convert trailing \t to nothing ....
		$l =~ s/,\s*,/,/og; # Remove duplicate ,
		$l =~ s/,\s*$//o;	# Remove trailing ,
		push( @out, $l );
    }
    if ( $eh->get( 'output.delta' ) !~ m/space/ ) {
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
	    $logger->warn( '__W_FIELD_NUMBER',
	    	"\tBad number of fields found in write_delta_excel!" );
	}
	my @w = map( { length( $_ ) }@fields );
	for my $i ( @w ) {
	    if ( $i > 1024 * 10 ) { # reg expression seems to be limited to 32766 chars ..
			$logger->warn( '__W_SPLIT_FIELD',
				"\tCannot split field with $i chars in delta mode!" );
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

#
# Print out message limits hit
#
sub _sum_loglimit_eh ($) {
	my $eh = shift;
	
	my $loglimit = $eh->get( 'log.limit' );
	my $logcount = $eh->get( 'log.count' );
	for my $category ( qw( re tag level ) ) {
		next unless exists ( $logcount->{$category} );
		for my $k ( sort( %{$logcount->{$category}} ) ) {
			# In tag category the key to limit is just the trailing part ...
			my $kl = $k;
			if ( $category eq 'tag' ) { # TODO : check if that catches all messages
				( $kl = $k ) =~ s/^__(\w)_.*/$1/;
			}
			if ( exists $loglimit->{$category}->{$kl} and
				$logcount->{$category}{$k} > $loglimit->{$category}{$kl} ) {
				$logger->info( "SUM: Loglimit for $category/$k:\t" .
					( $logcount->{$category}{$k} - $loglimit->{$category}{$kl} ) );
			}
		}
	}
} # End of _sum_loglimit_eh


####################################################################
## write_sum
## write out summary informations
####################################################################

=head2

write_sum ()

write out various summary information like number of changed files, generated wires

=cut

sub write_sum () {
    # TODO Shift function to other module ... ??

    # If we had 'inpath' verify mode, summarize left-over "golden" hdl files.
    if ( $eh->get( 'check.hdlout.path' ) and
    		$eh->get( 'check.hdlout.mode' ) =~ m,\binpath\b,io ) {
        mix_utils_loc_sum();
    }

    # If we scanned an IO sheet -> leave number of generated IO's in ..

    # Parsed input sheets:
    $logger->info( "============= SUMMARY =================" );
    $logger->info( "SUM: Summary of checks and created items:" );
    my $esum = $eh->get( 'sum' );
    for my $i ( sort( keys( %$esum ) ) ) {
        $logger->info( "SUM: $i $esum->{$i}" );
    }
    $logger->info( "======== ERRORS and WARNINGS ============" );
    $logger->info( "SUM: Number of messages logged:" );
    $esum = $eh->get( 'logs' );
    for my $i ( sort( keys( %$esum ) ) ) {
        $logger->info( "SUM: $i $esum->{$i}" );
    }

	# Log messages limited:
	_sum_loglimit_eh( $eh );
	
	# Overall run-time
	$logger->info( 'SUM: runtime: ' . ( time() - $eh->get( 'macro.%STARTTIME%' ) ) .
			' seconds' );

    $logger->info( "SUM: === Number of parsed input tables: ===" );
    for my $i ( qw( conf hier conn io i2c xml top_level) ) {
        $logger->info( "SUM: $i " . $eh->get( $i . '.parsed' ) );
    }

    # Summarize number of mismatches and not matchable hdl files
    $logger->info( "SUM: Number of verify issues: " . $eh->get( 'DELTA_VER_NR' ))
        if ( $eh->get( 'check.hdlout.path' ) );

    my $fdiff = 0;
    my $ldiff = 0;
    # Delta mode: return status equals number of changes
    if ( $eh->get( 'output.generate.delta' ) or $eh->get( 'report.delta' ) ) {
        $logger->info( "SUM: Number of changes in intermediate: " . 
        	$eh->get( 'DELTA_INT_NR' ) );
        $logger->info( "SUM: Number of changed files: " .
        	$eh->get( 'DELTA_NR' ));
		#!wig20060522: report added/removed files
		$fdiff = _sum_filediff();
		$logger->info( "SUM: Filelist compare result: " . $fdiff );
		$ldiff = _sum_errdiff();
		$logger->info( "SUM: Number of unexpected errors: " . $ldiff );
    }
    
    return $eh->get( 'DELTA_NR' ) + $eh->get( 'DELTA_INT_NR' ) +
    				$eh->get( 'DELTA_VER_NR' ) + $fdiff + $ldiff;

} # End of write_sum

#
# Count differences of log.limit.test.RE (soll) vs.
# number of yielded messages log.count.test.RE (ist)
#
sub _sum_errdiff () {
	
	my $llt = $eh->get( 'log.limit.test' );
	my $llc = $eh->get( 'log.count.test' );
	my $diff = 0;
	
	if ( scalar( keys( %$llt ) ) == 0 ) {
		$logger->info( '__I_NO_LOGDIFFTEST', "\tChecks for error/warnings not applied" );
	} else {
		$logger->info( '__I_LOGDIFFTEST', "\tChecking selected log messages occurance" );
	}
	
	for my $res ( keys( %$llt ) ) { 
		my $soll = $llt->{$res};
		my $ist  = ( exists( $llc->{$res} ) ) ? $llc->{$res} : 0;
		# If $soll == 0 -> $llc does not to have exist! 
		if ( $soll != $ist ) {
			# Found a diff: wrong message count
			$logger->error( '__E_LOGDIFFTEST', "\tCount for message $res is " .
				$ist . ", differs from expected " . $soll );
				$diff++;
		}
	}
	
	return $diff;
}

#
# Compare my created list with the expected filelist
# Print out in case it differs
#!wig20060523	
sub _sum_filediff () {
	
	my $soll = $eh->get( 'output.generate.deltafiles' );
	my $ist  = mix_utils_report_hdlfiles(); 

	my $delta = 0;
	# Compare $soll and $ist
	if ( scalar( @$soll ) ) {
		my %soll = ();
		for my $s ( @$soll ) {
			$soll{$s} = 1;
		}
		for my $i ( @$ist ) {
			if ( exists( $soll{$i} ) ) {
				delete $soll{$i};
			} else {
				# Found a diff: created file not expected
				$logger->error( '__E_DELTAFILE', "\tUnexpected file created: $i" );
				$delta++;
			}
		}
		# Is there anything left over:
		for my $s ( keys %soll ) {
			$delta++;
			$logger->error( '__E_DELTAFILE', "\tExpected file not created: $s" );
		}
	} else {
		$logger->error( '__E_DELTAFILE', "\tDid not get list of files to expect" );
		$delta = -1;
	}
	return $delta;
} # End of _sum_filediff

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

    my $inext  = join( '|', values( %{$eh->get( 'input.ext'  )} ) );
    my $outext = join( '|', values( %{$eh->get( 'output.ext' )} ) );
    my $output = '';
    my $input  = '';

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
	    	$logger->warn( '__W_INITFILE', "\tFound file $i not matching my extension set. Skipped!" );
		}
    }

    if ( scalar( @descr ) > 1 ) {
		$logger->warn( '__W_INIT_IGNORE', "\tIgnoring all but last mix input files!" );
		$output = pop( @descr );
    } elsif ( scalar( @descr ) < 1 ) {
		# User has not given an output file name -> take directory name
		if ( defined $OPTVAL{'dir'} and $OPTVAL{'dir'} ne '.' ) {
	    	$output = $OPTVAL{'dir'} . '/' . basename( $OPTVAL{'dir'} );
		} else {
	    	$output = $eh->get( 'cwd' ) . '/' . basename($eh->get( 'cwd' ));
		}

		# Extension: MS-Win -> xls, else csv
		if ( ( $eh->get( 'iswin' ) or $eh->get( 'iscygwin' ) ) ||
				$eh->get( 'intermediate.ext' ) =~ m/^xls$/) {
	    	$output .= '.xls';
		}
		elsif( $eh->get( 'intermediate.ext' )=~ m/^sxc$/) {
	    	$output .= '.sxc';
		}
		else {
	    	$output .= '.csv';
		}
		$logger->warn( '__W_PROJECT_SET', "\tSetting project name to $output" );
    } else {
		$output = pop( @descr );
    }

    ( my $ext = $output ) =~ s,.*\.,,;
    unless( $ext ) {
		$logger->fatal( '__F_BAD_EXTENSION',
			"\tCannot detect appropriate extension for output from $output" );
		exit 1;
    }

    # Get template and mix.cfg in place if "init"
    # In -init mode we will die if the output file already exists ...

    if ( $mode eq "init" ) {
		if ( -r $output ) {
	    	$logger->fatal( '__F_OUTPUT_EXIST', "\tOutput file $output already existing!" );
	    	exit 1;
		}
		( $input = $FindBin::Bin ."/template/mix." . $ext ) =~ s,\\,/,g;
		if ( ! -r $input ) { # Try again for UNIX (search in ../template):
			( $input = $FindBin::Bin ."/../template/mix." . $ext ) =~ s,\\,/,g;
			if ( ! -r $input ) {
	    		$logger->fatal( '__F_INIT_FAIL', "\tCannot init mix from $input" );
	    		exit 1;
			}
		}
		# Get mix.cfg template inplace:
		if ( -r ( dirname( $output ) . "/mix.cfg" ) ) {
	    	$logger->warn( '__W_MIXCFG_EXISTS', "\tExisting config file mix.cfg will not be changed!" );
		} else {
	    	copy( dirname( $input ) . "/mix.cfg" , dirname( $output ) . "/mix.cfg" )
				or $logger->warn( '__W_MIXCFG_CP',
					"\tCopying mix.cfg failed: " . $! . "!" );
		}

	# Get template in place ...
	copy( $input, $output ) or
	    $logger->fatal( '__F_INPUT_CP', "\tCopying $input to $output failed: " . $! . "!" )
	    and exit 1;
    }

    # If user provided HDL files, we try to scan these and add to the template ...
    if ( scalar( @hdlimport ) ) {

        Micronas::MixUtils::IO::mix_utils_open_input( $output );
        #Gets format from file to import too.

		Micronas::MixParser::mix_parser_importhdl( $output, \@hdlimport ); # Found in MixParser ...
    }

    # Done ...
    exit 0;

} # End of mix_utils_init_file

#
# This module returns 1, as any good module does.
#
1;

#!End
