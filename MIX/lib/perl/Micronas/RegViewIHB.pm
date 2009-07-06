###############################################################################
#  RCSId: $Id: RegViewIHB.pm,v 1.4 2009/07/06 09:03:20 lutscher Exp $
###############################################################################
#
#  Revision      : $Revision: 1.4 $                                  
#
#  Related Files :  Reg.pm, RegOOUtils.pm
#
#  Author(s)     :  Thorsten Lutscher                                      
#  Email         :  thorsten.lutscher@tridentmicro.com                          
#
#  Project       :  MIX                                                 
#
#  Creation Date :  25.06.2009
#
#  Contents      :  Functions to create IHB HDL register space views
#                   from Reg class object
#   Functions:
#   sub _gen_view_ihb_rs 
#   sub _ihb_rs_init
#   sub _ihb_rs_gen_hier
#   sub _ihb_rs_get_configuration
#   sub _ihb_rs_add_static_connections
#
###############################################################################
#                               Copyright
###############################################################################
#
#       Copyright (C) 2009 Trident Microsystems (Europe) , Munich, Germany 
#
#     All rights reserved. Reproduction in whole or part is prohibited
#          without the written permission of the copyright owner.
#
###############################################################################
#                                History
###############################################################################
#
#  $Log: RegViewIHB.pm,v $
#  Revision 1.4  2009/07/06 09:03:20  lutscher
#  changed to always generate generic for has_ecs
#
#  Revision 1.3  2009/07/06 08:20:25  lutscher
#  fixed typo
#
#  Revision 1.2  2009/07/02 12:43:40  lutscher
#  added ihb bus checker instance generation
#
#  Revision 1.1  2009/06/25 15:49:08  lutscher
#  initial release
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
use Micronas::RegOOUtils;
use Micronas::MixUtils::RegUtils;
use Micronas::RegViews; # we use some methods from this package that are not bus-protocol dependent

#------------------------------------------------------------------------------
# Private methods (of class Reg)
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# view: hdl-ihb-rs

# Main entry function; generate data structures for the MIX Parser for Register 
# shell generation;
# input: view-name, list ref. to domain names for which register shells are generated; if empty, 
# register shells for ALL register space domains in the Reg object are generated
# output: 0 in case of non-recoverable error, 1 otherwise
sub _gen_view_ihb_rs {
	my $this = shift;
    my ($view_name, $lref_domains) = @_;
	my @ldomains;
	my $href;
	my $o_domain;
    
    # initialise some config variables
    $this->_ihb_rs_init();

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
	if ($this->global->{'read_pipeline_lvl'} > 0 and $this->global->{'read_multicycle'} >0) {
		$this->global->{'read_multicycle'} = 0;
		_info("parameter \'read_multicycle\' is ignored because read-pipelining is enabled");
	};

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

	my ($o_field, $o_reg, $top_inst, $ihb_inst, $n_clocks, $cfg_inst, $clock);

	# iterate through all register domains and generate one register-shell per domain
	foreach $o_domain (@ldomains) {
		_info("generating code for domain ",$o_domain->name);
		$o_domain->display() if $this->global->{'debug'};
        $this->global('current_domain' => $o_domain);

		# reset per-domain data structures
        $this->global('hfnames' => {}, 'hclocks' => {}, 'hhdlconsts' => {}, 'hbackdoorpaths' => {}, 'rs_configuration' => "");
        delete $this->global->{'embedded_reg'};
		map {delete $this->global->{$_}} grep $_ =~ m/_inst$/i,keys %{$this->global};

		$n_clocks = $this->_ihb_rs_get_configuration($o_domain); # get some general information

		($top_inst, $ihb_inst) = $this->_ihb_rs_gen_hier($o_domain, $n_clocks); # generate module hierarchy

		$this->_ihb_rs_add_static_connections($o_domain, $n_clocks);# add all standard ports and connections 
		
		# iterate through all clock domains
		foreach $clock (keys %{$this->global->{'hclocks'}}) {
			my @ludc  = ();
			$href     = $this->global->{'hclocks'}->{$clock};
			$cfg_inst = $href->{'cfg_inst'};
			$this->_vgch_rs_gen_cfg_module($o_domain, $clock, \@ludc); # generate config module for clock domain
			$this->_vgch_rs_write_udc($cfg_inst, \@ludc); # add user-defined-code to config module instantation
		};
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
sub _ihb_rs_init {
    my $this =  shift;

   	# extend class data with data structure needed for code generation
	$this->global(
                  'mix_signature'      => "\"M1\"",     # signature for cross-checking MIX software version and IP version
				  'ihb_target_name'    => "ihb_target_0002", # library module name
                  'ihb_checker_name'   => "ihb_target_m_checker", # library module name
				  'mcda_name'          => "rs_mcda_0002",    # library module name
                  'rtl_libs'           => [{            # required MSD RTL libraries
                                            "project" => "ip_ocp",
                                            "version" => "0002",
                                            "release" => "ip_ocp_018_13Feb2009", # BAUSTELLE need new release with unit ihb_target
                                           },
                                           {
                                            "project" => "ip_sync",
                                            "version" => "0001",
                                            "release" => "ip_sync_006_23jan2008"
                                           }
                                          ],  
                  'set_postfix'        => "_set_p",     # postfix for interrupt-set input signal
				  'scan_en_port_name'  => "test_en",    # name of test-enable input
				  'clockgate_te_name'  => "scan_shift_enable", # name of input to connect with test-enable port of clock-gating cell
				  'embedded_reg_name'  => "RS_CTLSTS",  # reserved name of special register embedded in ocp_target
				  'field_spec_values'  => ['sha', 'w1c', 'usr'], # recognized values for spec attribute
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
                      'reg_shell.enforce_unique_addr',
                      'reg_shell.infer_reset_syncer',
                      'reg_shell.field_naming',
                      'reg_shell.domain_naming',
                      'reg_shell.virtual_top_instance',
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
    if (not defined($eh->mix_get_module_info("RegViewIHB"))) {
        $eh->mix_add_module_info("RegViewIHB", '$Revision: 1.4 $ ', "Utility functions to create IHB HDL register space view from Reg class object");
    };
};

# generate all instances for a register domain
# fills up the global->hclocks hash with data related to clock domains
sub _ihb_rs_gen_hier {
	my($this, $o_domain, $nclocks) = @_;
	my($clock, $bus_clock, $cfg_inst, $sg_inst, $sr_inst, $ihb_sync, $cgw_inst, $cgs_inst, $cgr_inst, $n, $sync_clock);
	my $refclks = $this->global->{'hclocks'};
	my $infer_cg = $this->global->{'infer_clock_gating'};
	my @lgen_filter = ();
	my ($mcda_inst, $predec_inst);
    my @lchecks = ();

	# instantiate top-level module
	my $rs_name = $this->global->{'regshell_prefix'}."_".$this->_gen_dname($o_domain);
   
	my $top_inst = $this->_add_instance($rs_name, $this->global->{'virtual_top_instance'}, "Register shell for domain ".$o_domain->name);
	$this->global('top_inst' => $top_inst);
    $o_domain->{'top_inst'} = $top_inst; # store also in domain 
    # $o_domain->display();

    if ($infer_cg) {
		_add_generic("cgtransp", 0, $top_inst);
	};
	# _add_generic("P_TOCNT_WIDTH", 10, $top_inst); # timeout counter width
	
	# instantiate IHB target
	my $ihb_inst = $this->_add_instance_unique($this->global->{"ihb_target_name"}, $top_inst, "IHB target module");
	$this->global('ihb_inst' => $ihb_inst);
	$eh->cappend('output.filter.file', $ihb_inst);
	
	_add_generic("P_DWIDTH", $this->global->{'datawidth'}, $ihb_inst);
	_add_generic("P_AWIDTH", $this->global->{'addrwidth'}, $ihb_inst);
    _add_generic("P_MIX_SIG", $this->global->{'mix_signature'}, $ihb_inst);
    if ($this->global->{'rs_configuration'} eq "scd-sync") {       
        _add_generic("hs_type", "\"ACTHIGH\"", $ihb_inst);
    };

	# _add_generic_value("P_TOCNT_WIDTH", 10, "P_TOCNT_WIDTH", $ihb_inst); # timeout counter width
	if(exists($this->global->{'embedded_reg'})) {
		# enable embedded control/status register in ihb_target 
		_add_generic("has_ecs", 1, $ihb_inst);
		my $ecs_addr = $o_domain->get_reg_address($this->global->{'embedded_reg'});
		_add_generic("P_ECSADDR", $ecs_addr, $ihb_inst);
		_add_generic("p_def_val", $this->global->{'ecs_def_val'}, $ihb_inst);
		_add_generic("p_def_ien", $this->global->{'ecs_def_ien'}, $ihb_inst);
        _add_generic("p_ecs_writable", $this->global->{'ecs_writable'}, $ihb_inst); # NEW
	} else {
        _add_generic("has_ecs", 0, $ihb_inst);
    };

	$ihb_sync = 0;

    # instantiate IHB master checker if configured
    my $ihb_checker_inst;
    if ($this->global->{'infer_sva'} and ($this->global->{"ihb_checker_name"} ne "")) {
        my $udc="/%PINS%/\`ifdef ASSERT_ON
// synopsys translate_off
/%AINS%/ // synopsys translate_on
\`endif";
        $ihb_checker_inst = $this->_add_instance_unique($this->global->{"ihb_checker_name"}, $top_inst, "IHB master checker module", $udc);
        $this->global('ihb_checker_inst' => $ihb_checker_inst);
        _add_generic("P_DWIDTH", $this->global->{'datawidth'}, $ihb_checker_inst);
        _add_generic("P_AWIDTH", $this->global->{'addrwidth'}, $ihb_checker_inst);
        $eh->cappend('output.filter.file', $ihb_checker_inst);
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
			$cfg_inst = $this->_add_instance(join("_",$this->global->{"regshell_prefix"}, $this->global->{'cfg_module_prefix'}, $this->_gen_dname($o_domain), $clock), $top_inst, "Config register module for clock domain \'$clock\'");
			if (!exists($this->global->{'mcda_inst'})) { 
				$ihb_sync = 1; # IHB target needs synchronizer if no MCDA is instantiated
			};
		} else {
			# synchronous config register module
			$cfg_inst = $this->_add_instance(join("_",$this->global->{"regshell_prefix"}, $this->global->{'cfg_module_prefix'}, $this->_gen_dname($o_domain)), $top_inst, "Config register module");
			$sync_clock = $n;
			if(exists($this->global->{'mcda_inst'})) {
				_add_generic("N_SYNCDOM", $sync_clock, $mcda_inst);
			};
		};
		# link clock domain to config register module
		$refclks->{$clock}->{'cfg_inst'} = $cfg_inst; # store in global->hclocks
		_add_generic("sync", $refclks->{$clock}->{'sync'}, $cfg_inst);
       
        # instantiate synchronizer for trans_start input (need unique instance names because MIX has flat namespace)
        $sg_inst = $this->_add_instance_unique("sync_generic", $cfg_inst, "Synchronizer for trans_start signal");
        $refclks->{$clock}->{'sg_inst'} = $sg_inst; # store in global->hclocks
        if ($this->global->{'rs_configuration'} ne "scd-sync") {       
            _add_generic("kind", 2, $sg_inst);
            _add_generic_value("sync", 0, "sync", $sg_inst);
        } else {
            # in configuration scd-sync, the synchronizer is set to bypass-mode and of type pulse
            _add_generic("kind", 0, $sg_inst);
            _add_generic("sync", 0, $sg_inst);
        };
        _add_generic("act", 1, $sg_inst);
        _add_generic("rstact", 0, $sg_inst);
        _add_generic("rstval", 0, $sg_inst);
        push @lgen_filter, $sg_inst;
        
        # instantiate reset synchronizer
        $sr_inst = $this->_add_instance_unique("sync_rst", $cfg_inst, "Reset synchronizer".($this->global->{'infer_reset_syncer'} ? "" : " (in bypass-mode)"));
        $refclks->{$clock}->{'sr_inst'} = $sr_inst; # store in global->hclocks
        if ($this->global->{'infer_reset_syncer'}) {                
            _add_generic_value("sync", 0, "sync", $sr_inst);
        } else {
            _add_generic("sync", 0, $sr_inst); # set  reset synchronizer to bypass mode
        };
        _add_generic("act", 0, $sr_inst);
        push @lgen_filter, $sr_inst;

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
	_add_generic("sync", $ihb_sync, $ihb_inst);

    # add logic to pre_dec module (it is only a big address decoder which is hopefully reduced by synthesis tool) 
    if(exists($this->global->{'mcda_inst'})) {
        $this->_vgch_rs_gen_pre_dec_logic($o_domain, $predec_inst);
    };

	# do not generate library modules
	$eh->cappend('output.filter.file', join(",",@lgen_filter));

	return ($top_inst, $ihb_inst);
};


# searches all clocks used in the register domain and stores the result in global->hclocks depending on 
# user settings; detects invalid configurations; collect some statistics per clock-domain;
# gets reset values for embedded control/status register;# returns the number of clocks
sub _ihb_rs_get_configuration {
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
    $this->global->{'rs_configuration'} = "scd-sync";

	# iterate all fields and retrieve clock names and other stuff
	foreach $o_field (@{$o_domain->fields}) {
		# get default values of embedded reg
		if ($o_field->name eq "rs_ien") {
			$ien = $o_field->attribs->{'init'};
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
			if ($this->global->{'field_naming'} !~ m/[DRBN]/) {
				_error("field name \'",$o_field->{'name'},"\' is defined more than once; correct this or use a naming scheme to differentiate (parameter reg_shell.field_naming)");
			};
		};
		# enter name in new data struct for checking
		$this->global->{'hfnames'}->{$o_field} = $o_field->name;
	};

	# store def. values of embedded reg in global
	$this->global('ecs_def_val' => $val,
				  'ecs_def_ien' => $ien,
                  'ecs_writable' => $ecs_writable);

	# if more than one clocks in the domain but MCD feature is off, delete all clocks other than the bus_clock
	if ($n>1 and !$this->global->{'multi_clock_domains'}) {
		my @lkeys = keys %hresult;
		foreach $clock (@lkeys) {
			if ($clock ne $bus_clock) {
                # save some properties before deleting the clock-domain (TBD maybe not complete)
                foreach my $property ("has_shdw", "has_read", "has_write", "has_cond_fields") {
                    if (exists($hresult{$clock}->{$property})) {
                        $hresult{$bus_clock}->{$property} = $hresult{$clock}->{$property};
                    };
                };
				delete $hresult{$clock};
				$n--;
			};
		};
		if($n <= 0) {
			_error("parameter \'multi_clock_domains\' is disabled but multiple clocks are in the design; one of them MUST be clock \'$bus_clock\' as defined by parameter \'bus_clock\'; contact support if in doubt");
		};
	};
	$this->global('hclocks' => \%hresult);

	# set the name of the register-shell configuration to multi-clock-domain if there is still more than one clock-domain left
    if ($n>1) {
        $this->global->{'rs_configuration'} = "mcd";
    };
    _info("determined register-shell configuration is \'" . ($this->global->{'rs_configuration'}) . "\'.");

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

# adds standard ports and connections to modules (IHB i/f, handshake i/f, clocks, resets)
sub _ihb_rs_add_static_connections {
	my ($this, $o_domain, $nclocks) = @_;
	my $ihb_i = $this->global->{'ihb_inst'};
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

	$this->_add_input($bus_clock, 0, 0, "${ihb_i}/clk_i");
	$this->_add_input($bus_reset, 0, 0, "${ihb_i}/reset_n_i");
	$this->_add_input($this->_gen_unique_signal_top("sreset_n", $o_domain), 0, 0, "$ihb_i/sreset_n_i");
	$this->_add_input($this->_gen_unique_signal_top("ihb_sel_n", $o_domain), 0, 0, "$ihb_i/ihb_sel_n_i");
	$this->_add_input($this->_gen_unique_signal_top("ihb_rdwr_n", $o_domain), 0, 0, "$ihb_i/ihb_rdwr_n_i");
	$this->_add_input($this->_gen_unique_signal_top("ihb_addr", $o_domain), $awidth-1, 0, "$ihb_i/ihb_addr_i");
	$this->_add_input($this->_gen_unique_signal_top("ihb_wdata", $o_domain), $dwidth-1, 0, "$ihb_i/ihb_wdata_i");
	$this->_add_input($this->_gen_unique_signal_top("ihb_rxrdy", $o_domain), 0, 0, "$ihb_i/ihb_rxrdy_i");
	$this->_add_output($this->_gen_unique_signal_top("ihb_wr_trdy_n", $o_domain), 0, 0, 0, "$ihb_i/ihb_wr_trdy_n_o");
	$this->_add_output($this->_gen_unique_signal_top("ihb_rd_trdy_n", $o_domain), 0, 0, 0, "$ihb_i/ihb_rd_trdy_n_o");
	$this->_add_output($this->_gen_unique_signal_top("ihb_rd_end", $o_domain), 0, 0, 0, "$ihb_i/ihb_rd_end_o");
	$this->_add_output($this->_gen_unique_signal_top("ihb_rdata", $o_domain), $dwidth-1, 0, 0, "$ihb_i/ihb_rdata_o");
	if(exists($this->global->{'embedded_reg'})) {
		$this->_add_output($this->_gen_unique_signal_top("ihb_irq", $o_domain), 0, 0, 0, "$ihb_i/ihb_irq_o");
	} else {
		$this->_add_conn("%OPEN%", 0, 0, "${ihb_i}/ihb_irq_o", "");
	};
    _tie_input_to_constant("${ihb_i}/wr_err_i", 0, 0, 0); # wr_err input not used
    

    if (exists ($this->global->{'ihb_checker_inst'})) {
        my $ihbc_i = $this->global->{'ihb_checker_inst'};
        $this->_add_input($bus_clock, 0, 0, "${ihbc_i}/clk_i");
        $this->_add_input($bus_reset, 0, 0, "${ihbc_i}/reset_n_i");
        $this->_add_input($this->_gen_unique_signal_top("sreset_n", $o_domain), 0, 0, "$ihbc_i/sreset_n_i");
        $this->_add_input($this->_gen_unique_signal_top("ihb_sel_n", $o_domain), 0, 0, "$ihbc_i/ihb_sel_n_i");
        $this->_add_input($this->_gen_unique_signal_top("ihb_rdwr_n", $o_domain), 0, 0, "$ihbc_i/ihb_rdwr_n_i");
        $this->_add_input($this->_gen_unique_signal_top("ihb_addr", $o_domain), $awidth-1, 0, "$ihbc_i/ihb_addr_i");
        $this->_add_input($this->_gen_unique_signal_top("ihb_wdata", $o_domain), $dwidth-1, 0, "$ihbc_i/ihb_wdata_i");
        $this->_add_input($this->_gen_unique_signal_top("ihb_rxrdy", $o_domain), 0, 0, "$ihbc_i/ihb_rxrdy_i");
        $this->_add_conn($this->_gen_unique_signal_top("ihb_wr_trdy_n", $o_domain), 0, 0, "$ihbc_i/ihb_wr_trdy_n_i");
        $this->_add_conn($this->_gen_unique_signal_top("ihb_rd_trdy_n", $o_domain), 0, 0, "$ihbc_i/ihb_rd_trdy_n_i");
        $this->_add_conn($this->_gen_unique_signal_top("ihb_rdata", $o_domain), $dwidth-1, 0, "$ihbc_i/ihb_rdata_i");
        $this->_add_conn($this->_gen_unique_signal_top("ihb_rd_end", $o_domain), 0, 0, "$ihbc_i/ihb_rd_end_i");
        _tie_input_to_constant("${ihbc_i}/ihb_wr_end_i", 0, 0, 0); # not used here
        if(exists($this->global->{'embedded_reg'})) {
            $this->_add_conn($this->_gen_unique_signal_top("ihb_irq", $o_domain), 0, 0, "$ihbc_i/ihb_irq_i");
        } else {
            _tie_input_to_constant("${ihbc_i}/ihb_irq_i", 0, 0, 0); # not used here
        };
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
		$this->_add_input($clock, 0, 0, $cfg_i);
		$this->_add_input($href->{'reset'}, 0, 0, $cfg_i);
        
        $this->_add_input($clock, 0, 0, "${sg_i}/clk_r");
        $this->_add_input($href->{'reset'}, 0, 0, "${sg_i}/rst_r");
        _tie_input_to_constant("${sg_i}/clk_s", 0, 0, 0);
        _tie_input_to_constant("${sg_i}/rst_s", 0, 0, 0);
        $this->_add_conn($trans_start_p, 0, 0, "${sg_i}/rcv_o", "");
        
        $this->_add_input($clock, 0, 0, "${sr_i}/clk_r");
        $this->_add_input($href->{'reset'}, 0, 0, "${sr_i}/rst_i");
        # the scan-enable input is only needed for the reset-synchronizer
        if ($this->global->{'infer_reset_syncer'}) { 
            $this->_add_input($this->global->{'scan_en_port_name'}, 0, 0, "$sr_i/test_i");
        } else {
            _tie_input_to_constant("${sr_i}/test_i", 0, 0, 0);
        };
        $this->_add_conn($int_rst_n, 0, 0, "${sr_i}/rst_o", "");
        
		$this->_add_conn($this->_gen_unique_signal_top("addr", $o_domain),  $awidth-1, 0, "${ihb_i}/addr_o", "${cfg_i}/addr_i");
		$this->_add_conn($this->_gen_unique_signal_top("wr_data", $o_domain), $dwidth-1, 0, "${ihb_i}/wr_data_o", "${cfg_i}/wr_data_i");
		$this->_add_conn($this->_gen_unique_signal_top("rd_wr", $o_domain), 0, 0, "${ihb_i}/rd_wr_o", "${cfg_i}/rd_wr_i");

		if (!defined $mcda_i) {
            $this->_add_conn($this->_gen_unique_signal_top("trans_start", $o_domain), 0, 0, "${ihb_i}/trans_start_o", "$sg_i/snd_i");
			$this->_add_conn($this->_gen_unique_signal_top("rd_err", $o_domain), 0, 0, "${cfg_i}/rd_err_o", "${ihb_i}/rd_err_i");
			$this->_add_conn($this->_gen_unique_signal_top("trans_done", $o_domain), 0, 0, "${cfg_i}/trans_done_o", "${ihb_i}/trans_done_i");
			$this->_add_conn($this->_gen_unique_signal_top("rd_data", $o_domain), $dwidth-1, 0, "${cfg_i}/rd_data_o", "${ihb_i}/rd_data_i");
		} else {
			# connect config register block to MCDA
            $this->_add_conn($this->_gen_unique_signal_top("trans_start_$n", $o_domain), 0, 0, "${mcda_i}/trans_start_vec_o($n)=(0)", "$sg_i/snd_i");
			$this->_add_conn($this->_gen_unique_signal_top("rd_data_vec", $o_domain), $dwidth*$nclocks-1, 0, "$cfg_i/rd_data_o=(".(($n+1)*$dwidth-1).":".($n*$dwidth).")", "$mcda_i/rd_data_vec_i");
			$this->_add_conn($this->_gen_unique_signal_top("rd_err_vec", $o_domain),  $nclocks-1, 0, "$cfg_i/rd_err_o=($n)", "$mcda_i/rd_err_vec_i");
			# $this->_add_conn("%OPEN%", 0, 0, "${cfg_i}/rd_err_o", ""); # rd_err now driven by pre-decoder module
            $this->_add_conn($this->_gen_unique_signal_top("trans_done_vec", $o_domain), $nclocks-1, 0, "$cfg_i/trans_done_o=($n)", "$mcda_i/trans_done_vec_i");
		};
		if (exists $href->{'cg_write_inst'}) {
			$this->_add_input($this->_gen_unique_signal_top($this->global->{'clockgate_te_name'}, $o_domain), 0, 0, $href->{'cg_write_inst'}."/test_i");
			$this->_add_input($clock, 0, 0, $href->{'cg_write_inst'}."/clk_i");
			$this->_add_conn($wr_clk_en, 0, 0, "", $href->{'cg_write_inst'}."/enable_i");
			$this->_add_conn($wr_clk, 0, 0, $href->{'cg_write_inst'}."/clk_o", "");
		};
		if (exists $href->{'cg_shdw_inst'}) {
			$this->_add_input($this->_gen_unique_signal_top($this->global->{'clockgate_te_name'}, $o_domain), 0, 0, $href->{'cg_shdw_inst'}."/test_i");
			$this->_add_input($clock, 0, 0, $href->{'cg_shdw_inst'}."/clk_i");
			$this->_add_conn($shdw_clk_en, 0, 0, "", $href->{'cg_shdw_inst'}."/enable_i");
			$this->_add_conn($shdw_clk, 0, 0, $href->{'cg_shdw_inst'}."/clk_o", "");
		};
		if (exists $href->{'cg_read_inst'}) {
			$this->_add_input($this->_gen_unique_signal_top($this->global->{'clockgate_te_name'}, $o_domain), 0, 0, $href->{'cg_read_inst'}."/test_i");
			$this->_add_input($clock, 0, 0, $href->{'cg_read_inst'}."/clk_i");
			$this->_add_conn($rd_clk_en, 0, 0, "", $href->{'cg_read_inst'}."/enable_i");
			$this->_add_conn($rd_clk, 0, 0, $href->{'cg_read_inst'}."/clk_o", "");
		};
		$n++; # count the config register blocks
	};
	
	# connect MCDA
	if (defined $mcda_i) {
		$this->_add_input($bus_clock, 0, 0, "${mcda_i}/clk_ocp");
		$this->_add_input($this->_gen_unique_signal_top("sreset_n", $o_domain), 0, 0, "$mcda_i/mreset_n_i");
		$this->_add_input($bus_reset, 0, 0, "${mcda_i}/rst_ocp_n_i");
		$this->_add_conn($this->_gen_unique_signal_top("trans_start", $o_domain), 0, 0, "${ihb_i}/trans_start_o", "$mcda_i/trans_start_i");
		$this->_add_conn($this->_gen_unique_signal_top("trans_done", $o_domain), 0, 0, "$mcda_i/trans_done_o", "${ihb_i}/trans_done_i");
		$this->_add_conn($this->_gen_unique_signal_top("rd_err", $o_domain), 0, 0, "${mcda_i}/rd_err_o", "${ihb_i}/rd_err_i");
		$this->_add_conn($this->_gen_unique_signal_top("rd_data", $o_domain), $dwidth-1, 0, "${mcda_i}/rd_data_o", "${ihb_i}/rd_data_i");
        # connect pre-decoder
        $this->_add_conn($this->_gen_unique_signal_top("addr", $o_domain),  $awidth-1, 0, "${ihb_i}/addr_o", "${predec_i}/addr_i");
        # connect MCDA and pre-decoder
        $this->_add_conn($this->_gen_unique_signal_top("pre_dec", $o_domain), _bitwidth($nclocks)-1, 0, "${predec_i}/pre_dec_o", "${mcda_i}/pre_dec_i");
        $this->_add_conn($this->_gen_unique_signal_top("pre_dec_err", $o_domain), 0, 0, "${predec_i}/pre_dec_err_o", "${mcda_i}/pre_dec_err_i");
        
	};

    # add some checking code for input ports to top-level module
    my @lchecks = ();
    my $dft;
    my @ltemp;
    if ($this->global->{'infer_reset_syncer'}) { 
        push @ltemp, $this->global->{'scan_en_port_name'};
    };
    if ($this->global->{'infer_clock_gating'} and (exists $href->{'cg_write_inst'} or exists $href->{'cg_shdw_inst'} or exists $href->{'cg_read_inst'})) {
        push @ltemp, $this->global->{'clockgate_te_name'};
    };
    if (scalar(@ltemp)>0) {
        $this->_vgch_rs_gen_udc_header(\@lchecks);
        push @lchecks, 'parameter P_WAIT_IS_DRIVEN = 256;',
        'property is_driven(clk, rst_n, sig);',
        '  @(posedge clk) $rose(rst_n) |=> ##P_WAIT_IS_DRIVEN !$isunknown(sig);',
        'endproperty';
        foreach $dft (@ltemp) {
            push @lchecks, "assert_${dft}_driven: assert property(is_driven(". $this->_gen_clock_name($bus_clock).", $bus_reset".$this->global->{'POSTFIX_PORT_IN'}.", ". $dft . $this->global->{'POSTFIX_PORT_IN'}.")) else \$error(\"ERROR: input port $dft is undriven after reset\");";
        };
        $this->_indent_and_prune_sva(\@lchecks);
        $this->_vgch_rs_write_udc($top_inst, \@lchecks);
    };
};



1;
