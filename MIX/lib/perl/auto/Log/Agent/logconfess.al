# NOTE: Derived from ./blib/lib/Log/Agent.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Log::Agent;

#line 232 "./blib/lib/Log/Agent.pm (autosplit into ./blib/lib/auto/Log/Agent/logconfess.al)"
#
# logconfess
#
# Die with a full stack trace
#
sub logconfess {
	my $ptag = prio_tag(priority_level(CRIT)) if defined $Priorities;
	my $str = tag_format_args($Caller, $ptag, $Tags, \@_);
	&log_default unless defined $Driver;
	$Driver->logconfess($str);
	bug("back from logconfess in driver $Driver\n");
}

# end of Log::Agent::logconfess
1;
