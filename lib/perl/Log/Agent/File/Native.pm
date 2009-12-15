#
# $Id: Native.pm,v 1.1 2003/02/03 13:18:29 wig Exp $
#
#  Copyright (c) 1999, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#  
# HISTORY
# $Log: Native.pm,v $
# Revision 1.1  2003/02/03 13:18:29  wig
# Initial revision
#
# Revision 1.1  2001/06/22 14:15:13  jentzsch
# Added Log::Agent
#
# Revision 0.2.1.2  2001/03/31 10:01:17  ram
# patch7: fixed =over to add explicit indent level
#
# Revision 0.2.1.1  2000/11/12 14:46:40  ram
# patch1: reset $\ before printing
#
# Revision 0.2  2000/11/06 19:30:33  ram
# Baseline for second Alpha release.
#
# $EndLog$
#

use strict;

########################################################################
package Log::Agent::File::Native;

#
# A native Perl filehandle.
#
# I'm no longer using the IO::* hierarchy because it is not adapted
# to what we're trying to achieve here.
#

#
# ->make
#
# Creation routine.
# Turns on autoflush as a side effect.
#
sub make {
	my $class = shift;
	my ($glob) = @_;
	select((select($glob), $| = 1)[0]);		# autoflush turned on
	return bless $glob, $class;
}

#
# ->print
#
# Print to file, propagates print() status.
#
sub print {
	my $glob = shift;
	local $\ = undef;
	return CORE::print $glob @_;
}

#
# ->close
#
# Close file.
#
sub close {
	my $glob = shift;
	CORE::close $glob;
}

#
# ->DESTROY
#
sub DESTROY {
	my $glob = shift;
	CORE::close $glob;
}

1;	# for require
__END__

=head1 NAME

Log::Agent::File::Native - low-overhead IO::File

=head1 SYNOPSIS

 require Log::Agent::File::Native;

 my $fh = Log::Agent::File::Native->make(\*main::STDERR);

=head1 DESCRIPTION

This class is a stripped down implementation of IO::File, to avoid using
the IO::* hierarchy which does not work properly for my simple needs.

=over 4

=item make I<glob>

This is the creation routine. Encapsulates the I<glob> reference so that
we can use object-oriented calls on it.

=item print I<args>

Prints I<args> to the file.

=back

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

Log::Agent::File::Rotate(3), Log::Agent::Driver::File(3).

=cut
