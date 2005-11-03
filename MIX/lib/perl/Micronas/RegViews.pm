###############################################################################
#  RCSId: $Id: RegViews.pm,v 1.8 2005/11/03 13:22:26 lutscher Exp $
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
#  Revision 1.8  2005/11/03 13:22:26  lutscher
#  some fixes for code generation for USR registers
#
#  Revision 1.7  2005/10/28 12:17:28  lutscher
#  many changes to fix the generated Verilog code
#
#  Revision 1.6  2005/10/26 13:58:15  lutscher
#  added property generation and fixed some code issues
#
#  Revision 1.5  2005/10/20 17:26:05  lutscher
#  Reg.pm
#
#  Revision 1.4  2005/10/18 16:29:29  lutscher
#  intermedate checkin (stable and almost fully functional)
#
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
# output: 0 in case of non-recoverable error, 1 otherwise
sub _gen_view_vgch_rs {
	my $this = shift;
	my @ldomains;
	my $href;

	# extend class data with data structure needed for code generation
	$this->global(
				  'ocp_target_name'    => "ocp_target",
				  'mcda_name'          => "rs_mcda",
				  'regshell_prefix'    => "rs",     # register-shell prefix
				  'cfg_module_prefix'  => "rs_cfg", # prefix for config register block
				  'int_set_postfix'    => "_set_p", # postfix for interrupt-set input signal
				  'test_port_name'     => "test",   # name of test input
				  'field_spec_values'  => ['sha', 'w1c', 'usr'], # recognized values for spec attribute
				  'hclocks'            => {},
				  'indent'             => "    " # indentation character(s)
				 );

	# import regshell.<par> parameters from MIX package to class data; user can change these parameters in mix.cfg
	my $param;
	my @lmixparams = ('reg_shell.bus_clock', 
					  'reg_shell.bus_reset', 
					  'reg_shell.addrwidth', 
					  'reg_shell.datawidth',
					  'reg_shell.multi_clock_domains', 
					  'reg_shell.infer_clock_gating', 
					  'reg_shell.infer_sva',
					  'reg_shell.read_multicycle',
					  'postfix.POSTFIX_PORT_OUT', 
					  'postfix.POSTFIX_PORT_IN'
					 );
	foreach $param (@lmixparams) {
		my ($main, $sub) = split(/\./,$param);
		if (exists($EH{$main}{$sub})) {
			$this->global($sub => $EH{$main}{$sub});
			_info("setting parameter $param = ", $this->global->{$sub}) if $this->global->{'debug'};
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

		if ($n_clocks > 1) { 
			#if ($this->global->{'multi_clock_domains'}) {
			#	_error("multi_clock_domains = 1 not supported yet");
			#	return 0;
			#};
		} else {
			_info("multi_clock_domains = 1 ignored, only one clock ") if $this->global->{'multi_clock_domains'};
		};
		
		($top_inst, $ocp_inst) = $this->_vgch_rs_gen_hier($o_domain, $n_clocks); # generate module hierarchy

		$this->_vgch_rs_add_static_connections($n_clocks);# add all standard ports and connections 
		
		# iterate through all clock domains
		foreach $clock (keys %{$this->global->{'hclocks'}}) {
			my @ludc = ();
			$href = $this->global->{'hclocks'}->{$clock};
			$cfg_inst = $href->{'cfg_inst'};
			# print "> domain ",$o_domain->name,", clock $clock, cfg module $cfg_inst\n";
			$this->_vgch_rs_gen_cfg_module($o_domain, $clock, \@ludc); # generate config module for clock domain
			$this->_vgch_rs_write_udc($cfg_inst, \@ludc); # add user-defined-code to config module instantation
		};
	};
	$this->display() if $this->global->{'debug'}; # dump Reg class object
	1;
};

# main method to generate config module for a clock domain
# input: domain object, 
# clock-name of the domain,
# reference to list where code lines are added (::udc)
sub _vgch_rs_gen_cfg_module {
	my ($this, $o_domain, $clock, $lref_udc) = @_;
	my($o_reg, $shdw_sig);
	my $href = $this->global->{'hclocks'}->{$clock};
	my $cfg_i = $href->{'cfg_inst'};
	my (@ldeclarations) = ("", "/*","  local wire or register declarations","*/");
	my (@lstatic_logic) = ();
	my $reset = $href->{'reset'};
	my (%husr, %hshdw, %hassigns, %hwp, %haddr_tokens, %hrp);
	my $nusr = 0;
	my (@lassigns) = ("", "/*","  local wire and output assignments","*/");
	my (@ldefines) = ("", "/*", "  local definitions","*/");
	my ($addr_msb, $addr_lsb) = $this->_get_address_msb_lsb($o_domain);
	my (@lsp) = ();
	my (@lrp) = ();
	my (@lchecks) = ("", "/*","  checking code","*/");

	if ($addr_msb >= $this->global->{'addrwidth'}) {
		_error("register offsets are out-of-bounds (max ",2**$this->global->{'addrwidth'} -1,")");
		return 0;
	};

	# iterate through all registers of the domain and add ports/instantiations
	foreach $o_reg (@{$o_domain->regs}) {
		# $o_reg->display() if $this->global->{'debug'}; # debug
		my $reg_offset = $o_domain->get_reg_address($o_reg);	
		my $reg_name = uc("reg_"._val2hex($addr_msb+1, $reg_offset)); # generate a register name ourselves
		if (!exists($haddr_tokens{$reg_offset})) {
			if ($reg_offset % ($this->global->{'datawidth'}/8) != 0) {
				_error("register offset for \'",$o_reg->name,"\' is not aligned to bus data width - skipped");
				next;
			};
			$haddr_tokens{$reg_offset} = "${reg_name}_OFFS";
			# add defines for addresses
			push @ldefines, "\`define ".$haddr_tokens{$reg_offset}." ".($reg_offset >> $addr_lsb)." // ".$o_reg->name; 
			# declare register
			push @ldeclarations, "reg [".($this->global->{'datawidth'}-1).":0] $reg_name;";
		} else {
			_error("register offset $reg_offset for register \'", $o_reg->name, "\' already defined - skipped");
			next;
		};

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
			next if $o_field->name =~ m/^UPD[EF]/; # skip legacy UPD* regs

			# get field attributes
			my $spec = $o_field->attribs->{'spec'}; # note: spec can contain several attributs
			my $access = lc($o_field->attribs->{'dir'});
			my $rrange = $this->_get_rrange($href->{'pos'}, $o_field);
			my $lsb = $o_field->attribs->{'lsb'};
			my $msb = $lsb - 1 + $o_field->attribs->{'size'};
			my $res_val = sprintf("'h%x", $o_field->attribs->{'init'});

			# track USR fields
			if ($spec =~ m/usr/i) {
				$nusr++; # count number of USR fields
				if(exists($husr{$reg_name})) {
					logwarn("register \'",$o_reg->name,"\' has more than one field with USR attribute - will not generate more than one read/write pulse output; try to merge the fields or re-map into several registers"); 
				} else {
					$husr{$reg_offset} = $o_field; # store usr field in hash
				};
			};

			# track shadow signals
			if ($spec =~ m/sha/i) {
				$shdw_sig = $o_field->attribs->{'sync'};
				if(lc($shdw_sig) eq "nto" or $shdw_sig =~ m/[\%OPEN\%|\%EMPTY\%]/) {
					_error("field \'",$o_field->name,"\' is shadowed but has no shadow signal defined");
				} else {
					if($spec =~ m/w1c/i or $spec =~ m/usr/i) {
						_error("a shadowed field can not have w1c or usr attributes (here: ", $o_field->name, ")");
					} else {
						push @{$hshdw{$o_field->attribs->{'sync'}}}, $o_field;
					};
				}; 
			};

			# add ports, declarations and assignments
			if ($access =~ m/r/i and $access !~/w/i ) { # read-only
				_add_primary_input($o_field->name, $msb, $lsb, $cfg_i);
				if ($spec =~ m/sha/i) {
					push @ldeclarations, "reg [$msb:$lsb] ".$o_field->name."_shdw;";
				};
			} elsif ($access =~ m/w/i) { # write
				if ($spec !~ m/w1c/i) {
					_add_primary_output($o_field->name, $msb, $lsb, ($spec =~ m/sha/i) ? 1:0, $cfg_i);
				} else { # w1c
					_add_primary_input($o_field->name.$this->global->{'int_set_postfix'}, 0, 0, $cfg_i);
				};
				if ($spec !~ m/sha/i) {
					$hassigns{$o_field->name.$this->global->{'POSTFIX_PORT_OUT'}} = $reg_name.$rrange;
				} else {
					$hassigns{$o_field->name."_shdw"} = $reg_name.$rrange;
					push @ldeclarations,"wire [$msb:$lsb] ".$o_field->name."_shdw;";
				};
				if($access =~ m/r/i and $spec =~ m/usr/i) { # usr read/write
					_add_primary_input($o_field->name, $msb, $lsb, $cfg_i);
				};
			};
			if ($spec =~ m/usr/i) { # usr read/write
				_add_primary_input($o_field->name."_trans_done_p", 0, 0, $cfg_i);
				if($access =~ m/r/i) {
					_add_primary_output($o_field->name."_rd_p", 0, 0, 1, $cfg_i);
				};
				if($access =~ m/w/i) {
					_add_primary_output($o_field->name."_wr_p", 0, 0, 1, $cfg_i);
				};
			};

			# registers in write processes
			if ($access =~ m/w/i and $spec !~ m/usr/i) { # write, except USR  fields
				if ($spec !~ m/w1c/i) { # read/write
					$hwp{'write'}->{$reg_name.$rrange} = $reg_offset;
					$hwp{'write_rst'}->{$reg_name.$rrange} = $res_val;
				} else { # w1c
					$hwp{'write_sts'}->{$reg_name.$rrange} = $o_field->name.$this->global->{'int_set_postfix'}.$this->global->{POSTFIX_PORT_IN};
					$hwp{'write_sts_rst'}->{$reg_name.$rrange} = $res_val;
				};
			};
			
			# registers for read mux
			if ($access =~ m/r/i) { # read
				if ($access =~ m/w/i) { # read/write
					if ($spec =~ m/sha/i) {
						push @{$hrp{$reg_offset}}, {$rrange => $o_field->name."_shdw"};
					} elsif ($spec =~ m/usr/i) {
						push @{$hrp{$reg_offset}}, {$rrange => $o_field->name.$this->global->{'POSTFIX_PORT_IN'}};
					} else {
						push @{$hrp{$reg_offset}}, {$rrange => $reg_name.$rrange};
					};
				} else { # read-only
					if ($spec =~ m/sha/i) {
						push @{$hrp{$reg_offset}}, {$rrange => $o_field->name."_shdw"};
					} else {
						push @{$hrp{$reg_offset}}, {$rrange => $o_field->name.$this->global->{'POSTFIX_PORT_IN'}};
					};
				};
			}; 
		}; # foreach $href
	}; # foreach $o_reg 

	# add ports, processes and synchronizer for shadow signals
	foreach $shdw_sig (keys %hshdw) {
		# add ports and wires/regs
		_add_primary_input("${shdw_sig}_en", 0, 0, $cfg_i);
		_add_primary_input("${shdw_sig}_force", 0, 0, $cfg_i);
		push @ldeclarations, split("\n","reg int_${shdw_sig};");

		# add synchronizer module (need unique instance names because MIX has flat namespace)
		my $s_inst = $this->_add_instance_unique("sync_generic", $cfg_i, "Synchronizer for update-signal $shdw_sig");
		_add_generic("kind", 3, $s_inst);
		_add_generic("sync", 1, $s_inst);
		_add_generic("act", 1, $s_inst);
		_add_generic("rstact", 0, $s_inst);
		_add_generic("rstval", 0, $s_inst);
		_add_primary_input($shdw_sig, 0, 0, "${s_inst}/snd_i");
		_add_primary_input($clock, 0, 0, "${s_inst}/clk_r");
		_add_primary_input($reset, 0, 0, "${s_inst}/rst_r");
		_add_connection("int_${shdw_sig}_p", 0, 0, "${s_inst}/rcv_o", "");
		_tie_input_to_constant("${s_inst}/clk_s", 0, 0, 0);
		_tie_input_to_constant("${s_inst}/rst_s", 0, 0, 0);

		# generate shadow process
		$this->_vgch_rs_code_shadow_process($clock, $shdw_sig, \%hshdw, \@lsp);
	};
	_pad_column(-1, $this->global->{'indent'}, 2, \@lsp); # indent

	# add glue-logic
	$this->_vgch_rs_code_static_logic($o_domain, $clock, \%husr, \%hshdw, \@ldeclarations, \@lstatic_logic, \@lchecks);
	_pad_column(0, $this->global->{'indent'}, 2, \@ldeclarations); # indent declarations
	
	# add assignments
	push @lassigns, map {"assign $_ = ".$hassigns{$_}.";"} sort keys %hassigns; 
	
	_pad_column(1, $this->global->{'indent'}, 2, \@lassigns); # indent assignments
	_pad_column(1, $this->global->{'indent'}, 2, \@ldefines); # indent defines

	# generate code for write processes
	my @lwp;
	$this->_vgch_rs_code_write_processes($clock, \%hwp, \%haddr_tokens, \@lwp);
	_pad_column(-1, $this->global->{'indent'}, 2, \@lwp); # indent

	# generate code for read mux
	$this->_vgch_rs_code_read_mux($clock, \%hrp, \%haddr_tokens, \@lrp);
	_pad_column(-1, $this->global->{'indent'}, 2, \@lrp); # indent

	# generate code for forwarded transactions
	my @lusr;
	$this->_vgch_rs_code_fwd_process($clock, \%husr, \%haddr_tokens, \@lusr);
	_pad_column(-1, $this->global->{'indent'}, 2, \@lusr); # indent

	_pad_column(-1, $this->global->{'indent'}, 2, \@lchecks); # indent checking code

	# insert everything
	push @$lref_udc, @ldefines, @ldeclarations, @lassigns, @lstatic_logic, @lwp, @lusr, @lsp, @lrp, @lchecks;
};

# create code for read logic from hash database
# input: clock-name,
# hash %hrep (offset1 => [ (reg_range1 => RHS),
#                     (reg_range2 => RHS) ] 
#        offset2 => [ (), ...]
#       ),
# hash with register-offset tokens (offset => token)
# ref. to list where code is added
# 
# RHS = verilog right-hand side assignment
sub _vgch_rs_code_read_mux {
	my ($this, $clock, $href_rp, $href_addr_tokens, $lref_rp) = @_;
	my  @linsert;
	my $ind = $this->global->{'indent'};
	my $ilvl = 0;
	my %hsens_list = ("iaddr" => "");
	my ($offs, $href, $sig, $cur_addr);
	my $n;

	if (scalar(keys %$href_rp)>0) {
		# get read-sensitivity list
		foreach $offs (keys %$href_rp) {
			foreach $href (@{$href_rp->{$offs}}) {
				$sig = (values(%{$href}))[0];
				$sig =~ s/\[.+\]$//;
				$hsens_list{$sig} = $offs;
			};
		};
		# prefix
		push @linsert, "", "/*","  read logic and mux process","*/";
		push @linsert, $ind x $ilvl . "assign rd_data_o = mux_rd_data;";
		push @linsert, $ind x $ilvl . "assign rd_err_o = mux_rd_err | addr_overshoot;";
		push @linsert, $ind x $ilvl++ . "always @(".join(" or ", sort {$a cmp $b || $hsens_list{$a} <=> $hsens_list{$b}} keys %hsens_list).") begin";
		push @linsert, $ind x $ilvl . "mux_rd_err  <= 0;";
		push @linsert, $ind x $ilvl . "mux_rd_data <= 0;";
		push @linsert, $ind x $ilvl++ . "case (iaddr)";

		foreach $offs (sort {$a <=> $b} keys %$href_rp) {
			$cur_addr = $href_addr_tokens->{$offs};
			push @linsert, $ind x $ilvl . "\`$cur_addr : begin";
			foreach $href (@{$href_rp->{$offs}}) {
				push @linsert, $ind x ($ilvl+1) . "mux_rd_data".(keys %{$href})[0] . " <= ".(values %{$href})[0].";";
			};
			push @linsert, $ind x $ilvl . "end";
			$n++;
		};
		push @linsert, $ind x $ilvl . "default: begin";
		push @linsert, $ind x ($ilvl+1) . "mux_rd_err <= 1; // no decode";
		push @linsert, $ind x $ilvl-- . "end";
		push @linsert, $ind x $ilvl-- . "endcase";
		push @linsert, $ind x $ilvl . "end";
	};
	push @$lref_rp, @linsert;
};

# create code for a shadow process for update signal $sig
# a field can have either write-shadow registers or read-shadow registers; read-shadowing is only implemented
# for read-only fields;
# if clock-gating is enabled, all shadow regs share the same gated clock;
# input: clock-name,
# hash with shadow signals and fields-array (shadow-signal => (list of fields))
# ref. to list where code is added
sub _vgch_rs_code_shadow_process {
	my ($this, $clock, $sig, $href_shdw, $lref_sp) = @_;
	my @linsert;
	my $ind = $this->global->{'indent'};
	my $ilvl = 0;
	my $o_field;
	my ($int_rst_n, $dummy1, $dummy2, $dummy3, $shdw_clk) = $this->_gen_unique_signal_names($clock);
	my ($shadow_clock) = $clock;
	my @ltemp;

	if (scalar(@{$href_shdw->{$sig}})>0) {
		if ($this->global->{'infer_clock_gating'}) {
			$shadow_clock = $shdw_clk;
		};
		# prefix
		push @linsert, "", "/*","  shadowing for update signal \'$sig\'","*/";
		# shadow signal
		push @linsert, $ind x $ilvl . "// generate internal update signal";
		push @linsert, $ind x $ilvl++ . "always @(posedge $clock or negedge $int_rst_n) begin";
		push @linsert, $ind x $ilvl . "if (~$int_rst_n)";
		push @linsert, $ind x ($ilvl+1) . "int_${sig} <= 1;";
		push @linsert, $ind x $ilvl . "else";
		push @linsert, $ind x ($ilvl+1) . "int_${sig} <= (int_${sig}_p & ${sig}_en".$this->global->{'POSTFIX_PORT_IN'}.") | ${sig}_force".$this->global->{'POSTFIX_PORT_IN'}.";";
		$ilvl--;
		push @linsert, $ind x $ilvl . "end";
		# assignment block
		push @linsert, $ind x $ilvl . "// shadow process";
		push @linsert, $ind x $ilvl++ . "always @(posedge $shadow_clock) begin";
		#if (!$this->global->{'infer_clock_gating'}) {
		push @linsert, $ind x $ilvl++ . "if (int_${sig}) begin";
		#};
		foreach $o_field (sort @{$href_shdw->{$sig}}) {
			if ($o_field->attribs->{'dir'} =~ m/w/i) {
				push @ltemp, $o_field->name . $this->global->{'POSTFIX_PORT_OUT'} ." <= ".$o_field->name."_shdw;";
			} else {
				if ($o_field->attribs->{'dir'} =~ m/r/i) {
					push @ltemp, $o_field->name . "_shdw <= " . $o_field->name . $this->global->{'POSTFIX_PORT_IN'} . ";"; 
				};
			};
		}; 
		_pad_column(0, $this->global->{'indent'}, $ilvl, \@ltemp);
		push @linsert, @ltemp;
		$ilvl--;
		#if (!$this->global->{'infer_clock_gating'}) {
		push @linsert, $ind x $ilvl-- . "end";
		#};
		push @linsert, $ind x $ilvl-- . "end";
	};
	push @$lref_sp, @linsert; 
};

# create code for transaction-forward-process from hash database and return a list with an entry for each line
# input:
# $clock clock name for processes
# %husr ( reg_name => field_name )
# hash with register-offset tokens (offset => token)
# ref. to list where code is added
sub _vgch_rs_code_fwd_process {
	my ($this, $clock, $href_usr, $href_addr_tokens, $lref_usr) = @_;
	my @linsert;
	my $ind = $this->global->{'indent'};
	my $ilvl = 0;
	my @lmap = sort { $a <=> $b } keys %$href_usr;
	my $nusr = scalar(keys %$href_usr);
	my ($int_rst_n, $trans_start_p) = $this->_gen_unique_signal_names($clock);
	my (@ltemp, @ltemp2, $sig);
	my ($sig_read) =  "rd_wr".$this->global->{'POSTFIX_PORT_IN'}; 
	my ($sig_write) = "~rd_wr".$this->global->{'POSTFIX_PORT_IN'};
	my ($rw, $dcd);

	if (scalar(keys %{$href_usr})>0) {
		# prefix
		push @linsert, "", "/*","  txn forwarding process","*/";

		# reset logic
		push @ltemp, "fwd_txn <= 0;";
		for (my $i=0; $i<scalar(@lmap); $i++) {
			$rw="";
			my $o_field = $href_usr->{$lmap[$i]};
			if ($o_field->attribs->{'dir'} =~ m/r/i) {
				push @ltemp, $o_field->name . "_rd_p".$this->global->{'POSTFIX_PORT_OUT'} . " <= 0;";
				$dcd = "(iaddr == `".$href_addr_tokens->{$lmap[$i]}.")";
				$rw = " & ${sig_read}";
				
			};
			if ($o_field->attribs->{'dir'} =~ m/w/i) {
				push @ltemp, $o_field->name . "_wr_p".$this->global->{'POSTFIX_PORT_OUT'} . " <= 0;"; 
				$dcd = "(iaddr == `".$href_addr_tokens->{$lmap[$i]}.")"; 
				if ($rw eq "") {
					$rw .= " & ${sig_write}";
				} else {
					$rw = ""; # collapse logic
				}; 
			};
			push @ltemp2, $dcd.$rw;
		};
		push @linsert, "// decode addresses of USR registers and read/write";
		push @linsert, "assign fwd_decode_vec = {".join(", ",@ltemp2)."};", "";
		push @linsert, $ind x $ilvl++ . "always @(posedge $clock or negedge $int_rst_n) begin";
		push @linsert, $ind x $ilvl++ . "if (~$int_rst_n) begin";
		_pad_column(0, $this->global->{'indent'}, $ilvl, \@ltemp);
		push @linsert, @ltemp;
		@ltemp=();
		$ilvl--;
		push @linsert, $ind x $ilvl . "end";
		push @linsert, $ind x $ilvl++ . "else begin";

		# default values
		for (my $i=0; $i<$nusr; $i++) {
			my $o_field = $href_usr->{$lmap[$i]};
			if ($o_field->attribs->{'dir'} =~ m/r/i) {
				push @ltemp, $o_field->name . "_rd_p".$this->global->{'POSTFIX_PORT_OUT'} . " <= 0;"; 
			};
			if ($o_field->attribs->{'dir'} =~ m/w/i) {
				push @ltemp, $o_field->name . "_wr_p".$this->global->{'POSTFIX_PORT_OUT'} . " <= 0;"; 
			};
		};
		_pad_column(0, $this->global->{'indent'}, $ilvl, \@ltemp);
		push @linsert, @ltemp;
		@ltemp=();

		# read/write pulse generation
		push @linsert, $ind x $ilvl++ . "if ($trans_start_p) begin";
		push @ltemp, "fwd_txn <= |fwd_decode_vec; // set flag for forwarded txn";
		for (my $i=0; $i<scalar(@lmap); $i++) {
			my $o_field = $href_usr->{$lmap[$i]};
			if ($o_field->attribs->{'dir'} =~ m/r/i) {
				$sig = $o_field->name . "_rd_p".$this->global->{'POSTFIX_PORT_OUT'};
				push @ltemp, $sig . " <= fwd_decode_vec[".($nusr-$i-1)."] & ${sig_read};"; 
			};
			if ($o_field->attribs->{'dir'} =~ m/w/i) {
				$sig = $o_field->name . "_wr_p".$this->global->{'POSTFIX_PORT_OUT'};
				push @ltemp, $sig . " <= fwd_decode_vec[".($nusr-$i-1)."] & ${sig_write};"; 
			};
		};
		_pad_column(0, $this->global->{'indent'}, $ilvl, \@ltemp);
		push @linsert, @ltemp;
		@ltemp=();
		$ilvl--;
		push @linsert, $ind x $ilvl . "end";
		push @linsert,  $ind x $ilvl++ . "else if (trans_done_p)";
		push @linsert,  $ind x $ilvl-- . "fwd_txn <= 0; // reset flag for forwarded transaction";
		push @linsert, $ind x $ilvl-- . "end";
		push @linsert, $ind x $ilvl-- . "end";
		push @$lref_usr, @linsert;
	};
};

# create code for write processes from hash database and return a list with an entry for each line
# input:
# $clock clock name for processes
# %hwp ( write => (LHS => RHS)),
#        write_rst => (LHS => RHS),
#        write_sts => (LHS => RHS),
#        write_sts_rst => (LHS => RHS),)
# hash with register-offset tokens (offset => token)
# ref. to list where code is added
#
# LHS/RHS = left/right-hand-side in verilog assignment
sub _vgch_rs_code_write_processes {
	my ($this, $clock, $href_wp, $href_addr_tokens, $lref_wp) = @_;
	my $write_clock = $clock;
	my $write_sts_clock = $clock;
	my $ind = $this->global->{'indent'};
	my $ilvl = 0;
	my (@linsert, @ltemp, $last_addr, $cur_addr, $reg_name, $reg_addr, $rrange);
	my $key;
	my $offs;
	my ($int_rst_n, $trans_start_p, $wr_clk) = $this->_gen_unique_signal_names($clock);

	#
	#  write block for normal registers
	#
	
	if (scalar(keys %{$href_wp->{'write'}})>0) {
		if ($this->global->{'infer_clock_gating'}) {
			$write_clock = $wr_clk; # use gated clock
		};
		# prefix
		push @linsert, "", "/*","  write process","*/";
		push @linsert, $ind x $ilvl++ . "always @(posedge $write_clock or negedge $int_rst_n) begin";

		# reset logic
		push @linsert, $ind x $ilvl++ . "if (~$int_rst_n) begin";
		@ltemp=();
		foreach $key (sort keys %{$href_wp->{'write_rst'}}) {
			push @ltemp, "$key <= $href_wp->{'write_rst'}->{$key};";
		};
		
		_pad_column(0, $ind, $ilvl, \@ltemp);
		push @linsert, @ltemp;
		$ilvl--;
		
		# write logic
		push @linsert, $ind x $ilvl ."end", $ind x $ilvl++ . "else begin";
		if (!$this->global->{'infer_clock_gating'}) {
			push @linsert, $ind x $ilvl++ . "if (wr_p)";
		};
		push @linsert, $ind x $ilvl++ . "case (iaddr)";
		@ltemp=();
		$last_addr = "-1";
		foreach $key (sort {$href_wp->{'write'}->{$a} <=> $href_wp->{'write'}->{$b}} keys %{$href_wp->{'write'}}) {
			$reg_name = $key;
			$offs = $href_wp->{'write'}->{$key};
			$rrange = "";
			if ($reg_name =~ m/(\[.+\])$/) {
				$reg_name = $`;
				$rrange = $1;
			};
			$cur_addr = $href_addr_tokens->{$offs}; # use tokenized address instead of number
			if ($cur_addr ne $last_addr) {
				if(scalar(@ltemp) > 0) {
					$reg_addr = $last_addr;
					push @linsert, $ind x $ilvl . "\`$reg_addr: begin";
					_pad_column(0, $ind, $ilvl+1, \@ltemp);
					push @linsert, sort @ltemp;
					push @linsert, $ind x $ilvl . "end";
					@ltemp=();
				};
				$last_addr = $cur_addr;
			}
			push @ltemp, "$key <= wr_data".$this->global->{POSTFIX_PORT_IN}."$rrange;";
		};
		# push last entries to list
		if (scalar(@ltemp) > 0) {
			$reg_addr = $cur_addr;
			push @linsert, $ind x $ilvl . "\`$reg_addr: begin";
			_pad_column(0, $ind, $ilvl+1, \@ltemp);
			push @linsert, @ltemp;
			push @linsert, $ind x $ilvl . "end";
			@ltemp=();
		};
		push @linsert, $ind x $ilvl-- . "default: ;";
		push @linsert, $ind x $ilvl-- . "endcase";
		if (!$this->global->{'infer_clock_gating'}) { $ilvl--; };
		push @linsert, $ind x $ilvl-- . "end";
		push @linsert, $ind x $ilvl . "end";
		@$lref_wp = @linsert;
	};

	#
	#  write block for status registers
	#
	@linsert = ();
	if (scalar(keys %{$href_wp->{'write_sts'}})>0) {
		# prefix
		push @linsert, "", "/*","  write process for status registers","*/";
		push @linsert, $ind x $ilvl . "always @(posedge $write_sts_clock or negedge $int_rst_n) begin";
		
		# reset logic
		push @linsert, $ind x ($ilvl+1) . "if (~$int_rst_n) begin";
		$ilvl = $ilvl+2;
		@ltemp=();
		foreach $key (sort keys %{$href_wp->{'write_sts_rst'}}) {
			push @ltemp, "$key <= $href_wp->{'write_sts_rst'}->{$key};";
		};
		
		_pad_column(0, $ind, $ilvl, \@ltemp);
		push @linsert, @ltemp;
		$ilvl--;
		push @linsert, $ind x $ilvl ."end", $ind x $ilvl++ . "else begin";
		
		# write logic
		foreach $key (sort {$href_wp->{'write_sts'}->{$a} <=> $href_wp->{'write_sts'}->{$b}} keys %{$href_wp->{'write_sts'}}) {
			$reg_name = $key;
			$rrange = "";
			if ($reg_name =~ m/(\[.+\])$/) {
				$reg_name = $`;
				$rrange = $1;
			};
			$offs = uc($reg_name . "_offs");
			push @linsert, $ind x $ilvl++ ."if ($href_wp->{'write_sts'}->{$key})";
			push @linsert, $ind x $ilvl-- ."$key <= 1;";
			push @linsert, $ind x $ilvl++ ."else if (wr_p && iaddr == \`".$offs.")";
			push @linsert, $ind x $ilvl-- ."$key <= $key & ~wr_data".$this->global->{POSTFIX_PORT_IN}."$rrange;";
		};
		$ilvl--;
		push @linsert, $ind x $ilvl-- ."end";
		push @linsert, $ind x $ilvl-- ."end";
		push @$lref_wp, @linsert;
	};
};

# add standard logic constructs; adds to two lists: declarations and udc.
# performs text indentation/alignment only on udc lists.
sub _vgch_rs_code_static_logic {
	my ($this, $o_domain, $clock, $href_usr, $href_shdw, $lref_decl, $lref_udc, $lref_checks) = @_;
	my ($addr_msb, $addr_lsb) = $this->_get_address_msb_lsb($o_domain);
	my ($o_field, $href, $shdw_sig, $nusr, $sig, $dummy);
	my ($int_rst_n, $trans_start_p, $wr_clk, $wr_clk_en, $shdw_clk, $shdw_clk_en) = $this->_gen_unique_signal_names($clock);
	my (@ltemp, @ltemp2);

	my $ind = $this->global->{'indent'};
	my $multicyc = $this->global->{'read_multicycle'};
	$nusr=scalar(keys %$href_usr); # number of USR fields
	if ($nusr>0 and $multicyc>0) {
		# if there are USR registers, the read-ack will be delayed by one cycle anyway, so subtract
		# it from the user"s  multicycle value 
		$multicyc--;	
	};
	
	#
	# insert wire/reg declarations
	#
	push @$lref_decl, split("\n","
wire wr_p;
wire rd_p;
reg [".($this->global->{'datawidth'}-1).":0] mux_rd_data;
reg  int_trans_done;
reg  mux_rd_err;
wire [".($addr_msb-$addr_lsb).":0] iaddr;
wire addr_overshoot;
wire trans_done_p;
");
	if ($nusr>0) { # if there are USR fields
		push @$lref_decl, split("\n","
reg rd_done_p;
reg wr_done_p;
reg  fwd_txn;
wire [".($nusr-1).":0] fwd_decode_vec;
wire [".($nusr-1).":0] fwd_done_vec;
");
	} else {
		push @$lref_decl, split("\n","
wire rd_done_p;
wire wr_done_p;
");
	};
	for (my $i=1; $i<= $multicyc; $i++) {
		push @$lref_decl, "reg rd_delay$i;"; # define registers for delaying rd_done_p
	};
	
	#
	# insert static logic
	#
	@ltemp = split("\n","
// clip address to decoded range
assign iaddr = addr_i[$addr_msb:$addr_lsb];");
	if($addr_msb < $this->global->{'addrwidth'}-1) {
		push @ltemp, "assign addr_overshoot = |addr_i[".($this->global->{'addrwidth'}-1).":".($addr_msb+1)."];";
	} else {
		push @ltemp, "assign addr_overshoot = 0;";
	};
	
	# clock-gating logic
	if ($this->global->{'infer_clock_gating'}) {
		if (exists $this->global->{'hclocks'}->{$clock}->{'cg_write_inst'}) {
			push @ltemp, "", "// write-clock enable", "assign $wr_clk_en = wr_p;"; # | ~$int_rst_n ;";
		};
		if (exists $this->global->{'hclocks'}->{$clock}->{'cg_shdw_inst'}) {
			push @ltemp, "", "// shadow-clock enable", "assign $shdw_clk_en = |{" . join(",",map {"int_".${_}} keys %$href_shdw) . "};";
	    };
    };

	push @ltemp, split("\n","
// write txn start pulse
assign wr_p = ~rd_wr".$this->global->{'POSTFIX_PORT_IN'}." & $trans_start_p;

// read txn start pulse
assign rd_p = rd_wr".$this->global->{'POSTFIX_PORT_IN'}." & $trans_start_p;

/* 
  generate txn done signals
*/
");
	if ($nusr==0) {
		push @ltemp, split("\n","assign wr_done_p = wr_p; // immediate ack for posted writes");
		push @ltemp, "assign rd_done_p = " .($multicyc ? "rd_delay$multicyc;" : "rd_p;") . " // ack for local reads";
		push @ltemp, "assign trans_done_p = wr_done_p | rd_done_p;";
	} else {
		@ltemp2 = map {$href_usr->{$_}->{'name'}."_trans_done_p".$this->global->{'POSTFIX_PORT_IN'}} keys %$href_usr;
		$dummy = "assign fwd_done_vec = {" . join(", ", @ltemp2) . "}; // ack for forwarded txns";
		push @ltemp, $dummy;
		push @ltemp, "assign trans_done_p = ((wr_done_p | rd_done_p) & ~fwd_txn) | ((fwd_done_vec != 0) & fwd_txn);";
		
		if ($this->global->{'infer_sva'}) {
			# insert assertions (and onehot function because Cadence has not yet delivered)
			$dummy = join(" || ", @ltemp2); 
			push @$lref_checks, split("\n","
p_fwd_done_expected: assert property
(
   @(posedge $clock) disable iff (~$int_rst_n)
   $dummy |-> fwd_txn
);

p_fwd_done_onehot: assert property
(
   @(posedge $clock) disable iff (~$int_rst_n)
   $dummy |-> onehot(fwd_done_vec)
);

p_fwd_done_only_when_fwd_txn: assert property
(
   @(posedge $clock) disable iff (~$int_rst_n)
   fwd_done_vec != 0 |-> fwd_txn
);

function onehot (input [".($nusr-1).":0] vec); // not built-in to SV yet
  integer i,j;
  begin
     j = 0;
	 for (i=0; i<$nusr; i=i+1) j = j + vec[i] ? 1 : 0;
	 onehot = (j==1) ? 1 : 0;
  end
endfunction
  
  ");
};
    };

	push @ltemp, ("",
				 "always @(posedge $clock or negedge $int_rst_n) begin",
				 $ind."if (~$int_rst_n) begin", 
				 $ind x 2 ."int_trans_done <= 0;"
				);
	for (my $i=1; $i<= $multicyc; $i++) {
		push @ltemp, $ind x 2 ."rd_delay$i <= 0;";
	};
    if ($nusr>0) {
        push @ltemp, (
                      $ind x 2 ."wr_done_p <= 0;",
                      $ind x 2 ."rd_done_p <= 0;"
                     );
    }; 
	push @ltemp, (
				  $ind."end",
				  $ind."else begin"
				 );
    if ($nusr>0) {
        push @ltemp, (
                      $ind x 2 ."wr_done_p <= wr_p;",
                      $ind x 2 ."rd_done_p <= " . ($multicyc ? "rd_delay$multicyc;" : "rd_p;")
                   );
    }
	for (my $i=1; $i<= $multicyc; $i++) {
		push @ltemp, ($i == 1) ? ($ind x 2 ."rd_delay$i \<= rd_p;") : ($ind x 2 ."rd_delay$i \<= rd_delay".($i-1).";");
	};

    push @ltemp, (
				  $ind x 2 ."if (trans_done_p)",
				  $ind x 3 ."int_trans_done <= ~int_trans_done;",
				  $ind."end",
				  "end",
				  "assign trans_done_o = int_trans_done;"
				 );
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
	my($clock, $bus_clock, $cfg_inst, $sg_inst, $sr_inst, $ocp_sync, $cgw_inst, $cgs_inst, $n, $sync_clock);
	my $refclks = $this->global->{'hclocks'};
	my $infer_cg = $this->global->{'infer_clock_gating'};
	my @lgen_filter = ();
	my $mcda_inst;

	# instantiate top-level module
	my $rs_name = $this->global->{'regshell_prefix'}."_".$o_domain->name;
	my $top_inst = $this->_add_instance($rs_name, "testbench", "Register shell for domain ".$o_domain->name);
	$this->global('top_inst' => $top_inst);
  	if ($infer_cg) {
		_add_generic("cgtransp", 0, $top_inst);
	};
	_add_generic("P_TOCNT_WIDTH", 10, $top_inst); # timeout counter width
	
	# instantiate OCP target
	my $ocp_inst = $this->_add_instance($this->global->{"ocp_target_name"}, $top_inst, "OCP target module");
	$this->global('ocp_inst' => $ocp_inst);
	if (defined (%EH)) {
		push @{$EH{'output'}{'filter'}{'file'}}, $ocp_inst;
	};
	_add_generic("P_DWIDTH", $this->global->{'datawidth'}, $ocp_inst);
	_add_generic("P_AWIDTH", $this->global->{'addrwidth'}, $ocp_inst);
	_add_generic("P_TOCNT_WIDTH", 10, $ocp_inst); # timeout counter width
	
	$ocp_sync = 0;

	# instantiate MCD adapter (if required)
	if ($nclocks > 1 and $this->global->{'multi_clock_domains'}) {
		$mcda_inst = $this->_add_instance($this->global->{"mcda_name"}, $top_inst, "Multi-clock-domain Adapter");	
		$this->global('mcda_inst' => $mcda_inst);
		_add_generic("N_DOMAINS", $nclocks, $mcda_inst);
		_add_generic("P_DWIDTH", $this->global->{'datawidth'}, $mcda_inst);
		push @lgen_filter, $mcda_inst;
	};
	
	# instantiate config register module(s) and sub-modules
	$sync_clock = 31415; # number of synchronous clock, default to invalid
	foreach $clock (sort keys %{$refclks}) {
		if ($refclks->{$clock}->{'sync'}) {
			# asynchronous config register module
			$cfg_inst = $this->_add_instance(join("_",$this->global->{"cfg_module_prefix"}, $o_domain->name, $clock), $top_inst, "Config register module for clock domain \'$clock\'");
			if (!exists($this->global->{'mcda_inst'})) { 
				$ocp_sync = 1; # OCP target needs synchronizer if no MCDA is instantiated
			};
		} else {
			# synchronous config register module
			$cfg_inst = $this->_add_instance(join("_",$this->global->{"cfg_module_prefix"}, $o_domain->name), $top_inst, "Config register module");
			$sync_clock = $n;
			if(exists($this->global->{'mcda_inst'})) {
				_add_generic("N_SYNCDOM", $sync_clock, $mcda_inst);
			};
		};
		# link clock domain to config register module
		$refclks->{$clock}->{'cfg_inst'} = $cfg_inst; # store in global->hclocks
		_add_generic("sync", $refclks->{$clock}->{'sync'}, $cfg_inst);

		# instantiate synchronizer modules (need unique instance names because MIX has flat namespace)
		$sg_inst = $this->_add_instance_unique("sync_generic", $cfg_inst, "Synchronizer for trans_done signal");
		$refclks->{$clock}->{'sg_inst'} = $sg_inst; # store in global->hclocks
		_add_generic("kind", 2, $sg_inst);
		_add_generic("sync", $refclks->{$clock}->{'sync'}, $sg_inst);
		_add_generic("act", 1, $sg_inst);
		_add_generic("rstact", 0, $sg_inst);
		_add_generic("rstval", 0, $sg_inst);
		$sr_inst = $this->_add_instance_unique("sync_rst", $cfg_inst, "Reset synchronizer");
		$refclks->{$clock}->{'sr_inst'} = $sr_inst; # store in global->hclocks
		_add_generic("sync", $refclks->{$clock}->{'sync'}, $sr_inst);
		_add_generic("act", 0, $sr_inst);
		push @lgen_filter, ($sr_inst, $sg_inst);

		# instantiate clock gating cell
		if ($infer_cg) {
			_add_generic("cgtransp", 0, $cfg_inst);
			if (exists $refclks->{$clock}->{'has_write'}) {
				$cgw_inst = $this->_add_instance_unique("ccgc", $cfg_inst, "Clock-gating cell for write-clock");
				_add_generic("cgtransp", 0, $cgw_inst);
				$refclks->{$clock}->{'cg_write_inst'} = $cgw_inst;
				push @lgen_filter, $cgw_inst;
			};
			if (exists $refclks->{$clock}->{'has_shdw'}) {
				$cgs_inst = $this->_add_instance_unique("ccgc", $cfg_inst, "Clock-gating cell for shadow-clock");
				_add_generic("cgtransp", 0, $cgs_inst);
				$refclks->{$clock}->{'cg_shdw_inst'} = $cgs_inst;
				push @lgen_filter, $cgs_inst;
			};
		};
		$n++;
	};
	# set N_SYNCDOM parameter for mcda if that did not happen yet
	if(exists($this->global->{'mcda_inst'}) && $sync_clock == 31415) {
		_add_generic("N_SYNCDOM", $sync_clock, $mcda_inst);
	};
	_add_generic("sync", $ocp_sync, $ocp_inst);

	# do not generate library modules
	if (defined (%EH)) {
		push @{$EH{'output'}{'filter'}{'file'}}, @lgen_filter;
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
		if ($o_field->attribs->{'spec'} =~ m/sha/i) {
			$hresult{$clock}->{'has_shdw'} = 1; # store if has shadowed registers
		};
		if ($o_field->attribs->{'dir'} =~ m/w/i) {
			$hresult{$clock}->{'has_write'} = 1; # store if has writable registers
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
	my ($this, $nclocks) = @_;
	my $ocp_i = $this->global->{'ocp_inst'};
	my ($mcda_i, $cfg_i, $sg_i, $sr_i, $clock, $is_async, $href, $n);
	my $bus_clock = $this->global->{'bus_clock'};
	my $bus_reset = $this->global->{'bus_reset'};
	my $dwidth = $this->global->{'datawidth'};
	my $awidth = $this->global->{'addrwidth'};

	$mcda_i = undef;
	if (exists($this->global->{'mcda_inst'})) {
		$mcda_i = $this->global->{'mcda_inst'};
	};

	_add_primary_input($bus_clock, 0, 0, "${ocp_i}/clk_i");
	_add_primary_input($bus_reset, 0, 0, "${ocp_i}/reset_n_i");
	_add_primary_input("mreset_n", 0, 0, $ocp_i);
	_add_primary_input("mcmd", 2, 0, $ocp_i);
	_add_primary_input("maddr", $awidth-1, 0, $ocp_i);
	_add_primary_input("mdata", $dwidth-1, 0, $ocp_i);
	_add_primary_input("mrespaccept", 0, 0, $ocp_i);
	_add_primary_output("scmdaccept", 0, 0, 0, $ocp_i);
	_add_primary_output("sresp", 1, 0, 0, $ocp_i);
	_add_primary_output("sdata", $dwidth-1, 0, 0, $ocp_i);

	# connections for each config register block
	$n=0;
	foreach $clock (sort keys %{$this->global->{'hclocks'}}) {
		my ($int_rst_n, $trans_start_p, $wr_clk, $wr_clk_en, $shdw_clk, $shdw_clk_en) = $this->_gen_unique_signal_names($clock);
		$href = $this->global->{'hclocks'}->{$clock};
		$cfg_i = $href->{'cfg_inst'};
		$sg_i = $href->{'sg_inst'};
		$sr_i = $href->{'sr_inst'};
		_add_primary_input($clock, 0, 0, $cfg_i);
		_add_primary_input($clock, 0, 0, "${sg_i}/clk_r");
		_add_primary_input($clock, 0, 0, "${sr_i}/clk_r");
		_add_primary_input($href->{'reset'}, 0, 0, $cfg_i);
		_add_primary_input($href->{'reset'}, 0, 0, "${sg_i}/rst_r");
		_add_primary_input($href->{'reset'}, 0, 0, "${sr_i}/rst_i");
		_add_primary_input($this->global->{'test_port_name'}, 0, 0, $cfg_i); # scan port, for later use
		_tie_input_to_constant("${sg_i}/clk_s", 0, 0, 0);
		_tie_input_to_constant("${sg_i}/rst_s", 0, 0, 0);

		_add_connection("addr",  $awidth-1, 0, "${ocp_i}/addr_o", "${cfg_i}/addr_i");
		_add_connection("trans_start", 0, 0, "${ocp_i}/trans_start_o", "$sg_i/snd_i");
		_add_connection("wr_data", $dwidth-1, 0, "${ocp_i}/wr_data_o", "${cfg_i}/wr_data_i");
		_add_connection("rd_wr", 0, 0, "${ocp_i}/rd_wr_o", "${cfg_i}/rd_wr_i");
		_add_connection($int_rst_n, 0, 0, "${sr_i}/rst_o", "");
		_add_connection($trans_start_p, 0, 0, "${sg_i}/rcv_o", "");
		if (!defined $mcda_i) {
			_add_connection("rd_err", 0, 0, "${cfg_i}/rd_err_o", "${ocp_i}/rd_err_i");
			_add_connection("trans_done", 0, 0, "${cfg_i}/trans_done_o", "${ocp_i}/trans_done_i");
			_add_connection("rd_data", $dwidth-1, 0, "${cfg_i}/rd_data_o", "${ocp_i}/rd_data_i");
		} else {
			# connect config register block to MCDA
			_add_connection("rd_data_vec", $dwidth*$nclocks-1, 0, "$cfg_i/rd_data_o=(".(($n+1)*$dwidth-1).":".($n*$dwidth).")", "$mcda_i/rd_data_vec_i");
			_add_connection("rd_err_vec",  $nclocks-1, 0, "$cfg_i/rd_err_o=($n)", "$mcda_i/rd_err_vec_i");
			_add_connection("trans_done_vec", $nclocks-1, 0, "$cfg_i/trans_done_o=($n)", "$mcda_i/trans_done_vec_i");
		};
		if (exists $href->{'cg_write_inst'}) {
			_add_primary_input($this->global->{'test_port_name'}, 0, 0, $href->{'cg_write_inst'});
			_add_primary_input($clock, 0, 0, $href->{'cg_write_inst'}."/clk_i");
			_add_connection($wr_clk_en, 0, 0, "", $href->{'cg_write_inst'}."/enable_i");
			_add_connection($wr_clk, 0, 0, $href->{'cg_write_inst'}."/clk_o", "");
		};
		if (exists $href->{'cg_shdw_inst'}) {
			_add_primary_input($this->global->{'test_port_name'}, 0, 0, $href->{'cg_shdw_inst'});
			_add_primary_input($clock, 0, 0, $href->{'cg_shdw_inst'}."/clk_i");
			_add_connection($shdw_clk_en, 0, 0, "", $href->{'cg_shdw_inst'}."/enable_i");
			_add_connection($shdw_clk, 0, 0, $href->{'cg_shdw_inst'}."/clk_o", "");
		};
		$n++;
	};
	
	# connect MCDA
	if (defined $mcda_i) {
		_add_primary_input($bus_clock, 0, 0, "${mcda_i}/clk_ocp");
		_add_primary_input("mreset_n", 0, 0, $mcda_i);
		_add_primary_input($bus_reset, 0, 0, "${mcda_i}/rst_ocp_n_i");
		_add_connection("trans_start", 0, 0, "${ocp_i}/trans_start_o", "$mcda_i/trans_start_i");
		_add_connection("trans_done", 0, 0, "$mcda_i/trans_done_o", "${ocp_i}/trans_done_i");
		_add_connection("rd_err", 0, 0, "${mcda_i}/rd_err_o", "${ocp_i}/rd_err_i");
		_add_connection("rd_data", $dwidth-1, 0, "${mcda_i}/rd_data_o", "${ocp_i}/rd_data_i");
	};

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
	
	if ($lang =~ m/vhdl/i) {
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

# generate unique names for some signals depending on clock domain in case of multi_clock_domains = 1;
# needed because MIX has flat namespace for signal names
sub _gen_unique_signal_names {
	my ($this, $clock) = @_;
	my $href = $this->global->{'hclocks'}->{$clock};

	if ($this->global->{'multi_clock_domains'} == 0 or scalar(keys %{$this->global->{'hclocks'}})==1) {
		return ("int_rst_n", "trans_start_p", "wr_clk", "wr_clk_en", "shdw_clk", "shdw_clk_en");
	} else {
		return (
				$href->{'sr_inst'}."_int_rst_n",
				$href->{'sg_inst'}."_trans_start_p",
				exists $href->{'cg_write_inst'} ? $href->{'cg_write_inst'}."wr_clk" : "wr_clk",
				exists $href->{'cg_write_inst'} ? $href->{'cg_write_inst'}."wr_clk_en" : "wr_clk_en",
				exists $href->{'cg_shdw_inst'} ? $href->{'cg_shdw_inst'}."shdw_clk" : "shdw_clk",
				exists $href->{'cg_shdw_inst'} ? $href->{'cg_shdw_inst'}."shdw_clk_en" : "shdw_clk_en"
			   );
	};
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

# function to create a constant for tying unused inputs
sub _tie_input_to_constant {
	my ($name, $value, $msb, $lsb) = @_;
	my %hconn;
	
	%hconn = ( 
			  '::name' => "tie${value}_".($msb - $lsb + 1),
			  '::out' => "$value",
			  '::in'  => "$name",
			  '::type' => "integer",
			  '::mode' => "C",
			  '::msb' => $msb,
			  '::lsb' => $lsb
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
	
	$hconn{'::out'} = "%GENERIC%/$value";
	$hconn{'::mode'} = "G";
	add_conn(%hconn);
};

# function to add a connection
sub _add_connection {
	my($name, $msb, $lsb, $source, $destination) = @_;
	my (%hconn, $src, $dest);	
	
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

# function to add output to top-level
sub _add_primary_output {
	my ($name, $msb, $lsb, $is_reg, $source) = @_;
	my %hconn;
	my $postfix = ($name =~ m/^clk/) ? "" : "%POSTFIX_PORT_OUT%";
	my $type = $is_reg ? "'reg":"'wire";

	$hconn{'::name'} = "${name}${postfix}";
	$hconn{'::out'} = $source.$type;
	$hconn{'::mode'} = "o";
	_get_signal_type($msb, $lsb, $is_reg, \%hconn);
	add_conn(%hconn);
};

# function to set ::type, ::high, ::low for add_conn()
sub _get_signal_type {
	my($msb, $lsb, $is_reg, $href) = @_;

	$href->{'::type'} = "";
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
			if (scalar(@buf) >= $col+1 and $col >= 0) {
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
			if (scalar(@buf) > $col and $col >= 0) {
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

# convert a number to hex string (w/o prefix)
{
	my(@ch)=('0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f');

	sub _val2hex {
		my($size, $val)=@_;
		my($result)="";
		my($i);
		
		$size = ($size < 4) ? 4 : $size;
		my($hsize) = (($size+3) >> 2) - 1;
		for ($i=0; $i<=$hsize; $i++) {
			$result = "$ch[$val%16]${result}";
			$val/=16;
		};
		return $result;
	};
};

1;
