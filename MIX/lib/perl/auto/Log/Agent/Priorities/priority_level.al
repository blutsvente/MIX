# NOTE: Derived from ./blib/lib/Log/Agent/Priorities.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Log::Agent::Priorities;

#line 113 "./blib/lib/Log/Agent/Priorities.pm (autosplit into ./blib/lib/auto/Log/Agent/Priorities/priority_level.al)"
#
# priority_level
#
# Decompiles priority which can be either a single digit, a "priority" string
# or a "priority:digit" string. Returns the priority (computed if none) and
# the level (computed if none).
#
sub priority_level {
	my ($id) = @_;
	return (prio_from_level($id), $id) if $id =~ /^\d+$/;
	return ($1, $2) if $id =~ /^([^:]+):(\d+)$/;
	return ($id, level_from_prio($id));
}

1;
# end of Log::Agent::Priorities::priority_level
