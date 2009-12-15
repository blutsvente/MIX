# NOTE: Derived from ./blib/lib/Log/Agent.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Log::Agent;

#line 187 "./blib/lib/Log/Agent.pm (autosplit into ./blib/lib/auto/Log/Agent/inited.al)"
#
# inited
#
# Returns whether Log::Agent was inited.
# NOT exported, must be called as Log::Agent::inited().
#
sub inited {
	return 0 unless defined $Driver;
	return ref $Driver ? 1 : 0;
}

# end of Log::Agent::inited
1;
