# NOTE: Derived from ./blib/lib/Log/Agent.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Log::Agent;

#line 316 "./blib/lib/Log/Agent.pm (autosplit into ./blib/lib/auto/Log/Agent/logxcarp.al)"
#
# logxcarp
#
# Same a logcarp, but with a specific additional offset.
#
sub logxcarp {
	return if $Trace < WARN;
	my $offset = shift;
	my $ptag = prio_tag(priority_level(WARN)) if defined $Priorities;
	my $str = tag_format_args($Caller, $ptag, $Tags, \@_);
	&log_default unless defined $Driver;
	$Driver->logxcarp($offset, $str);
}

# end of Log::Agent::logxcarp
1;
