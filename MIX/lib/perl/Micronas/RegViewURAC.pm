###############################################################################
#  RCSId: $Id: RegViewURAC.pm,v 1.3 2009/08/12 12:17:35 lutscher Exp $
###############################################################################
#                                  
#  Related Files :  Reg.pm, RegOOUtils.pm
#
#  Author(s)     :  Thorsten Lutscher                                      
#  Email         :  thorsten.lutscher@tridentmicro.com                          
#
#  Project       :  MIX                                              
#
#  Creation Date :  06.08.2009
#
#  Contents      :  Functions to create URAC bus HDL register space views
#                   from Reg class object 
#
###############################################################################
#                               Copyright
###############################################################################
#
#       Copyright (C) 2009 Trident Microsystems (Europe), Munich, Germany 
#
#     All rights reserved. Reproduction in whole or part is prohibited
#          without the written permission of the copyright owner.
#
###############################################################################
#                                History
###############################################################################
#
#  $Log: RegViewURAC.pm,v $
#  Revision 1.3  2009/08/12 12:17:35  lutscher
#  small fixes
#
#  Revision 1.2  2009/08/12 09:50:48  lutscher
#  removed automatic takeover for read-only fields
#
#  Revision 1.1  2009/08/12 07:40:19  lutscher
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
use Data::Dumper;
use Micronas::MixUtils qw($eh);
use Micronas::Reg;
use Micronas::RegDomain;
use Micronas::RegReg;
use Micronas::RegField;
use Micronas::RegOOUtils;
use Micronas::MixUtils::RegUtils;
use Micronas::RegViews; # we use some methods from this package that are not bus-protocol dependent

#------------------------------------------------------------------------------
# Private methods (of class Reg)
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# view: hdl-urac-rs

# Main entry function; generate data structures for the MIX Parser for Register 
# shell generation;
# input: view-name, list ref. to domain names for which register shells are generated; if empty, 
# register shells for ALL register space domains in the Reg object are generated
# output: 0 in case of non-recoverable error, 1 otherwise
sub _gen_view_urac_rs {
	my $this = shift;
    my ($view_name, $lref_domains) = @_;
	my @ldomains;
	my $href;
	my $o_domain;
    
    # initialise some config variables
    $this->_urac_rs_init();

	# make list of domains for generation
	if (scalar (@$lref_domains)) {
        # user supplied domains
		foreach my $domain (@$lref_domains) {
			$o_domain = $this->find_domain_by_name_first($domain);
			if (ref($o_domain)) {
				push @ldomains, $this->find_domain_by_name_first($domain);
			} else {
				_error("unknown domain \'$domain\'");
			};
		};
	} else {
		foreach $href (@{$this->domains}) { 
            # all domains
			push @ldomains, $href;
		};
	};

	# check parameters

	# modify MIX config parameters (only where required)
    ##LU this is potentially dangerous because subsequent view generators could be affected
	$eh->set('check.signal', 'load,driver,check');
    $eh->set('port.generate.name', 'postfix');
    $eh->set('postfix.PREFIX_PORT_GEN', '%EMPTY%');
    $eh->set('postfix.POSTFIX_PORT_GEN', '_%IO%');
    $eh->set('output.generate.inout', 'mode'); # default is mode,noxfix
    
    # $eh->set('output.filter.file', "");
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

	my ($o_field, $o_reg, $top_inst, $ocp_inst, $n_clocks, $clock);

	# iterate through all register domains and generate one register-shell per domain
	foreach $o_domain (@ldomains) {
		_info("generating code for domain ",$o_domain->name);
		$o_domain->display() if $this->global->{'debug'};
        $this->global('current_domain' => $o_domain);

		# reset per-domain data structures
        $this->global('hfnames' => {}, 'hclocks' => {}, 'hhdlconsts' => {}, 'hbackdoorpaths' => {}, 'rs_configuration' => "");
		map {delete $this->global->{$_}} grep $_ =~ m/_inst$/i,keys %{$this->global};

		$n_clocks = $this->_urac_rs_get_configuration($o_domain); # get some general information

		$top_inst = $this->_urac_rs_gen_hier($o_domain, $n_clocks); # generate module hierarchy

		$this->_urac_rs_add_static_connections($o_domain, $n_clocks);# add all standard ports and connections 
		
        my @ludc  = ();
        
        $this->_urac_rs_gen_cfg_module($o_domain, \@ludc); # generate config module for clock domain
        $this->_vgch_rs_write_udc($top_inst, \@ludc); # add user-defined-code to config module instantation
	   
		# write out auxiliary files (per domain)
		$this->_vgch_rs_write_defines($o_domain);
        $this->_vgch_rs_write_backdoor_paths($o_domain);
	};
    # write a file with MSD setup
    $this->_vgch_rs_write_msd_setup();
	$this->display() if $this->global->{'debug'}; # dump Reg class object
    
	1;
};

# init global parameters and import mix.cfg parameters
sub _urac_rs_init {
    my $this =  shift;
    
   	# extend class data with data structure needed for code generation
	$this->global(
                  'mix_signature'      => "\"M1\"",     # signature for cross-checking MIX software version and IP version
                  'rtl_libs'           => [
                                           {
                                            "project" => "ip_sync",
                                            "version" => "0001",
                                            "release" => "ip_sync_006_23jan2008"
                                           }
                                          ],  
                  'set_postfix'        => "_set_p",     # postfix for interrupt-set input signal
				  'field_spec_values'  => ['sha', 'w1c'], # recognized values for spec attribute
				  'indent'             => "    ",       # indentation character(s)
				  'assert_pragma_start'=> "`ifdef ASSERT_ON
// msd parse off",
				  'assert_pragma_end'  => "// msd parse on
`endif",
                  'cfg_module_prefix'  => "cfg",        # prefix for sub-modules, attached to regshell_prefix
				  # internal static data structs
				  'hclocks'            => {},           # for storing per-clock-domain information
				  'hfnames'            => {},           # for storing field names
				  'lexclude_cfg'       => [],           # list of registers to exclude from code generation
				  'hhdlconsts'         => {},           # hash with HDL constants
                  'hbackdoorpaths'     => {},           # hash with backdoor path to registers (key is reg-offset)
                  'current_domain'     => {},           # store currently processed domain object
                  'hparams'            => {},           # top-level parameters, needed if reg-shell is embedded in bigger hierarchy
                  'rs_configuration'   => ""            # type of register-shell configuration
				 );

	# import regshell.<par> parameters from MIX package to class data; user can change these parameters in mix.cfg
    # see also Globals.pm
	my $param;
	my @lmixparams = (
					  'reg_shell.bus_clock', 
					  'reg_shell.bus_reset', 
					  'reg_shell.addrwidth', 
					  'reg_shell.datawidth',
					  'reg_shell.infer_sva',
					  'reg_shell.exclude_regs',
					  'reg_shell.exclude_fields',
                      'reg_shell.regshell_prefix',  
                      'reg_shell.enforce_unique_addr',
                      'reg_shell.field_naming',
                      'reg_shell.domain_naming',
                      'reg_shell.virtual_top_instance',
                      'reg_shell.workaround',
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
    if (not defined($eh->mix_get_module_info("RegViews"))) {
        $eh->mix_add_module_info("RegViewURAC", '$Revision: 1.3 $ ', "Utility functions to create URAC register space view from Reg class object");
    };
};

# main method to generate config module 
# input: domain object, 
# reference to list where code lines are added (::udc)
sub _urac_rs_gen_cfg_module {
	my ($this, $o_domain, $lref_udc) = @_;
	my($o_reg, $shdw_sig, $par);
    my $bus_clock = $this->global->{'bus_clock'};
	my $bus_reset = $this->global->{'bus_reset'};
    my $top_inst = $o_domain->{'top_inst'};
	my (@ldeclarations) = ("", "/*","  local wire or register declarations","*/");
	my (@lstatic_logic) = ();
	my (%hshdw, %hshdw_tp, %hassigns, %hwp, %haddr_tokens, %hrp, %hwp_sts, %hparams);
	my (@lassigns) = ("", "/*","  local wire and output assignments","*/");
	my (@ldefines) = ("", "/*", "  local definitions","*/");
	my $addr_msb = $this->global->{'addr_msb'};
	my $addr_lsb = $this->global->{'addr_lsb'};
    my (@ltp) = ();
	my (@lsp) = ();
	my (@lrp) = ();
	my (@lchecks) = ();
	my (@lheader) = ();
	my $p_pos_pulse_check = 0;
	my ($o_field, $ftemp);
    my @lgen_filter = ();
    my ($clock, $fclock, $freset, $rclock);

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
			push @ldefines, "localparam ".$haddr_tokens{$reg_offset}." = ".($reg_offset >> $addr_lsb)."; // ".$o_reg->name; 
			# declare register
			push @ldeclarations, "reg [".($this->global->{'datawidth'}-1).":0] $reg_name;";
		} else {
            if ($this->global->{'enforce_unique_addr'}) {
                _error("register offset $reg_offset for register \'", $o_reg->name, "\' already used");
                next;
            };
        };

        $rclock = "";
		$fclock = "";
		$freset = "";
		# iterate through all fields of the register (sort by name)
		foreach my $href (sort {$a->{'field'}->name cmp $b->{'field'}->name} @{$o_reg->fields}) {
			$o_field = $href->{'field'};
			$shdw_sig = "";
			# $o_field->display();
			($fclock, $freset) = $this->_get_field_clock_and_reset("", "", $fclock, $freset, $o_field);

            # check if all fields in a register have the same clock-domain
            if ($rclock eq "") {
                $rclock = $fclock;
            } else {
              if ($fclock ne $rclock and $this->global->{'multi_clock_domains'}) {
                  _error("register \'",$o_reg->name,"\' has fields in different clock domains (\'$rclock\' and \'$fclock\'); not supported");
                  last;
              };  
            };

			# skip fields defined by user
			if (grep ($_ eq $o_field->name, @{$this->global->{'lexclude_cfg'}})) {
				_info("skipping field ", $o_field->name);
				next;
			};

            # store address/backdoor path to register if not already stored
            if ($o_reg->get_reg_access_mode() =~ m/w/gi and not exists($this->global->{'hbackdoorpaths'}->{$reg_offset})) {
                $this->global->{'hbackdoorpaths'}->{$reg_offset} = join(".", $top_inst, $reg_name);
            };

			# get field attributes
			my $spec = $o_field->attribs->{'spec'}; # note: spec can contain several attributs
            if (!grep {$_ eq $spec} @{$this->global->{'field_spec_values'}}) {
                _warning("spec attribute $spec not supported by this view");
            };
			my $access = lc($o_field->attribs->{'dir'});
			my $rrange = $this->_get_rrange($href->{'pos'}, $o_field);
			my $lsb = $o_field->attribs->{'lsb'};
			my $msb = $lsb - 1 + $o_field->attribs->{'size'};
			my $res_val = sprintf("'h%x", $o_field->attribs->{'init'});
           
			# store size and MSBs/LSBs attributes for later
            $this->global->{'hhdlconsts'}->{$this->_gen_fname("", $o_field) . "_pos_c"} = "'h"._val2hex($this->global->{'datawidth'}/4, $href->{'pos'});
            $this->global->{'hhdlconsts'}->{$this->_gen_fname("", $o_field) . "_size_c"} = "'h"._val2hex($this->global->{'datawidth'}/4, $o_field->attribs->{'size'});
			if ($o_field->attribs->{'size'} >1) {
				$this->global->{'hhdlconsts'}->{$this->_gen_fname("", $o_field) . "_msb_c"} = "'h"._val2hex($this->global->{'datawidth'}/4, $msb);
				$this->global->{'hhdlconsts'}->{$this->_gen_fname("", $o_field) . "_lsb_c"} = "'h"._val2hex($this->global->{'datawidth'}/4, $lsb);
			};

			# track shadow signals
			if ($spec =~ m/sha/i) {
                if($spec =~ m/w1c/i) {
                    _error("a shadowed field can not have W1C attribute (here: field ", $o_field->name, "); the set-signal from hardware side will be properly synchronized if necessary");
                    next;
                };
                
                $shdw_sig = $o_field->attribs->{'sync'};        
                if(lc($shdw_sig) eq "nto" or $shdw_sig =~ m/(%OPEN%|%EMPTY%)/) {
                    if ($access eq "r") {
                        _error("the SHA attribute without an external take-over signal (::sync column) is not supported for read-only fields (here: field ", $o_field->name, ")");
                        next;
                    }
                    if ($fclock eq $bus_clock) {
                        _error("the SHA attribute without an external take-over signal (::sync column) is not supported for fields in the bus-clock domain (here: field ", $o_field->name, ")");
                        next;
                    };
                    # encode clock-domain and signal name in key
                    $shdw_sig = join("_", $reg_name, "wr_ts");
                    my $key = join(".", $fclock, $shdw_sig); 
                    $hshdw_tp{$key} = $haddr_tokens{$reg_offset}; # for creation of toggle signals for automatic takeover
                    if (!grep {$_ eq "reg ${shdw_sig}_s;"} @ldeclarations) {
                        push @ldeclarations, "reg ${shdw_sig}_s;"; # declare only once
                    };
                    $hassigns{$shdw_sig} = "${shdw_sig}_s";
                    $shdw_sig .= ".nto"; # encode that this signal is for automatic takeover
                };
                push @{$hshdw{join(".", $fclock, $shdw_sig)}}, $o_field;
            }; 
			
			
			# warnings/errors for w1c fields 
			if ($spec =~ m/w1c/i) {
                if ($access !~ m/w/ or $access !~ m/r/) {
                    _error("field \'",$o_field->name,"\': attribute W1C can only be combined with RW access");
                }; 
			};
				
			# add ports, declarations and assignments
			if ($access =~ m/r/i and $access !~ /w/i ) { # read-only
				$this->_add_input($this->_gen_fname("in", $o_field, 1), $msb, $lsb, $top_inst."/".$this->_gen_fname("in", $o_field));
				if ($spec =~ m/sha/i) {
					push @ldeclarations, "reg [$msb:$lsb] ".$this->_gen_fname("shdw", $o_field).";";
				};
			} elsif ($access =~ m/w/i) { # write
				$this->_add_output($this->_gen_fname("out", $o_field, 1), $msb, $lsb, ($spec =~ m/sha/i) ? 1:0, $top_inst."/".$this->_gen_fname("out", $o_field));
				if ($spec =~ m/w1c/i) { # w1c
                    $ftemp = $this->_gen_fname("set", $o_field);
                    push @{$hwp_sts{$fclock}}, $o_field; # save (clock-domain => field) for later
					$this->_add_input($this->_gen_fname("set", $o_field, 1), $msb, $lsb, $top_inst."/".$ftemp);
					$p_pos_pulse_check = 1;
                    my $fclock_port = $this->_gen_clock_name($fclock);
                    my $freset_port = $freset . $this->global->{'POSTFIX_PORT_IN'}; 
                    if ($o_field->attribs->{'size'}>1) {
                        for (my $i=$lsb; $i<=$msb; $i++) {
                            push @lchecks, "assert_${ftemp}${i}_is_a_pulse: assert property(p_pos_pulse_check($fclock_port, $freset_port, ${ftemp}[$i\]));";
                        };
                    } else {
                         push @lchecks, "assert_${ftemp}_is_a_pulse: assert property(p_pos_pulse_check($fclock_port, $freset_port, ${ftemp}));";
                    };
				};
				if ($spec !~ m/sha/i) {				
                    # drive output signal from register
                    $hassigns{$this->_gen_fname("out", $o_field).$this->_get_frange($o_field)} = $this->_gen_cond_rhs(\%hparams, $o_field, $reg_name.$rrange);
				} else {
					# drive shadow signal from register
					$hassigns{$this->_gen_fname("shdw", $o_field).$this->_get_frange($o_field)} = $this->_gen_cond_rhs(\%hparams, $o_field, $reg_name.$rrange);
					push @ldeclarations,"wire ".($this->_get_frange($o_field))." ".$this->_gen_fname("shdw", $o_field).";";
				};
		   
			};

			# registers in write processes
			if ($access =~ m/w/i) { # write
				if ($spec !~ m/w1c/i) { # read/write
					$hwp{'write'}->{$reg_name.$rrange} = $reg_offset;
					$hwp{'write_rst'}->{$reg_name.$rrange} = $res_val;
				} else { # w1c
                    my $pos = $href->{'pos'};
                    if ($o_field->attribs->{'size'} == 1) {
                        $hwp{'write_sts'}->{$reg_name.$rrange} = $this->_gen_fname("set_s", $o_field); # use name of sync'ed signal
                    } else {
                        # multi-bit w1c fields
                        for (my $i=0; $i<$o_field->attribs->{'size'}; $i++) {
                            $hwp{'write_sts'}->{$reg_name.($this->_gen_vector_range($pos+$i, $pos+$i))} = $this->_gen_fname("set_s", $o_field) . ($this->_gen_vector_range($lsb+$i, $lsb+$i));
                        };
                    };
					$hwp{'write_sts_rst'}->{$reg_name.$rrange} = $res_val;
				};
			};
			
			# registers for read mux
			if ($access =~ m/r/i) { # read
				if ($access =~ m/w/i) { # read/write
					if ($spec =~ m/sha/i) {
						push @{$hrp{$reg_offset}}, {$rrange => $this->_gen_fname("shdw", $o_field)};
					} else {
						#push @{$hrp{$reg_offset}}, {$rrange => $reg_name.$rrange};
						push @{$hrp{$reg_offset}}, {$rrange => $this->_gen_cond_rhs(\%hparams, $o_field, $reg_name.$rrange)};
                    };
				} else { # read-only
					if ($spec =~ m/sha/i) {
						push @{$hrp{$reg_offset}}, {$rrange => $this->_gen_fname("shdw", $o_field)};
					} else {
						push @{$hrp{$reg_offset}}, {$rrange => $this->_gen_fname("in", $o_field)};
					};
				};
			}; 
		}; # foreach $href
	}; # foreach $o_reg 
	
	# add additional top-level parameters
	foreach $par (keys %hparams) {
        if ($this->global->{'virtual_top_instance'} eq "testbench") {
            _add_generic($par, $hparams{$par}, $this->global->{'top_inst'});
        } else {
            # if we are embedded in a bigger hierarchy, pass down the parameters from top
            _add_generic($par, $hparams{$par}, $this->global->{'virtual_top_instance'});
            _add_generic_value($par, $hparams{$par}, $par, $this->global->{'top_inst'});
        };
		_add_generic_value($par, $hparams{$par}, $par, $top_inst);
        # store in global
        $this->global->{'hparams'}->{$par} = $hparams{$par};
    };

	# add property for checking input set-pulses
	if ($p_pos_pulse_check) {
		unshift @lchecks, split("\n","
property p_pos_pulse_check (clock, reset, sig); // check for positive pulse
     @(posedge clock) disable iff (~reset)
     sig |=> ~sig;
endproperty
");
	};

    # add synchronizers for input set-pulses (pulse sync'er);
    # if no sync'er is needed (all in bus-clock domain) add an assignment statement instead
    foreach $clock (sort keys %{$this->global->{'hclocks'}}) { 
        if (exists $hwp_sts{$clock}) {
            foreach $o_field (@{$hwp_sts{$clock}}) {
                $ftemp = $this->_gen_fname("set", $o_field, 1);
                my $ftemp_s = $this->_gen_fname("set_s", $o_field, 1);
                if ($clock eq $bus_clock) {
                    # no sync'er
                    $hassigns{$ftemp_s} = $ftemp;
                    push @ldeclarations,"wire ".($this->_get_frange($o_field))." ${ftemp_s};";
                } else {
                    my $ssp_inst = $this->_add_instance_unique("sync_generic", $top_inst, "Synchronizer for set-signal $ftemp");
                    _add_generic("kind", 0, $ssp_inst);
                    _add_generic("sync", 1, $ssp_inst);
                    _add_generic("act", 1, $ssp_inst);
                    _add_generic("rstact", 0, $ssp_inst);
                    _add_generic("rstval", 0, $ssp_inst);
                    $this->_add_input($ftemp, 0, 0, "${ssp_inst}/snd_i");
                    $this->_add_input($clock, 0, 0, "${ssp_inst}/clk_s");
                    $this->_add_input($o_field->attribs->{'reset'}, 0, 0, "${ssp_inst}/rst_s");
                    $this->_add_conn($ftemp_s, 0, 0, "${ssp_inst}/rcv_o", "");
                    $this->_add_input($bus_clock, 0, 0, "${ssp_inst}/clk_r");
                    $this->_add_input($bus_reset, 0, 0, "${ssp_inst}/rst_r");
                    push @lgen_filter, $ssp_inst;
                }; 
            };
        };
    };
    
    # add synchronizers for automatic takeover-signals (toggle->pulse);
    # they are set to synchronous or asynchronous depending on the sending clock domain
    foreach my $key (keys %hshdw_tp) {   
        ($clock, $shdw_sig) = split(/\./, $key);
        my $stp_inst = $this->_add_instance_unique("sync_generic", $top_inst, "Synchronizer for internal takeover-signal $shdw_sig");
        _add_generic("kind", 2, $stp_inst);
        if ($clock eq $bus_clock) {
            _add_generic("sync", 0, $stp_inst);  # no sync'er; this mode is prohibited though because it does not make sense
        } else {
            _add_generic("sync", 1, $stp_inst);
        };
        _add_generic("act", 1, $stp_inst);
        _add_generic("rstact", 0, $stp_inst);
        _add_generic("rstval", 0, $stp_inst);
        $this->_add_conn($shdw_sig, 0, 0, "", "${stp_inst}/snd_i");
        _tie_input_to_constant("${stp_inst}/clk_s", 0, 0, 0);
 		_tie_input_to_constant("${stp_inst}/rst_s", 0, 0, 0);
        $this->_add_conn($shdw_sig."_p", 0, 0, "${stp_inst}/rcv_o", "");
        $this->_add_input($clock, 0, 0, "${stp_inst}/clk_r");
        $this->_add_input($this->global->{'hclocks'}->{$clock}->{'reset'}, 0, 0, "${stp_inst}/rst_r");
        push @lgen_filter, $stp_inst;
    };

    # add synchronizers for external takeover-signals (edge->pulse)
    # note: for one signal there must be one sync'er per clock-domain
    my $nto;
    foreach my $key (keys %hshdw) {      
        ($clock, $shdw_sig, $nto) = split(/\./, $key);
        next if ($nto); # skip internal takeover signals
        # name must be unique
        my $shdw_signame = join("_", ("int", $shdw_sig, $clock, "p"));
        my $sxtp_inst = $this->_add_instance_unique("sync_generic", $top_inst, "Synchronizer for external takeover-signal $shdw_sig");
        _add_generic("kind", 3, $sxtp_inst);
        if ($clock eq $bus_clock) {
            _add_generic("sync", 0, $sxtp_inst);  # no sync'er
        } else {
            _add_generic("sync", 1, $sxtp_inst);
        };
        _add_generic("act", 1, $sxtp_inst);
        _add_generic("rstact", 0, $sxtp_inst);
        _add_generic("rstval", 0, $sxtp_inst);
        $this->_add_input($shdw_sig, 0, 0, "${sxtp_inst}/snd_i");
        _tie_input_to_constant("${sxtp_inst}/clk_s", 0, 0, 0);
 		_tie_input_to_constant("${sxtp_inst}/rst_s", 0, 0, 0);
        $this->_add_conn($shdw_signame, 0, 0, "${sxtp_inst}/rcv_o", "");
        $this->_add_input($clock, 0, 0, "${sxtp_inst}/clk_r");
        $this->_add_input($this->global->{'hclocks'}->{$clock}->{'reset'}, 0, 0, "${sxtp_inst}/rst_r");
        push @lgen_filter, $sxtp_inst;
    };

    # generate process for automatic takeover
    $this->_urac_rs_code_takeover_signals_process(\%hshdw_tp, \@ltp);
	_pad_column(-1, $this->global->{'indent'}, 2, \@ltp); # indent

    # generate shadow processes
    foreach $clock (sort keys %{$this->global->{'hclocks'}}) { 
        $this->_urac_rs_code_shadow_process($clock, \%hshdw, \%hshdw_tp, \@lsp);
    };
    _pad_column(-1, $this->global->{'indent'}, 2, \@lsp); # indent

	# add glue-logic
	$this->_urac_rs_code_static_logic($o_domain, $bus_clock, \%hshdw, \@ldeclarations, \@lstatic_logic, \@lchecks);
	
	# add assignments
	push @lassigns, map {"assign $_ = ".$hassigns{$_}.";"} sort {$hassigns{$a} cmp $hassigns{$b}} keys %hassigns; 
	
	_pad_column(1, $this->global->{'indent'}, 2, \@lassigns); # indent assignments
	_pad_column(1, $this->global->{'indent'}, 2, \@ldefines); # indent defines

	# generate code for write processes
	my @lwp;
	$this->_urac_rs_code_write_processes($bus_clock, \%hwp, \%haddr_tokens, \@lwp);
	_pad_column(-1, $this->global->{'indent'}, 2, \@lwp); # indent

	# generate code for read mux
	$this->_urac_rs_code_read_mux($bus_clock, \%hrp, undef, \%haddr_tokens, \@lrp, \@ldeclarations);
	_pad_column(-1, $this->global->{'indent'}, 2, \@lrp); # indent
	
    $this->_indent_and_prune_sva(\@lchecks);

	_pad_column(0, $this->global->{'indent'}, 2, \@ldeclarations); # indent declarations

	# insert everything
	push @$lref_udc, @lheader, @ldefines, @ldeclarations, @lassigns, @lstatic_logic, @lwp, @lsp, @ltp, @lrp, @lchecks;

	# do not generate library modules
	$eh->cappend('output.filter.file', join(",",@lgen_filter));
};

# generate process for generating toggle signals for automatic takeover; these signals are first
# synchronized and then used in the shadow process, see _urac_rs_code_shadow_process();
# input: hash with toggle signals names: <clock>.<signame> => <address-offset-token>
# output: ref. to list where code is added
sub _urac_rs_code_takeover_signals_process {
    my ($this, $href_shdw_tp, $lref_tp) = @_;
    my @linsert;
    my @ltemp;
	my $ind = $this->global->{'indent'};
	my $ilvl = 0;
    my $bus_clock = $this->_gen_clock_name($this->global->{'bus_clock'});
    my $int_rst_n = $this->global->{'bus_reset'} . $this->global->{'POSTFIX_PORT_IN'};

    if (scalar keys %{$href_shdw_tp} > 0 ) {
        # prefix
        push @linsert, "", "/*","  toggle-signals for automatic takeover (read and write)", "*/";
        push @linsert, $ind x $ilvl++ . "always @(posedge $bus_clock or negedge $int_rst_n) begin";
        push @linsert, $ind x $ilvl . "if (~$int_rst_n) begin";

        # reset block
        foreach my $key (sort keys %{$href_shdw_tp}) {
            my ($clock, $shdw_sig) = split(/\./, $key);
            push @linsert, $ind x ($ilvl+1) . "${shdw_sig}_s <= 0;";
        };
        push @linsert, $ind x $ilvl . "end";
		push @linsert, $ind x $ilvl . "else begin";

        # signal assignment block
        foreach my $key (sort keys %{$href_shdw_tp}) {
            my ($clock, $shdw_sig) = split(/\./, $key);
            push @linsert, $ind x ($ilvl+1) . "if (iaddr == ".($href_shdw_tp->{$key})." && urac_wren_i)";
            push @linsert, $ind x ($ilvl+2) . "${shdw_sig}_s <= ~${shdw_sig}_s;";
        };
   
        push @linsert, $ind x $ilvl . "end";
		$ilvl--;
		push @linsert, $ind x $ilvl . "end";
    };

    push @$lref_tp, @linsert; 
};

# create code for a shadow process for update signal $sig
# a field can have either write-shadow registers or read-shadow registers; read-shadowing is only implemented
# for read-only fields;
# input: clock-name,
# hash with shadow signals and fields-array <clock>.<shadow-signal>[.nto] => (list of fields)
# where the optional postfix .nto means that the signal is not an external takeover signal
# output: ref. to list where code is added
sub _urac_rs_code_shadow_process {
	my ($this, $clock, $href_shdw, $href_shdw_tp, $lref_sp) = @_;
	my @linsert;
	my $ind = $this->global->{'indent'};
	my $ilvl = 0;
	my $o_field;
  
    if (scalar grep {$_ =~ m/^$clock\./} keys %{$href_shdw}) {
        my $int_rst_n = $this->global->{'hclocks'}->{$clock}->{'reset'} . $this->global->{'POSTFIX_PORT_IN'};
        
        push @linsert, "", "/*","  shadowing (into clock domain $clock)", "*/";
        push @linsert, $ind x $ilvl++ . "always @(posedge ". $this->_gen_clock_name($clock) ." or negedge $int_rst_n) begin";
        push @linsert, $ind x $ilvl . "if (~$int_rst_n) begin";
        
        # reset block
        foreach my $key (sort keys %{$href_shdw}) {
            my ($_clock, $_sig, $_nto) = split(/\./, $key);
            next if ($clock ne $_clock);
            foreach $o_field (@{$href_shdw->{$key}}) {
                my $res_val = 0;
                if (exists($o_field->attribs->{'init'})) {
                    $res_val = sprintf("'h%x", $o_field->attribs->{'init'});
                };
                my $access = lc($o_field->attribs->{'dir'});
                if ($access =~ m/w/) {
                    push @linsert, $ind x ($ilvl+1) . $this->_gen_fname("out", $o_field) ." <= $res_val;";
                } else {
                    if ($access =~ m/r/) {
                        push @linsert, $ind x ($ilvl+1) . $this->_gen_fname("shdw", $o_field) ." <= $res_val;";
                    };
                };
            };
        };
        push @linsert, $ind x $ilvl . "end";
        push @linsert, $ind x $ilvl . "else begin";
        
        # signal assignment block
        foreach my $key (sort keys %{$href_shdw}) {
            my ($_clock, $_sig, $_nto) = split(/\./, $key);
            next if ($clock ne $_clock);
            my $signame;
            if ($_nto) {
                $signame = $_sig . "_p";
            } else {
                $signame = join("_", ("int", $_sig, $clock, "p"));
            };
            push @linsert, $ind x ($ilvl+1) . "if ($signame) begin";
            foreach $o_field (@{$href_shdw->{$key}}) {
                my $access = lc($o_field->attribs->{'dir'});
                if ($access =~ m/w/) {
                    push @linsert, $ind x ($ilvl+2) . $this->_gen_fname("out", $o_field) ." <= ". $this->_gen_fname("shdw", $o_field) . ";";
                } else {
                    if ($access =~ m/r/) {
                        push @linsert, $ind x ($ilvl+2) . $this->_gen_fname("shdw", $o_field) ." <= " . $this->_gen_fname("in", $o_field) . ";";
                    };
                }; 
            };
            push @linsert, $ind x ($ilvl+1) . "end";
        };
        
        push @linsert, $ind x $ilvl-- . "end";
        push @linsert, $ind x $ilvl . "end";
        
        push @$lref_sp, @linsert;
    }; 
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
sub _urac_rs_code_read_mux {
	my ($this, $clock, $href_rp, $href_rp_trg, $href_addr_tokens, $lref_rp, $lref_decl) = @_;
	my (@linsert, @ltemp);
	my $ind = $this->global->{'indent'};
	my $ilvl = 0;
	my ($offs, $href, $cur_addr);
	my $n;
	# my $rdpl_stages = $this->global->{'rdpl_stages'};
	# my $rdpl_lvl =  $this->global->{'read_pipeline_lvl'};
	my ($i, $field);
	my $addr_msb = $this->global->{'addr_msb'};
	my $addr_lsb = $this->global->{'addr_lsb'};
	my (%hmux);

	if (scalar(keys %$href_rp)>0) {
		# prefix
		push @linsert, "", "/*","  read logic and mux process","*/";
        
        push @ltemp, "mux_rd_data <= 0;";
        _pad_column(0, $ind, $ilvl + 1, \@ltemp);
        push @linsert, $ind x $ilvl++ . "always @(*) begin";
        push @linsert, @ltemp;
        push @linsert, $ind x $ilvl++ . "case (iaddr)";
        
        foreach $offs (sort {$a <=> $b} keys %$href_rp) {
            $cur_addr = $href_addr_tokens->{$offs};
            push @linsert, $ind x $ilvl . "$cur_addr : begin";
            foreach $href (@{$href_rp->{$offs}}) {
                push @linsert, $ind x ($ilvl+1) . "mux_rd_data".(keys %{$href})[0] . " <= ".(values %{$href})[0].";";
            };
            push @linsert, $ind x $ilvl . "end";
            $n++;
        };
        push @linsert, $ind x $ilvl-- . "default: ;";
        push @linsert, $ind x $ilvl-- . "endcase";
        push @linsert, $ind x $ilvl . "end";
        # add intermediate regs
        push @$lref_decl, "reg [".($this->global->{'datawidth'}-1).":0] mux_rd_data;";
	} else { # no read-registers
        push @linsert, "", "/*","  no readable registers inferred","*/";
		push @linsert, $ind x $ilvl . "assign mux_rd_data = 'hdeadbeef;";
        push @$lref_decl, "wire [".($this->global->{'datawidth'}-1).":0] mux_rd_data;";
    };
    
	push @$lref_rp, @linsert;
};

# create code for write processes from hash database and return a list with an entry for each line
# input:
# $clock clock name for processes
# %hwp ( write => (LHS => RHS)),
#        write_rst => (LHS => RHS),
#        write_sts => (LHS => RHS),
#        write_sts_rst => (LHS => RHS),
# hash with register-offset tokens (offset => token)
# ref. to list where code is added
#
# LHS/RHS = left/right-hand-side in verilog assignment
sub _urac_rs_code_write_processes {
	my ($this, $clock, $href_wp, $href_addr_tokens, $lref_wp) = @_;
	my $write_clock = $clock;
	my $write_sts_clock = $clock;
	my $ind = $this->global->{'indent'};
	my $ilvl = 0;
	my (@linsert, @ltemp, $last_addr, $cur_addr, $reg_name, $reg_addr, $rrange);
	my ($key, $key2);
	my $offs;

    my $int_rst_n = $this->global->{'bus_reset'} . $this->global->{POSTFIX_PORT_IN};

	#
	#  write block for normal registers
	#
	
	if (scalar(keys %{$href_wp->{'write'}})>0) {
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
        push @linsert, $ind x $ilvl++ . "if (urac_wren_i)";
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
					push @linsert, $ind x $ilvl . "$reg_addr: begin";
					_pad_column(0, $ind, $ilvl+1, \@ltemp);
					push @linsert, sort @ltemp;
					push @linsert, $ind x $ilvl . "end";
					@ltemp=();
				};
				$last_addr = $cur_addr;
			}
			push @ltemp, "$key <= wdata${rrange};";
		};
		# push last entries to list
		if (scalar(@ltemp) > 0) {
			$reg_addr = $cur_addr;
			push @linsert, $ind x $ilvl . "$reg_addr: begin";
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
	# @linsert = ();
	# if (scalar(keys %{$href_wp->{'write_trg'}})>0) {
    #     $write_clock = $clock; # use gated clock
    #     
    #     # prefix
	# 	push @linsert, "", "/*","  write trigger process","*/";
	# 	push @linsert, $ind x $ilvl++ . "always @(posedge ". $this->_gen_clock_name($clock)." or negedge $int_rst_n) begin";
    # 
	# 	# reset logic
	# 	push @linsert, $ind x $ilvl++ . "if (~$int_rst_n) begin";
	# 	@ltemp=();
	# 	foreach $key (sort keys %{$href_wp->{'write_trg_rst'}}) {
	# 		push @ltemp, "$key <= $href_wp->{'write_trg_rst'}->{$key};";
	# 	};	
	# 	_pad_column(0, $ind, $ilvl, \@ltemp);
	# 	push @linsert, @ltemp;
	# 	$ilvl--;
	# 	
	# 	# write logic
	# 	push @linsert, $ind x $ilvl ."end", $ind x $ilvl++ . "else begin";
	# 	foreach $key (sort {$href_wp->{'write_trg'}->{$a} <=> $href_wp->{'write_trg'}->{$b}} keys %{$href_wp->{'write_trg'}}) {
	# 		push @linsert, $ind x $ilvl . $key . " <= 0;";
	# 	};
    # 
	# 	push @linsert, $ind x $ilvl++ . "case (iaddr)";
	# 	@ltemp=();
	# 	foreach $key (sort {$href_wp->{'write_trg'}->{$a} <=> $href_wp->{'write_trg'}->{$b}} keys %{$href_wp->{'write_trg'}}) {
	# 		$reg_name = $key;
	# 		$offs = $href_wp->{'write_trg'}->{$key};
	# 		$rrange = "";
	# 		if ($reg_name =~ m/(\[.+\])$/) {
	# 			$reg_name = $`;
	# 			$rrange = $1;
	# 		};
	# 		$reg_addr = $href_addr_tokens->{$offs}; # use tokenized address instead of number
    #         push @linsert, $ind x $ilvl . "$reg_addr: $key <= wr_p;";
    #     };
    #     push @linsert, $ind x $ilvl . "default: ;";
	# 	$ilvl--;
	# 	push @linsert, $ind x $ilvl-- . "endcase";
	# 	push @linsert, $ind x $ilvl-- . "end";
	# 	push @linsert, $ind x $ilvl . "end";
	# 	push @$lref_wp, @linsert;    
    # };

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
		
		# write logic
        @ltemp = ();
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
            
			push @linsert, $ind x $ilvl++ ."else if (urac_wren_i && iaddr == ".$offs.") begin";
			push @linsert, $ind x $ilvl ."$key <= $key & ~wdata${rrange};";
			# foreach $key2 (keys %{$href_wp->{'write_sts_trg'}}) {
            #     # search for write trigger signal associated with status signal
			# 	if ($href_wp->{'write_sts_trg'}->{$key2} eq $key) {
            #         push @ltemp, $ind x ($ilvl-1) . "if (urac_wren_i && iaddr == ".$offs.") begin // write trigger for address $offs";
			# 		push @ltemp, $ind x $ilvl . "$key2 <= 1;";
            #         push @ltemp, $ind x ($ilvl-1) . "end";
            #         push @ltemp, $ind x ($ilvl-1) . "else begin";
            #         push @ltemp, $ind x $ilvl . "$key2 <= 0;";
            #         push @ltemp, $ind x ($ilvl-1) . "end";
			# 	};
			# };
			$ilvl--;
			push @linsert, $ind x $ilvl ."end";
            if (scalar(@ltemp)>0) {
                push @linsert, @ltemp;
                @ltemp = ();
            };
		};
		$ilvl --;
		push @linsert, $ind x $ilvl-- ."end";
		push @linsert, $ind x $ilvl-- ."end";
		push @$lref_wp, @linsert;
	};
};

# add standard logic constructs; adds to two lists: declarations and udc.
# performs text indentation/alignment only on udc lists.
sub _urac_rs_code_static_logic {
	my ($this, $o_domain, $clock, $href_shdw, $lref_decl, $lref_udc, $lref_checks) = @_;
	my $addr_msb = $this->global->{'addr_msb'};
	my $addr_lsb = $this->global->{'addr_lsb'};
	my (@ltemp);
	my $ind = $this->global->{'indent'};
	# my $href = $this->global->{'hclocks'}->{$clock};
    my $bus_clock = $this->_gen_clock_name($this->global->{'bus_clock'});
    my $int_rst_n = $this->global->{'bus_reset'} . $this->global->{'POSTFIX_PORT_IN'};
 
	#
	# insert wire/reg declarations
	#
	push @$lref_decl, "wire [".($addr_msb-$addr_lsb).":0] iaddr;";
    push @$lref_decl, "wire ".($this->_gen_vector_range($this->global->{'datawidth'}-1,0))." wdata;";
	
	#
	# insert static logic
	#
	@ltemp = ();

	push @ltemp, split("\n","
/*
  inputs
*/
assign iaddr = urac_addr_i[$addr_msb:$addr_lsb];
assign wdata = urac_data_i;

/* 
  read data output assignment
*/
always @(posedge $bus_clock or negedge $int_rst_n) begin
   if (~res_n_i)
     urac_dout_o <= 0;
   else
     if (urac_rden_i)
       urac_dout_o <= mux_rd_data;
end
");
	_pad_column(-1, $this->global->{'indent'}, 2, \@ltemp);

	push @$lref_udc, @ltemp;
};

# adds standard ports and connections to modules (bus i/f, handshake i/f, clocks, resets)
sub _urac_rs_add_static_connections {
	my ($this, $o_domain, $nclocks) = @_;
	my ($clock, $href, $n);
	my $bus_clock = $this->global->{'bus_clock'};
	my $bus_reset = $this->global->{'bus_reset'};
	my $dwidth = $this->global->{'datawidth'};
	my $awidth = $this->global->{'addrwidth'};
    my $top_inst = $this->global->{'top_inst'};

	$this->_add_input($bus_clock, 0, 0, "${top_inst}/${bus_clock}".$this->global->{'POSTFIX_PORT_IN'});
	$this->_add_input($bus_reset, 0, 0, "${top_inst}/${bus_reset}".$this->global->{'POSTFIX_PORT_IN'});
	$this->_add_input($this->_gen_unique_signal_top("urac_addr", $o_domain), $awidth-1, 0, "$top_inst/urac_addr_i");
	$this->_add_input($this->_gen_unique_signal_top("urac_data", $o_domain), $dwidth-1, 0, "$top_inst/urac_data_i");
	$this->_add_input($this->_gen_unique_signal_top("urac_wren", $o_domain), 0, 0, "$top_inst/urac_wren_i");
	$this->_add_input($this->_gen_unique_signal_top("urac_rden", $o_domain), 0, 0, "$top_inst/urac_rden_i");
	$this->_add_output($this->_gen_unique_signal_top("urac_dout", $o_domain), $dwidth-1, 0, 1, "$top_inst/urac_dout_o");
    
	# foreach $clock (sort keys %{$this->global->{'hclocks'}}) {
    #     if ($clock ne $bus_clock) {
    #         $href = $this->global->{'hclocks'}->{$clock};
    #         $this->_add_input($clock, 0, 0, $top_inst);
    #         $this->_add_input($href->{'reset'}, 0, 0, $top_inst);
    #     };
    # };

    # add some checking code for input ports to top-level module
    my @lchecks = ();
    my @ltemp;
    push @ltemp, ("urac_wren", "urac_rden");
   
    push @lchecks, 'parameter P_WAIT_IS_DRIVEN = 256;',
      'property is_driven(clk, rst_n, sig);',
        '  @(posedge clk) $rose(rst_n) |=> ##P_WAIT_IS_DRIVEN !$isunknown(sig);',
          'endproperty';
    foreach my $dft (@ltemp) {
        push @lchecks, "assert_${dft}_driven: assert property(is_driven(". $this->_gen_clock_name($bus_clock).", $bus_reset".$this->global->{'POSTFIX_PORT_IN'}.", ". $dft . $this->global->{'POSTFIX_PORT_IN'}.")) else \$error(\"ERROR: input port $dft is undriven after reset\");";
    };
    $this->_indent_and_prune_sva(\@lchecks);
    $this->_vgch_rs_write_udc($top_inst, \@lchecks);
};

# generate all instances for a register domain
# fills up the global->hclocks hash with data related to clock domains
sub _urac_rs_gen_hier {
	my($this, $o_domain, $nclocks) = @_;
	my @lgen_filter = ();
	my ($mcda_inst, $predec_inst);
    my @lchecks = ();

	# instantiate top-level module
	my $rs_name = $this->global->{'regshell_prefix'}."_".$this->_gen_dname($o_domain);
   
	my $top_inst = $this->_add_instance($rs_name, $this->global->{'virtual_top_instance'}, "Register shell for domain ".$o_domain->name);
	$this->global('top_inst' => $top_inst);
    $o_domain->{'top_inst'} = $top_inst; # store also in domain 
    # $o_domain->display();
	
	# _add_generic("P_DWIDTH", $this->global->{'datawidth'}, $top_inst);
	# _add_generic("P_AWIDTH", $this->global->{'addrwidth'}, $top_inst);
    _add_generic("P_MIX_SIG", $this->global->{'mix_signature'}, $top_inst);
	
	# do not generate library modules
	$eh->cappend('output.filter.file', join(",",@lgen_filter));

	return $top_inst;
};

# searches all clocks used in the register domain and stores the result in global->hclocks depending on 
# user settings; detects invalid configurations; collect some statistics per clock-domain;
# returns the number of clocks
sub _urac_rs_get_configuration {
	my $this = shift;
	my ($o_domain) = @_;
	my ($n, $o_field, $clock, $reset, %hclocks, %hresult, $offset);
	my $bus_clock = $this->global->{'bus_clock'};
	my ($addr_msb, $addr_lsb) = $this->_get_address_msb_lsb($o_domain);

	$this->global->{'addr_msb'} = $addr_msb;
	$this->global->{'addr_lsb'} = $addr_lsb;

	$n = 0;
	$clock = "";
    $this->global->{'rs_configuration'} = "scd-sync";

	# iterate all fields and retrieve clock names and other stuff
	foreach $o_field (@{$o_domain->fields}) {
		if ($this->_skip_field($o_field)) {
			next;
		};
		$clock = $o_field->attribs->{'clock'};
		$reset = $o_field->attribs->{'reset'};
		if ($clock  =~ m/(%OPEN%|%EMPTY%)/) {
			$clock = $bus_clock; # use default clock
		};
		if (!exists($hresult{$clock})) {
			$hresult{$clock} = {'reset' => $reset }; # store clock name as key in hash
			if ($clock eq $bus_clock) {
				$hresult{$clock}->{'sync'} = 0;
			}else {
				$hresult{$clock}->{'sync'} = 1;
                # if at least one clock is not the bus-clock, the configuration is asynchronous
                $this->global->{'rs_configuration'} = "scd-async";
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
			if ($this->global->{'field_naming'} !~ m/[DRBN]/) {
				_error("field name \'",$o_field->{'name'},"\' is defined more than once; correct this or use a naming scheme to differentiate (parameter reg_shell.field_naming)");
			};
		};
		# enter name in new data struct for checking
		$this->global->{'hfnames'}->{$o_field} = $o_field->name;
	};

	$this->global('hclocks' => \%hresult);
    
	# set the name of the register-shell configuration to multi-clock-domain if there more than one clock-domain
    if ($n>1) {
        $this->global->{'multi_clock_domains'} = 1; 
        $this->global->{'rs_configuration'} = "mcd";
    } else {
         $this->global->{'multi_clock_domains'} = 0; 
    };

    _info("determined register-shell configuration is \'" . ($this->global->{'rs_configuration'}) . "\'.");
	
	return $n;
};

1;
