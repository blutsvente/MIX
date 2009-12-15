#
# $Id: Silent.pm,v 1.1 2003/02/03 13:18:29 wig Exp $
#
#  Copyright (c) 1999, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Silent.pm,v $
# Revision 1.1  2003/02/03 13:18:29  wig
# Initial revision
#
# Revision 1.1  2001/06/22 14:15:12  jentzsch
# Added Log::Agent
#
# Revision 0.2  2000/11/06 19:30:33  ram
# Baseline for second Alpha release.
#
# $EndLog$
#

use strict;
require Log::Agent::Driver;

########################################################################
package Log::Agent::Driver::Silent;

use vars qw(@ISA);

@ISA = qw(Log::Agent::Driver);

#
# ->make			-- defined
#
# Creation routine.
#
sub make {
	my $self = bless {}, shift;
	return $self;
}

#
# NOP routines.
#

sub prefix_msg {}
sub emit {}
sub channel_eq { 1 }

#
# In theory, we could live with the above NOP ops and the logxxx()
# routines would not do anything. Let's redefine them though...
#

sub logerr {}
sub logwarn {}
sub logsay {}
sub logwrite {}
sub logxcarp {}

#
# Those need minimal processing.
# We explicitely stringify the string argument (uses overloaded "" method)
#

sub logconfess { require Carp; Carp::confess("$_[1]"); }
sub logdie     { die "$_[0]\n"; }

#
# ->logxcroak		-- redefined
#
# Handle the offset parameter correctly
#
sub logxcroak  {
	my $self = shift;
	my ($offset, $str) = @_;
	require Carp;
	my $msg = $self->carpmess($offset, $str, \&Carp::shortmess);
	die "$msg\n";
}

1;	# for require
__END__

=head1 NAME

Log::Agent::Driver::Silent - silent logging driver for Log::Agent

=head1 SYNOPSIS

 use Log::Agent;
 require Log::Agent::Driver::Silent;

 my $driver = Log::Agent::Driver::Silent->make();
 logconfig(-driver => $driver);

=head1 DESCRIPTION

The silent logging driver remaps most of the logxxx() operations to NOPs.
Only logconfess() and logdie() respectively call Carp::confess() and die().

=head1 CHANNELS

All the channels go to /dev/null, so to speak.

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

Log::Agent::Driver(3), Log::Agent(3).

=cut
