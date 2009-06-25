###############################################################################
#  RCSId: $Id: RegOOUtils.pm,v 1.1 2009/06/25 15:10:14 lutscher Exp $
###############################################################################
#                                  
#  Related Files :  Reg.pm
#
#  Author(s)     :  Thorsten Lutscher                                      
#  Email         :  thorsten.lutscher@tridentmicro.com                          
#
#  Project       :  MIX                                                 
#
#  Creation Date :  22.06.2009
#
#  Contents      :  Utility member functions of the Reg class; they are mostly (but
#                   not only) used for RTL code generation;
#                   note: the global (non-oo) functions are in MixUtils/RegUtils.pm 
#
#   sub _indent_and_prune_sva 
#   sub _skip_field
#   sub _get_address_msb_lsb
#   sub _get_rrange
#   sub _get_frange
#   sub _get_field_clock_and_reset 
#   sub _add_instance
#   sub _add_instance_unique 
#   sub _gen_fname
#   sub _gen_vector_range
#   sub _gen_unique_signal_name 
#   sub _gen_unique_signal_top
#   sub _gen_cond_rhs 
#   sub _add_input
#   sub _add_output
#   sub _add_conn
#   sub _gen_clock_name
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
#  $Log: RegOOUtils.pm,v $
#  Revision 1.1  2009/06/25 15:10:14  lutscher
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
use Micronas::Reg;

#------------------------------------------------------------------------------
# Methods
# First parameter passed to method is implicit and is the object reference 
# ($this) if the method # is called in <object> -> <method>() fashion.
#------------------------------------------------------------------------------

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
	my($msb, $lsb, $o_ref, $i);
   
    $lsb = 0;
    my $o_addrmap = $o_domain->get_addrmap_by_name($o_domain->{default_addrmap}); # note: uses default addressmap
    
	# determine lsb of address
	for ($i=0; $i<=4; $i++) {
		if($this->global->{'datawidth'} <= (8,16,32,64,128)[$i]) {
		   $lsb = $i;
		   last;
	   };
	};

    # determine msb of address
	$msb = $lsb;
	foreach $o_ref (@{$o_addrmap->nodes}) {
		while(($o_ref->offset * $o_addrmap->granularity) > 2**($msb+1)-1) {
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
		_error("field \'",$o_field->name,"\' exceeds datawidth (pos=",$pos," size=",$size,")");
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
	if ($fclock =~ m/(%OPEN%|%EMPTY%)/) {
		$fclock = $last_clock; # use last clock
	};
	if ($fclock eq "") {
		$fclock = $rclock;
	} elsif ($last_clock ne ""  and $last_clock ne $fclock) {
		_warning("field \'",$o_field->name,"\' has a different clock than other field(s) in this register");
	}
	my $freset = $o_field->attribs->{'reset'};
	if ($freset =~ m/(%OPEN%|%EMPTY%)/) {
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

# shell for _add_connection/_add_primary_input primitives
sub _add_input {
    my ($this, $name, $msb, $lsb, $destination) = @_;
    
    if ($this->global->{'virtual_top_instance'} eq "testbench") {
        _add_primary_input($name, $msb, $lsb, $destination);
    } else {
        my $postfix = "%POSTFIX_PORT_IN%";
        #if ($name !~ m/\%POSTFIX_/g) {
        #    $name .= $postfix; # add postfix only if not already there
        #};
        my ($dest, @ldest);
        foreach $dest (split(/,\s*/, $destination)) {
            if ($dest !~ m/\//) {
                push @ldest, $destination."/".$name.$postfix; # add portname+postfix if destination is not specified
            } else {
                push @ldest, $destination;
            };
        };
        _add_connection($name, $msb, $lsb, "", join(",", @ldest));
    };
};

# shell for _add_primary_output primitives
sub _add_output {
    my ($this, $name, $msb, $lsb, $is_reg, $source) = @_;
    my $type = $is_reg ? "'reg":"'wire";
    my $postfix = "%POSTFIX_PORT_OUT%";

    if ($this->global->{'virtual_top_instance'} eq "testbench") {
        _add_primary_output($name, $msb, $lsb, $is_reg, $source);
    } else {
        #if ($name !~ m/\%POSTFIX_/g) {
        #    $name .= $postfix; # add postfix only if not already there
        #};
        my ($src, @lsrc);
        foreach $src (split(/,\s*/, $source)) {
            if ($source !~ m/\//) {
                push @lsrc, $source."/".$name.$postfix; # add portname+postfix if source is not specified
            } else {
                push @lsrc, $source;
            };
        };
        _add_connection($name, $msb, $lsb, join(",",  map {$_ .= $type} @lsrc), "");
    }; 
};

# shell for _add_connection primitive
sub _add_conn {
    my ($this, $name, $msb, $lsb, $source, $destination) = @_;
    _add_connection($name, $msb, $lsb, $source, $destination);
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
# input: type = [in|in_usr|out|s|set|shdw|usr_trans_done|trg]
# o_field = ref to field object or string (taken as name);
# no_postfix = if 1, do not add postfix macro (default is 0); use this to create signal names
sub _gen_fname {
	my ($this, $type, $o_field, $no_postfix);
    $no_postfix = 0;
    ($this, $type, $o_field, $no_postfix) = @_;
	my ($name, $reg_name, $id, $block);

    if (ref($o_field) =~ m/RegField$/) {
        # get field name from global struct
        if (exists($this->global->{'hfnames'}->{$o_field})) {
            $name = $this->global->{'hfnames'}->{$o_field};
        } else {
            $name = $o_field->name; # take original name
            # _info("internal info: field name \'", $name, "\' not found in global struct");
        }
        $id = $o_field->id;
        $reg_name =  $o_field->reg->name;
        $block = $o_field->attribs->{'block'};
    } else {
        # if the passed parameter is not an object
        $name = $o_field;
        $id = "";
        $reg_name = "";
        $block = "";
    };

    my $naming_scheme = $this->global->{'field_naming'};
	# prefix field name with register name
	if ($this->global->{'use_reg_name_as_prefix'}) {
        _warning("use of parameter \'reg_shell.use_reg_name_as_prefix\' is deprecated, use \'reg_shell.field_naming\' instead");
        $naming_scheme = "%R_" . $naming_scheme;
	};
    # apply naming scheme
    $name = _clone_name($naming_scheme, 99, $id, $this->global->{'current_domain'}->name, $reg_name, $name, $block);

    # attach postfixes/macros according to type of field
	if ($type eq "in") {
		$name .= "_par"."%POSTFIX_PORT_IN%"; # "%POSTFIX_FIELD_IN%";
    } elsif ($type eq "in_usr") { 
        # needed to avoid name-clash for rw usr fields
        $name .= "_in_par"."%POSTFIX_PORT_IN%";# "%POSTFIX_FIELD_IN%";
	} elsif ($type eq "out") {
		$name .= "_par"."%POSTFIX_PORT_OUT%"; # "%POSTFIX_FIELD_OUT%";
    } elsif ($type eq "s") {
        $name .= "%POSTFIX_SIGNAL%";
	} elsif ($type eq "set") {
		$name .= $this->global->{'set_postfix'}."%POSTFIX_PORT_IN%";
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

    # strip postfix macro if desired by caller
    if ($no_postfix) {
        $name =~ s/%POSTFIX_[A-Z_]+%$//;
    };
	return $name;
};

# function to generate the domain name in the output views
sub _gen_dname {
    my ($this, $o_domain) = @_;
    return _clone_name($this->global->{'domain_naming'}, 99, $o_domain->{'id'}, $o_domain->name)
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

	if (scalar(@{$this->domains}) == 1 and ($this->global->{'multi_clock_domains'} == 0 or scalar(keys %{$this->global->{'hclocks'}})==1)) {
        return $signal_name;
    } else {
        return (exists($href->{$inst_key}) ? $href->{$inst_key} . "_" . $signal_name : $signal_name);
    };
};

# generate unique name for signals depending on domain in case the top-level is not "testbench"
sub _gen_unique_signal_top {
    my ($this, $signal_name, $o_domain) = @_;
    
    if ($this->global->{'virtual_top_instance'} ne "testbench") {
        return join("_", $this->_gen_dname($o_domain), $signal_name);
    } else {
        return $signal_name;
    };
};

# function to generate the right-hand-side statement (RHS) for an assignment that used the cond_slice() function;
# value is a string with the original RHS which will be wrapped in the function call;
# the first argument to cond_slice() is an integer parameter; if the parameter is < 0, the function returns the
# 2nd parameter. If the parameter is >=0, the function returns the parameter itself
sub _gen_cond_rhs {
	my ($this, $href_params, $o_field, $value) = @_;
	my $res_val = $value;

	my $parname = "P__".uc($this->_gen_fname("",$o_field));
	if($o_field->is_cond()) {
		$res_val = "cond_slice($parname, $value)";
		$href_params->{$parname} = -1; # default value -1
	};
	return $res_val;
};

1;
