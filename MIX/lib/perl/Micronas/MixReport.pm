# -*- perl -*---------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# |
# |   Copyright Micronas GmbH, Inc. 2002/2005. 
# |     All Rights Reserved.
# | 
# |  
# | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF MICRONAS GMBH
# | The copyright notice above does not evidence any actual or intended
# | publication of such source code.
# |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# | Project:    Micronas - MIX / Report                                   |
# | Modules:    $RCSfile: MixReport.pm,v $                                |
# | Revision:   $Revision: 1.15 $                                               |
# | Author:     $Author: mathias $                                                 |
# | Date:       $Date: 2005/11/29 13:11:42 $                                                   |
# |                                                                       |
# | Copyright Micronas GmbH, 2005                                         |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/MixReport.pm,v 1.15 2005/11/29 13:11:42 mathias Exp $                                                             |
# +-----------------------------------------------------------------------+
#
# Write reports with details about the hierachy and connectivity of the
# generated nets/entities/....
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# | Changes:                                                              |
# | $Log: MixReport.pm,v $
# | Revision 1.15  2005/11/29 13:11:42  mathias
# | writes also a register overview table
# |
# | Revision 1.14  2005/11/28 13:58:59  mathias
# | do not write the bits for bitfields with 1 bit width
# |
# | Revision 1.13  2005/11/25 16:23:50  mathias
# | write only those registers into the mif file that are intended to be documented
# | fixed writing empty cells
# |
# | Revision 1.12  2005/11/24 16:21:16  mathias
# | report reglist seems to work
# |
# | Revision 1.11  2005/11/23 13:28:37  mathias
# | write Rgeister from RegisterMaster into Framemaker tables
# |
# | Revision 1.10  2005/11/09 13:00:03  lutscher
# | removed doubly defined function
# |
# | Revision 1.9  2005/11/08 08:06:54  wig
# | Added some documentation and example (register shell)
# |
# | Revision 1.8  2005/11/07 13:16:28  mathias
# | merged and added mix_rep_reglist
# |
# | Revision 1.7  2005/11/04 10:44:47  wig
# | Adding ::incom (keep CONN sheet comments) and improce portlist report format
# |
# | Revision 1.6  2005/10/24 12:10:30  wig
# | added output.language.verilog = ansistyle,2001param
# |
# | Revision 1.5  2005/10/19 08:19:19  wig
# | Extended portlist writer and Mif module
# |
# | Revision 1.4  2005/10/18 15:27:53  wig
# | Primary releaseable vgch_join.pl
# |
# | Revision 1.3  2005/10/18 09:34:37  wig
# | Changes required for vgch_join.pl support (mainly to MixUtils)
# |
# | Revision 1.2  2005/09/29 13:45:02  wig
# | Update with -report
# |
# | Revision 1.1  2005/09/14 14:40:06  wig
# | Startet report module (portlist)
# |                                                                |
# |                                                                       |
# +-----------------------------------------------------------------------+

package Micronas::MixReport;

require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(
	mix_report
); # symbols to export by default

@EXPORT_OK = qw();

our $VERSION = '0.1';
#
# RCS Id, to be put into output templates
#
my $thisid		=	'$Id: MixReport.pm,v 1.15 2005/11/29 13:11:42 mathias Exp $';
# ' # this seemes to fix a bug in the highlighting algorythm of Emacs' cperl mode
my $thisrcsfile	=	'$RCSfile: MixReport.pm,v $';
# ' # this seemes to fix a bug in the highlighting algorythm of Emacs' cperl mode
my $thisrevision   =      '$Revision: 1.15 $';
# ' # this seemes to fix a bug in the highlighting algorythm of Emacs' cperl mode

# unique number for Marker in the mif file
my $marker = 32178;

$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,;

#
# Start checks
#
#------------------------------------------------------------------------------
# Used packages
#------------------------------------------------------------------------------
use strict;
# use Data::Dumper;

use Log::Agent;
use Log::Agent::Priorities qw(:LEVELS);
# use Tree::DAG_Node; # tree base class

use Micronas::MixUtils qw(%EH %OPTVAL);
use Micronas::Reg;
use Micronas::MixUtils::Mif;

#use FindBin qw($Bin);
#use lib "$Bin";
#use lib "$Bin/..";
#use lib "$Bin/lib";

#
# Prototypes
#
sub _mix_report_getport ($$);

#------------------------------------------------------------------------------
# Class members
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Constructor
# returns a hash reference to the data members of this class
# package; does NOT call the subclass constructors.
# Input: 1. device identifier (can be whatever)
#------------------------------------------------------------------------------

sub new {
	my $this = shift;
	my %params = @_;

	# data member default values
	my $ref_member  = {
					   # device => "<no device specified>",
					   # domains => [],
					   # global => \%hglobal  # reference to class data
					  };
	# init data members w/ parameters from constructor call
	foreach (keys %params) {
		$ref_member->{$_} = $params{$_};
	};

	bless $ref_member, $this;
};

#
# Do the reporting if requested ...
#
sub mix_report($)
{
    my ($r_i2cin) = @_;

    return unless ( exists $OPTVAL{'report'} );

    my $reports = join( ',', @{$OPTVAL{'report'}} );
    # portlist:
    if ( $reports =~ m/\bportlist\b/io ) {
        mix_rep_portlist();
    }
    if ( $reports =~ m/\breglist\b/io ) {
        logsay("~~~~~ Report register list in mif format\n");
        mix_rep_reglist($r_i2cin);
    }
}

#
# Report register list
#
sub mix_rep_reglist($)
{
    my ($regp) = @_;      # Reference to the register object

    if (scalar @$regp) {
        my($o_space) = Micronas::Reg->new();

        if (grep($EH{'reg_shell'}{'type'} =~ m/$_/i, @{$o_space->global->{supported_views}})) {
            # init register module for generation of register-shell
            $o_space->init(inputformat => "register-master",
                           database_type => $EH{i2c}{regmas_type},
                           register_master => $regp
                          );
            # iterate through all blocks (domains)
            foreach my $href (@{$o_space->domains}) {
                my $o_domain = $href->{domain};
                #$o_domain->display();

                ### open mif file
                print("~~~~~ Domain name: " . $o_domain->name() . "\n");
                my $mif = new Micronas::MixUtils::Mif('name' => $EH{'report'}{'path'} . '/' .
                                                      $o_domain->name() . "_reglist.mif");
                $mif->template();           # Initialize it
                my $omif = new Micronas::MixUtils::Mif('name' => $EH{'report'}{'path'} . '/' .
                                                       $o_domain->name() . "_reg_overview.mif");
                $omif->template();           # Initialize it
                my $oview_table = mix_rep_reglist_oview_mif_header($omif);

                ### loop over all registers
                foreach my $o_reg (@{$o_domain->regs()}) {
                    if ($o_reg->to_document()) {        # should this register be documented
                        my $regtitle = $o_domain->name() . ' register: ' . $o_reg->name();
                        my $address  = sprintf("0x%08X", $o_domain->get_reg_address($o_reg));
                        my $init     = sprintf("0x%08X", $o_reg->get_reg_init());
                        my $mode     = $o_reg->get_reg_access_mode();

                        my ($regtable, $ref) = mix_rep_reglist_mif_header($mif, $regtitle, $o_reg->name(),
                                                                          $address, $mode, $init);
                        # write row into the overview table
                        mix_rep_reglist_oview_mif_row($omif, $oview_table, $ref, $address, $mode);

                        my $ii =0;
                        my @thefields;
                        foreach my $hreff (@{$o_reg->fields}) {
                            my $o_field = $hreff->{'field'};
                            # select type of register
                            $thefields[$ii]{name}    = lc($o_field->name);
                            $thefields[$ii]{size}    = $o_field->attribs->{'size'};
                            $thefields[$ii]{pos}     = $hreff->{'pos'};             # LSB position
                            $thefields[$ii]{lsb}     = $o_field->attribs->{'lsb'};
                            $thefields[$ii]{view}    = $o_field->attribs->{'view'};  # N: no documentation
                            $thefields[$ii]{mode}    = $o_field->attribs->{'dir'};
                            $thefields[$ii]{comment} = $o_field->attribs->{'comment'};
                            $ii += 1;
                        }
                        @thefields = reverse sort {${$a}{pos} <=> ${$b}{pos}} @thefields;

                        mix_rep_reglist_mif_bitfields($mif, $regtable, \@thefields);
                    }
                }

                ### write and close overview table of this domain
                $omif->end_body($oview_table);
                $omif->end_table($oview_table);
                $omif->write();
                ### write and close the file
                $mif->write();
            }
        }
    }
    return 0;
}

# write mif file header for the register overview table
sub mix_rep_reglist_oview_mif_header($$ )
{
    my ($mif) = @_;
    my %regtable = ('Title'       => 'Register description list',
                    'Format'      => 'Register overview',
                    'Cols'        => 4,
                    'ColumnWidth' => [ qw(45.0 15.0 27.0 92.0) ],
                    'TblTag'      => 'PageWidth'
                   );
    my $regtable = $mif->start_table(\%regtable);
    $mif->start_body($regtable);

    my $headtext = $mif->wrCell({ 'PgfTag'     => 'CellHeadingH9',
                                  'String'     => 'Register',
                                  'Fill'       => 0,
                                  'Color'      => "Gray 6.2"
                                },
                                2);
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeadingH9',
                                'String'     => 'R/W',
                                'Fill'       => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeadingH9',
                                'String'     => 'Address',
                                'Fill'       => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeadingH9',
                                'String'     => 'Comment',
                                'Fill'       => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);
    $mif->add($mif->Tr({ 'WithNext' => 'Yes',
                         'WithPrev' => 'Yes',
                         'Text'     => $headtext,
                         'Indent'   => 1
                        }), $regtable);
    return $regtable;
}

# write mif file header for register
sub mix_rep_reglist_oview_mif_row($$$$$ )
{
    my ($mif, $regtable, $regname, $address, $mode) = @_;
    my $headtext = "";

    # Register name
    $headtext .= $mif->wrCell({ 'PgfTag' => 'CellBodyH9',
                                'Xref' => $regname
                              },
                              2);
                                #'String' => $regname

    # Register Mode (R/W)
    $headtext .= $mif->wrCell({ 'PgfTag' => 'CellBodyH9center', 'String'  => $mode }, 2);

    # Register address
    $headtext .= $mif->wrCell({ 'PgfTag' => 'CellBodyH9center',
                                'String' => $address
                              },
                              2);

    # Comment (empty)
    $headtext .= $mif->wrCell({ 'PgfTag' => 'CellBodyH9',
                                'String' => ' '
                              },
                              2);

    $mif->add($mif->Tr({ 'WithNext' => 'Yes',
                         'WithPrev' => 'Yes',
                         'Text'     => $headtext,
                         'Indent'   => 1
                        }), $regtable);
}

# write mif file header for register
sub mix_rep_reglist_mif_header($$$$$$ )
{
    my ($mif, $title, $regname, $address, $mode, $init) = @_;
    my %regtable = ('Title'       => $title,
                    'Format'      => 'RegisterTable',
                    'Cols'        => 17,
                    'ColumnWidth' => [ qw(20.0 9.99993 9.99993 9.99993 9.99993 9.99993 9.99993 9.99993
                                               9.99993 9.99993 9.99993 9.99993 9.99993 9.99993 9.99993
                                               9.99993
                                          10.00105) ],
                    'TblTag'      => 'PageWidth'
                   );
    my $regtable = $mif->start_table(\%regtable);
    $mif->start_body($regtable);

    # Prepare tablehead data:
    #
    my $headtext = "";
    # Register name
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeadingH8',
                                'String'     => 'Register:',
                                'Fill'       => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);
    # new marker, cross reference
    $marker++;
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellBodyH8',
                                'String'     => $regname,
                                'Marker'     => $marker,
                                'Columns'    => 4
                              },
                              2);
    my $crossref = "$marker: CellBodyH8: $regname";

    for (my $i = 0; $i < 3; $i++) {
        $headtext .= $mif->wrCell({ 'PgfTag' => 'CellHeading' }, 2);
    }

    # Register address
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeadingH8',
                                'String'     => 'Address:',
                                'Columns'    => 2,
                                'Fill'       => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeading',
                                'Fill'       => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellBodyH8',
                                'String'     => $address,
                                'Columns'    => 3
                              },
                              2);
    $headtext .= $mif->wrCell({ 'PgfTag' => 'CellHeading' }, 2);
    $headtext .= $mif->wrCell({ 'PgfTag' => 'CellHeading' }, 2);

    # Register Mode (R/W)
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeadingH8',
                                'String'     => 'Mode:',
                                'Columns'    => 2,
                                'Fill'       => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeading',
                                'Fill'       => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);
    $headtext .= $mif->wrCell({ 'PgfTag' => 'CellBodyH8', 'String'  => $mode }, 2);

    # Register init value
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeadingH8',
                                'String'     => 'Init:',
                                'Fill'       => 0,
                                'Separation' => 2,
                                'Color'      => "Gray 6.2"
                              },
                              2);
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellBodyH8',
                                'String'     => $init,
                                'Columns'    => 3
                              },
                              2);
    $headtext .= $mif->wrCell({ 'PgfTag' => 'CellHeading' }, 2);
    $headtext .= $mif->wrCell({ 'PgfTag' => 'CellHeading' }, 2);

    #$mif->table_head($mif->Tr($headtext), $regtable);
    $mif->add($mif->Tr({ 'WithNext' => 'Yes',
                         'WithPrev' => 'Yes',
                         'Text'     => $headtext,
                         'Indent'   => 1
                        }), $regtable);

    return ($regtable, $crossref);
}

# write mif file for register
sub mix_rep_reglist_mif_bitfields($$$ )
{
    my ($mif, $regtable, $fields) = @_;
    my $headtext = "";

    ############ Row for the bits 31 .. 16
    # empty gray field on the left hand side
    $headtext = $mif->wrCell({ 'PgfTag'      => 'CellHeadingH8',
                                'Rows'       => 4,
                                'Fill'       => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);
    for (my $i = 31; $i > 15; $i--) {
        $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeadingH8',
                                    'Fill'       => 0,
                                    'String'     => $i,
                                    'Color'      => "Gray 6.2"
                                  },
                                  3);
    }
    $mif->add($mif->Tr({ 'WithNext' => 'Yes',
                         'WithPrev' => 'Yes',
                         'Text'     => $headtext,
                         'Indent'   => 0
                       }), $regtable);
    ############ Row for the bit slices 31 .. 16
    # empty gray field on the left hand side
    $headtext = $mif->wrCell({ 'PgfTag' => 'CellBodyH8',
                                'Fill'   => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);
    my $continue = 0;                    # 1: bitfield spans the bits 16 and 15
    my $fi;                              # index of the next element in $fields array
    my ($tbeg, $tend) = (31, 32);        # indexes of the next table entries to be written
    my ($size, $string);
    for ($fi = 0; $tend > 16; $fi++) {
        my $msbpos = $fields->[$fi]->{pos} + $fields->[$fi]->{size} - 1;
        # write unnamed bits if needed (including $msbpos + 1)
        if ($tend > $msbpos) {
            if ($msbpos > 15) {
                $tend = $msbpos + 1;
            } else {
                $tend = 16;
            }
        }
        for (my $i = $tbeg; $i >= $tend; $i--) {
            $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellBodyH8Center',
                                        'Fill'       => 15,
                                      },
                                      3);
        }
        $tbeg = $msbpos;
        # write named bits
        if ($tend > 16) {
            if ($fields->[$fi]->{pos} >= 16) {
                $tend = $fields->[$fi]->{pos};
                $size = $fields->[$fi]->{size};
                $string = $fields->[$fi]->{name};
            } else {
                $tend = 16;
                $continue = 1;
                $size = $tbeg - $tend + 1;
                my $msb = $fields->[$fi]->{size} + $fields->[$fi]->{lsb} - 1;
                my $lsb = $msb - $size + 1;
                $string = $fields->[$fi]->{name} . "[$msb-$lsb]";
            }
            my %hh = ('PgfTag'     => 'CellBodyH8Center',
                      'Fill'       => 15,
                      'String'     => $string);
            $hh{Columns} = $size if ($size > 1);
            if ($size == 1 and length($string) > 11) {
                $hh{'Angle'} = 270;
            }
            $headtext .= $mif->wrCell(\%hh, 3);
        }
        for (my $i = $tbeg - 1; $i >= $tend; $i--) {
            $headtext .= $mif->wrCell({ 'PgfTag' => 'CellBodyH8' }, 3);
        }
        if ($continue or ($msbpos < 16)) {
            $fi--;
        }
        $tbeg = $tend - 1;
    }
    $mif->add($mif->Tr({ 'WithNext' => 'Yes',
                         'WithPrev' => 'Yes',
                         'Text'     => $headtext,
                         'Indent'   => 0
                       }), $regtable);
    ############ Row for the bit slices 15 .. 0
    # empty gray field on the left hand side
    $headtext = $mif->wrCell({ 'PgfTag' => 'CellBodyH8',
                                'Fill'   => 0,
                                'Separation' => 5,
                                'Color'      => "Gray 6.2"
                              },
                              2);
    for ($tbeg = 15; $fi <= $#{$fields}; $fi++) {
        my $msbpos = $fields->[$fi]->{pos} + $fields->[$fi]->{size} - 1;
        if ($msbpos > 15) {       # $continue!!!
            $msbpos = 15;
        }
        # write unnamed bits if needed (including $msbpos + 1)
        if ($tend > $msbpos) {
            $tend = $msbpos + 1;
        }
        for (my $i = $tbeg; $i >= $tend; $i--) {
            $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellBodyH8Center',
                                        'Fill'       => 15,
                                      },
                                      3);
        }
        $tbeg = $msbpos;
        # write named bits
        $tend = $fields->[$fi]->{pos};
        if ($continue) {
            $continue = 0;
            $size = $tbeg - $tend + 1;
            my $msb = $size + $fields->[$fi]->{lsb} - 1;
            my $lsb = $fields->[$fi]->{lsb};
            $string = $fields->[$fi]->{name} . "[$msb-$lsb]";
        } else {
            $size = $fields->[$fi]->{size};
            $string = $fields->[$fi]->{name};
        }
        my %hh = ('PgfTag'     => 'CellBodyH8Center',
                  'Fill'       => 15,
                  'String'     => $string);
        $hh{'Columns'} = $size if ($size > 1);
        if ($size == 1 and length($string) > 11) {
            $hh{'Angle'} = 270;
        }
        $headtext .= $mif->wrCell(\%hh, 3);
        for (my $i = $tbeg - 1; $i >= $tend; $i--) {
            $headtext .= $mif->wrCell({ 'PgfTag' => 'CellBodyH8' }, 3);
        }
        $tbeg = $tend - 1;
    }
    if ($tend > 0) {                # last unnamed bits
        $tbeg = $tend - 1;
        for (my $i = $tbeg; $i >= 0; $i--) {
            $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellBodyH8Center',
                                        'Fill'       => 15,
                                      },
                                      3);
        }
    }

    $mif->add($mif->Tr({ 'WithNext' => 'Yes',
                         'WithPrev' => 'Yes',
                         'Text'     => $headtext,
                         'Indent'   => 0
                       }), $regtable);

    ############ Row for the bits  15.. 0
    # empty gray field on the left hand side
    $headtext = $mif->wrCell({ 'PgfTag' => 'CellHeadingH8',
                                'Fill'   => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);
    for (my $i = 15; $i >= 0; $i--) {
        $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeadingH8',
                                    'Fill'       => 0,
                                    'String'     => $i,
                                    'Color'      => "Gray 6.2"
                                  },
                                  3);
    }
    $mif->add($mif->Tr({ 'WithNext' => 'Yes',
                         'WithPrev' => 'Yes',
                         'Text'     => $headtext,
                         'Indent'   => 0
                       }), $regtable);

    ##### Header of the bitslice section
    $headtext = $mif->wrCell({ 'PgfTag'     => 'CellHeadingH8',
                               'String'     => 'Bit',
                               'Fill'       => 0,
                               'Color'      => "Gray 6.2"
                             },
                             2);
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeadingH8',
                                'String'     => 'Name',
                                'Columns'    => 3,
                                'Fill'       => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);
    $headtext .= $mif->wrCell({ 'PgfTag' => 'CellHeading' }, 2);
    $headtext .= $mif->wrCell({ 'PgfTag' => 'CellHeading' }, 2);
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeadingH8',
                                'String'     => 'R/W',
                                'Columns'    => 2,
                                'Fill'       => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);
    $headtext .= $mif->wrCell({ 'PgfTag' => 'CellHeading' }, 2);
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellHeadingH8',
                                'String'     => 'Function',
                                'Columns'    => 11,
                                'Fill'       => 0,
                                'Color'      => "Gray 6.2"
                              },
                              2);
    for (my $i = 0; $i < 10; $i++) {
        $headtext .= $mif->wrCell({ 'PgfTag' => 'CellHeading' }, 2);
    }

    $mif->add($mif->Tr({ 'WithNext' => 'Yes',
                         'WithPrev' => 'Yes',
                         'Text'     => $headtext,
                         'Indent'   => 1
                        }), $regtable);
    ##### End header of the bitslice section

    ##### Bitslices description
    for ($fi = 0; $fi <= $#{$fields}; $fi++) {
        my $msb = $fields->[$fi]->{pos} + $fields->[$fi]->{size} - 1;
        my $lsb = $fields->[$fi]->{pos};
        $headtext = $mif->wrCell({ 'PgfTag'     => 'CellBodyH8',
                                   'String'     => "[$msb:$lsb]"
                                 },
                                 2);
        $msb = $fields->[$fi]->{size} + $fields->[$fi]->{lsb} - 1;
        $lsb = $fields->[$fi]->{lsb};
        if ($msb == $lsb) {
            $string = $fields->[$fi]->{name};
        } else {
            $string = $fields->[$fi]->{name} . "[$msb:$lsb]";
        }
        $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellBodyH8',
                                    'String'     => $string,
                                    'Columns'    => 3
                                  },
                                  2);
        $headtext .= $mif->wrCell({ 'PgfTag' => 'CellHeading' }, 2);
        $headtext .= $mif->wrCell({ 'PgfTag' => 'CellHeading' }, 2);
        $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellBodyH8',
                                    'String'     => $fields->[$fi]->{mode},
                                    'Columns'    => 2
                                  },
                                  2);
        $headtext .= $mif->wrCell({ 'PgfTag' => 'CellHeading' }, 2);
        $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellBodyH8',
                                    'String'     => $fields->[$fi]->{comment},
                                    'Columns'    => 11
                                  },
                                  2);
        for (my $i = 0; $i < 10; $i++) {
            $headtext .= $mif->wrCell({ 'PgfTag' => 'CellHeading' }, 2);
            #$headtext .= $mif->wrCell({ 'PgfTag' => 'CellBodyH8' }, 3);
        }

        $mif->add($mif->Tr({ 'WithNext' => 'Yes',
                             'WithPrev' => 'Yes',
                             'Text'     => $headtext,
                             'Indent'   => 1
                           }), $regtable);
    }
    ##### End bitslices

    $mif->end_body($regtable);
    $mif->end_table($regtable);

    return;
}

#
# return signals in requested order ...
#
# config value: $EH{report}{portlist}{sort}
#
# alpha := sorted by port name (default)
# input (ordered as listed in input files)
# inout | outin: seperate in/out/inout seperately
#    can be combined with the "input" key
# ::COL : order as in column ::COL (alphanumeric!)		  			
sub _mix_report_sigsort {

	# $a and $b hold the respective conndb keys
	my $key = $EH{'report'}{'portlist'}{'sort'};
	my $conndb = \%Micronas::MixParser::conndb;
	
	my $va = $a;
	my $vb = $b;
	
	if ( exists $conndb->{$a} and exists $conndb->{$b} ) {
		if ( $key =~ m/\balpha\b/io ) {
			$va = $conndb->{$a}{'::name'};
			$vb = $conndb->{$b}{'::name'};
		} elsif ( $key =~ m/\binput\b/io ) {
			my $format = '%0' . ( length( $EH{'sum'}{'conn'} ) + 1 ) . 'd'; # 
			$va = sprintf( $format, $conndb->{$a}{'::connnr'});
			$vb = sprintf( $format, $conndb->{$b}{'::connnr'});
		} elsif ( $key =~ m/(\b::\w+)\b/io ) {
			if ( exists( $conndb->{$a}{$1} ) ) {
				$va = $conndb->{$a}{$1};
			}
			if ( exists( $conndb->{$b}{$1} )) {
				$vb = $conndb->{$b}{$1}; 
			}
		}	
	}

	# Do the sort here:
	$va cmp $vb;
	
}

#
# Print a list of all I/O signals ....
#
sub mix_rep_portlist () {

	my $mif = new Micronas::MixUtils::Mif(
		'name' => ( $EH{'report'}{'path'} . '/' . "mix_portlist.mif" ),
	);
		
	$mif->template(); # Initialize it

	# If ::external column is set, make a seperate table for external
	my $exttrigger = '';
	my $elist = '';
	if ( $EH{'report'}{'portlist'}{'split'} =~ m/\bexternal(::\w+)?/ ) {
		$exttrigger = "::external";
		if ( defined $1 ) {
			$exttrigger = $1;
		}
		#!wig20051103: new format ...
		$elist = $mif->start_table(
			{	'Title' => 'External Pin List',
				'TblTag' => 'PortList',
				'Cols' => 3,
				'ColumnWidth' => [ qw( 37.0 17.0 126.0 ) ],
			}
		);
	}
	
	my $plist = $mif->start_table(
		{ 'Title' => 'Portlist',
			'TblTag' => 'PortList',
			'Cols' => 6,
		  	'ColumnWidth' => [ qw( 37.0 12.0 16.0 16.0 10.0 89.0 ) ],
		}
	 );
	
	#
	# Prepare tablehead data:
	#
	my $headtext = $mif->td(
		{ 'PgfTag' => 'CellHeadingH9',
		  'String' => [
			  qw( PAD_Name I/O Description ),
		  ],
		}
	);

	if ( $elist ne '' ) {
		$mif->table_head( $mif->Tr($headtext), $elist );
		$mif->start_body( $elist );
	}

	$headtext = $mif->td(
		{ 'PgfTag' => 'CellHeadingH9',
		  'String' => [
			  # qw( Name Width Clock Description Source Destination ),
			  "Port" , "Width" , "Clock" , "S / D",  "I / O",  "Description",
		  ],
		}
	);	
	$mif->table_head( $mif->Tr($headtext), $plist );
	$mif->start_body( $plist );
	
	# Iterate over all instances ...
	my $hierdb = \%Micronas::MixParser::hierdb;
	my $conndb = \%Micronas::MixParser::conndb;
	for my $instance ( sort keys( %$hierdb ) ) {
		next if ( $hierdb->{$instance}{'::entity'} eq 'W_NO_ENTITY' );
		next if ( $instance =~ m/^%\w+/ );
		
		my $link = $hierdb->{$instance};
		
		# Create a large table ...
		## Instance name:
		my $line = $mif->td(
			{ 'PgfTag' => 'CellHeadingH9',
			  'Columns' => 6, # Columns Span of all six cells
			  'String'  => "$link->{'::inst'} ($link->{'::entity'})",
			}
		);
		
		$mif->add( $mif->Tr($line), $plist );
		
		#!wig20051103: different format for elist ...
		if ( $elist ne '' ) {
			$line = $mif->td(
				{ 'PgfTag' => 'CellHeadingH9',
			 		'Columns' => 3, # Columns Span of all three cells
			  		'String'  => "Input/Output PADs $link->{'::inst'} ($link->{'::entity'})",
				}
			);
			$mif->add( $mif->Tr($line), $elist );
		}


		## Signals at that instance
		## TODO : sort order ..
		for my $signal ( sort _mix_report_sigsort keys( %{$link->{'::sigbits'}} ) ) {
			# Iterate over all signals ...
			my $signalname = $conndb->{$signal}{'::name'};
			my $connect = $link->{'::sigbits'}{$signal};
			my $high	= $conndb->{$signal}{'::high'};
			my $low		= $conndb->{$signal}{'::low'};
			my $clock	= $conndb->{$signal}{'::clock'};
			my $descr	= $conndb->{$signal}{'::descr'};
			my $sd		= $conndb->{$signal}{'::sd'} || '';
			# Check connectivity: in vs. out vs. IO vs ....
			#   Mark if not fully connected with a footnote -> (*)

			#!wig20051103: if ::incom is set, this line has an attached
			#  comment. Print it before (post mode) or after (pre mode)	
			#  Maybe we limit the number of lines ...
			# my $incom_mode = ''; # pre or post
			$EH{'report'}{'portlist'}{'comments'} =~ m/(\d+)/;
			my $striphash = 0;
			if ( $EH{'report'}{'portlist'}{'comments'} =~ m/\bstriphash/io ) {
				$striphash = 1;
			}
			my $incom_lines = 0;
			if ( defined( $1 ) ) {
				$incom_lines = $1;
			}
			if ( $incom_lines <= 0 ) {
				$incom_lines = 100000; # This is nearly unlimited ....
			}
			my $incom_mode = '';
			my $incom_text = '';
			# Print up to $incom_lines ....
			if ( exists $conndb->{$signal}{'::incom'} ) {
				my $this_count = scalar( @{$conndb->{$signal}{'::incom'}} );
				my $min = 0;
				my $max = ( $this_count < $incom_lines ) ? $this_count : $incom_lines;
				$incom_mode = $conndb->{$signal}{'::incom'}[0]->mode();
				if ( $incom_mode eq "post" ) { # Take $max starting from last ...
					$min = $this_count - $max;
					$max = $this_count;
				}
				$max--;
				for my $com ( @{$conndb->{$signal}{'::incom'}}[$min..$max] ) {
					# $com is InComment Object ...
					my $t = $com->print() . "\n";
					$t =~ s/\s*#+// if ( $striphash );
					$incom_text .= $t;
				}
				chomp( $incom_text );
			}
				
			if ( $incom_mode eq 'post' ) {
				my $line = $mif->td(
				{ 	'PgfTag' => 'CellHeadingH9',
			  		'Columns' => 6, # Columns Span of all six cells
			  		'String'  => $incom_text,
				} );		
				$mif->add( $mif->Tr($line), $plist );
			};

			my $width = _mix_report_width( $high, $low );
			( my $full, my $mode ) = _mix_report_connect( $connect );
			$mode = uc( $mode );
			unless ( $full ) {
				$width .= '(*)'; # Not fully connected!
			}
			my $in = _mix_report_getinst( $conndb->{$signal}{'::in'} );
			my $out = _mix_report_getinst( $conndb->{$signal}{'::out'} );
			
			unless ( $sd ) {
				# If either I or O is set -> create combination
				if ( ( $in and not $out ) or ( not $in and $out ) ) {
					$sd = $in . $out;
				} elsif ( $in and $out ) {
					$sd = "I: $in" . "O: $out";
				}
			}
			$in = "(NO LOAD)" unless $in;
			$out = "(NO DRIVER)" unless $out;
			#TODO: Remember for later usage and sorting

			# Map signal name to port name:
			my $portname = $signalname;
			if ( $EH{'report'}{'portlist'}{'name'} =~ m/\bport\b/ ) {
				$portname = _mix_report_getport( $signalname, $link );
			}

			# If we split into internal/external list, decide which to take:
			my $tlist = $plist;
			my $external_flag = 0;
			if ( exists $conndb->{$signalname}{$exttrigger}
					and $conndb->{$signalname}{$exttrigger} !~ m/^\s*$/ ) {
				$external_flag = 1;
				$tlist = $elist;
			}
			
			if ( $external_flag ) {
				my $line = $mif->td(
					{ 'PgfTag' => 'CellBodyH9',
					   'String' => [
					   		$portname,
					   		$mode,
					   		$descr,
					   	],
					}
				);
				$mif->add( $mif->Tr(
					{ 'Text' => $line, 'WithPrev' => 0 },
					), $elist );
			} else {	
				my $line = $mif->td(
					{ 'PgfTag' => 'CellBodyH9',
				  	'String' => [
				  		$portname,
				  		$width,
				  		$clock,
				  		$sd,
				  		$mode,
				  		$descr,
				  	]
					} );
				$mif->add( $mif->Tr(
					{ 'Text' => $line, 'WithPrev' => 0 }
				), $plist );

			}
			# pre -> print comments after corresponding lines
			if ( $incom_mode eq 'pre' ) {
				my $line = $mif->td(
				{ 	'PgfTag' => 'CellHeadingH9',
			  		'Columns' => 6, # Columns Span of all six cells
			  		'String'  => $incom_text,
				} );		
				$mif->add( $mif->Tr($line), $plist );
			};

		}
	}
	
	$mif->end_body( $plist );
	$mif->end_table( $plist );
	if ( $elist ne '' ) {
		$mif->end_body( $elist );
		$mif->end_table( $elist);
	}	
	
	$mif->write();
	
	return;

}

#
# Map signal name to port name for given instance
#
#!wig20051018
sub _mix_report_getport ($$) {
	my $signal = shift;
	my $link   = shift;
	
	my @ports = ();
	# Get portname
	for my $io ( qw( in out ) ) {
		if ( exists( $link->{'::conn'}{$io} ) and
			 exists( $link->{'::conn'}{$io}{$signal} ) ) {
			push( @ports, keys( %{$link->{'::conn'}{$io}{$signal}} ) );
		}
	} 
	
	if ( scalar( @ports ) < 1 ) {
		# Did not get port ???
		$signal .= ' (S)';
		logwarn( "__W_MIX_REPORT: Could not map signal " . $signal .
			" to portname for instance " . $link->{'::inst'} );
		$EH{'sum'}{'warnings'}++;
	} elsif ( scalar( @ports ) > 1 ) {
		# More than one port attached :-(
		logwarn( "__W_MIX_REPORT: Multiple ports connected to " . $signal .
			" at instance " . $link->{'::inst'} );
		$EH{'sum'}{'warnings'}++;
		$signal = join( ',', @ports );
	} else {
		$signal = $ports[0];
	}

	return $signal;

} # End ox _mix_report_getport

#
# Get list of connected instances ...
#TODO: Do not print constants and other pseudo instances
sub _mix_report_getinst ($) {
	my $ref = shift;
	
	my $instances = "";
	for my $i ( @$ref ) {
		$instances .= ", " . $i->{'inst'};
	}

	$instances =~ s/^, //;
	
	return $instances;
}

#
# Create width string
#   if high and low are not set: "bit"
#   if high and low are digits:  $high - $low
#   if 
# 
sub _mix_report_width ($$) {
	my $high = shift;
	my $low	= shift;
	
	my $width = "__W_WIDTH_UNDEFINED";
	
	if ( ( not defined( $high ) or $high eq '' ) and
		 ( not defined( $low ) or $low eq '' ) ) {
		 # single bit, no vector
		 	$width = '1';
	} elsif ( $low =~ m/^\d+$/o and $high =~ m/^\d+$/o ) {
		$width = $high - $low + 1;
	} elsif ( $low eq "0" ) {
		# $low is "0" -> width is $high 
		$width = $high . ' + 1';
	} else {
		$width = "$high - $low + 1";
	}
	return $width;
}

#
# Is the signal in or out? Fully connected or not?
#  Examples:
#     A:::i, A:::o, B::io0:o, F:...T:...
#
#TODO: What about IO mode?
#TODO: shift that into the "sigbits" class!
sub _mix_report_connect ($) {
	my $connect = shift;
	
	my $sfull = "";
	my $smode = "";
	
	for my $c ( @$connect ) {
		my $full = -1;
		my $mode = "__E_UNKNOWN";
		if ( $c =~ m/^A:::([io]+)$/io ) {
			$full = 1;
			$mode = $1;
		} elsif ( $c =~ m/^B::(.*):([io]+)$/io ) {
			$full = 0;
			$mode = $2;
			( my $bitfield = $1 ) =~ s/0//g; # Remove all zeros
		
			$bitfield =~ s/$mode//g; # If that was the rest ->
			if ( $bitfield ne "" ) {
				$mode .= " (mixed: $bitfield)";
			}
		#TODO: Scan F:...T:...
		} else {
			$full = 0;
			$mode = "__W_OTHER";
		}
		if( $sfull eq "" ) {
			$sfull = $full; $smode = $mode;
		}
		if ( $sfull ne "" and $full ne $sfull ) {
			$sfull = 2;
		}
		if ( $smode ne "" and $smode ne $mode ) {
			$smode = $mode . "(CONFLICT!)";
		}
	}

	$smode = uc( $smode );
	
	return( $sfull, $smode );
}		

1;

#!End
