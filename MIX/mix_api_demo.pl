eval 'exec perl -S $0 ${1+"$@"}'
if 0;
###############################################################################
#  RCSId: $Id: mix_api_demo.pl,v 1.1 2009/12/14 10:36:38 lutscher Exp $
###############################################################################
#                                
#  Related Files :  <none>
#
#  Author(s)     :  Thorsten Lutscher                                      
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
#       Copyright (C) 2008 Trident Microsystems (Europe) GmbH, Germany  
#
###############################################################################
#                                History
###############################################################################
#
#  $Log: mix_api_demo.pl,v $
#  Revision 1.1  2009/12/14 10:36:38  lutscher
#  initial release
#
#  Revision 1.2  2008/12/11 09:32:50  lutscher
#
#  
###############################################################################

package Micronas::Mix;
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use lib "$Bin/lib";
use Getopt::Std;
use Data::Dumper;
use Micronas::Mix;
use Micronas::MixUtils qw (%OPTVAL $eh);
use Micronas::MixUtils::RegUtils;

#
# init Mix object and specify commandline options
#
our($mix) = Micronas::Mix->new(options => 
                               [qw(
                                  top=s
                                  variant=s
                                  conf|config=s@
                                  cfg=s
                                  listconf
                                  bak!
                                  init
                                  report=s@
                                  domain=s
                                 )]);

#
# process input
#
$mix->read_input();
$mix->parse_macros();
$mix->parse_hier();
$mix->parse_conn();
$mix->parse_io();
$mix->parse_registers();


#
# user code
#

my ($o_reg, @ldomains, $href, $o_domain);

# get register-space object
my $o_reg = $mix->{reg};
# $o_reg->display();

# get first domain object in list
foreach $href (@{$o_reg->domains}) {
    push @ldomains, $href->{'domain'};
};
$o_domain = $ldomains[0];
# $o_domain->display();



#
# Example code for conn-sheet API functions
#


# create top-level instance
my $top_inst = _add_instance_verilog("top", "testbench", "Top-Level of Buffer Management Unit", "");

# make top-level instance known to the Reg object (the default is "testbench")
$eh->set('reg_shell.virtual_top_instance', $top_inst);


# add clocks/resets
_add_primary_input($eh->get("reg_shell.bus_clock"), 0, 0, $top_inst."/".$eh->get("reg_shell.bus_clock")."%POSTFIX_PORT_IN%");
_add_primary_input($eh->get("reg_shell.bus_reset"), 0, 0, $top_inst."/".$eh->get("reg_shell.bus_reset")."%POSTFIX_PORT_IN%");
_add_primary_input("clk_mci", 0, 0, $top_inst."/"."clk_mci_i");
_add_primary_input("res_mci_n", 0, 0, $top_inst."/"."res_mci_n_i");



#
# generate output files
#
$mix->gen_register_views();
$mix->gen_modules();

my $status = $mix->write_output();
exit $status;

#!End
