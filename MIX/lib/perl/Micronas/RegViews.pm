###############################################################################
#  RCSId: $Id: RegViews.pm,v 1.3 2005/10/14 11:30:07 lutscher Exp $
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
#  Revision 1.3  2005/10/14 11:30:07  lutscher
#  intermedate checkin (stable, but fully functional)
#
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
use Micronas::MixParser qw( %hierdb %conndb add_inst add_conn);
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

# Main entry function; generate data structures for the MIX Parser for Register 
# shell generation;
# input: domain names for which register shells are generated; if omitted, 
# register shells for ALL register space domains in the Reg object are generated
sub _gen_view_vgch_rs {
	my $this = shift;
	my @ldomains;
	my $href;

	# extend class data with data structure needed for code generation
	$this->global(
				  'ocp_target_name'    => "ocp_target",
				  'mcda_name'          => "mcda",
				  'cfg_module_prefix'  => "cfg",
				  'field_spec_values'  => ['sha', 'w1c', 'usr'], # recognized values for spec attribute
				  'hclocks'            => {},
				  'indent'             => "    " # indentation character(s)
				 );

	# import regshell.<par> parameters from MIX package to class data; user can change these parameters in mix.cfg
	my $param;
	my @lmixparams = ('bus_clock', 'bus_reset', 'addrwidth', 'datawidth','multi_clock_domains', 'infer_clock_gating');
	foreach $param (@lmixparams) {
		if (exists($EH{'reg_shell'}{$param})) {
			$this->global($param => $EH{'reg_shell'}{$param});
			_info("setting parameter regshell.", $param, " = ", $this->global->{$param});
		} else {
			_error("parameter \'$param\' unknown");
			if (defined (%EH)) { $EH{'sum'}{'errors'}++;};
		};
	};

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
	if (defined (%EH)) {
		$EH{'check'}{'signal'} = 'load,driver,check';
		$EH{'output'}{'filter'}{'file'} = [];
	};

	my ($o_domain, $o_field, $o_reg, $top_inst, $ocp_inst, $n_clocks, $cfg_inst, $clock);

	# iterate through all register domains
	foreach $o_domain (@ldomains) {
		# $o_domain->display() if $this->global->{'debug'};
		# get all clocks of domain and check if we have to infer mcd logic
		$n_clocks = $this->_vgch_rs_get_configuration($o_domain);
		if ($n_clocks > 1 and $this->global->{'multi_clock_domains'}) {
			_error("multi_clock_domains = 1 not supported yet");
			return 0;
		};
		
		($top_inst, $ocp_inst) = $this->_vgch_rs_gen_hier($o_domain, $n_clocks); # generate module hierarchy

		$this->_vgch_rs_add_static_connections();# add all standard ports and connections 
		
		# iterate through all clock domains
		foreach $clock (keys %{$this->global->{'hclocks'}}) {
			my @ludc = ();
			$href = $this->global->{'hclocks'}->{$clock};
			$cfg_inst = $href->{'cfg_inst'};
			print "> domain ",$o_domain->name,", clock $clock, cfg module $cfg_inst\n";
			$this->_vgch_rs_gen_cfg_module($o_domain, $clock, \@ludc); # generate config module for clock domain
			$this->_vgch_rs_write_udc($cfg_inst, \@ludc); # add user-defined-code to config module instantation
		};
	};
	$this->display() if $this->global->{'debug'};
};

# main method to generate config module for a clock domain
sub _vgch_rs_gen_cfg_module {
	my ($this, $o_domain, $clock, $lref_udc) = @_;
	my($o_reg, $href, $shdw_sig);
	my $href = $this->global->{'hclocks'}->{$clock};
	my $cfg_i = $href->{'cfg_inst'};
	my (@ldeclarations) = ("/*","  local wire or register declarations","*/");
	my (@lstatic_logic) = ();
	my $reset = $href->{'reset'};
	my (%husr, %hshdw, %hassigns);
	my $nusr = 0;

	# iterate through all registers of the domain and add ports/instantiations
	foreach $o_reg (@{$o_domain->regs}) {
		# $o_reg->display() if $this->global->{'debug'}; # debug
		my $reg_offset = $o_domain->get_reg_address($o_reg);	

		my $fclock = "";
		my $freset = "";
		# iterate through all fields of the register
		foreach $href (@{$o_reg->fields}) {
			$shdw_sig = "";
			my $o_field = $href->{'field'};
			# $o_field->display();
			($fclock, $freset) = $this->_get_field_clock_and_reset($clock, $reset, $fclock, $freset, $o_field);
			# skip field if not in our clock domain and MCD feature is enabled
			next if ($this->global->{'multi_clock_domains'} and $fclock ne $clock); 
			#next if $o_field->name =~ m/^UPD[EF]/; # skip legacy UPD* regs

			# get field attributes
			my $spec = $o_field->attribs->{'spec'}; # note: spec can contain several attributs
			my $access = lc($o_field->attribs->{'dir'});
			my $rrange = $this->_get_rrange($href->{'pos'}, $o_field);
			my $lsb = $o_field->attribs->{'lsb'};
			my $msb = $lsb - 1 + $o_field->attribs->{'size'};

			# track USR fields
			if ($spec =~ m/usr/i) {
				$nusr++; # count number of USR fields
				$husr{$o_field->name} = ""; # store usr field in hash
			};

			# track shadow signals
			if ($spec =~ m/sha/i) {
				$shdw_sig = $o_field->attribs->{'sync'};
				if(lc($shdw_sig) eq "nto" or $shdw_sig =~ m/[\%OPEN\%|\%EMPTY\%]/) {
					_error("field \'",$o_field->name,"\' is shadowed but has no shadow signal defined");
				} else {
					push @{$hshdw{$o_field->attribs->{'sync'}}}, $o_field->name;
				}; 
			};

			if ($access =~ m/r/i and $access !~/w/i ) { # read-only
				_add_primary_input($o_field->name, $msb, $lsb, $cfg_i);
			} elsif ($access =~ m/w/i) { # write
				if ($spec !~ m/w1c/i) {
					_add_primary_output($o_field->name, $msb, $lsb, ($spec =~ m/sha/i) ? 1:0, $cfg_i);
				} else { # w1c
					_add_primary_input($o_field->name."_set_p", 0, 0, $cfg_i);
				};
				if($access =~ m/r/i and $spec =~ m/usr/i) { # usr read/write
					_add_primary_input($o_field->name, $msb, $lsb, $cfg_i);
				};
			};
			if ($spec =~ m/usr/i) { # usr read/write
				_add_primary_input($o_field->name."_trans_done_p", 0, 0, $cfg_i);
				if($access =~ m/r/i) {
					_add_primary_output($o_field->name."_rd_p", $msb, $lsb, 1, $cfg_i);
				};
				if($access =~ m/w/i) {
					_add_primary_output($o_field->name."_wr_p", $msb, $lsb, 1, $cfg_i);
				};
			};
		}; # foreach $href
	}; # foreach $o_reg 

	# add ports for shadow signals
	foreach $shdw_sig (keys %hshdw) {
		_add_primary_input($shdw_sig, 0, 0, $cfg_i);
		_add_primary_input("${shdw_sig}_en", 0, 0, $cfg_i);
		_add_primary_input("${shdw_sig}_force", 0, 0, $cfg_i);
		push @ldeclarations,split("\n","wire int_".$shdw_sig.";\nreg ".$shdw_sig."_d;");
	};

	# add glue-logic
	$this->_vgch_rs_add_static_logic($o_domain, \@ldeclarations, \@lstatic_logic, \%husr);

	_pad_column(0, $this->global->{'indent'}, 2, \@ldeclarations); # indent declarations

	push @$lref_udc, @ldeclarations, @lstatic_logic;
};

# add standard logic constructs; adds to two lists: declarations and udc.
# performs text indentation/alignment only on udc lists.
sub _vgch_rs_add_static_logic {
	my ($this, $o_domain, $lref_decl, $lref_udc, $href_usr) = @_;
	my ($addr_msb, $addr_lsb) = $this->_get_address_msb_lsb($o_domain);
	my ($o_field, $href, $shdw_sig, $nusr);

	$nusr=scalar(keys %$href_usr); # number of USR fields
	
	# insert wire/reg declarations
	my @ltemp = ();
	push @ltemp, split("\n","
wire wr_p;
wire rd_p;
reg [".$this->global->{'datawidth'}.":0] int_rd_data, mux_rd_data;
wire rd_trans_done_p;
reg  int_trans_done;
reg  mux_rd_err;
wire [".($addr_msb-$addr_lsb).":0] iaddr;
wire addr_overshoot;
wire int_rst_n;
reg  fwd_txn;
wire trans_done_p;
");
	if ($nusr>0) { # if there are USR fields
		push @ltemp, split("\n","
wire [".($nusr-1).":0] fwd_decode_vec;
wire [".($nusr-1).":0] fwd_done_vec;
");
	};
	
	# pad_column(0, $this->global->{'indent'}, 2, \@ltemp);
	push @$lref_decl, @ltemp;
	
	# insert static logic
	@ltemp = split("\n","
// clip address to decoded range
assign iaddr = addr_i[$addr_msb:$addr_lsb];
assign addr_overshoot = |addr_i[".($this->global->{'addrwidth'}-1).":".($addr_msb+1)."]

// generate txn write pulse
assign wr_p = trans_start_p & ~rd_wr_i;

// generate txn start pulses
assign wr_p = trans_start_p & ~rd_wr_i;

// generate txn done signals
");
	if ($nusr>0) {
		push @ltemp, "assign trans_done_p = (trans_start_p & (fwd_decode_vec==0)) | ((fwd_done_vec != 0) & fwd_txn);";
	} else {
		push @ltemp, "assign trans_done_p = trans_start_p;";
	};
	push @ltemp, split("\n","
assign rd_trans_done_p = rd_wr_i & trans_done_p; // immediate ack
always @(clk or negedge int_rst_n) begin
   if (~int_rst_n) 
 	 int_trans_done <= 0;
   else
 	if (trans_done_p)
 	  int_trans_done <= ~int_trans_done;
end
assign trans_done_o = int_trans_done;
");
	_pad_column(-1, $this->global->{'indent'}, 2, \@ltemp);

	push @$lref_udc, @ltemp;
};

# write out the list of lines of code to the ::udc field of the instance
sub _vgch_rs_write_udc {
	my ($this, $cfg_inst, $lref_udc) = @_;
	add_inst
	  (
	   '::inst'   => $cfg_inst,
	   '::udc'    => join("\n", @$lref_udc)
	  );
};

# generate all instances for a register domain
# fills up the global->hclocks hash with data related to clock domains
sub _vgch_rs_gen_hier {
	my($this, $o_domain, $nclocks) = @_;
	my($clock, $bus_clock, $cfg_inst, $sg_inst, $sr_inst);
	my $refclks = $this->global->{'hclocks'};

	# top-level module
	my $vrs_name = $o_domain->name; #join("_", map $_->{'name'},@ldomains);
	my $top_inst = $this->_add_instance($vrs_name, "testbench", "Register shell for domain ".$o_domain->name);
	$this->global('top_inst' => $top_inst);
	
	# OCP target inst
	my $ocp_inst = $this->_add_instance($this->global->{"ocp_target_name"}, $top_inst, "OCP target module");
	$this->global('ocp_inst' => $ocp_inst);
	if (defined (%EH)) { # BAUSTELLE new feature, must be tested 
		push @{$EH{'output'}{'filter'}{'file'}}, $ocp_inst;
	};

	# MCD adapter (if required)
	if ($nclocks > 1 and $this->global->{'multi_clock_domains'}) {
		my $mcda_inst = $this->add_instance($this->global->{"mcda_name"}, $top_inst, "Multi-clock-domain Adapter");	
		$this->global('mcda_inst' => $mcda_inst);
		if (defined (%EH)) {
			push @{$EH{'output'}{'filter'}{'file'}}, $mcda_inst;
		};
	};
	
	# config register module(s)
	foreach $clock (keys %{$refclks}) {
		if ($refclks->{$clock}->{'sync'}) {
			# asynchronous config register module
			$cfg_inst = $this->_add_instance(join("_",$this->global->{"cfg_module_prefix"},$vrs_name,$clock), $top_inst, "Config register module for clock domain \'$clock\'");
		} else {
			# synchronous config register module
			$cfg_inst = $this->_add_instance(join("_",$this->global->{"cfg_module_prefix"}, $vrs_name), $top_inst, "Config register module");
		};
		# link clock domain to config register module
		$refclks->{$clock}->{'cfg_inst'} = $cfg_inst; # store in global->hclocks
		_add_generic("sync", $refclks->{$clock}->{'sync'}, "${cfg_inst}");

		# add synchronizer modules (need unique instance names because MIX has flat namespace)
		$sg_inst = $this->_add_instance_unique("sync_generic", $cfg_inst, "Synchronizer for trans_done signal");
		$refclks->{$clock}->{'sg_inst'} = $sg_inst; # store in global->hclocks
		_add_generic("kind", 2, "${sg_inst}");
		_add_generic("sync", $refclks->{$clock}->{'sync'}, "${sg_inst}");
		_add_generic("act", 1, "${sg_inst}");
		_add_generic("rstact", 0, "${sg_inst}");
		_add_generic("rstval", 0, "${sg_inst}");
		$sr_inst = $this->_add_instance_unique("sync_rst", $cfg_inst, "Reset synchronizer");
		$refclks->{$clock}->{'sr_inst'} = $sr_inst; # store in global->hclocks
		_add_generic("sync", $refclks->{$clock}->{'sync'}, "${sr_inst}");
		_add_generic("act", 0, "${sr_inst}");
		if (defined (%EH)) {
			push @{$EH{'output'}{'filter'}{'file'}}, ($sr_inst, $sg_inst);
		};
	};

	return ($top_inst, $ocp_inst);
};

# searches all clocks used in the register domain and stores the result in global->hclocks depending on 
# user settings; detects invalid configurations;
# returns the number of clocks
sub _vgch_rs_get_configuration {
	my $this = shift;
	my ($o_dom) = @_;
	my ($n, $o_field, $clock, $reset, %hclocks, %hresult);
	my $bus_clock = $this->global->{'bus_clock'};

	$n = 0;
	$clock = "";
	# iterate all fields and retrieve clock names
	foreach $o_field (@{$o_dom->fields}) {
		$clock = $o_field->attribs->{'clock'};
		$reset = $o_field->attribs->{'reset'};
		if ($clock  =~ m/[\%OPEN\%|\%EMPTY\%]/) {
			$clock = $bus_clock; # use default clock
		};
		if (!exists($hresult{$clock})) {
			$hresult{$clock} = {'reset' => $reset }; # store clock name as key in hash
			if ($clock eq $bus_clock) {
				$hresult{$clock}->{'sync'} = 0;
			}else {
				$hresult{$clock}->{'sync'} = 1;
			};
			$n++;
		};
	};
	# if more than one clocks in the domain but MCD feature is off, delete all clocks other than the bus_clock
	if ($n>1 and !$this->global->{'multi_clock_domains'}) {
		my @lkeys = keys %hresult;
		foreach $clock (@lkeys) {
			if ($clock ne $bus_clock) {
				delete $hresult{$clock};
				$n--;
			};
		};
		if($n <= 0) {
			_error("parameter \'multi_clock_domains\' is disabled but multiple clocks are in the design; one of them MUST be clock \'$bus_clock\' as defined by parameter \'bus_clock\'; contact support if in doubt");
		};
	};
	$this->global('hclocks' => \%hresult);
	return $n;
};

# adds standard ports and connections to modules (OCP i/f, handshake i/f, clocks, resets)
sub _vgch_rs_add_static_connections {
	my $this = shift;
	my $ocp_i = $this->global->{'ocp_inst'};
	my ($mcda_i, $cfg_i, $sg_i, $sr_i, $clock, $is_async, $href);
	my $bus_clock = $this->global->{'bus_clock'};
	my $bus_reset = $this->global->{'bus_reset'};

	if (exists($this->global->{'mcda_inst'})) {
		$mcda_i = $this->global->{'mcda_inst'};
	};

	_add_primary_input($bus_clock, 0, 0, "${ocp_i}/clk");
	_add_primary_input("mcmd", 2, 0, $ocp_i);
	_add_primary_input("maddr", $this->global->{'addrwidth'}-1, 0, $ocp_i);
	_add_primary_input("mdata", $this->global->{'datawidth'}-1, 0, $ocp_i);
	_add_primary_input("mrespaccept", 0, 0, $ocp_i);
	_add_primary_output("scmdaccept", 0, 0, 0, $ocp_i);
	_add_primary_output("sresp", 1, 0, 0, $ocp_i);
	_add_primary_output("sdata", $this->global->{'datawidth'}-1, 0, 0, $ocp_i);
	
	# BAUSTELLE connect trans_done, rd_data, rd_err through MCDA for multi_clock_domain
	foreach $clock (keys %{$this->global->{'hclocks'}}) {
		$href = $this->global->{'hclocks'}->{$clock};
		$cfg_i = $href->{'cfg_inst'};
		$sg_i = $href->{'sg_inst'};
		$sr_i = $href->{'sr_inst'};
		_add_primary_input($clock, 0, 0, "${cfg_i}");
		_add_primary_input($clock, 0, 0, "${sg_i}/clk_r");
		_add_primary_input($clock, 0, 0, "${sr_i}/clk_r");
		_add_primary_input($href->{'reset'}, 0, 0, "${cfg_i}");
		_add_primary_input($href->{'reset'}, 0, 0, "${sg_i}/rst_r");
		_add_primary_input($href->{'reset'}, 0, 0, "${sr_i}/rst_i");

		_add_connection("addr",  $this->global->{'addrwidth'}-1, 0, "${ocp_i}/addr_o", "${cfg_i}/addr_i");
		_add_connection("trans_start", 0, 0, "${ocp_i}/trans_start_o", "$sg_i/snd_i");
		_add_connection("wr_data", $this->global->{'datawidth'}-1, 0, "${ocp_i}/wr_data_o", "${cfg_i}/wr_data_i");
		_add_connection("rd_wr", 0, 0, "${ocp_i}/rd_wr_o", "${cfg_i}/rd_wr_i");
		_add_connection("trans_done", 0, 0, "${cfg_i}/trans_done_o", "${ocp_i}/trans_done_i");
		_add_connection("rd_data", $this->global->{'datawidth'}-1, 0, "${cfg_i}/rd_data_o", "${ocp_i}/rd_data_i");
		_add_connection("rd_err", 0, 0, "${cfg_i}/rd_err_o", "${ocp_i}/rd_err_i");
		_add_connection("int_rst_n", 0, 0, "${sr_i}/rst", "");
		_add_connection("trans_start_p", 0, 0, "${sg_i}/rcv", "");
	};
	
	# connect the OCP target's reset
	_add_primary_input($bus_reset, 0, 0, "${ocp_i}/rst_n");
};

sub _get_address_msb_lsb {
	my($this, $o_domain) = @_;
	my($msb, $lsb, $href, $i);
	
	$msb = 0;
	foreach $href (@{$o_domain->addrmap}) {
		while($href->{'offset'} > 2**($msb+1)-1) {
			$msb++;
		}; 
	};
	
	# determine lsb of address
	for ($i=0; $i<=4; $i++) {
		if($this->global->{'datawidth'} == (8,16,32,64)[$i]) {
		   $lsb = $i;
		   last;
	   };
	};
	print "> msb $msb lsb $lsb <\n";
	return ($msb, $lsb);
};

sub _get_rrange {
	my ($this, $pos, $o_field) = @_;
	my $size = $o_field->attribs->{'size'};
	
	if ($pos + $size >  $this->global->{'datawidth'}) {
		_error("field \'",$o_field->name,"\' exceeds datawidth");
		return;
	};
	if ($pos == 0 and $size == $this->global->{'datawidth'}) {
		return "";
	} else {
		return $this->_gen_vector_range($pos + $size - 1, $pos);
	};
};

# extract clock and reset names from field, set default values if necessary, and complain when proper
sub _get_field_clock_and_reset {
	my $this = shift;
	my ($rclock, $rreset, $last_clock, $last_reset, $o_field) = @_;
	
	my $fclock = $o_field->attribs->{'clock'};
	if ($fclock  =~ m/[\%OPEN\%|\%EMPTY\%]/) {
		$fclock = $last_clock; # use last clock
	};
	if ($fclock eq "") {
		$fclock = $rclock;
	} elsif ($last_clock ne ""  and $last_clock ne $fclock) {
		_warning("field \'",$o_field->name,"\' has a different clock than other field(s) in this register");
	}
	my $freset = $o_field->attribs->{'reset'};
	if ($freset =~ m/[\%OPEN\%|\%EMPTY\%]/) {
		$freset = $last_reset; # use last reset
	};
	if ($freset eq "") {
		$freset = $rreset;
	} elsif ($last_reset ne "" and $last_reset ne $freset) {
		_warning("field \'",$o_field->name,"\' has a different reset than other field(s) in this register");
	};
	return ($fclock, $freset);
};

#	# add OR instance for data vector reduction
#	my $or_inst = add_inst
#	  (
#	   '::parent' => $inst,
#	   '::inst' => "sdata_redux",
#	   '::entity' => "%OR%",
#	   '::lang' => $this->global->{'lang'},
#	   '::conf' => "%NO_CONFIG%"
#	  );
#	_add_connection("int_sdata", $EH{'reg_shell'}{'datawidth'}-1, 0, $or_inst, "");

# helper function to call add_inst()
sub _add_instance {
	my($this, $name, $parent, $comment) = @_;
	return add_inst
	  (
	   '::entity' => $name,
	   '::inst'   => '%PREFIX_INSTANCE%%::entity%%POSTFIX_INSTANCE%',
	   '::descr'  => $comment,
	   '::parent' => $parent,
	   '::lang'   => $this->global->{'lang'}
	  );
};

# like _add_instance but the instance name is unique
{
	my($unumber) = 0; # static variable for this method
	sub _add_instance_unique {
		my($this, $name, $parent, $comment) = @_;
		my($uname) = "%PREFIX_INSTANCE%u${unumber}%POSTFIX_INSTANCE%";
		$unumber++;
		return add_inst
		  (
		   '::entity' => $name,
		   '::inst'   => $uname,
		   '::descr'  => $comment,
		   '::parent' => $parent,
		   '::lang'   => $this->global->{'lang'}
		  );
	}
};

# function to generate a vector range
sub _gen_vector_range {
	my($this, $msb, $lsb) = @_;
	my $result;
	my $lang = $this->global->{'lang'};
	
	if ($lang eq "vhdl") {
		if ($msb == $lsb) {
			$result = sprintf("(%d)", $lsb);
		} else {
			$result = sprintf("(%d downto %d)", $msb, $lsb);
		};
	} else {
		if ($msb == $lsb) {
			$result = sprintf("[%d]", $lsb);
		} else {
			$result = sprintf("[%d:%d]", $msb, $lsb);
		};
	};
	return $result	  
};

#------------------------------------------------------------------------------
# non-OO helper functions
#------------------------------------------------------------------------------

# wrap logwarn for errors
sub _error {
	my @ltxt = @_;
	logwarn("ERROR: ".join("",@ltxt));
	if (defined (%EH)) { $EH{'sum'}{'errors'}++;};				
};

sub _warning {
	my @ltxt = @_;
	logwarn("WARNING: ".join("",@ltxt));
	if (defined (%EH)) { $EH{'sum'}{'warnings'}++;};				
};

sub _info {
	my @ltxt = @_;
	logwarn("INFO: ".join("",@ltxt));
};

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
	my (%hconn, $src, $dest);
	# BAUSTELLE
	#my $postfix_in = ($name =~ m/^clk/i) ? "" : $EH{'postfix'}{POSTFIX_PORT_IN};
	#my $postfix_out = ($name =~ m/^clk/i) ? "" : $EH{'postfix'}{POSTFIX_PORT_OUT};
	#my $postfix_in = ($name =~ m/^clk/i) ? "" : "%POSTFIX_PORT_IN%";
	#my $postfix_out = ($name =~ m/^clk/i) ? "" : "%POSTFIX_PORT_OUT%";
	
	
#	if ($destination eq "") {
#		$dest = ""; 
#	} else {
#		$dest = ($destination =~ m/\//g) ? "${destination}$postfix_in" : "${destination}/${name}$postfix_in";
#	};
#	if ($source eq "") {
#		$src = "";
#	} else {
#		$src = ($source =~ m/\//g) ? "${source}$postfix_out" : "${source}/${name}$postfix_out";
#	};
	$hconn{'::name'} = $name;
	$hconn{'::in'} = $destination;
	$hconn{'::out'} = $source;
	#$hconn{'::in'} = $dest;
	#$hconn{'::out'} = $src;
	_get_signal_type($msb, $lsb, 0, \%hconn);
	add_conn(%hconn);
};

# function to add top-level input
sub _add_primary_input {
	my ($name, $msb, $lsb, $destination) = @_;
	my %hconn;
	my $postfix = ($name =~ m/^clk/) ? "" : "%POSTFIX_PORT_IN%";

	$hconn{'::name'} = "${name}${postfix}";
	$hconn{'::in'} = $destination;
	$hconn{'::mode'} = "i";
	_get_signal_type($msb, $lsb, 0, \%hconn);
	add_conn(%hconn);
};

# function to add output to top-level BAUSTELLE need wire/reg
sub _add_primary_output {
	my ($name, $msb, $lsb, $is_reg, $source) = @_;
	my %hconn;
	my $postfix = ($name =~ m/^clk/) ? "" : "%POSTFIX_PORT_OUT%";

	$hconn{'::name'} = "${name}${postfix}";
	$hconn{'::out'} = $source;
	$hconn{'::mode'} = "o";
	_get_signal_type($msb, $lsb, $is_reg, \%hconn);
	add_conn(%hconn);
};

# function to set ::type, ::high, ::low for add_conn() BAUSTELLE need wire/reg
sub _get_signal_type {
	my($msb, $lsb, $is_reg, $href) = @_;
	$href->{'::type'} = $is_reg ? "reg":"wire";
	if ($msb =~ m/[a-zA-Z_]+/g or $lsb =~ m/[a-zA-Z_]+/g) { # alphanumeric range
		if ($msb eq $lsb) {
			delete $href->{'::high'};
			delete $href->{'::low'};
		} else {
			$href->{'::high'} = $msb;
			$href->{'::low'} = $lsb;
		};
	} else {
		if ($msb == $lsb) { # numeric range
			delete $href->{'::high'};
			delete $href->{'::low'};
		} else {
			$href->{'::high'} = $msb;
			$href->{'::low'} = $lsb;
		};
	};
};

#------------------------------------------------------------------------------
# Pads the specified column $i (0..n) of an array @$lref containing lines with
# whitespaces to align it to the widest column;
# Leading white spaces are added according to indentation level $nindent and
# indentation symbol indent;
# comment lines and empty lines will be skipped;
# Input strings that contain \n must use ^n instead, will later be replaced
#------------------------------------------------------------------------------
sub _pad_column {
	my($col, $indent, $nindent, $lref) = @_;
	my($line, @buf, $max_len, $i);
	
	# get width of widest column
	$max_len = -1;
	foreach $line (@$lref) {
		#$line =~ s/^\s+//;
		if ($line !~ m/^--/ and $line !~ m/^\/\// and $line !~ m/^\#/ and $line !~ m/^\s+/ and $line ne ""){
			# # if $line contains a range, change spaces to '_' to avoid splitting the range
			# $line =~ s/(\s)downto(\s)/_downto_/ig;
			@buf = split(/\s+/, $line);
			if (scalar(@buf) >= $col+1) {
				$max_len =  _max($max_len, length($buf[$col]));
			}
		}
	}
	
	# concatenate leading whitespace string
	$indent = $indent x $nindent;
	
	# pad columns with whitespace and insert leading indentation
	$i=0;
	foreach $line (@$lref) {
		if ($line !~ m/^--/ and $line !~ m/^\/\// and $line !~ m/^\#/ and $line !~ m/^\s+/ and $line ne ""){
			$line =~ s/^\s+//;
			# # if $line contains a range, change spaces to '_' to avoid splitting the range
			#$line =~ s/(\s)downto(\s)/_downto_/ig;
			@buf = split(/\s+/, $line);
			if (scalar(@buf) >= $col+1) {
				_pad_str($max_len, \$buf[$col]);
			}
			$line = "${indent}".join(' ',@buf);
			# $line =~ s/_downto_/ DOWNTO /ig;
			$line =~ s/\^n/\n/g; # replace ^n with \n
			$$lref[$i] = $line; 
		}elsif ($line ne "") {
			$$lref[$i] = "${indent}".$line;
		}
		$i++;
	}
}

# max() - get max value of two values
sub _max {
  my(@c)=@_;
  if ($c[0] >= $c[1]) {
    return $c[0];
  }else {
    return $c[1];
  }
};

# pad_str - add whitespaces to end of str until it has specified size
sub _pad_str {
  my($size, $ref) = @_;
  my($i);
  for ($i=length($$ref); $i < $size; $i++) {
    $$ref = $$ref." ";
  }
  1;
}
1;
