# NOTE: Derived from ./blib/lib/Log/Agent.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Log::Agent;

#line 290 "./blib/lib/Log/Agent.pm (autosplit into ./blib/lib/auto/Log/Agent/logerr.al)"
#
# logerr
#
# Log error, at the "error" level.
#
sub logerr {
	return if $Trace < ERROR;
	my $ptag = prio_tag(priority_level(ERROR)) if defined $Priorities;
	my $str = tag_format_args($Caller, $ptag, $Tags, \@_);
	&log_default unless defined $Driver;
	$Driver->logerr($str);
}

# end of Log::Agent::logerr
1;
