#
# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright Cadence Design Systems, Inc. 2001.                        |
# |     All Rights Reserved.       Licensed Software.                     |
# |                                                                       |
# |                                                                       |
# | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF CADENCE DESIGN SYSTEMS |
# | The copyright notice above does not evidence any actual or intended   |
# | publication of such source code.                                      |
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# | Project:    Micronas - IDEAS 2001                                     |
# | Modules:    $RCSfile:  GetOpts.pm                                     |
# | Revision:   $Revision: 1.0                                            |
# | Author:     $Author:   Eyck Jentzsch                                  |
# | Date:       $Date:     06/22/01                                       |
# |                                                                       |
# | Copyright Cadence Design Systems, 2001                                |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/CDS/Util/GetOpts.pm,v 1.1 2003/02/03 13:18:28 wig Exp $                                                         |
# +-----------------------------------------------------------------------+
#
# +-------------------------------------------------------------+
# |                                                             |
# | PROPRIETARY INFORMATION, PROPERTY OF CADENCE DESIGN SYSTEMS |
# |                                                             |
# +-------------------------------------------------------------+
#

package CDS::Util::GetOpts;

require Exporter;

@CDS::Util::GetOpts::ISA = qw(Exporter);
@CDS::Util::GetOpts::EXPORT = qw();
@CDS::Util::GetOpts::EXPORT_OK = qw(
				%OPTVAL
				GetOpts
			       );
our $VERSION = '0.01';

use strict;
use vars qw(%OPTVAL $pgm);

($pgm=$0) =~s;^.*(/|\\);;g;

####################################################################
## used Packages
####################################################################
use Getopt::Long qw(GetOptions);
use Log::Agent;
use Log::Agent::Priorities qw(:LEVELS);
require CDS::Util::MarkedDrv;

####################################################################
## now the functions
####################################################################
sub GetOpts{
  # Application options
  my @appopts = @_;
  # Standard options
  my @stdopts = qw(help|h! 
		   quiet|q! 
		   verbose|v! 
		   debug:i);
  my $status;
  my @ret = ();

  # Get the options
  $Getopt::Long::ignorecase = 0;
  $status =  GetOptions( \%OPTVAL, @stdopts, @appopts);

  # quiet and verbose are exclusive
  undef($OPTVAL{'verbose'}) if(exists($OPTVAL{'quiet'}) && exists($OPTVAL{'verbose'}));
  $OPTVAL{loglvl}=NOTICE;
  # Evaluate options and set log level
  if (defined $OPTVAL{'debug'})  {
    $OPTVAL{loglvl}=DEBUG;
  } elsif (defined $OPTVAL{'verbose'}){
    $OPTVAL{loglvl}=INFO;
  } elsif (defined $OPTVAL{'quiet'} && $OPTVAL{'quiet'} ){
    $OPTVAL{loglvl}=WARN;
  }
  if(exists $OPTVAL{'help'}){
    system("pod2text", $0);
    exit(0);
  }

  logconfig(-driver => CDS::Util::MarkedDrv->make($pgm),
	    -level  => $OPTVAL{loglvl});  # can be NONE, EMERG, ALERT, CRIT, ERROR, WARN, NOTICE, INFO, DEBUG
  
  return($status);
}
################ Package Util::GetOpts ################

1;
