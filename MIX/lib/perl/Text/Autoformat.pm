package Text::Autoformat;

use strict; use vars qw($VERSION @ISA @EXPORT @EXPORT_OK); use Carp;
use 5.005;
$VERSION = '1.04';

require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw( autoformat );
@EXPORT_OK = qw( form tag break_with break_wrap break_TeX );


my $IGNORABLES = join "|", qw {
	a an at as and are
	but by 
	for from
	in is
	of on or
	the to that 
	with while whilst with without
};


my @bspecials = qw( [ | ] );
my @lspecials = qw( < ^ > );
my $ljustified = '[<]{2,}[>]{2,}';
my $bjustified = '[[]{2,}[]]{2,}';
my $bsingle    = '~+';
my @specials = (@bspecials, @lspecials);
my $fixed_fieldpat = join('|', ($ljustified, $bjustified,
				$bsingle,
				map { "\\$_\{2,}" } @specials));
my ($lfieldmark, $bfieldmark, $fieldmark, $fieldpat, $decimal);
my $emptyref = '';

sub import
{
#	use POSIX qw( localeconv );
#	$decimal = localeconv()->{decimal_point} || '.';
	$decimal = '.';

	my $lnumerical = '[>]+(?:'.quotemeta($decimal).'[<]{1,})';
	my $bnumerical = '[]]+(?:'.quotemeta($decimal).'[[]{1,})';

	$fieldpat = join('|', ($lnumerical, $bnumerical,$fixed_fieldpat));

	$lfieldmark = join '|', ($lnumerical, $ljustified, map { "\\$_\{2}" } @lspecials);
	$bfieldmark = join '|', ($bnumerical, $bjustified, $bsingle, map { "\\$_\{2}" } @bspecials);
	$fieldmark  = join '|', ($lnumerical, $bnumerical,
				 $bsingle,
				 $ljustified, $bjustified,
				 $lfieldmark, $bfieldmark);

	Text::Autoformat->export_to_level(1, @_);
}

###### USEFUL TOOLS ######################################

#===== form =============================================#

sub BAD_CONFIG { 'Configuration hash not allowed between format and data' }

sub break_with
{
	my $hyphen = $_[0];
	my $hylen = length($hyphen);
	my @ret;
	sub
	{
		if ($_[2]<=$hylen)
		{
			@ret = (substr($_[0],0,1), substr($_[0],1))
		}
		else
		{
			@ret = (substr($_[0],0,$_[1]-length($hyphen)),
				substr($_[0],$_[1]-length($hyphen)))
		}
		if ($ret[0] =~ /\A\s*\Z/) { return ("",$_[0]); }
		else { return ($ret[0].$hyphen,$ret[1]); }
	}

}

sub break_wrap
{
	return \&break_wrap unless @_;
	my ($text, $reqlen, $fldlen) = @_;
	if ($reqlen==$fldlen) { $text =~ m/\A(\s*\S*)(.*)/s }
	else                  { ("", $text) }
}

my %hyp;
sub break_TeX
{
	my $file = $_[0] || "";

	croak "Can't find TeX::Hypen module"
		unless require "TeX/Hyphen.pm";

	$hyp{$file} = TeX::Hyphen->new($file||undef)
			|| croak "Can't open hyphenation file $file"
		unless $hyp{$file};

	return sub {
		for (reverse $hyp{$file}->hyphenate($_[0])) {
			if ($_ < $_[1]) {
				return (substr($_[0],0,$_).'-',
					substr($_[0],$_) );
			}
		}
		return ("",$_[0]);
	}
}

sub debug { print STDERR @_, "\n" if $::DEBUG || $::DEBUG }

sub notempty
{
	my $ne = ${$_[0]} =~ /\S/;
	debug("\tnotempty('${$_[0]}') = $ne\n");
	return $ne;
}

sub replace($$$$)   # ($fmt, $len, $argref, $config)
{
	my $ref = $_[2];
	my $text = '';
	my $rem = $_[1];
	my $config = $_[3];

	$$ref =~ s/\A\s*//;
	my $fmtnum = length $_[0];

	if ($$ref =~ /\S/ && $fmtnum>2)
	{
	NUMERICAL:{
		#use POSIX qw( strtod );
		my ($ilen,$dlen) = map {length} $_[0] =~ m/([]>]+)\Q$decimal\E([[<]+)/;
		my ($num,$unconsumed) = strtod($$ref);
		if ($unconsumed == length $$ref)
		{
			$$ref =~ s/\s*\S*//;
			redo NUMERICAL if $config->{numeric} =~ m/\bSkipNaN\b/i
				       && $$ref =~ m/\S/;
			$text = '?' x $ilen . $decimal . '?' x $dlen;
			$rem = 0;
			return $text;
		}
		my $formatted = sprintf "%$fmtnum.${dlen}lf", $num;
		$text = (length $formatted > $fmtnum)
			? '#' x $ilen . $decimal . '#' x $dlen
			: $formatted;
		$text =~ s/(\Q$decimal\E\d+?)(0+)$/$1 . " " x length $2/e
			unless $config->{numeric} =~ m/\bAllPlaces\b/i
			    || $num =~ /\Q$decimal\E\d\d{$dlen,}$/;
		if ($unconsumed)
		{
			if ($unconsumed == length $$ref)
				{ $$ref =~ s/\A.[^0-9.+-]*// }
			else
				{ substr($$ref,0,-$unconsumed) = ""}
		}
		else            { $$ref = "" }
		$rem = 0;
	    }
	}
	else
	{
		while ($$ref =~ /\S/)
		{
			last if !$config->{fill} && $$ref=~s/\A\n//;
			last unless $$ref =~ /\A(\s*)(\S+)(.*)\z/s;
			my ($ws, $word, $extra) = ($1,$2,$3);
			my $nonnl = $ws =~ /[^\n]/;
			$ws =~ s/\n/$nonnl? "" : " "/ge if $config->{fill};
			my $lead = ($config->{squeeze} ? ($ws ? " " : "") : $ws);
			my $match = $lead . $word;
			last if $text && $match =~ /\n/;
			my $len1 = length($match);
			if ($len1 <= $rem)
			{
				$text .= $match;
				$rem  -= $len1;
				$$ref = $extra;
			}
			else
			{
				if ($len1 > $_[1] and $rem-length($lead)>$config->{minbreak})
				{
					my ($broken,$left) =
						$config->{break}->($match,$rem,$_[1]);	
					$text .= $broken;
					$$ref = $left.$extra;
					$rem -= length $broken;
				}
				last;
			}
		}
	}

	unless (length $text)
	{
		$text = substr($$ref,0,$rem);
		substr($$ref,0,$rem) = "";
		$rem -= length $text;
	}

	if ( $_[0] eq 'J' && $text =~ / / && length($$ref)) 	# FULLY JUSTIFIED
	{
		$text = reverse $text;
		$text =~ s/( +)/($rem-->0?" ":"").$1/ge while $rem>0;
		$text = reverse $text;
	}
	elsif ( $_[0] =~ /[~<[J]/ ) 			# LEFT JUSTIFIED
	{
		$text .= ' ' x $rem
	}
	elsif ( $_[0] =~ /\>|\]/ )			# RIGHT JUSTIFIED
	{
		substr($text,0,0) = ' ' x $rem;
	}
	elsif ( $_[0] =~ /\^|\|/ )			# CENTRE JUSTIFIED
	{
		my $halfrem = int($rem/2);
		substr($text,0,0) = ' ' x $halfrem;
		$text .= ' ' x ($rem-$halfrem);
	}

	return $text;
}

my %std_config =
(
	header	 => sub{""},
	footer	 => sub{""},
	pagefeed => sub{""},
	pagelen	 => 0,
	pagenum	 => do { \(my $pagenum = 1 )},
	break	 => break_with('-'),
	minbreak => 2,
	squeeze	 => 0,
	numeric	 => "",
	_used    => 1,
);

sub lcr {
	my ($data) = @_;
	$data->{width}  ||= 72;
	$data->{left}   ||= "";
	$data->{centre} ||= $data->{center}||"";
	$data->{right}  ||= "";
	return sub {
		my $l = ref $data->{left} eq 'CODE'
				? $data->{left}->(@_) : $data->{left};
		my $c = ref $data->{centre} eq 'CODE'
				? $data->{centre}->(@_) : $data->{centre};
		my $r = ref $data->{right} eq 'CODE'
				? $data->{right}->(@_) : $data->{right};
		my $gap = int(($data->{width}-length($c))/2-length($l));
		return $l . " " x $gap
		     . $c . " " x ($data->{width}-length($l)-length($c)-$gap-length($r))
		     . $r;
	}
}

sub fix_config(\%)
{
	my ($config) = @_;
	if (ref $config->{header} eq 'HASH') {
		$config->{header} = lcr $config->{header};
	}
	unless (ref $config->{header} eq 'CODE') {
		my $tmp = $config->{header}; $config->{header} = sub { $tmp }
	}
	if (ref $config->{footer} eq 'HASH') {
		$config->{footer} = lcr $config->{footer};
	}
	unless (ref $config->{footer} eq 'CODE') {
		my $tmp = $config->{footer}; $config->{footer} = sub { $tmp }
	}
	unless (ref $config->{pagefeed} eq 'CODE')
		{ my $tmp = $config->{pagefeed}; $config->{pagefeed} = sub { $tmp } }
	unless (ref $config->{break} eq 'CODE')
		{ $config->{break} = break_with($config->{break}) }
	unless (ref $config->{pagenum} eq 'SCALAR') 
		{ my $tmp = $config->{pagenum}; $config->{pagenum} = \$tmp }
}

sub FormOpt::DESTROY
{
	carp "Configuration specified at $std_config{_line} was not used before it went out of scope"
		if $^W && !$std_config{_used};
	%std_config = %{$std_config{_prev}};
}

sub form
{
	my $config = {%std_config};
	my $startidx = 0;
	if (@_ && ref($_[0]) eq 'HASH')		# RESETTING CONFIG
	{
		if (@_ > 1)			# TEMPORARY RESET
		{
			$config = {%$config, %{$_[$startidx++]}};
			fix_config(%$config);
			$startidx = 1;
		}
		elsif (defined wantarray)	# CONTEXT BEING CAPTURED
		{
			$_[0]->{_prev} = { %std_config };
			$_[0]->{_used} = 0;
			$_[0]->{_line} = join " line ", (caller)[1..2];;
			%{$_[0]} = %std_config = (%std_config, %{$_[0]});
			fix_config(%std_config);
			return bless $_[0], 'FormOpt';
		}
		else				# PERMANENT RESET
		{
			$_[0]->{_used} = 1;
			$_[0]->{_line} = join " line ", (caller)[1..2];;
			%std_config = (%std_config, %{$_[0]});
			fix_config(%std_config);
			return;
		}
	}
	$std_config{_used}++;
	my @ref = map { ref } @_;
	my @orig = @_;
	my $caller = caller;
	no strict;

	for my $nextarg (0..$#_)
	{
		my $next = $_[$nextarg];
		if (!defined $next)
		{
			splice @_, $nextarg, 1, '';
		}
		elsif ($ref[$nextarg] eq 'ARRAY')
		{
			splice @_, $nextarg, 1, \join("\n", @$next)
		}
		elsif (!defined eval { local $SIG{__DIE__};
				       $_[$nextarg] = $next;
				       debug "writeable: [$_[$nextarg]]";
				       1})
		{
		        debug "unwriteable: [$_[$nextarg]]";
			my $arg = $_[$nextarg];
			splice @_, $nextarg, 1, \$arg;
		}
		elsif (!$ref[$nextarg])
		{
			splice @_, $nextarg, 1, \$_[$nextarg];
		}
                elsif ($ref[$nextarg] ne 'HASH' and $ref[$nextarg] ne 'SCALAR')
                {
                       splice @_, $nextarg, 1, \"$next";
                }
	}

	my $header = $config->{header}->(${$config->{pagenum}});
	$header.="\n" if $header && substr($header,-1,1) ne "\n";

	my $footer = $config->{footer}->(${$config->{pagenum}});
	$footer.="\n" if $footer && substr($footer,-1,1) ne "\n";

	my $prevfooter = $footer;

	my $linecount = $header=~tr/\n/\n/ + $footer=~tr/\n/\n/;
	my $hfcount = $linecount;

	my $text = $header;

	while ($startidx < @_)
	{
		if ($ref[$startidx]||'' eq 'HASH')
		{
			$config = {%$config, %{$_[$startidx++]}};
			fix_config(%$config);
			next;
		}
		my $format = ${$_[$startidx++]}||"";
		debug("format: [$format]");
	
		my @parts = split /(\n|(?:\\.)+|$fieldpat)/, $format;
		push @parts, "\n" unless @parts && $parts[-1] eq "\n";
		my $fieldcount = 0;
		my $filled = 0;
		my $firstline = 1;
		while (!$filled)
		{
			my $nextarg = $startidx;
			my @data;
			foreach my $part ( @parts )
			{
				if ($part =~ /\A(?:\\.)+/)
				{
					debug("esc literal: [$part]");
					my $tmp = $part;
					$tmp =~ s/\\(.)/$1/g;
					$text .= $tmp;
				}
				elsif ($part =~ /($lfieldmark)/)
				{
					if ($firstline)
					{
						$fieldcount++;
						if ($nextarg > $#_)
							{ push @_,\$emptyref; push @ref, '' }
						my $type = $1;
						$type = 'J' if $part =~ /$ljustified/;
						croak BAD_CONFIG if ($ref[$startidx] eq 'HASH');
						debug("once field: [$part]");
						debug("data was: [${$_[$nextarg]}]");
						$text .= replace($type,length($part),$_[$nextarg],$config);
						debug("data now: [${$_[$nextarg]}]");
					}
					else
					{
						$text .= ' ' x length($part);
						debug("missing once field: [$part]");
					}
					$nextarg++;
				}
				elsif ($part =~ /($fieldmark)/ and substr($part,0,2) ne '~~')
				{
					$fieldcount++ if $firstline;
					if ($nextarg > $#_)
						{ push @_,\$emptyref; push @ref, '' }
					my $type = $1;
					$type = 'J' if $part =~ /$bjustified/;
					croak BAD_CONFIG if ($ref[$startidx] eq 'HASH');
					debug("multi field: [$part]");
					debug("data was: [${$_[$nextarg]}]");
					$text .= replace($type,length($part),$_[$nextarg],$config);
					debug("data now: [${$_[$nextarg]}]");
					push @data, $_[$nextarg];
					$nextarg++;
				}
				else
				{
					debug("literal: [$part]");
					my $tmp = $part;
					$tmp =~ s/\0(\0*)/$1/g;
					$text .= $tmp;
					if ($part eq "\n")
					{
						$linecount++;
						if ($linecount>=$config->{pagelen})
						{
							${$config->{pagenum}}++;
							my $pagefeed = $config->{pagefeed}->(${$config->{pagenum}});
							$header = $config->{header}->(${$config->{pagenum}});
							$header.="\n" if $header && substr($header,-1,1) ne "\n";
							$text .= $footer
							       . $pagefeed
							       . $header;
							$prevfooter = $footer;
							$footer = $config->{footer}->(${$config->{pagenum}});
							$footer.="\n" if $footer && substr($footer,-1,1) ne "\n";
							$linecount = $hfcount =
								$header=~tr/\n/\n/ + $footer=~tr/\n/\n/;
							$header = $pagefeed
								. $header;
						}
					}
				}
				debug("\tnextarg now:  $nextarg");
				debug("\tstartidx now: $startidx");
			}
			$firstline = 0;
			$filled = ! grep { notempty $_ } @data;
		}
		$startidx += $fieldcount;
	}

	# ADJUST FINAL PAGE HEADER OR FOOTER AS REQUIRED
	if ($hfcount && $linecount == $hfcount)		# UNNEEDED HEADER
	{
		$text =~ s/\Q$header\E\Z//;
	}
	elsif ($linecount && $config->{pagelen})	# MISSING FOOTER
	{
		$text .= "\n" x ($config->{pagelen}-$linecount)
		       . $footer;
		$prevfooter = $footer;
	}

	# REPLACE LAST FOOTER
	
	if ($prevfooter) {
		my $lastfooter = $config->{footer}->(${$config->{pagenum}},1);
		$lastfooter.="\n"
			if $lastfooter && substr($lastfooter,-1,1) ne "\n";
		substr($text, -length($prevfooter)) = $lastfooter;
	}

	# RESTORE ARG LIST
	for my $i (0..$#orig)
	{
		if ($ref[$i] eq 'ARRAY')
			{ eval { @{$orig[$i]} = map "$_\n", split /\n/, ${$_[$i]} } }
		elsif (!$ref[$i])
			{ eval { debug("restoring $i (".$_[$i].") to $orig[$i]");
				 ${$_[$i]} = $orig[$i] } }
	}

	${$config->{pagenum}}++;
	$text =~ s/[ ]+$//gm if $config->{trim};
	return $text unless wantarray;
	return map "$_\n", split /\n/, $text;
}


#==== tag ============================================#

sub invert($)
{
	my $inversion = reverse $_[0];
	$inversion =~ tr/{[<(/}]>)/;
	return $inversion;
}

sub tag		# ($tag, $text; $opt_endtag)
{
	my ($tagleader,$tagindent,$ldelim,$tag,$tagargs,$tagtrailer) = 
		( $_[0] =~ /\A((?:[ \t]*\n)*)([ \t]*)(\W*)(\w+)(.*?)(\s*)\Z/ );

	$ldelim = '<' unless $ldelim;
	$tagtrailer =~ s/([ \t]*)\Z//;
	my $textindent = $1||"";

	my $rdelim = invert $ldelim;

	my $i;
	for ($i = -1; -1-$i < length $rdelim && -1-$i < length $tagargs; $i--)
	{
		last unless substr($tagargs,$i,1) eq substr($rdelim,$i,1);
	}
	if ($i < -1)
	{
		$i++;
		$tagargs = substr($tagargs,0,$i);
		$rdelim = substr($rdelim,$i);
	}

	my $endtag = $_[2] || "$ldelim/$tag$rdelim";

	return "$tagleader$tagindent$ldelim$tag$tagargs$rdelim$tagtrailer".
		join("\n",map { "$tagindent$textindent$_" } split /\n/, $_[1]).
		"$tagtrailer$tagindent$endtag$tagleader";

}


###### AUTOFORMATTING ####################################

my $default_margin = 72;
my $default_widow  = 10;

$Text::Autoformat::widow_slack = 0.1;




sub defn($)
{
	return $_[0] if defined $_[0];
	return "";
}

# BITS OF A TEXT LINE

my $quotechar = qq{[!#%=|:]};
my $quotechunk = qq{(?:$quotechar(?![a-z])|[a-z]*>+)};
my $quoter = qq{(?:(?i)(?:$quotechunk(?:[ \\t]*$quotechunk)*))};

my $separator = q/(?:[-_]{2,}|[=#*]{3,}|[+~]{4,})/;


sub autoformat	# ($text, %args)
{
	my ($text,%args,$toSTDOUT);

	foreach ( @_ )
	{
		unless (ref || defined $text) { $text = $_ }
		elsif (ref eq 'HASH') { %args = (%args, %$_) }
		else { croak q{Usage: autoformat([text],[{options}])} }
	}

	unless (defined $text) {
		$text = join("",<STDIN>);
		$toSTDOUT = !defined wantarray();
	}

	$args{right}   = $default_margin unless exists $args{right};
	$args{justify} = "" unless exists $args{justify};
	$args{widow}   = 0 if $args{justify}||"" =~ /full/;
	$args{widow}   = $default_widow unless exists $args{widow};
	$args{case}    = '' unless exists $args{case};
	$args{squeeze} = 1 unless exists $args{squeeze};
	$args{gap}     = 0 unless exists $args{gap};
	$args{impfill} = ! exists $args{fill};
	$args{expfill} = $args{fill};
	$args{_centred} = 1 if $args{justify} =~ /cent(er(ed)?|red?)/;

	# DETABIFY
	my @rawlines = split /\n/, $text;
	use Text::Tabs;
	@rawlines = expand(@rawlines);

	# PARSE EACH LINE

	my $pre = 0;
	my @lines;
	foreach (@rawlines)
	{
			push @lines, { raw	   => $_ };
			s/\A([ \t]*)($quoter?)([ \t]*)//
				or die "Internal Error ($@) on '$_'";
			$lines[-1]{presig} =  $lines[-1]{prespace}   = defn $1;
			$lines[-1]{presig} .= $lines[-1]{quoter}     = defn $2;
			$lines[-1]{presig} .= $lines[-1]{quotespace} = defn $3;

			$lines[-1]{hang}       = defn Hang->new($_);

			s/([ \t]*)(.*?)(\s*)$//
				or die "Internal Error ($@) on '$_'";
			$lines[-1]{hangspace} = defn $1;
			$lines[-1]{text} = defn $2;
			$lines[-1]{empty} = $lines[-1]{hang}->empty() && $2 !~ /\S/;
			$lines[-1]{separator} = $lines[-1]{text} =~ /^$separator$/;
	}

	# SUBDIVIDE DOCUMENT INTO COHERENT SUBSECTIONS

	my @chunks;
	push @chunks, [shift @lines];
	foreach my $line (@lines)
	{
		if ($line->{separator} ||
		    $line->{quoter} ne $chunks[-1][-1]->{quoter} ||
		    $line->{empty} ||
		    @chunks && $chunks[-1][-1]->{empty})
		{
			push @chunks, [$line];
		}
		else
		{
			push @{$chunks[-1]}, $line;
		}
	}



 # DETECT CENTRED PARAS

	CHUNK: foreach my $chunk ( @chunks )
	{
		next CHUNK if @$chunk < 2;
		my @length;
		my $ave = 0;
		foreach my $line (@$chunk)
		{
			my $prespace = $line->{quoter}  ? $line->{quotespace}
							: $line->{prespace};
			my $pagewidth = 
				2*length($prespace) + length($line->{text});
			push @length, [length $prespace,$pagewidth];
			$ave += $pagewidth;
		}
		$ave /= @length;
		my $diffpre = 0;
		foreach my $l (0..$#length)
		{
			next CHUNK unless abs($length[$l][1]-$ave) <= 2;
			$diffpre ||= $length[$l-1][0] != $length[$l][0]
				if $l > 0;
		}
		next CHUNK unless $diffpre;
		foreach my $line (@$chunk)
		{
			$line->{centred} = 1;
			($line->{quoter} ? $line->{quotespace}
					 : $line->{prespace}) = "";
		}
	}

	# REDIVIDE INTO PARAGRAPHS

	my @paras;
	foreach my $chunk ( @chunks )
	{
		my $first = 1;
		my $firstfrom;
		foreach my $line ( @{$chunk} )
		{
			if ($first ||
			    $line->{quoter} ne $paras[-1]->{quoter} ||
			    $paras[-1]->{separator} ||
			    !$line->{hang}->empty
			   )
			{
				push @paras, $line;
				$first = 0;
				$firstfrom = length($line->{raw}) - length($line->{text});
			}
			else
			{
    my $extraspace = length($line->{raw}) - length($line->{text}) - $firstfrom;
				$paras[-1]->{text} .= "\n" . q{ }x$extraspace . $line->{text};
				$paras[-1]->{raw} .= "\n" . $line->{raw};
			}
		}
	}

	# HANDLE FIRST PARA UNLESS $args{all}

	my $remainder = "";
	unless ($args{all})
	{
		$remainder = join "\n", map { $_->{raw} } @paras[1..$#paras];
		@paras = ( $paras[0] );
	}

	# RE-CASE TEXT
	if ($args{case}) {
		foreach my $para ( @paras ) {
			if ($args{case} =~ /upper/i) {
				$para->{text} =~ tr/a-z/A-Z/;
			}
			if ($args{case} =~ /lower/i) {
				$para->{text} =~ tr/A-Z/a-z/;
			}
			if ($args{case} =~ /title/i) {
				$para->{text} =~ s/(\S+)/entitle($1)/ge;
			}
			if ($args{case} =~ /highlight/i) {
				$para->{text} =~ s/(\S+)/entitle($1,1)/ge;
				$para->{text} =~ s/([a-z])/\U$1/i;
			}
			if ($args{case} =~ /sentence(\s*)/i) {
				my $trailer = $1;
				$args{squeeze}=0 if $trailer && $trailer ne " ";
				ensentence();
				$para->{text} =~ s/(\S+(\s+|$))/ensentence($1, $trailer)/ge;
			}
		}
	}

	# ALIGN QUOTERS
	# DETERMINE HANGING MARKER TYPE (BULLET, ALPHA, ROMAN, ETC.)

	my %sigs;
	my $lastquoted = 0;
	my $lastprespace = 0;
	for my $i ( 0..$#paras )
	{
		my $para = $paras[$i];

	 if ($para->{quoter})
		{
			if ($lastquoted) { $para->{prespace} = $lastprespace }
			else		 { $lastquoted = 1; $lastprespace = $para->{prespace} }
		}
		else
		{
			$lastquoted = 0;
		}
	}

# RENUMBER PARAGRAPHS

	for my $para ( @paras )
	{
		my $sig = $para->{presig} . $para->{hang}->signature();
		push @{$sigs{$sig}{hangref}}, $para;
		$sigs{$sig}{hangfields} = $para->{hang}->fields()-1
			unless defined $sigs{$sig}{hangfields};
	}

	while (my ($sig,$val) = each %sigs)
	{
		next unless $sig =~ /rom/;
		field: for my $field ( 0..$val->{hangfields} )
		{
			my $romlen = 0;
			foreach my $para ( @{$val->{hangref}} )
			{
				my $hang = $para->{hang};
				my $fieldtype = $hang->field($field);
				next field 
					unless $fieldtype && $fieldtype =~ /rom|let/;
				if ($fieldtype eq 'let') {
					foreach my $para ( @{$val->{hangref}} ) {
						$hang->field($field=>'let')
					}
				}
				else {
					$romlen += length $hang->val($field);
				}
			}
			# NO ROMAN LETTER > 1 CHAR -> ALPHABETICS
			if ($romlen <= @{$val->{hangref}}) {
				foreach my $para ( @{$val->{hangref}} ) {
					$para->{hang}->field($field=>'let')
				}
			}
		}
	}

	my %prev;
	for my $para ( @paras )
	{
		my $sig = $para->{presig} . $para->{hang}->signature();
		unless ($para->{quoter}) {
			$para->{hang}->incr($prev{""}, $prev{$sig});
			$prev{""} = $prev{$sig} = $para->{hang}
				unless $para->{hang}->empty;
		}
			
		# COLLECT MAXIMAL HANG LENGTHS BY SIGNATURE

		my $siglen = $para->{hang}->length();
		$sigs{$sig}{hanglen} = $siglen
			if ! $sigs{$sig}{hanglen} ||
			   $sigs{$sig}{hanglen} < $siglen;
	}

	# PROPAGATE MAXIMAL HANG LENGTH

	while (my ($sig,$val) = each %sigs)
	{
		foreach (@{$val->{hangref}}) {
			$_->{hanglen} = $val->{hanglen};
		}
	}

	# BUILD FORMAT FOR EACH PARA THEN FILL IT 

	$text = "";
	my $gap = $paras[0]->{empty} ? 0 : $args{gap};
	for my $para ( @paras )
	{
	    if ($para->{empty}) {
		$gap += 1 + ($para->{text} =~ tr/\n/\n/);
	    }
	    my $leftmargin = $args{left} ? " "x($args{left}-1)
					 : $para->{prespace};
	    my $hlen = $para->{hanglen} || $para->{hang}->length;
	    my $hfield = ($hlen==1 ? '~' : '>'x$hlen);
	    my @hang;
	    push @hang, $para->{hang}->stringify if $hlen;
	    my $format = $leftmargin
			   . quotemeta($para->{quoter})
			   . $para->{quotespace}
			   . $hfield
			   . $para->{hangspace};
	    my $rightslack = int (($args{right}-length $leftmargin)*$Text::Autoformat::widow_slack);
	    my ($widow_okay, $rightindent, $firsttext, $newtext) = (0,0);
	    do {
	        my $tlen = $args{right}-$rightindent-length($leftmargin
			 			. $para->{quoter}
			 			. $para->{quotespace}
			 			. $hfield
			 			. $para->{hangspace});
	        next if blockquote($text,$para, $format, $tlen, \@hang, \%args);
	        my $tfield = ( $tlen==1                          ? '~'
			     : $para->{centred}||$args{_centred} ? '|'x$tlen
			     : $args{justify} eq 'right'         ? ']'x$tlen
			     : $args{justify} eq 'full'          ? '['x($tlen-2) . ']]'
			     : $para->{centred}||$args{_centred} ? '|'x$tlen
			     :                                     '['x$tlen
        		     );
		my $tryformat = "$format$tfield";
		$newtext = (!$para->{empty} ? "\n"x($args{gap}-$gap) : "") 
		         . form( { squeeze=>$args{squeeze}, trim=>1,
				   fill => !(!($args{expfill}
					|| $args{impfill} &&
					   !$para->{centred}))
			       },
				$tryformat, @hang,
				$para->{text});
		$firsttext ||= $newtext;
		$newtext =~ /\s*([^\n]*)$/;
		$widow_okay = $para->{empty} || length($1) >= $args{widow};
		# print "[$rightindent <= $rightslack : $widow_okay : $1]\n";
		# print $tryformat;
		# print $newtext;
	    } until $widow_okay || ++$rightindent > $rightslack;

	    $text .= $widow_okay ? $newtext : $firsttext;
	    $gap = 0 unless $para->{empty};
	}


	# RETURN FORMATTED TEXT

	if ($toSTDOUT) { print STDOUT $text . $remainder; return }
	return $text . $remainder;
}

sub entitle {
	my ($str,$ignore) = @_;
	my $mixedcase = $str =~ /[a-z].*[A-Z]|[A-Z].*[a-z]/;
	my $ignorable = $ignore && $str =~ /^[^a-z]*($IGNORABLES)[^a-z]*$/i;
	$str = lc $str if $ignorable || ! $mixedcase ;
	$str =~ s/([a-z])/\U$1/i unless $ignorable;
	return $str;
}

my $abbrev = join '|', qw{
	etc[.]	pp[.]	ph[.]?d[.]	U[.]S[.]
};

my $gen_abbrev = join '|', $abbrev, qw{
 	(^[^a-z]*([a-z][.])+)
};

my $term = q{(?:[.]|[!?]+)};

my $eos = 1;
my $brsent = 0;

sub ensentence {
	do { $eos = 1; return } unless @_;
	my ($str, $trailer) = @_;
	if ($str =~ /^([^a-z]*)I[^a-z]*?($term?)[^a-z]*$/i) {
		$eos = $2;
		$brsent = $1 =~ /^[[(]/;
		return uc $str
	}
	unless ($str =~ /[a-z].*[A-Z]|[A-Z].*[a-z]/) {
		$str = lc $str;
	}
	if ($eos) {
		$str =~ s/([a-z])/uc $1/ie;
		$brsent = $str =~ /^[[(]/;
	}
	$eos = $str !~ /($gen_abbrev)[^a-z]*\s/i
	    && $str =~ /[a-z][^a-z]*$term([^a-z]*)\s/
	    && !($1=~/[])]/ && !$brsent);
	$str =~ s/\s+$/$trailer/ if $eos && $trailer;
	return $str;
}

# blockquote($text,$para, $format, $tlen, \@hang, \%args);
sub blockquote {
	my ($dummy, $para, $format, $tlen, $hang, $args) = @_;
=begin other
	print STDERR "[", join("|", $para->{raw} =~
/ \A(\s*)		# $1 - leading whitespace (quotation)
	   (["']|``)		# $2 - opening quotemark
	   (.*)			# $3 - quotation
	   (''|\2)		# $4 closing quotemark
	   \s*?\n		# trailing whitespace
	   (\1[ ]+)		# $5 - leading whitespace (attribution)
	   (--|-)		# $6 - attribution introducer
	   ([^\n]*?$)		# $7 - attribution line 1
	   ((\5[^\n]*?$)*)		# $8 - attributions lines 2-N
	   \s*\Z
	 /xsm
), "]\n";
=cut
	$para->{text} =~
		/ \A(\s*)		# $1 - leading whitespace (quotation)
	   (["']|``)		# $2 - opening quotemark
	   (.*)			# $3 - quotation
	   (''|\2)		# $4 closing quotemark
	   \s*?\n		# trailing whitespace
	   (\1[ ]+)		# $5 - leading whitespace (attribution)
	   (--|-)		# $6 - attribution introducer
	   (.*?$)		# $7 - attribution line 1
	   ((\5.*?$)*)		# $8 - attributions lines 2-N
	   \s*\Z
	 /xsm
	 or return;

	#print "[$1][$2][$3][$4][$5][$6][$7]\n";
	my $indent = length $1;
	my $text = $2.$3.$4;
	my $qindent = length $2;
	my $aindent = length $5;
	my $attribintro = $6;
	my $attrib = $7.$8;
	$text =~ s/\n/ /g;

	$_[0] .= 

				form {squeeze=>$args->{squeeze}, trim=>1,
          fill => $args->{expfill}
			       },
	   $format . q{ }x$indent . q{<}x$tlen,
             @$hang, $text,
	   $format . q{ }x($qindent) . q{[}x($tlen-$qindent), 
             @$hang, $text,
	   {squeeze=>0},
	   $format . q{ } x $aindent . q{>> } . q{[}x($tlen-$aindent-3),
             @$hang, $attribintro, $attrib;
	return 1;
}

# Emulation to avoid including POSIX:
sub strtod {
    my $str = $_[0]; # preserve the original.
    my ($num, $sign);

    # From the strtod manpage:
    # The expected form of the (initial portion of the) string
    # is optional leading white space as recognized by isspace(3),
    $str =~ s/^\s*//;

    # an optional plus (``+'') or minus sign (``-'')
    $sign = $str =~ s/^([-+])//;
    $sign ||= '+';

    # NOTE: do hex first...
    # or (ii) a hexadecimal number,
    if ($str =~ s/^0x([0-9a-f]+(?:\.[0-9a-f]*)?)(?:p([-+]?)([0-9a-f]+))?//i) {
	my $exp = hex($3) || 0;
	$exp *= -1 if ($2 and $2 eq '-');
	$num = hex($1) * (2 ** $exp);
    }

    # NOTE: and then decimal second...
    # and then either (i) a decimal number, [decimal assumed to be '.']
    elsif ($str =~ s/^([0-9]+(?:\.[0-9]*)?)(?:[Ee]([-+]?)([0-9]+))?//) {
	my $exp = $3 || 0;
	$exp *= -1 if ($2 and $2 eq '-');
	$num = $1 * (10 ** $exp);
    }

    # or (iii) an infinity,
    elsif ($str =~ s/^(?:infinity|inf)//i) {
	$num = 'inf';
    }

    # or (iv) a NAN (not-a-number).
    elsif ($str =~ s/^NAN(?:\([^)]*\))?//i) {
	$num = 'nan';
    }

    $num = 0 unless defined $num;
    $num *= -1 if ($sign eq '-');

    return wantarray ? ($num, length($str)) : $num;
}

package Hang;

# ROMAN NUMERALS

sub inv($@) { my ($k, %inv)=shift; for(0..$#_) {$inv{$_[$_]}=$_*$k} %inv } 
my @unit= ( "" , qw ( I II III IV V VI VII VIII IX ));
my @ten = ( "" , qw ( X XX XXX XL L LX LXX LXXX XC ));
my @hund= ( "" , qw ( C CC CCC CD D DC DCC DCCC CM ));
my @thou= ( "" , qw ( M MM MMM ));
my %rval= (inv(1,@unit),inv(10,@ten),inv(100,@hund),inv(1000,@thou));
my $rbpat= join ")(",join("|",reverse @thou), join("|",reverse @hund), join("|",reverse @ten), join("|",reverse @unit);
my $rpat= join ")(?:",join("|",reverse @thou), join("|",reverse @hund), join("|",reverse @ten), join("|",reverse @unit);

sub fromRoman($)
{
    return 0 unless $_[0] =~ /^.*?($rbpat).*$/i;
    return $rval{uc $1} + $rval{uc $2} + $rval{uc $3} + $rval{uc $4};
}

sub toRoman($$)
{
    my ($num,$example) = @_;
    return '' unless $num =~ /^([0-3]??)(\d??)(\d??)(\d)$/;
    my $roman = $thou[$1||0] . $hund[$2||0] . $ten[$3||0] . $unit[$4||0];
    return $example=~/[A-Z]/ ? uc $roman : lc $roman;
}

# BITS OF A NUMERIC VALUE

my $num = q/(?:\d+)/;
my $rom = qq/(?:(?=[MDCLXVI])(?:$rpat))/;
my $let = q/[A-Za-z]/;
my $pbr = q/[[(<]/;
my $sbr = q/])>/;
my $ows = q/[ \t]*/;
my %close = ( '[' => ']', '(' => ')', '<' => '>', "" => '' );

my $hangPS      = qq{(?i:ps:|(?:p\\.?)+s\\.?(?:[ \\t]*:)?)};
my $hangNB      = qq{(?i:n\\.?b\\.?(?:[ \\t]*:)?)};
my $hangword    = qq{(?:(?:Note)[ \\t]*:)};
my $hangbullet  = qq{[*.+-]};
my $hang        = qq{(?:(?i)(?:$hangNB|$hangword|$hangbullet)(?=[ \t]))};

# IMPLEMENTATION

sub new { 
	my ($class, $orig) = @_;
	my $origlen = length $orig;
	my @vals;
	if ($_[1] =~ s#\A($hangPS)##) {
		@vals = { type => 'ps', val => $1 }
	}
	elsif ($_[1] =~ s#\A($hang)##) {
		@vals = { type => 'bul', val => $1 }
	}
	else {
		local $^W;
		my $cut;
		while (length $_[1]) {
			last if $_[1] =~ m#\A($ows)($abbrev)#
			     && (length $1 || !@vals);	# ws-separated or first

			$cut = $origlen - length $_[1];
			my $pre = $_[1] =~ s#\A($ows$pbr$ows)## ? $1 : "";
			my $val =  $_[1] =~ s#\A($num)##  && { type=>'num', val=>$1 }
			       || $_[1] =~ s#\A($rom)##i && { type=>'rom', val=>$1, nval=>fromRoman($1) }
			       || $_[1] =~ s#\A($let(?!$let))##i && { type=>'let', val=>$1 }
			       || { val => "", type => "" };
			$_[1] = $pre.$_[1] and last unless $val->{val};
			$val->{post} = $pre && $_[1] =~ s#\A($ows()[.:/]?[$close{$pre}][.:/]?)## && $1
		                     || $_[1] =~ s#\A($ows()[$sbr.:/])## && $1
		                     || "";
			$val->{pre}  = $pre;
			$val->{cut}  = $cut;
			push @vals, $val;
		}
		while (@vals && !$vals[-1]{post}) {
			$_[1] = substr($orig,pop(@vals)->{cut});
		}
	}
	# check for orphaned years...
	if (@vals==1 && $vals[0]->{type} eq 'num'
		     && $vals[0]->{val} >= 1000
		     && $vals[0]->{post} eq '.')  {
		$_[1] = substr($orig,pop(@vals)->{cut});

        }
	return NullHang->new if !@vals;
	bless \@vals, $class;
} 

sub incr {
	local $^W;
	my ($self, $prev, $prevsig) = @_;
	my $level;
	# check compatibility

	return unless $prev && !$prev->empty;

	for $level (0..(@$self<@$prev ? $#$self : $#$prev)) {
		if ($self->[$level]{type} ne $prev->[$level]{type}) {
			return if @$self<=@$prev;	# no incr if going up
			$prev = $prevsig;
			last;
		}
	}
	return unless $prev && !$prev->empty;
	if ($self->[0]{type} eq 'ps') {
		my $count = 1 + $prev->[0]{val} =~ s/(p[.]?)/$1/gi;
		$prev->[0]{val} =~ /^(p[.]?).*(s[.]?[:]?)/;
		$self->[0]{val} = $1  x $count . $2;
	}
	elsif ($self->[0]{type} eq 'bul') {
		# do nothing
	}
	elsif (@$self>@$prev) {	# going down level(s)
		for $level (0..$#$prev) {
				@{$self->[$level]}{'val','nval'} = @{$prev->[$level]}{'val','nval'};
		}
		for $level (@$prev..$#$self) {
				_reset($self->[$level]);
		}
	}
	else	# same level or going up
	{
		for $level (0..$#$self) {
			@{$self->[$level]}{'val','nval'} = @{$prev->[$level]}{'val','nval'};
		}
		_incr($self->[-1])
	}
}

sub _incr {
	local $^W;
	if ($_[0]{type} eq 'rom') {
		$_[0]{val} = toRoman(++$_[0]{nval},$_[0]{val});
	}
	else {
		$_[0]{val}++ unless $_[0]{type} eq 'let' && $_[0]{val}=~/Z/i;
	}
}

sub _reset {
	local $^W;
	if ($_[0]{type} eq 'rom') {
		$_[0]{val} = toRoman($_[0]{nval}=1,$_[0]{val});
	}
	elsif ($_[0]{type} eq 'let') {
		$_[0]{val} = $_[0]{val} =~ /[A-Z]/ ? 'A' : 'a';
	}
	else {
		$_[0]{val} = 1;
	}
}

sub stringify {
	my ($self) = @_;
	my ($str, $level) = ("");
	for $level (@$self) {
		local $^W;
		$str .= join "", @{$level}{'pre','val','post'};
	}
	return $str;
} 

sub val {
	my ($self, $i) = @_;
	return $self->[$i]{val};
}

sub fields { return scalar @{$_[0]} }

sub field {
	my ($self, $i, $newval) = @_;
	$self->[$i]{type} = $newval if @_>2;
	return $self->[$i]{type};
}

sub signature {
	local $^W;
	my ($self) = @_;
	my ($str, $level) = ("");
	for $level (@$self) {
		$level->{type} ||= "";
		$str .= join "", $level->{pre},
		                 ($level->{type} =~ /rom|let/ ? "romlet" : $level->{type}),
		                 $level->{post};
	}
	return $str;
} 

sub length {
	length $_[0]->stringify
}

sub empty { 0 }

package NullHang;

sub new       { bless {}, $_[0] }
sub stringify { "" }
sub length    { 0 }
sub incr      {}
sub empty     { 1 }
sub signature     { "" }
sub fields { return 0 }
sub field { return "" }
sub val { return "" }
1;

__END__

=head1 NAME

Text::Autoformat - Automatic and manual text wrapping and reformating formatting

=head1 VERSION

This document describes version 1.04 of Text::Autoformat,
released December  5, 2000.

=head1 SYNOPSIS

 # Minimal use: read from STDIN, format to STDOUT...

	use Text::Autoformat;
	autoformat;

 # In-memory formatting...

	$formatted = autoformat $rawtext;

 # Configuration...

	$formatted = autoformat $rawtext, { %options };

 # Margins (1..72 by default)...

	$formatted = autoformat $rawtext, { left=>8, right=>70 };

 # Justification (left by default)...

	$formatted = autoformat $rawtext, { justify => 'left' };
	$formatted = autoformat $rawtext, { justify => 'right' };
	$formatted = autoformat $rawtext, { justify => 'full' };
	$formatted = autoformat $rawtext, { justify => 'centre' };

 # Filling (does so by default)...

	$formatted = autoformat $rawtext, { fill=>0 };

 # Squeezing whitespace (does so by default)...

	$formatted = autoformat $rawtext, { squeeze=>0 };

 # Case conversions...

	$formatted = autoformat $rawtext, { case => 'lower' };
	$formatted = autoformat $rawtext, { case => 'upper' };
	$formatted = autoformat $rawtext, { case => 'sentence' };
	$formatted = autoformat $rawtext, { case => 'title' };
	$formatted = autoformat $rawtext, { case => 'highlight' };


=head1 BACKGROUND

=head2 The problem

Perl plaintext formatters just aren't smart enough. Given a typical
piece of plaintext in need of formatting:

        In comp.lang.perl.misc you wrote:
        : > <CN = Clooless Noobie> writes:
        : > CN> PERL sux because:
        : > CN>    * It doesn't have a switch statement and you have to put $
        : > CN>signs in front of everything
        : > CN>    * There are too many OR operators: having |, || and 'or'
        : > CN>operators is confusing
        : > CN>    * VB rools, yeah!!!!!!!!!
        : > CN> So anyway, how can I stop reloads on a web page?
        : > CN> Email replies only, thanks - I don't read this newsgroup.
        : >
        : > Begone, sirrah! You are a pathetic, Bill-loving, microcephalic
        : > script-infant.
        : Sheesh, what's with this group - ask a question, get toasted! And how
        : *dare* you accuse me of Ianuphilia!

both the venerable Unix L<fmt> tool and Perl's standard Text::Wrap module
produce:

        In comp.lang.perl.misc you wrote:  : > <CN = Clooless Noobie>
        writes:  : > CN> PERL sux because:  : > CN>    * It doesn't
        have a switch statement and you have to put $ : > CN>signs in
        front of everything : > CN>    * There are too many OR
        operators: having |, || and 'or' : > CN>operators is confusing
        : > CN>    * VB rools, yeah!!!!!!!!!  : > CN> So anyway, how
        can I stop reloads on a web page?  : > CN> Email replies only,
        thanks - I don't read this newsgroup.  : > : > Begone, sirrah!
        You are a pathetic, Bill-loving, microcephalic : >
        script-infant.  : Sheesh, what's with this group - ask a
        question, get toasted! And how : *dare* you accuse me of
        Ianuphilia!

Other formatting modules -- such as Text::Correct and Text::Format --
provide more control over their output, but produce equally poor results
when applied to arbitrary input. They simply don't understand the
structural conventions of the text they're reformatting.

=head2 The solution

The Text::Autoformat module provides a subroutine named C<autoformat> that
wraps text to specified margins. However, C<autoformat> reformats its
input by analysing the text's structure, so it wraps the above example
like so:

        In comp.lang.perl.misc you wrote:
        : > <CN = Clooless Noobie> writes:
        : > CN> PERL sux because:
        : > CN>    * It doesn't have a switch statement and you
        : > CN>      have to put $ signs in front of everything
        : > CN>    * There are too many OR operators: having |, ||
        : > CN>      and 'or' operators is confusing
        : > CN>    * VB rools, yeah!!!!!!!!! So anyway, how can I
        : > CN>      stop reloads on a web page? Email replies
        : > CN>      only, thanks - I don't read this newsgroup.
        : >
        : > Begone, sirrah! You are a pathetic, Bill-loving,
        : > microcephalic script-infant.
        : Sheesh, what's with this group - ask a question, get toasted!
        : And how *dare* you accuse me of Ianuphilia!

Note that the various quoting conventions have been observed. In fact,
their structure has been used to determine where some paragraphs begin.
Furthermore C<autoformat> correctly distinguished between the leading
'*' bullets of the nested list (which were outdented) and the leading
emphatic '*' of "*dare*" (which was inlined).

=head1 DESCRIPTION

=head2 Paragraphs

The fundamental task of the C<autoformat> subroutine is to identify and
rearrange independent paragraphs in a text. Paragraphs typically consist
of a series of lines containing at least one non-whitespace character,
followed by one or more lines containing only optional whitespace.
This is a more liberal definition than many other formatters
use: most require an empty line to terminate a paragraph. Paragraphs may
also be denoted by bulleting, numbering, or quoting (see the following
sections).

Once a paragraph has been isolated, C<autoformat> fills and re-wraps its
lines according to the margins that are specified in its argument list.
These are placed after the text to be formatted, in a hash reference:

        $tidied = autoformat($messy, {left=>20, right=>60});

By default, C<autoformat> uses a left margin of 1 (first column) and a
right margin of 72.

Normally, C<autoformat> only reformats the first paragraph it encounters,
and leaves the remainder of the text unaltered. This behaviour is useful
because it allows a one-liner invoking the subroutine to be mapped
onto a convenient keystroke in a text editor, to provide 
one-paragraph-at-a-time reformatting:

        % cat .exrc

        map f !Gperl -MText::Autoformat -e'autoformat'

(Note that to facilitate such one-liners, if C<autoformat> is called
in a void context without any text data, it takes its text from
C<STDIN> and writes its result to C<STDOUT>).

To enable C<autoformat> to rearrange the entire input text at once, the
C<all> argument is used:

        $tidied_all = autoformat($messy, {left=>20, right=>60, all=>1});


=head2 Bulleting and (re-)numbering

Often plaintext will include lists that are either:

        * bulleted,
        * simply numbered (i.e. 1., 2., 3., etc.), or
        * hierarchically numbered (1, 1.1, 1.2, 1.3, 2, 2.1. and so forth).

In such lists, each bulleted item is implicitly a separate paragraph,
and is formatted individually, with the appropriate indentation:

        * bulleted,
        * simply numbered (i.e. 1., 2., 3.,
          etc.), or
        * hierarchically numbered (1, 1.1,
          1.2, 1.3, 2, 2.1. and so forth).

More importantly, if the points are numbered, the numbering is
checked and reordered. For example, a list whose points have been
rearranged:

        2. Analyze problem
        3. Design algorithm
        1. Code solution
        5. Test
        4. Ship

would be renumbered automatically by C<autoformat>:

        1. Analyze problem
        2. Design algorithm
        3. Code solution
        4. Ship
        5. Test

The same reordering would be performed if the "numbering" was by letters
(C<a.> C<b.> C<c.> etc.) or Roman numerals (C<i.> C<ii.> C<iii.)> or by
some combination of these (C<1a.> C<1b.> C<2a.> C<2b.> etc.) Handling
disordered lists of letters and Roman numerals presents an interesting
challenge. A list such as:

        C. Put cat in box.
        D. Close lid.
        E. Activate Geiger counter.

should be reordered as C<A.> C<B.> C<C.,> whereas:

        C. Put cat in box.
        D. Close lid.
        XLI. Activate Geiger counter.

should be reordered C<I.> C<II.> C<III.> 

The C<autoformat> subroutine solves this problem by always interpreting 
alphabetic bullets as being letters, unless the full list consists
only of valid Roman numerals, at least one of which is two or
more characters long.

=head2 Quoting

Another case in which contiguous lines may be interpreted as belonging
to different paragraphs, is where they are quoted with distinct
quoters. For example:

        : > CN> So anyway, how can I stop reloads on a web page?
        : > CN> Email replies only, thanks - I don't read this newsgroup.
        : > Begone, sirrah! You are a pathetic, Bill-loving,
        : > microcephalic script-infant.
        : Sheesh, what's with this group - ask a question, get toasted!
        : And how *dare* you accuse me of Ianuphilia!

C<autoformat> recognizes the various quoting conventions used in this example
and treats it as three paragraphs to be independently reformatted.

Block quotations present a different challenge. A typical formatter would
render the following quotation:

        "We are all of us in the gutter,
         but some of us are looking at the stars"
                                -- Oscar Wilde

like so:

        "We are all of us in the gutter, but some of us are looking at
        the stars" -- Oscar Wilde

C<autoformat> recognizes the quotation structure by matching the following regular
expression against the text component of each paragraph:

        / \A(\s*)               # leading whitespace for quotation
          (["']|``)             # opening quotemark
          (.*)                  # quotation
          (''|\2)               # closing quotemark
          \s*?\n                # trailing whitespace after quotation
          (\1[ ]+)              # leading whitespace for attribution
                                #   (must be indented more than quotation)
          (--|-)                # attribution introducer
          ([^\n]*?\n)           # first attribution line
          ((\5[^\n]*?$)*)       # other attribution lines 
                                #   (indented no less than first line)
          \s*\Z                 # optional whitespace to end of paragraph
        /xsm

When reformatted (see below), the indentation and the attribution
structure will be preserved:

        "We are all of us in the gutter, but some of us are looking
         at the stars"
                                -- Oscar Wilde

=head2 Widow control

Note that in the last example, C<autoformat> broke the line at column
68, four characters earlier than it should have. It did so because, if
the full margin width had been used, the formatting would have left the
last two words by themselves on an oddly short last line:

        "We are all of us in the gutter, but some of us are looking at
         the stars"

This phenomenon is known as "widowing" and is heavily frowned upon in
typesetting circles. It looks ugly in plaintext too, so C<autoformat> 
avoids it by stealing extra words from earlier lines in a
paragraph, so as to leave enough for a reasonable last line. The heuristic
used is that final lines must be at least 10 characters long (though
this number may be adjusted by passing a C<widow =E<gt> I<minlength>>
argument to C<autoformat>).

If the last line is too short,
the paragraph's right margin is reduced by one column, and the paragraph
is reformatted. This process iterates until either the last line exceeds
nine characters or the margins have been narrowed by 10% of their
original separation. In the latter case, the reformatter gives up and uses its
original formatting.


=head2 Justification

The C<autoformat> subroutine also takes a named argument: C<{justify
=E<gt> I<type>}>, which specifies how each paragraph is to be justified.
The options are: C<'left'> (the default), C<'right',> C<'centre'> (or
C<'center'>), and C<'full'>. These act on the complete paragraph text
(but I<not> on any quoters before that text). For example, with C<'right'>
justification:

        R3>     Now is the Winter of our discontent made
        R3> glorious Summer by this son of York. And all
        R3> the clouds that lour'd upon our house In the
        R3>              deep bosom of the ocean buried.

Full justification is interesting in a fixed-width medium like plaintext
because it usually results in uneven spacing between words. Typically,
formatters provide this by distributing the extra spaces into the first
available gaps of each line:

        R3> Now  is  the  Winter  of our discontent made
        R3> glorious Summer by this son of York. And all
        R3> the  clouds  that  lour'd  upon our house In
        R3> the deep bosom of the ocean buried.

This produces a rather jarring visual effect, so C<autoformat> reverses
the strategy and inserts extra spaces at the end of lines:

        R3> Now is the Winter  of  our  discontent  made
        R3> glorious Summer by this son of York. And all
        R3> the clouds that lour'd  upon  our  house  In
        R3> the deep bosom of the ocean buried.

Most readers find this less disconcerting.

=head2 Implicit centring

Even if explicit centring is not specified, C<autoformat> will attempt
to automatically detect centred paragraphs and preserve their
justification. It does this by examining each line of the paragraph and
asking: "if this line were part of a centred paragraph, where would the
centre line have been?"

The answer can be determined by adding the length of leading whitespace
before the first word, plus half the length of the full set of words
on the line. That is, for a single line:

        $line =~ /^(\s*)(.*?)(\s*)$/
        $centre = length($1)+0.5*length($2);

By making the same estimate for every line, and then comparing the
estimates, it is possible to deduce whether all the lines are centred
with respect to the same axis of symmetry (with an allowance of
E<plusminus>1 to cater for the inevitable rounding when the centre
positions of even-length rows were originally computed). If a common
axis of symmetry is detected, C<autoformat> assumes that the lines are
supposed to be centred, and switches to centre-justification mode for
that paragraph.

=head2 Case transformations

The C<autoformat> subroutine can also optionally perform case conversions
on the text it processes. The C<{case =E<gt> I<type>}> argument allows the
user to specify five different conversions:

=over 4

=item C<'upper'>

This mode unconditionally converts every letter in the reformatted text to upper-case;

=item C<'lower'>

This mode unconditionally converts every letter in the reformatted text to lower-case;

=item C<'sentence'>

This mode attempts to generate correctly-cased sentences from the input text.
That is, the first letter after a sentence-terminating punctuator is converted
to upper-case. Then, each subsequent word in the sentence is converted to
lower-case, unless that word is originally mixed-case or contains punctuation.
For example, under C<{case =E<gt> 'sentence'}>:

        'POVERTY, MISERY, ETC. are the lot of the PhD candidate. alas!'

becomes:

        'Poverty, misery, etc. are the lot of the PhD candidate. Alas!'

Note that C<autoformat> is clever enough to recognize that the period after abbreviations such as C<etc.> is not a sentence terminator.

If the argument is specified as C<'sentence  '> (with one or more trailing
whitespace characters) those characters are used to replace the single space
that appears at the end of the sentence. For example,
C<autoformat($text, {case=E<gt>'sentence  '}>) would produce:

        'Poverty, misery, etc. are the lot of the PhD candidate.  Alas!'

=item C<'title'>

This mode behaves like C<'sentence'> except that the first letter of
I<every> word is capitalized:

        'What I Did On My Summer Vacation In Monterey'

=item C<'highlight'>

This mode behaves like C<'title'> except that trivial words are not
capitalized:

        'What I Did on my Summer Vacation in Monterey'

=back

=head1 OTHER FEATURES

=head2 The C<form> sub

The C<form()> subroutine may be exported from the module.
It takes a series of format (or "picture") strings followed by
replacement values, interpolates those values into each picture string,
and returns the result. The effect is similar to the inbuilt perl
C<format> mechanism, although the field specification syntax is
simpler and some of the formatting behaviour is more sophisticated.

A picture string consists of sequences of the following characters:

=over 8

=item <

Left-justified field indicator.
A series of sequential <'s specify
a left-justified field to be filled by a subsequent value.

=item >

Right-justified field indicator.
A series of sequential >'s specify
a right-justified field to be filled by a subsequent value.

=item ^

Centre-justified field indicator.
A series of sequential ^'s specify
a centred field to be filled by a subsequent value.

=item >>>.<<<<

A numerically formatted field with the specified number of digits to
either side of the decimal place. See L<Numerical formatting> below.


=item [

Left-justified block field indicator.
Just like a < field, except it repeats as required on subsequent lines. See
below.

=item ]

Right-justified block field indicator.
Just like a > field, except it repeats as required on subsequent lines. See
below.

=item |

Centre-justified block field indicator.
Just like a ^ field, except it repeats as required on subsequent lines. See
below.

=item ]]].[[[[

A numerically formatted block field with the specified number of digits to
either side of the decimal place.
Just like a >>>.<<<< field, except it repeats as required on
subsequent lines. See below. 

=item \

Literal escape of next character (e.g. C<\|> is formatted as '|', not a one
character wide centre-justified block field).

=item Any other character

That literal character.

=back

Any substitution value which is C<undef> (either explicitly so, or because it
is missing) is replaced by an empty string.



=head2 Controlling line filling.

Note that, unlike the a perl C<format>, C<form> preserves whitespace
(including newlines) unless called with certain options.

The "squeeze" option (when specified with a true value) causes any sequence
of spaces and/or tabs (but not newlines) in an interpolated string to be
replaced with a single space.

The "fill" option causes newlines to also be squeezed.

Hence:

	$frmt = "# [[[[[[[[[[[[[[[[[[[[[";
	$data = "h  e\t \tl lo\nworld\t\t\t\t\t";

	print form $frmt, $data;
	# h  e            l lo
	# world

	print form {squeeze=>1}, $frmt, $data;
	# h e l lo
	# world

	print form {fill=>1}, $frmt, $data;
	# h  e            l lo world

	print form {squeeze=>1, fill=>1}, $frmt, $data;
	# h e l lo world


Whether or not filling or squeezing is in effect, C<form> can also be
directed to trim any extra whitespace from the end of each line it
formats, using the "trim" option. If this option is specified with a
true value, every line returned by C<form> will automatically have the
substitution C<s/[ \t]+$//gm> applied to it.

Hence:

	print length form "[[[[[[[[[[", "short";
	# 11

	print length form {trim=>1}, "[[[[[[[[[[", "short";
	# 6



=head2 Temporary and permanent default options

If C<form> is called with options, but no template string or data, it resets
it's defaults to the options specified. If called in a void context:

        form { squeeze => 1, trim => 1 };

the options become permanent defaults.

However, when called with only options in non-void context, C<form>
resets its defaults to those options and returns an object. The reset
default values persist only until that returned object is destroyed.
Hence to temporarily reset C<form>'s defaults within a single subroutine:

        sub single {
                my $tmp = form { squeeze => 1, trim => 1 };

                # do formatting with the obove defaults

        } # form's defaults revert to previous values as $tmp object destroyed


=head2 How C<form> hyphenates

Any line with a block field repeats on subsequent lines until all block fields
on that line have consumed all their data. Non-block fields on these lines are
replaced by the appropriate number of spaces.

Words are wrapped whole, unless they will not fit into the field at
all, in which case they are broken and (by default) hyphenated. Simple
hyphenation is used (i.e. break at the I<N-1>th character and insert a
'-'), unless a suitable alternative subroutine is specified instead.

Words will not be broken if the break would leave less than 2 characters on
the current line. This minimum can be varied by setting the 'minbreak' option
to a numeric value indicating the minumum total broken characters (including
hyphens) required on the current line. Note that, for very narrow fields,
words will still be broken (but I<unhyphenated>). For example:

        print form '|', 'split';

would print:

        s
        p
        l
        i
        t

whilst:

        print form {minbreak=>1}, '|', 'split';

would print:

        s-
        p-
        l-
        i-
        t

Alternative breaking subroutines can be specified using the "break" option in a
configuration hash. For example:

        form { break => \&my_line_breaker }
             $format_str,
             @data;

C<form> expects any user-defined line-breaking subroutine to take three
arguments (the string to be broken, the maximum permissible length of
the initial section, and the total width of the field being filled).
The C<hypenate> sub must return a list of two strings: the initial
(broken) section of the word, and the remainder of the string
respectively).

For example:

        sub tilde_break = sub($$$)
        {
                (substr($_[0],0,$_[1]-1).'~', substr($_[0],$_[1]-1));
        }

        form { break => \&tilde_break }
             $format_str,
             @data;


makes '~' the hyphenation character, whilst:

        sub wrap_and_slop = sub($$$)
        {
                my ($text, $reqlen, $fldlen) = @_;
                if ($reqlen==$fldlen) { $text =~ m/\A(\s*\S*)(.*)/s }
                else                  { ("", $text) }
        }

        form { break => \&wrap_and_slop }
             $format_str,
             @data;

wraps excessively long words to the next line and "slops" them over
the right margin if necessary.

The Text::Autoformat package provides three functions to simplify the use
of variant hyphenation schemes. The exportable subroutine
C<Text::Autoformat::break_wrap> generates a reference to a subroutine
implementing the "wrap-and-slop" algorithm shown in the last example,
which could therefore be rewritten:

        use Text::Autoformat qw( form break_wrap );

        form { break => break_wrap }
             $format_str,
             @data;

The subroutine C<Text::Autoformat::break_with> takes a single string
argument and returns a reference to a sub which hyphenates with that
string. Hence the first of the two examples could be rewritten:

        use Text::Autoformat qw( form break_wrap );

        form { break => break_with('~') }
             $format_str,
             @data;

The subroutine C<Text::Autoformat::break_TeX> 
returns a reference to a sub which hyphenates using 
Jan Pazdziora's TeX::Hyphen module. For example:

        use Text::Autoformat qw( form break_wrap );

        form { break => break_TeX }
             $format_str,
             @data;

Note that in the previous examples there is no leading '\&' before
C<break_wrap>, C<break_with>, or C<break_TeX>, since each is being
directly I<called> (and returns a reference to some other suitable
subroutine);


=head2 The C<form> formatting algorithm

The algorithm C<form> uses is:

        1. split the first string in the argument list
           into individual format lines and add a terminating
           newline (unless one is already present).

        2. for each format line...

                2.1. determine the number of fields and shift
                     that many values off the argument list and
                     into the filling list. If insufficient
                     arguments are available, generate as many 
                     empty strings as are required.

                2.2. generate a text line by filling each field
                     in the format line with the initial contents
                     of the corresponding arg in the filling list
                     (and remove those initial contents from the arg).

                2.3. replace any <,>, or ^ fields by an equivalent
                     number of spaces. Splice out the corresponding
                     args from the filling list.

                2.4. Repeat from step 2.2 until all args in the
                     filling list are empty.

        3. concatenate the text lines generated in step 2

        4. repeat from step 1 until the argument list is empty


=head2 C<form> examples

As an example of the use of C<form>, the following:

        $count = 1;
        $text = "A big long piece of text to be formatted exquisitely";

        print form q
        {
                ||||  <<<<<<<<<<
                ----------------
                ^^^^  ]]]]]]]]]]\|
                                =
                ]]].[[[
                
        }, $count, $text, $count+11, $text, "123 123.4\n123.456789";

produces the following output:

                 1    A big long
                ----------------
                 12     piece of|
                      text to be|
                       formatted|
                      exquisite-|
                              ly|
                                =
                123.0
                123.4
                123.456

Picture strings and replacement values can be interleaved in the
traditional C<format> format, but care is needed to ensure that the
correct number of substitution values are provided. For example:

        $report = form
                'Name           Rank    Serial Number',
                '====           ====    =============',
                '<<<<<<<<<<<<<  ^^^^    <<<<<<<<<<<<<',
                 $name,         $rank,  $serial_number,
                ''
                'Age    Sex     Description',
                '===    ===     ===========',
                '^^^    ^^^     [[[[[[[[[[[',
                 $age,  $sex,   $description;


=head2 How C<form> consumes strings

Unlike C<format>, within C<form> non-block fields I<do> consume the text
they format, so the following:

        $text = "a line of text to be formatted over three lines";
        print form "<<<<<<<<<<\n  <<<<<<<<\n    <<<<<<\n",
                    $text,        $text,        $text;

produces:

        a line of
          text to
            be fo-

not:

        a line of
          a line 
            a line

To achieve the latter effect, convert the variable arguments
to independent literals (by double-quoted interpolation):

        $text = "a line of text to be formatted over three lines";
        print form "<<<<<<<<<<\n  <<<<<<<<\n    <<<<<<\n",
                   "$text",      "$text",      "$text";

Although values passed from variable arguments are progressively consumed
I<within> C<form>, the values of the original variables passed to C<form>
are I<not> altered.  Hence:

        $text = "a line of text to be formatted over three lines";
        print form "<<<<<<<<<<\n  <<<<<<<<\n    <<<<<<\n",
                    $text,        $text,        $text;
        print $text, "\n";

will print:

        a line of
          text to
            be fo-
        a line of text to be formatted over three lines

To cause C<form> to consume the values of the original variables passed to
it, pass them as references. Thus:

        $text = "a line of text to be formatted over three lines";
        print form "<<<<<<<<<<\n  <<<<<<<<\n    <<<<<<\n",
                    \$text,       \$text,       \$text;
        print $text, "\n";

will print:

        a line of
          text to
            be fo-
        rmatted over three lines

Note that, for safety, the "non-consuming" behaviour takes precedence,
so if a variable is passed to C<form> both by reference I<and> by value,
its final value will be unchanged.

=head2 Numerical formatting

The ">>>.<<<" and "]]].[[[" field specifiers may be used to format
numeric values about a fixed decimal place marker. For example:

        print form '(]]]]].[[)', <<EONUMS;
                   1
                   1.0
                   1.001
                   1.009
                   123.456
                   1234567
                   one two
        EONUMS

would print:
                   
        (    1.0 )
        (    1.0 )
        (    1.00)
        (    1.01)
        (  123.46)
        (#####.##)
        (?????.??)
        (?????.??)

Fractions are rounded to the specified number of places after the
decimal, but only significant digits are shown. That's why, in the
above example, 1 and 1.0 are formatted as "1.0", whilst 1.001 is
formatted as "1.00".

You can specify that the maximal number of decimal places always be used
by giving the configuration option 'numeric' a value that matches
/\bAllPlaces\b/i. For example:

        print form { numeric => AllPlaces },
                   '(]]]]].[[)', <<'EONUMS';
                   1
                   1.0
        EONUMS

would print:
                   
        (    1.00)
        (    1.00)

Note that although decimal digits are rounded to fit the specified width, the
integral part of a number is never modified. If there are not enough places
before the decimal place to represent the number, the entire number is 
replaced with hashes.

If a non-numeric sequence is passed as data for a numeric field, it is
formatted as a series of question marks. This querulous behaviour can be
changed by giving the configuration option 'numeric' a value that
matches /\bSkipNaN\b/i in which case, any invalid numeric data is simply
ignored. For example:


        print form { numeric => 'SkipNaN' }
                   '(]]]]].[[)',
                   <<EONUMS;
                   1
                   two three
                   4
        EONUMS

would print:
                   
        (    1.0 )
        (    4.0 )


=head2 Filling block fields with lists of values

If an argument corresponding to a field is an array reference, then C<form>
automatically joins the elements of the array into a single string, separating
each element with a newline character. As a result, a call like this:

        @values = qw( 1 10 100 1000 );
        print form "(]]]].[[)", \@values;

will print out

         (   1.00)
         (  10.00)
         ( 100.00)
         (1000.00)

as might be expected.

Note however that arrays must be passed by reference (so that C<form>
knows that the entire array holds data for a single field). If the previous
example had not passed @values by reference:

        @values = qw( 1 10 100 1000 );
        print form "(]]]].[[)", @values;

the output would have been:

         (   1.00)
         10
         100
         1000

This is because @values would have been interpolated into C<form>'s
argument list, so only $value[0] would have been used as the data for
the initial format string. The remaining elements of @value would have
been treated as separate format strings, and printed out "verbatim".

Note too that, because arrays must be passed using a reference, their
original contents are consumed by C<form>, just like the contents of
scalars passed by reference.

To avoid having an array consumed by C<form>, pass it as an anonymous
array:

        print form "(]]]].[[)", [@values];


=head2 Headers, footers, and pages

The C<form> subroutine can also insert headers, footers, and page-feeds
as it formats. These features are controlled by the "header", "footer",
"pagefeed", "pagelen", and "pagenum" options.

The "pagenum" option takes a scalar value or a reference to a scalar
variable and starts page numbering at that value. If a reference to a
scalar variable is specified, the value of that variable is updated as
the formatting proceeds, so that the final page number is available in
it after formatting. This can be useful for multi-part reports.

The "pagelen" option specifies the total number of lines in a page (including
headers, footers, and page-feeds).

If the "header" option is specified with a string value, that string is
used as the header of every page generated. If it is specified as a reference
to a subroutine, that subroutine is called at the start of every page and
its return value used as the header string. When called, the subroutine is
passed the current page number.

Likewise, if the "footer" option is specified with a string value, that
string is used as the footer of every page generated. If it is specified
as a reference to a subroutine, that subroutine is called at the I<start>
of every page and its return value used as the footer string. When called,
the footer subroutine is passed the current page number. If the option is
specified as a hash, it acts as described above for the "header" option.

Both the header and footer options can also be specified as hash references.
In this case the hash entires for keys "left", "centre" (or "center"), and
"right" specify what is to appear on the left, centre, and right of the
header/footer. The entry for the key "width" specifies how wide the
footer is to be. The  "left", "centre", and "right" values may be literal
strings, or subroutines (just as a normal header/footer specification may
be.) See the second example, below.

The "pagefeed" option acts in exactly the same way, to produce a
pagefeed which is appended after the footer. But note that the pagefeed
is not counted as part of the page length.

All three of these page components are recomputed at the start of each
new page, before the page contents are formatted (recomputing the header
and footer makes it possible to determine how many lines of data to
format so as to adhere to the specified page length).

When the call to C<form> is complete and the data has been fully formatted,
the footer subroutine is called one last time, with an extra argument of 1.
The string returned by this final call is used as the final footer.

So for example, a 60-line per page report, starting at page 7,
with appropriate headers and footers might be set up like so:

        $page = 7;

        form { header => sub { "Page $_[0]\n\n" },
               footer => sub { return "" if $_[1];
                               "-"x50 . "\n" . form ">"x50", "...".($_[0]+1);
                             },
               pagefeed => "\n\n",
               pagelen  => 60
               pagenum  => \$page,
             },
             $template,
             @data;

Note the recursive use of C<form> within the "footer" option.

Alternatively, to set up headers and footers such that the running
head is right justified in the header and the page number is centred
in the footer:

        form { header => { right => "Running head" },
               footer => { centre => sub { "Page $_[0]" } },
               pagelen  => 60
             },
             $template,
             @data;



=head2 The C<tag> sub

The C<tag> subroutine may be exported from the module.
It takes two arguments: a tag specifier and a text to be
entagged. The tag specifier indicates the indenting of the tag, and of the
text. The sub generates an end-tag (using the usual "/I<tag>" variant),
unless an explicit end-tag is provided as the third argument.

The tag specifier consists of the following components (in order):

=over 4

=item An optional vertical spacer (zero or more whitespace-separated newlines)

One or more whitespace characters up to a final mandatory newline. This
vertical space is inserted before the tag and after the end-tag

=item An optional tag indent

Zero or more whitespace characters. Both the tag and the end-tag are indented
by this whitespace.

=item An optional left (opening) tag delimiter

Zero or more non-"word" characters (not alphanumeric or '_').
If the opening delimiter is omitted, the character '<' is used.

=item A tag

One or more "word" characters (alphanumeric or '_').

=item Optional tag arguments

Any number of any characters

=item An optional right (closing) tag delimiter

Zero or more non-"word" characters which balance some sequential portion
of the opening tag delimiter. For example, if the opening delimiter
is "<-(" then any of the following are acceptible closing delimiters:
")->", "->", or ">".
If the closing delimiter is omitted, the "inverse" of the opening delimiter 
is used (for example, ")->"),

=item An optional vertical spacer (zero or more newlines)

One or more whitespace characters up to a mandatory newline. This
vertical space is inserted before and after the complete text.

=item An optional text indent

Zero or more space of tab characters. Each line of text is indented
by this whitespace (in addition to the tag indent).


=back

For example:

        $text = "three lines\nof tagged\ntext";

        print tag "A HREF=#nextsection", $text;

prints:

        <A HREF=#nextsection>three lines
        of tagged
        text</A>

whereas:

        print tag "[-:GRIN>>>\n", $text;

prints:

        [-:GRIN>>>:-]
        three lines
        of tagged
        text
        [-:/GRIN>>>:-]

and:

        print tag "\n\n   <BOLD>\n\n   ", $text, "<END BOLD>";

prints:

S< >

           <BOLD>

              three lines
              of tagged
              text

           <END BOLD>

S< >

(with the indicated spacing fore and aft).

=head1 AUTHOR

Damian Conway (damian@conway.org)

=head1 BUGS

There are undoubtedly serious bugs lurking somewhere in code this funky :-)
Bug reports and other feedback are most welcome.

=head1 COPYRIGHT

Copyright (c) 1997-2000, Damian Conway. All Rights Reserved.
This module is free software. It may be used, redistributed
and/or modified under the terms of the Perl Artistic License
  (see http://www.perl.com/perl/misc/Artistic.html)
