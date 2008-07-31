###############################################################################
#  RCSId: $Id: RegPacking.pm,v 1.1 2008/07/31 09:03:44 lutscher Exp $
###############################################################################
#
#  Revision      : $Revision: 1.1 $                                  
#
#  Related Files :  Reg.pm
#
#  Author(s)     :  Thorsten Lutscher                                      
#  Email         :  thorsten.lutscher@micronas.com                          
#
#  Project       :  MIX                                                 
#
#  Creation Date :  21.06.2006
#
#  Contents      :  Module for packing/unpacking a register object to new registers
#        
###############################################################################
#                               Copyright
###############################################################################
#
#       Copyright (C) 2008 Micronas GmbH, Munich, Germany 
#
#     All rights reserved. Reproduction in whole or part is prohibited
#          without the written permission of the copyright owner.
#
###############################################################################
#                                History
###############################################################################
#
#  $Log: RegPacking.pm,v $
#  Revision 1.1  2008/07/31 09:03:44  lutscher
#  initial release
#
#
#
###############################################################################

package Micronas::Reg;

#------------------------------------------------------------------------------
# Used packages
#------------------------------------------------------------------------------
use strict;
use Data::Dumper;
use Micronas::MixUtils qw($eh);
use Micronas::Reg;
use Micronas::RegDomain;
use Micronas::RegReg;
use Micronas::RegField;
use Micronas::MixUtils::RegUtils;

#------------------------------------------------------------------------------
# Private methods (of class Reg)
#------------------------------------------------------------------------------

# Main entry function of this module;
sub _pack {
	my $this = shift;
    my $href;

    my @ldomain_names = ();
    if (@_) {
        @ldomain_names = @_;
    };

    # call init function of HDL-vgch-rs view (RegViews.pm) because we need the parameters
    $this->_vgch_rs_init();

    # make list of domain names for generation if not passed as parameter
    if (!scalar(@ldomain_names)) {
        if (exists $OPTVAL{'domain'}) {
            push @ldomain_names, $OPTVAL{'domain'};
        } else {
            foreach $href (@{$this->domains}) {
                push @ldomain_names, $href->{'domain'}->{'name'};
            };
        };
	};
    
    # make it so
    my $o_new_space = $this->_pack_regspace(\@ldomain_names);
    
	return $o_new_space;
};

# create new $o_space object from this Reg object
# input: list of domain names that are to be packed/unpacked
sub _pack_regspace {
	my ($this, $lref_domain_names) = @_;
    my $mode = $eh->get('reg_shell.packing.mode');
    my $endianness = $eh->get('reg_shell.packing.endianness'); 
	my ($o_domain1, $o_reg0, $o_reg1, $o_reg2, $href, $o_field0, $o_field1, %hfattribs, %hrattribs, $fpos);
    my @lalldomains = ();

    # create a new register space
    my ($o_space) = Micronas::Reg->new;		

    # get list of all domains
    foreach $href (@{$this->domains}) {
        push @lalldomains, $href->{'domain'};
    };
    
    # iterate through all domains
    foreach my $o_domain0 (@lalldomains) {
        my ($domain) = $o_domain0->name;
        if (grep($domain eq $_, @{$lref_domain_names})) { 
            _info("packing domain $domain with mode ", $mode, " and endianness ", $endianness,"...");
            
            # create a new domain
            $o_domain1 = Micronas::RegDomain->new('name' => $domain,);
            
            # link domain into new register space object
            $o_space->domains('domain' => $o_domain1);
            
            # pack registers, creating new ones
            if ($mode eq "64to32") {
                _warning("no support for integers > 32bit yet");
                foreach $o_reg0 (sort {$o_domain0->get_reg_address($a) <=> $o_domain0->get_reg_address($b)} @{$o_domain0->regs}) {
                    my $reg_offset =  $o_domain0->get_reg_address($o_reg0);
                    my ($offs0, $offs1);
                    # create new register objects
                    ($o_reg1, $o_reg2) = $o_reg0->_pack_64to32();
                    
                    # link new register object and its fields into domain and addrmap
                    if (lc($endianness) eq "little") {
                        ($offs0, $offs1) = ($reg_offset, $reg_offset + 4);
                    } else {
                        ($offs0, $offs1) = ($reg_offset + 4, $reg_offset);
                    };
                    if (ref($o_reg1) =~ m/Micronas::RegReg/) { 
                        $o_domain1->regs($o_reg1);
                        $o_domain1->fields($o_reg1->fields);
                        $o_domain1->addrmap(reg => $o_reg1, offset => $offs0);
                    };
                    if (ref($o_reg2) =~ m/Micronas::RegReg/) { 
                        $o_domain1->regs($o_reg2);
                        $o_domain1->fields($o_reg2->fields);
                        $o_domain1->addrmap(reg => $o_reg2, offset => $offs1);
                    };
                };    
            } else {
                _error("unknown packing-mode $mode");
            };
        };
    };
    return $o_space;
};
1;
