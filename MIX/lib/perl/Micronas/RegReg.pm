###############################################################################
#  RCSId: $Id: RegReg.pm,v 1.17 2009/12/14 10:58:18 lutscher Exp $
###############################################################################
#
#  Related Files :  RegDomain.pm
#
#  Author(s)     :  Thorsten Lutscher
#
#  Project       :  MIX
#
#  Creation Date :  27.06.2005
#
#  Contents      :  Register class; contains register-level attributes and
#                   fields (named bit-slices) of the register 
#
###############################################################################
#                               Copyright
###############################################################################
#
#       Copyright (C) 2005 Trident Microsystems (Europe) GmbH, Germany
#
###############################################################################
#                                History
###############################################################################
#
#  $Log: RegReg.pm,v $
#  Revision 1.17  2009/12/14 10:58:18  lutscher
#  changed copyright
#
#  Revision 1.16  2009/11/19 12:26:25  lutscher
#  added top-level sheet input and vi2c-xml view
#
#  Revision 1.15  2009/08/27 08:31:30  lutscher
#  added functions
#
#  Revision 1.14  2008/12/10 13:11:37  lutscher
#  fixed bug in _pack functions
#
#  Revision 1.13  2008/10/29 15:05:55  lutscher
#  some changes to avoid numbers>32 bit
#
#  Revision 1.12  2008/10/27 13:18:13  lutscher
#  fixed bugs in packing and added packing.mode 32to16
#
#  Revision 1.11  2008/07/31 09:05:21  lutscher
#  added packing/unpacking feature for register-domains
#
#  Revision 1.10  2008/02/07 10:45:04  lutscher
#  some extensions for generated e-code
#
#  Revision 1.9  2007/11/22 09:36:07  mathias
#  Registers are now documented in the mif file when at least ome bitfield has to be visible.
#
#  Revision 1.8  2007-06-18 12:01:56  lutscher
#  added access method for id
#
#  Revision 1.7  2006/11/20 17:08:49  lutscher
#  changed get_reg_access_mode() to be consistent with register-master cell values
#
#  Revision 1.6  2006/07/25 13:21:28  mathias
#  fixed copy&paste bug in get_reg_init
#
#  Revision 1.5  2006-07-25 12:51:45  lutscher
#  fixed get_reg_init()
#
#  Revision 1.4  2005/11/25 16:01:48  mathias
#  added to_document()
#  which checks if the register should be visible in the documentation
#
#  Revision 1.3  2005/11/22 15:10:31  mathias
#  added new funcrion get_reg_access_mode()
#
#  Revision 1.2  2005/09/16 13:57:47  lutscher
#  added get_reg_init()
#
#  Revision 1.1  2005/07/07 12:35:26  lutscher
#  Reg: register space class; represents register space
#  of a device and contains register domains; also contains
#  most of the user API for dealing with register spaces.
#  Contains subclasses (see Reg.pm).
#
#  
###############################################################################

package Micronas::RegReg;

#------------------------------------------------------------------------------
# Used packages
#------------------------------------------------------------------------------
use strict;
use Data::Dumper;
use Micronas::RegField;
use Micronas::MixUtils::RegUtils;

#use FindBin qw($Bin);
#use lib "$Bin";
#use lib "$Bin/..";
#use lib "$Bin/lib";

#------------------------------------------------------------------------------
# Class members and constants
#------------------------------------------------------------------------------
our($debug) = 1;
our($VERSION) = '1.1';
our($_id) = 0; # incremental object id

#------------------------------------------------------------------------------
# Constructor
# returns a hash reference to the data members of this class
# package; does NOT call the subclass constructors.
# Input: 1. hash containing data members
#------------------------------------------------------------------------------

sub new {
	my $this = shift;
	my %params = @_; 

	# domain attributes hash
	
	# data member default values
	my $ref_member  = {
					   id => $_id,
					   name => "",
					   definition => "",
					   attribs => { 
								   size => 16,
								   usedbits => 2**16-1
								  },
					   fields => []             # list of hashes
					  };

	# init data members w/ parameters from constructor call
	foreach (keys %params) {
		$ref_member->{$_} = $params{$_};
	};
	$_id++;
	bless $ref_member, $this;
};

# Destructor
sub DESTROY { --$_id; };

#------------------------------------------------------------------------------
# Methods
#------------------------------------------------------------------------------

# scalar object data access method
sub name {
	my $this = shift;
	if (@_) { $this->{name} = shift @_; };
	return $this->{name};
};
# scalar object data access method
sub id {
	my $this = shift;
	if (@_) { $this->{id} = shift @_; };
	return $this->{id};
};
# scalar object data access method
sub definition {
	my $this = shift;
	if (@_) { $this->{definition} = shift @_; };
	return $this->{definition};
};
# hash object data access method
# input: none or attribute hash
sub attribs {
	my $this = shift;
	if (@_) { 
		my %hattribs = @_;
		foreach my $key (keys %hattribs) {
			$this->{attribs}->{$key} = $hattribs{$key};
		};
	};
	return $this->{attribs};
};

# add single field to the register or return ref. to list of field hashes
# input: none or hash describing the field mapping:
# field => ref. to field object
# pos   => position in register
sub fields {
	my $this = shift;
	if (@_) {
		my %hfield = @_;
		push @{$this->{fields}}, \%hfield;
	};
	return $this->{fields};
};

# retrieves the init value for a register from its fields
sub get_reg_init {
   my $this = shift;
   my $href;
   
   my $res = 0;
   my $init;
   foreach $href (@{$this->fields}) {
       my $mask = $href->{'field'}->attribs->{'size'} >= 32 ? 0xffffffff : ((2** ($href->{'field'}->attribs->{'size'})) - 1);
	   $init = $href->{'field'}->attribs->{'init'} & $mask;
       $res |= $init << $href->{'pos'};
   };
   return $res;
};

# retrieves the access mode (R, W, RW) for a register from its fields
sub get_reg_access_mode()
{
    my ($this) = @_;
    my $mode = "";

    foreach my $href (@{$this->fields}) {
        if ($mode eq "") {
            $mode = uc($href->{'field'}->attribs->{'dir'});
        } elsif ($mode ne uc($href->{'field'}->attribs->{'dir'})) {
            $mode = 'RW';
        }
    }
    return $mode;
}

# get the mask for all bits of a field (or undef if not found)
sub get_field_mask {
    my ($this, $o_field) = @_;
    my $result = undef;
    my $size = $o_field->attribs->{'size'};

    foreach my $href (@{$this->fields}) {
        if ($o_field == $href->{'field'}) {
            my $tmp = ($size + $href->{'pos'} >= 32) ? 0xffffffff : ((2** ($size + $href->{'pos'})) - 1);
            $result = $tmp & ~((2** $href->{'pos'})-1);
            last;
        };
    };

	return $result;
};

# create mask for all W1C fields of a register
sub _get_w1c_mask {
	my ($this) = @_;
	my $result=0;
	my $href;
 
	foreach $href (@{$this->fields}) {
		my $o_field = $href->{'field'};
        my $mask = $o_field->attribs->{'size'} >= 32 ? 0xffffffff : ((2** ($o_field->attribs->{'size'})) - 1);

		if ($o_field->attribs->{'spec'} =~ m/w1c/i) {
			$result |= $mask << $href->{'pos'};
		};
	};
	return $result;
};

# create mask for read-only bits of a register
sub _get_read_only_mask {
	my ($this) = @_;
	my $result=0;
	my $href;
	foreach $href (@{$this->fields}) {
		my $o_field = $href->{'field'};
        my $mask = $o_field->attribs->{'size'} >= 32 ? 0xffffffff : ((2** ($o_field->attribs->{'size'})) - 1);
		if (lc($o_field->attribs->{'dir'}) eq "r")  {
			$result |= $mask << $href->{'pos'};
		};
	};
	return $result;
};


# checks if framemaker documentation should be generated for this register
# returns true when at least one bitfield should be documented (view == 'Y')
sub to_document()
{
    my ($this) = @_;
    my $mode = "N";

    foreach my $href (@{$this->fields}) {
        if (uc($href->{field}->attribs->{view}) eq 'Y') {
            $mode = 'Y';
            last;
        }
    }
    return ($mode eq 'Y');
}

# unpack 64-bit register to two 32-bit registers
sub _pack_64to32 {
    my ($this) = shift;
    my ($postfix_lo, $postfix_hi) = @_;
    my ($o_reg0, $o_reg1, $href, %hattribs, $o_field0, $o_field1, $is_splitted);
    
    if ($this->attribs->{'size'} != 64) {
        _error("_pack_64to32() register size ",$this->attribs->{'size'}, " does not match requested packing mode");
    } else {
        $is_splitted = 0;
        %hattribs = %{$this->attribs};
        foreach $href (@{$this->fields}) {
            my $o_field = $href->{'field'};
            if ($href->{'pos'} < 32) {
                if (!ref($o_reg0)) {
                    $o_reg0 = Micronas::RegReg->new('name' => $this->name . $postfix_lo, 'definition' => $this->definition . $postfix_lo);
                    $o_reg0->attribs(%hattribs);
                    $o_reg0->attribs('size' => 32); # correct size
                };
                # check if field does not fit into lower 32-bit range
                if ($href->{'pos'} + $o_field->attribs->{'size'} > 32) {
                    # split field  
                    _info("field \'", $o_field->name, "\' of register \'", $this->name, "\' is not 32-bit aligned, will be splitted");
                    ($o_field0, $o_field1) = $o_field->_split_at(32-$href->{'pos'});
                    if (ref $o_field0 and ref $o_field1) {
                        $o_field0->reg($o_reg0);
                        $o_reg0->fields(field => $o_field0, pos => $href->{'pos'});
                        if (!ref($o_reg1)) {
                            $o_reg1 = Micronas::RegReg->new(name => $this->name . $postfix_hi, definition => $this->definition . $postfix_hi);
                            $o_reg1->attribs(%hattribs);
                            $o_reg1->attribs('size' => 32); # correct size
                        };
                        $o_field1->reg($o_reg1);
                        $o_reg1->fields(field => $o_field1, pos => 0);
                    } else {
                        _error("failed to split field \'", $o_field->name, "\' of register \'", $this->name, "\'");
                    };
                } else {
                    # add the old field to the new register
                    $o_field->reg($o_reg0);
                    $o_reg0->fields(field => $o_field, pos => $href->{'pos'});
                };
            } else {
                # fit field into upper 32-bit range
                $is_splitted = 1;
                if (!ref($o_reg1)) {
                    $o_reg1 = Micronas::RegReg->new(name => $this->name . $postfix_hi, definition => $this->definition . $postfix_hi);
                    $o_reg1->attribs(%hattribs);
                    $o_reg1->attribs('size' => 32); # correct size
                };
                # add the field to the new register
                $o_field->reg($o_reg1);
                $o_reg1->fields(field => $o_field, pos => $href->{'pos'} - 32);
            };
        };
    };
    # if the register fits into the lower range, use the old name w/o postfixing
    if (!$is_splitted) { $o_reg0->name($this->name) };
    return ($o_reg0, $o_reg1);
};

# unpack 32-bit register to two 16-bit registers
sub _pack_32to16 {
    my ($this) = shift;
    my ($postfix_lo, $postfix_hi) = @_;
    my ($o_reg0, $o_reg1, $href, %hattribs, $o_field0, $o_field1, $is_splitted);
    
    if ($this->attribs->{'size'} != 32) {
        _error("_pack_32to16() register size ",$this->attribs->{'size'}, " does not match requested packing mode");
    } else {
        $is_splitted = 0;
        %hattribs = %{$this->attribs};
        foreach $href (@{$this->fields}) {
            my $o_field = $href->{'field'};
            if ($href->{'pos'} < 16) {
                if (!ref($o_reg0)) {
                    $o_reg0 = Micronas::RegReg->new('name' => $this->name . $postfix_lo, 'definition' => $this->definition . $postfix_lo);
                    $o_reg0->attribs(%hattribs);
                    $o_reg0->attribs('size' => 16); # correct size
                };
                # check if field does not fit into lower 16-bit range
                if ($href->{'pos'} + $o_field->attribs->{'size'} > 16) {
                    # split field  
                    _info("field \'", $o_field->name, "\' of register \'", $this->name, "\' is not 16-bit aligned, will be splitted");
                    ($o_field0, $o_field1) = $o_field->_split_at(16-$href->{'pos'});
                    if (ref $o_field0 and ref $o_field1) {
                        $o_field0->reg($o_reg0);
                        $o_reg0->fields(field => $o_field0, pos => $href->{'pos'});
                        $is_splitted = 1;
                        if (!ref($o_reg1)) {
                            $o_reg1 = Micronas::RegReg->new(name => $this->name . $postfix_hi, definition => $this->definition . $postfix_hi);
                            $o_reg1->attribs(%hattribs);
                            $o_reg1->attribs('size' => 16); # correct size
                        };
                        $o_field1->reg($o_reg1);
                        $o_reg1->fields(field => $o_field1, pos => 0);
                    } else {
                        _error("failed to split field \'", $o_field->name, "\' of register \'", $this->name, "\'");
                    };
                } else {
                    # add the old field to the new register
                    $o_field->reg($o_reg0);
                    $o_reg0->fields(field => $o_field, pos => $href->{'pos'});
                };
            } else {
                # fit field into upper 16-bit range
                $is_splitted = 1;
                if (!ref($o_reg1)) {
                    $o_reg1 = Micronas::RegReg->new(name => $this->name . $postfix_hi, definition => $this->definition . $postfix_hi);
                    $o_reg1->attribs(%hattribs);
                    $o_reg1->attribs('size' => 16); # correct size
                };
                # add the field to the new register
                $o_field->reg($o_reg1);
                $o_reg1->fields(field => $o_field, pos => $href->{'pos'} - 16);
            };
        };
    };
    # if the register fitted into the lower range, use the old name w/o postfixing
    if (!$is_splitted) { $o_reg0->name($this->name) };
    return ($o_reg0, $o_reg1);
};

# delete a matching field-object from the register
# returns number of deleted fields
sub del_field {
     my ($this, $o_field_del) = @_;
     my $result = 0;
     my $i=0;
     foreach my $href (@{$this->fields}) {
         my $o_field = $href->{'field'};
         if ($o_field == $o_field_del) {
             splice @{$this->fields}, $i, 1;
             $result ++;
         };
         $i++;
     };

     return $result;
 };


# default display method
sub display {
	my $this = shift;
	my $dump  = Data::Dumper->new([$this]);
	$dump->Maxdepth($debug == 1 ? 5 : 3);
	$dump->Sortkeys(1);
	print $dump->Dump;
};

1;
