# -*- perl -*---------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# |
# |   Copyright 2002/2005 Trident Microsystems (Europe) GmbH, Germany
# |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# | Project:    Micronas - MIX / Report                                   |
# | Modules:    $RCSfile: MixReport.pm,v $                                |
# | Revision:   $Revision: 1.74 $                                               |
# | Author:     $Author: lutscher $                                                 |
# | Date:       $Date: 2009/12/14 12:43:43 $                                                |
# |                                                                       |                            |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/MixReport.pm,v 1.74 2009/12/14 12:43:43 lutscher Exp $|
# +-----------------------------------------------------------------------+
#
# Write reports with details about the hierachy and connectivity of the
# generated nets/entities/....
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# | Changes:                                                              |
# | $Log: MixReport.pm,v $
# | Revision 1.74  2009/12/14 12:43:43  lutscher
# | changed mix_rep_header_print to consider register-width
# |
# | Revision 1.73  2009/12/14 12:22:48  lutscher
# | added old c-macro
# |
# | Revision 1.72  2009/12/14 10:58:17  lutscher
# | changed copyright
# |
# | Revision 1.71  2009/12/14 08:49:09  lutscher
# | add nformat
# |
# | Revision 1.70  2009/12/03 13:16:19  lutscher
# | prune comments in C-Header; improve reg_naming, can also use %B now
# |
# | Revision 1.69  2009/12/02 14:29:26  lutscher
# | repaired cheader and perl views
# |
# | Revision 1.68  2009/06/15 11:57:25  lutscher
# | added addrmaps member to Reg and RegDomain
# |
# | Revision 1.67  2008/11/13 10:46:26  lutscher
# | added 2nd .per file generation
# |
# | Revision 1.66  2008/09/02 08:43:23  lutscher
# | added report.cheader.use_view_attrib
# |
# | Revision 1.65  2008/09/02 07:12:54  lutscher
# | view attribute has now no effect on c-header/perl/lauterbach file generation
# |
# | Revision 1.64  2008/08/28 13:49:24  lutscher
# | uppercase for client names; changed mix_rep_perl_open according to R.Winter request
# |
# | Revision 1.63  2008/08/27 12:54:40  lutscher
# | some failsafe code for reading the top-level sheet
# |
# | Revision 1.62  2008/08/20 10:39:15  lutscher
# | fixed mix_rep_per_print
# |
# | Revision 1.61  2008/08/19 14:10:04  lutscher
# | code clean-up
# |
# | Revision 1.60  2008/07/10 12:42:54  lutscher
# | improved error handling in mix_rep_header_read_top_address_map
# |
# | Revision 1.59  2008/06/23 09:17:12  lutscher
# | moved portlist report to dedicated function because it does not use the register object
# |
# | Revision 1.58  2008/06/16 16:01:11  megyei
# | Replaced option '-report <view>' by corresponding setting in mix.cg.
# |
# | The config parameter reg_shell.type can now take all the views that were
# | previously defined by the -report option.
# |
# | Revision 1.57  2008/05/05 11:45:50  megyei
# | The new report specifier 'vctyper' reads the device.ini file and computes the addresses when writing
# | .per files.
# | The number of spaces in the 'bitfld.long' lines is now calculated from the length of the bitfield
# | (ceil(<bitfield length>) + 1).
# |
# | Revision 1.56  2008/02/18 11:54:18  mathias
# | Use default value for the .per file name
# |
# | Revision 1.55  2007-12-19 13:52:45  mathias
# | put parenthesis around the parameter 'base' in the macro that computes
# | the real base address of a block
# |
# | Revision 1.54  2007-11-22 09:36:06  mathias
# | Registers are now documented in the mif file when at least ome bitfield has to be visible.
# |
# | Revision 1.53  2007-11-02 13:42:14  mathias
# | mix_rep_header_read_top_address_map:
# |  fix: when assigning the client name take into account only the number of clones in the current line
# |
# | mix_rep_per_print:
# |  the printed 'width' has to be 1 higher than the longest name in order to reserve space
# |  for the closing '0' in the Lauterbach debugger
# |
# | Revision 1.52  2007/09/28 14:04:37  mathias
# | bugfix
# |
# | Revision 1.51  2007-09-27 13:23:30  mathias
# | mix_rep_header_read_top_address_map:
# | client names are numbered consecutively according to the
# | accumulated number of clones
# |
# | Revision 1.50  2007-09-27 07:39:25  mathias
# | mix_rep_header_read_top_address_map: hierachical address map
# | multiple instantiated blocks can contain sub-blocks that are also multiple instantiated
# | The instance name (::client) is used in order to generate unique names
# | in the header structure.
# |
# | Revision 1.49  2007-06-26 13:49:05  mathias
# | write footnote when some bitfields have 'W1C', 'W0C' or 'WC' in the column '::spec'
# |
# | Revision 1.48  2007-03-23 08:41:11  mathias
# | mix_rep_reglist_mif_header: removed ':' after Init in the table header
# |
# | Revision 1.47  2007-02-20 15:46:45  mathias
# | fixed something
# |
# | Revision 1.46  2007-02-14 08:32:00  mathias
# | perl package name should be in upper case
# |
# | Revision 1.45  2007-02-13 14:25:30  mathias
# | fix
# |
# | Revision 1.44  2007-02-13 12:36:08  mathias
# | encapsulate the c typedefs with '#ifndef LANGUAGE_ASSEMBLY'
# |
# | Revision 1.43  2007-02-13 11:34:04  mathias
# | fixes in generating per files for Lauterbach debugger
# |
# | Revision 1.42  2007-02-07 15:35:57  mathias
# | write vcty header files
# |
# | Revision 1.41  2007/02/01 07:28:42  mathias
# | generate c structures for all registers unless _every_ bitfield
# | of a register is marked as not visible (view == 'N')
# |
# | Revision 1.40  2007/01/22 17:31:50  wig
# |  	MixParser.pm MixReport.pm : update -report portlist (seperate ports)
# |
# | Revision 1.39  2006/12/22 14:20:42  mathias
# | write hidden registers to perl package
# |
# | Revision 1.38  2006-12-13 12:41:22  mathias
# | added report output to generate perl package
# |
# | Revision 1.37  2006-11-30 14:47:26  mathias
# | implemented output for the lauterbach debugger
# |
# | Revision 1.36  2006-11-24 13:42:17  mathias
# | write info for doxygen
# |
# | Revision 1.35  2006-11-09 13:35:00  mathias
# | added '#ifdef' to the written header files to prevent multiple includes
# |
# | Revision 1.34  2006-10-26 06:37:38  mathias
# | report c header files:
# | - fixed issue with endianness
# | - write macro to get real (base + offset) address
# |
# | Revision 1.33  2006-10-23 12:12:27  mathias
# | allow description (definition) of more than 1 register for the same address
# |
# | Revision 1.32  2006-10-18 08:09:03  mathias
# | fixed handling of multiple instances in report header files
# |
# | Revision 1.31  2006-10-12 11:26:59  mathias
# | implemented writing c-header files for the software delopment
# |
# | Revision 1.30  2006-07-07 11:58:37  mathias
# | fixed writing extra line into bit description table
# | when no bitfield was defined in the lower 16 bits of the register
# |
# | Revision 1.29  2006-06-22 07:13:21  wig
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
# |                                                                       |
# +-----------------------------------------------------------------------+

package Micronas::MixReport;

require Exporter;
use POSIX qw(ceil);

@ISA = qw(Exporter);
@EXPORT = qw(
	mix_report mix_reg_report
); # symbols to export by default

@EXPORT_OK = qw();

our $VERSION = '0.1';
#
# RCS Id, to be put into output templates
#
my $thisid		=	'$Id: MixReport.pm,v 1.74 2009/12/14 12:43:43 lutscher Exp $';
# ' # this seems to fix a bug in the highlighting algorithm of Emacs' cperl mode
my $thisrcsfile	=	'$RCSfile: MixReport.pm,v $';
# ' # this seems to fix a bug in the highlighting algorithm of Emacs' cperl mode
my $thisrevision   =      '$Revision: 1.74 $';
# ' # this seems to fix a bug in the highlighting algorithm of Emacs' cperl mode

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
use Micronas::MixUtils qw($eh %OPTVAL convert_in);
use Micronas::MixUtils::IO qw(open_infile);
use Micronas::Reg;
use Micronas::MixUtils::RegUtils;
use Micronas::MixUtils::Mif;
use File::Basename;

# attributes of the RegReg RegField objects that will be dumped in view "perl"
use constant PERL_REG_ATTRIBS => qw(size);
use constant PERL_FIELD_ATTRIBS => qw(size lsb init dir spec clock sync nformat);

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

# sub new {
# 	my $this = shift;
# 	my %params = @_;
# 
# 	# data member default values
# 	my $ref_member  = {
# 					   # device => "<no device specified>",
# 					   # domains => [],
# 					   # global => \%hglobal  # reference to class data
# 					  };
# 	# init data members w/ parameters from constructor call
# 	foreach (keys %params) {
# 		$ref_member->{$_} = $params{$_};
# 	};
# 
# 	bless $ref_member, $this;
# };

#
# Do the reporting if requested ...
#

# general reports; this function is called from main 
sub mix_report() {
    return unless ( exists $OPTVAL{'report'} );

    my $reports = join( ',', @{$OPTVAL{'report'}} );
    # portlist:
    if ( $reports =~ m/\bportlist\b/io ) {
        mix_rep_portlist();
        return;
    };

    # if still here, complain to user
    $logger->error('__E_OPT', "  Option '-report $OPTVAL{report}->[0]' has been changed!");
    $logger->error('       ', "  Please use '-conf reg_shell.type=$OPTVAL{report}->[0]' instead");
    $logger->error('       ', "  or specify all views you want to generate in the mix.cfg file!");
};

# generate reports/views for the register object (this is here and not in the Reg packages because formerly maintained by Mathias);
# this function is called by Reg module
sub mix_reg_report($$)
{
    my ($r_i2cin) = shift;
    my ($reports) = shift;

    if ( $reports =~ m/\breglist\b/io ) {
        $logger->info('__I_REPORT', "\tReport register list in mif format");
        mix_rep_reglist($r_i2cin);
    }
    if ( $reports =~ m/\bcheader\b/io ) {
        $logger->info('__I_REPORT', "\tGenerate C-header files");
        mix_rep_header($r_i2cin);
    }
    if ( $reports =~ m/\bper\b/io ) {
        $logger->info('__I_REPORT', "\tReport Lauterbach peripheral files");
        mix_rep_per($r_i2cin);
    }
    if ( $reports =~ m/\bperl\b/io ) {
        $logger->info('__I_REPORT', "\tGenerate Perl package file");
        mix_rep_perl($r_i2cin);
    }
}

##############################################################################

#####################################################################
# Report header files
#####################################################################

sub mix_rep_header($)
{
    my ($o_space) = @_;        # Reference to the register object

    if (defined $o_space) {
        
        # iterate through all domains
        foreach my $o_domain (@{$o_space->domains}) {
            my $fh = mix_rep_header_open_files($o_space, $o_domain);
         
            # collect all information to the registers in a hash with the address as the key
            my %theBlock;
            foreach my $o_reg (@{$o_domain->regs()}) {
                my $addr_1   = $o_domain->get_reg_address($o_reg);
                my $address  = sprintf("0x%08X", $addr_1);
                my $init     = sprintf("0x%08X", $o_reg->get_reg_init());
                my $mode     = $o_reg->get_reg_access_mode();

                while (exists($theBlock{$address})) {
                    $address .= "_1";
                }
                my $block_name = $o_reg->fields->[0]->{"field"}->attribs->{"block"}; # take block from first field
                $theBlock{$address}->{regname} = _clone_name($eh->get('report.reg_naming'),99,$o_reg->id,$o_domain->name, $o_reg->name, "", $block_name);
                $theBlock{$address}->{init}    = $init;
                $theBlock{$address}->{size}    = $o_reg->attribs->{'size'};
                if ($eh->get('report.cheader.debug')) {
                    print("~~~~~ Register: " . $o_reg->name() . "     $theBlock{$address}->{regname}\n");
                }
                my $ii = 0;
                my @thefields;
                foreach my $hreff (@{$o_reg->fields}) {
                    my $o_field = $hreff->{'field'};
                    # select type of register
                    $thefields[$ii]{name}    = _clone_name($eh->get('report.field_naming'),99,$o_field->id,$o_domain->name,$o_reg->name,$o_field->name, $o_field->attribs->{'block'});
                    $thefields[$ii]{size}    = $o_field->attribs->{'size'};
                    $thefields[$ii]{pos}     = $hreff->{'pos'}; # LSB position
                    $thefields[$ii]{lsb}     = $o_field->attribs->{'lsb'};
                    $thefields[$ii]{view}    = $o_field->attribs->{'view'}; # N: no documentation  Y: bitfield to document
                    # ignore this bitfield
                    if(lc($thefields[$ii]{view}) ne 'y' and $eh->get('report.cheader.use_view_attrib')) {
                        $logger->info("__I_REPORT", "\texcluding field ".lc($o_field->name)." from C-header because view attribute is set to N");
                        next;
                    };
                    $thefields[$ii]{mode}    = $o_field->attribs->{'dir'};
                    $thefields[$ii]{comment} = $o_field->attribs->{'comment'};
                    $thefields[$ii]{comment} =~ s/\\.//g;
                    $thefields[$ii]{sync}    = $o_field->attribs->{'sync'};
                    if ($eh->get('report.cheader.debug')) {
                        print("~~~~~    " . $thefields[$ii]{name} . '(' . $thefields[$ii]{size}
                              . ')' . '/' . $thefields[$ii]{pos}  . "\n");
                    }
                    $ii += 1;
                }
                if ($ii == 0) {
                    # no visible bitfield found, ignore the whole register
                    delete $theBlock{$address};
                    next;
                }
                # sort the fields (probably reserved?)
                #@thefields = reverse sort {${$a}{pos} <=> ${$b}{pos}} @thefields;
                @thefields = sort {${$a}{pos} <=> ${$b}{pos}} @thefields;
                
                $theBlock{$address}->{fields} = \@thefields;
            }
            # All register were read in, write the header file
            mix_rep_header_print($fh, $o_domain->name, \%theBlock);

            # close the header file
            $fh->print('/* \@} */' . "\n");    # doxygen
            $fh->print("#endif\n");            # end of LANGUAGE_ASSEMBLY
            $fh->print("#endif\n");
            $fh->close();
        }
    }
    return 0;
}

##############################################################################
#####################################################################
# Read the top address map in
# Return:
#          $blocks       Reference to a hash
#####################################################################
# note: only works for old format of the top-level Register-Master, no longer used!!!

sub mix_rep_header_read_top_address_map()
{
    ####!!!!!! How to get the file name of the top address sheet?
    my $files = $eh->get('report.cheader.address.map');
    # print("!!!!! top address map: `$files'\n");
    my @arrayhash;
    # Open top address file and retrieve the desired sheet (Sheet1 the only one)
    my $type = 'default';
    my $conn = open_infile($files, 'Sheet1', '', $eh->get($type . '.req') . ',hash');
    if (!defined($conn)) {
        $logger->error("__E_REPORT_FILE", "\tCould not read top-address-map sheet, filename must be supplied via parameter report.cheader.address.map");
    };
    # Convert to hashes ...
    foreach my $sheetname (keys %$conn) {
        if ($sheetname eq 'Sheet1') {
            @arrayhash = convert_in($type, $conn->{$sheetname});
        }
    }
    # get the instance names that replace the client names from the top address map
    # (defined in MIX' config file)
    my $chref_inst = $eh->get('report.cheader.instance');
    # get the type names that replace the definition from the top address map
    # (defined in MIX' config file)
    my $chref_types = $eh->get('report.cheader.transform');
    # remove the "'" from the string read in in order to get perl regexp syntax
    foreach my $key (sort keys %$chref_types) {
        $chref_types->{$key} =~ s/^'//;
        $chref_types->{$key} =~ s/'$//;
    }
    # relevant informations from top address sheet
    my %blocks;
    my $clone_start;  # when one '::definition' has clones, first one begins at this position
    foreach my $block (@arrayhash) {
        my $name = $block->{'::definition'};
        if ($name ne 'Definition') {
            if (! exists($blocks{$name})) {            # first occurence of $name
                $blocks{$name}->{name} = $name;        # remember the name also in the hash
                $clone_start = 0;
                if (!exists $block->{'::reg_clones'} or $block->{'::reg_clones'} eq "" or !exists $block->{'::clone_spacing'}) {
                    $logger->warn( '__E_REPORT', "\tdefinition attribute is used, this requires also reg_clones and clone_spacing attributes; setting them to 1/0");
                    $blocks{$name}->{reg_clones} = 1;
                    $blocks{$name}->{size} = hex("0x0");
                } else {
                    $blocks{$name}->{reg_clones} = $block->{'::reg_clones'};  
                    $blocks{$name}->{size}       = hex('0x' . $block->{'::clone_spacing'});
                };
            } else {                                   # more instances of $name
                $clone_start = $blocks{$name}->{reg_clones};
                $blocks{$name}->{reg_clones} += (exists($block->{'::reg_clones'}) and $block->{'::reg_clones'} ne "" ? $block->{'::reg_clones'} : 1);
                # check whether the same size is defined as in previous occurence of $name
                if (exists ($block->{'::clone_spacing'}) and $blocks{$name}->{size} != hex('0x' . $block->{'::clone_spacing'})) {
                    my $msg = "\tFor $name different size (::clone_spacing " . $block->{'::clone_spacing'};
                    $msg .= ") defined as for previous occurence (" . $blocks{$name}->{size} . ")!";
                    $logger->error('__E_REPORT_FILE', $msg);
                }
            }
            ###!!!! replace client names from the sheet by the ones from mix config file
            if (exists ($block->{'::reg_clones'}) and $block->{'::reg_clones'} ne "" and $block->{'::reg_clones'} > 1) {
                for (my $i = $clone_start; $i < $blocks{$name}->{reg_clones}; $i++) {
                    my $client = $name;
                    if (exists($chref_inst->{lc($client)})) {
                        $client = $chref_inst->{lc($client)};
                    }
                    # client names are numbered consecutively according to the
                    # accumulated number of clones
                    push(@{$blocks{$name}->{clients}}, $client . $i);
                    push(@{$blocks{$name}->{base_addr}}, hex('0x' . $block->{'::sub'}) + ($i - $clone_start) * $blocks{$name}->{size});
                }
            } elsif (exists($chref_inst->{lc($block->{'::client'})})) {
                push(@{$blocks{$name}->{base_addr}}, hex('0x' . $block->{'::sub'}));
                push(@{$blocks{$name}->{clients}}, $chref_inst->{lc($block->{'::client'})});
                $blocks{$name}->{reg_clones} = scalar(@{$blocks{$name}->{clients}});
            } else {
                push(@{$blocks{$name}->{base_addr}}, hex('0x' . $block->{'::sub'}));
                push(@{$blocks{$name}->{clients}},   $block->{'::client'});
                $blocks{$name}->{reg_clones} = scalar(@{$blocks{$name}->{clients}});
            }
        }
    }

    return(\%blocks, $chref_types);
}

#####################################################################
# Read the device.ini file
# Parameter:
#          $old_blocks   Reference to the hash created from top address sheet
# Return:
#          $blocks       Reference to a hash containing the blocks
#                        from device.ini
#####################################################################

sub mix_rep_vcty_read_device_ini($)
{
    my ($old_blocks) = @_;
    my $file = $eh->get('report.cheader.device.ini');
     my %blocks;
    my $BaseAddress = $old_blocks->{sci_vcty_core}->{base_addr}->[0];

    # Open device.ini file
    my $fh = new FileHandle $file, 'r';
    if (! defined($fh)) {
        $logger->error( '__E_REPORT_FILE', "\tCannot open file: $file!" );
        exit(2);
    }
    while (my $line = $fh->getline()) {
        chomp($line);
        if ($line =~ m/\s*device\s+([^\s]+)\s+=\s+7'h([^\s]+);/) {
            my $name = $1;
            $blocks{$name}->{name} = $name;
            $blocks{$name}->{reg_clones} = 1;
            push(@{$blocks{$name}->{clients}}, $name);
            $blocks{$name}->{base_addr}->[0] = (hex($2) << 10) + $BaseAddress;
            #$blocks{$1} = hex($2) * 1024;
        }
    }

    return(\%blocks);
}

#####################################################################
# mix_rep_header_check_name
#          apply possibly string replacement to $regname
# Parameter:
#          $regname    <Blockname>_<Register name>
#          $rTypes     ref to the hash with search replace strings
# Return:
#          $regname
#####################################################################

sub mix_rep_header_check_name($$)
{
    my ($regname, $rTypes) = @_;

    foreach my $key (sort keys %$rTypes) {
        my ($from, $to) = split(/,/, $rTypes->{$key});
        if ($regname =~ m/$from/) {
            #if ($regname =~ m/cpus_/i) {
            #    print("##### Name: $regname    From: $from     To: $to\n");
            #}
            $regname =~ s/$from/$to/;
            #if ($regname =~ m/cpus_/i) {
            #    print("            $regname\n");
            #}
        }
    }
    return $regname;
}

#####################################################################
# Open the header file for one register domain
# Write global address(es) into the file
# Return:
#          $fh       FileHandle
#####################################################################

sub mix_rep_header_open_files {
    my ($o_space, $o_domain) = @_;

    # create include dir if not already there
    if (! -d $eh->get('output.path_include')) {
        if ($eh->get('output.mkdir') =~ m/auto|all|yes/i) {
            mkdir($eh->get('output.path_include'))
        } else {
            _error("directory \'",$eh->get('output.path_include'),"\' does not exist and I am not allowed to create it (mkdir parameter)");
        };
    };

    my $domain_name = $o_domain->name;
    
    my $filename = $eh->get("output.path_include") . "/reg_". lc($domain_name) . ".h";
    my $base_addr = $o_space->get_domain_baseaddr($o_domain->name,  $o_space->try_addrmap_name($eh->get("report.addrmap")));
    if (!defined $base_addr) {
        $logger->error('__E_REPORT', "\t could not determine base-address for domain ".$o_domain->name);
    };
    my $fh = new FileHandle $filename, "w";
    if (! defined($fh)) {
        $logger->error( '__E_REPORT', "\tCould not open file `$filename'!");
    }
   
    # apply domain-naming rule
    my $newname=_clone_name($eh->get('report.domain_naming'),99,$o_domain->id,$domain_name);
 
    # prevent multiple includes
    my $newf = basename $filename;
    $newf =~ s/\./_/g;
    $fh->print("#ifndef _" . uc($newf) . "_\n");
    $fh->print("#define _" . uc($newf) . "_\n\n");
    $fh->print('/** @addtogroup ' . uc($newf) . "*/\n");
    $fh->print('/* @{  */' . "\n");

    # write base address(es)
    $fh->print("/* Base address */\n"); 
    my $basename =  $newname . '_BASE';
    $fh->printf("#define %-48s 0x%08x\n", $basename, $base_addr);
    $fh->print("\n");
    return $fh;
}

#####################################################################
# Print type definitions for the registers of the current domain
#####################################################################

sub mix_rep_header_print($$)
{
    my ($fh, $domain_name, $rBlock) = @_;

    $fh->write("\n/*  Relative offsets of the register adresses */\n\n");
    foreach my $addr (sort keys %{$rBlock}) {
        if ($eh->get('report.cheader.debug')) {
            print("!!!!! processing domain: '$domain_name' ... register: '$rBlock->{$addr}->{regname}'\n");
        }
        # $rBlock->{$addr}->{regname} = mix_rep_header_check_name(uc($domain_name) . '_' . $rBlock->{$addr}->{regname}, $rTypes);
        # relative address of the register in this domain
        $fh->printf("#define %-48s %s\n", $rBlock->{$addr}->{regname} . '_OFFS', (split(/_/, $addr))[0]);
        $fh->printf("#define %-48s %s\n", $rBlock->{$addr}->{regname} . '(base)', '(base + '.$rBlock->{$addr}->{regname} . '_OFFS)');
    }
    $fh->write("\n#ifndef LANGUAGE_ASSEMBLY\n");
    $fh->write("\n/* C structure bitfields */\n");
    foreach my $addr (sort keys %{$rBlock}) {
        my $reg_width = $rBlock->{$addr}->{size};
        $fh->write("\n");
        $fh->write("typedef union _" . $rBlock->{$addr}->{regname} . "_t\n");
        $fh->write("{\n");
        $fh->write("   uint${reg_width}_t Reg;\n");
        $fh->write("   struct\n");
        $fh->write("   {\n");
        #### prepapare bitfields (extended by empty ("reserved") fields
        my $high = 0;
        my @slicearr = ();
        for (my $i = 0; $i <= $#{$rBlock->{$addr}->{fields}}; $i++) {
            my $slice = $rBlock->{$addr}->{fields}->[$i];
            if ($slice->{pos} > $high) {
                my $width = $slice->{pos} - $high;
                push(@slicearr, sprintf("%5s uint${reg_width}_t %-28s : %2d;   /* reserved */\n", ' ', ' ', $width));
                $high += $width;
            }
            # prune comment
            my $tmp_comment = "";
            if ($slice->{comment}) {
                $tmp_comment = join(" \ ", split ("\n", $slice->{comment}));
                if (length $tmp_comment  > 50) {
                    $tmp_comment = substr($tmp_comment,0,50) . " [...]"
                } else {
                    $tmp_comment = substr($tmp_comment,0,50);
                };
            };
            push(@slicearr, sprintf("%5s uint${reg_width}_t %-28s : %2d;   /**< %s (#)*/\n", ' ', $slice->{name}, $slice->{size}, $tmp_comment));
            $high += $slice->{size};
        }
        # remaining bits
        if ($high < 32) {
            my $width = 32 - $high;
            push(@slicearr, sprintf("%5s uint${reg_width}_t %-28s : %2d;   /* reserved */\n", ' ', ' ', $width));
        }
        if (scalar @slicearr>1) {
            ### for little endian
            $fh->write("   #if defined(_LITTLE_ENDIAN) || defined(__LITTLE_ENDIAN)\n");
            for (my $i = 0; $i < scalar(@slicearr); $i++) {
                $fh->write($slicearr[$i]);
            }
            $fh->write("   #else\n");
            ### for big endian
            for (my $i = scalar(@slicearr) - 1; $i >= 0; $i--) {
                $fh->write($slicearr[$i]);
            }
            $fh->write("   #endif\n");
        } else {
            for (my $i = 0; $i < scalar(@slicearr); $i++) {
                $fh->write($slicearr[$i]);
            }
        };
        $fh->write("   } Bits;\n");
        $fh->write("} $rBlock->{$addr}->{regname}_t;");
        $fh->printf(" // Init value %12s\n", $rBlock->{$addr}->{init});
    }
    # Write pseudo comments with string and reset values
    # Those values will be extracted and written into a separate file by a Perl script
    # foreach my $addr (sort keys %{$rBlock}) {
    #    $fh->write("\n// Register name and init value; read by another script\n");
    #    $fh->printf("// Init   %-40s %12s\n", $rBlock->{$addr}->{regname}, $rBlock->{$addr}->{init});
    #}
}


##############################################################################
##############################################################################

#####################################################################
# Open the per file for one register
# Write global address(es) into the file; is_ead controls the postfix of the filename
# Return:
#          $fh       FileHandle
#####################################################################

sub mix_rep_per_open_files($$$$)
{
    my ($name, $blocks, $global_base_address, $is_ead) = @_;
    my $newname = $eh->get("report.cheader.definition." . lc($name));
    $newname = $name if (! defined($newname));
    my $file = lc($newname) . ($is_ead ? "_ead.per" : ".per");
    my $fh = new FileHandle $file, "w";

    if (! defined($fh)) {
        $logger->error("__E_REPORT","\tCould not open file `$file'!");
        exit(2);
    }

    return $fh;
}

#####################################################################
# Print type definitions for the registers of the current domain
#####################################################################

sub mix_rep_per_print($$$$$$$$)
{
    my ($fh, $name, $rBlock, $rTypes, $blocks, $maxwidth, $global_base_address, $is_ead) = @_;
    my $group_length;
    my @groups;
    my $ad;

    # write width; increment $maxwidth by 1 to let space for a terminating '0' in Lauterbach system
    $fh->write("width " . ($maxwidth + 1) . ".\n\n");
    for (my $i = 0; $i < $blocks->{$name}->{reg_clones}; $i++) {
        # Write base address
        if ($is_ead) {
            $ad = $blocks->{$name}->{base_addr}->[$i];
            $fh->printf("base ead:0x%08X\n", $ad);
        } else {
            $ad = hex($global_base_address) + $blocks->{$name}->{base_addr}->[$i];
            $fh->printf("base d:0x%08X\n", $ad);
        };
        $fh->printf("tree \"%s\"\n", uc($blocks->{$name}->{clients}->[$i]));

        foreach my $addr (sort keys %{$rBlock}) {
            $addr = (split(/_/, $addr))[0];
            $group_length = hex($addr) + 3;
            my $reladdr  = '0x00';
            my $groupstr = ($rBlock->{$addr}->{mode} eq 'R') ? 'rgroup' :
                ($rBlock->{$addr}->{mode} eq 'W') ? 'wgroup' : 'group';
            $fh->printf("   $groupstr.long $addr--0x%06X\n", $group_length);
            push(@groups, sprintf("   $groupstr.long $addr--0x%06X\n", $group_length));
            $fh->write("   line.long  " . $reladdr . "  \"$rBlock->{$addr}->{regname}\"\n");
            if (scalar(@{$rBlock->{$addr}->{fields}}) >= 1) {
                #### write bitfields (there are more than one)
                for (my $i = 0; $i <= $#{$rBlock->{$addr}->{fields}}; $i++) {
                    my $slice = $rBlock->{$addr}->{fields}->[$i];
                    my $digits = ceil($slice->{size} / 4) + 1;     # spaces for the debugger
                    $fh->write("      textline \"   \"\n");
                    if (!exists $slice->{comment}) { # handle fields with ::view=N
                        $slice->{comment} = "no descr. available";
                    };
                    $slice->{comment} =~ s/[\n\r]+/ /g;
                    $slice->{comment} =~ s/"//g;
                    $fh->write("      bitfld.long  " . $reladdr . " " .
                               $slice->{pos} . ".--" . ($slice->{pos} + $slice->{size} - 1) . ".   \"" .
                               $slice->{name} . "  , " . $slice->{comment} . "\"" .
                               " \"" . (' ' x $digits) . "\"\n");
                }
            }
        }
        $fh->write("tree.end\n\n");
    }
}

#####################################################################
# Report Lauterbach peripheral files
#####################################################################

sub mix_rep_per($;$)
{
    my ($o_space, $vcty) = @_;   # Reference to the register object

    my $maxwidth = 0;   # max length of register or bitslice names
    my $global_base_address = $eh->get("report.lauterbach.base_address");
    if (defined $o_space) {
        my ($blocks, $rTypes) = mix_rep_header_read_top_address_map();
        # re-create $blocks when processing vcty sheets
        $blocks = mix_rep_vcty_read_device_ini($blocks) if $vcty;

        # iterate through all blocks (domains)
        foreach my $o_domain (@{$o_space->domains}) {
            my $domain_name = $o_domain->name();
            if (! exists($blocks->{$domain_name})) {
                $logger->error("__E_REPORT","\tCould not find `$domain_name' from register-master in the top address map!");
                next;
            }
            my $fh = mix_rep_per_open_files($domain_name, $blocks, $global_base_address, 0);
            my $fh_ead = mix_rep_per_open_files($domain_name, $blocks, $global_base_address, 1);
            # collect all information to the registers in a hash with the address as the key
            my %theBlock;
            #$o_domain->display();
            foreach my $o_reg (@{$o_domain->regs()}) {
                my $addr_1   = $o_domain->get_reg_address($o_reg);
                $addr_1 *= 4 if $vcty;
                my $address  = sprintf("0x%08X", $addr_1);
                my $init     = sprintf("0x%08X", $o_reg->get_reg_init());
                my $mode     = $o_reg->get_reg_access_mode();

                while (exists($theBlock{$address})) {
                    $address .= "_1";
                }
                $theBlock{$address}->{regname} = uc($o_reg->name());
                $theBlock{$address}->{regname} = mix_rep_header_check_name(uc($domain_name) . '_' . $theBlock{$address}->{regname}, $rTypes);
                if (length($theBlock{$address}->{regname}) > $maxwidth) {
                    $maxwidth = length($theBlock{$address}->{regname});
                }
                $theBlock{$address}->{mode} = $mode;
                $theBlock{$address}->{init} = $init;
                if ($eh->get('report.per.debug')) {
                    print("~~~~~ Register: " . $o_reg->name() . "     $theBlock{$address}->{regname}\n");
                }
                my $ii = 0;
                my @thefields;
                foreach my $hreff (@{$o_reg->fields}) {
                    my $o_field = $hreff->{'field'};
                    # select type of register
                    $thefields[$ii]{name}    = lc($o_field->name);
                    if (length($thefields[$ii]{name}) > $maxwidth) {
                        $maxwidth = length($thefields[$ii]{name});
                    }
                    $thefields[$ii]{size}    = $o_field->attribs->{'size'};
                    $thefields[$ii]{pos}     = $hreff->{'pos'}; # LSB position
                    $thefields[$ii]{lsb}     = $o_field->attribs->{'lsb'};
                    $thefields[$ii]{view}    = $o_field->attribs->{'view'}; # N: no documentation  Y: bitfield to document
                    # ignore this bitfield
                    # ##LU changed: view now only used to exclude stuff from documentation
                    # next if $thefields[$ii]{view} ne 'Y';
                    $thefields[$ii]{mode}    = $o_field->attribs->{'dir'};
                    $thefields[$ii]{comment} = $o_field->attribs->{'comment'} || "no descr. available";
                    $thefields[$ii]{comment} =~ s/\\.//g;
                    $thefields[$ii]{sync}    = $o_field->attribs->{'sync'};
                    if ($eh->get('report.per.debug')) {
                        print("~~~~~    " . $thefields[$ii]{name} . '(' . $thefields[$ii]{size}
                              . ')' . '/' . $thefields[$ii]{pos}  . "\n");
                    }
                    $ii += 1;
                }
                if ($ii == 0) {
                    # no visible bitfield exists, ignore the whole register
                    delete $theBlock{$address};
                    next;
                }
                # sort the fields (probably reserved?)
                #@thefields = reverse sort {${$a}{pos} <=> ${$b}{pos}} @thefields;
                @thefields = sort {${$a}{pos} <=> ${$b}{pos}} @thefields;

                $theBlock{$address}->{fields} = \@thefields;
            }
            # All register were read in, write the header file
            mix_rep_per_print($fh, $domain_name, \%theBlock, $rTypes, $blocks, $maxwidth, $global_base_address, 0);
            mix_rep_per_print($fh_ead, $domain_name, \%theBlock, $rTypes, $blocks, $maxwidth, $global_base_address, 1);
            # close the header file
            $fh->close();
        }
    }
    return 0;
}

##############################################################################
##############################################################################

#####################################################################
# Open the perl file for one register
# Write global address(es) into the file
# Return:
#          $fh       FileHandle
#####################################################################

sub mix_rep_perl_open_files($) {
    my ($o_space) = @_;

    # create include dir if not already there
    if (! -d $eh->get('output.path_include')) {
        if ($eh->get('output.mkdir') =~ m/auto|all|yes/i) {
            mkdir($eh->get('output.path_include'))
        } else {
            _error("directory \'",$eh->get('output.path_include'),"\' does not exist and I am not allowed to create it (mkdir parameter)");
        };
    };

    my $newname = $o_space->device;
    my $filename = $eh->get("output.path_include") . "/reg_". lc($newname) . ".pm";
    
    my $fh = new FileHandle $filename, "w";

    if (! defined($fh)) {
        $logger->error("__E_REPORT_FILE","\tCould not open file `$filename'!");
    } else {
        
        # Write base address
        
        $fh->print(<<PMHEADER);
# Register-Space dump for device $newname generated by MIX module MixReport.pm 
# package Micronas::Reg;

require Exporter;
use Micronas::Reg;
use Micronas::RegDomain;
use Micronas::RegReg;
use Micronas::RegField;
use Micronas::RegAddrMap;
use strict;
use vars qw(\@ISA \@EXPORT \$o_space1);
\@ISA = qw(Exporter);
\@EXPORT = qw(\$o_space1);

BEGIN {
PMHEADER

    }
    return $fh;
};

#####################################################################
# Print type definitions for the registers of the current domain
#####################################################################

# sub mix_rep_perl_print($$$$$$)
# {
#     my ($fh, $name, $rBlock, $rTypes, $blocks, $maxwidth) = @_;
#     my $newname = uc($eh->get("report.cheader.definition." . lc($name)));
# 
#     # write EXPORT definition
#     $fh->write('our @EXPORT = qw(' . "\n");
#     foreach my $addr (sort keys %{$rBlock}) {
#         if ( $eh->get( 'report.perl.debug' ) ) {
#             print("!!!!! processing domain: '$newname' ... register: '$rBlock->{$addr}->{regname}'\n");
#         }
#         # export reference to the register hash
#         for (my $i = 0; $i < $blocks->{$name}->{reg_clones}; $i++) {
#             my $newreg;
#             if ($blocks->{$name}->{reg_clones} > 1) {
#                 # remove '<domain>_' from name (GPIO2_GPIO_otto --> GPIO2_otto)
#                 $newreg = uc($blocks->{$name}->{clients}->[$i]) . '_' . uc($rBlock->{$addr}->{regname});
#                 $newreg =~ s/^((.+)\d+)_\2/$1/;
#                 #print("~~~~~ old name:     " . uc($blocks->{$name}->{clients}->[$i]) . '_' . uc($rBlock->{$addr}->{regname}) . "\n");
#                 #print("~~~~~ new reg name: $newreg\n");
#             } else {
#                 $newreg = uc($rBlock->{$addr}->{regname});
#             }
#             $fh->print("    \$" . $newreg . "\n");
#         }
#     }
#     $fh->write(");\n\n");
# 
#     # write hash for each register
#     foreach my $addr (sort keys %{$rBlock}) {
#         for (my $i = 0; $i < $blocks->{$name}->{reg_clones}; $i++) {
#             my $newreg;
#             if ($blocks->{$name}->{reg_clones} > 1) {
#                 # remove '<domain>_' from name (GPIO2_GPIO_otto --> GPIO2_otto)
#                 $newreg = uc($blocks->{$name}->{clients}->[$i]) . '_' . uc($rBlock->{$addr}->{regname});
#                 $newreg =~ s/^((.+)\d+)_\2/$1/;
#             } else {
#                 $newreg = uc($rBlock->{$addr}->{regname});
#             }
#             $fh->write("our \%$newreg = (\n");
#             $fh->printf("    _address => \"0x%08X\",\n", ($blocks->{$name}->{base_addr}->[$i] + hex((split(/_/, $addr))[0])));
#             $fh->printf("    _width   => %d,\n", $rBlock->{$addr}->{width});
#             #### write bitfields (there are more than one)
#             for (my $i = 0; $i <= $#{$rBlock->{$addr}->{fields}}; $i++) {
#                 my $slice = $rBlock->{$addr}->{fields}->[$i];
#                 $fh->printf("    $slice->{name}    %s => \"0x%X\",\n", (' ' x ($maxwidth - 3 - length($slice->{name}))), $slice->{init});
#                 $fh->write("    $slice->{name}_reg" . (' ' x ($maxwidth - 3 - length($slice->{name}))) . " => [" . ($slice->{pos} + $slice->{size} - 1) .
#                            "," . $slice->{pos} . "],\n");
#             }
#             $fh->write(");\n\n");
#         }
#     }
# 
#     # write definition of the reference to the hash for each register
#     foreach my $addr (sort keys %{$rBlock}) {
#         for (my $i = 0; $i < $blocks->{$name}->{reg_clones}; $i++) {
#             my $newreg;
#             if ($blocks->{$name}->{reg_clones} > 1) {
#                 # remove '<domain>_' from name (GPIO2_GPIO_otto --> GPIO2_otto)
#                 $newreg = uc($blocks->{$name}->{clients}->[$i]) . '_' . uc($rBlock->{$addr}->{regname});
#                 $newreg =~ s/^((.+)\d+)_\2/$1/;
#             } else {
#                 $newreg = uc($rBlock->{$addr}->{regname});
#             }
#             $fh->write("our \$$newreg" . ' ' x ($maxwidth - length($newreg)) . " = \\\%$newreg;\n");
#         }
#     }
# 
#     # write end of the file
#     $fh->printf("\n1;\n");
# }

#####################################################################
# Report Registermaster definition as Perlpackage
#####################################################################

sub mix_rep_perl($) {
    my ($o_space) = @_;   # Reference to the register object
    
    my $fh = mix_rep_perl_open_files($o_space);
    
    if (defined $o_space and defined $fh) {
        # create a stripped-down register object, using default address-map or map from mix.cfg file
        my $o_addrmap = $o_space->get_addrmap_by_name($o_space->try_addrmap_name($eh->get("report.addrmap")));
        my $o_new_addrmap = Micronas::RegAddrMap->new('name' => $o_addrmap->{name});
        my $o_new_space = Micronas::Reg->new(
                                             device => $o_space->device, 
                                             default_addrmap => $o_space->{default_addrmap},
                                             addrmaps => [$o_new_addrmap]
                                            );
        delete ($o_new_space->{'global'}); # do not need global member

        # iterate through all blocks (domains)
        foreach my $o_domain (@{$o_space->domains}) {
            # create a new domain
            my $domain_name = _clone_name($eh->get("report.domain_naming"), 99, $o_domain->id, $o_domain->name());
            my $o_new_domain = Micronas::RegDomain->new('name' => $domain_name);
            my $base_address = $o_space->get_domain_baseaddr($o_domain->name, $o_addrmap->{name});
           
            if (! defined($base_address)) {
                $logger->error("__E_REPORT","\tCould not find `$domain_name' in the top address map!");
                next;
            }
            
            # link new domain into register space
            $o_new_space->add_domain($o_new_domain, $base_address, $o_addrmap->{name});
            
            foreach my $o_reg (@{$o_domain->regs}) {
                my $block_name = $o_reg->fields->[0]->{"field"}->attribs->{"block"}; # take block from first field
                my $reg_name = _clone_name($eh->get("report.reg_naming"), 99, $o_reg->id, $o_domain->name, $o_reg->name, "", $block_name);
                my $reg_offset = $o_domain->get_reg_address($o_reg);
                my %hrattribs;
                # copy some selected attributes
                foreach my $key (keys %{$o_reg->attribs}) {
                    if (grep ($key eq $_, (PERL_REG_ATTRIBS))) {
                        $hrattribs{$key} = $o_reg->attribs->{$key};
                    };
                };
                
                # create new register object
                my $o_new_reg = Micronas::RegReg->new('name' => $reg_name, 'attribs' => \%hrattribs);
                
                # link new register object into domain (will use default domain-address-map)
                $o_new_domain->add_reg($o_new_reg, $reg_offset);

                # iterate through all fields of the register
                foreach my $href (@{$o_reg->fields}) {
                    my $o_field = $href->{'field'}; # reference to field object in register
                    my $field_name = _clone_name($eh->get("report.field_naming"), 99, $o_field->id, $o_domain->name, $o_reg->name, $o_field->name, $o_field->attribs->{'block'});                    
                    my $fpos = $href->{'pos'};       # lsb position of field in register
                    
                    my %hfattribs;
                    # copy some selected attributes
                    foreach my $key (keys %{$o_field->attribs}) {
                        if (grep ($key eq $_, PERL_FIELD_ATTRIBS)) {
                            $hfattribs{$key} = $o_field->attribs->{$key};
                        };
                    };

                    # create new field object (also links to register where contained)
                    my $o_new_field = Micronas::RegField->new(name => $field_name, reg => $o_new_reg, attribs => \%hfattribs);
                    
                    # link into register
                    $o_new_reg->fields(field => $o_new_field, pos => $fpos);
                };  
            };
        }

        # dump all; use Purity=1 to resolve nested references in object
        my $dump  = Data::Dumper->new([$o_new_space]);
        $dump->Maxdepth(0);
        $dump->Varname("o_space");
        $dump->Indent(1)->Purity(1)->Sortkeys(1);
        print $fh $dump->Dump;
        # add an eval statement to fill the variable (necessary ?)
        # print $fh "eval(\$o_space1);\n";
        print $fh "};\n1;\n";
        # close the perl file
        $fh->close();
    }
    return 0;
}

##############################################################################
##############################################################################

######################################################################
# mix_rep_reglist
#       Report register list as mif file
#####################################################################

sub mix_rep_reglist($)
{
    my ($o_space) = shift @_;   # Reference to the register object

    if (defined $o_space) {
        # iterate through all blocks (domains)
        foreach my $o_domain (@{$o_space->domains}) {
            #$o_domain->display();

            ### open mif file
            # print("~~~~~ Domain name: " . $o_domain->name() . "\n");
            my $mif = new Micronas::MixUtils::Mif('name' => $eh->get( 'report.path' ) . '/' .
                                                  $o_domain->name() . "_reglist.mif");
            $mif->template();   # Initialize it
            my $omif = new Micronas::MixUtils::Mif('name' => $eh->get( 'report.path' ) . '/' .
                                                   $o_domain->name() . "_reg_overview.mif");
            $omif->template();  # Initialize it
            my $oview_table = mix_rep_reglist_oview_mif_header($omif);

            ### loop over all registers
            my @reg_crossrefs;  # cross references will appear in overview table
            foreach my $o_reg (@{$o_domain->regs()}) {
                if ($o_reg->to_document()) { # should this register be documented
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
                        $thefields[$ii]{pos}     = $hreff->{'pos'}; # LSB position
                        $thefields[$ii]{lsb}     = $o_field->attribs->{'lsb'};
                        $thefields[$ii]{view}    = $o_field->attribs->{'view'}; # N: no documentation
                        # ignore this bitfield if it shouldn't be documented
                        next if $thefields[$ii]{view} ne 'Y';
                        $thefields[$ii]{mode}    = $o_field->attribs->{'dir'};
                        $thefields[$ii]{comment} = $o_field->attribs->{'comment'};
                        $thefields[$ii]{spec}    = $o_field->attribs->{'spec'}; # WC, W1C or W0C (reset the interrupt)
                        if ($thefields[$ii]->{spec} ne 'W1C' and $thefields[$ii]->{spec} ne 'W0C' and
                            $thefields[$ii]->{spec} ne 'WC') {
                            delete($thefields[$ii]->{spec});
                        }
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
    my ($mif, $title) = @_;
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
                                'String'     => 'Init',
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
        if ($fi > $#{$fields}) {         # No bitslices defined in lower 16 bits of the register
            $tend = 16;
            last;
        }
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
    my $fncnt = 0;
    # footnote hash
    # key: 'W1C', 'W0C', or 'WC'
    # value: ref to a hash
    #        key: 'fnnr'    value: footnote number
    #        key: 'fnstr'   value: footnote string
    my %fnh;

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
        if (exists($fields->[$fi]->{spec})) {
            my ($fnstr, $fnnr);
            if (exists($fnh{$fields->[$fi]->{spec}})) {
                $fnnr = $fnh{$fields->[$fi]->{spec}}->{fnnr};
            } else {
                $fnnr = ++$fncnt;
                $fnh{$fields->[$fi]->{spec}}->{fnnr} = $fnnr;
                if ($fields->[$fi]->{spec} eq 'W1C') {
                    $fnh{$fields->[$fi]->{spec}}->{fnstr} =
                        ") Note: A write access to this bit will clear the dedicated interrupt status if the corresponding bit is set to 1. If it is set to 0 the dedicated interrupt status remains active.";
                } elsif ($fields->[$fi]->{spec} eq 'W0C') {
                    $fnh{$fields->[$fi]->{spec}}->{fnstr} =
                        ") Note: A write access to this bit will clear the dedicated interrupt status if the corresponding bit is set to 0. If it is set to 1 the dedicated interrupt status remains active.";
                } elsif ($fields->[$fi]->{spec} eq 'WC') {
                    $fnh{$fields->[$fi]->{spec}}->{fnstr} = 
                        ") Note: A write access to this bit will clear the dedicated interrupt status if the corresponding bit is set to 0 or 1.";
                }
            }
            $text .= $mif->wrCell({'PgfTag'      => 'CellBodyH8',
                                   'String'      => $fields->[$fi]->{mode},
                                   'Footnotenr'  => $fnnr,
#                                  'Footnotestr' => $fnstr,
                                   'Columns'     => 2
                                  },
                                  2);
        } else {
            $text .= $mif->wrCell({'PgfTag'  => 'CellBodyH8',
                                   'String'  => $fields->[$fi]->{mode},
                                   'Columns' => 2
                                  },
                                  2);
        }
        $text .= $mif->wrCell({'PgfTag'  => 'CellHeading' }, 2);
        $text .= $mif->wrCell({'PgfTag'  => 'CellBodyH8',
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
    # write footnote at the end of (but inside) the table
    foreach my $wc (keys %fnh) {
        #print("fnnr: $fnh{$wc}->{fnnr}    string: $fnh{$wc}->{fnstr}\n");
        my $text = $mif->wrCell({'PgfTag'   => 'CellBodyH8',
                                 'String'   => $fnh{$wc}->{fnnr} . $fnh{$wc}->{fnstr},
                                 'Columns'  => 17
                                },
                                2);
        for (my $i = 0; $i < 16; $i++) {
            $text .= $mif->wrCell({ 'PgfTag' => 'CellHeading' }, 2);
        }
        my %hh = ('Text' => $text, 'Indent' => 1);
        $hh{WithPrev} = 'Yes';
        $mif->add($mif->Tr(\%hh), $regtable);
    }
}

##############################################################################
##############################################################################

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
	my $key = $eh->get( 'report.portlist.sort' );
	my $conndb = \%Micronas::MixParser::conndb;
	
	my %spo = ();
	# Iterate over signals
	for my $s ( keys( %$splist ) ) {
		# Iterate over ports
		for my $p ( keys( %{$splist->{$s}} ) ) {
			my ( $n, $d ) = split( /\s+/, $splist->{$s}->{$p} );
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
				# Keep port order in signals:
				# TODO : Check is port input order goes before signal input order
				if ( $pos ) {
					my $mp = $eh->get('sum.port');
					$format = '%0' . ( length( $mp ) + 1 ) . 'd';
					if ( exists( $conndb->{$s}{'::' . $d}[$n]{'_nr_'} ) ) {
						$va = sprintf( $format, $conndb->{$s}{'::' . $d }[$n]{'_nr_'} );
					}
				}
				# Add port number
			} # elsif ( $key =~ m/(\b::\w+)\b/io ) { }
			$spo{$va . '!###!' . $s . '!###!' . $p . '!###!' . $n . '!###!' . $d } = 1;
		}
	}

	# Do the sort here:
	# $va cmp $vb;
	# Array has:
	#	$signal / $port / $sigportnr / $dir (in|out)
	my @sorted = ();
	for my $i ( sort( keys %spo ) ) {
		push( @sorted, [ (split( /!###!/, $i ))[1..4] ] ); #!wig20070122: adding number of in/out field
	}
	return @sorted;
} # End of _mix_report_sigsort

#
# combine ::conn data structure into one hash
#!wig20070122: keep in/out, too.
#!wig20070122: remember max. number of ports
sub _mix_report_conn2sp ($) {
	my $conn = shift;

	my %sp = ();
	for my $m ( qw( in out ) ) {
		for my $s ( keys( %{$conn->{$m}} ) ) {
			my $pr = $conn->{$m}->{$s};
			for my $p ( keys %$pr ) {
				$sp{$s}{$p} = $pr->{$p} . " $m" ;
			}
		}
	}
	return \%sp;
} # End of _mix_report_conn2sp


#
# Print a list of all I/O signals ....
#   or ports (see report.portlist config parameters)
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
		my $incom_last = ''; # Remeber last printed comment, do not redo!

		for my $sigport ( _mix_report_sigsort( $sigandport ) ) {
			# Iterate over all signals ... (and ports)
			my $signal     = $sigport->[0];
			my $port       = $sigport->[1];
			my $sigportnr  = $sigport->[2];
			my $sigportdir = $sigport->[3];

			my $signalname = $conndb->{$signal}{'::name'};
			# my $connect = $link->{'::sigbits'}{$signal};
			my $connect = $link->{'::sigbits'}{$signal}; # new20060406

			# use port bounds if 
			my $high	= '';
			my $low		= '';
			my $clock	= '';
			my $descr	= '';
			my $sd		= '';
			if ( $eh->get( 'report.portlist.data' ) =~ m/\bport\b/ ) {
				my $sigportds = undef();
				if ( exists( $conndb->{$signal}{'::' . $sigportdir}[$sigportnr] ) ) {
					$sigportds = $conndb->{$signal}{'::' . $sigportdir}[$sigportnr];
				}
				# Find port description:
				if ( defined( $sigportds ) ) {
					if ( exists( $sigportds->{'_descr_'} ) ) {
						$descr = $sigportds->{'_descr_'}
					} else {
						$descr	= $conndb->{$signal}{'::descr'};
					}
				}
				# Find port width:
				#	if ( is_interger2( $sigportds->{'port_f'}, $sigportds->{'port_t'} ) ) { }
				$high = $sigportds->{'port_f'};
				$low  = $sigportds->{'port_t'};
			} else {
				$high	= $conndb->{$signal}{'::high'};
				$low	= $conndb->{$signal}{'::low'};
				$descr	= $conndb->{$signal}{'::descr'};
			}
			$sd		= $conndb->{$signal}{'::sd'} || '';
			$clock	= $conndb->{$signal}{'::clock'};

			# Check connectivity: in vs. out vs. IO vs ....
			#   Mark if not fully connected with a footnote -> (*)

			#!wig20051103: if ::incom is set, this line has an attached
			#  comment. Print it before (post mode) or after (pre mode)	
			#  Maybe we limit the number of lines ...
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
				# Do not print if the previous header was the same:
				if ( $incom_text eq $incom_last ) {
					$incom_text = '';
				} else {
					# Remember for next round:
					$incom_last = $incom_text;
				}
			}
			
			# Add comment line (mode = post -> print before!)		
			if ( $incom_mode eq 'post' and $incom_text ) {
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
			if ( $incom_mode eq 'pre' and $incom_text ) {
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

} # End of mix_rep_portlist

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
		$logger->warn( '__W_REPORT', "\tCould not map signal " . $signal .
			" to portname for instance " . $link->{'::inst'} );
	} elsif ( scalar( @ports ) > 1 ) {
		# More than one port attached :-(
		$logger->warn( '__W_REPORT', "\tMultiple ports connected to " . $signal .
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
