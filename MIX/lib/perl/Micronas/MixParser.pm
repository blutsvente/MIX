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
# | Project:    Micronas - MIX / Parser                                    |
# | Modules:    $RCSfile: MixParser.pm,v $                                     |
# | Revision:   $Revision: 1.4 $                                             |
# | Author:     $Author: wig $                                  |
# | Date:       $Date: 2003/02/07 13:18:45 $                                   |
# |                                                                       |
# | Copyright Micronas GmbH, 2002                                |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/MixParser.pm,v 1.4 2003/02/07 13:18:45 wig Exp $                                                         |
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
      add_portsig
      add_sign2hier
      parse_mac
      purge_relicts
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

use Micronas::MixUtils qw( mix_store db2array write_excel %EH );

# Prototypes:
sub _scan_inout ($);
sub my_common (@);

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
        logdie( "ERROR: Undefined or empty input argument for parse_conn_macros!\n" );
    }
    my $mflag = 0;
    my @m = ();
    my $n = -1;
    for my $i ( 0..$#{$rin} ) {
        #wig:TODO what was that meant? Why would we skip the comment field???
        #if ( defined( $rin->[$i]{'::comment'} ) and
        #                $rin->[$i]{'::comment'} =~ m,^\s*(#|//),io ) {
        #    next;
        # }
        #wig:bug: if ( not $mflag and $rin->[$i]{'::gen'} =~ m/^\s*MH/io ) {
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
        if ( $mflag ) {
            # no new macro definition, go to status "wait for another MH"
            $mflag = 0;
            next;
        }
    }

    $n++;
    logtrc( "INFO", "Found $n macro definitions" );

    #
    # Check macro definitions
    #
    @m = check_conn_macros( \@m );

    #
    # Convert mh into mm,mv and mo
    # defining order of fileds, variables defined and matching string
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
        logdie("ERROR: bad input argument for check_conn_macros\n");
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
            # if ( $f{$ii} =~ m/\$(.)/ ) { # Only cells with a $N in it are of interest
            if ( $f{$ii} !~ m/^$/o and $ii !~ /^::(comment|descr|gen|ign)/io ) {
                # Only non-empty cells are of interest, and do not match comment, descr, ...
                push( @oo, $ii );
                $mm .= "${ii}::";
                @{$vars{$ii}} = ( $f{$ii} =~ m{\$(\w)}xg ); # Give me all variables ....
                ( my $tmp = $f{$ii} ) =~ s,\$\w,(.+),g;
                $mm .= $tmp; # Replace variable names by (.+)
                
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
            next;
        }
        unless ( defined( $r_m->[$i]{'md'} ) and $#{$r_m->[$i]{'md'}} >= 0 ) {
            logwarn("ERROR: macro definition missing $i");
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

Retrieve connection generator definitions from the input data. There are two
allowed forms:

=over 4

=item

    $i (n..m),/PERL_RE

=item

    /PERL_RE/

=back

It returns a hash, key is the instance name perl regular expression match.
Right now this function can be used for both CONN and HIER matrix.

=cut

sub parse_conn_gen ($) {
    my $rin = shift;

    unless( defined $rin ) {
        logdie "FATAL: parse_conn_gen called with bad argument\n";
        exit 1;
    }

    my %g = ();
    for my $i ( 0..$#{$rin} ) {

        next unless ( $rin->[$i] ); # Holes in the array?        
        next if ( $rin->[$i]{'::comment'} =~ m,\s*(#|//),o );   # Commented out
        next if ( $rin->[$i]{'::gen'} =~ m,^\s*$, );                # Empty

        # iterator based generator: $i(1..10), /PERL_RE/
        if ( $rin->[$i]{'::gen'} =~ m!^\s*\$(\w)\s*\((\d+)\.\.(\d+)\)\s*,\s*/(.*)/! ) {
            my $pre = $4;
            if ( $2 > $3 ) {
                logwarn("bad bounds $2 .. $3 in generator definition!");
                next;
            }
            $g{$pre}{'var'} = $1;
            $g{$pre}{'lb'}   = $2;
            $g{$pre}{'ub'}  = $3;
            # $g{$pre}{'pre'} = $4;
            $g{$pre}{'field'} = $rin->[$i];
            $rin->[$i]{'::comment'} = "# Generator parsed /" . $rin->[$i]{'::comment'};
        }
        # plain generator: /PERL_RE/
        elsif ( $rin->[$i]{'::gen'} =~ m!^\s*/(.*)/! ) {
            $g{$1}{'var'} = undef;
            $g{$1}{'lb'}   = undef;
            $g{$1}{'ub'}  = undef;
            # $g{$pre}{'pre'} = $4;
            $g{$1}{'field'} = $rin->[$i];
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
        #TODO: next if ( $r_hier->[$i]{'::comment'} =~ m,^\s*(#|//),o ); #TODO: is it true? use ::ign instead?
        next unless ( $r_hier->[$i] ); # Skip if input filed is empty
        next if ( $r_hier->[$i]{'::ign'} =~ m,^(#|//),o );
        next if ( $r_hier->[$i]{'::gen'} !~ m,^\s*$,o );
        # Add more "go away" here if needed

        add_inst( %{$r_hier->[$i]} );

    }
    
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

    unless ( defined( $in{'::inst'} ) ) {
        logwarn( "try to create instance without name!" );
        return;
    }

    my $name = $in{'::inst'};
    if ( defined( $hierdb{$name} ) ) {
        merge_inst( $name, %in );
    } else {
        create_inst( $name, %in );
    }
}

sub create_inst ($%) {
    my $name = shift;
    my %data = @_;

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

    if ( defined( $hierdb{$parent} ) and $hierdb{$parent} ) {
            $hierdb{$parent}{'::treeobj'}->add_daughter( $node );
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

    #
    # Tree check: Does this instance get a new parent?
    #
    if ( defined( $data{'::parent'} ) and $data{'::parent' }
        and defined( $hierdb{$name}{'::parent'} and $hierdb{$name}{'::parent'} ) ) {
        if (
            $data{'::parent'} ne $EH{'hier'}{'field'}{'::parent'}[3] and
            $data{'::parent'} ne $hierdb{$name}{'::parent'} ) {
                #BAD: my $par = $hierdb{$name}{'::parent'} || "W_NO_PARENT";
                # my $par = $data{'::parent'} || "W_NO_PARENT";
                logwarn( "Debug: Change parent for cell $name to $data{'::parent'} from $hierdb{$name}{'::parent'}" )
                    unless( $hierdb{$name}{'::parent'} eq $EH{'hier'}{'field'}{'::parent'}[3] );
                my $node = $hierdb{$name}{'::treeobj'};
                # If parent is already defined -> change it ...
                unless ( exists( $hierdb{$data{'::parent'}} ) ) {
                    logwarn( "Autocreate parent for $name: $data{'::parent'}" );
                    create_inst( $data{'::parent'}, \{} );
                }
                my $pnode = $hierdb{$data{'::parent'}}{'::treeobj'};
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
            if ( $data{$i} ) {    #BAD: defined( $data{$i} ) ) {
                $hierdb{$name}{$i} = $data{$i};
            }
        }
    }    
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
        
        unless ( defined( $r_conn->[$i]{'::name'} ) ) {
            # Is it a constant?
            if ( $r_conn->[$i]{'::mode'} =~ m/^\s*c/io ) {
                $r_conn->[$i]{'::name'} = "CONST_" . $const++;
            }
        }
        add_conn( %{$r_conn->[$i]} );
    }
}

sub add_conn (%) {
        my %in = @_;

        my $name = $in{'::name'};

        #
        # strip of leading and trailing whitespace
        #
        $name =~ s/^\s+//o;
        $name =~ s/\s+$//o;
        $in{'::name'} = $name;
        #
        # name must be defined:
        #
        if ( $name eq "" ) {
            # Handle CONSTANTS ..
            if ( $in{'::mode'} =~ m/C/ ) {
                # Generate a name
                $name = $EH{'postfix'}{'PREFIX_CONST'} . $EH{'CONST_NR'}++;
                $in{'::name'} = $name;
                logwarn( "INFO: Creating name $name for constant!" );
            } else {
            # Mark signal .... but add it anyway (user should be able to fix it)
                logwarn( "Missing signal name. Will be ignored!" );
                $in{'::ign'} = "#ERROR_MISSING_SIGNAL_NAME";
                $in{'::comment'} = "#ERROR_MISSING_SIGNAL_NAME $name" . $in{'::comment'};
                $name = "ERROR_MISSING_SIGNAL_NAME";
                $in{'::name'} = $name;
            }
        }
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
            }
        }
            
        if ( defined( $conndb{$name}  ) ) {
            merge_conn( $name, %in );
        } else {
            create_conn( $name, %in);
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
            if ( $data{$i} ) {
                $conndb{$name}{$i} = _create_conn( "$1", $data{$i}, %data );
            } else {
                $conndb{$name}{$i} = []; #Initialize empty array. Will be removed later on
            }
        } elsif ( defined( $data{$i} ) ) {
            $conndb{$name}{$i} = $data{$i};
        } else {
            $conndb{$name}{$i} = $ehr->{$i}[3]; # Set to DEFAULT Value
            #TODO: Initialize fields to empty / Marker, set DEFAULT if still empty at end 
        }
        $conndb{$name}{$i} =~ s/%NULL%//g; # Just to make sure fields are initialized
        delete( $data{$i} );
    }

    #
    # Add the rest, too
    #
    for my $i( keys( %data ) ) {
        $conndb{$name}{$i} = $data{$i};
    }

}

####################################################################
## _create_conn
## create/add/modify a bus/signal/connection from the ::in/::out field
####################################################################

=head2

_create_conn ($$%)

Create/add/modify a bus/signal/connection; convert input into simple array of hashes.

=cut

sub _create_conn ($$%) {
    my $inout = shift;
    my $instr = shift;
    my %data = @_;

    #A bus with ::low and ::high    
    my $h = undef;
    my $l = undef;
    #TODO: check bus definitions better!
    if ( defined( $data{'::low'} ) and defined ( $data{'::high'} ) ) {
        #    if ( $data{::low} <= $data{::high} ) {
        #        # This ia a bus ...
        if ( $data{'::high'} ne "" ) {
            unless ( $data{'::high'} =~ /^\d+$/ ) {
                logwarn( "Bus $data{'::name'} upper bound $data{'::high'} not a number!" );
            } else {
                $h = $data{'::high'};
            }
        }
        if ( $data{'::low'} ne "" ) {
            unless ( $data{'::low'} =~ /^\d+$/ ) {
                logwarn( "Bus $data{'::name'} lower bound $data{'::low'} not a number!" );
            } else {
                $l = $data{'::low'};
            }
        }
        if ( defined( $h ) and defined( $l ) and $h <= $l ) {
            logwarn( "Ununsual bus ordering $h downto $l" );
        }
    }
    #    else {
    #        logwarn( "ERROR", "Error: wrong bounds on signal $data{::name}!");
    #        return;
    #    }
    my %co = ();
    my @co = ();
    unless( $instr ) {
        logwarn("Called _create_conn without data for $inout");
        return \@co; #Return dummy array, just in case
    }
    for my $d ( split( /,/, $instr ) ) {
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
            $d =~ s/\((\d+)\)/($1:$1)/g; # Extend (N) to (N:N)
            if ( $d !~ m,/,o ) {
                $d =~ s,(\w+),$1/%::name%,;
            }

            if ( $d =~ m,(\w+)/(\S+)\((\d+):(\d+)\)\s*=\s*\((\d+):(\d+), ) {
                # INST/PORTS(pf:pt)=(sf:st)
                $co{'inst'} = $1;
                $co{'port'} = $2;
                $co{'port_f'} = $3;
                $co{'port_t'} = $4;
                $co{'sig_f'} = $5;
                $co{'sig_t'} = $6;
            } elsif ( $d =~ m,(\w+)/(\S+)=\((\d+):(\d+)\)\s*, ) {
                # INST/PORTS=(f:t) Port-Bit to Bus-Bit f = t; expand to pseudo bus?
                #TODO: Implement better solution (e.g. if Port is bus slice, not bit?
                #wig20030207: handle single bit port connections ....
                if ( $3 == $4 ) {
                    $co{'inst'} = $1;
                    $co{'port'} = $2;
                    $co{'port_f'} = 0; #Port is bit, not bus
                    $co{'port_t'} = 0; #Port is bit, not bus
                    $co{'sig_f'} = $3;
                    $co{'sig_t'} = $4;
                } else { # Assume we connect to ($f - $t) - 0 !
                    if ( $4 != 0 ) {
                        # Wire port of width
                        logwarn("Automatically wiring signal bits $3 to $4 of $1/$2 to bits " . ( $3 - $4 ) . " to 0");
                    }
                    $co{'inst'} = $1;
                    $co{'port'} = $2;
                    $co{'port_f'} = $3 - $4;
                    $co{'port_t'} = 0;
                    $co{'sig_f'} = $3;
                    $co{'sig_t'} = $4;
                }   
            } elsif ( $d =~ m,(\w+)/(\S+)\((\d+):(\d+)\)\s*, ) {
                # INST/PORTS(f:t)
                $co{'inst'} = $1;
                $co{'port'} = $2;
                $co{'port_f'} = $3;
                $co{'port_t'} = $4;
                $co{'sig_f'} = $3 - $4;
                $co{'sig_t'} = 0;
            } elsif ( $d =~ m,(\w+)/(\S+)\s*, ) {
                # INST/PORTS
                $co{'inst'} = $1;
                $co{'port'} = $2;
                $co{'port_f'} = $h;
                $co{'port_t'} = $l;
                $co{'sig_f'} = $h;
                $co{'sig_t'} = $l;
            } else {
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
    return \@co;
}

#
# Check connection properties
#
sub check_conn_prop ($) {
    my $ref = shift;

    if ( $ref->{'inst'} !~ m,^[:%\w]+$,o ) {
        logwarn( "Unusual character in instance name: $ref->{'inst'}/$ref->{'port'}!" );
    }
    if ( $ref->{'port'} !~ m,^[:%\w]+$,o ) {
        logwarn( "Unusual character in port name: $ref->{'inst'}/$ref->{'port'}!" );
    }

}    
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
            if ( $conndb{$name}{$i} and $conndb{$name}{$i} ne "%SIGNAL%" ) {
                # conndb{$name}{::type} is defined and ne the default
                 if ( $data{$i} and $data{$i} ne "%SIGNAL%" ) {
                    my $t_cdb = $conndb{$name}{$i};
                    if ( $data{$i} ne $t_cdb ) { #TODO: and $name !~ m/%(HIGH|LOW)/o ) {
                        # %HIGH% and %LOW% signal will get type assigned
                        logwarn( "ERROR: type mismatch for signal $name: $t_cdb ne $data{$i}!" );
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
                        } elsif ( not ( $data{$i} eq 'S' and $t_cdb =~ m/^(I|O|IO)/o ) ) {
                            logwarn( "ERROR: mode mismatch for signal $name: $t_cdb ne $data{$i}!" );
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
            if ( $conndb{$name}{$i} ) {
                if ( $data{$i }and $conndb{$name}{$i} ne $data{$i} ) {
                    # LOW and HIGH "signals" are special.
                    if ( $name =~ m,^\s*%(LOW|HIGH)_BUS%, ) { # Accept larger value for upper bound
                        if ( $i =~ m,^\s*::high,o ) {
                            $conndb{$name}{$i} = $data{$i} if ( $data{$i} > $conndb{$name}{$i} );
                        } elsif ( $i =~ m,^\s*::low,o ) {
                            $conndb{$name}{$i} = $data{$i} if ( $data{$i} < $conndb{$name}{$i} );
                        }
                    } else {
                        logwarn( "ERROR: bound mismatch for signal $name: $conndb{$name}{$i} ne $data{$i}!");
                        $conndb{$name}{$i} = "__E_BOUND_MISMATCH";
                    }
                }
            } else {
                $conndb{$name}{$i} = $data{$i};
            }
        } elsif ( $i =~ /^\s*::(gen|comment|descr)/o ) {
            # Accumulate generator infos, comments and description
            if ( $data{$i} ) { #
                $conndb{$name}{$i} .= $data{$i};
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
    
    if ( $type eq "auto" ) {
        # Derive output format from output name extension
        if ( $dumpfile =~ m,\.(xls|csv)$, ) {
                $type=$1;
        } else {
        # Default to "internal" format
                $type="internal";
        }
    }
      
    if ( $type eq "xls" ) {
        my $arc = db2array( \%conndb , "conn" );
        my $arh = db2array( \%hierdb, "hier" );
        write_excel( $dumpfile, "CONN", $arc );
        write_excel( $dumpfile, "HIER", $arh );
    } else {
        mix_store( $dumpfile, { 'conn' => \%conndb , 'hier' => \%hierdb,
                                    %$varh
                            }   );
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
    #    write_excel( $dumpfile, "CONN", $arc );
    #    write_excel( $dumpfile, "HIER", $arh );
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
                    logtrc("INFO", "macro $ii matched");
                    
                    my %mex = ();
                    # Gets matched variables
                    unless ( eval $r_cm->[$ii]{'me'} ) {
                        logwarn("Evaluation of macro $ii for macro expansion in line $i failed: $@");
                        next;
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
    
    for my $i ( keys( %hierdb) ) { #See if the ::gen matches one of the instances already known
        next if $hierdb{$i}{'::ign'} =~ m,^\s*(#|//),o;
        for my $cg ( keys( %$r_hg ) ) {
            unless( $r_hg->{$cg}{'var'} ) {
            # Plain match, no run parameter
                if ( $i =~ m/^$cg$/ ) {
                    my %in = ();
                    for my $ii ( keys %{$r_hg->{$cg}{'field'}} ) {
                        if ( $r_hg->{$cg}{'field'}{$ii} ) {
                            # my $e = '$r_hg->{$cg}{\'field\'}{$ii}';
                            my $e = "\$in{'$ii'} = \"" . $r_hg->{$cg}{'field'}{$ii} . "\"";
                            unless( eval $e ) {
                                $in{$ii} = "E_BAD_EVAL" if $@;
                                logwarn("bad hierachy match for $i, match $cg: $@") if $@;
                            }
                        } else {
                            $in{$ii} = $hierdb{$i}{$ii};
                        }
                    }
                    # We add another instance based on the ::gen field matching some other table
                    &$func( %in );
                }
            } else {
            # There is an additional run parameter involved: $r_hg{$cg}{'var'}
            # Match first; if it applies, we see if the variable is within range
                my $matcher = $cg;
                my $rv = $r_hg->{$cg}{'var'};
                my %mres = ();
                #
                # $i or {$i + N}
                #
                $matcher =~ s/{.+?}/\\d+/g; #Replace {$i + N} by \\d+
                $matcher =~ s/\$$rv/\\d+/g; #Replace $i by \\d+
                if ( $i =~ m/^$matcher$/ ) {
                    # Save $1..$N for later reusal into %mres
                    for my $ii ( 1..20 ) { #No more then $20 !!
                        my $e = "\$mres{\$$ii} = \$$ii if defined( \$$ii );";
                        unless ( eval $e ) {
                            if ( $@ ) {
                                logwarn( "bad eval $mres{\$$ii}: $@" );
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
                    ( $matcher = $cg ) =~ s,[()],,g; # Remove all parens

                    if ( $matcher =~ s/{.+?}/\\d+/g ) {
                        logwarn( "Illegal arithemtic expression in $matcher. Will be ignored!" );     # postpone that ....
                    }
                    $matcher =~ s/\$$rv/(\\d+)/g;   # Replace $rv by (\d+)
                    
                    if ( $i =~ m/^$matcher$/ ) { # $1 has value for $rv ...
                        $mres{$rv} = $1;
                    } else { #Error, this has to match!
                        logdie( "matching failed for $cg" );
                    }
                    # Check bounds:
                    if ( $r_hg->{$cg}{'lb'} <= $mres{$rv} and $r_hg->{$cg}{'ub'} >= $mres{$rv} ) {
                        # bingo ... this instance matches
                        #
                        # TODO: Handle arith. {$V + N} {$N +N} ...
                        # Basic idea:fetch {...} and evaluate with results known so far
                        # Apply the results to the matcher string and do a last check ...
                        #
                        my %in = (); # Hold input fields ....
                        for my $iii ( keys( %{$r_hg->{$cg}{'field'}} ) ) {
                            my $f = $r_hg->{$cg}{'field'}{$iii};
                            if ( $iii =~ m/::gen/ ) { # Treat ::gen specially
                                $f =~ s/\$$rv/\\\$$rv/g; # Replace $V by \$V ....
                                $f = "G # $rv = $mres{$rv} #" . $f;
                            } else {
                                $f =~ s/\$(\d+)/\$mres{$1}/g; # replace $N by $mres{'N'}
                                $f =~ s/\$$rv/$mres{$rv}/g;    # Replace the run variable by it's value
                                # $f =~ tr/{}/()/;                     # Replace {} by (), which will be evaluated
                                $f =~s/{/" . (/g;
                                $f =~s/}/) . "/g;       #TODO: make sure {} do match!!
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
    
=cut

sub add_portsig () {

    # my %seen = (); # Remember instances already visited.
    
    for my $signal ( keys( %conndb ) ) {
        my %connected = (); # List of connected instanc nodes
        my %modes = ();
        my @addup = ();

        if ( $signal eq "" ) { #Fatal error!
            logdie( "Detecting signal without name in add_portsig! Check CONN sheet!");
            next;
        }
        
        # Skip HIGH/LOW
        if ( $signal =~ m/^\s*%(HIGH|LOW)/o ) { next; }
        #
        # Skip if signal mode equals Constant or Generic
        # Constant and Generics should not extend port map!
        #
        my $mode = $conndb{$signal}{'::mode'};
        
        if ( $mode and ( $mode eq 'C' or $mode eq 'G' ) ) {
            next;
        }

        for my $i ( 0..$#{$conndb{$signal}{'::in'}} ) {
                my $inst = $conndb{$signal}{'::in'}[$i]{'inst'};
                if ( defined ( $hierdb{$inst} ) ) {
                    $connected{$inst} = $hierdb{$inst}{'::treeobj'}; # Tree::DAG_Node objects
                    $modes{$inst} .= ":in:$i"; # Remember in/out columns
                }
        }
        for my $i ( 0..$#{$conndb{$signal}{'::out'}} ) {
                my $inst = $conndb{$signal}{'::out'}[$i]{'inst'};
                if ( defined ( $hierdb{$inst} )) {
                    $connected{$inst} = $hierdb{$inst}{'::treeobj'}; # Tree::DAG_Node objects
                    $modes{$inst} .= ":out:$i";
                }
        }
        
        my $commonpar = my_common( values( %connected ) );
        unless ( defined( $commonpar ) ) {
            logwarn( "ERROR: Signal $signal spawns several seperate trees!\n" );
            next;
            #TODO: How should such a case be handled? Should we add the top node here?
        }
        #
        # now we know the tree top for that signal. The top must not have the
        # signal in his port list ..
        #TODO: check that ..
        #
        # Get all chains from the commonpar node to each of the list and
        # see if they are in the list ... if not: add port!
        #
        for my $leaves ( keys( %connected ) ) {
            my $l = $leaves;
            next if ( $connected{$leaves} eq $commonpar ); # $leaves is the commonpar!
            my $n = $connected{$leaves}->mother;
            while( $n ne $commonpar ) { # Climb up tree
                my $name = $n->name;
                unless( exists( $connected{$name} ) ) {
                    ## ADD port to that module:
                    logtrc( "notice:4" , "Adding port to hierachy module $name for signal $signal!" );
                    push( @addup, [ $signal, $name, $l, $modes{$l} ] );
                }
                $n = $n->mother;
                unless( defined( $n ) ) {
                    logwarn( "ERROR: climb up tree failed for signal $signal!" );
                    last;
                }
            }
        }
        add_port( @addup ); # Add ports to instances as required ...
    }

    #TODO: Print out summary of generated ports ...    
    return;
    
}

#
# add_port: add ports to intermediate instances
#
# Input: array of:
#  [0] = ( $signal, $name, $leave, $mode )
#   $signal := signal name
#   $name := instance name
#   $leave := leaf cell name (where does the signal come from)
#   $mode := ":in:NR:out:NR:in:NR2 ..."  index into instance port map
#
# $leave might be omitted ($mode is sufficient to address the instance/port/bus data
# Will be called for each signal
#
# add bit number to avoid collision in case of busses
sub add_port (@) {
    my @adds = @_;

    for my $r ( @adds ) {
        #
        #TODO: go through that data and check for consistency!!
        # So far we did not consider if the signal definitions match and
        # how that fits together.
        #
        my ( $s, $n, $l, $m ) = @$r;
        while( $m =~ m,:(in|out):(\d+),og ) {
            my $mi = $2;
            my $mo = "::" . $1;
            my $dir = uc( substr( $1, 0 ,1 ) );
            #
            # Get template for that signal
            #
            my $cell = $conndb{$s}{$mo};   # Reference to ::in|::out
            my %templ = %{$cell->[$mi]};
            # Replace child instance name by hierachical instance
            $templ{'inst'} = $n;
            my $sf = "";
            # Make ports different if signal assignment differs ....
            if ( defined ( $templ{'sig_f'} ) ) { 
                $sf = "_" . $templ{'sig_f'};
            }
            my $st = "";
            if ( defined ( $templ{'sig_t'} ) ) { 
                $st = "_" . $templ{'sig_t'};
            }
            # Generate PORT name: MIX_$signal_G[IO].
            $templ{'port'} = "P_MIX_" . $s . $sf . $st . "_G" . $dir; 
            push( @$cell, { %templ } );
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
        logwarn("Warning: trying to match against undef value");
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
                logwarn("Cannot find macro $1 to replace!");
            }
        } elsif( exists( $ehmacs->{$mac} ) ) {
            $$ra =~ s/$mac/$ehmacs->{$mac}/;
        } else {
            logwarn("Cannot locate replacement for $mac in data!");
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

Look through heirachy and connection database and fix up things like:
    instances without name (parentless ...??)
    
=cut
sub purge_relicts () {

    #
    # remove empty entities (e.g. created for entities without parents ...)
    #
    for my $i ( keys( %hierdb ) ) {
        unless ( $i ) {
            logwarn("Removing empty instance!");
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
}

#
# strip awy duplicate entries in ::in and ::out
#TODO: combine entries (opposite of split busses)
#
sub _scan_inout ($) {
        my $rsa = shift;

        no warnings; # switch of warnings here, values might be undefined ...
        my %seen = ();
        my @left = ();
        for my $iii ( 0..$#{$rsa} ) {
                my $this = join( ',', values( %{$rsa->[$iii]} ) );
                unless( defined( $seen{$this} ) ) {
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
        unless ( exists( $hierdb{$inst} ) )  {
                unless ( $conndb{$conn}{'::mode'} =~ m,^\s*(C), ) {
                    logwarn("Skipping connection $conn to undefined instance $inst!");
                }
                next; #TODO: Should we try to add that instance?
        }
        my $port = $rsa->[$iii]{'port'};
        unless ( defined( $port ) ) {
                logwarn("Undefined port for connection $conn, instance $inst!");
                $port = "__E_UNDEF_PORT";
        }
        if ( exists( $hierdb{$inst}{'::conn'}{$io}{$conn}{$port} ) ) {
            $hierdb{$inst}{'::conn'}{$io}{$conn}{$port} .= "," . $iii;
        } else {
            $hierdb{$inst}{'::conn'}{$io}{$conn}{$port} = $iii;
        }
    }
}

1;

#!End