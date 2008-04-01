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
# | Revision:   $Revision: 1.5 $                                          |
# | Author:     $Author: wig $                                            |
# | Date:       $Date: 2008/04/01 12:48:33 $                              |
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
# | Revision 1.5  2008/04/01 12:48:33  wig
# | Added: optimizeportassign feature to avoid extra assign commands
# | added protoype for collapse_conn function allowing to merge signals
# |
# | Revision 1.4  2006/11/15 09:54:28  wig
# | Added ImportVerilogInclude module: read defines and replace in input data.
# |
# | Revision 1.3  2006/07/04 12:22:36  wig
# | Fixed TOP handling, -cfg FILE issue, ...
# |
# | Revision 1.2  2005/10/24 15:43:48  wig
# | added 'reg detection to ::out column
# |
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
my $thisid          =      '$Id: Entity.pm,v 1.5 2008/04/01 12:48:33 wig Exp $';#'
my $thisrcsfile	    =      '$RCSfile: Entity.pm,v $'; #'
my $thisrevision    =      '$Revision: 1.5 $'; #'

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
		'port'	=> {},	# Ports list (hash -> port objects)
		'port_cache' => '', # Cache for port map
		'gen_cache'	=> '',	# Cache for generic map
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
#  as usual it is a hash
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
		'cast'	=>	'', # Typecast
		'rorw'	=>	'', # Register or wire (usefull for Verilog)
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
# Return width
#	N -> if high/low are digits
# 	1 -> single bits
#	F	 -> if low is 0 and high is 'F-1'
#   F+1  -> if low is 0
#   F:T  -> if one or both bounds are not digits
#
sub width () {
	my $this = shift;
	my $h = $this->{high};
	my $l = $this->{low};
	if ( $h eq '' and $l eq '' ) {
		return 1;
	} elsif ( is_integer2( $h, $l ) ) {
		return $h - $l + 1;
	} elsif ( $h ne '0' and $l eq '0' ) {
		if ( $h =~ m/(.*) \s* - \s* 1 \s*$/x ) {
			return $h;
		} else {
			return "$h + 1";
		}
	} else {
		return "$h - $l + 1";
	}
} # End of portwidth

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

__END__

Interface:

Port::
	->name
	->width
	->from
	->to
	->join (-->)
	->purge (function to iterate over all ports, remove duplicates)
	->is_connected
	->print / stringify
	? ->sort
	->type (in/out/inout/buffer/tristate/constant/...)

Generic::
	s/a
	->parameter
	->default

Constant::

PortSlice:  connection between entity::port and signals
	->name
	->width
	->from
	->to
	->fromto
	->signal
	->type
	->stringify
	->portmap
	->genericmap

PortSliceDescr::  instance specific ::descr and ::comment field and ...
	->descr()  -> set and return
	->comment() -> set and return

Signal::
	->add
	->create
	->merge
	->name
	->start
	->end
	->width
	->slices
	->top
	->split(...)
	->join(...)
	->splice(...)
	->check
	->generateports()

InOut::
	->open
	->convert
	->write
	->dump

Instance::  extended class of TreeObject
	->new
	->add
	->parent
	->print
	->dump
	->
Collection::

#!End