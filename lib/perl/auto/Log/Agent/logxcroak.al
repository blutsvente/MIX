# NOTE: Derived from ./blib/lib/Log/Agent.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Log::Agent;

#line 260 "./blib/lib/Log/Agent.pm (autosplit into ./blib/lib/auto/Log/Agent/logxcroak.al)"
#
# logxcroak
#
# Same a logcroak, but with a specific additional offset.
#
sub logxcroak {
	my $offset = shift;
	goto &logconfess if $Confess;		# Redirected when -confess
	my $ptag = prio_tag(priority_level(CRIT)) if defined $Priorities;
	my $str = tag_format_args($Caller, $ptag, $Tags, \@_);
	&log_default unless defined $Driver;
	$Driver->logxcroak($offset, $str);
	bug("back from logxcroak in driver $Driver\n");
}

# end of Log::Agent::logxcroak
1;
