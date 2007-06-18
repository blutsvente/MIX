###############################################################################
#  RCSId: $Id: RegReg.pm,v 1.8 2007/06/18 12:01:56 lutscher Exp $
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
#  Revision 1.8  2007/06/18 12:01:56  lutscher
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
	   $init = $href->{'field'}->attribs->{'init'} & ((2** ($href->{'field'}->attribs->{'size'})) - 1);
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

# checks if framemaker documentation should be generated for this register
sub to_document()
{
    my ($this) = @_;
    my $mode = "";

    foreach my $href (@{$this->fields}) {
        if ($mode eq "") {
            $mode = uc($href->{field}->attribs->{view});
        } elsif ($mode ne uc($href->{field}->attribs->{view})) {
            $mode = 'N';
        }
    }
    return ($mode eq 'Y');
}

# default display method
sub display {
	my $this = shift;
	my $dump  = Data::Dumper->new([$this]);
	$dump->Maxdepth($debug == 1 ? 5 : 3);
	$dump->Sortkeys(1);
	print $dump->Dump;
};

1;
