# NOTE: Derived from ./blib/lib/Log/Agent.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Log::Agent;

#line 330 "./blib/lib/Log/Agent.pm (autosplit into ./blib/lib/auto/Log/Agent/logwarn.al)"
#
# logwarn
#
# Log warning at the "warning" level.
#
sub logwarn {
	return if $Trace < WARN;
	my $ptag = prio_tag(priority_level(WARN)) if defined $Priorities;
	my $str = tag_format_args($Caller, $ptag, $Tags, \@_);
	&log_default unless defined $Driver;
	$Driver->logwarn($str);
}

# end of Log::Agent::logwarn
1;
