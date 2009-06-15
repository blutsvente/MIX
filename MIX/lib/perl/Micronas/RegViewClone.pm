###############################################################################
#  RCSId: $Id: RegViewClone.pm,v 1.16 2009/06/15 11:57:26 lutscher Exp $
###############################################################################
#
#  Revision      : $Revision: 1.16 $                                  
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
#  Contents      :  Module for cloning a register object; used for orthogonal
#                   registers spaces which use the same set of registers a couple
#                   of times in the same register domain. First used in MIC32 
#                   project.
#        
###############################################################################
#                               Copyright
###############################################################################
#
#       Copyright (C) 2006 Micronas GmbH, Munich, Germany 
#
#     All rights reserved. Reproduction in whole or part is prohibited
#          without the written permission of the copyright owner.
#
###############################################################################
#                                History
###############################################################################
#
#  $Log: RegViewClone.pm,v $
#  Revision 1.16  2009/06/15 11:57:26  lutscher
#  added addrmaps member to Reg and RegDomain
#
#  Revision 1.15  2008/12/10 18:00:10  lutscher
#  small fix concerning unique_domains parameter
#
#  Revision 1.14  2008/12/10 13:12:21  lutscher
#  added domain_naming and feature unique_domains
#
#  Revision 1.13  2008/07/07 14:23:13  lutscher
#  added %B option for _clone_name()
#
#  Revision 1.12  2007/09/05 10:56:23  lutscher
#  set default clone.number to 0 because 1 will now force 1 clone
#
#  Revision 1.11  2007/08/23 13:32:23  lutscher
#  commented out a logfilter, not needed anymore
#
#  Revision 1.10  2007/08/10 08:42:18  lutscher
#  o some fixes for the case that the register space contains more than one domain
#  o store some cloning information in the domain and the cloned fields
#
#  Revision 1.9  2006/11/20 17:09:13  lutscher
#  moved _clone_name() to RegUtils.pm
#
#  Revision 1.8  2006/09/22 09:17:07  lutscher
#  added clone attribute handling to exempt registers from cloning
#
#  Revision 1.7  2006/09/11 06:33:20  lutscher
#  changed debug output
#
#  Revision 1.6  2006/08/28 14:09:15  lutscher
#  added cloning of update signals
#
#  Revision 1.5  2006/07/20 10:57:03  lutscher
#  major changes, renamed methods and regrouped code
#
#  Revision 1.4  2006/07/06 11:59:56  lutscher
#  fixed _clone_regspace()
#
#  Revision 1.3  2006/07/06 09:56:29  lutscher
#  changed how to deal with embedded_reg
#
#  Revision 1.2  2006/06/22 12:20:14  lutscher
#  fixed a typo
#
#  Revision 1.1  2006/06/22 11:45:43  lutscher
#  added new view HDL-vgch-rs-clone and package RegViewClone
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
# Creates a new Reg object that contains clones of the original Reg object, whereby Fields and Registers
# get new names according to user-defined naming schemes. Domains are not changed. 
# input: optionally takes a list of domain names as parameters or commandline option(s) -domain: if nothing is specified,
# clones all domains;
# output: object of class Reg
sub _clone {
	my $this = shift;
	my $href;
	my ($domain, $o_domain, @ldomain_names);
    
    @ldomain_names = ();
    if (@_) {
        @ldomain_names = @_;
    };

    # call init function of HDL-vgch-rs view (RegViews.pm) because we need the parameters
    $this->_vgch_rs_init();

	# extend class data with data structure needed for code generation
	#$this->global(
	#			  'debug'              => 0,
	#			  'indent'             => "    "       # indentation character(s)
	#			 );
	
	# import regshell.<par> parameters from MIX package to class data; user can change these parameters in mix.cfg
	my $param;
	my @lmixparams = ('reg_shell.clone.number',        # number of clones
					  'reg_shell.clone.addr_spacing',  # number of address bits reserved for every clone
					  'reg_shell.clone.reg_naming',    # naming scheme for cloned registers
					  'reg_shell.clone.field_naming',  # naming scheme for cloned fields
					  'reg_shell.clone.domain_naming', # naming scheme for cloned domains
					  'reg_shell.clone.unique_clocks', # if 1, uniquify clock names of clones
                      'reg_shell.clone.unique_domains' # if 1, will create new domains for clones
					 );

	foreach $param (@lmixparams) {
		my ($main, $sub, $subsub) = split(/\./,$param);
		if (ref $eh->get("${main}.${sub}")) {
			$this->global($subsub => $eh->get("${main}.${sub}.${subsub}"));
			_info("setting parameter $param = ", $this->global->{$subsub}) if $this->global->{'debug'};
		} elsif (defined $eh->get("${main}.${sub}")) {
			$this->global($sub => $eh->get("${main}.${sub}"));
			_info("setting parameter $param = ", $this->global->{$sub}) if $this->global->{'debug'};
		} else {
			_error("parameter \'$param\' unknown");
		};
	};

	# changes logger settings
	#$eh->set('log.limit.re.__I_CHECK_CASE',1);
	#$eh->set('log.limit.re.__I_REG\sfield\sname ', 1);

	# make list of domain names for generation if not passed as parameter
    if (!scalar(@ldomain_names)) {
        if (exists $OPTVAL{'domain'}) {
            push @ldomain_names, $OPTVAL{'domain'};
        } else {
            foreach $href (@{$this->domains}) {
                push @ldomain_names, $href->{'name'};
            };
        };
	};
    
    # make it so
    my $o_new_space = $this->_clone_regspace(\@ldomain_names);
    
	return $o_new_space;
};

# create new $o_space object from this Reg object
# input: list of domain names that are cloned
sub _clone_regspace {
	my ($this, $lref_domain_names) = @_;
	my ($o_domain1, $o_reg0, $o_reg1, $href, $o_field0, $o_field1, %hfattribs, %hrattribs, $fpos);
	my ($n, $reg_offset, $fclock, $freset, $baseaddr);
	my ($last_addr) = -1;
    my ($o_domain0);
    my (@lalldomains);
    # create a new register space
    my ($o_space) = Micronas::Reg->new(device => $this->device);		

    # get list of all domains
    foreach $href (@{$this->domains}) {
        push @lalldomains, $href;
    };
    # iterate through all domains
    foreach $o_domain0 (@lalldomains) {
        my ($domain) = $o_domain0->name;
        my %hclone_once = ();
        
        if (grep($domain eq $_, @{$lref_domain_names})) { 
            _info("cloning domain $domain ", $this->global->{'number'}, " times, unique_clocks=", $this->global->{'unique_clocks'},", unique_domains=", $this->global->{'unique_domains'});
            if ($this->global->{'number'} eq 1) {
                _warning("number of clones is 1, applying naming scheme - make sure this is what you intended");
            };

            if ($this->global->{'unique_domains'} == 0) {
                # create a new domain using the old name, containing all clones, storing some cloning information
                $o_domain1 = Micronas::RegDomain->new('name' => $domain, 
                                                      'clone' => {
                                                                  'number'        => $this->global->{'number'}, 
                                                                  'field_naming'  => $this->global->{'field_naming'},
                                                                  'domain_naming' => $this->global->{'domain_naming'},
                                                                  'reg_naming'    => $this->global->{'reg_naming'},
                                                                  'addr_spacing'  => $this->global->{'addr_spacing'},
                                                                  'unique_clocks' => $this->global->{'unique_clocks'}
                                                                 }
                                                     );
                # link domain into new register space object
                $o_space->add_domain($o_domain1, 0x0);
            };

            for ($n=0; $n< $this->global->{'number'}; $n=$n+1) {
                if ($this->global->{'unique_domains'} == 0) {
                    $baseaddr = $n * (2 ** $this->global->{'addr_spacing'});
                    if ($baseaddr <= $last_addr) {
                        _error("overlapping address ranges for cloned domain \'$domain\', check config parameter addr_spacing");
                    }
                } else {
                    $baseaddr = 0;
                    my $new_domain_baseaddr =  $n * (2 ** $this->global->{'addr_spacing'});
                    if ($new_domain_baseaddr <= $last_addr) {
                        _error("overlapping address ranges for cloned domain \'$domain\', check config parameter addr_spacing");
                    }
                    my $new_domain_name=_clone_name($this->global->{'domain_naming'}, 99, $n, $domain); # apply domain-naming rule
                    # create a new domain for each clone, storing some cloning information
                    $o_domain1 = Micronas::RegDomain->new('name' => $new_domain_name, 
                                                          'clone' => {
                                                                      'number'        => $this->global->{'number'}, 
                                                                      'field_naming'  => $this->global->{'field_naming'},
                                                                      'domain_naming' => $this->global->{'domain_naming'},
                                                                      'reg_naming'    => $this->global->{'reg_naming'},
                                                                      'addr_spacing'  => $this->global->{'addr_spacing'},
                                                                      'unique_clocks' => $this->global->{'unique_clocks'}
                                                                     }
                                                         );
                    # link domain into new register space object
                    $o_space->add_domain($o_domain1, $new_domain_baseaddr);
                };
              
                # iterate original register space and build up new register space
                foreach $o_reg0 (sort {$o_domain0->get_reg_address($a) <=> $o_domain0->get_reg_address($b)} @{$o_domain0->regs}) {
                    $reg_offset = $baseaddr + $o_domain0->get_reg_address($o_reg0);	
                    %hrattribs = %{$o_reg0->attribs};
                    
                    my $reg_name;
                    # check if cloning is enabled; if not, clone only once (copy of original)
                    if ($o_reg0->attribs->{'clone'}==0) {
                        # clone reg only once if attribute is 0
                        if (!exists($hclone_once{$o_reg0->name})) {
                            # register is cloned unchanged
                            $reg_name = $o_reg0->name;
                            $hclone_once{$o_reg0->name} = 1;
                        } else {
                            next;
                        };
                    } else {
                        $reg_name = _clone_name($this->global->{'reg_naming'}, $this->global->{'number'}-1, $n, $domain, $o_reg0->name);
                    };
                    # create new register object
                    $o_reg1 = Micronas::RegReg->new('name' => $reg_name, 'definition' => $o_reg0->definition, 'inst_n' => $n);
                    
                    # copy attributes into register
                    $o_reg1->attribs(%hrattribs);
                    
                    # link new register object into domain
                    $o_domain1->add_reg($o_reg1, $reg_offset);
                    
                    # iterate through all fields of the register
                    foreach $href (sort {$a cmp $b} @{$o_reg0->fields}) {
                        $o_field0 = $href->{'field'}; # reference to field object in register
                        
                        my $field_name;
                        # if field is part of a non-cloned register, use unchanged name 
                        $field_name = $o_reg0->attribs->{'clone'} == 0 ? $o_field0->name : _clone_name($this->global->{'field_naming'}, $this->global->{'number'}-1, $n, $domain, $o_reg0->name, $o_field0->name, $o_field0->attribs->{'block'});
                        
                        $fpos = $href->{'pos'};       # lsb position of field in register
                        %hfattribs = %{$o_field0->attribs};
                        
                        # uniquify clock and reset names if desired
                        if ($this->global->{'unique_clocks'}) {
                            $hfattribs{'clock'} = $hfattribs{'clock'} . _clone_name("_%N", $this->global->{'number'}-1, $n);
                            $hfattribs{'reset'} = $hfattribs{'reset'} . _clone_name("_%N", $this->global->{'number'}-1, $n);
                        };
                        
                        # uniquify update signal
                        if (lc($hfattribs{'sync'}) ne "nto" and $hfattribs{'sync'} !~ m/[\%OPEN\%|\%EMPTY\%]/) {
                            $hfattribs{'sync'} = $hfattribs{'sync'} . _clone_name("_%N", $this->global->{'number'}-1, $n);
                        };
                        
                        # create new field object, saving original name and instance number
                        $o_field1 = Micronas::RegField->new('name' => $field_name, 'reg' => $o_reg1, 'definition' => $o_field0->definition, 'inst_n' => $n, 'org_name' => $o_field0->name);
                        
                        # copy attributes into field
                        $o_field1->attribs(%hfattribs);
                        
                        # link field into domain
                        $o_domain1->fields($o_field1);
                        
                        # link field into register
                        $o_reg1->fields(field => $o_field1, pos => $fpos);
                    };
                    # $o_reg1->display();
                };
                $last_addr = $reg_offset;
            };
        } else {
            # don't clone, just copy
            _info("copying domain $domain");
            $o_space->add_domain($o_domain0, $this->get_domain_baseaddr($domain));
        };
    };
    return $o_space;
};

1;
