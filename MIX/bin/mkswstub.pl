#!/bin/sh --
#!/bin/sh -- # -*- perl -*- -w
eval 'exec ${PERL:-`[ ! -d "$HOME/bin/perl" -a -x "$HOME/bin/perl" ] && echo "$HOME/bin/perl" || { [ -x /usr/bin/perl ] && echo /usr/bin/perl || echo /usr/local/bin/perl ; } `} -x -S $0 ${1+"$@"} ;'
if 0; # dynamic perl startup; suppress preceding line in perl
#line 6

#-----------------------------------------------------------------------------
#-- Name     : mkswstub
#-- $Revision: 1.1 $
#-- $Date    : 2006/03/09 13:52:02 $
#-- $Author  : mathias $
#-----------------------------------------------------------------------------

use strict;
use Cwd;
use FileHandle;
use File::Basename qw(basename dirname);
use File::Path     qw(mkpath);

use lib "/tools/veriplan/1.1/lib/perl";
use Mway::MBase    qw(%OPTVAL mmsg musage mgetopt);
use vars qw($out
            $string
            $reset
            $returncode
           );

$returncode = 1;
$out        = "reg_swstub.c";
$reset      = "reg_reset.c";
$string     = "reg_string.c";

##############################################################################
# Possible targets and other constant declarations
##############################################################################


##############################################################################
# Prototypes
##############################################################################

sub printHeader($);
sub printHeaderrs($$$);
sub readFiles($$$);
sub parseOptions();

##############################################################################
# Parse the commandline
##############################################################################
my $files = parseOptions();

my $fh = new FileHandle $out, 'w';
if (! defined($fh)) {
    mmsg($Mway::MBase::FATAL, "Couldn't open $out for writing!");
}
my $fhr = new FileHandle $reset, 'w';
if (! defined($fh)) {
    mmsg($Mway::MBase::FATAL, "Couldn't open $reset for writing!");
}
my $fhs = new FileHandle $string, 'w';
if (! defined($fh)) {
    mmsg($Mway::MBase::FATAL, "Couldn't open $string for writing!");
}

printHeader($fh);
printHeaderrs($fhr, $reset, "reset values");
printHeaderrs($fhs, $string, "names");
my $refDomain = readFiles($fh, $fhr, $fhs);

$fh->print("\n\n");

############################################## write 'static' declarations
foreach my $file (sort keys %{$refDomain}) {
    my $refNames = $refDomain->{$file}->{names};
    foreach my $inst (@{$refDomain->{$file}->{instances}}) {
        foreach my $name (sort keys %{$refNames}) {
            $fh->print("static uint32_t " . lc($inst) . '_' . lc($name) . ";\n");
        }
    }
}

$fh->print("\n\n");

############################################## write 'reset' function
$fhr->print("#include \"reg_utils.h\"");
$fhr->print("\n\n");
$fhr->print("uint32_t REG_GetResetValue_Generic (uint32_t regAddr)\n");
$fhr->print("{\n");
$fhr->print("   switch (regAddr)\n");
$fhr->print("   {\n");
foreach my $file (sort keys %{$refDomain}) {
    my $refNames = $refDomain->{$file}->{names};
    foreach my $inst (@{$refDomain->{$file}->{instances}}) {
        foreach my $name (sort keys %{$refNames}) {
            $fhr->print(' ' x 6 . "case " . uc($inst) . '+' .  uc($name) . '_OFFS' .
                        ' ' x (45 - length($name) - length($inst)) .
                        " : return " . $refNames->{$name} . ";\n");
        }
        # write 'case' lines for each instance when the INSTANCE_SIZE is missing in $file
        #last if (exists($refDomain->{$file}->{instance_size}));
    }
}
$fhr->print("      default:  return 0xdeadbeef;\n");
$fhr->print("   }\n");
$fhr->print("}\n\n\n");

############################################## write 'set reset values' function
$fhr->print("\n\n");
$fhr->print("void REG_SetAllResetValues (void)\n");
$fhr->print("{\n");
foreach my $file (sort keys %{$refDomain}) {
    my $refNames = $refDomain->{$file}->{names};
    foreach my $inst (@{$refDomain->{$file}->{instances}}) {
        foreach my $name (sort keys %{$refNames}) {
            $fhr->print(' ' x 6 . "REG_Write( " . uc($inst) . '+' .  uc($name) . '_OFFS,' .
                        ' ' x (45 - length($name) - length($inst)) .
                        $refNames->{$name} . ");\n");
        }
        # write 'REG_SetAllResetValues' lines for each instance when the INSTANCE_SIZE is missing in $file
        last if (exists($refDomain->{$file}->{instance_size}));
    }
}
$fhr->print("}\n\n\n");

############################################## write 'getRegname' function
$fhs->print("#include \"reg_utils.h\"");
$fhs->print("\n");
$fhs->print("#include \<string.h\>");
$fhs->print("\n\n");
$fhs->print("const char * REG_GetRegName_Generic (uint32_t regAddr)\n");
$fhs->print("{\n");
$fhs->print("   switch (regAddr)\n");
$fhs->print("   {\n");
foreach my $file (sort keys %{$refDomain}) {
    my $refNames = $refDomain->{$file}->{names};
    foreach my $inst (@{$refDomain->{$file}->{instances}}) {
        foreach my $name (sort keys %{$refNames}) {
            $fhs->print(' ' x 6 . "case " . uc($inst) . '+' .  uc($name) . '_OFFS' .
                        ' ' x (45 - length($name) - length($inst)) .
                        " : return \"" . uc($name) . "\";\n");
        }
        # write 'case' lines for each instance when the INSTANCE_SIZE is missing in $file
        #last if (exists($refDomain->{$file}->{instance_size}));
    }
}
$fhs->print("      default:  return \"unknown register\";\n");
$fhs->print("   }\n");
$fhs->print("}\n\n\n");

### structure and function to get the address offset for given register name
$fhs->print("typedef struct _regStr2Addr_t {\n");
$fhs->print("   char*    regName;\n");
$fhs->print("   uint32_t regAddr;\n");
$fhs->print("} regStr2Addr_t;\n\n");
$fhs->print("#define END_OF_REG_STRING_LIST  0xffffffff\n\n");

$fhs->print("regStr2Addr_t regString2Address[] =\n");
$fhs->print("{\n");
foreach my $file (sort keys %{$refDomain}) {
    my $refNames = $refDomain->{$file}->{names};
    foreach my $name (sort keys %{$refNames}) {
        $fhs->print(' ' x 8 . "{\"" . uc($name) . "\"," . ' ' x (45 - length($name)) .
                    uc($name) . "_OFFS},\n");
    }
}
$fhs->print(' ' x 8 . "{\"END_OF_REG_STRING_LIST\"," . ' ' x 23 . "END_OF_REG_STRING_LIST}\n");
$fhs->print("};\n\n");

$fhs->print("uint32_t REG_GetRegAddr_Generic (const int8_t * regString)\n");
$fhs->print("{\n");
$fhs->print("  uint32_t regAddr = 0;\n");
$fhs->print("  uint32_t cnt = 0;\n");
$fhs->print("\n");
$fhs->print("  while(regAddr != END_OF_REG_STRING_LIST)\n");
$fhs->print("  {\n");
$fhs->print("  	if ( strcasecmp(regString2Address[cnt].regName, regString) == 0)\n");
$fhs->print("  	{\n");
$fhs->print("  		/* register name found */\n");
$fhs->print("  		regAddr = regString2Address[cnt].regAddr;\n");
$fhs->print("  		break;\n");
$fhs->print("    }\n");
$fhs->print("\n");
$fhs->print("        /* check end of list */\n");
$fhs->print("        if (regString2Address[cnt].regAddr == END_OF_REG_STRING_LIST) { regAddr = END_OF_REG_STRING_LIST;}\n");
$fhs->print("        cnt++;\n");
$fhs->print("   //MIC_INFO(string,\"0x%08x\\n\",regAddr);\n");
$fhs->print("  }\n");
$fhs->print("  return regAddr;\n");
$fhs->print("}\n");

############################################## write 'REGwrite' function
$fh->print("void REG_WriteStub (uint32_t regAddr, uint32_t val)\n");
$fh->print("{\n");
$fh->print("   switch (regAddr)\n");
$fh->print("   {\n");
foreach my $file (sort keys %{$refDomain}) {
    my $refNames = $refDomain->{$file}->{names};
    foreach my $inst (@{$refDomain->{$file}->{instances}}) {
        foreach my $name (sort keys %{$refNames}) {
            $fh->print("      case " . uc($inst) . '+' . uc($name) . '_OFFS');
            $fh->print(' ' x (40 - length($name) - length($inst)));
            $fh->print(': { ' . lc($inst) . '_' . lc($name) . ' ' x (45 - length($name) - length($inst)));
            $fh->print('= val;  return; }' . "\n");
        }
    }
}
$fh->print("      default:  return;\n");
$fh->print("   }\n");
$fh->print("}\n\n\n");

############################################## write 'REGread' function
$fh->print("uint32_t REG_ReadStub (uint32_t regAddr)\n");
$fh->print("{\n");
$fh->print("   switch (regAddr)\n");
$fh->print("   {\n");
foreach my $file (sort keys %{$refDomain}) {
    my $refNames = $refDomain->{$file}->{names};
    foreach my $inst (@{$refDomain->{$file}->{instances}}) {
        foreach my $name (sort keys %{$refNames}) {
            $fh->print("      case " . uc($inst) . '+' . uc($name) . '_OFFS');
            $fh->print(' ' x (40 - length($name) - length($inst)) . ': return ');
            $fh->print(lc($inst) . '_' . lc($name) . ";\n");
        }
    }
}
$fh->print("      default:  return -1;\n");
$fh->print("   }\n");
$fh->print("}\n");

$fh->close();
$fhr->close();
$fhs->close();
# End of the script
mmsg($Mway::MBase::INFO, "$0 ended successfully.");
exit(0);

##############################################################################
# readFiles
#    read in all input files
#    print include line to output file
#    store base address of each instans of the block and
#    the name of each register with its init value in a hash (%domain)
#       $domain{<filename>}->{instances}     ref to an array with base addresses
#       $domain{<filename>}->{names}         ref to hash with (regname, reset val)
##############################################################################
sub readFiles($$$)
{
    my ($fh, $fhr, $fhs) = @_;
    my %domain;

    foreach my $file (@{$files}) {
        my $fhin = new FileHandle $file, 'r';
        mmsg($Mway::MBase::FATAL, "Couldn't open $out for reading!") if !defined($fhin);
        $fh->print("#include \"" . basename($file) . "\"\n");
        $fhr->print("#include \"" . basename($file) . "\"\n");
        $fhs->print("#include \"" . basename($file) . "\"\n");

        # collect base address of each instance
        my ($base_started, $base_finished) = (0, 0);
        while (my $line = $fhin->getline() and ! $base_finished) {
            $base_started = 1 if ($line =~ m:Base\s+address:);
            if (($line =~ m:^\s*$:) and $base_started) {
                $base_finished = 1;
            }
            if ($base_started and ($line =~ m:#define\s+([^\s]+)\s+:)) {
                push(@{$domain{$file}->{instances}}, $1);
            }
        }
        # collect reset values of the registers
        my ($name, $init, $expected);
        while (my $line = $fhin->getline()) {
            $expected = 1 if ($line =~ m:// Register name and init value; read by another scrip:);
            if ($line =~ m:^//\s+Init\s+([^\s]+)\s+([^\s]+):) {
                $name = $1;
                $init = $2;
                if (!$expected) {
                    mmsg($Mway::MBase::ERROR, "Found unexpected name $name in file $file!");
                } else {
                    $domain{$file}->{names}->{$name} = $init;
                    $name = '';
                    $init = 0;
                    $expected = 0;
                }
            } elsif ($line =~ m:^#define\s+[^\s]+_INSTANCE_SIZE\s+\d+:) {
                $domain{$file}->{instance_size} = 1;
            }
        }
    }
    return \%domain;
}

##############################################################################
# printHeader
#    print first lines into output file
##############################################################################
sub printHeader($)
{
    my ($fh) = @_;

    $fh->print( <<EOH);
/******************************************************************************/
/**
 * \@file             reg_swstub.c
 *
 * \@brief            register software stubs for simulation of the hardware register.
 *
 * \@note             Copyright (c) 2006 by Micronas GmbH.
 *                    All rights reserved.
 *
 * This file has been automatically generated by the mix script
 *
 ******************************************************************************/
#include "mic_common.h"
EOH
}

##############################################################################
# printHeaderrs
#    print first lines into output file
##############################################################################
sub printHeaderrs($$$)
{
    my ($fh, $name, $desc) = @_;

    $fh->print( <<EOH);
/******************************************************************************/
/**
 * \@file             $name
 *
 * \@brief            register $desc of the hardware register.
 *
 * \@note             Copyright (c) 2006 by Micronas GmbH.
 *                    All rights reserved.
 *
 * This file has been automatically generated by the mix script
 *
 ******************************************************************************/
#include "mic_common.h"
EOH
}

##############################################################################
# Parse Options
#    Allowed options depends on the chosen target.
#    Available targets: `$targets'
##############################################################################
sub parseOptions()
{
    my %optdef = ("default" => [qw(unit=s
                                   perl_package|pp=s
                                   testname|t=s
                                   working_dir|wd=s)
                               ],
                 );
    mgetopt(@{$optdef{default}});

    #---------------------------------------------------------------------------
    # There can be one value following the keyed arguments, which is the target.
    #---------------------------------------------------------------------------
    my $target;
    if (@ARGV == 0) {
        mmsg($Mway::MBase::ERROR, "Header file names are missing");
        mmsg($Mway::MBase::ERROR, "Please start $0 with the list of the register header files!");
        musage();
        exit(1);
    } else {
        return \@ARGV;
    }
}

__END__

=head1 NAME

mkswstub - Creates three c files with basic functions

=head1 SYNOPSIS

=over 4

=item mkswstub -help

=back

=over 4

=item B<mkswstub> <h file name> [ <h file name> ... ]

=back


=head1 DESCRIPTION

The script B<mkswstub> creates a c file with basic functions.
The necessary information is taken from the given h files.

=head1 FILES

B<mkswstub> creates the following files in the current directory

F<reg_reset.c>

F<reg_swstub.c>

F<reg_string.c>

=head1 EXAMPLES

mkswstub /proot/vgch/0001/workareas/bartholo/reg_003_vcth/*.h

=head1 SEE ALSO

=cut
