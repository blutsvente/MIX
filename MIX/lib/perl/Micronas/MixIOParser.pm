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
# | Revision:   $Revision: 1.1 $
# | Author:     $Author: wig $
# | Date:       $Date: 2003/04/01 14:30:19 $
# | 
# | Copyright Micronas GmbH, 2003
# | 
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/MixIOParser.pm,v 1.1 2003/04/01 14:30:19 wig Exp $
# +-----------------------------------------------------------------------+
#
# The functions here provide the parsing capabilites for the MIX project.
# Take a matrix of information in some well-known format and convert it into
# intermediate format and/or source code files
# MixIOParser is spezialized in parsing the IO description sheet
#

# +-----------------------------------------------------------------------+
# |
# | Changes:
# | $Log: MixIOParser.pm,v $
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

use Micronas::MixUtils;

# Prototypes:
sub parse_io_init ($);

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
my $thisid		=	'$Id: MixIOParser.pm,v 1.1 2003/04/01 14:30:19 wig Exp $';
my $thisrcsfile	=	'$RCSfile: MixIOParser.pm,v $';
my $thisrevision   =      '$Revision: 1.1 $';

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
format. Several columns have to be present.

=cut

sub parse_io_init ($) {
    my $ref = shift;

    return 0;

}


1;

#!End