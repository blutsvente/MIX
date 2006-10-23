#!/bin/sh --
#!/bin/sh -- # -*- perl -*- -w
eval 'exec ${PERL:-`[ ! -d "$HOME/bin/perl" -a -x "$HOME/bin/perl" ] && echo "$HOME/bin/perl" || { [ -x /usr/bin/perl ] && echo /usr/bin/perl || echo /usr/local/bin/perl ; } `} -x -S $0 ${1+"$@"} ;'
if 0; # dynamic perl startup; suppress preceding line in perl
#line 6

use strict;
use warnings;
use Cwd;
use File::Basename;
use Getopt::Long qw(GetOptions);
use Pod::Text;
# use diagnostics; # -> will be set by -debug option

# +-----------------------------------------------------------------------+
# |   Copyright Micronas GmbH, Inc. 2006.                                 |
# |     All Rights Reserved.                                              |
# |                                                                       |
# | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF MICRONAS GMBH          |
# | The copyright notice above does not evidence any actual or intended   |
# | publication of such source code.                                      |
# +-----------------------------------------------------------------------+

# +-----------------------------------------------------------------------+
# | Id           : $Id: bads.pl,v 1.1 2006/10/23 08:24:59 mathias Exp $  |
# | Name         : $Name:  $                                              |
# | Description  : $Description:$                                         |
# | Parameters   : -                                                      |
# | Version      : $Revision: 1.1 $                                       |
# | Mod.Date     : $Date: 2006/10/23 08:24:59 $                           |
# | Author       : $Author: mathias $                                         |
# | Phone        : $Phone: +49 89 54845 7275$                             |
# | Fax          : $Fax: $                                                |
# | Email        : $Email: mathias.megyei@micronas.com$                   |
# +-----------------------------------------------------------------------+

#******************************************************************************
# Other required packages
#******************************************************************************

use FindBin;

use lib "$FindBin::Bin/..";
use lib "$FindBin::Bin/../lib/perl";
use lib "$FindBin::Bin";
use lib "$FindBin::Bin/lib/perl";
use lib getcwd() . "/lib/perl";
use lib getcwd() . "/../lib/perl";

use Log::Log4perl qw(:easy get_logger :levels);

use Micronas::MixUtils qw( mix_init $eh %OPTVAL mix_getopt_header
	convert_in db2array replace_mac);
use Micronas::MixUtils::IO qw(init_ole
                              open_infile
                              write_outfile);
use Micronas::MixUtils::Mif;
# use Micronas::MixParser;
# use Micronas::MixIOParser;
# use Micronas::MixI2CParser;
# use Micronas::MixWriter;
# use Micronas::MixReport;


##############################################################################
# Prototypes
##############################################################################

sub bads_mif_header($$);
sub bads_mif_starttable($$);
sub bads_mif_row($$$$$$$$$);

##############################################################################
# Global Variables
##############################################################################

$::VERSION = '$Revision: 1.1 $'; # RCS Id
$::VERSION =~ s,\$,,go;

# Our local variables
# Global access to logging and environment

Log::Log4perl->init( $FindBin::Bin . '/mixlog.conf' );
my $logger = get_logger('PADS_PINS_BALLS');

# Step 0: Init $0
mix_init();               # Presets ....

### Name of the relevant sheet
my %xls = ();
$xls{top}   = '.*';
$xls{sheet} = "PadPinlist";

# TODO : promote that settings to some other place ...
$xls{'others'} = 'peri.*'; # Take the default.xls config key
$eh->set( 'default.xls', '.*' ); # Read in all sheets ....
$eh->set( 'macro.%UNDEF_1%', '' );
# Remove NL and CR
$eh->set( 'format.csv.style', 'stripnl,doublequote,autoquote,maxwidth' );
$eh->set( 'output.input.ignore.comments', '::ignany' ); # Skip all lines with s.th. \S in ::ign

# Add your options here ....
mix_getopt_header(qw(out=s
                     sheet=s
                     dir=s
                     conf|config=s@
                     #sheet=s@
                     listconf
                    ));

if ( scalar( @ARGV ) < 1 ) { # Need  at least one sheet!!
    $logger->fatal('__F_INPUT_MISS', "\tNo input file specified!\n");
    die();
}

##############################################################################
# Step 2: Open the input file and retrieve the required table(s)
# Do a first simple conversion from Excel arrays into array of hashes

my %sheets = ();
my $outname = $OPTVAL{'out'} || 'bads.mif';

# Options sheet overwrites $xls{sheet}
if ($OPTVAL{sheet}) {
    $xls{sheet} = $OPTVAL{sheet};
}

# GLOBAL variables:
my $files = $ARGV[0];
# Open file and retrieve the desired sheet(s)
my $type = 'default';
my $conn = open_infile($files,
                       $xls{sheet},             # Select sheets ... default: "PadPinlist"
                       '',                      # no ignored sheets
                       $eh->get($type . '.req') . ',hash');

# Convert to hashes ...
foreach my $sheetname (keys %$conn) {
    if ($sheetname eq $xls{sheet}) {
        my @arrayhash = convert_in($type, $conn->{$sheetname});
        $sheets{$files}{$sheetname} = \@arrayhash;
        #print("!!!!! sheetname: $sheetname\n");
    }
}

### open mif file
$logger->info("Creating mif data structure");

my $mif = new Micronas::MixUtils::Mif('name' => $eh->get( 'report.path' ) . '/' . $outname);
$mif->template();           # initialize it

my $title    = "Pin connection and short description for package PBGA-4xx";
my $miftable = bads_mif_starttable($mif, $title);
bads_mif_header($mif, $miftable);
$mif->start_body($miftable);

# If the sheets matches a client from the top, print out ...
my $aref = $sheets{$files}{$xls{sheet}};
my %power;
foreach my $pad_ball (@{$aref}) {
    my $ballname = $pad_ball->{'::ballname'};    # Ball-, Pinname
    my $ball     = $pad_ball->{'::ball'};        # Ball position
    my $pin1     = $pad_ball->{'::pin1'};
    my $pin2     = $pad_ball->{'::pin2'};
    my $pin3     = $pad_ball->{'::pin3'};
    my $typ1     = $pad_ball->{'::type1'};
    my $typ2     = $pad_ball->{'::type2'};
    my $typ3     = $pad_ball->{'::type3'};
    my $connect  = $pad_ball->{'::connections'} ? $pad_ball->{'::connections'} : ' ';
    my $reset    = $pad_ball->{'::reset'} ? $pad_ball->{'::reset'} : ' ';
    my $desc1    = $pad_ball->{'::desc1'};
    my $desc2    = $pad_ball->{'::desc2'};
    my $desc3    = $pad_ball->{'::desc3'};

    # Collect information to power supply pads
    # That lines will be written at the end of the table
    if (defined($pin1) and $pin1 and ($pin1 =~ m/^\s*(VDD|VSS)/)) {
        #if (! exists($power{$ball}->{pins})) {
        #    $power{$ball}->{pins} = ();
        #}
        print("!!!!! $pin1     $ball\n");
        push(@{$power{$ball}->{pins}}, $pin1);
        $power{$ball}->{desc}    = $desc1   ? $desc1   : " ";
        $power{$ball}->{typ}     = $typ1    ? $typ1    : " ";
        $power{$ball}->{connect} = $connect ? $connect : " ";
        $power{$ball}->{reset}   = $reset   ? $reset   : " ";
        next;
    }
    # alternate 1 (one table row for all pins belonging to the same ball)
    if (defined($pin2) and $pin2 and $pin2 ne "-") {
        $pin1 .= '\n' . $pin2;
        $typ1 .= '\n' . $typ2;
        $desc1 .= '\n' . $desc2;
    }
    if (defined($pin3) and $pin3 and $pin3 ne "-") {
        $pin1 .= '\n' . $pin3;
        $typ1 .= '\n' . $typ3;
        $desc1 .= '\n' . $desc3;
    }
    bads_mif_row($mif, $miftable, $ball, $ballname, $pin1, $typ1, $connect, $reset, $desc1);

    # alternate 2 (each pin* in its own table row)
    #if ((defined($ball) && $ball or defined($pin1) && $pin1) && $ball ne "Ball Name") {
    #    bads_mif_row($mif, $miftable, $ballname, $ball, $pin1, $typ1, $connect, $reset, $desc1);
    #}
    #if (defined($pin2) && $pin2) {
    #    bads_mif_row($mif, $miftable, " ", " ", $pin2, $typ2, $connect, $reset, $desc2);
    #}
    #if (defined($pin3) && $pin3) {
    #    bads_mif_row($mif, $miftable, " ", " ", $pin3, $typ3, $connect, $reset, $desc3);
    #}
}

# Write power balls
foreach my $ball (keys %power) {
    my $pin = "";
    foreach my $p (@{$power{$ball}->{pins}}) {
        $pin .=  '\n' . $p;
    }
    $pin =~ s/\\n//;    # delete first '\n'
    bads_mif_row($mif, $miftable, $ball, $ballname, $pin, $power{$ball}->{typ},
                 $power{$ball}->{connect}, $power{$ball}->{reset}, $power{$ball}->{desc});
}

# Table body end
$mif->end_body($miftable);
# Table end
$mif->end_table($miftable);
### write and close the file
$mif->write();

# Overall run-time
$logger->info('SUM: runtime: ' . (time() - $eh->get('macro.%STARTTIME%')) . ' seconds');

my $status = 0;
exit $status;

##############################################################################
# bads_mif_row
#      writes one row with the given pad
# Parameters:
#      $mif          MIF object
#      $title        Title string of the new table
# Return:
#      $table        reference to the table object to be written
##############################################################################
sub bads_mif_row($$$$$$$$$)
{
    my ($mif, $table, $ballposition, $ballname, $pin, $typ, $connect, $reset, $desc) = @_;
    my %hstr = ('PgfTag'   => 'CellBodyH8Center');

    # ball no
    $hstr{'String'} = $ballposition;
    my $text = $mif->wrCell(\%hstr, 2);

    # ball name
    $hstr{'String'} = $ballname;
    $text .= $mif->wrCell(\%hstr, 2);

    # pin name (Function)
    $hstr{'PgfTag'} = 'CellBodyH8';
    $hstr{'String'} = $pin;
    $text .= $mif->wrCell(\%hstr, 2);

    # pin type
    $hstr{'String'} = $typ;
    $text .= $mif->wrCell(\%hstr, 2);

    # connect
    $hstr{'String'} = $connect;
    $text .= $mif->wrCell(\%hstr, 2);

    # reset
    $hstr{'String'} = $reset;
    $text .= $mif->wrCell(\%hstr, 2);

    # description
    $hstr{'String'} = $desc;
    $text .= $mif->wrCell(\%hstr, 2);

    my %hh = ('Text' => $text, 'Indent' => 1);
    #$hh{WithPrev} = 'Yes';
    $mif->add($mif->Tr(\%hh), $table);
}

##############################################################################
# bads_mif_starttable
#      creates mif table
# Parameters:
#      $mif          MIF object
#      $title        Title string of the new table
# Return:
#      $table        reference to the table object to be written
##############################################################################
sub bads_mif_starttable($$ )
{
    my ($mif, $title) = @_;
    my %table = ('Title'       => $title,
                 'Format'      => 'PageWidth',
                 'Cols'        => 7,
                 'ColumnWidth' => [ qw(10.0 15.0 26.0 18.0 18.0 13.0 80.0) ],
                 'TblTag'      => 'PageWidth'
                );
    my $table = $mif->start_table(\%table);
    return $table;
}

##############################################################################
# bads_mif_header
#      writes header (line) into ball pin connection table
# Parameters:
#      $mif          MIF object
#      $table        Table object
##############################################################################
sub bads_mif_header($$)
{
    my ($mif, $miftable) = @_;

    # Prepare tablehead data:
    #
    my $headtext = "";
    # Ball position (D5, E5, J8, ...)
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeadingH8Center',
                                'String'     => 'Ball Position',
                                'Fill'       => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);
    # Ball name
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeadingH8Center',
                                'String'     => 'Ball Name',
                                'Fill'       => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);

    # Function (Pin/Pad name)
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeadingH8Center',
                                'String'     => 'Function',
                                'Fill'       => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);

    # Type (Input, output, inout, analog input, ...)
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeadingH8Center',
                                'String'     => 'Type',
                                'Fill'       => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);
    # Connections
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeadingH8Center',
                                'String'     => 'Connection (if not used)',
                                'Fill'       => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);
    # Reset
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeadingH8Center',
                                'String'     => 'Reset state',
                                'Fill'       => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);

    # Description
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeadingH8Center',
                                'String'     => 'Short Description',
                                'Fill'       => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);

    $mif->table_head($mif->Tr({ 'WithNext' => 'Yes',
                                'WithPrev' => 'Yes',
                                'Text'     => $headtext,
                                'Indent'   => 1
                              }), $miftable);
}

__END__

=head1 NAME

bads.pl - Write mif file for ball - pin assignment

=head1 SYNOPSIS

=over 4

=item msim [ -out <outfile.mif> ] [-sheet <sheetname> ] <excel_file.xls>

=back

=head1 OPTIONS

=over 4

=item B<-out> <outfile.mif>

Name of the mif file to be written. The default name is
F<bads.mif>.

=item -sheet <sheetname>

Name of the sheet containing the ball - pin assignment.
The default name is B<PadPinlist>.

=back

=cut

=head1 EXAMPLES

C<perl K:\PROJECTS\MIX\PROG\bads.pl -out VCTH_pads_n_pins.mif VCTH_pads_n_pins.xls>

=cut
