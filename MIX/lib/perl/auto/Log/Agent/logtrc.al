# NOTE: Derived from ./blib/lib/Log/Agent.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Log::Agent;

#line 357 "./blib/lib/Log/Agent.pm (autosplit into ./blib/lib/auto/Log/Agent/logtrc.al)"
#
# logtrc		-- frozen
#
# Trace the message if trace level is set high enough.
# Trace level must either be a single digit or "priority" or "priority:digit".
#
sub logtrc {
	my $id = shift;
	my ($prio, $level) = priority_level($id);
	return if $level > $Trace;
	my $ptag = prio_tag($prio, $level) if defined $Priorities;
	my $str = tag_format_args($Caller, $ptag, $Tags, \@_);
	&log_default unless defined $Driver;
	$Driver->logwrite('output', $prio, $level, $str);
}

# end of Log::Agent::logtrc
1;
