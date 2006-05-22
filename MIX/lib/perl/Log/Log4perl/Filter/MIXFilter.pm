# -*- perl -*---------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright Micronas GmbH, 2002/2006.                                 |
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
# | Modules:    $RCSfile: MIXFilter.pm,v $                                      |
# | Revision:   $Revision: 1.5 $                                          |
# | Author:     $Author: wig $                                            |
# | Date:       $Date: 2006/05/22 14:05:15 $                              |
# |                                                                       | 
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# | Changes:                                                              |
# | $Log: MIXFilter.pm,v $
# | Revision 1.5  2006/05/22 14:05:15  wig
# | Put logmessage counter in place (again).
# |
# | Revision 1.4  2006/05/03 12:03:15  wig
# | Improved top handling, fixed generated format
# |
# | Revision 1.3  2006/04/24 12:41:52  wig
# | Imporved log message filter
# |
# | Revision 1.2  2006/03/14 16:32:59  wig
# |  	MIXFilter.pm : extended filter based on tag names and occurance
# |
# | Revision 1.1  2006/03/14 08:10:27  wig
# | No changes, got deleted accidently
# |
# |                                                                       |
# +-----------------------------------------------------------------------+

package Log::Log4perl::Filter::MIXFilter;

our $VERSION = '1.0';

use strict;
use vars qw();
use Cwd;

use base qw( Log::Log4perl::Filter );
# use Micronas::MixUtils qw( mix_get_eh );
use Micronas::MixUtils::Globals qw( get_eh );

#
# RCS Id, to be put into output templates
#
my $thisid          =      '$Id: MIXFilter.pm,v 1.5 2006/05/22 14:05:15 wig Exp $'; 
my $thisrcsfile	    =      '$RCSfile: MIXFilter.pm,v $';
my $thisrevision    =      '$Revision: 1.5 $';  

# Keep logger objects ...
my %logger = ();

$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?

sub new {
	my ( $class, %options ) = @_;
	
	my $self = { 
		'maxcount' => -1, # Cut off if > 100 messages are reached for a given tag
		'_tagc_' => {},
		'_levelmap_' => {
			'FATAL' => 'fatals',
			'WARN'  => 'warnings',
			'ERROR' => 'errors',
			'DEBUG' => 'debug',
			'INFO'  => 'info',
		},
		'_levelhit_' => {},
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
	my $l = lc($p{log4p_level});
	
	# For tag: take everything up to first whitespace
	my $tag = '__GENERIC_TAG';
	if ( ref( $p{'message'} ) eq 'ARRAY' ) {
		( $tag = $p{'message'}->[0] ) =~ s/(\S)\s.*/$1/;
	} else {
		( $tag = $p{'message'} ) =~ s/(\S)\s.*/$1/;
	}
	$tag =~ s/\n+$//;

	my $eh = get_eh();
	if ( $eh and $tag !~ m/^SUM:/ ) {
		# Count number of hits in various categories ...
		$eh->inc('logs.' . lc($l) );
		 
		my $loglimits = $eh->get('log.limit');
		# A. MIXCFG log.limit.re.TAG_RE <count>
		if ( exists $loglimits->{'re'} ) {
			for my $res ( keys( %{$loglimits->{'re'}} ) ) {
				next if $loglimits->{'re'}{$res} < 0;
				if ( $tag =~ m/^$res/ ) { # Got a match
					my $c = $eh->inc( 'log.count.re.' . $res );
					if ( $c > $loglimits->{'re'}{$res} ) {
						# Skip it!
						return 0;
					}
				}
			}
		} # End of A.

		# B. Tag default filter:
		# MIXCFG log.limit.tag.<F|E|W|I|D|A> <count>
		#
		#	is somehow equivilant to log.limit.__<L>.* <count>
		# Count individual tags:
		my $skip = 0;
		if ( exists $loglimits->{'tag'} ) {
			for my $res ( keys( %{$loglimits->{'tag'}} ) ) {
				next if $loglimits->{'tag'}{$res} < 0;
				my $r = '__' . $res . '_'; # All level tags 
				if ( $tag =~ m/^$r/ ) { # Got a match
					my $c = $eh->inc( 'log.count.tag.' . $tag );
					if ( $c > $loglimits->{'tag'}{$res} ) {
						$skip = 1;
						# Skip it!
					}
				}
			}
		} # End of B.

		# C. Level filter:
		# MIXCFG log.limit.level.F|E|W|I|D|A... <count>
		#
		# make sure sum of all tags from given level does not exceed <count> 
		# Count individual tags:
		my $mylevel = uc(substr( $l, 0, 1)); 
		my $mytag = '__' . $mylevel . '_'; 
		if ( exists $loglimits->{'level'}->{$mylevel} ) {
			# for my $res ( keys( %{$loglimits->{'level'}} ) ) {
				next if $loglimits->{'level'}{$mylevel} < 0;
				# my $r = '__' . $res . '_'; # All level tags 
				if ( substr( $tag, 0, 4 ) eq $mytag ) { # Got a match
					my $c = $eh->inc( 'log.count.level.' . $mylevel ); # Count it
					# Speed it up here (do not use inc, but increase counter!)
					if ( $c > $loglimits->{'level'}{$mylevel} ) {
						$skip = 1;
						# Skip it!
					}
				}
			# }
		} # End of C.

		# D. For testing purposes you can set
		# MIXCFG log.limit.test.TAG_RE  <test_count>
		#	All tags matching TAG_RE will be counted. In -delta mode an
		#	exit status not equal 0 will indicate a mismatch of the expected and
		#	the real tag count. There is no default here.

		if ( exists $loglimits->{'test'} ) {
			for my $res ( keys( %{$loglimits->{'test'}} ) ) { 
				if ( $tag =~ m/^$res/ ) { # Got a match
					$eh->inc( 'log.count.test' . $res );
				}
			}
		} # End of D.
		
		if ( $skip ) {
			return 0;
		}
	}
	
	$self->{'_levelhit_'}{$l}++;

	my $cur = $self->{'_tagc_'}{$tag}++;

	# If number of max message repeats < current count
	if ( $self->{'maxcount'} > -1 and $cur > $self->{'maxcount'} ) {
		$self->{'_levellimit_'}{$l}++;
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
