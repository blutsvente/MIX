# NOTE: Derived from ./blib/lib/Log/Agent.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Log::Agent;

#line 204 "./blib/lib/Log/Agent.pm (autosplit into ./blib/lib/auto/Log/Agent/DATUM_is_here.al)"
#
# DATUM_is_here		-- undocumented, but for Carp::Datum
#
# Tell Log::Agent that the Carp::Datum package was loaded and configured
# for debug.
#
# If there is a driver configured already, install the interceptor.
# Otherwise, record that DATUM is here and the interceptor will be installed
# by logconfig().
#
# NOT exported, must be called as Log::Agent::DATUM_is_here().
#
sub DATUM_is_here {
	$DATUM = 1;
	return unless defined $Driver;
	return if ref $Driver eq 'Log::Agent::Driver::Datum';

	#
	# Install the interceptor.
	#

	require Log::Agent::Driver::Datum;
	$Driver = Log::Agent::Driver::Datum->make($Driver);
}

# end of Log::Agent::DATUM_is_here
1;
