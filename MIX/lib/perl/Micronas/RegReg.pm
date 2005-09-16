###############################################################################
#  RCSId: $Id: RegReg.pm,v 1.2 2005/09/16 13:57:47 lutscher Exp $
###############################################################################
#                                  
#  Related Files :  RegDomain.pm
#
#  Author(s)     :  Thorsten Lutscher                                      
#  Email         :  thorsten.lutscher@micronas.com                          
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
#       Copyright (C) 2005 Micronas GmbH, Munich, Germany 
#
#     All rights reserved. Reproduction in whole or part is prohibited
#          without the written permission of the copyright owner.
#
###############################################################################
#                                History
###############################################################################
#
#  $Log: RegReg.pm,v $
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
   foreach $href (@{$this->fields}) {
	   $res |= $href->{'field'}->attribs->{'init'} << $href->{'pos'};
   };
   return $res;
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
