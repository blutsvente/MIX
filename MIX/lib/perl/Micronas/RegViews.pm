###############################################################################
#  RCSId: $Id: RegViews.pm,v 1.1 2005/07/07 12:35:26 lutscher Exp $
###############################################################################
#                                  
#  Related Files :  Reg.pm
#
#  Author(s)     :  Thorsten Lutscher                                      
#  Email         :  thorsten.lutscher@micronas.com                          
#
#  Project       :  MIX                                                 
#
#  Creation Date :  30.06.2005
#
#  Contents      :  Utility functions to create different register space views
#                   from Reg class object
#        
#
###############################################################################
#                               Copyright
###############################################################################
#
#       Copyright (C) 2005 Micronas GmbH, Munich, Germany 
#
#     All rights reserved. Reproduction in whole or part is prohibited
#          without the written permission of the copyright owner.
#
###############################################################################
#                                History
###############################################################################
#
#  $Log: RegViews.pm,v $
#  Revision 1.1  2005/07/07 12:35:26  lutscher
#  Reg: register space class; represents register space
#  of a device and contains register domains; also contains
#  most of the user API for dealing with register spaces.
#  Contains subclasses (see Reg.pm).
#
#  
###############################################################################

package Micronas::Reg;

#------------------------------------------------------------------------------
# Used packages
#------------------------------------------------------------------------------
use strict;
use Data::Dumper;
use Micronas::MixUtils qw(%EH);
use Micronas::MixParser qw( %hierdb %conndb add_inst add_conn );
use Micronas::Reg;
use Micronas::RegDomain;
use Micronas::RegReg;
use Micronas::RegField;

#use FindBin qw($Bin);
#use lib "$Bin";
#use lib "$Bin/..";
#use lib "$Bin/lib";

#------------------------------------------------------------------------------
# Private methods (of class Reg)
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# view: HDL-vrs

# Generate data structures for the MIX Parser for video register shell generation;
# input: domain name(s) for which the register shell is generated; if omitted, 
# one shell is generated containing all register space domains in the Reg object
sub _gen_view_vrs {
	my $this = shift;
	my @ldomains;
	my $href;

	# make list of domains for generation
	if (scalar (@_)) {
		foreach my $domain (@_) {
			push @ldomains, $this->find_domain_by_name_first($domain);
		};
	} else {
		foreach $href (@{$this->domains}) {
			push @ldomains, $href->{'domain'};
		};
	};

	my ($top_inst, %hconn, $o_domain, $o_field, $o_reg, @lmux_data, @lmux_resp, @lmux_cmdaccept, $reg_id, $signal, $clock, $reset);

	#
	# top-level module
	#
	my $vrs_name = join("_", map $_->{'name'},@ldomains);
	$top_inst = add_inst
	  (
	   '::interface' => $vrs_name,
	   '::inst' => '%PREFIX_INSTANCE%%::interface%%POSTFIX_INSTANCE%',
	   '::entity' => '%::interface%'.$EH{'postfix'}{'POSTFIX_ENTY'},
	   '::descr' => "Video register shell for domain \'".$vrs_name."\'"
	  );

	# extend class data with data structure needed for code generation
	$this->global('lmux_resp' => [],
				  'lmux_data' => [],
				  'lmux_cmdaccept' => [],
				  'hupdate_signals' => {},
				  'hcode_input_assigns' => {},
				  'hcode_output_assigns' => {}
				 );
	
	# top-level generics
	_add_generic("reset_active_g", $EH{'reg_shell'}{'reset_active'}, $top_inst);
	_add_generic("syn_reset_g", $EH{'reg_shell'}{'syn_reset'}, $top_inst);
	
	# add standard inputs
	_add_primary_input("clk_i", 0, 0, $top_inst);
	_add_primary_input("reset_i", 0, 0, $top_inst);
	_add_primary_input("maddr_i", $EH{'reg_shell'}{'addrwidth'}-1, 0, $top_inst);
	_add_primary_input("mcmd_i", 2, 0, $top_inst);
	_add_primary_input("mdata_i", $EH{'reg_shell'}{'datawidth'}-1, 0, $top_inst);
	
	# add standard outputs
	_add_primary_output("scmdaccept_o", 0, 0, $top_inst);
	_add_primary_output("sdata_o", $EH{'reg_shell'}{'datawidth'}-1, 0, $top_inst);
	_add_primary_output("sresp_o", 1, 0, $top_inst);

	foreach $o_domain (@ldomains) {
		# iterate through all registers of the domain and add ports/instantiations
		foreach $o_reg (@{$o_domain->regs}) {
			my $inst_added;
			my $reg_type = "";
			my $reg_access = "";
			my $reg_offset = $o_domain->get_reg_address($o_reg);

			foreach $href (@{$o_reg->fields}) {
				$o_field = $href->{'field'};
				next if $o_field->name =~ m/^UPD[EF]/; # skip UPD* regs

				# select type of register
				if ($reg_type eq "") {
					$reg_type = lc($o_field->attribs->{'spec'});
				} else {
					if (lc($o_field->attribs->{'spec'}) ne $reg_type) {
						print STDERR "ERROR: register \'".$o_reg->name."\': all fields in one register must have same 'spec' attribute\n"; next;
					};
				};
				if ($reg_access eq "") {
					$reg_access = lc($o_field->attribs->{'dir'});
				} else {
					if (lc($o_field->attribs->{'dir'}) ne $reg_access) {
						print STDERR "ERROR: register \'".$o_reg->name."\': all fields in one register must have same 'dir' attribute\n"; next;
					};
				};
				
				# add register instantiation
				if (!$inst_added) {
					$reg_id = $this->_add_vrs_register_instantiation($o_reg, $o_field, $reg_offset, $reg_access, $reg_type, $top_inst);
					next if (!$reg_id);
					$inst_added = 1;
				};
				
				# add field port and assignment
				# BAUSTELLE check for doubly defined fields
				$this->_add_vrs_field($o_field, $href->{'pos'}, $reg_id, $top_inst);
			};
		}; # foreach $o_reg 
	};

	# instantiate and connect the update signal synchronizer
	$this->_add_vrs_sync_upd_instances($top_inst);

	# the last step: set macros for code generation
	$this->_generate_vrs_code_macros();
};

# end view: HDL-vrs
#------------------------------------------------------------------------------

# Function to fill the macros that will be inserted into generated code
sub _generate_vrs_code_macros {
	my $this = shift;
	my $lang = _get_hdl_language();
	my $indent = $EH{'macro'}{'%S%'} x 2;
	my $key;

	if ($lang eq "vhdl") {
		$EH{'macro'}{'%VHDL_HOOK_ARCH_BODY%'} = $indent.$EH{'macro'}{'%ACOM%'}."-- input assignments\n";
		$EH{'macro'}{'%VHDL_HOOK_ARCH_BODY%'} .= join
		  (
		   "\n", map ($indent."$_ <= ".$this->global->{'hcode_input_assigns'}->{$_}.";", sort keys %{$this->global->{'hcode_input_assigns'}}),"\n"
		  );
		$EH{'macro'}{'%VHDL_HOOK_ARCH_BODY%'} .= $indent.$EH{'macro'}{'%ACOM%'}."-- output assignments\n";
		$EH{'macro'}{'%VHDL_HOOK_ARCH_BODY%'} .= join
		  (
		   "\n", map ($indent."$_ <= ".$this->global->{'hcode_output_assigns'}->{$_}.";", sort {$this->global->{'hcode_output_assigns'}->{$a} cmp $this->global->{'hcode_output_assigns'}->{$b}} keys %{$this->global->{'hcode_output_assigns'}}),"\n"
		  );
	} else {
		print STDERR "ERROR: output language \'$lang\' not supported yet\n";
	};
};

# Function to add a field port to connection database and assignment to/from register to hashes for generated code
sub _add_vrs_field {
	my ($this, $o_field, $pos, $reg_id, $top_inst) = @_;
	my $key;
	my $range = _get_vhdl_range($o_field->attribs->{'size'}+$pos-1, $pos);
	
	if (lc($o_field->attribs->{'dir'}) eq "r") { # read-only
		_add_primary_input(lc($o_field->name) . "%POSTFIX_FIELD_IN%", 
						   $o_field->attribs->{'size'}+$o_field->attribs->{'lsb'}-1,
						   $o_field->attribs->{'lsb'},
						   $top_inst);
		$key = "regdata_${reg_id}${range}";
		if (exists($this->global->{'hcode_input_assigns'}->{$key})) {
			print "ERROR: left-hand side statement \'$key\' exists more than once, dropping repetition\n";
		} else {
			$this->global->{'hcode_input_assigns'}->{$key} = lc($o_field->name).$EH{'postfix'}{'POSTFIX_FIELD_IN'};
		};
	} else { # rw and write-only
		_add_primary_output(lc($o_field->name) . "%POSTFIX_FIELD_OUT%", 
							$o_field->attribs->{'size'}+$o_field->attribs->{'lsb'}-1,
							$o_field->attribs->{'lsb'},
							$top_inst);
		$key = lc($o_field->name).$EH{'postfix'}{'POSTFIX_FIELD_OUT'};
		if(exists $this->global->{'hcode_output_assigns'}->{$key}) {
			print "ERROR: left-hand side statement \'$key\' exists more than once, dropping repetition\n";
		} else {
			$this->global->{'hcode_output_assigns'}->{$key} = "regdata_${reg_id}${range}";
		};
	};
};

# Function to add and connect an update signal synchronizer module
sub _add_vrs_sync_upd_instances {
	my ($this, $top_inst) = @_;
	my ($signal, $o_field);

	# add update-signal-synchronizer
	foreach $signal (keys %{$this->global->{'hupdate_signals'}}) {
		$o_field = $this->global->{'hupdate_signals'}->{$signal};
		my $inst = add_inst
			  (
			   '::parent' => $top_inst,
			   '::inst' => "sync_$signal",
			   '::entity' => "pucb_sync_upd",
			   '::descr' => "synchronize update signal \'$signal\' into clock domain \'".$o_field->attribs->{'clock'}."\'"
			  );
		_add_primary_input($signal, 0, 0, "sync_$signal/update_i");
		_add_primary_input($o_field->attribs->{'clock'}, 0, 0, "$inst/clk_pu_i");
		_add_primary_input($o_field->attribs->{'reset'}, 0, 0, "$inst/reset_pu_i");
		_add_connection("%LOW%", 0, 0, "", "$inst/force_i");    # BAUSTELLE
		_add_connection("%OPEN%", 0, 0, "$inst/clear_o", "");   # BAUSTELLE
		_add_generic("reset_active_g", $EH{'reg_shell'}{'reset_active'}, $inst);
		_add_generic("syn_reset_g", $EH{'reg_shell'}{'syn_reset'}, $inst);
	};
};

# Function to add and connect register instantiation; will also instantiate 
# shadow register if required;
# returns register id string or undef if register was not instantiated
sub _add_vrs_register_instantiation {
	my ($this, $o_reg, $o_field, $offset, $access, $type, $top_inst ) = @_;
	my ($inst, $inst_shw, $inst_upd);
	my $not_supported;
	my ($reg_id) = sprintf("%x", $offset>>2);
	
	if ($access eq "r" and $type =~ m/^[sha|ehs]/) {
		$not_supported = 1;
	} else {
		# add main register and connect it; save output names for multiplexor
		$inst = add_inst("::parent" => $top_inst,
						 "::inst" => lc($o_reg->name),
						 "::entity" => ($access eq "r") ? "pucb_rd_reg" : "pucb_rw_reg"
						);
		_add_primary_input("clk_i", 0, 0, $inst);
		_add_primary_input("reset_i", 0, 0, $inst);
		_add_primary_input("maddr_i", 0, 0, $inst);
		_add_primary_input("mdata_i", 0, 0, $inst);
		_add_connection("int_mcmd", 2, 0, $top_inst, "$inst/mcmd_i");
		_add_connection("int_byteaddr_del", 1, 0, $top_inst, "$inst/byteaddr_del_i");
		_add_connection("scmdaccept_${reg_id}", 0, 0, "$inst/scmdaccept_o", $top_inst); # to logic
		push @{$this->global->{'lmux_cmdaccept'}}, "scmdaccept_${reg_id}";
		_add_connection("sresp_${reg_id}", 0, 0, "$inst/sresp_o", $top_inst);# to logic
		push @{$this->global->{'lmux_resp'}}, "sresp_${reg_id}";
		_add_connection("select_pu", 0, 0, $top_inst, "$inst/select_pu_i");
		_add_generic("address_g", sprintf("16#%x#", $offset>>2), $inst);# BAUSTELLE buggy
		_add_generic("awidth_g", $EH{'reg_shell'}{'addrwidth'}, $inst);
		_add_generic("dwidth_g", $EH{'reg_shell'}{'datawidth'}, $inst);
		_add_generic("cac_del_g", $EH{'reg_shell'}{'cac_del'}, $inst);
		_add_generic("dav_del_g", $EH{'reg_shell'}{'dav_del'}, $inst);
		_add_generic("reg_output_g", $EH{'reg_shell'}{'reg_output'}, $inst);
		_add_generic("reset_active_g", $EH{'reg_shell'}{'reset_active'}, $inst);
		_add_generic("syn_reset_g", $EH{'reg_shell'}{'syn_reset'}, $inst);
		_add_generic("handshake_g", ($type =~ m/ehs/g) ? 1 : 0, $inst);
		_add_generic("used_bits_g", sprintf("16#%x#", $o_reg->attribs->{'usedbits'}), $inst); # BAUSTELLE buggy
		if($access =~ m/r/g) {
			_add_connection("sdata_${reg_id}", $EH{'reg_shell'}{'datawidth'}-1, 0, "$inst/sdata_o", $top_inst);# to logic
			push @{$this->global->{'lmux_data'}}, "sdata_${reg_id}"; 
		} else {
			_add_connection("%OPEN%", $EH{'reg_shell'}{'datawidth'}-1, 0, "$inst/sdata_o", "");
		};

		if($access eq "r") {
			_add_connection($this->_get_pu_clk($type, $o_field), 0, 0, $top_inst, "$inst/clk_pu_i");
			_add_connection($this->_get_pu_rst($type, $o_field), 0, 0, $top_inst, "$inst/reset_pu_i");
			_add_connection("%LOW%", 0, 0, $top_inst, "$inst/force_update_i");
			_add_connection("%LOW%", 0, 0, $top_inst, "$inst/update_i");
			_add_connection("%LOW%", 0, 0, $top_inst, "$inst/data_valid_i");
			_add_connection("%OPEN%", 0, 0, "$inst/data_request_o", "");
			_add_connection("regdata_${reg_id}", $EH{'reg_shell'}{'datawidth'}-1, 0, $top_inst, "$inst/regdata_i");# from logic
			_add_generic("clear_g", 0, $inst);
			_add_generic("shadow_g", 0, $inst);
			_add_generic("update_g", 0, $inst);
			_add_generic("autoupdate_g", 0, $inst);		
		} else {
			_add_connection("%LOW%", 0, 0, $top_inst, "$inst/update_done_i");
			_add_connection("%OPEN%", 0, 0, "$inst/update_shadow_o", "");
			_add_generic("readback_g", ($access eq "rw") ? 1 : 0, $inst);
			
			# add shadow register (only needed for writable regs)
			if ($type =~ m/^sha/) {
				$inst_shw  = add_inst("::parent" => $top_inst,
									  "::inst" => lc($o_reg->name) . "_shw",
									  "::entity" => "pucb_shw_reg"
									 );
				_add_primary_input($this->_get_pu_clk($type, $o_field), 0, 0, $inst_shw);
				_add_primary_input($this->_get_pu_rst($type, $o_field), 0, 0, $inst_shw);
				_add_connection("regdata_pre_${reg_id}", $EH{'reg_shell'}{'datawidth'}-1, 0, "$inst/regdata_o", "$inst_shw/regdata_i");
				_add_connection("regdata_${reg_id}", $EH{'reg_shell'}{'datawidth'}-1, 0, "$inst_shw/regdata_o", $top_inst); 
				
				_add_connection("%LOW%", 0, 0, $top_inst, "$inst_shw/update_shadow_i");
				_add_connection("%OPEN%", 0, 0, "$inst_shw/update_done_o", "");
				_add_connection("%LOW%", 0, 0, $top_inst, "$inst_shw/force_update_i");
				_add_connection("%OPEN%", 0, 0, "$inst_shw/take_over_o", "");
				_add_generic("dwidth_g", $EH{'reg_shell'}{'datawidth'}, $inst_shw);
				_add_generic("reset_active_g", $EH{'reg_shell'}{'reset_active'}, $inst_shw);
				_add_generic("syn_reset_g", $EH{'reg_shell'}{'syn_reset'}, $inst_shw);
				_add_generic("update_g", 0, $inst_shw);
				_add_generic("handshake_g", ($type =~ m/ehs/g) ? 1 : 0, $inst_shw);
				_add_generic("used_bits_g", sprintf("16#%x#", $o_reg->attribs->{'usedbits'}), $inst_shw);# BAUSTELLE buggy
				$this->_connect_update_signal($inst_shw, $o_field);
			} else {
				_add_connection("regdata_${reg_id}", $EH{'reg_shell'}{'datawidth'}-1, 0, "$inst/regdata_o", $top_inst); 
			};
		};
	};
	
	if ($not_supported) {
		print STDERR "ERROR: requested register type not supported: ",uc("${access}_${type}")," (",$o_reg->name,")\n";
		$reg_id = undef;
	};
	return $reg_id;
};

# helper function to connect update signal of shadow register
sub _connect_update_signal {
	my ($this, $inst, $o_field) = @_;
	my ($signal) = $o_field->attribs->{'sync'};
	
	if (lc($signal) eq "nto") {
		print STDERR "ERROR: no update signal specified for field \'",$o_field->name,"\'";
		_add_connection("%LOW%", 0, 0, "", "$inst/update_i");
	} else {
		# store the signal name for later
		$this->global->{'hupdate_signals'}->{$signal} = $o_field;
		_add_connection("${signal}_s", 0, 0, "sync_${signal}/update_o", "$inst/update_i");
	};
};

# helper function to get pu clock name
sub _get_pu_clk {
	my($this, $type, $o_field) = @_;
	my($result) = "%LOW%";
	if ($type =~ m/^[ehs|cor]/) {
		$result = $o_field->attribs->{'clock'};
		# $this->global->{'hclocks'} = $result;
	};
	return $result;
};

# helper function to get pu reset name
sub _get_pu_rst {
	my($this, $type, $o_field) = @_;
	my($result) = "%LOW%";
	if ($type =~ m/^[ehs|cor]/) {
		$result = $o_field->attribs->{'reset'};
		# $this->global->{'hresets'} = $result;
	};
	return $result;
};

# helper function to add an integer generic/parameter
sub _add_generic {
	my($name, $value, $destination) = @_;
	my %hconn;

	%hconn = (
			  '::name' => $name,
			  '::out'  => "%PARAMETER%/$value",
			  '::in'   => "$destination",
			  '::type' => "integer",
			  '::mode' => "P"
			 );
	add_conn(%hconn);

	#$hconn{'::out'} = "%GENERIC%/$value";
	#$hconn{'::mode'} = "G";
	#add_conn(%hconn);
};

# helper function to add a connection
sub _add_connection {
	my($name, $msb, $lsb, $source, $destination) = @_;
	my %hconn;

	$hconn{'::name'} = $name;
	$hconn{'::in'} = $destination;
	$hconn{'::out'} = $source;
	if ($msb == $lsb) {
		$hconn{'::type'} = "%SIGNAL%";
		delete $hconn{'::high'};
		delete $hconn{'::low'};
	} else {
		$hconn{'::type'} = "%BUS_TYPE%";
		$hconn{'::high'} = $msb;
		$hconn{'::low'} = $lsb;
	};
	add_conn(%hconn);
};

# helper function to add top-level input
sub _add_primary_input {
	my ($name, $msb, $lsb, $destination) = @_;
	my %hconn;

	$hconn{'::name'} = $name;
	$hconn{'::in'} = $destination;
	$hconn{'::mode'} = "i";
	if ($msb == $lsb) {
		$hconn{'::type'} = "%SIGNAL%";
		delete $hconn{'::high'};
		delete $hconn{'::low'};
	} else {
		$hconn{'::type'} = "%BUS_TYPE%";
		$hconn{'::high'} = $msb;
		$hconn{'::low'} = $lsb;
	};
	add_conn(%hconn);
};

# helper function to add output to top-level
sub _add_primary_output {
	my ($name, $msb, $lsb, $source) = @_;
	my %hconn;

	$hconn{'::name'} = $name;
	$hconn{'::out'} = $source;
	$hconn{'::mode'} = "o";
	if ($msb == $lsb) {
		$hconn{'::type'} = "%SIGNAL%";
		delete $hconn{'::high'};
		delete $hconn{'::low'};
	} else {
		$hconn{'::type'} = "%BUS_TYPE%";
		$hconn{'::high'} = $msb;
		$hconn{'::low'} = $lsb;
	};
	add_conn(%hconn);
};

# helper function to generate a vector range
sub _get_vhdl_range {
	my($msb, $lsb) = @_;
	my $result;
	my $lang = _get_hdl_language();
	
	if ($lang eq "vhdl") {
		if ($msb == $lsb) {
			$result = sprintf("(%d)", $lsb);
		} else {
			$result = sprintf("(%d downto %d)", $msb, $lsb);
		};
	} else {
		print STDERR "ERROR: output language \'$lang\' not supported yet\n";
	};
	return $result	  
};

# helper function to get the target language
sub _get_hdl_language {
	return $EH{'macro'}{'%LANGUAGE%'}; # BAUSTELLE - not clean
};

1;
