# NOTE: Derived from ./blib/lib/Log/Agent.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Log::Agent;

#line 373 "./blib/lib/Log/Agent.pm (autosplit into ./blib/lib/auto/Log/Agent/logdbg.al)"
#
# logdbg		-- frozen
#
# Emit debug message if debug level is set high enough.
# Debug level must either be a single digit or "priority" or "priority:digit".
#
sub logdbg {
	my $id = shift;
	my ($prio, $level) = priority_level($id);
	return if !defined($Debug) || $level > $Debug;
	my $ptag = prio_tag($prio, $level) if defined $Priorities;
	my $str = tag_format_args($Caller, $ptag, $Tags, \@_);
	&log_default unless defined $Driver;
	$Driver->logwrite('debug', $prio, $level, $str);
}

# end of Log::Agent::logdbg
1;
