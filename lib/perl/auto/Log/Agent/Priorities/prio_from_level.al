# NOTE: Derived from ./blib/lib/Log/Agent/Priorities.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Log::Agent::Priorities;

#line 86 "./blib/lib/Log/Agent/Priorities.pm (autosplit into ./blib/lib/auto/Log/Agent/Priorities/prio_from_level.al)"
#
# prio_from_level
#
# Given a level, compute suitable priority.
#
sub prio_from_level {
	my ($level) = @_;
	return 'none' if $level < 0;
	return 'debug' if $level >= @basic_prio;
	return $basic_prio[$level];
}

# end of Log::Agent::Priorities::prio_from_level
1;
