###############################################################################
#  RCSId: $Id: RegViewRDL.pm,v 1.5 2009/12/14 10:58:18 lutscher Exp $
###############################################################################
#
#  Revision      : $Revision: 1.5 $                                  
#
#  Related Files :  Reg.pm
#
#  Author(s)     :  Thorsten Lutscher                                                             
#
#  Project       :  MIX                                                 
#
#  Creation Date :  13.02.2006
#
#  Contents      :  Create a Denali RDL representation of the Reg object 
#                   This is EXPERIMENTAL only !!
#        
###############################################################################
#                               Copyright
###############################################################################
#
#       Copyright (C) 2006 Trident Microsystems (Europe) GmbH, Germany
#
###############################################################################
#                                History
###############################################################################
#
#  $Log: RegViewRDL.pm,v $
#  Revision 1.5  2009/12/14 10:58:18  lutscher
#  changed copyright
#
#  Revision 1.4  2009/06/15 11:57:26  lutscher
#  added addrmaps member to Reg and RegDomain
#
#  Revision 1.3  2008/04/01 09:19:29  lutscher
#  changed parameter list of main methods
#
#  Revision 1.2  2006/03/14 14:21:19  lutscher
#  made changes for new eh access and logger functions
#
#  Revision 1.1  2006/02/28 11:33:59  lutscher
#  initial release (experimental)
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
use Micronas::RegViews;
use Micronas::MixUtils::RegUtils;

#------------------------------------------------------------------------------
# Private methods (of class Reg)
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# view: STL
# Main entry function of this module;
# input: view-name, list ref. to domain names for which output is generated; if empty, 
# will consider ALL register space domains in the Reg object;
# output: 0 in case of non-recoverable error, 1 otherwise
sub _gen_view_rdl {
	my $this = shift;
    my ($view_name, $lref_domains) = @_;
	# extend class data with data structure needed for code generation
	$this->global(
				  'debug'              => 0,
				  'indent'             => "    ",       # indentation character(s)
				  'pragma_head_start'  => "pragma MIX_RDL head begin",
				  'pragma_head_end'    => "pragma MIX_RDL head end",
				  'pragma_body_start'  => "pragma MIX_RDL body begin",
				  'pragma_body_end'    => "pragma MIX_RDL body end",
				  'pragma_foot_start'  => "pragma MIX_RDL foot begin",
				  'pragma_foot_end'    => "pragma MIX_RDL foot end",
				  'file_suffix'        => "rdl",
				  'header'             => "
/* Denali Register Description Language file
   automatically generated by MIX
   note: do not change code enveloped by MIX_RDL pragmas, it will be overwritten by script next time!
*/
",
				  # internal static data structs
				  'lbody'          => [],
				  'laddrmap'       => [],
				  'ldomains'       => []
				 );

	# import regshell.<par> parameters from MIX package to class data; user can change these parameters in mix.cfg
	my $param;
	my @lmixparams = ('reg_shell.bus_clock', 
					  'reg_shell.bus_reset', 
					  'reg_shell.addrwidth', 
					  'reg_shell.datawidth'
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

	my ($o_domain, $o_field, $o_reg, $usedbits, $reg, $reg_offset, %hregs, $mask, $dwidth, $val, $href, $ilvl);

	# check over which domains we want to iterate
	if (scalar (@$lref_domains)) {
		foreach my $domain (@$lref_domains) {
			push @{$this->global->{'ldomains'}}, $this->find_domain_by_name_first($domain);
		};
	} else {
		foreach $href (@{$this->domains}) {
			push @{$this->global->{'ldomains'}}, $href;
		};
	};

	$ilvl=1;
	# iterate through all register domains
	foreach $o_domain (@{$this->global->{'ldomains'}}) {
		_info("generating code for domain ", $o_domain->name);
		$this->global->{'lbody'} = [];
		
		# iterate through all domain registers
		foreach $o_reg ( sort { $o_domain->get_reg_address($a) <=> $o_domain->get_reg_address($b) } @{$o_domain->regs}) {
			# $o_reg->display() if $this->global->{'debug'}; # debug
			$reg = $o_reg->name;
			$reg_offset = $o_domain->get_reg_address($o_reg);
			push @{$this->global->{'laddrmap'}}, "$reg ${reg}_i \@0x"._val2hex($this->global->{'addrwidth'}, $reg_offset).";";
			push @{$this->global->{'lbody'}}, $this->global->{'indent'} x $ilvl++ . "reg ${reg} {";

			# iterate through all fields of the register
			foreach $href (@{$o_reg->fields}) {
				$o_field = $href->{'field'};
				push @{$this->global->{'lbody'}}, $this->global->{'indent'} x $ilvl++ . "field {";
				my $access = lc($o_field->attribs->{'dir'});
				my $res_val = sprintf("0x%x", $o_field->attribs->{'init'});
				my $rrange = $this->_get_rrange($href->{'pos'}, $o_field);
				my $comment = $o_field->attribs->{'comment'};
				$this->_rdl_format_comment(\$comment);
				# access properties
				if($access =~ m/rw/i) {
					push @{$this->global->{'lbody'}}, $this->global->{'indent'} x $ilvl . "sw = rw; hw = r;";
					if ($o_field->attribs->{'spec'} =~ m/w1c/i) {
						push @{$this->global->{'lbody'}}, $this->global->{'indent'} x $ilvl . "woclr = true;";
					};
				} elsif($access =~ m/r/i) {
					push @{$this->global->{'lbody'}}, $this->global->{'indent'} x $ilvl . "sw = r; hw = w;";
				} elsif($access =~ m/w/i) {
					push @{$this->global->{'lbody'}}, $this->global->{'indent'} x $ilvl . "sw = w; hw = r;";
				};
				# reset value
				push @{$this->global->{'lbody'}}, $this->global->{'indent'} x $ilvl . "reset = $res_val;";
				# clock and reset signal
				#push @{$this->global->{'lbody'}}, $this->global->{'indent'} x $ilvl . "resetsignal = ". $o_field->attribs->{'reset'} . ";";
				#$this->global->{'hresets'} = $o_field->attribs->{'reset'}
				#push @{$this->global->{'lbody'}}, $this->global->{'indent'} x $ilvl . "clock = ".$o_field->attribs->{'clock'} . ";";
				# description
				push @{$this->global->{'lbody'}}, $this->global->{'indent'} x $ilvl . "desc = \"$comment\";";
				$ilvl--;
				push @{$this->global->{'lbody'}}, $this->global->{'indent'} x $ilvl . "} ". $o_field->name . "$rrange;";
			};
			$ilvl--;
			push @{$this->global->{'lbody'}}, $this->global->{'indent'} x $ilvl . "};", "";
		};
		$this->_write_rdl($o_domain);
	};
	
};

# convert the comment from spreadsheet
sub _rdl_format_comment {
	my ($this, $ref) = @_;
	$$ref =~ s/\\[xb]//g;
};

# generate RDL file (for one domain)
# uses existing file if there is one in the current dir
sub _write_rdl {
	my ($this, $o_domain) = @_;
	my (@lresult);

	my $fname = $o_domain->{'name'} . "." . $this->global->{'file_suffix'};

	if (-e "$fname") {
		_info("reading existing file \'$fname\'");
		if (!_attach_file_to_list($fname, \@lresult)) {
			_error("could not open file \'$fname\' for reading");
			return 0;
		};
	} else {
		_info("creating new file \'$fname\'");
		# create an empty file
		push @lresult, "// ---- ". $this->global->{'pragma_head_start'};
		push @lresult, "// ---- ". $this->global->{'pragma_head_end'} , "";
		push @lresult, "// ---- ". $this->global->{'pragma_body_start'};
		push @lresult, "// ---- ". $this->global->{'pragma_body_end'}, "";
		push @lresult, "// ---- ". $this->global->{'pragma_foot_start'};
		push @lresult, "// ---- ". $this->global->{'pragma_foot_end'}, "";	};

	# insert a header
	$this->_gen_rdl_head($o_domain, \@lresult);

	# insert the body
	$this->_gen_rdl_body(\@lresult);

	# insert the footer
	$this->_gen_rdl_footer($o_domain, \@lresult);

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
sub _gen_rdl_body {
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
sub _gen_rdl_head {
	my($this, $o_domain, $lref) = @_;
	my @ltemp;

	my $pragma_start_pos = _get_pragma_pos($this->global->{'pragma_head_start'}, $lref);
	my $pragma_end_pos   = _get_pragma_pos($this->global->{'pragma_head_end'}, $lref);
	if ($pragma_start_pos == -1 or $pragma_end_pos == -1) {
		_warning("no pragmas found, skipping file header insertion");
		return 1;
	};
	push @ltemp, split("\n", $this->global->{'header'}), "";
	push @ltemp, "// addressmap for domain ". $o_domain->name, "";
	push @ltemp, "addrmap ". $o_domain->name . "{";
	splice @$lref, $pragma_start_pos + 1, $pragma_end_pos - $pragma_start_pos - 1, @ltemp;
	1;
};

# generate the footer
sub _gen_rdl_footer {
	my($this, $o_domain, $lref) = @_;
	my @ltemp;
	my $line;

	my $pragma_start_pos = _get_pragma_pos($this->global->{'pragma_foot_start'}, $lref);
	my $pragma_end_pos   = _get_pragma_pos($this->global->{'pragma_foot_end'}, $lref);
	if ($pragma_start_pos == -1 or $pragma_end_pos == -1) {
		_warning("no pragmas found, skipping file header insertion");
		return 1;
	};
	push @ltemp, $this->global->{'indent'} . "alignment = ". ($this->global->{'datawidth'}/8) . ";";
	foreach $line (@{$this->global->{'laddrmap'}}) {
		push @ltemp, $this->global->{'indent'} . $line;
	};
	push @ltemp, "};","";

	splice @$lref, $pragma_start_pos + 1, $pragma_end_pos - $pragma_start_pos - 1, @ltemp;
	1;
};

1;
