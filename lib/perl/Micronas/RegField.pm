###############################################################################
#  RCSId: $Id: RegField.pm,v 1.7 2009/12/14 10:58:18 lutscher Exp $
###############################################################################
#                                  
#  Related Files :  RegReg.pm
#
#  Author(s)     :  Thorsten Lutscher                                      
#
#  Project       :  MIX                                                 
#
#  Creation Date :  28.06.2005
#
#  Contents      :  Field class; contains field-level attributes and a 
#                   reference to the enclosing register
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
#  $Log: RegField.pm,v $
#  Revision 1.7  2009/12/14 10:58:18  lutscher
#  changed copyright
#
#  Revision 1.6  2009/11/19 12:26:23  lutscher
#  added top-level sheet input and vi2c-xml view
#
#  Revision 1.5  2008/10/27 13:18:12  lutscher
#  fixed bugs in packing and added packing.mode 32to16
#
#  Revision 1.4  2008/07/31 09:05:21  lutscher
#  added packing/unpacking feature for register-domains
#
#  Revision 1.3  2007/06/18 12:01:56  lutscher
#  added access method for id
#
#  Revision 1.2  2006/10/18 08:16:36  lutscher
#  added field function is_cond()
#
#  Revision 1.1  2005/07/07 12:35:26  lutscher
#  Reg: register space class; represents register space
#  of a device and contains register domains; also contains
#  most of the user API for dealing with register spaces.
#  Contains subclasses (see Reg.pm).
#
#  
###############################################################################

package Micronas::RegField;

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
					   attribs => {
								  size => 1,
								  lsb  => 0
								  },        # other field attributes are defined during initialisation
					   reg => undef,        # pointer to register where this field is instantiated
					  };

	# init data members w/ parameters from constructor call
	foreach (keys %params) {
		$ref_member->{$_} = $params{$_};
	};
	$_id++;
	bless $ref_member, $this;
};

# Destructor
# clear back-pointer to register, in case garbage collection cannot handle circular reference
sub DESTROY { 
	my $this = shift;
	--$_id; 
	$this->{reg} = undef;
};

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

# reference object data access method
# input: none or register object
sub reg {
	my $this = shift;
	if (@_) { $this->{reg} = shift @_; };
	return $this->{reg};
};


# default display method
sub display {
	my $this = shift;
	my $dump  = Data::Dumper->new([$this]);
	$dump->Maxdepth(3);
	$dump->Sortkeys(1);
	print $dump->Dump;
};

# query function for conditional attribute of a field
sub is_cond {
    my ($this) = @_;
    my ($result) = 0;
    if(exists ($this->attribs->{'cond'}) and $this->attribs->{'cond'} == 1) {
        $result = 1;
    };
    return $result;
};

# calculate the value range of a field as (min,max) list
sub get_value_range {
    my ($this) = @_;
    my (@lresult) = ();

    my $size = $this->attribs->{'size'};
    if (exists $this->attribs->{'nformat'} and $this->attribs->{'nformat'} =~ m/s/i) {
         @lresult = (-2**($size-1),2**($size-1)-1); 
    } else {
        my $max_val = $size >= 32 ? 0xffffffff : 2**$size-1;
        @lresult = (0, $max_val);
    };
};

# split a field into <n> fields starting at given <n-1> bit positions and returns the list of new field objects;
# returns an empty list if the operation fails
# example: 16-bit field[15:0], split(8, 12) returns field_s0[7:0], field_s0[11:8], field_s0[15:13]
# BAUSTELLE no support for integers bigger than 32 yet
sub _split_at {
    my $this = shift;
    my @lpos = @_;
    
    my @lfield = ();
    my $last_pos = 0;
    my $id = 0;
    my ($split_at_pos, %hattribs0, %hattribs1, $o_field, $postfix);

    $postfix = "_s0";
    %hattribs0 = %{$this->attribs};
    if (($lpos[0] > $last_pos) and ($lpos[0] < $this->attribs->{'size'})) {
        # create first new field with bits old_field[$lpos[0]: 0]
        $hattribs0{size}  = $lpos[0];
        $hattribs0{range} = "0..".(2**$lpos[0]-1);
        $hattribs0{init}  = $hattribs0{init} & (2**$lpos[0]-1);
        $hattribs0{rec}   = $hattribs0{rec} & (2**$lpos[0]-1);
        $o_field = Micronas::RegField->new (
                                            name        => $this->name . $postfix, 
                                            definition  => ($this->definition eq "" ? "" : $this->definition . $postfix),
                                            reg         => $this->reg,
                                            attribs     => \%hattribs0
                                           );
        push @lfield, $o_field;
        %hattribs1 = %{$this->attribs};

        # create 2nd and other new fields
        for ( $id = 0; $id < scalar @lpos; $id += 1) {
            $split_at_pos = $lpos[$id];
            if (($split_at_pos > $last_pos) and ($split_at_pos < $this->attribs->{'size'})) {
                $postfix = "_s" . ($id+1);
                my $new_size = ($id == scalar(@lpos)-1 ? $this->attribs->{size} - $split_at_pos : $lpos[$id+1] - $split_at_pos);
                $hattribs1{size}  = $new_size;
                $hattribs1{range} = "0..".(2**$new_size-1);
                $hattribs1{init}  = ($hattribs1{init} >> $split_at_pos) & (2**$new_size-1);
                $hattribs1{rec}   = ($hattribs1{rec} >> $split_at_pos) & (2**$new_size-1);
                # create new field object, copying everything except the size
                $o_field = Micronas::RegField->new (
                                                    name        => $this->name . $postfix, 
                                                    definition  => ($this->definition eq "" ? "" : $this->definition . $postfix),
                                                    reg         => $this->reg,
                                                    attribs     => \%hattribs1
                                                   );
                push @lfield, $o_field;
            };
            $last_pos = $split_at_pos;
        };
    };
    return @lfield;
};
1;
