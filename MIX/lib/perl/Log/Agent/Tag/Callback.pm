#
# $Id: Callback.pm,v 1.1 2003/02/03 13:18:29 wig Exp $
#
#  Copyright (c) 1999, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Callback.pm,v $
# Revision 1.1  2003/02/03 13:18:29  wig
# Initial revision
#
# Revision 1.1  2001/06/22 14:15:13  jentzsch
# Added Log::Agent
#
# Revision 0.2.1.2  2001/03/31 10:02:20  ram
# patch7: fixed =over to add explicit indent level
#
# Revision 0.2.1.1  2001/03/13 18:45:16  ram
# patch2: created
#
# Revision 0.2  2000/11/06 19:30:32  ram
# Baseline for second Alpha release.
#
# $EndLog$
#

use strict;

########################################################################
package Log::Agent::Tag::Callback;

require Log::Agent::Tag;
use vars qw(@ISA);
@ISA = qw(Log::Agent::Tag);

#
# ->make
#
# Creation routine.
#
# Calling arguments: a hash table list.
#
# The keyed argument list may contain:
#	-POSTFIX	whether to postfix log message or prefix it.
#   -SEPARATOR  separator string to use between tag and message
#   -NAME       tag's name (optional)
#   -CALLBACK   Callback object
#
# Attributes:
#   callback    the Callback object
#
sub make {
	my $self = bless {}, shift;
	my (%args) = @_;
	my ($name, $postfix, $separator, $callback);

	my %set = (
		-name		=> \$name,
		-callback	=> \$callback,
		-postfix	=> \$postfix,
		-separator	=> \$separator,
	);

	while (my ($arg, $val) = each %args) {
		my $vset = $set{lc($arg)};
		next unless ref $vset;
		$$vset = $val;
	}

	unless (defined $callback) {
		require Carp;
		Carp::croak("Argument -callback is mandatory");
	}

	unless (ref $callback && $callback->isa("Callback")) {
		require Carp;
		Carp::croak("Argument -callback needs a Callback object");
	}

	$self->_init($name, $postfix, $separator);
	$self->{callback} = $callback;

	return $self;
}

#
# Attribute access
#

sub callback	{ $_[0]->{callback} }

#
# Defined routines
#

#
# ->string			-- defined
#
# Build tag string by invoking callback.
#
sub string {
	my $self = shift;

	#
	# Avoid recursion, which could happen if another logxxx() call is made
	# whilst within the callback.
	#
	# Assumes mono-threaded application.
	#

	return sprintf 'callback "%s" busy', $self->name if $self->{busy};

	$self->{busy} = 1;
	my $string = $self->callback->call();
	$self->{busy} = 0;

	return $string;
}

1;			# for "require"
__END__

=head1 NAME

Log::Agent::Tag::Callback - a dynamic tag string

=head1 SYNOPSIS

 require Log::Agent::Tag::Callback;
 # Inherits from Log::Agent::Tag.

 my $tag = Log::Agent::Tag::Callback->make(
     -name      => "session id",
     -callback  => Callback->new($obj, 'method', @args),
     -postfix   => 1,
     -separator => " -- ",
 );

=head1 DESCRIPTION

This class represents a dynamic tag string, whose value is determined
by invoking a pre-determined callback, which is described by a C<Callback>
object.

You need to make your application depend on the C<Callback> module from CPAN
if you make use of this tagging feature, since C<Log::Agent> does not
depend on it, on purpose (it does not really use it, it only offers an
interface to plug it in).  At least version 1.02 must be used.

=head1 CREATION ROUTINE PARAMETERS

The following parameters are defined, in alphabetical order:

=over 4

=item C<-callback> => C<Callback> I<object>

The callback to invoke to determine the value of the tag.  The call is
protected via a I<busy> flag, in case there is an unwanted recursion due
to a call to one of the logging routines whilst within the callback.

If the callback is busy, the tag emitted is:

    callback "user" busy

assuming C<user> is the name you supplied via C<-name> for this tag.

=item C<-name> => I<name>

The name of this tag.  Used to flag a callback as I<busy> in case there is
an unwanted recursion into the callback routine.

=item C<-postfix> => I<flag>

Whether tag should be placed after or before the log message.
By default, it is prepended to the log message, i.e. this parameter is false.

=item C<-separator> => I<string>

The separation string between the tag and the log message.
A single space by default.

=back

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

Callback(3), Log::Agent::Tag(3), Log::Agent::Message(3).

=cut

