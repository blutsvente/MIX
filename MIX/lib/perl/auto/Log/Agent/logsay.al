# NOTE: Derived from ./blib/lib/Log/Agent.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Log::Agent;

#line 343 "./blib/lib/Log/Agent.pm (autosplit into ./blib/lib/auto/Log/Agent/logsay.al)"
#
# logsay
#
# Log message at the "notice" level.
#
sub logsay {
	return if $Trace < NOTICE;
	my $ptag = prio_tag(priority_level(NOTICE)) if defined $Priorities;
	my $str = tag_format_args($Caller, $ptag, $Tags, \@_);
	&log_default unless defined $Driver;
	$Driver->logsay($str);
}

# end of Log::Agent::logsay
1;
