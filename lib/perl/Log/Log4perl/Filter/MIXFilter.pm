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
# | Revision:   $Revision: 1.8 $                                          |
# | Author:     $Author: wig $                                            |
# | Date:       $Date: 2006/07/05 09:58:28 $                              |
# |                                                                       | 
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# | Changes:                                                              |
# | $Log: MIXFilter.pm,v $
# | Revision 1.8  2006/07/05 09:58:28  wig
# | Added -variants to conn and io sheet parsing, rewrote open_infile interface (ordered)
# |
# | Revision 1.7  2006/07/04 12:22:36  wig
# | Fixed TOP handling, -cfg FILE issue, ...
# |
# | Revision 1.6  2006/06/22 07:08:53  wig
# | Fixed bug in module with log.limit.test (missing .)
# |
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
my $thisid          =      '$Id: MIXFilter.pm,v 1.8 2006/07/05 09:58:28 wig Exp $'; 
my $thisrcsfile	    =      '$RCSfile: MIXFilter.pm,v $';
my $thisrevision    =      '$Revision: 1.8 $';  

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
# If used in MIX, reads limits and other config from $eh
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
				next if $res eq 'A';
				next if $loglimits->{'tag'}{$res} < 0;
				my $r = '__' . $res . '_'; # This level tags
				if ( $tag =~ m/^$r/ ) {    # Got a match
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
		# TODO : implement A (All) level limit!
		# make sure sum of all tags from given level does not exceed <count> 
		# Count individual tags:
		my $mylevel = uc(substr( $l, 0, 1)); 
		my $mytag = '__' . $mylevel . '_'; 
		if ( exists $loglimits->{'level'}->{$mylevel} ) {
			if ( $loglimits->{'level'}{$mylevel} > 0 ) {  
				if ( substr( $tag, 0, 4 ) eq $mytag ) { # Got a match
					my $c = $eh->inc( 'log.count.level.' . $mylevel ); # Count it
					# Speed it up here (do not use inc, but increase counter!)
					if ( $c > $loglimits->{'level'}{$mylevel} ) {
						$skip = 1;
						# Skip it!
					}
				}
			}
		} # End of C.

		# D. For testing purposes you can set
		# MIXCFG log.limit.test.TAG_RE  <test_count>
		#	All tags matching TAG_RE will be counted. In -delta mode an
		#	exit status not equal 0 will indicate a mismatch of the expected and
		#	the real tag count. There is no default here.

		if ( exists $loglimits->{'test'} ) {
			for my $res ( keys( %{$loglimits->{'test'}} ) ) { 
				if ( $tag =~ m/^$res/ ) { # Got a match
					$eh->inc( 'log.count.test.' . $res );
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
#!End