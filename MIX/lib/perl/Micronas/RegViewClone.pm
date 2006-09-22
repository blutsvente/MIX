###############################################################################
#  RCSId: $Id: RegViewClone.pm,v 1.8 2006/09/22 09:17:07 lutscher Exp $
###############################################################################
#
#  Revision      : $Revision: 1.8 $                                  
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
# output: object of class Reg
sub _clone {
	my $this = shift;
	my $href;
	my ($domain, $o_domain, @ldomains);

    # call init function of HDL-vgch-rs view (RegViews.pm) because we need the parameters
    $this->_vgch_rs_init();

	# extend class data with data structure needed for code generation
	#$this->global(
	#			  'debug'              => 0,
	#			  'indent'             => "    "       # indentation character(s)
	#			 );
	
	# import regshell.<par> parameters from MIX package to class data; user can change these parameters in mix.cfg
	my $param;
	my @lmixparams = ('reg_shell.clone.number',       # number of clones
					  'reg_shell.clone.addr_spacing', # number of address bits reserved for every clone
					  'reg_shell.clone.reg_naming',   # naming scheme for cloned registers/fields
					  'reg_shell.clone.field_naming', # naming scheme for cloned registers/fields
					  'reg_shell.clone.unique_clocks' # if 1, uniquify clock names of clones
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
	$eh->set('log.limit.re.__I_REG\sfield\sname ', 1);

	# make list of domains for generation
	if (exists $OPTVAL{'domain'}) {
        push @ldomains, $this->find_domain_by_name_first($OPTVAL{'domain'});
	} else {
		foreach $href (@{$this->domains}) {
			push @ldomains, $href->{'domain'};
		};
	};
    
    # make it so
    my $o_new_space = $this->_clone_regspace(\@ldomains);
    
	return $o_new_space;
};

# create new $o_space object from this Reg object
sub _clone_regspace {
	my ($this, $lref_domains) = @_;
	my ($o_domain1, $o_reg0, $o_reg1, $href, $o_field0, $o_field1, %hfattribs, %hrattribs, $fpos);
	my ($n, $reg_offset, $fclock, $freset, $baseaddr);
	my ($last_addr) = -1;
    my ($o_domain0);
    
    # create a new register space
    my ($o_space) = Micronas::Reg->new;		
    
    # iterate through all domains
    foreach $o_domain0 (@{$lref_domains}) {
        my ($domain) = $o_domain0->name;
        my %hclone_once = ();
        
        _info("cloning domain $domain ", $this->global->{'number'}, " times");
     
        # create a new domain
        $o_domain1 = Micronas::RegDomain->new('name' => $domain);
        
        # link domain into new register space object
        $o_space->domains('domain' => $o_domain1, 'baseaddr' => 0x0);
        
        for ($n=0; $n< $this->global->{'number'}; $n=$n+1) {
            $baseaddr = $n * (2 ** $this->global->{'addr_spacing'});
            if ($baseaddr <= $last_addr) {
                _error("overlapping address ranges for cloned domain \'$domain\', check config parameter addr_spacing");
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
                    $reg_name = $this->_clone_name($this->global->{'reg_naming'}, $n, $domain, $o_reg0->name, "");
                };
                # create new register object
                $o_reg1 = Micronas::RegReg->new('name' => $reg_name, 'definition' => $o_reg0->definition);

                # copy attributes into register
                $o_reg1->attribs(%hrattribs);
                
                # link new register object into domain
                $o_domain1->regs($o_reg1);
                $o_domain1->addrmap('reg' => $o_reg1, 'offset' => $reg_offset);
                
                # iterate through all fields of the register
                foreach $href (sort {$a cmp $b} @{$o_reg0->fields}) {
                    $o_field0 = $href->{'field'}; # reference to field object in register
                    
                    my $field_name;
                    # if field is part of a non-cloned register, use unchanged name 
                    $field_name = $o_reg0->attribs->{'clone'} == 0 ? $o_field0->name : $this->_clone_name($this->global->{'field_naming'}, $n, $domain, $o_reg0->name, $o_field0->name);
                    
                    $fpos = $href->{'pos'};       # lsb position of field in register
                    %hfattribs = %{$o_field0->attribs};
                    
                    # uniquify clock and reset names if desired
                    if ($this->global->{'unique_clocks'}) {
                        $hfattribs{'clock'} = $hfattribs{'clock'} . $this->_clone_name("_%N", $n);
                        $hfattribs{'reset'} = $hfattribs{'reset'} . $this->_clone_name("_%N", $n);
                    };

                    # uniquify update signal
                    if (lc($hfattribs{'sync'}) ne "nto" and $hfattribs{'sync'} !~ m/[\%OPEN\%|\%EMPTY\%]/) {
                        $hfattribs{'sync'} = $hfattribs{'sync'} . $this->_clone_name("_%N", $n);
                    };
                    
                    # create new field object
                    $o_field1 = Micronas::RegField->new('name' => $field_name, 'reg' => $o_reg1, 'definition' => $o_field0->definition);
                    
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
    };
    return $o_space;
};

# create a new name according to $pattern (see Globals.pm)
sub _clone_name {
	my ($this, $pattern, $n, $domain, $reg, $field) = @_;
	
	$pattern =~ s/[\'\"]//g; # strip quotes from pattern

    # create a number padded with leading zeros
	my($digits) = $this->global->{'number'} < 10 ? 1 : ($this->global->{'number'} < 100 ? 2 : ($this->global->{'number'} < 1000 ? 3 : 4)); # max 4 digits, should be enough (or we would never have had the Millenium Bug)
	$digits = sprintf("%0${digits}d", $n);

    # take the pattern and fill in the passed object names
	my($name) = $pattern;
	$name =~ s/%D/$domain/g;
	$name =~ s/%R/$reg/g;
	$name =~ s/%F/$field/g;
	$name =~ s/%N/$digits/g;
	return $name;
};

1;
