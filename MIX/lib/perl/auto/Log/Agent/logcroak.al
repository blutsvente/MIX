# NOTE: Derived from ./blib/lib/Log/Agent.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Log::Agent;

#line 246 "./blib/lib/Log/Agent.pm (autosplit into ./blib/lib/auto/Log/Agent/logcroak.al)"
#
# logcroak
#
# Fatal error, from the perspective of our caller
# Error is logged, and then we die.
#
sub logcroak {
	goto &logconfess if $Confess;		# Redirected when -confess
	my $ptag = prio_tag(priority_level(CRIT)) if defined $Priorities;
	my $str = tag_format_args($Caller, $ptag, $Tags, \@_);
	&log_default unless defined $Driver;
	$Driver->logxcroak(0, $str);
	bug("back from logxcroak in driver $Driver\n");
}

# end of Log::Agent::logcroak
1;
