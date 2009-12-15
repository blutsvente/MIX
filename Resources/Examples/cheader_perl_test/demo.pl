eval 'exec perl -S $0 ${1+"$@"}'
if 0;
###############################################################################
#  RCSId: $Id: template_main.pl,v 1.3 2009/06/02 12:37:21 lutscher Exp $
###############################################################################
#                                
#  Related Files :  <none>
#
#  Author(s)     :  Thorsten Lutscher                                      
#  Email         :  thorsten.lutscher@micronas.com                          
#
#  Project       :  <none>                                                 
#
#  Creation Date :  15.02.2002
#
#  Contents      :  see usage below
#
###############################################################################
#                               Copyright
###############################################################################
#
#       Copyright (C) 2009 Trident Microsystems (Europe), Munich, Germany 
#
#     All rights reserved. Reproduction in whole or part is prohibited
#          without the written permission of the copyright owner.
#
###############################################################################
#                                History
###############################################################################
#
#  $Log: template_main.pl,v $
#  
###############################################################################

#------------------------------------------------------------------------------
# Global variables
#------------------------------------------------------------------------------
our($debug, $this, $usage, %hopts);

#------------------------------------------------------------------------------
# Used packages, initialisation, commandline parameters etc.
#------------------------------------------------------------------------------
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use lib "$Bin/lib";
use lib "$Bin/include";
use Getopt::Std;
use File::Basename;
# use Cwd;
# use Data::Dumper

use reg_ip3d qw($o_space1);   # import the serialized register object

BEGIN {
   $debug=1;     # debug mode off = 0, on = 1

   # initialisation and get commandline arguments
   $this = basename($0);

   $usage="
Usage        : $this [-h]
Description  : demo for using the MIX view \"perl\"
Options      : h - show help
";

   # sanity check
   my $wanttype = "Micronas::Reg";
   ref($o_space1) eq $wanttype || die "imported object is not of class $wanttype";

   getopts('h', \%hopts);

   if (exists $hopts{'h'}) { print $usage; exit 1 };
};

#------------------------------------------------------------------------------
# Main part of script
#------------------------------------------------------------------------------

# print some info on the main object
printf("device: %s default address-map name: %s\n", 
       $o_space1->device, 
       $o_space1->default_addrmap
      );

# iterate through all domains and print their object type and name and base-address
foreach my $o_domain (@{$o_space1->domains}) {
    printf("(%s) %-20s 0x%x\n",
           ref($o_domain), 
           $o_domain->name,
           $o_space1->get_domain_baseaddr($o_domain->name)
          );
};


#------------------------------------------------------------------------------
# Subroutines
#------------------------------------------------------------------------------

1;
