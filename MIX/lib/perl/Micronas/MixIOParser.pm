# -*- perl -*---------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# | 
# |   Copyright Micronas GmbH, Inc. 2002. 
# |     All Rights Reserved. 
# | 
# | 
# | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF MICRONAS GMBH 
# | The copyright notice above does not evidence any actual or intended
# | publication of such source code.
# | 
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# | Project:    Micronas - MIX / IOParser
# | Modules:    $RCSfile: MixIOParser.pm,v $ 
# | Revision:   $Revision: 1.5 $
# | Author:     $Author: wig $
# | Date:       $Date: 2003/07/09 07:52:43 $
# | 
# | Copyright Micronas GmbH, 2003
# | 
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/MixIOParser.pm,v 1.5 2003/07/09 07:52:43 wig Exp $
# +-----------------------------------------------------------------------+
#
# The functions here provide the parsing capabilites for the MIX project.
# Take a matrix of information in some well-known format and convert it into
# intermediate format and/or source code files
# MixIOParser is spezialized in parsing the IO description sheet
# Information about IOcells and Pads will be converted to connection
# and hierachy and added to the HIER and CONN databases accordingly.
#

# +-----------------------------------------------------------------------+
# |
# | Changes:
# | $Log: MixIOParser.pm,v $
# | Revision 1.5  2003/07/09 07:52:43  wig
# | Adding first version of Verilog support.
# | Fixing lots of tiny issues (see TODO).
# | Adding first release of documentation.
# |
# | Revision 1.4  2003/06/05 14:48:01  wig
# | Releasing alpha IO-Parser
# |
# | Revision 1.3  2003/06/04 15:52:43  wig
# | intermediate release, before releasing alpha IOParser
# |
# | Revision 1.2  2003/04/28 06:40:37  wig
# | Added %OPEN% (to allow ports without connection, use VHDL open keyword)
# | Started parseIO (not operational, would be a branch instead)
# | Fixed nreset2 issue (20030424a bug)
# |
# | Revision 1.1  2003/04/01 14:30:19  wig
# | Primary Version of IOParser. Will be the place to read/evalute IO sheets
# |
# |
# +-----------------------------------------------------------------------+

package  Micronas::MixIOParser;

require Exporter;

  @ISA = qw(Exporter);
  @EXPORT = qw(
      parse_io_init
      );            # symbols to export by default
  @EXPORT_OK = qw(
    );         # symbols to export on request
  # %EXPORT_TAGS = tag => [...];  

our $VERSION = '0.01'; #TODO: fill that from RCS ...

use strict;
# use vars qw();

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
# use Tree::DAG_Node; # tree base class

use Micronas::MixUtils qw( %EH );
use Micronas::MixParser;

# Prototypes:
sub parse_io_init ($);
sub get_select_sigs ($);

####################################################################
#
# Our global variables
#  hierdb <- hierachy
#  conndb <- connection matrix

####################################################################
#
# Our local variables

#
# RCS Id, to be put into output templates
#
my $thisid		=	'$Id: MixIOParser.pm,v 1.5 2003/07/09 07:52:43 wig Exp $';
my $thisrcsfile	=	'$RCSfile: MixIOParser.pm,v $';
my $thisrevision   =      '$Revision: 1.5 $';

$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?

####################################################################
## parse_io_init
## go through IO sheet(s) and build instances and connections 
####################################################################

=head2

parse_io_init ($) {

Go through data provided by IO sheet and generate instances and connections
as defined there. Please see the MIX documentation for a description of the
format. Several columns are required.

=cut

sub parse_io_init ($) {
    my $ref = shift;

    my $sel = 0;
    my $selsignals = undef;
    
    foreach my $i ( @$ref ) {
        next if ( $i->{'::ign'} =~ m,^\s*(#|\\), ); # Skip comments, just in case they sneak in

        if ( $i->{'::class'} =~ m,%SEL%,o ) { # Got a selector definition line ...
            # Retrieve selector signal names from the ::muxopt columns
            $selsignals = get_select_sigs( $i );
        } elsif ( $selsignals ) {
            # if this has got ::pad and ::iocell -> create pad and iocell
            if ( $i->{'::pad'} and $i->{'::iocell'} ) {
                mix_iop_padioc( $i );
                mix_iop_iocell( $i, $selsignals );
            } elsif ( $i->{'::pad'} ) {
                mix_iop_pad( $i );
            } else {
                # Upps, empty line???
                logwarn( "WARNING: Bad branch taken in parse_io_init, file bug report!" );
            }

        } else { # We need selsignals ...
            logwarn( "WARNING: Missing SEL line in input for parse_io_init!" );
        }
    }
    
    return 0;

}

#
# Read in a line from the input and create an appropriate IOCELL
# Input: hash_ref with input description, hashref with muxopt's
#
sub mix_iop_iocell ($$) {
    my $r_h = shift;
    my $r_sel = shift;

    my %d = ();

    if ( $r_h->{'::pad'} !~ m,^\s*(\d+)\s*$, ) {
        logwarn( "WARNING: bad ::pad entry $r_h->{'::pad'}, only digits allowed!" );
        $EH{'sum'}{'warnings'}++;
        return 1;
    } else {
        $d{'::inst'} = $1;
        $d{'::pad'} = $1;
    }

    if ( $r_h->{'::iocell'} ) {
        $d{'::inst'} = $r_h->{'::iocell'} . "_" . $d{'::inst'};
        $d{'::entity'} = $r_h->{'::iocell'};
    } else {
        $d{'::inst'} = $EH{'macro'}{'%IOCELL_TYPE%'} . "_" . $d{'::inst'};
    }

    $d{'::class'} = $r_h->{'::class'} || '%PAD_CLASS%';

    $d{'::comment'} = $r_h->{'::comment'} || "";

    # Parent and all other attributes have to come from macros!!
    add_inst( %d );

    # Now to the connections ...
    #
    # Start with the SEL signals
    # Models a 1-hot architecture.
    #
    my $port = $r_sel->{'__PORT__'} || '%IOCELL_SELECT_PORT%'; # Default port name to select.
    for my $s ( keys( %$r_sel ) ) {
        next if ( $s =~ m,^__, );
        my %s = ();
        $s{'::in'} = $d{'::inst'} . "/" . $port;

        # Get the number from muxopt:N ...
        my $n = 0;
        if ( $s eq "::muxopt" ) {
            $n = 0;
        } elsif ( $s =~ m,:(\d+), ) {
            $n = $1;
        }
        my $signal;
        my $nr;
        # select signal is SIGNAL(N) ... or SIGNAL.N
        if ( $r_sel->{$s} =~ m,(.+)\.(\d+), or
            $r_sel->{$s} =~ m,(.+)\((\d+)\), ) {
            $signal = $1;
            $nr = "=(". $2 . ")";
        } else {
            $signal = $r_sel->{$s};
            $nr = "";
        }
        $s{'::name'} = $signal;
        $s{'::in'} .= "(" . $n . ")" . $nr;

        $s{'::low'} = ""; # Don't care
        $s{'::high'} = ""; # Don't care
        $s{'::mode'} = ""; # Don't care (automatically generated later on or inherited)
        $s{'::class'} = "";
        $s{'::clock'} = "";
        $s{'::ign'} = "";
        $s{'::gen'} = "";
        $s{'::comment'} = "IO Generated ";
        
        #TODO: Will we need more information??
        add_conn( %s );
    }

    #
    # Now go through the ::port / ::muxopt matrix for this pad/iocell ...
    #
    mix_iop_connioc( $d{'::inst'}, $r_h, $r_sel );

}

#
# Connect iocells
#
sub mix_iop_connioc ($$$) {
    my $inst = shift;
    my $r_h = shift;
    my $r_sel = shift;

    my @pins = split( /[,\s]+/, $r_h->{'::port'} );

    # Check pin names ....
    foreach my $p ( @pins ) {
        if ( $p =~ m,%reg\(\w+\),io ) {
            logwarn( "WARNING: clocked pad port not handeled now." );
            $p =~ s,%reg\(\w+\),,io;
        }
    }

    # Iterate through all ::muxopt:N ...
    foreach my $s ( keys( %$r_sel ) ) {
        next if ( $s =~ m,^__, );

        unless( exists( $r_h->{$s} ) and defined( $r_h->{$s} ) ) {
            logwarn( "ERROR: Missing muxopt definition for $s, pad nr. $r_h->{'::pad'}!" );
            $EH{'sum'}{'errors'}++;
            next;
        }

        my $n = 0; # Get number of select line ...
        if ( $s eq "::muxopt" ) {
            $n = 0;
        } elsif ( $s =~ m,:(\d+), ) {
            $n = $1;
        }
        
        my @c = split( /,/, $r_h->{$s} );
        map( { s,\s+,,g }  @c ); # Get rid of all kind of whitespace

        if ( scalar( @c ) > scalar( @pins ) ) {
            logwarn( "WARNING: ::muxopt $s has too many signals defined. Pad $r_h->{'::pad'} has " .
                         scalar( @pins ) . "!" );
            $EH{'sum'}{'warnings'}++;
        } elsif ( scalar( @c ) < scalar( @pins ) ) {
            logtrc( "INFO:4", "INFO: muxopt $s not completely defined for pad $r_h->{'::pad'}!" );
            
        }

        # Connect pin with signal ....
        foreach my $c ( 0..(scalar( @c ) -1 ) ) {
            my %d = ();
            my $name = "__E_MISSINGPADNAME";
            my $num = "__E_MISSINGPADNUM";
            if ( $c[$c] =~ m,(.+)\.(\d+)$, or $c[$c] =~ m,(.+)\((\d)\)$, ) {
                $name = $1;
                $num = $2;
            } elsif ( $c[$c] ) {
                $name = $c[$c];
                $num = undef;
            } else {
                next;  # Empty input line
            }
                
            $d{'::name'} = $name;
            $d{'::class'} = $r_h->{'::class'} || "";
            my $io = mix_iop_getdir( $inst, $name );
            # In/out
            if ( $num ) {
                if ( $io =~ m,^in,io ) {
                    $d{'::in'} = $inst . "/" . $pins[$c] . "(" . $n . ")" . "=(" . $num . ")";
                } else {
                    $d{'::out'} = $inst . "/" . $pins[$c] . "(" . $n . ")" . "=(" . $num . ")"; 
                }
            } else {
                if ( $io =~ m,^in,io ) {
                    $d{'::in'} = $inst . "/" . $pins[$c] . "(" . $n . ")";
                } else {
                    $d{'::in'} = $inst . "/" . $pins[$c] . "(" . $n . ")";
                }
            }
            # width??
            $d{'::low'} = ""; # Don't care
            $d{'::high'} = ""; # Don't care
            $d{'::mode'} = ""; # Don't care (automatically generated later on or inherited)
            $d{'::clock'} = "";
            $d{'::ign'} = "";
            $d{'::gen'} = "";
            $d{'::comment'} = "IO Generated ";
        
            add_conn( %d );
        }
    }
}

#
# mix_iop_getdir
# Return in or out, depending on assumed direction of the pin for this
# instance
#
sub mix_iop_getdir ($$) {
    my $inst = shift;
    my $name  = shift;

    #TODO: Define s.th more appropriate ... XXXX
    return( "in" );

}    

#
# Retrieve and convert pad data from input line, create instance ...
# Connections are created by appropriate macros
# Keywords: ::pad, ::type, ::class, ::iocell, ::ispin, ::pin
#
sub mix_iop_padioc ($) {
    my $r_h = shift;

    my %d = ();
    # Pad name
    if ( $r_h->{'::pad'} !~ m,^\s*(\d+)\s*$, ) {
        logwarn( "WARNING: bad ::pad entry $r_h->{'::pad'}, only digits allowed!" );
        return 1;
    } else {
        $d{'::inst'} = $EH{'pad'}{'name'}; # %::name% or %PREFIX_PAD_GEN%_%::pad%
        $d{'::pad'} = $r_h->{'::pad'};
    }

    # Pad entitiy
    if ( $r_h->{'::type'} ) {
        $d{'::entity'} = $r_h->{'::type'};
    } else {
        logwarn( "WARNING: missing ::type entry for pad $r_h->{'::pad'}!" );
        $EH{'sum'}{'warnings'}++;
        $d{'::entity'} = '%PAD_TYPE%';
    }

    $d{'::class'} = $r_h->{'::class'} || '%PAD_CLASS%';

    # Some things we add to the ::comments field:
    foreach my $i ( qw( ::comment ::iocell ::ispin ::pin ) ) {
        if ( exists( $r_h->{$i} ) and $r_h->{$i} ) {
            $d{'::comment'} .= "# $i: $r_h->{$i}";
        }
    }
    # Finally: add this pad ...
    #Caveat: parent and other information has to come from macros defined in the
    # hierachy sheet.
    add_inst( %d );
}

#
# Retrieve and convert pad data from input line, create instance ...
# Connections are created by appropriate macros
# Keywords: ::pad, ::type, ::class, ::iocell, ::ispin, ::pin
#
sub mix_iop_pad ($) {
    my $r_h = shift;

    logwarn("ERROR: mix_iop_pad not implemented!");
    return;

}

#
# retrieve list of select signals from muxopt columns and
# name of select port ...
# returns ref->hash: ::muxopt[:N] => NAME
#
sub get_select_sigs ($) {
    my $r = shift;

    my %s = ();
    my $n = 0;
    foreach my $k ( keys( %$r ) ) {
        if ( $k =~ m,^::muxopt, ) {
            if ( defined( $r->{$k} ) and $r->{$k} ) {
                if ( $r->{$k} =~  m,(\w+)\.(\d+), ) {
                    #  signal.N -> signal(N)
                    $s{$k} = $1 . "(" . $2 . ")";
                } else {
                    $s{$k} = $r->{$k};
                }
                $n++;
            }
        } elsif ( $k =~ m,^::port, ) {
            if ( defined( $r->{$k} ) and $r->{$k} ) {
                $s{'__PORT__'} = $r->{$k};
            }
        }
    }

    $s{'__NR__'} = $n;

    if ( $n == 0 ) {
        logwarn("WARNING: no muxopt column filled with select signals detected!");
    } elsif ( $n == 1 ) {
        logwarn("WARNING: only one muxopt column found!");
    }
    return \%s;
}
 
1;

#!End