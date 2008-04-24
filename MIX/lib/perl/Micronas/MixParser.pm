# -*- perl -*--------------------------------------------------------------
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
# | Project:    Micronas - MIX / Parser                                   |
# | Modules:    $RCSfile: MixParser.pm,v $                                |
# | Revision:   $Revision: 1.99 $                                         |
# | Author:     $Author: lutscher $                                            |
# | Date:       $Date: 2008/04/24 12:16:44 $                              |
# |                                                                       |
# | Copyright Micronas GmbH, 2002                                         |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/MixParser.pm,v 1.99 2008/04/24 12:16:44 lutscher Exp $                                                         |
# +-----------------------------------------------------------------------+
#
# The functions here provide the parsing capabilites for the MIX project.
# Take a matrix of information in some well-known format and convert it into
# intermediate format and/or source code files
#

# +-----------------------------------------------------------------------+
# |                                                                       |
# | Changes:                                                              |
# | $Log: MixParser.pm,v $
# | Revision 1.99  2008/04/24 12:16:44  lutscher
# | another fix in mix_store_db()
# |
# | Revision 1.98  2008/04/24 12:01:08  lutscher
# | extended mix_store_db to capture xml type
# |
# | Revision 1.97  2008/04/14 12:07:30  lutscher
# | fixed collapse_conn
# |
# | Revision 1.96  2008/04/01 12:48:34  wig
# | Added: optimizeportassign feature to avoid extra assign commands
# | added protoype for collapse_conn function allowing to merge signals
# |
# | Revision 1.95  2007/11/26 23:00:49  wig
# | Handle import with spaces between bus definition and ;
# |
# | Revision 1.94  2007/11/15 13:07:00  wig
# | Improved HDL import:
# | 	- Handle parantheses in VHDL comments
# | 	- Extend intermdiate.order: row:(alpha|input),col:(alpha,input,template)
# |
# | Revision 1.93  2007/10/30 15:54:46  wig
# | Added a if defined( ... ) ...
# |
# | Revision 1.92  2007/09/28 12:26:34  lutscher
# | change merge_inst() to also concatenate ::udc data
# |
# | Revision 1.91  2007/03/20 14:52:24  wig
# | Added %PURGE% into merge_inst and merge_conn
# |
# | Revision 1.90  2007/03/08 09:24:31  wig
# | Minor update for Base.pm (renamed subs).
# |
# | Revision 1.89  2007/03/06 12:44:33  wig
# | Adding IF/ELSIF/ELSE for generators and testcase.
# |
# | Revision 1.88  2007/01/22 17:31:50  wig
# |  	MixParser.pm MixReport.pm : update -report portlist (seperate ports)
# |
# | Revision 1.87  2006/11/22 10:37:15  wig
# | Reworked hier overlay mode (data redefinition!)
# |
# | Revision 1.85  2006/11/21 09:03:30  wig
# |  	MixParser.pm : variant filtering for generators fixed
# |
# | Revision 1.84  2006/11/15 16:24:37  wig
# | 	MixParser.pm : minor fix to get verilog include import working
# |
# | Revision 1.83  2006/11/14 16:48:59  wig
# | extended add_ports to handle `define ports!
# |
# | Revision 1.82  2006/10/30 15:45:25  wig
# |  	MixParser.pm MixWriter.pm : renamed variable, fixed typo
# |
# | Revision 1.81  2006/10/30 15:35:00  wig
# | extended handling of `define port/signal definitions
# |
# | Revision 1.80  2006/09/25 15:15:44  wig
# | Adding `foo support (rfe20060904a)
# |
# | Revision 1.79  2006/09/25 08:24:10  wig
# | Prepared emumux and `define
# |
# | Revision 1.78  2006/07/12 15:23:40  wig
# | Added [no]sel[ect]head switch to xls2csv to support selection based on headers and variants.
# |
# | Revision 1.77  2006/07/04 12:22:36  wig
# | Fixed TOP handling, -cfg FILE issue, ...
# |
# | Revision 1.76  2006/06/22 07:13:21  wig
# | Updated HIGH/LOW parsing, extended report.portlist.comments
# |
# | Revision 1.75  2006/05/22 14:02:22  wig
# | Fix avfb issues with high/low connections
# |
# | Revision 1.74  2006/05/10 08:26:59  wig
# | __NODRV__ improvements
# |
# | Revision 1.73  2006/05/09 14:38:51  wig
# |  	MixParser.pm MixUtils.pm MixWriter.pm : improved constant assignments
# |
# | Revision 1.72  2006/05/03 12:03:15  wig
# | Improved top handling, fixed generated format
# |
# | Revision 1.71  2006/04/19 07:32:08  wig
# | Fix issue 20060404c (duplicate output ports)
# |
# | Revision 1.70  2006/04/13 13:31:52  wig
# | Changed possition of VERILOG_HOOK_PARA, detect illegal stuff in ::in/out description
# |
# | Revision 1.69  2006/04/10 15:50:09  wig
# | Fixed various issues with logging and global, added mif test case (report portlist)
# |
# | Revision 1.68  2006/03/17 09:18:31  wig
# | Fixed bad usage of $eh inside m/../ and print "..."
# |
# | Revision 1.66  2006/03/14 08:10:34  wig
# | No changes, got deleted accidently
# |
# | Revision 1.65  2006/01/18 16:59:28  wig
# |  	MixChecker.pm MixParser.pm MixUtils.pm MixWriter.pm : UNIX tested
# |
# | Revision 1.64  2005/12/22 13:40:56  wig
# | fixed missing port generation bug 20051221a
# |
# | ...[cut]...
# |
# +-----------------------------------------------------------------------+

package  Micronas::MixParser;

require Exporter;

  @ISA = qw(Exporter);
  @EXPORT = qw(
      parse_conn_macros
      parse_conn_gen
      parse_hier_init
      parse_conn_init
      mix_store_db
      mix_load_db
      apply_conn_macros
      apply_hier_gen
      apply_conn_gen
      add_inst
      add_tree_node
      add_conn
      collapse_conn
      mix_p_updateconn
      mix_p_retcprop
      add_portsig
      add_sign2hier
      parse_mac
      purge_relicts
      mix_parser_importhdl
      %hierdb
      %conndb
      );            # symbols to export by default
  @EXPORT_OK = qw(
    ); # symbols to export on request

# %EXPORT_TAGS = tag => [...];

our $VERSION = '0.01';

use strict;

use vars qw( %hierdb %conndb );

use Log::Log4perl qw(get_logger);
use Tree::DAG_Node; # tree base class
use Regexp::Common; # Needed for import/init functions: parse VHDL ...

use Micronas::MixUtils qw( $eh mix_store db2array db2array_intra mix_list_econf
						replace_mac is_integer is_integer2 );
use Micronas::MixUtils::IO;
use Micronas::MixChecker;

# Prototypes:
sub _scan_inout ($);
sub my_common (@);
sub add_port ($$);
sub _add_port ($$$$$$$$);
sub mix_p_retcprop ($$);
sub mix_p_updateconn($$);
sub _mix_p_getconnected ($$$$;$);
sub mix_parser_importhdl ($$);
sub _mix_parser_parsehdl ($);
sub overlay_bits($$);
sub mix_p_co2str ($$);
sub _mix_p_unsplice_inout($);
sub _mix_p_try_merge ($);
sub _mix_p_getsplicerange ($$$);
sub _mix_p_dogen ($$$$$$);
sub _mix_p_get_reparmatch ($$);
sub _add_inst_auto ($);
sub init_pseudo_inst ();
sub bits_at_inst ($$$);
sub bits_at_inst_hl ($$$);
sub _check_portspecm ($$$);
sub map2bus			($$);
sub map2signal		($$);
sub require_bus_port ($);
sub collapse_conn	($@);

####################################################################
#
# Our global variables
#  hierdb <- hierachy
#  conndb <- connection matrix
%hierdb     = ();
%conndb     = ();

####################################################################
#
# Our local variables
my $const   = 0; # Counter for constants name generation

#
# RCS Id, to be put into output templates
#
my $thisid		 =	'$Id: MixParser.pm,v 1.99 2008/04/24 12:16:44 lutscher Exp $';
my $thisrcsfile	 =	'$RCSfile: MixParser.pm,v $';
my $thisrevision =	'$Revision: 1.99 $';

$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,;

my $logger = get_logger( 'MIX::MixParser' );
# my $eh = $::eh;

####################################################################
## parse_conn_macros
## retrieve macro header and definitions from the input data
####################################################################

=head2

parse_conn_macros ($) {

Retrieve connection macro header and definitions from the input data.
Returns array of macro headers and definitions, preprocessed for later usage.
E.g. extends a "mo" array, which lists the significant fields for that macro,
"mm" is a perl reg match string, stretching over all significant fields.
"me" contains an piece of perl code to be evaled, which will fill in the variables
$1, $2, .... into the $mex{'L'} hash. 'L' is defined to be the variable names listed
in the MH fields.

=cut

sub parse_conn_macros ($) {
    my $rin = shift;

    unless( defined( $rin ) and $rin ) {
        $logger->fatal( '__F_PARSER_CONN_MACRO',  "\tUndefined or empty input argument for parse_conn_macros!" );
        die;
    }
    my $mflag = 0;
    my @m = ();
    my $n = -1;
    for my $i ( 0..$#{$rin} ) {
        if ( $rin->[$i]{'::gen'} =~ m/^\s*MH/io ) {
            # New MH line, go to "read macro definition mode"
            $m[++$n]{'mh'} = $rin->[$i]; # Copy MH line
            $rin->[$i]{'::comment'} = "#macro header parsed /" . $rin->[$i]{'::comment'};
            $mflag=1;
            next;
        }
        if ( $mflag and $rin->[$i]{'::gen'} =~ m/^\s*MD/io ) {
            # another MD, while being in "read macro definition mode"
            push( @{$m[$n]{'md'}}, $rin->[$i] );
            $rin->[$i]{'::comment'} = "#macro definition parsed /" . $rin->[$i]{'::comment'};
            next;
        }
        # if ( $mflag ) {
        # no new macro definition, go to status "wait for another MH"
            $mflag = 0;
        # next;
        # }
    }

    $n++;
    $logger->warn( '__I_PARSER_CONN_MACRO', "\tFound $n macro definitions" );

    #
    # Check macro definitions
    #
    @m = check_conn_macros( \@m );

    #
    # Convert mh into mm,mv and mo
    # defining order of fields, variables defined and matching string
    #
    convert_conn_macros( \@m );

    return \@m;

}

####################################################################
## convert_conn_macros
## convert macro header to macro match ...
####################################################################

=head2

convert_conn_macros ($) {

Convert macro header entry to something more suitable for matching and parsing.
Remove all fixed text cells. Just consider the one's that come with a $N (N:=a-zA-Z)
Set up the mm, ml, mv and mo fields.
mm = perl regular expression matching all relevant fields
ml = hash pointing to ::field:nr for each used variable
mv = variables defined in the various MH fields
me = generated perl code, ready to save $1..$N from matching into $mex{'N'}

=cut

sub convert_conn_macros ($) {
    my $r_m = shift;

    unless( defined $r_m ) {
        $logger->fatal( '__F_PARSER_CONN_MACROS', "\tBad input argument for check_conn_macros\n");
        die;
    }

    for my $i ( 0..$#{$r_m} ) {
        my %om = ();
        my @oo = ();
        my %vars = ();
        my $mm = "";
        my $me = "";
        my $n = 0;
        my %f = %{$r_m->[$i]{'mh'}};
        for my $ii ( keys( %f ) ) {
            if ( $f{$ii} !~ m/^$/o and
            		# TODO : Skip internally used fields!!
            		$ii !~ /^::(comment|descr|gen|ign|incom)/io # and
            		# take only plain text fields!
            		# ref( $f{$ii} ) eq ''
            		) {
                # Only non-empty cells are of interest,
                # d do not match comment, descr, ...
                push( @oo, $ii ); #Order preserve
                $mm .= "${ii}::";
                @{$vars{$ii}} = ( $f{$ii} =~ m{\$(\w)}xg ); # Give me all variables ....
                ( my $tmp = $f{$ii} ) =~ s,\$\w,(.+),g; # Replace variables by a (.+)
                $mm .= $tmp;

                for my $iii ( 0..$#{$vars{$ii}} ) {
                    $n++;
                    $me .= "\$mex{'" . $vars{$ii}[$iii] . "'} = \$" . $n . "; ";
                }
            }
        }
        #
        # Store results of conversion into hash
        #
        @{$r_m->[$i]{'mo'}} = @oo;      # All fields to match against
        $r_m->[$i]{'mm'} = $mm;           # Match string
        # Complain if variables are defined multiple times ...
        my %t = ();
        my %tl = ();
        for my $ii ( keys( %vars ) ) {
            for my $iii ( 0..$#{$vars{$ii}} ) {
                if ( defined( $t{$vars{$ii}[$iii]} ) ) {
                    $logger->warn( '__W_PARSER_CONN_MACROS' , "\tVariable $t{$vars{$ii}[$iii]} redefined in macro key $ii (macro nr. $i)!");
                }
                $t{$vars{$ii}[$iii]} = $ii . ":" . $vars{$ii}[$iii]; # $t{'N'} = "::FIELD:NAME"
                $tl{$vars{$ii}[$iii]} = $ii . ":" . $iii; # $t{'N'} = "::FIELD:NR"
            }
        }
        %{$r_m->[$i]{'mv'}} = %vars;    # Order and name of matching variables
        %{$r_m->[$i]{'ml'}} = %tl;           # maps variables to ::field:NR
        #
        # Convert/Prepare a string like "$mex{'n'}=$1; $mex{'m'}=$2;" to be evaluated for macro
        # expansion
        #
        $r_m->[$i]{'me'} = $me;

        #
        # Replace $N in MD fields by $mex{'N'} (will be evaluated later while parsing for MX)
        #
        for my $ii ( 0..$#{$r_m->[$i]{'md'}} ) {
            for my $iii ( keys( %{$r_m->[$i]{'md'}[$ii]} ) ) {
                while( $r_m->[$i]{'md'}[$ii]{$iii} =~ m/\$(\w)/g ) {
                    unless( defined( $r_m->[$i]{'ml'}{$1} ) ) {
                        $logger->warn('__W_PARSER_CONN_MACROS', "\tVariable $1 used in macro definition for macro nr. $i undefined!");
                        $r_m->[$i]{'me'} .= "\$mex{'" . $1 . "'} = \"E_UNDEFINED_VAR\"; ";
                    }
                }
                $r_m->[$i]{'md'}[$ii]{$iii} =~ s/\$(\w)/\$mex{'$1'}/g;
            }
        }
    }
    return;
} # End of convert_conn_macros

####################################################################
## check_conn_macros
## do some simple checks on macros ...
####################################################################

=head2

check_conn_macros ($) {

Do simple checks on input macros

=cut

sub check_conn_macros ($) {
    my $r_m = shift;

    my @m = ();
    unless( defined $r_m ) {
        $logger->fatal( '__F_PARSER_CONN_MACROS', "\tBad input argument for check_conn_macros\n");
        die;
    }

    for my $i ( 0..$#{$r_m} ) {
        unless ( defined( $r_m->[$i]{'mh'} )  ) {
            $logger->error( '__E_PARSER_CONN_MACROS', "\tMacro header missing $i");
            next;
        }
        unless ( defined( $r_m->[$i]{'md'} ) and $#{$r_m->[$i]{'md'}} >= 0 ) {
            $logger->error( '__E_PARSER_CONN_MACROS', "\tMacro definition missing $i");
            next;
        }
        push( @m, $r_m->[$i] );
    }

    return @m;

} # End of check_conn_macros

####################################################################
## parse_conn_gen
## retrieve generator line definitions from the input data
####################################################################

=head2

parse_conn_gen ($) {

Retrieve connection and hierachy generator definitions from the input data. There are two
allowed forms:

=over 4

=item $i (n..m),/PERL_RE/

This will be applied to all input lines. If /PERL_RE/ matches a given
instance or connection name, the generator line will be executed. This is just a special case
of the simple /PERL_RE/.

=item /PERL_RE/

The generator line will be matched against each input instance or connection
name. If it matches the generator line will be executed.

=item $i (n..m)

This is the second case. It will generate instances/connections, no matching lines required.
Make sure to use $i in the instance or signal name to generate the objects as requested.

=item HIER vs. CONN

A leading CONN means iteration about the conndb data, while by default the instances
in hierdb are iterated through.

#!wig20060125: the SPLICE modifier attached to the CONN namespace, iterate
the macro over all bits of a vector while setting the special variable $s
to the current bit number.

=item EXAMPLES

Examples:

		CONN:SPLICE $i (n..m),/PERL_RE/
			iterate over all signals, search for matching names within the $i range
			and evaluate the generator for each slice of a signal with setting
			$s to the current bit number. Experimental today (20060209).

		CONN $i(n..m)/padsig_($i=\d+)/
			will match all signals, whose names start with padsig_ and set $i to the
			number matched by (\d+). The generator only applies if the yielded $i is
			within the range of n to m

		$i(n..m)/inst_(\w+)::::number=($i=\d+)/
			iterate over all instance names, match if the instance name starts with
			"inst_" and if there is an additional comlum ::number defined, whose
			value is a digit and within the range of n to m. You can make use of
			the $i and $1
=back

It returns a hash, key is the instance name perl regular expression match.
Right now this function can be used for both CONN and HIER matrix.

!wig20061121: make sure generators and macros get executed in order of occurance (adds 'n')
!wig20070305: add IF/.../ ELSIF/.../ ELSE keywords

=cut

sub parse_conn_gen ($) {
    my $rin = shift;

    my $gi = 0;
    unless( defined $rin ) {
        $logger->fatal( '__F_PARSER_CONN_GEN',  "\tparse_conn_gen called with bad argument\n" );
        die;
    }

    my %g = ();
	my $n = 0; # Generator counter
	my $icomms	= $eh->get( 'input.ignore.comments' );
	my $ivar	= $eh->get( 'input.ignore.variant' ) || '#__I_VARIANT';
    for my $i ( 0..$#{$rin} ) {

        next unless ( $rin->[$i] ); # Holes in the array?
        next if ( $rin->[$i]{'::ign'} =~ m,$icomms,o );		# Skip fields commented out
        next if ( $rin->[$i]{'::ign'} =~ m,$ivar,o );		# Skip variants not selected
        next if ( $rin->[$i]{'::comment'} =~ m,#macro,o );	# No generator, but a macro!

        next if ( $rin->[$i]{'::gen'} =~ m,^\s*(M)?$, );      # Empty or M(acro)

		#!wig20070305: Catch IF / ELSIF / ELSE
		my $ifelse = '';
		if ( $rin->[$i]{'::gen'} =~ s!^\s*(IF|ELSIF|ELSE)\s*!!io ) {
			$ifelse = lc($1); # Remember the link to previous genertors
		}
        # CONN vs. HIER: Strip and remember leading CONN .
        #wig20030715
        my $namesp = 'hier';
        if ( $rin->[$i]{'::gen'} =~ s!^\s*(HIER|CONN(:SPLICE)?)[\s,]*!!io ) {
            $namesp = lc( $1 );
        }

        # iterator based generator: $i(1..10), /PERL_RE/
        if ( $rin->[$i]{'::gen'} =~ m!^\s*\$(\w)\s*\((\d+)\.\.(\d+)\)\s*,\s*/(.*)/! ) {
            my $pre = $4 . "_$2_$3";	# Generator unique name
            if ( $2 > $3 ) {
                $logger->error('__E_PARSER_BAD_BOUNDS', "\t$2..$3 in generator definition '" .
                	$rin->[$i]{'::gen'} . "', skipped!");
                next;
            }
            if ( exists( $g{$pre} ) ) { # Redefinition of this macro ...make name unique
                $g{$pre}{'rep'}++;
                $pre .= '__DUPL__' . $gi++;
            }
            $g{$pre}{'pre'} = $4;
            $g{$pre}{'var'} = $1;
            $g{$pre}{'lb'}  = $2;
            $g{$pre}{'ub'}  = $3;
            $g{$pre}{'field'} = $rin->[$i];
            $g{$pre}{'ns'}  = $namesp;
            $g{$pre}{'n'}   = $n++;
            $g{$pre}{'link'} = $ifelse;
            $rin->[$i]{'::comment'} = '# Generator parsed /' . $rin->[$i]{'::comment'};
        }
        # plain generator: /PERL_RE/
        elsif ( $rin->[$i]{'::gen'} =~ m!^\s*/(.*)/! ) {
            my $tag = $1;
            if ( exists( $g{$tag} ) ) { # Redefinition of this macro ... make name unique
                $g{$tag}{'rep'}++;
                $tag .= '__DUPL__' . $gi++;
            }
            $g{$tag}{'var'} = undef;
            $g{$tag}{'lb'}  = undef;
            $g{$tag}{'ub'}  = undef;
            $g{$tag}{'pre'} = $1;
            $g{$tag}{'field'} = $rin->[$i];
            $g{$tag}{'ns'}  = $namesp;
            $g{$tag}{'n'}   = $n++;
            $g{$tag}{'link'} = $ifelse;	# Hmmm, a link does not make to much sense here
            $rin->[$i]{'::comment'} = "# Generator parsed /" . $rin->[$i]{'::comment'};
        }
        # parameter generator: $i (1..10)
        # no /match/ .....
        elsif ( $rin->[$i]{'::gen'} =~ m!^\s*\$(\w)\s*\((\d+)\.\.(\d+)\)!o ) {
            my $gname = '__MIX_ITERATOR_' . $gi++;
            if ( $ifelse ) { # An ELSE or whatever
            	$gname = '__MIX_ITERATOR_ELSE_' . $gi++;
            }
            $g{$gname}{'var'} = $1;
            $g{$gname}{'lb'}  = $2;
            $g{$gname}{'ub'}  = $3;
            $g{$gname}{'field'} = $rin->[$i];
            $g{$gname}{'pre'} = $gname;
            $g{$gname}{'ns'}  = $namesp;
            $g{$gname}{'n'}   = $n++;
            $g{$gname}{'link'} = $ifelse;
            $rin->[$i]{'::comment'} = "# Generator parsed /" . $rin->[$i]{'::comment'};
        } else { # TODO : Check if that makes sense (maybe we abov expression has to be repeated ...)
            my $gname = '__MIX_ELSE_' . $gi++;
            $g{$gname}{'var'} = '';
            $g{$gname}{'lb'}  = '';
            $g{$gname}{'ub'}  = '';
            $g{$gname}{'field'} = $rin->[$i];
            $g{$gname}{'pre'} = $gname;
            $g{$gname}{'ns'}  = $namesp;
            $g{$gname}{'n'}   = $n++;
            $g{$gname}{'link'} = $ifelse;
            $rin->[$i]{'::comment'} = "# Generator parsed /" . $rin->[$i]{'::comment'};
		}
    }

    #
    # TODO : do more sanity checks ... e.g. allowed characters, fields ...
    # but most of that can be relayed to later
    #
    return \%g;

} # End of parse_conn_gen

####################################################################
## parse_hier_init
## parse hierachy input and combine with generators to produce list/hash of instances
####################################################################

=head2

parse_hier_init ($)

Build initial instance list from input data and generators.

=cut

sub parse_hier_init ($) {

    my $r_hier = shift;
    # my $r_conmac = shift;
    # my $r_congen = shift;
    # my $r_hiergen = shift;

    # unless ( defined $r_hier or defined $r_conmac or defined $r_congen or defined $r_hiergen ) {
    unless( defined $r_hier ) {
        $logger->fatal( '__F_PARSER_HIER_INIT', "\tparse_hier called with bad arguments!" );
        die;
    }

	init_pseudo_inst();

    #
    # Add all instances left in the input data
    #
    #!wig20060712: removing comments:
	my $icomms	= $eh->get( 'input.ignore.comments' );
	my $ivar	= $eh->get( 'input.ignore.variant' ) || '#__I_VARIANT';
    for my $i ( 0..$#{$r_hier} ) {
        next unless ( $r_hier->[$i] ); # Skip if input field is empty
        next if ( $r_hier->[$i]{'::ign'} =~ m,$icomms,o );
        next if ( $r_hier->[$i]{'::ign'} =~ m,$ivar,o );
        # Skip lines with data in the ::gen column:
        next if ( $r_hier->[$i]{'::gen'} !~ m,^\s*$,o );
        # Add more "go away" here if needed

        #
        # Early name expansion required for primary key ::inst
        #!wig: this is a sepcial case of replace_mac!
        my $meh = $eh->get('output.generate._logicre_');
        if ( $r_hier->[$i]{'::inst'} =~ m/^\s*%(::\w+?)%/o ) {
            my $name = $r_hier->[$i]{'::inst'};
            if ( defined( $r_hier->[$i]{$1} ) ) {
                $name =~ s/%(::\w+?)%/$r_hier->[$i]{$1}/g; # replace %::key% ...
                #
                #TODO: multiple replacements could lead to troubles!
                #    and it will not work recursive !!
                $r_hier->[$i]{'::inst'} = $name;
            } elsif ( $name !~ m/$meh/io ) {
                $logger->error( '__E_PARSER_HIER_INIT', "\tCannot replace %::inst% for $name!" );
            }
        }
        $r_hier->[$i]{'::__source__'} = 'hier'; # Mark these to be from HIER sheet
        add_inst( %{$r_hier->[$i]} );
    }

}

#
# Create some pseudo instances up-front
#
sub init_pseudo_inst () {

    #
    # Add some meta instances: %TOP%, %CONST%, %OPEN%
    # These are needed for proper program flow.
    #
    add_inst( '::inst' => '%CONST%', );
    add_inst( '::inst' => '%GENERIC%', );
    add_inst( '::inst' => '%PARAMETER%', );

    add_inst( '::inst' => '%TOP%',
    		  '::entity' => '%TOP_ENTY%',
    		  '::config' => '%TOP_CONF%',
    );
    add_inst( '::inst' => '%OPEN%', );
    add_inst( '::inst' => '%BUS%', );  # Meta instance for %BUS% connections ...
}

####################################################################
## add_inst
## add an instance to the hierdb data structure
####################################################################

=head2

add_inst (%)

Build instance from input data. Do lots of checks.

=cut

sub add_inst (%) {
    my %in = @_;

	# Trying to create a module without a valid name:
    unless ( exists( $in{'::inst'} ) and
    		 defined( $in{'::inst'} ) and
    		 $in{'::inst'} ) {
        $logger->error( '__E_ADD_INST', "\tTry to create instance without name:" .
        	join( " ", %in ) );
        return;
    }

    my $name = mix_expand_name( 'inst', \%in ); # Expand names with %foobar% inside ..
    $name = mix_check_case( 'inst', $in{'::inst'} ); # Get appropriate name and fix it if flag is set

    if ( defined( $hierdb{$name} ) ) {
        # Alert user if this connection already got defined somewhere ....
        if ( $eh->get( 'check.defs' ) =~ m,\binst, ) {# Warning, another line adding to this inst.
            $logger->warn( '__W_ADD_INST', "\tRedefinition of instance $name!" );
            $eh->inc( 'sum.uniq' );
        }
        merge_inst( $name, %in );
    } else {
        create_inst( $name, %in );
        $eh->inc( 'sum.inst' );
    }
    # Return name of instance ...
    return( $name );
}

#
# Expand %::COL% in names ....
# Will return expanded name and also replace it in the input data hash
#
sub mix_expand_name ($$) {
    my $toex = shift;
    my $rdata = shift;

    my $n = $rdata->{'::' . $toex};
    #!wig20060405: redo that, TESTBENCH should be daughter of %TOP%!
    #!wig20060403: TOP is named TESTBENCH (mostly for compatability resaons):
    # if ( $n =~ m/^testbench/i and $eh->get('top') =~ m/^%?testbench\b/i ) {
    #	$n = "%TOP%";
    # }
    #
    # Early name expansion required for primary keys (like ::inst)
    #
    while ( $n =~ m/%((::)?\w+?)%/g ) {
        my $key = $1;
        next if $key =~ m,^(TOP|PARAMETER|GENERIC|CONST|(OPEN|LOW|HIGH|LOW_BUS|HIGH_BUS)(_\d+)?|BUS)$,o;
        next if $key =~ m,^(TYPECAST_),;
        if ( defined( $rdata->{$key} ) ) {
                $n =~ s/%$key%/$rdata->{$key}/g; # replace %::key% ...
                #
                # TODO : multiple replacements could lead to troubles!
                #        and it will not work recursive !!
                #
        } elsif ( defined( my $pfk = $eh->get( 'postfix.' . $key ) ) ) {
            $n =~ s/%$key%/$pfk/g; # replace %::key% -> $eh->get( 'postfix' ...)
        } elsif ( defined( my $pmk = $eh->get( 'macro.%' . $key . '%' ) ) ) {
            $n =~ s/%$key%/$pmk/g; # replace %::key% -> $eh->get( 'macro' ...)
        }else {
                $logger->error( '__E_EXPAND_NAME', "\tCannot replace %$key% in name $n!" );
        }
    }
    $rdata->{'::' . $toex} = $n;
    return $n
}

sub create_inst ($%) {

    my $name = shift;
    my %data = @_;

    #wig20030331: do not add if ignore field is set:
    if ( exists( $data{'::ign'} ) and $data{'::ign'} =~ m,^\s*(#|//),o ) {
        return;
    }

    #wig20030404: special handling: check case of parent name ...
    if( exists( $data{'::parent'} ) ) {
        $data{'::parent'} = mix_check_case( 'inst', $data{'::parent'} );
    }

    my $ehr = $eh->get( 'hier.field' );
    for my $i ( keys %$ehr ) {
        next unless ( $i =~ m/^::/ );
        if ( defined( $data{$i} ) and $data{$i} ne "" ) { #If it's an empty string -> use default
            $hierdb{$name}{$i} = $data{$i};
        } else {
            $hierdb{$name}{$i} = $ehr->{$i}[3]; # Set to DEFAULT Value
            #TODO: Initialize fields to empty / Marker, set DEFAULT if still empty at end
        }
        $hierdb{$name}{$i} =~ s/%NULL%//g; # Just to make sure fields are initialized
        delete( $data{$i} );
    }

    #
    # Add the rest, too
    #
    for my $i( keys( %data ) ) {
        $hierdb{$name}{$i} = $data{$i};
    }

    add_tree_node( $name, $hierdb{$name} );

    return;
}

#
# Add an element/node and a parent if required
#
=head2

add_tree_node ($$)

adds an entry in the hierachy tree for each element in the HIER sheet
if needed creates parent node, too. Links element to parent.

=cut

sub add_tree_node ($$) {
    my $name = shift;
    my $r_h = shift;

    my $ehr = $eh->get( 'hier.field' );

    # Prevent redefinition!
    if ( defined( $r_h->{'::treeobj'} ) ) {
        $logger->warn('__W_ADD_TREE_NODE', "\tTree node for element $name already created!");
        return;
    }

    #
    # Build tree
    # we can rely on the fact that this hierachy element was never seen before ...
    # TODO : store all attributes in tree object, instead of hierdb ...
    #
    my $node = Tree::DAG_Node -> new;
    $node->name($name);
    $r_h->{'::treeobj'} = $node; # store object reference!

	# Default parent:
    my $parent = 'W_NO_PARENT';
	# TESTBENCH: if no parent set, link it to %TOP%
	my $auto_top = 0;
	if ( $name =~ m/^%?testbench/i ) {
		unless( defined( $r_h->{'::parent'} ) ) {
			$logger->info( '__I_SELECTTOP', "\tUse built-in top %TOP%" );
			$r_h->{'::parent'} = '%TOP%';
			$auto_top = 1;
		}
	}

	# Parent:
    if ( defined( $r_h->{'::parent'} ) and $r_h->{'::parent'} ) {
        # If the parent is already defined, link this instance to the parent, else create a parent node
        $parent = $r_h->{'::parent'};
    }

    #!wig20030404: Caseing ...
	$parent = mix_expand_name( 'inst', { '::inst' => $parent } ); # Caveat: Cannot do full expansion
    $parent = mix_check_case( 'inst', $parent);

	#!wig20060503: If parent does not exist -> create it
    unless ( defined( $hierdb{$parent} ) and $hierdb{$parent} ) {
    		# Create "default" parent
            my $parnode = Tree::DAG_Node -> new;
            $parnode->name($parent);
            $hierdb{$parent}{'::treeobj'} = $parnode;
            $parnode->add_daughter($node);
            # Initialize empty module:
            for my $i ( keys %$ehr ) {
                    next unless ( $i =~ m/^::/ );
                    $hierdb{$parent}{$i} = $ehr->{$i}[3]; # Set to DEFAULT Value
                    # TODO : Initialize fields to empty / Marker, set DEFAULT if still empty at end
                    $hierdb{$parent}{$i} =~ s/%NULL%//g; # Just to make sure fields are initialized
            }
            # Force TESTBENCH (auto) to be daughter of %TOP%
            if ( $parent =~ m/^%?testbench/i ) { # Autolink testbench to TOP ...
            	$hierdb{$parent}{'::parent'} = '%TOP%';
            	$hierdb{'%TOP%'}{'::treeobj'}->add_daughter( $parnode );
            }
            $hierdb{$parent}{'::inst'} = $parent; # Set parent name
            $hierdb{$name}{'::parent'} = $parent; # Set name for parent of this
    }
    $hierdb{$parent}{'::treeobj'}->add_daughter( $node);
} # End of add_tree_node

sub merge_inst ($%) {

    my $name = shift;
    my %data = @_;

    #wig20030331: do not add if ignore field is set:
    if ( exists( $data{'::ign'} ) and $data{'::ign'} =~ m,^\s*(#|//),o ) {
        return;
    }

    #
    # Get my parent name
    #
    my $parent = ''; # Start with empty parent name
    if ( defined( $data{'::parent'} ) ) {
        $parent = mix_check_case( 'inst', $data{'::parent'} );
        $data{'::parent'} = $parent; # Rewrite input data ...
    }

    #
    # Tree check: Check it parent changed ...
    #
    if ( defined( $parent ) and $parent
        and defined( $hierdb{$name}{'::parent'} and
        $hierdb{$name}{'::parent'} ) ) {
        if (
            $parent ne ($eh->get( 'hier.field.::parent'))->[3] and
            $parent ne $hierdb{$name}{'::parent'} ) {
                $logger->debug( '__D_MERGE_INST', "\tChange parent for cell $name to $parent from $hierdb{$name}{'::parent'}" )
                    unless( $hierdb{$name}{'::parent'} eq ($eh->get( 'hier.field.::parent'))->[3] );
                my $node = $hierdb{$name}{'::treeobj'};
                # If parent is already defined -> change it ...
                unless ( exists( $hierdb{$data{'::parent'}} ) ) {
                    $logger->info( '__I_MERGE_INST', "\tAutocreate parent for $name: $parent" );
                    my %info = ();
                    if ( $parent =~ m/^\s*%?testbench/i ) {
                    	# Automatically link to %TOP%!
                    	# TODO : Check if that is o.k. always (what if user defines his own testbench?
                    	$info{'::parent'} = '%TOP%';
                    }
                    create_inst( $parent, %info );
                }
                my $pnode = $hierdb{$parent}{'::treeobj'};
                $pnode->add_daughter( $node );
        }
    }
    #
    # Overwrite hierdb if fields are zero or space ....
    #
    # TODO : Check if order matters here ..
	my $overload = ( $eh->get('hier.options') =~ m/\boverload\b/io );
    for my $i ( keys( %data ) ) {
        # TODO : Trigger merge mode for special cases where we want to add
        # up data instead of overwrite
        # e.g. add a filed defining concatenate/overwrite/array/noover/... mode
        # Here we implement:
        # If the field already exists and has a contents
        # AND $eh has a value for that field AND
        # the field differs from the default value, do nothing.
        # Else fill in the field with the input data

		if ( defined( $data{$i} ) and $data{$i} eq '%PURGE%' ) {
			$hierdb{$name}{$i} = '';
			next;
		}

        if ( defined( $hierdb{$name}{$i} ) and $hierdb{$name}{$i} ne '' ) {
            if ( not $overload and
            		defined( $eh->get( 'hier.field.' . $i ) ) and
		 			( $hierdb{$name}{$i} ne
		 				($eh->get( 'hier.field.' . $i ))->[3] ) ) {
		 			# Leave that value ....
					$logger->warn( '__I_MERGE_INST', "\tField $i for $name already filled");
            } else {
            	if ( $data{$i} ne '' ) {
            		if ( $i eq '::comments' or $i eq '::udc') {
            			$hierdb{$name}{$i} .= ' ' . $data{$i}; # concatenate
            		} else {
						$hierdb{$name}{$i} = $data{$i};
            		}
            	}
            }
        } else {
        	# Take this new value
            if ( $data{$i} ) {
                $hierdb{$name}{$i} = $data{$i};
            }
        }
    }
    return;
} # End of merge_inst

####################################################################
## parse_conn_init
## setup the initial conection db
####################################################################

=head2

parse_conn_init ($)

Parse the initial connection database. Iterate through all lines.

=cut

sub parse_conn_init ($) {
    my $r_conn = shift;

    unless( defined $r_conn ) {
        $logger->fatal( '__F_PARSER_CONN_INIT', "\tparse_conn_init called with bad arguments!" );
        die;
    }

    my $ehr = $eh->get( 'conn.field' );
	my $icomms	= $eh->get( 'input.ignore.comments' );
	my $ivar	= $eh->get( 'input.ignore.variant' ) || '#__I_VARIANT';
    for my $i ( 0..$#{$r_conn} ) {
        # Skip comment lines
        # TODO : allow to pass such lines through ..
        next if ( $r_conn->[$i]{'::ign'} =~ m,$icomms,o );
        next if ( $r_conn->[$i]{'::ign'} =~ m,$ivar,o );
        # Skip generator lines
        next if ( $r_conn->[$i]{'::gen'} !~ m,^\s*$,o );

        add_conn( %{$r_conn->[$i]} );
    }

    #
    # Add some internal/meta signals:
    #

    # add_conn( '::name' => "%DUMMY%", );

}

sub add_conn (%) {
    my %in = @_;

    my $name = $in{'::name'} || '';
    my $nameflag = 0;

    #
    # strip of leading and trailing whitespace
    #
    $name =~ s/^\s+//o;
    $name =~ s/\s+$//o;

    #
    # Special handling: open -> %OPEN%
    if ( $name =~ m,^open$,io or $name =~ m,^\s*%OPEN%,o ) {
        $name = '%OPEN_' . $eh->postinc( 'OPEN_NR' ) . '%';
    }
	#
	# If user assigns bus to %LOW% and/or %HIGH%
	#   -> map to LOW_BUS|HIGH_BUS
	#!wig20050719
	#!wig20060516 and vice versa
	if ( $name =~ m/%(LOW|HIGH)(_BUS)?(_\d+)?%/o ) {
		my $hl  = $1;
		my $bus = ( $2 ) ? $2 : '';
		my $n   = ( $3 ) ? $3 : '';
		# Map non-bus to BUS
		if ( not $bus and
		     ( ( defined( $in{'::high'} ) and $in{'::high'} ne '' ) or
			   ( defined( $in{'::low'} )  and $in{'::low'}  ne '' ) ) ) {
			$logger->warn('__W_ADD_CONN', "\tExtend assignment from $1 to $1_BUS!");
			$bus = '_BUS';
			# Care about the ::type -> add a _vector
			$in{'::type'} = map2bus( 'HL_BUS', $in{'::type'} );

			}

		# Map bus to non-bus (if no borders given)
		if ( $bus and
				( ( not defined( $in{'::high'} ) or $in{'::high'} eq '' ) and
			      ( not defined( $in{'::low'} )  or $in{'::low'}  eq '' ) ) ) {
			#!wig20060619: check port assignment
			my $width = '';
			if( $width = require_bus_port( $in{'::in'} ) ) {
				$logger->warn('__W_ADD_CONN', "\tDetected width for $name automatically: $width:0" );
				$in{'::high'} = $width;
				$in{'::low'} = 0;
			} else {
				$logger->warn('__W_ADD_CONN', "\tRemove _BUS from $1 !");
				$bus = '';
				$in{'::type'} = map2signal( 'HL_BUS', $in{'::type'} );
			}
		}
		if( $n eq '' ) { # Get a new number for high/low
			$n = '_' . $eh->postinc( $hl . '_NR' );
		}
		$name = '%' . $hl . $bus . $n . '%';
		$in{'::name'} = $name;
	}

    $in{'::name'} = $name;
    #
    # name must be defined:
    # if not, assume that could be a generated name, check later on
    #
    if ( $name eq '' ) {
        # Handle CONSTANTS ..either set in input or derived by detecting constants in ::out
        # Generate a name
        $nameflag = 1;
        $name = $eh->get( 'postfix.PREFIX_CONST' ) .
              	$eh->postinc( 'CONST_NR' );
        $in{'::name'} = $name;
		$logger->debug( '__D_ADD_CONN', "\tCreating name $name for constant!" );
    }

    #
    # Get expanded signal name
    #
    if ( $in{'::name'} =~ m,%,o ) { $name = mix_expand_name( 'name', \%in ) };

    #
    # Check case ...
    #
    $name = mix_check_case( 'conn', $name );

    #
    # check name: only [a-z_A-Z0-9%:] allowed ..
    # strip of leading and trailing whitespace
    # TODO : allow %macro% and ::macro, only!
    #
    if ( $name =~ m/[^0-9A-Za-z_%:]/ ) {
        # Mark signal .... but add it anyway (user should be able to fix it)
        $logger->error( '__E_ADD_CONN', "\tIllegal signal name $name. Will be ignored!" );
        $in{'::ign'} = "#ERROR_ILLEGAL_SIGNAL_NAME";
        $in{'::comment'} = "#ERROR_ILLEGAL_SIGNAL_NAME $name" . $in{'::comment'};
        $name = "ERROR_ILLEGAL_SIGNAL_NAME";
        $in{'::name'} = $name;
    }
    #
    # Early name expansion required ...
    #
    if ( $name =~ m/^\s*%(::\w+)%/o ) {
        if ( defined( $in{$1} ) ) {
            $name =~ s/%(::\w+?)%/$in{$1}/g; # replace %::key% ...
            #
            # TODO : multiple replacements could lead to troubles!
            #
            $in{'::name'} = $name;
        } else {
            $logger->warn( '__W_ADD_CONN', "\tCannot replace ::name for $name!" );
        }
    }

    if ( defined( $conndb{$name}  ) ) {
        # Alert user if this connection already got defined somewhere ....
        if ( $eh->get( 'check.defs' ) =~ m,conn, ) {
            $logger->warn( '__W_ADD_CONN', "\tRedefinition of conection $name!" );
            $eh->inc( 'sum.uniq' ); # Not uniq warning!!
        }
        merge_conn( $name, %in );
    } else {
        create_conn( $name, %in);
    }

    # If name was not given, complain ...
    if ( $nameflag and $conndb{$name}{'::mode'} !~ m/^\s*[CPG]/o ) {
        # Check if this signals ::out has a %CONST% in it:
        # If yes, mark it as C
        unless( exists( $conndb{$name}{'::out'}[0] ) and
				$conndb{$name}{'::out'}[0]{'inst'} eq '%CONST%' ) {
            # Mark signal .... but add it anyway (user should be able to fix it)
            # TODO : fix up that code, should not deal with conndb here ....
			##LU added some hint for user
			my($hint) = $eh->get( 'macro.%EMPTY%' );
			if (lc($conndb{$name}{'::mode'}) eq 'i' ) {
				$hint = $in{'::in'} if (exists $in{'::in'});
			} elsif (lc($conndb{$name}{'::mode'}) eq 'o' ) {
				$hint = $in{'::out'} if (exists $in{'::out'});
			} else {
				$hint = $in{'::out'} if (exists $in{'::out'});
				if ($hint eq $eh->get( 'macro.%NULL%' ) or
					$hint eq $eh->get( 'macro.%EMPTY%' ) ) {
					$hint = $in{'::in'} if (exists $in{'::in'});;
				};
			};
            $logger->error( '__E_ADD_CONN', "\tMissing signal name in input near \'$hint\'. Generated name $name!" );
            $conndb{$name}{'::ign'} = "#__E_MISSING_SIGNAL_NAME";
            $conndb{$name}{'::comment'} = "#__E_MISSING_SIGNAL_NAME" . $conndb{$name}{'::comment'};
            $conndb{$name}{'::name'} = $name;
        } else {
            $conndb{$name}{'::mode'} = 'C';
        }
        # Is it linked to %CONST% instance ...
    } elsif ( defined( $conndb{$name}{'::out'}[0]{'inst'} ) and
        $conndb{$name}{'::out'}[0]{'inst'} eq '%CONST%' ) {
        # If we found a constant, change the ::mode bit to be constant ...
        if ( $conndb{$name}{'::mode'} and $conndb{$name}{'::mode'} !~ m,^\s*[CPG],io ) {
            $logger->error('__E_ADD_CONN', "\tSignal $name mode expected to be C, G or P but is " .
                        $conndb{$name}{'::mode'} . '!' );
            $conndb{$name}{'::mode'} = 'C';
            $conndb{$name}{'::comment'} .= '__E_MODE_MISMATCH';
        } elsif ( not $conndb{$name}{'::mode'} ) {
            # If this signal mode is not defined, assume C
            $logger->warn( '__I_ADD_CONN', "\tSetting mode to C for signal $name\n" );
            $conndb{$name}{'::mode'} = 'C';
            $conndb{$name}{'::comment'} .= '__I_SET_MODE_C';
        }
    }
} # End of add_conn

=head4 collapse_conn

	Merge two exisiting signales into one new instance

	Consider the inherit/overlay rules defined in the conn.fields global setting
	 	
	Checks: TODO

	Caveat: only use in the parse phase to simply overload.
	
	Output:
		error code	
			
	Input:
		sig_out		:=	name of signal (output); might be new or already existing
				will be created automatically if new.
		sig_in1		:=	name of input signal (conndb data strucuture)
		sig_in2		:=  ...
		[sig_inN]
		The signal data structure for sig_inN will be removed after merge.
	
=cut

sub collapse_conn ($@) {
	my $outname = shift;

	for my $inname ( @_ ) {
		unless ( exists $conndb{$inname} ) {
			$logger->error('__E_COLLAPSE_CONN', "\tNo signal $inname defined up to now" );
			next;
		}

		# Overload name upfront!
		$conndb{$inname}{'::name'} = $outname;

		if ( defined( $conndb{$outname}  ) ) {
        	merge_conn( $outname, %{$conndb{$inname}} );
    	} else {
        	create_conn( $outname, %{$conndb{$inname}} );
    	}
    	
    	# Remove the old data
    	delete( $conndb{$inname} );
	}
} # End of collapse_conn

#
# check if the assigned too values are bus or single bit
#    inst/port(F:T)=(F:T)
# only done if no ::high/::low was defined
#
# In: ::in description
# Out: max. width of connection in ::in
#
sub require_bus_port ($) {
	my $instr = shift;

	my $high = 0;
	for my $d ( split( /[,;]/, $instr ) ) {
        next if ( $d =~ /^\s*$/o );
        # Need to have () or []!
        if ( $d =~ m/[\[\(]/ ) {
        	$d =~ tr/\[\]/()/;
        	my $port = '';
        	my $signal = '';
        	if ( $d =~ m/\((.+)\)\s*=\s*\((.+)\)/ ) {
        		$port = $1;
        	} elsif ( $d =~ m/=\s*\((.+)\)/ ) {
        		$port = $1;
        	} elsif ( $d =~ m/\((.+)\)/ ) {
        		$port = $1;
        	} else {
        		# No () -> next!
        		next;
        	}

        	# Look into $port and $signal
        	if ( $port =~ m/(.+):(.+)/ ) {
        		my $ph = $1;
        		my $pl = $2;
        		if ( $ph ne $pl ) {
        			my $newmax = '';
        			# Differing borders -> is bus!
        			if ( $pl eq '0' ) {
        				$newmax = $ph;
        			} elsif ( is_integer2( $ph, $pl ) ) {
        				$newmax = $ph - $pl;
        			} else {
        				$newmax = $ph . ' - ' . $pl;
        			}
        			if ( is_integer2( $newmax, $high ) ) {
        				$high = ( $newmax > $high ) ? $newmax : $high;
        			} elsif ( $newmax and $high == '0' ) {
        				$high = $newmax;
        			} else {
        				$logger->error( '__E_PARSE_HIGHLOW', "\tBad borders to compare: $newmax found now, but $high before!");
        				$high = $newmax; # TODO : Make that wide enough!
        			}
        		}
        	}
        }
	}
	return $high; # Returns buswidth - 1!
} # End of require_bus_port

#
# map2bus: usually appends a "_vector"
#
# Input:
#		key  := HL_BUS, ....
#       type := current setting of type
#
# Output:
#		expanded bus type
#
# Global: -
sub map2bus ($$) {
	my $key  = shift;
	my $type = shift;

	if ( $type eq '' or $type eq '%SIGNAL%' ) {
		$type = '%BUS_TYPE%';
	} elsif( $type !~ m/_vector$/ ) {
		$type .= '_vector';
	}
	return $type;
} # End of map2bus

#
# map2signal: remove "_vector" or map %BUS_TYPE% to %SIGNAL%
#
# Input:
#		key  := HL_BUS, ....
#       type := current setting of type
#
# Output:
#		mapped type with removed _vector
#
# Global: -
sub map2signal ($$) {
	my $key  = shift;
	my $type = shift;

	if ( $type eq '' or $type eq '%BUS_TYPE%' ) {
		$type = '%SIGNAL%';
	}
	$type =~ s/_vector$//;
	return $type;
} # End of map2signal

sub create_conn ($%) {
    my $name = shift;
    my %data   = @_;

    my $ehr = $eh->get( 'conn.field' );

    for my $i ( keys %$ehr ) {
        next unless ( $i =~ m/^::/ );
        # ::in and ::out are special case; split if it contains s.th.
        if ( $i =~ m/^::(in|out)$/o ) {
            if ( defined( $data{$i} ) and $data{$i} ne '' ) {#Bugfix20030212: create_conn if field defined ...
                $conndb{$name}{$i} = _create_conn( $1, $data{$i}, %data );
            } else {
                $conndb{$name}{$i} = []; #Initialize empty array. Will be removed later on
            }
        } elsif ( defined( $data{$i} ) ) {
            $conndb{$name}{$i} = $data{$i};
        } else {
            $conndb{$name}{$i} = $ehr->{$i}[3]; # Set to DEFAULT Value
            # TODO : Initialize fields to empty / Marker, set DEFAULT if still empty at end
        }
        #wig20030801/20050713: remove %NULL% and %EMPTY% on the fly ...
        unless( ref( $conndb{$name}{$i} ) ) {
        	my $null = $eh->get( 'macro.%NULL%' );
        	$conndb{$name}{$i} =~ s/%NULL%/$null/g; # Just to make sure fields are initialized
        	my $empty = $eh->get( 'macro.%EMPTY%' );
        	$conndb{$name}{$i} =~ s/%EMPTY%/$empty/g; # Just to make sure fields are initialized
        }
        #!wig: shifted down (bug20040319): delete( $data{$i} );
    }
    #
    # Now remove keys read in by previous loop
    #
    for my $i ( keys %$ehr ) {
        delete( $data{$i} );
    }

    #
    # Add the rest, too
    #
    for my $i( keys( %data ) ) {
        $conndb{$name}{$i} = $data{$i};
    }

    # Give each signal a unique number: starting from 0 ...
    $conndb{$name}{'::connnr'} = $eh->inc( 'sum.conn' );
} # End of create_conn

####################################################################
## _create_conn
## create/add/modify a bus/signal/connection from the ::in/::out field
####################################################################

=head2

_create_conn ($$%)

Create/add/modify a bus/signal/connection; convert input into simple array of hashes.
The third argument should contain current data for ::high, ::low and ::mode

Recognize constant values like:

=over 4

=item hex

0x[0-9a-f] ....

=item octal

0[0-7] ...

=item quoted by " or '

    "VALUE" or 'VALUE'

Value can just be anything ... will be added literally to the output architecture.

Returns mode and a array of hashes.

!wig20051010: create a ::descr field in the port map ...
!wig20060413: detect whitespace and alert user ...

=cut

sub _create_conn ($$%) {
    my $inout = shift;
    my $instr = shift;
    my %data = @_;

    my $tcmethod = ( $eh->get( 'output.generate.workaround.typecast' )
    	=~m/\bintsig\b/ );

    # Inform user if upper/lower bounds is not-a-number
    my $naninfo  = ( $eh->get( 'check.signal' ) =~ m/\bnanbounds\b/io );

    #A bus with ::low and ::high
    my $h = undef;
    my $l = undef;
    my $hldigitflag = 0; # Assume ::high and ::low are no digits!

    # TODO : check bus definitions better!
    if ( defined( $data{'::low'} ) and defined ( $data{'::high'} ) ) {
        $data{'::low'} =~ s,^\s+,,; # Remove leading white-space
        $data{'::high'} =~ s,^\s+,,; # Remove leading white-space

        if ( $data{'::high'} ne '' ) {
            unless ( $data{'::high'} =~ /^\d+$/ ) {
                $logger->info( '__I_CREATE_CONN_H_NAN', "\tBus $data{'::name'} upper bound $data{'::high'} not a number!" )
                	if ( $naninfo );
                $hldigitflag = 0;
            } else {
                $hldigitflag++;
            }
            $h = $data{'::high'}; # ::high can be string, too ...
        }
        if ( $data{'::low'} ne '' ) {
            unless ( $data{'::low'} =~ /^\d+$/ ) {
                $logger->info( '__I_CREATE_CONN_L_NAN', "\tBus $data{'::name'} lower bound $data{'::low'} not a number!" )
                	if ( $naninfo );
                $hldigitflag = 0;
            } else {
                $hldigitflag++;
            }
            $l = $data{'::low'};
        }
        if ( defined( $h ) and defined( $l ) and $hldigitflag == 2 and $h < $l ) {
            $logger->info( '__I_CREATE_CONN_ORDER', "\tHINT for " . $data{'::name'} .
                     ": unusual bus ordering $h downto $l" );
        }
    }
    my @co = (); # Collect ports defined here ...
    unless( defined( $instr ) and $instr ne '' ) {
        $logger->warn( '__W_CREATE_CONN', "\tCalled _create_conn without data for $inout");
        return \@co; #Return dummy array, just in case
    }

    # Allowed seperators: , and ; in in/out columns
	#!wig20070122: remember creation order -> _nr_
    $instr =~ s/\n/,/go;
    for my $d ( split( /[,;]/, $instr ) ) {
    	my %co = ();
        next if ( $d =~ /^\s*$/o );
		$co{'_nr_'} = $eh->postinc('sum.port');
            #
            # Recognized signal descriptions:
            #
            #   All (N) will be automatically extended (N:N)
            #   If / is missing -> replace MOD by MOD/%::name%
            #
            #   MOD/SIG(PF:PT) = (SF:ST)
            #   MOD/SIG = (SF:ST)           <- (PF:PT) := (SF-ST:0)
            #   MOD/SIG(PF:PT)              <- (SF:ST) := (PF-PT:0)
            #   MOD/SIG                 take SF:ST and PF,PT from ::high and ::low
            #!wig20050519:
            #   MOD/%LOG(_N)%/SIG(PF:PT)    <- convert to MOD_%LOG(_N)% instance name
            #!wig20060905:
            #	MOD/PORT[(PF:PT)] = (`USER_DEFINE)
            #

            $d =~ s,^\s+,,o; # Remove leading whitespace
            $d =~ s,\s+$,,o; # Remove trailing whitespace
            $d =~ s,%::,%##,og; # Mask %:: ... vs. N:N

			# Alert user if there is still whitespace in
            #
            # Recognize 0xHEX, 0OCT, 0bBIN and DECIMAL values in ::out
            # Also: 10.2, 1_000_000, 16#hex#, 2#binary_binary#, 2.2e-6 10ns 2.27[mnfpu]s
            # Recognize 'CONST' and "CONST"
            # Mark with %CONST% instance name .... the port name will hold the value
            # Force anything following %CONST%/ to be a constant value
            #Additionally allow partial assignments by a  =(N:M) ...
            $d =~ s,__(CONST|GENERIC|PARAMETER|BUS)__,%$1%,g; # Convert back __CONST__ to %CONST%
            # A constant could hold a partial assignment, too:

			# Map [N:M] to (M:N) ....
			#!wig: added 20060215
			$d =~ tr/\[\]/()/;

            my ( $cd, $cpart ) = split( /=/, $d, 2 );
            if (
                # Get VHDL constants : B#VAL#
                $cd =~ m,^(%(CONST|GENERIC|PARAMETER)%/)?(\d+#[_a-f\d]+#)\s*$,io or
                # or 0xHEX or 0b01xzhl or 0777 or 1000 (integers)
                $cd =~ m,^(%(CONST|GENERIC|PARAMETER)%/)?(0x[_\da-f]+|0b[_01xzhl]+|0[_0-7]+|[\d][._\d]*)\s*$,io or
                # or reals or time definitions: ... 1 ns, 1.3 ps ...
                $cd =~ m,^(%(CONST|GENERIC|PARAMETER)%/)?([+-]*[_\d]+\.*[_\d]*(e[+-]\d+)?\s*([munpf]s)?)\s*$,io or
                # or anything in ' text ' or " text "
                $cd =~ m,^(%(CONST|GENERIC|PARAMETER)%/)?((['"]).+\4)\s*$,io or  # ' match
                # or anything following a %CONST%/ or GENERIC or PARAMETER keyword
                $cd =~ m,^(%(CONST|GENERIC|PARAMETER)%/)(.+)\s*,io
                ) { # Constant value ...
                my $const = $3;
                $co{'rvalue'} = $const; # Save raw value!!
                my $t = $2;
                if ( $inout =~ m,in, ) {
                    $logger->error('__E_CREATE_CONN', "\tIllegal constant value for signal in ::in " . $data{'::name'} . "!");
                    $data{'::comment'} .= "__E_BAD_CONSTANT_DEFINED";
                }
                if ( defined( $t ) ) {
                    $co{'inst'} = "%" . $t . "%";
                } elsif ( defined( $data{'::mode'} ) ) {
                # Derive instance/type from mode field ....
                    if ( $data{'::mode'} =~ m,^\s*G,io ) {
                        $co{'inst'} = '%GENERIC%';
                    } elsif ( $data{'::mode'} =~ m,^\s*P,io ) {
                        $co{'inst'} = '%PARAMETER%';
                    } else {
                        $co{'inst'} = '%CONST%';
                    }
                } else {
                        $co{'inst'} = '%CONST%';
                }

                # Convert input data ...hex, binary and decimal to decimal ....
                if ( $d =~ m,^0x,io ) {
                    $const = hex( $const ); # Handles hex and octal
                } elsif ( $d =~ m,^0[0-7]+,io ) {
                    $const = oct( $const ); # Handles oct and binary ....
                } elsif ( $d =~ m,^(0b[01xzhl]+),io ) {
                    # Convert hl to 10.
                    #TODO: What about x and z??
                    $const =~tr/HhLl/1100/;
                    $const = oct( $const );
                }
                $const =~ tr/'/"/; # Convert ' to " (otherwise ExCEL will eat it). # "

                $co{'port'} = $const; # Decimal base or literal

                # Inherit bus width from signal definition or if a =() is attached ...
                #  but start at zero! Constants should not have an offset
                if ( $cpart ) {
                    #  (N), (N:N) ... assign appr. port_f:port_t and sig_f:sig_t
                    if ( $cpart =~ m,^\s*\(([\w%#]+)(:([\w%#]+))?\), ) {
                        my ( $mh, $ml ) = ( $1, $3 );
                        $co{'port_t'} = 0;
                        if ( not defined($ml)  ) { # No lower bound -> single bit width
                            $co{'port_f'} = 0;
                            $co{'sig_f'} = $co{'sig_t'} = $mh;
                        } elsif ( $mh =~ m/^\d+$/ and $ml =~ m/^\d+$/ ) {
                            $co{'port_f'} = $mh - $ml;
                            $co{'sig_f'} = $mh;
                            $co{'sig_t'} = $ml;
                        } else { # ( $ml =~ m/^\d+$/ ) #
                            $co{'port_f'} = "$mh - $ml";
                            $co{'sig_f'} = $mh;
                            $co{'sig_t'} = $ml;
                            $logger->debug( '__D_CREATE_CONN', "\tTextual bounds for constant" );
                        }
                    } else {
                        $logger->warn( '__W_CREATE_CONN', "\tCannot parse constant signal assignment width definition: $cpart" );
                        $co{'port_f'} = $co{'sig_f'} = $h;
                        $co{'port_t'} = $co{'sig_t'} = $l;
                    }
                }else {
                    # Full bus assigned ...
                    $co{'port_f'} = $co{'sig_f'} = $h;
                    $co{'port_t'} = $co{'sig_t'} = $l;
                }

                $co{'value'} = $const;
				#!wig20051010: adding 'comment' for each port ...
				if ( exists( $data{'::descr'}) and
					defined $data{'::descr'} and $data{'::descr'} ne '' ) {
					$co{'_descr_'} = $data{'::descr'};
				}
                push( @co, { %co } );
                next;
            } #end of constants

            #
            # Port and signal names and bounds may be composed of
            # \w   alphanumeric and _
            # %   marker for macros
            # :    part of macro like %::name% (converted to # here)
            # `user_define

            #
            # Normal inst/ports ....
            #

			# Remove embedded whitespace, detect remaining whitespace
			#!wig20060413
			if ( $d =~ m/\s/ ) {
				# Remove allowed whitespace around  =
				$d =~ s/\s+=/=/;
				$d =~ s/=\s+/=/;
				if ( $d =~ m/\s/ ) {
					$logger->error( '__E_CONN_PORTWS', "\tPort description '$d' has embededded whitespace! Fix input!" );
				}
			}

            #!wig20051024: check for 'reg or 'wire
            #  -> will be added to port definition ....
            if ( $d =~ m,(/?'(reg|wire)), ) { # Define reg or wire for verilog output: inst/port'reg or inst/'wire  # '
                $co{'rorw'} = $2;
                $d =~ s,$1,,;
            }

            #wig20030801: typecast port'cast_func ...
            #wig20040803: adding advanced typecast function: convert typecast request
            #  into internal instance (%TC_xxxxx%) mapper
            my $tcdo = '';
            if ( $d =~ m,(/?'(\w+)), ) { # Get typecast   inst/port'cast or inst/'cast  # '
                if ( $tcmethod ) {
                    # Create a mapper instance and attach the signal the following way
                    $tcdo = $2;
                }
                $co{'cast'} = $2;
                $d =~ s,$1,,;
            }

			#!wig20060921: `defines are handeled specially in (...), when there
			#		is no :
			# use "magic" %TICK_DEFINE_<define>% key, which will get replaced
			#  later on.
			while ( $d =~ m/\((\s*`[\w%#]+)\)/g ) {
				$d =~ s/\(\s*`([\w%#]+)\)/(`$1:%TICK_DEFINE_$1%)/;
			}
            $d =~ s/\(([\w%#`]+)\)/($1:$1)/g; # Extend (N) to (N:N)

            # Detect MOD/%LOGIC(_N)% -> MOD_%LOGIC(_N)%/....
            # if( $d =~ m,^(.+)/(%\w+((_)?\d+)?%)(/(.+))?, ) {
            #	my $pre = $1;
            #	my $pot_logic = $2;
            #	my $rest = $5;
            #	# XXXXXX20050520;
            # }

            if ( $d !~ m,/,o ) { # Add signal name as port name by default
                $d =~ s,([\w%:#]+),$1/%::name%,;
            }


           if ( $d =~ m,([\w%#]+)/(\S+)\(([\w%#`]+):([\w%#`]+)\)=\(([\w%#`]+):([\w%#`]+)\), ) {
                # INST/PORTS(pf:pt)=(sf:st)
                _check_portspecm( $d, $-[0], $+[0] );
                $co{'inst'} = $1;
                $co{'port'} = $2;
                $co{'port_f'} = $3;
                $co{'port_t'} = $4;
                $co{'sig_f'} = $5;
                $co{'sig_t'} = $6;
            } elsif ( $d =~ m,([\w%#]+)/(\S+)=\(([\w%#`]+):([\w%#`]+)\), ) {
                # INST/PORTS=(f:t) Port-Bit to Bus-Bit f = t; expand to pseudo bus?
                #TODO: Implement better solution (e.g. if Port is bus slice, not bit?
                #wig20030207: handle single bit port connections ....
                _check_portspecm( $d, $-[0], $+[0] );
                if ( $3 eq $4 ) {
                    $co{'inst'} = $1;
                    $co{'port'} = $2;
                    $co{'port_f'} = 0; #Port is bit, not bus
                    $co{'port_t'} = 0; #Port is bit, not bus
                    $co{'sig_f'} = $3;
                    $co{'sig_t'} = $4;
                } else { # Assume we connect to ($f - $t) downto 0 !
                    $co{'inst'} = $1;
                    $co{'port'} = $2;
                    $co{'sig_f'} = $3;
                    $co{'sig_t'} = $4;
                    if ( $4 ne '0' ) {
                        # Wire port of width
                        my $f = $3;
                        my $t = $4;
                        my $inst = $1;
                        my $port = $2;
                        if ( $f =~ m,^(\d+)$,o and $t =~ m,^(\d+)$,o ) {
                      		$logger->warn('__W_CREATE_CONN',
                        		"\tAutomatically wiring signal bits $f to $t of $inst/$port to bits " .
                        			( $f - $t ) . " to 0");
                            $co{'port_f'} = $f - $t;
                            $co{'port_t'} = 0;
                        } elsif ( $f eq $t ) {
                        	# Another special case: single bit
                        	$logger->warn('__W_CREATE_CONN',
                        		"\tAutomatically wiring signal bit $f of $inst/$port to bit 0");
                            $co{'port_f'} = 0;
                            $co{'port_t'} = 0;
                        #!wig20061030a: get port_width from `define signal assignment
                        } elsif ( $f =~ m/^`(\w+)/ and $t =~ m/%TICK_DEFINE_$1%/ ) {
                        	$co{'port_f'} = $f;
                        	$co{'port_t'} = $t;
                        } else {
                            # TODO : Needs to be checked ... autowiring does not work here!
                      		$logger->warn('__W_CREATE_CONN',
                        		"\tAutomatically wiring signal bits $f to $t of $inst/$port to bits '$f - $t' to 0");
                            $co{'port_f'} = "$f - $t";
                            $co{'port_t'} = 0;
                        }
                    } else {
                        $co{'port_f'} = $3; # - $4 ;
                        $co{'port_t'} = 0;
                    }
                }
            } elsif ( $d =~ m,([\w%#]+)/(\S+)\(([\w%#`]+):([\w%#`]+)\), ) {
            	_check_portspecm( $d, $-[0], $+[0] );
                # INST/PORTS(f:t)
                $co{'inst'} = $1;
                $co{'port'} = $2;
                $co{'port_f'} = $3;
                $co{'port_t'} = $4;
                if ( $4 ne '0' ) {
                    my $f = $3;
                    my $t = $4;
                    if ( $t =~ m,^(\d+)$,o and $f =~ m,^(\d+)$,o ) {
                        $co{'sig_f'} = $f - $t;
                        $co{'sig_t'} = 0;
                    } else {
                        $co{'sig_f'} = "$f - $t"; # TODO : Is that a good idea?
                        $co{'sig_t'} = 0;
                    }
                } else {
                    $co{'sig_f'} = $3;
                    $co{'sig_t'} = 0;
                }
            } elsif ( $d =~ m,([\w%#]+)/(\S+), ) {
                # INST/PORTS
                _check_portspecm( $d, $-[0], $+[0] );
                $co{'inst'} = $1;
                $co{'port'} = $2;
                $co{'port_f'} = $h;
                $co{'port_t'} = $l;
                $co{'sig_f'} = $h;
                $co{'sig_t'} = $l;
            } elsif ( $d =~ m,([\w%#]+), ) {
            	_check_portspecm( $d, $-[0], $+[0] );
                $co{'inst'} = $d;
                $co{'port'} = $data{'::name'}; #Port name equals signal name
                $co{'port_f'} = $h;
                $co{'port_t'} = $l;
                $co{'sig_f'} = $h;
                $co{'sig_t'} = $l;
            }else {
                # INST
                $co{'inst'} = $d;
                $co{'port'} = $data{'::name'}; #Port name equals signal name
                $co{'port_f'} = $h;
                $co{'port_t'} = $l;
                $co{'sig_f'} = $h;
                $co{'sig_t'} = $l;
            }

			#!wig20051010: adding 'comment' for each port ...
			if ( exists( $data{'::descr'}) and
				defined $data{'::descr'} and $data{'::descr'} ne '' ) {
				$co{'_descr_'} = $data{'::descr'};
			}

            check_conn_prop( \%co );

			#!wig20060329: adding hierachy automatically if needed
			if ( $eh->get( 'hier.req' ) =~ m/\bauto/ ) {
				_add_inst_auto( $co{'inst'} );
			}

            # We have a full description of this port, now add typecast_wrapper
            #wig20040803, typecast wrapper

            # no typecast for std_logic vs. std_ulogic:
            if ( $eh->get( 'output.generate.workaround.std_log_typecast' ) =~ m/\bignore\b/io
                and $tcdo =~ m/^std_(u)?logic$/io ) {
                if ( $data{'::type'} =~ m/^std_(u)?logic$/io ) {
                    $tcdo = "";
                }
            }
            if ( $tcdo ) {
                my $tcwr = '%TYPECAST_' . $eh->postinc( 'TYPECAST_NR' ) . '%' ;
                my $tcsig = $eh->get( 'postfix.PREFIX_TC_INT' ) .
                	$eh->get( 'TYPECAST_NR' ) . "_" . $data{'::name'};
                my @tcassign = ();
                if ( $inout =~ m/in/ ) {
                    @tcassign = ( $tcsig , $tcdo, $data{'::name'} );
                } else {
                    @tcassign = ( $data{'::name'}, $data{'::type'}, $tcsig );
                }
                add_inst( '::inst' => $tcwr,
                              '::parent' => $hierdb{$co{'inst'}}{'::parent'},
                              '::entity' => '%TYPECAST_ENT%', # Just dummies
                              '::config' => '%TYPECAST_CONF%', # Just dummies
                              '::lang' => 'vhdl',              # typecast in for VHDL
                              '::typecast' => \@tcassign , # remember what to typecast
                            );

                my $oe = ( $inout =~ m/in/  ) ? "::out" : "::in"; # opposite end
                my $portdef = "";

               #EARLY: Early expansion of port name required here
                if ( $co{'port'} eq "%::name%" ) {
                    $co{'port'} = $data{'::name'};
                }

                # generate port description ::in <-> ::out  for intermediate signal
                my $oecon = $tcwr . "/" . $co{'port'} . mix_p_co2str( $co{'port_f'}, $co{'port_t'} ) .
                        "=" . mix_p_co2str( $co{'sig_f'}, $co{'sig_t'} );

                # TODO : will we need more expansion? Maybe the intermediate signal should inherite
                #   all features from the originating signal ...
                my $oeicon = $co{'inst'} . '/' . $co{'port'} . mix_p_co2str( $co{'port_f'}, $co{'port_t'} ) .
                        "=" . mix_p_co2str( $co{'sig_f'}, $co{'sig_t'} );
                $oecon =~ s/=$//;
                $oeicon =~ s/=$//;

                #!wig20040805: add all of current line settings, just overload some values ...
                my %ec = %data;
                $ec{'::type'} = $tcdo;
                $ec{'::name'} = $tcsig;
                $ec{'::high'} = $h;   # TODO : Maybe that is to much? And we could
                $ec{'::low'} = $l;    # use the port border's, ... obviously noone should typecast
                                      # just parts of ports
                $ec{'::mode'} = 'S';
                $ec{'::comment'} = '__I_TYPECAST_INT' . ( defined( $ec{'::comment'} ) ?
                            ( " " . $ec{'::comment'} ) : "" );
                $ec{'::' . $inout} = $oeicon;
                $ec{$oe} = $oecon;
                add_conn( %ec );
                # Overload connection instance (shift typecast wrapper inplace ...)
                $co{'inst'} = $tcwr;

            }
            push( @co, { %co } );
    }
    return ( \@co );
} # End of _create_conn

#
# See if port spec matched whole input string
#
sub _check_portspecm ($$$) {
	my $string = shift;
	my $start  = shift;
	my $end    = shift;

	if ( $start > 0 or $end < length( $string ) ) {
		$logger->error('__E_CONN_PORTSPEC', "\tinst/port spec '$string' has leading/trailing junk! Ignored! Fix input data!" );
	}
	return;
} # End of _check_portspecm

#
# Automatically create "flat" hierachy if needed ...
#
sub _add_inst_auto ($) {
	my $inst = shift;

	return if ( exists $hierdb{$inst} );

	# add to "testbench", define level of warning
	#   by number of parsed hier sheets ...
	# Warn user if hier.parsed > 0

	add_inst(
		'::inst' => $inst,
		'::entity' => ( $inst . '%AUTOENTY%' ),
		'::config' => ( $inst . '%AUTOCONF%' ),
		'::parent' => '%TESTBENCH%',
		'::comment' => '__W_AUTOHIER: automatic hierachy created',
		'::descr'	=> '__I_AUTOHIER: Automatically created and linked to %TESTBENCH%',
		'::__source__' => 'auto',
	);
	if ( $eh->get( 'hier.parsed' ) > 0 ) {
		$logger->error( '__E_AUTOHIER', "\tAutomatically created hierachy for instance " .
			$inst );
	} else {
		$logger->info( '__I_AUTOHIER', "\tAutomatically created hierachy for instance " .
			$inst );
	}

} # End of _add_inst_auto

#
# convert given boundaries to (F:T) description
#
sub mix_p_co2str ($$) {
    my $f = shift;
    my $t = shift;

    my $portdef = "";
    if ( defined $t and defined $f ) {
        $portdef = "(" . $f . ":" . $t . ")";
    } elsif ( defined $f ) {
        $portdef = "(" . $f . ")";
    } elsif ( defined $t ) {
        $portdef = "(:" . $t . ")";
        $logger->warn( '__W_CO2STR', "\tBad port description in co2str input def: <UNDEF>/$t" );
    }
    return $portdef;
}

#
# Check connection propertie, resubstitute # -> :
#
#TODO: If value is set, make sure we have mode set to C or G or P
sub check_conn_prop ($) {
    my $ref = shift;

    foreach my $i ( qw( inst port port_f port_t sig_f sig_t ) ) {
        if ( $ref->{$i} ) { $ref->{$i} =~ y/#/:/; }
    }

    if ( $ref->{'inst'} !~ m,^[:%\w]+$,o ) {
        $logger->warn( '__W_CONN_PROP', "\tUnusual character in signal name: $ref->{'inst'}/$ref->{'port'}!" );
    }
    if ( $ref->{'port'} !~ m,^[:%\w]+$,o ) {
        $logger->warn( '__W_CONN_PROP', "\tUnusual character in port name: $ref->{'inst'}/$ref->{'port'}!" );
    }

}

#
# Retrieve conncetion properties
# Input:    $name = connection name
#              $props = comma seperated list of properties
#
sub mix_p_retcprop ($$) {
    my $name = shift;
    my $props = shift;

    my %data = ();

    if ( exists( $conndb{$name} ) ) {
        for my $i ( split( /[\s,]+/, $props ) ) {
            if ( exists( $conndb{$name}{$i} ) ) {
                $data{$i} = $conndb{$name}{$i};
            }
        }
    } else {
        return undef;
    }

    return \%data;

}

#
# Retrieve conncetion properties
# Input:    $name = connection name
#              $props = comma seperated list of properties to update ...
#
# Caveat: there will be NO extensive error checking done here ...
#
sub mix_p_updateconn ($$) {
    my $name = shift;
    my $props = shift;

    my %data = ();

    unless( exists( $conndb{$name} ) ) {
        $logger->error( '__E_UPDATECONN', "\tCannot update connection $name!" );
    } else {
        for my $i ( keys( %$props ) ) {
            $conndb{$name}{$i} = $props->{$i};
        }
    }

    return;
}

#
# merge more data into an already existing connection
#
#!wig20070320: special key %PURGE% will remove all previously defined data for that signal
sub merge_conn($%) {
    my $name = shift;
    my %data = @_;

    #
    # Overwrite conndb if fields are zero or space ....
    #
    for my $i ( keys( %data ) ) {
        # TODO : Trigger merge mode for special cases where we want to add
        # up data instead of overwrite

		#!wig20070320: experimental: remove all previously defined data:
		if ( defined( $data{$i} ) and $data{$i} eq '%PURGE%' ) {
			if ( $i =~ /^::(in|out)$/ ) {
				$conndb{$name}{$i} = [];
			} else {
				$conndb{$name}{$i} = '';
			}
			next;
		}

        if ( $i =~ /^::(in|out)$/ ) {
			#!wig20060116: check if data is defined:
        	if ( defined( $data{$i} ) and $data{$i} !~ /^\s*$/io ) {
        		# If the ::in or ::out is an array -> simply push
        		if ( ref( $data{$i} ) eq 'ARRAY' ) {
        			push( @{$conndb{$name}{$i}}, @{$data{$i}} );
        		} else {
                	# Add array to in/out field, if the cell contains data
                	push( @{$conndb{$name}{$i}} , @{_create_conn( $1, $data{$i}, %data )});
        		}
            }
        } elsif ( $i =~ /^::type\b/ ) {
            #
            # ::type requires special handling
            # Complain if ::type does not match
            #
            if ( $conndb{$name}{$i} and
                 $conndb{$name}{$i} !~ m,%(SIGNAL|BUS_TYPE)%,o and
                 $conndb{$name}{'::name'} !~ m,%OPEN(_\d+)?%, ) {
                 # conndb{$name}{::type} is defined and ne the default
                 if ( $data{$i} and $data{$i} !~ m,%(SIGNAL|BUS_TYPE)%,o ) {
                    my $t_cdb = $conndb{$name}{$i};
                    if ( $data{$i} ne $t_cdb ) {
                        $logger->error( '__E_MERGE_CONN', "\tType mismatch for signal $name: $t_cdb ne $data{$i}!" );
                        $conndb{$name}{$i} = "__E_TYPE_MISMATCH";
                        $conndb{$name}{'::comment'} .= "#__E_TYPE: $t_cdb ne $data{$i} ";
                    }
                } # else leave conndb as is
            } else {
                # ::type was not set so far, therefore we overwrite if the input data has type defined
                if ( $data{$i} ) {
                    $conndb{$name}{$i} = $data{$i};
                }
            }
        } elsif ( $i =~ /^\s*::mode\b/o ) {
            #
            # Mode has to match!
            # I, O and IO have precedene over %SIGNAL% and "S"
            # If the user mixes G and C in, he is out of luck ... and we print error!
            if ( $conndb{$name}{$i} and $conndb{$name}{$i} ne "%DEFAULT_MODE%" ) {
                # conndb{$name}{::mode} is defined and ne the default
                 if ( $data{$i} and $data{$i} ne "%DEFAULT_MODE%" ) {
                    my $t_cdb = $conndb{$name}{$i};
                    unless ( $data{$i} eq $t_cdb ) {
                        if ( $t_cdb eq 'S' and $data{$i} =~ m/^(I|O|IO)/o ) {
                            $conndb{$name}{$i} = $data{$i};
                        }elsif ( $t_cdb =~ m,^\s*[GCP],io and $data{$i} =~ m,^\s*[GCP],io ) {
                            # Do nothing here ...
                            ;
                        } elsif ( not ( $data{$i} eq 'S' and $t_cdb =~ m/^(I|O|IO)/o ) ) {
                            $logger->error( '__E_MERGE_CONN', "\tMode mismatch for signal $name: $t_cdb ne $data{$i}!" );
                            $conndb{$name}{$i} = "__E_MODE_MISMATCH";
                            $conndb{$name}{'::comment'} .= "#__E_MODE: $t_cdb ne $data{$i} ";
                        }
                    }
                } # else leave conndb as is
            } else {
                # ::mode was not set so far, therefore we overwrite if the input data has type defined
                if ( $data{$i} ) {
                    $conndb{$name}{$i} = $data{$i};
                }
            }
        } elsif ( $i =~ /^\s*::(high|low)\b/o ) {
            if ( defined($conndb{$name}{$i}) and $conndb{$name}{$i} ne '' ) {
                # There was already s.th. defined for this bus
                if ( defined( $data{$i} ) and $data{$i} ne '' and $conndb{$name}{$i} ne $data{$i} ) {
                    # LOW and HIGH "signals" are special.
                    if ( $name =~ m,^\s*%(LOW|HIGH)_BUS(_\d+)?%,o ) { # Accept larger value for upper bound
						if ( $data{$i} =~ m/^\d+/ ) {
                        	if ( $i =~ m,^\s*::high,o ) {
                            	$conndb{$name}{$i} = $data{$i} if ( $data{$i} > $conndb{$name}{$i} );
                        	} elsif ( $i =~ m,^\s*::low,o ) {
                            	$conndb{$name}{$i} = $data{$i} if ( $data{$i} < $conndb{$name}{$i} );
                        	}
						} else {
                        	$logger->warn( '__W_MERGE_HIGHLOW', "\tconflicting width values for $name($i): $conndb{$name}{$i} ne $data{$i}!");
						}
                    } elsif ( $name =~ m,^\s*%OPEN(_\d+)?%,o ) {
                        if ( not defined( $conndb{$name}{$i} ) or $conndb{$name}{$i} eq ""
                             or $conndb{$name}{$i} eq "%NULL%" ) {
                            $conndb{$name}{$i} = $data{$i};
                        } else {
                            if ( $data{$i} =~ m,^\d+$,o and $conndb{$name}{$i} =~ m,^\d+$,o ) {
                                if ( $i =~ m,^\s*::high,o ) {
                                    $conndb{$name}{$i} = $data{$i} if ( $data{$i} > $conndb{$name}{$i} );
                                } elsif ( $i =~ m,^\s*::low,o ) {
                                    $conndb{$name}{$i} = $data{$i} if ( $data{$i} < $conndb{$name}{$i} );
                                }
                            } else {
                                $conndb{$name}{$i} .= "," . $data{$i}; #Bad, just need to concatenate ...
                            }
                        }
                    } else {
                        $logger->error( '__E_MERGE_CONN', "\tBound mismatch for signal $name: $conndb{$name}{$i} ne $data{$i}!");
                        $conndb{$name}{$i} = "__E_BOUND_MISMATCH";
                    }
                }
            } else {
                $conndb{$name}{$i} = $data{$i};
            }
        } elsif ( $i =~ /^\s*::(gen|comment|descr)\b/o ) {
            # Accumulate generator infos, comments and description
            if ( $data{$i} and $data{$i} ne '%EMPTY%' ) {
                #wig20031106: try to keep comments short ....
                #   replace "text text" by "text X2"
                #   check if $data{$i} is part of $conndb{$name}{$i}
                my $pos = rindex( $conndb{$name}{$i}, $data{$i} );
                if ( $pos >= 0 and $eh->get( 'output.generate.fold' ) =~ m,signal,io ) {
                    my $text = substr( $conndb{$name}{$i}, $pos );
                    my $occurs = 0;
                    $text = substr( $text, length( $data{$i} )); # Take rest of text ...
                    if ( $text =~ m/^\s*\(X(\d+)\)/ ) {
                        $occurs = $1 + 1;
                        $text =~ s/^\s*\(X\d+\)/ (X$occurs)/;
                    } else {
                        $occurs = 2;
                        $text = " (X2)" . $text;
                    }
                    # Put back text ...
                    substr( $conndb{$name}{$i}, $pos ) = $data{$i} . $text;
                } else {
                    $conndb{$name}{$i} .= $data{$i};
                }
            }
        } else {
            #TODO: Overwrite data ??? Is that always the right way to go
            #TODO: Get that information from $eh ....
            if ( $data{$i} ) {
                $conndb{$name}{$i} = $data{$i};
            }
        }
    }
}

####################################################################
## mix_store_db
## dump data onto disk
## format is either set as argument or automatically deteced by file name extension
####################################################################

=head2

mix_store_db ($$$)

Save intermediate connection and hierachy data into disk file.
Arguments:
    $file  filename to dump or "out" (will be replaced by the filename provided by
            -out FILE or the default, which is INPUT-mixed.ext
    $type auto,xls,csv or internal; auto tries to guess the preferred format from
           the output file name
    $vars hashref with variables to dump; by default it will dump hierachy and connectivity matrix
=cut


sub mix_store_db ($$$) {
    my $dumpfile = shift;
    my $type = shift || "internal";
    my $varh = shift || {} ;

    if ( $dumpfile eq "out" ) {
        $dumpfile = $eh->get( 'out' );
    }

    if ( $dumpfile eq "dump" ) {
        $dumpfile = $eh->get( 'dump' );
    }

    if ( $type eq "auto" ) {
        # Derive output format from output name extension
        if ( $dumpfile =~ m,\.(xls|sxc|csv|ods|xml)$, ) {
                $type=$1;
        } else {
        # Default to "internal" format
                $type="internal";
        }
    }

    if ( $type eq 'xls' || $type eq 'sxc' || $type eq 'csv' || $type eq 'ods' ) {
        my $aro = mix_list_econf( 'xls' ); # Convert $eh to two-dim array

		# db2array
		#!wig20051012: if eh(intermediate.intra) is set,
		#  arc is done differentely!
		# ar will get a hash with sheet names, which reference arrays with data
		#
		my $arc;
		if ( $eh->get( 'intermediate.intra' ) ) {
			my @tops = get_top_cell();
			$arc = db2array_intra( \%conndb, 'conn', \@tops, \%hierdb, '' );
		} else {
        	$arc->{'CONN'} = db2array( \%conndb , 'conn', $type, '' );
		}
        my $arh = db2array( \%hierdb, 'hier', $type, "^(%\\w+%|W_NO_PARENT)\$" );
        if ( $eh->get( 'output.generate.delta' ) ) {
            my $conf_diffs = write_outfile( $dumpfile, "CONF", $aro ); # Do not generate deltas, just output
			my $conn_diffs = 0;
			for my $conns ( keys( %$arc ) ) {
            	$conn_diffs += write_delta_sheet( $dumpfile, $conns, $arc->{$conns} );
			}
            my $hier_diffs = write_delta_sheet( $dumpfile, "HIER", $arh );
            if ( defined( $conn_diffs ) and defined( $hier_diffs ) ) {
                $eh->set( 'DELTA_INT_NR', $conn_diffs + $hier_diffs );
            } else {
                $eh->set( 'DELTA_INT_NR', -1 ); # This only happens if no CONN or HIER sheet was available
            }
        } else {
            write_outfile( $dumpfile, "CONF", $aro ); #wig20030708: store CONF options ...
			for my $conns ( keys( %$arc ) ) {
            	write_outfile( $dumpfile, $conns, $arc->{$conns} );
			}
            write_outfile( $dumpfile, "HIER", $arh );
        }
        if($eh->get( 'intermediate.strip' ) ) {
	    	clean_temp_sheets($eh->get( 'out' ));
		}
		close_open_workbooks(); # Close everything we opened
    } else {
        if ($type eq 'xml') {
            $logger->info('__I_STORE_DB', "\tno dumper for .xml implemented");
        } else {
            if ( $type ne "internal" ) {
                $type="intermediate";
            }
            mix_store( $dumpfile,
                       { 'conn' => \%conndb , 'hier' => \%hierdb, %$varh }, $type);
        }
    }
}

####################################################################
## mix_load_db
## load data dumped by front-end
## format is either given as argument or derived from the dumpfile extension!
####################################################################

=head2

mix_load_db ($$$)

Load intermediate connection and hierachy data from disk.
Arguments:
    $file  filename to load fro
    $type auto,xls,csv or internal; auto tries to guess the preferred format from
           the output file name
    # $vars hashref with variables to load; by default it will load hierachy and connectivity matrix
=cut


sub mix_load_db ($$$) {
    my $dumpfile = shift;
    my $type = shift || "internal";
    my $varh = shift || {} ;

    if ( $dumpfile eq "in" ) {
        $dumpfile = $eh->get( 'dump' );
    }

    unless( -r $dumpfile ) {
        $logger->error( '__E_LOAD_DB', "\tCannot read dump file $dumpfile!\n" );
        exit 1;
    }

    if ( $type eq "auto" ) {
        # Derive output format from output name extension
        if ( $dumpfile =~ m,\.(xls|csv|pli)$, ) {
                $type=$1;
        } else {
        # Default to "internal" format
                $type="internal";
        }
    }
        mix_load( $dumpfile, { 'conn' => \%conndb , 'hier' => \%hierdb });
}

####################################################################
## apply_conn_macro
## do I have to say more?
####################################################################

=head2

apply_conn_macros ($$)

Find MX lines and apply macro definitions (MD) onto connection database.

=cut

sub apply_conn_macros ($$) {
    my $r_in = shift;         # Input connection data
    my $r_cm = shift;       # Preprocessed macro definitions

    for my $i ( 0..$#{$r_in} ) {
        #TODO: next if ( $r_in->[$i]{'::comment'} =~ m,^\s*(#|//),o ); #Skip comment fields
        next if ( $r_in->[$i]{'::ign'} =~ m,^\s*(#|//),o ); # Skip if ::ign is marked
        if ( $r_in->[$i]{'::gen'} =~ m,^\s*MX, ) {
            # Apply all macros ....
            for my $ii ( 0..$#{$r_cm} ) {
                 #
                # Build match string from MX field:  ::field::CONTENT::field2::....
                # This will be matched against mm (prepared from MH fields)
                #
                my $xre = "";
                for my $iii ( 0..$#{$r_cm->[$ii]{'mo'}} ) {
                	# xt if ( ref(
                    $xre .= $r_cm->[$ii]{'mo'}[$iii] . "::";
                    $xre .= defined( $r_in->[$i]{$r_cm->[$ii]{'mo'}[$iii]} ) ?
                    		$r_in->[$i]{$r_cm->[$ii]{'mo'}[$iii]} : '';
                }
                if ( $xre =~ /$r_cm->[$ii]{'mm'}/ ) {
                    # Got it .... catch matched variables and apply to MX line ...
                    $logger->debug( '__I_APPLY_MACRO', "\tMacro $ii matches here");
                    $eh->inc( 'sum.cmacros' );
                    my %mex = ();
                    # Gets matched variables
                    unless ( eval $r_cm->[$ii]{'me'} ) {
                        if ( $@ ) {
                            $logger->error('__E_APPLY_MACRO', "\tEvaluation of macro $ii for macro expansion in line $i failed: $@");
                            next;
                        }
                    }

                    for my $md ( 0..$#{$r_cm->[$ii]{'md'}} ) {
                        # Iterate through the macro definitons and apply values
                        my %ns = %{$r_in->[$i]}; # Use MX input fields as default
                        for my $mf ( keys( %{$r_cm->[$ii]{'md'}[$md]} ) ) {
                            my $e = '$ns{$mf} = "' . $r_cm->[$ii]{'md'}[$md]{$mf}. '"';
                            unless ( eval $e ) {
                                if ( $@ ) { $ns{$mf} = "E_$@" };
                            }
                        }
                        # Mark as generated by MX
                        $ns{'::gen'} = "G_MX";
                        # Add to connection data structure
                        add_conn( %ns );
                    }
                 }
            }
        }
    }
}

####################################################################
## apply_conn_gen
## do I have to say more?
####################################################################

=head2

apply_conn_gen ($)

Scan through all instances and add to connectivity db if matched

Caveat: All generators are executed in order of appearance.
But the plain iterators will be executed up-front (here)!

=cut

sub apply_conn_gen ($) {
    my $r_cg = shift;       # connection gen data

    my $f = \&add_conn;

    # 1. Expand iterators ...
    # TODO : shift that into the apply_x_gen subroutine?
    foreach my $g ( sort( { $r_cg->{$a}->{'n'} <=> $r_cg->{$b}->{'n'} }
    		keys( %$r_cg ) ) ) {
        if ( $g =~ m,^__MIX_ITERATOR_,io ) {
            my $var = $r_cg->{$g}{'var'};
            foreach my $i ( $r_cg->{$g}{'lb'} .. $r_cg->{$g}{'ub'} ) {
                my %in = %{$r_cg->{$g}{'field'}};
                my %g = ();
                foreach my $k ( keys( %in ) ) {
                    if ( $k eq '::gen' ) {
                        $g{$k} = "GIC # \$$var = $i # " . $in{$k};
                    } else {
                        ( $g{$k} = $in{$k} ) =~ s,\$$var,$i,g;
                    }
                }
                # eval ....
                add_conn( %g );
            }
        }
    }
    # We could remove the iterators from the generator data, now

    apply_x_gen( $r_cg, $f );

} # End of apply_conn_gen

####################################################################
## apply_hier_gen
## do I have to say more?
####################################################################

=head2

apply_hier_gen ($)

Scan through all instances and add to instance db if matched

=cut
sub apply_hier_gen ($) {
    my $r_hg = shift;

    my $f = \&add_inst;

    # Expand iterators ...
    foreach my $g ( sort( { $r_hg->{$a}->{'n'} <=> $r_hg->{$b}->{'n'} }
    			keys( %$r_hg ) ) ) {
        if ( $g =~ m,^__MIX_ITERATOR_,io ) {
            my $var = $r_hg->{$g}{'var'};
            foreach my $i ( $r_hg->{$g}{'lb'} .. $r_hg->{$g}{'ub'} ) {
                my %in = %{$r_hg->{$g}{'field'}};
                my %g = ();
                # my $e = '$' . $var . " = $i; ";
                foreach my $k ( keys( %in ) ) {
                    if ( $k eq '::gen' ) {
                        $g{$k} = "GIH # \$$var = $i # " . $in{$k};
                    } else {
                        ( $g{$k} = $in{$k} ) =~ s,\$$var,$i,g;
                    }
                }
                $g{'::__source__'} = 'hier_gen';
                # eval ....
                add_inst( %g );
            }
        }
    }

    # We could remove the iterators from the generator data, now

    # Do the rest ...
    apply_x_gen( $r_hg, $f );

} # End of apply_hier_gen

####################################################################
## apply_x_gen
####################################################################

=head2

apply_x_gen ($$)

Scan through all instances and add instancances or connections if required
Gets ::gen entries and add_function (add_hier or add_conn)

Intermediate data is kept in:

#            $g{$pre}{'var'} = $1;
#            $g{$pre}{'lb'}   = $2;
#            $g{$pre}{'ub'}  = $3;
#            $g{$pre}{'field'} = $rin->[$i];
#            $rin->[$i]{'::comment'} = "# Generator parsed /" . $rin->[$i]{'::comment'};
#        # plain generator: /PERL_RE/
#        elsif ( $rin->[$i]{'::gen'} =~ m!^\s*/(.*)/! ) {
#            $g{$1}{'var'} = undef;
#            $g{$1}{'lb'}   = undef;
#            $g{$1}{'ub'}  = undef;
#            # $g{$pre}{'pre'} = $4;
#            $g{$1}{'field'} = $rin->[$i];
#			 $g{$1}{'n'}
#            $rin->[$i]{'::comment'} = "# Generator parsed /" . $rin->[$i]{'::comment'};

#!wig20070305: adding IF/ELSIF/ELSE feature
			 $rin->[$i]{'link'} = 'if' or 'elsif' or 'else'

=cut
sub apply_x_gen ($$) {
    my $r_hg = shift;   # connection generator data
    my $func = shift;	# which function to call ...

	# Sort generators by number of appearance:
	my %lasthit = (); # Track if/elsif/else
    for my $cg ( sort( { $r_hg->{$a}->{'n'} <=> $r_hg->{$b}->{'n'} }
    		keys( %$r_hg ) ) ) { # Iterate through all known generators ...

		# Skip __MIX_ITERATOR_ ...
		next if ( $cg =~ m,^__MIX_ITERATOR_,io );

		my $ifelslink= $r_hg->{$cg}{'link'};
        # Iterate over CONN or HIER, defined by ...{'ns'} namespace ...
        my $ky = ( $r_hg->{$cg}{'ns'} =~ m,^conn, ) ? \%conndb : \%hierdb ;

        for my $i ( keys( %$ky ) ) { #See if the ::gen matches one of the instances already known
            next if $ky->{$i}{'::ign'} =~ m,^\s*(#|//),o;

			# Skip if we are part of if/elsif/else and last time was a match
			if ( $lasthit{$i} and $ifelslink and $ifelslink ne 'if' ) {
				if ( $ifelslink eq 'else' ) {
					$lasthit{$i} = '';
				}
				next;
			}
			$lasthit{$i} = '';

            unless( $r_hg->{$cg}{'var'} ) {
            # Plain match, no run parameter
                my( $text, $re );
                ( $text, $re ) = mix_p_prep_match( $i, $r_hg->{$cg}{'ns'},
                                                 $ky->{$i}, $r_hg->{$cg}{'pre'} );
                next unless defined( $text );

                # Generator match
                if ( $text =~ m,^$re$, ) { # $text matches $re ... possibly setting $1 ...
                    # Apply all fields defined in generator:
                    #!wig20060125: if namespace contains :splice, iterate over all bit splices!
                    #				$s gets the current value of the bit splice ...
                    $lasthit{$i} = 1;
                    my @splice_range = _mix_p_getsplicerange( $i, $r_hg->{$cg}, $ky );

					if ( scalar( @splice_range ) ) {
						for my $s ( @splice_range ) {
 							_mix_p_dogen( $r_hg->{$cg}, $ky, $s, $cg, $i, $func );
						}
					} else {
						_mix_p_dogen( $r_hg->{$cg}, $ky, '', $cg, $i, $func );
					}
                } else {
                	$lasthit{$i} = '';
                }
            } else {
            # There is an additional run parameter involved: $r_hg{$cg}{'var'}
            # Match first; if it applies, we see if the variable is within range
                my( $text, $re );
                ( $text, $re ) = mix_p_prep_match( $i, $r_hg->{$cg}{'ns'},
                                        $ky->{$i}, $r_hg->{$cg}{'pre'} );
                next unless defined( $text );

                my $matcher = $re;
                my $rv = $r_hg->{$cg}{'var'};
                my %mres = ();
                #
                # $i or {$i + N}
                #
                $matcher =~ s/{.+?}/\\d+/g; #Replace {$i + N} by \\d+
                $matcher =~ s/\$$rv/\\d+/g; #Replace $i by \\d+
                if ( $text =~ m/^$matcher$/ ) {
                	%mres = _mix_p_get_reparmatch( $text, $matcher );
                    #
                    # We found all $N; now let's deal with {EXPR} and $V
                    #
                    ( $matcher = $re ) =~ s,[()],,g; # Remove all parens

                    if ( $matcher =~ s/{.+?}/\\d+/g ) {
                        $logger->error( '__E_APPLY_GEN', "\tIllegal arithmetic expression in $matcher. Will be ignored!" );     # postpone that ....
                    }
                    $matcher =~ s/\$$rv/(\\d+)/g;   # Replace $rv by (\d+)

                    if ( $text =~ m/^$matcher$/ ) { # $1 has value for $rv ... only one variable
                        if ( defined( $1 ) ){
                            $mres{$rv} = $1;
                        } else {
                            $mres{$rv} = "__UNDEF__"; # No run variable in matcher! This is an error!
                            unless( exists( $r_hg->{$cg}{'error'} ) ) {
                                $logger->error( '__E_APPLY_GEN', "\tGenerator " . $r_hg->{$cg}{'field'}{'::gen'} .
                                        " does not define run parameter \$$rv!");
                            }
                            $r_hg->{$cg}{'error'}++;
                            last; # Leave loop here .... TODO: should we alert user?
                        }
                    } else { #Error, this has to match!
                        $logger->fatal( '__F_APPLY_GEN', "\tMatching failed for $cg! File bug report!" );
                        die;
                    }
                    # Check bounds:
                    if ( $r_hg->{$cg}{'lb'} <= $mres{$rv} and
                            $r_hg->{$cg}{'ub'} >= $mres{$rv} ) {
                        # bingo ... this instance matches
                        #
                        # TODO : Handle arith. {$V + N} {$N +N} ...
                        # Basic idea:fetch {...} and evaluate with results known so far
                        # Apply the results to the matcher string and do a last check ...
                        #
                    	$lasthit{$i} = 1;
                        my @splice_range = _mix_p_getsplicerange( $i, $r_hg->{$cg}, $ky );

                     	if ( scalar( @splice_range ) ) {
							for my $s ( @splice_range ) {
 								_mix_p_dogen2( $r_hg->{$cg}, $ky, $rv, \%mres, $s, $cg, $i, $func );
							}
						} else {
							_mix_p_dogen2( $r_hg->{$cg}, $ky, $rv, \%mres, '', $cg, $i, $func );
						}

                    } else {
                		$lasthit{$i} = '';
                	}
                } else {
                	$lasthit{$i} = '';
                }
            }
        }
    }
} # End of apply_x_gen

sub _mix_p_get_reparmatch ($$) {
	my $text 	= shift;
	my $matcher = shift;

	$text =~ m/^$matcher$/;

	my %mres = ();
    # Save $1..$N for later reusal into %mres
    for my $ii ( 1..20 ) { #No more then $20, but loop will be left if undef found.
    	my $e = "\$mres{$ii} = \$$ii if defined( \$$ii );"; # Keep $1 ...
    	unless ( eval $e ) {
			if ( $@ ) {
				$logger->error( '__E_REPARMATCH', "\tBAD_EVAL $mres{\$$ii}: $@" );
				last;
			}
		}
		unless ( defined( $mres{$ii} ) ) {
			last; # If $N was undefined, we are at the end ...
		}
	}
	return( %mres );
} # End of _mix_p_get_reparmatch

#
# Apply the generator now, second variant
# TODO match with other variant
#
# Input:
#		r_gen -> key to macro definition
#		ky	  -> conndb or hierdb (depends on namespace)
#		rv		-> run parameter for this generator ($i)
#		mres	-> reference to hash with evaluated run parameters
#		splice -> if set, iterates over signal splices, sets '$s'
#		$cg	   -> name of current macro
#		$i	   -> current element (instance or signal name)
#		$func  -> add_inst or add_conn
#
# Output:
#		-
#
# Global:
#		$eh->get( 'sum' )
#		changes %conndb or %hierdb
#
sub _mix_p_dogen2 ($$$$$$$$) {
	my $r_cg	= shift;
	my $ky		= shift;
	my $rv		= shift;
	my $mres	= shift;
	my $splice	= shift;
	my $cg		= shift;
	my $i		= shift;
	my $func	= shift;

	my %in = (); # Hold input fields ....

	# if ( $splice ) {
	# 	$mres->{'s'} = $splice;
	# }

	for my $iii ( keys( %{$r_cg->{'field'}} ) ) {
		# my $f = mix_p_genexp( $r_hg->{$cg}{'field'}{$iii}, $ky->{$i} );
		my $f = $r_cg->{'field'}{$iii};
		if ( $iii =~ m/::gen/ ) { # Treat ::gen specially
				$f =~ s/\\/\\\\/g; #  Mask \
				$f =~ s/\$$rv/\\\$$rv/g; # Replace $V by \$V ....
				$f = "G # $rv = $mres->{$rv} #" .
					( ( $splice ne '' ) ? " splice = " . $splice . " #" : '' )
					. $f;
		} else {
				#!wig20030516: first convert {} to (), then replace variables
				$f =~s/{/" . (/g;
				$f =~s/}/) . "/g;       #TODO: make sure {} do match!!

				$f =~ s/\$(\d+)/$mres->{$1}/g; # replace $N by $mres{'N'}
				$f =~ s/\$$rv/$mres->{$rv}/g;    # Replace the run variable by it's value
				$f =~ s/\$s/$splice/g if ( $splice ne '' );
		}
		my $e = '$in{\'' . $iii . '\'} = "' . $f .'"';
		unless ( eval $e ) {
			if ( $@ ) {
				$in{$iii} = "E_BAD_EVAL";
				$logger->error( '__E_DOGEN2', "\tEval of $e failed while processing $cg" );
			}
		}
	}
	&$func( %in );
} # End of _mix_p_dogen2


#
# Apply the generator now:
#
# Input:
#		r_gen -> key to macro definition
#		ky	  -> conndb or hierdb (depends on namespace)
#		splice -> if set, iterates over signal splices, sets '$s'
#		$cg	   -> name of current macro
#		$i	   -> current element (instance or signal name)
#		$func  -> add_inst or add_conn
#
# Output:
#		-
#
# Global:
#		$eh->get( 'sum' )
#		changes %conndb or %hierdb
#
sub _mix_p_dogen ($$$$$$) {
	my $r_gen	= shift;
	my $ky		= shift;
	my $splice	= shift;
	my $cg		= shift;
	my $i		= shift;
	my $func	= shift;

	my %in = ();

	for my $ii ( keys %{$r_gen->{'field'}} ) {
		#!wig20031007: emtpy is not equal 0!!
		if ( defined( $r_gen->{'field'}{$ii} ) and
			$r_gen->{'field'}{$ii} ne "" ) {
			# my $f = mix_p_genexp( $r_hg->{$cg}{'field'}{$ii}, $ky->{$i} );

			my $f = $r_gen->{'field'}{$ii};
			my $e = "\$in{'$ii'} = \"" . $f . "\"";
			if ( $splice ne '' ) { # If $splice is set -> set $s in eval!
				$e = '$s = ' . $splice . ';' . $e;
			}
			if ( $ii eq "::gen" ) { # Mask \
				$e =~ s/\\/\\\\/g;
			}
			unless( eval $e ) {
				if ( $@ ) {
					$in{$ii} = "__E_BAD_EVAL";
					$logger->error( '__E_DOGEN', "\tBAD_EVAL match for $i, match $cg: $@");
				}
			}
		} else {
		#!wig20060125: do not do this if $ii is ::in or ::out!
		# ::in and ::out will be merged by create conn anyway!
			unless( $ii =~ m/^::(in|out)$/ ) {
				if ( ref( $ky->{$i}{$ii} ) ) {
					$logger->error( '__E_DOGEN', "\tBad usage of macro $cg for key $i, object $ii!");
				}
				$in{$ii} = $ky->{$i}{$ii}; # Apply defaults from input line ...
			}
		}
	}

	if ( exists( $in{'::gen'} ) ) {
		$in{'::gen'} = "G1 #" . $in{'::gen'};
	}
	# We add another instance or connection,
	# based on the ::gen field matching
	&$func( %in );

} # End of _mix_p_dogen

#
# Get wdith for signals to iterate over (in case CONN:SPLICE is set)
# Input:
#	$signal	name from $ky namespace
#	$r_cg   reference to macro
#	$ky		ref to %conndb or %hierdb
#
# Output:
#	array with singlle bit splice numbers or empty array
#
sub _mix_p_getsplicerange ($$$) {
	my $name = shift;
	my $r_cg = shift;
	my $ky	 = shift; # Current search namespace

	my @splice_range = ();

	if ( $r_cg->{'ns'} =~ m/:splice/ ) {
    	# If ::high and ::low are defined -> range goes from ::low to ::high
        my $high = _mix_p_get_digits( '::high', $ky->{$name} );
        my $low  = _mix_p_get_digits( '::low', $ky->{$name} );

        # Otherwise take macro defined range
        if ( $high eq '' ) {
        	$high = _mix_p_get_digits( '::high', $r_cg->{'fields'} );
        }
        if ( $low eq '' ) {
        	$low = _mix_p_get_digits( '::low', $r_cg->{'fields'} );
        }

        # Take the current lines bounds:
        # my $expandit = $r_cg->{'fields'}{'::name'};
        # expand $x in $name
        # TODO ???

        if ( $high ne '' and $low ne '' ) {
        	if ( $high >= $low ) {
        		@splice_range = $low..$high;
        	} else {
        		@splice_range = $high..$low;
        	}
        }
    }
	return @splice_range;
} # End of _mix_p_getsplicerange

#
# Check if variable exists and get digits
# Otherwise return emtpy string!
#
sub _mix_p_get_digits {
	my $name = shift;
	my $ref  = shift;

	my $d = '';
	if ( exists( $ref->{$name} ) and $ref->{$name} =~ m/^(\d+)/ ) {
		$d = $1;
	}
	return $d;
}
#
# Expand available fields to real values
#
sub mix_p_genexp ($$) {
    my $field = shift;
    my $keys = shift;

    while ( $field =~ m,%(::\w+?)%,g ) {
        if ( defined( $keys->{$1} ) and not ref( $keys->{$1} ) ) {
            my $k = $1;
            # Found s.th, try to replace it now ...
            $field =~ s,%$k%,$keys->{$k},;
        }
    }

    return $field;
}

####################################################################
## mix_p_prep_match
##
## Do the match for generators
## if the match operator contains ::name=/RE/, use the value of ::name to
## match against.
## ::name defaults to $eh->get( $type . '.key' ) ...
##
## Returns: $content, $re
##
####################################################################

sub mix_p_prep_match ($$$$) {
    my $key = shift;
    my $type = shift || 'hier';
    my $r_d = shift;
    my $re = shift;

	$type =~ s/:.*//; # Strip off modifieres
    my $defcol = $eh->get( $type . '.key' ) || '::inst';
    my $pre = undef;

    my $content = "";

    # Leading text? Save it, start building $contents and strip off
    if ( $re =~ s,^(.*?)(?=::\w+),, ) {
        if ( $1 ) {
            $content = $r_d->{$defcol};
            $pre = $1;
        }
    } else {
        # No ::COL= inside ... return default and full regular expression
        $content = $r_d->{$defcol};
        $pre = $re;
        return( $content, $pre );
    }

    # Parse ::col=RE:: ....
    while ( $re =~ s,^(::\w+?)=(.*?)(::|$),, ) { #
        if ( defined( $r_d->{$1} ) and not ref( $r_d->{$1} ) ) {
            $content .= "#" . $r_d->{$1}; # Apply a # as field seperator ...
            $pre .= "#" . $2; # Save regular expression ....
        } else {
            # Found something, but that is not defined here -> will never match
            $content = undef;
            $pre = "__E_NONMATCHINGRE__";
            return ( $content, $pre );
        }
    }

    # Some trailing stuff left? Add default column contents ....
    if ( $re =~ m,(.+)$, ) {
        $content .= "#" . $r_d->{$defcol};
        $pre .= "#" . $1;
    }

    return( $content, $pre );
}

####################################################################
## get_top_cell
## Return list of top cell(s).
## If not specified otherwise, these are the daughter(s) of the testbench cell
####################################################################

=head2

#
# Return list of top cell(s)
#
# TODO : Rewrite that:
#    Search for TOP node of created tree, no need to know if it's testbench ...

=cut

sub get_top_cell () {
    my @tops = ();
	my @etops = ();
    my $topname = $eh->get( 'top' ); # By default $topname is %TOP%

    if ( exists( $hierdb{$topname} ) ) {
    	if ( $topname eq '%TOP%' ) {
    	# Default is %TOP% -> take daughter or daughter(s) of TESTBENCH
    		@tops = ( $hierdb{$topname}{'::treeobj'}->daughters() );
    		if ( scalar( @tops ) == 0 ) { # %TOP% has no daughters ->
    			# Try TESTBENCH
    			if ( exists( $hierdb{'TESTBENCH'} ) ) {
    				$logger->info( '__I_GET_TOP', "\tFall back to TESTBENCH for %TOP%" );
    				$eh->set( 'top', 'TESTBENCH' );
    				$topname = 'TESTBENCH';
    				@tops = ( $hierdb{'TESTBENCH'}{'::treeobj'}->daughters() );
    			}
    		}
    		# If the @tops is "TESTBENCH" and that was automatically generated
    		#	-> go one level down
    		for my $t ( @tops ) {
    			if ( $t->name() =~ m,^%?TESTBENCH,i ) {
    				if ( $hierdb{$t->name()}{'::entity'} eq 'W_NO_ENTITY' ) {
    					push( @etops, $t->daughters() );
    					if ( scalar( @tops ) != 1 ) { # Unusual setup
    						$logger->error( '__E_GET_TOP',
    							"\tHierachy top " . $t->name() . " has sisters. Check hierachy!" );
    					}
    				} else {
    					push( @etops, $t );
    				}
    			} else {
    				push ( @etops, $t );
    			}
    		}
    	} else {
    	# Take user defined TOP
    		if ( exists( $hierdb{$topname} ) and
    			 exists( $hierdb{$topname}{'::treeobj'} ) ) {
    			push( @etops, $hierdb{$topname}{'::treeobj'} );
    		} else {
    			$logger->error( '__E_GET_TOP', "\tCould not find hierachy object for $topname" );
    		}
    	}
    }

    if ( scalar( @etops ) < 1 ) { # Did not find testbench ...
        $logger->error( '__E_GET_TOP', "\tCould not identify toplevel aka. " .
        	$topname );
    }

    return @etops;
} # End of get_top_cell

####################################################################
## add_portsig
##
####################################################################

=head2

add_portsig ()

Add signals to ports of intermediate hierachy elements if required.
To do that we need to parse the instance hierachy for each signal.
Looks like lot of work, hopefully the Tree::DAG_Node is fast in finding
the common subtree.
#
# Add conections and ports if needed (hierachy traversal)
# Add connections to TOPLEVEL for connections without ::in or ::out
# Replace OPEN and %OPEN%
#

Algorithm: Start with all leaf instances:
    Collect list of signals attaches to leaf cell and all sisters of that leaf cell.
    If this signal is attached to a node nearer the tree, generate a port
    and add a connection. Now crawl up the tree.

Alternative implementation:
    Iterate through all signals and find topmost instance connected. Add ports
    if signal does not appear at an intermediate instance.

Will remember the top cell for each signal in $conndb{$signal}{'::topinst'}

Side effects:
	Store connectivity information in hierdb{X}{::sigbits}

=cut

sub add_portsig () {
    for my $signal ( keys( %conndb ) ) {
        my %connected = (); # List of connected instance nodes
        my %modes = ();
        my @addup = ();

        if ( $signal eq '' ) { #Fatal error!
            $logger->fatal( '__F_ADD_PORTSIG', "\tDetecting signal without name in add_portsig! Check CONN sheet!");
            die;
        }

        #
        # Skip if signal mode equals Constant or Generic
        # Constant and Generics will not extend port map!
        #
        my $mode = $conndb{$signal}{'::mode'};

        # add %LOW%, %HIGH%, ... to ::sigbits ..., will be reused by MixReport later on
		#!wig 20060406: get info for ::sigbits ....
        if ( $signal =~ m/^\s*%(HIGH|LOW|OPEN)/o ) {
			_mix_p_getconnected( $signal, '::in', $mode, \%modes, \%connected );
			_mix_p_getconnected( $signal, '::out', $mode, \%modes, \%connected );
			# Iterate over all modules connected here
			for my $i ( keys ( %connected ) ) {
				if ( exists( $hierdb{$i} ) ) {
					my $name = $hierdb{$i}{'::inst'};
					# Let "bits_at_inst" do the work
            		my $tbits = bits_at_inst_hl( $signal, $name, $modes{$name} );
				} else {
					$logger->error( '__E_PORTSIG', "\tCannot find module $i in hierdb!" );
				}
			}
 			next;
		}
		#!wig 20060406: get info for ::sigbits .... / END
        if ( $mode and ( $mode =~ m,^\s*[CGP],o ) ) { #wig20040802: should C be removed?
            next;
        }

        _mix_p_getconnected( $signal, "::in", $mode, \%modes, \%connected );
        _mix_p_getconnected( $signal, "::out", $mode, \%modes, \%connected );

        #
        # If signal mode is I |O | IO (not S), make sure it's connected to the
        # top level
        # Add IO-port if not connected already ....
        #
        my $meh = $eh->get( 'output.generate._re_xinout');
        if ( $eh->get( 'output.generate.inout' ) =~ m,mode,io and
            	( $mode =~ m,[IO],io or $mode =~ m,IO,i ) and
            	$signal !~ m/$meh/
            ) {
            #wig20030625: adding IO switch ...
            # TODO : what about buffers and tristate? So far noone requested this ...
            # TODO : make "inout" more flexible, e.g. replace by io,o,i, ...
                my @tops = get_top_cell();
                my @addtop = ();
                my @addtopn = ();
                my $atp_flag = 0;
                my $dir = ( $mode =~ m,io,io ) ? 'inout' :
                    ( ( $mode =~ m,i,io, ) ? 'in' :
                    ( ( $mode =~ m,o,io, ) ? 'out' :
                    ( ( $mode =~ m,b,io, ) ? 'buffer' : 'error' )));
                for my $t ( @tops ) {
                    # Is this signal already connected here?
                    if ( exists( $connected{$t->name} ) ) {
                        my $bits = bits_at_inst($signal, $t->name, $modes{$t->name} );
                        if ( join( "__", @$bits ) !~ m,A:::$dir, ) { # $bits = ARRAY( 'A:::o' ...
                            $atp_flag = 1;
                        }
                    } else {
                        # Is that signal connected to one of our daughters?
                        $atp_flag = 1;
                    }
                    if ( $atp_flag ) {
                        my $flag = 0;
                        my $one_leaf = "";
                        CONN: for my $tw ( values( %connected ) ) {
                            for my $ancestor ( $tw->ancestors ) {
                            #TODO: Strip off up-level nodes
                                if ( $ancestor == $t ) {
                                    $one_leaf = $tw->name;
                                    $flag = 1;
                                    last CONN;
                                }
                            }
                        }
                        if ( $flag ) { # Need to create I/O port here
                            # Always make a full connection!
                            # Force mode to ::mode -> :out:0 or :inout:0 or :in:0 or :buffer:0
                            #!wig push( @addtopn, [ $signal, $t->name, $one_leaf, $modes{$one_leaf}, 'A::' ] );
                            push( @addtopn, [ $signal, $t->name, $one_leaf, ':' . $dir . ':0' , 'A::' ] );
                            # set hierdb{inst}{'::sigbits'} ...
                            my $bits = bits_at_inst( $signal, $one_leaf, $modes{$one_leaf} );
                            push( @addtop, $t->name );
                        }
                    }
                }
                # Add TOP level port if not already connected ...
                # Theoretically there could be several top nodes ...
                if ( scalar( @addtopn ) > 0 ) {
                    add_top_port( \@addtopn, \%connected );
                    # Will extend %connected as modes happen
                    %modes = (); # Redo modes data
                    _mix_p_getconnected( $signal, "::in", $mode, \%modes );
                    _mix_p_getconnected( $signal, "::out", $mode, \%modes );
                }
        }

        # Top cell is the common parent of all connected components ...
        my $commonpar = my_common( values( %connected ) );

        unless ( defined( $commonpar ) ) {
            $logger->error( '__E_ADD_PORTSIG', "\tSignal $signal spawns several seperate trees! Will be dropped!" );
            next;
        }

        # Keep name of top instance for later reuse ....
        $conndb{$signal}{'::topinst'} = $commonpar->{'name'};

        #
        # now we know the tree top for that signal. The top may not have the
        # signal in his port list ..
        #
        # Get all chains from the commonpar node to each of the list and
        # see if they are in the list ... if not: add port!
        #
        for my $leaves ( keys( %connected ) ) {
            # @addup = ();
            my $l = $leaves;
            my $bits = bits_at_inst( $signal, $l, $modes{$l} ); # Tells me how to connect
            next if ( $connected{$leaves} eq $commonpar ); # $leaves is the commonpar!
            my $n = $connected{$leaves}->mother;
            while( $n ne $commonpar ) { # Climb up tree
                my $name = $n->name;
                unless( exists( $connected{$name} ) ) {
                    ## ADD port to that module:
                    $logger->debug( '__D_ADD_PORTSIG', "\tAdding port to hierachy module $name for signal $signal!" );
                    push( @addup, [ $signal, $name, $l, $modes{$l}, $bits ] );
                } else {
                    # Connected, but not all bits? Or in/out mode differs?
                    my $tbits = bits_at_inst( $signal, $name, $modes{$name} );
                    for my $t ( @$tbits ) {
                        for my $lb ( @$bits ) {
                            if ( substr( $t, -1, 1 ) eq substr( $lb, -1, 1 ) ) { #Same i/o
                            	my $m = substr( $t, -1, 1 );
                                if ( $m eq 'i' and $lb !~ m,A::, and $t ne $lb ) {
                                	# $t -> what parent has
                                	# $lb -> what current has
                                	#!wig20060413: check if $lb is somwhow contained in $t
                                	#  e.g. if $t is A:::x and $lb has some bits
                                	#	added brackets around [$t] and [$lb]
                                    push( @addup, [ $signal, $name, $l, $modes{$l}, [ $t ], [ $lb ] ] );
                                } elsif ( $m eq 'o' and $t !~ m,A::, and $t ne $lb ) {
                                	#!wig20060418: added
                                	# $t -> what parent has
                                	# $lb -> what current has
                                	#!wig20060413: check if $lb is somwhow contained in $t
                                	#  e.g. if $t is A:::x and $lb has some bits
                                	#	added brackets around [$t] and [$lb]
                                    push( @addup, [ $signal, $name, $l, $modes{$l}, [ $t ], [ $lb ] ] );
                                }
                            } else {
                            	$logger->error( '__E_ADD_PORTSIG_BRANCH', "\tBad branch in add_portsig for signal $signal" );
                            }
                        }
                    }
                }
                $n = $n->mother;
                unless( defined( $n ) ) {
                    $logger->error( '__E_ADD_PORTSIG', "\tClimbing up tree failed for signal $signal!" );
                    last;
                }
            }
        }
        # Add ports to instances as required ...
        if ( scalar( @addup ) ) { add_port( \@addup, \%connected ) };
    }

    return;
}

#
# scan through conndb for a given signal and give back the
# connected instances and the modes for them ...
#
# Input:
#       $signal   signalname
#       $dir      ::in or ::out (corresponding the CONN sheet columns
#       $mode   mode of signal (I, O, IO, B, T, ...)
#
#   \%modes         ref to instance indexed mode list
#   \%connected     ref to instance indexed list of connected instances
#
sub _mix_p_getconnected ($$$$;$) {
    my $signal = shift;
    my $dir = shift;  # ::in or ::out ....
    my $mode = shift || 'S'; # signal mode defaults to S #wig20030729:bug
    my $r_mod = shift;
    my $r_con = shift || undef;

    my $n = 0;
    if ( exists( $conndb{$signal}{$dir} ) ) {
        for my $i ( 0..$#{$conndb{$signal}{$dir}} ) {
            my $inst = $conndb{$signal}{$dir}[$i]{'inst'};
            my $md = ( $mode !~ m,^[IOS]$,io ) ? ( "/" . $mode ) : ""; #!wig20030729: bug
            #Active IO: $md = ""; #TODO: MakeActive
            next unless ( defined( $inst ) );
                if ( exists ( $hierdb{$inst} )) {
                    if ( $r_con ) { $r_con->{$inst} = $hierdb{$inst}{'::treeobj'}; } # Tree::DAG_Node objects
                    $r_mod->{$inst} .= $dir . $md . ":" . $i;
                }
                $n++;
        }
        return( $n );
    } else {
        $logger->error( '__E_GETCONNECTED', "\tBad branch in _mix_p_getconnected! File bug report!");
    }
    return -1; # Indicate error condition ...
} # end of _mix_p_get_connected

#
# Which bits are connected to that signal
#
# Returns: array for in or out or buffer ... with description of connectivity:
#   Bitvector:
#   A:::d
#   B:::000ddd0dddd00
#   F::TEXT:T::TEXT
#   E:: Error
# d :=   i(n) | o(ut) | b(uffer) | c(inout) | m(isc) | e(rror)
# Currently i,o and e are used.
#
#TODO: what if in/out mode conflicts? Do not want to think about that ...
# Need to extend conndb{}{::sigbits} then.
#
#!wig20061114: If signal width == digits and all connections are with `define
#   then do a full connect!!
sub bits_at_inst ($$$) {
    my $signal = shift;
    my $inst = shift;
    my $modes = shift;

    # my $name = $node->name;
    my $h = $conndb{$signal}{'::high'} || 0;
    my $l = $conndb{$signal}{'::low'} || 0;

    my $d = '';
    my %width = (); # F[ull], B[it],
    my %bits = ();
    my %sigw_flag = ();
    # Scan through modes: ::DIR[/MODE]:N
    while ( $modes =~ m#::(in|out)(/(\w+))?:(\d+)#g ) {
        my $io = $1;
        my $sigm = $3;
        my $n = $4;

        my $cell = $conndb{$signal}{'::' . $io}[$n];
        my $sig_f = $cell->{'sig_f'} || 0; # Changed wig20030605
        my $sig_t = $cell->{'sig_t'} || 0; # Changed wig20030605

        $sigm = '' if ( lc( $sigm ) eq 's' );
        if ( $sigm ) {
            if ( $sigm =~ m,^io,io ) {
                $d = 'c';
            } elsif ( $sigm =~ m,^([btio]),io ) {
                $d = lc( $1 );
            } else {
                $d = 'e'; # TODO 20030723 ..
            }
        } else {
            # Derive -> i/o from in/out
            $d = lc( substr( $io, 0, 1 ) ); #TODO: extend for buffer and inout pins
        }
        unless( defined( $sigw_flag{$d} ) ) { $sigw_flag{$d} = 1; } # First time

        if ( $h eq $sig_f and $l eq $sig_t ) { # Full match
            push( @{$width{$d}}, "A::" );
        } else {
            push( @{$width{$d}}, "F::$sig_f:T::$sig_t" );
            #OLD: if ( "$sig_f --- $sig_t" =~ m,(\d+) --- (\d+),o ) {}
			# Port has integer bounds
			if ( is_integer2( $sig_f, $sig_t ) ) {
                if ( $sig_f >= $sig_t ) {
                    for my $b ( $sig_t..$sig_f ) { $bits{$d}[$b] = $d; };
                } else {
                    for my $b ( $sig_f..$sig_t ) { $bits{$d}[$b] = $d; };
                }
            } elsif ( 0 ) { # Handle cases with unknown/unresolvable signal width
				;
			} else {
                $logger->warn( '__W_BITS_AT_INST', "\tSignal $signal width unknown at instance $inst: " . $width{$d}[-1] );
                $sigw_flag{$d} = 0;
            }
        }
    }

    if ( scalar( keys( %width ) ) > 1 ) {
        $logger->warn( '__W_BITS_AT_INST', "\tSignal $signal has mixed links into instance $inst!" );
    }

    # Combine the output:
    my @ret = (); # Preset to Error
    for my $i ( keys( %width ) ) {
        #
        # TODO : Iterate through $width!!!!
        if ( scalar( @{$width{$i}} ) == 1 and $width{$i}[0] eq "A::" ) {
            # only one link, that's easy and clear
            push( @ret , $width{$i}[0] . ":$i" );
        } else {
        	#!wig20051102: also consider other entries (could be A::)!
			my $isa_flag = 0;
        	for my $ii ( 0..(scalar( @{$width{$i}} ) - 1) ) {
            	my $max = $width{$i}[$ii];
            	if ( $max =~ m,A::, ) {
                	push( @ret, $max . ":$i" );
                	# One link was ALL, we can ignore all other cases
                	$isa_flag = 1;
                	last;
            	}
            }
            # Not fully connected?
            unless( $isa_flag ) {
           		if ( not $sigw_flag{$i} ) {
                	# TODO : !wig20061114a: keep direction push( @ret, "A:::e$i" ); # Error + in/out indication ...
                	push( @ret, "A:::e" ); # Error + in/out indication ...
                	# If we do not know, we take full signal
            	} elsif ( is_integer2( $h, $l ) ) {
                	my $miss = 0;
                	my $bits = '';
                	for my $b ( $l..$h ) {
                   		unless( $bits{$i}[$b] ) { $miss = 1; }
                   		$bits = ( ( $bits{$i}[$b] ) ? $bits{$i}[$b] : '0' ) . $bits;
                	}
                	unless ( $miss ) { push( @ret, "A:::$i" ); }
                	else { push ( @ret, "B::$bits" . ":$i" )};
            	} else {
                	push( @ret, "A:::$i" );
            	}
            }
        }
    }
    # Save to %hierdb for later reusal
    #Attention: add additonal data for different ports!!
    #TODO: delete sigbits entry first?
    push( @{$hierdb{$inst}{'::sigbits'}{$signal}}, @ret );
    return \@ret;
} # End of bits_at_inst

# Variant of the above for %LOW|HIGH|OPEN(_BUS)% ...
# only purpose: extend ::sigbits ...
#  no overlay (?)
# 20060406: function needs more testing!!
#
#!wig20060406
sub bits_at_inst_hl ($$$) {
    my $signal = shift;
    my $inst = shift;
    my $modes = shift;

    # my $name = $node->name;
	# You can savely ignore h an l here, %LOW_BUS% has autowidth
	# %OPEN% might be different (testcase please!)
    # my $h = $conndb{$signal}{'::high'} || 0;
    # my $l = $conndb{$signal}{'::low'} || 0;

    my $d = '';
    # my %width = (); # F[ull], B[it],
    my %bits = ();
    my %sigw_flag = ();
    # Scan through modes: ::DIR[/MODE]:N
	# TODO : protect against duplicate
    while ( $modes =~ m#::(in|out)(/(\w+))?:(\d+)#g ) {
        my $io = $1;
        my $sigm = $3;
        my $n = $4;

        my $cell = $conndb{$signal}{'::' . $io}[$n];
        my $sig_f = $cell->{'sig_f'} || 0; # Changed wig20030605
        my $sig_t = $cell->{'sig_t'} || 0; # Changed wig20030605

        $sigm = '' if ( lc( $sigm ) eq 's' );
        if ( $sigm ) {
            if ( $sigm =~ m,^io,io ) {
                $d = "c";
            } elsif ( $sigm =~ m,^([btio]),io ) {
                $d = lc( $1 );
            } else {
                $d = "e"; # TODO 20030723 ..
            }
        } else {
            # Derive -> i/o from in/out
            $d = lc( substr( $io, 0, 1 ) ); #TODO: extend for buffer and inout pins
        }
        unless( defined( $sigw_flag{$d} ) ) { $sigw_flag{$d} = 1; } # First time

		# push( @{$width{$d}}, 'A::' );

		# Add to ::sigbits
    	push( @{$hierdb{$inst}{'::sigbits'}{$signal}}, ( 'A:::' . $d ) );
    }

} # End of bits_at_inst_hl

#
# Take input like:
#   A::
#   B::0XXX00xx
#   F::CHAR:T::CHAR
#  Try to overlap this ...
#  mode already got stripped away ...
sub overlay_bits($$) {
    my $bv1 = shift;
    my $bv2 = shift;

    unless( $bv1 ) {
        $logger->warn('__W_OVERLAY_BITS', "\tFeed empty bitvector 1 to overlay_bits");
        return $bv2;
    }
    unless ( $bv2 ) {
        $logger->warn('__W_OVERLAY_BITS', "\tFeed empty bitvector 2 to overlay_bits");
        return $bv1;
    }

    if ( $bv1 eq 'A::' or $bv2 eq 'A::' ) {
        return 'A::';
    }

    if ( $bv1 eq $bv2 ) {
        return $bv1;
    }

    my $bits1 = "";
    if ( $bv1 =~ m,^B::(.+), ) {
        $bits1 = $1;
    }
    if ( $bits1 ne "" and $bv2 =~ m,^B::(.+), ) {
        my $bits2 = $1;
        if ( length( $bits1 ) != length( $bits2 ) ) {
            $logger->warn( '__W_OVERLAY_BITS', "\tBitvector length mismatch: $bits1 vs. $bits2" );
        }
        my $ub = length( $bits1 ) - 1;
        my $out = "";
        my $miss = 0;
        if ( length( $bits1 ) < length( $bits2 ) ) { $ub = length( $bits2 ) - 1; }

        for my $i ( 0..$ub ) {
            my $c1 = substr( $bits1, $i, 1 ) || "0";
            my $c2 = substr( $bits2, $i, 1 ) || "0";
            if ( $c1 and $c2 ) {
                if ( $c1 ne $c2 ) {
                        $logger->warn( '__W_OVERLAY_BITS', "\tMixing wrong mode: $bits1 vs. $bits2" );
                        substr( $out, $i, 1 ) = 'e';
                        $miss = 1;
                } else {
                        substr( $out, $i, 1 ) = $c1;
                }
            } elsif ( $c1 ) { substr( $out, $i, 1 ) = $c1;
            } elsif ( $c2 ) { substr( $out, $i, 1 ) = $c2;
            } else { substr( $out, $i, 1 ) = '0'; $miss = 1; }
        }
        if ( $miss ) {
            return( 'B::' . $out );
        } else {
            return( 'A::' );
        }
    }

    if ( $bv1 =~ m,F::.*T::, and $bv2 eq $bv1 ) {
        return $bv1;
    }

    $logger->error( '__E_OVERLAY_BITS', "\tCannot overlay bitvectors $bv1 vs. $bv2" );

    return( 'E::' );
} # End of overlay_bits

#
# add_port: add ports to intermediate instances
#
# Input: array of:
#  [0] = ( $signal, $name, $leave, $mode )
#   $signal := signal name
#   $name := instance name
#   $leave := leaf cell name (where does the signal come from)
#   $mode := "::in[/MODE]:NR::out:NR::in:NR2 ..."  index into instance port map
#
# $leave might be omitted ($mode is sufficient to address the instance/port/bus data
# Will be called for each signal
#
# add bit number to avoid collision in case of busses
#
#!wig20061114: extend A:::e[io]
sub add_port ($$) {
    my $r_adds = shift;
    my $r_connected = shift;
    my @adds = @$r_adds;

    # Get mode:
    # If adds has only in -> need in-port
    # If adds has only out -> need out-port (there has to be only one!)
    # If adds has in and out -> !!need out-port (print out warning!)!!
    #

    my $signal = $r_adds->[0][0];
    my %mc = ();
    my %d_mode = ();
    my %d_wid = ();
    my $mode = "__E_MODE_DEFAULT";
    for my $r ( keys( %$r_connected ) ) {

        # Retrieve modes and width from sigbits data structure
        for my $sb ( @{$hierdb{$r}{'::sigbits'}{$signal}} ) {
			#!wig20061114: TODO allow A::e[io] (for case where port width cannot be resolved.
			# TODO : Create a full signal connect if the current inst. has no connection!
            # TODO : if ( $sb =~ m,(.*):(e.)$, ) {
            # TODO :     $d_mode{$r}{$2} = $1; # eo = A:: ....
            # TODO : } elsif ( $sb =~ m,(.*):(.)$, ) {
			if ( $sb =~ m,(.*):(.)$, ) {
                $d_mode{$r}{$2} = $1; # o = A:: ....
            }
        }
        unless( defined ( $d_mode{$r} ) ) {
            $logger->error( '__E_ADD_PORT', "\tMissing sigbits/mode definition for signal $signal, instance $r in add_port");
        }
    }

    #
    # Sort by depth first (aka longest address first)
    #
    my %length = ();
    for my $r ( 0 .. scalar(@adds)-1 ) {
        my $l = length( $hierdb{$adds[$r][1]}{'::treeobj'}->address );
        push( @{$length{$l}}, $r );
        # $adds[$r][5] = length( $hierdb{$adds[$r][1]}{'::treeobj'}->address );
    }
    my @order = ();
    for my $l ( reverse( sort( { $a <=> $b } keys( %length ) ) ) ) {
    	#!wig20051222: numeric sort
        push( @order, @{$length{$l}} );
    }

    #
    # iterate through list
    #
    my %seen = ();
    for my $o ( @order ) {
        my $r = $adds[$o];
        # Do it only once.
        my $inst = $r->[1];
        if ( $seen{$inst} ) {
            next;
        } else {
            $seen{$inst} = 1;
        }

        # Are daughters connected? Or do they need to be connected?
        my @daughters = $hierdb{$inst}{'::treeobj'}->daughters;

        #
        # Collect mode and width for this signal provided by daughters!
        # That means daughters have to be evaluated first. Bottom up.
        #
        my %dm = ();
        my %dw = ();
        for my $d ( @daughters ) {
            my $name = $d->name;
            next unless( exists( $r_connected->{$name} ) ); # This daughter has no link.
            unless( exists( $d_mode{$name} ) ) {
                $logger->error( '__E_ADD_PORT', "\tSignal mode not defined internally ($name). File bug report!" );
            }
            for my $dd ( keys( %{$d_mode{$name}} ) ) {
                if ( $dd =~ m,(i|o|e|b|m|c), ) {
                    $dm{$dd}++;
                } else {
                    $dm{'e'}++;
                }
                if( not defined( $dw{$dd} ) ) {
                    $dw{$dd} = $d_mode{$name}{$dd};
                } elsif ( $dw{$dd} ne 'A::' ) {
                    if ( $d_mode{$name}{$dd} ne 'A::' ) {
                        $dw{$dd} = overlay_bits( $d_mode{$name}{$dd}, $dw{$dd} );
                    } else {
                       $dw{$dd} = 'A::';
                    }
                }
            }
        }

        #
        # What do all the others require (parents and other branches)?
        # mode and width
        #
        my @desc = $hierdb{$inst}{'::treeobj'}->descendants;
        my @anc = $hierdb{$inst}{'::treeobj'}->ancestors;
        my %non_desc = ();

        map( { $non_desc{$_} = 1; } keys( %$r_connected ) ); #All instances connected
        for my $d ( @desc ) {
            # Delete all our descendants from the list
            delete( $non_desc{$d->name} );
        }
        for my $d ( @anc ) {
            if ( exists( $non_desc{$d->name} ) ) {
                $non_desc{$d->name} = 2; #Mark our ancestors!
            }
        }
        delete( $non_desc{$inst} ); # Just in case

        my %ndm = ();
        my %ndw = ();
        # my %nhdm = ();
        # my %nhdw = ();
        for my $d ( keys( %non_desc ) ) {
            # Is this one of our ancestors? If yes, we reverse the direction settings
            #  i -> o, o -> i
            #TODO: Check the up-inverse routine!!
            my $up_flag = 0;
            if ( $non_desc{$d} == 2 ) {
                $up_flag = 1;
            }
            if( not exists( $d_mode{$d} ) ) {
                $logger->error( '__E_ADD_PORT', "\tSignal mode not defined internally ($d). File bug report!" );
            } else {
                for my $dd ( keys( %{$d_mode{$d}} ) ) {
                    my $ddr = $dd;
                    if ( $up_flag ) {
                        if ( $dd eq 'o' ) {$ddr = 'i'; }
                        elsif( $dd eq 'i' ) {$ddr = 'o'; }
                    }
                    if ( $ddr =~ m,(i|o|e|b|m|c), ) {
                        $ndm{$1}++;
                    } else {
                        $ndm{'e'}++;
                    }
                    if( not defined( $ndw{$ddr} ) ) {
                        $ndw{$ddr} = $d_mode{$d}{$dd};
                    } elsif ( $ndw{$ddr} ne 'A::' ) {
                        if ( $d_mode{$d}{$dd} ne 'A::' ) {
                            $ndw{$ddr} = overlay_bits( $d_mode{$d}{$dd}, $ndw{$ddr} );
                        } else {
                            $ndw{$ddr} = 'A::';
                        }
                    }
                }
            }
        }

        # We have already some link?
        # Do this for each mode found so far ....
        my $this_mode = "";
        my $this_width = "";
        my @new_sb = ();
        if ( $r_connected->{$inst} ) {
            for my $tm ( keys %{$d_mode{$inst}} ) {
                # Repeat for all modes ....i,o,....
                $this_mode = $d_mode{$inst}{$tm}; # Reference!
                # $this_width = $d_mode{$inst}{$tm};
                my $thm = $tm;
                #TODO: $this_mode here is actually this_width!!
                ( $this_width, $thm ) = _add_port( $r, $this_mode, $tm, \%dw, \%dm, \%ndw, \%ndm, 0 );

                # $d_mode{$inst}{$thm} = $this_width;
                join_vec( \%d_mode, $inst, $this_width );
                # $d_wid{$inst} = $this_width;
                $r_connected->{$inst} = $hierdb{$inst}{'::treeobj'}; #TODO
            }
        } else {
            # This module has no mode (not connected up to now).
            ( $this_width , $this_mode ) = _add_port( $r, $this_width, $this_mode, \%dw, \%dm, \%ndw, \%ndm, 0 );

            # $d_mode{$inst}{$this_mode} = $this_width;
            #old: $d_wid{$inst} = $this_width;
            join_vec( \%d_mode, $inst, $this_width );
            # $d_mode{$inst} = $this_width;
            $r_connected->{$inst} = $hierdb{$inst}{'::treeobj'}; #TODO
        }

        # Extend this instance/entitiy ....
        my @nb = ();
        for my $m ( keys( %{$d_mode{$inst}} ) ) {
            push( @nb , $d_mode{$inst}{$m} . ":" . $m );
        }
        # Replace the signal/port/hierachy data structure
        @{$hierdb{$inst}{'::sigbits'}{$signal}} = @nb;
    }
} # End of add_port

#
# add_top_port: add IO ports if defined by ::mode to top cells
# This has to be done in advance to give the add_port function a chance
# to add intermediate ports automatically.
#
# Input: array of:
#  [0] = ( $signal, $name, $leave, $mode )
#   $signal := signal name
#   $name := instance name
#   $leave := leaf cell name (where does the signal come from)
#   $mode := ":in:NR:out:NR:in:NR2 ..."  index into instance port map
#       $mode should be :in:N or :inout:N or :out:N or :buffer:N
#
# $leave might be omitted ($mode is sufficient to address the instance/port/bus data)
# Will be called for each signal
#
#
sub add_top_port ($$) {
    my $r_adds = shift;
    my $r_connected = shift;
    my @adds = @$r_adds;

    # Get mode:
    # If adds has only in -> need in-port
    # If adds has only out -> need out-port (there has to be only one!)
    # If adds has in and out -> !!need out-port (print out warning!)!!
    #

    my $signal = $r_adds->[0][0];
    my %mc = ();
    my %d_mode = ();
    my %d_wid = ();
    my $mode = "__E_MODE_DEFAULT";

    for my $r ( keys( %$r_connected ) ) {
       # my $m = $r->[3]; #Mode
        next unless( exists $hierdb{$r}{'::sigbits'}{$signal} );
        # Retrieve modes and width from sigbits data structure
        for my $sb ( @{$hierdb{$r}{'::sigbits'}{$signal}} ) {
               if ( $sb =~ m,(.*):(.)$, ) {
                   $d_mode{$r}{$2} = $1; # o = A:: ....
                }
        }
        unless( defined ( $d_mode{$r} ) ) {
           $logger->error( '__E_ADD_TOP_PORT', "\tMissing sigbits/mode definition for instance $r in add_top_port");
        }
    }
    for my $r ( @adds ) {
        my $m = $r->[3]; # Target mode, forced!!
        $m =~ s,.*:(in|out|inout|buffer):.*,$1,;
        my $mi = ( $m eq "in" ) ? "i" :
            ( ($m eq "out" ) ? "o" :
                ( ( $m eq "inout" ) ? "c" :
                    ( ( $m eq "buffer" ) ? "b" : "e" )
                )
            );
        # TODO : Remove reverse logic for ndw in _add_port!!!
        my $mr = ( $mi eq "i" ) ? "o" :
            ( ( $mi eq "o" ) ? "i" : $mi);

        my %dw = ();
        my %ndw = ();
        my %dm = ();
        my %ndm = ();

        $dw{$mi} = "A::";
        $ndw{$mr} = "A::";
        $dm{$mi} = 1;
        $ndm{$mr} = 1;

        my $this_mode = "";
        my $this_width = "";
        ( $this_width , $this_mode ) = _add_port( $r, $this_width, $this_mode, \%dw, \%dm, \%ndw, \%ndm, "top" );

        join_vec( \%d_mode, $r->[1], $this_width );

        $r_connected->{$r->[1]} = $hierdb{$r->[1]}{'::treeobj'}; #TODO

        my @nb = ();
        for my $m ( keys( %{$d_mode{$r->[1]}} ) ) {
            push( @nb , $d_mode{$r->[1]}{$m} . ":" . $m );
        }
        # Replace the signal/port/hierachy data structure
        @{$hierdb{$r->[1]}{'::sigbits'}{$signal}} = @nb;
    }

} # End of add_top_port

#
# Take added port description and join
#
sub join_vec($$$) {
    my $r = shift;
    my $inst = shift;
    my $nv = shift;

    my %keys = ();
    my $ov;
    map( { $keys{$_} = 1; } keys( %$nv ) );
    if ( exists( $r->{$inst} ) ) {
        $ov = $r->{$inst};
        map( { $keys{$_} = 1; } keys( %$ov ) );
    } else {
        $ov = {};
    }
    for my $k ( keys( %keys ) ) {
        if ( exists( $nv->{$k} ) and exists( $ov->{$k} ) ) {
            $r->{$inst}{$k} = overlay_bits( $ov->{$k}, $nv->{$k} );
        } elsif( exists( $nv->{$k} ) )  {
            $r->{$inst}{$k} = $nv->{$k};
        } else {
            $r->{$inst}{$k} = $ov->{$k};
        }
    }
}


sub _add_port ($$$$$$$$) {
    my $r = shift; # Array ref, has signal name, instance, daughter, mode, ...
    my $tw = shift; # width of already connected pins ...
    my $tm = shift; # mode of current port
    my $dw = shift; # width of port requested by daughters
    my $dm = shift; # reference to mode(s) requested by daughters
    my $uw = shift; # width required by upper hierachy
    my $um = shift; # mode reference required by upper hierachy
    my $top_flag = shift; # Set to generate special port names for top level cells

    # Generate port:
    # Consider bits needed, mode needed and some VHDL specialities:
    my $signal = $r->[0];
    my $inst = $r->[1];

    my $uk = join( '', sort ( keys ( %$um ) ) ); # bceimo
    if ( $uk =~ m,e, ) { # Error
		$logger->error( '__E_ADD_PORT_', "\tBad mode detected for signal $signal generating port at instance $inst" );
    }
    my $do = 'e';
    my $dir = "::err";

    # Try to define a base direction to head for ...
    my $simple = 0;
    if ( length( $uk ) > 1 and $uk ne "io" ) { #
        $logger->error( '__E_ADD_PORT_', "\tMixed mode $uk connection for instance $inst cannot be resolved for signal $signal!");
        return; #TODO: Set to mode io and continue with that?
    }

    if ( $uk =~ m,(io),o ) { # Upper level has in's and out's -> We have to be ::in
        $do = 'i';
        $dir = "::in";
        if ( $uw->{'i'} eq 'A::' and $uw->{'o'} eq 'A::' ) {
            if ( scalar( keys( %$dw ) ) > 1 ) { # Possible Conflict!!
                $simple = 2;
                $logger->warn( '__W_ADD_PORT_', "\tPossible io mode conflict for $signal at $inst" );
            } else {
                if ( ( exists $dw->{'i'} ) and ( $dw->{'i'} eq 'A::' ) ) {
                    $simple = 1;
                } else {
                    $simple = 0;
                }
            }
        }
    } elsif ( $uk =~ m,^i$,o ) { # Upper inst. have in's, only ->
        $do = 'o';
        $dir = "::out";
        if ( $uw->{'i'} eq 'A::' ) {
            if ( exists( $dw->{'o'} ) and $dw->{'o'} eq 'A::' ) { $simple = 1; }
        } #All others cases are handled in other branch
    } elsif ( $uk =~ m,^o$,o ) { # Upper inst. have out's, only ->
        #Maybe there are multiple driver's
        $do = 'i';
        $dir = "::in";
        if ( $uw->{'o'} eq 'A::' ) {
            if (  exists( $dw->{'i'} ) and $dw->{'i'} eq 'A::' and
                not exists( $dw->{'o'} ) ) {
                    $simple = 1;
            }
        }
    } elsif ( $uk =~ m,^c$,o ) { # Upper levels are inout/c, only ...
        $do = 'c'; # inout should be the mode ...
        $dir = "::in"; #Put that into ::out column ..
        #TODO: define $dir by daughter's ::in or ::out?
        if ( $uw->{'c'} eq 'A::' ) {
            if (  exists( $dw->{'c'} ) and $dw->{'c'} eq 'A::' and
                not exists( $dw->{'o'} ) and not exists( $dw->{'i'} ) ) {
                    $simple = 1;
            }
        }
    } else {
    # Other cases are mixes or new ...
        $logger->warn( '__W_ADD_PORT_', "\tCannot resolve connection request $uk for $inst, signal $signal" );
    }

    #
    # If we identified the simple cases, let's do it.
    # Else we go into bit counting ..
    #
    my %t = ();
    if ( not $tw and $simple  ) {
        # I guess this is the most likely case
        # Full signal connect needed (either bus or single bit)
        #
        my $sf = $conndb{$signal}{'::high'};
        my $st = $conndb{$signal}{'::low'};
        unless ( defined $sf ) { $sf = ""; };
        unless ( defined $st ) { $st = ""; };

        generate_port( $signal, $inst, $do, $sf, $st, $top_flag ); # Full connect, always!

        $tw = { $do => "A::" };
        $tm = $do;

    } else {
    #
    # Here begins the bit/bus/splice trouble
    # only busses here ...
    # If I just could put myself in here and make sure MIX doesn't produce "suboptimal"
    # results ..
    #

        # Case one: There is already a (partial) connection to this_instance ...
        if ( $tm ) {
            # Delete the corresponding bits
            # TODO : Catch further cases ....
            #!wig20031008: Another case: $tw equals $dw (only one mode!!) ... ignore $do then ....
            if ( join( '', keys( %$dw ) ) eq $tm ) {
                if ( $dw->{$tm} eq $tw ) {
                    $logger->info('__I_ADD_PORT_', "\tAlready connected daughters of $inst properly for signal $signal, ignore uppers");
                    return( {$tm => $tw}, $tm );
                }
            }
            elsif ( $tm eq $do ) { # Maybe this is a stupid try to reconnect ....
                if ( $tw =~ m,^A::, ) { # Already connected fully .... hmm, simply return ..
                    $logger->info('__I_ADD_PORT_', "\tTrying to reconnect $signal to $inst.");
                    return( { $tm => $tw} , $tm );
                } elsif ( defined( $dw->{$do} ) and $dw->{$do} eq $tw )  {
                    $logger->info('__I_ADD_PORT_', "\tTrying to reconnect $signal to $inst partially.");
                    return( { $tm => $tw} , $tm );
                } else {
                    $logger->warn( '__W_ADD_PORT_', "\tInstance $inst partially connected to $signal. File bug report!" );
                }
            }
        }
        #
        # Case two:
        # All bit vectors are of same format .... or expandable
        #
        my $mode = ""; # mode = "b" or "f"
        for my $m ( keys( %$dw ) )  {
            my $nm = substr( $dw->{$m}, 0, 1 );
            next if ( $nm eq "A" ); # "A" can be used anyway
            if ( $nm eq "E" ) { # Some error coming from previous processing
                $mode = "E";
                last;
            } elsif ( not $mode ) { # Mode not set up to now
                $mode = $nm;
            } elsif ( $mode ne $nm ) { # Upps, conflict
                $logger->error( '__E_ADD_PORT_', "\tCannot resolve mode requests $signal at $inst!" );
                $mode = "E";
            }
        }
        # unless ( $mode ) { $dmode = "A"; }
        for my $m ( keys( %$uw ) )  {
            my $nm = substr( $uw->{$m}, 0, 1 );
            next if ( $nm eq "A" ); # "A" can be used anyway
            if ( $nm eq "E" ) { # Some error coming from previous processing
                $mode = "E";
                last;
            } elsif ( not $mode ) { # Mode not set up to now
                $mode = $nm;
            } elsif ( $mode ne $nm ) { # Upps, conflict
                $logger->error( '__E_ADD_PORT_', "\tCannot resolve conflicting mode requests $signal at $inst!" );
                $mode = "E";
            }
        }
        unless( $mode ) { #Cannot be true, we have all A's, maybe related to $tm
            $mode = "B";
        }
        if ( $mode eq "E" ) {
            $logger->error( '__E_ADD_PORT_', "\tCannot resolve mode request for $signal at $inst finally!" );
        } elsif ( $mode eq "B" ) {
            my $sf = $conndb{$signal}{'::high'};
            my $st = $conndb{$signal}{'::low'};
            my $ub;
            my $lb;
            unless ( defined $sf ) { $sf = ""; };
            unless ( defined $st ) { $st = ""; };
            if ( $sf eq "" and $st eq "" ) { #Might be single bit signal, but with i/o issue:
                $sf = 0; # hmmm, hope that will do the trick
                $st = 0;
            }
            if ( is_integer2( $sf, $st ) ) {
                if ( $sf > $st ) { # Run from $st to $sf ....
                    $ub = $sf;
                    $lb = $st;
                } else {
                    $ub = $st;
                    $lb = $sf;
                }
                expand_a_vec( $dw, $lb, $ub ); # Get rid of A::
                expand_a_vec( $uw, $lb, $ub );
                check_b_vec( $dw, $lb, $ub ); # Are these the right size?
                check_b_vec( $uw, $lb, $ub );
				# ! forward 'ei' / 'eo' to 'i' / 'o'
				# TODO : if ( exists( $uw->{'ei'} ) ) {
				# TODO: 	$uw->{'i'} = $uw->{'ei'};
				# TODO: }
				# TODO: if ( exists( $uw->{'eo'} ) ) {
				# TODO: 	$uw->{'o'} = $uw->{'eo'};
				# TODO: }
				# TODO: if ( exists( $dw->{'ei'} ) ) {
				# TODO: 	$dw->{'i'} = $dw->{'ei'};
				# TODO: }
				# TODO: if ( exists( $dw->{'eo'} ) ) {
				# TODO: 	$dw->{'o'} = $dw->{'eo'};
				# TODO: }
                strip_b_vec( $dw , "ioc", $lb, $ub );
                strip_b_vec( $uw, "ioc", $lb, $ub );

                #
                # Create ports
                # Iterate through bitslices and create port slices
                # if there is no link internally -> not link
                # if there   int: i,   ext: (i)o   -> create in port
                #             int: o, ext: i      -> create out port
                #             int: io, ext: i      -> create out port
                #             int: io, ext: -     -> no port
                #             int: io, ext: (i)o    -> kind of error, create an out port
                #                                       is an error anyway?
                my $start = "";
                my @p = ();
                # Iterate through all bit slices .. (left to right)
                for my $bc ( 0..($ub-$lb) ) {
                    $b = $ub - $lb - $bc;
                    if ( substr( $dw->{'i'}, $b, 1 ) and substr( $dw->{'o'}, $b, 1 ) ) {
                        if ( substr( $uw->{'i'}, $b, 1 ) and substr( $uw->{'o'}, $b, 1 ) ) {
                            $p[$bc] = "oed"; # Driver conflicts, Better: e??
                        } elsif( substr( $uw->{'o'}, $b, 1 ) )  {
                            $p[$bc] = "oed"; # Driver conflicts
                        } elsif( substr( $uw->{'i'}, $b, 1 ) ) {
                            $p[$bc] = "o";
                        } else {
                            $p[$bc] = "0"; # Not connected
                        }
                    } elsif ( substr( $dw->{'i'}, $b, 1 ) ) {
                        if ( substr( $uw->{'o'}, $b, 1 ) ) {
                            $p[$bc] = "i"; # In port
                        } elsif ( substr( $uw->{'i'}, $b, 1 ) ) {
                            $p[$bc] = "iwd"; # Warning, missing driver! Possibly check ::mode
                        } else {
                            $p[$bc] = "0"; # Not connected
                        }
                    } elsif ( substr( $dw->{'o'}, $b, 1 ) ) {
                        if ( substr( $uw->{'o'}, $b, 1 ) ) {
                            $p[$bc] = "oed"; # To much drivers
                        } elsif ( substr( $uw->{'i'}, $b, 1 ) ) {
                            $p[$bc] = "o";
                        } else {
                            $p[$bc] = "0";
                        }
                    } else { # No internal conection -> Don't care
                        $p[$bc] = "0";
                    }
                }
                # Now generate
                $start = $ub-$lb;
                my $m = "0";
                my %full = (); # if generate port does a full connect -> remember that
                my %bv = ( 'i' => "B::", 'o' => "B::", 'c' => "B::" );
                for my $b ( reverse( 0..($ub-$lb) ) ) {
                    if ( substr( $p[$b], 0, 1 ) ne $m ) { # Change
                        if ( $m and not exists( $full{$m} ) ) {
                            if ( generate_port( $signal, $inst, $m, $start + $lb , $b + 1 + $lb, $top_flag ) ) {
                                # Attached a full port!!
                                #TODO: Check if there are conflicts! Dangerous!
                                $full{$m} = 1;
                            }
                        }
                        $m = substr( $p[$b], 0, 1 );
                        $start = $b;
                    }
                    if ( $m eq "o" ) {
                        $bv{o} .= $m;
                        $bv{i} .= "0";
                        $bv{c} .= "0";
                    } elsif ( $m eq "i" ) {
                        $bv{i} .= $m;
                        $bv{o} .= "0";
                        $bv{c} .= "0";
                    } elsif ( $m eq "c" ) {
                        $bv{i} .= "0";
                        $bv{o} .= "0";
                        $bv{c} .= "c";
                    } else {
                        $bv{i} .= "0";
                        $bv{o} .= "0";
                        $bv{c} .= "0";
                    }
                }
                if ( $m and not exists( $full{$m} ) ) {
                    if ( generate_port( $signal, $inst, $m, $start + $lb , $lb, $top_flag ) ) {
                        # Attached a full port!!
                        $full{$m} = 1;
                    }
                }

                #TODO: Create tw for i and o, return hash
                $tm = "";
                for my $t ( sort( keys( %bv ) ) ) {
                    if ( $full{$t} ) {
                        $bv{$t} = 'A::';
                        $tm .= $t;
                    } elsif ( $bv{$t} =~ m,^B::0+$, ) {
                        delete( $bv{$t} );
                    } elsif( $bv{$t} =~ m,^B::$t+$, ) {
                        $bv{$t} = 'A::';
                        $tm .= $t;
                    } else {
                        $tm .= $t;
                    }
                }
                $tw = \%bv;
            } else {
                $logger->error( '__E_ADD_PORT_', "\tCannot read t/f for signal $signal, inst $inst!" );
                $tw = {};
                $tm = 'e';
            }
        } else { # F::STR...T::STR
            $logger->error( '__E_ADD_PORT', "\tNeed programming for F::foo:T::bar, signal $signal, inst $inst!" );
        }
    }
    return( $tw, $tm );
} # End of _add_port

#
# Generate an port for intermediate hierachy
#
#wig20031106: consider the new configuration options:
#  $eh->get( 'port.generate.name' ) and ...'width'
sub generate_port ($$$$$$) {
    my $signal = shift;
    my $inst = shift;
    my $m = shift;
    my $f = shift;
    my $t = shift;
    my $top_flag = shift;

    my %t = ();
    my $post = $eh->get( 'postfix.POSTFIX_PORT_GEN' );
    my $ftp = "";
    my $full = 0;

    my $h = $conndb{$signal}{'::high'};
    my $l = $conndb{$signal}{'::low'};
    # Get postfix for generated ports (special macro!):
    if ( $post =~ m,%IO%,o ) {
        $post =~ s/%IO%/$m/;
    }

    # If width is max -> use full signal to connect!
    # TODO : Check if upper level recognized that ...
    if ( $eh->get( 'port.generate.width' ) =~ m,\bmax,i ) {
        $post = '';
        # Do some checks ....
        if ( $f =~ m,^\d+$,o and $f ) { # $f is digit and > 0!
            if ( $conndb{$signal}{'::high'} =~ m,^\s*\d+\s*$,o ) {
                if ( $f > $h ) {
                    $logger->warn( '__W_GENERATE_PORT', "\tUpper bound $f of generated port for signal $signal at instance $inst greater then signal upper bound!" );
                }
            } elsif ( $h =~ m,\s*$^,o ) { # Signal has no width
                    $logger->warn( '__W_GENERATE_PORT', "\tUpper bound $f of generated port for signal $signal at instance $inst greater then signal upper bound!" );
            }
        } elsif ( $f =~ m,\S+,o and $f ne $h ) {
            $logger->warn( '__W_GENERATE_PORT', "\tUpper bound $f of generated port for signal $signal at instance $inst not matching signal definition!" );
        }
        if ( $t =~ m,^\d+$,o and $t ) { # $f is digit and > 0!
            if ( $l =~ m,^\s*\d+\s*$,o ) {
                if ( $f < $l ) {
                    $logger->warn( '__W_GENERATE_PORT', "\tLower bound $t of generated port for signal $signal at instance $inst smaller then signal lower bound!" );
                }
            } elsif ( $l =~ m,\s*$^,o ) { # Signal has no width
                    $logger->warn( '__W_GENERATE_PORT', "\tLower bound $t of generated port for signal $signal at instance $inst smaller then signal lower bound!" );
            }
        } elsif ( $t =~ m,\S+,o and $t ne $l ) {
            $logger->warn( '__W_GENERATE_PORT', "\tLower bound $t of generated port for signal $signal at instance $inst not matching signal definition!" );
        }
        # Simply take signal width as port width:
        $f = $h;
        $t = $l;
        $full = 1;
    } else {
        # Create port with minimum required number of bits ..
        # Unless high and low match $t and $f, we need to add a _F_T
        if ( $post =~ m,%FT%,o ) {
            $ftp = ( $f !~ m,^\s*$,o ) ? ( "_" . $f ) : "";
            $ftp .= ( $t !~ m,^\s*$,o ) ? ( "_" . $t ) : "";
            $post =~ s,%FT%,,;
        } elsif ( $f ne $h or $t ne $l ) {
        # Special: if signal is only one bit (no bus!) -> port should be one bit wide, too
            if ( ( $h eq "" or $h eq "0" ) and ( $l eq "" or $l eq "0" ) and
             ( $f eq "" or $f eq "0" ) and ( $t eq "" or $t eq "0" ) ) {
                $ftp = "";
            } else {
                $ftp = ( $f !~ m,^\s*$,o ) ? ( "_" . $f ) : "";
                $ftp .= ( $t !~ m,^\s*$,o ) ? ( "_" . $t ) : "";
            }
        }
    }

    # Top level will get no postfix!
    if ( ( $top_flag =~ m,top,io and $eh->get( 'output.generate.inout' ) =~ m,\bnoxfix,io )
         or $eh->get( 'port.generate.name' ) =~ m,\bsignal,io ) {
        $t{'port'} = $signal;
        #TODO: Check if port name is unique? But how should that work?
    } elsif ( $top_flag =~ m,top,io ) {
        $t{'port'} = $signal . $ftp . $post;
    } else {
        $t{'port'} = $eh->get( 'postfix.PREFIX_PORT_GEN' ) . $signal .
                $ftp . $post;
    }

    $t{'inst'} = $inst;

    if ( $t =~ m,^\s*$, ) {
        $t{'port_t'} = $t{'sig_t'} = undef;
    } else {
        $t{'sig_t'} = $t;
        $t{'port_t'} = 0;
    }

    #!wig: extend port guessing:
    if ( $f =~ m,^\s*$,o ) {
        $t{'port_f'} = $t{'sig_f'} = undef;
    } elsif ( $f =~ m,^\d+$,o ) { # $f is a number ...
        $t{'sig_f'} = $f;
        $t{'port_f'} = $f - (( $t =~ m,^\d+$, ) ? $t : 0);
    } else {
        $t{'sig_f'} = $f;
        # Take port_f literally!
        if ( $t eq "0" or $t eq "" or $t !~ m,^\d+$, ) {
            $t{'port_f'} = $f;
        } else {
            $logger->warn( '__W_GENERATE_PORT', "\tNeed to create port, but cannot calculate width: $f .. $t for instance $inst/$t{port}!" );
            $t{'port_f'} = "$f - $t"; # Try a simple " FROM - TO ";
        }
    }

	#!wig20050926: Single bit means -> set to empty string!
	# will not create problems, because the generated ports are unique
	#  and bit count starts from zero!
    if ( defined $f and defined $t and $f eq $t ) {
         $t{'port_t'} = $t{'port_f'} = ''; #previous set to: undef; # Port is only one bit wide ...
    }

    $logger->warn( '__I_GENERATE_PORT', "\tgenerate_port: signal $signal adds port $t{'port'} to instance $t{'inst'}" );
    $eh->inc( 'sum.genport' );

    # Push onto Connection Database ....
    if ( $m eq "o" ) {
        $m = '::out';
    } else {
        $m = '::in';
    }

    # To avoid issues, get rid of %EMPTY% in port name now
    $t{'port'} = replace_mac( $t{'port'}, $eh->get( 'macro' ) );
	$t{'_gen_'} = 1; # Mark this to be a generated port!

    push( @{$conndb{$signal}{$m}},  { %t } ); # Push on conndb array ...

    return $full;
}

#
# Strip B:: and add 0 vectors
#
sub strip_b_vec ($$$$) {
    my $r = shift;
    my $modes = shift;
    my $lb = shift;
    my $ub = shift;

    for my $i ( split( '', $modes ) ) {
        unless( exists ( $r->{$i} ) ) {
            $r->{$i} = "0" x ( $ub - $lb + 1 );
        } elsif ( not $r->{$i} =~ s,^B::,, ) {
            $r->{$i} = "0" x ( $ub - $lb + 1 );
        }
    }
}

#
# convert A:: to B::0dddd0dd0
#
sub expand_a_vec ($$$) {
    my $r = shift;
    my $min = shift;
    my $max = shift;

    for my $i ( keys( %$r ) ) {
		( my $tag = $i ) =~ s/^e([io])/$1/;
        if ( $r->{$i} =~ m,A::, ) {
            $r->{$i} = "B::" . $tag x ( $max - $min + 1);
        }
    }
}

#
# Check if B:: vector is formed as expected
# Extend missing branches ...
#
sub check_b_vec ($$$) {
    my $r = shift;
    my $min = shift;
    my $max = shift;

    for my $i ( keys( %$r ) ) {
        if ( $r->{$i} !~ m,B::, ) {
            $logger->warn( '__W_CHECK_B_VEC', "\tBad value in bit vector $i: $r->{$i}" );
        } elsif ( length( $r->{$i} ) - 3 != $max - $min + 1 ) {
            $logger->warn( '__W_CHECK_B_VEC', "\tBad length of bit vector $i: $r->{$i}" );
            substr( $r->{$i} , 3, 0 ) = "0" x ( $max - $min + 1 - length( $r->{$i} ) + 3 )
        }
    }
}

#
# Tree::DAG_Node::common is buggy -> use my_common instead
#
sub my_common (@) {
	my ( @nodes ) = @_;

	#
	# return undef if called without arguments
	#
	return unless( scalar( @nodes) >= 1 );

	#!wig20060503: make root the node with the shortest address:
	my $root = $nodes[0];
	my $is_root = 0;
	if ( scalar( @nodes ) == 1 and Tree::DAG_Node::is_node( $root )) {
        return $root;
	} else {
		my $l = 100;
        for my $n ( @nodes ) {
            if( Tree::DAG_Node::is_node( $n ) ) {
            	my $thisa = $n->address;
            	if( length( $thisa ) < $l ) {
            		$root = $n;
            		$l = length( $thisa );
            	}
            	$is_root++ if ( $thisa eq '0' );
            } else {
                $logger->error( '__E_PARSER_TREE_COMMON',
                	"\tInput of my_common nodes array is no Tree::DAG_Node node!" );
                return undef;
            }
        }
    }

	# If we have to many roots -> warn!
	if( $is_root > 1 ) {
		$logger->error('__E_DUPLICATE_TREEROOT', "\tFound $is_root root hierachy nodes" );
		return undef();
	}

	# If we have the root in here -> return immediately
	# Otherwise common( @nodes ) has problems!
	if ( $root->address eq '0' ) {
		return $root;
	}
	#
	# or if the nodes are not part of the same tree
	#
	unless( defined( $root->common( @nodes ) ) ) { return undef; };

	my $ar = $root->address . ':';

	for my $n ( 0..$#nodes ) {
		my $an = $nodes[$n]->address . ":";
		if ( index( $ar, $an ) == 0 ) { # an is substr of ar -> an is new root!
			$root = $nodes[$n];
			$ar = $root->address . ":";
		} elsif ( index( $an, $ar ) != 0 ) { # ar is not substr of an -> get ancestor ...
			# Look for common part of address:
			my @an = split( ':', $an );
			my @ar = split( ':', $ar );
			for my $m ( 0..$#an ) {
				if ( $an[$m] != $ar[$m] ) {
					# Here they differ -> substr has address of common
					if ( $m ) {
						$ar = join( ":", (@ar)[0..($m-1)]); # Take slice
						$root = $root->address( $ar );
                                                $ar .= ":";
						last;
					} else {
						return undef; # No match at all
					}
				}
			}
		}
	}
	return $root;
} # End of my_common

####################################################################
## parse_mac
## replace %MACROS% in data structures
####################################################################

=head2

parse_mac ()

Replace all occurences of %MACRO% in %hierdb and %conndb

=cut
sub parse_mac () {

    # Go through %hierdb ...
    _parse_mac( \%hierdb );

    # Go through %conndb ...
    _parse_mac( \%conndb );

}

=head2

_parse_mac ($)

get reference to hash{hash}... and do the macro parsing

=cut

sub _parse_mac ($) {
    my $rh = shift;

    for my $h ( keys( %$rh ) ) {
        for my $f ( keys( %{$rh->{$h}} ) ) {
            #TODO if $f is array or hash -> recurse into it

            # Skip internal data structures
            next if ( $f eq '::treeobj' );
            next if ( $f eq '::conn' );
            next if ( $f eq '::typecast' );

            my $rf = \$rh->{$h}{$f};

            # If $rf is not of type ref(scaler) -> go deeper into it
            if ( ref($rf) eq 'REF' and ref( $$rf ) eq 'ARRAY' ) { # ::in and ::out
                for my $e ( 0..$#{$$rf} ) {
                    __parse_inout( $$rf->[$e], $rh->{$h} ); #TODO ...
                }
            } elsif ( ref($rf) eq "SCALAR" ) {
                __parse_mac( $rf, $rh->{$h} );
            } else {
                $logger->error( '__E_PARSE_MAC_', "\tTODO: Implement recursive parse_mac for $h $f");
                next;
            }
        }
    }
    return;
}

sub __parse_inout ($$) {
    my $ra = shift;
    my $rb = shift;

    for my $i ( keys( %$ra ) ) {
        if ( $ra->{$i} ) {
            __parse_mac( \$ra->{$i}, $rb );
        }
    }
}

#
# replace %text%
#
# Arguments:
#  1. text to scan through
#  2. hash array reference (to e.g. add comments)
#  Will modify contents of first argument directely
#
#!wig20050712: add exceptions for the logic keywords
#!wig20051011: adding 'postfix' replacements!
#		see also mix_expand_name (which does early name expansion)
#!wig20060517: support %HIGH|LOW(_BUS)_NN%
sub __parse_mac ($$) {
    my $ra = shift;
    my $rb = shift;

    my $ehmacs = \%{$eh->get( 'macro' )};
	my $pfmacs = \%{$eh->get( 'postfix' )};

    unless( defined $$ra ) {
        $logger->warn( '__W_PARSE_MAC__', "\tTrying to match against undef value");
        $rb->{'::comment'} .= "#WARNING: undef value somewhere";
        return;
    }

	# Iterate through text:
    while ( $$ra =~ m/(%([\w:]+?)%)/g ) {
        my $mac = $1;
        my $mackey = $1;
        my $hln    = '';
        my $pfkey = $2;  # Keys in eh.postfix do not have the %....%!!
        # Downgrade %OPEN_NN% to %OPEN% ..
        if ( $mac =~ m/^%OPEN_\d+%/o ) {
            $mackey = '%OPEN%';
        }
        # Be prepared for %HIGH|LOW(_BUS)_NN% to %HIGH|LOW(_BUS)%
        if ( $mac =~ m/^%(HIGH|LOW)(_BUS)?(_\d+)%/o ) {
        	$mackey = '%' . $1 .
        		( ( $2 ) ? $2 : '' ) . '%';
        	$hln = $3; # Forward number to replacer below
        }

        # O.K., ignore TYPECAST and TICK_DEFINE_ dummy generated modules ...
        if ( $mac =~ m/^%(TYPECAST_|TICK_DEFINE_)/o ) {
            return;
        }
        my $meh = $eh->get( 'output.generate._logicre_' );
        if ( $mackey =~ m/^%(::\w+)%/ ) {
            if ( exists( $rb->{$1} ) ) {
                my $r = $rb->{$1};
                $$ra =~ s/%[\w:]+?%/$r/;
            } else {
            	# Skip some
                $logger->warn( '__W_PARSE_MAC__', "\tCannot find macro $1 to replace!");
            }
        } elsif( exists( $ehmacs->{$mackey} ) ) {
            $$ra =~ s/$mac/$ehmacs->{$mackey}$hln/;
        } elsif ( $mackey =~ m/$meh/i ) {
        	; # Do nothing here
        } elsif ( exists( $pfmacs->{$pfkey} ) ) {
        	$$ra =~ s/$mac/$pfmacs->{$pfkey}/;
        } else {
            $logger->warn( '__W_PARSE_MAC__', "\tCannot locate replacement for $mac in data!");
        }
    }
    return;
}

####################################################################
## purge_relicts
## look through %hierdb and %conndb and fix up things
####################################################################

=head2

purge_relicts ()

Look through hierachy and connection database and fix up things like:
    instances without name (parentless ...??)

=cut
sub purge_relicts () {

    #
    # remove empty entities (e.g. created for entities without parents ...)
    # Should not happen anyway.
    #
    for my $i ( keys( %hierdb ) ) {
        unless ( $i ) {
            $logger->warn( '__W_PURGE_RELICTS', "\tRemoving empty instance! Check input sheets!");
            delete( $hierdb{$i} );
        }
        #wig20040322: detect and remove %UAMN% keyword -> set ::workaround
        if ( $hierdb{$i}{'::config'} =~ s,%(UAMN|USEASMODULENAME)%,,i ) {
            $hierdb{$i}{'::workaround'} = "::config::__" . $1 . "__"; #Workaround: %UAMN% -> __UAMN__
        }
    }

	# No connection defined here:
	if ( scalar( keys( %conndb ) ) <= 0 ) {
		#!wig20071001: if conn.req is set to "mandatory" report this
		if ( $eh->get('conn.req') =~ m/\bmandatory/io ) {
			$logger->error( '__E_CONN_EMPTY', "\tNo connections defined here!" );
		}
		return;
	}

    #
    # If ::high and ::low is defined, extend ::in and ::out definitions
    #
    for my $i ( keys( %conndb ) ) {

        unless( defined( $conndb{$i}{'::high'} ) ) { $conndb{$i}{'::high'} = ''; }
        unless( defined( $conndb{$i}{'::low'} ) ) { $conndb{$i}{'::low'} = ''; }

        $conndb{$i}{'::high'} = '' if ( $conndb{$i}{'::high'} =~ m,^\s+,o );
        $conndb{$i}{'::low'} = '' if ( $conndb{$i}{'::low'} =~ m,^\s+,o );

        #!wig20050113: next if ( $i =~ m,%OPEN(_\d+)?%, ); # Ignore the %OPEN% pseudo-signal

		# Remove empty entries (s.times we have an empty array!
        if ( $conndb{$i}{'::high'} ne '' or $conndb{$i}{'::low'} ne '' ) {
            my $h = $conndb{$i}{'::high'};
            my $l = $conndb{$i}{'::low'};
            	if ( scalar( @{$conndb{$i}{'::in'}} )) {
                	_extend_inout( $h, $l, $conndb{$i}{'::in'} );
            	}
            	if ( scalar( @{$conndb{$i}{'::out'}} )) {
                	_extend_inout( $h, $l, $conndb{$i}{'::out'} );
            	}
            # }
        }

        #!wig20030731: make sure high/low_bus has width!
        if ( $i =~ m,^%(LOW|HIGH)_BUS(_\d+)?%$,o ) {
            # If high or low bus does not have ::high or ::low defined, set it ...
            if ( $conndb{$i}{'::high'} eq '' or $conndb{$i}{'::low'} eq '' ) {
                my $max = 1; # Minimal assign a 1 to the high/low bus width
                for my $ii ( @{$conndb{$i}{'::in'}} ) {
                    if ( $ii->{'port_f'} and $ii->{'port_f'} < $max ) {
                        $max = $ii->{'port_f'};
                    }
                }
                $conndb{$i}{'::high'} = $max;
                $conndb{$i}{'::low'} = '0';
            }
        }

        #!wig20030731: make sure "open" gets width!
        if ( $i =~ m,^%OPEN(_\d+)?%$,o ) {
            if ( $conndb{$i}{'::high'} eq '' or $conndb{$i}{'::low'} eq '' ) {
                my $max = 0; # Minimal assign a 0 to the high/low bus width
                for my $ii ( @{$conndb{$i}{'::out'}} ) {
                    if ( $ii->{'sig_f'} and $ii->{'sig_f'} > $max ) {
                        $max = $ii->{'sig_f'};
                    }
                }
                if ( $max > 0 ) {
                    $conndb{$i}{'::high'} = $max;
                    $conndb{$i}{'::low'} = "0";
                }
            }
            # TODO : Is "type" set correctely
            unless( $conndb{$i}{'::type'} ) {
                if ( $conndb{$i}{'::high'} ) {
                    $conndb{$i}{'::type'} = "%BUS_TYPE%";
                } else {
                    $conndb{$i}{'::type'} = "%SIGNAL%";
                }
            }
        }

    	# uniquify signals
        my $rsa = $conndb{$i}; #Reference
        $rsa->{'::out'} = _scan_inout( $rsa->{'::out'} );
        $rsa->{'::in'}  = _scan_inout( $rsa->{'::in'} );

        # Does a _vector type have bounds defined?
        if ( ( $conndb{$i}{'::high'} eq "" or $conndb{$i}{'::low'} eq "" ) and
            $conndb{$i}{'::type'} =~ m,(.*_vector$), ) {
                $logger->warn( '__W_PURGE_RELICTS', "\tFound signal ($i) of type $1 with undefined bounds!" );
        }

        #!wig20030516: auto reducing single width busses to signals ...
        if ( $conndb{$i}{'::high'} eq "0" and $conndb{$i}{'::low'} eq "0" ) {
            if ( $conndb{$i}{'::type'} =~ m,std_u?logic\s*$,io ) {
                $conndb{$i}{'::high'} = '';
                $conndb{$i}{'::low'} = '';
            } elsif ( $conndb{$i}{'::type'} =~ m,(std_u?logic)_vector\s*$,io ) {
                $logger->warn( '__W_PURGE_RELICTS', "\tReducing signal $i from type $conndb{$i}{'::type'} to $1!");
                $conndb{$i}{'::high'} = '';
                $conndb{$i}{'::low'} = '';
                $conndb{$i}{'::type'} = $1;
            } elsif ( $conndb{$i}{'::type'} eq ($eh->get( 'conn.field.::type' ))->[3] ) {
                $conndb{$i}{'::high'} = '';
                $conndb{$i}{'::low'} = '';
            }
        }
    }

    #
    # Check for VHDL/Verilog/... keywords in instance and port names ...
    #
    for my $i ( keys( %conndb ) ) {
            _check_keywords( $i, $conndb{$i}{'::in'} );
            _check_keywords( $i, $conndb{$i}{'::out'} );
    }

    # Last iteration:
    for my $i ( keys( %conndb ) ) {
        # fix borders for constant definitions with %BUS% references ...
        if ( scalar( @{$conndb{$i}{'::in'}} ) and
        		exists( $conndb{$i}{'::in'}[0]{'inst'} ) and
             $conndb{$i}{'::in'}[0]{'inst'} =~ m/^(%|__)BUS(%|__)$/io ) {
            my $b = $conndb{$i}{'::in'}[0]{'port'};
            if ( exists ( $conndb{$b} ) ) {
                $conndb{$i}{'::low'} = $conndb{$b}{'::low'};
                $conndb{$i}{'::high'} = $conndb{$b}{'::high'};
                $conndb{$i}{'::type'} = $conndb{$b}{'::type'};
            } else {
                $logger->warn( '__W_PURGE_RELICTS', "\tUnknown bus $b referenced in constant $i" );
            }
        }
    }
} # End of purge_relicts

#
# Look through ::in and ::out arrays and check/change VHDL/Verilog keywords ..
# e.g. open ....
# Set configuration value postfix.PREFIX_KEYWORD to %NULL% to suppress changes
#
# TODO : Shift that routine to MixChecker
sub _check_keywords ($$) {
    my $name = shift;
    my $ior = shift;

    # TODO : Run that again in the backend, after everything got evaled
    # TODO : There is no way to figure out %::cols% conflicts finally :-(
    # at this stage.
    # We will do our best to find open/%::name% (as this is likely to happen)
    #
    my $ehkw = $eh->get( 'check.keywords' );
    for my $l ( keys( %$ehkw ) ) {
        for my $i ( @$ior ) {
            for my $ii ( qw( inst port ) ) {
            	#!wig20050713: Found ports defined without "inst" and "port"!
            	if( not exists( $i->{$ii} ) or not defined( $i->{$ii} ) ) {
            		$logger->error( '__E_CHECK_KEYWORDS', "\tMissing key $ii in structure $name! Contact MIX maintainer" );
            	} elsif ( $i->{$ii} =~ m,^$ehkw->{$l}$, ) {
                    $i->{$ii} = $eh->get( 'postfix.PREFIX_KEYWORD' ) . $1;
                    $logger->warn( '__W_CHECK_KEYWORDS', "\tDetected keyword $1 in $ii got replaced!" );
                } elsif ( $name =~ m,%OPEN(_\d+)%,o and $i->{$ii} eq '%::name%' ) {
                    $i->{$ii} = $eh->get( 'postfix.PREFIX_KEYWORD' ) . $i->{$ii};
                    $logger->warn( '__W_CHECK_KEYWORDS', "\tWARNING: Detected keyword $name in $ii got extended!" );
                }
            }
        }
    }
} # End of _check_keywords

# If ::high and/or ::low is defined,
# check if there are port definitions to be extended
#
#!wig20050713: return when $ref has no real contents!
sub _extend_inout ($$$) {
    my $h = shift;
    my $l = shift;
    my $ref = shift;

	# remove empty hashes:
    for my $i ( @{$ref} ) {
    	next if ( scalar( keys ( %$i ) ) == 0 ); # Skip empty hashes
        if( not defined( $i->{'sig_f'} ) and
            not defined( $i->{'port_f'} ) ) {
                $i->{'sig_f'} = $h;
                $i->{'port_f'} = $h;
        } elsif ( not defined( $i->{'sig_f'} ) # or
                # not defined( $i->{'port_f'} )
                ) {
            $logger->warn( '__W_EXTEND_INOUT', "\tUnusual upper bound definitions for $i->{'inst'} / $i->{'port'}" );
        }
        if ( not defined( $i->{'sig_t'} ) and
            not defined( $i->{'port_t'} ) ) {
                $i->{'sig_t'} = $l;
                $i->{'port_t'} = $l;
        } elsif ( not defined( $i->{'sig_t'} ) # or
                # not defined( $i->{'port_t'} )
                  ) {
            $logger->warn( '__W_EXTEND_INOUT', "\tUnusual lower bound definitions for $i->{'inst'} / $i->{'port'}" );
        }
        #!wig50050511: port bounds get derived from signal bounds (if unset).
		if ( not defined( $i->{'port_f'} ) ) {
			$i->{'port_f'} = $h;
		}
		if ( not defined( $i->{'port_t'} ) ) {
			$i->{'port_t'} = $l;
		}
    }
} # End of _extend_open

#
# strip away duplicate entries in ::in and ::out
# strip away empty entries
# force lowercasing if configured
#wig20040818: remove empty port maps
#TODO: combine entries (opposite of split busses)
#
sub _scan_inout ($) {
        my $rsa = shift;

        no warnings; # switch of warnings here, values might be undefined ...
        my %seen = ();
        my @left = ();

        for my $iii ( 0..$#{$rsa} ) {
            # Remove empty ::in/::out ...
            if ( scalar( keys %{$rsa->[$iii]} ) > 0 ) {
                unless( exists( $rsa->[$iii]{'rvalue'} ) ) {
                    if ( exists( $rsa->[$iii]{'inst'} ) ) {
                        $rsa->[$iii]{'inst'} = mix_check_case( 'inst', $rsa->[$iii]{'inst'} );
                    }
                    if ( exists( $rsa->[$iii]{'port'} ) ) {
                        $rsa->[$iii]{'port'} = mix_check_case( 'port', $rsa->[$iii]{'port'} );
                    }
                }
                # Mask the _descr_ field :
                my $this = '';
                for my $k ( qw( inst port sig_f sig_t port_f port_t ) ) {
                	$this .= '_$k::_' . $rsa->[$iii]{$k}; # Use specaial seperator
            	}
            	# TODO : Prevent loose of information like _descr_ ...
                if( $this and not defined( $seen{$this} ) ) {
                    push( @left, $rsa->[$iii] );
                    $seen{$this} = 1;
                }
            }
        }
        $rsa = _mix_p_unsplice_inout( \@left );
        return $rsa;
}

#
# See if certain parts of a signal/port can be combined into one description
#
sub _mix_p_unsplice_inout ($) {
	my $rsa = shift; # array ref with ::in or ::out

	return $rsa unless( scalar @$rsa  > 1 );

	my @io = @$rsa; # Make a copy here

	my %h  = ();
	my %hi = ();
	my %h2 = ();
	my @ho = (); # Gets output ....
	my $n   = 0;
	# Find combinable ports (max port width)
	# Prerequisite: port_f is > then port_t!!
	for my $i ( @io ) {
		# Read all in/out ...
		# has to be dezimal limit (positive integer
		if ( defined( $i->{'port_f'} ) and
				$i->{'port_f'} =~ m/^\d+$/ and
				$i->{'port_f'} >= 0 and
				defined( $i->{'port_t'} ) and
				$i->{'port_t'} =~ m/^\d+$/ and
				$i->{'port_t'} >= 0
			) {
			# Check that parts match (should be done already
			# somewhere else ...
			if( $i->{'sig_f'} !~ m/^\d+/ or
				$i->{'sig_t'} !~ m/^\d+/ ) {
				$logger->error( '__E_UNSPLICE_INOUT', "\tMismatch port vs. signal borders for " .
					$i->{'inst'} . "/" . $i->{'port'} . "!" );
				$h2{$i->{'inst'}}{$i->{'port'}} = 1; # Not combinable ...
				push( @ho, $i );
			} elsif ( $i->{'port_f'} - $i->{'port_t'} !=
				 	  $i->{'sig_f'} - $i->{'sig_t'} ) {
				 $logger->error('__E_UNSPLICE_INOUT', "\tMismatch port width vs. signal width for " .
					$i->{'inst'} . "/" . $i->{'port'} . "!" );
				$h2{$i->{'inst'}}{$i->{'port'}} = 1; # Not combinable ...
				push( @ho, $i );
			} else {
				# Remember this ports index number ...
				push( @{$hi{$i->{'inst'}}{$i->{'port'}}}, $n );
			}
		} else {
			$h2{$i->{'inst'}}{$i->{'port'}} = 1; # Not combinable ...
			push( @ho, $i );
		}
		$n++;
	}
	# Remove all non-combinable ports from hi index!
	# %h2 -> non-combinable!
	# @ho -> all non-combinable
	# %hi -> index to combinable
	for my $k ( keys %h2 ) {
		for my $kk ( keys %{$h2{$k}} ) {
			if ( exists $hi{$k}{$kk} ) {
				# This inst/port is not combinable -> send them to output
				for my $kkk ( @{$hi{$k}{$kk}} ) {
					push( @ho, $io[$kkk] );
				}
				delete $hi{$k}{$kk};
			}
		}
	}

	#TODO: rebuild to_merge structure, but based on the left-over in the
	#  %hi index -> h2;

	for my $k ( keys %hi ) {
		for my $kk ( keys( %{$hi{$k}} ) ) {
			my $num = scalar( @{$hi{$k}{$kk}} );
			if ( $num > 1 ) {
				my @h = ();
				for my $i ( @{$hi{$k}{$kk}} ) {
					push( @h, $io[$i] );
				}
				# Try combine for all ports left in %hi
				#   results go to @ho
				push( @ho, _mix_p_try_merge( \@h )) ;
			} else {
				push( @ho, $io[$hi{$k}{$kk}[0]] );
			}
		}
	}

	return \@ho; # Return a reworked array reference
}

#
# Check if some port descriptions are mergeable
# use digits as tokens
#!wig20050428
sub _mix_p_try_merge ($) {
	my $r = shift;

	my %s = ();
	my %smax = ();
	my @out = ();

	# Sort by diffs from signal_f vs. port_f
	for my $i ( @$r ) {
		my $d = $i->{'sig_f'} - $i->{'port_f'};
		push( @{$s{$d}}, $i );
		if ( not exists $smax{$d} or $smax{$d} < $i->{'port_f'} + 1  ) {
			$smax{$d} = $i->{'port_f'} + 1;
		}
	}
	for my $d ( keys( %s ) ) { # All parts with the same shift:
		# Width of tokens is defined by number of slots;
		my $ntokens = scalar( @{$s{$d}} );
		my $tokwid = length( $ntokens );
		my $map = " " x ( $smax{$d} * $tokwid );
		# fill string with the tokens
		my $n = 0;
		for my $c ( @{$s{$d}} ) {
			# calculate position -> port_f..port_t
			my $lpos = $c->{'port_t'};
			my $upos = $c->{'port_f'};
			# my $rep  = $upos - $c->{'port_t'}; #TODO: What is port_t > port_f ?
			my $token = sprintf( ("%0" . $tokwid . "d" ), $n );
			# insert token into token string ....
			# but: check if token position is already set (wig says: not needed!!)
			for my $it ( $lpos..$upos ) {
				if ( substr( $map, $it * $tokwid, $tokwid ) =~ m/^\s+$/io ) {
					substr( $map, $it * $tokwid, $tokwid ) = $token;
				}
				# else: Already set? Conflict or just a duplicate definition:
				# Skip it! port/signal have same offset!
				#	my $prev = substr( $map, $it, $tokwid );
				#	my $sig_prev = $s{$d}[$prev]
			}
			$n++;
		}
		# Scan through map and get consecutive tokens ....
		for my $p ( split( /\s+/ , $map ) ) { # split by whitespace:
			# Split $p in $tokwid wide pieces
			my $partwidth = length( $p  ) / $tokwid; # Has to be integer ...
			next if ( $partwidth < 1 ); # split returns empty string sometimes ...
			#  read first token data
			$p =~ m/^(\d{$tokwid})/;
			# index number:
			my %pout = %{$s{$d}->[$1]};
			# correct width
			$pout{'port_f'} = $pout{'port_t'} + $partwidth - 1;
			$pout{'sig_f'}  = $pout{'sig_t'} + $partwidth - 1;
			push( @out, \%pout );
		}
	}
	#TODO: check for overlapping port connections

	return( @out ); # Ref to unspliced ports description
}

####################################################################
## add_sign2hier
## look through %conndb and add $hierdb{INSTANCE}{::conn}{::out|::in}{CONN}{PORT}
## as index to the signals.
####################################################################

=head2

add_sign2hier ()

look through %conndb and add $hierdb{INSTANCE}{::conn}{::out|::in}{CONN}{PORT}
as index to the signals.

=cut
sub add_sign2hier () {

    #
    for my $i ( keys( %conndb ) ) {
        my $rsa = $conndb{$i};
        _add_sign2hier( "out", $i, $rsa->{'::out'} );
        _add_sign2hier( "in", $i, $rsa->{'::in'} );
        _add_sign2hier( "generic", $i, $rsa->{'::in'} );
    }
}

#
#TODO: check if a port is both in ::in and ::out list
#
sub _add_sign2hier ($$$) {
    my $io  = shift;
    my $conn = shift;
    my $rsa = shift;

    for my $iii ( 0..$#{$rsa} ) {
        my $inst = $rsa->[$iii]{'inst'};
        next unless ( defined( $inst ) ); # Skip undefined instance names ....
        $inst =~ s,^__(\w+)__$,%$1%,; # Get back %NAME% from __NAME__
        unless ( exists ( $hierdb{$inst} ) )  {
			if ( $conndb{$conn}{'::mode'} !~ m,^\s*[CPG],o ) {
               	# Complain if signal does connect to unknown instance
               	$logger->error('__E_SIGN2HIER', "\tSkipping connection $conn to undefined instance $inst!");
            }
            next;
        }
        next if ( $inst eq '%CONST%' );
        # Skip meta instance %CONST%
        my $port = $rsa->[$iii]{'port'};
        unless ( defined( $port ) ) {
                $logger->error('__E_SIGN2HIER', "\tUndefined port for connection $conn, instance $inst!");
                $port = "__E_UNDEF_PORT";
        }
        #
        # Collect generic definitions ....
        #
        if ( $io eq "generic" ) {
            if ( $conndb{$conn}{'::mode'} =~ m,^\s*[GP],io ) {
                # Store $hierdb{$inst}{'::conn'}{'generic'}{NAME} = val
                my $parameter = "";
                for my $v ( 0 .. $#{$conndb{$conn}{'::out'}} ) {
                    if ( $conndb{$conn}{'::out'}[$v]{'inst'} =~ m,(%|__)PARAMETER(%|__),io ) {
                        $parameter = $conndb{$conn}{'::out'}[$v]{'port'};
                        last;
                    }
                }
                if ( $parameter ne "" ) { #Found s.th. appropriate ...
                    if ( exists( $hierdb{$inst}{'::conn'}{$io}{$port} ) ) {
                        $hierdb{$inst}{'::conn'}{$io}{$port} .= "," . $parameter;
                    } else {
                        $hierdb{$inst}{'::conn'}{$io}{$port} = $parameter;
                    }
                }
            }
        } else {
            #
            #TODO: Make sure we attach each port only once ...
            #
            if ( exists( $hierdb{$inst}{'::conn'}{$io}{$conn}{$port} ) ) {
                $hierdb{$inst}{'::conn'}{$io}{$conn}{$port} .= "," . $iii;
            } else {
                $hierdb{$inst}{'::conn'}{$io}{$conn}{$port} = $iii;
            }
        }
    }
}

##############################################################################
# mix_parser_importhdl($$)
##############################################################################

=head2 mix_parser_importhdl($$)

Read in HDL files and add appropriate data to the output
files.

=cut

sub mix_parser_importhdl ($$) {
    my $file = shift;    # Output goes to ...
    my $r_hdl = shift;  #Input comes from this array ref

    # scan input files
    # create HIER and CONN data
    for my $f ( @$r_hdl ) {
		if ( -r $f ) {
	    	$logger->info( '__I_IMPORTHDL', "\tImporting $f now!" );
	    	_mix_parser_parsehdl( $f ); # Will create a dummy hier and conn file
		} else {
	    	$logger->error( '__E_IMPORTHDL', "\tCannot read HDL $f for import" );
		}
    }

	# detect extension:
	my $ext = 'xls';
	if ( $file =~ m/\.(xls|csv|sxc|ods)$/ ) {
		$ext = $1;
	}
    # prepare to dump the data now ..
    parse_mac();
    my $arc = db2array( \%conndb , 'conn', $ext, '' );
    my $arh = db2array( \%hierdb, 'hier', $ext, "^(%\\w+%|W_NO_PARENT)\$" );

    # write_outfile( $dumpfile, "CONF", $aro ); #wig20030708: store CONF options ...
    write_outfile( $file, 'IMP_CONN', $arc );
    write_outfile( $file, 'IMP_HIER', $arh );

} # End of mix_parser_importhdl

=head2 Example for entity to parse

Scan HDL file and prepare the IMP_CONN and IMP_HIER sheet.

entity ddrv4 is
        -- Generics:
		-- No Generated Generics for Entity ddrv4
		generic(
		-- Generated Generics for Entity inst_1_e
			FOO	: integer -- __W_NODEFAULT
		-- End of Generated Generics for Entity inst_1_e
		);

    	-- Generated Port Declaration:
		port(
		-- Generated Port for Entity ddrv4
			alarm_time_ls_hr	: in	std_ulogic_vector(3 downto 0);
			alarm_time_ls_min	: in	std_ulogic_vector(3 downto 0);
			alarm_time_ms_hr	: in	std_ulogic_vector(3 downto 0);
			alarm_time_ms_min	: in	std_ulogic_vector(3 downto 0);
			clk	: in	std_ulogic;
			current_time_ls_hr	: in	std_ulogic_vector(3 downto 0);
			current_time_ls_min	: in	std_ulogic_vector(3 downto 0);
			current_time_ms_hr	: in	std_ulogic_vector(3 downto 0);
			current_time_ms_min	: in	std_ulogic_vector(3 downto 0);
			display_ls_hr	: out	std_ulogic_vector(6 downto 0);
			display_ls_min	: out	std_ulogic_vector(6 downto 0);

	    )
end inst_1_e;

=cut

sub _mix_parser_parsehdl ($) {
    my $file = shift;
    # my $r_h = shift;
    # my $r_c = shift;

    # Open ...
    my $fh = new IO::File;
    unless( $fh->open($file) ) {
		$logger->error( '__E_PARSEHDL', "\tCannot open import file $file: $!" );
		return undef;
    }

    # Read in all of file into one string:
    my $hdl  = do { local $/; <$fh> };

    # Look for entities in case of vhdl ...
    if ( $file =~ m,\.vhd(l)?$,io ) {
		# Look for all entities ....
		while( $hdl =~ m,entity\s+(\w+)\s+is\s+(.*?)end\s+\1,imsg ) {
	    	# Has entity body ...
	    	my $enty = $1; # Will use entity name as instance??
	    	my $inst = add_inst(
				'::inst' => "%PREFIX_INSTANCE%" . $enty . "%POSTFIX_INSTANCE%",
				'::entity' => $enty,
				'::parent' => "%IMPORT%",
				'::__source__' => 'hier',
			);
	    	my $body = $2;

	    	my $paren_in_comment_flag = 0;
	    	if ( $body =~ m,--.*[\(\)], ) { # $generic has a -- ( .. ) in it ...
			# Mask these parens ...
				while ( $body =~ m/(--.*?)\(/ ) {
		    		$body =~ s,(--.*?)\(,$1___LEFTPAR___,;  # Will that work properly?
				}
				while ( $body =~ m/(--.*?)\)/ ) {
		    		$body =~ s,(--.*?)\),$1___RIGHTPAR___,; # Will that work properly?
				}
				$paren_in_comment_flag = 1;
	   		}

	    	if ( $body =~  m,^\s*generic\s*($RE{balanced}{-parens=>'()'});,im ) {
        	# Got generic
				my $generic = $1;

            	# NO_DEFAULT	: string; -- __W_NODEFAULT
            	# NO_NAME	: string; -- __W_NODEFAULT
            	# WIDTH	: integer	:= 7
            	while( $generic =~ s/^\s*(\w+)\s*:\s*(\w+)\s*
                       (:=\s*([-\.,\w\d]+?))?
				       ;
				       ([ \t]*--.*)?//xm
		       	) {
		   		# $1 = genericname
		   		# $2 = generic type
		   		# $4 = default value (if set)
		   		# $5 = comments ...
		   		# push( @generics, [ $1, $2, $4, $5 ] );
		    		my %d = ( '::name' => $1,
				    	'::mode' => 'G',
				    	'::type' => $2,
				    	'::in' =>	$inst . "/" . $1,
                                    '::high' => '',
                                    '::low' => '',
                                    '::bundle'  => '%IMPORT_BUNDLE%' . uc($inst) ,
                                    '::class' => '%IMPORT%' . uc($inst),
                                    '::clock' => '%IMPORT_CLK%' . uc($inst),
			    	);
		    		$d{'::out'} = ( "'" . $4 ) if ( defined( $4 ) );
		    		$d{'::comment'} = $5 if ( defined( $5 ));
		    		$d{'::comment'} =~ s/^\s*(--)?\s*//;
					$d{'::comment'} =~ s/__LEFTPAR__/(/g;
					$d{'::comment'} =~ s/__RIGHTPAR__/)/g;
                    add_conn( %d );
                }
				if ( $generic =~ s/^\s*(\w+)\s*:\s*(\w+)\s*
                                       (:=\s*([-\.,\w\d]+?))?
				       ([ \t]*--.*)?//xm
		   		) {
		    		my %d = ( '::name' => $1,
				    	'::mode' => 'G',
				    	'::type' => $2,
				    	'::in' =>	$inst . "/" . $1,
                                    '::high' => "",
                                    '::low' => "",
                                    '::bundle'  => "%IMPORT_BUNDLE%" . uc($inst) ,
                                    '::class' => "%IMPORT%" . uc($inst),
                                    '::clock' => "%IMPORT_CLK%" .uc($inst),
			    	);
		    		$d{'::out'} = ( "'" . $4 ) if ( defined( $4 ) );
		    		$d{'::comment'} = $5 if ( defined( $5 ));
		    		$d{'::comment'} =~ s/^\s*(--)?\s*//;
					$d{'::comment'} =~ s/__LEFTPAR__/(/g;
					$d{'::comment'} =~ s/__RIGHTPAR__/)/g;
		    		# printf ( "#### Found generic in instance $inst:\n" );
		    		# printf ( "\t%s %s\n" x scalar( keys( %d ) ), %d );
                    add_conn( %d );
				}
	    	}
	    	# line begins with \s*port( .... ) ..
	    	if ( $body =~ m,^\s*port\s*($RE{balanced}{-parens=>'()'});,im ) {
                my $ports = $1;

                # alarm_time_ms_min	: in	std_ulogic_vector(3 downto 0);
                # clk	: in	std_ulogic;

                $ports =~ s/^\s*\(//;
                $ports =~ s/\s*\)$//;

                while( $ports =~ s/^\s*(\w+)\s*:\s*(\w+)\s*(\w+)\s*
                               (\(\s*(\d+)(\s+(down)?to\s+(\d+))?\s*\)\s*)?   # Optional (N downto M)
                               ;                                                   # ; or end of line
                               ([ \t]*--.*)?//ixm ) {
                    # Will catch e.th. but the last line ...
                    # $1 = portname
                    # $2 = port mode
                    # $3 = port type
                    # $4 contains ( N [down]to M )
                    # $5 = N
                    # $6 = downto M
                    # $7 = down | <empty>
                    # $8 = M
                    # $9 = comment
                    #TODO: check if M <= N for
                    # push( @ports, [ $1, $2, $3, $5, $8, $9 ] );
		    		my $mode = $2;
                    my $col = "::in";
		    		my %d = ( '::name' => $1,
				    # '::mode' => $2,
				    	'::type' => $3,
                        '::high' => "",
                        '::low' => "",
                        '::class' => "%IMPORT%" . uc($inst),
                        '::clock' => "%IMPORT_CLK%" . uc($inst),
                        '::bundle'  => "%IMPORT_BUNDLE%" . uc($inst) ,
			    	);
		    		if ( lc( $mode ) eq "in" ) {
						$d{'::mode'} = "%IMPORT_I%"; #TODO
		    		} elsif ( lc( $mode ) eq "out" ) {
						$col = "::out"; $d{'::mode'} = "%IMPORT_O%";
		    		} elsif ( lc( $mode ) eq "inout" ) {
						$d{'::mode'} = "IO";
		    		} elsif ( lc( $mode ) eq "buffer" ) {
						$d{'::mode'} = "B";
		    		} else {
						$logger->warn( '__W_PARSEHDL', "\tUnknown mode $mode in import" );
						$d{'::mode'} = "S";
		    		}

		    		$d{$col} = $inst . "/" . $1;
		    		$d{'::high'} = $5 if ( defined( $5 ) );
		    		$d{'::low'} = $8 if ( defined( $8 ) );
		    		if ( defined( $9 )){
		    			( $d{'::comment'} = $9 ) =~ s/^\s*(--)?\s*//;
						$d{'::comment'} =~ s/__LEFTPAR__/(/g;
						$d{'::comment'} =~ s/__RIGHTPAR__/)/g;
		    		}
		    		if ( $eh->get( 'import.generate' ) =~ m/\bstripio\b/io ) {
		    			$d{'::name'} =~ s/_(i|o|io)$//i;
		    		}
		    		add_conn( %d );
		    		# printf ( "#### Found port in instance $inst:\n" );
		    		# printf ( "\t%s %s\n" x scalar( keys( %d ) ), %d );
                }
                # catch last signal
                if( $ports =~ m/\n\s*(\w+)\s*:\s*(\w+)\s*(\w+)
                            	(\(\s*(\d+)(\s+(down)?to\s+(\d+))?[ \t]*\)\s*)?   # Optional (N downto M)
								([ \t]*--.*)?/ixm ) {
		    		#TODO: check if M <= N for
		    		my $mode = $2;
                    my $col = "::in";
		    		my %d = ( '::name' => $1,
				    # '::mode' => $2,
				    '::type' => $3,
                                   '::ign' => "",
                                    '::gen' => "",
                                    '::high' => "",
                                    '::low' => "",
                                    '::class' => "%IMPORT%" . uc( $inst ),
                                    '::clock' => "%IMPORT_CLK%" . uc( $inst ),
                                    '::bundle'  => "%IMPORT_BUNDLE%" . uc($inst) ,
			    	);
		    		if ( lc( $mode ) eq "in" ) {
						$d{'::mode'} = "%IMPORT_I%"; #TODO
		    		} elsif ( lc( $mode ) eq "out" ) {
						$col = "::out"; $d{'::mode'} = "%IMPORT_O%";
		    		} elsif ( lc( $mode ) eq "inout" ) {
						$d{'::mode'} = "IO";
		    		} elsif ( lc( $mode ) eq "buffer" ) {
						$d{'::mode'} = "B";
		    		} else {
						$logger->warn( '__W_PARSEHDL', "\tUnknown mode $mode in import" );
						$d{'::mode'} = "S";
		    		}
		    		$d{$col} = $inst . "/" . $1;
		    		$d{'::high'} = $5 if ( defined( $5 ) );
		    		$d{'::low'} = $8 if ( defined( $8 ) );
		    		if ( defined( $9 )){
		    			( $d{'::comment'} = $9 ) =~ s/^\s*(--)?\s*//;
						$d{'::comment'} =~ s/__LEFTPAR__/(/g;
						$d{'::comment'} =~ s/__RIGHTPAR__/)/g;
						$d{'::comment'} =~ s/^--\s*//;
		    		}
		    		if ( $eh->get( 'import.generate' ) =~ m/\bstripio\b/io ) {
		    			$d{'::name'} =~ s/_(i|o|io)$//i;
		    		}
		    		# printf ( "#### Found port in instance $inst:\n" );
		    		# printf ( "\t%s %s\n" x scalar( keys( %d ) ), %d );
            		add_conn( %d );
            	}
	    	}
		}
    } elsif ( $file =~ m,\.v$, ) {
		# Verilog ...
		$logger->error( '__E_PARSEHDL', "\tMaster Wilfried has not taught me to read in Verilog :-(" );
    } else {
		# What's that ?
		$logger->error( '__E_PARSEHDL', "\tCannot import file $file, unknown type!" );
    }

    return;

} # End of _mix_parser_parsehdl

=head 4 verilog connectivity import module

#
# Parse verilog files (read module header only!)
#
# Two styles supported:
#	module something ( signal, signal, signal );
#		input [6:0] signal;
#		input signal, signal;
#		inout signal;
#  ...
#  endmodule

module ent_t
//
// Generated Module inst_t
//
	(
		sig_i_a,
		sig_i_a2,
		sig_i_ae,
		sig_o_a,
		sig_o_a2,
		sig_o_ae
	);

	// Generated Module Inputs:
		input		sig_i_a;
		input		sig_i_a2;
		input	[6:0]	sig_i_ae;
	// Generated Module Outputs:
		output		sig_o_a;
		output		sig_o_a2;
		output	[7:0]	sig_o_ae;
	// Generated Wires:
		wire		sig_i_a;
		wire		sig_i_a2;
		wire	[6:0]	sig_i_ae;
		wire		sig_o_a;
		wire		sig_o_a2;
		wire	[7:0]	sig_o_ae;
// End of generated module header

		// Generated Instance Port Map for inst_a
		ent_a inst_a (

			.p_mix_sig_01_go(sig_01),	// Use internally test1Will create p_mix_sig_1_go port
			.p_mix_sig_03_go(sig_03),	// Interhierachy link, will create p_mix_sig_3_go
			.p_mix_sig_04_gi(sig_04),	// Interhierachy link, will create p_mix_sig_4_gi
			.p_mix_sig_05_2_1_go(sig_05[2:1]),	// Bus, single bits go to outsideBus, single bits go to outside, will create p_mix_sig_5_2_2_goBu...
			.p_mix_sig_06_gi(sig_06),	// Conflicting definition (X2)
			.p_mix_sig_i_ae_gi(sig_i_ae),	// Input Bus
			.p_mix_sig_o_ae_go(sig_o_ae),	// Output Bus
			.port_i_a(sig_i_a),	// Input Port
			.port_o_a(sig_o_a),	// Output Port
			.sig_07(sig_07),	// Conflicting definition, IN false!
			.sig_08(sig_08),	// VHDL intermediate needed (port name)
			.sig_13(),	// Create internal signal name
			.sig_i_a2(sig_i_a2),	// Input Port
			.sig_o_a2(sig_o_a2)	// Output Port
		);
		// End of Generated Instance Port Map for inst_a

endmodule



=cut

sub _mix_parser_parseverilog ($) {
	my $hdl = shift;

	# Look for all modules ....
	while( $hdl =~ m,module \s+ (\w+) \s+ \((.*?)\); (.*?) \s+ endmodule\s+\1,ximsg ) {
	    	# Has entity body ...
			######## REWORK ###########
	    	my $enty = $1; # Will use entity name as instance??
	    	my $inst = add_inst(
				'::inst' => "%PREFIX_INSTANCE%" . $enty . "%POSTFIX_INSTANCE%",
				'::entity' => $enty,
				'::parent' => "%IMPORT%",
				'::__source__' => 'hier',
			);
	    	my $body = $2;

	    	my $paren_in_comment_flag = 0;
	    	if ( $body =~ m,--.*[\(\)], ) { # $generic has a -- ( .. ) in it ...
			# Mask these parens ...
				while ( $body =~ m/(--.*?)\(/ ) {
		    		$body =~ s,(--.*?)\(,$1___LEFTPAR___,;  # Will that work properly?
				}
				while ( $body =~ m/(--.*?)\)/ ) {
		    		$body =~ s,(--.*?)\),$1___RIGHTPAR___,; # Will that work properly?
				}
				$paren_in_comment_flag = 1;
	   		}

	    	if ( $body =~  m,^\s*generic\s*($RE{balanced}{-parens=>'()'});,im ) {
        	# Got generic
				my $generic = $1;

            	# NO_DEFAULT	: string; -- __W_NODEFAULT
            	# NO_NAME	: string; -- __W_NODEFAULT
            	# WIDTH	: integer	:= 7
            	while( $generic =~ s/^\s*(\w+)\s*:\s*(\w+)\s*
                       (:=\s*([-\.,\w\d]+?))?
				       ;
				       ([ \t]*--.*)?//xm
		       	) {
		   		# $1 = genericname
		   		# $2 = generic type
		   		# $4 = default value (if set)
		   		# $5 = comments ...
		   		# push( @generics, [ $1, $2, $4, $5 ] );
		    		my %d = ( '::name' => $1,
				    	'::mode' => 'G',
				    	'::type' => $2,
				    	'::in' =>	$inst . "/" . $1,
                                    '::high' => '',
                                    '::low' => '',
                                    '::bundle'  => '%IMPORT_BUNDLE%' . uc($inst) ,
                                    '::class' => '%IMPORT%' . uc($inst),
                                    '::clock' => '%IMPORT_CLK%' . uc($inst),
			    	);
		    		$d{'::out'} = ( "'" . $4 ) if ( defined( $4 ) );
		    		$d{'::comment'} = $5 if ( defined( $5 ));
                    add_conn( %d );
                }
				if ( $generic =~ s/^\s*(\w+)\s*:\s*(\w+)\s*
                                       (:=\s*([-\.,\w\d]+?))?
				       ([ \t]*--.*)?//xm
		   		) {
		    		my %d = ( '::name' => $1,
				    	'::mode' => 'G',
				    	'::type' => $2,
				    	'::in' =>	$inst . "/" . $1,
                                    '::high' => "",
                                    '::low' => "",
                                    '::bundle'  => "%IMPORT_BUNDLE%" . uc($inst) ,
                                    '::class' => "%IMPORT%" . uc($inst),
                                    '::clock' => "%IMPORT_CLK%" .uc($inst),
			    	);
		    		$d{'::out'} = ( "'" . $4 ) if ( defined( $4 ) );
		    		$d{'::comment'} = $5 if ( defined( $5 ));
		    		# printf ( "#### Found generic in instance $inst:\n" );
		    		# printf ( "\t%s %s\n" x scalar( keys( %d ) ), %d );
                    add_conn( %d );
				}
	    	}
	    	# line begins with \s*port( .... ) ..
	    	if ( $body =~ m,^\s*port\s*($RE{balanced}{-parens=>'()'});,im ) {
                my $ports = $1;

                # alarm_time_ms_min	: in	std_ulogic_vector(3 downto 0);
                # clk	: in	std_ulogic;

                $ports =~ s/^\s*\(//;
                $ports =~ s/\s*\)$//;

                while( $ports =~ s/^\s*(\w+)\s*:\s*(\w+)\s*(\w+)\s*
                               (\(\s*(\d+)(\s+(down)?to\s+(\d+))?\s*\))?   # Optional (N downto M)
                               ;                                                   # ; or end of line
                               ([ \t]*--.*)?//ixm ) {
                    # Will catch e.th. but the last line ...
                    # $1 = portname
                    # $2 = port mode
                    # $3 = port type
                    # $4 contains ( N [down]to M )
                    # $5 = N
                    # $6 = downto M
                    # $7 = down | <empty>
                    # $8 = M
                    # $9 = comment
                    #TODO: check if M <= N for
                    # push( @ports, [ $1, $2, $3, $5, $8, $9 ] );
		    		my $mode = $2;
                    my $col = "::in";
		    		my %d = ( '::name' => $1,
				    # '::mode' => $2,
				    	'::type' => $3,
                        '::high' => "",
                        '::low' => "",
                        '::class' => "%IMPORT%" . uc($inst),
                        '::clock' => "%IMPORT_CLK%" . uc($inst),
                        '::bundle'  => "%IMPORT_BUNDLE%" . uc($inst) ,
			    	);
		    		if ( lc( $mode ) eq "in" ) {
						$d{'::mode'} = "%IMPORT_I%"; #TODO
		    		} elsif ( lc( $mode ) eq "out" ) {
						$col = "::out"; $d{'::mode'} = "%IMPORT_O%";
		    		} elsif ( lc( $mode ) eq "inout" ) {
						$d{'::mode'} = "IO";
		    		} elsif ( lc( $mode ) eq "buffer" ) {
						$d{'::mode'} = "B";
		    		} else {
						$logger->warn( '__W_PARSEHDL', "\tUnknown mode $mode in import" );
						$d{'::mode'} = "S";
		    		}

		    		$d{$col} = $inst . "/" . $1;
		    		$d{'::high'} = $5 if ( defined( $5 ) );
		    		$d{'::low'} = $8 if ( defined( $8 ) );
		    		if ( defined( $9 )){
		    			( $d{'::comment'} = $9 ) =~ s/^\s+//;
		    		}
		    		if ( $eh->get( 'import.generate' ) =~ m/\bstripio\b/io ) {
		    			$d{'::name'} =~ s/_(i|o|io)$//i;
		    		}
		    		add_conn( %d );
		    		# printf ( "#### Found port in instance $inst:\n" );
		    		# printf ( "\t%s %s\n" x scalar( keys( %d ) ), %d );
                }
                # catch last signal
                if( $ports =~ m/\n\s*(\w+)\s*:\s*(\w+)\s*(\w+)
                            	(\(\s*(\d+)(\s+(down)?to\s+(\d+))?[ \t]*\))?   # Optional (N downto M)
								([ \t]*--.*)?/ixm ) {
		    		#TODO: check if M <= N for
		    		my $mode = $2;
                    my $col = "::in";
		    		my %d = ( '::name' => $1,
				    # '::mode' => $2,
				    '::type' => $3,
                                   '::ign' => "",
                                    '::gen' => "",
                                    '::high' => "",
                                    '::low' => "",
                                    '::class' => "%IMPORT%" . uc( $inst ),
                                    '::clock' => "%IMPORT_CLK%" . uc( $inst ),
                                    '::bundle'  => "%IMPORT_BUNDLE%" . uc($inst) ,
			    	);
		    		if ( lc( $mode ) eq "in" ) {
						$d{'::mode'} = "%IMPORT_I%"; #TODO
		    		} elsif ( lc( $mode ) eq "out" ) {
						$col = "::out"; $d{'::mode'} = "%IMPORT_O%";
		    		} elsif ( lc( $mode ) eq "inout" ) {
						$d{'::mode'} = "IO";
		    		} elsif ( lc( $mode ) eq "buffer" ) {
						$d{'::mode'} = "B";
		    		} else {
						$logger->warn( '__W_PARSEHDL', "\tUnknown mode $mode in import" );
						$d{'::mode'} = "S";
		    		}
		    		$d{$col} = $inst . "/" . $1;
		    		$d{'::high'} = $5 if ( defined( $5 ) );
		    		$d{'::low'} = $8 if ( defined( $8 ) );
		    		if ( defined( $9 )){
		    			( $d{'::comment'} = $9 ) =~ s/^\s+//;
		    		}
		    		if ( $eh->get( 'import.generate' ) =~ m/\bstripio\b/io ) {
		    			$d{'::name'} =~ s/_(i|o|io)$//i;
		    		}
		    		# printf ( "#### Found port in instance $inst:\n" );
		    		# printf ( "\t%s %s\n" x scalar( keys( %d ) ), %d );
            		add_conn( %d );
            	}
	    	}
		}
		############## END of REWORK ################
} # End of _mix_parser_parseverilog
1;

#!End
