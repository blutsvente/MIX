#
# $Id: String.pm,v 1.1 2003/02/03 13:18:29 wig Exp $
#
#  Copyright (c) 1999, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: String.pm,v $
# Revision 1.1  2003/02/03 13:18:29  wig
# Initial revision
#
# Revision 1.1  2001/06/22 14:15:14  jentzsch
# Added Log::Agent
#
# Revision 0.2.1.2  2001/03/31 10:02:25  ram
# patch7: fixed =over to add explicit indent level
#
# Revision 0.2.1.1  2001/03/13 18:45:21  ram
# patch2: created
#
# Revision 0.2  2000/11/06 19:30:32  ram
# Baseline for second Alpha release.
#
# $EndLog$
#

use strict;

########################################################################
package Log::Agent::Tag::String;

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
#   -VALUE      string value to use
#
# Attributes:
#   string      the string value
#
sub make {
	my $self = bless {}, shift;
	my (%args) = @_;
	my ($name, $postfix, $separator, $value);

	my %set = (
		-name		=> \$name,
		-value		=> \$value,
		-postfix	=> \$postfix,
		-separator	=> \$separator,
	);

	while (my ($arg, $val) = each %args) {
		my $vset = $set{lc($arg)};
		next unless ref $vset;
		$$vset = $val;
	}

	$self->_init($name, $postfix, $separator);
	$self->{string} = $value;

	return $self;
}

#
# Defined routines
#

sub string		{ $_[0]->{'string'} }

1;			# for "require"
__END__

=head1 NAME

Log::Agent::Tag::String - a constant tag string

=head1 SYNOPSIS

 require Log::Agent::Tag::String;
 # Inherits from Log::Agent::Tag.

 my $tag = Log::Agent::Tag::String->make(
     -name      => "session id",
     -value     => $session,
     -postfix   => 1,
     -separator => " -- ",
 );

=head1 DESCRIPTION

This class represents a constant tag string.

=head1 CREATION ROUTINE PARAMETERS

The following parameters are defined, in alphabetical order:

=over 4

=item C<-name> => I<name>

The name of this tag.  Currently unused.

=item C<-postfix> => I<flag>

Whether tag should be placed after or before the log message.
By default, it is prepended to the log message, i.e. this parameter is false.

=item C<-separator> => I<string>

The separation string between the tag and the log message.
A single space by default.

=item C<-value> => I<string>

The tag's value.

=back

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

Log::Agent::Tag(3), Log::Agent::Message(3).

=cut

