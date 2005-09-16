###############################################################################
#  RCSId: $Id: RegViews.pm,v 1.2 2005/09/16 13:57:27 lutscher Exp $
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
#  Revision 1.2  2005/09/16 13:57:27  lutscher
#  added register view E_VR_AD from Emanuel
#
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
use Log::Agent;
use Log::Agent::Priorities qw(:LEVELS);
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
# view: HDL-vgch-vrs

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

	# modify MIX config (only where required)
	$EH{'check'}{'signal'} = 'load,driver,check';

	my ($top_inst, %hconn, $o_domain, $o_field, $o_reg, @lmux_data, @lmux_resp, @lmux_cmdaccept, $reg_id, $signal, $clock, $reset);

	# extend class data with data structure needed for code generation
	$this->global(
				  'n_regs'       => 0,
				  'n_scmdaccept' => 0,
				  'n_sresp'      => 0,
				  'hupdate_signals' => {}
				 );

	#
	# top-level module
	#
	my $vrs_name = join("_", map $_->{'name'},@ldomains);
	$top_inst = add_inst
	  (
	   '::interface' => $vrs_name,
	   '::inst'   => '%PREFIX_INSTANCE%%::interface%%POSTFIX_INSTANCE%',
	   '::entity' => '%::interface%'.$EH{'postfix'}{'POSTFIX_ENTY'},
	   '::descr'  => "Video register shell for domain \'".$vrs_name."\'",
	   '::lang'   => $this->global->{'lang'},
	   '::use'    => "ieee.std_logic_misc"
	  );
	$this->global->{'top_inst'} = $top_inst;
	
	# top-level generics
	#_add_generic("reset_active_g", $EH{'reg_shell'}{'reset_active'}, $top_inst);
	#_add_generic("syn_reset_g", $EH{'reg_shell'}{'syn_reset'}, $top_inst);
	
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

	# iterate through all register domains
	foreach $o_domain (@ldomains) {
		$this->global->{'n_regs'} = scalar(@{$o_domain->regs}); # get number of registers
		$o_domain->display();

		# iterate through all registers of the domain and add ports/instantiations
		foreach $o_reg (@{$o_domain->regs}) {
			# $o_reg->display(); # debug
			my $inst_added;
			my $reg_type = "";
			my $reg_access = "";
			my $reg_offset = $o_domain->get_reg_address($o_reg);

			# iterate through all fields of the register
			foreach $href (@{$o_reg->fields}) {
				$o_field = $href->{'field'};
				#next if $o_field->name =~ m/^UPD[EF]/; # skip UPD* regs

				# select type of register
				if ($reg_type eq "") {
					$reg_type = lc($o_field->attribs->{'spec'});
				} else {
					if (lc($o_field->attribs->{'spec'}) ne $reg_type) {
						logwarn("ERROR: register \'".$o_reg->name."\': all fields in one register must have same 'spec' attribute"); next;
						$EH{'sum'}{'errors'}++;
					};
				};
				if ($reg_access eq "") {
					$reg_access = lc($o_field->attribs->{'dir'});
				} else {
					if (lc($o_field->attribs->{'dir'}) ne $reg_access) {
						logwarn("ERROR: register \'".$o_reg->name."\': all fields in one register must have same 'dir' attribute"); next;
						$EH{'sum'}{'errors'}++;
					};
				};
				
				# add register instantiation
				if (!$inst_added) {
					$reg_id = $this->_add_vrs_register_instantiation($o_reg, $o_field, $reg_offset, $reg_access, $reg_type);		
					$inst_added = 1;
					last if (!$reg_id); # unsupported register
				};

				# add register<->field connection
				$this->_connect_vrs_field($o_reg, $o_field, $reg_id, $reg_access, $reg_type, $href->{'pos'});
			};
		}; # foreach $o_reg 
	};

	# add logic
	$this->_add_vrs_logic();

	# instantiate and connect the update signal synchronizer
	$this->_add_vrs_sync_upd_instances();
};

# Function to add logic required by video register-shell
sub _add_vrs_logic {
	my $this = shift;
	my $inst = $this->global->{'top_inst'};

	my $udc = '
/%DECL%/
SIGNAL sdata_u2         : std_ulogic_vector(7 DOWNTO 0);
SIGNAL sresp_u2         : std_ulogic_vector(1 DOWNTO 0);
SIGNAL scmdaccept_r     : std_ulogic;
SIGNAL scmdaccept_r2    : std_ulogic;

/%BODY%/
int_scmdaccept <= OR_REDUCE(scmdaccept); -- reduce scmdaccept vector
int_sresp      <= OR_REDUCE(sresp); -- reduce sresp vector
select_bc      <= \'1\'  WHEN mcmd_i = OCP_BCST_c   -- activate broadcast select
                       ELSE \'0\';
select_pu      <= NOT select_bc;
int_mcmd       <= OCP_WR_c WHEN mcmd_i = OCP_BCST_c   -- map broadcast to write command
                           ELSE mcmd_i;

reg_outputs: PROCESS (clk_i, reset_i) -- OCP 1.0 output register
BEGIN
   IF reset_i = reset_active_c AND syn_reset_g = 0 THEN
     sdata_o       <= (OTHERS => \'0\');
     sresp_o       <= (OTHERS => \'0\');
     scmdaccept_r  <= \'0\';
     scmdaccept_r2 <= \'0\';
     clr_irq_o     <= \'0\';
   ELSIF clk_i\'event AND clk_i = \'1\' THEN
      IF reset_i = reset_active_c AND syn_reset_g = 1 THEN
         sdata_o       <= (OTHERS => \'0\');
         sresp_o       <= (OTHERS => \'0\');
         scmdaccept_r  <= \'0\';
         scmdaccept_r2 <= \'0\';
         clr_irq_o     <= \'0\';
      ELSE
         sdata_o       <= sdata_u2;
         sresp_o       <= sresp_u2;
         scmdaccept_r  <= int_scmdaccept;
         scmdaccept_r2 <= scmdaccept_r;
         clr_irq_o     <= int_clr_irq;
      END IF;
   END IF;
END PROCESS reg_outputs;

scmdaccept_o <= scmdaccept_r;
sdata_u2     <= int_sdata WHEN scmdaccept_r2 = \'1\' ELSE \"00000000\";
sresp_u2     <= int_sresp WHEN scmdaccept_r2 = \'1\' ELSE \"00\";		

reg_maddr: PROCESS (clk_i, reset_i) -- delay LSBs of register address
BEGIN
   IF reset_i = reset_active_c AND syn_reset_g = 0 THEN
      int_byteaddr_del   <= (OTHERS => \'0\');
   ELSIF clk_i\'event AND clk_i = \'1\' THEN
      IF reset_i = reset_active_c AND syn_reset_g = 1 THEN
         int_byteaddr_del   <= (OTHERS => \'0\');
      ELSE
         int_byteaddr_del   <= maddr_i(1 DOWNTO 0);
      END IF;
   END IF;
END PROCESS reg_maddr;
				 ';

	add_inst
	  (
	   '::inst' => $inst,
	   '::udc'  => join("\n", map { $EH{'macro'}{'%S%'}.$_ } split("\n", $udc)),
	  );

	# add OR instance for data vector reduction
	my $or_inst = add_inst
	  (
	   '::parent' => $inst,
	   '::inst' => "sdata_redux",
	   '::entity' => "%OR%",
	   '::lang' => $this->global->{'lang'},
	   '::conf' => "%NO_CONFIG%"
	  );
	_add_connection("int_sdata", $EH{'reg_shell'}{'datawidth'}-1, 0, $or_inst, "");
};

# Function to connect a field with the appropriate register slice
sub _connect_vrs_field {
	my($this, $o_reg, $o_field, $rid, $access, $type, $pos) = @_;
	my($msb) = $o_field->attribs->{'size'}+$o_field->attribs->{'lsb'}-1;
	my $reg_range  = "(".($pos+$o_field->attribs->{'size'}-1).":".$pos.")";
	my $frange = "(".$msb.":".$o_field->attribs->{'lsb'}.")";
	my $top_inst = $this->global->{'top_inst'};

	if ($access eq "r") {  
		# read-only BAUSTELLE
		_add_primary_input(lc($o_field->name) . "%POSTFIX_FIELD_IN%", $msb,$o_field->attribs->{'lsb'}, lc($o_reg->name)."/regdata_i${reg_range}");
		#_add_connection("regdata_${rid}", "dwidth_g - 1", 0, ,lc($o_reg->name)."/regdata_i${reg_range}=${frange}", "$top_inst/".lc($o_field->name).$EH{'macro'}{'%POSTFIX_FIELD_IN'}."${frange}");
	} else { 
		if ($type =~ m/^sha/) { # connect to shadow reg output
			_add_primary_output(lc($o_field->name) . "%POSTFIX_FIELD_OUT%", $msb,$o_field->attribs->{'lsb'}, lc($o_reg->name)."_shw/regdata_o${reg_range}");
		} else { # writable, no shadow
			if ($type !~ m/^upd[ef]/) { # update enable/force register
				_add_primary_output(lc($o_field->name) . "%POSTFIX_FIELD_OUT%", $msb,$o_field->attribs->{'lsb'}, lc($o_reg->name)."/regdata_o${reg_range}");
			};
		};	
	};
};

# Function to add and connect an update signal synchronizer module
sub _add_vrs_sync_upd_instances {
	my $this = shift;
	my ($signal, $o_field, $uslice, $clr_irq_connected);
	my $top_inst = $this->global->{'top_inst'};

	# add update-signal-synchronizer
	foreach $signal (keys %{$this->global->{'hupdate_signals'}}) {
		$o_field = $this->global->{'hupdate_signals'}->{$signal};
		next if !(ref $o_field); # filter meta-keys
		my $inst = add_inst
			  (
			   '::parent' => $top_inst,
			   '::inst' => "sync_$signal",
			   '::entity' => "pucb_sync_upd",
			   '::descr' => "synchronize update signal \'$signal\' into clock domain \'".$o_field->attribs->{'clock'}."\'",
			   '::lang' => $this->global->{'lang'}
			  );
		_add_primary_input($signal, 0, 0, "sync_$signal/update_i");
		_add_primary_input($o_field->attribs->{'clock'}, 0, 0, "$inst/clk_pu_i");
		_add_primary_input($o_field->attribs->{'reset'}, 0, 0, "$inst/reset_pu_i");
		_add_generic("reset_active_g", $EH{'reg_shell'}{'reset_active'}, $inst);
		_add_generic("syn_reset_g", $EH{'reg_shell'}{'syn_reset'}, $inst);
		
		# connect to update enable/force register
		$uslice = $o_field->attribs->{'update'};
		if ($uslice =~ m/\.(\d+)$/) {
			$uslice = $1;
			if(exists($this->global->{'hupdate_signals'}->{'_update_enable_'})) {
				_add_connection("int_upde_".$uslice , 0, 0, $this->global->{'hupdate_signals'}->{'_update_enable_'}."/regdata_o(".$uslice.":".$uslice.")", "$inst/enable_i");
				_add_connection("int_upde_".$uslice."_clr", 0, 0, "$inst/clear_o", $this->global->{'hupdate_signals'}->{'_update_enable_'}."/regclr_i(".$uslice.":".$uslice.")");
				if (!$clr_irq_connected) {
					_add_connection("int_clr_irq", 0, 0, $this->global->{'hupdate_signals'}->{'_update_enable_'}."/clr_irq_o", "");
					$clr_irq_connected = 1;
				};
			} else {
				_add_connection("%LOW%", 0, 0, "", "$inst/enable_i");  
				logwarn("ERROR: cannot find update enable register");
			};
			if(exists($this->global->{'hupdate_signals'}->{'_update_force_'})) {
				_add_connection("int_updf_".$uslice , 0, 0, $this->global->{'hupdate_signals'}->{'_update_force_'}."/regdata_o(".$uslice.":".$uslice.")", "$inst/force_i");
			} else {
				_add_connection("%LOW%", 0, 0, "", "$inst/force_i");
				logwarn("ERROR: cannot find update force register");
			};		  
		} else {
			logwarn("ERROR: cannot evaluate ::update attribute for field \'".($o_field->name)."\' : $uslice");
		};
	};
};

# Function to add and connect register instantiation; will also instantiate 
# shadow register if required;
# returns register id string or undef if register was not instantiated
sub _add_vrs_register_instantiation {
	my ($this, $o_reg, $o_field, $offset, $access, $type) = @_;
	my ($inst, $inst_shw, $inst_upd);
	my $not_supported;
	my $reg_id = sprintf("%x", $offset>>2);
	my $top_inst = $this->global->{'top_inst'};

	if ($access eq "r" and $type =~ m/^[sha|ehs|cor]/) {
		$not_supported = 1;
	} else {
		# add main register and connect it; save output names for generating multiplexor
		$inst = add_inst("::parent" => $top_inst,
						 "::inst" => lc($o_reg->name),
						 "::entity" => ($access eq "r") ? "pucb_rd_reg" : ($type =~ m/^upde/ ? "pucb_rwc_reg":"pucb_rw_reg"),
						 '::lang' => $this->global->{'lang'}
						);
		_add_primary_input("clk_i", 0, 0, $inst);
		_add_primary_input("reset_i", 0, 0, $inst);
		_add_primary_input("maddr_i", $EH{'reg_shell'}{'addrwidth'}-1, 0, $inst);
		_add_primary_input("mdata_i", $EH{'reg_shell'}{'datawidth'}-1, 0, $inst);
		_add_connection("int_mcmd", 2, 0, "", "$inst/mcmd_i");
		_add_connection("int_byteaddr_del", 1, 0, "", "$inst/byteaddr_del_i");
		_add_connection("scmdaccept", $this->global->{'n_regs'}-1, 0, "$inst/scmdaccept_o(0:0) = (".($this->global->{'n_scmdaccept'}).":".($this->global->{'n_scmdaccept'}++).")",""); # to OR
		_add_connection("sresp", $this->global->{'n_regs'}-1, 0, "$inst/sresp_o(0:0) = (".($this->global->{'n_sresp'}).":".($this->global->{'n_sresp'}++).")",""); # to OR
		_add_connection(($type =~ m/^upd[ef]/) ? "select_bc" : "select_pu", 0, 0, "" , "$inst/select_pu_i");
		_add_generic("address_g", sprintf("16#%x#", $offset>>2), $inst);
		_add_generic("awidth_g", $EH{'reg_shell'}{'addrwidth'}, $inst);
		_add_generic("dwidth_g", $o_reg->attribs->{size}, $inst);
		_add_generic("cac_del_g", $EH{'reg_shell'}{'cac_del'}, $inst);
		_add_generic("dav_del_g", $EH{'reg_shell'}{'dav_del'}, $inst);
		_add_generic("reg_output_g", $EH{'reg_shell'}{'reg_output'}, $inst);
		_add_generic("reset_active_g", $EH{'reg_shell'}{'reset_active'}, $inst);
		_add_generic("syn_reset_g", $EH{'reg_shell'}{'syn_reset'}, $inst);
		_add_generic("handshake_g", ($type =~ m/ehs/g) ? 1 : 0, $inst) unless $type =~ m/^upde/;
		_add_generic("used_bits_g", sprintf("16#%x#", $o_reg->attribs->{'usedbits'}), $inst);
		_add_generic("reset_value_g", sprintf("16#%x#", $o_reg->get_reg_init), $inst);
		if($access =~ m/r/g) { # R or RW register
			_add_connection("sdata_${reg_id}", $EH{'reg_shell'}{'datawidth'}-1, 0, "$inst/sdata_o", "sdata_redux/sdata_${reg_id}");# to logic
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
			_add_generic("clear_g", 0, $inst);
			_add_generic("shadow_g", 0, $inst);
			_add_generic("update_g", 0, $inst);
			_add_generic("autoupdate_g", 0, $inst);	
			# connect unused data inputs
			# BAUSTELLE entity declaration does not use generic
			#_add_connection("regdata_${reg_id}", "dwidth_g - 1", 0, "$inst/regdata_i", "");
			#for(my $i = 0; $i<$o_reg->attribs->{'size'}; $i++) {
			#	if (!($o_reg->attribs->{'usedbits'} & (1<<$i))) {
			#		_add_connection("%LOW%", 0, 0, $top_inst, "$inst/regdata_i($i:$i)");	
			#	}; 
			#};
		} else {
			_add_connection(($type =~ m/^updf/) ? "%HIGH%": "%LOW%", 0, 0, $top_inst, "$inst/update_done_i");
			_add_connection("%OPEN%", 0, 0, "$inst/update_shadow_o", "");
			_add_generic("readback_g", ($access eq "rw") ? 1 : 0, $inst);

			# store update enable/force register names for later
			if ($type =~ m/^upde/) {
				$this->global->{'hupdate_signals'}->{"_update_enable_"} = $inst;
			};
			if ($type =~ m/^updf/) {
				$this->global->{'hupdate_signals'}->{"_update_force_"} = $inst;
			};

			# add shadow register (only implemented for writable regs)
			if ($type =~ m/^sha/) {
				$inst_shw  = add_inst("::parent" => $top_inst,
									  "::inst" => lc($o_reg->name) . "_shw",
									  "::entity" => "pucb_shw_reg",
									  '::lang' => $this->global->{'lang'}
									 );
				_add_primary_input($this->_get_pu_clk($type, $o_field), 0, 0, $inst_shw);
				_add_primary_input($this->_get_pu_rst($type, $o_field), 0, 0, $inst_shw);
				_add_connection("regdata_pre_${reg_id}", "dwidth_g - 1", 0, "$inst/regdata_o", "$inst_shw/regdata_i");
				_add_connection("%LOW%", 0, 0, $top_inst, "$inst_shw/update_shadow_i");
				_add_connection("%OPEN%", 0, 0, "$inst_shw/update_done_o", "");
				_add_connection("%LOW%", 0, 0, $top_inst, "$inst_shw/force_update_i");
				_add_connection("%OPEN%", 0, 0, "$inst_shw/take_over_o", "");
				_add_generic("dwidth_g", $o_reg->attribs->{size}, $inst_shw);
				_add_generic("reset_active_g", $EH{'reg_shell'}{'reset_active'}, $inst_shw);
				_add_generic("syn_reset_g", $EH{'reg_shell'}{'syn_reset'}, $inst_shw);
				_add_generic("update_g", 0, $inst_shw);
				_add_generic("handshake_g", ($type =~ m/ehs/g) ? 1 : 0, $inst_shw);
				_add_generic("used_bits_g", sprintf("16#%x#", $o_reg->attribs->{'usedbits'}), $inst_shw);
				_add_generic("reset_value_g", 0, $inst_shw);
				$this->_connect_vrs_update_signal($inst_shw, $o_field);
			};
		};
	};
	
	if ($not_supported) {
		# make dummy response bits for skipped registers, because the response vector length covers all registers
		_tie_signal_to_constant("scmdaccept", 0, $this->global->{'n_scmdaccept'}, $this->global->{'n_scmdaccept'}++);
		_tie_signal_to_constant("sresp", 0, $this->global->{'n_sresp'}, $this->global->{'n_sresp'}++);
		logwarn("ERROR: requested register type not supported: ".uc("${access}_${type}")." (".$o_reg->name.")");
		$EH{'sum'}{'errors'}++;
		$reg_id = undef;
	};
	return $reg_id;
};

# helper function to connect update signal of shadow register
sub _connect_vrs_update_signal {
	my ($this, $inst, $o_field) = @_;
	my ($signal) = $o_field->attribs->{'sync'};
	
	if (lc($signal) eq "nto") {
		logwarn("ERROR: no update signal specified for field \'".$o_field->name."\'");
		$EH{'sum'}{'errors'}++;
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

#------------------------------------------------------------------------------
# non-OO helper functions
#------------------------------------------------------------------------------

# function to create a constant for tying unused bits in signals using a special connection sheet function
sub _tie_signal_to_constant {
	my ($sig_name, $value, $msb, $lsb) = @_;
	my %hconn;
	
	%hconn = ( 
			  '::name' => $sig_name . "_${msb}_${lsb}_c$value",
			  '::out' => "$value=($msb:$lsb)",
			  '::in'  => "%BUS%/$sig_name",
			  '::type' => "integer",
			  '::mode' => "C"
			 );
	add_conn(%hconn);
};

# function to add an integer generic/parameter
sub _add_generic {
	my($name, $value, $destination) = @_;
	my %hconn;

	%hconn = (
			  '::name' => "",
			  '::out'  => "%PARAMETER%/$value",
			  '::in'   => "$destination/$name",
			  '::type' => "integer",
			  '::mode' => "P"
			 );
	add_conn(%hconn);
	
	#$hconn{'::out'} = "%GENERIC%/$value";
	#$hconn{'::mode'} = "G";
	#add_conn(%hconn);
};

# function to add a connection
sub _add_connection {
	my($name, $msb, $lsb, $source, $destination) = @_;
	my %hconn;

	$hconn{'::name'} = $name;
	$hconn{'::in'} = $destination;
	$hconn{'::out'} = $source;
	_get_signal_type($msb, $lsb, \%hconn);
	add_conn(%hconn);
};

# function to add top-level input
sub _add_primary_input {
	my ($name, $msb, $lsb, $destination) = @_;
	my %hconn;

	$hconn{'::name'} = $name;
	$hconn{'::in'} = $destination;
	$hconn{'::mode'} = "i";
	_get_signal_type($msb, $lsb, \%hconn);
	add_conn(%hconn);
};

# function to add output to top-level
sub _add_primary_output {
	my ($name, $msb, $lsb, $source) = @_;
	my %hconn;

	$hconn{'::name'} = $name;
	$hconn{'::out'} = $source;
	$hconn{'::mode'} = "o";
	_get_signal_type($msb, $lsb, \%hconn);
	add_conn(%hconn);
};

# function to set ::type, ::high, ::low for add_conn()
sub _get_signal_type {
	my($msb, $lsb, $href) = @_;
	if ($msb =~ m/[a-zA-Z_]+/g or $lsb =~ m/[a-zA-Z_]+/g) { # alphanumeric range
		if ($msb eq $lsb) {
			$href->{'::type'} = "%SIGNAL%";
			delete $href->{'::high'};
			delete $href->{'::low'};
		} else {
			$href->{'::type'} = "%BUS_TYPE%";
			$href->{'::high'} = $msb;
			$href->{'::low'} = $lsb;
		};
	} else {
		if ($msb == $lsb) { # numeric range
			$href->{'::type'} = "%SIGNAL%";
			delete $href->{'::high'};
			delete $href->{'::low'};
		} else {
			$href->{'::type'} = "%BUS_TYPE%";
			$href->{'::high'} = $msb;
			$href->{'::low'} = $lsb;
		};
	};
};

# function to generate a vector range
sub _get_vhdl_range {
	my($msb, $lsb) = @_;
	my $result;
	#my $lang = $this->global->{'lang'};
	
	if ($msb == $lsb) {
		$result = sprintf("(%d)", $lsb);
	} else {
		$result = sprintf("(%d downto %d)", $msb, $lsb);
	};
	#} else {
	#	logwarn("ERROR: output language \'$lang\' not supported yet\n");
	#};
	return $result	  
};

1;
