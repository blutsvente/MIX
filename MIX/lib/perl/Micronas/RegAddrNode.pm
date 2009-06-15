###############################################################################
#  RCSId: $Id: RegAddrNode.pm,v 1.1 2009/06/15 11:57:13 lutscher Exp $
###############################################################################
#                                  
#  Related Files :  RegAddrMap.pm, Reg.pm
#
#  Author(s)     :  Thorsten Lutscher                                      
#  Email         :  thorsten.lutscher@tridentmicro.com                          
#
#  Project       :  MIX                                                 
#
#  Creation Date :  09.06.2009
#
#  Contents      :  Address node class; basicall holds an addressable-object reference 
#                   and its address.
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
#  $Log: RegAddrNode.pm,v $
#  Revision 1.1  2009/06/15 11:57:13  lutscher
#  initial release
#
#
#  
###############################################################################

package Micronas::RegAddrNode;

#------------------------------------------------------------------------------
# Used packages
#------------------------------------------------------------------------------
use strict;
use Data::Dumper;
use Micronas::MixUtils::RegUtils;

#------------------------------------------------------------------------------
# Class members
#------------------------------------------------------------------------------
# <define static members here>

# Generic Class Properties
our $package   = __PACKAGE__;
our $instances = 0;
our $debug     = 0;

# version of this package, extracted from RCS macros
our($VERSION) = '$Revision: 1.1 $ ';  #'
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
                 id         => $instances,
                 type       => "Micronas::RegReg",  # type of object (result of call to ref())
                 o_ref      => undef,               # reference to an addressable object
                 offset     => 0,                   # offset value

                 debug      => $debug, # debug switch
                 version    => $VERSION # Version of class package
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

# display method for debugging (every class should have one)
sub display {
	my $this = shift;
	my $dump  = Data::Dumper->new([$this]);
    $dump->Maxdepth(2);
	$dump->Sortkeys(1);
	print $dump->Dump;
};

1;
