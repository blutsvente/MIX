#
# $Id: Tag_List.pm,v 1.1 2003/02/03 13:18:29 wig Exp $
#
#  Copyright (c) 1999, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#  
# HISTORY
# $Log: Tag_List.pm,v $
# Revision 1.1  2003/02/03 13:18:29  wig
# Initial revision
#
# Revision 1.1  2001/06/22 14:15:11  jentzsch
# Added Log::Agent
#
# Revision 0.2.1.1  2001/03/13 18:45:22  ram
# patch2: created
#
# Revision 0.2  2000/11/06 19:30:33  ram
# Baseline for second Alpha release.
#
# $EndLog$
#

use strict;

########################################################################
package Log::Agent::Tag_List;

require Tie::Array;				# contains Tie::StdArray
use vars qw(@ISA);
@ISA = qw(Tie::StdArray);

#
# A list of all log message tags recorded, with dedicated methods to
# manipulate them.
#

#
# ->make
#
# Creation routine.
#
sub make {
	my $self = bless [], shift;
	my (@tags) = @_;
	@$self = @tags;
	return $self;
}

#
# _typecheck
#
# Make sure only objects of the proper type are given in the list.
# Croaks when type checking detects an error.
#
sub _typecheck {
	my $self = shift;
	my ($type, $list) = @_;
	my @bad = grep { !ref $_ || !$_->isa($type) } @$list;
	return unless @bad;

	my $first = $bad[0];
	require Carp;
	Carp::croak(sprintf
		"Expected list of $type, got %d bad (first one is $first)",
		scalar(@bad));
}

#
# ->append
#
# Append list of Log::Agent::Tag objects to current list.
#
sub append {
	my $self = shift;
	my (@tags) = @_;
	$self->_typecheck("Log::Agent::Tag", \@tags);
	push @$self, @tags;
}

#
# ->prepend
#
# Prepend list of Log::Agent::Tag objects to current list.
#
sub prepend {
	my $self = shift;
	my (@tags) = @_;
	$self->_typecheck("Log::Agent::Tag", \@tags);
	unshift @$self, @tags;
}

1;	# for require
__END__

=head1 NAME

Log::Agent::Tag_List - user-defined tags to add to every log

=head1 SYNOPSIS

 use Log::Agent qw(logtags);

 my $taglist = logtags();
 $taglist->append(@tags);        # adds @tags at the tail of list
 $taglist->prepend(@tags);       # adds @tags at the head of list

=head1 DESCRIPTION

This class handles the list of user-defined tags, which are added to
each log message.  The initial list is taken from the C<-tags> argument
of the logconfig() routine. See Log::Agent(3).

=head1 INTERFACE

The following interface is available:

=over 4

=item append I<list>

Append I<list> of C<Log::Agent::Tag> objects to the existing list.

=item prepend I<list>

Prepends I<list> of C<Log::Agent::Tag> objects to the existing list.

=back

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

Log::Agent(3), Log::Agent::Tag(3).

=cut

