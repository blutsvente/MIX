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
# | Project:    Micronas - MIX / I2CParser                                |
# | Modules:    $RCSfile: MixI2CParser.pm,v $                             |
# | Revision:   $Revision: 1.2 $                                          |
# | Author:     $Author: abauer $                                         |
# | Date:       $Date: 2003/12/10 10:17:33 $                              |
# |                                                                       |
# | Copyright Micronas GmbH, 2003                                         |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/Attic/MixI2CParser.pm,v 1.2 2003/12/10 10:17:33 abauer Exp $ |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# |    The functions here provide the parsing capabilites for the MIX     |
# |  project. Take a matrix of information in some well-known format and  |
# |     convert it into intermediate format and/or source code files      |
# |   MixI2CParser is spezialized in parsing the I2C description sheet    |
# |    Information about I2C Registers will be converted to connection    |
# |   and hierachy and added to the HIER and CONN databases accordingly.  |
# +-----------------------------------------------------------------------+
#

package Micronas::MixI2CParser;

require Exporter;

@ISA = qw( Exporter);
@EXPORT = qw( parse_i2c_init);            # symbols to export by default
@EXPORT_OK = qw();         # symbols to export on request

our $VERSION = '0.1'; #TODO: fill that from RCS ...

use strict;

# Caveat: relies on proper setting of base, pgmpath and dir in main program!
use lib "$main::base/";
use lib "$main::base/lib/perl";
use lib "$main::pgmpath/";
use lib "$main::pgmpath/lib/perl";
use lib "$main::dir/lib/perl";
use lib "$main::dir/../lib/perl";

use Log::Agent;
use Log::Agent::Priorities qw( :LEVELS);

use Micronas::MixUtils qw( %EH);
use Micronas::MixParser qw( %hierdb %conndb);

####################################################################
## Prototypes:
####################################################################

sub parse_i2c_init($);


####################################################################
## Our local variables
####################################################################
#
# RCS Id, to be put into output templates
#

my $thisid		= 	'$Id: MixI2CParser.pm,v 1.2 2003/12/10 10:17:33 abauer Exp $';
my $thisrcsfile	        =	'$RCSfile: MixI2CParser.pm,v $';
my $thisrevision        =       '$Revision: 1.2 $';

$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?


####################################################################
## parse_i2c_init
## go through I2C sheet(s) and build instances and connections 
####################################################################

=head1

    parse_i2c_init ($)

    Go through data provided by IO sheet and generate instances and connections
    as defined there. Please see the MIX documentation for a description of the
    format. Several columns are required.

  Arg1: input Array

=cut

sub parse_i2c_init($) {

    my $r_i2c = shift;

    my $ehr = $EH{'i2c'}{'field'};

    foreach my $i (@$r_i2c) {

        next if ( $i->{'::ign'} =~ m,^\s*(#|\\),); # Skip comments, just in case they sneak in

        for my $j ( keys %$ehr) {
	    next unless ( $i =~ m/^::/ );
	    next if ( not defined( $i->{$j} ));
	    if( $i->{$j} ne "") {
		$i->{$j} = $ehr->{$i}[3]; # Set to DEFAULT Value
	    }	   
	}			  
	add_i2c_int($i);
    }
    return 0;
}


####################################################################
## add_i2c_int
####################################################################

=head1
    add or merge a new interfaces definition
=cut

sub add_i2c_int(%) {

    my $in = shift;

    my $interface = $in->{'::interface'};

    if( defined $hierdb{$interface}) {
	merge_i2c_int($in);
    }
    else {
	create_i2c_int($in);
    }

    return;
}


####################################################################
## create_i2c_int
####################################################################

=head1
    create a new interface
=cut

sub create_i2c_int(%) {

    my $in = shift;

    # add_subaddr(in);

    return;
}


####################################################################
## merge_i2c_int
####################################################################

=head1
    merge interface definitions
=cut

sub merge_i2c_int(%) {

    my $in = shift;

    return;
}


####################################################################
## add_i2c_
####################################################################

=head1
    creates or merges a new definition of a subaddress
=cut

sub add_subaddr(%) {

    my $in = shift;

    return;
}


####################################################################
## merge_reg
####################################################################

=head1
    merge definitions for the same subaddress, specified in different row.
=cut

sub merge_subaddr($%) {

    my $name = shift;
    my $in = shift;

    my $ehr = $EH{'i2c'}{'field'};

    for my $i ( keys %$ehr) {
        if ( defined( $in->{$i} ) and $in->{$i} ne "" ) { #If it's an empty string -> use default
	    # Todo: combine entries
        }
    }

    return;
}


####################################################################
## create_reg
####################################################################

=head1
    create new i2c register subaddress
=cut

sub create_subaddr($%) {

    my $name = shift;
    my $data = shift;

    my $ehr = $EH{'i2c'}{'field'};


    #
    # Add the rest, too
    #
    #    for my $i( keys( %data ) ) {
    #        $hierdb{$name}{$i} = $data->{$i};
    #    }

    #    add_tree_node( $name, $hierdb{$name} );

    return;
}
