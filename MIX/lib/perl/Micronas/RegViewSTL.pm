###############################################################################
#  RCSId: $Id: RegViewSTL.pm,v 1.10 2008/01/23 14:54:33 lutscher Exp $
###############################################################################
#
#  Revision      : $Revision: 1.10 $                                  
#
#  Related Files :  Reg.pm
#
#  Author(s)     :  Thorsten Lutscher                                      
#  Email         :  thorsten.lutscher@micronas.com                          
#
#  Project       :  MIX                                                 
#
#  Creation Date :  18.11.2005
#
#  Contents      :  Generate STL stimuli file for register testing from Reg 
#                   object
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
#  $Log: RegViewSTL.pm,v $
#  Revision 1.10  2008/01/23 14:54:33  lutscher
#  fixed a bug in read-all-ones
#
#  Revision 1.9  2008/01/23 13:23:57  lutscher
#  fixed read-back for read-only regs
#
#  Revision 1.8  2008/01/23 10:03:57  lutscher
#  added read-only registers to read-tests
#
#  Revision 1.7  2007/03/05 18:28:30  lutscher
#  no changes
#
#  Revision 1.6  2006/03/14 14:21:19  lutscher
#  made changes for new eh access and logger functions
#
#  Revision 1.5  2006/02/28 11:34:39  lutscher
#  no changes
#
#  Revision 1.4  2005/11/29 15:00:29  lutscher
#  added clearing of data between domains
#
#  Revision 1.3  2005/11/29 08:45:55  lutscher
#  RegViewSTL.pm
#
#  Revision 1.2  2005/11/25 13:32:22  lutscher
#  first functional release
#
#  Revision 1.1  2005/11/23 13:31:17  lutscher
#  initial release, not yet functional
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
# view: STL

# Main entry function of this module;
# input: domain names for which STL files are generated; if omitted, 
# STL file will consider ALL register space domains in the Reg object;
# output: 0 in case of non-recoverable error, 1 otherwise
sub _gen_view_stl {
	my $this = shift;
	my $href;
	my @lexclude_regs;

	# extend class data with data structure needed for code generation
	$this->global(
				  'debug'              => 0,
				  'indent'             => "    ",       # indentation character(s)
				  'pragma_head_start'  => "pragma MIX_STL head begin",
				  'pragma_head_end'    => "pragma MIX_STL head end",
				  'pragma_body_start'  => "pragma MIX_STL body begin",
				  'pragma_body_end'    => "pragma MIX_STL body end",
				  'file_suffix'        => "stl",
				  'header'             => "
# Socket Transaction Language file
# automatically generated by MIX (module RegViewSTL.pm)
# note: do not change code enveloped by MIX_STL pragmas, it will be overwritten by script next time!

version 2.0

",
				  # internal static data structs
				  'hclocks'        => {},           # for storing per-clock-domain information
				  'hfnames'        => {},           # for storing field names
				  'lbody'          => [],
				  'ldomains'       => [],
				  'lexclude_cfg'   => [],
				  'lexclude_other' => []
				 );
	
	# import regshell.<par> parameters from MIX package to class data; user can change these parameters in mix.cfg
	my $param;
	my @lmixparams = ('reg_shell.bus_clock', 
					  'reg_shell.bus_reset', 
					  'reg_shell.addrwidth', 
					  'reg_shell.datawidth',
					  'reg_shell.stl.initial_idle',
					  'reg_shell.stl.exclude_regs',
					  'reg_shell.stl.use_base_addr'
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

	# make list of domains for generation
	if (scalar (@_)) {
		foreach my $domain (@_) {
			push @{$this->global->{'ldomains'}}, $this->find_domain_by_name_first($domain);
		};
	} else {
		foreach $href (@{$this->domains}) {
			push @{$this->global->{'ldomains'}}, $href->{'domain'};
		};
	};

	my ($o_domain, $o_field, $o_reg, $usedbits, $reg, $reg_offset, %hregs, $mask, $dwidth, $val, $def_val);
	# list of skipped  registers
	if (exists($this->global->{'exclude_regs'})) {
		@{$this->global->{'lexclude_cfg'}} = split(/\s*,\s*/,$this->global->{'exclude_regs'}); 
	};
	$dwidth = $this->global->{'datawidth'};
	# iterate through all register domains
	foreach $o_domain (@{$this->global->{'ldomains'}}) {
		_info("generating code for domain ", $o_domain->name);
		
		%hregs = ();
		$this->global->{'lexclude_other'} = [];
		$this->global->{'lbody'} = [];

		# perform some filtering and pre-processing on the domain registers
		foreach $o_reg ( sort { $o_domain->get_reg_address($a) <=> $o_domain->get_reg_address($b) } @{$o_domain->regs}) {
			# $o_reg->display() if $this->global->{'debug'}; # debug
			$reg = $o_reg->name;
			$reg_offset = $o_domain->get_reg_address($o_reg);
			if (grep($_ eq $reg, @{$this->global->{'lexclude_cfg'}})) {
				next;
			};
			my $has_usr = 0;
			# iterate through all fields of the register
			foreach $href (@{$o_reg->fields}) {
				$o_field = $href->{'field'};
				if($o_field->attribs->{'spec'} =~ m/usr/i) {
					$has_usr = 1;
					last;
				};
			};
			# exclude USR registers
			if ($has_usr) {
				push @{$this->global->{'lexclude_other'}}, $reg;
				next;
			};
			# add base address to register offset if desired
			if ($this->global->{'use_base_addr'}) {
				$reg_offset += $this->get_domain_baseaddr($o_domain->{'name'});
			};
			$hregs{$reg_offset} = $o_reg;
		};
		
		push @{$this->global->{'lbody'}}, "
#
# read back reset values
#
";
		foreach $reg_offset (sort {$a <=> $b} keys %hregs) {
			$o_reg = $hregs{$reg_offset};
			# $usedbits = $o_reg->attribs->{'usedbits'};
			$mask = $this->_get_read_write_mask($o_reg) | $this->_get_w1c_mask($o_reg);
			$def_val = $o_reg->get_reg_init;
			$this->_ocp_access("read", $o_reg, $reg_offset, $def_val, $mask);
		};

		push @{$this->global->{'lbody'}}, "
#
# write all ones
#
";
		foreach $reg_offset (sort {$a <=> $b} keys %hregs) {
			$o_reg = $hregs{$reg_offset};
			$mask = "";
			$val = (2**$dwidth)-1;
			$this->_ocp_access("write", $o_reg, $reg_offset, $val, $mask);
		};

		push @{$this->global->{'lbody'}}, "
#
# read all ones
#
";
		foreach $reg_offset (sort {$a <=> $b} keys %hregs) {
			$o_reg = $hregs{$reg_offset};
            $def_val = $o_reg->get_reg_init & $this->_get_read_only_mask($o_reg);
			$val = ((2**$dwidth)-1) & ~$this->_get_read_only_mask($o_reg);
			$mask = $this->_get_read_write_mask($o_reg);
			$this->_ocp_access("read", $o_reg, $reg_offset, $val | $def_val, $mask);
		};

		push @{$this->global->{'lbody'}}, "
#
# write all zeros
#
";
		foreach $reg_offset (sort {$a <=> $b} keys %hregs) {
			$o_reg = $hregs{$reg_offset};
			$mask = "";
			$val = 0;
			$this->_ocp_access("write", $o_reg, $reg_offset, $val, $mask);
		};

		push @{$this->global->{'lbody'}}, "
#
# read all zeros
#
";
		foreach $reg_offset (sort {$a <=> $b} keys %hregs) {
			$o_reg = $hregs{$reg_offset};
            $def_val = $o_reg->get_reg_init & $this->_get_read_only_mask($o_reg);
			$val = 0;
			$mask = $this->_get_read_write_mask($o_reg);
			$this->_ocp_access("read", $o_reg, $reg_offset, $val | $def_val, $mask);
		};		

		$this->_write_stl($o_domain);
	};
	$this->display() if $this->global->{'debug'}; # dump Reg class object

    # disable mix error message

    # return to mix
	1;
};

# create mask for read-writable and read-only bits of a register
# write-only and W1C fields are read back as 0 or unknown, so read-write mask is 0 for them
sub _get_read_write_mask {
	my ($this, $o_reg) = @_;
	my $result=0;
	my $href;
	foreach $href (@{$o_reg->fields}) {
		my $o_field = $href->{'field'};
		if ($o_field->attribs->{'dir'} =~ m/r/i and $o_field->attribs->{'spec'} !~ m/w1c/i) {
			$result |= ((2**$o_field->attribs->{'size'})-1) << $href->{'pos'};
		};
	};
	return $result;
};

# create mask for read-only bits of a register
sub _get_read_only_mask {
	my ($this, $o_reg) = @_;
	my $result=0;
	my $href;
	foreach $href (@{$o_reg->fields}) {
		my $o_field = $href->{'field'};
		if (lc($o_field->attribs->{'dir'}) eq "r")  {
			$result |= ((2**$o_field->attribs->{'size'})-1) << $href->{'pos'};
		};
	};
	return $result;
};

# create mask for all W1C fields of a register
sub _get_w1c_mask {
	my ($this, $o_reg) = @_;
	my $result=0;
	my $href;
	foreach $href (@{$o_reg->fields}) {
		my $o_field = $href->{'field'};
		if ($o_field->attribs->{'spec'} =~ m/w1c/i) {
			$result |= ((2**$o_field->attribs->{'size'})-1) << $href->{'pos'};
		};
	};
	return $result;
};

# create mask for all write-only fields of a register
sub _get_write_only_mask {
	my ($this, $o_reg) = @_;
	my $result=0;
	my $href;
	foreach $href (@{$o_reg->fields}) {
		my $o_field = $href->{'field'};
		if ($o_field->attribs->{'spec'} =~ m/w/i and $o_field->attribs->{'spec'} !~ m/r/i) {
			$result |= ((2**$o_field->attribs->{'size'})-1) << $href->{'pos'};
		};
	};
	return $result;
};

# generate a line in STL syntax
# for reads, the value is the expected value;
# mask (used for reads) can be left empty; if a mask is given, only the bits that are 1 are compared with the expected value;
# if all bits of the mask are 0, do not execute the read (is probably a write-only register)
sub _ocp_access {
	my ($this, $access, $o_reg, $addr, $value, $mask) = @_;
	my $addr_str = "0x"._val2hex($this->global->{'addrwidth'}, $addr);
	my $value_str = "0x"._val2hex($this->global->{'datawidth'}, $value);
	my $mask_str = "";
	if ($mask ne "") {
		$mask_str = "(0x"._val2hex($this->global->{'datawidth'}, $mask) .")";
		if ($access eq "read" and $mask == 0) {
			return;
		};
	};
	push @{$this->global->{'lbody'}}, "# register: " . $o_reg->name . " (" .$o_reg->get_reg_access_mode(). ")";
	push @{$this->global->{'lbody'}}, join(" ", $access, $addr_str, $value_str, $mask_str);
};

# generate STL file (for one domain)
# uses existing file if there is one in the current dir
sub _write_stl {
	my ($this, $o_domain) = @_;
	my (@lresult);

	my $fname = "regtest_" . $o_domain->{'name'} . "." . $this->global->{'file_suffix'};

	if (-e "$fname") {
		_info("reading existing file \'$fname\'");
		if (!_attach_file_to_list($fname, \@lresult)) {
			_error("could not open file \'$fname\' for reading");
			return 0;
		};
	} else {
		_info("creating new file \'$fname\'");
		# create an empty file
		push @lresult, "# ---- ". $this->global->{'pragma_head_start'};
		push @lresult, "# ---- ". $this->global->{'pragma_head_end'} , "";
		push @lresult, "# ---- ". $this->global->{'pragma_body_start'};
		push @lresult, "# ---- ". $this->global->{'pragma_body_end'}, "";
	};
	
	# insert a header
	$this->_gen_stl_head($o_domain, \@lresult);

	# insert the body
	$this->_gen_stl_body(\@lresult);

	# write the new file
	if (!open(DHANDLE, ">$fname")) {
		_error("could not open file \'$fname\' for writing");
		return 0;
	} else {
		print DHANDLE  join("\n", @lresult), "\n";
		close(DHANDLE);
	};
	1;
};

# generate the file body
sub _gen_stl_body {
	my ($this, $lref) = @_;
	my @ltemp;

	my $pragma_start_pos = _get_pragma_pos($this->global->{'pragma_body_start'}, $lref);
	my $pragma_end_pos   = _get_pragma_pos($this->global->{'pragma_body_end'}, $lref);
	if ($pragma_start_pos == -1 or $pragma_end_pos == -1) {
		_warning("no pragmas found, skipping file body insertion");
		return 1;
	};
	push @ltemp, "", join("\n", @{$this->global->{'lbody'}}), "";
	splice @$lref, $pragma_start_pos + 1, $pragma_end_pos - $pragma_start_pos - 1, @ltemp;
	1;
};

# generate the file header
sub _gen_stl_head {
	my($this, $o_domain, $lref) = @_;
	my @ltemp;

	my $pragma_start_pos = _get_pragma_pos($this->global->{'pragma_head_start'}, $lref);
	my $pragma_end_pos   = _get_pragma_pos($this->global->{'pragma_head_end'}, $lref);
	if ($pragma_start_pos == -1 or $pragma_end_pos == -1) {
		_warning("no pragmas found, skipping file header insertion");
		return 1;
	};
	push @ltemp, split("\n", $this->global->{'header'}), "";
	push @ltemp, "# register test for domain ". $o_domain->name, "";
	if(scalar(@{$this->global->{'lexclude_cfg'}})) {
		push @ltemp, "# exclude registers via user setting : ". join(", ",@{$this->global->{'lexclude_cfg'}}), "";
	};
	if(@{$this->global->{'lexclude_other'}}) {
		push @ltemp, "# exclude registers via internal rule: ". join(", ",@{$this->global->{'lexclude_other'}}), "";
	};
	push @ltemp, "idle ".$this->global->{'initial_idle'},"";
	splice @$lref, $pragma_start_pos + 1, $pragma_end_pos - $pragma_start_pos - 1, @ltemp;
	1;
};

1;
