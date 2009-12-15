###############################################################################
#                                  
#  Related Files :  <related>
#
#  Author(s)     :  <author>                                      
#  Email         :  <author-mail>                         
#
#  Project       :  MIX                                                 
#
#  Creation Date :  14.12.2009
#
#  Contents      :  <template for OO-Perl class> 
#
###############################################################################
#                               Copyright
###############################################################################
#
#     Copyright (C) <year> <author>
#
#     This file is part of MIX.
# 
#     MIX is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     MIX is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with MIX.  If not, see <http://www.gnu.org/licenses/>.
#
###############################################################################

package template; # the class-name

#------------------------------------------------------------------------------
# Used packages
#------------------------------------------------------------------------------
use strict;
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use lib "$Bin/lib";
use Data::Dumper;

#------------------------------------------------------------------------------
# Class members
#------------------------------------------------------------------------------
# <define static members here>

# Generic Class Properties
our $package   = __PACKAGE__;
our $instances = 0;
our $debug     = 0;
our $logtag    = "<logtag>"; # for the logger messages

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
                 # debug switch
                 'debug' => 0,
                 
                 # Version of class package
                 'version' => $VERSION
                };

	# init data members w/ parameters from constructor call
	foreach (keys %params) {
		$this->{$_} = $params{$_};
	};
    
    $instances++;
	bless $this, $class;
    $this->_parameters( @_ ); # processes arguments passed to constructor 
    return( $this );
};

#------------------------------------------------------------------------------
# Public attributes access methods
#------------------------------------------------------------------------------

our $AUTOLOAD;
sub AUTOLOAD {
    my $this = shift;
    my $name = $AUTOLOAD;
    my $type = ref($this) or die "$this is not an object";

    $name =~ s/.*://; # strip fully qualified portion
    unless (exists $this->{$name}) {
        die "cant access field $name in class $type";
    };
    if (@_) {
        return $this->{$name} = shift;
    } else {
        return $this->{$name};
    };
};
# need to declare this to avoid AUTOLOAD being called
sub DESTROY { --$instances };

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
	$dump->Sortkeys(1);
	print $dump->Dump;
};

1;
