# -*- perl -*---------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright 2002/2006 Trident Microsystems (Europe) GmbH, Germany
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# | Project:    Micronas - MIX                                            |
# | Modules:    $RCSfile: Log.pm,v $                                      |
# | Revision:   $Revision: 1.2 $                                          |
# | Author:     $Author: lutscher $                                            |
# | Date:       $Date: 2009/12/14 10:58:19 $                              |
# |                                                                       | 
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# | Changes:                                                              |
# | $Log: Log.pm,v $
# | Revision 1.2  2009/12/14 10:58:19  lutscher
# | changed copyright
# |
# | Revision 1.1  2006/07/04 12:22:35  wig
# | Fixed TOP handling, -cfg FILE issue, ...
# |
# |                                                                       |
# +-----------------------------------------------------------------------+

package Log::Log4perl::Filter::MIXFilter;

our $VERSION = '1.0';

use strict;
use vars qw();
use Cwd;

# use FindBin;
# use lib "$FindBin::Bin/..";
# use lib "$FindBin::Bin/../lib/perl";
# use lib "$FindBin::Bin";
# use lib "$FindBin::Bin/lib/perl";
# use lib getcwd() . "/lib/perl";
# use lib getcwd() . "/../lib/perl";

use base qw( Log::Log4perl::Filter );
use Micronas::MixUtils qw( $eh );

#
# RCS Id, to be put into output templates
#
my $thisid          =      '$Id: Log.pm,v 1.2 2009/12/14 10:58:19 lutscher Exp $'; 
my $thisrcsfile	    =      '$RCSfile: Log.pm,v $';
my $thisrevision    =      '$Revision: 1.2 $';  

# Keep logger objects ...
my %logger = ();

$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?

sub new {
	my ( $class, %options ) = @_;
	
	my $self = { 
		'maxcount' => 100, # Cut off if > 100 messages are reached for a given tag
		'_tagc_' => {},
		'_levelmap_' => {
			'FATAL' => 'fatals',
			'WARN'  => 'warnings',
			'ERROR' => 'errors',
			'DEBUG' => 'debug',
			'INFO'  => 'info',
		},
		%options,
	};
	
	bless $self, $class;
	
	return $self;
	
}
	
#
# My own filter:
#
#   count number of errors, warnings, ....
#   refuse to print out if messages count
#
sub ok {
	my ( $self, %p ) = @_;
	
	# Count the level messages
	$eh->inc( 'sum.' . lc($p{log4p_level}) );
	
	# Count this tag
	my $tag = ($p{'message'})[0];
	my $cur = $self->{'_tagc_'}{$tag}++;
	
	# If number of max message repeats < current count
	if ( $cur > 100 ) {
		return 0;
	}
	return 1;
}

1;

__DATA__

#
#  storage for global configuration parameters
#	read in from mix.cfg or through command line
#
sub new {
	my $this = shift;
	my ( $class ) = ref( $this ) || $this;
	my %params = ();
	if ( ref( $_[0] ) eq 'HASH' ) {
		%params = %{$_[0]};
	} else {
		%params = @_;
	}
	# data member default values
	my $ref_member  = {
		'map' => {
			'D' => 'debug',		# Debugging -> to log file (if -debug set)
			'I' => 'info',		# Info level -> print to screen and log file
			'W' => 'warnings',	# Warnings -> to log file
			'E' => 'errors',	# Errors -> to log file and screen
			'F' => 'fatals',	# Fatal error -> to log file and screen, end
			'M' => 'message',	# Message -> see info
		},
		'max' => {				# Limit number of messages to max ...
			'ALL' => '10',
		},
		'count' => {			# Keep message tag counts
		},
		'limit' => {			# Keep info about reached limits
		}
	};
	
	# init data members w/ parameters from constructor call
	foreach (keys %params) {
		$ref_member->{$_} = $params{$_};
	};

	bless $ref_member, $class;
};
#
# Increase counter for given tag and return current value
#
sub inccount {
	my $self = shift;
	my $tag  = shift;
	
	$self->{'count'}{$tag}++;

	return $self->{'count'}{$tag};
	
}

sub getcount {
	my $self = shift;
	my $tag  = shift;
	
	if ( exists( $self->{'count'}{$tag} ) ) {
		return $self->{'count'}{$tag};
	} else {
		return 0;
	}
}

#
# Return number of message tag max ...
#
sub getmax {
	my $self = shift;
	my $tag  = shift;
	
	if ( exists( $self->{'max'}{$tag} ) ) {
		return $self->{'max'}{$tag};
	} else {
		return $self->{'max'}{'ALL'};
	}
}

sub setlimit {
	my $self = shift;
	my $tag  = shift;
	
	$self->{'limit'}{$tag}++;
	return;
}

sub getlimit {
	my $self = shift;
	my $tag  = shift;
	
	if ( exists( $self->{'limit'}{$tag} ) ) {
		return $self->{'limit'}{$tag};
	} else {
		return 0;
	}
}

#
# Increase counter, limit number of logged lines for a 'tag'
# Meant for all kind of messages
#
sub mlogwarn {
	my $self = shift;
	my $tag  = shift;
	my $text = shift || '';

	if ( $tag =~ m/^__([DIWEFM])/ ) {
		# Increase message counters (via global call!)
		$::eh->inc( 'sum.' . $self->{map}{$1} );
	}

	my $ntag = $self->inccount( $tag ); # Increase and get number
	my $max	 = $self->getmax( $tag );
	
	if ( $ntag > $max ) {
		# Do not print, but increase limit counter ...
		$self->setlimit( $tag );
	} else {
		logwarn( $tag . ' ' . $text ); # Forward to logger module
	}
}

#
# Errors
#
sub mlogerror {
	my $self = shift;
	my $tag  = shift;
	my $text = shift;
	
	# normalize tag
	if ( $tag =~ m/^ERROR/i ) {
		$tag = '__E_' . $tag;
	}
	unless( $tag =~ m/^__E/ ) {
		$tag = '__E_' . $tag;
	}
	$self->mlogwarn( $tag, $text );
}

#
# returns logger object
#
sub get_mixlogger {
	my $self = shift;
	my $ltag = shift || '';
	
	unless ( ref( $self ) ) {
		$ltag = $self;
	}
	# Find logger object for certain tag
	if ( exists( $logger{$ltag} ) ) {
		return $logger{$ltag};
	} else {
		# Create new and return
		my $l = new('OpenDist::MixUtils::Log');  # OpenDist::MixUtils::Log;
		$logger{$ltag} = $l;
		return $l;
	}
}
