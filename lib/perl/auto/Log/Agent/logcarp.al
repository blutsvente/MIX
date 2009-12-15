# NOTE: Derived from ./blib/lib/Log/Agent.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Log::Agent;

#line 303 "./blib/lib/Log/Agent.pm (autosplit into ./blib/lib/auto/Log/Agent/logcarp.al)"
#
# logcarp
#
# Warning, from the perspective of our caller (at the "warning" level)
#
sub logcarp {
	return if $Trace < WARN;
	my $ptag = prio_tag(priority_level(WARN)) if defined $Priorities;
	my $str = tag_format_args($Caller, $ptag, $Tags, \@_);
	&log_default unless defined $Driver;
	$Driver->logxcarp(0, $str);
}

# end of Log::Agent::logcarp
1;
