# -*- perl -*---------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright Micronas GmbH, Inc. 2005.                                 |
# |     All Rights Reserved.                                              |
# |                                                                       |
# |                                                                       |
# | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF MICRONAS GMBH          |
# | The copyright notice above does not evidence any actual or intended   |
# | publication of such source code.                                      |
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# | Project:    Micronas - MIX                                            |
# | Modules:    $RCSfile: Entity.pm,v $                                      |
# | Revision:   $Revision: 1.1 $                                          |
# | Author:     $Author: wig $                                            |
# | Date:       $Date: 2005/10/24 12:10:30 $                              |
# | Description: Contains data structure and methods/functions for Entities |
# |                                                                       | 
# | Copyright Micronas GmbH, 2005                                         |
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# | Changes:                                                              |
# | $Log: Entity.pm,v $
# | Revision 1.1  2005/10/24 12:10:30  wig
# | added output.language.verilog = ansistyle,2001param
# |
# |                                                                       |
# +-----------------------------------------------------------------------+
package  Micronas::MixEDA::Entity;
require Exporter;

@ISA=qw(Exporter);

@EXPORT  = qw();

@EXPORT_OK = qw();

our $VERSION = '1.0';

use strict;
# use vars qw( $ex ); # Gets OLE object

use Cwd;
use File::Basename;
use Log::Agent;
use FileHandle;

# Prototypes
# sub write_delta_sheet ($$$);

#
# RCS Id, to be put into output templates
#
my $thisid          =      '$Id: Entity.pm,v 1.1 2005/10/24 12:10:30 wig Exp $';#'  
my $thisrcsfile	    =      '$RCSfile: Entity.pm,v $'; #'
my $thisrevision    =      '$Revision: 1.1 $'; #'  

$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?

#
# Create a new Entity
#  as usual that is a hash
#
sub new {
	my $this = shift;
	my ( $class ) = ref( $this ) || $this;
	my %params = @_;

	# data member default values
	my $ref_member  = {
		'leaf'	=>	'', # If set -> is a leaf enty
		'name'	=>	'',	# Name of this entity
		'lang'	=>  '', # Language like VHDL, Verilog, ...
		'port'	=> [],	# Ports
		'port_cache' => '', # Cache for port map 
		'gen_cache'	=> '',	# Cachee for generic map 
	};
	
	# init data members w/ parameters from constructor call
	foreach (keys %params) {
		$ref_member->{$_} = $params{$_};
	};

	bless $ref_member, $class;
};

1;

#
# Tmp port description located here
#
package  Micronas::MixEDA::Entity::Port;
require Exporter;

# @ISA=qw(Exporter);

# @EXPORT  = qw();

# @EXPORT_OK = qw();

# our $VERSION = '1.0';

#
# Create a new Entity
#  as usual that is a hash
#
sub new {
	my $this = shift;
	my ( $class ) = ref( $this ) || $this;
	my %params = @_;

	# data member default values
	my $ref_member  = {
		'name'	=>	'', # Port name
		'type'	=>	'',	# Port type
		'mode'	=>  '', # Port mode (std_ulogic)
		'high'	=>	'',	# High bound for vectors 
		'low'	=>	'', # Low bound for vectors
		'descr'	=>	'',	# Storage for ::description
		'__nr__' =>	'', # Number for sorting
		'__gen__' => '', # Flag for generated ports
	};
	
	# init data members w/ parameters from constructor call
	foreach (keys %params) {
		$ref_member->{$_} = $params{$_};
	};

	bless $ref_member, $class;
};

#
# Print portwidth
#	N -> if high/low are digits
# 	1 -> single bits
#   F+1  -> if low is 0
#   F:T  -> if one or both bounds are not digits
#
sub portwidth () {
	return;
}

1;

#
# Tmp port description located here
# -> Parameter/Generic port
#
package  Micronas::MixEDA::Entity::Parameter;
require Exporter;

# @ISA=qw(Micronas::MixEDA::Entity::Parameter);

# @EXPORT  = qw();

# @EXPORT_OK = qw();

# our $VERSION = '1.0';

#
# Generic/Parameter init:
#    extend "Port" by a value!
#
sub new {
	my $this = shift;
	my ( $class ) = ref( $this ) || $this;
	my %params = @_;

	my $ref_member = new Micronas::MixEDA::Entity::Port; # TODO : SUPER
	# Add value!
	$ref_member->{'value'} = '';
	
	# init data members w/ parameters from constructor call
	foreach (keys %params) {
		$ref_member->{$_} = $params{$_};
	};

	bless $ref_member, $class;
};

# generic value, possibly converted into appropriate format
sub value () {
	return;
}
1;

#!End