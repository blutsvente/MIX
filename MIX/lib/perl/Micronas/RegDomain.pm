###############################################################################
#  RCSId: $Id: RegDomain.pm,v 1.8 2009/08/27 08:31:30 lutscher Exp $
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
#  Revision 1.8  2009/08/27 08:31:30  lutscher
#  added functions
#
#  Revision 1.7  2009/06/15 11:57:25  lutscher
#  added addrmaps member to Reg and RegDomain
#
#  Revision 1.6  2009/03/26 12:45:37  lutscher
#  fixed a bug in find function
#
#  Revision 1.5  2008/12/10 13:08:50  lutscher
#  fixed typo
#
#  Revision 1.4  2007/11/20 10:01:14  lutscher
#  changed a find function
#
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
use Micronas::RegAddrMap;

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
# package; addrmaps will be initialized with an empty default address map
# Input: 1. hash containing data members
#------------------------------------------------------------------------------

sub new {
	my $this = shift;
	my %params = @_; 

	# domain attributes hash
	
	# data member default values
	my $ref_member  = {
					   id              => $_id,
					   name            => "",
					   definition      => "",
					   addrmaps        => [],           # list with RegAddrMap objects
                       default_addrmap => "default",    # name of default addressmap
					   regs            => [],
					   fields          => [],
                       clone           => {
                                           'number' => 0
                                          },            # cloning information
                       
                       # private fields
                       hfind_field_by_name_cache  => {},
                       hfind_reg_by_field_cache   => {}
					  };

	# init data members w/ parameters from constructor call
	foreach (keys %params) {
		$ref_member->{$_} = $params{$_};
	};
	$_id++;

    # init default addrmaps list
    my $o_addrmap = Micronas::RegAddrMap->new(name => $ref_member->{default_addrmap});
    push @{$ref_member->{addrmaps}}, $o_addrmap;

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
#sub addrmap {
#	my $this = shift;
#	if (@_) {
#		my %hamap = @_;
#		push @{$this->{addrmap}}, \%hamap;
#	};
#	return $this->{addrmap};
#};

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

# helper function to link a register object with an address offset into a domain
# input: register object, offset value, [optionally] address-map name
sub add_reg {
    my ($this, $o_reg, $offset, $addrmap) = @_;
    if (!defined $addrmap) { $addrmap = $this->{default_addrmap} };
    my $o_addrmap = $this->get_addrmap_by_name($addrmap);
    if (defined $o_addrmap) {
        $o_addrmap->add_node($o_reg, $offset);
    } else {
       _error("add_reg(): unknown address map \'$addrmap\'");
    };
    $this->regs($o_reg);
};

# method to create a new address-map object
sub add_addrmap {
    my ($this, $name, $granularity) = @_;
    my $o_addrmap = Micronas::RegAddrMap->new(name => $name, granularity => $granularity);
    push @{$this->{addrmaps}}, $o_addrmap;
};

# get address-map matching $name or return undef
sub get_addrmap_by_name {
    my ($this, $name) = @_;
    my @ltemp = grep($_->name eq $name, @{$this->{addrmaps}});
    if (scalar @ltemp) {
        return $ltemp[0];
    } else {
        return undef;
    };
};

# finds first register object in address map at given address and returns the object (or undef)
# input: sub-address in domain, [optionally] address-map name
sub find_reg_by_address_first {
	my ($this, $offset, $addrmap) = @_;
    if (!defined $addrmap) { $addrmap = $this->{default_addrmap} };
    my $o_addrmap = $this->get_addrmap_by_name($addrmap);
    if (defined $o_addrmap) {
        return ($o_addrmap->find_object_by_address($offset))[0];
    } else {
        return undef;
    };
};

# find all register objects in address map at given address and return the list of found objects
# input: sub-address in domain, [optionally] address-map name
sub find_reg_by_address_all {
	my ($this, $offset, $addrmap) = @_;
    if (!defined $addrmap) { $addrmap = $this->{default_addrmap} };
    my $o_addrmap = $this->get_addrmap_by_name($addrmap);
    if (defined $o_addrmap) {
        return $o_addrmap->find_object_by_address($offset);
    } else {
        return ();
    };
};

# takes a register object and returns exactly one register offset or undef
# input: reference to register object, [optionally] address-map name
sub get_reg_address {
	my ($this, $o_reg, $addrmap) = @_;
	my $href;
    if (!defined $addrmap) { $addrmap = $this->{default_addrmap} };
    my $o_addrmap = $this->get_addrmap_by_name($addrmap);
    if (defined $o_addrmap) {
        return ($o_addrmap->get_object_address($o_reg))[0];
    } else {
        return undef;
    };
};

# finds all field objects in list with given name and returns a list with the found objects
# uses caching with member hfind_field_by_name_cache
sub find_field_by_name {
	my ($this, $name) = @_;
    
    # cache lookup
    if (exists $this->{hfind_field_by_name_cache}->{$name}) {
        if (defined $this->{hfind_field_by_name_cache}->{$name}) {
            return @{$this->{hfind_field_by_name_cache}->{$name}};
        } else {
            return undef;
        };
    };
 
	my (@lresult) = grep ($_->{name} eq $name, @{$this->fields});
	if (scalar(@lresult)) {
        $this->{hfind_field_by_name_cache}->{$name} = \@lresult;
        return @lresult;
	} else {
		$this->{hfind_field_by_name_cache}->{$name} = undef;
        return undef;
	};
};

# finds all field objects with given base-name (exact match) and clone-number (is irrelevant if domain wasn't cloned) 
# and returns a list with the found object(s)
sub find_cloned_field_by_name {
    my ($this, $name, $n) = @_;
    my $o_field = undef;
    my @lresult;

    if ($this->clone->{'number'}>0) {
        # cloned domain
        if ($n>= $this->clone->{'number'}) {
            _error("internal error: specified clone-number $n is greater than total number of clones ", $this->{'clone'}->{'number'});
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
        @lresult = $this->find_field_by_name($name);
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

    # cache lookup
    # my $key = $o_field->name;
    my $key = $o_field;
    return $this->{hfind_reg_by_field_cache}->{$key} if exists ($this->{hfind_reg_by_field_cache}->{$key});
     
    foreach $o_reg (@{$this->regs}) {
        # if (grep ($key eq $_->{field}->name, @{$o_reg->fields})) {
        if (grep ($key eq $_->{field}, @{$o_reg->fields})) {
            return $this->{hfind_reg_by_field_cache}->{$key} = $o_reg;
        };
    };
};

# find all register objects that match exactly with the passed name; returns list with RegReg objects
sub find_reg_by_name_all {
    my ($this, $search) = @_;
    my ($o_reg);
    my @lresult = ();
    
    foreach $o_reg (@{$this->regs}) {
        if ($o_reg->name eq $search) {
            push @lresult, $o_reg;
        };
    };
    return @lresult;
};

# delete all matching register-objects from the domain and addressmap;
# returns number of deleted objects
sub del_reg {
    my ($this, $o_reg, $addrmap) = @_;
    my $result = 0;

    if (!defined $addrmap) { $addrmap = $this->{default_addrmap} };
    my $o_addrmap = $this->get_addrmap_by_name($addrmap);

    if (defined $o_addrmap) {
        foreach my $o_node ($o_addrmap->find_node_by_object($o_reg)) {
            $o_addrmap->del_node($o_node);
        };
        my $i=0;
        foreach my $_reg (@{$this->regs}) {
            if ($o_reg == $_reg) {
                splice @{$this->{regs}}, $i, 1;
                $result ++;
            };
            $i++;
        };
    } else {
        _error("del_reg(): unknown address map \'$addrmap\'");
    };
    return $result;
};

# delete a field from the domain; this does not delete the field from the register where it is linked
# returns number of deleted objects;
sub del_field {
    my ($this, $o_field) = @_;
    my $result = 0;
    my $i=0;
    foreach my $_field (@{$this->fields}) {
       
        if ($_field == $o_field) {
            # delete field from register
            my $o_reg = $this->find_reg_by_field($_field);
            if (ref $o_reg) {
                $o_reg->del_field($_field);
                # $o_reg->display();
            };       
            # delete field from domain
            splice @{$this->{fields}}, $i, 1;
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
	$dump->Maxdepth(3);
	$dump->Sortkeys(1);
	print $dump->Dump;
};

1;
