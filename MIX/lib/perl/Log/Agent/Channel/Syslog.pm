#
# $Id: Syslog.pm,v 1.1 2003/02/03 13:18:29 wig Exp $
#
#  Copyright (c) 1999, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Syslog.pm,v $
# Revision 1.1  2003/02/03 13:18:29  wig
# Initial revision
#
# Revision 1.1  2001/06/22 14:15:11  jentzsch
# Added Log::Agent
#
# Revision 0.2.1.2  2001/03/31 10:00:19  ram
# patch7: fixed =over to add explicit indent level
#
# Revision 0.2.1.1  2001/03/14 23:40:18  ram
# patch5: forgot to handle -prefix
#
# Revision 0.2  2000/11/06 19:30:32  ram
# Baseline for second Alpha release.
#
# $EndLog$
#

use strict;
require Log::Agent::Channel;

########################################################################
package Log::Agent::Channel::Syslog;

use vars qw(@ISA);
@ISA = qw(Log::Agent::Channel);

use Sys::Syslog qw(:DEFAULT setlogsock);

#
# ->make			-- defined
#
# Creation routine.
#
# Attributes (and switches that set them):
#
# prefix		the logging prefix to use (application name, usally)
# facility		the syslog facility name to use ("auth", "daemon", etc...)
# showpid		whether to show pid
# socktype		socket type ('unix' or 'inet')
# logopt		list of openlog() options: 'ndelay', 'cons' or 'nowait'
#
sub make {
	my $self = bless {}, shift;
	my (%args) = @_;

	my %set = (
		-prefix		=> \$self->{'prefix'},
		-facility	=> \$self->{'facility'},
		-showpid	=> \$self->{'showpid'},
		-socktype	=> \$self->{'socktype'},
		-logopt		=> \$self->{'logopt'},
	);

	while (my ($arg, $val) = each %args) {
		my $vset = $set{lc($arg)};
		unless (ref $vset) {
			require Carp;
			Carp::croak("Unknown switch $arg");
		}
		$$vset = $val;
	}

	$self->{'logopt'} =~ s/\bpid\b//g;			# Must use showpid => 1
	$self->{'logopt'} .= ' pid' if $self->showpid;

	return $self;
}

#
# Attribute access
#

sub prefix		{ $_[0]->{'prefix'} }
sub facility	{ $_[0]->{'facility'} || 'user' }
sub showpid		{ $_[0]->{'showpid'} }
sub socktype	{ $_[0]->{'socktype'} }
sub logopt		{ $_[0]->{'logopt'} }
sub connected	{ $_[0]->{'connected'} }

#
# ->connect
#
# Connect to syslogd.
#
sub connect {
	my $self = shift;
	setlogsock $self->socktype if $self->socktype;
	openlog $self->prefix, $self->logopt, $self->facility;
	$self->{'connected'}++;
}

#
# ->close			-- defined
#
# Disconnect from syslogd.
#
sub disconnect {
	my $self = shift;
	return unless $self->connected;
	closelog;
	$self->{'connected'} = 0;
}

#
# ->write			-- defined
#
sub write {
	my $self = shift;
	my ($priority, $logstring) = @_;
	$self->connect unless $self->connected;
	syslog $priority, "%s", $logstring;
}

1;	# for require
__END__

=head1 NAME

Log::Agent::Channel::Syslog - syslog logging channel for Log::Agent::Logger

=head1 SYNOPSIS

 require Log::Agent::Channel::Syslog;

 my $channel = Log::Agent::Channel::Syslog->make(
     # Specific attributes
     -prefix     => prefix,
     -facility   => "user",
     -showpid    => 1,
     -socktype   => "unix",
     -logopt     => "ndelay",
 );

=head1 DESCRIPTION

The syslog logging channels directs operations to syslog() via the
Sys::Syslog(3) interface.

The creation routine make() takes the following switches:

=over 4

=item C<-facility> => I<facility>

Tell syslog() which facility to use (e.g. "user", "auth", "daemon").
Unlike the Sys::Syslog(3) interface, the facility is set once and for all:
every message logged through this channel will use the same facility.

=item C<-logopt> => I<syslog options>

Specifies logging options, under the form of a string containing zero or
more of the words I<ndelay>, I<cons> or I<nowait>.

=item C<-prefix> => I<prefix>

The I<prefix> here is syslog's identification string.

=item C<-showpid> => I<flag>

Set to true to have the PID of the process logged. It is false by default.

=item C<-socktype> => (I<unix> | I<inet>)

Specifies the logging socket type to use. The default behaviour is to
use Sys:Syslog's default.

=back

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

Log::Agent::Logger(3).

=cut
