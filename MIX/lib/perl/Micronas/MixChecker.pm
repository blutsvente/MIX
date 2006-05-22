# -*- perl -*---------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# |
# |   Copyright Micronas GmbH, Inc. 2002. 
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
# | Project:    Micronas - MIX / Checker
# | Modules:    $RCSfile: MixChecker.pm,v $
# | Revision:   $Revision: 1.15 $
# | Author:     $Author: wig $
# | Date:       $Date: 2006/05/22 14:02:21 $
# |
# | Copyright Micronas GmbH, 2003
# | 
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/MixChecker.pm,v 1.15 2006/05/22 14:02:21 wig Exp $                                                         |
# +-----------------------------------------------------------------------+
#
# The functions here provide the checking capabilites for the MIX project.
# Accepts the intermediate (aka. final connection and hierachy description)
# and check if everything against your company design guide lines
# Through plug-ins you can add checks at will
#
# +-----------------------------------------------------------------------+
# |
# | Changes:
# | $Log: MixChecker.pm,v $
# | Revision 1.15  2006/05/22 14:02:21  wig
# | Fix avfb issues with high/low connections
# |
# | Revision 1.14  2006/04/13 13:31:52  wig
# | Changed possition of VERILOG_HOOK_PARA, detect illegal stuff in ::in/out description
# |
# | Revision 1.13  2006/03/17 09:18:31  wig
# | Fixed bad usage of $eh inside m/../ and print "..."
# |
# | Revision 1.12  2006/03/14 08:10:35  wig
# | No changes, got deleted accidently
# |
# | Revision 1.11  2006/01/18 16:59:28  wig
# |  	MixChecker.pm MixParser.pm MixUtils.pm MixWriter.pm : UNIX tested
# |
# | ...[cut]...
# |
# +-----------------------------------------------------------------------+
package  Micronas::MixChecker;

require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(
    mix_check_case
);            # symbols to export by default
@EXPORT_OK = qw(
);

our $VERSION = '0.01'; # TODO: use the RCS info

use strict;

use Log::Log4perl qw(get_logger);
use Tree::DAG_Node; # tree base class

use Micronas::MixUtils qw( $eh mix_store db2array replace_mac);
use Micronas::MixUtils::IO;
use Micronas::MixParser; # TODO : Remove that recursion!
#
# Prototypes
#
sub mix_check_case($$);
sub mix_check_wiring($$);
sub mix_check_initkeyword ();
sub _mix_check_case_int ($$$$);
sub _wrap_lc ($);
sub _wrap_uc ($);
sub _wrap_lcfirst ($);
sub _wrap_ucfirst ($);
sub _wrap_lcfirstuc ($);
sub _wrap_ucfirstlc ($);

# Internal variable
my %mix_check_list = ();

#
# RCS Id, to be put into output templates
#
my $thisid		=	'$Id: MixChecker.pm,v 1.15 2006/05/22 14:02:21 wig Exp $';
my $thisrcsfile	=	'$RCSfile: MixChecker.pm,v $';
my $thisrevision   =      '$Revision: 1.15 $';

$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?

my $logger = get_logger( 'MIX::MixChecker' );

#
# Start checks
#

####################################################################
## mix_check_case
## if configuration says so, make everything lower or upper case!
## Or just inform about possible conflicts.
####################################################################

=head2

mix_check_case () {

Check if cases match. Depending on the value of the configuration value
<I check.name.$type> do the following:

=over 4

=item no

Do nothing. Keep case as is.

=item lc,check

Just check if everything is written in lower case. Report possible conflicts.
Write at INFO level for objects with bad cases, but without conflicts.
Write at WARNING level if a real case conflict is detected.

=item lc,force

Change all objects to lower case. Possible conflicts will get reported.
Conflicts will be resolved by brute force.


=back

You can add a "f" before uc or lc to imply that the first character will be in a
different case (t.b.d).

=cut

sub mix_check_case ($$) {
    my $type = shift;
    my $name = shift;

    unless( defined( $type ) ) {
        $logger->warn( '__W_CHECK_CASE_IN', "\tmix_check_name called without appropriate type definition!" );
        return '';
    }

    unless( defined( $name ) ) {
        $logger->warn( '__W_CHECK_CASE_ARG', "\tmix_check_name called without appropriate name definition!" );
        return $name;
    }

    # mix internals ....
    # TODO : these have to be all uppercase!!
    if ( $name =~ m,^\s*(__|%)(.*)(__|%)$,o ) {
        if ( uc( $1 ) ne $1 ) {
            $logger->info( '__I_CHECK_CASE_MAC', "\tmix_check_name internal macro $1 not all upper case!" );
        }
        return $name;
    }

    #!wig20031008: adding macro replacement ...
    if ( $name =~ m,%, ) { # Has a %, maybe can be macro parsed ...
        $name = replace_mac( $name, $eh->get( 'macro' ) )
    }
        
    if ( $type eq 'inst' and $name =~ m,^\s*W_NO_(PARENT|ENTITY|CONF),o ) {
        return $name;
    }
    
	# Load check mode and settings:
    my $check = $eh->get( 'check.name.' . $type );
	# and exception regular expression
	my $xcheck = $eh->get( 'check.namex.' . $type ) . ',' .
					$eh->get( 'check.namex.all' );
	$xcheck =~ s/[,\s]+$//;
	$xcheck =~ s/^[,\s]+//;

	# return if check is disabled
	#  or $name matches the exception list
	if ( $check =~ m/^\s*$/ or
		 $check =~ m/\bdisable/ or
		 $check =~ m/\bna\b/ ) {
		return $name;
	}

	#
	# except certain names ...
	#!wig20060117
	if ( $xcheck ) {
		$xcheck = '^(' . join( '|', split( /[,\s+]/, $xcheck ) ) . ')$';
		return $name if ( $name =~ m/$xcheck/ );
	}

	my $func;

	if ( $check =~ m/\blc\b/ ) {
		$func = \&_wrap_lc;
	} elsif ( $check =~ m/\buc\b/ ) {
		$func = \&_wrap_uc;
	} elsif ( $check =~ m/\blcfirst\b/ ) {
		$func = \&_wrap_lcfirst;
	} elsif ( $check =~ m/\bucfirst\b/ ) {
		$func = \&_wrap_ucfirst;
	} elsif ( $check =~ m/\blcfirstuc\b/ ) {
		$func = \&_wrap_lcfirstuc;
	} elsif ( $check =~ m/\bucfirstlc\b/ ) {
		$func = \&_wrap_ucfirstlc;
	} 

	# TESTBENCH always in capital letters, but allow any spelling
	if ( $name eq 'TESTBENCH' ) {
		$func = \&_wrap_ic;
	}
	# Check and change ...
	$name = _mix_check_case_int( $type, $name, $check, $func );

}

#
# Required wrappers for lc/uc/lcfirst/ucfirst ...
#
sub _wrap_lc ($) {
	return lc( $_[0] );
}
sub _wrap_uc ($) {
	return uc( $_[0] );
}
sub _wrap_lcfirst ($) {
	return lcfirst( $_[0] );
}
sub _wrap_ucfirst ($) {
	return ucfirst( $_[0] );
}
sub _wrap_ucfirstlc ($) {
	return ucfirst( lc( $_[0]) );
}
sub _wrap_lcfirstuc ($) {
	return lcfirst( uc( $_[0]) );
}
sub _wrap_ic ($) {
	return( $_[0] );
}

#
# Do the real check with one of the functions uc, lc, ucfirst, lcfirst!
# Default: lc!
#
# Input:
# Global:
# Output: return expanded name
#
sub _mix_check_case_int ($$$$) {
	my $type = shift;
	my $name = shift;
	my $check = shift;
	my $func = shift;

    #
    # TODO : save all variants of spelling in mix_check_list?
    #
    
    my $list = $mix_check_list{$type}; # Reference to this type's list of names
    unless( exists( $mix_check_list{$type} ) ) {
       $mix_check_list{$type} = {};
    }

	# $list keeps version of all names, indexed by lc version
	if ( exists( $list->{lc($name)} ) ) {
		if ( $list->{lc($name)} ne $name ) { # Potential problem found ...
			if ( $check =~ m,\bcheck,o ) {
				$logger->warn( '__W_CHECK_CASE_N', "\tGot new element '$name' conflicting with '" .
					$list->{lc($name)} . "'!" );
					$eh->inc( 'sum.checkwarn' );
			} elsif( $check =~ m,\bforce,o ) {
				$logger->warn( '__W_CHECK_CASE_F', "\tForcing new element '$name' to correct case '" . &$func($name) . "'!" );
				$name = &$func( $name );
				$eh->inc( 'sum.checkforce' );
			}
		}
		# else "have seen the same before, no issue"
	} else {
		# Something new:
		if( $name ne &$func( $name ) ) { 
			if ( $check =~ m,\bforce,o ) {
				$logger->info( '__I_CHECK_CASE_F', "\tForcing new $type element '$name' to correct case '" . &$func($name) . "'!" );
				$eh->inc( 'sum.checkforce' );
				$name = &$func( $name );
			} elsif ( $check =~ m,\bcheck,o ) {
				$logger->info( '__I_CHECK_CASE', "\tNot all chars in correct case in new $type element '$name'!" );
			}
		}
		$list->{ lc( $name ) } = $name;
	}
	# Return name, might have been forced to different spelling ..
    return($name);
}

####################################################################
## mix_check_wiring
## Micronas specific: see if _n signals are connected to ports not _n!
####################################################################

=head2

mix_check_wiring () {

Check is signals ending with _n are connected to non-_n ports!
If so, print a warning. This is controlled by a global configuration value.
More wiring sanity checks can be added.

=over 4

=item t.b.d.

Needs more options.


=back

Start this checker very late (after names have been resolved).
It might run into problems if there are still macros in the descriptions.

=cut

sub mix_check_wiring ($$) {

    my $conn_r = shift;

    for my $s ( keys( %$conn_r ) ) {
        # signal internal name -> $s
        # signal "real" name -> $conn_r->{$s}{'::name'}

        # 1. if signal is low active ( _n ) -> check all connected ports!
        if ( $s =~ m/_n$/io ) {
            check_n_ports( $s, $conn_r->{$s} );
        }
    }
} # End of mix_check_wiring

sub check_n_ports ($$) {
    my $s = shift;
    my $s_r = shift;

    my $name = $s_r->{'::name'};
    if ( $name !~ m/_n$/io ) {
        $logger->warn( '__W_CHECK_NPORT1', "\tsignal internal name $s level mismatch real name $name" );
        $eh->inc( 'sum.checkconn' );
    }

    for my $p ( @{$s_r->{'::in'}}, @{$s_r->{'::out'}} ) {
        my $port = $p->{'port'};
        if ( $port !~ m/_n$/io ) {
            $logger->warn( '__W_CHECK_NPORT2', "\tsignal $s connection mismatch for port $port, instance ".
                   $p->{'inst'} );
            $eh->inc( 'sum.checkconn' );
        }
    }
} # End of check_n_ports

#
# Create a list of keywords in various languages:
#
# VHDL: from http://www.seas.upenn.edu/~ee201/vhdl/keywordlist.html
# Verilog: 
sub mix_check_initkeyword () {
	
# VHDL:
# the keywords are not case-sensitive!
my @keys = qw (
	abs access after alias all and architecture array assert attribute
	begin block body buffer bus
	case component configuration constant
	disconnect downto
	else elsif end entity exit
	file for function
	generate generic group guarded
	if impure in inertial inout is
	label library linkage literal loop
	map mod
	nand new next nor not null
	of on open or others out
	package port postponed procedure process pure
	range record register reject return rol ror
	select severity signal shared sla sli sra srl subtype
	then to transport type
	unaffected units until use
	variable
	wait when while with
	xnor xor
);

=head 2 list from other place http://opensource.ethz.ch/emacs/vhdl87_syntax.html#keywords

Reserved Words

      abs, access, after, alias, all, and, architecture, array, assert, attribute,
      begin, block, body, buffer, bus,
      case, component, configuration, constant,
      disconnect, downto,
      else, elsif, end, entity, exit,
      file, for, function,
      generate, generic, guarded,
      if, in, inout, is,
      label, library, linkage, loop,
      map, mod,
      nand, new, next, nor, not, null,
      of, on, open, or, others, out,
      package, port, procedure, process,
      range, record, register, rem, report, return,
      select, severity, signal, subtype,
      then, to, transport, type,
      units, until, use,
      variable,
      wait, when, while, with,
      xor 

=cut

=head 2 the same for Verilog now from http://toolbox.xilinx.com/docsan/xilinx4/data/docs/xst/verilog10.html

always
and
assign
begin
buf
bufif0
bufif1
case
casex
casez
cmos
deassign
default
defparam
disable
edge
else
end
endcase
endfunction
endmodule
endprimitive
endspecify
endtable
endtask
event
for
for
force
forever
function
highz0
highz1
if
ifnone
initial
inout
input
integer
join
large
macromodule
medium
module
nand
negedge
nmos
nor
not
notif0
notif1
or
output
parameter
pmos
posedge
primitive
pull0
pull1
pulldown
pullup
rcmos
real
realtime
reg
release
repeat
rnmos
rpmos
rtran
rtranif0
rtranif1
scalared
small
specify
specparam
strong0
strong1
supply0
supply1
table
task
time
tran
tranif0
tranif1
tri
tri0
tri1
triand
trior
trireg
vectored
wait
wand
weak0
weak1
while
wire
wor
xnor
xor

=cut

} # End of mix_check_initkeywords

1;

#!End
