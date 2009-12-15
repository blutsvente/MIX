# NOTE: Derived from ./blib/lib/Log/Agent.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Log::Agent;

#line 389 "./blib/lib/Log/Agent.pm (autosplit into ./blib/lib/auto/Log/Agent/logtags.al)"
#
# logtags
#
# Returns info on user-defined logging tags.
# Asking for this creates the underlying taglist object if not already present.
#
sub logtags {
	return $Tags if defined $Tags;
	require Log::Agent::Tag_List;
	return $Tags = Log::Agent::Tag_List->make();
}

# end of Log::Agent::logtags
1;
