package Regexp::Common::zip;

use strict;
local $^W = 1;

use Regexp::Common qw /pattern clean no_defaults/;
use Carp;

use vars qw /$VERSION/;

($VERSION) = q $Revision: 1.1 $ =~ /[\d.]+/;

#
# Prefer '[0-9]' over \d, because the latter may include more
# in Unicode string.
#

my %code = (
    Australia         =>  [qw /AUS? AU AUS/],
    Belgium           =>  [qw /BE?  BE B/],
    Denmark           =>  [qw /DK   DK DK/],
    France            =>  [qw /FR?  FR F/],
    Germany           =>  [qw /DE?  DE D/],
    Greenland         =>  [qw /DK   DK DK/],
    Netherlands       =>  [qw /NL   NL NL/],
    USA               =>  [qw /USA? US USA/],
);

# Returns the empty string if the argument is undefined, the argument otherwise.
sub __ {defined $_ [0] ? $_ [0] : ""}

# Used for allowable options. If the value starts with 'y', the option is
# required ("{1,1}" is returned, if the value starts with 'n', the option
# is disallowed ("{0,0}" is returned), otherwise, the option is allowed,
# but not required ("{0,1}" is returned).
sub _t {
    if (defined $_ [0]) {
        if ($_ [0] =~ /^y/i) {return "{1,1}"}
        if ($_ [0] =~ /^n/i) {return "{0,0}"}
    }
    "{0,1}"
}

# Returns the (sub)pattern for the country named '$name', and the 
# -country option '$country'.
sub _c {
    my ($name, $country) = @_;
    if (defined $country && $country ne "") {
        if ($country eq 'iso')  {return $code {$name} [1]}
        if ($country eq 'cept') {return $code {$name} [2]}
        return $country;
    }
    $code {$name} [0]
}


my %zip = (
    Australia   =>  "(?k:(?k:[1-8][0-9]|9[0-7]|0?[28])(?k:[0-9]{2}))",
                    # Postal codes of the form 'DDDD', with the first
                    # two digits 02, 08 or 20-97. Leading 0 may be omitted.

    Belgium     =>  "(?k:(?k:[1-9])(?k:[0-9]{3}))",
                    # Postal codes of the form: 'DDDD', with the first
                    # digit representing the province; the others
                    # distribution sectors. Postal codes do not start
                    # with a zero.

    Denmark     =>  "(?k:(?k:[1-9])(?k:[0-9])(?k:[0-9]{2}))",
                    # Postal codes of the form: 'DDDD', with the first
                    # digit representing the distribution region, the
                    # second digit the distribution district. Postal
                    # codes do not start with a zero. Postal codes 
                    # starting with '39' are in Greenland.

    France      =>  "(?k:(?k:0[1-9]|[1-8][0-9]|9[0-8])(?k:[0-9]{3}))",
                    # Postal codes of the form: 'DDDDD'. All digits are used.
                    # First two digits indicate the department, and range
                    # from 01 to 98.

    Germany     =>  "(?k:(?k:[0-9])(?k:[0-9])(?k:[0-9]{3}))",
                    # Postal codes of the form: 'DDDDD'. All digits are used.
                    # First digit is the distribution zone, second a
                    # distribution region. Other digits indicate the
                    # distribution district and postal town.

    Greenland   =>  "(?k:(?k:39)(?k:[0-9]{2}))",
                    # Postal codes of Greenland are part of the Danish
                    # system. Codes in Greenland start with 39.
);

my %alternatives = (
    Australia    => [qw /Australian/],
    France       => [qw /French/],
    Germany      => [qw /German/],
);


while (my ($country, $zip) = each %zip) {
    my @names = ($country);
    push @names => @{$alternatives {$country}} if $alternatives {$country};
    foreach my $name (@names) {
        pattern name   => [zip => $name, qw /-prefix= -country=/],
                create => sub {
                    my $pt  = _t $_ [1] {-prefix};

                    my $cn  = _c $country => $_ [1] {-country};
                    my $pfx = "(?:(?k:$cn)-)";

                    "(?k:$pfx$pt$zip)";
                },
                ;
    }
}


# Postal codes of the form 'DDDD LL', with F, I, O, Q, U and Y not
# used, SA, SD and SS unused combinations, and the first digit
# cannot be 0. No specific meaning to the letters or digits.
foreach my $country (qw /Netherlands Dutch/) {
    pattern name   => ['zip', $country => qw /-prefix= -country=/, "-sep= "],
            create => sub {
                my $pt  = _t $_ [1] {-prefix};

                # Unused letters: F, I, O, Q, U, Y.
                # Unused combinations: SA, SD, SS.
                my $num =  '[1-9][0-9]{3}';
                my $let =  '[A-EGHJ-NPRTVWXZ][A-EGHJ-NPRSTVWXZ]|' .
                           'S[BCEGHJ-NPRTVWXZ]';

                my $sep = __ $_ [1] {-sep};
                my $cn  = _c Netherlands => $_ [1] {-country};
                my $pfx = "(?:(?k:$cn)-)";

                "(?k:$pfx$pt(?k:(?k:$num)(?k:$sep)(?k:$let)))";
            },
            ;
}


# Postal codes of the form 'DDDDD' or 'DDDDD-DDDD'. All digits are used,
# none carry any specific meaning.
pattern name    => [qw /zip US -prefix= -country= -extended= -sep=-/],
        create  => sub {
            my $pt  = _t $_ [1] {-prefix};
            my $et  = _t $_ [1] {-extended};

            my $sep = __ $_ [1] {-sep};

            my $cn  = _c USA => $_ [1] {-country};
            my $pfx = "(?:(?k:$cn)-)";
            my $zip = "(?k:[0-9]{5})";
            my $ext = "(?:(?k:$sep)(?k:[0-9]{4}))";

            "(?k:$pfx$pt(?k:$zip$ext$et))";
        },
        version => 5.00503,
        ;


# pattern name   => [qw /zip British/, "-sep= "],
#         create => sub {
#             my $sep     = $_ [1] -> {-sep};
# 
#             my $london  = '(?:EC[1-4]|WC[12]|S?W1)[A-Z]';
#             my $single  = '[BGLMS][0-9]{1,2}';
#             my $double  = '[A-Z]{2}[0-9]{1,2}';
# 
#             my $left    = "(?:$london|$single|$double)";
#             my $right   = '[0-9][ABD-HJLNP-UW-Z]{2}';
# 
#             "(?k:(?k:$left)(?k:$sep)(?k:$right))";
#         },
#         ;
# 
# pattern name   => [qw /zip Canadian/, "-sep= "],
#         create => sub {
#             my $sep     = $_ [1] -> {-sep};
# 
#             my $left    = '[A-Z][0-9][A-Z]';
#             my $right   = '[0-9][A-Z][0-9]';
# 
#             "(?k:(?k:$left)(?k:$sep)(?k:$right))";
#         },
#         ;


1;

__END__

=pod

=head1 NAME

Regexp::Common::zip -- provide regexes for postal codes.

=head1 SYNOPSIS

    use Regexp::Common qw /zip/;

    while (<>) {
        /^$RE{zip}{Netherlands}$/   and  print "Dutch postal code\n";
    }


=head1 DESCRIPTION

Please consult the manual of L<Regexp::Common> for a general description
of the works of this interface.

Do not use this module directly, but load it via I<Regexp::Common>.

This module offers patterns for zip or postal codes of many different
countries. They all have the form C<$RE{zip}{Country}[{options}]>.

The following common options are used:

=head2 C<{-prefix=[yes|no|allow]}> and C<{-country=PAT}>.

Postal codes can be prefixed with a country abbreviation. That is,
a dutch postal code of B<1234 AB> can also be written as B<NL-1234 AB>.
By default, all the patterns will allow the prefixes. But this can be
changed with the C<-prefix> option. With C<-prefix=yes>, the returned
pattern requires a country prefix, while C<-prefix=no> disallows a
prefix. Any argument that doesn't start with a C<y> or a C<n> allows a
country prefix, but doesn't require them.

The prefixes used are, unfortunally, not always the same. Officially,
ISO country codes need to be used, but the usage of I<CEPT> codes (the
same ones as used on cars) is common too. By default, each postal code
will recognize a country prefix that's either the ISO standard or the
CEPT code. That is, German postal codes may prefixed with either C<DE>
or C<D>. The recognized prefix can be changed with the C<-country>
option, which takes a (sub)pattern as argument. The arguments C<iso>
and C<cept> are special, and indicate the language prefix should be the
ISO country code, or the CEPT code.

Examples:
 /$RE{zip}{Netherlands}/;
           # Matches '1234 AB' and 'NL-1234 AB'.
 /$RE{zip}{Netherlands}{-prefix => 'no'}/;
           # Matches '1234 AB' but not 'NL-1234 AB'.
 /$RE{zip}{Netherlands}{-prefix => 'yes'}/;
           # Matches 'NL-1234 AB' but not '1234 AB'.

 /$RE{zip}{Germany}/;
           # Matches 'DE-12345' and 'D-12345'.
 /$RE{zip}{Germany}{-country => 'iso'}/; 
           # Matches 'DE-12345' but not 'D-12345'.
 /$RE{zip}{Germany}{-country => 'cept'}/;
           # Matches 'D-12345' but not 'DE-12345'.
 /$RE{zip}{Germany}{-country => 'GER'}/;
           # Matches 'GER-12345'.

=head2 C<{-sep=PAT}>

Some countries have postal codes that consist of two parts. Typically
there is an official way of separating those parts; but in practise
people tend to use different separators. For instance, if the official
way to separate parts is to use a space, it happens that the space is
left off. The C<-sep> option can be given a pattern as argument which
indicates what to use as a separator between the parts.

Examples:
 /$RE{zip}{Netherlands}/;
           # Matches '1234 AB' but not '1234AB'.
 /$RE{zip}{Netherlands}{-sep => '\s*'}/;
           # Matches '1234 AB' and '1234AB'.

=head2 C<$RE{zip}{Australia}>

Returns a pattern that recognizes Australian postal codes. Australian
postal codes consist of four digits; the first two digits, which range
from '10' to '97', indicate the state. Territories use '02' or '08'
as starting digits; the leading zero is optional. The (optional) country
prefixes are I<AU> (ISO country code) and I<AUS> (CEPT code).
Regexp::Common 2.107 and before used C<$RE{zip}{Australia}>. This is
still supported.

If C<{-keep}> is used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country prefix.

=item $4

The state or territory.

=item $5

The last two digits.

=back

=head2 C<$RE{zip}{Belgian}>

Returns a pattern than recognizes Belgian postal codes. Belgian postal
codes consist of 4 digits, of which the first indicates the province.
The (optional) country prefixes are I<BE> (ISO country code) and
I<B> (CEPT code).

If C<{-keep}> is used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country prefix.

=item $4

The digit indicating the province.

=item $5

The last three digits of the postal code.

=back


=head2 C<$RE{zip}{Denmark}>

Returns a pattern that recognizes Danish postal codes. Danish postal
codes consist of four numbers; the first digit (which cannot be 0),
indicates the distribution region, the second the distribution
district. The (optional) country prefix is I<DK>, which is both
the ISO country code and the CEPT code.

If C<{-keep}> is used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country prefix.

=item $4

The digit indicating the distribution region.

=item $5

The digit indicating the distribution district.

=item $6

The last two digits of the postal code.

=back


=head2 C<$RE{zip}{France}>

Returns a pattern that recognizes French postal codes. French postal
codes consist of five numbers; the first two numbers, which range
from '01' to '98', indicate the department. The (optional) country
prefixes are I<FR> (ISO country code) and I<F> (CEPT code).
Regexp::Common 2.107 and before used C<$RE{zip}{French}>. This is
still supported.

If C<{-keep}> is used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country prefix.

=item $4

The department.

=item $5

The last three digits.

=back

=head2 C<$RE{zip}{Germany}>

Returns a pattern that recognizes German postal codes. German postal
codes consist of five numbers; the first number indicating the
distribution zone, the second the distribution region, while the 
latter three indicate the distribution district and the postal town.
The (optional) country prefixes are I<DE> (ISO country code) and
I<D> (CEPT code).
Regexp::Common 2.107 and before used C<$RE{zip}{German}>. This is
still supported.

If C<{-keep}> is used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country prefix.

=item $4

The distribution zone.

=item $5

The distribution region.

=item $6

The distribution district and postal town.

=back


=head2 C<$RE{zip}{Greenland}>

Returns a pattern that recognizes postal codes from Greenland.
Greenland, being part of Denmark, uses Danish postal codes.
All postal codes of Greenland start with 39.
The (optional) country prefix is I<DK>, which is both
the ISO country code and the CEPT code.

If C<{-keep}> is used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country prefix.

=item $4

39, being the distribution region and distribution district for Greenland.

=item $5

The last two digits of the postal code.

=back

=head2 C<$RE{zip}{Netherlands}>

Returns a pattern that recognizes Dutch postal codes. Dutch postal
codes consist of 4 digits and 2 letters, separated by a space.
The separator can be changed using the C<{-sep}> option, as discussed
above. The (optional) country prefix is I<NL>, which is both the 
ISO country code and the CEPT code. Regexp::Common 2.107 and earlier
used C<$RE{zip}{Dutch}>. This is still supported.

If C<{-keep}> is used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country prefix.

=item $4

The digits part of the postal code.

=item $5

The separator between the digits and the letters.

=item $6 

The letters part of the postal code.

=back


=head2 C<< $RE{zip}{US}{-extended => [yes|no|allow]} >>

Returns a pattern that recognizes US zip codes. US zip codes consist
of 5 digits, with an optional 4 digit extension. By default, extensions
are allowed, but not required. This can be influenced by the 
C<-extended> option. If its argument starts with a C<y>,
extensions are required; if the argument starts with a C<n>,
extensions will not be recognized. If an extension is used, a dash
is used to separate the main part from the extension, but this can
be changed with the C<-sep> option.

The country prefix is either I<US> (the ISO country code), or
I<USA> (the CEPT code).

If C<{-keep}> is being used, the following variables will be set:

=over 4

=item $1

The entire postal code.

=item $2

The country code prefix.

=item $3

The postal code without the country prefix.

=item $4

The first 5 digits of the postal code.

=item $5

The separator between the 5 digit part and the 4 digit part.

=item $6

The 4 digit part of the postal code (if any).

=back

You need at least version 5.005_03 to be able to use US postal codes.
Older versions contain a bug that let the pattern match invalid US
postal codes.

=head1 HISTORY

 $Log: zip.pm,v $
 Revision 1.1  2003/10/14 12:14:12  wig
 Adding RegExp perl module to source tree

 Revision 2.107  2003/03/25 23:46:58  abigail
 Added RCS Id: tag

 Revision 2.106  2003/02/09 21:31:16  abigail
 Postal codes for Denmark and Greenland

 Revision 2.105  2003/02/09 12:41:31  abigail
 Added Belgian postal codes

 Revision 2.104  2003/02/01 22:55:31  abigail
 Changed Copyright years

 Revision 2.103  2003/02/01 22:49:25  abigail
 Added Australian postal codes

 Revision 2.102  2003/01/23 02:18:42  abigail
 Added French postal codes

 Revision 2.101  2003/01/22 17:23:26  abigail
 German postal codes added.

 Revision 2.100  2003/01/21 23:19:40  abigail
 The whole world understands RCS/CVS version numbers, that 1.9 is an
 older version than 1.10. Except CPAN. Curse the idiot(s) who think
 that version numbers are floats (in which universe do floats have
 more than one decimal dot?).
 Everything is bumped to version 2.100 because CPAN couldn't deal
 with the fact one file had version 1.10.

 Revision 1.5  2003/01/16 11:06:27  abigail
 Typo fix.

 Revision 1.4  2003/01/16 11:02:17  abigail
 For US zip codes, version needs to be at least 5.005_03; older 5.005
 versions seem to have a bug in the regex machine, creating false
 positives.

 Revision 1.3  2003/01/13 21:45:01  abigail
 Complete redoing of Dutch & US postal codes. Documented them.

 Revision 1.2  2003/01/01 15:09:47  abigail
 Added US zip codes.

 Revision 1.1  2002/12/31 02:01:33  abigail
 First version


=head1 SEE ALSO

L<Regexp::Common> for a general description of how to use this interface.

=head1 AUTHOR

Damian Conway (damian@conway.org)

=head1 MAINTAINANCE

This package is maintained by Abigail S<(I<regexp-common@abigail.nl>)>.

=head1 BUGS AND IRRITATIONS

Zip codes for most countries are missing.
Send them in to I<regexp-common@abigail.nl>.

=head1 COPYRIGHT

     Copyright (c) 2001 - 2003, Damian Conway. All Rights Reserved.
       This module is free software. It may be used, redistributed
      and/or modified under the terms of the Perl Artistic License
            (see http://www.perl.com/perl/misc/Artistic.html)

=cut
