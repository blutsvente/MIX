###############################################################################
#  RCSId: $Id: RegViewClone.pm,v 1.2 2006/06/22 12:20:14 lutscher Exp $
###############################################################################
#
#  Revision      : $Revision: 1.2 $                                  
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
#  Contents      :  Like the RegView.pm module but takes a Reg Object as template
#                   to generate <n> identical clones in the same domain; used in
#                   MIC32 project
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
#  Revision 1.2  2006/06/22 12:20:14  lutscher
#  fixed a typo
#
#  Revision 1.1  2006/06/22 11:45:43  lutscher
#  added new view HDL-vgch-rs-clone and package RegViewClone
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

#------------------------------------------------------------------------------
# view: HDL-vgch-rs-clone

# Main entry function of this module;
# input: domain names for which Verilog files are generated; if omitted, 
# will consider ALL register space domains in the Reg object;
# output: 0 in case of non-recoverable error, 1 otherwise
sub _gen_view_vgch_rs_clone {
	my $this = shift;
	my $href;
	my @lexclude_regs;
	my ($domain, $o_domain, @ldomains);

	# extend class data with data structure needed for code generation
	$this->global(
				  'debug'              => 0,
				  'indent'             => "    "       # indentation character(s)
				 );
	
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
			_info("setting parameter $param = ", $this->global->{$subsub});
		} elsif (defined $eh->get("${main}.${sub}")) {
			$this->global($sub => $eh->get("${main}.${sub}"));
			_info("setting parameter $param = ", $this->global->{$sub});
		} else {
			_error("parameter \'$param\' unknown");
		};
	};

	# changes logger settings
	#$eh->set('log.limit.re.__I_CHECK_CASE',1);
	$eh->set('log.limit.re.__I_REG\sfield\sname ', 1);

	# make list of domains for generation
	if (scalar (@_)) {
		foreach $domain (@_) {
			push @ldomains, $this->find_domain_by_name_first($domain);
		};
	} else {
		foreach $href (@{$this->domains}) {
			push @ldomains, $href->{'domain'};
		};
	};

	# iterate through all template domains
	foreach $o_domain (@ldomains) {
		$domain = $o_domain->name;

		# make it so
		my $o_new_space = $this->_clone_regspace($o_domain);
		
		# for debug only
		$o_new_space->display() if ($this->global->{'debug'});
		
		# generate Verilog register-shell
		$o_new_space->_gen_view_vgch_rs($domain);
	};
	1;
};

# create new $o_space object from this Reg object
sub _clone_regspace {
	my ($this, $o_domain0) = @_;
	my ($o_domain1, $o_reg0, $o_reg1, $href, $o_field0, $o_field1, %hfattribs, %hrattribs, $fpos);
	my ($n, $reg_offset, $fclock, $freset, $baseaddr);
	my ($last_addr) = -1;
	my ($domain) = $o_domain0->name;

	_info("cloning domain $domain ", $this->global->{'number'}, " times");
	# create a new register space
	my ($o_space) = Micronas::Reg->new;		

	# create the new domain
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
			
			# create new register object
			my $reg_name = $this->_clone_name($this->global->{'reg_naming'}, $n, $domain, $o_reg0->name, "");
			$o_reg1 = Micronas::RegReg->new('name' => $reg_name, 'definition' => $o_reg0->definition);
			$o_reg1->attribs(%hrattribs);
			
			# link new register object into domain
			$o_domain1->regs($o_reg1);
			$o_domain1->addrmap('reg' => $o_reg1, 'offset' => $reg_offset);
			
			# iterate through all fields of the register
			foreach $href (sort {$a cmp $b} @{$o_reg0->fields}) {
				$o_field0 = $href->{'field'}; # reference to field object in register
				my $field_name = $this->_clone_name($this->global->{'field_naming'}, $n, $domain, $o_reg0->name, $o_field0->name);
				$fpos = $href->{'pos'};       # lsb position of field in register
				%hfattribs = %{$o_field0->attribs};
				
				# uniquify clock and reset names if desired
				if ($this->global->{'unique_clocks'}) {
					$hfattribs{'clock'} = $hfattribs{'clock'} . $this->_clone_name("_%N", $n);
					$hfattribs{'reset'} = $hfattribs{'reset'} . $this->_clone_name("_%N", $n);
				};
				
				# create new field object
				$o_field1 = Micronas::RegField->new('name' => $field_name, 'reg' => $o_reg1, 'definition' => $o_field0->definition);
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
	return $o_space;
};

# create a new name according to $pattern (see Globals.pm)
sub _clone_name {
	my ($this, $pattern, $n, $domain, $reg, $field) = @_;
	
	$pattern =~ s/[\'\"]//g; # strip quotes from pattern

	my($digits) = $this->global->{'number'} < 10 ? 1 : ($this->global->{'number'} < 100 ? 2 : ($this->global->{'number'} < 1000 ? 3 : 4)); # max 4 digits, should be enough
	$digits = sprintf("%0${digits}d", $n);
	my($name) = $pattern;
	$name =~ s/%D/$domain/g;
	$name =~ s/%R/$reg/g;
	$name =~ s/%F/$field/g;
	$name =~ s/%N/$digits/g;
	return $name;
};

1;
