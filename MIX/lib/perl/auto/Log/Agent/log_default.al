# NOTE: Derived from ./blib/lib/Log/Agent.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Log::Agent;

#line 222 "./blib/lib/Log/Agent.pm (autosplit into ./blib/lib/auto/Log/Agent/log_default.al)"
#
# log_default
#
# Initialize a default logging driver.
#
sub log_default {
	return if defined $Driver;
	logconfig();
}

# end of Log::Agent::log_default
1;
