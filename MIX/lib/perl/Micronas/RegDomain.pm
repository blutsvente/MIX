###############################################################################
#  RCSId: $Id: RegDomain.pm,v 1.1 2005/07/07 12:35:26 lutscher Exp $
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
					   fields => []
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

# finds first register object in list at given address and returns the object (or undef)
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
