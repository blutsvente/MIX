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
# | Project:    Micronas - MIX / Parser                                   |
# | Modules:    $RCSfile: MixParser.pm,v $                                |
# | Revision:   $Revision: 1.37 $                                         |
# | Author:     $Author: abauer $                                         |
# | Date:       $Date: 2003/12/23 13:25:20 $                              |
# |                                                                       |
# | Copyright Micronas GmbH, 2002                                         |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/MixParser.pm,v 1.37 2003/12/23 13:25:20 abauer Exp $                                                         |
# +-----------------------------------------------------------------------+
#
# The functions here provide the parsing capabilites for the MIX project.
# Take a matrix of information in some well-known format and convert it into
# intermediate format and/or source code files
#

# +-----------------------------------------------------------------------+
# |
# | Changes:
# | $Log: MixParser.pm,v $
# | Revision 1.37  2003/12/23 13:25:20  abauer
# | added i2c parser
# |
# | Revision 1.36  2003/12/22 08:33:16  wig
# | Added output.generate.xinout feature
# |
# | Revision 1.35  2003/12/10 14:37:17  abauer
# | *** empty log message ***
# |
# | Revision 1.34  2003/12/10 10:17:33  abauer
# | *** empty log message ***
# |
# | Revision 1.33  2003/12/05 14:59:29  abauer
# | *** empty log message ***
# |
# | Revision 1.32  2003/12/05 11:49:43  abauer
# | added MixI2CParser.pm (basics)
# | added i2c sheet description (internal & doc)
# |
# | Revision 1.31  2003/12/04 14:56:31  abauer
# | corrected cvs problems
# |
# | Revision 1.30  2003/11/27 13:18:40  abauer
# | *** empty log message ***
# |
# | Revision 1.29  2003/11/27 09:08:56  abauer
# | *** empty log message ***
# |
# | Revision 1.28  2003/11/10 09:28:39  wig
# | Adding testcase for verilog: create dummy open wires
# |
# | Revision 1.27  2003/10/23 12:08:25  wig
# | added counter for macro evaluation cmacros
# |
# | Revision 1.25  2003/08/11 07:16:24  wig
# | Added typecast
# | Fixed Verilog issues
# |
# | Revision 1.24  2003/07/29 15:48:04  wig
# | Lots of tiny issued fixed:
# | - Verilog constants
# | - IO port
# | - reconnect
# |
# | Revision 1.22  2003/07/17 12:10:42  wig
# | fixed minor bugs:
# | - Verilog `define before module
# | - Verilog open
# | - signals(NN) in IO-Parser failed (bad reg-ex)
# |
# | Revision 1.20  2003/07/09 13:01:01  wig
# | Fixed mix_ioparse functions to get free programmanble pad cell naming,
# | dito. for iocells
# |
# | Revision 1.18  2003/06/05 14:48:01  wig
# | Releasing alpha IO-Parser
# |
# | Revision 1.17  2003/06/04 15:52:43  wig
# | intermediate release, before releasing alpha IOParser
# |
# | Revision 1.16  2003/04/29 07:22:36  wig
# | Fixed %OPEN% bit/bus problem.
# |
# | Revision 1.15  2003/04/28 06:40:37  wig
# | Added %OPEN% (to allow ports without connection, use VHDL open keyword)
# | Started parseIO (not operational, would be a branch instead)
# | Fixed nreset2 issue (20030424a bug)
# |
# | Revision 1.14  2003/04/01 14:27:59  wig
# | Added IN/OUT Top Port Generation
# |
# | Revision 1.13  2003/03/24 13:04:45  wig
# | Extensively tested version, fixed lot's of issues (still with busses and bus splices).
# |
# | Revision 1.11  2003/03/13 14:05:19  wig
# | Releasing major reworked version
# | Now handles bus splices much better
# |
# | Revision 1.10  2003/02/28 15:03:44  wig
# | Intermediate version with lots of fixes.
# | Signal issue still open.
# |
# | Revision 1.9  2003/02/21 16:05:14  wig
# | Added options:
# | -conf
# | -sheet
# | -listconf
# | see TODO.txt, 20030220/21
# |
# | Revision 1.8  2003/02/20 15:07:13  wig
# | Fixed: port signal assignment direction bus
# | Capitalization (folding is still missing)
# | Added ::arch column and created output
# |
# | Revision 1.7  2003/02/19 16:28:00  wig
# | Added generics.
# | Renamed generated objects
# |
# | Revision 1.6  2003/02/14 14:06:43  wig
# | Improved add port handling, consider in/out/... cases
# | Entitiy port/signals redeclaration prevented
# |
# | Revision 1.5  2003/02/12 15:40:47  wig
# | Improved handling of bus splicing (but still a way to go)
# | Added seom meta instances.
# |
# | Revision 1.4  2003/02/07 13:18:45  wig
# | no changes
# |
# | Revision 1.3  2003/02/06 15:48:31  wig
# | added constant handling
# | rewrote bit splice handling
# |
# | Revision 1.2  2003/02/04 07:19:31  wig
# | Fixed header of modules
# |
# |
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
      mix_p_updateconn
      mix_p_retcprop
      add_portsig
      add_sign2hier
      parse_mac
      purge_relicts
      mix_parser_importhdl
      );            # symbols to export by default
  @EXPORT_OK = qw(
      %hierdb
      %conndb
    );         # symbols to export on request
  # %EXPORT_TAGS = tag => [...];

# @Micronas::MixParser::ISA=qw(Exporter);
# @Micronas::MixParser::EXPORT=qw(
# );
# @Micronas::MixUtils::EXPORT_OK=qw(
# );

our $VERSION = '0.01';

use strict;
use vars qw( %hierdb %conndb );

# Caveat: relies on proper setting of base, pgmpath and dir in main program!
use lib "$main::base/";
use lib "$main::base/lib/perl";
use lib "$main::pgmpath/";
use lib "$main::pgmpath/lib/perl";
use lib "$main::dir/lib/perl";
use lib "$main::dir/../lib/perl";

# use lib 'h:\work\x2v\lib\perl'; #TODO Rewrite that !!!!
use Log::Agent;
use Log::Agent::Priorities qw(:LEVELS);
use Tree::DAG_Node; # tree base class
use Regexp::Common; # Needed for import/init functions: parse VHDL ...

use Micronas::MixUtils qw( mix_store db2array mix_list_econf %EH replace_mac );
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

####################################################################
#
# Our global variables
#  hierdb <- hierachy
#  conndb <- connection matrix
%hierdb       = ();
%conndb     = ();

####################################################################
#
# Our local variables
my $const   = 0; # Counter for constants name generation

#
# RCS Id, to be put into output templates
#
my $thisid		=	'$Id: MixParser.pm,v 1.37 2003/12/23 13:25:20 abauer Exp $';
my $thisrcsfile	=	'$RCSfile: MixParser.pm,v $';
my $thisrevision   =      '$Revision: 1.37 $';

# | Revision:   $Revision: 1.37 $
$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?


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
        logdie( "FATAL: Undefined or empty input argument for parse_conn_macros!\n" );
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
    logtrc( "INFO", "Found $n macro definitions" );

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
        logdie("FATAL: bad input argument for check_conn_macros\n");
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
            if ( $f{$ii} !~ m/^$/o and $ii !~ /^::(comment|descr|gen|ign)/io ) {
                # Only non-empty cells are of interest, and do not match comment, descr, ...
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
                    logwarn("variable $t{$vars{$ii}[$iii]} redefined in macro key $ii (macro nr. $i)!");
                    $EH{'sum'}{'warnings'}++;
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
                        logwarn("Variable $1 used in macro definition for macro nr. $i undefined!");
                        $r_m->[$i]{'me'} .= "\$mex{'" . $1 . "'} = \"E_UNDEFINED_VAR\"; ";
                    }
                }
                $r_m->[$i]{'md'}[$ii]{$iii} =~ s/\$(\w)/\$mex{'$1'}/g;
            }
        }
    }
    return;
}

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
        logdie("FATAL: Bad input argument for check_conn_macros\n");
    }

    for my $i ( 0..$#{$r_m} ) {
        unless ( defined( $r_m->[$i]{'mh'} )  ) {
            logwarn("ERROR: macro header missing $i");
            $EH{'sum'}{'errors'}++;
            next;
        }
        unless ( defined( $r_m->[$i]{'md'} ) and $#{$r_m->[$i]{'md'}} >= 0 ) {
            logwarn("ERROR: macro definition missing $i");
            $EH{'sum'}{'errors'}++;
            next;
        }
        push( @m, $r_m->[$i] );
    }

    return @m;

}

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

=back

It returns a hash, key is the instance name perl regular expression match.
Right now this function can be used for both CONN and HIER matrix.

=cut

sub parse_conn_gen ($) {
    my $rin = shift;

    my $gi = 0;
    unless( defined $rin ) {
        logdie "FATAL: parse_conn_gen called with bad argument\n";
        exit 1;
    }

    my %g = ();
    for my $i ( 0..$#{$rin} ) {

        next unless ( $rin->[$i] ); # Holes in the array?
        next if ( $rin->[$i]{'::comment'} =~ m,\s*(#|//),o );   # Commented out
        next if ( $rin->[$i]{'::gen'} =~ m,^\s*$, );                # Empty

        # CONN vs. HIER: Strip and remember leading CONN .
        #wig20030715
        my $namesp = "hier";
        if ( $rin->[$i]{'::gen'} =~ s!^\s*(HIER|CONN)[\s,]*!!io ) {
            $namesp = lc( $1 );
        }

        # iterator based generator: $i(1..10), /PERL_RE/
        if ( $rin->[$i]{'::gen'} =~ m!^\s*\$(\w)\s*\((\d+)\.\.(\d+)\)\s*,\s*/(.*)/! ) {
            my $pre = $4 . "_$2_$3";
            if ( $2 > $3 ) {
                logwarn("WARNING: __E_BAD_BOUNDS $2 .. $3 in generator definition!");
                $EH{'sum'}{'errors'}++;
                next;
            }
            if ( exists( $g{$pre} ) ) { # Redefinition of this macro ...make name unique
                $g{$pre}{'rep'}++;
                $pre .= "__DUPL__" . $gi++;
            }
            $g{$pre}{'pre'} = $4;
            $g{$pre}{'var'} = $1;
            $g{$pre}{'lb'}   = $2;
            $g{$pre}{'ub'}  = $3;
            $g{$pre}{'field'} = $rin->[$i];
            $g{$pre}{'ns'} = $namesp;
            $rin->[$i]{'::comment'} = "# Generator parsed /" . $rin->[$i]{'::comment'};
        }
        # plain generator: /PERL_RE/
        elsif ( $rin->[$i]{'::gen'} =~ m!^\s*/(.*)/! ) {
            my $tag = $1;
            if ( exists( $g{$tag} ) ) { # Redefinition of this macro ... make name unique
                $g{$tag}{'rep'}++;
                $tag .= "__DUPL__" . $gi++;
            }
            $g{$tag}{'var'} = undef;
            $g{$tag}{'lb'}   = undef;
            $g{$tag}{'ub'}  = undef;
            $g{$tag}{'pre'} = $1;
            $g{$tag}{'field'} = $rin->[$i];
            $g{$tag}{'ns'} = $namesp;
            $rin->[$i]{'::comment'} = "# Generator parsed /" . $rin->[$i]{'::comment'};
        }
        # parameter generator: $i (1..10)
        # no /match/ .....
        elsif ( $rin->[$i]{'::gen'} =~ m!^\s*\$(\w)\s*\((\d+)\.\.(\d+)\)!o ) {
            my $gname = "__MIX_ITERATOR_" . $gi++;
            $g{$gname}{'var'} = $1;
            $g{$gname}{'lb'} = $2;
            $g{$gname}{'ub'} = $3;
            $g{$gname}{'field'} = $rin->[$i];
            $g{$gname}{'pre'} = $gname;
            $g{$gname}{'ns'} = $namesp;
            $rin->[$i]{'::comment'} = "# Generator parsed /" . $rin->[$i]{'::comment'};
        }
    }

    #
    # Todo: do more sanity checks ... e.g. allowed characters, fields ...
    # but most of that can be relayed to later
    #
    return \%g;

}

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
        logdie( "FATAL: parse_hier called with bad arguments!\n" );
        exit 1;
    }

    #
    # Add all instances left in the input data
    #
    for my $i ( 0..$#{$r_hier} ) {
        next unless ( $r_hier->[$i] ); # Skip if input field is empty
        next if ( $r_hier->[$i]{'::ign'} =~ m,^(#|//),o );
        next if ( $r_hier->[$i]{'::gen'} !~ m,^\s*$,o );
        # Add more "go away" here if needed

        #
        # Early name expansion required for primary key ::inst
        #
        if ( $r_hier->[$i]{'::inst'} =~ m/^\s*%(::\w+?)%/o ) {
            my $name = $r_hier->[$i]{'::inst'};
            if ( defined( $r_hier->[$i]{$1} ) ) {
                $name =~ s/%(::\w+?)%/$r_hier->[$i]{$1}/g; # replace %::key% ...
                #
                #TODO: multiple replacements could lead to troubles!
                #    and it will not work recursive !!
                $r_hier->[$i]{'::inst'} = $name;
            } else {
                logwarn( "ERROR: Cannot replace %::inst% for $name!" );
                $EH{'sum'}{'errors'}++;
            }
        }
        add_inst( %{$r_hier->[$i]} );

    }

    #
    # Add some meta instances: %TOP%, %CONST%, %OPEN%
    # These are needed for proper program flow.
    #
    add_inst( '::inst' => "%CONST%", );
    add_inst( '::inst' => "%GENERIC%", );
    add_inst( '::inst' => "%PARAMETER%", );

    add_inst( '::inst' => "%TOP%", );
    add_inst( '::inst' => "%OPEN%", );

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

    unless ( exists( $in{'::inst'} ) and defined( $in{'::inst'} ) ) {
        logwarn( "WARNING: try to create instance without name!" );
        return;
    }

    my $name = mix_expand_name( 'inst', \%in ); # Expand names with %foobar% inside ..

    $name = mix_check_case( 'inst', $in{'::inst'} ); # Get appropriate name and fix it if flag is set

    if ( defined( $hierdb{$name} ) ) {
        # Alert user if this connection already got defined somewhere ....
        if ( $EH{'check'}{'defs'} =~ m,inst, ) {# Warning, another line adding to this inst.
            logwarn( "WARNING: redefinition of instance $name!" );
            $EH{'sum'}{'uniq'}++;
        }
        merge_inst( $name, %in );
    } else {
        create_inst( $name, %in );
        $EH{'sum'}{'inst'}++;
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
    #
    # Early name expansion required for primary keys (like ::inst)
    #
    while ( $n =~ m/%((::)?\w+?)%/g ) {
        my $key = $1;
        next if  $key =~ m,^(TOP|PARAMETER|OPEN|GENERIC|CONST|LOW|HIGH|LOW_BUS|HIGH_BUS)$,o;
        if ( defined( $rdata->{$key} ) ) {
                $n =~ s/%$key%/$rdata->{$key}/g; # replace %::key% ...
                #
                #TODO: multiple replacements could lead to troubles!
                #    and it will not work recursive !!
                #
        } elsif ( defined( $EH{'postfix'}{$key} ) ) {
            $n =~ s/%$key%/$EH{'postfix'}{$key}/g; # replace %::key% -> EH
        } elsif ( defined( $EH{'macro'}{'%' . $key . '%'} ) ) {
            $n =~ s/%$key%/$EH{'macro'}{'%' . $key .'%'}/g; # replace %::key% -> EH
        }else {
                logwarn( "ERROR: Cannot replace %$key% in name $n!" );
                $EH{'sum'}{'errors'}++;
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

    my $ehr = $EH{'hier'}{'field'};
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

    my $ehr = $EH{'hier'}{'field'};

    # Prevent redefinition!
    if ( defined( $r_h->{'::treeobj'} ) ) {
        logwarn("Tree node for element $name already created!");
        return;
    }

    #
    # Build tree
    # we can rely on the fact that this hierachy element was never seen before ...
    #TODO: store all attributes in tree object, instead of hierdb ...
    my $node = Tree::DAG_Node -> new;
    $node->name($name);
    $r_h->{'::treeobj'} = $node; # store object reference!

    my $parent = "W_NO_PARENT";
    if ( defined( $r_h->{'::parent'} ) and $r_h->{'::parent'} ) {
        # If the parent is already defined, link this instance to the parent, else create a parent node
        $parent = $r_h->{'::parent'};
    }

    #!wig20030404: Caseing ...
    $parent = mix_check_case( "inst", $parent);

    if ( defined( $hierdb{$parent} ) and $hierdb{$parent} ) {
            $hierdb{$parent}{'::treeobj'}->add_daughter( $node);
    } else {
            my $parnode = Tree::DAG_Node -> new;
            $parnode->name($parent);
            $hierdb{$parent}{'::treeobj'} = $parnode;
            $parnode->add_daughter($node);
            # Initialize empty module:
            for my $i ( keys %$ehr ) {
                    next unless ( $i =~ m/^::/ );
                    $hierdb{$parent}{$i} = $ehr->{$i}[3]; # Set to DEFAULT Value
                    #TODO: Initialize fields to empty / Marker, set DEFAULT if still empty at end 
                    $hierdb{$parent}{$i} =~ s/%NULL%//g; # Just to make sure fields are initialized
            }
            $hierdb{$parent}{'::inst'} = $parent; # Set parent name
            $hierdb{$name}{'::parent'} = $parent; # Set name for parent of this
    }
}

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
    my $parent = ""; # Start with empty parent name
    if ( defined( $data{'::parent'} ) ) {
        $parent = mix_check_case( 'inst', $data{'::parent'} );
        $data{'::parent'} = $parent; # Rewrite input data ...
    }

    #
    # Tree check: Check it parent changed ...
    #
    if ( defined( $parent ) and $parent
        and defined( $hierdb{$name}{'::parent'} and $hierdb{$name}{'::parent'} ) ) {
        if (
            $parent ne $EH{'hier'}{'field'}{'::parent'}[3] and
            $parent ne $hierdb{$name}{'::parent'} ) {
                logwarn( "Debug: Change parent for cell $name to $parent from $hierdb{$name}{'::parent'}" )
                    unless( $hierdb{$name}{'::parent'} eq $EH{'hier'}{'field'}{'::parent'}[3] );
                my $node = $hierdb{$name}{'::treeobj'};
                # If parent is already defined -> change it ...
                unless ( exists( $hierdb{$data{'::parent'}} ) ) {
                    logwarn( "Autocreate parent for $name: $parent" );
                    create_inst( $parent, () );
                }
                my $pnode = $hierdb{$parent}{'::treeobj'};
                $pnode->add_daughter( $node );
        }
    }
    #
    # Overwrite hierdb if fields are zero or space ....
    #
    #TODO: Check if order matters here ..
    for my $i ( keys( %data ) ) {
        #TODO: Trigger merge mode for special cases where we want to add
        # up data instead of overwrite
        # e.g. add a filed defining concatenate/overwrite/array/noover/... mode
        # Here we implement:
        # If the field already exists and has a contents
        # AND EH has a value for that field AND
        # the field differs from the default value, do nothing.
        # Else fill in the field with the input data
        if ( defined( $hierdb{$name}{$i} ) and
            $hierdb{$name}{$i} ne "" ) {
            if ( defined( $EH{'hier'}{'field'}{$i} ) and exists( $EH{'hier'}{'field'}{$i} ) and
		 ( $hierdb{$name}{$i} ne $EH{'hier'}{'field'}{$i}[3] ) ) { # Leave that value ....
		logtrc("INFO", "field $i for $name already filled");
            } else {
		if ( $data{$i} ne "" ) { $hierdb{$name}{$i} = $data{$i} };
            }
        } else {
        # Overwrite data ??? Is that always the rigth way to go
            if ( $data{$i} ) {
                $hierdb{$name}{$i} = $data{$i};
            }
        }
    }
    return;
}

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
        logdie( "FATAL: parse_conn_init called with bad arguments!\n" );
        exit 1;
    }

    my $ehr = $EH{'conn'}{'field'};

    for my $i ( 0..$#{$r_conn} ) {
        # Skip comment lines
        #TODO: allow to pass such lines through ..
        next if ( $r_conn->[$i]{'::ign'} =~ m,^\s*(#|//),o );
        # Skip generator lines
        next if ( $r_conn->[$i]{'::gen'} !~ m,^\s*$,o ); #Is that really true

        add_conn( %{$r_conn->[$i]} );
    }

    #
    # Add some internal/meta signals:
    #

    # add_conn( '::name' => "%DUMMY%", );

}

sub add_conn (%) {
        my %in = @_;

        my $name = $in{'::name'};
        my $nameflag = 0;

        #
        # strip of leading and trailing whitespace
        #
        $name =~ s/^\s+//o;
        $name =~ s/\s+$//o;

        #
        # Special handling: open -> %OPEN%
        if ( $name =~ m,^open$,i ) {
            $name = "%OPEN%";
        }

        $in{'::name'} = $name;
        #
        # name must be defined:
        # if not, assume that could be a generated name, check later on
        #
        if ( $name eq "" ) {
            # Handle CONSTANTS ..either set in input or derived by detecting constants in ::out
            # Generate a name
                $nameflag = 1;
                $name = $EH{'postfix'}{'PREFIX_CONST'} . $EH{'CONST_NR'}++;
                $in{'::name'} = $name;
                logwarn( "INFO: Creating name $name for constant!" );
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
        #TODO: allow %macro% and ::macro, only!
        #
        if ( $name =~ m/[^0-9A-Za-z_%:]/ ) {
            # Mark signal .... but add it anyway (user should be able to fix it)
            logwarn( "Illegal signal name $name. Will be ignored!" );
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
                #TODO: multiple replacements could lead to troubles!
                #
                $in{'::name'} = $name;
            } else {
                logwarn( "Cannot replace ::name for $name!" );
                $EH{'sum'}{'warnings'}++;
            }
        }

        if ( defined( $conndb{$name}  ) ) {
            # Alert user if this connection already got defined somewhere ....
            if ( $EH{'check'}{'defs'} =~ m,conn, ) {
                logwarn( "WARNING: redefinition of conection $name!" );
                $EH{'sum'}{'uniq'}++; # Not uniq warning!!
            }
            merge_conn( $name, %in );
        } else {
            create_conn( $name, %in);
            #now in create_conn: $EH{'sum'}{'conn'}++;
        }

        # If name was not given, complain ...
        if ( $nameflag and $conndb{$name}{'::mode'} !~ m/^\s*[CPG]/o ) {
            # Check if this signals ::out has a %CONST% in it:
            # If yes, mark it as C
            unless( $conndb{$name}{'::out'}[0]{'inst'} eq "%CONST%" ) {
                # Mark signal .... but add it anyway (user should be able to fix it)
                #TODO: fix up that code, should not deal with conndb here ....
                logwarn( "Missing signal name in input. Generated name $name!" );
                $conndb{$name}{'::ign'} = "#__E_MISSING_SIGNAL_NAME";
                $conndb{$name}{'::comment'} = "#__E_MISSING_SIGNAL_NAME" . $conndb{$name}{'::comment'};
                $conndb{$name}{'::name'} = $name;
            } else {
                $conndb{$name}{'::mode'} = 'C';
            }
        # Is it linked to %CONST% instance ...
        } elsif ( defined( $conndb{$name}{'::out'}[0]{'inst'} ) and
            $conndb{$name}{'::out'}[0]{'inst'} eq "%CONST%" ) {
                # If we found a constant, change the ::mode bit to be constant ...
                if ( $conndb{$name}{'::mode'} and $conndb{$name}{'::mode'} !~ m,^\s*[CPG],io ) {
                    logwarn("Signal $name mode expected to be C, G or P but is " .
                            $conndb{$name}{'::mode'} ."!" );
                    $conndb{$name}{'::mode'} = "C";
                    $conndb{$name}{'::comment'} .= "__E_MODE_MISMATCH";
                } elsif ( not $conndb{$name}{'::mode'} ) {
                    # If this signal mode is not defined, assume C
                    logtrc( "INFO", "Setting mode to C for signal $name\n" );
                    $conndb{$name}{'::mode'} = "C";
                    $conndb{$name}{'::comment'} .= "__I_SET_MODE_C";
                }
        }
}


sub create_conn ($%) {
    my $name = shift;
    my %data   = @_;

    my $ehr = $EH{'conn'}{'field'};

    for my $i ( keys %$ehr ) {
        next unless ( $i =~ m/^::/ );
        # ::in and ::out are special case; split if it contains s.th.
        if ( $i =~ m/^::(in|out)$/o ) {
            if ( defined( $data{$i} ) and $data{$i} ne "" ) {#Bugfix20030212: create_conn if field defined ...
                $conndb{$name}{$i} = _create_conn( $1, $data{$i}, %data );
            } else {
                $conndb{$name}{$i} = []; #Initialize empty array. Will be removed later on
            }
        } elsif ( defined( $data{$i} ) ) {
            $conndb{$name}{$i} = $data{$i};
        } else {
            $conndb{$name}{$i} = $ehr->{$i}[3]; # Set to DEFAULT Value
            #TODO: Initialize fields to empty / Marker, set DEFAULT if still empty at end 
        }
        #TODO: Remove this ....
        #wig20030801
        $conndb{$name}{$i} =~ s/%NULL%/$EH{'macro'}{'%NULL%'}/g; # Just to make sure fields are initialized
        $conndb{$name}{$i} =~ s/%EMPTY%/$EH{'macro'}{'%EMPTY%'}/g; # Just to make sure fields are initialized
        delete( $data{$i} );
    }

    #
    # Add the rest, too
    #
    for my $i( keys( %data ) ) {
        $conndb{$name}{$i} = $data{$i};
    }

    # Give each signal a unique number: starting from 0 ...
    $conndb{$name}{'::connnr'} = $EH{'sum'}{'conn'}++;
}

####################################################################
## _create_conn
## create/add/modify a bus/signal/connection from the ::in/::out field
####################################################################

=head2

_create_conn ($$%)

Create/add/modify a bus/signal/connection; convert input into simple array of hashes.

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

=cut

sub _create_conn ($$%) {
    my $inout = shift;
    my $instr = shift;
    my %data = @_;

    #A bus with ::low and ::high
    my $h = undef;
    my $l = undef;
    my $hldigitflag = 0; # Assume ::high and ::low are no digits!

    #TODO: check bus definitions better!
    if ( defined( $data{'::low'} ) and defined ( $data{'::high'} ) ) {
        #    if ( $data{::low} <= $data{::high} ) {
        #        # This ia a bus ...
        $data{'::low'} =~ s,^\s+,,; # Remove leading white-space
        $data{'::high'} =~ s,^\s+,,; # Remove leading white-space

        if ( $data{'::high'} ne "" ) {
            unless ( $data{'::high'} =~ /^\d+$/ ) {
                logtrc( "INFO", "Bus $data{'::name'} upper bound $data{'::high'} not a number!" );
                $hldigitflag = 0;
            } else {
                $hldigitflag++;
            }
            $h = $data{'::high'}; # ::high can be string, too ...
        }
        if ( $data{'::low'} ne "" ) {
            unless ( $data{'::low'} =~ /^\d+$/ ) {
                logtrc( "INFO", "Bus $data{'::name'} lower bound $data{'::low'} not a number!" );
                $hldigitflag = 0;
            } else {
                $hldigitflag++;
            }
            $l = $data{'::low'};
        }
        if ( defined( $h ) and defined( $l ) and $hldigitflag == 2 and $h < $l ) {
            logwarn( "WARNING: _create_conn for " . $data{'::name'} .
                     ": unusual bus ordering $h downto $l" );
            $EH{'sum'}{'warnings'}++;
        }
    }
    #    else {
    #        logwarn( "ERROR", "Error: wrong bounds on signal $data{::name}!");
    #        return;
    #    }
    my %co = ();
    my @co = ();
    unless( defined( $instr ) and $instr ne "" ) {
        logwarn("Called _create_conn without data for $inout");
        return \@co; #Return dummy array, just in case
    }

    # Allow , and ; in in/out columns
    $instr =~ s/\n/,/go;
    for my $d ( split( /[,;]/, $instr ) ) {
        next if ( $d =~ /^\s*$/o );
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
            #

            $d =~ s,^\s+,,o; # Remove leading whitespace
            $d =~ s,\s+$,,o; # Remove trailing whitespace
            $d =~ s,%::,%##,og; # Mask %:: ... vs. N:N

            #
            # Recognize 0xHEX, 0OCT, 0bBIN and DECIMAL values in ::out
            # Also: 10.2, 1_000_000, 16#hex#, 2#binary_binary#, 2.2e-6 10ns 2.27[mnfpu]s
            # Recognize 'CONST' and "CONST"
            # Mark with %CONST% instance name .... the port name will hold the value
            # Force anything following %CONST%/ to be a constant value
            $d =~ s,__(CONST|GENERIC|PARAMTER)__,%$1%,g; # Convert back __CONST__ to %CONST%
            if (
                # Get VHDL constants : B#VAL#
                $d =~ m,^(%(CONST|GENERIC|PARAMETER)%/)?(\d+#[_a-f\d]+#)\s*$,io or
                # or 0xHEX or 0b01xzhl or 0777 or 1000 (integers)
                $d =~ m,^(%(CONST|GENERIC|PARAMETER)%/)?(0x[_\da-f]+|0b[_01xzhl]+|0[_0-7]+|[\d][._\d]*)\s*$,io or
                # or reals or time definitions: ... 1 ns, 1.3 ps ...
                $d =~ m,^(%(CONST|GENERIC|PARAMETER)%/)?([+-]*[_\d]+\.*[_\d]*(e[+-]\d+)?\s*([munpf]s)?)\s*$,io or
                # or anything in ' text ' or " text "
                $d =~ m,^(%(CONST|GENERIC|PARAMETER)%/)?((['"]).+\4)\s*$,io or
                # $d =~ m,^(%(CONST|GENERIC|PARAMETER)%/)?(".+")\s*$,io or
                # or anything following a %CONST%/ or GENERIC or PARAMETER keyword
                $d =~ m,^(%(CONST|GENERIC|PARAMETER)%/)(.+)\s*,io
                ) { # Constant value ...
                my $const = $3;
                $co{'rvalue'} = $const; # Save raw value!!
                my $t = $2;
                if ( $inout =~ m,in, ) {
                    logerr("ERROR: illegal constant value for ::in signal " . $data{'::name'} . "!");
                    $data{'::comment'} .= "__E_BAD_CONSTANT_DEFINED";
                    $EH{'sum'}{'errors'}++;
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
                $const =~ tr/'/"/; # Convert ' to " (otherwise ExCEL will eat it).

                $co{'port'} = $const; # Decimal base or literal
                # Inherit bus width from signal definition ....
                $co{'port_f'} = $h;
                $co{'port_t'} = $l;
                $co{'sig_f'} = $h;
                $co{'sig_t'} = $l;
                $co{'value'} = $const;

                push( @co, { %co } );
                #TODO: $mode = 'C'; # Autochange ::mode to constant
                next;

            }

            #
            # Port and signal names and bounds may be composed of
            # \w   alphanumeric and _
            # %   marker for macros
            # :    part of macro like %::name%
            #

            #
            # Normal inst/ports ....
            #
            #wig20030801: typecast port'cast_func ...
            if ( $d =~ m,(/?'(\w+)), ) { # Get typecast   inst/port'cast or inst/'cast
                $co{'cast'} = $2;
                $d =~ s,$1,,;
            }

            $d =~ s/\(([\w%#]+)\)/($1:$1)/g; # Extend (N) to (N:N)

            if ( $d !~ m,/,o ) { # Add signal name as port name by default
                $d =~ s,([\w%:#]+),$1/%::name%,;
            }

            if ( $d =~ m,([\w%#]+)/(\S+)\(([\w%#]+):([\w%#]+)\)\s*=\s*\(([\w%#]+):([\w%#]+), ) {
                # INST/PORTS(pf:pt)=(sf:st)
                $co{'inst'} = $1;
                $co{'port'} = $2;
                $co{'port_f'} = $3;
                $co{'port_t'} = $4;
                $co{'sig_f'} = $5;
                $co{'sig_t'} = $6;
            } elsif ( $d =~ m,([\w%#]+)/(\S+)=\(([\w%#]+):([\w%#]+)\)\s*, ) {
                # INST/PORTS=(f:t) Port-Bit to Bus-Bit f = t; expand to pseudo bus?
                #TODO: Implement better solution (e.g. if Port is bus slice, not bit?
                #wig20030207: handle single bit port connections ....
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
                    if ( $4 ne "0" ) {
                        # Wire port of width
                        logwarn("Automatically wiring signal bits $3 to $4 of $1/$2 to bits " . ( $3 - $4 ) . " to 0");
                        my $f = $3;
                        my $t = $4;
                        if ( $f =~ m,^(\d+)$,o and $t =~ m,^(\d+)$,o ) {
                            $co{'port_f'} = $f - $t;
                            $co{'port_t'} = 0;
                        } else {
                            #TODO: Needs to be checked ... autowiring does not work here!
                            $co{'port_f'} = "$f - $t";
                            $co{'port_t'} = 0;
                        }
                    } else {
                        $co{'port_f'} = $3; # - $4 ;
                        $co{'port_t'} = 0;
                    }
                }
            } elsif ( $d =~ m,([\w%#]+)/(\S+)\(([\w%#]+):([\w%#]+)\)\s*, ) {
                # INST/PORTS(f:t)
                $co{'inst'} = $1;
                $co{'port'} = $2;
                $co{'port_f'} = $3;
                $co{'port_t'} = $4;
                if ( $4 ne "0" ) {
                    my $f = $3;
                    my $t = $4;
                    if ( $t =~ m,^(\d+)$,o and $f =~ m,^(\d+)$,o ) {
                        $co{'sig_f'} = $f - $t;
                        $co{'sig_t'} = 0;
                    } else {
                        $co{'sig_f'} = "$f - $t"; #TODO: Is that a good idea?
                        $co{'sig_t'} = 0;
                    }
                } else {
                    $co{'sig_f'} = $3;
                    $co{'sig_t'} = 0;
                }
            } elsif ( $d =~ m,([\w%#]+)/(\S+)\s*, ) {
                # INST/PORTS
                $co{'inst'} = $1;
                $co{'port'} = $2;
                $co{'port_f'} = $h;
                $co{'port_t'} = $l;
                $co{'sig_f'} = $h;
                $co{'sig_t'} = $l;
            } elsif ( $d =~ m,([\w%#]+), ) {
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

            check_conn_prop( \%co );

            push( @co, { %co } );
    }
    return ( \@co );
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
        logwarn( "Unusual character in signal name: $ref->{'inst'}/$ref->{'port'}!" );
    }
    if ( $ref->{'port'} !~ m,^[:%\w]+$,o ) {
        logwarn( "Unusual character in port name: $ref->{'inst'}/$ref->{'port'}!" );
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
        logwarn( "ERROR: Cannot update connection $name!" );
        $EH{'sum'}{'errors'} ++;
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
sub merge_conn($%) {
    my $name = shift;
    my %data = @_;

    #
    # Overwrite conndb if fields are zero or space ....
    #
    #TODO: Check if order matters here ..
    for my $i ( keys( %data ) ) {
        #TODO: Trigger merge mode for special cases where we want to add
        # up data instead of overwrite
        if ( $i =~ /^::(in|out)$/ ) { #TODO: should we write ::\s*::(in|out) instead
            if ( $data{$i} ) {
                # Add array to in/out field, if the cell contains data
                push( @{$conndb{$name}{$i}} , @{_create_conn( $1, $data{$i}, %data )});
            }
        } elsif ( $i =~ /^::type/ ) {
            #
            # ::type requires special handling
            # Complain if ::type does not match
            #
            if ( $conndb{$name}{$i} and
                 $conndb{$name}{$i} !~ m,%(SIGNAL|BUS_TYPE)%,o and
                 $conndb{$name}{'::name'} ne "%OPEN%" ) {
                # conndb{$name}{::type} is defined and ne the default
                 if ( $data{$i} and $data{$i} !~ m,%(SIGNAL|BUS_TYPE)%,o ) {
                    my $t_cdb = $conndb{$name}{$i};
                    if ( $data{$i} ne $t_cdb ) { #TODO: and $name !~ m/%(HIGH|LOW)/o ) {
                        # %HIGH% and %LOW% signal will get type assigned
                        logwarn( "ERROR: type mismatch for signal $name: $t_cdb ne $data{$i}!" );
                        $conndb{$name}{$i} = "__E_TYPE_MISMATCH";
                        $conndb{$name}{'::comment'} .= "#__E_TYPE: $t_cdb ne $data{$i} ";
                        $EH{'sum'}{'errors'}++;
                    }
                } # else leave conndb as is
            } else {
                # ::type was not set so far, therefore we overwrite if the input data has type defined
                if ( $data{$i} ) {
                    $conndb{$name}{$i} = $data{$i};
                }
            }
        } elsif ( $i =~ /^\s*::mode/o ) {
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
                            logwarn( "ERROR: mode mismatch for signal $name: $t_cdb ne $data{$i}!" );
                            $EH{'sum'}{'errors'}++;
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
        } elsif ( $i =~ /^\s*::(high|low)/o ) {
            if ( defined($conndb{$name}{$i}) and $conndb{$name}{$i} ne '' ) {
                # There was already s.th. defined for this bus
                if ( defined( $data{$i} ) and $data{$i} ne '' and $conndb{$name}{$i} ne $data{$i} ) {
                    # LOW and HIGH "signals" are special.
                    if ( $name =~ m,^\s*%(LOW|HIGH)_BUS%,o ) { # Accept larger value for upper bound
                        if ( $i =~ m,^\s*::high,o ) {
                            $conndb{$name}{$i} = $data{$i} if ( $data{$i} > $conndb{$name}{$i} );
                        } elsif ( $i =~ m,^\s*::low,o ) {
                            $conndb{$name}{$i} = $data{$i} if ( $data{$i} < $conndb{$name}{$i} );
                        }
                    } elsif ( $name =~ m,^\s*%OPEN%,o ) {
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
                        logwarn( "ERROR: bound mismatch for signal $name: $conndb{$name}{$i} ne $data{$i}!");
                        $EH{'sum'}{'errors'}++;
                        $conndb{$name}{$i} = "__E_BOUND_MISMATCH";
                    }
                }
            } else {
                $conndb{$name}{$i} = $data{$i};
            }
        } elsif ( $i =~ /^\s*::(gen|comment|descr)/o ) {
            # Accumulate generator infos, comments and description
            if ( $data{$i} and $data{$i} ne '%EMPTY%' ) {
                #wig20031106: try to keep comments short ....
                #   check if $data{$i} is part of $conndb{$name}{$i}
                my $pos = rindex( $conndb{$name}{$i}, $data{$i} );
                if ( $pos >= 0 and $EH{'output'}{'generate'}{'fold'} =~ m,signal,io ) {
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
            #TODO: Get that information from %EH ....
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

Save intermediate connection and hierachy data into disk.
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
        $dumpfile = $EH{'out'};
    }

    if ( $dumpfile eq "dump" ) {
        $dumpfile = $EH{'dump'};
    }

    if ( $type eq "auto" ) {
        # Derive output format from output name extension
        if ( $dumpfile =~ m,\.(xls|sxc|csv)$, ) {
                $type=$1;
        } else {
        # Default to "internal" format
                $type="internal";
        }
    }

    if ( $type eq "xls" || $type eq "sxc" || $type eq "csv") {
        my $aro = mix_list_econf( "xls" ); # Convert %EH to two-dim array
        my $arc = db2array( \%conndb , "conn", "" );
        my $arh = db2array( \%hierdb, "hier", "^(%\\w+%|W_NO_PARENT)\$" );
        if ( $EH{'output'}{'generate'}{'delta'} ) {
            my $conf_diffs = write_outfile( $dumpfile, "CONF", $aro ); # Do not generate deltas, just output
            my $conn_diffs = write_delta_sheet( $dumpfile, "CONN", $arc );
            my $hier_diffs = write_delta_sheet( $dumpfile, "HIER", $arh );
            $EH{'DELTA_INT_NR'} = $conn_diffs + $hier_diffs;
        } else {
            write_outfile( $dumpfile, "CONF", $aro ); #wig20030708: store CONF options ...
            write_outfile( $dumpfile, "CONN", $arc );
            write_outfile( $dumpfile, "HIER", $arh );
        }
        if($EH{'intermediate'}{'strip'}) {
	    clean_temp_sheets($EH{'out'});
	}
	close_open_workbooks(); # Close everything we opened
    } else {
        if ( $type ne "internal" ) {
            $type="intermediate";
        }
        mix_store( $dumpfile, { 'conn' => \%conndb , 'hier' => \%hierdb,
                                    %$varh
                            }, $type);
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
        $dumpfile = $EH{'dump'};
    }

    unless( -r $dumpfile ) {
        log_error( "Cannot read dump file $dumpfile!\n" );
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

    #TODO: if ( $type eq "xls" ) {
    #    my $arc = db2array( \%conndb , "conn" );
    #    my $arh = db2array( \%hierdb, "hier" );
    #    write_outfile( $dumpfile, "CONN", $arc );
    #    write_outfile( $dumpfile, "HIER", $arh );
    #} else {
        mix_load( $dumpfile,
            { 'conn' => \%conndb , 'hier' => \%hierdb   }
                  );
    # }
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
                    $xre .= $r_cm->[$ii]{'mo'}[$iii] . "::";
                    $xre .= $r_in->[$i]{$r_cm->[$ii]{'mo'}[$iii]};
                }
                if ( $xre =~ /$r_cm->[$ii]{'mm'}/ ) {
                    # Got it .... catch matched variables and apply to MX line ...
                    logtrc("INFO", "Macro $ii matches here");
                    $EH{'sum'}{'cmacros'}++;
                    my %mex = ();
                    # Gets matched variables
                    unless ( eval $r_cm->[$ii]{'me'} ) {
                        if ( $@ ) {
                            logwarn("Evaluation of macro $ii for macro expansion in line $i failed: $@");
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

=cut

sub apply_conn_gen ($) {
    my $r_cg = shift;       # connection gen data

    my $f = \&add_conn;

    # Expand iterators ...
    # TODO: shift that into the apply_x_gen subroutine?
    foreach my $g ( keys( %$r_cg ) ) {
        if ( $g =~ m,^__MIX_ITERATOR_,io ) {
            my $var = $r_cg->{$g}{'var'};
            foreach my $i ( $r_cg->{$g}{'lb'} .. $r_cg->{$g}{'ub'} ) {
                my %in = %{$r_cg->{$g}{'field'}};
                my %g = ();
                # my $e = '$' . $var . " = $i; ";
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
    #TODO: We could remove the iterators from the generator data, now

    apply_x_gen( $r_cg, $f );

}

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
    foreach my $g ( keys( %$r_hg ) ) {
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
                # eval ....
                add_inst( %g );
            }
        }
    }
    #TODO: We could remove the iterators from the generator data, now

    # Do the rest ...
    apply_x_gen( $r_hg, $f );

}

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
#            $rin->[$i]{'::comment'} = "# Generator parsed /" . $rin->[$i]{'::comment'};

=cut
sub apply_x_gen ($$) {
    my $r_hg = shift;       # connection gen data
    my $func = shift;   # which function to call ...

    # for my $i ( keys( %hierdb) ) { #See if the ::gen matches one of the instances already known
    #    next if $hierdb{$i}{'::ign'} =~ m,^\s*(#|//),o;

    for my $cg ( keys( %$r_hg ) ) { # Iterate through all known generators ...

        # Iterate over CONN or HIER, defined by ...{'ns'} namespace ...
        my $ky = ( $r_hg->{$cg}{'ns'} eq 'conn' ) ? \%conndb : \%hierdb ;

        for my $i ( keys( %$ky ) ) { #See if the ::gen matches one of the instances already known
            next if $ky->{$i}{'::ign'} =~ m,^\s*(#|//),o;

            unless( $r_hg->{$cg}{'var'} ) {
            # Plain match, no run parameter
                my( $text, $re );
                ( $text, $re ) = mix_p_prep_match( $i, $r_hg->{$cg}{'ns'},
                                                 $ky->{$i}, $r_hg->{$cg}{'pre'} );
                next unless defined( $text );
                if ( $text =~ m,^$re$, ) { # $text matches $re ... possibly setting $1 ...
                # if ( $i =~ m/^$r_hg->{$cg}{'pre'}$/ ) {
                    my %in = ();
                    # Apply all fields defined in generator:
                    for my $ii ( keys %{$r_hg->{$cg}{'field'}} ) {
                        #!wig20031007: emtpy is not equal 0!!
                        if ( defined( $r_hg->{$cg}{'field'}{$ii} ) and
                            $r_hg->{$cg}{'field'}{$ii} ne "" ) {
                            # my $f = mix_p_genexp( $r_hg->{$cg}{'field'}{$ii}, $ky->{$i} );
                            my $f = $r_hg->{$cg}{'field'}{$ii};
                            my $e = "\$in{'$ii'} = \"" . $f . "\"";
                            if ( $ii eq "::gen" ) { # Mask \ 
                                $e =~ s/\\/\\\\/g;
                            }
                            unless( eval $e ) {
                                $in{$ii} = "E_BAD_EVAL" if $@;
                                logwarn("ERROR: BAD_EVAL match for $i, match $cg: $@") if $@;
                                $EH{'sum'}{'errors'}++ if $@;
                            }
                        } else {
                            $in{$ii} = $ky->{$i}{$ii}; # Apply defaults from input line ...
                        }
                    }
                    # We add another instance based on the ::gen field matching some other table
                    if ( exists( $in{'::gen'} ) ) {
                        $in{'::gen'} = "G1 #" . $in{'::gen'};
                    }
                    &$func( %in );
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
                    # Save $1..$N for later reusal into %mres
                    for my $ii ( 1..20 ) { #No more then $20, but loop will be left if undef found.
                        #!wig20030516:bug:  my $e = "\$mres{\$$ii} = \$$ii if defined( \$$ii );";
                        my $e = "\$mres{$ii} = \$$ii if defined( \$$ii );"; # Keep $1 ...
                        unless ( eval $e ) {
                            if ( $@ ) {
                                logwarn( "WARNING: BAD_EVAL $mres{\$$ii}: $@" );
                                $EH{'sum'}{'warnings'}++;
                                last;
                            }
                        }
                        unless ( defined( $mres{$ii} ) ) {
                            last; # If $N was undefined, we are at the end ...
                        }
                    }
                    #
                    # We found all $N; now let's deal with {EXPR} and $V
                    #
                    ( $matcher = $re ) =~ s,[()],,g; # Remove all parens

                    if ( $matcher =~ s/{.+?}/\\d+/g ) {
                        logwarn( "ERROR: Illegal arithmetic expression in $matcher. Will be ignored!" );     # postpone that ....
                        $EH{'sum'}{'errors'}++;
                    }
                    $matcher =~ s/\$$rv/(\\d+)/g;   # Replace $rv by (\d+)

                    if ( $text =~ m/^$matcher$/ ) { # $1 has value for $rv ... only one variable
                        if ( defined( $1 ) ){
                            $mres{$rv} = $1;
                        } else {
                            $mres{$rv} = "__UNDEF__"; # No run variable in matcher! This is an error!
                            unless( exists( $r_hg->{$cg}{'error'} ) ) {
                                logwarn("ERROR: Generator " . $r_hg->{$cg}{'field'}{'::gen'} .
                                        " does not define run parameter \$$rv!");
                                $EH{'sum'}{'errors'}++;
                            }
                            $r_hg->{$cg}{'error'}++;
                            last; # Leave loop here .... TODO: should we alert user?
                        }
                    } else { #Error, this has to match!
                        logdie( "FATAL: Matching failed for $cg! File bug report!" );
                    }
                    # Check bounds:
                    if ( $r_hg->{$cg}{'lb'} <= $mres{$rv} and
                            $r_hg->{$cg}{'ub'} >= $mres{$rv} ) {
                        # bingo ... this instance matches
                        #
                        # TODO: Handle arith. {$V + N} {$N +N} ...
                        # Basic idea:fetch {...} and evaluate with results known so far
                        # Apply the results to the matcher string and do a last check ...
                        #
                        my %in = (); # Hold input fields ....
                        for my $iii ( keys( %{$r_hg->{$cg}{'field'}} ) ) {
                            # my $f = mix_p_genexp( $r_hg->{$cg}{'field'}{$iii}, $ky->{$i} );
                            my $f = $r_hg->{$cg}{'field'}{$iii};
                            if ( $iii =~ m/::gen/ ) { # Treat ::gen specially
                                $f =~ s/\\/\\\\/g; #  Mask \
                                $f =~ s/\$$rv/\\\$$rv/g; # Replace $V by \$V ....
                                $f = "G # $rv = $mres{$rv} #" . $f;
                             } else {
                                #!wig20030516: first convert {} to (), then replace variables
                                $f =~s/{/" . (/g;
                                $f =~s/}/) . "/g;       #TODO: make sure {} do match!!

                                $f =~ s/\$(\d+)/$mres{$1}/g; # replace $N by $mres{'N'}
                                $f =~ s/\$$rv/$mres{$rv}/g;    # Replace the run variable by it's value
                                # $f =~ tr/{}/()/;                     # Replace {} by (), which will be evaluated
                            }
                            my $e = '$in{\'' . $iii . '\'} = "' . $f .'"';
                            unless ( eval $e ) {
                                if ( $@ ) {
                                    $in{$iii} = "E_BAD_EVAL";
                                    logwarn "eval of $e failed while processing $cg";
                                }
                            }
                        }
                        &$func( %in );
                    }
                }
            }
        }
    }
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
## ::name defaults to $EH{$type}{'key'} ...
##
## Returns: $content, $re
##
####################################################################

sub mix_p_prep_match ($$$$) {
    my $key = shift;
    my $type = shift || "hier";
    my $r_d = shift;
    my $re = shift;

    my $defcol = $EH{$type}{'key'} || '::inst';
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
## get_opt_cell
## Return list of top cell(s).
## If not specified otherwise, these are the daughter(s) of the testbench cell
####################################################################

=head2

#
# Return list of top cell(s)
#

=cut

sub get_top_cell () {

    my @tops = ();
    if ( $EH{'top'} =~ m,testbench,io ) {
    # Find testbench in hierdb, take daughters
        for my $i ( keys( %hierdb ) ) {
            if ( $i =~ m,testbench,io ) {
                @tops = $hierdb{$i}{'::treeobj'}->daughters;
                last;
            }
        }
    } else {
        for my $i ( keys( %hierdb ) ) {
            if ( $i =~ m,$EH{'top'},io ) { #TODO: What about case sensitive?
                @tops = ( $hierdb{$EH{$i}}{'::treeobj'} );
                last;
            }
        }
    }
    if ( scalar( @tops ) < 1 ) { # Did not find testbench ???
        logwarn( "WARNING: Could not identify toplevel aka. $EH{'top'}" );
    }

    return @tops;
}

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

=cut

sub add_portsig () {

    for my $signal ( keys( %conndb ) ) {
        my %connected = (); # List of connected instance nodes
        my %modes = ();
        my @addup = ();

        if ( $signal eq "" ) { #Fatal error!
            logdie( "FATAL: Detecting signal without name in add_portsig! Check CONN sheet!");
            next;
        }

        # Skip HIGH/LOW/OPEN
        if ( $signal =~ m/^\s*%(HIGH|LOW|OPEN)/o ) { next; }
        #
        # Skip if signal mode equals Constant or Generic
        # Constant and Generics will not extend port map!
        #
        my $mode = $conndb{$signal}{'::mode'};

        if ( $mode and ( $mode =~ m,^\s*[CGP],o ) ) {
            next;
        }

        _mix_p_getconnected( $signal, "::in", $mode, \%modes, \%connected );
        _mix_p_getconnected( $signal, "::out", $mode, \%modes, \%connected );

        #
        # If signal mode is I |O | IO (not S), make sure it's connected to the
        # top level
        # Add IO-port if not connected already ....
        #
        if ( $EH{'output'}{'generate'}{'inout'} =~ m,mode,io and
            ( $mode =~ m,[IO],io or $mode =~ m,IO,io ) and
            $signal !~ m/$EH{'output'}{'generate'}{'_re_xinout'}/o
            ) {
            #wig20030625: adding IO switch ...
            #TODO: what about buffers and tristate? So far noone requested this ...
            #TODO: make "inout" more flexible, e.g. replace by io,o,i, ...
                my @tops = get_top_cell();
                my @addtop = ();
                my @addtopn = ();
                my $atp_flag = 0;
                my $dir = ( $mode =~ m,io,io ) ? "inout" :
                    ( ( $mode =~ m,i,io, ) ? "in" :
                    ( ( $mode =~ m,o,io, ) ? "out" :
                    ( ( $mode =~ m,b,io, ) ? "buffer" :"error" )));
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
                            # set ierdb{inst}{'::sigbits'} ...
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
            logwarn( "ERROR: Signal $signal spawns several seperate trees! Will be dropped\n" );
            $EH{'sum'}{'errors'}++;
            next;
            #TODO: How should such a case be handled? Should we add a common top node here?
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
                    logtrc( "notice:4" , "Adding port to hierachy module $name for signal $signal!" );
                    push( @addup, [ $signal, $name, $l, $modes{$l}, $bits ] );
                } else {
                    # Connected, but not all bits? Or in/out mode differs?
                    my $tbits = bits_at_inst( $signal, $name, $modes{$name} );
                    for my $t ( @$tbits ) {
                        for my $lb ( @$bits ) {
                            if ( substr( $t, -1, 1 ) eq substr( $lb, -1, 1 ) ) { #Same i/o
                                if ( $lb !~ m,A::, and $t ne $lb ) {
                                    push( @addup, [ $signal, $name, $l, $modes{$l}, $t ] );#TODO: XXXX
                                }
                            }
                        }
                    }
                }
                $n = $n->mother;
                unless( defined( $n ) ) {
                    logwarn( "ERROR: climb up tree failed for signal $signal!" );
                    $EH{'sum'}{'errors'}++;
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
        logwarn( "WARNING: Bad branch in _mix_p_getconnected! File bug report!");
        $EH{'sum'}{'warnings'}++;
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
sub bits_at_inst ($$$) {
    my $signal = shift;
    my $inst = shift;
    my $modes = shift;

    # my $name = $node->name;
    my $h = $conndb{$signal}{'::high'} || 0;
    my $l = $conndb{$signal}{'::low'} || 0;

    my $d = "";
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
        # unless( defined( $sig_f ) ) { $sig_f = "0"; };
        # unless( defined( $sig_t ) ) { $sig_t = "0"; };

        $sigm = "" if ( lc( $sigm ) eq "s" );
        if ( $sigm ) {
            if ( $sigm =~ m,^io,io ) {
                $d = "c";
            } elsif ( $sigm =~ m,^([btio]),io ) {
                $d = lc( $1 );
            } else {
                $d = "e"; #TODO20030723 ..
            }
        } else {
            # Derive -> i/o from in/out
            $d = lc( substr( $io, 0, 1 ) ); #TODO: extend for buffer and inout pins
        }
        unless( defined( $sigw_flag{$d} ) ) { $sigw_flag{$d} = 1; } # First time

        # } # else {
        #    if ( $d ne lc( substr( $io, 0, 1 ) ) and $d ne "e" ) {
        #        logwarn( "ERROR: Signal direction mismatch for $signal, $name" );
        #        # $d = "e";
        #    }
        #}
        if ( $h eq $sig_f and $l eq $sig_t ) { # Full match
            push( @{$width{$d}}, "A::" );
        } else {
            push( @{$width{$d}}, "F::$sig_f:T::$sig_t" );
            if ( "$sig_f --- $sig_t" =~ m,(\d+) --- (\d+),o ) {
                if ( $1 >= $2 ) {
                    for my $b ( $2..$1 ) { $bits{$d}[$b] = $d; };
                } else {
                    for my $b ( $1..$2 ) { $bits{$d}[$b] = $d; };
                }
            } else {
                logwarn( "WARNING: signal $signal width unknown at instance $inst!" );
                $EH{'sum'}{'warnings'}++;
                $sigw_flag{$d} = 0;
            }
        }
    }

    if ( scalar( keys( %width ) ) > 1 ) {
        logwarn( "WARNING: Signal $signal has mixed links into instance $inst!" );
        $EH{'sum'}{'warnings'}++;
    }

    # Combine the output:
    my @ret = (); # Preset to Error
    for my $i ( keys( %width ) ) {
        #
        #TODO: Iterate through $width!!!!
        if ( scalar( @{$width{$i}} ) == 1 and $width{$i}[0] eq "A::" ) {
            # only one link, that's easy and clear
            push( @ret , $width{$i}[0] . ":$i" );
        } else {
            my $max = $width{$i}[0];
            if ( $max =~ m,A::, ) {
                push( @ret, $max . ":$d" ); # One link was ALL
            } elsif ( not $sigw_flag{$i} ) {
                push( @ret, "A:::e" ); # Missing direction!
                # If we do not know, we take full signal
            } elsif ( $h =~ m,^\s*\d+\s*$,o and $l =~ m,^\s*(\d+)\s*$, ) {
                my $miss = 0;
                my $bits = "";
                #TODO: What if signal does not start at zero?
                for my $b ( $l..$h ) {
                    unless( $bits{$i}[$b] ) { $miss = 1; }
                    $bits = ( ( $bits{$i}[$b] ) ? $bits{$i}[$b] : "0" ) . $bits;
                }
                unless ( $miss ) { push( @ret, "A:::$i" ); }
                else { push ( @ret, "B::$bits" . ":$i" )};
            } else {
                push( @ret, "A:::$i" );
            }
        }
    }
    # Save to %hierdb for later reusal
    #Attention: add additonal data for different ports!!
    #TODO: delete sigbits entry first?
    push( @{$hierdb{$inst}{'::sigbits'}{$signal}}, @ret );
    return \@ret;
}

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
        logwarn("WARNING: Feed empty bitvector 1 to overlay_bits");
        return $bv2;
    }
    unless ( $bv2 ) {
        logwarn("WARNING: Feed empty bitvector 2 to overlay_bits");
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
            logwarn( "WARNING: bitvector length mismatch: $bits1 vs. $bits2" );
            $EH{'sum'}{'warnings'}++;
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
                        logwarn( "WARNING: mixing wrong mode: $bits1 vs. $bits2" );
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

    logwarn( "ERROR: Cannot overlay bitvectors $bv1 vs. $bv2" );

    return( 'E::' );
}

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
            if ( $sb =~ m,(.*):(.)$, ) {
                # $d_wid{$r} = $1;
                $d_mode{$r}{$2} = $1; # o = A:: ....
            }
        }
        unless( defined ( $d_mode{$r} ) ) {
            logwarn( "ERROR: missing sigbits/mode definition for signal $signal, instance $r in add_port");
            $EH{'sum'}{'errors'}++;
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
    for my $l ( reverse( sort( keys( %length ) ) ) ) {
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
                logwarn( "ERROR: signal mode not defined internally ($name). File bug report!" );
            }
            # if ( $d_mode{$name} =~ m,:(in|out|inout|buffer), ) {
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
                logwarn( "ERROR: signal mode not defined internally ($d). File bug report!" );
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
}

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
           logwarn( "ERROR: missing sigbits/mode definition for instance $r in add_top_port");
           $EH{'sum'}{'errors'}++;
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
        #TODO: Remove reverse logic for ndw in _add_port!!!
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

}

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

    my $uk = join( "", sort ( keys ( %$um ) ) ); # bceimo
    if ( $uk =~ m,e, ) { # Error
            logwarn( "ERROR: error mode detected for signal $signal generating port at instance $inst" );
            $EH{'sum'}{'errors'}++;
    }
    my $do = 'e';
    my $dir = "::err";

    # Try to define a base direction to head for ...
    my $simple = 0;
    if ( length( $uk ) > 1 and $uk ne "io" ) { #
        logwarn( "ERROR: Mixed mode $uk connection for instance $inst cannot be resolved for signal $signal!");
        $EH{'sum'}{'errors'}++;
        return; #TODO: Set to mode io and continue with that?
    }

    if ( $uk =~ m,(io),o ) { # Upper level has in's and out's -> We have to be ::in
        $do = 'i';
        $dir = "::in";
        if ( $uw->{'i'} eq 'A::' and $uw->{'o'} eq 'A::' ) {
            if ( scalar( keys( %$dw ) ) > 1 ) { # Possible Conflict!!
                $simple = 2;
                logwarn( "WARNING: Possible io mode conflict for $signal at $inst" );
                $EH{'sum'}{'warnings'}++;
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
        logwarn( "WARNING: Cannot resolve connection request $uk for $inst, signal $signal" );
        $EH{'sum'}{'warnings'}++;
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
            #TODO: Catch further cases ....
            #!wig20031008: Another case: $tw equals $dw (only one mode!!) ... ignore $do then ....
            if ( join( "", keys( %$dw ) ) eq $tm ) {
                if ( $dw->{$tm} eq $tw ) {
                    logtrc("INFO:4",  "Already connected daughters of $inst properly for signal $signal, ignore uppers");
                    return( {$tm => $tw}, $tm );
                }
            }
            elsif ( $tm eq $do ) { # Maybe this is a stupid try to reconnect ....
                if ( $tw =~ m,^A::, ) { # Already connected fully .... hmm, simply return ..
                    logwarn("Info: trying to reconnect $signal to $inst.");
                    return( { $tm => $tw} , $tm );
                } elsif ( defined( $dw->{$do} ) and $dw->{$do} eq $tw )  {
                    logwarn("Info: trying to reconnect $signal to $inst partially.");
                    return( { $tm => $tw} , $tm );
                } else {
                    logwarn( "WARNING: instance $inst partially connected to $signal. File bug report!" );
                    $EH{'sum'}{'warnings'}++;
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
                logwarn( "ERROR: Cannot resolve mode requests $signal at $inst!" );
                $EH{'sum'}{'errors'}++;
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
                logwarn( "ERROR: Cannot resolve conflicting mode requests $signal at $inst!" );
                $mode = "E";
                $EH{'sum'}{'errors'}++;
            }
        }
        unless( $mode ) { #Cannot be true, we have all A's, maybe related to $tm
            $mode = "B";
        }
        if ( $mode eq "E" ) {
            logwarn ( "ERROR: Cannot resolve mode request for $signal at $inst finally!" );
            $EH{'sum'}{'errors'}++;
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
            if ( $sf =~ m,^\d+$, and $st =~ m,^\d+$, ) {
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
                logwarn( "ERROR: Cannot read t/f for signal $signal, inst $inst!" );
                $EH{'sum'}{'errors'}++;
                $tw = {};
                $tm = 'e';
            }
        } else { # F::STR...T::STR
            logwarn( "ERROR: Need programming for F::foo:T::bar, signal $signal, inst $inst!" );
            $EH{'sum'}{'errors'}++;
        }
    }
    return( $tw, $tm );
}

#
# Generate an port for intermediate hierachy
#
#wig20031106: consider the new configuration options:
#  $EH{'port'}{'generate'}{'name'} and {'width'} ...
sub generate_port ($$$$$$) {
    my $signal = shift;
    my $inst = shift;
    my $m = shift;
    my $f = shift;
    my $t = shift;
    my $top_flag = shift;

    my %t = ();
    my $post = $EH{'postfix'}{'POSTFIX_PORT_GEN'};
    my $ftp = "";
    my $full = 0;

    my $h = $conndb{$signal}{'::high'};
    my $l = $conndb{$signal}{'::low'};
    # Get postfix for generated ports (special macro!):
    if ( $post =~ m,%IO%,o ) {
        $post =~ s/%IO%/$m/;
    }

    # If width is max -> use full signal to connect!
    #TODO: Check if upper level recognized that ...
    if ( $EH{'port'}{'generate'}{'width'} =~ m,max,io ) {
        $post = "";
        # Do some checks ....
        if ( $f =~ m,^\d+$,o and $f ) { # $f is digit and > 0!
            if ( $conndb{$signal}{'::high'} =~ m,^\s*\d+\s*$,o ) {
                if ( $f > $h ) {
                    logwarn( "WARNING: upper bound $f of generated port for signal $signal at instance $inst greater then signal upper bound!" );
                    $EH{'sum'}{'warnings'}++;
                }
            } elsif ( $h =~ m,\s*$^,o ) { # Signal has no width
                    logwarn( "WARNING: upper bound $f of generated port for signal $signal at instance $inst greater then signal upper bound!" );
                    $EH{'sum'}{'warnings'}++;
            }
        } elsif ( $f =~ m,\S+,o and $f ne $h ) {
            logwarn( "WARNING: upper bound $f of generated port for signal $signal at instance $inst not matching signal definition!" );
                    $EH{'sum'}{'warnings'}++;
        }
        if ( $t =~ m,^\d+$,o and $t ) { # $f is digit and > 0!
            if ( $l =~ m,^\s*\d+\s*$,o ) {
                if ( $f < $l ) {
                    logwarn( "WARNING: lower bound $t of generated port for signal $signal at instance $inst smaller then signal lower bound!" );
                    $EH{'sum'}{'warnings'}++;
                }
            } elsif ( $l =~ m,\s*$^,o ) { # Signal has no width
                    logwarn( "WARNING: lower bound $t of generated port for signal $signal at instance $inst smaller then signal lower bound!" );
                    $EH{'sum'}{'warnings'}++;
            }
        } elsif ( $t =~ m,\S+,o and $t ne $l ) {
            logwarn( "WARNING: lower bound $t of generated port for signal $signal at instance $inst not matching signal definition!" );
                    $EH{'sum'}{'warnings'}++;
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
    if ( ( $top_flag =~ m,top,io and $EH{'output'}{'generate'}{'inout'} =~ m,noxfix,io )
         or $EH{'port'}{'generate'}{'name'} =~ m,signal,io ) {
        $t{'port'} = $signal;
        #TODO: Check if port name is unique? But how should that work?
    } elsif ( $top_flag =~ m,top,io ) {
        $t{'port'} = $signal . $ftp . $post;
    } else {
        $t{'port'} = $EH{'postfix'}{'PREFIX_PORT_GEN'} . $signal .
                $ftp . $post;
    }

    $t{'inst'} = $inst;

    if ( $t =~ m,^\s*$, ) {
        $t{'port_t'} = $t{'sig_t'} = undef;
    } else {
        $t{'sig_t'} = $t;
        $t{'port_t'} = 0;
    }

    if ( $f =~ m,^\s*$,o ) {
        $t{'port_f'} = $t{'sig_f'} = undef;
    } else {
        $t{'sig_f'} = $f;
        $t{'port_f'} = $f - (( $t =~ m,^\d+$, ) ? $t : 0);
    }

    if ( $f eq $t ) {
        $t{'port_t'} = $t{'port_f'} = undef; # Port is only one bit wide ...
    }

    logtrc( "INFO:4", "add_port: signal $signal adds port $t{'port'} to instance $t{'inst'}" );
    $EH{'sum'}{'genport'}++;

    # Push onto Connection Database ....
    if ( $m eq "o" ) {
        $m = '::out';
    } else {
        $m = '::in';
    }

    # To avoid issues, get rid of %EMPTY% in port name now
    $t{'port'} = replace_mac( $t{'port'}, $EH{'macro'} );

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
        if ( $r->{$i} =~ m,A::, ) {
            $r->{$i} = "B::" . $i x ( $max - $min + 1);
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
            logwarn( "WARNING: Bad value in bit vector $i: $r->{$i}" );
        } elsif ( length( $r->{$i} ) - 3 != $max - $min + 1 ) {
            logwarn( "WARNING: Bad length of bit vector $i: $r->{$i}" );
            substr( $r->{$i} , 3, 0 ) = "0" x ( $max - $min + 1 - length( $r->{$i} ) + 3 ) 
        }
    }
}

#
# Tree::DAG_Node::common is buggy -> use my_common instead
#
sub my_common (@) {
	my ( $root, @nodes ) = @_;

	#
	# return undef if called without arguments
	#
	unless( defined $root and $root ) { return undef; };
        unless( Tree::DAG_Node::is_node( $root ) ) {
            logwarn( "Input of my_common $root is no Tree::DAG_Node node!" );
            return undef;
        }

	if ( $#nodes < 0 ) {
             return $root;
	} else {
            for my $n ( @nodes ) {
                unless( Tree::DAG_Node::is_node( $n ) ) {
                    logwarn( "Input of my_common  nodes array is no Tree::DAG_Node node!" );
                    return undef;
                }
            }
        }

	#
	# or if the nodes are not part of the same tree
	#
	unless( defined( $root->common( @nodes ) ) ) { return undef; };

	my $ar = $root->address . ":";

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
}

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

            my $rf = \$rh->{$h}{$f};

            # If $rf is not of type ref(scaler) -> go deeper into it
            if ( ref($rf) eq "REF" and ref( $$rf ) eq "ARRAY" ) { # ::in and ::out
                for my $e ( 0..$#{$$rf} ) {
                    __parse_inout( $$rf->[$e], $rh->{$h} ); #TODO ...
                }
            } elsif ( ref($rf) eq "SCALAR" ) {
                __parse_mac( $rf, $rh->{$h} );
            } else {
                logwarn("TODO: Implement recursive parse_mac for $h $f");
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

sub __parse_mac ($$) {
    my $ra = shift;
    my $rb = shift;

    my $ehmacs = \%{$EH{'macro'}};

    unless( defined $$ra ) {
        logwarn("WARNING: __parse_mac: trying to match against undef value");
        $rb->{'::comment'} .= "#WARNING: undef value somewhere";
        return;
    }

    while ( $$ra =~ m/(%[\w:]+?%)/g ) {
        my $mac = $1;
        if ( $mac =~ m/^%(::\w+)%/ ) {
            if ( exists( $rb->{$1} ) ) {
                my $r = $rb->{$1};
                $$ra =~ s/%[\w:]+?%/$r/;
            } else {
                logwarn("WARNING: Cannot find macro $1 to replace!");
                $EH{'sum'}{'warnings'}++;
            }
        } elsif( exists( $ehmacs->{$mac} ) ) {
            $$ra =~ s/$mac/$ehmacs->{$mac}/;
        } else {
            logwarn("WARNING: Cannot locate replacement for $mac in data!");
            $EH{'sum'}{'warnings'}++;
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
            logwarn("WARNING: Removing empty instance! Check input sheets!");
            $EH{'sum'}{'warnings'}++;
            delete( $hierdb{$i} );
        }
    }

    #
    # uniquify signals
    #TODO
    for my $i ( keys( %conndb ) ) {
            my $rsa = $conndb{$i}; #Reference
            _scan_inout( $rsa->{'::out'} );
            _scan_inout( $rsa->{'::in'} );
    }
    #
    # If ::high and ::low is defined, extend ::in and ::out definitions
    #
    for my $i ( keys( %conndb ) ) {

        unless( defined( $conndb{$i}{'::high'} ) ) { $conndb{$i}{'::high'} = ''; }
        unless( defined( $conndb{$i}{'::low'} ) ) { $conndb{$i}{'::low'} = ''; }

        $conndb{$i}{'::high'} = '' if ( $conndb{$i}{'::high'} =~ m,^\s+,o );
        $conndb{$i}{'::low'} = '' if ( $conndb{$i}{'::low'} =~ m,^\s+,o );

        next if ( $i eq '%OPEN%' ); # Ignore the %OPEN% pseudo-signal

        if ( $conndb{$i}{'::high'} ne '' or $conndb{$i}{'::low'} ne '' ) {
            my $h = $conndb{$i}{'::high'};
            my $l = $conndb{$i}{'::low'};
                _extend_inout( $h, $l, $conndb{$i}{'::in'} );
                _extend_inout( $h, $l, $conndb{$i}{'::out'} );
            # }
        }

        #!wig20030731: make sure high/low_bus has width!
        if ( $i =~ m,^%(LOW|HIGH)_BUS%$,o ) {
            # If high or low bus does not have ::high or ::low defined, set it ...
            if ( $conndb{$i}{'::high'} eq '' or $conndb{$i}{'::low'} eq '' ) {
                my $max = 1; # Minimal assign a 1 to the high/low bus width
                for my $ii ( @{$conndb{$i}{'::in'}} ) {
                    if ( $ii->{'port_f'} and $ii->{'port_f'} < $max ) {
                        $max = $ii->{'port_f'};
                    }
                }
                $conndb{$i}{'::high'} = $max;
                $conndb{$i}{'::low'} = "0";
            }
        }


        # Does a _vector type have bounds defined?
        if ( ( $conndb{$i}{'::high'} eq "" or $conndb{$i}{'::low'} eq "" ) and
            $conndb{$i}{'::type'} =~ m,(.*_vector$), ) {
                logwarn( "WARNING: Found signal of type $1 with undefined bounds!" );
                $EH{'sum'}{'warnings'}++;
        }

        #!wig20030516: auto reducing single width busses to signals ...
        if ( $conndb{$i}{'::high'} eq "0" and $conndb{$i}{'::low'} eq "0" ) {
            if ( $conndb{$i}{'::type'} =~ m,std_u?logic\s*$,io ) {
                $conndb{$i}{'::high'} = '';
                $conndb{$i}{'::low'} = '';
            } elsif ( $conndb{$i}{'::type'} =~ m,(std_u?logic)_vector\s*$,io ) {
                logwarn("WARNING: reducing signal $i from mode $conndb{$i}{'::mode'} to $1!");
                $conndb{$i}{'::high'} = '';
                $conndb{$i}{'::low'} = '';
                $conndb{$i}{'::type'} = $1;
            } elsif ( $conndb{$i}{'::type'} eq $EH{'conn'}{'field'}{'::type'}[3] ) {
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
}

#
# Look through ::in and ::out arrays and check/change VHDL/VErilog keywords ..
# e.g. open ....
# Set configuration value postfix.PREFIX_KEYWORD to %NULL% to suppress changes
#
# TODO: Shift that routine to MixChecker
sub _check_keywords ($$) {
    my $name = shift;
    my $ior = shift;

    #TODO: Run that again in the backend, after everything got evaled
    #TODO: There is no way to figure out %::cols% conflicts finally :-(
    # at this stage.
    # We will do our best to find open/%::name% (as this is likely to happen)
    #
    for my $l ( keys( %{$EH{'check'}{'keywords'}} ) ) {    
        for my $i ( @$ior ) {
            for my $ii ( qw( inst port ) ) {
                if ( $i->{$ii} =~ m,^$EH{'check'}{'keywords'}{$l}$, ) {
                    $i->{$ii} = $EH{'postfix'}{'PREFIX_KEYWORD'} . $1;
                    logwarn( "WARNING: Detected keyword $1 in $ii got replaced!" );
                    $EH{'sum'}{'warnings'}++;
                } elsif ( $name eq '%OPEN%' and $i->{$ii} eq '%::name%' ) {
                    $i->{$ii} = $EH{'postfix'}{'PREFIX_KEYWORD'} . $i->{$ii};
                    logwarn( "WARNING: Detected keyword $name in $ii got replaced!" );
                    $EH{'sum'}{'warnings'}++;
                }
            }
        }
    }
}

# sub _extend_open ($$$) {
#    my $h = shift;
#    my $l = shift;
#    my $ref = shift;
#
# }

# If ::high and/or ::low is defined,
# check if there are port definitions to be extended
#

sub _extend_inout ($$$) {
    my $h = shift;
    my $l = shift;
    my $ref = shift;

    for my $i ( @{$ref} ) {
        if( not defined( $i->{'sig_f'} ) and
            not defined( $i->{'port_f'} ) ) {
                $i->{'sig_f'} = $h;
                $i->{'port_f'} = $h;
        } elsif ( not defined( $i->{'sig_f'} ) # or
                # not defined( $i->{'port_f'} )
                ) {
            logwarn( "Warning: Unusual upper bound definitions for $i->{'inst'} / $i->{'port'}" );
        }
        if ( not defined( $i->{'sig_t'} ) and
            not defined( $i->{'port_t'} ) ) {
                $i->{'sig_t'} = $l;
                $i->{'port_t'} = $l;
        } elsif ( not defined( $i->{'sig_t'} ) # or
                # not defined( $i->{'port_t'} )
                  ) {
            logwarn( "Warning: Unusual lower bound definitions for $i->{'inst'} / $i->{'port'}" );
        }
    }
#TODO: What if only one of is defined???
}

#
# strip away duplicate entries in ::in and ::out
# strip away empty entries
# force lowercasing if configured
#TODO: combine entries (opposite of split busses)
#
sub _scan_inout ($) {
        my $rsa = shift;

        no warnings; # switch of warnings here, values might be undefined ...
        my %seen = ();
        my @left = ();

        for my $iii ( 0..$#{$rsa} ) {
                unless( exists( $rsa->[$iii]{'rvalue'} ) ) {
                    if ( exists( $rsa->[$iii]{'inst'} ) ) {
                        $rsa->[$iii]{'inst'} = mix_check_case( 'inst', $rsa->[$iii]{'inst'} );
                    }
                    if ( exists( $rsa->[$iii]{'port'} ) ) {
                        $rsa->[$iii]{'port'} = mix_check_case( 'port', $rsa->[$iii]{'port'} );
                    }
                }
                my $this = join( ',', values( %{$rsa->[$iii]} ) );
                if( $this and not defined( $seen{$this} ) ) {
                    push( @left, $rsa->[$iii] );
                    $seen{$this} = 1;
                }
        }
        @$rsa = @left;
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
                unless ( $conndb{$conn}{'::mode'} =~ m,^\s*[CPG],o ) {
                    # Complain if signal does connect to unknown instance
                    logwarn("Skipping connection $conn to undefined instance $inst!");
                }
                next; #TODO: Should we try to add that instance?
        }
        next if ( $inst eq "%CONST%" );
        # Skip meta instance %CONST%
        my $port = $rsa->[$iii]{'port'};
        unless ( defined( $port ) ) {
                logwarn("Undefined port for connection $conn, instance $inst!");
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
	    logwarn( "INFO: Importing $f now!" );
	    _mix_parser_parsehdl( $f ); # Will create a dummy hier and conn file
	} else {
	    logwarn( "WARNING: Cannot read HDL $f for import" );
	    $EH{'sum'}{'warnings'}++;
	}
    }

    # prepare to dump the data now ..
    parse_mac();
    my $arc = db2array( \%conndb , "conn", "" );
    my $arh = db2array( \%hierdb, "hier", "^(%\\w+%|W_NO_PARENT)\$" );

    # write_outfile( $dumpfile, "CONF", $aro ); #wig20030708: store CONF options ...
    write_outfile( $file, "IMP_CONN", $arc );
    write_outfile( $file, "IMP_HIER", $arh );

}

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
	logwarn( "ERROR: Cannot open import file $file: $!" );
	$EH{'sum'}{'warnings'}++;
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
		'::parent' => "%IMPORT%"
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
                                    '::high' => "",
                                    '::low' => "",
                                    '::bundle'  => "%IMPORT_BUNDLE%" . uc($inst) ,
                                    '::class' => "%IMPORT%" . uc($inst),
                                    '::clock' => "%IMPORT_CLK%" . uc($inst),
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

                #OLD: if ( $body =~ m,port\s*\((.+?)\);,ims ) {
                # alarm_time_ms_min	: in	std_ulogic_vector(3 downto 0);
                # clk	: in	std_ulogic;
                while( $ports =~ s/^\s*(\w+)\s*:\s*(\w+)\s*(\w+)\s*
                               (\(\s*(\d+)(\s+(down)?to\s+(\d+))?\s*\))?   # Optional (N downto M)
                               ;                                                   # ; or end of line
                               ([ \t]*--.*)?//xm ) {
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
			logwarn( "WARNING: unknown mode $mode in import" );
			$d{'::mode'} = "S";
		    }
		    $d{$col} = $inst . "/" . $1;
		    $d{'::high'} = $5 if ( defined( $5 ) );
		    $d{'::low'} = $8 if ( defined( $8 ) );
		    $d{'::comment'} = $9 if ( defined( $9 ));
		    add_conn( %d );
		    # printf ( "#### Found port in instance $inst:\n" );
		    # printf ( "\t%s %s\n" x scalar( keys( %d ) ), %d ); 
                }
                # catch last signal
                if( $ports =~ m/\n\s*(\w+)\s*:\s*(\w+)\s*(\w+)
                               (\(\s*(\d+)(\s+(down)?to\s+(\d+))?[ \t]*\))?   # Optional (N downto M)
				([ \t]*--.*)?/xm ) {
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
			logwarn( "WARNING: unknown mode $mode in import" );
			$d{'::mode'} = "S";
		    }
		    $d{$col} = $inst . "/" . $1;
		    $d{'::high'} = $5 if ( defined( $5 ) );
		    $d{'::low'} = $8 if ( defined( $8 ) );
		    $d{'::comment'} = $9 if ( defined( $9 ));
		    # add_conn( %d );
		    printf ( "#### Found port in instance $inst:\n" );
		    printf ( "\t%s %s\n" x scalar( keys( %d ) ), %d );
                    add_conn( %d );
                }
	    }
	}
    } elsif ( $file =~ m,\.v$, ) {
	# Verilog ...
	logwarn( "INFO: Master Wilfried has not taught me to read in Verilog :-(" );

    } else {
	# What's that ?
	logwarn( "ERROR: Cannot import file $file, unknown type!" );
    }

    return;

}

1;

#!End
