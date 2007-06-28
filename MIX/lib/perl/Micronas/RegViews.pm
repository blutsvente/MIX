###############################################################################
#  RCSId: $Id: RegViews.pm,v 1.64 2007/06/28 07:57:02 lutscher Exp $
###############################################################################
#
#  Revision      : $Revision: 1.64 $                                  
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
#   Functions:
#   sub _gen_view_vgch_rs 
#   sub _vgch_rs_init
#   sub _vgch_rs_gen_cfg_module 
#   sub _vgch_rs_gen_udc_header
#   sub _vgch_rs_code_read_mux
#   sub _rdmux_builder
#   sub _rdmux_iterator
#   sub _vgch_rs_code_shadow_process
#   sub _vgch_rs_code_fwd_process
#   sub _vgch_rs_code_write_processes 
#   sub _vgch_rs_code_static_logic
#   sub _vgch_rs_write_udc
#   sub _vgch_rs_gen_hier 
#   sub _vgch_rs_gen_pre_dec_logic
#   sub _vgch_rs_get_configuration
#   sub _vgch_rs_add_static_connections 
#   sub _vgch_rs_write_defines
#   sub _vgch_rs_write_msd_setup
#   sub _indent_and_prune_sva 
#   sub _skip_field
#   sub _get_address_msb_lsb
#   sub _get_rrange
#   sub _get_frange
#   sub _get_field_clock_and_reset 
#   sub _add_instance
#   sub _add_instance_unique 
#   sub _gen_field_name
#   sub _gen_vector_range
#   sub _gen_unique_signal_name 
#   sub _gen_cond_rhs 
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
#  Revision 1.64  2007/06/28 07:57:02  lutscher
#  added translate_on/off for behavioural Verilog instances
#
#  Revision 1.63  2007/06/26 13:02:54  lutscher
#  removed exception for clock ports, postfix is now attached; fixed bug in read-pipeline generation for clock-gating disabled
#
#  Revision 1.62  2007/06/20 07:32:07  lutscher
#  fixed bug in _get_address_msb_lsb()
#
#  Revision 1.61  2007/06/19 08:20:34  lutscher
#  added ocp_checker instance to output.filter.file
#
#  Revision 1.60  2007/06/18 12:43:26  lutscher
#  added reg_shell.field_naming feature and instantiation of ocp checker module
#
#  Revision 1.59  2007/05/23 14:46:33  lutscher
#  added wr_err_i pin of new ocp_target module
#
#  Revision 1.58  2007/05/07 07:11:14  lutscher
#  added features infer_reset_syncer and enforce_unique_addr
#
#  Revision 1.57  2006/11/30 15:23:41  lutscher
#  fixed bug in code generation for USR registers and made improvements in generated write process
#
#  Revision 1.56  2006/11/13 11:31:49  lutscher
#  fixed _vgch_rs_code_read_mux in case there are no readable registers
#
#  Revision 1.55  2006/10/18 08:31:45  lutscher
#  renamed SV assertions according to naming rules
#
#  Revision 1.54  2006/10/18 08:16:36  lutscher
#  added field function is_cond()
#
#  Revision 1.53  2006/09/28 10:29:26  lutscher
#  changed generation of pre_dec module
#
#  Revision 1.52  2006/09/22 09:18:23  lutscher
#  improved _vgch_rs_write_defines() and added P_MIX_SIG parameter to instantiations
#
#  Revision 1.51  2006/09/11 06:32:46  lutscher
#  no changes
#
#  Revision 1.50  2006/09/01 15:20:38  lutscher
#  using Perl registration functions; added Verilog assertions in generated code
#
#  Revision 1.49  2006/08/30 08:02:49  lutscher
#  fixed bitwidth calculations
#
#  Revision 1.48  2006/08/24 09:45:37  lutscher
#  more fixes to the last issue
#
#  Revision 1.47  2006/08/24 09:23:00  lutscher
#  fixed problem with name-clashes for internal signals in generated code
#
#  Revision 1.46  2006/08/16 08:05:32  lutscher
#  fixed _gen_view_vgch_rs(), deletion of some per-domain global parameters was missing
#
#  Revision 1.45  2006/08/04 11:37:56  lutscher
#  fixed order of adding ports, order should now be more stable
#
#  Revision 1.44  2006/07/21 10:09:44  lutscher
#  fixed trg_p generation in Verilog code
#
#  Revision 1.43  2006/07/20 10:57:40  lutscher
#  changed code generation for MCD configurations
#
#  Revision 1.42  2006/06/28 09:16:02  lutscher
#  moved two reg_shell parameters to Globals.pm
#
#  Revision 1.41  2006/06/22 11:45:09  lutscher
#  removed an info message
#
#  [history deleted]
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
use Micronas::MixUtils qw($eh);
# use Micronas::MixChecker qw(mix_check_case);
use Micronas::Reg;
use Micronas::RegDomain;
use Micronas::RegReg;
use Micronas::RegField;
use Micronas::MixUtils::RegUtils;

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
	my $o_domain;
    
    # initialise some config variables
    $this->_vgch_rs_init();

	# make list of domains for generation
	if (scalar (@_)) {
		foreach my $domain (@_) {
			$o_domain = $this->find_domain_by_name_first($domain);
			if (ref($o_domain)) {
				push @ldomains, $this->find_domain_by_name_first($domain);
			} else {
				_error("unknown domain \'$domain\'");
			};
		};
	} else {
		foreach $href (@{$this->domains}) {
			push @ldomains, $href->{'domain'};
		};
	};

	# check parameters
	if ($this->global->{'read_pipeline_lvl'} > 0 and $this->global->{'read_multicycle'} >0) {
		$this->global->{'read_multicycle'} = 0;
		_info("parameter \'read_multicycle\' is ignored because read-pipelining is enabled");
	};

	# modify MIX config parameters (only where required)
	$eh->set('check.signal', 'load,driver,check');
    $eh->set('output.filter.file', "");
    $eh->set('output.generate.arch', "");
    $eh->set('check.name.all', 'na');
    $eh->set('log.limit.re.__I_CHECK_CASE', 1);
    $eh->set('log.limit.re.__W_CHECK_CASE', 1);

	# list of skipped registers and fields (put everything together in one list)
	if (exists($this->global->{'exclude_regs'})) {
		@{$this->global->{'lexclude_cfg'}} = split(/\s*,\s*/,$this->global->{'exclude_regs'});
	};
	if (exists($this->global->{'exclude_fields'})) {
		push @{$this->global->{'lexclude_cfg'}}, split(/\s*,\s*/,$this->global->{'exclude_fields'});
	};

	my ($o_field, $o_reg, $top_inst, $ocp_inst, $n_clocks, $cfg_inst, $clock);

	# iterate through all register domains
	foreach $o_domain (@ldomains) {
		_info("generating code for domain ",$o_domain->name);
		$o_domain->display() if $this->global->{'debug'};
        $this->global('current_domain' => $o_domain);

		# reset per-domain data structures
		$this->global('hfnames' => {});
		$this->global('hclocks' => {});
		map {delete $this->global->{$_}} grep $_ =~ m/_inst$/i,keys %{$this->global};

		$n_clocks = $this->_vgch_rs_get_configuration($o_domain); # get some general information

		($top_inst, $ocp_inst) = $this->_vgch_rs_gen_hier($o_domain, $n_clocks); # generate module hierarchy

		$this->_vgch_rs_add_static_connections($n_clocks);# add all standard ports and connections 
		
		# iterate through all clock domains
		foreach $clock (keys %{$this->global->{'hclocks'}}) {
			my @ludc = ();
            $this->global('hhdlconsts' => {});
			$href = $this->global->{'hclocks'}->{$clock};
			$cfg_inst = $href->{'cfg_inst'};
			# print "> domain ",$o_domain->name,", clock $clock, cfg module $cfg_inst\n";
			$this->_vgch_rs_gen_cfg_module($o_domain, $clock, \@ludc); # generate config module for clock domain
			$this->_vgch_rs_write_udc($cfg_inst, \@ludc); # add user-defined-code to config module instantation
		};
		# try to write out a Verilog file with defines
		$this->_vgch_rs_write_defines($o_domain);
	};
    # write a file with MSD setup
    $this->_vgch_rs_write_msd_setup();
	$this->display() if $this->global->{'debug'}; # dump Reg class object
	1;
};


# init global parameters and import mix.cfg parameters
sub _vgch_rs_init {
    my $this =  shift;

   	# extend class data with data structure needed for code generation
	$this->global(
                  'mix_signature'      => "\"M1\"",     # signature for cross-checking MIX software version and IP version
				  'ocp_target_name'    => "ocp_target", # library module name
                  'ocp_checker_name'   => "ocp_target_m_checker", # library module name
				  'mcda_name'          => "rs_mcda",    # library module name
                  'rtl_libs'           => [{            # required MSD RTL libraries
                                            "project" => "ip_ocp",
                                            "version" => "0001",
                                            "release" => "ip_ocp_003_18Jun2007" #ip_ocp_002_14May2007
                                           },
                                           {
                                            "project" => "ip_sync",
                                            "version" => "0001",
                                            "release" => "ip_sync_004_05apr2007"
                                           }
                                          ],  
                  'int_set_postfix'    => "_set_p",     # postfix for interrupt-set input signal
				  'scan_en_port_name'  => "test_en",    # name of test-enable input
				  'clockgate_te_name'  => "scan_shift_enable", # name of input to connect with test-enable port of clock-gating cell
				  'embedded_reg_name'  => "RS_CTLSTS",  # reserved name of special register embedded in ocp_target
				  'field_spec_values'  => ['sha', 'w1c', 'usr'], # recognized values for spec attribute
				  'indent'             => "    ",       # indentation character(s)
				  'assert_pragma_start'=> "`ifdef ASSERT_ON
// msd parse off",
				  'assert_pragma_end'  => "// msd parse on
`endif",
				  # internal static data structs
				  'hclocks'            => {},           # for storing per-clock-domain information
				  'hfnames'            => {},           # for storing field names
				  'lexclude_cfg'       => [],           # list of registers to exclude from code generation
				  'hhdlconsts'         => {},           # hash with HDL constants
                  'current_domain'     => {}            # store currently processed domain object
				 );

	# import regshell.<par> parameters from MIX package to class data; user can change these parameters in mix.cfg
	my $param;
	my @lmixparams = (
					  'reg_shell.bus_clock', 
					  'reg_shell.bus_reset', 
					  'reg_shell.addrwidth', 
					  'reg_shell.datawidth',
					  'reg_shell.multi_clock_domains', 
					  'reg_shell.infer_clock_gating', 
					  'reg_shell.infer_sva',
					  'reg_shell.read_multicycle',
					  'reg_shell.read_pipeline_lvl',
					  'reg_shell.use_reg_name_as_prefix',
					  'reg_shell.exclude_regs',
					  'reg_shell.exclude_fields',
					  'reg_shell.add_takeover_signals',
                      'reg_shell.regshell_prefix',  
                      'reg_shell.cfg_module_prefix',
                      'reg_shell.enforce_unique_addr',
                      'reg_shell.infer_reset_syncer',
                      'reg_shell.field_naming',
					  'postfix.POSTFIX_PORT_OUT', 
					  'postfix.POSTFIX_PORT_IN',
					  'postfix.POSTFIX_FIELD_OUT', 
					  'postfix.POSTFIX_FIELD_IN',
                      'output.path_include',
                      'output.mkdir',
                      'output.ext.verilog_def',
					 );
    
	foreach $param (@lmixparams) {
		if (defined $eh->get("$param")) {
            my $key;
			my ($main, $sub, $subsub) = split(/\./,$param);
            if (defined ($subsub) and $subsub ne "") {
                $key = $subsub;
            } else {
                $key = $sub;
            };
            $this->global($key => $eh->get("${param}"));
			_info("setting parameter $param = ", $this->global->{$key}) if $this->global->{'debug'};
		} else {
			_error("parameter \'$param\' unknown");
		};
	}; 

    # register Perl module with mix
    $eh->mix_add_module_info("RegViews", '$Revision: 1.64 $ ', "Utility functions to create different register space views from Reg class object");
};


# main method to generate config module for a clock domain
# input: domain object, 
# clock-name of the domain,
# reference to list where code lines are added (::udc)
sub _vgch_rs_gen_cfg_module {
	my ($this, $o_domain, $clock, $lref_udc) = @_;
	my($o_reg, $shdw_sig, $par);
	my $href = $this->global->{'hclocks'}->{$clock};
	my $cfg_i = $href->{'cfg_inst'};
	my (@ldeclarations) = ("", "/*","  local wire or register declarations","*/");
	my (@lstatic_logic) = ();
	my $reset = $href->{'reset'};
	my (%husr, %hshdw, %hassigns, %hwp, %haddr_tokens, %hrp, %hrp_trg, %hparams);
	my $nusr = 0;
	my (@lassigns) = ("", "/*","  local wire and output assignments","*/");
	my (@ldefines) = ("", "/*", "  local definitions","*/");
	my $addr_msb = $this->global->{'addr_msb'};
	my $addr_lsb = $this->global->{'addr_lsb'};
	my (@lsp) = ();
	my (@lrp) = ();
	my (@lchecks) = ();
	my (@lheader) = ();
	my ($int_rst_n) = $this->_gen_unique_signal_name("int_rst_n", $clock, "sr_inst");
	my $p_pos_pulse_check = 0;
	my $o_field;
    my @lgen_filter = ();

	if ($addr_msb >= $this->global->{'addrwidth'}) {
		_error("register offsets are out-of-bounds (max ",2**$this->global->{'addrwidth'} -1,")");
		return 0;
	};

	# generate a header for the code
	$this->_vgch_rs_gen_udc_header(\@lheader);

	# iterate through all registers of the domain and add ports/instantiations (sort by address)
	foreach $o_reg (sort {$o_domain->get_reg_address($a) <=> $o_domain->get_reg_address($b)} @{$o_domain->regs}) {
	    $o_reg->display() if $this->global->{'debug'}; # debug
		# skip register defined by user
		if (grep ($_ eq $o_reg->name, @{$this->global->{'lexclude_cfg'}})) {
			_info("skipping register ", $o_reg->name);
			next;
		};
		# skip embedded control/status register
		if ($o_reg->name eq $this->global->{'embedded_reg_name'}) {
			next;
		};
		my $reg_offset = $o_domain->get_reg_address($o_reg);	
        # print "reg : ",$o_reg->name,", offset : ",$reg_offset, " 0x",_val2hex($addr_msb+1, $reg_offset),"\n";

		# store address for later
		$this->global->{'hhdlconsts'}->{$o_reg->name . "_offs_c"} = "'h"._val2hex($this->global->{'addrwidth'}, $reg_offset);

		my $reg_name = uc("reg_"._val2hex($addr_msb+1, $reg_offset)); # generate a register name ourselves
		if (!exists($haddr_tokens{$reg_offset})) {
			if ($reg_offset % ($this->global->{'datawidth'}/8) != 0) {
				_error("register offset $reg_offset for \'",$o_reg->name,"\' is not aligned to bus data width - skipped");
				next;
			};
			$haddr_tokens{$reg_offset} = "${reg_name}_OFFS";
			# add defines for addresses
			push @ldefines, "\`define ".$haddr_tokens{$reg_offset}." ".($reg_offset >> $addr_lsb)." // ".$o_reg->name; 
			# declare register
			push @ldeclarations, "reg [".($this->global->{'datawidth'}-1).":0] $reg_name;";
		} else {
            if ($this->global->{'enforce_unique_addr'}) {
                _error("register offset $reg_offset for register \'", $o_reg->name, "\' already used");
                next;
            };
        };

        my $rclock = "";
		my $fclock = "";
		my $freset = "";
		# iterate through all fields of the register (sort by name)
		foreach $href (sort {$a->{'field'}->name cmp $b->{'field'}->name} @{$o_reg->fields}) {
			$o_field = $href->{'field'};
			$shdw_sig = "";
			# $o_field->display();
			($fclock, $freset) = $this->_get_field_clock_and_reset($clock, $reset, $fclock, $freset, $o_field);

            # check if all fields in a register have the same clock-domain
            if ($rclock eq "") {
                $rclock = $fclock;
            } else {
              if ($fclock ne $rclock and $this->global->{'multi_clock_domains'}) {
                  _error("register \'",$o_reg->name,"\' has fields in different clock domains (\'$rclock\' and \'$fclock\'); not supported anymore");
                  last;
              };  
            };

			# skip field if not in our clock domain and MCD feature is enabled
			next if ($this->global->{'multi_clock_domains'} and $fclock ne $clock); 
			# next if $o_field->name =~ m/^UPD[EF]/; # skip legacy UPD* regs

			# skip fields defined by user
			if (grep ($_ eq $o_field->name, @{$this->global->{'lexclude_cfg'}})) {
				_info("skipping field ", $o_field->name);
				next;
			};

			# get field attributes
			my $spec = $o_field->attribs->{'spec'}; # note: spec can contain several attributs
			my $access = lc($o_field->attribs->{'dir'});
			my $rrange = $this->_get_rrange($href->{'pos'}, $o_field);
			my $lsb = $o_field->attribs->{'lsb'};
			my $msb = $lsb - 1 + $o_field->attribs->{'size'};
			my $res_val = sprintf("'h%x", $o_field->attribs->{'init'});

			# store MSBs for later
			# the LSBs are not stored, they are usually 0; if not, the MSB information alone does not help
			if ($o_field->attribs->{'size'} >1) {
				$this->global->{'hhdlconsts'}->{$this->_gen_field_name("", $o_field) . "_msb_c"} = "'h"._val2hex($this->global->{'datawidth'}/4, $msb);
			};

			# track USR fields
			if ($spec =~ m/usr/i) {
				if(exists($husr{$reg_offset})) {
					_error("register \'",$o_reg->name,"\' has more than one field with USR attribute - I cannot generate more than one read/write pulse output; try to merge the fields or re-map them into several registers!"); 
				} else {
					$nusr++; # count number of USR fields
					$husr{$reg_offset} = $o_field; # store usr field in hash
				};
				if ($spec =~ m/trg/i) {
					_warning("attribute TRG ignored because cannot be mixed with attribute USR (here: field ", $o_field->name, ")");
				};
			};

			# track shadow signals
			if ($spec =~ m/sha/i) {
				$shdw_sig = $o_field->attribs->{'sync'};
				if(lc($shdw_sig) eq "nto" or $shdw_sig =~ m/[\%OPEN\%|\%EMPTY\%]/) {
					_error("field \'",$o_field->name,"\' is shadowed but has no shadow signal defined");
				} else {
					if($spec =~ m/w1c/i or $spec =~ m/usr/i) {
						_error("a shadowed field can not have W1C or usr attributes (here: field ", $o_field->name, ")");
					} else {
						push @{$hshdw{$shdw_sig}}, $o_field;
					};
				}; 
			};
			
			# warnings/errors for w1c fields 
			if ($spec =~ m/w1c/i and $o_field->attribs->{'size'} >1 ) {
                # greater than one bit
                if ($o_field->attribs->{'size'} >1) {
                    _warning("field \'",$o_field->name,"\': for fields of type write-one-to-clear, only 1-bit size is currently supported");
                };
                if ($access !~ m/w/ or $access !~ m/r/) {
                    _error("field \'",$o_field->name,"\': attribute W1C can only be combined with RW access");
                }; 
			};
				
			# add ports, declarations and assignments
			if ($access =~ m/r/i and $access !~/w/i ) { # read-only
				_add_primary_input($this->_gen_field_name("in", $o_field), $msb, $lsb, $cfg_i);
				if ($spec =~ m/sha/i) {
					push @ldeclarations, "reg [$msb:$lsb] ".$this->_gen_field_name("shdw", $o_field).";";
				};
				if ($spec =~ m/trg/i and $spec !~ m/usr/i) { # add write trigger output
					_add_primary_output($this->_gen_field_name("trg", $o_field), 0, 0, $spec =~ m/sha/i ? 0 : 1, $cfg_i);
				};
			} elsif ($access =~ m/w/i) { # write
				_add_primary_output($this->_gen_field_name("out", $o_field), $msb, $lsb, ($spec =~ m/sha/i) ? 1:0, $cfg_i);
				if ($spec =~ m/w1c/i) { # w1c
                    my $ftemp = $this->_gen_field_name("int_set", $o_field);
					_add_primary_input($ftemp, 0, 0, $cfg_i);
					$p_pos_pulse_check = 1;
					push @lchecks, "assert_${ftemp}_is_a_pulse: assert property(p_pos_pulse_check($ftemp));";
				};
				if ($spec !~ m/sha/i) {
					if ($spec =~ m/usr/i) {
						# route through, no register generated
						$hassigns{$this->_gen_field_name("out", $o_field).$this->_get_frange($o_field)} = "wr_data_i".$rrange;
					} else {
						# drive from register
						$hassigns{$this->_gen_field_name("out", $o_field).$this->_get_frange($o_field)} = $this->_gen_cond_rhs(\%hparams, $o_field, $reg_name.$rrange);
					};
				} else {
					# drive from register
					$hassigns{$this->_gen_field_name("shdw", $o_field).$this->_get_frange($o_field)} = $this->_gen_cond_rhs(\%hparams, $o_field, $reg_name.$rrange);
					push @ldeclarations,"wire [$msb:$lsb] ".$this->_gen_field_name("shdw", $o_field).";";
				};
				if($access =~ m/r/i and $spec =~ m/usr/i) { # usr read/write
					_add_primary_input($this->_gen_field_name("in", $o_field), $msb, $lsb, $cfg_i);
				};
				if ($spec =~ m/trg/i and $spec !~ m/usr/i) { # add write trigger output
					_add_primary_output($this->_gen_field_name("trg", $o_field), 0, 0, ($spec =~ m/w1c/i) ? 1:0, $cfg_i);
				};
			};
			if ($spec =~ m/usr/i) { # usr read/write
                my $ftemp = $this->_gen_field_name("usr_trans_done", $o_field);
				_add_primary_input($ftemp, 0, 0, $cfg_i);
				$p_pos_pulse_check = 1;
				push @lchecks, "assert_${ftemp}_is_a_pulse: assert property(p_pos_pulse_check($ftemp));";
				if($access =~ m/r/i) {
					_add_primary_output($this->_gen_field_name("usr_rd", $o_field), 0, 0, 1, $cfg_i);
				};
				if($access =~ m/w/i) {
					_add_primary_output($this->_gen_field_name("usr_wr", $o_field), 0, 0, 1, $cfg_i);
				};
			};

			# registers in write processes
			if ($access =~ m/w/i and $spec !~ m/usr/i) { # write, except USR  fields
				if ($spec !~ m/w1c/i) { # read/write
					$hwp{'write'}->{$reg_name.$rrange} = $reg_offset;
					$hwp{'write_rst'}->{$reg_name.$rrange} = $res_val;
					if ($spec =~ m/trg/i and $spec !~ m/sha/i) {
						# add only one trigger signal per register and assign individual trigger signals
						my $trg = "int_${reg_name}_trg_p";
						if (!exists($hwp{'write_trg'}->{$trg})) {
							$hwp{'write_trg_rst'}->{$trg} = 0;
							$hwp{'write_trg'}->{$trg} = $reg_offset;
							push @ldeclarations,"reg $trg;"
						};
						$hassigns{$this->_gen_field_name("trg", $o_field)} = $trg;
					};
				} else { # w1c
					$hwp{'write_sts'}->{$reg_name.$rrange} = $this->_gen_field_name("int_set", $o_field);
					$hwp{'write_sts_rst'}->{$reg_name.$rrange} = $res_val;
					if ($spec =~ m/trg/i and $spec !~ m/usr/i) {
						# add dedicated trigger signal per field
						$hwp{'write_sts_rst'}->{$this->_gen_field_name("trg", $o_field)} = 0;
						$hwp{'write_sts_trg'}->{$this->_gen_field_name("trg", $o_field)} = $reg_name.$rrange;
					};
				};
			};
			
			# registers for read mux
			if ($access =~ m/r/i) { # read
				if ($access =~ m/w/i) { # read/write
					if ($spec =~ m/sha/i) {
						push @{$hrp{$reg_offset}}, {$rrange => $this->_gen_field_name("shdw", $o_field)};
					} elsif ($spec =~ m/usr/i) {
						push @{$hrp{$reg_offset}}, {$rrange => $this->_gen_field_name("in", $o_field)};
					} else {
						#push @{$hrp{$reg_offset}}, {$rrange => $reg_name.$rrange};
						push @{$hrp{$reg_offset}}, {$rrange => $this->_gen_cond_rhs(\%hparams, $o_field, $reg_name.$rrange)};
};
				} else { # read-only
					if ($spec =~ m/sha/i) {
						push @{$hrp{$reg_offset}}, {$rrange => $this->_gen_field_name("shdw", $o_field)};
					} else {
						push @{$hrp{$reg_offset}}, {$rrange => $this->_gen_field_name("in", $o_field)};
						if ($spec =~ m/trg/i and $spec !~ m/usr/i) {
							push @{$hrp_trg{$reg_offset}}, $this->_gen_field_name("trg", $o_field);
						};
					};
				};
			}; 
		}; # foreach $href
	}; # foreach $o_reg 
	
	# add additional top-level parameters
	foreach $par (keys %hparams) {
		_add_generic($par, $hparams{$par}, $this->global->{'top_inst'});
		_add_generic_value($par, $hparams{$par}, $par, $cfg_i);
	};

	# add assertions for input pulses
	if ($p_pos_pulse_check) {
		unshift @lchecks, split("\n","
property p_pos_pulse_check (sig); // check for positive pulse
     @(posedge ". $this->_gen_clock_name($clock).") disable iff (~$int_rst_n)
     sig |=> ~sig;
endproperty
");
	};

	# add ports, processes and synchronizer for shadow signals
	foreach $shdw_sig (keys %hshdw) {
		# add ports and wires/regs
		_add_primary_input("${shdw_sig}_en", 0, 0, $cfg_i);
		_add_primary_input("${shdw_sig}_force", 0, 0, $cfg_i);
		push @ldeclarations, split("\n","reg int_${shdw_sig};");
		push @ldeclarations, split("\n","reg int_${shdw_sig}_en;");

		# add synchronizer module for update signal (need unique instance names because MIX has flat namespace)
		my $su_inst = $this->_add_instance_unique("sync_generic", $cfg_i, "Synchronizer for update-signal $shdw_sig");
        $this->global->{'hclocks'}->{$clock}->{'su_inst'} = $su_inst;
		_add_generic("kind", 3, $su_inst);
		_add_generic("sync", 1, $su_inst);
		_add_generic("act", 1, $su_inst);
		_add_generic("rstact", 0, $su_inst);
		_add_generic("rstval", 0, $su_inst);
		_add_primary_input($shdw_sig, 0, 0, "${su_inst}/snd_i");
		_add_primary_input($clock, 0, 0, "${su_inst}/clk_r");
		_add_primary_input($reset, 0, 0, "${su_inst}/rst_r");
        my $conn = $this->_gen_unique_signal_name("int_${shdw_sig}_p", $clock, "su_inst");
        _add_connection($conn, 0, 0, "${su_inst}/rcv_o", "");
		_tie_input_to_constant("${su_inst}/clk_s", 0, 0, 0);
		_tie_input_to_constant("${su_inst}/rst_s", 0, 0, 0);
        push @lgen_filter, $su_inst;
        
		# add synchronizer module for update enable signal
		my($sa_inst) = $this->_add_instance_unique("sync_generic", $cfg_i, "Synchronizer for update-enable signal ${shdw_sig}_en");
        $this->global->{'hclocks'}->{$clock}->{'sa_inst'} = $sa_inst;
		_add_generic("kind", 3, $sa_inst);
		_add_generic("sync", 1, $sa_inst);
		_add_generic("act", 1, $sa_inst);
		_add_generic("rstact", 0, $sa_inst);
		_add_generic("rstval", 0, $sa_inst);
		_add_primary_input("${shdw_sig}_en", 0, 0, "${sa_inst}/snd_i");
		_add_primary_input($clock, 0, 0, "${sa_inst}/clk_r");
		_add_primary_input($reset, 0, 0, "${sa_inst}/rst_r");
        $conn = $this->_gen_unique_signal_name("int_${shdw_sig}_arm_p", $clock, "sa_inst");
		_add_connection($conn, 0, 0, "${sa_inst}/rcv_o", "");
		_tie_input_to_constant("${sa_inst}/clk_s", 0, 0, 0);
		_tie_input_to_constant("${sa_inst}/rst_s", 0, 0, 0);
        push @lgen_filter, $sa_inst;

		# if requested, route the update signal to top
		if ($this->global->{'add_takeover_signals'}) { 
			#my $to_sig = mix_check_case("port", "to_${shdw_sig}_${clock}");
			my $to_sig = "to_${shdw_sig}_${clock}";
            _info("adding takeover output \'$to_sig\'");
			_add_primary_output("$to_sig", 0, 0, 0, $cfg_i);
			push @lassigns, "assign $to_sig".($this->global->{'POSTFIX_PORT_OUT'})." = int_${shdw_sig};";
		};

		# generate shadow process
		$this->_vgch_rs_code_shadow_process($clock, $shdw_sig, \%hshdw, \%hassigns, \@lsp);
	};
	_pad_column(-1, $this->global->{'indent'}, 2, \@lsp); # indent

	# add glue-logic
	$this->_vgch_rs_code_static_logic($o_domain, $clock, \%husr, \%hshdw, \@ldeclarations, \@lstatic_logic, \@lchecks);
	
	# add assignments
	push @lassigns, map {"assign $_ = ".$hassigns{$_}.";"} sort {$hassigns{$a} cmp $hassigns{$b}} keys %hassigns; 
	
	_pad_column(1, $this->global->{'indent'}, 2, \@lassigns); # indent assignments
	_pad_column(1, $this->global->{'indent'}, 2, \@ldefines); # indent defines

	# generate code for write processes
	my @lwp;
	$this->_vgch_rs_code_write_processes($clock, \%hwp, \%haddr_tokens, \@lwp);
	_pad_column(-1, $this->global->{'indent'}, 2, \@lwp); # indent

	# generate code for read mux
	$this->_vgch_rs_code_read_mux($clock, \%hrp, \%hrp_trg, \%haddr_tokens, \@lrp, \@ldeclarations);
	_pad_column(-1, $this->global->{'indent'}, 2, \@lrp); # indent

	# generate code for forwarded transactions
	my @lusr;
	$this->_vgch_rs_code_fwd_process($clock, \%husr, \%haddr_tokens, \@lusr);
	_pad_column(-1, $this->global->{'indent'}, 2, \@lusr); # indent
	
    $this->_indent_and_prune_sva(\@lchecks);

	_pad_column(0, $this->global->{'indent'}, 2, \@ldeclarations); # indent declarations

	# insert everything
	push @$lref_udc, @lheader, @ldefines, @ldeclarations, @lassigns, @lstatic_logic, @lwp, @lusr, @lsp, @lrp, @lchecks;

	# do not generate library modules
	$eh->cappend('output.filter.file', join(",",@lgen_filter));
};

# create a header for the user-defined-code sections
# input: ref to result array
sub _vgch_rs_gen_udc_header {
	my ($this, $lref_res) = @_;
	my $pkg_name = $this;
    my $ref;
	$pkg_name =~ s/=.*$//;
	push @$lref_res, ("/* ". "-" x 60, "  Generator information:", "  used package $pkg_name is version " . $this->global->{'version'});
    my $href_info = $eh->mix_get_module_info("RegViews.pm");
	my $rev = "  this package RegViews.pm is version ".$href_info->{'version'};
	# $rev =~ s/\$//g;
	# $rev =~ s/Revision\: //;
	push @$lref_res, $rev;
    push @$lref_res, "  use with RTL libraries:";
    foreach $ref (@{$this->global->{'rtl_libs'}}) {
        push @$lref_res, "  " . $ref->{'project'} . "/" . $ref->{'version'} . "/" . $ref->{'release'};
    };
	push @$lref_res, "-" x 60 . " */";
	_pad_column(-1, $this->global->{'indent'}, 2, $lref_res);
	return;
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
	my ($this, $clock, $href_rp, $href_rp_trg, $href_addr_tokens, $lref_rp, $lref_decl) = @_;
	my (@linsert, @ltemp);
	my $ind = $this->global->{'indent'};
	my $ilvl = 0;
	my ($offs, $href, $sig, $cur_addr, $rd_clk, $int_rst_n);
	my $n;
	my $rdpl_stages = $this->global->{'rdpl_stages'};
	my $rdpl_lvl =  $this->global->{'read_pipeline_lvl'};
	my ($i, $field);
	my $addr_msb = $this->global->{'addr_msb'};
	my $addr_lsb = $this->global->{'addr_lsb'};
	my (%hmux);

	$int_rst_n = $this->_gen_unique_signal_name("int_rst_n", $clock, "sr_inst");
    $rd_clk = $clock;
    $href = $this->global->{'hclocks'}->{$clock};
    if (exists $href->{'cg_read_inst'}) {
        $rd_clk = $this->_gen_unique_signal_name("rd_clk", $clock, "cg_read_inst");
    };

	if (scalar(keys %$href_rp)>0) {
		# prefix
		push @linsert, "", "/*","  read logic and mux process","*/";
		push @linsert, $ind x $ilvl . "assign rd_data_o = mux_rd_data;";
		push @linsert, $ind x $ilvl . "assign rd_err_o  = mux_rd_err | addr_overshoot;";
		my %hsens_list = ("iaddr" => "");

		if ($rdpl_stages == 0) { # insert combinatiorial read process
			# get read-sensitivity list
			foreach $offs (keys %$href_rp) {
				foreach $href (@{$href_rp->{$offs}}) {
					$sig = (values(%{$href}))[0];
					if ($sig =~ m/\(.*,(.*)\)/) { # strip function call cond_slice() so it does not appear in sens. list
						$sig = $1;
					};
					$sig =~ s/\[.+\]$//;
					$hsens_list{$sig} = $offs;
				};
			};
		
			push @ltemp, "mux_rd_err <= 0;";
			push @ltemp, "mux_rd_data <= 0;";
			_pad_column(0, $ind, $ilvl + 1, \@ltemp);
			push @linsert, $ind x $ilvl++ . "always @(".join(" or ", sort {$a cmp $b || $hsens_list{$a} <=> $hsens_list{$b}} keys %hsens_list).") begin";
			#push @linsert, $ind x $ilvl++ . "always @(*) begin";
            push @linsert, @ltemp;
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
			# add intermediate regs
			push @$lref_decl, "reg [".($this->global->{'datawidth'}-1).":0] mux_rd_data;";
			push @$lref_decl, "reg mux_rd_err;";
		} else {
			# create process for read-pipelining
			# this is kind of complicated; first, the mux structure will be generated in a hash where
			# the keys are the mux select signals prefixed by a number which is the mux select value of the previous stage; 
			# the values are keys of the next stage;
			# the leaf keys are mux select values and leaf the values are the register offsets; 
			
			#print "> rdpl_stages $rdpl_stages\n";
 			foreach $offs (sort {$a <=> $b} keys %$href_rp) {
 				$this->_rdmux_iterator(\%hmux, $rdpl_stages, $offs, -1);
 			};
 			#my $dump = Data::Dumper->new([\%hmux]);
 			#print $dump->Dump;

			# then, the code will be generated from the the mux hash.
			$this->_rdmux_builder($int_rst_n, $rd_clk, $href_rp, \%hmux, \@linsert, $lref_decl, (keys %hmux)[0], $rdpl_stages, 0);
		};

		# build combinatorial mux for trigger signals
		if (scalar (keys %{$href_rp_trg}) > 0) {
			@ltemp = ();
			# prefix
			push @linsert, "", "// generate read-notify trigger (combinatorial)";
			push @linsert, $ind x $ilvl++ . "always @(iaddr or rd_p) begin";
			push @linsert, $ind x $ilvl++ . "case (iaddr)";
			foreach $offs (sort {$a <=> $b} keys %$href_rp_trg) {
				push @linsert, $ind x $ilvl . "\`" . $href_addr_tokens->{$offs} . ": begin";
				foreach $field (@{$href_rp_trg->{$offs}}) {
					push @linsert, $ind x ($ilvl+1) ."$field <= rd_p;";
				};
				push @linsert, $ind x $ilvl . "end";
			}; 
			push @linsert, $ind x $ilvl . "default: begin";
			foreach $offs (sort {$a <=> $b} keys %$href_rp_trg) {
				foreach $field (@{$href_rp_trg->{$offs}}) {
					push @linsert, $ind x ($ilvl+1) . "$field <= 0;";
				}; 
			};
			push @linsert, $ind x $ilvl-- . "end";
			push @linsert, $ind x $ilvl-- . "endcase";
			push @linsert, $ind x $ilvl-- . "end";
		};
	} else { # no read-registers
        push @linsert, "", "/*","  no readable registers inferred","*/";
		push @linsert, $ind x $ilvl . "assign rd_data_o = 'hdeadbeef;";
		push @linsert, $ind x $ilvl . "assign rd_err_o  = 1;";
    };
	push @$lref_rp, @linsert;
};

# recursive function to map the hash representing a mux structur to Verilog case statements;
# it's badly documented.
sub _rdmux_builder {
	my ($this, $int_rst_n, $rd_clk, $href_rp, $href_mux, $lref_insert, $lref_decl, $prev_key, $prev_lvl, $prev_sel) = @_;
	my $ind = $this->global->{'indent'};
	my $ilvl = 0;
	my $rdpl_stages = $this->global->{'rdpl_stages'};
	my $case = 0;
	my (@lsens, @ltemp);
	my ($sel, $select, $lvl, $offs, $key, $href, $out_d, $out_e, $driver, $drv_postfix);

	if(ref $href_mux->{$prev_key}) {
		$lvl = $prev_lvl - 1;		
		if ($prev_key =~ m/^iaddr/) {
			$out_d = "mux_rd_data";
			$out_e = "mux_rd_err";
		} else {
			$out_d = join("_", "mux_rd_data", $prev_lvl);
			$out_e = join("_", "mux_rd_err", $prev_lvl);
			if ($prev_lvl != $rdpl_stages) {
				$out_d .= "_$prev_sel";
				$out_e .= "_$prev_sel";
			};
		};
		foreach $key (sort keys %{$href_mux->{$prev_key}}) {
			# print "> prev_key $prev_key key $key\n";
			$select = $prev_key;
			$select =~ s/^\d+_//;
			if (!$case) {         
				$ilvl=1;
				push @ltemp, "case ($select)";
				$case = 1;
			};
			if ($key =~ m/^(\d+)_(iaddr.*$)/) {
				$sel = $1;
				if ($prev_lvl != $rdpl_stages) {
					$drv_postfix = join("_", $prev_sel, $sel);
				} else {
					$drv_postfix = $sel;
				}
				$driver = join("_", "mux_rd_data", $lvl, $drv_postfix);
				push @ltemp, $ind x $ilvl++ ."$sel: begin";
				push @ltemp, $ind x $ilvl ."$out_d <= $driver;";
				push @lsens, $driver;
				$driver = join("_", "mux_rd_err", $lvl, $drv_postfix);
				push @ltemp, $ind x $ilvl-- ."$out_e  <= $driver;";
				push @ltemp, $ind x $ilvl ."end";
				push @lsens, $driver;
			} else {
				$sel = $key;
				push @ltemp, $ind x $ilvl++ ."$sel: begin";
				$offs = $href_mux->{$prev_key}->{$key};
				#print "> offs $offs\n";
				foreach $href (@{$href_rp->{$offs}}) {
					push @ltemp, $ind x $ilvl ."$out_d".(keys %{$href})[0]." <= ".(values %{$href})[0].";";
					# BAUSTELLE: here, the field size or usedbits mask can be extracted and added up
					# store in $href, because it is no longer used
				};
				$ilvl--;
				push @ltemp, $ind x $ilvl . "end";
			};
		 }
		 if ($case) {
			 $ilvl = 0;
			 if ($prev_key =~ m/^iaddr/) {
				 # generate the head of the combinatorial process (the final mux stage)
				 push @$lref_insert, "", "always @(".join(" or ", "iaddr", @lsens).") begin // stage $prev_lvl";
				 $ilvl++;
			 } else {
				 # generate the head of the pipelined mux process
				 push @$lref_insert, "", "always @(posedge ". $this->_gen_clock_name($rd_clk)." or negedge $int_rst_n) begin // stage $prev_lvl";
				 $ilvl++;
				 push @$lref_insert, $ind x $ilvl++ ."if (~$int_rst_n) begin";
				 push @$lref_insert, $ind x $ilvl ."$out_d <= 0;";
				 push @$lref_insert, $ind x $ilvl-- ."$out_e <= 0;";
				 push @$lref_insert, $ind x $ilvl ."end";
				 push @$lref_insert, $ind x $ilvl++ ."else begin";
				 push @$lref_insert, $ind x $ilvl ."$out_e <= 0;";
				 push @$lref_insert, $ind x $ilvl ."$out_d <= 0;";
			 };
			 push @$lref_insert, map {$ind x $ilvl . $_} @ltemp;
			 $ilvl++;
			 # generate the default clause for the case statement
			 push @$lref_insert, $ind x $ilvl++ ."default: begin";
			 push @$lref_insert, $ind x $ilvl ."$out_d <= 0;";
			 push @$lref_insert, $ind x $ilvl-- ."$out_e <= 1;";
			 push @$lref_insert, $ind x $ilvl-- ."end";
			 push @$lref_insert, $ind x $ilvl-- ."endcase";
			 push @$lref_insert, $ind x $ilvl ."end" unless $prev_key =~ m/^iaddr/;
			 push @$lref_insert, "end";
			 # add reg to declarations
			 push @$lref_decl, "reg [".($this->global->{'datawidth'}-1).":0] $out_d;";
			 push @$lref_decl, "reg $out_e;";
		 }
		 foreach $key (sort keys %{$href_mux->{$prev_key}}) {
			if ($key =~ m/^(\d+)_(iaddr.*$)/) {
				$sel = $1;
			} else {
				$sel = $key;
			};
			if ($prev_lvl != $rdpl_stages) {
				$drv_postfix = join("_", $prev_sel, $sel);
			} else {
				$drv_postfix = $sel;
			}
			# call me recursively
			$this->_rdmux_builder($int_rst_n, $rd_clk, $href_rp, $href_mux->{$prev_key}, $lref_insert, $lref_decl, $key, $lvl, $drv_postfix);
		};
	};
};

# recursive function to build a mux structure from %$href_mux as hash tree
# also badly documented
sub _rdmux_iterator {
	my ($this, $href_mux, $rdpl_stages, $offs, $sel) = @_;
	my $addr_msb = $this->global->{'addr_msb'};
	my $addr_lsb = $this->global->{'addr_lsb'};
	my $rdpl_lvl = $this->global->{'read_pipeline_lvl'};
	my ($range_high, $range_low, $mask, $key, $new_sel);

	if ($rdpl_stages>=0) {
		$range_low =  $addr_lsb + $rdpl_lvl * $rdpl_stages;
		$range_high = ($range_low + $rdpl_lvl - 1 > $addr_msb) ? $addr_msb : $range_low + $rdpl_lvl - 1;
		if ($sel>=0) {
			$key = "${sel}_iaddr".$this->_gen_vector_range($range_high-$addr_lsb, $range_low-$addr_lsb);
		} else {
			# root mux
			$key = "iaddr".$this->_gen_vector_range($range_high-$addr_lsb, $range_low-$addr_lsb);
		};
		if (!exists($href_mux->{$key})) {
			$href_mux->{$key} = {};
		};
		# print "> key $key\n";		
		$mask = (1<<($range_high-$range_low+1))-1;
		$new_sel = ($offs>>$range_low) & $mask;

		$this->_rdmux_iterator($href_mux->{$key}, $rdpl_stages-1, $offs, $new_sel);
	   
	} else {
		# print $offs,"\n";
		$href_mux->{$sel} = "$offs";
	};
};

# create code for a shadow process for update signal $sig
# a field can have either write-shadow registers or read-shadow registers; read-shadowing is only implemented
# for read-only fields;
# if clock-gating is enabled, all shadow regs share the same gated clock;
# input: clock-name,
# hash with shadow signals and fields-array (shadow-signal => (list of fields))
# ref. to list where code is added
sub _vgch_rs_code_shadow_process {
	my ($this, $clock, $sig, $href_shdw, $href_assigns, $lref_sp) = @_;
	my @linsert;
	my $ind = $this->global->{'indent'};
	my $ilvl = 0;
	my $o_field;
	my ($shadow_clock) = $clock;
	my @ltemp;

	my $int_rst_n = $this->_gen_unique_signal_name("int_rst_n", $clock, "sr_inst");
    my $shdw_clk = $this->_gen_unique_signal_name("shdw_clk", $clock, "cg_shdw_inst");
    my $shdw_upd = $this->_gen_unique_signal_name("int_${sig}_p", $clock, "su_inst");
    my $shdw_arm = $this->_gen_unique_signal_name("int_${sig}_arm_p", $clock, "sa_inst");

	if (scalar(@{$href_shdw->{$sig}})>0) {
		if ($this->global->{'infer_clock_gating'}) {
			$shadow_clock = $shdw_clk;
		};
		# prefix
		push @linsert, "", "/*","  shadowing for update signal \'$sig\'","*/";
		# shadow signal
		push @linsert, $ind x $ilvl . "// generate internal update signal";
		push @linsert, $ind x $ilvl++ . "always @(posedge ". $this->_gen_clock_name($clock) ." or negedge $int_rst_n) begin";
		push @linsert, $ind x $ilvl . "if (~$int_rst_n) begin";
		push @linsert, $ind x ($ilvl+1) . "int_${sig} <= 1;";
		push @linsert, $ind x ($ilvl+1) . "int_${sig}_en <= 0;";
		push @linsert, $ind x $ilvl . "end";
		push @linsert, $ind x $ilvl . "else begin";
		if ($this->global->{'infer_clock_gating'}) {
			push @linsert, $ind x ($ilvl+1) . "int_${sig} <= // synopsys translate_off";
			push @linsert, $ind x ($ilvl+2) . "#0.1"; # note: the 0.1ns notation is SystemVerilog only
			push @linsert, $ind x ($ilvl+2) . "// synopsys translate_on";
			push @linsert, $ind x ($ilvl+2) . "($shdw_upd & int_${sig}_en) | ${sig}_force".$this->global->{'POSTFIX_PORT_IN'}.";";
		} else {
			push @linsert, $ind x ($ilvl+1) . "int_${sig} <= ($shdw_upd & int_${sig}_en) | ${sig}_force".$this->global->{'POSTFIX_PORT_IN'}.";";
		};
		push @linsert, $ind x ($ilvl+1) . "if ($shdw_arm)";
		push @linsert, $ind x ($ilvl+2) . "int_${sig}_en <= 1; // arm enable signal";
		push @linsert, $ind x ($ilvl+1) . "else if($shdw_upd)";
		push @linsert, $ind x ($ilvl+2) . "int_${sig}_en <= 0; // reset enable signal after update-event";
		push @linsert, $ind x $ilvl . "end";
		$ilvl--;
		push @linsert, $ind x $ilvl . "end";
		# assignment block
		push @linsert, $ind x $ilvl . "// shadow process";
		push @linsert, $ind x $ilvl++ . "always @(posedge ". $this->_gen_clock_name($shadow_clock) . " or negedge $int_rst_n) begin";
		push @linsert, $ind x $ilvl . "if (~$int_rst_n) begin";
		foreach $o_field (sort @{$href_shdw->{$sig}}) {
			my $res_val = 0;
			if (exists($o_field->attribs->{'init'})) {
				$res_val = sprintf("'h%x", $o_field->attribs->{'init'});
			};
			if ($o_field->attribs->{'dir'} =~ m/w/i) {
				push @ltemp, $this->_gen_field_name("out", $o_field) ." <= ${res_val};";
			} else {
				if ($o_field->attribs->{'dir'} =~ m/r/i) {
					push @ltemp, $this->_gen_field_name("shdw", $o_field) ." <= ${res_val};"; 
				};
			};
		}; 
		_pad_column(0, $this->global->{'indent'}, $ilvl+1, \@ltemp);
		push @linsert, @ltemp;
		@ltemp = ();
		push @linsert, $ind x $ilvl . "end";
		push @linsert, $ind x $ilvl++ . "else begin";
		foreach $o_field (sort @{$href_shdw->{$sig}}) {
			if ($o_field->attribs->{'dir'} =~ m/w/i) {
				push @ltemp, $this->_gen_field_name("out", $o_field) ." <= ".$this->_gen_field_name("shdw", $o_field).";";
			} else {
				if ($o_field->attribs->{'dir'} =~ m/r/i) {
					push @ltemp, $this->_gen_field_name("shdw", $o_field) ." <= " . $this->_gen_field_name("in", $o_field) . ";"; 
				};
			};
			# add assignment for trigger signal
			if ($o_field->attribs->{'spec'} =~ m/trg/i) { # add trigger signal
				$href_assigns->{$this->_gen_field_name("trg", $o_field)} = "int_${sig}";
			};
		}; 
		_pad_column(0, $this->global->{'indent'}, $ilvl+1, \@ltemp);
	   
		push @linsert, $ind x $ilvl . "if (int_${sig}) begin";
		push @linsert, @ltemp;
		push @linsert, $ind x $ilvl-- . "end";
		push @linsert, $ind x $ilvl-- . "end";
		push @linsert, $ind x $ilvl . "end";
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
	my (@ltemp, @ltemp2, $sig);
	my ($sig_read) =  "rd_wr".$this->global->{'POSTFIX_PORT_IN'}; 
	my ($sig_write) = "~rd_wr".$this->global->{'POSTFIX_PORT_IN'};
	my ($rw, $dcd, $i);

    my $int_rst_n = $this->_gen_unique_signal_name("int_rst_n", $clock, "sr_inst");
    my $trans_start_p = $this->_gen_unique_signal_name("trans_start_p", $clock, "sg_inst");

	if (scalar(keys %{$href_usr})>0) {
		# prefix
		push @linsert, "", "/*","  txn forwarding process","*/";

		# reset logic
		push @ltemp, "fwd_txn <= 0;";
		for ($i=0; $i<scalar(@lmap); $i++) {
			$rw="";
			my $o_field = $href_usr->{$lmap[$i]};
			if ($o_field->attribs->{'dir'} =~ m/r/i) {
				push @ltemp, $this->_gen_field_name("usr_rd", $o_field) . " <= 0;";
				$dcd = "(iaddr == `".$href_addr_tokens->{$lmap[$i]}.")";
				$rw = " & ${sig_read}";
				
			};
			if ($o_field->attribs->{'dir'} =~ m/w/i) {
				push @ltemp, $this->_gen_field_name("usr_wr", $o_field) . " <= 0;"; 
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
		push @linsert, $ind x $ilvl++ . "always @(posedge ". $this->_gen_clock_name($clock)." or negedge $int_rst_n) begin";
		push @linsert, $ind x $ilvl++ . "if (~$int_rst_n) begin";
		_pad_column(0, $this->global->{'indent'}, $ilvl, \@ltemp);
		push @linsert, @ltemp;
		@ltemp=();
		$ilvl--;
		push @linsert, $ind x $ilvl . "end";
		push @linsert, $ind x $ilvl++ . "else begin";

		# default values
		for ($i=0; $i<$nusr; $i++) {
			my $o_field = $href_usr->{$lmap[$i]};
			if ($o_field->attribs->{'dir'} =~ m/r/i) {
				push @ltemp, $this->_gen_field_name("usr_rd", $o_field) . " <= 0;"; 
			};
			if ($o_field->attribs->{'dir'} =~ m/w/i) {
				push @ltemp, $this->_gen_field_name("usr_wr", $o_field) . " <= 0;"; 
			};
		};
		_pad_column(0, $this->global->{'indent'}, $ilvl, \@ltemp);
		push @linsert, @ltemp;
		@ltemp=();

		# read/write pulse generation
		push @linsert, $ind x $ilvl++ . "if ($trans_start_p) begin";
		push @ltemp, "fwd_txn <= |fwd_decode_vec; // set flag for forwarded txn";
		for ($i=0; $i<scalar(@lmap); $i++) {
			my $o_field = $href_usr->{$lmap[$i]};
			if ($o_field->attribs->{'dir'} =~ m/r/i) {
				$sig = $this->_gen_field_name("usr_rd", $o_field);
				push @ltemp, $sig . " <= fwd_decode_vec[".($nusr-$i-1)."] & ${sig_read};"; 
			};
			if ($o_field->attribs->{'dir'} =~ m/w/i) {
				$sig = $this->_gen_field_name("usr_wr", $o_field);
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
#        write_trg => (field => reg_offset),
#        write_sts => (LHS => RHS),
#        write_sts_rst => (LHS => RHS),
#        write_sts_trg => (field => reg_name))
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
	my ($key, $key2);
	my $offs;

    my $int_rst_n = $this->_gen_unique_signal_name("int_rst_n", $clock, "sr_inst");
    my $trans_start_p = $this->_gen_unique_signal_name("trans_start_p", $clock, "sg_inst");
    my $wr_clk = $this->_gen_unique_signal_name("wr_clk", $clock, "cg_write_inst");

	#
	#  write block for normal registers
	#
	
	if (scalar(keys %{$href_wp->{'write'}})>0) {
		if ($this->global->{'infer_clock_gating'}) {
			$write_clock = $wr_clk; # use gated clock
		};
		# prefix
		push @linsert, "", "/*","  write process","*/";
		push @linsert, $ind x $ilvl++ . "always @(posedge ". $this->_gen_clock_name($write_clock)." or negedge $int_rst_n) begin";

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
		#if ($this->global->{'infer_clock_gating'}) {
		#	push @linsert, $ind x $ilvl++ . "if (wr_p || (cgtransp == 0))";
		#} else {
        push @linsert, $ind x $ilvl++ . "if (wr_p)";
		#};
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
			push @linsert, sort @ltemp;
			push @linsert, $ind x $ilvl . "end";
			push @linsert, $ind x $ilvl . "default: ;";
			@ltemp=();
		};
		$ilvl--;
		push @linsert, $ind x $ilvl-- . "endcase";
		$ilvl--;
		push @linsert, $ind x $ilvl-- . "end";
		push @linsert, $ind x $ilvl . "end";
		@$lref_wp = @linsert;
	};

	#
	#  write block for write trigger pulses
	#
	@linsert = ();
	if (scalar(keys %{$href_wp->{'write_trg'}})>0) {
        $write_clock = $clock; # use gated clock
        
        # prefix
		push @linsert, "", "/*","  write trigger process","*/";
		push @linsert, $ind x $ilvl++ . "always @(posedge ". $this->_gen_clock_name($clock)." or negedge $int_rst_n) begin";

		# reset logic
		push @linsert, $ind x $ilvl++ . "if (~$int_rst_n) begin";
		@ltemp=();
		foreach $key (sort keys %{$href_wp->{'write_trg_rst'}}) {
			push @ltemp, "$key <= $href_wp->{'write_trg_rst'}->{$key};";
		};	
		_pad_column(0, $ind, $ilvl, \@ltemp);
		push @linsert, @ltemp;
		$ilvl--;
		
		# write logic
		push @linsert, $ind x $ilvl ."end", $ind x $ilvl++ . "else begin";
		foreach $key (sort {$href_wp->{'write_trg'}->{$a} <=> $href_wp->{'write_trg'}->{$b}} keys %{$href_wp->{'write_trg'}}) {
			push @linsert, $ind x $ilvl . $key . " <= 0;";
		};
   
		push @linsert, $ind x $ilvl++ . "case (iaddr)";
		@ltemp=();
		foreach $key (sort {$href_wp->{'write_trg'}->{$a} <=> $href_wp->{'write_trg'}->{$b}} keys %{$href_wp->{'write_trg'}}) {
			$reg_name = $key;
			$offs = $href_wp->{'write_trg'}->{$key};
			$rrange = "";
			if ($reg_name =~ m/(\[.+\])$/) {
				$reg_name = $`;
				$rrange = $1;
			};
			$reg_addr = $href_addr_tokens->{$offs}; # use tokenized address instead of number
            push @linsert, $ind x $ilvl . "\`$reg_addr: $key <= wr_p;";
        };
        push @linsert, $ind x $ilvl . "default: ;";
		$ilvl--;
		push @linsert, $ind x $ilvl-- . "endcase";
		push @linsert, $ind x $ilvl-- . "end";
		push @linsert, $ind x $ilvl . "end";
		push @$lref_wp, @linsert;    
    };

	#
	#  write block for status registers
	#
	@linsert = ();
	if (scalar(keys %{$href_wp->{'write_sts'}})>0) {
		# prefix
		push @linsert, "", "/*","  write process for status registers","*/";
		push @linsert, $ind x $ilvl . "always @(posedge ". $this->_gen_clock_name($write_sts_clock)." or negedge $int_rst_n) begin";
		
		# reset logic
		push @linsert, $ind x ($ilvl+1) . "if (~$int_rst_n) begin";
		$ilvl = $ilvl+2;
		@ltemp=();
		foreach $key (sort keys %{$href_wp->{'write_sts_rst'}}) {
			push @ltemp, "$key <= " . $href_wp->{'write_sts_rst'}->{$key} . ";";
		};
		
		_pad_column(0, $ind, $ilvl, \@ltemp);
		push @linsert, @ltemp;
		$ilvl--;
		push @linsert, $ind x $ilvl . "end", $ind x $ilvl++ . "else begin";
		
		# reset trigger signals
		@ltemp=();
		foreach $key2 (keys %{$href_wp->{'write_sts_trg'}}) {
			push @ltemp, "$key2 <= 0;";
		};
		_pad_column(0, $ind, $ilvl, \@ltemp);
		push @linsert, @ltemp;
		
		# write logic
		foreach $key (sort {$href_wp->{'write_sts'}->{$a} cmp $href_wp->{'write_sts'}->{$b}} keys %{$href_wp->{'write_sts'}}) {
			$reg_name = $key;
			$rrange = "";
			if ($reg_name =~ m/(\[.+\])$/) {
				$reg_name = $`;
				$rrange = $1;
			};
			$offs = uc($reg_name . "_offs");
			push @linsert, $ind x $ilvl++ ."if ($href_wp->{'write_sts'}->{$key})";
			push @linsert, $ind x $ilvl-- ."$key <= 1;";
			push @linsert, $ind x $ilvl++ ."else if (wr_p && iaddr == \`".$offs.") begin";
			push @linsert, $ind x $ilvl ."$key <= $key & ~wr_data".$this->global->{POSTFIX_PORT_IN}."$rrange;";
			foreach $key2 (keys %{$href_wp->{'write_sts_trg'}}) {
				if ($href_wp->{'write_sts_trg'}->{$key2} eq $key) {
					push @linsert, $ind x $ilvl . "$key2 <= 1;"; 
				};
			};
			$ilvl--;
			push @linsert, $ind x $ilvl ."end";
		};
		$ilvl --;
		push @linsert, $ind x $ilvl-- ."end";
		push @linsert, $ind x $ilvl-- ."end";
		push @$lref_wp, @linsert;
	};
};

# add standard logic constructs; adds to two lists: declarations and udc.
# performs text indentation/alignment only on udc lists.
sub _vgch_rs_code_static_logic {
	my ($this, $o_domain, $clock, $href_usr, $href_shdw, $lref_decl, $lref_udc, $lref_checks) = @_;
	my $addr_msb = $this->global->{'addr_msb'};
	my $addr_lsb = $this->global->{'addr_lsb'};
	my ($o_field, $href, $shdw_sig, $nusr, $sig, $dummy, $fwd_rd_done, $fwd_wr_done);
	my (@ltemp, @ltemp2);
	my $multicyc;
	my $ind = $this->global->{'indent'};
	$href = $this->global->{'hclocks'}->{$clock};

    my $int_rst_n = $this->_gen_unique_signal_name("int_rst_n", $clock, "sr_inst");
    my $trans_start_p = $this->_gen_unique_signal_name("trans_start_p", $clock, "sg_inst");
    my $wr_clk = $this->_gen_unique_signal_name("wr_clk", $clock, "cg_write_inst");
    my $wr_clk_en = $this->_gen_unique_signal_name("wr_clk_en", $clock, "cg_write_inst");
    my $shdw_clk = $this->_gen_unique_signal_name("shdw_clk", $clock, "cg_shdw_inst");
    my $shdw_clk_en = $this->_gen_unique_signal_name("shdw_clk_en", $clock, "cg_shdw_inst");
    my $rd_clk = $this->_gen_unique_signal_name("rd_clk", $clock, "cg_read_inst");
    my $rd_clk_en = $this->_gen_unique_signal_name("rd_clk_en", $clock, "cg_read_inst");
	my $sig_read =  "rd_wr".$this->global->{'POSTFIX_PORT_IN'}; 
	my $sig_write = "~rd_wr".$this->global->{'POSTFIX_PORT_IN'};

	# calc new read-multicycle value in case of pipelining
	if ($this->global->{'rdpl_stages'}==0) {
		$multicyc = $this->global->{'read_multicycle'};
	} else {
		$multicyc = $this->global->{'rdpl_stages'};
	};

    # number of USR fields
	$nusr=scalar(keys %$href_usr);

    # get read and write USR fields
    my @lusr_rd = grep {$href_usr->{$_}->attribs->{'dir'} =~ m/r/i} keys %$href_usr;
    my @lusr_wr = grep {$href_usr->{$_}->attribs->{'dir'} =~ m/w/i} keys %$href_usr;
    #print join(",", keys %$href_usr),"\n";
    #print scalar(@lusr_rd), ":",join(",",@lusr_rd),"\n";
    #print scalar(@lusr_wr), ":",join(",",@lusr_wr),"\n";

	if ($multicyc>0) {
		# the read-ack will be delayed by one cycle anyway, so subtract
		# it from the multicycle value which is a measure for delaying it
		$multicyc--;	
	};

	#
	# insert wire/reg declarations
	#
	push @$lref_decl, split("\n","
wire wr_p;
wire wr_done_p;
wire rd_p;
wire rd_done_p;
reg  int_trans_done;
wire [".($addr_msb-$addr_lsb).":0] iaddr;
wire addr_overshoot;
wire trans_done_p;
reg  ts_del_p;
");
	if ($nusr>0) { # if there are USR fields
		push @$lref_decl, split("\n","
reg  fwd_txn;
wire [".($nusr-1).":0] fwd_decode_vec;
wire fwd_rd_done_p;
wire fwd_wr_done_p;
");
	};
    if ($multicyc > 0) {
        push @$lref_decl, "reg [".($multicyc-1).":0] rd_del;"; # define registers for delaying rd_done_p
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
		push @ltemp, "", "/*", "  clock enable signals", "*/";
		if (exists $href->{'cg_write_inst'}) {
			push @ltemp, "assign $wr_clk_en = wr_p; // write-clock enable"; # | ~$int_rst_n ;";
		};
		if (exists $href->{'cg_shdw_inst'}) {
			push @ltemp, "assign $shdw_clk_en = " . join(" | ",map {"int_".$_} keys %$href_shdw) . "; // shadow-clock enable";
		};
		if (exists $href->{'cg_read_inst'}) {
			for (my $i=0; $i<= $multicyc; $i++) {
				push @ltemp2, ($i == 0) ? "rd_p" : "rd_del[".($i-1)."]";
			};
			push @ltemp, "assign $rd_clk_en = " . join(" | ", @ltemp2) . "; // read-clock enable";
        };
    };

	push @ltemp, split("\n","
/* 
  generate transaction-handling signals
*/

assign trans_done_p = rd_done_p | wr_done_p;

// write txn start pulse
assign 
// synopsys translate_off
#0.1
// synopsys translate_on 
wr_p = $sig_write & $trans_start_p;

// read done pulse
");
    push @ltemp, "assign rd_done_p = ".($multicyc ? "rd_del[".($multicyc-1)."];" : "rd_p;");

    if ($nusr==0) {
        # has no USR registers
        push @ltemp, split("\n","
assign rd_p      = $sig_read & ts_del_p; // read txn start pulse
assign wr_done_p = $sig_write & ts_del_p; // write done pulse
");
        
	} else {
        # has USR registers
        $fwd_rd_done = scalar(@lusr_rd) > 0 ? join(" | ",  map {$this->_gen_field_name("usr_trans_done",$href_usr->{$_})} @lusr_rd) : "0";
        $fwd_wr_done = scalar(@lusr_wr) > 0 ? join(" | ",  map {$this->_gen_field_name("usr_trans_done",$href_usr->{$_})} @lusr_wr) : "0";  
        push @ltemp, split("\n","
assign fwd_rd_done_p = ${fwd_rd_done};
assign fwd_wr_done_p = ${fwd_wr_done};
assign rd_p          = $sig_read & ((ts_del_p & ~fwd_txn) | (fwd_rd_done_p & fwd_txn)); // read txn start pulse
assign wr_done_p     = $sig_write & ((ts_del_p & ~fwd_txn) | (fwd_wr_done_p & fwd_txn)); // write done pulse
");
		$dummy = join(", ", map {$this->_gen_field_name("usr_trans_done",$href_usr->{$_})} keys %$href_usr);

		push @$lref_checks, split("\n","
// all acks for forwarded txns
wire [".($nusr-1).":0] fwd_done_vec;
assign fwd_done_vec = {${dummy}};

assert_fwd_done_onehot: assert property
(
   @(posedge ". $this->_gen_clock_name($clock).") disable iff (~$int_rst_n)
   fwd_done_vec != 0 |-> onehot(fwd_done_vec)
);

assert_fwd_done_only_when_fwd_txn: assert property
(
   @(posedge ". $this->_gen_clock_name($clock).") disable iff (~$int_rst_n)
   fwd_done_vec != 0 |-> fwd_txn
);

function onehot (input [".($nusr-1).":0] vec);
  integer i,j;
  begin
     j = 0;
	 for (i=0; i<$nusr; i=i+1) j = j + vec[i] ? 1 : 0;
	 onehot = (j==1) ? 1 : 0;
  end
endfunction
  
  ");
    };

	push @ltemp, ("",
				 "always @(posedge ". $this->_gen_clock_name($clock)." or negedge $int_rst_n) begin",
				 $ind."if (~$int_rst_n) begin", 
				 $ind x 2 ."int_trans_done <= 0;",
				 $ind x 2 ."ts_del_p       <= 0;"
				);
    if ($multicyc>0) {
       push @ltemp, $ind x 2 ."rd_del         <= 0;"
    };
	push @ltemp, (
				  $ind."end",
				  $ind."else begin",
                  $ind x 2 . "ts_del_p <= $trans_start_p;"
				 );
	for (my $i=0; $i< $multicyc; $i++) {
		push @ltemp, ($i == 0) ? ($ind x 2 ."rd_del[$i] \<= rd_p;") : ($ind x 2 ."rd_del[$i] \<= rd_del[".($i-1)."];");
	};

    push @ltemp, (
				  $ind x 2 ."if (trans_done_p)",
				  $ind x 3 ."int_trans_done <= ~int_trans_done;",
				  $ind."end",
				  "end",
				  "assign trans_done_o = int_trans_done;"
				 );
	 
    # function for conditional instantiation of Flip-Flops
	if (exists($href->{'has_cond_fields'})) {
        my $fullrange = $this->_gen_vector_range($this->global->{'datawidth'}-1,0);
		push @ltemp, (
		              "", "/*", "  helper function for conditional FFs", "*/",
                      "// msd parse off",
                      "function $fullrange cond_slice(input integer enable, input $fullrange vec);",
                      $ind . "begin",
                      $ind x 2 . "cond_slice = (enable < 0) ? vec : enable;",
                      $ind . "end",
                      "endfunction",
                      "// msd parse on"
                     ); 
        _info("clock domain \'$clock\' has conditionally instantiated FFs");
	};

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
	my($clock, $bus_clock, $cfg_inst, $sg_inst, $sr_inst, $ocp_sync, $cgw_inst, $cgs_inst, $cgr_inst, $n, $sync_clock);
	my $refclks = $this->global->{'hclocks'};
	my $infer_cg = $this->global->{'infer_clock_gating'};
	my @lgen_filter = ();
	my ($mcda_inst, $predec_inst);
    my @lchecks = ();

	# instantiate top-level module
	my $rs_name = $this->global->{'regshell_prefix'}."_".$o_domain->name;
	my $top_inst = $this->_add_instance($rs_name, "testbench", "Register shell for domain ".$o_domain->name);
	$this->global('top_inst' => $top_inst);
 
    if ($infer_cg) {
		_add_generic("cgtransp", 0, $top_inst);
	};
	# _add_generic("P_TOCNT_WIDTH", 10, $top_inst); # timeout counter width
	
	# instantiate OCP target
	my $ocp_inst = $this->_add_instance_unique($this->global->{"ocp_target_name"}, $top_inst, "OCP target module");
	$this->global('ocp_inst' => $ocp_inst);
	$eh->cappend('output.filter.file', $ocp_inst);
	
	_add_generic("P_DWIDTH", $this->global->{'datawidth'}, $ocp_inst);
	_add_generic("P_AWIDTH", $this->global->{'addrwidth'}, $ocp_inst);
    _add_generic("P_MIX_SIG", $this->global->{'mix_signature'}, $ocp_inst);

	# _add_generic_value("P_TOCNT_WIDTH", 10, "P_TOCNT_WIDTH", $ocp_inst); # timeout counter width
	if(exists($this->global->{'embedded_reg'})) {
		# enable embedded control/status register in ocp_target; 
		# the default for has_ecs is 0, so we don't need this param in case there is no reg
		_add_generic("has_ecs", 1, $ocp_inst);
		my $ecs_addr = $o_domain->get_reg_address($this->global->{'embedded_reg'});
		_add_generic("P_ECSADDR", $ecs_addr, $ocp_inst);
		_add_generic("def_val_p", $this->global->{'ecs_def_val'}, $ocp_inst);
		_add_generic("def_rerr_en_p", $this->global->{'ecs_def_rerr_en'}, $ocp_inst);
		_add_generic("def_ien_p", $this->global->{'ecs_def_ien'}, $ocp_inst);
        _add_generic("ecs_writable_p", $this->global->{'ecs_writable'}, $ocp_inst); # NEW
	};

	$ocp_sync = 0;

    # instantitate OCP master checker if configured
    my $ocp_checker_inst;
    if ($this->global->{'infer_sva'}) {
        my $udc="/%PINS%/\`ifdef ASSERT_ON
// synopsys translate_off
/%AINS%/ // synopsys translate_on
\`endif";
        $ocp_checker_inst = $this->_add_instance_unique($this->global->{"ocp_checker_name"}, $top_inst, "OCP master checker module", $udc);
        $this->global('ocp_checker_inst' => $ocp_checker_inst);
        _add_generic("P_DWIDTH", $this->global->{'datawidth'}, $ocp_checker_inst);
        _add_generic("P_AWIDTH", $this->global->{'addrwidth'}, $ocp_checker_inst);
        _add_generic("P_WRITERESP_ENABLE", 0, $ocp_checker_inst);
        $eh->cappend('output.filter.file', $ocp_checker_inst);
    };

	# instantiate MCD adapter (if required)
	if ($nclocks > 1 and $this->global->{'multi_clock_domains'}) {
		$mcda_inst = $this->_add_instance_unique($this->global->{"mcda_name"}, $top_inst, "Multi-clock-domain Adapter");
        $this->global('mcda_inst' => $mcda_inst);
		_add_generic("N_DOMAINS", $nclocks, $mcda_inst);
		_add_generic("P_DWIDTH", $this->global->{'datawidth'}, $mcda_inst);
        _add_generic("P_PRDWIDTH", _bitwidth($nclocks), $mcda_inst);
        _add_generic("P_MIX_SIG", $this->global->{'mix_signature'}, $mcda_inst);

		push @lgen_filter, $mcda_inst;

        # instantiate pre-decoder
        $predec_inst = $this->_add_instance(join("_", $rs_name, "pre_dec"), $top_inst, "Multi-clock-domain Pre-decoder");
        $this->global('predec_inst' => $predec_inst);
		_add_generic("N_DOMAINS", $nclocks, $predec_inst);
	};
	
	# instantiate config register module(s) and sub-modules
	$sync_clock = 31415; # number of synchronous clock, default to invalid
	$n=0;
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
		$sg_inst = $this->_add_instance_unique("sync_generic", $cfg_inst, "Synchronizer for trans_start signal");
		$refclks->{$clock}->{'sg_inst'} = $sg_inst; # store in global->hclocks
		_add_generic("kind", 2, $sg_inst);
		# _add_generic("sync", $refclks->{$clock}->{'sync'}, $sg_inst);
		_add_generic_value("sync", 0, "sync", $sg_inst);
		_add_generic("act", 1, $sg_inst);
		_add_generic("rstact", 0, $sg_inst);
		_add_generic("rstval", 0, $sg_inst);
        $sr_inst = $this->_add_instance_unique("sync_rst", $cfg_inst, "Reset synchronizer");
        $refclks->{$clock}->{'sr_inst'} = $sr_inst; # store in global->hclocks
        #_add_generic("sync", $refclks->{$clock}->{'sync'}, $sr_inst);
        if ($this->global->{'infer_reset_syncer'}) {                
            _add_generic_value("sync", 0, "sync", $sr_inst);
        } else {
            _add_generic("sync", 0, $sr_inst); # set  reset synchronizer to bypass mode
        };
        _add_generic("act", 0, $sr_inst);
        push @lgen_filter, ($sr_inst, $sg_inst);

		# instantiate clock gating cells
		if ($infer_cg) {
			_add_generic_value("cgtransp", 0, "cgtransp", $cfg_inst);
			if (exists $refclks->{$clock}->{'has_write'}) {
				$cgw_inst = $this->_add_instance_unique("ccgc", $cfg_inst, "Clock-gating cell for write-clock");
				_add_generic_value("cgtransp", 0, "cgtransp", $cgw_inst);
				$refclks->{$clock}->{'cg_write_inst'} = $cgw_inst;
				push @lgen_filter, $cgw_inst;
			};
			if (exists $refclks->{$clock}->{'has_shdw'}) {
				$cgs_inst = $this->_add_instance_unique("ccgc", $cfg_inst, "Clock-gating cell for shadow-clock");
				_add_generic_value("cgtransp", 0, "cgtransp", $cgs_inst);
				$refclks->{$clock}->{'cg_shdw_inst'} = $cgs_inst;
				push @lgen_filter, $cgs_inst;
			};
			if ($this->global->{'rdpl_stages'}>0 and exists $refclks->{$clock}->{'has_write'}) {
				$cgr_inst = $this->_add_instance_unique("ccgc", $cfg_inst, "Clock-gating cell for read-clock");
				_add_generic_value("cgtransp", 0, "cgtransp", $cgr_inst);
				$refclks->{$clock}->{'cg_read_inst'} = $cgr_inst;
				push @lgen_filter, $cgr_inst;
			};
		};
		$n++;
	};
	# set N_SYNCDOM parameter for mcda if that did not happen yet
	if(exists($this->global->{'mcda_inst'}) && $sync_clock == 31415) {
		_add_generic("N_SYNCDOM", $sync_clock, $mcda_inst);
	};
	_add_generic("sync", $ocp_sync, $ocp_inst);

    # add logic to pre_dec module (it is only a big address decoder which is hopefully reduced by synthesis tool) 
    if(exists($this->global->{'mcda_inst'})) {
        $this->_vgch_rs_gen_pre_dec_logic($o_domain, $predec_inst);
    };

	# do not generate library modules
	$eh->cappend('output.filter.file', join(",",@lgen_filter));

	return ($top_inst, $ocp_inst);
};

# add logic to pre_dec module (it is only a big address decoder which is hopefully reduced by synthesis tool) 
sub _vgch_rs_gen_pre_dec_logic {
    my ($this, $o_domain, $predec_inst) = @_;
    my $refclks = $this->global->{'hclocks'};
    my @ludc;
    my ($n, $select, $clock, $offset, $o_reg);
    my @ltemp;
    my $indent = $this->global->{'indent'};
    
    # get used bits of address to optimize the address decoder
	my $addr_msb = $this->global->{'addr_msb'};
	my $addr_lsb = $this->global->{'addr_lsb'};
    
    # the pre-decoder output holds the number of the clock-domain, so the range is ceil(ld(n-domains))
    my $ld_nclocks = _bitwidth(scalar(keys %{$refclks}));
    my $range;
    if ($ld_nclocks == 1) {
        $range = "";
    } else {
        $range = $this->_gen_vector_range($ld_nclocks-1,0);
    };

    $this->_vgch_rs_gen_udc_header(\@ludc);
    push @ludc, "// pre-address decoder (per clock-domain)";
    push @ludc, "reg $range pre_dec;";
    push @ludc, "reg pre_dec_err;";
    push @ludc, "assign pre_dec_o     = pre_dec;";
    push @ludc, "assign pre_dec_err_o = pre_dec_err;";
    push @ludc, "", "always @(addr_i) begin";
    push @ludc, $indent . "pre_dec     = 0;";
    push @ludc, $indent . "pre_dec_err = 0;";
    push @ludc, $indent . "case (addr_i[$addr_msb:$addr_lsb]) // synopsys infer_mux";
    $n = 0;
    # iterate all clock domains
    foreach $clock (sort keys %{$refclks}) {
        my @loffsets = sort {$a <=> $b} keys %{$refclks->{$clock}->{'offset'}};
        # foreach $offset (keys %{$refclks->{$clock}->{'offset'}}) {
        #     # find all readable register addresses in the clock-domain
        #     $o_reg = $o_domain->find_reg_by_address_first($offset);
        #     if (defined($o_reg) and $o_reg->get_reg_access_mode() ne "W") { 
        #         push @loffsets, $offset;
        #     };
        # };
        # make a comma-seperated list of all addresses of the clock-domain; clip the address to the used
        # range and convert it to hex
        $select = join(", ", map {"'h"._val2hex($addr_msb-$addr_lsb+1, $_ >> $addr_lsb)} @loffsets);
        push @ltemp, $indent x 2 . "// clock-domain #$n --> $clock";
        push @ltemp, $indent x 2 . "$select". ": pre_dec = $n;";
        $n++;
    };
    push @ludc, @ltemp;
    push @ludc, $indent x 2 . "default: begin ";
    push @ludc, $indent x 3 . "pre_dec     = 0;";
    push @ludc, $indent x 3 . "pre_dec_err = 1;";
    push @ludc, $indent x 2 . "end";
    push @ludc, $indent . "endcase";
    push @ludc, "end";
    _pad_column(-1, $indent, 1, \@ludc);
    $this->_vgch_rs_write_udc($predec_inst, \@ludc);
};

# searches all clocks used in the register domain and stores the result in global->hclocks depending on 
# user settings; detects invalid configurations; collect some statistics per clock-domain;
# gets reset values for embedded control/status register;# returns the number of clocks
sub _vgch_rs_get_configuration {
	my $this = shift;
	my ($o_domain) = @_;
	my ($n, $o_field, $clock, $reset, %hclocks, %hresult, $href, $o_reg, $offset);
	my $bus_clock = $this->global->{'bus_clock'};
	my $rdpl_lvl = $this->global->{'read_pipeline_lvl'};
	my ($addr_msb, $addr_lsb) = $this->_get_address_msb_lsb($o_domain);

	$this->global->{'addr_msb'} = $addr_msb;
	$this->global->{'addr_lsb'} = $addr_lsb;

	# check if embedded register exists
	foreach $o_reg (@{$o_domain->regs}) {
		if ($o_reg->name eq $this->global->{'embedded_reg_name'} and !exists($this->global->{'embedded_reg'})) {
			$this->global('embedded_reg' => $o_reg);
            _info("will infer embedded register \'", $o_reg->name, "\'");
			last;
		};
	};

	$n = 0;
	$clock = "";
	my ($rerr_en, $ien, $val, $ecs_writable) = (0,0,7,1); # ecs parameter default values
	# iterate all fields and retrieve clock names and other stuff
	foreach $o_field (@{$o_domain->fields}) {
		# get default values of embedded reg
		if ($o_field->name eq "rs_to_ien") {
			$ien = $o_field->attribs->{'init'};
            if ($o_field->attribs->{'dir'} !~ m/w/i) {
                $ecs_writable = 0;
            };
		};
		if ($o_field->name eq "rs_to_rerr_en") {
			$rerr_en = $o_field->attribs->{'init'};
            if ($o_field->attribs->{'dir'} !~ m/w/i) {
                $ecs_writable = 0;
            };
        };
		if ($o_field->name eq "rs_to_val") {
			$val = $o_field->attribs->{'init'};
            if ($o_field->attribs->{'dir'} !~ m/w/i) {
                $ecs_writable = 0;
            };  
        };
		if ($this->_skip_field($o_field)) {
			next;
		};
		$clock = $o_field->attribs->{'clock'};
		$reset = $o_field->attribs->{'reset'};
		if ($clock  =~ m/[\%OPEN\%|\%EMPTY\%]/) {
			$clock = $bus_clock; # use default clock
		};
		if (!exists($hresult{$clock})) { # baustelle
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
		if ($o_field->attribs->{'dir'} =~ m/r/i) {
			$hresult{$clock}->{'has_read'} = 1; # store if has readable registers
		};
		if ($o_field->is_cond()) {
			$hresult{$clock}->{'has_cond_fields'} = 1;
			if ($o_field->attribs->{'spec'} =~ m/usr/i) {
				_warning("field \'",$o_field->{'name'},"\' is of type USR, conditional attribute makes no sense here");
			};
		};
        # save register address of field per clock-domain
        $offset = $o_domain->get_reg_address($o_field->reg);
        if (defined $offset) {
            $hresult{$clock}->{'offset'}->{$offset} = "";
        };

		# check length of field names
		if (length($o_field->{'name'}) >32) {
			_warning("field name \'",$o_field->{'name'},"\' is ridiculously long");
		};
		# check doubly defined fields, allowed only if there is a naming scheme in place which uniquifies the name
		if (grep ($_ eq $o_field->name, values(%{$this->global->{'hfnames'}}))) {
			if ($this->global->{'field_naming'} !~ m/[RN]/) {
				_error("field name \'",$o_field->{'name'},"\' is defined more than once; correct this or use a naming scheme to differentiate (parameter reg_shell.field_naming)");
			};
		};
		# enter name in new data struct for checking
		$this->global->{'hfnames'}->{$o_field} = $o_field->name;
	};

	# store def. values of embedded reg in global
	$this->global('ecs_def_val' => $val,
				  'ecs_def_ien' => $ien,
				  'ecs_def_rerr_en' => $rerr_en,
                  'ecs_writable' => $ecs_writable);

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
	
	# tell user if use of multi_clock_domains parameter is useless
	if ($n == 1 and $this->global->{'multi_clock_domains'}) { 
		_info("multi_clock_domains = 1 ignored, only one clock") if $this->global->{'multi_clock_domains'};
	};

	# check if read-pipelining is required
	my ($rdpl_stages)=0;
	if($rdpl_lvl > 0) {
		my $res_size = $addr_msb-$addr_lsb+1; # usable address width
		# calculate required number of read-pipeline stages
		while($res_size > $rdpl_lvl) {
			$res_size = $res_size -$rdpl_lvl;
			$rdpl_stages++;
		};
	};
	$this->global('rdpl_stages' => $rdpl_stages); # save for later
	_info("will infer $rdpl_stages read-pipeline stages");
	
	return $n;
};

# adds standard ports and connections to modules (OCP i/f, handshake i/f, clocks, resets)
sub _vgch_rs_add_static_connections {
	my ($this, $nclocks) = @_;
	my $ocp_i = $this->global->{'ocp_inst'};
	my ($mcda_i, $cfg_i, $sg_i, $sr_i, $predec_i, $clock, $is_async, $href, $n);
	my $bus_clock = $this->global->{'bus_clock'};
	my $bus_reset = $this->global->{'bus_reset'};
	my $dwidth = $this->global->{'datawidth'};
	my $awidth = $this->global->{'addrwidth'};
    my $top_inst = $this->global->{'top_inst'};

	$mcda_i = undef;
	if (exists($this->global->{'mcda_inst'})) {
		$mcda_i = $this->global->{'mcda_inst'};
        $predec_i = $this->global->{'predec_inst'};
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
	if(exists($this->global->{'embedded_reg'})) {
		_add_primary_output("sinterrupt", 0, 0, 0, $ocp_i);
	} else {
		_add_connection("%OPEN%", 0, 0, "${ocp_i}/sinterrupt_o", "");
	};
    _add_connection("%OPEN%", 0, 0, "", "${ocp_i}/wr_err_i"); # NEW wr_err input not used

    if (exists ($this->global->{'ocp_checker_inst'})) {
        my $ocpc_i = $this->global->{'ocp_checker_inst'};
        _add_primary_input($bus_clock, 0, 0, "${ocpc_i}/clk_i");
        _add_primary_input($bus_reset, 0, 0, "${ocpc_i}/reset_n_i");
        _add_primary_input("mreset_n", 0, 0, $ocpc_i);
        _add_primary_input("mcmd", 2, 0, $ocpc_i);
        _add_primary_input("maddr", $awidth-1, 0, $ocpc_i);
        _add_primary_input("mdata", $dwidth-1, 0, $ocpc_i);
        _add_primary_input("mrespaccept", 0, 0, $ocpc_i);
        _add_connection("scmdaccept_o", 0, 0, $ocp_i, "$ocpc_i/scmdaccept_i");
        _add_connection("sresp_o", 1, 0, $ocp_i, "$ocpc_i/sresp_i");
    };
    
	# connections for each config register block
	$n=0;
	foreach $clock (sort keys %{$this->global->{'hclocks'}}) {
        my $int_rst_n = $this->_gen_unique_signal_name("int_rst_n", $clock, "sr_inst");
        my $trans_start_p = $this->_gen_unique_signal_name("trans_start_p", $clock, "sg_inst");
        my $wr_clk = $this->_gen_unique_signal_name("wr_clk", $clock, "cg_write_inst");
        my $wr_clk_en = $this->_gen_unique_signal_name("wr_clk_en", $clock, "cg_write_inst");
        my $shdw_clk = $this->_gen_unique_signal_name("shdw_clk", $clock, "cg_shdw_inst");
        my $shdw_clk_en = $this->_gen_unique_signal_name("shdw_clk_en", $clock, "cg_shdw_inst");
        my $rd_clk = $this->_gen_unique_signal_name("rd_clk", $clock, "cg_read_inst");
        my $rd_clk_en = $this->_gen_unique_signal_name("rd_clk_en", $clock, "cg_read_inst");

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
		# _add_primary_input($this->global->{'scan_en_port_name'}, 0, 0, $cfg_i); # scan port
		_add_primary_input($this->global->{'scan_en_port_name'}, 0, 0, "$sr_i/test_i");  # scan port
		_tie_input_to_constant("${sg_i}/clk_s", 0, 0, 0);
		_tie_input_to_constant("${sg_i}/rst_s", 0, 0, 0);
		_add_connection("addr",  $awidth-1, 0, "${ocp_i}/addr_o", "${cfg_i}/addr_i");
		_add_connection("wr_data", $dwidth-1, 0, "${ocp_i}/wr_data_o", "${cfg_i}/wr_data_i");
		_add_connection("rd_wr", 0, 0, "${ocp_i}/rd_wr_o", "${cfg_i}/rd_wr_i");
		_add_connection($int_rst_n, 0, 0, "${sr_i}/rst_o", "");
		_add_connection($trans_start_p, 0, 0, "${sg_i}/rcv_o", "");
		if (!defined $mcda_i) {
            _add_connection("trans_start", 0, 0, "${ocp_i}/trans_start_o", "$sg_i/snd_i");
			_add_connection("rd_err", 0, 0, "${cfg_i}/rd_err_o", "${ocp_i}/rd_err_i");
			_add_connection("trans_done", 0, 0, "${cfg_i}/trans_done_o", "${ocp_i}/trans_done_i");
			_add_connection("rd_data", $dwidth-1, 0, "${cfg_i}/rd_data_o", "${ocp_i}/rd_data_i");
		} else {
			# connect config register block to MCDA
            _add_connection("trans_start_$n", 0, 0, "${mcda_i}/trans_start_vec_o($n)=(0)", "$sg_i/snd_i");
            # workaround, intermediate signal to connect bus to single bit inputs
            #_add_connection("int_trans_start_$n", 0, 0, "", "$sg_i/snd_i, ${cfg_i}/trans_start_i");
			_add_connection("rd_data_vec", $dwidth*$nclocks-1, 0, "$cfg_i/rd_data_o=(".(($n+1)*$dwidth-1).":".($n*$dwidth).")", "$mcda_i/rd_data_vec_i");
			_add_connection("rd_err_vec",  $nclocks-1, 0, "$cfg_i/rd_err_o=($n)", "$mcda_i/rd_err_vec_i");
			# _add_connection("%OPEN%", 0, 0, "${cfg_i}/rd_err_o", ""); # rd_err now driven by pre-decoder module
            _add_connection("trans_done_vec", $nclocks-1, 0, "$cfg_i/trans_done_o=($n)", "$mcda_i/trans_done_vec_i");
		};
		if (exists $href->{'cg_write_inst'}) {
			_add_primary_input($this->global->{'clockgate_te_name'}, 0, 0, $href->{'cg_write_inst'}."/test_i");
			_add_primary_input($clock, 0, 0, $href->{'cg_write_inst'}."/clk_i");
			_add_connection($wr_clk_en, 0, 0, "", $href->{'cg_write_inst'}."/enable_i");
			_add_connection($wr_clk, 0, 0, $href->{'cg_write_inst'}."/clk_o", "");
		};
		if (exists $href->{'cg_shdw_inst'}) {
			_add_primary_input($this->global->{'clockgate_te_name'}, 0, 0, $href->{'cg_shdw_inst'}."/test_i");
			_add_primary_input($clock, 0, 0, $href->{'cg_shdw_inst'}."/clk_i");
			_add_connection($shdw_clk_en, 0, 0, "", $href->{'cg_shdw_inst'}."/enable_i");
			_add_connection($shdw_clk, 0, 0, $href->{'cg_shdw_inst'}."/clk_o", "");
		};
		if (exists $href->{'cg_read_inst'}) {
			_add_primary_input($this->global->{'clockgate_te_name'}, 0, 0, $href->{'cg_read_inst'}."/test_i");
			_add_primary_input($clock, 0, 0, $href->{'cg_read_inst'}."/clk_i");
			_add_connection($rd_clk_en, 0, 0, "", $href->{'cg_read_inst'}."/enable_i");
			_add_connection($rd_clk, 0, 0, $href->{'cg_read_inst'}."/clk_o", "");
		};
		$n++; # count the config register blocks
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
        # connect pre-decoder
        _add_connection("addr",  $awidth-1, 0, "${ocp_i}/addr_o", "${predec_i}/addr_i");
        # connect MCDA and pre-decoder
        _add_connection("pre_dec", _bitwidth($nclocks)-1, 0, "${predec_i}/pre_dec_o", "${mcda_i}/pre_dec_i");
        _add_connection("pre_dec_err", 0, 0, "${predec_i}/pre_dec_err_o", "${mcda_i}/pre_dec_err_i");
        
	};

    # add some checking code for input ports to top-level module
    my @lchecks = ();
    my $dft;
    my @ltemp;
    $this->_vgch_rs_gen_udc_header(\@lchecks);
    push @lchecks, 'parameter P_WAIT_IS_DRIVEN = 256;',
'property is_driven(clk, rst_n, sig);',
'  @(posedge clk) $rose(rst_n) |=> ##P_WAIT_IS_DRIVEN !$isunknown(sig);',
'endproperty';
    @ltemp = ($this->global->{'scan_en_port_name'});
    if ($this->global->{'infer_clock_gating'} and (exists $href->{'cg_write_inst'} or exists $href->{'cg_shdw_inst'} or exists $href->{'cg_read_inst'})) {
        push @ltemp, $this->global->{'clockgate_te_name'};
    };
    foreach $dft (@ltemp) {
        push @lchecks, "assert_${dft}_driven: assert property(is_driven(". $this->_gen_clock_name($bus_clock).", $bus_reset".$this->global->{'POSTFIX_PORT_IN'}.", ". $dft . $this->global->{'POSTFIX_PORT_IN'}.")) else \$error(\"ERROR: input port $dft is undriven after reset\");";
    };
    $this->_indent_and_prune_sva(\@lchecks);
    $this->_vgch_rs_write_udc($top_inst, \@lchecks);
};

# Write out a Verilog file with defines
sub _vgch_rs_write_defines {
	my ($this, $o_domain) = @_;
	
	my $rs_name = $this->global->{'regshell_prefix'}."_".$o_domain->name;
	my $key;
	my $fname = $this->global->{'path_include'} . "/${rs_name}.".$this->global->{'verilog_def'};
	my @ltemp;

    if (! -d $this->global->{'path_include'}) {
        if ($this->global->{'mkdir'} =~ m/auto|all|yes/) {
            mkdir($this->global->{'path_include'})
        } else {
            _warning("directory \'",$this->global->{'path_include'},"\' does not exist and I am not allowed to create it (mkdir parameter)");
        };
    };
	if (!open(DHANDLE,">$fname")) {
		_warning("could not open file \'$fname\' for writing");
		return;
	};
	$this->_vgch_rs_gen_udc_header(\@ltemp);
	print DHANDLE join("\n", @ltemp);
	print DHANDLE "\n\n";
	print DHANDLE "// useful defines for domain ".$o_domain->name."\n";
	@ltemp=();
	foreach $key (sort keys %{$this->global->{'hhdlconsts'}}) {
		push @ltemp,"\`define ${key} ".$this->global->{'hhdlconsts'}->{$key};
	};
	_pad_column(1, $this->global->{'indent'}, 0, \@ltemp);
	print DHANDLE join("\n", @ltemp);
	print DHANDLE "\n// end\n";
	close(DHANDLE);

    # update statistics
    $eh->inc("sum.hdlfiles");
	_info("generated file \'$fname\'");
    
};

# write a file in XML syntax listing the required RTL libraries
sub _vgch_rs_write_msd_setup {
    my ($this) = @_;
    my $fname = "rtl_libs.xml";
    my @ludc;
    my $ref;
    
    if (!open(DHANDLE,">$fname")) {
		_warning("could not open file \'$fname\' for writing");
		return;
	};
    print DHANDLE "<!--\n";
    $this->_vgch_rs_gen_udc_header(\@ludc);
    print DHANDLE join("\n", @ludc);
	print DHANDLE "\n-->\n";
    print DHANDLE "<resources>\n";
    foreach $ref (@{$this->global->{'rtl_libs'}}) {
        print DHANDLE $this->global->{'indent'} . "<library>\n";
        print DHANDLE $this->global->{'indent'}x2 . $ref->{'project'}, "\n";
        print DHANDLE $this->global->{'indent'}x2 . "<version> " .  $ref->{'version'} . " </version>\n";
        print DHANDLE $this->global->{'indent'}x2 . "<release> " .  $ref->{'release'} . " </release>\n";
        print DHANDLE $this->global->{'indent'} . "</library>\n";  
    };
    print DHANDLE "</resources>\n";
    # update statistics
    $eh->inc("sum.hdlfiles");
	_info("generated file \'$fname\'");
};

# helper method to prepare SVA to be inserted into module
sub _indent_and_prune_sva {
    my ($this, $lref_checks) = @_;
	# add comment and pragmas to checking code and indent it (unless there is no code or not enabled)
	if (scalar(@$lref_checks)) {
		if ($this->global->{'infer_sva'}) {
			unshift @$lref_checks, ("", "/*","  checking code","*/", split("\n",$this->global->{'assert_pragma_start'}));
			push @$lref_checks, split("\n",$this->global->{'assert_pragma_end'});
			_pad_column(-1, $this->global->{'indent'}, 2, $lref_checks);
		} else {
			@$lref_checks=();
		};
	};
};

# function to determine if a field is to be skipped because it is excluded by the user or because it belongs to
# the embedded control/status register
sub _skip_field {
	my($this, $o_field) = @_;
	if (
		grep ($_ eq $o_field->name, @{$this->global->{'lexclude_cfg'}}) 
		or grep ($_ eq $o_field->reg->name,@{$this->global->{'lexclude_cfg'}}) 
		or $o_field->reg->name eq $this->global->{'embedded_reg_name'}
	   ) 
	  {
		  return 1;
	  } else {
		  return 0;
	  };
};

# calcute the effectively used range of the address
sub _get_address_msb_lsb {
	my($this, $o_domain) = @_;
	my($msb, $lsb, $href, $i);
   
    $lsb = 0;

	# determine lsb of address
	for ($i=0; $i<=4; $i++) {
		if($this->global->{'datawidth'} <= (8,16,32,64,128)[$i]) {
		   $lsb = $i;
		   last;
	   };
	};

    # determine msb of address
	$msb = $lsb;
	foreach $href (@{$o_domain->addrmap}) {
		while($href->{'offset'} > 2**($msb+1)-1) {
			$msb++;
		}; 
	};
	return ($msb, $lsb);
};

# generate a vector range for a field depending on its position in a register
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

# generate a vector range for a field depending on its size and lsb
sub _get_frange {
	my ($this, $o_field) = @_;

	if ($o_field->attribs->{'size'} == 1) {
		return "";
	} else {
		my $lsb = $o_field->attribs->{'lsb'};
		my $msb = $lsb - 1 + $o_field->attribs->{'size'};
		return $this->_gen_vector_range($msb, $lsb);
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

# helper function to call add_inst()
sub _add_instance {
	my($this, $name, $parent, $comment, $udc) = @_;
	return add_inst
	  (
	   '::entity' => $name,
	   '::inst'   => '%PREFIX_INSTANCE%%::entity%%POSTFIX_INSTANCE%',
	   '::descr'  => $comment,
	   '::parent' => $parent,
	   '::lang'   => $this->global->{'lang'},
       '::udc'    => $udc
	  );
};

# like _add_instance but the instance name is unique
{
	my($unumber) = 0; # static variable for this method
	sub _add_instance_unique {
		my($this, $name, $parent, $comment, $udc) = @_;
		my($uname) = "%PREFIX_INSTANCE%u${unumber}_${name}%POSTFIX_INSTANCE%";
		$unumber++;
		return add_inst
		  (
		   '::entity' => $name,
		   '::inst'   => $uname,
		   '::descr'  => $comment,
		   '::parent' => $parent,
		   '::lang'   => $this->global->{'lang'},
           '::udc'    => $udc
		  );
	}
};

# function to add a postfix to a clock name if it is a primary input
sub _gen_clock_name {
	my ($this, $clock) = @_;
    my $result = $clock;

    if ($clock eq $this->global->{'bus_clock'} or grep ($clock eq $_, keys %{$this->global->{'hclocks'}})) {
        $result .= $this->global->{'POSTFIX_PORT_IN'};
    };
    return $result;
};

# function to generate the name for a field how it appears in the HDL; solely use this function
# to get the name of a field!
# input: type = [in|out|int_set|shdw|usr_trans_done|trg]
# o_field = ref to field object
sub _gen_field_name {
	my ($this, $type, $o_field) = @_;
	my ($name);

	# get field name from global struct
	if (exists($this->global->{'hfnames'}->{$o_field})) {
		$name = $this->global->{'hfnames'}->{$o_field};
	} else {
		$name = $o_field->name; # take original name
		_error("internal error: field name \'", $name, "\' not found in global struct");
	};

	if ($type eq "in") {
		$name .= "%POSTFIX_FIELD_IN%";
	} elsif ($type eq "out") {
		$name .= "%POSTFIX_FIELD_OUT%";
	} elsif ($type eq "int_set") {
		$name .= $this->global->{'int_set_postfix'}."%POSTFIX_PORT_IN%";
	} elsif ($type eq "shdw") {
		$name .= "_shdw";
	} elsif ($type eq "usr_trans_done") {
		$name .= "_trans_done_p"."%POSTFIX_PORT_IN%";
	} elsif ($type eq "usr_rd") {
		$name .= "_rd_p"."%POSTFIX_PORT_OUT%";
	} elsif ($type eq "usr_wr") {
		$name .= "_wr_p"."%POSTFIX_PORT_OUT%";
	} elsif ($type eq "trg") {
		$name .= "_trg_p"."%POSTFIX_PORT_OUT%";
	};

    my $naming_scheme = $this->global->{'field_naming'};
	# prefix field name with register name
	if ($this->global->{'use_reg_name_as_prefix'}) {
        _warning("use of parameter \'reg_shell.use_reg_name_as_prefix\' is deprecated, use \'reg_shell.field_naming\' instead");
        $naming_scheme = "%R_" . $naming_scheme;
	};
    # apply naming scheme
    $name = _clone_name($naming_scheme, 99, $o_field->id, $this->global->{'current_domain'}->name, $o_field->reg->name, $name);
    
	return $name;
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
# note: parameter inst_key is key name in global hclocks hash
sub _gen_unique_signal_name {
	my ($this, $signal_name, $clock, $inst_key) = @_;
	my $href = $this->global->{'hclocks'}->{$clock};

	if ($this->global->{'multi_clock_domains'} == 0 or scalar(keys %{$this->global->{'hclocks'}})==1) {
        return $signal_name;
    } else {
        return (exists($href->{$inst_key}) ? $href->{$inst_key} . "_" . $signal_name : $signal_name);
    };
};

# function to generate the right-hand-side statement (RHS) for an assignment that used the cond_slice() function;
# value is a string with the original RHS which will be wrapped in the function call;
# the first argument to cond_slice() is an integer parameter; if the parameter is < 0, the function returns the
# 2nd parameter. If the parameter is >=0, the function returns the parameter itself
sub _gen_cond_rhs {
	my ($this, $href_params, $o_field, $value) = @_;
	my $res_val = $value;

	my $parname = "P__".uc($this->_gen_field_name("",$o_field));
	if($o_field->is_cond()) {
		$res_val = "cond_slice($parname, $value)";
		$href_params->{$parname} = -1; # default value -1
	};
	return $res_val;
};
1;
