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
# | Project:    Micronas - MIX / Checker
# | Modules:    $RCSfile: MixChecker.pm,v $
# | Revision:   $Revision: 1.1 $
# | Author:     $Author: wig $
# | Date:       $Date: 2003/02/25 08:06:52 $
# |
# | Copyright Micronas GmbH, 2003
# | 
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/MixChecker.pm,v 1.1 2003/02/25 08:06:52 wig Exp $                                                         |
# +-----------------------------------------------------------------------+
#
# The functions here provide the checking capabilites for the MIX project.
# Accepts the intermediate (aka. final connection and hierachy description)
# and check if everything against your company design guide lines
# Through plug-ins you can add checks at will
#
# +-----------------------------------------------------------------------+
# |
# | Changes:
# | $Log: MixChecker.pm,v $
# | Revision 1.1  2003/02/25 08:06:52  wig
# | Checks are located here.
# |
# |
# +-----------------------------------------------------------------------+
package  Micronas::MixChecker;

require Exporter;

  @ISA = qw(Exporter);
  @EXPORT = qw(

    );            # symbols to export by default
  @EXPORT_OK = qw(
    );

our $VERSION = '0.01'; # TODO: use the RCS info

use strict;
# use vars qw();

# Caveat: relies on proper setting of base, pgmpath and dir in main program!
use lib "$main::base/";
use lib "$main::base/lib/perl";
use lib "$main::pgmpath/";
use lib "$main::pgmpath/lib/perl";
use lib "$main::dir/lib/perl";
use lib "$main::dir/../lib/perl";

use Log::Agent;
use Log::Agent::Priorities qw(:LEVELS);
use Tree::DAG_Node; # tree base class

# use Micronas::MixUtils qw( mix_store db2array write_excel %EH );
use Micronas::MixParser qw( %hierdb %conndb );

#
# Prototypes
#


# Internal variable

#
# RCS Id, to be put into output templates
#
my $thisid		=	'$Id: MixChecker.pm,v 1.1 2003/02/25 08:06:52 wig Exp $';
my $thisrcsfile	=	'$RCSfile: MixChecker.pm,v $';

$thisid =~ s,\$,,go;
$thisrcsfile =~ s,\$,,go;

#
# Start checks
#

####################################################################
## mix_check_cases
## if configuration says so, make everything lower or upper case!
## Or just inform about possible conflicts.
####################################################################

=head2

mix_check_cases () {

Check if cases match. Depending on the value of the configuration value
<I check.case> do the following:

=over 4

=item no

Do nothing. Keep case as is.

=item check2lc

Just check if everything is written in lower case. Report possible conflicts.
Write at INFO level for objects with bad cases, but without conflicts.
Write at WARNING level if a real case conflict is detected.

=item force2lc

Change all objects to lower case. Possible conflicts will get reported.
Conflicts will be resolved by brute force.

=item check2uc

Upper case checks.

=item force2uc

Lower case checks.

=back

You can add a "f" before uc or lc to imply that the first character will be in a
different case.

Caveat: Most of the possibilities here are not implemented today.

=cut

mix_check_cases () {

    return;

}
1;

#!End