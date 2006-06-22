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
# | Revision:   $Revision: 1.29 $                                               |
# | Author:     $Author: wig $                                                 |
# | Date:       $Date: 2006/06/22 07:13:21 $                                                   |
# |                                                                       |
# | Copyright Micronas GmbH, 2005                                         |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/MixReport.pm,v 1.29 2006/06/22 07:13:21 wig Exp $                                                             |
# +-----------------------------------------------------------------------+
#
# Write reports with details about the hierachy and connectivity of the
# generated nets/entities/....
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# | Changes:                                                              |
# | $Log: MixReport.pm,v $
# | Revision 1.29  2006/06/22 07:13:21  wig
# | Updated HIGH/LOW parsing, extended report.portlist.comments
# |
# | Revision 1.28  2006/06/16 07:43:32  lutscher
# | changed input to mix_rep_reglist() to take a Reg object
# |
# |
# | Revision 1.27  2006/04/10 15:50:09  wig
# | Fixed various issues with logging and global, added mif test case (report portlist)
# |
# | Revision 1.26  2006/03/27 13:17:31  mathias
# | start with a random number for unique number for marker in the mif file
# |
# | Revision 1.25  2006/03/24 14:07:11  mathias
# | write a message when documentation of a register is disabled
# |
# | Revision 1.24  2006/03/17 09:18:32  wig
# | Fixed bad usage of $eh inside m/../ and print "..."
# |
# | Revision 1.23  2006/03/07 09:04:05  mathias
# | fixed in writing API function name
# |
# | Revision 1.22  2006/02/23 12:44:32  mathias
# | enable register names in the overview table rather than cross refeferences
# | added API line to the register table if the ::api column exists
# |
# | Revision 1.21  2006/01/18 15:28:57  mathias
# | added debug commands
# |
# | Revision 1.20  2005/12/14 12:50:32  wig
# | Improved external portlist tabe creation, prepared delta mode
# |
# | Revision 1.19  2005/12/08 11:32:49  mathias
# | long tables now have dedicated header
# |
# | Revision 1.18  2005/12/06 16:07:04  wig
# | Testing watch
# |
# | Revision 1.17  2005/12/06 15:04:05  mathias
# | splits long tables
# |
# | Revision 1.16  2005/11/30 06:53:11  mathias
# | fixed vertical alignment
# |
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
my $thisid		=	'$Id: MixReport.pm,v 1.29 2006/06/22 07:13:21 wig Exp $';
# ' # this seemes to fix a bug in the highlighting algorythm of Emacs' cperl mode
my $thisrcsfile	=	'$RCSfile: MixReport.pm,v $';
# ' # this seemes to fix a bug in the highlighting algorythm of Emacs' cperl mode
my $thisrevision   =      '$Revision: 1.29 $';
# ' # this seemes to fix a bug in the highlighting algorythm of Emacs' cperl mode

# unique number for Marker in the mif file
#my $marker = 32178;
my $marker = int(rand(100000));

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
use File::Basename;

use Log::Log4perl qw(get_logger);
use Micronas::MixUtils qw($eh %OPTVAL);
use Micronas::Reg;
use Micronas::MixUtils::Mif;

#
# Prototypes
#
sub _mix_report_getport ($$);
sub _mix_report_conn2sp ($);

my $logger = get_logger( 'MIX::MixReport' );

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
        $logger->info('__I_REPORT', "\tReport register list in mif format");
        mix_rep_reglist($r_i2cin);
    }
}

#
# Report register list
#
sub mix_rep_reglist($)
{
    my ($o_space) = shift @_;      # Reference to the register object

    if (defined $o_space) {
		# iterate through all blocks (domains)
		foreach my $href (@{$o_space->domains}) {
			my $o_domain = $href->{domain};
			#$o_domain->display();
			
			### open mif file
			# print("~~~~~ Domain name: " . $o_domain->name() . "\n");
			my $mif = new Micronas::MixUtils::Mif('name' => $eh->get( 'report.path' ) . '/' .
												  $o_domain->name() . "_reglist.mif");
			$mif->template();           # Initialize it
			my $omif = new Micronas::MixUtils::Mif('name' => $eh->get( 'report.path' ) . '/' .
												   $o_domain->name() . "_reg_overview.mif");
			$omif->template();           # Initialize it
			my $oview_table = mix_rep_reglist_oview_mif_header($omif);
			
			### loop over all registers
			my @reg_crossrefs;   # cross references will appear in overview table
			foreach my $o_reg (@{$o_domain->regs()}) {
				if ($o_reg->to_document()) {        # should this register be documented
					my $regtitle = $o_domain->name() . ' register: ' . $o_reg->name();
					my $address  = sprintf("0x%08X", $o_domain->get_reg_address($o_reg));
					my $init     = sprintf("0x%08X", $o_reg->get_reg_init());
					my $mode     = $o_reg->get_reg_access_mode();
					
					my $regtable = mix_rep_reglist_mif_starttable($mif, $regtitle);
					$mif->start_body($regtable);
					my $ref      = mix_rep_reglist_mif_header($mif, $regtable, $o_reg->name(),
															  $address, $mode, $init);
					my %href = ( 'crossref' => $ref,
								 'address'  => $address,
								 'mode'     => $mode);
					if ($eh->get( 'report.reglist.crossref' ) eq 'no') {
						$href{crossref} = $o_reg->name();
						#print("~~~~~    printing register name rather than cross-reference\n");
					}
					push(@reg_crossrefs, \%href);
					if ( $eh->get( 'output.mif.debug' ) ) {
						print("~~~~~ Register: " . $o_reg->name() . "\n");
					}
					my ($ii, $width_1) = (0, 0);
					my @thefields;
					my $api = '';
					foreach my $hreff (@{$o_reg->fields}) {
						my $o_field = $hreff->{'field'};
						# select type of register
						$thefields[$ii]{name}    = lc($o_field->name);
						$thefields[$ii]{size}    = $o_field->attribs->{'size'};
						$width_1++ if ($thefields[$ii]{size} == 1);
						$api = $o_field->attribs->{'api'} if (exists($o_field->attribs->{'api'}));
						$thefields[$ii]{pos}     = $hreff->{'pos'};             # LSB position
						$thefields[$ii]{lsb}     = $o_field->attribs->{'lsb'};
						$thefields[$ii]{view}    = $o_field->attribs->{'view'};  # N: no documentation
						$thefields[$ii]{mode}    = $o_field->attribs->{'dir'};
						$thefields[$ii]{comment} = $o_field->attribs->{'comment'};
						$thefields[$ii]{sync}    = $o_field->attribs->{'sync'};
						if ( $eh->get( 'output.mif.debug' ) ) {
							print("~~~~~    " . $thefields[$ii]{name} . '(' . $thefields[$ii]{size}
								  . ')' . '/' . $thefields[$ii]{pos}  . "\n");
							if ($eh->get( 'output.mif.debug' ) == 2) {
								print("         " . $thefields[$ii]{comment} . "\n");
							}
						}
						$ii += 1;
					}
					@thefields = reverse sort {${$a}{pos} <=> ${$b}{pos}} @thefields;
			
			mix_rep_reglist_mif_bitfields($mif, $regtable, \@thefields);
			# write 'API' row
			if ($api) {
				if ( $eh->get( 'output.mif.debug' ) ) {
					if ( $eh->get( 'output.mif.debug' ) == 3) {
						print("         api: `$api'\n");
					}
				}
				mix_rep_reglist_mif_api($mif, $regtable, $api);
			}
			if ($width_1 >= 3 or $#thefields >= 7) {
				# to many bitfields for one single table
				# write bitfield descriptions in another table
				$mif->end_body($regtable);
				$mif->end_table($regtable);
				$regtitle = $o_domain->name() . ' register: ' . $o_reg->name() . '  Bitfields';
				$regtable = mix_rep_reglist_mif_starttable($mif, $regtitle);
				mix_rep_reglist_mif_bitfield_description_header($mif, $regtable, 'new_table');
				$mif->start_body($regtable);
			} else {
				mix_rep_reglist_mif_bitfield_description_header($mif, $regtable);
			}
			mix_rep_reglist_mif_bitfield_description($mif, $regtable, \@thefields);
			$mif->end_body($regtable);
			$mif->end_table($regtable);
		} else {
			if ( $eh->get( 'output.mif.debug' ) ) {
				print("!!!!! Register: " . $o_reg->name() . " will not be documented\n");
			}
		}
	}
	
	# write rows into the overview table
	mix_rep_reglist_oview_mif_row($omif, $oview_table, \@reg_crossrefs);
	### write and close overview table of this domain
	$omif->end_body($oview_table);
	$omif->end_table($oview_table);
	$omif->write();
	### write and close the file
	$mif->write();
}
    }
    return 0;
}

# write mif file header for the register overview table
sub mix_rep_reglist_oview_mif_header($ )
{
    my ($mif) = @_;
    my %regtable = ('Title'       => 'Register description list',
                    'Format'      => 'Register overview',
                    'Cols'        => 4,
                    'ColumnWidth' => [ qw(45.0 15.0 27.0 92.0) ],
                    'TblTag'      => 'PageWidth'
                   );
    my $regtable = $mif->start_table(\%regtable);

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
    #$mif->add( $mif->Tr($headtext), $regtable);
    $mif->table_head($mif->Tr({ 'WithNext' => 'Yes',
                                'WithPrev' => 'Yes',
                                'Text'     => $headtext,
                                'Indent'   => 1
                              }), $regtable);
    $mif->start_body($regtable);
    return $regtable;
}

# write references to register tables into overview table
sub mix_rep_reglist_oview_mif_row($$$ )
{
    my ($mif, $regtable, $ref_to_crossref) = @_;

    for (my $i = 0; $i <= $#{$ref_to_crossref}; $i++) {
        my $headtext = "";
        # Register name
        if ($eh->get( 'report.reglist.crossref' ) eq 'no' ) {
            $headtext .= $mif->wrCell({ 'PgfTag' => 'CellBodyH9',
                                        'String'   => $ref_to_crossref->[$i]->{crossref}
                                      }, 2);
        } else {
            $headtext .= $mif->wrCell({ 'PgfTag' => 'CellBodyH9',
                                        'Xref'   => $ref_to_crossref->[$i]->{crossref}
                                      }, 2);
        }

        # Register Mode (R/W)
        $headtext .= $mif->wrCell({ 'PgfTag' => 'CellBodyH9center',
                                    'String'  => $ref_to_crossref->[$i]->{mode}
                                  }, 2);

        # Register address
        $headtext .= $mif->wrCell({ 'PgfTag' => 'CellBodyH9center',
                                    'String' => $ref_to_crossref->[$i]->{address}
                                  }, 2);

        # Comment (empty)
        $headtext .= $mif->wrCell({ 'PgfTag' => 'CellBodyH9',
                                    'String' => ' '
                                  }, 2);

        my %hh = ('Text'     => $headtext,
                  'Indent'   => 1
                 );
        $hh{WithPrev} = 'Yes' if ($i == $#{$ref_to_crossref} or $i == 0);
        $mif->add($mif->Tr(\%hh), $regtable);
    }
}

# write mif file header for register
sub mix_rep_reglist_mif_starttable($$ )
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
    return $regtable;
}

# write mif file header for register
sub mix_rep_reglist_mif_header($$$$$$ )
{
    my ($mif, $regtable, $regname, $address, $mode, $init) = @_;

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

    return $crossref;
}

# write mif file for register
sub mix_rep_reglist_mif_bitfields($$$ )
{
    my ($mif, $regtable, $fields) = @_;
    my $headtext = "";

    ############ Row for the bits 31 .. 16
    # Update signal field on the left hand side
    $headtext = $mif->wrCell({ 'PgfTag'           => 'CellHeadingH8',
                               'String'           => 'Update:',
                               'Rows'             => 4,
                               'PgfCellAlignment' => "Middle",
                               'Fill'             => 0,
                               'Color'            => "Gray 6.2"
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
    # Update signal on the left hand side (taken from bitfield 0)
    $headtext = $mif->wrCell({ 'PgfTag' => 'CellBodyH8',
                               'PgfCellAlignment' => "Middle",
                               'String' => $fields->[0]->{sync},
                               'Fill'   => 0,
                               'Color'  => "Gray 6.2"
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
    # empty field on the left hand side
    $headtext = $mif->wrCell({ 'PgfTag' => 'CellBodyH8', 'PgfCellAlignment' => "Middle", 'Fill' => 0 }, 2);

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
                               'PgfCellAlignment' => "Middle",
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
    $mif->add($mif->Tr({ 'WithPrev' => 'Yes',
                         'Text'     => $headtext,
                         'Indent'   => 0
                       }), $regtable);

    return;
}


# write row containing information about API
sub mix_rep_reglist_mif_api($$$ )
{
    my ($mif, $regtable, $api) = @_;
    my $headtext = "";

    # API field
    $headtext = $mif->wrCell({ 'PgfTag'      => 'CellHeadingH8',
                               'String'      => 'API:',
                               'Fill'        => 0,
                               'Color'       => "Gray 6.2"
                              },
                              2);
    # api function
    $headtext .= $mif->wrCell({ 'PgfTag'     => 'CellBodyH8',
                                'String'     => $api,
                                'Columns'    => 16
                              },
                              2);
    for (my $i = 1; $i <= 15; $i++) {
        $headtext .= $mif->wrCell({ 'PgfTag' => 'CellHeading' }, 2);
    }
    $mif->add($mif->Tr({ 'WithNext' => 'Yes',
                         'WithPrev' => 'Yes',
                         'Text'     => $headtext,
                         'Indent'   => 0
                       }), $regtable);

    return;
}

##### Header of the bitslice description section/table
sub mix_rep_reglist_mif_bitfield_description_header($$$)
{
    my ($mif, $regtable, $newtable) = @_;

    my $headtext = $mif->wrCell({ 'PgfTag'     => 'CellHeadingH8',
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
    $headtext .= $mif->wrCell({ 'PgfTag'  => 'CellHeading' }, 2);
    $headtext .= $mif->wrCell({ 'PgfTag'  => 'CellHeading' }, 2);
    $headtext .= $mif->wrCell({ 'PgfTag'  => 'CellHeadingH8',
                                'String'  => 'R/W',
                                'Columns' => 2,
                                'Fill'    => 0,
                                'Color'   => "Gray 6.2"
                              },
                              2);
    $headtext .= $mif->wrCell({ 'PgfTag'  => 'CellHeading' }, 2);
    $headtext .= $mif->wrCell({ 'PgfTag'  => 'CellHeadingH8',
                                'String'  => 'Function',
                                'Columns' => 11,
                                'Fill'    => 0,
                                'Color'   => "Gray 6.2"
                              },
                              2);
    for (my $i = 0; $i < 10; $i++) {
        $headtext .= $mif->wrCell({ 'PgfTag' => 'CellHeading' }, 2);
    }

    my %hh = ('WithNext' => 'Yes',
              'Text'     => $headtext,
              'Indent'   => 1
              );
    if ($newtable) {
        $mif->table_head($mif->Tr(\%hh), $regtable);
    } else {
        $mif->add($mif->Tr(\%hh), $regtable);
    }
    ##### End header of the bitslice section
}

##### Bitslices description
sub mix_rep_reglist_mif_bitfield_description($$$)
{
    my ($mif, $regtable, $fields) = @_;

    for (my $fi = 0; $fi <= $#{$fields}; $fi++) {
        my $msb = $fields->[$fi]->{pos} + $fields->[$fi]->{size} - 1;
        my $lsb = $fields->[$fi]->{pos};
        my $string = ($msb == $lsb) ? $msb : "$msb:$lsb";
        my $text = $mif->wrCell({ 'PgfTag'   => 'CellBodyH8',
                                  'String'   => "[$string]"
                                },
                                2);
        $msb = $fields->[$fi]->{size} + $fields->[$fi]->{lsb} - 1;
        $lsb = $fields->[$fi]->{lsb};
        if ($msb == $lsb) {
            $string = $fields->[$fi]->{name};
        } else {
            $string = $fields->[$fi]->{name} . "[$msb:$lsb]";
        }
        $text .= $mif->wrCell({ 'PgfTag'  => 'CellBodyH8',
                                'String'  => $string,
                                'Columns' => 3
                              },
                              2);
        $text .= $mif->wrCell({ 'PgfTag'  => 'CellHeading' }, 2);
        $text .= $mif->wrCell({ 'PgfTag'  => 'CellHeading' }, 2);
        $text .= $mif->wrCell({ 'PgfTag'  => 'CellBodyH8',
                                'String'  => $fields->[$fi]->{mode},
                                'Columns' => 2
                              },
                              2);
        $text .= $mif->wrCell({ 'PgfTag'  => 'CellHeading' }, 2);
        $text .= $mif->wrCell({ 'PgfTag'  => 'CellBodyH8',
                                'String'  => $fields->[$fi]->{comment},
                                'Columns' => 11
                              },
                              2);
        for (my $i = 0; $i < 10; $i++) {
            $text .= $mif->wrCell({ 'PgfTag' => 'CellHeading' }, 2);
        }
        my %hh = ('Text' => $text, 'Indent' => 1);
        $hh{WithPrev} = 'Yes' if ($fi == $#{$fields} or $fi == 0);
        $mif->add($mif->Tr(\%hh), $regtable);
    }
}

#
# return signals in requested order ...
#
# config value: $eh->{report}{portlist}{sort}
#
# alpha := sorted by port name (default)
# input (ordered as listed in input files) 			
sub _mix_report_sigsort {
	my $splist = shift;

	my $pos = ( $eh->get( 'report.portlist.data' ) =~ m/\bport\b/ );
	# $a and $b hold the respective conndb keys
	my $key = $eh->get( 'report.portlist.sort' );
	my $conndb = \%Micronas::MixParser::conndb;
	
#	my $va = $a;
#	my $vb = $b;
	my %spo = ();
	# Iterate over signals
	for my $s ( keys( %$splist ) ) {
		# Iterate over ports
		for my $p ( keys( %{$splist->{$s}} ) ) {
			my $va = '';
			if ( $key =~ m/\balpha\b/io ) {
				if ( $pos ) {
					$va = $p;
				} else {
					$va = $conndb->{$s}{'::name'};
				}
			} elsif ( $key =~ m/\binput\b/io ) {
				my $format = '%0' . ( length( $eh->get( 'sum.conn' ) ) + 1 ) . 'd'; # 
				$va = sprintf( $format, $conndb->{$s}{'::connnr'});
			} # elsif ( $key =~ m/(\b::\w+)\b/io ) {
			$spo{$va . '!###!' . $s . '!###!' . $p } = 1;
		}
	}

	# Do the sort here:
	# $va cmp $vb;
	my @sorted = ();
	for my $i ( sort( keys %spo ) ) {
		push( @sorted, [ (split( /!###!/, $i ))[1..2] ] );
	}
	return @sorted;
} # End of _mix_report_sigsort

#
# combine ::conn data structure into one hash
#
sub _mix_report_conn2sp ($) {
	my $conn = shift;

	my %sp = ();
	for my $m ( qw( in out ) ) {
		for my $s ( keys( %{$conn->{$m}} ) ) {
			$sp{$s} = $conn->{$m}->{$s};
		}
	}
	return \%sp;
} # End of _mix_report_conn2sp


#
# Print a list of all I/O signals ....
#
sub mix_rep_portlist () {

	# If ::external column is set, make a seperate table for "externals"
	my $exttrigger = '';
	if ( $eh->get( 'report.portlist.split' ) =~ m/\bexternal(::\w+)?/ ) {
		$exttrigger = "::external";
		if ( defined $1 ) {
			$exttrigger = $1;
		}
	}
	# Prepare a table object ...
	my( $mif, $mifname, $plist, $elist ) =
		_mix_report_portlist_create ( $exttrigger );

	my %names_used = (); # Remember that name ...
	
	# Iterate over all instances ...
	my $hierdb = \%Micronas::MixParser::hierdb;
	my $conndb = \%Micronas::MixParser::conndb;
	for my $instance ( sort keys( %$hierdb ) ) {
		next if ( $hierdb->{$instance}{'::entity'} eq 'W_NO_ENTITY' );
		next if ( $instance =~ m/^%\w+/ );

		if ( $eh->get( 'report.portlist.split' ) =~ m/\bfile/io ) {
			# Create new file for each instance ...
			($mif, $mifname, $plist, $elist ) =
				_mix_report_portlist_create ( $exttrigger );
				# Check for uniq name near the flush ---
		}
		my $link = $hierdb->{$instance};
		
		# Create a large table ...
		## Instance name:
		my $line = $mif->td(
			{ 'PgfTag' => 'CellHeadingH9',
			  'Columns' => 6, # Columns Span of all six cells
			  'String'  => "$link->{'::inst'} ($link->{'::entity'})",
			}
		);
		
		# Remember name, overwrite output file name:
		if ( $eh->get( 'report.portlist.name' ) =~ m/^INST$/ ) {
			$mifname = $link->{'::inst'} . '-portlist.' .
				$eh->get( 'report.portlist.ext' );
		} elsif ( $eh->get( 'report.portlist.name' ) =~ m/^ENTY$/ ) {
			$mifname = $link->{'::entity'} . '-portlist.' .
				$eh->get( 'report.portlist.ext' );
		}
		
		$mif->add( $mif->Tr($line), $plist );
		
		#!wig20051103: different format for elist ...
		if ( $elist ne '' ) {
			$line = $mif->td(
				{ 'PgfTag' => 'CellHeadingH9',
			 		'Columns' => 4, # Columns Span of all three cells
			  		'String'  => "Input/Output PADs $link->{'::inst'} ($link->{'::entity'})",
				}
			);
			$mif->add( $mif->Tr($line), $elist );
		}

		## Signals at that instance
		#OLD for my $signal ( sort _mix_report_sigsort keys( %{$link->{'::sigbits'}} ) ) {}
		#!wig20060406: use the ::conn data instead ..
		my $sigandport = _mix_report_conn2sp( $link->{'::conn'} );

		for my $sigport ( _mix_report_sigsort( $sigandport ) ) {
			# Iterate over all signals ... (and ports)
			my $signal = $sigport->[0];
			my $port   = $sigport->[1];

			my $signalname = $conndb->{$signal}{'::name'};
			# my $connect = $link->{'::sigbits'}{$signal};
			my $connect = $link->{'::sigbits'}{$signal}; # new20060406
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
			my $rpc = $eh->get( 'report.portlist.comments' );

			my $striphash = 0;
			if ( $rpc =~ m/\bstrip(hash|all)/io ) {
				$striphash = 1;
			}
			my $stripdblslash = 0;
			if ( $rpc =~ m/\bstrip(dblslash|all)/io ) {
				$stripdblslash = 1;
			}
			# Parse for number of lines to print out:
			#	-1 or less -> do not print!
			#	0  -> unlimited
			#	N  -> print N consecutive lines
			my $incom_lines = 0;
			$rpc =~ m/(-?\d+)/;
			if ( defined( $1 ) ) {
				$incom_lines = $1;
			}
			if ( $incom_lines == 0 ) {
				$incom_lines = 100000; # This is nearly unlimited ....
			} elsif ( $incom_lines < 0 ) {
				$incom_lines = 0;
			}
			# Skip print if config is "naportlist"
			if ( $rpc =~ m/\bnaportlist\b/ ) {
				$incom_lines = 0;
			}
			# Only select lines with matchin tag:
			#	tag:portlist -> #portlist\s*
			my $select_tag = '';
			if ( $rpc =~ m/\btag:(\w+)/ ) {
				$select_tag = $1;
			}
			
			my $incom_mode = '';
			my $incom_text = '';
			# Print up to $incom_lines ....
			if ( $incom_lines and exists $conndb->{$signal}{'::incom'} ) {
				my $this_count = scalar( @{$conndb->{$signal}{'::incom'}} );
				my $min = 0;
				my $max = ( $this_count < $incom_lines ) ? $this_count : $incom_lines;
				$incom_mode = $conndb->{$signal}{'::incom'}[0]->mode();
				if ( $incom_mode eq 'post' ) { # Take $max starting from last ...
					$min = $this_count - $max;
					$max = $this_count;
				}
				$max--;
				for my $com ( @{$conndb->{$signal}{'::incom'}}[$min..$max] ) {
					# $com is InComment Object ...
					my $t = $com->print() . "\n";
					# Only choose comments with matching tag:
					if ( $select_tag ) {
						if ( $t =~ m/\s*#$select_tag\s+(.*)/ ) {
							$t = $1;
						} else {
							$t = '';
						}
					}
					$t =~ s,^\s*#+,, if ( $striphash );
					$t =~ s,^\s*//,, if ( $stripdblslash );
					$incom_text .= $t;
				}
				chomp( $incom_text );
			}
			
			# Add comment line (mode = post -> print before!)		
			if ( $incom_mode eq 'post' ) {
				my $line = $mif->td(
				{ 	'PgfTag' => 'CellHeadingH9',
			  		'Columns' => 6, # Columns Span of all six cells
			  		'String'  => $incom_text,
				} );		
				$mif->add( $mif->Tr($line), $plist );
			};

			if ( $signal =~ m/%(HIGH|LOW)_BUS(_\d+)?%/ ) {
				# Get width from ::conn ...
				my $co = $hierdb->{$instance}->{'::conn'}->{'in'}->{$signal}->{$port};
				$high	= $conndb->{$signal}->{'::in'}->[$co]->{'sig_f'} || 0;
				$low	= $conndb->{$signal}->{'::in'}->[$co]->{'sig_t'} || 0;
			} elsif ( $signal =~ m/%(HIGH|LOW)(_\d+)?%/ ) {
				$high = '';
				$low  = ''; 
			}
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

			#  What to print: port or signal
			my $name = $signalname;
			if ( $eh->get( 'report.portlist.data' ) =~ m/\bport\b/ ) {
				$name = $port;
				# $name = _mix_report_getport( $signalname, $link );
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
					   		$name,
					   		$width,
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
				  		$name,
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
			# pre -> print comments >after< corresponding lines
			if ( $incom_mode eq 'pre' ) {
				my $line = $mif->td(
				{ 	'PgfTag' => 'CellHeadingH9',
			  		'Columns' => 6, # Columns Span of all six cells
			  		'String'  => $incom_text,
				} );		
				$mif->add( $mif->Tr($line), $plist );
			}
		}

		# Write one file per instance (entity):
		if ( $eh->get( 'report.portlist.split' ) =~ m/\bfile/io ) {
			# Flush it now:
		
			# Did we write that before?	
			if ( exists ( $names_used{$mifname} ) ) {
				$logger->error( '__E_REPORT_FILE', "\tReused portlist file name: $mifname!" );
			}
			$names_used{$mifname} = 1;
			_mix_report_flushmif($mif, $mifname, $plist, $elist );
		}

	}

	# Write common file:
	unless ( $eh->get( 'report.portlist.split' ) =~ m/\bfile/io ) {
		# Flush it now:	
		_mix_report_flushmif( $mif, $mifname, $plist, $elist );
	}

	return;

}

#
# Write prepared data to disk
#
sub _mix_report_flushmif ($$$$) {
	my $mif = shift;
	my $mifname = shift;
	my $plist = shift;
	my $elist = shift;
	 
	$mif->end_body( $plist );
	$mif->end_table( $plist );
	if ( $elist ne '' ) {
		$mif->end_body( $elist );
		$mif->end_table( $elist);
	}	
	
	# Write ...
	$mif->write( $eh->get( 'report.path' ) . '/' . $mifname );
}

#
# Create a new portlist file ...
#
# Input:
#	filename
# Output:
#	$mif     object
#	$mifname filename
#	$plist   primary table
#	$elist   external table
#
# Global:
#	$eh
#	%hierdb
#
#!wig20051209
sub _mix_report_portlist_create ($) {
	my $exttrigger = shift;
	
	#!wig20051208: derive portlist filename from name
	# (there is always a chance to change the filename until "write")
	my $mifname = '';

	my $hierdb = \%Micronas::MixParser::hierdb;
	
	if ( $eh->get( 'report.portlist.name' ) ) {
		$mifname =
			$eh->get( 'report.portlist.name' ) . '.' .
				$eh->get( 'report.portlist.ext' );
	} else {
		# Take top level module name ... (first if several)
		my $base = '';
		if ( exists( $hierdb->{$eh->get('top')} )
			 and exists ( $hierdb->{$eh->get('top')}{'::treeobj'} ) ) {
			my $topobj = $hierdb->{$eh->get('top')}{'::treeobj'};
			# Take daughter of top (first one!)
			for ( $topobj->daughters() ) {
				if ( exists( $hierdb->{$_->name()} ) ) {
					# check if that module is not W_NO_ENTITIY
					if ( $_->name() =~ m/testbench/i ) {
						$topobj = $_;
						next;
					}
					if ( $hierdb->{$_->name()}{'::entity'} ne 'W_NO_ENTITY' ) {
						$topobj = $_;
						last;
					}
				}
			}
			
			# Get name -> ...
			if ( $topobj->name ne 'TESTBENCH' ) {
				$base = $topobj->name;
			} else {
				# Get daughters ...
				my @daughters = $topobj->daughters;
				if ( scalar( @daughters ) ) {
					$base = $daughters[0]->{name}; # TODO : Get that as object ...
				}
			}
		}
		$base='mix_portlist' unless $base;
		
		# Strip off extension (if any)
		$base =~ s,(\.[^.]+)$,,;
		$mifname = $base . '_port.' . $eh->get( 'report.portlist.ext' );
	}
		
	my $mif = new Micronas::MixUtils::Mif(
		'name' => ( $eh->get( 'report.path' ) . '/' . $mifname ),
	);
		
	$mif->template(); # Initialize it

	# If ::external column is set, make a seperate table for "externals"
	my $elist = '';
	if ( $exttrigger ) {
		#!wig20051103: new format ...
		$elist = $mif->start_table(
			{	'Title' => 'External Pin List',
				'TblTag' => 'PortList',
				'Cols' => 4,
				'ColumnWidth' => [ qw( 37.0 13.0 13.0 117.0 ) ], 
			}
		);
	}
	
	# Portlist
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
	my $headtext;
	if ( $elist ne '' ) {
		$headtext = $mif->td(
			{ 'PgfTag' => 'CellHeadingH9',
		  	  'String' => [
			  	qw( PAD_Name Width I/O Description ),
		  		],
			}
		);
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
	
	return( $mif, $mifname, $plist, $elist );
} # End of _mix_report_portlist_create

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
		$logger->warn( '__W_MIX_REPORT', "\tCould not map signal " . $signal .
			" to portname for instance " . $link->{'::inst'} );
	} elsif ( scalar( @ports ) > 1 ) {
		# More than one port attached :-(
		$logger->warn( '__W_MIX_REPORT', "\tMultiple ports connected to " . $signal .
			" at instance " . $link->{'::inst'} );
		$signal = join( ',', @ports );
	} else {
		$signal = $ports[0];
	}

	return $signal;

} # End ox _mix_report_getport

#
# Get list of connected instances ...
# TODO : Do not print constants and other pseudo instances
sub _mix_report_getinst ($) {
	my $ref = shift;
	
	my %ins = ();
	for my $i ( @$ref ) {
		if ( exists( $i->{'inst'} ) ) {
			$ins{$i->{'inst'}} = 1;
		}
	}

	return join( ',', keys %ins );
} # End of _mix_report_getinst

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
	
	my $sfull = '';
	my $smode = '';
	
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
			$sfull = $full;
			$smode = $mode;
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
