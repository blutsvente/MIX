# NOTE: Derived from ./blib/lib/Log/Agent.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Log::Agent;

#line 276 "./blib/lib/Log/Agent.pm (autosplit into ./blib/lib/auto/Log/Agent/logdie.al)"
#
# logdie
#
# Fatal error
# Error is logged, and then we die.
#
sub logdie {
	goto &logconfess if $Confess;		# Redirected when -confess
	my $ptag = prio_tag(priority_level(CRIT)) if defined $Priorities;
	my $str = tag_format_args($Caller, $ptag, $Tags, \@_);
	&log_default unless defined $Driver;
	$Driver->logdie($str);
	bug("back from logdie in driver $Driver\n");
}

# end of Log::Agent::logdie
1;
