###############################################################################
#  RCSId: $Id: RegDomain.pm,v 1.3 2007/08/10 08:41:21 lutscher Exp $
###############################################################################
#                                  
#  Related Files :  Reg.pm
#
#  Author(s)     :  Thorsten Lutscher                                      
#  Email         :  thorsten.lutscher@micronas.com                          
#
#  Project       :  MIX                                                 
#
#  Creation Date :  27.06.2005
#
#  Contents      :  Register domain class; represents a sub-address space and
#                   contains domain-level attributes, registers, fields, and 
#                   address mapping of registers
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
#  $Log: RegDomain.pm,v $
#  Revision 1.3  2007/08/10 08:41:21  lutscher
#  o some fixes for the case that the register space contains more than one domain
#  o store some cloning information in the domain and the cloned fields
#
#  Revision 1.2  2006/01/18 13:05:57  lutscher
#  added find_reg_by_address_all()
#
#  Revision 1.1  2005/07/07 12:35:26  lutscher
#  Reg: register space class; represents register space
#  of a device and contains register domains; also contains
#  most of the user API for dealing with register spaces.
#  Contains subclasses (see Reg.pm).
#
#  
###############################################################################

package Micronas::RegDomain;

#------------------------------------------------------------------------------
# Used packages
#------------------------------------------------------------------------------
use strict;
use Data::Dumper;
use Micronas::MixUtils::RegUtils;

#use FindBin qw($Bin);
#use lib "$Bin";
#use lib "$Bin/..";
#use lib "$Bin/lib";

#------------------------------------------------------------------------------
# Class members and constants
#------------------------------------------------------------------------------
our($debug) = 0;
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
					   addrmap => [],                    # ref. to list of hashes
					   regs => [],
					   fields => [],
                       clone => {
                                 'number' => 0
                                }                      # cloning information
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
sub definition {
	my $this = shift;
	if (@_) { $this->{definition} = shift @_; };
	return $this->{definition};
};
# add single address mapping to hash
# input: none or hash describing register mapping:
# reg => ref. to register
# offset => sub-address/offset of register in domain
sub addrmap {
	my $this = shift;
	if (@_) {
		my %hamap = @_;
		push @{$this->{addrmap}}, \%hamap;
	};
	return $this->{addrmap};
};

# ref. object data access method
sub regs {
	my $this = shift;
	if (@_) { 
		push @{$this->{regs}}, @_;
	};
	return $this->{regs};
};
# ref. object data access method
sub fields {
	my $this = shift;
	if (@_) { 
		push @{$this->{fields}}, @_;
	};
	return $this->{fields};
};
# ref. object data access method
sub clone {
	my $this = shift;
	if (@_) { 
		%{$this->{clone}} = @_;
	};
	return $this->{clone};
};

# finds first register object in address map at given address and returns the object (or undef)
# input: sub-address in domain
sub find_reg_by_address_first {
	my ($this, $offset) = @_;
	my ($result) = (grep ($_->{offset} == $offset, @{$this->addrmap}))[0];
	if (ref($result)) {
		return $result->{reg};
	} else {
		return undef;
	};
};

# find all register objects in address map at given address and return the list of found objects
sub find_reg_by_address_all {
	my ($this, $offset) = @_;
	my (@ltemp) = grep ($_->{offset} == $offset, @{$this->addrmap});
	return map {$_->{reg}} @ltemp;
};

# finds all field objects in list with given name and returns a list with the found objects
sub find_field_by_name {
	my ($this, $name) = @_;
	my (@lresult) = grep ($_->{name} eq $name, @{$this->fields});
	if (scalar(@lresult)) {
		return @lresult;
	} else {
		return undef;
	};
};

# finds all field objects with given base-name (exact match) and clone-number (is irrelevant if domain wasn't cloned) 
# and returns a list with the found object(s)
sub find_cloned_field_by_name {
    my ($this, $name, $n) = @_;
    my $o_field = undef;
    my @lresult;

    if ($this->clone->{'number'}>1) {
        # cloned domain
        if ($n>= $this->clone->{'number'}) {
            _error("internal error: specified clone-number $n is greater than total number of clones ", $this->{'clone'}->{'clone_number'});
        };
        foreach $o_field (@{$this->fields}) {
            if (exists $o_field->{'org_name'}) {
                # cloned field
                if ($o_field->{'org_name'} eq $name and $o_field->{'inst_n'} == $n) {
                    push @lresult, $o_field;
                };
            } else { 
                # domain cloned but the field was not cloned
                if ($o_field->name eq $name) {
                    push @lresult, $o_field;
                };
            };
        };
    } else {
        # domain not cloned
        foreach $o_field (@{$this->fields}) {
            if ($o_field->name eq $name) {
                push @lresult, $o_field;
            };
        };
    };
    if (!scalar(@lresult)) {
        _error("field \'$name\' from clone $n not found in domain \'".$this->name."\'");
    };
    return @lresult;
};

# takes a field object and returns the first register object the field is instantiated in
sub find_reg_by_field {
    my ($this, $o_field) = @_;
    my ($o_reg);
    foreach $o_reg (@{$this->regs}) {
        if (grep ($o_field->name eq $_->name, $o_reg->fields)) {
            return $o_reg;
        };
    };
};

# takes a register object and returns a register offset or undef
sub get_reg_address {
	my ($this, $o_reg) = @_;
	my $href;
	foreach $href (@{$this->addrmap}) {
		if ($href->{reg} == $o_reg) {
			return $href->{offset};
		};
	};
	return undef;
};

# default display method
sub display {
	my $this = shift;
 	my $dump  = Data::Dumper->new([$this]);
	$dump->Maxdepth(3);
	$dump->Sortkeys(1);
	print $dump->Dump;
};

1;
