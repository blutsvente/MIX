# NOTE: Derived from ./blib/lib/Log/Agent.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Log::Agent;

#line 91 "./blib/lib/Log/Agent.pm (autosplit into ./blib/lib/auto/Log/Agent/logconfig.al)"
#
# logconfig
#
# Configure the logging system at the application level. By default, logging
# uses the Log::Agent::Driver::Default driver.
#
# Available options (case insensitive):
#
#   -PREFIX   => string           logging prefix/tag to use, for Default agent
#   -DRIVER   => object           object heir of Log::Agent::Driver
#   -TRACE    => level            trace level
#   -DEBUG    => level            debug level
#   -LEVEL    => level            specifies common trace/debug level
#   -CONFESS  => flag             whether to automatically confess on logdie
#   -CALLER   => listref          info from caller to add and where
#   -PRIORITY => listref          message priority information to add
#   -TAGS     => listref          list of user-defined tags to add
#
# Notes:
#   -CALLER   allowed keys documented in Log::Agent::Tag::Caller's make()
#   -PRIORITY allowed keys documented in Log::Agent::Tag::Priority's make()
#   -TAGS     supplies list of Log::Agent::Tag objects
#
sub logconfig {
	my (%args) = @_;
	my ($calldef, $priodef, $tags);

	my %set = (
		-prefix			=> \$Prefix,		# Only for Default init
		-driver			=> \$Driver,
		-trace			=> \$Trace,
		-debug			=> \$Debug,
		-level			=> [\$Trace, \$Debug],
		-confess		=> \$Confess,
		-caller			=> \$calldef,
		-priority		=> \$priodef,
		-tags			=> \$tags,
	);

	while (my ($arg, $val) = each %args) {
		my $vset = $set{lc($arg)};
		unless (ref $vset) {
			require Carp;
			Carp::croak("Unknown switch $arg");
		}
		if		(ref $vset eq 'SCALAR')		{ $$vset = $val }
		elsif	(ref $vset eq 'ARRAY')		{ map { $$_ = $val } @$vset }
		elsif	(ref $vset eq 'REF')		{ $$vset = $val }
		else								{ die "bug in logconfig" }
	}

	unless (defined $Driver) {
		require Log::Agent::Driver::Default;
		# Keep only basename for default prefix
		$Prefix =~ s|^.*/(.*)|$1| if defined $Prefix;
		$Driver = Log::Agent::Driver::Default->make($Prefix);
	}

	$Prefix = $Driver->prefix;
	$Trace = level_from_prio($Trace) if defined $Trace && $Trace =~ /^\D+/;
	$Debug = level_from_prio($Debug) if defined $Debug && $Debug =~ /^\D+/;

	#
	# Handle -caller => [ <options for Log::Agent::Tag::Caller's make> ]
	#

	if (defined $calldef) {
		unless (ref $calldef eq 'ARRAY') {
			require Carp;
			Carp::croak("Argument -caller must supply an array ref");
		}
		require Log::Agent::Tag::Caller;
		$Caller = Log::Agent::Tag::Caller->make(-offset => 3, @{$calldef});
	};

	#
	# Handle -priority => [ <options for Log::Agent::Tag::Priority's make> ]
	#

	if (defined $priodef) {
		unless (ref $priodef eq 'ARRAY') {
			require Carp;
			Carp::croak("Argument -priority must supply an array ref");
		}
		$Priorities = $priodef;		# Objects created via prio_tag()
	};

	#
	# Handle -tags => [ <list of Log::Agent::Tag objects> ]
	#

	if (defined $tags) {
		unless (ref $tags eq 'ARRAY') {
			require Carp;
			Carp::croak("Argument -tags must supply an array ref");
		}
		my $type = "Log::Agent::Tag";
		if (grep { !ref $_ || !$_->isa($type) } @$tags) {
			require Carp;
			Carp::croak("Argument -tags must supply list of $type objects");
		}
		if (@$tags) {
			require Log::Agent::Tag_List;
			$Tags = Log::Agent::Tag_List->make(@$tags);
		} else {
			undef $Tags;
		}
	}

	# Install interceptor if needed
	DATUM_is_here() if defined $DATUM && $DATUM;
}

# end of Log::Agent::logconfig
1;
