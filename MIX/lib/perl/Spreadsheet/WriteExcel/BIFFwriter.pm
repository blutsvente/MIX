package Spreadsheet::WriteExcel::BIFFwriter;

###############################################################################
#
# BIFFwriter - An abstract base class for Excel workbooks and worksheets.
#
#
# Used in conjunction with Spreadsheet::WriteExcel
#
# Copyright 2000-2003, John McNamara, jmcnamara@cpan.org
#
# Documentation after __END__
#

use Exporter;
use strict;







use vars qw($VERSION @ISA);
@ISA = qw(Exporter);

$VERSION = '0.05';

###############################################################################
#
# Class data.
#
my $byte_order   = '';
my $BIFF_version = 0x0500;


###############################################################################
#
# new()
#
# Constructor
#
sub new {

    my $class  = $_[0];

    my $self   = {
                    _byte_order    => '',
                    _data          => '',
                    _datasize      => 0,
                    _limit         => 2080,
                 };

    bless $self, $class;
    $self->_set_byte_order();
    return $self;
}


###############################################################################
#
# _set_byte_order()
#
# Determine the byte order and store it as class data to avoid
# recalculating it for each call to new().
#
sub _set_byte_order {

    my $self    = shift;

    if ($byte_order eq ''){
        # Check if "pack" gives the required IEEE 64bit float
        my $teststr = pack "d", 1.2345;
        my @hexdata =(0x8D, 0x97, 0x6E, 0x12, 0x83, 0xC0, 0xF3, 0x3F);
        my $number  = pack "C8", @hexdata;

        if ($number eq $teststr) {
            $byte_order = 0;    # Little Endian
        }
        elsif ($number eq reverse($teststr)){
            $byte_order = 1;    # Big Endian
        }
        else {
            # Give up. I'll fix this in a later version.
            croak ( "Required floating point format not supported "  .
                    "on this platform. See the portability section " .
                    "of the documentation."
            );
        }
    }
    $self->{_byte_order} = $byte_order;
}


###############################################################################
#
# _prepend($data)
#
# General storage function
#
sub _prepend {

    my $self    = shift;
    my $data    = join('', @_);

    $data = $self->_add_continue($data) if length($data) > $self->{_limit};

    $self->{_data}      = $data . $self->{_data};
    $self->{_datasize} += length($data);
}


###############################################################################
#
# _append($data)
#
# General storage function
#
sub _append {

    my $self    = shift;
    my $data    = join('', @_);

    $data = $self->_add_continue($data) if length($data) > $self->{_limit};

    $self->{_data}      = $self->{_data} . $data;
    $self->{_datasize} += length($data);
}


###############################################################################
#
# _store_bof($type)
#
# $type = 0x0005, Workbook
# $type = 0x0010, Worksheet
#
# Writes Excel BOF record to indicate the beginning of a stream or
# sub-stream in the BIFF file.
#
sub _store_bof {

    my $self    = shift;
    my $record  = 0x0809;        # Record identifier
    my $length  = 0x0008;        # Number of bytes to follow

    my $version = $BIFF_version;
    my $type    = $_[0];

    # According to the SDK $build and $year should be set to zero.
    # However, this throws a warning in Excel 5. So, use these
    # magic numbers.
    my $build   = 0x096C;
    my $year    = 0x07C9;

    my $header  = pack("vv",   $record, $length);
    my $data    = pack("vvvv", $version, $type, $build, $year);

    $self->_prepend($header, $data);
}


###############################################################################
#
# _store_eof()
#
# Writes Excel EOF record to indicate the end of a BIFF stream.
#
sub _store_eof {

    my $self      = shift;
    my $record    = 0x000A; # Record identifier
    my $length    = 0x0000; # Number of bytes to follow

    my $header    = pack("vv", $record, $length);

    $self->_append($header);
}


###############################################################################
#
# _add_continue()
#
# Excel limits the size of BIFF records. In Excel 5 the limit is 2084 bytes. In
# Excel 97 the limit is 8228 bytes. Records that are longer than these limits
# must be split up into CONTINUE blocks.
#
# This function take a long BIFF record and inserts CONTINUE records as
# necessary.
#
sub _add_continue {

    my $self        = shift;
    my $data        = $_[0];
    my $limit       = $self->{_limit};
    my $record      = 0x003C; # Record identifier
    my $length;               # Number of bytes to follow
    my $header;
    my $tmp;

    # The first 2080/8224 bytes remain intact. However, we have to change
    # the length field of the record.
    #
    $tmp = substr($data, 0, $limit, "");
    substr($tmp, 2, 2, pack("v", $limit-4));

    # Strip out chunks of 2080/8224 bytes +4 for the header.
    while (length($data) > $limit) {
        $header  = pack("vv", $record, $limit);
        $tmp    .= $header;
        $tmp    .= substr($data, 0, $limit, "");
    }

    # Mop up the last of the data
    $header  = pack("vv", $record, length($data));
    $tmp    .= $header;
    $tmp    .= $data;

    return $tmp ;
}




1;


__END__


=head1 NAME

BIFFwriter - An abstract base class for Excel workbooks and worksheets.

=head1 SYNOPSIS

See the documentation for Spreadsheet::WriteExcel

=head1 DESCRIPTION

This module is used in conjunction with Spreadsheet::WriteExcel.

=head1 AUTHOR

John McNamara jmcnamara@cpan.org

=head1 COPYRIGHT

� MM-MMIII, John McNamara.

All Rights Reserved. This module is free software. It may be used, redistributed and/or modified under the same terms as Perl itself.
