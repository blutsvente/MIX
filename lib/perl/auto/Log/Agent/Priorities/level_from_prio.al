# NOTE: Derived from ./blib/lib/Log/Agent/Priorities.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Log::Agent::Priorities;

#line 98 "./blib/lib/Log/Agent/Priorities.pm (autosplit into ./blib/lib/auto/Log/Agent/Priorities/level_from_prio.al)"
#
# level_from_prio
#
# Given a syslog priority, compute suitable level.
#
sub level_from_prio {
	my ($prio) = @_;
	return -1 if lc($prio) eq 'none';		# none & notice would look alike
	my $canonical = lc(substr($prio, 0, 2));
	return 10 unless exists $basic_level{$canonical};
	return $basic_level{$canonical} || -1;
}

# end of Log::Agent::Priorities::level_from_prio
1;
