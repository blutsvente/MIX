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
# | Revision:   $Revision: 1.1 $                                          |
# | Author:     $Author: abauer $                                         |
# | Date:       $Date: 2003/12/05 11:49:43 $                              |
# |                                                                       |
# | Copyright Micronas GmbH, 2003                                         |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/Attic/MixI2CParser.pm,v 1.1 2003/12/05 11:49:43 abauer Exp $ |
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

my $thisid		= 	'$Id: MixI2CParser.pm,v 1.1 2003/12/05 11:49:43 abauer Exp $';
my $thisrcsfile	        =	'$RCSfile: MixI2CParser.pm,v $';
my $thisrevision        =       '$Revision: 1.1 $';

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

    foreach my $i (@$r_i2c) {

        next if ( $i->{'::ign'} =~ m,^\s*(#|\\),); # Skip comments, just in case they sneak in

        add_i2c( $i);
    }

    return 0;
}


####################################################################
## add_iic
####################################################################
sub add_i2c(%) {

    my $in = shift;

    my $sub_addr = $in->{'::sub'};

    #
    # strip of leading and trailing whitespace
    #
}


####################################################################
## merge_reg
####################################################################

=head1

    merge definitions for the same sub-address, specified in different lines.

=cut

sub merge_reg(%) {

    my $in = shift;
}


####################################################################
## create_reg
####################################################################

=head1

    create new i2c register

=cut

sub create_reg(%) {

    my $in = shift;
}
