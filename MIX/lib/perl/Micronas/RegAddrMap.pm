###############################################################################
#  RCSId: $Id: RegAddrMap.pm,v 1.2 2009/06/22 14:14:07 lutscher Exp $
###############################################################################
#                                  
#  Related Files :  Reg.pm
#
#  Author(s)     :  Thorsten Lutscher                                      
#  Email         :  thorsten.lutscher@tridentmicro.com                          
#
#  Project       :  MIX                                                 
#
#  Creation Date :  09.06.2009
#
#  Contents      :  Address-map class; contains address-nodes (offsets) of addressable objects,
#                   e.g. registers or domains (base-address of domain) 
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
#  $Log: RegAddrMap.pm,v $
#  Revision 1.2  2009/06/22 14:14:07  lutscher
#  fixed syntax error
#
#  Revision 1.1  2009/06/15 11:57:13  lutscher
#  initial release
#
#
#  
###############################################################################

package Micronas::RegAddrMap;

#------------------------------------------------------------------------------
# Used packages
#------------------------------------------------------------------------------
use strict;
use Data::Dumper;
use Micronas::MixUtils::RegUtils;
use Micronas::RegAddrNode;

#------------------------------------------------------------------------------
# Class members
#------------------------------------------------------------------------------
# <define static members here>

# Generic Class Properties
our $package   = __PACKAGE__;
our $instances = 0;
our $debug     = 0;
use constant ADDRESSABLE_OBJECT_TYPES => qw(RegReg RegDomain);

# version of this package, extracted from RCS macros
our($VERSION) = '$Revision: 1.2 $ ';  #'
$VERSION =~ s/\$//g;
$VERSION =~ s/Revision\: //;

#------------------------------------------------------------------------------
# Constructor
# returns a blessed hash reference to the data members of this class
# package; does NOT call the subclass constructors.
# Input: hash for setting member variables with <field-name> => <field-value> (optional)
#------------------------------------------------------------------------------
sub new {
	my $class = shift;
	my %params = @_;

	# data members and their default values
	my $this  = {         
                 id          => $instances,
                 name        => "default",
                 granularity => 1,       # granularity of address values in bytes, used for output generation only, not internal stuff!
                 nodes       => [],      # list of address node objects

                 debug       => $debug,  # debug switch
                 version     => $VERSION # Version of class package
                };

	# init data members w/ parameters from constructor call
	foreach (keys %params) {
		$this->{$_} = $params{$_};
	};
    
    $instances++;
	bless $this, $class;
    $this->_constructor();    # adds access functions for data members
    $this->_parameters( @_ ); # processes arguments passed to constructor 
    return( $this );
};

#------------------------------------------------------------------------------
# Public attributes access methods
#------------------------------------------------------------------------------
sub _constructor() {
    my $this = shift;
    my @all_fields = keys %{$this};
    
    # for each field, set up a named closure as its data accessor (note: this way all is public).
    foreach my $field (@all_fields) {
        no warnings 'redefine';
        print( "field = $field\n" ) if $debug;
        no strict;    
        *{$package."::$field"} = sub :lvalue {
            my($this) = shift;
            if (@_) {
                $this->{$field} = shift;
            }
            return $this->{$field};
        };
        use strict;
    };
};

#------------------------------------------------------------------------------
# Initialize members
#------------------------------------------------------------------------------
sub _parameters() {
  my $this = shift;

  my %params = @_;

  # <optionally check for required number of params>
  # if ( scalar (keys %params) < 1 ) {
  #    die;
  # };

  # init data members w/ parameters from constructor call
  foreach (keys %params) {
      $this->{$_} = $params{$_};
  };

};

#------------------------------------------------------------------------------
# Methods
# First parameter passed to method is implicit and is the object reference 
# ($this) if the method # is called in <object> -> <method>() fashion.
#------------------------------------------------------------------------------

# add a node to the list, returns the node object or undef in case of error
# input: object reference, address-offset value as integer
sub add_node {
    my ($this, $o_ref, $val) = @_;
    my $type = ref($o_ref);
    if (grep($type =~ m/$_/, (ADDRESSABLE_OBJECT_TYPES))) {
        my $o_node = Micronas::RegAddrNode->new(type => $type, o_ref => $o_ref, offset => $val);
        push @{$this->nodes}, $o_node;
        return $o_node;
    } else {
        _error("add_node(): unknown object type \'".${type}."\'");
        return undef;
    };
};

# search function by address, returns list of matching objects referenced by all nodes with matching offset
sub find_object_by_address {
    my ($this, $offset) = @_;
    my (@ltemp) = grep ($_->offset == $offset, @{$this->nodes});
    if (scalar @ltemp) {
        return map {$_->o_ref} @ltemp;
    } else {
        return ();
    };
};

# takes an addressable object (e.g. RegReg, RegDomain) and returns a list of offsets of all nodes 
# where this object is referenced
sub get_object_address {
    my ($this, $o_ref) = @_;
    my (@ltemp) = grep {$_->type eq ref($o_ref) and $_->o_ref == $o_ref} @{$this->nodes};
    # my (@ltemp) = grep ($_->o_ref == $o_ref, @{$this->nodes});
    if (scalar @ltemp) {
        return map {$_->offset} @ltemp;
    } else {
        return ();
    };
};

# display method for debugging (every class should have one)
sub display {
	my $this = shift;
	my $dump  = Data::Dumper->new([$this]);
    $dump->Maxdepth(2);
	$dump->Sortkeys(1);
	print $dump->Dump;
};

1;
