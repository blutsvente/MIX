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
# | Modules:    $RCSfile:  SetEnv.pm                                      |
# | Revision:   $Revision: 1.0                                            |
# | Author:     $Author:   John Armitage                                  |
# | Date:       $Date:     06/22/01                                       |
# |                                                                       |
# | Copyright Cadence Design Systems, 2001                                |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/CDS/Util/SetEnv.pm,v 1.1 2003/02/03 13:18:28 wig Exp $                                                         |
# +-----------------------------------------------------------------------+
#
# +-------------------------------------------------------------+
# |                                                             |
# | PROPRIETARY INFORMATION, PROPERTY OF CADENCE DESIGN SYSTEMS |
# |                                                             |
# +-------------------------------------------------------------+
#

package CDS::Util::SetEnv;

use strict;
use vars qw(
	    $date
	    $user
	    $template_dir
	    $basedir
           );

# These variables are used by various other files.
# They are however, environment dependant and so may
# need to be set differenly depending on the installation.

$date = `date "+%A %d %B %Y"` if ($^O ne "MSWin32");
chomp $date;
$user  = $ENV{USER};
$template_dir = $ENV{TEMPLATE_PATH};
($basedir=$0) =~s;^(.*)[/\\]\w+[/\\][\w\.]+$;$1;g;


1;
