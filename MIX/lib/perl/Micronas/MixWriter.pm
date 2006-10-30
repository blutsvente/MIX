# -*- perl -*---------------------------------------------------------------
#
#line 4
# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright Micronas GmbH, Inc. 2002,2005                             |
# |     All Rights Reserved.                                              |
# |                                                                       |
# |                                                                       |
# | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF MICRONAS GMBH          |
# | The copyright notice above does not evidence any actual or intended   |
# | publication of such source code.                                      |
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# | Project:    Micronas - MIX / Writer                                   |
# | Modules:    $RCSfile: MixWriter.pm,v $                                |
# | Revision:   $Revision: 1.97 $                                         |
# | Author:     $Author: wig $                                         |
# | Date:       $Date: 2006/10/30 15:34:59 $                              |
# |                                                                       |
# | Copyright Micronas GmbH, 2003,2005                                        |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/MixWriter.pm,v 1.97 2006/10/30 15:34:59 wig Exp $                                                         |
# +-----------------------------------------------------------------------+
#
# The functions here provide the backend for the MIX project.
# HDL output files will get written according to the data found
# in %hierdb and %conndb
#
# +-----------------------------------------------------------------------+
# |
# | Changes:
# | $Log: MixWriter.pm,v $
# | Revision 1.97  2006/10/30 15:34:59  wig
# | extended handling of `define port/signal definitions
# |
# | Revision 1.96  2006/10/23 08:31:06  wig
# | Fixed problem with ::b ::b:1 output / missing ::b:1
# |
# | Revision 1.95  2006/09/25 15:18:20  wig
# |  	MixWriter.pm : another undefined if check
# |
# | Revision 1.94  2006/09/25 15:15:44  wig
# | Adding `foo support (rfe20060904a)
# |
# | Revision 1.93  2006/09/25 08:24:10  wig
# | Prepared emumux and `define
# |
# | Revision 1.92  2006/07/12 15:23:40  wig
# | Added [no]sel[ect]head switch to xls2csv to support selection based on headers and variants.
# |
# | Revision 1.91  2006/07/04 12:22:35  wig
# | Fixed TOP handling, -cfg FILE issue, ...
# |
# | Revision 1.90  2006/06/22 07:13:21  wig
# | Updated HIGH/LOW parsing, extended report.portlist.comments
# |
# | Revision 1.89  2006/05/23 06:48:05  wig
# | Fixed typo %S
# |
# | Revision 1.88  2006/05/22 14:02:21  wig
# | Fix avfb issues with high/low connections
# |
# | Revision 1.87  2006/05/10 08:26:59  wig
# | __NODRV__ improvements
# |
# | Revision 1.86  2006/05/10 07:15:52  wig
# |  	MixWriter.pm : fix NODRV bad regular expression
# |
# | Revision 1.85  2006/05/09 14:38:51  wig
# |  	MixParser.pm MixUtils.pm MixWriter.pm : improved constant assignments
# |
# | Revision 1.84  2006/05/03 12:03:15  wig
# | Improved top handling, fixed generated format
# |
# | ...[cut]...
# |
# +-----------------------------------------------------------------------+
package  Micronas::MixWriter;

require Exporter;

  @ISA = qw(Exporter);
  @EXPORT = qw(
    generate_entities
    write_entities
    write_architecture
    write_configuration
    );            # symbols to export by default
  @EXPORT_OK = qw();

our $VERSION = '0.01';

use strict;
use vars qw( %entities );

use Log::Log4perl qw(get_logger);
use Tree::DAG_Node; # tree base class
use Regexp::Common; # Needed for reading back spliced ports

use Micronas::MixUtils 
    qw( $eh mix_store mix_utils_open mix_utils_print 
	mix_utils_printf mix_utils_close replace_mac
	is_integer is_integer2 );
use Micronas::MixUtils::IO;
use Micronas::MixParser qw( %hierdb %conndb add_conn );

#
# Prototypes
#
sub _write_entities				($$$);
sub compare_merge_entities		($$$$);
sub mix_wr_fromto				($$$$);
sub _write_constant				($$$$$;$);
sub write_architecture			();
sub strip_empty					($);
sub port_map					($$$$$$);
sub generic_map					($$$$;$$);
sub print_conn_matrix			($$$$$$$$$;$);
sub signal_port_resolve			($$);
sub use_lib						($$);
sub is_vhdl_comment				($);
sub is_comment					($$);
sub count_load_driver			($$$$);
sub gen_concur_port				($$$$$$$$;$$);
sub mix_wr_get_interface		($$$$;$);
sub _mix_wr_get_ivhdl			($$$;$);
sub _mix_wr_get_iveri			($$$$;$);
sub mix_wr_port_check			($$);
sub mix_wr_unsplice_port		($$$);
sub mix_wr_hier2mac				($);
sub mix_wr_getpwidth			($);
sub mix_wr_getconstname			($$);
sub sig_typecast				($$);
sub _mix_wr_isinteger			($$$);
sub mix_wr_mapsort				($$);
sub _mix_wr_is_modegennr		($$);
sub mix_wr_use_udc				($$$);
sub _mix_wr_save_hooks			();
sub _mix_wr_preset_hooks		();
sub _mix_wr_getfilter			($$);
sub _mix_wr_descr				($$$$$);
sub mix_wr_printdescr			($$);
sub _mix_wr_regorwire			($$);
sub _mix_wr_signum2signam		($);
sub _mix_wr_map_veri			($$$$$);
sub _mix_wr_get_components		($$$$$$$$$$);
sub _mix_wr_nice_comment		($$$);

# Internal variable

#
# RCS Id, to be put into output templates
#
my $thisid		=	'$Id: MixWriter.pm,v 1.97 2006/10/30 15:34:59 wig Exp $';
my $thisrcsfile	=	'$RCSfile: MixWriter.pm,v $';
my $thisrevision   =      '$Revision: 1.97 $';

$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?

my $logger = get_logger( 'MIX::MixWriter' );

#
# Templates ...
#
sub tmpl_enty () {

# TODO: Read that templates in from default location (e.g. a company default)
my $tmpl = <<'EOD';
-- -------------------------------------------------------------
--
--  Entity Declaration for %ENTYNAME%
--
-- Generated
--  by:  %USER%
--  on:  %DATE%
--  cmd: %CARGV%
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- %H%Author%H%
-- %H%Id%H%
-- %H%Date%H%
-- %H%Log%H%
--
-- Based on Mix Entity Template built into THISRCSFILE
-- THISID
--
-- Generator: %0% Version: %VERSION%, wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
%VHDL_USE_ENTY%
%VHDL_HOOK_ENTY_HEAD%
--

EOD

$tmpl =~ s/THISRCSFILE/$thisrcsfile/;
$tmpl =~ s/THISID/$thisid/;
$eh->set( 'template.vhdl.enty.head' , $tmpl ),

$tmpl = <<'EOD';
--
-- Start of Generated Entity %ENTYNAME%
--
entity %ENTYNAME% is
%VHDL_HOOK_ENTY_BODY%
%S%-- Generics:
%GENERIC%
%S%-- Generated Port Declaration:
%PORT%
end %ENTYNAME%;
--
-- End of Generated Entity %ENTYNAME%
--

EOD

$eh->set( 'template.vhdl.enty.body', $tmpl );

$tmpl = <<'EOD';
%VHDL_HOOK_ENTY_FOOT%
--
--!End of Entity/ies
-- --------------------------------------------------------------
EOD

$eh->set( 'template.vhdl.enty.foot', $tmpl );

} # End of tmpl_enty

#
# Architecture Templates ...
#
sub tmpl_arch () {

my $tmpl = <<'EOD';
-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for %ARCHNAME% of %ENTYNAME%
--
-- Generated
--  by:  %USER%
--  on:  %DATE%
--  cmd: %CARGV%
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- %H%Author%H%
-- %H%Id%H%
-- %H%Date%H%
-- %H%Log%H%
--
-- Based on Mix Architecture Template built into THISRCSFILE
-- THISID
--
-- Generator: %0% %VERSION%, wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
%VHDL_USE_ARCH%
%VHDL_HOOK_ARCH_HEAD%
--
EOD

$tmpl =~ s/THISRCSFILE/$thisrcsfile/;
$tmpl =~ s/THISID/$thisid/;
$eh->set( 'template.vhdl.arch.head', $tmpl );

$eh->set( 'template.vhdl.arch.body', <<'EOD' );
--
-- Start of Generated Architecture %ARCHNAME% of %ENTYNAME%
--
architecture %ARCHNAME% of %ENTYNAME% is 

%CONSTANTS%

%COMPONENTS%

%SIGNALS%

%VHDL_HOOK_ARCH_DECL%

begin

%VHDL_HOOK_ARCH_BODY%
%S%--
%S%-- Generated Concurrent Statements
%S%--

%CONCURS%

%INSTANCES%

end %ARCHNAME%;

EOD
# Replaced %ARCHNAME% by RTL, requested by Michael P.
# Replaces end %ARCHNAME% by %ENTYNAME%

$eh->set( 'template.vhdl.arch.foot', <<'EOD' );
%VHDL_HOOK_ARCH_FOOT%
--
--!End of Architecture/s
-- --------------------------------------------------------------
EOD

#	'vhdl' =>{
#	    'conf' => "VHDL Configuration Template String t.b.d.",
#	    'arch' => "VHDL Architecture Template String t.b.d.",
#	},
#	'verilog' =>{
#	    'wrap' => "Verilog Wrapper Template String",
#	    'file' => "Verilog File Template String",
#	},
#   },

#
# Verilog: has only a "arch" template ...
# Use the same schema as for VHDL to make it easier to program ..

$tmpl = <<'EOD';
// -------------------------------------------------------------
//
// Generated Architecture Declaration for %ARCHNAME% of %ENTYNAME%
//
// Generated
//  by:  %USER%
//  on:  %DATE%
//  cmd: %CARGV%
//
// !!! Do not edit this file! Autogenerated by MIX !!!
// %H%Author%H%
// %H%Id%H%
// %H%Date%H%
// %H%Log%H%
//
// Based on Mix Verilog Architecture Template built into THISRCSFILE
// THISID
//
// Generator: %0% %VERSION%, wilfried.gaensheimer@micronas.com
// (C) 2003,2005 Micronas GmbH
//
// --------------------------------------------------------------
%VERILOG_USE_ARCH%

%VERILOG_TIMESCALE%

%VERILOG_HOOK_HEAD%

//
EOD

$tmpl =~ s/THISRCSFILE/$thisrcsfile/;
$tmpl =~ s/THISID/$thisid/;
$eh->set( 'template.verilog.arch.head', $tmpl );

$eh->set( 'template.verilog.arch.body', <<'EOD' );
//
// Start of Generated Module %ARCHNAME% of %ENTYNAME%
//

%VERILOG_DEFINES%
%INT_VERILOG_DEFINES%

module %ENTYNAME%
%VERILOG_INTF%

%S%// Internal signals

%SIGNALS%

%S%// %COMPILER_OPTS%

%CONCURS%

%VERILOG_HOOK_BODY%

%INSTANCES%

endmodule
//
// End of Generated Module %ARCHNAME% of %ENTYNAME%
//
EOD

$eh->set( 'template.verilog.arch.foot', <<'EOD' );
%VERILOG_HOOK_FOOT%
//
//!End of Module/s
// --------------------------------------------------------------
EOD

} # End of tmpl_arch

sub tmpl_conf () {

# TODO: Read that templates in from default location (e.g. a company default)
my $tmpl = <<'EOD';
-- -------------------------------------------------------------
--
-- Generated Configuration for %CONFNAME%
--
-- Generated
--  by:  %USER%
--  on:  %DATE%
--  cmd: %CARGV%
--
-- !!! Do not edit this file! Autogenerated by MIX !!!
-- %H%Author%H%
-- %H%Id%H%
-- %H%Date%H%
-- %H%Log%H%
--
-- Based on Mix Entity Template built into THISRCSFILE
-- THISID
--
-- Generator: %0% Version: %VERSION%, wilfried.gaensheimer@micronas.com
-- (C) 2003,2005 Micronas GmbH
--
-- --------------------------------------------------------------
%VHDL_USE_CONF%
%VHDL_HOOK_CONF_HEAD%
EOD

$tmpl =~ s/THISRCSFILE/$thisrcsfile/;
$tmpl =~ s/THISID/$thisid/;
$eh->set( 'template.vhdl.conf.head', $tmpl );

$eh->set( 'template.vhdl.conf.body', <<'EOD' );
--
-- Start of Generated Configuration %CONFNAME% / %ENTYNAME%
--
configuration %CONFNAME% of %ENTYNAME% is
%VHDL_HOOK_CONF_BODY%
%S%for %ARCHNAME%

%S%%S%%CONFIGURATION%

%S%end for; 
end %CONFNAME%;
--
-- End of Generated Configuration %CONFNAME%
--

EOD
# Replaced %ARCHNAME% by RTL, requested by Michael P. 

$eh->set( 'template.vhdl.conf.foot', <<'EOD' );
%VHDL_HOOK_CONF_FOOT%
--
--!End of Configuration/ies
-- --------------------------------------------------------------
EOD

} # End of tmpl_conf

####################################################################
## generate_entities
## scan through hierachy and set up entities
####################################################################

=head2

generate_entities () {

Scan all of hierachy and create consistent, checked list of entities.
An entity has a name and a portmap (generic map).

Data structure will look like $entities{$name}{$port}{type|from|to|mode}.
Type will be generic or std_logic or std_ulogic ....

Relies on $hierdb{inst}{::conn}{::in|::out} to exist!

TODO: Usage of hierdb is not nice. Search for a better way.
TODO: Generics and inout mode ....

=cut

sub generate_entities () {

    for my $i ( keys( %hierdb ) ) {
        unless( exists ( $hierdb{$i}{'::entity'} ) ) {
            $logger->warn('__W_GENERATE_ENTY', "\tSkipping instance $i with undefined entity!");
            next;
        }
        my $ent = $hierdb{$i}{'::entity'};

        if ( defined( $entities{$ent} ) ) {
            merge_entity( $ent, $hierdb{$i} );
        } else {
            create_entity( $ent, $hierdb{$i} );
        }
    }
    return;
}

#
# Create a dummy entity entry and compare the "signatures"
# Merge into old one
#
sub merge_entity ($$) {
    my $ent = shift;
    my $inst = shift;

    my %ient;
    if ( exists( $inst->{'::conn'}{'in'} ) ) {
        %ient = _create_entity( 'in', $inst->{'::conn'}{'in'} );
    } else {
        # Create dummy entry, no port ...
        %{$ient{'-- NO IN PORTs'}} = (
            'type' => '',
            'mode' => '',
            'high' => '',
            'low' => '',
            '_descr_' => '',
        );
    }

    if ( exists( $inst->{'::conn'}{'out'} ) ) {
        %ient = ( %ient, _create_entity( 'out', $inst->{'::conn'}{'out'} ) );
    } else {
        # Create dummy entry, no port ...
        %{$ient{'-- NO OUT PORTs'}} = (
            'type' => '',
            'mode' => '',
            'high' => '',
            'low' => '',
            '_descr_' => '',
        );
    }

    # $eq will be 1 if acceptable differences exist, else 0!
    # compare_merge_entities will sum up acceptable differences in %entities and
    # complain verbosely otherwise
    my $eq = compare_merge_entities( $ent, $inst->{'::inst'}, $entities{$ent}, \%ient );
    #TODO: use result for further decision making

    if ( $inst->{'::treeobj'}->daughters ne "0" ) {
		$ient{'__LEAF__'}++;
    }

    # Remember language for this entity ...
    if ( exists( $inst->{'::lang'} ) and $inst->{'::lang'} ) {
        $ient{'__LANG__'}{lc($inst->{'::lang'})}++;
    } else {
        $ient{'__LANG__'}{lc( $eh->get( 'macro.%LANGUAGE%' )) }++;
    }
} # End of merge_entity

#
# Overlap the signal and hierachy information to generate a entity
# 
# Input:
#	Entity name
#	Instance name
#	Existing  entitiy "object"
#	New entity "object"
#
# Output:
#	1 if new description matches existing
#	0 otherwise
#
# Global:
#	writes %entities
#	writes $eh
#
sub compare_merge_entities ($$$$) {
    my $ent = shift;
    my $inst = shift || "__E_INST__";
    my $rent = shift;
    my $rnew = shift;

    #    %{$entity{$ent}{'-- NO OUT PORTs'}} = (
    #       'type' => '',
    #       'mode' => '',
    #       'high' => '',
    #       'low' => '',
    #       'value' => ''  (stores default value for generics)
    #       'cast' => port is of type cast, needs typecast function to match signal type!
	#		'rorw' =>	register or wire ....
	#		'_descr_'	=> []	array of descriptions (to remove duplicates)

    my $eflag = 1; # Is equal

    #For all ports:
    my $simple_re = $eh->get( 'output.generate._logicre_' );
    for my $p ( keys( %$rent ) ) {

		next if ( $p =~ m,^__, ); # Skip internals like __LEAF__, __LANG__
    	# Skip that if it does not exist in the new port map
		unless( exists( $rnew->{$p} ) ) {
	    	if (    $p ne '-- NO OUT PORTs' 
	    			and $p ne '-- NO IN PORTs'
	    			and $ent ne 'W_NO_ENTITY'
	    			and $ent ne '%TYPECAST_ENT%'
	    			and $ent !~ m/$simple_re/i ) {
				$logger->warn( '__W_COMP_MERG_ENTY', "Missing port $p in entity $ent ($inst) redeclaration, ignoreing!" );
				$eflag  = 0;
	    	}
            next;
        }

        # Type has to match
        if ( $rent->{$p}{'type'} ne $rnew->{$p}{'type'} ) {
            $logger->warn( '__W_COMP_MERG_ENTY', "\tEntity port type mismatch for entity $ent ($inst), port $p: ".
                     $rnew->{$p}{'type'} . " was " . $rent->{$p}{'type'} . "!" );
            $eflag = 0;
            next; # TODO : How should we handle that properly?
        # Mode has to match
        } elsif ( ($rent->{$p}{'mode'} !~ m/[pg]/i and $rnew->{$p}{'mode'} !~  m/[pg]/i ) and ($rent->{$p}{'mode'} ne $rnew->{$p}{'mode'}) ) {
            $logger->warn( '__W_COMP_MERG_ENTY', "\tEntity port mode mismatch for enitity $ent ($inst), port $p: " .
                     $rnew->{$p}{'mode'} . " was " . $rent->{$p}{'mode'} . "!" );
            $eflag = 0;
            next;
        }
        # Take larger 'high' value
        if ( defined( $rnew->{$p}{'high'} ) and $rnew->{$p}{'high'} =~ m/^(\d+)$/o ) {
            my $val = $1;
            my $re = $rent->{$p}{'high'};
            unless ( defined( $re ) and
                     $re =~ m/^(\d+)$/o and
                     $re >= $val ) {
                $rent->{$p}{'high'} = $val;
            }
        }
        # Take lower 'low' value
        if ( defined( $rnew->{$p}{'low'} ) and $rnew->{$p}{'low'} =~ m/^(\d+)$/o ) {
            my $val = $1;
            my $re = $rent->{$p}{'low'};
            unless ( defined( $re ) and
                     $re =~ m/^(\d+)$/o and
                     $re <= $val ) {
                $rent->{$p}{'low'} = $val;
            }
        }
        # If 'value' is defined, add it ...
        if ( exists( $rnew->{$p}{'value'} ) ) {
            $rent->{$p}{'value'} = $rnew->{$p}{'value'};
        }
        # If 'rvalue' is defined, add it ...
        if ( exists( $rnew->{$p}{'rvalue'} ) ) {
            $rent->{$p}{'rvalue'} = $rnew->{$p}{'rvalue'};
        }
        delete( $rnew->{$p} ); # Done
    }

    # Now we add up the rest of $rnew ...
    $simple_re = $eh->get( 'output.generate._logicre_' );
    for my $p ( keys( %$rnew ) ) {
		if (    $p ne '-- NO OUT PORTs'
			and $p ne '-- NO IN PORTs'
            and $ent ne 'W_NO_ENTITY'
            and $ent ne '%TYPECAST_ENT%'
            and $ent !~ m/$simple_re/i )
        {
	    	$logger->warn( '__W_COMP_MERG_ENTY', "\tDeclaration for entity $ent ($inst) extended by $p!" );
	    	$eflag = 0;
    	}
        $rent->{$p} = $rnew->{$p}; # Copy
    }
    return $eflag;
} # End of compare_merge_entities

sub create_entity ($$) {
    my $ent = shift; # Entity name
    my $inst = shift; # Reference to instance.

    if ( exists( $inst->{'::conn'}{'in'} ) ) {
        %{$entities{$ent}} = _create_entity( 'in', $inst->{'::conn'}{'in'} );
    } else {
        # Create dummy entry, no port ...
        %{$entities{$ent}{'-- NO IN PORTs'}} = (
            'type' => '',
            'mode' => '',
            'high' => '',
            'low' => '',
            '_descr_' => '',
        );
    }

    if ( exists( $inst->{'::conn'}{'out'} ) ) {
        %{$entities{$ent}} = ( %{$entities{$ent}} , _create_entity( 'out', $inst->{'::conn'}{'out'} ));
    } else {
        # Create dummy entry, no port ...
        %{$entities{$ent}{'-- NO OUT PORTs'}} = (
            'type' => '',
            'mode' => '',
            'high' => '',
            'low' => '',
            '_descr_' => '',
        );
    }

    if ( $inst->{'::treeobj'}->daughters() ne "0" ) {
		$entities{$ent}{'__LEAF__'}++;
    } else {
		$entities{$ent}{'__LEAF__'} = 0;
    }

    # Remember language for this entity ... check later on ...    
    if ( exists( $inst->{'::lang'} ) and $inst->{'::lang'} ) {
        $entities{$ent}{'__LANG__'}{lc($inst->{'::lang'})}++;
    } else {
        $entities{$ent}{'__LANG__'}{lc($eh->get( 'macro.%LANGUAGE%'))}++;
    }
    
} # End of create_entity

#
# Take ::in and ::out defined data and generate a port description ...
#
#!wig20040330: if port width = 0 (undef or 0:0): remove _vector from type!
sub _create_entity ($$) {
    my $io = shift;
    my $ri = shift;

    my %res = ();
    for my $i ( keys( %$ri ) ) { # iterate over all signals
        my $sport = $ri->{$i};
	
        unless( defined( $conndb{$i} ) ) {
            $logger->error('__E_CREATE_ENTY', "\tIllegal signal name $i referenced in _create_entity!");
            next;
        }

		my $type = $conndb{$i}{'::type'} || "_E_CONNTYPE"; 
        my $cast = '';
        my $nr   = $conndb{$i}{'::connnr'};
        $nr = '__E_CONNNR' unless( defined $nr );
        
		#
		# Iterate through all inst/ports ...
		#
        for my $port ( keys( %$sport ) ) {
	    	my $h = -100000;	# Absurd value .... just to avoid undef
	    	my $l = -100000;	# Absurd value ....
			my $gen = 0;		# Flag for generated port
			my $descr = '';		# Keep description
			my $rorw = '';		# Storage for special "rorw" (reg or wire switch)
			
	    	# width definition may differ for this port ....
	    	for my $ii ( split( ',', $$sport{$port} ) ) {
				my $thissig = $conndb{$i}{'::' . $io}[$ii]; # Get this signal ...
				# Find max/min port bounds ....
				# TODO : What if there are holes? Sanity checks need to be done before ...
				if ( defined $thissig->{'port_f'} and $thissig->{'port_f'} ne '' ) { # This is a bus ...
                    if ( $h =~ m,^-?\d+$,o ) {
                        if ( $thissig->{'port_f'} =~ m,^\d+$,o ) {
                            if ( $h < $thissig->{'port_f'} ) {
                                    $h = $thissig->{'port_f'};
                            }
                        } else { # port_f is non numeric ...
                            $logger->warn('__W_CREATE_ENTY', "\tNonnumeric upper port bound for $thissig->{'inst'}/$thissig->{'port'}!")
                                unless ( $h == -100000 );
                            $h = $thissig->{'port_f'};
                        }
                    } else {
                        if ( $h ne $thissig->{'port_f'} ) {
                            $logger->warn('__W_CREATE_ENTY', "\tNonmatching nonnumeric upper port bound $thissig->{'inst'}/$thissig->{'port'}!");
                            $h = "__E_NONMATCH_NONNUM_UB";
                        }
                    }
				}
		    
				if ( defined $thissig->{'port_t'} and $thissig->{'port_t'} ne '' ) { # This is be a bus ...
                    if ( $l =~ m,^-?\d+$,o ) {
                       if ( $thissig->{'port_t'} =~ m,^\d+$,o ) {
                            if ( $l == -100000 or $l > $thissig->{'port_t'} ) {
                                    $l = $thissig->{'port_t'};
                            }
                        } else { # port_t is non numeric ...
                            $logger->warn('__W_CREATE_ENTY', "\tNonnumeric lower port bound for $thissig->{'inst'}/$thissig->{'port'}!")
                                unless ( $l == -100000 );
                            $l = $thissig->{'port_t'};
                        }
                    } else {
                        if ( $l ne $thissig->{'port_t'} ) {
                            $logger->warn('__W_CREATE_ENTY', "\tNon-matching non-numeric lower port bound $thissig->{'inst'}/$thissig->{'port'}!");
                            $h = "__E_NONMATCH_NONNUM_LB";
                        }
                    }
		    	}

            	#
            	# typecast required
            	#wig20030801
            	#wig20040803: the old way (creates port map typecast)
 
            	# $type -> port type;
            	# $cast -> signal type;
            	if ( defined( $thissig->{'cast'} ) ) {    
                	if ( $eh->get( 'output.generate.workaround.typecast' ) =~ m/\bportmap\b/o ) {
                    	$cast = $type;
                    	$type = $thissig->{'cast'};
                    	$logger->debug('__D_CREATE_ENTY', "\tPortmap typecast requested for signal $i/$cast, port $port/$type");
                	} elsif ( $eh->get( 'output.generate.workaround.std_log_typecast' ) =~ m/\bignore\b/o ) {
                    	$cast = $type;
                    	$type = $thissig->{'cast'};
                    	$logger->debug('__D_CREATE_ENTY', "\tstd_log_ignore typecast for signal $i/$cast, port $port/$type");
                	}
            	}
            	# Remember: was that port generated?
            	# TODO : improve error handling
				if ( exists( $thissig->{'_gen_'} ) ) {
					$gen = 1;
				}
				if ( exists( $thissig->{'_descr_'} ) ) {
					$descr = $thissig->{'_descr_'};
				}
				if ( exists( $thissig->{'rorw'} ) ) {
					$rorw = $thissig->{'rorw'};
				}
	    	}
	    	# Still at the preset value?
	    	if ( $l eq '-100000' ) {
				$l = undef;
	    	}
	    	if ( $h eq '-100000' ) {
				$h = undef;
	    	}

	    	# If connecting single signals to a bus-port, make type match!
	    	# TODO SPECIAL trick ???? Check if that is really so clever ....
	    	# TODO Should be done by just any type ...
	    	if ( ( $type eq 'std_logic' or
		    	$type eq 'std_ulogic' ) and
		    	defined( $h ) and defined( $l ) and
		    	( $h ne $l ) ) { #!wig20030516 ...
				$type = $type . '_vector';
				$logger->warn('__W_CREATE_ENTY', "\tAutoconnecting bit signal $i to bus port $port" );
	    	}

        	# If we connect a single bit to to a bus, we strip of the _vector from
        	# the type of the signal to get correct port type
        	# TODO : Expand to work for any type ...
        	#!wig20040330: if port spans from 0:0 remove the _vector, too (?)
        	if ( ( ( not defined( $h ) and not defined( $l )) or
                   ( defined( $h ) and $h eq '0' and defined( $l ) and $l eq '0' ) ) and
                  $type =~ m,(.+)_vector, ) {
				#!wig: remove vector, leave rest as is: $type = $1;
				$type =~ s/_vector//io;
				$logger->warn('__W_CREATE_ENTY', "\tAutoreducing port type for signal $i to $type" );
			};

    
			my $m = $conndb{$i}{'::mode'};
	    	my $mode = '__E_MODE_DEFAULT_ERROR__';
	    	if ( $m ) { # not empty
				if ( $m =~ m,IO,io )   { $mode = "inout"; } 	 # inout mode!
				elsif ( $m =~ m,B,io ) { $mode = "%BUFFER%"; }	 # buffer
				elsif ( $m =~ m,T,io ) { $mode = "%TRISTATE%"; } # tristate bus ...
				elsif ( $m =~ m,C,io ) { $mode = $io; }			 # Constant / wig20050202: map to S
				elsif ( $m =~ m,[GP],io ) {                      # Generic, parameter
                	# Read "value" from ...:out
                	$mode = $m;
            	} elsif ( $m =~ m,S,io ) { $mode = $io; }				# signal -> derive from i/o
				elsif ( $m =~ m,I,io ) {							# warn if mode mismatches
		    		# TODO : Need to look at all connections ....
		    		if ( $io eq "out" ) {
						$logger->debug('__D_CREATE_ENTY', "\tMode mismatch for signal $i, port $port: $m ne $io" );
						$conndb{$i}{'::comment'} .= ",__W_MODE_MISMATCH"; # TODO :  __E?? (increase level to error)
						$mode = $io;
		    		} else {
						$mode = 'in';
		    		}
				} elsif ( $m =~ m,O,io ) {					# xls says O!
		    		if ( $io eq 'in' ) {
						$logger->debug('__D_CREATE_ENTY', "\tMode mismatch for signal $i, port $port: $m ne $io" );
						$conndb{$i}{'::comment'} .= ",__W_MODE_MISMATCH"; # TODO : __E?? (increase errror level)
						$mode = $io;
		    		} else {
						$mode = "out";
		    		}
				} else {
		    		$logger->error('__E_CREATE_ENTY', "\tSignal $i mode $m defaults to bad value, set to $io" );
		    		$mode = $io;
				}
	    	} else { # if no mode was specified, it defaults to S, which means to autodetecte in/out
				$mode = $io;
	    	}
    
	    	#
	    	# Duplicate signals will be caught by the compare_and_merge_entitiy
	    	# function
	    	#
	    	if ( exists( $res{$port} ) ) {
	    		#
	    		# Overlay port definitions ...
	    		# Mark mismatches ....
	    		#
				if ( $mode ne $res{$port}{'mode'} ) {
                	if ( $mode =~ m,^\s*[GP],io and $res{$port}{'mode'} =~ m,\s*[GP],io ) {
                    	$mode = 'P';
                    	$res{$port}{'mode'} = "P";
                	} elsif ( $res{$port}{'mode'} !~ m,^\s*[GP],io ) {
                    	$logger->warn('__W_CREATE_ENTY', "\tPort $port redefinition mode mismatch: $mode " .
			    					$res{$port}{'mode'} );
			    		$res{$port}{'mode'} = "__W_PORTMODE_MISMATCH";
                	}
				}
				
				#  if port is generated -> set __gen__ to true!
				if ( $gen ) {
					$res{$port}{'__gen__'} = 1;
				}
		
				# High bound:
				if ( defined( $h ) ) {
		    		if ( defined( $res{$port}{'high'} ) ) {
						# check borders:
						my $s_h = $res{$port}{'high'};
						if ( $h ne $s_h ) {
							if ( $h =~ m/^\d+$/ and $s_h =~ m/^\d+$/ ) {
								# Increase if $h > stored value:
								if ( $h > $s_h ) {
			    					$res{$port}{'high'} = $h;
								}
							} else {
			    				$logger->warn('__W_CREATE_ENTY_NAN',
									"\tPort $port high bound redefinition mismatch/nan: $h vs. " .
									$s_h );
							}
						}
		    		} else {
						if ( $h ) { # Defined, but 0, which is approx. undef.
			    			$logger->warn('__W_CREATE_ENTY', "\tPort $port high bound redefinition mismatch: $h vs. undef" );
						}
						$res{$port}{'high'} = $h;
		    		}
				} elsif ( defined( $res{$port}{'high'} ) ) {
		    		if( $res{$port}{'high'} ) { # Suppress message
						$logger->warn('__W_CREATE_ENTY', "\tPort $port high bound redefinition mismatch: undef  vs. " .
						$res{$port}{'high'} );
		    		}
				}
				# Low bound:
				if ( defined( $l ) ) {
		    		if ( defined( $res{$port}{'low'} ) ) {
						my $s_l = $res{$port}{'low'};
						if ( $l ne $s_l ) {
							if ( $l =~ m/^\d+$/ and $s_l ) {
								if ( $l < $s_l ) {
			    					$res{$port}{'low'} = $l;
								}
							} else {
			    				$logger->warn('__W_CREATE_ENTY_NAN',
								"\tPort $port low bound redefinition mismatch/nan: $l vs. " .
									$s_l );
							}
						}
		    		} else {
						if ( $l ) {
			    			$logger->warn('__W_CREATE_ENTY', "\tPort $port low bound redefinition mismatch: $l vs. undef" );
						}
						$res{$port}{'low'} = $l;
		    		}
				} elsif ( defined( $res{$port}{'low'} ) ) {
		    		if ( $res{$port}{'low'} ) { # Suppress message if 0
						$logger->warn('__W_CREATE_ENTY', "\tPort $port low bound redefinition mismatch: undef  vs. " .
			    		$res{$port}{'low'} );
		    		}
				}
				$l = $res{$port}{'low'};
				$h = $res{$port}{'high'};

				if ( defined( $h ) and defined ( $l ) and ( $h ne $l ) and $type =~ m,(std_u?logic)\s*$, ) {
                	if ( ( $type . "_vector" ) ne $res{$port}{'type'} ) {
                    	$logger->warn('__W_CREATE_ENTY', "\tAutoexpand port $port from $type to vector type!");
                    	$type = $1 . "_vector";
                	}
				}
			
				#
				# type mismatch handling:
				#
            	# Expand port to std_ulogic_type if required ...
            	# TODO : Why here again? See above		
				if ( $type ne $res{$port}{'type'} ) {
		    		if ( defined( $l ) and defined( $h ) and ( $h ne $l ) ) { #Take _vector ...
						if ( $res{$port}{'type'} !~ m,_vector,io ) {
			    			if ( $type =~ m,(std_u?logic),io ) {
								$res{$port}{'type'} = $type; # Automatically expand to vector type
			    			} else {
								$logger->warn('__W_CREATE_ENTY', "\tPort $port redefinition type mismatch: $type vs. " .
				    				$res{$port}{'type'} );
			    			}
		    			}
					}
				}
		
            	# Detect bad typecast requests (differing!!)
    			if ( $cast and exists( $res{$port}{'cast'} ) ) {
                	if ( $cast ne $res{$port}{'cast'} ) {
                    	$logger->warn('__W_CREATE_ENTY', "\tPort $port typecast mismatch: $cast was $res{$port}{'cast'}" );
                	}
    			} elsif( $cast or exists( $res{$port}{'cast'} ) ) {
                	my $c = ( defined( $cast ) ) ? $cast : "NOT_NOW";
                	my $cp = ( defined( $res{$port}{'cast'} ) ) ?
                         $res{$port}{'cast'} : "NOT_BEFORE";
                	$logger->warn('__W_CREATE_ENTY', "\tPort $port typecast requested: $cp was $cp" );
    			}

				# take lowest signal number ...
				#TODO: should we remember all signals?
				if ( $res{$port}{'__nr__'} > $nr ) {
					$res{$port}{'__nr__'} = $nr;
				}
				#!wig20051010: Get descr if available
				$res{$port}{'__descr__'} .= $descr;
	    	} else {
				%{$res{$port}} = (
		    		'mode' => $mode, #TODO: do some sanity checking! e.g. high, low might be
						# undefined, check if bus vs. bit. and consider the ::mode!
		    		'type' => $type,  #|| 'signal', # type defaults to signal
		    		'high' => $h,  # set default to '' string
		    		'low'  => $l,   # set default to '' string
					);
        		$res{$port}{'cast'} = $cast if ( $cast ); # Adding a typecast if requested
        		$res{$port}{'rorw'} = $rorw if ( defined($rorw) and $rorw );
				$res{$port}{'__gen__'}  = 1 if ( $gen );
				$res{$port}{'__nr__'} = $nr   if ( defined( $nr ) );
				$res{$port}{'__descr__'} = $descr;
	    	}

        	if ( $mode =~ m,^\s*[GP], ) {
            	# Set 'default' value from '::out' field (if defined)
            	my @vals = @{$conndb{$i}{'::out'}};
            	for my $v ( 0..$#vals ) {
                	if ( exists( $vals[$v]{'inst'} ) and
                     	$vals[$v]{'inst'} =~ m,(%|__)GENERIC(%|__),o ) {
                     	$res{$port}{'value'} = $vals[$v]{'port'};
                     	last;
                	}
            	}
        	}
        }
    }
    return %res;
} # End of _create_entity

####################################################################
## write_entities
####################################################################

=head2

write_entities () {

Write entity into output file(s).

=cut

sub write_entities () {

    # Set up entity template;
    tmpl_enty();
    
    # output file name
    my $efname = $eh->get('outenty');

 	
    if ( $efname =~m/^(ENTY|COMB)/o ) {
        # ENTY -> write each entity in a file of it's own
        # COMB(INE) -> combine entity, architecture and configuration
        #  this is mostly important for architecture and configuration
        # filename is the entity name
        # All other cases -> use efname as entity file name (write all entities into
        # one file of that name)
        my $entext = $eh->get('postfix.POSTFILE_ENTY');
        if ( $1 eq 'COMB' ) {
            $entext = '';
        }
		for my $i ( sort( keys( %entities ) ) ) {
            
            next if ( $i eq 'W_NO_ENTITY' );
            next if ( $i eq '%TYPECAST_ENT%' );
                my $i_fn = $i;
                #Changed 20030714a/Bug:
                $i_fn =~ s,_,-,og if ( $eh->get('output.filename') =~ m,allminus, );
                # replace _ by - in entity names.

                # In combine mode, choose entity.vhd as filename.
                # my $lang = "vhdl"; # Filename extension defaults to VHDL
                my $lang = mix_wr_getlang( $i, $entities{$i}{__LANG__} );
				my $filename = $i_fn . $entext . '.' . $eh->get( 'output.ext.' . $lang );
	    	_write_entities( $i, $filename, \%entities )
		}
    } else {
	_write_entities( "__COMMON__", $efname, \%entities );
    }

    return;

}

#
# mix_wr_getlang( $i )
# Retrieve a allowed HDL language for this entity
# from the __LANG__ hash. Compare against the allowed
# languages (all the one we have $eh->get('template') for)
#
sub mix_wr_getlang ($$) {
    my $enti = shift;
    my $entylangr = shift;

    my @langs = keys %$entylangr;
    my $requested = scalar( @langs );

    my $goodlang = '(' . join( '|', keys( %{$eh->get('template')} )) . ')';
    @langs = grep( m/^$goodlang/ , @langs ); # Select available languages    
    if ( scalar( @langs ) > 1 ) {
        $logger->warn('__W_GETLANG', "\tRequesting multiple languages for entity $enti!");
    } elsif ( $requested > 1 ) {
        $logger->warn('__W_GETLANG', "\tAutoresolved multiple language request for entity $enti!");
    }
    if ( scalar( @langs ) < 1 ) {
        return $eh->get( 'macro.%LANGUAGE%' );
    } else {
        return $langs[0];
    }
} # End of mix_wr_getlang

#
# Do the work: Collect ports and generics from %entities.
# Print out and also save port and generics for later reusal (e.g. architecture)
#
#20030523: add Verilog -> output comment
# TODO : rework that, split the parts that build internally used information
# and the pure writer into two. REMOVE SIDEEFFECTS
#20050414: trial to support very simple logic: AND, OR, WIRE, ...
#
sub _write_entities ($$$) {
    my $ehname = shift;
    my $file = shift;
    my $ae = shift;

    my %macros = %{$eh->get('macro')};

    $macros{'%ENTYNAME%'} = $ehname;

    if ( -r $file ) {
		$logger->warn('__W_WR_ENTY', "\tEntity declaration file $file will be overwritten!" );
    }

    #
    # Do not create an output file if entitiy is leaf and "noleaf" set
    #
    my $write_flag = 1;
    my $fh = undef; # Keep rel/abs. file name (without PATH?)
 
    #
    # will write a output file anyway if we are in __COMMON__ mode
    # or if we want to write leaf cells and it's a leaf cell
    # or if it's VHDL
    # or if the "check.entities.path" flag is set ...
    #
    if ( $ehname ne "__COMMON__" and
            ( $eh->get( 'output.generate.enty' ) =~ m,\bnoleaf,io and
            $entities{$ehname}{'__LEAF__'} == 0 or
            mix_wr_getlang( $ehname, $ae->{$ehname}{'__LANG__'}) ne "vhdl" )
        ) {
		$write_flag = "0"; # Do NOT write ...
    }
    #
    # Do not write, if this entity is in the filter list!
    #!wig20051005:
    if ( $eh->get( 'output.filter.file' ) ) {
	   	my $filter = _mix_wr_getfilter( 'enty', $eh->get( 'output.filter.file' ) );	    	
	    if ( $ehname =~ m/$filter/ ) {
	    	$write_flag = 0;
		    $logger->warn( '__W_WR_ENTY', "\tSkipped writing of entity $ehname due to filter" );    		
		    
	    }
	}
	
    #
    # another case: if this entity is in the "simple logic" list, do
    # not write ...
    #
    my $simple_re = $eh->get( 'output.generate._logicre_');
    if ( $ehname =~ m/$simple_re/i ) {
    	$write_flag = "0";
    }

    # Are we in verify mode?
    if ( $eh->get( 'check.hdlout.path' ) and
         $eh->get( 'check.hdlout.mode' ) =~ m,\b(ent[iy]|all),io ) { # Selected ...
        # Append check flag ...
        if ( $eh->get( 'check.hdlout.mode' ) =~ m,\bleaf,io ) { # opposite for nonleaf and dcleaf
            # __LEAF__ is 1 if this is not a LEAF!
            $write_flag .= ( $entities{$ehname}{'__LEAF__'} == 0 ) ? "_CHK_ENT_LEAF" : "";
        } else {
            $write_flag .= ( $entities{$ehname}{'__LEAF__'} == 0 ) ? "_CHK_ENT_LEAF" : "_CHK_ENT";
        }
    }

    #wig20040218: pot. two files could get opened ....
    if ( $write_flag ) {
        unless ( $fh = mix_utils_open( $file, $write_flag ) ) {
            $logger->warn( '__W_WR_ENTY', "\tCannot open file $file to write entity declarations: $!" );
            return;
        }
    }

    # Add header
    my $tpg = $eh->get( 'template.vhdl.enty.body' );

    # Collect all use libs from all instances here!
    $macros{'%VHDL_USE%'} = use_lib( "enty", $ehname );

    my $et = replace_mac( $eh->get( 'template.vhdl.enty.head' ), \%macros );    

    #
    # Collect generics and ports ...
    #
    my @keys = ( $ehname eq '__COMMON__' ) ? keys( %$ae ) : ( $ehname );
    for my $e ( sort( @keys ) ) {

		if ( $e eq 'W_NO_ENTITY' ) { next; };
		if ( $e eq '__COMMON__' ) { next; };
        if ( $e eq '%TYPECASTENT%' ) { next; };

		$macros{'%ENTYNAME%'} = $e;
		my $gent = '';
		my $port = '';
		my $pd = $ae->{$e};
        # This language and this comment is
        my $lang = mix_wr_getlang( $e, $pd->{'__LANG__'});
        my $tcom = $eh->get( 'output.comment.' .$lang ) ||
        	$eh->get( 'output.comment.vhdl' );

        # Get interface description for this instance
        ( $port, $gent ) = mix_wr_get_interface( $pd, $e, $lang, $tcom, 2 );

		#
		# If we found ports, 
		# get rid of trailing ; (possibly followed by a comment), replace %MACs%
		# store the results in the entities data structure (will need it later on
		# for the component declarations
		#
        unless ( is_vhdl_comment( $port ) ) { 
            # TODO : %S% use a better mechanism to format output!!
            $port = '%S%' x 2 . $tcom . " Generated Port for Entity $e\n" . $port;
            $port =~ s/;((%S%|\s)*$tcom.*\n)$/$1/i; # Remove trailing ;
            $port =~ s/;\n$/\n/i;
            $port .= '%S%' x 2 . $tcom . " End of Generated Port for Entity $e\n";
            # Store ports and generics for later reusal
            $entities{$e}{'__PORTTEXT__'}{$lang} = $port;
            $port = '%S%' x 2 . "port(\n" . $port . '%S%' x 2 . ');';
        } else {
            $entities{$e}{'__PORTTEXT__'}{$lang} = $port;
            $port = '%S%' x 2 . $tcom . " No Generated Port for Entity $e\n$port";
        }
        # The same for generics
        unless ( is_vhdl_comment( $gent ) ) {
            $gent = '%S%' x 2 . $tcom . " Generated Generics for Entity $e\n" . $gent;            
            $gent =~ s/;((%S%|\s)*$tcom.*\n)$/$1/i;
            $gent =~ s/;\n$/\n/i;
            $gent .= '%S%' x 2 . $tcom . " End of Generated Generics for Entity $e\n";
            # Store ports and generics for later reusal
            $entities{$e}{'__GENERICTEXT__'}{$lang} = $gent;
            $gent = '%S%' x 2 . "generic(\n" . $gent . '%S%' x 2 . ');';
        } else {
            $entities{$e}{'__GENERICTEXT__'}{$lang} = $gent;
            $gent = '%S%' x 2 . $tcom . " No Generated Generics for Entity $e\n$gent";
        }
	
		$macros{'%PORT%'} = $port;
		$macros{'%GENERIC%'} = $gent;

		unless ( $eh->get( 'output.generate.enty' ) =~ m,noleaf,io and
		    $ae->{$e}{'__LEAF__'} == 0  ) {

            #
            # If language other then vhdl -> don't write a thing.
            # makes sense only in __COMMON__ case
            #
            if ( $lang ne "vhdl" ) {
                $et .= '%S%' x 2 . "--\n" . '%S%' x 2 . "-- $lang language choosen for entity $e\n\t\t--\n";
            } else {
                $et .= replace_mac( $tpg, \%macros );
            }
		}
    }
    
    $et .=  $eh->get( 'template.vhdl.enty.foot' );

    $et = replace_mac( $et, \%macros );

    $et = strip_empty( $et );

    # All data collected, now print and close ...
    if ( $write_flag ) {
        mix_utils_print( $fh, $et);
        mix_utils_close( $fh, $file );
    }
}


#                         NAME => PORT => type,mode,high,low(,generic-value)
#         'entities' => {
#                         'ddrv' => {
#					'__LEAF__' = 0...,
#                                      'current_time' => {
#                                                          'low' => '0',
#                                                          'mode' => 'in',
#                                                          'high' => '3',
#                                                          'type' => 'std_ulogic_vector'
#                                                        },
#                                      'key_buffer' => {
#                                                        'low' => '0',
#                                                        'mode' => 'in',
#                                                        'high' => '3',
#                                                        'type' => 'std_ulogic_vector'
#                                                      },	    

####################################################################
##
## mix_wr_get_interface
## query entity and return description of their interface
## input:
## $r_ent   reference to entity description hash
## $ename  entity name
## $lang      requested language
## $tcom     comment ( -- or // ... )
## $indent	level of indent (default: 2)
##
## return values:
##      $port        text description of this entites ports
##      $generics  text description of this entities generics
## side effects:
##     ????
##
## 20050418: return sorted by $
####################################################################
sub mix_wr_get_interface ($$$$;$) {
    my $r_ent	= shift;
    my $ename	= shift; # Name of entity ...
    my $lang	= shift;
    my $tcom	= shift;
    my $indent	= shift || 2;

    if ( $lang =~ m,vhdl,io ) {
        return ( _mix_wr_get_ivhdl( $r_ent, $ename, $tcom, $indent ) );
    }elsif ( $lang =~ m,verilog,io ) { #Potentially also 2001
        return ( _mix_wr_get_iveri( $r_ent, $ename, $lang, $tcom, $indent ) );
    } else {
        $logger->error( '__E_GET_INTERFACE', "\tUnimplemented get_interface for entity $ename, language $lang" );
        return( '%S%' x $indent . $tcom . " __E_MISSING_GET_INTERFACE for $lang",
                    '%S%' x $indent . $tcom . " __E_MISSING_GET_INTERFACE for $lang" );
    }
} # End of mix_wr_get_interface

#
# return VHDL conform interface (port list ....)
#20050418: adding sort criteria
#
# input:
#	entitiy refernece
#	entity name
#	comment chars
#	indent level
# output:
#	portdescription (string)
#	genericsdescription (string)
#
# Globals:
#	<yes>
#
sub _mix_wr_get_ivhdl ($$$;$) {
    my $r_ent	= shift;
    my $ename	= shift; # Name of entity ...
    my $tcom	= shift;
    my $indent	= shift || 2;

    my $gent = '';
    my $port = '';

	my $indent2 = $indent + 1;
	# my $indent3 = $indent + 2;
	
    for my $p ( sort ( keys( %{$r_ent} ) ) ) { # for each port ...
	    next if ( $p =~ m,^__,o ); # Skip internal data ...
        next if ( $p =~ m,^-- NO, ); # Skip internal data ...

	    my $pdd = $r_ent->{$p};
		my $descr = '';
			
	    #!wig20051010: adding description ...
	    my $pdindent = $eh->get( 'output.generate.portdescrindent' ) . $tcom . ' ';
	    if ( $pdd->{'__descr__'} ne '' ) {
	    	( my $d = $pdd->{'__descr__'} ) =~ s/\n/$pdindent/g;
	    	# Prepend all linefeeds by a space - comment
	    	$descr = '%S%' . $tcom . ' ' . $d;
	    	$descr = _mix_wr_shortendescr( $descr, $pdindent ); # Make it fit ...
	    }
	    if ( $pdd->{'mode'} =~ m,^\s*(generic|G|P),io ) {
	    	$gent .= mix_wr_mapsort( $ename, $p );
			if ( exists( $pdd->{'value'} ) ) {
                # Generic, get default value from conndb ...
                 $gent .= '%S%' x $indent2 . $p . "%S%: " . $pdd->{'type'} .
                    	"%S%:= " . $pdd->{'value'} . ';' . $descr . "\n";
			} else {
                 $gent .= '%S%' x $indent2 . $p . "\t: " . $pdd->{'type'} .
                    	'; ' . (( $descr ) ? $descr : $tcom ) . " __W_NODEFAULT\n";
			}
	    } elsif (	defined( $pdd->{'high'} ) and
			defined( $pdd->{'low'} ) and
            $pdd->{'high'} !~ m,^\s*$,o and
            $pdd->{'low'} !~ m,^\s*$,o ) {
			$port .= mix_wr_mapsort( $ename, $p ); # Put in sort criteria!	    
			my $mode = "";
			if ( $pdd->{'mode'} =~ m,^\s*C,io ) {
		    	$mode = "in";
			} else {
		    	$mode = $pdd->{'mode'};
			}

        	# Numeric bounds ....
        	if ( $pdd->{'high'} =~ m/^\s*[+-]?\d+\s*$/o and
            	$pdd->{'low'} =~ m/^\s*[+-]?\d+\s*$/ ) {
		    	# Signal ...from high to low. Ignore everything not matching
		    	# this pattern (e.g. only one bound set ....)

        		if ( $pdd->{'high'} == $pdd->{'low'} ) {
            		if ( $pdd->{'high'} == 0 ) {
                		# Special case: single pin "bus" -> reduce to it ....
                		$logger->warn('__W_GET_IVHDL', "\tPort $p of entity $ename one bit wide, reduce to signal" );
                    		$pdd->{'type'} =~ s,_vector,,; # Try to strip away trailing vector!
                    		$pdd->{'low'} = undef;
                    		$pdd->{'high'} = undef;
                    		$port .= '%S%' x $indent2 . $p . '%S%: ' . $mode . '%S%' . $pdd->{'type'} .
                        	  	'; ' . 
                        	  	( $descr ? $descr : $tcom ) . " __I_AUTO_REDUCED_BUS2SIGNAL\n";
            		} else {
                		$logger->warn( '__W_GET_IVHDL', "\tPort $p of entity $ename one bit wide, missing lower bits\n" );
                     	$port .= '%S%' x $indent2 . $p . '%S%: ' . $mode . '%S%' . $pdd->{'type'} .
                        	  "(" . $pdd->{'high'} . "); " .
                        	  ( $descr ? $descr : $tcom ) . " __W_SINGLEBITBUS\n";
            		}
        		} elsif ( $pdd->{'high'} > $pdd->{'low'} ) {
            		$port .= '%S%' x $indent2 . $p . '%S%: ' . $mode . '%S%' . $pdd->{'type'} .
                 	 	'(' . $pdd->{'high'} . ' downto ' . $pdd->{'low'} . ');' .
                 	 	( $descr ? $descr : '' ) .
                 	 	"\n";
        		} else {
            		$port .= '%S%' x $indent2 . $p . '%S%: ' . $mode. '%S%' . $pdd->{'type'} .
                  	'(' . $pdd->{'high'} . ' to ' . $pdd->{'low'} . ');' .
                  	( $descr ? $descr : '' ) .
                  	"\n";
        		}
    		} else {
        		if ( $pdd->{'high'} eq $pdd->{'low'} ) {
                	# $pdd->{'type'} =~ s,_vector,,; # Try to strip away trailing vector!
                	$port .= '%S%' x $indent2 . $p . '%S%: ' . $mode . '%S%' . $pdd->{'type'} .
                    	'(' . $pdd->{'high'} . ');' . 
               	 	( $descr ? $descr : '' ) .
               	 	"\n";
                	#!wig20030812: adding support for non-numeric signal/port bounds
                } else {
                   	$port .= '%S%' x $indent2 . $p . '%S%: ' . $mode . '%S%' . $pdd->{'type'} .
                       	"(" . $pdd->{'high'} . " downto " . $pdd->{'low'} . ');' .
                     ( $descr ? $descr : '' ) .
                     "\n";
                }
            }
	    } else {
   			$port .= mix_wr_mapsort( $ename, $p ); # Put in sort criteria!	    
			my $mode = "";
			if ( $pdd->{'mode'} =~ m,^\s*C,io ) {
		   		$mode = "in";
			} else {
		   		$mode = $pdd->{'mode'};
			}
		   	$port .= '%S%' x $indent2 . $p . '%S%: ' . 
		   		$mode . '%S%' . $pdd->{'type'} . ';' .
		   		( $descr ? $descr : '' ) .
		   		"\n";
	    }
	    
	    #TODO: Check all case where only one of high or low is defined or high and/or
	    # low are not digit!
	}
	# Now split -> sort -> remove markers -> join and return:
	my $order = $eh->get( 'output.generate.portmapsort' );
	if ( $order =~ m/\bdebug\b/ ) {
		$order = 1;
	} else {
		$order = 0;
	}
	$port = join( "\n", map( { s/%MAPSORT(.+?)SORTMAP%//; $_ . 
				(( $order ) ? ( ' ' . $tcom . 'SORT: ' . $1 ) : ''); } 
				sort( split( /\n/, $port ) ) ) ) . "\n";
	$gent = join( "\n", map( { s/%MAPSORT(.+?)SORTMAP%//; $_ .
				(( $order ) ? ( ' ' . $tcom . 'SORT: ' . $1 ) : ''); } 
				sort( split( /\n/, $gent ) ) ) ) . "\n";
	$port = '' if ( $port =~ m/^(\s|%S%)*$/ );
	$gent = '' if ( $gent =~ m/^(\s|%S%)*$/ );

	return( $port, $gent );

} # End of _mix_wr_get_ivhdl

#
# return Verilog conform interface (list of ports ....)
#  borrows a lot from the vhdl code above :-)
#
# Input:
#	- reference to entity
#	- entity name
#	- language (verilog and/or verilog 2001
#	- comment valid (//)
#
# output:
# 	verilog portmap (string)
#	verilog generics defintion
#
# global:
#  reads $eh (output.generate.language.verilog)
#
#!wig20051007: support verilog2001
#!wig20060925: support insertion of emumux
sub _mix_wr_get_iveri ($$$$;$) {
    my $r_ent	= shift;
    my $ename	= shift; # Name of entity ...
    my $lang	= shift;
    my $tcom	= shift;
    my $indent	= shift || 2; # Default indent level

	my $indent2 = $indent + 1;
	# Verilog 2001 style output definitions ....
	my %flags = (
		'2001'		=> 0,
		'ansisytle'	=> 0,
		'iwire'		=> 1,
		'owire'		=> 1,
	);
	
	if ( $lang =~ m/2001/ or
		$eh->get( 'output.language.verilog' ) =~ m/\b2001\b/ ) {
		%flags = (
			'2001'		=> 1,
			'ansisytle'	=> 1,
			'iwire'		=> 0,
			'owire'		=> 0,
		);
	};
	
	for my $i ( qw( ansistyle iwire owire ) ) {
		if ( $eh->get( 'output.language.verilog' ) =~ m/\b$i\b/ ) {
			$flags{$i} = 1;
		} elsif ( $eh->get( 'output.language.verilog' ) =~ m/\bno$i\b/ ) {
			$flags{$i} = 0;
		}
	}
	
	#!wig: do not print "wire" if ansistyle
	if ( $flags{'ansistyle'} ) {
		$flags{'iwire'} = 0;
		$flags{'owire'} = 0;
	}
	
    # Possible Verilog modes. Please extend %ioky, %port and %portheader
    my %ioky = (
        'in'	=> 'input',
        'out'	=> 'output',
        'io'	=> 'inout',
        'inout'	=> 'inout', 
        'not_valid' => '__W_INVALID_PORT',
        'parameter' => 'parameter',
    );

    my $gent = '';
    my $intf = '';
    my %port = (
        'out'	=> '',
        'in'	=> '',
        'io'	=> '',
        'inout'	=> '',
        'not_valid' => '',
        'wire'	=> '',
        'parameter' => '',
    );
    my @portorder = qw( parameter in io inout out wire not_valid );
    my %portheader = (
        'out'   => '%S%' x $indent . $tcom . " Generated Module Outputs:\n",
        'in'    => '%S%' x $indent . $tcom . " Generated Module Inputs:\n",
        'io'    => '%S%' x $indent . $tcom . " Generated Module In/Outputs:\n",
        'inout'    => '%S%' x $indent . $tcom . " Generated Module In/Outputs:\n",
        'not_valid' => '%S%' x $indent . $tcom . " __W_NOT_VALID Module In/Outputs:\n",
        'wire'  => '%S%' x $indent . $tcom . " Generated Wires:\n",
        'parameter' => '%S%' x $indent . $tcom . " Module parameters:\n",
    );

	my $portsort = ''; #Contains value if non-default port order is requested

	# Iterate over all ports at that entity:	
    for my $p ( sort ( keys( %{$r_ent} ) ) ) {
	    next if ( $p =~ m,^__,o ); #Skip internal data ...
        next if ( $p =~ m,^-- NO, );

		$portsort = mix_wr_mapsort( $ename, $p ); # Put in sort criteria!

		# Should that be a reg or a wire?
		# Default is wire
		my $reg_wire = _mix_wr_regorwire( $ename, $p );
		my $pdd = $r_ent->{$p};

	    #!wig20051010: adding description ...
	    #!wig20051010: Add descriptions to port map:
	    my $descr = '';
	    if ( $pdd->{'__descr__'} ne '' ) {
	    	# Prevent problems with mulitline comments:
	    	( my $d = $pdd->{'__descr__'} ) =~ s/\n/%CR%%S%%S%%S%%S%$tcom /g; 
	    	$descr = '%S%' . $tcom . ' ' . $d;
	    }
	    
	    if ( $pdd->{'mode'} =~ m,^\s*(generic|G|P),io ) {
			if ( exists( $pdd->{'value'} ) ) {
                #Generic, with default value from conndb ...
                # TODO : is here also ansistyle?
                $port{'parameter'} .= $portsort . '%S%' x $indent2 . $ioky{'parameter'} .
                	' ' . $p . ' = ' . $pdd->{'value'} . ";\n";
			} else {
                $port{'parameter'} .= $portsort . '%S%' x $indent2 . $ioky{'parameter'} .
                	' ' . $p . '; ' . $tcom . " = __W_NODEFAULT;\n";
			}
        } elsif (	defined( $pdd->{'high'} ) and
			defined( $pdd->{'low'} ) and
                     $pdd->{'high'} !~ m,^\s*$,o and
                     $pdd->{'low'} !~ m,^\s*$,o ) {
			# Signal ...from high to low. Ignore everything not matching
			# this pattern (e.g. only one bound set ....)
			my $mode = '';
			if ( $pdd->{'mode'} =~ m,^\s*C,io ) {
		    	$mode = 'in';
			} else {
		    	$mode = $pdd->{'mode'};
			}
            my $valid = '';
            unless( exists( $ioky{$mode} ) ) {
                $valid = $tcom . '__I_PORT_NOT_VALID%S%';
                $mode  = 'not_valid';
            }

			# Numeric bounds:
			if ( $pdd->{'high'} =~ m/^\s*[+-]?\d+\s*$/o and
                 $pdd->{'low'} =~ m/^\s*[+-]?\d+\s*$/o ) {
                if ( $pdd->{'high'} == $pdd->{'low'} ) {
                    if ( $pdd->{'high'} == 0 ) {
                        # Special case: single pin "bus" -> reduce it ....
                        $logger->warn('__W_GET_IVERI', "\tPort $p of entity $ename one bit wide, reduce to signal\n" );
                        $pdd->{'type'} =~ s,_vector,,; # Try to strip away trailing vector!
                        $pdd->{'low'} = undef;
                        $pdd->{'high'} = undef;

						if ( $flags{'ansistyle'} ) {
							#!wig20051010
                        	$intf .= $portsort . '%S%' x $indent2 . $valid . $ioky{$mode} .
                        		'%S%' . $reg_wire . '%S%' x 2 . $p . "," . '%S%' .
                        		( $descr ? $descr : $tcom ) .
                        		" __I_AUTO_REDUCED_BUS2SIGNAL\n";
						} else {	
							# Add to interface						
                        	$intf .= $portsort . '%S%' x $indent2 . $valid . $p . ',' .
      						( $descr ? $descr : '' ) .
                        	"\n";
                        	# Add to portlist
                        	$port{$mode} .= $portsort . '%S%' x $indent2 . $valid .
                        			$ioky{$mode} . '%S%' x 2 . $p . ';' .
                            		'%S%' . $tcom . " __I_AUTO_REDUCED_BUS2SIGNAL\n";
						}
						#!wig: iwire??
						if ( $flags{'owire'} ) {
                        	$port{'wire'} .= $portsort . '%S%' x $indent2 . $valid .
                        		$reg_wire . '%S%' x 2
                        		. $p . ';%S%' . $tcom . " __I_AUTO_REDUCED_BUS2SIGNAL\n";
						}
                    } else {
                        $logger->warn( '__W_GET_IVERI', "\tPort $p of entity $ename one bit wide, missing lower bits\n" );
                        if ( $flags{'ansistyle'} ) {
                        	$intf .=
                        		$portsort . '%S%' x $indent2 . $valid . $ioky{$mode} .
                        		'%S%' . $reg_wire .
                        		'%S%[' . $pdd->{'high'} . ']%S%' . $p .
                                ',' .
                                ( $descr ? $descr : $tcom ) .
                                " __W_SINGLEBITBUS\n";
                        } else {
                        	$intf .= $portsort . '%S%' x $indent2 . $valid . $p . ',' .
                        			( $descr ? $descr : '' ) .
                        	 		"\n";
                        	$port{$mode} .=
                        		$portsort . '%S%' x $indent2 . $valid . $ioky{$mode} .
                        		'%S%[' . $pdd->{'high'} . ']%S%' . $p .
                                ";\t$tcom __W_SINGLEBITBUS\n";
                        }
                        if ( $flags{'owire'} ) {
                        	$port{'wire'} .=
                        		$portsort . '%S%' x $indent2 . $valid . $reg_wire .
                        		'%S%[' . $pdd->{'high'} . ']%S%' . $p .
                                ";\t$tcom __W_SINGLEBITBUS\n";
                        }
                    }
                } elsif ( $pdd->{'high'} > $pdd->{'low'} ) {
                	if ( $flags{'ansistyle'} ) {
                    	$intf .= 
                    		$portsort . '%S%' x $indent2 . $valid .
                     		$ioky{$mode} . '%S%' . $reg_wire . 
                     		'%S%[' . $pdd->{'high'} . ':' . $pdd->{'low'} . ']%S%' . $p . ',' .
                        	( $descr ? $descr : '' ) .
                        	"\n";
                	} else {
                    	$intf .= $portsort . '%S%' x $indent2 . $valid . $p . "," . 
                    	( $descr ? $descr : '' ) .
                    	"\n";
                    	$port{$mode} .= $portsort . '%S%' x $indent2 . $valid . $ioky{$mode} . "\t[" .
                                $pdd->{'high'} . ':' . $pdd->{'low'} . "]\t" . $p . ";\n";
                	}
                	if ( $flags{'owire'} ) {
                    	$port{'wire'} .= $portsort . '%S%' x $indent2 . $valid . $reg_wire . 
                    		'%S%[' . $pdd->{'high'} . ':' . $pdd->{'low'} . "]\t" . $p . ";\n";
                	}
                } else {
                    # TODO : Check if Verilog allows this ...
                    #Couple warning on check flag for design guide line "downto busses"
                    $logger->warn('__W_GET_IVERI', "\tPort $p, entity $ename, high bound < low bound!" );
                    if ( $flags{'ansistyle'} ) {
                    	$intf .= $portsort . '%S%' x $indent2 . $valid .
                    	$ioky{$mode} . '%S%' . $reg_wire . 
                    	'%S%[' . $pdd->{'high'} . ':' . $pdd->{'low'} . ']%S%' .
                    	$p . ',' .
						( $descr ? $descr : '' ) .
                        "\n";
                    } else {
                    	$intf .= $portsort . '%S%' x $indent2 . $valid . $p . ',' .
                    	( $descr ? $descr : '' ) .
                    	 "\n";
                    	$port{$mode} .= $portsort . '%S%' x $indent2 . $valid . $ioky{$mode} . 
                    		'%S%[' . $pdd->{'high'} . ':' . $pdd->{'low'} . ']%S%' . $p . ";\n";
                    }
                    if ( $flags{'owire'} ) {
                    	$port{'wire'} .= $portsort . '%S%' x $indent2 . $valid . $reg_wire .
                    		'%S%[' . $pdd->{'high'} . ':' . $pdd->{'low'} . ']%S%' . $p . ";\n";
                    }
                }
			} else {
                #New 20061030a: find `define - %TICK_DEFINE_define : 0
                if ( $pdd->{'high'} =~ m/^`(\w+)\s*-\s*%TICK_DEFINE_\1%/
                	 and $pdd->{'low'} eq '0' ) {
                	      	# high == low or low is defined by a `foo                	
                	if ( $flags{'ansistyle'} ) {
                    	$intf .= $portsort . '%S%' x $indent2 . $valid .
                    		$ioky{$mode} . '%S%' . $reg_wire .
                    		'%S%[' . '`' . $1 . ']%S%' . $p . ',' .
                            ( $descr ? $descr : '' ) .
                            "\n";
                	} else {
                    	$intf .= $portsort . '%S%' x $indent2 . $valid . $p . ',' .
                    	( $descr ? $descr : '' ) .
                    	"\n";
                    	$port{$mode} .= $portsort . '%S%' x $indent2 . $valid . $ioky{$mode} .
                    		'%S%[' . '`' . $1 . ']%S%' . $p . ";\n";
                	}
					if ( $flags{'owire'} ) {
                    	$port{'wire'} .= $portsort . '%S%' x $indent2 . $valid . $reg_wire . 
                    		'%S%[' . '`' . $1 . ']%S%' . $p . ";\n";
                	}
                # Non numeric bounds (non-numeric or lower bound is a TICK_DEFINE)
                } elsif ( $pdd->{'high'} eq $pdd->{'low'} or
                	 $pdd->{'low'} =~ m/^%TICK_DEFINE_/ ) {
                	# high == low or low is defined by a `foo                	
                	if ( $flags{'ansistyle'} ) {
                    	$intf .= $portsort . '%S%' x $indent2 . $valid .
                    		$ioky{$mode} . '%S%' . $reg_wire .
                    		'%S%[' . $pdd->{'high'} . ']%S%' . $p . ',' .
                            ( $descr ? $descr : '' ) .
                            "\n";
                	} else {
                    	$intf .= $portsort . '%S%' x $indent2 . $valid . $p . ',' .
                    	( $descr ? $descr : '' ) .
                    	"\n";
                    	$port{$mode} .= $portsort . '%S%' x $indent2 . $valid . $ioky{$mode} .
                    		'%S%[' . $pdd->{'high'} . ']%S%' . $p . ";\n";
                	}
					if ( $flags{'owire'} ) {
                    	$port{'wire'} .= $portsort . '%S%' x $indent2 . $valid . $reg_wire . 
                    		'%S%[' . $pdd->{'high'} . ']%S%' . $p . ";\n";
                	}
                } else {
                	if ( $flags{'ansistyle'} ) {
                    	$intf .= $portsort . '%S%' x $indent2 . $valid .
                    		$ioky{$mode} . '%S%' . $reg_wire .
                    			'%S%[' . $pdd->{'high'} . ':' . $pdd->{'low'} . ']%S%' .
                    			$p . ',' .
                         	( $descr ? $descr : '' ) .
                         	"\n";
                	} else {
                    	$intf .= $portsort . '%S%' x $indent2 . $valid . $p . ',' .
                   		( $descr ? $descr : '' ) .
                    	"\n";
                    	$port{$mode} .= $portsort . '%S%' x $indent2 . $valid . $ioky{$mode} . 
                    		'%S%[' . $pdd->{'high'} . ':' . $pdd->{'low'} . ']%S%' .
                    		$p . ";\n";
                	}
                	if ( $flags{'owire'} ) {
                    	$port{'wire'} .= $portsort . '%S%' x $indent2 . $valid . $reg_wire . 
                    		'%S%[' . $pdd->{'high'} . ':' . $pdd->{'low'} . ']%S%' . $p . ";\n";
                	}
                }
			}
        } else {
			my $mode = '';
			if ( $pdd->{'mode'} =~ m,^\s*C,io ) {
		    	$mode = 'in';
			} else {
		    	$mode = $pdd->{'mode'};
			}
            my $valid = '';
            unless( exists( $ioky{$mode} ) ) {
                $valid = $tcom . ' __I_PORT_NOT_VALID ';
                $mode = 'not_valid';
            }
            if ( $flags{'ansistyle'} ) {
            	$intf .= $portsort . '%S%' x $indent2 . $valid . $ioky{$mode} .
            		'%S%' . $reg_wire .
                	'%S%' x 2 . $p . ',' .
                	( $descr ? $descr : '' ) .
                	"\n";
            } else {
            	$intf .= $portsort . '%S%' x $indent2 . $valid . $p . ',' .
            		( $descr ? $descr : '' ) .
            		"\n";
            	$port{$mode} .= $portsort . '%S%' x $indent2 . $valid . $ioky{$mode} .
                	'%S%' x 2 . $p . ";\n";
            }
            if ( $flags{'owire'} ) {
            	$port{'wire'} .= $portsort . '%S%' x $indent2 . $valid . $reg_wire .
                '%S%' x 2 . $p . ";\n";
            }
	    }
    }
    # Finalize intf: add all inputs, outputs and inouts ....
    my $order = $eh->get( 'output.generate.portmapsort' );
	if ( $order =~ m/\bdebug\b/ ) {
		$order = 1;
	} else {
		$order = 0;
	}
	if ( $portsort ) {
		$intf = join( "\n", map( { s/%MAPSORT(.+?)SORTMAP%//; $_ .
				(( $order ) ? ( ' ' . $tcom .'SORT:' . $1 ) : ''); }
			sort( split( /\n/, $intf ) ) ) ) . "\n";
		$intf = '' if ( $intf =~ m/^\s*$/o );
		for my $i ( keys %port ) {
			$port{$i} = join( "\n", map( { s/%MAPSORT(.+?)SORTMAP%//; $_ .
				(( $order ) ? ( ' ' . $tcom .'SORT:' . $1 ) : ''); }
				sort( split( /\n/, $port{$i} ) ) ) ) . "\n";
			$port{$i} = '' if ( $port{$i} =~ m/^\s*$/o );
		}
	}
	
	# Prepend  begin now:
	$intf = '%S%' x $indent . "(\n" . $intf;
	$intf =~ s/,((%S%|\t)+$tcom[^\n]*)$/$1/i;
    $intf =~ s/,(\s*)$/$1/i; # Remove trailing , in port map ...
    $intf .= '%S%' x $indent . ");\n";
    #!wig20060413: adding another HOOK for poersch
    $intf .= "%VERILOG_HOOK_PARA%\n";
    # Print out inputs, outputs, inouts and wires ...
    for my $i ( @portorder ) {
       	if ( $port{$i} ) {
           	$intf .= $portheader{$i};
           	$intf .= $port{$i};
       	}
    }
    return( $intf, $gent );
} # End of _mix_wr_get_iveri

#
# Decide if that prot requires a reg or a wire
#
# Input:
#	Entity name
#	Port name
#
# Output:
#	"reg" or "wire"
#
# Globals:
#	%entities
#	%conndb
#	$eh
#
#!wig20051015
sub _mix_wr_regorwire($$) {
	my $entity	= shift;
	my $port	= shift;

	my $rw = "wire";

	
	my $leafflag =  _mix_wr_isleaf( $entity ) ? 'leaf' : 'hier';
	my ( $iomode )	 = _mix_wr_is_modegennr( $entity, $port ); # Dump gener

	# TODO : What about other modes like buffer, tristate, ...?
	my $io = 'i';
	if ( $iomode =~ m/^out$/io ) {
		$io = 'o';
	}

	# Check the global settings:
	if ( $eh->get( 'output.language.verilog' ) =~ m/\b(no)?($leafflag)($io)(reg|wire)\b/ ) {
		# <no>leaf[io]<reg|wire>
		# <no>hier[io]<reg|wire>
		# only usefull: leaforeg!
		if ( defined( $1 ) ) {
			# "no" -> nothing
			$rw = '';
		} else {
			$rw = $4;
		} 
	}
	
	# Check instance/entity specific settings
	#	e.g. ::lang = verilog,%REG%
	# Thorsten thinks that wire or reg shold not be controlled
	# by the instance, but i had already implemented this switch ... ;-) 
	my $lang = $entities{$entity}{'__LANG__'};
	if ( $lang =~ m/\b(reg|wire)/io ) {
		$rw = $1;
	}
	
	# Check port specific settings
	# Logic: if the signal type (actually inherited by the
	#   port type) field has a %REG% or a %WIRE% and
	# - the mode is out and
	# - the entity is leaf -> buy it
	if ( $leafflag eq 'leaf' and
		 $io eq 'o' and
		 $entities{$entity}{$port}{'type'} =~ m/(__|%)(REG|WIRE)(__|%)/io ) {
				$rw = lc( $2 );
	}

	#!wig20051024: the above methods do not allow fine control
	if ( exists( $entities{$entity}{$port}{'rorw'} ) and
			$entities{$entity}{$port}{'rorw'} ) {
		$rw = $entities{$entity}{$port}{'rorw'};
	}
	return $rw;

} # End of _mix_wr_regorwire

#
# Input: entity name
#
# Return 1 if this is a leaf
# 		 0 if this is non-leaf
#		-1 in case of error
#
#	available for entities now
#	should be entitiy object!
#   !! __LEAF__ counter >= 1 --> no leaf
#!wig20051021
sub _mix_wr_isleaf ($) {
	my $entity = shift;

	if ( exists $entities{$entity} ) {
		if ( $entities{$entity}{'__LEAF__'} < 1 ) {
			return 1;
		} else {
				return 0;
		}
	} else {
		return -1;
	}
}

####################################################################
## write_architecture
## write architecture VHDL files
####################################################################

=head2

write_architecture () {

Write architecture into output file(s).

=cut

sub write_architecture () {

    # Set up architecture template;
    tmpl_arch();

    # open output file
    my %seen = ();
    my $efname = $eh->get( 'outarch' );
    if ( $efname =~m/^(ARCH|COMB)/o ) {
        my $archext = $eh->get( 'postfix.POSTFILE_ARCH' );
        if ( $1 eq "COMB" ) {
            $archext = "";
        }
		# Write each architecture in a file of it's own
		for my $i ( sort( keys( %hierdb ) ) ) {
			# Skip it if it was seen before
			# TODO : sort be order of hierachy
			# TODO : will that be unique?
			my $e = $hierdb{$i}{'::entity'};

	    	# Should we print it? if the noleaf flag ist set, skip
			next if ( $e eq "W_NO_ENTITY" );
            next if ( $e =~ m/TYPECAST_/io );
            
			if ( $eh->get( 'output.generate.arch' ) =~ m,noleaf,io and
		    		not $hierdb{$i}{'::treeobj'}->daughters ) {
		    	next;
			}

			# Skip HDL/arch out if this file name matches the given filter reg-exp.		
		    if ( $eh->get( 'output.filter.file' ) ) {
		    	my $filter = _mix_wr_getfilter( 'arch', $eh->get( 'output.filter.file' ) );
		    	if ( $i =~ m/$filter/ ) {
		               $logger->warn('__W_WR_ARCH', "\tSkipped writing of architecture $e (inst: $i) due to filter" );    		
		               next;
		    	}
		    }
            # Prepare for an alternate filename (if entity got instantiated multiple times)
            my $alt = '';
			if ( exists( $seen{$e} ) ) {
                next unless ( $eh->get( 'output.generate.arch' ) =~ m,\balt,io );
                $alt = "-alt" . $seen{$e}++;
                $logger->info('__I_WR_ARCH', "\tWriting another architecture for $e (inst: $i)" );
			}
			$seen{$e}++;
            # Generate an output filename
            my $filename;
            my $e_fn = $e;
            #Changed 20030714a/Bug: replace - by _ ...
            $e_fn =~ s,_,-,go if ( $eh->get( 'output.filename' ) =~ m,\ballminus, );
            # replace _ by - in entity names.
            # In combine mode, choose entity.vhd as filename.
            # Filename extension defaults to VHDL

            # Language? vhdl, verilog or what else?
            my $lang = lc( $hierdb{$i}{'::lang'} ) || $eh->get( 'macro.%LANGUAGE%' );
            unless ( $eh->get( 'template.' . $lang ) ) {
                $logger->warn( '__W_WR_ARCH', "\tIllegal language $lang selected. Autoswitch to " .
                	$eh->get( 'macro.%LANGUAGE%' ) . '!' );
                $lang = $eh->get( 'macro.%LANGUAGE%' );
            }

            if ( $lang =~ m,^veri,io ) {
                # verilog filename:
                $filename = $e_fn . '.' . $eh->get( 'output.ext.' . $lang ) . $alt;    
            } elsif ( $efname =~ m/^COMB/o ) {
                # Combined output
                $filename = $e_fn . '.' . $eh->get( 'output.ext.' . $lang ) . $alt;
            } elsif ( $hierdb{$i}{'::arch'} ) {
                $filename = $e_fn . '-' . $hierdb{$i}{'::arch'} .
                        $archext . '.' .
                        $eh->get( 'output.ext.' . $lang ) . $alt;
            } else {
                $filename = $e_fn . $archext . '.'
                       . $eh->get( 'output.ext.' . $lang ) . $alt;
            }
            _write_architecture( $i, $e, $filename, \%hierdb );
		}
    } else {
		_write_architecture( "__COMMON__", "__COMMON__", $efname, \%hierdb );
    }
    return;
} # End of write_architecture

#
# Convert hierdb names to macros ala %::tag%
# Omitt all non-scalar values
# see replace_mac and parse_mac for similiar things
#
sub mix_wr_hier2mac ($) {
    my $rhdb = shift;

    my %mac = ();
    for my $i ( keys( %$rhdb ) ) {
        if ( ref( $rhdb->{$i} ) eq "" ) {
            $mac{'%' . $i . '%' } = $rhdb->{$i};
        }
    }

    return \%mac;
}
    
####################################################################
## gen_instmap
## generate an instance map 
####################################################################

=head2

gen_instmap ($$$) {

Return an port map for the instance and a list of in and out signals

Input:
    instancename (instantiated component)
    language (default: $eh->get( 'macro.%LANGUAGE%' ) aka. VHDL)
    comment (default to comment string of language or ##)

=cut

sub gen_instmap ($;$$) {
    my $inst = shift;
    my $lang = shift || lc( $eh->get( 'macro.%LANGUAGE%' ) ); # Language of interface to generate ...
    my $tcom = shift || $eh->get( 'output.comment.' . $lang ) ||
    	$eh->get( 'output.comment.default' );

    my $map = '';
    my $gmap = '';
    my $dummies = []; # Reference to dummy signals needed to open ports(splices)
    my %expanded = (); # Reference to HASH holding HIGH/LOW signals expandede in mix_wr_unsplice_port

    my @in = ();
    my @out = ();
    my $enty = $hierdb{$inst}{'::entity'};

    #
    # Iterate through all signals attached to that instance:
    #
    my $rinstc = $hierdb{$inst}{'::conn'};
 	my $simple_flag=0;
 	my $simple_re = $eh->get( 'output.generate._logicre_' );
 	#!wig20050414: implement simple logic, simple start-up
 	if ( $enty =~ m/$simple_re/i ) {
 		# $gmap gets the output, $map the input(s)
 		( $gmap, $map ) = port_simple( 'outin', $inst, $enty, $lang,
 			$rinstc->{'out'}, $rinstc->{'in'}, \@out, \@in );
 		$simple_flag=1;
 	} else {	 
    	$map .= port_map( 'in', $inst, $enty, $lang, $rinstc->{'in'}, \@in );
  
    	if ( exists( $rinstc->{'generic'} ) ) {
        	$gmap .= generic_map( 'in', $inst, $enty, $rinstc->{'generic'}, $lang, $tcom );
    	}

    	$map .= port_map( 'out', $inst, $enty, $lang, $rinstc->{'out'}, \@out );
 	}

    # Generate signal assignement for typecast functions ...
	#  %TYPECAST% is a pseudo instance!
    if ( $inst =~ m/^(__|%)TYPECAST_/io ) {
        # Read $hierdb{$inst}{'::typecast'}  -> SIGNAME, TYPECAST, INTNAME
        my ( $orgsig, $tcf, $intsig ) = @{$hierdb{$inst}{'::typecast'}}; 
	    $map = '%S%' x 2 . $orgsig . ' <= ' . $tcf . '( ' . $intsig . ' ) '
            . '; ' . $tcom . " __I_TYPECAST\n";
    } else {
        # Sort map ...
        $map = join( "\n", sort( split ( /\n/, $map ) ) ) . "\n" unless $simple_flag;

        #wig20030808: Adding Verilog port splice collector .. for mpallas
        # TODO : Shouldn't that be integrated into the print_conn_matrix function?
        if ( $lang =~ m,^veri,io and $map =~ m,\]\(, ) {
            # Get a better map and a list of dummy signals (if needed for open port splices)
            # Will add dummies to out signals ...
            my $e = ();
            ($map, $dummies, $e) = mix_wr_unsplice_port( $map, $lang, $tcom );
          	for ( keys %$e ) {
          		$expanded{$_} = 1;
          	}
        }

        # Quick hack: Get rid of possible %EMPTY%, which prevents end-of-map detection ...
        my $empty = $eh->get( 'macro.%EMPTY%' );
        my $space = $eh->get( 'macro.%S%' );
        $map =~ s/%EMPTY%/$empty/g; # Get rid of %EMPTY% ....
        $map =~ s/%S%/$space/g;
        $gmap =~ s/%EMPTY%/$empty/g; 
        $gmap =~ s/%S%/$space/g;
        
        # Remove trailing "," and such (VHDL) and also for Verilog ...    
        $map =~ s/,(\s*$tcom.*)\n?$/$1\n/;
        $map =~ s/,\s*\n?$/\n/; 
        $gmap =~ s/,(\s*$tcom.*)\n?$/$1\n/;
        $gmap =~ s/,\s*\n?$/\n/;

        # Create VHDL generic map frame
        unless( is_vhdl_comment( $gmap ) or $simple_flag or $lang =~ m,^veri,io ) {
            $gmap = '%S%' x 2 . "generic map (\n" . $gmap .
                '%S%' x 2 .")\n"; # Remove empty definitons
        }

        # Create VHDL port map frame
        unless( is_vhdl_comment( $map ) or $simple_flag or $lang =~ m,^veri,io ) {    
            $map = '%S%' x 2 . "port map (\n" . $map .
                '%S%' x 2 . ");\n";
        } else {
        	if ( $lang !~ m,^veri,io ) {
        		if ( $simple_flag ) {
        			$map .= ";\n";
        		} else {
                	$map .= '%S%' x 2 . ";\n"; # Get a trailing ;
        		}
            }
        }

        if ( $lang =~ m,^veri,io ) {
            #!wig20031107: Add dummy signals here (temp.)
            my $dum = '';
            if ( scalar( @$dummies ) ) {
                $dum = join( "\n", map(
                    ( '%S%' x 2 .  $_ ),
                    @$dummies
                )) . "\n";
            }

			#
            # Parent language is verilog -> Different parameter hand-over!
            # format gets prepared in generic_map
            #    enty #(param) inst (port)
            #
            my $hashm = ' ';
            if  ( $hierdb{$inst}{'::lang'} =~ m,\bvhdl,io or
            	  $eh->get( 'output.language.verilog' ) =~ m/\b2001param/io ) {
                # Special case: daughter is VHDL-> use config name instead of entity name ...
                # see 20040209/a req
                # The "useconfname" option applies globally, while setting %UAMN% in the
                #  ::config column works for each module individually

                if ( $eh->get( 'output.generate.verilog' ) =~ m,useconfname,i or
                     defined( $hierdb{$inst}{'::workaround'} ) and
                     $hierdb{$inst}{'::workaround'} =~ m,(uamn|useasmodulename),i ) {  
                    $enty = $hierdb{$inst}{'::config'} || $enty;
                    # As this can create problems with certain tools (Magma), use 'define
                    if ( $eh->get( 'output.generate.workaround.magma' ) =~ m,useasmodulename_define,io ) {
                        my $tm = mix_wr_hier2mac( $hierdb{$inst} );
                        # Keep the `define in this global variable. This is ugly, but today
                        #  the easiest way.
                        $eh->append( 'output.generate.workaround._magma_uamn_' ,
                            replace_mac( $eh->get( 'output.generate.workaround._magma_def_' ), $tm  ) );
                        $enty = replace_mac( $eh->get( 'output.generate.workaround._magma_mod_' ), $tm );
                    }
                }
                $hashm = $gmap || ' '; #If gmap is empty -> do not replace hashm
                $gmap = '';            
            }
            
            if ( $simple_flag ) {
            	$map = '%S%' x 2 . $tcom . " Generated Logic for $inst\n" .
            		$dum .
            		$gmap .
            		$map .
            		'%S%' x 2 . $tcom . " End of Generated Logic for $inst\n";
            } else {
            	$map = '%S%' x 2 . $tcom . " Generated Instance Port Map for $inst\n" .
                    $dum .
                    '%S%' x 2 . $enty . $hashm . $inst . " (" .
                    _mix_wr_descr( 'hier', $inst, $hierdb{$inst}{'::descr'}, 4, $tcom ) .
                    "\n" .
                    $map .
                    '%S%' x 2 . ");\n" .
                    $gmap .
                    '%S%' x 2 . $tcom . " End of Generated Instance Port Map for $inst\n";

            }
        } else {
           	# Verilog or VHDL, but no dummies?
           	if ( $simple_flag ) {
           	       	$map = '%S%' x 2 . $tcom . " Generated Logic for $inst\n" .
           	       	$gmap .
            		$map .
            		"\n" . '%S%' x 2 . $tcom . " End of Generated Logic for $inst\n";
            } else {
            	$map =  '%S%' x 2 . $tcom . " Generated Instance Port Map for $inst\n" .
                   '%S%' x 2 . $inst . ": " . $enty .
                   _mix_wr_descr( 'hier', $inst, $hierdb{$inst}{'::descr'}, 4, $tcom ) .
                    "\n" .
                    $gmap .
                    $map .
                    "\n" . '%S%' x 2 . $tcom . " End of Generated Instance Port Map for $inst\n";
           	}
        }
    }
    
    #!wig20060411: wrap verilog module into ifdef ....
    if ( $lang =~ m,^veri,io and $eh->get( 'output.generate.verimap.modules' ) ) {
    	$map = _mix_wr_map_veri( $inst, $map, \@in, \@out, $tcom );
    }
    
    #!wig20060522: remove internally expanded signals (e.g. unsplice port)
    if ( scalar( keys %expanded ) ) {
    	my @i = @in;
    	@in = ();
    	for my $i ( @i ) {
    		push( @in, $i ) unless( exists( $expanded{$i} ));
    	}
    }
    
    return( $map, \@in, \@out);
} # End of gen_instmap


#
# wrap a verilog module header in
#
#   `ifdef exclude_module_1
#		assign sig_1 = 1'b0;
#		...
#	`else
#		<real port map>
#	`endif
#
# Globals:	$eh
#
# TODO: Handle partial port assignments
#       Sort order for signal list
sub _mix_wr_map_veri ($$$$$) {
	my $inst = shift;
	my $map  = shift;
	my $inr  = shift;
	my $outr = shift;
	my $tcom = shift;

	my $vm = $eh->get( 'output.generate.verimap' );
	
	# Will module be mapped? vm->{modules} has comma seperated list of perl re
	my $match = 0;
	for my $re ( split( /[,\s]+/, $vm->{'modules'} ) ) {
		if ( $inst =~ m/^$re$/ ) {
			$match = 1;
			last;
		}
		if ( $re =~ m/^all$/io ) {
			$match = 1;
			last;
		}
	}

	# No match -> no wrap	
	return $map unless $match;
	
	# Needs wrap ...
	my $wmap = '`ifdef ' . $vm->{'select'} . "\n";
	
	# Iterate over all in and out signals
	for my $i ( @$inr ) {
		$wmap .= '%S%' x 3 . $tcom . ' assign ' .
			$i . " = open;\n";
	}

	for my $o ( @$outr ) {
		# Get signal value (generic format)
		my $force = _mix_wr_getmapval( $inst, $o, $vm->{'sigvalue'} ); 
		my $connect = $hierdb{$inst}{'::sigbits'}{$o}; # Width, usually A:::<d>
		my $width = 1;

		unless( defined( $connect ) ) {
			$logger->error( '__E_MAPVERI', "\tMissing connection matrix for signal $o at instance $inst!" );
			next;
		}
		# TODO : Handle multiple connections ....
		if ( scalar( @$connect ) > 1 ) {
			$logger->error( '__E_MAPVERI', "\tCannot handle multiple connections for signal $o at instance $inst!" );
		}
		if ( $connect->[0] =~ m/^A::/ ) {
			$width = 1;

			if ( $conndb{$o}{'::high'} =~ m/^(\d+)$/ and
				 $conndb{$o}{'::low'} =~ m/^(\d+)$/ ) { 
				$width = $conndb{$o}{'::high'} - $conndb{$o}{'::low'} + 1;
			}
		} else {
			$logger->error( '__E_MAPVERI', "\tCannot handle partial port assignment for signal $o at instance $inst!" );
		}		
		my $vval = $force;
		# Expand key to appropriate format:
		#	0 -> <w>'b0
		#	1 -> <w>'b1111
		#
		if ( $force eq '0' or $force eq '1' ) {
			$vval = $width . "'b" . $force x $width;
		}


		$wmap .= '%S%' x 3 . "assign " .
			$o . " = " . $vval . ";\n";		
	}

	
	$wmap .= "`else\n" . $map . "`endif\n";
	
	# Evaluate some macros: %::inst%
	$wmap =~ s/%::inst%/$inst/g;
	
	return $wmap;

} # End of _mix_wr_map_veri


#
# Get default value for verilog exclude map
#		Possible values for the valuemap are:
#		INSTANCE_RE/SIGNAL_RE=VAL
#		SIGNAL_RE=VAL
#		VAL
#  Caveat: apecify signal names, not port names!
#
sub _mix_wr_getmapval ($$$) {
	my $inst   = shift;
	my $signal = shift;
	my $valmap = shift;
	
	my $force = ''; # Default
	for my $sv ( split( /[,\s]+/, $valmap ) ) {
		#  inst_re/signal_re=val
		if ( $sv =~ m,(.+)/(.+)=(.+), ) {
			my $inre = $1;
			my $snre = $2;
			my $snvl = $3;
			if ( $inst =~ m/^$inre$/ and $signal =~ m/^$snre$/ ) {
				$force = $snvl;
				last;
			}
			next;
		}
		# Value is s.th. like RE=VAL
		if ( $sv =~ m/(.+)=(.+)/ ) {
			my $snre = $1;
			my $snvl = $2;
			if ( $signal =~ m/^$snre$/ ) {
				$force = $snvl;
				last;
			}
			next;
		}
		$force = $sv;
		last;
	}
	
	# Using  '0' as default:
	if ( $force eq '' ) {
		$force = 0;
	}
	return $force;
} # End of _mix_wr_getmapval

=head2 _mix_wr_descr

#
# Print out the description
#  Description is shortened to portdescrlength chars (+- some extras
#    for later replacement) and \n is converted to %S%<comment>%CR% here to
#    keep comments near the line for portsort
#
# Input:
#	mode (hier, conn, ....; unused now)
#   obj  (name of object)
#	descr (text e.g. from ::descr)
# 	indent	number of indents (tabs to prepend before line breaks)
#	comm	current comment symbol
#
# Output:
#	text to be printed as description
#
# Global: -
#

=cut

sub _mix_wr_descr ($$$$$) {
	my $mode	= shift;
	my $obj		= shift;
	my $descr 	= shift;
	my $indent	= shift;
	my $comm	= shift;
	
	my $pre  = $eh->get( 'output.generate.portdescrindent' ) . $comm . ' ';
	#OLD: '%S%' x $indent . $comm . ' ';
	if ( defined $descr and $descr ne '' ) {
		$descr =~ s/\n/$pre/g;
		$descr = '%S%' . $comm . ' ' . $descr;
	} else {
		$descr = '';
	}
		
	return _mix_wr_shortendescr($descr, $pre);
	
} # End of _mix_wr_descr

#
# Try to collect spliced ports like
#   .port[N:M]( some )
#   .port[K](more )
#  -> .port( more & some )
# TODO : Resolve that and be more clever with writing the map instead
# of doing it backwards ...
#
# Currently only works for Verilog ...
#!wig20060522: return list of here expanded HIGH/LOW signals
my $dummynr = 0; # Count dummy ports ....
sub mix_wr_unsplice_port ($$$) {
    my $map = shift;
    my $lang = shift;
    my $tcom = shift;

    my @out = ();
    my %col = ();
    my %l = (); # Last line for port
    my @dummies = ();
    my %expanded = (); # Hold expanded HIGH/LOW busses
    # Read in spliced port maps ...
    for my $l ( split( "\n", $map ) ) {
    	next if $l =~ m/^\s*$/io; #20051006: Skip empty lines!
        # ($RE{balanced}{-parens=>'()'})
        if ( $l =~ m!(\s*|(%S%)*)\.(\w+)
                    ($RE{balanced}{-parens=>'[]'})   # [(\d+)(:(\d+))]
                    (\s*|(%S%)*)
                    ($RE{balanced}{-parens=>'()'})   # (.*?)
                    ,(.*)                                       # Trailing comments
                    !x ) {
            # s.th. to collect ...
            my ( $pre, $p, $hl, $s, $c ) = ( $1, $3, $4, $7, $8 );
            my $hb = -2;
            my $lb = -1;
            if ( $hl =~ m,\[(\d+)(:(\d+))?\], ) {
                    $hb = $1;
                    $lb = ( defined( $3 ) ? $3 : $hb );
            } else {
            	# NAN hl | hb
            	push( @out, $l );
            	next;
            }

            # Catch connected signal(s)
            if ( $s =~ m,\((.+)\), ) {
                    $s = $1;
            } else {
                # Open port .... put enough space in place 
                # Add a dummy signal (use w'bz for now ... )
                #   as this does not work as expected, we invent a dummy signal
                #   conf{workaround.verilog} is set to dummyopen
                # If bounds ($hb, $lb) are non numeric -> cry for help ...
                if ( $hb =~ m,^\s*\d+\s*$,o and
                     $lb =~ m,^\s*\d+\s*$,o ) {
                    my $w = $hb - $lb + 1;
                    if ( $eh->get( 'output.generate.workaround.verilog' ) =~ m,\bdummyopen,io ) {
                        $s = 'mix_dmy_open_' . $dummynr++; # Create a dummy signal and attach this bit to it ...
                        my $wid = ( $w > 1 ) ? ( '[' . $w . ':0] ' ) : '%S%';
                        push( @dummies, 'wire ' . $wid . $s . '; ' . $tcom .
                                  "__I_OPEN_DUMMY" ); #   wire [N:0] mix_dmy_open_N; // __I_DUMMY_OPEN
                    } else {
                        $s = $w . "'bz"; # Comes from open ports ....
                    }
                } else {
                    if ( $eh->get( 'output.generate.workaround.verilog' ) =~ m,\bdummyopen,io ) {
                        $s = "mix_dmy_open_" . $dummynr++; # Create a dummy signal and attach this bit to it ...
                        my $wid = "[" . $hb . ":" . $lb . "] ";
                        push( @dummies, "wire " . $wid . $s . "; " . $tcom .
                                  "__I_DUMMY_OPEN, __I_NAN_BOUNDS" ); #   wire [N:0] mix_dmy_open_N; // __I_DUMMY_OPEN
                    } else {
                        $logger->warn('__W_UNSPLICE_PORT', "\tCannot determine width of open port splice! Set marker! Please fix!" );
                        $s = "__W_NANPORTSPLICE_WIDTH[" . $hb . ":" . $lb .
                                "]" . "'bz"; # Comes from open ports ....
                    }
                }
            }
            push( @{$col{$p}}, [ $hb, $lb , $pre, $s, $c ] );
            $l{$p} = $l;
        } else {
            push( @out, $l );
        }
    }
    
    #!wig20061030: If port mentioned only once -> take literally
    for my $p ( keys( %col ) ) {
    	if ( scalar( @{$col{$p}} ) == 1 ) {
    		push( @out, $l{$p} );
    		delete $col{$p};
    	}
    }	
    
    # We found collectable ports -> scan through them top-down and
    # write out better format
    my $flag = 0;
    for my $p ( keys( %col ) ) {
        my @arr=();
        my $nn = -1;
        for my $n ( @{$col{$p}} ) {
        	#!wig20061030: if scalar( @$n ) == 1 -> do not combi
            # Check bounds for this port
            $nn++;
            if ( $n->[0] < $n->[1] ) {
                $logger->error('__E_UNSPLICE_PORT', "\tCannot collect spliced port $p, bad bound order!");
                    $flag = 1;
                    # Print out as-is
                    last;
            }
            # Create usage vector ...
            for my $b ( $n->[1] .. $n->[0] ) {
                    if ( defined ( $arr[$b] ) ) {
                        $logger->error('__E_UNSPLICE_PORT', "\tDuplicate connection at spliced port $p!" );
                        $flag = 1;
                        last;
                    } else {
                        $arr[$b] = $nn;
                    }
            }
        }
        # Finally: build port string, right to left
        my $t = '';
        my @c = '';
        unless( $flag ) {
            my $start = -1;
            for my $b ( 0..(scalar(@arr) - 1) ) {
                    if ( defined( $arr[$b] ) and $arr[$b] ne $start ) {
                        my $data = $col{$p}[$arr[$b]];
                        my $es = $data->[3];
                        if ( $es =~ m,^%((HIGH|LOW)(_BUS)?(_\d+)?),o ) {
                            # Replace HIGH/LOW immediately!!  
                            $expanded{'%' . $1 . '%'} = 1;
                            my $v = ( $2 eq 'HIGH' ) ? '1' : '0';
                            if ( is_integer2( $data->[0], $data->[1] ) ) {
                            	my $w = $data->[0] - $data->[1] + 1;
                            	$es = $w . "'b" . $v x $w; #Verilog, only!
                            } else { # nan-borders
                            	if ( $v eq '0' ) {
                            		$es = "1'b0"; # Verilog automatically extends 0
                            	} else {
                            		# Generate s.th. like {from-to{1}}
                            		if ( $data->[1] eq '0' ) {
                            			$es = '{' . $data->[0] . '{1}}';
                            		} else {

                            			$es = '{' . $data->[0] . ' - ' . $data->[1] .
                            				'{1}}';
                            		} 
                            	}
                            }
                        }  
                        #!wig20030812: create { a , b, c } format
                        # $t = " & " . $es . $t;
                        $t = ', ' . $es . $t;
                        push( @c, $data->[4] );
                        $start = $arr[$b];
                    } elsif ( not defined( $arr[$b] ) ) {
                        $logger->error('__E_UNSPLICE_PORT', "\tDetected missing bits in spliced port $p!" );
                        $flag = 1;
                        last;
                    }
            }
        }
        # TODO : How can we check if the port width equals all found bits?
        # $t =~ s,^ & ,,;
        $t =~ s#^,##;
        if ( $t =~ m#,# ) { # enclose signal into {} if > 1 parts found ...
            $t = '{' . $t . ' }';
        } else {
        	$t =~ s#^\s+##;
        }
        # Create comment -> remove duplicates ...
        my %c = ();
        my $c = '';
        for my $n ( @c ) {
            # Remove trailing \s and $tcom
            $n =~ s,^\s*$tcom\s*,,;
            $c{$n}++ if ( $n );
        }
        for my $n ( keys( %c ) ) {
            if ( $c{$n} > 1 ) {                    
                $c .= $tcom . ' ' . $n . ' (x' . $c{$n} . ') ';
            } else {
                $c .= $tcom . ' ' . $n . ' ';
            }
        }
            
        if ( $flag ) {
            for my $n ( @{$col{$p}} ) {
                    push( @out, $n->[2] . '.' . $p . '[' . $n->[0] .
                        ( ( $n->[0] ne $n->[1] ) ? ( ':' . $n->[1] ) : '' ) .
                            '](' . $n->[3] . '), ' .
                        ( ( $n->[4] ) ? $n->[4] : '' ) .
                        $tcom . ' __E_CANNOT_COMBINE_SPLICES' );
            }
        } else {
            # TODO : Detect HIGH/LOW_BUS and splice these acordingly!!
            push( @out, '%S%' x 3 . '.' . $p . '(' . $t . '), ' .
                  $c . $tcom . ' __I_COMBINE_SPLICES' );
        }
    }
    # Replace the map ....
    $map = join( "\n", sort( @out ) ) . "\n";
    return $map, \@dummies, \%expanded;
} # End of mix_wr_unsplice_port

#
# create generic map for component instantiation
#	aka. this map will be included in a parent module
#
# Input:
#  $io  = 'in' or 'out'
#  $inst = instancename
#  $enty = entityname
#  $ref = reference to $hierdb{$i}{::conn}{$io}
#  $lang = language .... of instantiating module!
#  $tcom = this language comment
#
sub generic_map ($$$$;$$) {
    my $io = shift;
    my $inst = shift;
    my $enty = shift;
    my $ref = shift;
    my $lang = shift || $eh->get( 'macro.%LANGUAGE%' );
    my $tcom = shift || $eh->get( 'macro.comment.' . $lang );

    my $map = '';

    if ( $lang =~ m,^veri,io ) {
        #wig20050126: if this instance is VHDL -> do not use defparam, but
        #  enty #( list ) inst ....
        #!wig20051020: output.language.verilog = 2001param -> use the #() notation
        my $ilang = $hierdb{$inst}{'::lang'};
        if ( $ilang =~ m,^vhd,io or 
        	$eh->get( 'output.language.verilog' ) =~ m/\b2001param\b/io ) {
            $map = '%S%' x 1 . "#(\n"; # Same line
            # TODO : Add ::description if available ... -> does not work this way
            #                                                   (lost param name here).
            for my $g ( sort( keys( %$ref ) ) ) {
                $map .= '%S%' x 3 . "." . $g . '(' . $ref->{$g} . '),' .
                    (( _mix_wr_isinteger( $inst, $g, $ref->{$g} ) ) ?
                         " $tcom __W_ILLEGAL_PARAM" : '' ) .
                    "\n";
            }
            # Remove final ,
            $map =~ s/,(\s*$tcom.+|\s*)\n$/$1\n/;
            $map .= '%S%' x 2 . ') '; # Indent 2
        } else {
            # Verilog in Verilog uses defparam ....
            for my $g ( sort( keys( %$ref ) ) ) {
                $map .=  '%S%' x 3 . $inst . "." . $g . " = " . $ref->{$g} . "," .
                        (( _mix_wr_isinteger( $inst, $g, $ref->{$g} ) ) ?
                            " $tcom __W_ILLEGAL_PARAM" : "" ) .
                "\n";
            }
			$map =~ s/,(\s$tcom.+|\s*)\n$/;$1\n/; # Replace the final , by a ; ##LU changed 20051110
            $map =~ s,^%S%%S%%S%,%S%%S%defparam ,;
        }
    } else {
        for my $g ( sort( keys( %$ref ) ) ) {
                  $map .= '%S%' x 3 . $g . " => " . $ref->{$g} . ",\n";
        }
    }
    return $map;
}

####################################################################
## _mix_wr_isinteger
##  check if input is integer 
####################################################################

=head2

_mix_wr_isinteger ($$$) {

Finds out if input is valid integer. Print warning if not.

First try for integer:
    [W['B]]NN_NNN
    B: b o h d
    W: NN
    NN_NNN: depends on B

TODO: migrate to MixChecker or MixBase

Input:
    instancename (instantiated component)
   generic (name of the generic)
   value (parameter value)

Return:
	1 if problem!
	
=cut

# TODO : extend checks to string types ...??
sub _mix_wr_isinteger ($$$) {
    my $inst = shift;
    my $generic = shift;
    my $val = shift;
    my $lang = shift || $eh->get( 'macro.%LANGUAGE%' );

    my %allowed = (
        'b' => '[01_]',
        'o' => '[0-7_]',
        'd' => '[0-9_]',
        'h' => '[0-9a-fA-F_]',
    );

    my $set = 'ILLEGAL';    

    my $base = 'd';
    my $width = '';
    my $number = '';
    my $flag = 0;

    # Split input string
    if ( $val =~ m/(.*)'(\w)(.*)/ ) {    # ' just for eclipse syntax higlighting
        $base = $2;
        $width = $1;
        $number = $3;
    } else {
        $number = $val;
    }

    # base defined?
     if ( $base !~ m/[bohd]/ ) {
        $flag = 1;
    } else {
        $set = $allowed{$base};
    }
    # width defined?
    if ( $width ) { # Has to be real number
        unless( $width =~ m/^\d+$/o ) {
            $flag = 1;
        }
    }
    # check number:
    if ( $number ne "" ) {
        unless ( $number =~ m/^$set+$/ ) {
            $flag = 1;
        }
    } else {
        $flag = 1;
    }
    
    if ( $flag ) {
    	#!wig20051109: Check if type is string -> allow anything
    	my $enty = $hierdb{$inst}{'::entity'};
    	if ( exists( $entities{$enty}{$generic} ) and
    		  exists( $entities{$enty}{$generic}{'type'} ) ) {
    		 my $type = $entities{$enty}{$generic}{'type'};
    		 if ( $type =~ m/string/io ) {
    		 	$flag = 0;
    		 }
    	}
    	if ( $flag ) {
        	$logger->warn('__W_ISINTEGER', "\tApplied non-integer parameter $val for generic $generic at instance $inst!" );
    	}
    }
    return $flag;
} # End of mix_wr_isinteger

#
# create a "port map" for VHDL logic's like AND, OR, NAND, ...
#
#  out <= in1 AND in2 AND ...
#
sub port_simple ($$$$$$) {
    my $io = shift;
    my $inst = shift;
    my $enty = shift;
    my $lang = shift;
    my $refo = shift;
    my $refi = shift;
    my $ro = shift;
    my $ri = shift;
	
	# if out -> only one signal allowed!
	# if ( $io eq "out" ) {
	# Simple logic always has ONE out!!
	
	# Test if we have the right amount if outputs
	# Currently: only one signal allowed! No bitsplices!
	my $logiccheck = $eh->get( 'output.generate._logiciocheck_' );
	( my $logictype = lc( $enty ) ) =~ s/[%_]//g;
	if ( exists( $logiccheck->{$logictype}{'omax'} ) and
		$logiccheck->{$logictype}{'omax'} =~ m/^\d+$/ ) {
		if ( scalar( keys %$refo ) != $logiccheck->{$logictype}{'omax'} ) {
			$logger->error('__E_PORT_SIMPLE', "\tOUTPUT_COUNT_MISMATCH instance $inst($enty)!" );
		}
	}
	# Take all keys from %$refo
	my $outsig = join( "_E_DUPL_OUT_LOGIC_", keys( %$refo ));
	push( @$ro, $outsig ); # Remember the output signal
	# }
	
	my $tcom = $eh->get( 'output.comment.' . $lang ) || $eh->get( 'output.comment.default' ) || '#';

	my @sin = ();
	
	my $out = '%S%' x 2;
	my $ins = "";
	if ( $lang =~ /veri/io ) {
		$out .= "assign $outsig =\n";
	} else {
		$out .= "$outsig <=\n";
	}

	#TODO: sort order, comments ....	
    # for my $s ( sort( keys( %$refi ) ) ) {
    # if ( $conndb{$s}{'::mode'} =~ m,^\s*[GP],io ) {
            # Parameter for generics ... skip in port map ...
    #         next;
    #    }
	
	 #   my $sf = $conndb{$s}{'::high'}; # Set signal high bound
	 #   unless( defined( $sf ) and $sf ne '' ) { $sf = '__UNDEF__'; }
	
	 #   my $st = $conndb{$s}{'::low'}; 	# Set signal low bound
	 #   unless( defined( $st ) and $st ne '' ) { $st = '__UNDEF__'; }

		for my $io ( keys %$refi ) {
			# Remember signal names ...
			# TODO: check if full port got matched!
			push( @sin, $io );
			push( @$ri, $io );
		}
		
		# _mix_w_simple_check();

		# %WIRE%  -> one in / same out!
		#
		if ( $enty eq "%WIRE%" ) {
			$ins .= _mix_simple_wire( $sin[0], $lang);
		} else {
			$ins .= _mix_simple_logic( $enty, \@sin, $lang );
		}

    # }
	return ( $out, $ins );
	    
} # End of port_simple

#
# print a simple wire (assignment)
# one-liner -> no extra sort required.
#
sub _mix_simple_wire ($$$) {
	my $in = shift;
	my $lang = shift;
	
	if ( $lang =~ m/veri/io ) {
		return ( '%S%' x 3 . "$in" );
	} else { 
		return ( '%S%' x 3 . "$in" );
	}
}

# TODO : add description and bus splice logic ...
# First try:
#  data_reg_to_iic <= data_reg70_to_iic OR
# 		data_reg7f_to_iic OR
#		"0000000000000000";
# 
sub _mix_simple_logic ($$$) {
	my $enty  = shift;
	my $inr  = shift;
	my $lang = shift;

	( my $op = lc( $enty ) ) =~ s/%//g;
	if ( $eh->get( 'output.generate.logicmap' ) =~ m/\buc|upper/ ) {
		$op = uc( $op );
	}

	my $logic = "";
	# VHDL:
	$logic .= '%S%' x 3 . join( ( "\n" . '%S%' x 3 . $op . '%S%' ), @$inr );
	# TODO : Attach a trailing OR "0000" ???
	return $logic;
} # End of _mix_simple_logic

#
# do sanity checks on the simple ports ...
#

sub _mix_w_simple_check () {
	return;
}
#
# create port map, handles bus slices ...
# store port usage and print alert if a port gets attached twice!
#
# Input:
#  $io  = 'in' or 'out'
#  $inst = instancename
#  $enty = entityname
#  $lang = HDL be generated (VHDL or Verilog)
#  $ref = reference to $hierdb{$i}{::conn}{$io}
#  $rio = reference to array keeping in's and out's (output!)
#
sub port_map ($$$$$$) {
    my $io = shift;
    my $inst = shift;
    my $enty = shift;
    my $lang = shift;
    my $ref = shift;
    my $rio = shift;

    # Check if port width equals signal width.
    # Use simple assigment if yes, else slice bus
    my @map = ();
    for my $s ( sort( keys( %$ref ) ) ) {
	# constants work the same way as the rest here ...
        if ( $conndb{$s}{'::mode'} =~ m,^\s*[GP],io ) {
            # Parameter for generics ... skip in port map ...
            next;
        }
	
	    my $sf = $conndb{$s}{'::high'}; # Set signal high bound
	    unless( defined( $sf ) and $sf ne '' ) { $sf = '__UNDEF__'; }
	
	    my $st = $conndb{$s}{'::low'}; 	# Set signal low bound
	    unless( defined( $st ) and $st ne '' ) { $st = '__UNDEF__'; }

	    for my $p ( sort( keys( %{$ref->{$s}} ) ) ) {
	        # $p has port name
	        # $s has signal name
	        my $pf = $entities{$enty}{$p}{'high'};
	        unless( defined( $pf ) and $pf ne '' ) { $pf = '__UNDEF__'; }

	        my @cm = (); # Connections to this port ....
	        my $pt = $entities{$enty}{$p}{'low'};
	        unless( defined( $pt ) and $pt ne '' ) { $pt = '__UNDEF__'; }

			# typecast in port maps (seems to be problem with synopsys dc, see typecast switch)
        	my $cast = '';
        	if ( exists( $entities{$enty}{$p}{'cast'} ) and
				$eh->get( 'output.generate.workaround.typecast' ) =~ m/\bportmap\b/ ) {
            	$cast = $entities{$enty}{$p}{'cast'};
        	}
	        for my $n ( split( ',', $ref->{$s}{$p} ) ) {
			    #
			    # Read out the actual connection data
		    	#  $conn->{inst}, $conn->{port}
		    	#  $conn->{port_f}, $conn->{port_t},
		    	#  $conn->{sig_f}, $conn->{sig_t}		
		    	#!wig20050518: adding lcm
		    	# TODO : remove cm (no longer needed!)
		    	my @lcm = (); # Local connection matrix
		    	my $conn = $conndb{$s}{'::' . $io}[$n];
		    	my $lret = add_conn_matrix( $p, $s, \@lcm, $conn );
		    	my $ret = add_conn_matrix( $p, $s, \@cm, $conn ); #Overlaps connection matrix
            	#!wig20030908: very special trick to get constants for nan bounds:
            	if ( $ret and ( $ret eq 2 or $ret eq 3 ) ) { # nan bounds, matching .... store for later
                	$hierdb{$inst}{'::nanbounds'}{$s} = \@cm;
                	# TODO : check if that happened already ...
            	}
			
				push( @map , print_conn_matrix( $inst, $p, $pf, $pt, $s, $sf, $st, $lang, \@lcm, $cast ));
	    		# Remember if a port got used ....
	    		if ( store_conn_matrix( \%{$hierdb{$inst}{'::portbits'}}, $inst, $p, $pf, $pt, $s, \@lcm ) ) {
                	#DONE: Do something against duplicate connections ... -> handeled by purge_relicts
	    		}
				
	    	}

		}
		push( @$rio, $s );
    }
    return '' if ( scalar @map == 0 ); # No map -> return nothing

    my $order = $eh->get( 'output.generate.portmapsort' );
	if ( $order =~ m/\bdebug\b/ ) {
		$order = 1;
	} else {
		$order = 0;
	}
    my $tcom = $eh->get( 'output.comment.' . $lang ) || $eh->get( 'output.comment.default' ) || '#';
    return join( '', map( { s/%MAPSORT(.+?)SORTMAP%//; 
			$_ .
				(( $order ) ? (' ' . $tcom . 'SORT:' . $1 ) : ''); }
    		sort( @map ) ) ) . "\n"; # Return sorted by port name (comes first)
} # End of port_map


#
# Set up an array for each pin of a port, indexing a given signal!
#
# Handle duplicate connection of one signal to several pins ...
# Returns:
#   - modified connection matrix in $matrix
#   - return value:
#     undef = s.th. went wrong
#    0 = everything fine, signal and port slice are equal
#    1 = non-matching signal/port slice ...
#    2 = detected nan bounds, matching
#    3 = detected nan bounds for single bit
#	 4 = detected nan bounds, non-matching
#
sub add_conn_matrix ($$$$) {
    my $port = shift;
    my $signal = shift;
    my $matrix = shift;
    my $conn = shift;

    my $cpf = $conn->{port_f} || '0';  # undef -> 0
    my $cpt = $conn->{port_t} || '0';  # undef -> 0

    my $csf = $conn->{sig_f} || '0';  # undef -> 0
    my $cst = $conn->{sig_t} || '0';  # undef -> 0

    #!wig20030812: catch non-numeric bounds ....
    # TODO : is this the only cases?
    if ( $cpf !~ m,^\s*[+-]?\d+\s*$,o or
        $cpt !~ m,^\s*[+-]?\d+\s*$,o or
        $csf !~ m,^\s*[+-]?\d+\s*$,o or
        $cst !~ m,^\s*[+-]?\d+\s*$,o
         ) {
         	if ( $eh->get( 'check.signal' ) =~ m/\bnanbound/i ) {
        		$logger->warn('__W_ADD_CONN_MATRIX', "\tsignal $signal bounds ($cpf:" .
        			$cpt . ") or port $port ($cpf:$cpt) not a number!" );
        	}
        # $cpt and/or $cpf is not a number!!
        # We carry on if cpf equals csf and cpt equals cst ->
        #   otherwise we bail out ...
        if ( $csf eq $cpf and $cst eq $cpt ) {
            # Is there already contents in the connection matrix?
            if ( scalar( @$matrix ) ) {
                $logger->warn('__W_ADD_CONN_MATRIX', "\tRedefinition of connection matrix for signal $signal, port $port!");
            }
            # Store marker: __NAN__ , From, To
            $matrix->[0] = '__NAN__';
            $matrix->[1] = $csf;
            $matrix->[2] = $cst;
            return 2;
        } elsif ( $csf eq $cst and $cpf eq $cpt ) {
        	#!wig20060906: Single bit connected (from equals to ...)
        	# Store marker: __NAN__ , From, To
            $matrix->[0] = '__NAN_SB__';
            $matrix->[1] = $csf; # Bit in signal
            $matrix->[2] = $cpf; # Bit in port
            return 3;
        } else {
        	# Allowed for `foo, else warn:
        	unless ( $csf =~ m/^\s*`/ or $cpf =~ m/^\s*`/ ) {
            	$logger->warn('__W_ADD_CONN_MATRIX', "\tCheck resolved signal/port $signal ($csf:$cst) $port ($cpf:$cpt): non numeric and non matching bounds!" );
        	}
			$matrix->[0] = '__NAN_EX__';
			$matrix->[1] = $csf;
			$matrix->[2] = $cst;
			$matrix->[3] = $cpf;
			$matrix->[4] = $cpt;
			return 3;
        }
        
        return 4;
        # TODO : other cases ...
    }
    
    my $max = $cpf;
    my $min = $cpt;
    my $dirf = 1; # Normal from downto to
    
    if ( $cpt > $max ) {
        $max = $cpt; $min = $cpf; $dirf = -1;
    };


    my $smax = $csf;
    my $smin = $cst;
    my $sdirf = 1;
    
    if ( $cst > $smax ) {
        $smax = $cst; $smin = $csf; $sdirf = -1;
    };

    if ( $smax - $smin != $max - $min ) {
		$logger->error('__E_CONN_MATRIX', "\tE_SLICE_WIDTH_MISMATCH:signal " .
			$signal . "($smax downto $smin) to port " .
			$port . "($max downto $min)!");
		return undef;
    }

    # TODO : Extended testing ....
    if ( $dirf == $sdirf ) {
		for my $i ( $min .. $max ) {
	    	if ( defined( $matrix->[$i] ) ) { # Seen before ...
				if ( $matrix->[$i] ne $smin - $min + $i ) {
		    		$logger->error('__E_PORT_SIGNAL_CONFLICT', "\t$port($i) connecting signal $signal " . ( $smin + $i ) .
			    		" or " . $matrix->[$i] . "!" );
				}
	    	} else {
				$matrix->[$i] = $smin - $min + $i;
	    	}
        }
    } else {
		for my $i ( $min .. $max ) {
	    	if ( defined( $matrix->[$i] ) ) { # Seen before ...
				if ( $matrix->[$i] ne $smax - $max - $i ) {
		    		$logger->error('__E_PORT_SIGNAL_CONFLICT', "\t$port($i) connecting signal $signal " . ( $smin + $i ) .
			    		" or " . $matrix->[$i] . "!" );
				}
	    	} else {	    
				$matrix->[$i] = $smax - $min - $i;
	    	}
        }
    }

    # Return 1 if signal and port slice are the same !!    
    if ( $cpt eq $cst and $cpf eq $csf ) {
		return 1;
    } else {
		return 0;
    }
} # End of add_conn_matrix

#
# Remember that this port got already connected
# Sets $hierdb{inst}{'::portbits'}{'port'} = 'A::' or 'E::' or 'F::foo:T::bar' or
#    'B::01io000'
#TODO: replace 1 by i,o,c,b,t,....
#
sub store_conn_matrix ($$$$$$$) {
    my $prev = shift;
    my $instance = shift;
    my $port = shift;
    my $pf = shift;
    my $pt = shift;
    my $signal = shift; # Ignore
    my $rcm = shift;

    # If prev does not exist -> create it
    unless ( defined( $prev ) and defined( $prev->{$port} )  ) {
        $prev->{$port} = '';
    }

    #
    # Simple case: everything is in sync and o.k. ( matrix index equals signal pin number)
    #
    my $usage = "E::";

    if ( $pf eq $pt and $pf eq "__UNDEF__" ) {
        if ( defined( $rcm->[0] ) ) {
            $usage = "A::";
        } else {
            $logger->error('__E_STORE_CONN_MATRIX', "\tBad branch taken $instance, $signal. File bug report!" );
        }
    } elsif ( not ( $pf =~ m,^[+-]?\d+$,o and $pt =~ m,^\s*[+-]?\d+\s*$,o ) ) {
        $usage = "F::" . $pf . ":T::" . $pt;
    } else {
        # Run through cm and see if everything is filled and ordered
        my $ub = ( $pf > $pt ) ? $pf : $pt;
        my $lb = ( $pf > $pt ) ? $pt : $pf;
        my $bv = "";
        my $miss = 0;
        for my $i ( $lb..$ub ) {
            # End of slice reached?
            unless ( defined( $rcm->[$i] ) ) {
                $miss = 1;
                $bv = "0" . $bv;
            } else {
                $bv = "1" . $bv;
            } 
        }
        unless( $miss ) {
            $usage = "A::";
        } else {
            # B runs from $pt to $pf (or other if $pt > $pf),
            # B:: will not have bits for the numbers < $pt
            $usage = "B::" . $bv;
        }
    }
    
    #
    # If this port did not appear previously, set it and return
    #
    unless ( $prev->{$port} ) {
        $prev->{$port} = $usage;
        return;
    } else {
        # Compare / add the previously connected bits with the new one's
        if ( $prev->{$port} =~ m,^A::, ) {
            unless( $instance =~ m/^%TYPECAST_/io ) {
                $logger->warn('__W_STORE_CONN_MATRIX', "\tReconnecting port $port at instance $instance: now: $usage, was: A::!" );
                push( @{$hierdb{$instance}{'::reconnections'}{$port}}, $signal ); # Only partial info available!
            }
            return;
        } else {
            my ( $conflict, $result ) = mix_wr_port_check($usage, $prev->{$port});
            if ( $conflict == "1" ) {
                $logger->warn('__W_STORE_CONN_MATRIX', "\tPossible conflict with reconnection of port $port at instance $instance: $usage was $prev->{$port}!" );
                $prev->{$port} = $result;
            } elsif ( $conflict == "-1" ) {
                $logger->error('__E_STORE_CONN_MATRIX', "\tMode conflict with reconnection of port $port at instance $instance: $usage was $prev->{$port}!" );
                $prev->{$port} = $result;
            } else {
                # O.K., got s.th. overlapping ...
                $prev->{$port} = $result;
            }
        }
    }
} # End of store_conn_matrix

#
# Check if input vector can be overlayed without duplicates ..
# Returns:
#  flag -> 0 o.k. (no overlay)
#           -1  error (bad overlay mode)
#           1 collision, but matching mode
#
sub mix_wr_port_check ($$) {
    my $np = shift;
    my $op = shift;

    my $m = "1"; # Default: unknown mode, just a one for "got connection"
    my $w = 0;
    my $mo = "1";
    my $wo = 0;
    my $mn = "1";
    my $wn = "0";

    if ( $np eq $op ) { # The same -> easy, isn't it
        return( "1", $np );
    }

    if ( $np =~ m,^A::(\w*), ) {
        # collision! But there is still a chance to get a match
        $mn = ( $1 ) ? $1 : "1";
        $wn = "ALL";
    }

    if ( $op =~ m,^A::(\w*), ) {
        # collision! But there is still a chance to get a match
        $mo = (  $1 ) ? $1 : "1"; 
        $wo = "ALL";
    }

    # Both have a A::, but mode differs ...
    if ( $wo eq "ALL" and $wn eq "ALL" ) {
        # modes differ!!
        return( "-1", "A::e" );
    }

    if ( $np =~ m,^F::, or $op =~ m,^F::, ) {
        $logger->warn('__W_PORT_CHECK', "\tPlease check overlay of port $np, was $op!" );
        return( "1", $np . $op );
    }

    my $bitn = "";
    if ( $np =~ m,^B::(\w+), ) {
        $wn = length( $1 );
        $bitn = $1;
    }
    my $bito = "";
    if ( $op =~ m,^B::(\w+), ) {
        $wo = length( $1 );
        $bito = $1;
    }

    # We had a A:: before?
    if ( $wo eq "ALL" and $wn > 0 ) {
        # old was A::, new is bit vector ...
        my %mod = ();
        for my $l ( split( '', $bitn ) ) {
            $mod{$l} = 1 if $l;
        }
        # delete( $mod{'0'} ); # Get rid of '0'
        $mn = join( '', keys( %mod ) );
        if ( length( $mn ) > 1 ) {
            $logger->error('__E_PORT_CHECK', "\tMixed modes in port!!" );
            $mn = "1";
        } elsif ( $mn ne $mo ) {
            $logger->error('__E_PORT_CHECK', "\tMode mismatch in port join!" );
            $mn = "1";
        } else {
            return( "1", "A::" . $mn );
        }
        return( "-1", "A::" . $mn );
    }

   # We get a A:: now?
    if ( $wn eq "ALL" and $wo > 0 ) {
        # old was A::, new is bit vector ...
        my %mod = ();
        for my $l ( split( '', $bito ) ) {
            $mod{$l} = 1 if $l;
        }
        # delete( $mod{'0'} ); # Get rid of '0'
        $mo = join( '', keys( %mod ) );
        if ( length( $mo ) > 1 ) {
            $logger->error('__E_PORT_CHECK', "\tMixed modes in port!!" );
            $mo = "1";
        } elsif ( $mn ne $mo ) {
            $logger->error('__E_PORT_CHECK', "\tMode mismatch in port join!" );
            $mo = "1";
        } else {
            return( "1", "A::" . $mo );
        }
        return( "-1", "A::" . $mo );
    }

    # O.k., now remains B::.... vs B::....
    $w = $wo;
    if ( $wn ne $wo ) {
        $logger->error('__E_PORT_CHECK', "\tPort width mismatch $wn was $wo" );
        # Attach some 0 in front
        if ( $wn > $wo ) {
            $w = $wn;
            $bito = "0" x ( $wn - $wo ) . $bito;
        } else {
            $w = $wo;
            $bitn = "0" x ( $wo - $wn ) . $bitn;
        }
    }

    my @bo = split( '', $bito );
    my @bn = split( '', $bitn );

    # Compare bit by bit:
    #  O   N
    #  0   0   ->  0
    #  0   X  ->  X
    #  X   0   -> X
    #  X  X    -> X, collision!
    #  X  Y   -> X, bad collision!
    # and make sure that only one mode appears ...
    # result goes into $bit
    my $res = "B::";
    my $col = 0;
    my $badcol = 0;
    my $tm = 0;
    my $hasgap = 0;
    for my $n ( 0..($w - 1) ) {
        if ( $bo[$n] eq "0" ) {
            $res .= $bn[$n]; # Covers case 1 and 2
            if ( $bn[$n] and $tm and $bn[$n] ne $tm ) {
                $logger->error('__E_PORT_CHECK', "Port internal mode change: $bn[$n] was $tm" );
            }
            $hasgap = 1 unless ( $bn[$n] );
            $tm = $bn[$n] if ( $bn[$n] );
        } elsif ( $bn[$n] eq "0" ) {
            $res .= $bo[$n]; # Covers case 3
            if ( $bo[$n] and $tm and $bo[$n] ne $tm ) {
                $logger->error('__E_PORT_CHECK', "\tPort internal mode change: $bo[$n] was $tm" );
            }
            $hasgap = 1 unless ( $bo[$n] );
            $tm = $bo[$n] if ( $bo[$n] );
        } elsif ( $bn[$n] eq $bo[$n] ) {
            if ( $tm and $tm ne $bo[$n] ) {
                $logger->error('__E_PORT_CHECK', "\tPort internal mode change: $bo[$n] was $tm" );
            }
            $res .= $bn[$n]; # case 4: matching mode
            $col = 1;
            $tm = $bn[$n];
        } else {
            $res .= $bo[$n];
            $badcol = 1;
        }
    }
    
    # Final check: if B::xxxxxx does not have a 0 in it -> replace by A::x
    unless( $hasgap ) {
        $res = "A::" . $tm;
    }
    
    if ( $badcol ) {
        return( "-1", $res );
    } else {
        return ( $col, $res );
    }
}

#
# print the connections, aka. print a port map
#
#!wig20030806: Optionally takes a typecast argument ...
#  the cast function will be applied to the port (hopefully this is valid for most tools) ...
#
# Adding: __NAN__ support (string aka. generic ::high/::low bounds)
#
#!wig20031014: Print out the ::descr field if eh->get( output.generate.portdescr )
#!wig20050418: Adding sort criteria, need to extend interface by instance name
#
sub print_conn_matrix ($$$$$$$$$;$) {
	my $inst = shift;
    my $port = shift;
    my $pf = shift;
    my $pt = shift;
    my $signal = shift;
    my $sf = shift;
    my $st = shift;
    my $lang = shift || $eh->get( 'macro.%LANGUAGE%' );
    my $rcm = shift;
    my $cast = shift || '';

    #
    # Simple case: everything is in sync and o.k. ( matrix index equals signal pin number)
    #
    my $t = '';
    my $lb = undef;
    my $ub = $#$rcm;
    my $lstart = 0;


	my $sortcrit = mix_wr_mapsort( $hierdb{$inst}{'::entity'}, $port ); # port map sort order prefix

    my $tcom = $eh->get( 'output.comment.' . $lang ) || $eh->get( 'output.comment.default' ) || '#';

	my $descr = mix_wr_printdescr( $signal, $tcom );

	#!wig20060503: $rcm is empty!
	if ( $ub eq -1 ) { # Error: signal not really connected!!
		$logger->error( '__E_PRINTCONN', "\tSignal $signal not properly connected to port $port of instance $inst!" );
		return( $sortcrit . '%S%' x 3 . $tcom . ' __E_PRINTCONN ' . $port . ' => ' . $signal . "\n" );
	}   
    #
    # Non-Numeric bounds:
    #
    # __NAN__ , From:, To: ..
    # __NAN__ works for full connections, only (today)
    #!wig: extend __NAN_SB__ (single bit) + __NAN_EX__ (extended)
    if ( defined( $rcm->[0] ) and $rcm->[0] eq '__NAN__' ) {
    	if ( $sf eq $rcm->[1] and $st eq $rcm->[2] ) {
    		# Full connect!!
    		if ( $lang =~ m,^veri,io ) { # Verilog
            	$signal = '' if ( $signal =~ m/^%OPEN(_\d+)?%/io ); # For Verilog: let %OPEN% disappear
            	$t .= '%S%' x 3 . '.' . $port . '(' . $signal . '),' . $descr . "\n";
        	} else {
            	if ( $cast ) {
                	$t .= '%S%' x 3 . $cast . '(' . $port . ') => ' .
                		$signal . ',' . $descr . "\n";
            	} else {
                	$t .= '%S%' x 3 . $port . ' => ' . $signal . ',' . $descr . "\n";
            	}
        	}
    	} else {
    		# Only part of signal gets connected
    		my $sft = $rcm->[1] . ':' . $rcm->[2];
    		if ( $rcm->[2] =~ m/%TICK_DEFINE_(\w+)%/ ) {
    			$sft = $rcm->[1];
    		}
    		if ( $lang =~ m,^veri,io ) { # Verilog
            	$signal = '' if ( $signal =~ m/^%OPEN(_\d+)?%/io ); # For Verilog: let %OPEN% disappear
            	$t .= '%S%' x 3 . '.' . $port . '(' . $signal . 
            		'[' . $sft . ']),' . $descr . "\n";
        	} else {
            	if ( $cast ) {
                	$t .= '%S%' x 3 . $cast . '(' . $port . ') => ' .
                		$signal . '(' . $sft . ')' . ',' . $descr . "\n";
            	} else {
                	$t .= '%S%' x 3 . $port . ' => ' . $signal .
                	'(' . $sft . ')' . ',' .
                	$descr . "\n";
            	}
        	}
    	}
        #!wig20050418: prepend sort criteria
        return ( $sortcrit . $t );
    }
    
    # not a full connection, but a single bit, only
    if ( defined( $rcm->[0] ) and $rcm->[0] eq '__NAN_SB__' ) {
        if ( $lang =~ m,^veri,io ) { # Verilog
            $signal = '' if ( $signal =~ m/^%OPEN(_\d+)?%/io );
            # For Verilog: let %OPEN% disappear
            $t .= '%S%' x 3 . '.' . $port . '[' . $rcm->[2] . ']' .
            	'(' . $signal . '[' . $rcm->[1] . ']),' . $descr . "\n";
            #TODO, check Verilog syntax
        } else {
            if ( $cast ) {
                $t .= '%S%' x 3 . $cast . '(' . $port . '(' . $rcm->[2] . ')' . ') => ' .
                	$signal . '(' . $rcm->[1] . ')' . ',' . $descr . "\n";
            } else {
                $t .= '%S%' x 3 . $port . '(' . $rcm->[2] . ')' .
                	' => ' . $signal . '(' . $rcm->[1] . ')' . ',' . $descr . "\n";
            }
        }
        #!wig20050418: prepend sort criteria
        return ( $sortcrit . $t );
    }

	# Partial signal to NAN port bounds
	#	marker __NAN_EX__ in rcm->[0]
	#	signal from/to in rcm->[1]/[2]
	#	port   from/to in rcm->[3]/[4]
	if ( defined( $rcm->[0] ) and $rcm->[0] eq '__NAN_EX__' ) {
        if ( $lang =~ m,^veri,io ) { # Verilog
            $signal = '' if ( $signal =~ m/^%OPEN(_\d+)?%/io );
            # For Verilog: let %OPEN% disappear
            #!wig: another special case: `foo ....
            my $p_to = ( $rcm->[4] =~ m/^%TICK_DEFINE_/ ) ? '' : ( ':' . $rcm->[4] );
            my $s_to = ( $rcm->[2] =~ m/^%TICK_DEFINE_/ ) ? '' : ( ':' . $rcm->[2] );
            $p_to    = '' if ( $rcm->[3] eq $rcm->[4] );
            $s_to    = '' if ( $rcm->[1] eq $rcm->[2] ); 
            $t .= '%S%' x 3 . '.' . $port .
            		'[' . $rcm->[3] . $p_to . ']' .
            		'(' . $signal .
            		'[' . $rcm->[1] . $s_to . ']),' . $descr . "\n";
        } else {
        	# TODO : How should we handle the `foo cases from above?
            if ( $cast ) {
                $t .= '%S%' x 3 . $cast . '(' . $port .
                	'(' . $rcm->[3] . ':' . $rcm->[4] . ')' .
                	') => ' . $signal .
                	'(' . $rcm->[1] . ':' . $rcm->[2] . ')' . 
                	 ',' . $descr . "\n";
            } else {
                $t .= '%S%' x 3 . $port . 
                	'(' . $rcm->[3] . ':' . $rcm->[4] . ')' .
                	' => ' . $signal . 
               		'(' . $rcm->[1] . ':' . $rcm->[2] . ')' .
                	',' . $descr . "\n";
            }
        }
        #!wig20050418: prepend sort criteria
        return ( $sortcrit . $t );
    }
    # $ub = 0 and $p[f|t] = __UNDEF__ and $s[f|t] = __UNDEF__
    # and $rcm->[0] = 0  -> single pin assignment
    if ( $ub == 0 and
	 $pf eq '__UNDEF__' and $pt eq '__UNDEF__' and
	 $sf eq '__UNDEF__' and $st eq '__UNDEF__' and
	 $rcm->[0] == 0 ) {
            if ( $lang =~ m,^veri,io ) { # Verilog
                $signal = '' if ( $signal =~ m/^%OPEN(_\d+)?%/io ); # For Verilog: let %OPEN% disappear
                $t .= '%S%' x 3 . '.' . $port . '(' . $signal . '),' . $descr . "\n";
            } else {
                if ( $cast ) {
                    $t .= '%S%' x 3 . $cast . '(' . $port . ') => ' . $signal . ',' . $descr . "\n";
                } else {
                    $t .= '%S%' x 3 . $port . ' => ' . $signal . ',' . $descr . "\n";
                }
            }
	    return ( $sortcrit . $t );
    }

    # Run through cm and see if everything is filled and ordered   
    my $fflag = $ub;
    my $cflag = 1;
    #TODO: reverse flag if ::high < ::low: my $rflag = 1;
    # Simple version: if the connection is not continuos, print bit slices ...
    #
    for my $i ( 0..$ub ) {
		# Find starting point ($lb), first defined value in conn array
		if ( not defined( $lb ) ) {
	    	if ( defined( $rcm->[$i] ) ) {
				$lb = $i; # Find start point, offset ....
	    	} else {
				next;
	    	}
		}
		# End of slice reached?
		unless ( defined( $rcm->[$i] ) ) {
	    	$fflag = $i - 1; # fflag set to last valid entry ...
	    	last;
		}
		# Was last value just one off? Counts 
		if ( $i ne $lb and $rcm->[$i] ne $rcm->[$i - 1] + 1 ) {
	    	$cflag = 0; # Continue flag set to zero ...
		}
    }

    if ( $cflag and $fflag == $ub ) {
		# Full conn matrix port <-> signal  or
		# One bit of port connected to bit signal
		if ( ( $pf eq $pt ) and defined( $lb ) and ( $lb eq $ub ) ) {
	    	# Single bit port .... connected to bus slice
	    	# TODO : do more checking ...
	    	if ( $pf eq '__UNDEF__' ) {
                if ( $lang =~ m,^veri,io ) { # Verilog
                    $t .= '%S%' x 3 . '.' . $port . '(' . $signal . '[' .
                    	$rcm->[$ub] . "]),\n"; #TODO: Check Verilog syntax
                } else {
                    if ( $cast ) {
                        $t .= '%S%' x 3 . $cast . '(' . $port . ') => ' .
                            $signal . '(' . $rcm->[$ub] . "),\n";
                    } else {
                        $t .= '%S%' x 3 . $port . ' => ' .
                            $signal . '(' . $rcm->[$ub] . "),\n";
                    }
                }
	    	} else {
                if ( $lang =~ m,^veri,io ) { # Verilog
                    $t .= '%S%' x 3 . '.' . $port . '[' . $pf . '](' . $signal . '[' . $rcm->[$ub] . "]),\n"; #TODO: is this legal?
                } else {
                    if ( $cast ) {
                        $t .= '%S%' x 3 . $cast . "(" . $port . "(" . $pf . ")) => " .
                            $signal . "(" . $rcm->[$ub] . "),\n";
                    } else {
                        $t .= '%S%' x 3 . $port . "(" . $pf . ") => " .
                            $signal . "(" . $rcm->[$ub] . "),\n";
                    }
                }               
	    	}
		} elsif ( $sf eq "__UNDEF__" and $st eq "__UNDEF__" ) {
            # Single bit of signal connected to bus port ...
           if ( $lang =~ m,^veri,io ) { #Verilog
                $t .= '%S%' x 3 . '.' . $port . "[" . $ub . "](" . $signal . "), " . $tcom . " __I_BIT_TO_BUSPORT\n"; #
            } else {
                if ( $cast ) {
                    $t .= '%S%' x 3 . $cast . "(" . $port . "(" . $ub . ")) => " .
                        $signal . ", " . $tcom . " __I_BIT_TO_BUSPORT\n";
                } else {
                    $t .= '%S%' x 3 . $port . "(" . $ub . ") => " .
                        $signal . ", " . $tcom . " __I_BIT_TO_BUSPORT\n";
                }
            }
		#!wig20030516: $t .= "\t\t\t$port(" . $rcm->[$ub] . ") => $signal,\n"; #Needs more checking ..
		# } elsif ( $rcm->[$ub] eq $sf and $rcm->[$lb] eq $st ) { # Should == be used here instead?
		#    $t .= "\t\t\t$port => $signal,\n";
		} elsif ( $rcm->[$ub] eq $sf and $rcm->[$lb] eq $st ) { # Should == be used here instead?
            # Full signal used
            if ( $ub - $lb eq $pf - $pt ) { # Port width eq signal width
                if ( $lang =~ m,^veri,io ) { #Verilog
                    $t .= '%S%' x 3 . "." . $port . "(" . $signal . "),\n";
                } else {
                    if ( $cast ) {
                        $t .= '%S%' x 3 . $cast . "(" . $port . ") => ". $signal . ",\n";
                    } else {
                        $t .= '%S%' x 3 . $port . " => " . $signal . ",\n";
                    }
                }
            } else {
                if ( $lang =~ m,^veri,io ) { #Verilog
                    $t .= '%S%' x 3 . "." . $port . "[" . $ub . ":" . $lb . "](" . $signal . "), " .
                            $tcom . " __W_PORT\n";
                } else {
                    if ( $cast ) {
                        $t .= '%S%' x 3 . $cast . "(" . $port . "(" . $ub . " downto " . $lb . ")  => " .
                            $signal . ", " . $tcom . " __W_PORT\n";
                    } else {
                        $t .= '%S%' x 3 . $port . "(" . $ub . " downto " . $lb . ")  => " .
                            $signal . ", " . $tcom . " __W_PORT\n";
                    }
                }
            }
		} elsif ( $sf =~ m,^\d+$,o and $st =~ m,^\d+$,o and ( $rcm->[$ub] < $sf or $rcm->[$lb] > $st ) ) { #TODO: There could be more cases ???
	    	if ( $ub == $lb ) {
        		if ( $lang =~ m,^veri,io ) { #Verilog
                	$t .= '%S%' x 3 . "." . $port . "[" . $ub . "](" . $signal . "[" . $rcm->[$ub] . "]),\n";
            	} else {
                	if ( $cast ) {
                    	$t .= '%S%' x 3 . $cast . "(" . $port . "(" . $ub . ")) => " .
                        	$signal . "(" . $rcm->[$ub] . "),\n";
                	} else {
                    	$t .= '%S%' x 3 . $port . "(" . $ub . ") => " .
                    	    $signal . "(" . $rcm->[$ub] . "),\n";
                	}
            	}
	    	} elsif ( $pf > $ub or $pt < $lb ) {
            	if ( $lang =~ m,^veri,io ) { #Verilog
                	$t .= '%S%' x 3 . "." . $port . "[" . $ub . ":" . $lb . "](" . $signal . "["
                   	. $rcm->[$ub] . ":" . $rcm->[$lb] . "]),\n";
            	} else {
                	if ( $cast ) {
                    	$t .= '%S%' x 3 . $cast . "(" . $port . "(" . $ub . " downto " . $lb . ")) => " .
                        	$signal . "(" . $rcm->[$ub] . " downto " . $rcm->[$lb] . "),\n";
                	} else {
                    	$t .= '%S%' x 3 . $port . "(" . $ub . " downto " . $lb . ") => " .
                        	$signal . "(" . $rcm->[$ub] . " downto " . $rcm->[$lb] . "),\n";
                	}
            	}
	    	} elsif ( $ub == 0 ) {
                if ( $lang =~ m,^veri,io ) { #Verilog
                    $t .= '%S%' x 3 . "." . $port . "(" . $signal . "[" . $rcm->[$ub] . "]),\n";
                } else {
                    if ( $cast ) {
                        $t .= '%S%' x 3 . $cast . "(" . $port . ") => " .
                            $signal . "(" . $rcm->[$ub] . "),\n";
                    } else {
                        $t .= '%S%' x 3 . $port . " => " . $signal . "(" . $rcm->[$ub] . "),\n";
                    }
                }
	    	} else {
                if ( $lang =~ m,^veri,io ) { #Verilog
                    $t .= '%S%' x 3 . "." . $port . "(" . $signal . "[" . $rcm->[$ub] . ":" . $rcm->[$lb] . "]),\n";
                } else {
                    if ( $cast ) {
                        $t .= '%S%' x 3 . $cast . "(" . $port . " => " .
                            $signal . "(" . $rcm->[$ub] . " downto " . $rcm->[$lb] . "),\n";
                    	} else {
                        	$t .= '%S%' x 3 . $port . " => " .
                            	$signal . "(" . $rcm->[$ub] . " downto " . $rcm->[$lb] . "),\n";
                    	}
                	}
	    		}           
			} else {
            	if ( $lang =~ m,^veri,io ) { # Verilog
                	$t .= '%S%' x 3 . $tcom . "__E_BAD_BOUNDS ." .
                    	$port . "[" . $pf . ":" . $pt . "](" .
                    	$signal . "[" . $sf . ":" . $st . "]),\n";
            	} else {
                	$t .= '%S%' x 3 . $tcom . "__E_BAD_BOUNDS . " .
                    	$port . "(" . $pf . " downto " . $pt . ")" . " => " .
                    	$signal . "(" . $sf . " downto " . $st . "), \n";
                }
	        	$logger->error('__E_PRINT_CONN_MATRIX', "\tUnexpected branch in print_conn_matrix, signal $signal, port $port");
	    	}
        	if ( $signal =~ m,%OPEN(_\d+)?%, ) {
            	if ( $lang =~ m,^veri,io ) {
                	$t =~ s,%OPEN(_\d+)?%(\s*\[[:\w]+?\])?,,g; # Remove %OPEN% aka. open[a:b]
            	} else {
                	$t =~ s,((<=|=>)\s*%OPEN(_\d+)?%)\s*\([\s\w\.]+?\),$1,g; # Remove ( ... ) definitons ...
            	}
        	}
        $t =~ s,(\n)?$,$descr$1, if $descr; # Add ::descr comments ....
		return ( $sortcrit . $t );
    #
    #TODO: catch the most important cases here: XXXX partial connects!
    #
    } else { # Output each single bit!!
		for my $i ( 0..$ub ) {
	    	if ( defined( $rcm->[$i] ) ) {
				if ( $rcm->[$i] == 0 and $sf eq "__UNDEF__" ) {
		    	# signal is bit!
                    if ( $lang =~ m,^veri,io ) { #Verilog
                        $t .= '%S%' x 3 . "." . $port . "[" . $i . "](" . $signal . "),\n";
                    } else {
                        if ( $cast ) {
                            $t .= '%S%' x 3 . $cast . "(" . $port . "(" . $i . ")) => " .
                                $signal . ",\n";
                        } else {
                            $t .= '%S%' x 3 . $port . "(" . $i . ") => " . $signal . ",\n";
                        }
                    }
				} else {
		    	# signal is bus!
                    if ( $lang =~ m,^veri,io ) { #Verilog
                        $t .= '%S%' x 3 . "." . $port . "[" . $i . "](" . $signal . "[" . $rcm->[$i] ."]),\n";
                    } else {
                        if ( $cast ) {
                            $t .= '%S%' x 3 . $cast . "(" . $port . "(" . $i . ")) => " .
                                $signal . "(" . $rcm->[$i] ."),\n";
                        } else {
                            $t .= '%S%' x 3 . $port . "(" . $i . ") => " .
                                $signal . "(" . $rcm->[$i] ."),\n";
                        }
                    }
				}
	    	}
		}
    }
    if ( $signal =~ m,%OPEN(_\d+)?%,o ) {
        # TODO : Verilog???
        if ( $lang =~ m,^veri,io ) {
            $t =~ s,%OPEN(_\d+)?%(\s*\[[:\w]+?\])?,,g; # Remove %OPEN%
        } else {
            $t =~ s,((<=|=>)\s*%OPEN(_\d+)?%)\s*\([\s\w\.]+?\),$1,g; # Remove signal bus splices
        }
    }

    $t =~ s,(\n)?$,$descr$1, if $descr; # Add ::descr comments ....
    return ( $sortcrit . $t );
} # End of print_conn_matrix

#
# compose signal description ( to be used in portmaps)
#
# input:
#	signal name
#	current comment sign
#
# output:
#	text with description
#
# global:
#	%conndb (read)
#	$eh		(read -> output.generate.portdescr
#
#!wig20060117: add the connection number for debugging purposes
#    -> output.generate.portdescr to ... %::connnr% ...
#!wig20060315:	now all input fields from the conndb data are available.
#				plus some specials:
#					::ininst + ::outinst is a list of all instances connected here
#					::inport, ::outport:  all ports connected to that signal
#					::ininpo, ::outinpo:  all instance/ports pairs
sub mix_wr_printdescr($$) {
	my $signal = shift;
	my $tcom   = shift;

	my $descr = '';	
    if ( $eh->get( 'output.generate.portdescr' ) ) {
        # Available fields: %<key from conndb>%, %::ininst%, %::outinst%
        my %tm = ();
		$tm{'%::ininst%'} = '';
		$tm{'%::outinst%'} = '';
        my $sigdata = $conndb{$signal};
        for my $k ( keys ( %$sigdata ) ) {
        	unless ( ref ( $sigdata->{$k} ) ) {
        		# All plain string data:
        		$tm{'%' . $k . '%'} = $sigdata->{$k};
        	} elsif ( $k =~ m/^(::(in|out))$/ ) {
       			for my $i ( @{$sigdata->{$1}} ) {
            		if (exists( $i->{'inst'})) {
            			$tm{'%' . $1 . 'inst%'} .= ' ' . $i->{'inst'};
            		}
            		if ( exists( $i->{'port'} )) {
						$tm{'%' . $1 . 'port%'} .= ' ' . $i->{'port'};
            		}
            		if ( exists( $i->{'inst'} ) and exists( $i->{'port'} ) ) {
            			$tm{'%' . $1 . 'inpo%'} .= ' ' . $i->{'inst'} . '/' . $i->{'port'};
            		}	
        		}
        	}
        }

        $descr = replace_mac( $eh->get( 'output.generate.portdescr' ), \%tm );
        if ( $descr and $descr ne '%EMPTY%' ) {
        	$descr = _mix_wr_descr( 'conn', $conndb{$signal}, $descr, 4, $tcom );
        }
        if ( $eh->get( 'output.generate.portdescrlength' ) =~ m,^(\d+)$, ) { # Limit lenght
            if ( length( $descr )  > $1 ) {
            	# Rework the description line by line
            	my $indent = $eh->get( 'output.generate.portdescrindent' ) . $tcom . ' ';
            	$descr = _mix_wr_shortendescr( $descr, $indent, $1 ); 
            }
        }
        $descr =~ s/$tcom[ \t]*$tcom/$tcom/; #Remove duplicate comments ...
    }

	return $descr;
}

#
# create ::descr if too long,
#   but make sure to not hit <cr> or remove %macro%
#
sub _mix_wr_shortendescr ($$;$) {
	my $descr = shift;
	my $indent = shift;
	my $maxlen = shift;

	unless ( defined( $maxlen ) ) {
		$eh->get( 'output.generate.portdescrlength' ) =~ m,^(\d+)$,;
		$maxlen = $1;
	}
	$indent =~ s/^%CR%//;
	
	my $maxlines = $eh->get( 'output.generate.portdescrlines' );
	$maxlines =~ s/\s+//g;
	$maxlines =~ s/\D.*//;
	
	my @newdescr = ();
	
	$descr =~ s/\n/%CR%/og; # Replace line breaks by %CR%
	# Split into single lines and shorten these!
	for my $line ( split( /%CR%/, $descr )) {
		if ( length( $line ) > $maxlen ) {
			# Needs to be shortened
			my $new = '';
			# Catch embedded %macro% strings:
			while( $line =~ s/^(.*?)(%\w+%)// ) { # Minimal length match
				my $l = length( $new );
				if ( $maxlen - $l < 1 ) {
					last;
				}
				if ( $maxlen - $l < length( $1 ) ) {
					my $a = substr( $1, 0, $maxlen - $l ) . '...';
					$new .= $a;
					last; # We have enough now ...
				} else { 
					$new .= $1 . ( defined( $2 ) ? $2 : '' );
				}
			}
			# Consider rest in $line:
			if ( length( $new ) < $maxlen ) {
				$new .= substr( $line, 0, $maxlen - length( $new )) . '...';
			}
			$line = $new;	
		}
		push( @newdescr, $line );
		if ( scalar( @newdescr ) >= $maxlines ) {
			# Enough lines seen
			push( @newdescr, $indent . '...[cut]...' );
			last;
		} 	
	}
	return join( '%CR%', @newdescr );	
} # End of _mix_wr_shortdescr

#
# Retrieve signal name from signal number
# TODO : increase speed by caching this ...
#
# Input: integer signal number
#
# Output: signal name
#!wig20060308, added primary version
sub _mix_wr_signum2signam ($) {
	my $nr = shift;

	for my $signal ( keys %conndb ) {
		return $signal if ( $conndb{$signal}{'::connnr'} == $nr );
	}

	return undef();

} # End of _mix_wr_signum2signam

#
# create a string to prepend in case user wants unusual sort order
#  %MAPSORT_KEY_KEY_SORTMAP%
# see comments below for list of allowed keywords
#
# input:
#	entity name
#	port name
# output:
#	key to prepend for ordering
# global:
#	$eh (output.generate.portmapsort)
#
sub mix_wr_mapsort ($$) {
	my $e = shift; # entity name 
	my $p = shift; # port

	my $order = $eh->get( 'output.generate.portmapsort' );
	my $so = "%MAPSORT_";
	
	return unless ( $order );
	#!wig20051007: alpha needed for verilog2001
	#!wig20051007: return "" if ( $order eq "alpha" );

	# portmapsort' => 'alpha', # How to sort port map; allowed values are:
	# alpha := sorted by port name (default)
	# input (ordered as listed in input files)
	# inout | outin: seperate in/out/inout seperately; inout will always be in between
	#    can be combined with the "input" key
	# genpost | genpre: generated ports post/pre
	# ::COL : order as in column ::COL (alphanumeric!)
	# TODO: is it I, O or IO here?

	my $g = "0";
	my $m = "i"; # default mode: i
	my $s = 0;
	( $m , $g, $s ) = _mix_wr_is_modegennr( $e, $p ); # is that signal/port generated and i/o here?
	 
	for my $o ( split( /[,\s]+/, $order ) ) {

		#TODO: where to place inout?
		# inout : in  / A -> inout / B -> out / C
		# outin : out / A -> inout / B -> in  / C
		if ( $o =~ m/\binout\b/io ) {
			if ( $m eq "inout" ) {
				$so .= "_B_";
			} elsif ( $m eq "out" ) {
				$so .= "_C_";
			} else {
				$so .= "_A_";
			}
		} elsif ( $o =~ m/\boutin\b/io ) {
			if ( $m eq "inout" ) {
				$so .= "_B_";
			} elsif ( $m eq "out" ) {
				$so .= "_A_";
			} else {
				$so .= "_C_";
			}
		} elsif ( $o =~ m/\binput\b/io ) {
			# Get number of signal ...
			my $format = '_%0' . ( length( $eh->get( 'sum.conn' ) ) + 1 ) . 'd_'; # 
			$so .= 	sprintf( $format, $s );
		} elsif ( $o =~ m/\balpha\b/io ) {
			$so .= "_" . $p . "!_"; # $p is the name of the port ..., ! makes order o.k.
		} elsif ( $o =~ m/(::\w+)\b/io ) {
			# Take content of column ::foo
			# Get signal name (from the signal number)
			my $signal = _mix_wr_signum2signam( $s );
			if ( defined( $signal ) and exists( $conndb{$signal}{$1} ) ) {
				( my $t = $conndb{$signal}{$1} ) =~ s/\W+//g; # Remove no word chars
				$so .= "_" . $t  . "!_"; 					  # ! is the first non-whitespace char! 
			} else {
				$logger->warn('__W_MAPSORT', "\tIllegal sort column for port maps: $1!" );
			}
		} elsif ( $o =~ m/\bgen(erated)?(post|pre)\b/ ) {
			# if generated port
			if ( $2 eq "pre" xor $g ) {
				$so .= "_B_";
			} else {
				$so .= "_A_";
			}
		} 
	}
	
	$so .= "_SORTMAP%";
	return $so;
}

#
# find out the mode (i,o,io) of that port; find if that port is generated
# and also the lowest signal number connected to that port (for sort)
#
# return values:
#	out,in,inout, ....
sub _mix_wr_is_modegennr ($$) {
	my $e = shift || "__E_NO_ENTY";
	my $p = shift;

	my $g = 0;
	my $m = "_E_"; #
	my $s = 0;
	
	my $eh = $entities{$e};
	if ( exists( $eh->{$p} ) ) {
		$g = 1 if ( exists ($eh->{$p}{'__gen__'} ));
		$s = $eh->{$p}{'__nr__'};
		$m = $eh->{$p}{'mode'}; # in, out, inout, %BUFFER%, %TRISTATE%, ....
	}
		#if ( $m =~ m,IO,io ) { $mode = "inout"; } 		# inout mode!
		#elsif ( $m =~ m,B,io ) { $mode = "%BUFFER%"; }	# buffer
		#elsif ( $m =~ m,T,io ) { $mode = "%TRISTATE%"; }	# tristate bus ...
		#elsif ( $m =~ m,C,io ) { $mode = $io; }		# Constant / wig20050202: map to S
		#elsif ( $m =~ m,[GP],io ) {                             # Generic, parameter
        # Read "value" from ...:out
	return( $m, $g, $s )

}	
	
#
# Do the work: Collect ports and generics from %entities.
# Print out and also save port and generics for later reusal (e.g. architecture)
#
sub _write_architecture ($$$$) {
    my $instance = shift;
    my $entity = shift;
    my $filename = shift;
    my $ae = shift;

    my %macros = %{$eh->get( 'macro' )};  # Take predefined macro replacement set
    my $lang = lc($macros{'%LANGUAGE%'}); # Set default language
    my $p_lang = '';
    my $daughter_is_top = 0;
    
    $macros{'%ENTYNAME%'} = $entity;
    if ( $instance ne "__COMMON__" and exists ( $hierdb{$instance}{'::arch'}  ) ) {
	$macros{'%ARCHNAME%'} = $hierdb{$instance}{'::arch'};
		if ( $hierdb{$instance}{'::lang'} ) {
	    	if ( $eh->get( 'template.' . lc($hierdb{$instance}{'::lang'}))) {
				$lang = lc($hierdb{$instance}{'::lang'}); # Change language
	    	}
		}
    } else {
        $macros{'%ARCHNAME%'} = $entity . $eh->get( 'postfix.POSTFIX_ARCH' );
        # For __COMMON__ header only, see below
    }
    if ( -r $filename and $eh->get( 'outarch' ) ne "COMB" ) {
		$logger->warn('__W_WRITE_ARCH', "\tArchitecture declaration file $filename will be overwritten!" );
    }

    # Add header
    my $tpg = $eh->get( 'template.' . $lang . '.arch.body' );

	# Prepare macros:
    $macros{'%VHDL_USE%'} = use_lib( 'arch', $instance );
    #!wig20041110: add includes and defines from ::use column
    $macros{'%INT_VERILOG_DEFINES%'} = use_lib( "veri", $instance );
    # prepare user defined code
    mix_wr_use_udc( 'arch', $instance, \%macros );

	# Start the HDL code
    my $et = replace_mac( $eh->get( 'template.' . $lang . '.arch.head' ), \%macros);    

    my %seenthis = ();
    my $contflag = 0;
    #
    # Go through all instances and generate a architecture for each !entity!
    # $t_inst <- the instance done now
    my @keys = ( $instance eq "__COMMON__" ) ? keys( %$ae ) : ( $instance );
    for my $t_inst ( sort( @keys ) ) {
		# $t_inst is the actual instance name ...
		if ( $t_inst eq "W_NO_ENTITY" ) { next; }; # Should read __W_NO_INSTANCE !
    	if ( $t_inst =~ m/^(__|%)TYPECAST_/ ) { next; };  # Ignore typecast architecture
    	#
		# Do not write architecture for leaf cells ...
		# can be overwritten by setting $eh ... to leaf ...
		if ( $eh->get( 'output.generate.arch' ) =~ m,noleaf,io and
	    	$#{[ $ae->{$t_inst}{'::treeobj'}->daughters ]} < 0 ) {
	    	next;
		}

		# Do not write, if we are a "simple logic" cell
		my $simple_re = $eh->get('output.generate._logicre_');
		if ( $ae->{$t_inst}{'::entity'} =~ m/$simple_re/i ) {
			next;
		}
		$contflag = 1;
		my $aent = $ae->{$t_inst}{'::entity'};
		if ( $aent =~ m,W_NO_ENTITY,io ) { next; };
		my $arch = $ae->{$t_inst}{'::arch'};	

    	my $ilang = lc( $hierdb{$t_inst}{'::lang'} ||$eh->get( 'macro.%LANUAGE%' ) );
    	if ( $p_lang and $p_lang ne $ilang ) {
        	$logger->error('__E_WRITE_ARCH', "\tLanguage mix: $p_lang requeste, but module $t_inst is defined $ilang" );
    	}
    	$p_lang = $ilang;
    	my $tcom = $eh->get( 'output.comment.' . $ilang ) || $eh->get( 'output.comment.default' ) || '##' ;
		$macros{'%ENTYNAME%'}	= $aent;
		$macros{'%ARCHNAME%'}	= $arch . $eh->get( 'postfix.POSTFIX_ARCH' );
    	$macros{'%VERILOG_INTF%'} = $tcom . "\n" .
        	$tcom . " Generated Module " . $t_inst . "\n" . $tcom . "\n"; 
		$macros{'%CONCURS%'}	= _mix_wr_nice_comment( $tcom, 1, 'Generated Signal Assignments' );
		$macros{'%CONSTANTS%'}	= _mix_wr_nice_comment( $tcom, 1, 'Generated Constant Declarations' );
		#
		# Collect components by looking through all our daughters
		#
		$macros{'%COMPONENTS%'} = _mix_wr_nice_comment( $tcom, 1, 'Generated Components' );
		$macros{'%INSTANCES%'}	= _mix_wr_nice_comment( $tcom, 1, 'Generated Instances and Port Mappings' );

		my %seen = ( '%TYPECAST_ENT%' => 1 ); # Never use TYPECAST entity ...
    	my %i_macros = ();
    	my %sig2inst = ();
		my @in= ();
		my @out = ();
        my %nanbounds = ();
		#
		# Inform user about rewrite of architecture for this entity ...
		#
		if ( exists( $seenthis{$aent} ) ) {
	    	$logger->info('__I_WRITE_ARCH', "\tPossibly rewriting architecture for entity $aent, instance $t_inst!" );
		} else {
	    	$seenthis{$aent} = 1;
		}

    	# Is verilog -> get interface for this module
    	if ( $ilang =~ m,^veri,io ) {
        	my $intf = '';
        	my $generics = '';
        	( $intf, $generics ) = mix_wr_get_interface( $entities{$aent}, $aent, $ilang, $tcom, 1 );
        	#!wig20051007: do not indent
        	$intf = $intf . $tcom . " End of generated module header\n";
        	$macros{'%VERILOG_INTF%'} .= $generics . $intf;
    	}

		my $node = $ae->{$t_inst}{'::treeobj'};

		#!wig20060425: get signals and all components used in this instance:
		my ( $in, $out ) = _mix_wr_get_components( $t_inst, $node, $lang, $ilang, $tcom,
				\%seen, \%macros, \%i_macros, \%sig2inst, \%nanbounds );

		push( @out, @$out);
		push( @in,	@$in);

    	# Add constants if defined via %BUS%
    	# Caveat: there should be a one:one mapping of busses and constants here
		# TODO : check this ...
		#!wig20060711: check if signal was defined before
    	if ( exists( $hierdb{'%BUS%'}{'::conn'}{'in'} ) ) {
        	my $ins = $hierdb{'%BUS%'}{'::conn'}{'in'};
        	for my $c ( keys( %$ins ) ) {
            	for my $bus ( keys( %{$ins->{$c}} ) ) {
					# Apply to mother of this instance!
					#!wig20060711: check if this signal exists:
					unless ( exists( $conndb{$bus} ) and exists( $conndb{$bus}{'::topinst'} ) ) {
						$logger->error( '__E_', "\tMISSING signal definition for $bus to be used in %BUS% skipped!" );
						next;
					}
                	if ( $hierdb{$conndb{$bus}{'::topinst'}}{'::treeobj'}->mother eq $node ) {
                    	push( @in, $c );
                	}
            	}
        	}
    	}
            
		#
		# extract >>signals<< from @in and @out array
		#
		my %aeport = ();
		# Uniquify
		for my $ii ( @out ) { $aeport{$ii}{'out'}++; }; # Count subblock out ports
		for my $ii ( @in )   { $aeport{$ii}{'in'}++; };    # Count subblock in ports

        #
        # Check if a signal here has the same name as a port of our entity
        #
        # TODO : Do something with the return value of count_load_driver
        count_load_driver( $t_inst, $aent, $hierdb{$t_inst}{'::conn'}, \%aeport );
        my %sp_conflict = ();
        my %tc_sigs = ();
        if ( $ilang =~ m,^vhdl,io ) { # Make VHDL internal signal ...
            %sp_conflict = signal_port_resolve( $aent, \%aeport );
        }

		my $signaltext;
		my $veridefs = '';
		$signaltext = _mix_wr_nice_comment( $tcom, 1, 'Generated Signal List' );

		for my $t_signal ( sort( keys( %aeport ) ) ) {
	    # $t_signal is signal name

        #
        # If there is no in or out, do nothing here ....
        #
        next unless ( exists( $aeport{$t_signal}{'in'} ) or exists( $aeport{$t_signal}{'out'} ) );
		if ( $t_signal eq '' ) { # ERROR: s.th. bad happened!
			$logger->error('__E_WRITE_ARCH', "\tMIX_INTERNAL_ERROR: empty signal in list for instance $t_inst" );
			next;
		}

        # Skip "open" pseudo-signal
        next if ( $t_signal =~ m,%OPEN(_\d+)?%, );
            
	    my $s = $conndb{$t_signal};
	    my $type = $s->{'::type'};
	    my $high = $s->{'::high'};
	    my $low = $s->{'::low'};
	    # The signal definition should be consistent here!

        # Using %HIGH%, %LOW%, %HIGH_BUS%, %LOW_BUS%
        if ( $t_signal =~ m,^\s*%(HIGH|LOW)_BUS,o ) {
			my $logicv = ( $1 eq 'HIGH' ) ? '1' : '0';
            if ( $ilang =~ m,^veri,io ) {
            	if ( is_integer2( $high, $low ) ) {
                	my $w = $high - $low + 1;
                	$macros{'%CONCURS%'} .= '%S%' x 2 .
                    	'assign' . '%S%' . $t_signal . ' = ' .
                    	$w . "'b" . $logicv x $w . ";\n"; # Added width for Verilog
            	} else {
            		if ( $logicv eq '0' ) {
            			$macros{'%CONCURS%'} .= '%S%' x 2 .
                    		'assign' . '%S%' . $t_signal . ' = ' .
                    			"1'b" . $logicv . ";\n";
            		} else {
            			if ( $low eq '0' ) {
            				$macros{'%CONCURS%'} .= '%S%' x 2 .
                    			'assign' . '%S%' . $t_signal . ' = ' .
                    			'{' . $high . '{1}}' . ";\n";
            			} else {
            				 $macros{'%CONCURS%'} .= '%S%' x 2 .
                    			'assign' . '%S%' . $t_signal . ' = ' .
                    			'{' . $high . ' - ' . $low . '{1}}' . ";\n";
            			}
            		}
            	}
            } else {
            	# VHDL is more easy her
                $macros{'%CONCURS%'} .= '%S%' x 2 .
                    $t_signal . '%S%' . '<=' . '%S%' . "( others => '$logicv' );\n";
            }
	    } elsif ( $t_signal =~ m,^\s*%(HIGH|LOW)(_\d+)?%,o ) {
	    	#TODO: %HIGH% and %LOW% will be mapped to a single value
	    	my $logicv = ( $1 eq 'HIGH' ) ? '1' : '0';
                if ( $ilang =~ m,^veri,io ) {
                    $macros{'%CONCURS%'} .= '%S%' x 2 .
                        'assign' . '%S%' . $t_signal . " = 1'b" . $logicv . ";\n";
                } else { # VHDL
                    $macros{'%CONCURS%'} .= '%S%' x 2 .
                         $t_signal . '%S%' . '<=' . '%S%' . "'$logicv';\n";
                }
	    }

            # If signal $t_signal  has no load here and it's top level module (::topinst) is
            # one of our daughter's, leave it open...
            # if ( $dname eq $conndb{$t_inst}{'::topinst'} ) { $daughter_is_top++; }
            #!wig20031010
            my $port_open='';
            if ( $aeport{$t_signal}{'load'} == 0 and $eh->get( 'check.signal' ) =~ m/\btop_open/io ) {
                unless ( $t_signal =~ m,^\s*%(HIGH|OPEN|LOW), ) { #Meta signals %HIGH... %LOW, ... %OPEN
                    if ( exists $conndb{$t_signal}{'::topinst'} and $conndb{$t_signal}{'::topinst'} and
                    	 $node == $hierdb{$conndb{$t_signal}{'::topinst'}}{'::treeobj'}->mother ) {
                        $logger->warn('__W_WRITE_ARCH', "\tLeave unloaded port $t_signal open at instance $t_inst");
                        $eh->inc( 'sum.openports' );
                        # Will map to open ...
                        $port_open = $tcom . "  __I_OUT_OPEN ";
                        if ( exists( $sp_conflict{$t_signal} ) ) {
                            $logger->error('__WRITE_ARCH', "\tBAD_BRANCH for $t_signal, no load on port! File bug report!");
                        }
                        $sp_conflict{$t_signal} = "__open__"; # Map that signal to open ...
                    }
                }
            }
            #!wig20060425: leave undriven ports open, too ...
            if ( $aeport{$t_signal}{'driver'} == 0 and $eh->get( 'check.signal' ) =~ m/\btop_nodriver/io ){
            	unless ( $t_signal =~ m,^\s*%(HIGH|OPEN|LOW), ) { #Meta signals %HIGH... %LOW, ... %OPEN
					# CONST currently have not ::topinst!
                    if ( exists $conndb{$t_signal}{'::topinst'} and $conndb{$t_signal}{'::topinst'} and
                    	 $node == $hierdb{$conndb{$t_signal}{'::topinst'}}{'::treeobj'}->mother ) {
                        $logger->warn('__W_WRITE_ARCH', "\tLeave undriven port $t_signal open at instance $t_inst");
                        $eh->inc( 'sum.nodriverport' );
                        # Will map to __nodrv__ ...
                        $port_open = $tcom . ' __I_NODRV_I ';
                        if ( exists( $sp_conflict{$t_signal} ) ) {
                            $logger->error('__WRITE_ARCH', "\tBAD_BRANCH for $t_signal, no driver on port! File bug report!");
                        }
                        $sp_conflict{$t_signal} = '__nodrv__'; # Map that signal to be undriven ...
                    }
                }
            }

            my ( $dt, $dc ) = mix_wr_fromto( $high, $low, $ilang, $tcom );
            $dt .= $dc;

	    	# Add constant definitions here to concurrent signals ....
	    	# $dt has full signal width definition ...
	    	#20040730: allow to assign constants to bus splices
	    	#!wig20050720: if ( $s->{'::mode'} =~ m,C,io ) {
	    	#!wig20050930: if ::in->[0]->{inst} is __BUS__ -> stop here
            my $no = 0;
            my $busref = 0;
            for my $o ( @{$s->{'::out'}} )  {
                my ( $si, $a, $d ) = _write_constant( $no, $o, $s, $type, $dt, $ilang );
                $signaltext .= $si;                    # add to signal declaration ...
                $veridefs .= $d;                       # Verilog defines
                $macros{'%CONCURS%'} .= $a;  # add to signal assignment
                # Increment only if detected a signal ...
                $no++ if ( exists( $o->{'rvalue' } ) and $o->{'rvalue'} ne '' );
                $busref++ if (
                  	exists( $s->{'::in'} ) and
                   	exists( $s->{'::in'}[0] ) and
                   	exists( $s->{'::in'}[0]{'inst'}) and
                   	$s->{'::in'}[0]{'inst'} eq '__BUS__' ); # Only for ONE __BUS__
                }
                next if $busref; # Skip if only busref!
                # next; #TODO: continue here -> ::out has rvalue, ignore below ...
	    		#!wig20050720: }

	    		# Generics and parameters: Not needed here
	    		if ( $s->{'::mode'} =~ m,\s*[GP],io ) {
                	next;
	    		}

    	# Now deal with the ports, that are read internally, too:
        # Or output ports, that are left open here ... (if value is open)
	    # Generate intermediate signal
	    #Caveat: $t_signal is a signal name, while sp_conflict references a port name,
	    #   which could happen to be the same thing ...
        my $usesig = $t_signal; 
	    if ( exists( $sp_conflict{$t_signal} ) ) {
            $usesig = $sp_conflict{$t_signal};
            # Redo all generated maps of my subblocks to use the internal signal name ....
            for my $insts ( @{$sig2inst{$t_signal}} ) {
                # TODO : is that the final idea? Maybe splitting gen_map
                # in two parts makes it better
                # Port name might be not equal signal name here (generated port!)
                my $pm = $i_macros{'%INST_' . $insts . '%'};
                if ( $ilang =~ m,^veri,io ) {
                    # Strip away the signal $t_signal
                    if ( $usesig eq '__open__' ) {
                        $pm =~ s!(\.\w+?)\(\s*$t_signal\s*(\[.+?\])?\s*\)!$1()!g;
                        if ( exists( $hierdb{$insts}{'::reconnections'} ) ) {
                            # Maybe name will be changed here ... comment out port => open
                            for my $pstr ( keys( %{$hierdb{$insts}{'::reconnections'}} ) ) {
                                $pm =~ s!(\.$pstr\s*\(\))!$tcom __I_RECONN_O $1!g;
                            }
                        }
                    } elsif ( $usesig eq '__nodrv__' ) {
                    	#!wig20060426: handle undriven ports ....
                    	#  prepend __I_NODRV_I
                    	# $pm =~ s!(\.\w+?)\(\s*$t_signal\s*(\[.+?\])?\s*\)!$tcom __I_NODRV_I $1()!g;
                    	$pm =~ s!(\.\w+?\(\s*$t_signal\s*)!$tcom __I_NODRV_I $1/__nodrv__!g;
                        if ( exists( $hierdb{$insts}{'::reconnections'} ) ) {
                            # Maybe name will be changed here ... comment out port => open
                            for my $pstr ( keys( %{$hierdb{$insts}{'::reconnections'}} ) ) {
                                $pm =~ s!(\.$pstr\s*\(\))!$tcom __I_RECONN_I $1!g;
                            }
                        }
                    }else {
                        $pm =~ s!(\.\w+?)\(\s*$t_signal(\s*\[.+?\])?\s*\)!$1($usesig$2)!g;
                    }
                } else {
                #!wig20031014: add -- as allowed continuation after the signal name!
                #   port => signal,
                #   port => signal, -- comment
                #   port => signal( ....
                #   port => signal\n
                    $pm =~ s!(\w*)(\s+=>\s+)$t_signal(\s*(\(|,|\n|--))!$1$2$usesig$3!g; 
                    if ( $usesig eq '__open__' ) {
                        $pm =~ s!(\s+=>\s+)__open__    # Has __open__ in it
                            (\s*$RE{balanced}{-parens=>'()'})?
                            (.*)                                        # Rest of line
                            !${1}open$3 $tcom __I_OUT_OPEN!gx;
                        # Strip out ( N downto M )
                        # $pm =~ s!__open__!open!g;
                        if ( exists( $hierdb{$insts}{'::reconnections'} ) ) {
                            # Maybe name will be changed here ... comment out port => open
                            for my $pstr ( keys( %{$hierdb{$insts}{'::reconnections'}} ) ) {
                                $pm =~ s!($pstr\s+=>\s+open)!$tcom __I_RECONN $1!g;
                            }
                        }
                    } elsif ( $usesig eq '__nodrv__' ) {
                        $pm =~ s!(\S+)(\s+=>\s+)__nodrv__    # Has __nodrv__ in it
                            ((\s*$RE{balanced}{-parens=>'()'})?)
                            (.*)                                        # Rest of line
                           !$tcom __I_NODRV_I $1$2 __nodrv__/$t_signal$3$5!gx;
                        # TODO: simplify this: Strip out ( N downto M )
                        # $pm =~ s!__open__!open!g;
                        if ( exists( $hierdb{$insts}{'::reconnections'} ) ) {
                            # Maybe name will be changed here ... comment out port => open
                            for my $pstr ( keys( %{$hierdb{$insts}{'::reconnections'}} ) ) {
                                $pm =~ s!($pstr\s+=>\s+open)!$tcom __I_RECONN $1!g;
                            }
                        }
                    }
                }
                $i_macros{'%INST_' . $insts . '%'} = $pm;
             }
	    }

        # TODO is that the final idea? Maybe splitting gen_map
        # in two parts makes it better
	    # Add signal just if this signal is not routed up (outside) ..
	    # Inside the loop we look if the signal name equals the entity definition ..
	    # TODO Handle bit slices!!! Bring that to subroutine!!!
	    my $pre = '';
	    my $post = '';
	    my $iconn = $hierdb{$t_inst}{'::conn'};

        # Iterate through all signals connected here ...
        # Generate an assignment if
        #   -- signal not used internally
        #   -- signal name ne port name (if exists)
        # Add signal to this architecture signal list, if there is no
        #   port hooked to that signal
        #
        # Iterate through all ports connected to this signal
        # In has precedence.
        # TODO : What if both in and out exists?
        #   What if signal is connected to multiple ports:
        my $match_port_signal = 0; # Remember port and signal even with different cases (Verilog)
        unless( $t_signal =~ m/%(HIGH|LOW|OPEN)(_BUS)?%/o ) {
			if ( exists( $iconn->{'in'}{$t_signal} ) ) {
				# Special case: 1:1 connection, but different cases in Verilog
				if ( $ilang =~ m/^veri/io and
						scalar( keys( %{$iconn->{'in'}{$t_signal}} ) ) == 1 ) {
					my $port = (keys( %{$iconn->{'in'}{$t_signal}} ))[0];
					if ( lc( $usesig ) ne lc ( $port ) ) {
						$pre = '';
			    		$post = "$tcom __W_PORT_SIGNAL_MAP_REQ";
                       	my $concurs = gen_concur_port( 'in', $t_inst, $aent, $t_signal, $usesig, $port, $iconn, $aeport{$t_signal}, $ilang, $tcom );
			    		$macros{'%CONCURS%'} .= $concurs;
					} else {
						$match_port_signal = 1;
					}
				} else { 
		    		foreach my $port ( keys( %{$iconn->{'in'}{$t_signal}} ) ) {
						if ( $usesig ne $port ) {
			    			$pre = '';
			    			$post = "$tcom __W_PORT_SIGNAL_MAP_REQ";
                        	my $concurs = gen_concur_port( 'in', $t_inst, $aent, $t_signal, $usesig, $port, $iconn, $aeport{$t_signal}, $ilang, $tcom );
			    			$macros{'%CONCURS%'} .= $concurs;
						}
					}
    		    }
			}
			if ( exists( $iconn->{'out'}{$t_signal} ) ) {
				if ( $ilang =~ m/^veri/io and
						scalar( keys( %{$iconn->{'out'}{$t_signal}} ) ) == 1 ) {
					my $port = (keys( %{$iconn->{'out'}{$t_signal}} ))[0];
					if ( lc( $usesig ) ne lc ( $port ) ) {
						$pre = '';
			    		$post = "$tcom __W_PORT_SIGNAL_MAP_REQ";
                    	my $concurs = gen_concur_port( 'out', $t_inst, $aent, $t_signal, $usesig, $port, $iconn, $aeport{$t_signal}, $ilang, $tcom );
			    		$macros{'%CONCURS%'} .= $concurs;
					} else {
						$match_port_signal = 1;
					}
				} else { 
		    		foreach my $port ( keys( %{$iconn->{'out'}{$t_signal}} ) ) {
						if ( $usesig ne $port ) {		    
			    			$pre = '';
			    			$post = "$tcom __W_PORT_SIGNAL_MAP_REQ";
                    		my $concurs = gen_concur_port( 'out', $t_inst, $aent, $t_signal, $usesig, $port, $iconn, $aeport{$t_signal}, $ilang, $tcom );
			    			$macros{'%CONCURS%'} .= $concurs;
						}
		    		}
		    	}
			}
	    }

	    # Add signal definition if required:
        my $tmp_sig = '';
        if ( $usesig ne $t_signal ) {
			$usesig = $t_signal if ( $usesig eq '__open__' or $usesig eq '__nodrv__' );
            # Use internally generated signalname ....
            $tmp_sig .= ( $ilang =~ m,^veri,io ) ?
                ( $pre . 'wire' . '%S%' . $dt . '%S%' . $usesig .
            	"; $post $tcom __W_BAD_BRANCH\n" ) :
                ( $pre . 'signal' . '%S%' . $usesig . '%S%' . ': '
               	. $type . $dt . '; ' . $post . "\n" );
        } elsif ( exists( $iconn->{'out'}{$t_signal} ) or
                  exists( $iconn->{'in'}{$t_signal} ) ) {
            unless( $match_port_signal or exists( $entities{$aent}{$t_signal} ) ) {
                $tmp_sig .= ( $ilang =~ m,^veri,io ) ?
                    ( $pre . 'wire' . '%S%' . $dt . '%S%' . $usesig . 
                   	'; ' . $post . "\n" ) :
                    ( $pre . 'signal' . '%S%' . $usesig . '%S%' . ': '
                   	. $type . $dt . "; " . $post . "\n" );
            }
        } else {
                # Not connected to upside world (needs wire/signal definition ...
                if ( $ilang =~ m,^veri,io ) {
                    $tmp_sig .= $pre . 'wire' . '%S%' . $dt . '%S%' . $usesig .
                    	'; ' . $post . "\n";
                } else {
                    $tmp_sig .= $pre . 'signal' . '%S%' . $usesig . '%S%' .
                    	': ' . $type. $dt . '; ' . $post . "\n";
                }
        }
        $signaltext .= '%S%' x 2 . $port_open . $tmp_sig if ( $tmp_sig );

	} # End for $t_signal / signal

	#
	# Adding constant definitions for nan bounds signals ...
	#
        my %parms = ();
        for my $ii ( keys( %nanbounds ) ) {
            for my $iii ( values( %{$nanbounds{$ii}} ) ) {
                my $high = $iii->[1];
                my $low = $iii->[2];
                while( $high =~ m,(\w+),g ) { # Get all words in the high/low definition
                    next if ( exists( $parms{$1} ) );
                    if ( exists( $conndb{$1} )  and $conndb{$1}{'::mode'} eq "P" ) {
                        $macros{'%CONSTANTS%'} .= "\t\tconstant " . $1 . " : " .
                            $conndb{$1}{'::type'} . " := " . $conndb{$1}{'::out'}[0]{'value'} .
                            "; -- __I_PARAMETER\n";
                        $parms{$1} = 1;
                    }
                }
                while( $low =~ m,(\w+),g ) { # Get all words in the high/low definition
                    next if ( exists( $parms{$1} ) );
                    if ( exists( $conndb{$1} )  and $conndb{$1}{'::mode'} eq "P" ) {
                        $macros{'%CONSTANTS%'} .= "\t\tconstant " . $1 . " : " .
                            $conndb{$1}{'::type'} . " := " . $conndb{$1}{'::out'}[0]{'value'} .
                            "; -- __I_PARAMETER\n";
                        $parms{$1} = 1;
                    }
                }
            }
        }
        
		# End is near for write_architecture ...
		$signaltext .= _mix_wr_nice_comment( $tcom, 1, 'End of Generated Signal List' );
		$macros{'%SIGNALS%'} = $signaltext;

		#Workaround:  magma and configuration as module names: wig20040322
        $veridefs .= $eh->get( 'output.generate.workaround._magma_uamn_' );
        $macros{'%INT_VERILOG_DEFINES%'} .= $veridefs if ( $veridefs );

        $eh->set( 'output.generate.workaround._magma_uamn_', '' ); # Reset the define storage
        
        if ( keys( %i_macros ) > 0 ) {
            $macros{'%INSTANCES%'} = replace_mac( $macros{'%INSTANCES%'}, \%i_macros );
        }
		$et .= replace_mac( $tpg, \%macros );
    }

    return unless ( $contflag ); #Print only if you found s.th. to print

    $et .=  $eh->get( 'template.' . $lang . '.arch.foot' );

    $et = replace_mac( $et, \%macros );

    $et = strip_empty( $et );

    #
    # Write here
    #
    my $write_flag = $eh->get( 'outarch' );
    # Are we in verify mode?
    # Not possible in __COMMON__ mode
    if ( $instance ne '__COMMON__' and $eh->get( 'check.hdlout.path' ) and
        $eh->get( 'check.hdlout.mode' ) =~ m,\b(arch|mod|head|all),io ) { # Selected ...
            # Append check flag ...
        if ( $eh->get( 'check.hdlout.mode' ) =~ m,\bleaf,io ) {
                # __LEAF__ is 1 if this is not a LEAF!
                $write_flag .= ( $entities{$entity}{'__LEAF__'} == 0 ) ? '_CHK_ARCH_LEAF' : '';
        } else {
                $write_flag .= ( $entities{$entity}{'__LEAF__'} == 0 ) ? '_CHK_ARCH_LEAF' : '_CHK_ARCH';
        }
    }
    
    # Do not write, if we are a "simple logic" cell
    my $simple_re = $eh->get('output.generate._logicre_');
	if ( $instance ne '__COMMON__' and
		 $ae->{$instance}{'::entity'} =~ m/$simple_re/i ) {
		$write_flag = 0;
	}

    my $fh = undef();
    unless( $fh = mix_utils_open( $filename, $write_flag ) ) {
        $logger->warn( '__W_WRITE_ARCH', "\tCannot open file $filename to write architecture declarations: $!" );
        return;
    }

    mix_utils_print( $fh, $et );

    mix_utils_close( $fh, $filename );

} # End of _write_architecture

#
# Create a nicely formatted comment
#!wig20060426/added
sub _mix_wr_nice_comment ($$$) {
	my $tcom	= shift;	# Verilog or VHDL comment to use
	my $indent	= shift;	# indent level
	my $text	= shift;	# text to comment

	my $comment =	'%S%' x $indent . $tcom . "\n";
	$comment .= 	'%S%' x $indent . $tcom . ' ' . $text . "\n";
	$comment .= 	'%S%' x $indent . $tcom . "\n";
	
	return $comment;
	 	
} # End of _mix_wr_nice_comment
	
#
# Create components, portmaps, ... for daughter modules
#
# Global variables:
#	%entities
#	%hierdb
#	
# Side effects:
#	modifies \%macro, \%i_macros, \%sig2inst, \%nanbounds
#
#!wig20060425, spliced out from _write_architecture
sub _mix_wr_get_components ($$$$$$$$$$) {
	my $instance = shift;
	my $node	= shift;
	my $lang	= shift;
	my $ilang	= shift;
	my $tcom	= shift;
	my $seen	= shift;
	my $macros	= shift;
	my $i_macros = shift;
	my $sig2inst = shift;
	my $nanbounds = shift;
	
	my @out = ();
	my @in  = ();
	
	for my $daughter ( sort( { $a->name cmp $b->name } $node->daughters ) ) {
	   	my $d_name = $daughter->name;
        # need full access to hierdb here (makes $ae somehow useless)
	   	my $d_enty = $hierdb{$d_name}{'::entity'};

	   	#
	   	# Component declaration, relies on results found in _write_entities
	   	# do it only once ....
       	#wig20030228: do not add empty generics or port lists
       	#wig20040804: %TYPECAST_N% creates a typecasted signal assignment 
        	
	    unless ( exists( $seen->{$d_enty} )) {
            unless ( exists( $entities{$d_enty}{'__PORTTEXT__'}{$ilang}  ) and
                exists( $entities{$d_enty}{'__GENERICTEXT__'}{$ilang} ) ) {
                # Have not made interface in that language, ...
                my ( $d_port, $gt );
                ( $d_port, $gt ) = mix_wr_get_interface( $entities{$d_enty}, $d_enty, $ilang, $tcom, 2 );
                if ( is_comment( $d_port, $ilang ) ) {
                    $entities{$d_enty}{'__PORTTEXT__'}{$ilang} = $d_port;
                } else {
                    $d_port = '%S%' x 2 . $tcom . " Generated Port for Entity $d_enty\n" . $d_port;
                    $d_port =~ s/;((%S%|\s)*$tcom.*\n)$/$1/i;
                    $d_port =~ s/;\n$/\n/i;
                    $d_port .= '%S%' x 2 . $tcom . " End of Generated Port for Entity $d_enty\n";
                    $entities{$d_enty}{'__PORTTEXT__'}{$ilang} = $d_port;
                }
                if ( is_comment( $gt, $ilang ) ) {
                    $gt = '%S%' x 2 . $tcom . " Generated Generics for Entity $d_enty\n" . $gt;            
                    $gt =~ s/;((%S%|\s)*$tcom.*\n)$/$1/i; # Remove trailing ; for VHDL
                    $gt =~ s/;\n$/\n/i;
                    $gt .= '%S%' x 2 . $tcom . " End of Generated Generics for Entity $d_enty\n";
                    # Store ports and generics for later reusal
                    $entities{$d_enty}{'__GENERICTEXT__'}{$ilang} = $gt;
                } else {
                    $entities{$d_enty}{'__GENERICTEXT__'}{$ilang} = $gt;
                }
            }
            
            # %COMPONENTS% are VHDL entities ..
            #wig20030711: do not print component if user sets %NO_COMP% flag in ::use
            my $simple_re = $eh->get('output.generate._logicre_');
            if ( defined( $hierdb{$d_name}{'::use'}) and
                $hierdb{$d_name}{'::use'} =~ m,(NO_COMP|__NOCOMPDEC__),o ) {
                    $macros->{'%COMPONENTS%'} .= '%S%' x 2 . $tcom .
                    	'__I_COMPONENT_NOCOMPDEC__ ' . $d_name . "\n\n";
            } elsif ( $d_enty =~ m/$simple_re/i ) {
           		#!wig20050414: simple logic -> no component declaration
                $macros->{'%COMPONENTS%'} .= '%S%' x 2 . $tcom . '__I_SIMPLE_LOGIC__ ' .
                    $d_name . "\n\n";
            } else {
                $macros->{'%COMPONENTS%'} .= '%S%' x  1 . 'component ' . $d_enty .
                    _mix_wr_descr( 'hier', $hierdb{$d_name}, $hierdb{$d_name}{'::descr'}, 3, $tcom ) .
                    "\n" .
		        	( ( not is_vhdl_comment( $entities{$d_enty}{'__GENERICTEXT__'}{$ilang} ) ) ?
                    ( '%S%' x 2 . "generic (\n" . $entities{$d_enty}{'__GENERICTEXT__'}{$ilang} .
                           '%S%' x 2 . ");\n"
                        ) :
                            ( '%S%' x 2 . $tcom . " No Generated Generics\n" .
                              $entities{$d_enty}{'__GENERICTEXT__'}{$ilang}
                            )
			         ) .
                     ( ( not is_vhdl_comment( $entities{$d_enty}{'__PORTTEXT__'}{$ilang} ) ) ?
                        ( '%S%' x 2 . "port (\n" . $entities{$d_enty}{'__PORTTEXT__'}{$ilang} .
                            '%S%' x 2 . ");\n"
                         ) :
                         ( '%S%' x 2 . $tcom . " No Generated Port\n" .
                           $entities{$d_enty}{'__PORTTEXT__'}{$ilang}
                         )
                    ) .
			        '%S%' x 1 . "end component;\n" . '%S%' x 1 .
			        $tcom . " ---------\n\n";
                }
                $seen->{$d_enty} = 1;
	    } else {
            # Is multiple usage of a instance permitted?
            if ( $d_enty ne '%TYPECAST_ENT' and $eh->get( 'check.inst' ) !~ m,\bnomulti\b,io ) {
                $macros->{'%COMPONENTS%'} .=
                   '%S%' x 2 . $tcom . "__I_COMPONENT_REUSE: multiple instantiations of component " .
                    $instance . ", declaration for entity " . $d_enty . " already added!\n";
                $logger->warn('__W_WRITE_ARCH', "\tMultiple instantiations of entity $d_enty");
            }
	    }

	    #
	    # Instances: generate an instance port map for each of our children
	    # and returns a list of in/out signals
	    #
	    my( $imap, $r_in, $r_out );
	    ( $imap, $r_in, $r_out ) = gen_instmap( $d_name, $lang, $tcom );
	    if ( exists( $hierdb{$d_name}{'::nanbounds'} ) ) {
                $nanbounds->{$d_name} = $hierdb{$d_name}{'::nanbounds'};
	    }
	    
	    $macros->{'%INSTANCES%'} .= "%INST_" . $d_name . "%\n";
        $i_macros->{'%INST_' . $d_name . '%'} = $imap;

        for my $s ( @$r_in, @$r_out ) {
            push( @{$sig2inst->{$s}}, $d_name );
        }
	    push( @in, @$r_in ) if scalar( @$r_in );
	    push( @out, @$r_out ) if scalar( @$r_out );
            
	} # end of: for my $daughter
	return( \@in, \@out );
} # End of _mix_wr_get_components

#
# return a string  like  (N downto M) or verilog equiv.
#   a second return value could be a comment in case some unusual things happen
#
sub mix_wr_fromto ($$$$) {
    my $high = shift;
    my $low = shift;
    my $ilang = shift;
    my $tcom = shift;

    my $dt = "";
    my $dc = "";

	if ( defined( $high ) and defined( $low ) ) {
        if ( $ilang =~ m,^veri,io ) {
            if ( $high =~ m/^\d+$/o and $low =~ m/^\d+$/o ) {
                # if ( $low < $high ) {
                $dt = '[' . $high . ':' . $low . ']'; # TODO : Consider all case in Verilog
                # } elsif ( $low > $high ) {
                #    $dt = "($high to $low . "]";
                # } else {
                #    $dt = " -- __W_SINGLE_BIT_BUS";
                # }
            } elsif ( $high ne '' ) {
                if ( $high ne $low ) {
                    $dt = '[' . $high . ':' . $low . ']'; # String used as high/low bound
                } else {
                    $dt = '[' . $high . '] ';
                    $dc = ' ' . $tcom . ' __W_HIGHLOW_EQUAL';
                }
            }
        } else {
            if ( $high =~ m/^\d+$/o and $low =~ m/^\d+$/o ) {
               if ( $low < $high ) {
                    $dt = "($high downto $low)";
               } elsif ( $low > $high ) {
                    $dt = "($high to $low)";
               } elsif ( $high > 0 ) {
                    $dt = "($high)";
                    $dc = ' ' . $tcom . ' __W_SINGLE_BIT_BUS';
               } else {
                    $dt = '';
                    $dc = ' ' . $tcom . ' __W_SINGLE_BIT_BUS';
               }
            } elsif ( $high ne '' ) {
                if ( $high ne $low ) {
                    $dt = "($high downto $low)"; # String used as high/low bound
                } else {
                    $dt = "($high) ";
                    $dc = ' ' . $tcom . ' __W_HIGHLOW_EQUAL';
                }
            }
        }
	}

	return $dt, $dc;
}

#
# Calculate port width ...
#  input: portdescription ..
#
sub mix_wr_getpwidth ($) {
    my $spd = shift;

    my $w = $spd->{'port_f'} - $spd->{'port_t'} + 1;

    return $w;
}

#
# Print out constant definitions:
#
#  constant NAME : $TYPE := VALUE;
#  + additional signal assignment
#  Currently we pass through the value nearly literally!
#
# Special cases
#20030710: adding Verilog support ...
#20040730: changed interface: add out
sub _write_constant ($$$$$;$) {
    my $n = shift;		  # counter t uniquify the generated constant name
    my $out = shift;      # constant description
    my $s    = shift;     # ref to signal definition
    my $type = shift;     # type of this constant 
    my $dt = shift;       # has predefined (F downto T) # unused now ...
    my $lang = shift || $eh->get( 'macro.%LANGUAGE%' ) || 'vhdl';

    my $tcom = $eh->get( 'output.comment.' . $lang ) ||
    		$eh->get( 'output.comment.default' ) || '##';
    
    my $t     = '';     # Signal definitions
    my $sat   = '';     # Signal assignments
    my $def   = '';     # Take `defines
    my $comm  = '';   	# Comments
    my $width = '__E_WIDTH_CONST';

    #TODO: remove this dead code?
    unless( exists( $out->{'rvalue'} ) ) {
            if ( $out->{'inst'} =~ m,(__|%)CONST(__|%),io ) {
                $logger->warn('__W_WRITE_CONSTANT', "\tMissung value definition for constant $s->{'::name'}" );
                $t = '%S%' x 2 . $tcom .  $s->{'::name'} . " <= __W_MISSING_CONST_VALUE;\n";
            }
    } else {
		my $value = $out->{'rvalue'};

	#
    # Caveat: Keep the RE here in sync with MixParser::_create_conn
    #
    # Get VHDL constants : B#VAL#
    # $d =~ m,^(%(CONST|GENERIC|PARAMETER)%/)?(\d+#[_a-f\d]+#)\s*$,io o
    # or 0xHEX or 0b01xzhl or 0777 or 1000 (integers)
    # $d =~ m,^(%(CONST|GENERIC|PARAMETER)%/)?(0x[_\da-f]+|0b[_01xzhl]+|0[_0-7]+|[\d][._\d]*)\s*$,io or
    # or reals or time definitions: ... 1 ns, 1.3 ps ...
    # $d =~ m,^(%(CONST|GENERIC|PARAMETER)%/)?([+-]*[_\d]+\.*[_\d]*(e[+-]\d+)?\s*([munpf]s)?)\s*$,io or
    # or anything in ' text ' or " text "
    # $d =~ m,^(%(CONST|GENERIC|PARAMETER)%/)?((['"]).+\4)\s*$,io or
    # $d =~ m,^(%(CONST|GENERIC|PARAMETER)%/)?(".+")\s*$,io or
    # or anything following a %CONST%/ or GENERIC or PARAMETER keyword
    # $d =~ m,^(%(CONST|GENERIC|PARAMETER)%/)(.+)\s*,io
    #TODO: Add conversion functions ... make sure to use " and ' appr.
        
    if ( $value =~ m,([+-]*[_\d]+\.*[_\d]*(e[+-]\d+)?)(\s*)([munpf]s),io ) {
            # It's a time constant
            # Add a space before "s"
            if ( $3 eq '' ) {
                $value = $1 . ' ' . $4;
            }
            if ( $lang =~ m,^veri,io ) {
                $logger->warn( '__W_WRITE_CONSTANT', "\tCannot handle time constant $value in verilog mode!" );
            }
            #TODO: Check if type is time ...
        } elsif ( $value eq '0' or $value eq '1' ) {
            # Bind a vector to 0 or 1
            if ( $lang =~ m,^veri,io ) {
                $value =  "1'b" . $value; # Gives 1'b0 or 1'b1 ....
            } else {
                if ( $s->{'::type'} =~ m,_vector$,io and $out->{'port_f'} ne '0' ) {
                    $value = "( others => '$value' )"; ##VHDL, only
                } else {               
                    $value = "'" . $value . "'"; # Put ' around bit vectors, VHDL
                }
            }
        } elsif (  ( $value =~ m,^\s*0,io or
                    $value =~ m,^\s*[_\d+]+\s*$,io or
                    $value =~ m,^\s*\d+#[_a-f\d]+#,io ) and
                    $type =~m,std_.*_vector,io
                  ) {
                #
                # If value !~ 010101 and type equal std_ulogic_vector ->
                #  convert value to binary!
                # Not necessary for Verilog!
                $comm = ' ' . $tcom . ' __I_ConvConstant: ' . $value;
                #!wig20040730: improve ...
               # my $w = $s->{'::high'} - $s->{'::low'} + 1; #Will complain if high/low not
                                # defined or not digits!
                my $w = mix_wr_getpwidth( $out );
 
                    if ( $value =~ m,^\s*(\d+)#([_a-f\d]+)#,io ) {
                        if ( $1 == 16 ) {
                            $value = '0x' . $2;
                            $value = hex( $value );
                        } elsif ( $1 == 8 ) {
                            $value = '0' . $2;
                            $value = oct( $value );
                        } elsif ( $1 == 2 ) {
                            $value = oct( '0b' . $2 );
                        } else {
                            $logger->warn( '__W_WRITE_CONSTANT', "\tCannot cope with base $1 for constant $value!" );
                            $w = '';
                        }
                    }

                if ( $value =~ m,^\s*0, ) {
                    $value = oct( $value );
                }
                if ( $w ) {
                    $value = sprintf( '%0' . $w . 'b', $value );
                    if ( length( $value ) > $w +2 ) {
                        $logger->warn('__W_WRITE_CONSTANT', "\tConstant value $comm to large for signal $s->{'::name'} of $w bits!" );
                        $comm = ' ' . $tcom . ' __E_VECTOR_WIDTH ' . $comm;
                    }
                    $width = $w; # Save width ....
                    if ( $lang =~ m,^veri,io ) {
                        $value = $w . "'b" . $value; ## TODO : Streamline that !!
                    } else {
                        $value = '"' . $value . '"';
                    }
                }
            
        } elsif ( $value =~ m,^\s*0x([0-9a-f]),io ) {
            # Convert 0xHEXV to 16#HEXV# (VHDL) or 'hHEXV (Verilog)
            $comm = ' ' . $tcom . " __I_ConvConstant2:" . $value;
                if ( $lang =~ m,^veri,io ) {
                    #!wig20040329: Add width of constant:
                    $value =~ s,^\s*0x,'h,; # syntax highlight colors with a '
                    ( my $l = $value ) =~ s,_,,g;
                    $value = ( length( $l ) - 2 ) . $value;
                } else {
                    $value =~ s,^\s*0x,16#,;
                    $value =~ s,\s*$,#,;
                }

	} elsif ( $value =~ m,^\s*0b([01_]),io ) {
            # Convert 0bBINV to 2#BINV# (VHDL) or 'bBINV (Verilog)
                $comm = " " . $tcom . " __I_ConvConstant3:" . $value;
                if ( $lang =~ m,^veri,io ) {
                    $value =~ s,^\s*0b,'b,; # syntax highlight colors with a '
                    ( my $l = $value ) =~ s,_,,g;
                    $value = ( length( $l ) - 2 ) . $value;
                } else {
                    $value =~ s,^\s*0b,2#,;
                    $value =~ s,\s*$,#,;
                }
	} elsif ( $type =~ m,_vector,io ) {
            # Replace ' -> "
            $comm = " " . $tcom . " __I_VectorConv";
            $value =~ s,',",go; 		# '
            if ( $lang =~ m,^veri,io) {
                $value =~ s,['"],,go; 	# '
                # $value = "'d" . $value; # Decimal values assumed ...
                $value = "'b" . $value; # value should be of binary type!!
            }
	} else {
            $comm = " " . $tcom . " __I_ConstNoconv";
	}

        # Get this port's description ... port_width and signal_width ....
        my( $dtp, $dtpc ) = mix_wr_fromto ( $out->{'port_f'}, $out->{'port_t'}, $lang, $tcom);
        my( $dts, $dtsc ) = mix_wr_fromto ( $out->{'sig_f'}, $out->{'sig_t'}, $lang, $tcom);
        my( $dtsa, $dtsac ) = mix_wr_fromto ( $s->{'::high'}, $s->{'::low'}, $lang, $tcom);

        #!wig20030403: Use intermediate signal ...
        my ( $sname, $cname, $bref ) = mix_wr_getconstname( $s, $n );

        if ( $lang =~ m,^veri,io ) {
            $value =~ s,["],,g; # Quick hack ....
            #TODO: rework ident strategy ... e.g. mark with keywords ...
            $def = '`define' . '%S%' . $cname . '%S%' . $value . '%S%' . $comm . "\n";
            if ( $dtp eq $dtsa ) {
                $sat = '%S%' x 2 . 'assign' . '%S%' . $sname . '%S%' . '= `' .   # `
                        $cname . ";\n";
            } else {
                $sat = '%S%' x 2 . 'assign' . '%S%' . $sname . $dts . '%S%' . '= `' . # `
                        $cname . ";\n";
            }
        } else {
        	# Print out signal definition ...
        	#!wig20050720: only the first time ($n == 0)
            # Reduce type if constant is one-bit wide ...
            if ( $type =~ m/_vector$/o and $out->{'port_f'} eq '0' and $out->{'port_t'} eq "0" ) {
                $type =~ s/_vector$//;
            }
            $t .= '%S%' x 3 . 'constant' . '%S%' . $cname .
                '%S%' . ": $type$dtp := $value;$comm $dtpc\n";
            # Is the constant assigned to all of the signal?
            if ( $dtp eq $dtsa ) {
                $sat =  '%S%' x 3 . "$sname <= $cname" . ";\n";
            } else {
                $sat =  '%S%' x 3 . $sname . $dts . '%S%' . '<=' . '%S%' .
                	$cname . ';' . $dtpc . $dtsc . "\n";
            }
        }
    }

    return $t, $sat, $def;
} # End of _write_constant

#
# Create an unique constant name,
# return signal and constant name ...
#
sub mix_wr_getconstname ($$) {
    my $sref = shift;
    my $n = shift || '';

    my $busref = 0;
    # Return name for signal and name for constant ...
    my $sn = $sref->{'::name'};
    my $cn = $sn . ( $n ? ( '_' . $n . 'c' ) : '_c' );

    my $nt = $n || '0';

    #Caveat: will only work if the constant has only >one< %BUS% reference!!
    #    and this reference has to be first!
    if ( exists( $sref->{'::in'}[0]{'inst'} ) and
         exists( $sref->{'::out'}[$nt] ) and
        $sref->{'::out'}[$nt]{'inst'} =~ m/(__|%)CONST(__|%)/io and
        $sref->{'::in'}[0]{'inst'} =~ m/(__|%)BUS(__|%)/io ) {
            $busref = 1;
            $cn = $sn . ( $n ? ( '_' . $n . 'c' ) : '' ); # Signalname taken from ::in
                # constant name as defined or attach a _Nc if N > 0 
            $sn = $sref->{'::in'}[0]{'port'} || '__W_UNKNOWN_CONST_BUS';
            if ( $cn eq $sn ) { $cn = $sn . ( $n ? ( '_' . $n . 'c' ) : '_c' ); }
    }        

    return $sn, $cn, $busref;
}


#
# gen_concur_port: generate an concurrent assignment to map signals to
# a given port of a given instance
# Basic assumption: port maps may contain multiple assignments to single
# bit splices of a port!
#
# interface:             my $concurs = gen_concur_port( $i, $ii, $port, $iconn, $aeport{$ii}, $lang, $tcom );

sub gen_concur_port($$$$$$$$;$$) {
    my $mode = shift;
    my $inst = shift;
    my $enty = shift;
    my $signal = shift;
    my $signal_n = shift;
    my $port = shift;
    my $rconn = shift;
    my $aeportii = shift;
    my $lang = shift || $eh->get( 'macro.%LANGUAGE%' );
    my $tcom = shift || $eh->get( 'output.comment.' . $lang ) || '##';

    my $concur = '';
    # Is this a splice?
    # Get bus width for signal and port
    my $sh = $conndb{$signal}{'::high'}; 
    my $sl = $conndb{$signal}{'::low'};
    my $ph = $entities{$enty}{$port}{'high'};
    my $pl = $entities{$enty}{$port}{'low'};
    unless( defined( $sh ) ) { $sh = ''; };
    unless( defined( $sl ) ) { $sl = ''; };
    unless( defined( $ph ) ) { $ph = ''; };
    unless( defined( $pl ) ) { $pl = ''; };

    # Get width for the connection in this instance:
    PS: for my $ps ( @{$conndb{$signal}{'::' . $mode}} ) {
        #DEBUG
        next PS if ( scalar( %$ps ) eq "0" ); #Should not happen, empty hash??
        unless( defined( $inst ) and defined( $port ) and
                defined( $ps->{'port'} ) and defined( $ps->{'inst'} ) ) {
                    $logger->error('__E_GEN_CONCUR_PORT', "\tMissing definition $inst/$port, Contact maintainer!");
        }
        if ( $ps->{'port'} eq $port and
            $ps->{'inst'} eq $inst ) {
            my $tsh = $ps->{'sig_f'}; 
            my $tsl = $ps->{'sig_t'};
            my $tph = $ps->{'port_f'};
            my $tpl = $ps->{'port_t'};
            unless( defined( $tsh ) ) { $tsh = ''; };
            unless( defined( $tsl ) ) { $tsl = ''; };
            unless( defined( $tph ) ) { $tph = ''; };
            unless( defined( $tpl ) ) { $tpl = ''; };
            # Single bit assignment:
            my $type = '';
            my $sslice = '';
            my $pslice = '';
            my $tswidth = -1;
            my $tpwidth = -1;
            if ( $tsh eq $sh and $tsh eq '' and
                 $tph eq $ph and $tph eq '' and
                 $tsl eq $sl and $tsl eq '' and
                 $tpl eq $pl and $tpl eq '' ) {
                $type = " $tcom __I_" . uc( substr( $mode, 0, 1 ) ) . "_BIT_PORT";
            } elsif ( $tsh eq $sh and $tph eq $ph
                      and $tsl eq $sl and $tpl eq $pl
                      and $tsh eq $tph and $tsl eq $tpl
                      ) {
                # Complete bus/port
                $type = " $tcom __I_" . uc( substr( $mode, 0, 1 ) ) . "_BUS_PORT";
            } else {
                # Is this a signal slice?       
                $type = " $tcom __I_" . uc( substr( $mode, 0, 1 ) ) . "_SLICE_PORT";

                # TODO : do not add (n downto m) if $tsh eq $sh and $tsl eq $sl
                if ( $tsh ne $tsl ) {
                    if ( $tsh =~ m/^\d+$/o and $tsl =~ m/^\d+$/o ) {
                        $tswidth = $tsh - $tsl + 1;
                        if ( $tsh > $tsl ) {# Numeric values
                            $sslice = ( $lang =~ m,^veri,io ) ?
                                ( "[" . $tsh . ":" . $tsl . "]" ) :
                                ( "(" . $tsh . " downto " . $tsl . ")" );
                        } else {
                            $sslice = ( $lang =~ m,^veri,io ) ?
                                ( "[" . $tsh . ":" . $tsl . "]" ) :
                                ( "(" . $tsh . " to " . $tsl . ")" );
                        }
                    } else { # Strings or any other nonsense, order is up to user!
                        $sslice = ( $lang =~ m,^veri,io ) ?
                            ( "[" . $tsh . ":" . $tsl . "]" ) :
                            ( "(" . $tsh . " downto " . $tsl . ")" );
                    }
                } elsif ( $tsh ne '' ) {
                    $tswidth = 1;
                    if ( $tsh eq '0' and $sh eq '' ) { # 
                        $sslice = "";
                        $type .= " $tcom __I_SINGLE_BIT (" . $tsh . ")";
                    } else {
                        $sslice = ( $lang =~ m,^veri,io ) ?
                            ( "[" . $tsh . "]" ) :
                            ( "(" . $tsh . ")" );
                        $type .= " $tcom __W_SINGLE_BIT_SLICE";
                    }
                }
                # Port slice?
                if ( $tph ne $tpl ) {
                    if ( $tph =~ m/^\d+$/o and $tpl =~ m/^\d+$/o ) {
                        $tpwidth = $tph - $tpl + 1;
                        if ( $tph > $tpl ) {# Numeric values
                            $pslice = ( $lang =~ m,^veri,io ) ?
                                ( '[' . $tph . ':' . $tpl . ']' ) :
                                ( '(' . $tph . ' downto ' . $tpl . ')' );
                        } else {
                            $pslice = ( $lang =~ m,^veri,io ) ?
                                ( '[' . $tph . ':' . $tpl . ']' ) :
                                ( '(' . $tph . ' to ' . $tpl . ')' );
                        }
                    } else { #Strings or any other nonsense, order is up to user!
                         $pslice = ( $lang =~ m,^veri,io ) ?
                                ( '[' . $tph . ':' . $tpl . ']' ) :
                                ( '(' . $tph . ' downto ' . $tpl . ')' );
                    }
                } elsif ( $tph ne '' ) {
                    $tpwidth = 1;
                    if ( $ph eq '' and $pl eq '' and $tph eq '0' ) {
                    # Another exception: single bit port ... (0) -> 
                    # Autoreduce bus to bit port
                        $pslice = "";
                    } else {
                        $pslice = ( $lang =~ m,^veri,io ) ?
                                ( '[' . $tph . ']' ) :
                                ( '(' . $tph . ')' );
                    }
                }
            }

            # TODO : check this_port vs. this_signal width (if possible)
            if ( $tswidth >= 0 and $tpwidth >= 0 and $tpwidth != $tswidth ) {
                $logger->warn('__W_GEN_CONCUR_PORT', "\tConnection width mismatch for instance $inst, signal $signal, port $port: $tswidth vs. $tpwidth!");
            }

            # in:               SIGNAL <= PORT;
            # out (et al.):   PORT <= SIGNAL;
            if ( $lang =~ m,^veri,io ) {
                if ( $mode eq 'in' ) {
                    $concur .= '%S%' x 2 . "assign\t" . $signal_n . $sslice . '%S%=%S%' . $port . $pslice . '; ' . $type . "\n";
                } else {
                    $concur .= '%S%' x 2 . "assign\t" . $port . $pslice . '%S%=%S%' . $signal_n . $sslice . '; ' . $type . "\n";
                }
            } else {
                if ( $mode eq 'in' ) {
                    $concur .= '%S%' x 2 . $signal_n . $sslice . '%S%<=%S%' . $port . $pslice . '; ' . $type . "\n";
                } else {
                    $concur .= '%S%' x 2 . $port . $pslice . '%S%<=%S%' . $signal_n . $sslice . '; ' . $type . "\n";
                }
            }
        }
    }

    unless( $concur ) {
        $logger->warn('__E_GEN_CONCUR_PORT', "\tMissing port/signal connection for instance $inst, signal $signal, port $port!" );
    }
    return $concur;
} # End of gen_concur_port

#
# Will return true if the input string is a comment, only
#
sub is_vhdl_comment ($) {
    my $text = shift;
    return( $text =~ m,\A(^(%S%|\s)*(--.*)?\n)*\Z,om );
}

#
# Return is $text contains only comment
# depending on $lang
#
sub is_comment ($$) {
    my $text = shift;
    my $lang = shift || lc( $eh->get( 'macro.%LANGUAGE%') );

    # Retrieve the comment for that language ...
    my $tcom = $eh->get( 'output.comment.' . $lang ) ||
    		$eh->get( 'output.comment.default' );
    if( $tcom ) {
        return( $text =~ m,\A(^\s*($tcom.*)?\n)*\Z,om );
    } else {
        return 0;
    }
}

####################################################################
## strip_empty
####################################################################

=head2

strip_empty ($) 

    Remove empty "generic" statments

like
    component keyscan
    		generic (
    		-- Generated Generics for Entity keyscan
               );
    	generic(
           -- Generated Generics for Entity ent_a
           -- End of Generated Generics for Entity ent_a
        );

Input: generic map in string
Output: condensed map string

Current status: empty subroutine, no longer needed!

=cut

sub strip_empty ($) {
    my $text = shift;

    #
    # Remove empty "generic" statments
    #
    #   component keyscan
    #		generic (
    #		-- Generated Generics for Entity keyscan
    #           );
    #	generic(
    #       -- Generated Generics for Entity ent_a
    #       -- End of Generated Generics for Entity ent_a
    #       );
    # $text =~ s,^\s*--\sgeneric\s*\(\s+--[^\n]*\n(^(\s*--[^\n]*|\s*)\n$)*^\s*\)\s*;,\t\t-- nothing,siomg;

    # 20030227 I believe I no longer need that ...
    # $text =~ s,^(\s*--\s*generics:\s*$)?^\s*generic\s*\(\s*$(\s*--.*$)*\s*\);,,iomg
#    $text =~ s
#    $text =~ s,\s*--\s*Generics:\s+generic\s*\(\s+--\s+Generated\s+Generics\s+for\s+Entity\s+\w+\s+\);,,siog;
#    $text =~ s,generic\s*\(\s+--\s+Generated\s+Generics\s+for\s+Entity\s+\w+\s+\);,,siog;

    return $text;
}

####################################################################
## count_load_driver
## find out how many loads and drivers the signals attached to that entity have
####################################################################

=head2

count_load_driver($$$$) {

Count loads and drivers of all signals here. Adds to the aeport strucuture
above. Makes sure aeport has:
    $aeport{'in'}  := number of internally connected blocks, "in"
    $aeport{'out'} := number of internally connected blocks, "out"
    $aeport{'load'} := number of loads ( "in" + ports driven )
    $aeport{'driver'} := number of drivers ( "out" + ports driving )


Arguments:
    $inst := Instance name
    $enty := Entitiy name
    $rextsig := pointer to $hierdb{$inst}{::conn} array
    $rinsig := pointer to $aeport{$sig}{in|out} array

This subroutine does not care about bit/bus headaches.
This subroutine will break as soon as someone comes along with buffers and
inouts.

=cut

sub count_load_driver ($$$$) {
    my $inst = shift;
    my $enty = shift;
    my $rextsig = shift;
    my $rinsig = shift;

    # $rinsig is not a reliable input source ??? But we have nothing better
    #  BTW: extsig/in are drivers (while "in" in subblocks are loads)
    #  and extsig/out counts as load
    my %sub_iold = (
        'in' => 'load',
        'out' => 'driver',
    );

    my %port_iold = (
            'in' => 'driver',
            'out' => 'load',
    );

    foreach my $s ( keys( %$rinsig ) ) {
        for my $io ( qw( in out ) ) {
            if ( exists( $rinsig->{$s}{$io} ) and $rinsig->{$s}{$io} ) {
                $rinsig->{$s}{$sub_iold{$io}} = $rinsig->{$s}{$io};
            }
        }
    }

    foreach my $io ( qw( in out ) ) {
        my $ld = $port_iold{$io};
        if ( exists( $rextsig->{$io} ) ) {
            foreach my $s ( keys( %{$rextsig->{$io}} ) ) {
               $rinsig->{$s}{$ld} += scalar( keys( %{$rextsig->{$io}{$s}} ) );
            }
        }
    }

    # Do some sanity checks here (only non-leaf blocks, we don't care about
    # leaf internals)
    # loads = 0 -> complain (missing load)
    # driver = 0 -> missing driver
    # driver > 1 -> multiple driver
    #TODO: Complain if a signal enters/leaves a block through several ports
    # This check produces false results for busses, which are connected by different
    # signals to different slices (because we just count the overall signals connected
    # to the busses).
    #TODO: Make real check (consider bit slices). That will require to count links
    # to individual bits ... (but will that be costly)
    my $error_flag = 0;
    if ( $entities{$enty}{"__LEAF__"} != 0 ) {
        for my $s ( keys( %$rinsig )  ) {
            unless( exists( $rinsig->{$s}{'load'} ) ) {

                unless ( $s =~ m/%open(_\d+)?%/io ) {
                   	if ( $eh->get( 'output.warnings' ) =~ m/load/io ) {
                       	$logger->warn('__W_COUNT_LDDRVS', "\tSignal $s does not have a load in instance $inst!" );
                   	} else {
                       	$logger->debug('__D_COUNT_LDDRVS', "\tSignal $s does not have a load in instance $inst!" );
                   	}
                	$conndb{$s}{'::comment'} .= "__W_MISSING_LOAD/$inst,";
                	$eh->inc( 'sum.noload' );
            	} else {
            		$conndb{$s}{'::comment'} .= "__I_OPEN/$inst,";
            		$eh->inc( 'sum.open' );
                }
                $rinsig->{$s}{'load'} = 0;
            }
            unless( exists( $rinsig->{$s}{'driver'} ) ) {
            	unless ( $s =~ m/%(HIGH|LOW)(_BUS)?%/ ) {
                	if ( $eh->get( 'output.warnings' ) =~ m/driver/io ) {
                    	$logger->warn('__W_COUNT_LDDRVS', "\tSignal $s does not have a driver in instance $inst!" );  
                	} else {
                    	$logger->debug('__D_COUNT_LDDRVS', "\tSignal $s does not have a driver in instance $inst!" );
                	}
                	$eh->inc( 'sum.nodriver' );
                	$conndb{$s}{'::comment'} .= "__W_MISSING_DRIVER/$inst,";
            	} else {
            		$conndb{$s}{'::comment'} .= "__I_TIE_HIGHLOW/$inst,";
            	    $eh->inc( 'sum.tie_hl' );
            	}
            	$rinsig->{$s}{'driver'} = 0;
            } elsif ( $rinsig->{$s}{'driver'} > 1 ) {
                if ( $eh->get( 'output.warnings' ) =~ m/driver/io ) {
                    $logger->warn('__W_COUNT_LDDRVS', "\tSignal $s  has multiple drivers in instance $inst!" );
                } else {
                    $logger->debug('__D_COUNT_LDDRVS', "\tSignal $s  has multiple drivers in instance $inst!" );
                }
                $conndb{$s}{'::comment'} .= "__E_MULTIPLE_DRIVER/$inst,";
                $error_flag++;
                $eh->inc( 'sum.multdriver' );
            }
        }
    }
    return $error_flag;
} # End of count_load_drivers

####################################################################
## sig_typecast
## provide typecasting ports to signals
## used as alternative to port map typecasting
####################################################################

=head2

sig_typecast($$) {

generate an intermediate signal for typecast requests ..

=cut

sub sig_typecast ($$) {
    my $enty = shift;
    my $rinsig = shift;

    unless( defined( $entities{$enty} ) ) {
        $logger->warn('__W_SIG_TYPECASTT', "\tCannot check unknown entity $enty for typecast port mapping!" );
        return;
    }

    my %map = ();

    for my $p ( keys( %{$entities{$enty}} ) ) {
        next if ( $p =~ m,^__,io );
        next if ( $p =~ m,^%,io ); # Special ports/signals will be skipped ...

        if ( exists( $entities{$enty}{$p} )
            and exists( $entities{$enty}{$p}{'cast'}  ) ) { 
            $map{$p}{'cast'} = $entities{$enty}{$p}{'cast'};
            $map{$p}{'isig'} = $eh->get( 'postfix.PREFIX_TC_INT' ) . $p;
            $map{$p}{'enty'} = $enty;
        }
    }
    return( %map );
}

####################################################################
## signal_port_resolve
## find if signals used internally and having the same name as the port it's connected to.
## Provide mapping of signal to port name inside of this entitiy
####################################################################

=head2

signal_port_resolve($$) {

Find signals/ports used internally, too.

=cut

sub signal_port_resolve ($$) {
    my $enty = shift;
    my $rinsig = shift;

    unless( defined( $entities{$enty} ) ) {
        $logger->warn('__W_SIGNAL_PORT_RESOLVE', "\tCannot check unknown entity $enty signal port mapping!" );
        return;
    }

    my %map = ();

    for my $p ( keys( %{$entities{$enty}} ) ) {
        next if ( $p =~ m,^__,io );
        next if ( $p =~ m,^%,io ); # Special ports/signals will be skipped ...

        # Port name: is that an out port and exists in and out internally?
        # We will not attempt to resolve the multiple driver issue
        if ( exists( $rinsig->{$p} )
            and exists( $rinsig->{$p}{'out'} )  #wig20030325: is that a good idea?
            and exists( $rinsig->{$p}{'in'} ) ) {
                # if ( $entities{$enty}{$p}{'mode'} eq "out" ) { # Rename the internal signal
                    $map{$p} = $eh->get( 'postfix.PREFIX_SIG_INT' ) . $p;
                # } else {
                #    $map{$p} = "__E_CONFLICT_$p";
                # }
                # TODO: handle other modes: buffer, inout
        }
    }

    return( %map );
}


####################################################################
## write_configuration
## write configurarion for VHDL files
####################################################################

=head2

write_configuration () {

Write configuration into output file(s).

=cut

sub write_configuration () {

    # Set up configuration template;
    tmpl_conf();

    # open output file
    my %seen = ();
    my $efname = $eh->get( 'outconf' );
    if ( $efname =~m/^(CONF|COMB)/o ) {
        my $confext = $eh->get( 'postfix.POSTFILE_CONF' );
        if ( $1 eq "COMB" ) {
            $confext = "";
        }
		# Write each configuration in a file of it's own
		for my $i ( sort( keys( %hierdb ) ) ) {
			# Skip it if it was seen before
			# TODO : sort by order of hierachy??

    		if ( $eh->get( 'output.generate.conf' ) =~ m,\bnoleaf\b,io and
		    	not $hierdb{$i}{'::treeobj'}->daughters ) {
		    		next;
		    }
		    if ( $eh->get( 'output.filter.file' ) ) {
		    	my $filter = _mix_wr_getfilter( 'conf', $eh->get( 'output.filter.file' ) );	    	
		    	if ( $i =~ m/$filter/ ) {
		           $logger->warn('__W_WRITE_CONF', "\tSkipped writing of configuration $i due to filter" );    		
		           next;
		    	}
		    }

			my $e = $hierdb{$i}{'::entity'};
            next if ( $e eq 'W_NO_ENTITY' );
            next if ( $e eq '%TYPECAST_ENT%' );

			unless ( exists( $seen{$e} ) ) {
		    	$seen{$e} = 1;

                #
                # Simple attempt to define a filename:
                # Take configuration name if that contains the entitiy name,
                #  else use ENTY-c.vhd
                #
                my $filename;
                my $e_fn = $e;
                my $ce = $hierdb{$i}{'::config'};
                #Changed 20030714a/Bug: change only trailing _ to - !!
                if ( $eh->get( 'output.filename' ) =~ m,allminus,o ) {
                    $ce =~ s,_,-,og;
                    $e_fn =~ s,_,-,og;
                } elsif ( $eh->get( 'output.filename' ) =~ m,useminus,i ) {
                    # Only trailing part gets changed ...
                    # Stip of entity name, replace _ by - and attach ...
                    if ( $ce =~ s,^\Q$e_fn\E,, ) { # entity name in configurartion
                        $ce =~ s,_,-,og; # Replace _ with - ... Micronas Design Guideline
                        $ce = $e_fn . $ce;
                    } else {
                        $ce =~ s,_,-,og; # Replace _ with - ... Micronas Design Guideline
                    }
                }

                # Language? vhdl, verilog or what else?
                my $lang = lc( $hierdb{$i}{'::lang'} ) || $eh->get( 'macro.%LANGUAGE%' );
                unless ( $eh->get( 'template.' . $lang  ) ) {
                    $logger->warn('__W_WRITE_CONF', "\tIllegal language $lang selected. Autoswitch to " .
                    		$eh->get( 'macro.%LANGUAGE%' ) . '!' );
                    $lang = $eh->get( 'macro.%LANGUAGE%' );
                }
                next if ( $lang ne "vhdl" ); # No configuration to write if language ne VHDL

                if ( $eh->get( 'outconf' ) eq "COMB" ) {
                    $filename = $e_fn . $confext . '.' . $eh->get( 'output.ext.' . $lang );
                } elsif ( substr( $ce, 0, length( $e_fn ) ) eq $e_fn ) {
                    $filename = $ce . $confext  . '.' . $eh->get( 'output.ext.' . $lang );
                } else {
                    $filename = $e_fn . $confext  . '.' . $eh->get( 'output.ext.' . $lang );
                }
		    	_write_configuration( $i, $e, $filename, \%hierdb );
			}
		}
    } else {
		_write_configuration( "__COMMON__", "__COMMON__", $efname, \%hierdb );
    }
    return;
} # End of write_configuration

#
# Do the work:
#
sub _write_configuration ($$$$) {
    my $instance = shift;
    my $entity = shift;
    my $filename = shift;
    my $ae = shift;

    my %macros = %{$eh->get( 'macro' )}; # Take predefined macro replacement set

    $macros{'%INSTNAME%'} = $instance;
    $macros{'%ARCHNAME%'} = $entity . $eh->get( 'postfix.POSTFIX_ARCH' );
    $macros{'%CONFNAME%'} = $entity . $eh->get( 'postfix.POSTFIX_CONF' );


    my $write_flag = $eh->get( 'outconf' );
    #!wig20040804: if this is a leaf cell, supress writing!
    if ( $instance ne '__COMMON__'  and $eh->get( 'output.generate.conf' ) =~ m,\bnoleaf\b, and
            $hierdb{$instance}{'::treeobj'}->daughters == 0  ) {
                # Leaf ...
            $write_flag = 0;
    }
    
    #
    # Another case: if this entity is in the "simple logic" list, do
    # not write ...
    #
    my $simple_re = $eh->get('output.generate._logicre_');
    if ( $entity =~ m/$simple_re/i ) {
    	$write_flag = 0;
    	return; # 
    }
    
    # Are we in verify mode?
    # Not possible if in __COMMON__ mode!
    if ( $instance ne '__COMMON__' and $eh->get( 'check.hdlout.path' ) and
        $eh->get( 'check.hdlout.mode' ) =~ m,\b(conf|all),io ) { # Selected ...
        # Append check flag ...
        if ( $eh->get( 'check.hdlout.mode' ) =~ m,\bleaf\b,io ) {
                # __LEAF__ is 1 if this is not a LEAF!
                $write_flag .= ( $entities{$entity}{'__LEAF__'} == 0 ) ? "_CHK_CONF_LEAF" : "";
        } else {
                $write_flag .= ( $entities{$entity}{'__LEAF__'} == 0 ) ? "_CHK_CONF_LEAF" : "_CHK_CONF";
        }
    }

    if ( $write_flag and -r $filename and $eh->get( 'outconf' ) ne "COMB" ) {
		$logger->warn('__W_WRITE_CONF', "\tConfiguration definition file $filename will be overwritten!" );
    }
   
    my $fh = undef;
    unless( $fh = mix_utils_open( $filename, $write_flag ) ) {
        $logger->warn( '__W_WRITE_CONF', "\tCannot open file $filename to write configuration definitions: $!" );
        return;
    }

    # Add header
    my $tpg = $eh->get( 'template.vhdl.conf.body' );

    $macros{'%VHDL_USE%'} = use_lib( "conf", $instance );

    my $et = replace_mac( $eh->get( 'template.vhdl.conf.head' ), \%macros);

    my %seenthis = ();

    #
    # Go through all instances and generate a configuration for each !entity!
    # TODO: or instance?
    #
    my @keys = ( $instance eq "__COMMON__" ) ? keys( %$ae ) : ( $instance );
    for my $i ( sort( @keys ) ) {

	# Do not write configurations for leaf cells ... or dummy/internals
        if ( $i =~ m/TYPECAST_/o ) { next };
	if ( $eh->get( 'output.generate.conf' ) =~ m,noleaf,io and
	    $hierdb{$i}{'::treeobj'}->daughters == 0  ) {
		next;
	}
	# Skip some internals
	if ( $i eq "W_NO_ENTITY" ) { next; };
	if ( $i eq "W_NO_CONFIG" ) { next; };
 
	my $aent = $ae->{$i}{'::entity'};

	if ( $aent eq "W_NO_ENTITY" ) { next; }

	$macros{'%ENTYNAME%'} = $aent;
	$macros{'%CONFNAME%'} = $ae->{$i}{'::config'} . $eh->get( 'postfix.POSTFIX_CONF' );
	$macros{'%ARCHNAME%'} = $ae->{$i}{'::arch'}   . $eh->get( 'postfix.POSTFIX_ARCH' );

	#
	# Collect components by looking through all our daughters
	#
	$macros{'%CONFIGURATION%'} = '%S%' x 1 . "-- Generated Configuration\n";

	#
	# Inform user about rewrite of architecture for this entity ...
	#
	if ( exists( $seenthis{$aent} ) ) {
	    $logger->warn('__W_WRITE_CONF', "\tPossibly rewriting configuration for entity $aent, instance $i!" );
	} else {
	    $seenthis{$aent} = 1;
	}

	my $lang = lc ( $hierdb{$i}{'::lang'} || $eh->get( 'macro.%LANGUAGE%' ) || 'vhdl' ) ;
        my $tcom = $eh->get( 'output.comment.' . $lang ) || $eh->get( 'output.comment.default' ) || '##';

	my $node = $ae->{$i}{'::treeobj'};
	for my $daughter ( sort( { $a->name cmp $b->name } $node->daughters ) ) {

	    my $d_name = $daughter->name;
	    my $d_enty = $hierdb{$d_name}{'::entity'};
	    my $d_conf = $hierdb{$d_name}{'::config'};

            next if ( $d_enty eq "%TYPECAST_ENT%" ); # Skip dummy ...

            #
            # Comment out Verilog daughter's, subblocks
            #wig20030711: also if the configuration is W_NO_CONFIG and or %NO_CONFIGURATION%
            #
            my $pre = "";
            if ( $eh->get( 'output.generate.conf' ) !~ m,veri,io ) {
                if ( $ae->{$d_name}{'::lang'} =~ m,veri,io ) {
                    $pre = $tcom . " __I_NO_CONFIG_VERILOG " . $tcom;
                }
            }
            # If this daughter is from the simple logic list -> do not add a configuration
            my $simple_re = $eh->get( 'output.generate._logicre_' );
            if ( $d_enty =~ m/$simple_re/i ) {
            	$pre = $tcom . " __I_NO_CONF_LOGIC " . $pre;
            }
            # If this daughter has a NO_CONFIG in it's configuration -> comment it out:
            if ( $ae->{$d_name}{'::config'} =~ m,(W_NO_CONFIG|NO_CONFIG),o ) {
                $pre = $tcom . " __I_NO_CONFIG " . $pre;
            }
	    #
	    # Component configuration:
	    # 
		$macros{'%CONFIGURATION%'} .=
                        "\t\t\t" . $pre . "for $d_name : $d_enty\n" .
			"\t\t\t" . $pre . "\tuse configuration work.$d_conf;\n" .
			"\t\t\t" . $pre . "end for;\n";
	}
	$et .= replace_mac( $tpg, \%macros );

    }

    $et .=  $eh->get( 'template.vhdl.conf.foot' );
    $et = replace_mac( $et, \%macros );

    mix_utils_print( $fh, $et );

    mix_utils_close( $fh, $filename );
}

####################################################################
## use_lib
## provide project specific use .... commands
####################################################################

=head2

use_lib ($$)

provide project specific use commands for VHDL
provide module specific defines and includes for verilog

=cut

sub use_lib ($$) {
    my $type = shift;
    my $instance = shift;

    # Get all instances to take into account:
    my @keys = ();
    if ( $instance eq "__COMMON__" ) {
    # Do it for all instances ...
    	@keys = keys( %hierdb );
    } elsif ( $type eq "enty" ) {
        # $instance is an entity name, collect all ...
        @keys = grep( { $hierdb{$_}{'::entity'} eq $instance; } keys( %hierdb ) );
    } else {
        $keys[0] = $instance;
    }

    # Now read all ::use fields and combine ...
    my $all = "";
    my %libs = ();
    my @veri = ();
    foreach my $k ( @keys ) {
        next if ( $k =~ m,%\w+%, );
        next if ( $k eq "W_NO_ENTITY" );
        next if ( $k eq "W_NO_PARENT");

        if ( exists( $hierdb{$k}{'::use'} ) and $hierdb{$k}{'::use'} ) {
            # Is this verilog?
            my @u = ();
            if ( $type eq "veri" ) {
                # Split by newline's and , and take literally
                push( @veri, split( /[,\n]/, $hierdb{$k}{'::use'} ) );
                
            } else {
                # VHDL:
                @u = split( /[,\s]+/, $hierdb{$k}{'::use'} ); # Split by space and ,

                foreach my $u ( @u ) {
                    # libs may be seperated by , and/or \s
                    # $u := SEL:library.component ...
                    next if ( $u =~ m,(%NCD%|%NO_COMPONENT_DECLARATION|NO_COMP|__NOCOMPDEC__),o );
                    # next if ( $u =~ m,(%DEFINE%|%INCLUDE%),o );
                    my $sel = lc( $eh->get( 'output.generate.use' ) );
                    my $pack = '';
                    my $lib = '';
                    if ( $u =~ m,(\S+):(\S+),o ) {
                        $sel = lc($1);
                        ( $pack = $2 ) =~s,\s+,,og;
                    } else {
                        ( $pack = $u ) =~ s,\s+,,og;
                    }
                    ( $lib = $pack ) =~ s/\..*//;
                    if ( $sel eq 'all' or $sel eq $type ) {
                        if ( $lib ) {
                            $libs{$lib}{$pack}  = 1;
                        }
                    }
                }
            }
        }
    }
    #
    # Create:   library foo;
    #               use foo.bar.all;
    # VHDL only (libs hash gets values only in VHDL)
    for my $l ( sort( keys( %libs ) ) ) {
        $all .= "library $l;\n";
        for my $p ( sort( keys( %{$libs{$l}} ) ) ) {
            $all .= "use $p.all;\n"; # Attach .all by default ....
        }
    }

    if ( $all ) {
        $all = "-- Generated use statements\n" . $all;
    } elsif ( $type ne "veri" ) {
        $all = $eh->get( 'macro.%VHDL_NOPROJ%' ) . '/' . $type . "\n";
    }

    # Verilog: do a simple concatenate!
    # TODO : replace comment by generic format
    if ( scalar( @veri ) ) {
        $all = "// Generated include statements\n" .
            join( "\n", @veri ) . "\n";
    }
    
    return $all;

}

#
# Set the %*_HOOK_*% macros (globally), possibly with some code from the optional
#  ::udc column from the HIER sheet
#  mode = arch (only implemented for ARCH now)
# Caveat: to keep the global definitios for the HOOKs values,
#  they are stored in a static internal array the first time this
#  subroutine is called!
#
#!wig20060405: Added PARA (allow Verilog parameters to be set)
#
# TODO : extend MODE for enty and conf and verilog ...
# TODO : detect "new" hooks and make sure they get reset
#!wig20050711
sub mix_wr_use_udc ($$$) {
	my $mode = shift;
	my $instance = shift;
	my $macroref = shift;

	#!wig: will not work for __COMMON__
	return if ( $instance eq '__COMMON__' );
	
	# my %modkeys = (
	# 	'arch' => [ qw( HEAD DECL BODY FOOT ) ],
	# );
	my $tagre = '/(%|__?)(' . join( "|", qw( HEAD DECL PARA BODY FOOT ) ) . ')(%|__?)/';

	my $lang = uc( $hierdb{$instance}{'::lang'} || $eh->get( 'macro.%LANGUAGE%') );		
	if ( exists( $hierdb{$instance}{'::udc'} ) and
		$hierdb{$instance}{'::udc'} ) {
		my $udc = $hierdb{$instance}{'::udc'};
		
		my %udc = ();
		my $tag = uc('body'); # Stick to captital letters!
		my $post = $udc;
		
		# Split $udc data in fields prepended by a /%TAG%/
		# $tagre has three () pairs! The middle one holds the keyword.
		while ( 1 ) {
			if ( $post =~ m!^(.*?)$tagre(.*)!msi ) {
				$udc{$tag} = $1;
				$tag = uc($3);
				$post = $5;
			} else {
				$udc{$tag} .= $post;
				last;
			}
		}
		
		if ( $lang =~ m/veri/io ) {
			$mode = "";
			$lang = "verilog";
		} else {
			$mode .= "_";
		}
		
		# Create macro hooks from ::udc
		for my $t ( keys( %udc ) ) {
			my $h = '%' . uc( $lang . "_hook_" . $mode . $t ) . '%';
			$macroref->{$h} = $udc{$t};
		}			
	}
}

#
# Get a regular expression which contains only filters for this mode
#   mode := arch|enty|conf ...., "all" matches all possible modes
#   mode will select keys which have "mode:" prepended
#	e.g. all:.* -> do not print any file
#
sub _mix_wr_getfilter ($$) {
	my $mode = shift;
	my $all  = shift;

	my @match = ();
		
	for my $i ( split( /[,;\s]+/, $all ) ) {
		if ( $i =~ m/(\w+):(.*)/ ) {
			if ( lc($1) eq lc($mode) or lc($1) eq 'all' ) {
				push( @match, $2 );
			}
		} else {
			push( @match, $i );
		} 
	}
	return '^(' . join( '|', @match ) . ')$';
}
	
# } #End of %keep_hooks

1;

#!End
