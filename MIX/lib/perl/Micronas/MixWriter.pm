# -*- perl -*---------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright Micronas GmbH, Inc. 2002.                        |
# |     All Rights Reserved.                     |
# |                                                                       |
# |                                                                       |
# | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF MICRONAS GMBH |
# | The copyright notice above does not evidence any actual or intended   |
# | publication of such source code.                                      |
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# | Project:    Micronas - MIX / Writer                                    |
# | Modules:    $RCSfile: MixWriter.pm,v $                                     |
# | Revision:   $Revision: 1.26 $                                             |
# | Author:     $Author: wig $                                  |
# | Date:       $Date: 2003/08/13 09:09:21 $                                   |
# |                                                                       |
# | Copyright Micronas GmbH, 2003                                |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/MixWriter.pm,v 1.26 2003/08/13 09:09:21 wig Exp $                                                         |
# +-----------------------------------------------------------------------+
#
# The functions here provide the parsing capabilites for the MIX project.
# Take a matrix of information in some well-known format and convert it into
# intermediate format and/or source code files
#
# +-----------------------------------------------------------------------+
# |
# | Changes:
# | $Log: MixWriter.pm,v $
# | Revision 1.26  2003/08/13 09:09:21  wig
# | Minor bug fixes
# | Added -given mode for iocell.select (MDE-D)
# |
# | Revision 1.24  2003/08/11 07:16:25  wig
# | Added typecast
# | Fixed Verilog issues
# |
# | Revision 1.22  2003/07/23 13:34:40  wig
# | Fixed minor bugs:
# | - open(N) removed
# | - overlay bitvector fixed
# |
# | Revision 1.21  2003/07/17 12:10:43  wig
# | fixed minor bugs:
# | - Verilog `define before module
# | - Verilog open
# | - signals(NN) in IO-Parser failed (bad reg-ex)
# |
# | Revision 1.19  2003/07/09 07:52:44  wig
# | Adding first version of Verilog support.
# | Fixing lots of tiny issues (see TODO).
# | Adding first release of documentation.
# |
# | Revision 1.18  2003/06/05 14:48:01  wig
# | Releasing alpha IO-Parser
# |
# | Revision 1.17  2003/06/04 15:52:43  wig
# | intermediate release, before releasing alpha IOParser
# |
# | Revision 1.16  2003/04/28 06:40:37  wig
# | Added %OPEN% (to allow ports without connection, use VHDL open keyword)
# | Started parseIO (not operational, would be a branch instead)
# | Fixed nreset2 issue (20030424a bug)
# |
# | Revision 1.15  2003/04/01 14:28:00  wig
# | Added IN/OUT Top Port Generation
# |
# | Revision 1.14  2003/03/24 13:04:45  wig
# | Extensively tested version, fixed lot's of issues (still with busses and bus splices).
# |
# | Revision 1.12  2003/03/14 14:52:11  wig
# | Added -delta mode for backend.
# |
# | Revision 1.11  2003/03/13 14:05:19  wig
# | Releasing major reworked version
# | Now handles bus splices much better
# |
# | Revision 1.10  2003/02/28 15:03:44  wig
# | Intermediate version with lots of fixes.
# | Signal issue still open.
# |
# | Revision 1.9  2003/02/21 16:05:14  wig
# | Added options:
# | -conf
# | -sheet
# | -listconf
# | see TODO.txt, 20030220/21
# |
# | Revision 1.8  2003/02/20 15:07:13  wig
# | Fixed: port signal assignment direction bus
# | Capitalization (folding is still missing)
# | Added ::arch column and created output
# |
# | Revision 1.7  2003/02/19 16:27:59  wig
# | Added generics.
# | Renamed generated objects
# |
# | Revision 1.6  2003/02/14 14:06:42  wig
# | Improved add port handling, consider in/out/... cases
# | Entitiy port/signals redeclaration prevented
# |
# | Revision 1.5  2003/02/12 15:40:47  wig
# | Improved handling of bus splicing (but still a way to go)
# | Added seom meta instances.
# |
# | Revision 1.4  2003/02/07 13:18:44  wig
# | no changes
# |
# | Revision 1.3  2003/02/06 15:47:46  wig
# | added constant handling
# | rewrote bit splice handling
# |
# | Revision 1.2  2003/02/04 07:18:13  wig
# | Fixed header of modules
# |
# |
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
  @EXPORT_OK = qw(
    );

our $VERSION = '0.01';

use strict;
use vars qw( %entities );

# Caveat: relies on proper setting of base, pgmpath and dir in main program!
use lib "$main::base/";
use lib "$main::base/lib/perl";
use lib "$main::pgmpath/";
use lib "$main::pgmpath/lib/perl";
use lib "$main::dir/lib/perl";
use lib "$main::dir/../lib/perl";

use Log::Agent;
use Log::Agent::Priorities qw(:LEVELS);
use Tree::DAG_Node; # tree base class
use Regexp::Common; # Needed for reading back spliced ports

use Micronas::MixUtils
    qw(   mix_store db2array write_excel
            mix_utils_open mix_utils_print mix_utils_printf mix_utils_close
            replace_mac
            %EH );
use Micronas::MixParser qw( %hierdb %conndb add_conn );

#
# Prototypes
#
sub _write_entities ($$$);
sub compare_merge_entities ($$$$);
sub _write_constant ($$$;$);
sub write_architecture ();
sub strip_empty ($);
sub port_map ($$$$$$);
sub generic_map ($$$$);
sub print_conn_matrix ($$$$$$$$;$);
sub signal_port_resolve($$);
sub use_lib($$);
sub is_vhdl_comment($); # Should got to MixUtils ...
sub is_comment($$);
sub count_load_driver ($$$$);
sub gen_concur_port($$$$$$$$;$$);
sub mix_wr_get_interface ($$$$);
sub _mix_wr_get_ivhdl ($$$);
sub _mix_wr_get_iveri ($$$);
sub mix_wr_port_check ($$);
sub mix_wr_unsplice_port ($$$);

# Internal variable

#
# RCS Id, to be put into output templates
#
my $thisid		=	'$Id: MixWriter.pm,v 1.26 2003/08/13 09:09:21 wig Exp $';
my $thisrcsfile	=	'$RCSfile: MixWriter.pm,v $';
my $thisrevision   =      '$Revision: 1.26 $';

$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?


#
# Templates ...
#
sub tmpl_enty () {

# TODO: Read that templates in from default location (e.g. a company default)
$EH{'template'}{'vhdl'}{'enty'}{'head'} = <<'EOD';
-- -------------------------------------------------------------
--
--  Entity Declaration for %ENTYNAME%
--
-- Generated
--  by:  %USER%
--  on:  %DATE%
--  cmd: %ARGV%
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
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
%VHDL_USE_ENTY%
--

EOD

$EH{'template'}{'vhdl'}{'enty'}{'head'} =~ s/THISRCSFILE/$thisrcsfile/;
$EH{'template'}{'vhdl'}{'enty'}{'head'} =~ s/THISID/$thisid/;

$EH{'template'}{'vhdl'}{'enty'}{'body'} = <<'EOD';
--
-- Start of Generated Entity %ENTYNAME%
--
entity %ENTYNAME% is
        -- Generics:
%GENERIC%
    	-- Generated Port Declaration:
%PORT%
end %ENTYNAME%;
--
-- End of Generated Entity %ENTYNAME%
--

EOD

$EH{'template'}{'vhdl'}{'enty'}{'foot'} = <<'EOD';
--
--!End of Entity/ies
-- --------------------------------------------------------------
EOD

}

#
# Architecture Templates ...
#
sub tmpl_arch () {

$EH{'template'}{'vhdl'}{'arch'}{'head'} = <<'EOD';
-- -------------------------------------------------------------
--
-- Generated Architecture Declaration for %ARCHNAME% of %ENTYNAME%
--
-- Generated
--  by:  %USER%
--  on:  %DATE%
--  cmd: %ARGV%
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
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
%VHDL_USE_ARCH%

--
EOD

$EH{'template'}{'vhdl'}{'arch'}{'head'} =~ s/THISRCSFILE/$thisrcsfile/;
$EH{'template'}{'vhdl'}{'arch'}{'head'} =~ s/THISID/$thisid/;

$EH{'template'}{'vhdl'}{'arch'}{'body'} = <<'EOD';
--
-- Start of Generated Architecture %ARCHNAME% of %ENTYNAME%
--
architecture %ARCHNAME% of %ENTYNAME% is 
	--
	-- Components
	--

%COMPONENTS%

	--
	-- Nets
	--

%SIGNALS%

%CONSTANTS%

begin

	--
	-- Generated Concurrent Statements
	--

%CONCURS%

	--
	-- Generated Instances
	--

%INSTANCES%

end %ARCHNAME%;

EOD
# Replaced %ARCHNAME% by RTL, requested by Michael P.
# Replaces end %ARCHNAME% by %ENTYNAME%

$EH{'template'}{'vhdl'}{'arch'}{'foot'} = <<'EOD';
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

$EH{'template'}{'verilog'}{'arch'}{'head'} = <<'EOD';
// -------------------------------------------------------------
//
// Generated Architecture Declaration for %ARCHNAME% of %ENTYNAME%
//
// Generated
//  by:  %USER%
//  on:  %DATE%
//  cmd: %ARGV%
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
// (C) 2003 Micronas GmbH
//
// --------------------------------------------------------------
%VERILOG_USE_ARCH%

%VERILOG_TIMESCALE%

//
EOD

$EH{'template'}{'verilog'}{'arch'}{'head'} =~ s/THISRCSFILE/$thisrcsfile/;
$EH{'template'}{'verilog'}{'arch'}{'head'} =~ s/THISID/$thisid/;

$EH{'template'}{'verilog'}{'arch'}{'body'} = <<'EOD';
//
// Start of Generated Module %ARCHNAME% of %ENTYNAME%
//

%VERILOG_DEFINES%

module %ENTYNAME%
%VERILOG_INTF%

    // Internal signals

%SIGNALS%

    // %COMPILER_OPTS%

%CONCURS%

    //
    // Generated Instances
    // wiring ...

%INSTANCES%

endmodule
//
// End of Generated Module %ARCHNAME% of %ENTYNAME%
//
EOD

$EH{'template'}{'verilog'}{'arch'}{'foot'} = <<'EOD';
//
//!End of Module/s
// --------------------------------------------------------------
EOD

}

sub tmpl_conf () {

# TODO: Read that templates in from default location (e.g. a company default)
$EH{'template'}{'vhdl'}{'conf'}{'head'} = <<'EOD';
-- -------------------------------------------------------------
--
-- Generated Configuration for %CONFNAME%
--
-- Generated
--  by:  %USER%
--  on:  %DATE%
--  cmd: %ARGV%
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
-- (C) 2003 Micronas GmbH
--
-- --------------------------------------------------------------
%VHDL_USE_CONF%

EOD

$EH{'template'}{'vhdl'}{'conf'}{'head'} =~ s/THISRCSFILE/$thisrcsfile/;
$EH{'template'}{'vhdl'}{'conf'}{'head'} =~ s/THISID/$thisid/;

$EH{'template'}{'vhdl'}{'conf'}{'body'} = <<'EOD';
--
-- Start of Generated Configuration %CONFNAME% / %ENTYNAME%
--
configuration %CONFNAME% of %ENTYNAME% is
        for %ARCHNAME%

	    %CONFIGURATION%

	end for; 
end %CONFNAME%;
--
-- End of Generated Configuration %CONFNAME%
--

EOD
# Replaced %ARCHNAME% by RTL, requested by Michael P. 

$EH{'template'}{'vhdl'}{'conf'}{'foot'} = <<'EOD';
--
--!End of Configuration/ies
-- --------------------------------------------------------------
EOD

}

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
            logwarn("Skipping instance $i with undefined entity!");
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
        );
    }

    # $eq will be 1 if acceptable differences exist, else 0!
    # compare_merge_entities will sum up acceptable differences in %entities and
    # complain verbosely otherwise
    my $eq = compare_merge_entities( $ent, $inst->{'::inst'}, $entities{$ent}, \%ient );
    #TODO: use result for further decision making

    #TODO: __LEAF__, another name??
    if ( $inst->{'::treeobj'}->daughters ne "0" ) {
	$ient{'__LEAF__'}++;
    }

    # Remember language for this entity ...    
    if ( exists( $inst->{'::lang'} ) and $inst->{'::lang'} ) {
        $ient{'__LANG__'}{lc($inst->{'::lang'})}++;
    } else {
        $ient{'__LANG__'}{lc($EH{'macro'}{'%LANGUAGE%'})}++;
    }
} # create_entity


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

    my $eflag = 1; # Is equal

    # for all ports:    
    for my $p ( keys( %$rent ) ) {
 
	next if ( $p =~ m,^__, ); # Skip internals like __LEAF__, __LANG__
       # Skip that if it does not exist in the new port map
        unless( exists( $rnew->{$p} ) ) {
	    if ( ( $p ne "-- NO OUT PORTs" and $p ne "-- NO IN PORTs" ) and
                 $ent ne "W_NO_ENTITY" ) {
		logwarn( "WARNING: Missing port $p in entity $ent ($inst) redeclaration, ignoreing!" );
		$eflag  = 0;
                $EH{'sum'}{'warnings'}++;
	    }
            next;
        }


        # type has to match
        if ( $rent->{$p}{'type'} ne $rnew->{$p}{'type'} ) {
            logwarn( "WARNING: Entity port type mismatch for entity $ent ($inst), port $p: ".
                     $rnew->{$p}{'type'} . " was " . $rent->{$p}{'type'} . "!" );
            $EH{'sum'}{'warnings'}++;
            $eflag = 0;
            next; #TODO: How should we handle that properly?
        # mode has to match
        } elsif ( $rent->{$p}{'mode'} ne $rnew->{$p}{'mode'} ) {
            logwarn( "WARNING: Entity port mode mismatch for enitity $ent ($inst), port $p: " .
                     $rnew->{$p}{'mode'} . " was " . $rent->{$p}{'mode'} . "!" );
            $EH{'sum'}{'warnings'}++;
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
    for my $p ( keys( %$rnew ) ) {
        #
	if ( $p ne "-- NO OUT PORTs" and $p ne "-- NO IN PORTs"
            and $ent ne "W_NO_ENTITY" ) {
	    logwarn( "WARNING: Declaration for entity $ent ($inst) extended by $p!" );
            $EH{'sum'}{'warnings'}++;
	    $eflag = 0;
    	}
        $rent->{$p} = $rnew->{$p}; # Copy
    }
    return $eflag;
}

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
        $entities{$ent}{'__LANG__'}{lc($EH{'macro'}{'%LANGUAGE%'})}++;
    }
    
} # create_entity

#
# Take ::in and ::out defined data and generate a port description ...
#
sub _create_entity ($$) {
    my $io = shift;
    my $ri = shift;

    my %res = ();
    for my $i ( keys( %$ri ) ) {
        my $sport = $ri->{$i};
	
        unless( defined( $conndb{$i} ) ) {
            logwarn("ERROR: Illegal signal name $i referenced!");
            $EH{'sum'}{'errors'}++;
            next;
        }

	my $type = $conndb{$i}{'::type'}; 
        my $cast = "";
	#
	# Iterate through all inst/ports ...
	#
        for my $port ( keys( %$sport ) ) {
            # my $index = $signal->{$port};
            # for my $ii ( split( ',', $index ) ) {
            #    #mode = in

	    #TODO: Catch all bad cases before in seperate check stage!
	    
	    my $h = -100000; # Absurd value .... just to avoid undef
	    my $l = -100000;  # Absurd value ....

	    # but may differ for this port ....
	    for my $ii ( split( ',', $$sport{$port} ) ) {
		my $thissig = $conndb{$i}{'::' . $io}[$ii]; # Get this signal ...
		# Find max/min port bounds ....
		#TODO: What if there are holes? Sanity checks need to be done before ...
		if ( defined $thissig->{'port_f'} and $thissig->{'port_f'} ne '' ) { # This is a bus ...
                    if ( $h =~ m,^-?\d+$,o ) {
                        if ( $thissig->{'port_f'} =~ m,^\d+$,o ) {
                            if ( $h < $thissig->{'port_f'} ) {
                                    $h = $thissig->{'port_f'};
                            }
                        } else { # port_f is non numeric ...
                            logwarn("WARNING: Non-numeric upper port bound for $thissig->{'inst'}/$thissig->{'port'}!")
                                unless ( $h == -100000 );
                            $h = $thissig->{'port_f'};
                        }
                    } else {
                        if ( $h ne $thissig->{'port_f'} ) {
                            logwarn("WARNING: Non-matching non-numeric upper port bound $thissig->{'inst'}/$thissig->{'port'}!");
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
                            logwarn("WARNING: Non-numeric lower port bound for $thissig->{'inst'}/$thissig->{'port'}!")
                                unless ( $l == -100000 );
                            $l = $thissig->{'port_t'};
                        }
                    } else {
                        if ( $l ne $thissig->{'port_t'} ) {
                            logwarn("WARNING: Non-matching non-numeric lower port bound $thissig->{'inst'}/$thissig->{'port'}!");
                            $EH{'sum'}{'warnings'}++;
                            $h = "__E_NONMATCH_NONNUM_LB";
                        }
                    }
		    # if ( $l == -100000 or $l > $thissig->{'port_t'} ) { $l = $thissig->{'port_t'}; }
		}

                #
                # typecast required
                #wig20030801
 
                # $type -> port type;
                # $cast -> signal type;
                if ( defined( $thissig->{'cast'} ) ) {
                    $cast = $type;
                    $type = $thissig->{'cast'};
                    logtrc ( "INFO:4", "typecast requested for signal $i/$cast, port $port/$type");
                }            
	    }
	    if ( $l eq "-100000" ) {
		$l = undef;
	    }
	    if ( $h eq "-100000" ) {
		$h = undef;
	    }

	    # If connecting single signals to a bus-port, make type match!
	    #TODO SPECIAL trick ???? Check if that is really so clever ....
	    #TODO Should be done by just any type ...
	    if ( ( $type eq "std_logic" or
		 $type eq "std_ulogic" ) and
		 defined( $h ) and defined( $l ) and
		 ( $h ne $l ) ) { #!wig20030516 ...
		$type = $type . "_vector";
		logtrc( "INFO:4", "autoconnecting single signal $i to bus port $port" );
	    }

            # If we connect a single bit to to a bus, we strip of the _vector from
            # the type of the signal to get correct port type
            #TODO: Expand to work for any type ...
            if ( not defined( $h ) and not defined( $l ) and
                  $type =~ m,(.+)_vector, ) {
		$type = $1;
		logtrc( "INFO:4", "autoreducing port type for signal $i to $type" );
            };
                
            my $m = $conndb{$i}{'::mode'};
	    my $mode = "__E_MODE_DEFAULT_ERROR__";
	    if ( $m ) { # not empty
		if ( $m =~ m,IO,io ) { $mode = "inout"; } 		# inout mode!
		elsif ( $m =~ m,B,io ) { $mode = "%BUFFER%"; }	# buffer
		elsif ( $m =~ m,C,io ) { $mode = $m; }		# Constant
		elsif ( $m =~ m,[GP],io ) {                             # Generic, parameter
                    # Read "value" from ...:out
                    $mode = $m;
                }
		elsif ( $m =~ m,S,io ) { $mode = $io; }			# signal -> derive from i/o
		elsif ( $m =~ m,I,io ) {						# warn if mode mismatches
		    #TODO: Need to look at all connections ....
		    if ( $io eq "out" ) {
			#!wig20030207:off: logwarn( "mode mismatch for signal $i, port $port: $m ne $io" );
			$conndb{$i}{'::comment'} .= ",__W_MODE_MISMATCH"; #TODO:  __E??
			$mode = $io;
		    } else {
			$mode = "in";
		    }
		} elsif ( $m =~ m,O,io ) {					# xls says O!
		    if ( $io eq "in" ) {
			#!wig20030207:off: logwarn( "mode mismatch for signal $i, port $port: $m ne $io" );
			$conndb{$i}{'::comment'} .= ",__W_MODE_MISMATCH"; #TODO: __E??
			$mode = $io;
		    } else {
			$mode = "out";
		    }
		} else {
		    logwarn( "ERROR: signal $i mode $m defaults to bad value, set to $io\n" );
                    $EH{'sum'}{'errors'}++;
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
                        logwarn("Warning: port $port redefinition mode mismatch: $mode " .
			    $res{$port}{'mode'} );
			    $res{$port}{'mode'} = "__W_PORTMODE_MISMATCH"; #TODO ???
                    }
		}

		# High bound:
		if ( defined( $h ) ) {
		    if ( defined( $res{$port}{'high'} ) ) {
			if ( $h > $res{$port}{'high'} ) {
			    $res{$port}{'high'} = $h;
			}
		    } else {
			if ( $h ) { # Defined, but 0, which is approx. undef.
			    logwarn("Warning: port $port high bound redefinition mismatch: $h vs. undef" );
			}
			$res{$port}{'high'} = $h;
		    }
		} elsif ( defined( $res{$port}{'high'} ) ) {
		    if( $res{$port}{'high'} ) { # Suppress message
			logwarn("Warning: port $port high bound redefinition mismatch: undef  vs. " .
			$res{$port}{'high'} );
		    }
		}
		# Low bound:
		if ( defined( $l ) ) {
		    if ( defined( $res{$port}{'low'} ) ) {
			if ( $l < $res{$port}{'low'} ) {
			    $res{$port}{'low'} = $l;
			}
		    } else {
			if ( $l ) {
			    logwarn("Warning: port $port low bound redefinition mismatch: $l vs. undef" );
                            $EH{'sum'}{'warnings'}++;
			}
			$res{$port}{'low'} = $l;
		    }
		} elsif ( defined( $res{$port}{'low'} ) ) {
		    if ( $res{$port}{'low'} ) { # Suppress message if 0
			logwarn("Warning: port $port low bound redefinition mismatch: undef  vs. " .
			    $res{$port}{'low'} );
                        $EH{'sum'}{'warnings'}++;
		    }
		}
		$l = $res{$port}{'low'};
		$h = $res{$port}{'high'};
		#
		# type mismatch handling:
		#

                #
                # Expand port to std_ulogic_type if required ...
                #TODO: Why here again? See above
		if ( defined( $h ) and defined ( $l ) and ( $h != $l ) and $type =~ m,(std_u?logic)\s*$, ) {
                    if ( ( $type . "_vector" ) ne $res{$port}{'type'} ) {
                        logwarn( "INFO: Autoexpand port $port from $type to vector type!");
                        $type = $1 . "_vector";
                    }
                    # $res{$port}{'type'} = $type;
		}
		
		if ( $type ne $res{$port}{'type'} ) {
		    if ( defined( $l ) and defined( $h ) and ( $h != $l ) ) { #Take _vector ...
			if ( $res{$port}{'type'} !~ m,_vector,io ) {
			    if ( $type =~ m,(std_u?logic),io ) {
				$res{$port}{'type'} = $type; # Automatically expand to vector type
			    } else {
				logwarn("Warning: port $port redefinition type mismatch: $type vs. " .
				    $res{$port}{'type'} );
                                $EH{'sum'}{'warnings'}++;
			    }
			# } else {
			#    logwarn("Warning: port $port redefinition type mismatch: $type vs. " .
			#    $res{$port}{'type'} );
			#    # $res{$port}{'type'} #TODO ???
			}
		    }
		}
		
                # Detect bad typecast requests (differing!!)
    		if ( $cast and exists( $res{$port}{'cast'} ) ) {
                    if ( $cast ne $res{$port}{'cast'} ) {
                        logwarn( "WARNING: port $port typecast mismatch: $cast was $res{$port}{'cast'}" );
                        $EH{'sum'}{'warnings'}++;
                    }
    		} elsif( $cast or exists( $res{$port}{'cast'} ) ) {
                        my $c = ( defined( $cast ) ) ? $cast : "NOT_NOW";
                        my $cp = ( defined( $res{$port}{'cast'} ) ) ?
                            $res{$port}{'cast'} : "NOT_BEFORE";
                        logwarn( "WARNING: port $port typecast requested: $cp was $cp" );
                        $EH{'sum'}{'warnings'}++;
    		}

	    } else {
		%{$res{$port}} = (
		    'mode' => $mode, #TODO: do some sanity checking! e.g. high, low might be
					# undefined, check if bus vs. bit. and consider the ::mode!
		    'type' => $type,  #|| 'signal', # type defaults to signal
		    'high' => $h,  # set default to '' string
		    'low'  => $l,   # set default to '' string
		);
                $res{$port}{'cast'} = $cast if $cast; # Adding a typecast if requested
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
	# $res{'__SIGNAL__'}{$i}=; # Remember signals connected
    }
    return %res;
}

####################################################################
## write_entities
## write entities
####################################################################

=head2

write_entities () {

Write entity into output file(s).

=cut

sub write_entities () {

    # Set up entity template;
    tmpl_enty();
    
    # output file name
    my $efname = $EH{'outenty'};
    if ( $efname =~m/^(ENTY|COMB)/o ) {
        # ENTY -> write each entity in a file of it's own
        # COMB(INE) -> combine entity, architecture and configuration
        #  this is mostly important for architecture and configuration
        # filename is the entity name
        # All other cases -> use efname as entity file name (write all entities into
        # one file of that name)
        my $entext = $EH{'postfix'}{'POSTFILE_ENTY'};
        if ( $1 eq "COMB" ) {
            $entext = "";
        }
	for my $i ( sort( keys( %entities ) ) ) {
            
                next if ( $i eq "W_NO_ENTITY" );
                
                my $i_fn = $i;
                #Changed 20030714a/Bug:
                $i_fn =~ s,_,-,og if ( $EH{'output'}{'filename'} =~ m,allminus, );
                # replace _ by - in entity names.

                # In combine mode, choose entity.vhd as filename.
                # my $lang = "vhdl"; # Filename extension defaults to VHDL
                my $lang = mix_wr_getlang( $i, $entities{$i}{__LANG__} );
		my $filename = $i_fn . $entext . "." . $EH{'output'}{'ext'}{$lang};
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
# languages (all the one we have $EH{'template'} for)
#
sub mix_wr_getlang ($$) {
    my $enti = shift;
    my $entylangr = shift;

    my @langs = keys %$entylangr;
    my $requested = scalar( @langs );

    my $goodlang = "(" . join( "|", keys( %{$EH{'template'}} )) . ")";
    @langs = grep( m/^$goodlang/ , @langs ); # Select available languages    
    if ( scalar( @langs ) > 1 ) {
        logwarn("WARNING: requesting multiple languages for entity $enti!");
    } elsif ( $requested > 1 ) {
        logwarn("WARNING: autoresolved multiple language request for entity $enti!");
    }
    if ( scalar( @langs ) < 1 ) {
        return $EH{'macro'}{'%LANGUAGE%'};
    } else {
        return $langs[0];
    }
}

#
# Do the work: Collect ports and generics from %entities.
# Print out and also save port and generics for later reusal (e.g. architecture)
#
#20030523: add Verilog -> output comment
#TODO: rework that, split the parts that build internally used information
# and the pure writer into two. REMOVE SIDEEFFECTS
#
sub _write_entities ($$$) {
    my $ehname = shift;
    my $file = shift;
    my $ae = shift;

    my %macros = %{$EH{'macro'}};

    $macros{'%ENTYNAME%'} = $ehname;

    if ( -r $file ) {
	logtrc(INFO, "Entity declaration file $file will be overwritten!" );
    }

    #
    # Do not create an output file if entitiy is leaf and "noleaf" set
    #
    my $write_flag = 1;
    my $fh = undef;
 
    #
    # will write a output file anyway if we are in __COMMON__ mode
    # or if we want to write leaf cells and it's a leaf cell
    # or if it's VHDL
    #
    if ( $ehname ne "__COMMON__" and
            ( $EH{'output'}{'generate'}{'enty'} =~ m,noleaf,io and
            $entities{$ehname}{'__LEAF__'} == 0 or
            mix_wr_getlang( $ehname, $ae->{$ehname}{'__LANG__'}) ne "vhdl" )
        ) {
            $write_flag = 0; # Do NOT write ...
    }
    
    if ( $write_flag ) {
        unless ( $fh = mix_utils_open( $file ) ) {
            logwarn( "Cannot open file $file to write entity declarations: $!" );
            return;
        }
    }

    # Add header
    my $tpg = $EH{'template'}{'vhdl'}{'enty'}{'body'};

    # Collect all use libs from all instances here!
    $macros{'%VHDL_USE%'} = use_lib( "enty", $ehname );

    my $et = replace_mac( $EH{'template'}{'vhdl'}{'enty'}{'head'}, \%macros);    

    #
    # Collect generics and ports ...
    #
    my @keys = ( $ehname eq "__COMMON__" ) ? keys( %$ae ) : ( $ehname );
    for my $e ( sort( @keys ) ) {

	if ( $e eq "W_NO_ENTITY" ) { next; };
	if ( $e eq "__COMMON__" ) { next; };

	$macros{'%ENTYNAME%'} = $e;
	my $gent = "";
	my $port = "";
	my $pd = $ae->{$e};
        # This language and this comment is
        my $lang = mix_wr_getlang( $e, $pd->{'__LANG__'});
        my $tcom = $EH{'output'}{'comment'}{$lang} || $EH{'output'}{'comment'}{'vhdl'};

        # Get interface description for this instance
        ( $port, $gent ) = mix_wr_get_interface( $pd, $e, $lang, $tcom );

	#
	# If we found ports, 
	# get rid of trailing ; (possibly followed by a comment), replace %MACs%
	# store the results in the entities data structure (will need it later on
	# for the component declarations
	#
        unless ( is_vhdl_comment( $port ) ) {
            # $port = 
            $port = "\t\t" . $tcom . " Generated Port for Entity $e\n" . $port;
            $port =~ s/;(\s*$tcom.*\n)$/$1/io;
            $port =~ s/;\n$/\n/io;
            $port .= "\t\t" . $tcom . " End of Generated Port for Entity $e\n";
            # Store ports and generics for later reusal
            $entities{$e}{'__PORTTEXT__'}{$lang} = $port;
            $port = "\t\tport(\n" . $port . "\t\t);";
        } else {
            $entities{$e}{'__PORTTEXT__'}{$lang} = $port;
            $port = "\t\t" . $tcom . " No Generated Port for Entity $e\n$port";
        }
        # The same for generics
        unless ( is_vhdl_comment( $gent ) ) {
            $gent = "\t\t" . $tcom . " Generated Generics for Entity $e\n" . $gent;            
            $gent =~ s/;(\s*$tcom.*\n)$/$1/io;
            $gent =~ s/;\n$/\n/io;
            $gent .= "\t\t" . $tcom . " End of Generated Generics for Entity $e\n";
            # Store ports and generics for later reusal
            $entities{$e}{'__GENERICTEXT__'}{$lang} = $gent;
            $gent = "\t\tgeneric(\n" . $gent . "\t\t);";
        } else {
            $entities{$e}{'__GENERICTEXT__'}{$lang} = $gent;
            $gent = "\t\t" . $tcom . " No Generated Generics for Entity $e\n$gent";
        }
	
	$macros{'%PORT%'} = $port;
	$macros{'%GENERIC%'} = $gent;

	unless ( $EH{'output'}{'generate'}{'enty'} =~ m,noleaf,io and
	    $ae->{$e}{'__LEAF__'} == 0  ) {

            #
            # If language other then vhdl -> don't write a thing.
            # makes sense only in __COMMON__ case
            #
            if ( $lang ne "vhdl" ) {
                $et .= "\t\t--\n\t\t-- $lang language choosen for entity $e\n\t\t--\n";
            } else {
                $et .= replace_mac( $tpg, \%macros );
            }
	}
    }
    
    $et .=  $EH{'template'}{'vhdl'}{'enty'}{'foot'};

    $et = replace_mac( $et, \%macros );

    $et = strip_empty( $et );

    # All data collected, now print and close ...
    if ( $write_flag ) {
        mix_utils_print( $fh, $et );
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
##  $r_ent   reference to entity description hash
## $ename  entity name
## $lang      requested language
## $tcom     comment ( -- or // ... )
##
## return values:
##      $port        text description of this entites ports
##      $generics  text description of this entities generics
## side effects:
##     ????
##
####################################################################
sub mix_wr_get_interface ($$$$) {
    my $r_ent = shift;
    my $ename = shift; # Name of entity ...
    my $lang = shift;
    my $tcom = shift;

    if ( $lang =~ m,vhdl,io ) {
        return ( _mix_wr_get_ivhdl( $r_ent, $ename, $tcom ) );
    }elsif ( $lang =~ m,verilog,io ) {
        return ( _mix_wr_get_iveri( $r_ent, $ename, $tcom ) );
    } else {
        logwarn( "WARNING: unimplemented get_interface for entity $ename, language $lang" );
        $EH{'sum'}{'warnings'}++;
        return( "\t\t" . $tcom . " __W_MISSING_GET_INTERFACE for $lang",
                    "\t\t" . $tcom . " __W_MISSING_GET_INTERFACE for $lang" );
    }
}

#
# return VHDL conform interface (port list ....)
#
sub _mix_wr_get_ivhdl ($$$) {
    my $r_ent = shift;
    my $ename = shift; # Name of entity ...
    my $tcom = shift;

    my $gent = "";
    my $port = "";

    for my $p ( sort ( keys( %{$r_ent} ) ) ) {
	    next if ( $p =~ m,^__,o ); # Skip internal data ...
            next if ( $p =~ m,^-- NO, ); # Skip internal data ...
	    
	    my $pdd = $r_ent->{$p};

	    if ( $pdd->{'mode'} =~ m,^\s*(generic|G|P),io ) {
		if ( exists( $pdd->{'value'} ) ) {
                # Generic, get default value from conndb ...
                    $gent .= $EH{'macro'}{'%S%'} x 3 . $p . "\t: " . $pdd->{'type'} . "\t:= " . $pdd->{'value'} . ";\n";
		} else {
                    $gent .= $EH{'macro'}{'%S%'} x 3 . $p . "\t: " . $pdd->{'type'} . "; $tcom __W_NODEFAULT\n";
		}
	    } elsif (	defined( $pdd->{'high'} ) and
			defined( $pdd->{'low'} ) and
                        $pdd->{'high'} !~ m,^\s*$,o and
                        $pdd->{'low'} !~ m,^\s*$,o ) {

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
                            logtrc( "INFO:4", "Port $p of entity $ename one bit wide, reduce to signal\n" );
                            $pdd->{'type'} =~ s,_vector,,; # Try to strip away trailing vector!
                            $pdd->{'low'} = undef;
                            $pdd->{'high'} = undef;
                            $port .= $EH{'macro'}{'%S%'} x 3 . $p . "\t: " . $mode . "\t" . $pdd->{'type'} .
                                "; $tcom __I_AUTO_REDUCED_BUS2SIGNAL\n";
                        } else {
                            logwarn( "Warning: Port $p of entity $ename one bit wide, missing lower bits\n" );
                            $EH{'sum'}{'warnings'}++;
                            $port .= $EH{'macro'}{'%S%'} x 3 . $p . "\t: " . $mode . "\t" . $pdd->{'type'} .
                                "(" . $pdd->{'high'} . "); $tcom __W_SINGLEBITBUS\n";
                        }
                    } elsif ( $pdd->{'high'} > $pdd->{'low'} ) {
                        $port .= $EH{'macro'}{'%S%'} x 3 . $p . "\t: " . $mode . "\t" . $pdd->{'type'} .
                            "(" . $pdd->{'high'} . " downto " . $pdd->{'low'} . ");\n";
                    } else {
                        $port .= $EH{'macro'}{'%S%'} x 3 . $p . "\t: " . $mode. "\t" . $pdd->{'type'} .
                            "(" . $pdd->{'high'} . " to " . $pdd->{'low'} . ");\n";
                    }
                }else {
                    if ( $pdd->{'high'} eq $pdd->{'low'} ) {
                        # $pdd->{'type'} =~ s,_vector,,; # Try to strip away trailing vector!
                        $port .= $EH{'macro'}{'%S%'} x 3 . $p . "\t: " . $mode . "\t" . $pdd->{'type'} .
                            "(" . $pdd->{'high'} . ");\n";
                    #!wig20030812: adding support for non-numeric signal/port bounds
                    } else {
                        $port .= $EH{'macro'}{'%S%'} x 3 . $p . "\t: " . $mode . "\t" . $pdd->{'type'} .
                            "(" . $pdd->{'high'} . " downto " . $pdd->{'low'} . ");\n";
                    }
                }
	    } else {
		my $mode = "";
		if ( $pdd->{'mode'} =~ m,^\s*C,io ) {
		    $mode = "in";
		} else {
		    $mode = $pdd->{'mode'};
		}
		    $port .= $EH{'macro'}{'%S%'} x 3 . $p . "\t: " . $mode . "\t" . $pdd->{'type'} . ";\n";
	    }
	    #TODO: Check all case where only on of high or low is defined or high and/or
	    # low are not digit!
	}
        return( $port, $gent );
}

#
# return Verilog conform interface (list of ports ....)
#  borrows a lot from the vhdl code above :-)
#
sub _mix_wr_get_iveri ($$$) {
    my $r_ent = shift;
    my $ename = shift; # Name of entity ...
    my $tcom = shift;

    # Possible Verilog modes. Please extend %ioky, %port and %portheader
    my %ioky = (
        'in' => "input",
        'out' => "output",
        'io' => "inout",
        'inout' => "inout", 
        'not_valid' => "__W_INVALID_PORT",
    );
    
    my $gent = "";
    my $intf = "\t\t(\n"; # Module interface ...
    my %port = (
        'out'   => "",
        'in'    => "",
        'io'    => "",
        'inout' => "",
        'not_valid' => "",
        'wire'  => "",
    );
    my %portheader = (
        'out'   => "\t\t$tcom Generated Module Outputs:\n",
        'in'    => "\t\t$tcom Generated Module Inputs:\n",
        'io'    => "\t\t$tcom Generated Module In/Outputs:\n",
        'inout'    => "\t\t$tcom Generated Module In/Outputs:\n",
        'not_valid' => "\t\t$tcom __W_NOT_VALID Module In/Outputs:\n",
        'wire'  => "\t\t$tcom Generated Wires:\n",
    );

    for my $p ( sort ( keys( %{$r_ent} ) ) ) {
	    next if ( $p =~ m,^__,o ); #Skip internal data ...
            next if ( $p =~ m,^-- NO, );
	    
	    my $pdd = $r_ent->{$p};

	    if ( $pdd->{'mode'} =~ m,^\s*(generic|G|P),io ) {
		if ( exists( $pdd->{'value'} ) ) {
                #Generic, with default value from conndb ...
                    $gent .= $EH{'macro'}{'%S%'} x 2 . $tcom . " __W_VERI_GENERIC: " . $p .
                                " " . $pdd->{'type'} . " := " . $pdd->{'value'} . ";\n";
		} else {
                    $gent .= $EH{'macro'}{'%S%'} x 2 . $tcom . " __W_VERI_GENERIC: " . $p .
                                " " . $pdd->{'type'} . "; " . $tcom . " := __W_NODEFAULT;\n";
		}
            } elsif (	defined( $pdd->{'high'} ) and
			defined( $pdd->{'low'} ) and
                        $pdd->{'high'} !~ m,^\s*$,o and
                        $pdd->{'low'} !~ m,^\s*$,o ) {
		# Signal ...from high to low. Ignore everything not matching
		# this pattern (e.g. only one bound set ....)
		my $mode = "";
		if ( $pdd->{'mode'} =~ m,^\s*C,io ) {
		    $mode = "in";
		} else {
		    $mode = $pdd->{'mode'};
		}
                my $valid = "";
                unless( exists( $ioky{$mode} ) ) {
                    $valid = $tcom . " __I_PORT_NOT_VALID ";
                    $mode = "not_valid";
                }
		# Numeric bounds:
		if ( $pdd->{'high'} =~ m/^\s*[+-]?\d+\s*$/o and
                     $pdd->{'low'} =~ m/^\s*[+-]?\d+\s*$/o ) {
                    if ( $pdd->{'high'} == $pdd->{'low'} ) {
                        if ( $pdd->{'high'} == 0 ) {
                            # Special case: single pin "bus" -> reduce to it ....
                            logtrc( "INFO:4", "INFO: Port $p of entity $ename one bit wide, reduce to signal\n" );
                            $pdd->{'type'} =~ s,_vector,,; # Try to strip away trailing vector!
                            $pdd->{'low'} = undef;
                            $pdd->{'high'} = undef;

                            $intf .= $EH{'macro'}{'%S%'} x 2 . $valid . $p . ",\n";
                            $port{$mode} .= $EH{'macro'}{'%S%'} x 2 . $valid . $ioky{$mode} . "\t\t" . $p . ";\t" .
                                "\t$tcom __I_AUTO_REDUCED_BUS2SIGNAL\n";
                            $port{'wire'} .= $EH{'macro'}{'%S%'} x 2 . $valid . "wire\t\t" . $p . ";\t" .
                                "\t$tcom __I_AUTO_REDUCED_BUS2SIGNAL\n";
                        } else {
                            logwarn( "Warning: Port $p of entity $ename one bit wide, missing lower bits\n" );
                            $EH{'sum'}{'warnings'}++;
                            #OLD my $valid = "";
                            # unless( exists( $ioky{$mode} ) ) {
                            #    $valid = $tcom . " __I_PORT_NOT_VALID ";
                            #    $mode = "not_valid";
                            # }
                            $intf .= $EH{'macro'}{'%S%'} x 2 . $valid . $p . ",\n";
                            $port{$mode} .= $EH{'macro'}{'%S%'} x 2 . $valid . $ioky{$mode} . "\t[" .
                                    $pdd->{'high'} . ":" . $pdd->{'low'} . "]\t" . $p .
                                    ";\t$tcom __W_SINGLEBITBUS\n";
                            $port{'wire'} .= $EH{'macro'}{'%S%'} x 2 . $valid . "wire\t[" .
                                    $pdd->{'high'} . ":" . $pdd->{'low'} . "]\t" . $p .
                                    ";\t$tcom __W_SINGLEBITBUS\n";
                        }
                    } elsif ( $pdd->{'high'} > $pdd->{'low'} ) {
                        #OLD: my $valid = "";
                        # unless( exists( $ioky{$mode} ) ) {
                        #    $valid = $tcom . " __I_PORT_NOT_VALID ";
                        #    $mode = "not_valid";
                        # }
                        $intf .= $EH{'macro'}{'%S%'} x 2 . $valid . $p . ",\n";
                        $port{$mode} .= $EH{'macro'}{'%S%'} x 2 . $valid . $ioky{$mode} . "\t[" .
                                    $pdd->{'high'} . ":" . $pdd->{'low'} . "]\t" . $p . ";\n";
                        $port{'wire'} .= $EH{'macro'}{'%S%'} x 2 . $valid . "wire\t[" .
                                    $pdd->{'high'} . ":" . $pdd->{'low'} . "]\t" . $p . ";\n";
                    } else {
                        #TODO: Check if Verilog allows this ...
                        #Couple warning on check flag for desig guide line "downto busses"
                        logwarn( "WARNING: Port $p, entity $ename, high bound < low bound!" );
                        $EH{'sum'}{'warnings'}++;
                        #OLD: my $valid = "";
                        # unless( exists( $ioky{$mode} ) ) {
                        #    $valid = $tcom . " __I_PORT_NOT_VALID ";
                        #    $mode = "not_valid";
                        # }
                        $intf .= $EH{'macro'}{'%S%'} x 3 . $valid . $p . ",\n";
                        $port{$mode} .= $EH{'macro'}{'%S%'} x 2 . $valid . $ioky{$mode} . "\t[" .
                                    $pdd->{'high'} . ":" . $pdd->{'low'} . "]\t" . $p . ";\n";
                        $port{'wire'} .= $EH{'macro'}{'%S%'} x 2 . $valid . "wire\t[" .
                                    $pdd->{'high'} . ":" . $pdd->{'low'} . "]\t" . $p . ";\n";
                    }
		} else {
                    #wig20030812:
                    # Non numeric bounds ...
                    if ( $pdd->{'high'} eq $pdd->{'low'} ) {
                        $intf .= $EH{'macro'}{'%S%'} x 3 . $valid . $p . ",\n";
                        $port{$mode} .= $EH{'macro'}{'%S%'} x 2 . $valid . $ioky{$mode} . "\t[" .
                                    $pdd->{'high'} . "]\t" . $p . ";\n";
                        $port{'wire'} .= $EH{'macro'}{'%S%'} x 2 . $valid . "wire\t[" .
                                    $pdd->{'high'} . "]\t" . $p . ";\n";
                    } else {
                        $intf .= $EH{'macro'}{'%S%'} x 3 . $valid . $p . ",\n";
                        $port{$mode} .= $EH{'macro'}{'%S%'} x 2 . $valid . $ioky{$mode} . "\t[" .
                                    $pdd->{'high'} . ":" . $pdd->{'low'} . "]\t" . $p . ";\n";
                        $port{'wire'} .= $EH{'macro'}{'%S%'} x 2 . $valid . "wire\t[" .
                                    $pdd->{'high'} . ":" . $pdd->{'low'} . "]\t" . $p . ";\n";
                    }
		}
            } else {
		my $mode = "";
		if ( $pdd->{'mode'} =~ m,^\s*C,io ) {
		    $mode = "in";
		} else {
		    $mode = $pdd->{'mode'};
		}
                my $valid = "";
                unless( exists( $ioky{$mode} ) ) {
                    $valid = $tcom . " __I_PORT_NOT_VALID ";
                    $mode = "not_valid";
                }		
                $intf .= $EH{'macro'}{'%S%'} x 2 . $valid . $p . ",\n";
                $port{$mode} .= $EH{'macro'}{'%S%'} x 2 . $valid . $ioky{$mode} . "\t\t" . $p . ";\n";
                $port{'wire'} .= $EH{'macro'}{'%S%'} x 2 . $valid . "wire\t\t" . $p . ";\n";
	    }
    }
    # Finalize intf: add all inputs, outputs and inouts ....
    $intf .= $EH{'macro'}{'%S%'} x 2 . ");\n";
    # Print out inputs, outputs, inouts and wires ...
    for my $i ( sort keys %port ) {
        if ( $port{$i} ) {
            $intf .= $portheader{$i};
            $intf .= $port{$i};
        }
    }
    return( $intf, $gent );
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
    my $efname = $EH{'outarch'};
    if ( $efname =~m/^(ARCH|COMB)/o ) {
        my $archext = $EH{'postfix'}{'POSTFILE_ARCH'};
        if ( $1 eq "COMB" ) {
            $archext = "";
        }
	# Write each architecture in a file of it's own
	for my $i ( sort( keys( %hierdb ) ) ) {
		# Skip it if it was seen before
		#TODO: sort be order of hierachy
		#TODO: will that be unique?
		my $e = $hierdb{$i}{'::entity'};

	    	# Should we print it? if the noleaf flag ist set, skip
		next if ( $e eq "W_NO_ENTITY" );
		if ( $EH{'output'}{'generate'}{'arch'} =~ m,noleaf,io and
		    not $hierdb{$i}{'::treeobj'}->daughters ) {
		    next;
		}
                # Prepare for an alternate filename (if entity got instantiated multiple times)
                my $alt = "";
		if ( exists( $seen{$e} ) ) {
                    next unless ( $EH{'output'}{'generate'}{'arch'} =~ m,alt,io );
                    $alt = "-alt" . $seen{$e}++;
                    logtrc( "INFO", "Writing another architecture for $e (inst: $i)" );
		}
		$seen{$e}++;
                # Generate an output filename
                my $filename;
                my $e_fn = $e;
                #Changed 20030714a/Bug: replace - by _ ...
                $e_fn =~ s,_,-,go if ( $EH{'output'}{'filename'} =~ m,allminus, );
                # replace _ by - in entity names.
                # In combine mode, choose entity.vhd as filename.
                # Filename extension defaults to VHDL

                # Language? vhdl, verilog or what else?
                my $lang = lc( $hierdb{$i}{'::lang'} ) || $EH{'macro'}{'%LANGUAGE%'};
                unless ( exists ( $EH{'template'}{$lang} ) ) {
                    logwarn( "WARNING: Illegal language $lang selected. Autoswitch to $EH{'macro'}{'%LANGUAGE%'}!" );
                    $lang = $EH{'macro'}{'%LANGUAGE%'};
                }
		# my $filename = $i_fn . $entext . "." . $EH{'output'}{'ext'}{$lang};
                if ( $lang =~ m,^veri,io ) {
                    # verilog filename:
                    $filename = $e_fn . "." . $EH{'output'}{'ext'}{$lang} . $alt;    
                } elsif ( $efname =~ m/^COMB/o ) {
                    # Combined output
                    $filename = $e_fn . "." . $EH{'output'}{'ext'}{$lang} . $alt;
                } elsif ( $hierdb{$i}{'::arch'} ) {
                        $filename = $e_fn . "-" . $hierdb{$i}{'::arch'} .
                            $archext . "." .
                            $EH{'output'}{'ext'}{$lang} . $alt;
                } else {
                        $filename = $e_fn . $archext . "."
                        . $EH{'output'}{'ext'}{$lang} . $alt;
                }
                _write_architecture( $i, $e, $filename, \%hierdb );
	}
    } else {
	_write_architecture( "__COMMON__", "__COMMON__", $efname, \%hierdb );
    }

    return;

}

####################################################################
## gen_instmap
## generate an instance map 
####################################################################

=head2

gen_instmap ($$$) {

Return an port map for the instance and a list of in and out signals

Input:
    instancename
    language (default: $EH{'macro'}{'%LANGUAGE%'} aka. VHDL)
    comment (default to comment string of language or ##)

=cut

sub gen_instmap ($;$$) {
    my $inst = shift;
    my $lang = shift || lc( $EH{'macro'}{'%LANGUAGE%'} );
    my $tcom = shift || $EH{'output'}{'comment'}{$lang} || $EH{'output'}{'comment'}{'default'};
    
    my $map = "";
    my $gmap = "";
    
    my @in = ();
    my @out = ();
    my $enty = $hierdb{$inst}{'::entity'};

    #
    # Iterate through all signals attached to that instance:
    #
    my $rinstc = $hierdb{$inst}{'::conn'};
    $map .= port_map( 'in', $inst, $enty, $lang, $rinstc->{'in'}, \@in );

    if ( exists( $rinstc->{'generic'} ) ) {
        $gmap .= generic_map( 'in', $inst, $enty, $rinstc->{'generic'} );
    }
 
    $map .= port_map( 'out', $inst, $enty, $lang, $rinstc->{'out'}, \@out );

    # Sort map:
    $map = join( "\n", sort( split ( /\n/, $map ) ) );

    #wig20030808: Adding Verilog port splice collector .. for mpallas
    #TODO: Shouldn't that be integrated into the print_conn_matrix function?
    if ( $lang =~ m,^veri,io and $map =~ m,\]\(, ) {
        $map = mix_wr_unsplice_port( $map, $lang, $tcom );
    }


    # Remove trailing , and such (VHDL)
    $map =~ s/,(\s*--.*)\n?$/$1\n/o;
    $map =~ s/,\s*\n?$/\n/o;
    $gmap =~ s/,(\s*--.*)\n?$/$1\n/o;
    $gmap =~ s/,\s*\n?$/\n/o;

    unless( is_vhdl_comment( $gmap ) or $lang =~ m,^veri,io ) {
        $gmap = $EH{'macro'}{'%S%'} x 2 . "generic map (\n" . $gmap .
            $EH{'macro'}{'%S%'} x 2 .")\n"; # Remove empty definitons
    }

    unless( is_vhdl_comment( $map ) or $lang =~ m,^veri,io ) {    
        $map = $EH{'macro'}{'%S%'} x 2 . "port map (\n" . $map .
            $EH{'macro'}{'%S%'} x 2 . ");\n";
    } else {
        if ( $lang !~ m,^veri,io ) {
            $map .= $EH{'macro'}{'%S%'} x 2 . ";\n"; # Get a trailing ;
        }
    }

    if ( $lang =~ m,^veri,io ) {
        $map =  $EH{'macro'}{'%S%'} x 2 . $tcom . " Generated Instance Port Map for $inst\n" .
                $EH{'macro'}{'%S%'} x 2 ."$enty $inst(" .
                (  $hierdb{$inst}{'::descr'} ? ( $EH{'macro'}{'%S%'} . "// "
                        . $hierdb{$inst}{'::descr'} ) : "" ) .
                "\n" .
                $gmap .
                $map .
                $EH{'macro'}{'%S%'} x 2 . ");". $tcom . " End of Generated Instance Port Map for $inst\n";
    } else {
        $map =  $EH{'macro'}{'%S%'} x 2 . "-- Generated Instance Port Map for $inst\n" .
                $EH{'macro'}{'%S%'} x 2 . $inst . ": " . $enty .
                (  $hierdb{$inst}{'::descr'} ? ( $EH{'macro'}{'%S%'} . "-- " .
                        $hierdb{$inst}{'::descr'} ) : "" ) .
                "\n" .
                $gmap .
                $map .
                $EH{'macro'}{'%S%'} x 2 . "-- End of Generated Instance Port Map for $inst\n";
    }
                
    return( $map, \@in, \@out);
}

#
# Try to collect spliced ports like
#   .port[N:M]( some )
#   .port[K](more )
#  -> .port( more & some )
#TODO: Resolve that and be more clever with writing the map instead
# of doing it backwards ...
#
# Currently only works for Verilog ...
sub mix_wr_unsplice_port ($$$) {
    my $map = shift;
    my $lang = shift;
    my $tcom = shift;
    
 
        my @out = ();
        my %col = ();
        # Read in spliced port maps ...
        for my $l ( split( "\n", $map ) ) {
            # ($RE{balanced}{-parens=>'()'})
            if ( $l =~ m!(\s*)\.(\w+)
                        ($RE{balanced}{-parens=>'[]'})   # [(\d+)(:(\d+))]
                         \s*
                        ($RE{balanced}{-parens=>'()'})   # (.*?)
                        ,(.*)                                       # Trailing comments
                        !x ) {
                # s.th. to collect ...
                my ( $pre, $p, $hl, $s, $c ) = ( $1, $2, $3, $4, $5 );
                my $hb = -2;
                my $lb = -1;
                if ( $hl =~ m,\[(\d+)(:(\d+))?\], ) {
                    $hb = $1;
                    $lb = ( defined( $3 ) ? $3 : $hb );
                } # else {
                #    logerr( "FATAL: Died of unexpected branch in collect_spliced_port" );
                #    exit 1;
                # }
                if ( $s =~ m,\((.+)\), ) {
                    $s = $1;
                } else {
                    # Open port .... put enough space in place 
                    # logerr( "FATAL: Died of unexpected branch in collect_spliced_port" );
                    # exit 1;
                    # Add a dummy signal (use w'bz for now ... )
                    #TODO: What if $hb and $lb are non numeric?
                    my $w = $hb - $lb + 1;
                    $s = $w . "'bz"; # Comes from open ports ....
                }
                push( @{$col{$p}}, [ $hb, $lb , $pre, $s, $c ] );
            } else {
                push( @out, $l );
            }
        }
        # We found collectable ports -> scan through them topdown and
        # write out better format
        my $flag = 0;
        for my $p ( keys( %col ) ) {
            my @arr=();
            my $nn = -1;
            for my $n ( @{$col{$p}} ) {
                # Check bounds for this port
                $nn++;
                if ( $n->[0] < $n->[1] ) {
                    logwarn( "ERROR: Cannot collect spliced port $p, bad bound order!");
                    $EH{'sum'}{'errors'}++;
                    $flag = 1;
                    # Print out as-is
                    last;
                }
                # Create usage vector ...
                for my $b ( $n->[1] .. $n->[0] ) {
                    if ( defined ( $arr[$b] ) ) {
                        logwarn( "ERROR: Duplicate connection at spliced port $p!" );
                        $flag = 1;
                        last;
                    } else {
                        $arr[$b] = $nn;
                    }
                }
            }
            # Finally: build port string, right to left
            my $t = "";
            my @c = "";
            unless( $flag ) {
                my $start = -1;
                for my $b ( 0..(scalar(@arr) - 1) ) {
                    if ( defined( $arr[$b] ) and $arr[$b] ne $start ) {
                        my $data = $col{$p}[$arr[$b]];
                        my $es = $data->[3];
                        if ( $es =~ m,^%(HIGH|LOW),o ) {
                            # Replace HIGH/LOW immediately!!
                            my $v = ( $1 eq "HIGH" ) ? "1" : "0";
                            my $w = $data->[0] - $data->[1] + 1;
                            $es = $w . "'b" . $v x $w; #Verilog, only!
                        }  
                        #!wig20030812: create { a , b, c } format
                        # $t = " & " . $es . $t;
                        $t = ", " . $es . $t;
                        push( @c, $data->[4] );
                        $start = $arr[$b];
                    } elsif ( not defined( $arr[$b] ) ) {
                        logwarn( "ERROR: Detected missing bits in spliced port $p!" );
                        $EH{'sum'}{'error'}++;
                        $flag = 1;
                        last;
                    }
                }
            }
            #TODO: How can we check if the port width equals all found bits?
            # $t =~ s,^ & ,,;
            $t =~ s#^,##;
            if ( $t =~ m#,# ) { # enclose signal into {} if > 1 parts found ...
                $t = "{" . $t . " }";
            }
            # Create comment -> remove duplicates ...
            my %c = ();
            my $c = "";
            for my $n ( @c ) {
                # Remove trailing \s and $tcom
                $n =~ s,^\s*$tcom\s*,,;
                $c{$n}++ if ( $n );
            }
            for my $n ( keys( %c ) ) {
                if ( $c{$n} > 1 ) {                    
                    $c .= $tcom . " " . $n . " (x" . $c{$n} . ") ";
                } else {
                    $c .= $tcom . " " . $n . " ";
                }
            }
            
            if ( $flag ) {
                for my $n ( @{$col{$p}} ) {
                    push( @out, $n->[2] . "." . $p . "[" . $n->[0] .
                        ( ( $n->[0] ne $n->[1] ) ? ( ":" . $n->[1] ) : "" ) .
                            "](" . $n->[3] . "), " .
                        ( ( $n->[4] ) ? $n->[4] : "" ) .
                        $tcom . " __E_CANNOT_COMBINE_SPLICES" );
                }
            } else {
                #TODO: Detect HIGH/LOW_BUS and splice these acordingly!!
                push( @out, $EH{'macro'}{'%S%'} x 3 . "." . $p . "(" . $t . "), " .
                      $c . $tcom . " __I_COMBINE_SPLICES" );
            }
        }
        # Replace the map ....
        $map = join( "\n", sort( @out ) );
        return $map;
}

#
# create generic map, ...
#
# Input:
#  $io  = 'in' or 'out'
#  $inst = instancename
#  $enty = entityname
#  $ref = reference to $hierdb{$i}{::conn}{$io}
#
sub generic_map ($$$$) {
    my $io = shift;
    my $inst = shift;
    my $enty = shift;
    my $ref = shift;

    my $map = "";

    for my $g ( sort( keys( %$ref ) ) ) {
                  $map .= "\t\t\t$g => $ref->{$g},\n";
    }
    return $map;
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

	    for my $n ( split( ',', $ref->{$s}{$p} ) ) {
		#
		# Read out the actual connection data
		#  $conn->{inst}, $conn->{port}
		#  $conn->{port_f}, $conn->{port_t},
		#  $conn->{sig_f}, $conn->{sig_t}		
		my $conn = $conndb{$s}{'::' . $io}[$n];
		add_conn_matrix( $p, $s, \@cm, $conn );
	    }

            my $cast = "";
            if ( exists( $entities{$enty}{$p}{'cast'} ) ) {
                #TODO: Check $EH{'typecast'}{} ....
                $cast = $entities{$enty}{$p}{'cast'};
            }
	    push( @map , print_conn_matrix( $p, $pf, $pt, $s, $sf, $st, $lang, \@cm, $cast ));
	    # Remember if a port got used ....
	    if ( store_conn_matrix( \%{$hierdb{$inst}{'::portbits'}}, $inst, $p, $pf, $pt, $s, \@cm ) ) {
                #TODO: Do something against duplicate connections ...
	    }
	}
	push( @$rio, $s );
    }
    return join( "", sort( @map ) ); # Return sorted by port name (comes first)
}


#
# Set up an array for each pin of a port, indexing a given signal!
#
# Handle duplicate connection of one signal to several pins ...
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
    #TODO: is this the only cases?
    if ( $cpf !~ m,^\s*[+-]?\d+\s*$,o or
        $cpt !~ m,^\s*[+-]?\d+\s*$,o or
        $csf !~ m,^\s*[+-]?\d+\s*$,o or
        $cst !~ m,^\s*[+-]?\d+\s*$,o
         ) {
        logwarn( "Info: signal $signal bounds $cpf .. $cpt or port $port $cpf .. $cpt not a number!" );
        # $EH{'sum'}{'warnings'}++;
        # $cpt and/or $cpf is not a number!!
        # We carry one if cpf equals csf and cpt equals cst ->
        #   otherwise we bail out ...
        if ( $csf eq $cpf and $cst eq $cpt ) {
            # Is there already contents in the connection matrix?
            if ( scalar( @$matrix ) ) {
                logwarn( "WARNING: redefinition of connection matrix for signal $signal, port $port!");
            $EH{'sum'}{'warnings'}++;
            }
            # Store marker: __NAN__ , From, To
            $matrix->[0] = "__NAN__";
            $matrix->[1] = $csf;
            $matrix->[2] = $cst;
        } else {
            logwarn( "WARNING: cannot resolve signal/port $signal $port: non numeric and non matching bounds!" );
            $EH{'sum'}{'warnings'}++;
        }
        
        return 1;
        #TODO: other cases ...
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
	logwarn("__E_SLICE_WIDTH_MISMATCH:signal $signal ($smax downto $smin) to port $port ($max downto $min)!");
	return undef;
	#TODO:?? return( "\t\t-- __E_SLICE_WIDTH_MISMATCH for signal $signal connected to port $port!" );
    }

    #TODO: Extended testing ....
    if ( $dirf == $sdirf ) {
	for my $i ( $min .. $max ) {
	    if ( defined( $matrix->[$i] ) ) { # Seen before ...
		if ( $matrix->[$i] ne $smin - $min + $i ) {
		    logwarn("__E_PORT_SIGNAL_CONFLICT: $port($i) connecting signal $signal" . ( $smin + $i ) .
			    " or " . $matrix->[$i] . "!" );
                    $EH{'sum'}{'errors'}++;
		}
	    } else {
		 $matrix->[$i] = $smin - $min + $i;
	    }
        }
    } else {
	for my $i ( $min .. $max ) {
	    if ( defined( $matrix->[$i] ) ) { # Seen before ...
		if ( $matrix->[$i] ne $smax - $max - $i ) {
		    logwarn("__E_PORT_SIGNAL_CONFLICT: $port($i) connecting signal $signal" . ( $smin + $i ) .
			    " or " . $matrix->[$i] . "!" );
                    $EH{'sum'}{'errors'}++;
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
}

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
            logwarn( "ERROR: bad branch taken $instance, $signal. File bug report!" );
            $EH{'sum'}{'errors'}++;
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
            logwarn( "WARNING: Reconnecting port $port at instance $instance: $usage A::!" );
            $EH{'sum'}{'warnings'}++;
            return;
        } else {
            my ( $conflict, $result ) = mix_wr_port_check($usage, $prev->{$port});
            if ( $conflict == "1" ) {
                logwarn( "WARNING: Pot. conflict with reconnection of port $port at instance $instance: $usage was $prev->{$port}!" );
                $prev->{$port} = $result;
                $EH{'sum'}{'warnings'}++;
            } elsif ( $conflict == "-1" ) {
                logwarn( "ERROR: Mode conflict with reconnection of port $port at instance $instance: $usage was $prev->{$port}!" );
                $prev->{$port} = $result;
                $EH{'sum'}{'errors'}++;
            } else {
                # O.K., got s.th. overlapping ...
                $prev->{$port} = $result;
            }
        # TODO: Check that better ...
        }
    }
}

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
        logwarn( "WARNING: Please check overlay of port $np, was $op!" );
        $EH{'sum'}{'warnings'}++;
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
            logwarn( "ERROR: mixed modes in port!!" );
            $EH{'sum'}{'warnings'}++;
            $mn = "1";
        } elsif ( $mn ne $mo ) {
            logwarn( "ERROR: mode mismatch in port join!" );
            $EH{'sum'}{'warnings'}++;
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
            logwarn( "ERROR: mixed modes in port!!" );
            $EH{'sum'}{'warnings'}++;
            $mo = "1";
        } elsif ( $mn ne $mo ) {
            logwarn( "ERROR: mode mismatch in port join!" );
            $EH{'sum'}{'warnings'}++;
            $mo = "1";
        } else {
            return( "1", "A::" . $mo );
        }
        return( "-1", "A::" . $mo );
    }

    # O.k., now remains B::.... vs B::....
    $w = $wo;
    if ( $wn ne $wo ) {
        logwarn( "ERROR: port width mismatch $wn was $wo" );
        $EH{'sum'}{'errors'}++;
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
                logwarn( "ERROR: port internal mode change: $bn[$n] was $tm" );
                $EH{'sum'}{'errors'}++;
            }
            $hasgap = 1 unless ( $bn[$n] );
            $tm = $bn[$n] if ( $bn[$n] );
        } elsif ( $bn[$n] eq "0" ) {
            $res .= $bo[$n]; # Covers case 3
            if ( $bo[$n] and $tm and $bo[$n] ne $tm ) {
                logwarn( "ERROR: port internal mode change: $bo[$n] was $tm" );
                $EH{'sum'}{'errors'}++;
            }
            $hasgap = 1 unless ( $bo[$n] );
            $tm = $bo[$n] if ( $bo[$n] );
        } elsif ( $bn[$n] eq $bo[$n] ) {
            if ( $tm and $tm ne $bo[$n] ) {
                logwarn( "ERROR: port internal mode change: $bo[$n] was $tm" );
                $EH{'sum'}{'errors'}++;
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
# print the connectios, aka. print a port map
#
#!wig20030806: Optionally takes a typecast argument ...
#  the cast function will be applied to the port (hopefully this is valid for most tools) ...
#
# Adding: __NAN__ support (string aka. generic ::high/::low bounds)
#
sub print_conn_matrix ($$$$$$$$;$) {
    my $port = shift;
    my $pf = shift;
    my $pt = shift;
    my $signal = shift;
    my $sf = shift;
    my $st = shift;
    my $lang = shift || $EH{'macro'}{'%LANGUAGE%'};
    my $rcm = shift;
    my $cast = shift || "";

    #
    # Simple case: everything is in sync and o.k. ( matrix index equals signal pin number)
    #
    my $t = "";
    my $lb = undef;
    my $ub = $#$rcm;
    my $lstart = 0;

    my $tcom = $EH{'output'}{'comment'}{$lang} || $EH{'output'}{'comment'}{'default'} || "#";

    #
    # Non-Numeric bounds:
    #
    # __NAN__ , From:, To: ..
    # __NAN__ works for full connections, only (today)
    if ( defined( $rcm->[0] ) and $rcm->[0] eq "__NAN__" ) {
        if ( $lang =~ m,^veri,io ) { # Verilog
            $t .= $EH{'macro'}{'%S%'} x 3 . "." . $port . "(" . $signal . "),\n"; #TODO, check Verilog syntax
        } else {
            if ( $cast ) {
                $t .= $EH{'macro'}{'%S%'} x 3 . $cast . "(" . $port . ") => " . $signal . ",\n";
            } else {
                $t .= $EH{'macro'}{'%S%'} x 3 . $port . " => " . $signal . ",\n";
            }
        }
        return $t;
    }

    # $ub = 0 and $p[f|t] = __UNDEF__ and $s[f|t] = __UNDEF__
    # and $rcm->[0] = 0  -> single pin assignment
    if ( $ub == 0 and
	 $pf eq "__UNDEF__" and $pt eq "__UNDEF__" and
	 $sf eq "__UNDEF__" and $st eq "__UNDEF__" and
	 $rcm->[0] == 0 ) {
            if ( $lang =~ m,^veri,io ) { # Verilog
                $t .= $EH{'macro'}{'%S%'} x 3 . "." . $port . "(" . $signal . "),\n"; #TODO, check Verilog syntax
            } else {
                if ( $cast ) {
                    $t .= $EH{'macro'}{'%S%'} x 3 . $cast . "(" . $port . ") => " . $signal . ",\n";
                    #OLD $t .= $EH{'macro'}{'%S%'} x 3 . $port . " => " . $cast . "(" . $signal . "),\n";
                } else {
                    $t .= $EH{'macro'}{'%S%'} x 3 . $port . " => " . $signal . ",\n";
                }
            }
	    return $t;
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
	if ( $pf eq $pt and defined( $lb ) and $lb eq $ub ) {
	    # Single bit port .... connected to bus slice
	    # TODO: do more checking ...
	    if ( $pf eq "__UNDEF__" ) {
                if ( $lang =~ m,^veri,io ) { #Verilog
                    $t .= $EH{'macro'}{'%S%'} x 3 . "." . $port . "(" . $signal . "[" . $rcm->[$ub] . "]),\n"; #TODO: Check Verilog syntax
                } else {
                    if ( $cast ) {
                        $t .= $EH{'macro'}{'%S%'} x 3 . $cast . "(" . $port . ") => " .
                            $signal . "(" . $rcm->[$ub] . "),\n";
                    } else {
                        $t .= $EH{'macro'}{'%S%'} x 3 . $port . " => " .
                            $signal . "(" . $rcm->[$ub] . "),\n";
                    }
                }
	    } else {
                if ( $lang =~ m,^veri,io ) { #Verilog
                    $t .= $EH{'macro'}{'%S%'} x 3 . "." . $port . "[" . $pf . "](" . $signal . "[" . $rcm->[$ub] . "]),\n"; #TODO: is this legal?
                } else {
                    if ( $cast ) {
                        $t .= $EH{'macro'}{'%S%'} x 3 . $cast . "(" . $port . "(" . $pf . ")) => " .
                            $signal . "(" . $rcm->[$ub] . "),\n";
                    } else {
                        $t .= $EH{'macro'}{'%S%'} x 3 . $port . "(" . $pf . ") => " .
                            $signal . "(" . $rcm->[$ub] . "),\n";
                    }
                }               
	    }
	} elsif ( $sf eq "__UNDEF__" and $st eq "__UNDEF__" ) {
            # Single bit of signal connected to bus port ...
           if ( $lang =~ m,^veri,io ) { #Verilog
                $t .= "\t\t\t." . $port . "[" . $ub . "](" . $signal . "), " . $tcom . " __I_BIT_TO_BUSPORT\n"; #
            } else {
                if ( $cast ) {
                    $t .= $EH{'macro'}{'%S%'} x 3 . $cast . "(" . $port . "(" . $ub . ")) => " .
                        $signal . ", " . $tcom . " __I_BIT_TO_BUSPORT\n";
                } else {
                    $t .= $EH{'macro'}{'%S%'} x 3 . $port . "(" . $ub . ") => " .
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
                    $t .= $EH{'macro'}{'%S%'} x 3 . "." . $port . "(" . $signal . "),\n";
                } else {
                    if ( $cast ) {
                        $t .= $EH{'macro'}{'%S%'} x 3 . $cast . "(" . $port . ") => ". $signal . ",\n";
                    } else {
                        $t .= $EH{'macro'}{'%S%'} x 3 . $port . " => " . $signal . ",\n";
                    }
                }
            } else {
                if ( $lang =~ m,^veri,io ) { #Verilog
                    $t .= $EH{'macro'}{'%S%'} x 3 . "." . $port . "[" . $ub . ":" . $lb . "](" . $signal . "), " .
                            $tcom . " __W_PORT\n";
                } else {
                    if ( $cast ) {
                        $t .= $EH{'macro'}{'%S%'} x 3 . $cast . "(" . $port . "(" . $ub . " downto " . $lb . ")  => " .
                            $signal . ", " . $tcom . " __W_PORT\n";
                    } else {
                        $t .= $EH{'macro'}{'%S%'} x 3 . $port . "(" . $ub . " downto " . $lb . ")  => " .
                            $signal . ", " . $tcom . " __W_PORT\n";
                    }
                }
            }
	} elsif ( $sf =~ m,^\d+$,o and $st =~ m,^\d+$,o and ( $rcm->[$ub] < $sf or $rcm->[$lb] > $st ) ) { #TODO: There could be more cases ???
	    if ( $ub == $lb ) {
                if ( $lang =~ m,^veri,io ) { #Verilog
                    $t .= $EH{'macro'}{'%S%'} x 3 . "." . $port . "[" . $ub . "](" . $signal . "[" . $rcm->[$ub] . "]),\n";
                } else {
                    if ( $cast ) {
                        $t .= $EH{'macro'}{'%S%'} x 3 . $cast . "(" . $port . "(" . $ub . ")) => " .
                            $signal . "(" . $rcm->[$ub] . "),\n";
                    } else {
                        $t .= $EH{'macro'}{'%S%'} x 3 . $port . "(" . $ub . ") => " .
                            $signal . "(" . $rcm->[$ub] . "),\n";
                    }
                }
	    } elsif ( $pf > $ub or $pt < $lb ) {
                if ( $lang =~ m,^veri,io ) { #Verilog
                    $t .= $EH{'macro'}{'%S%'} x 3 . "." . $port . "[" . $ub . ":" . $lb . "](" . $signal . "["
                       . $rcm->[$ub] . ":" . $rcm->[$lb] . "]),\n";
                } else {
                    if ( $cast ) {
                        $t .= $EH{'macro'}{'%S%'} x 3 . $cast . "(" . $port . "(" . $ub . " downto " . $lb . ")) => " .
                            $signal . "(" . $rcm->[$ub] . " downto " . $rcm->[$lb] . "),\n";
                    } else {
                        $t .= $EH{'macro'}{'%S%'} x 3 . $port . "(" . $ub . " downto " . $lb . ") => " .
                            $signal . "(" . $rcm->[$ub] . " downto " . $rcm->[$lb] . "),\n";
                    }
                }
	    } elsif ( $ub == 0 ) {
                if ( $lang =~ m,^veri,io ) { #Verilog
                    $t .= $EH{'macro'}{'%S%'} x 3 . "." . $port . "(" . $signal . "[" . $rcm->[$ub] . "]),\n";
                } else {
                    if ( $cast ) {
                        $t .= $EH{'macro'}{'%S%'} x 3 . $cast . "(" . $port . ") => " .
                            $signal . "(" . $rcm->[$ub] . "),\n";
                    } else {
                        $t .= $EH{'macro'}{'%S%'} x 3 . $port . " => " . $signal . "(" . $rcm->[$ub] . "),\n";
                    }
                }
	    } else {
                if ( $lang =~ m,^veri,io ) { #Verilog
                    $t .= $EH{'macro'}{'%S%'} x 3 . "." . $port . "(" . $signal . "[" . $rcm->[$ub] . ":" . $rcm->[$lb] . "]),\n";
                } else {
                    if ( $cast ) {
                        $t .= $EH{'macro'}{'%S%'} x 3 . $cast . "(" . $port . " => " .
                            $signal . "(" . $rcm->[$ub] . " downto " . $rcm->[$lb] . "),\n";
                    } else {
                        $t .= $EH{'macro'}{'%S%'} x 3 . $port . " => " .
                            $signal . "(" . $rcm->[$ub] . " downto " . $rcm->[$lb] . "),\n";
                    }
                }
	    }           
	} else {
            if ( $lang =~ m,^veri,io ) { # Verilog
                $t .= $EH{'macro'}{'%S%'} x 3 . $tcom . "__E_BAD_BOUNDS ." .
                    $port . "[" . $pf . ":" . $pt . "](" .
                    $signal . "[" . $sf . ":" . $st . "]),\n";
            } else {
                $t .= $EH{'macro'}{'%S%'} x 3 . $tcom . "__E_BAD_BOUNDS . " .
                    $port . "(" . $pf . " downto " . $pt . ")" . " => " .
                    $signal . "(" . $sf . " downto " . $st . "), \n";
            }
	    logwarn("Warning: unexpected branch in print_conn_matrix, signal $signal, port $port");
            $EH{'sum'}{'warnings'}++;
	}
        if ( $signal eq "%OPEN%" ) {
            if ( $lang =~ m,^veri,io ) {
                $t =~ s,%OPEN%(\s*\[[:\w]+?\])?,,g; # Remove %OPEN% aka. open[a:b]
            } else {
                $t =~ s,(?<=%OPEN%)\s*\([\s\w]+?\),,g; # Remove ( ... ) definitons ...
            }
        }
	return $t;
    #
    #TODO: catch the most important cases here
    #
    } else { # Output each single bit!!
	for my $i ( 0..$ub ) {
	    if ( defined( $rcm->[$i] ) ) {
		if ( $rcm->[$i] == 0 and $sf eq "__UNDEF__" ) {
		    # signal is bit!
                    if ( $lang =~ m,^veri,io ) { #Verilog
                        $t .= $EH{'macro'}{'%S%'} x 3 . "." . $port . "[" . $i . "](" . $signal . "),\n";
                    } else {
                        if ( $cast ) {
                            $t .= $EH{'macro'}{'%S%'} x 3 . $cast . "(" . $port . "(" . $i . ")) => " .
                                $signal . ",\n";
                        } else {
                            $t .= $EH{'macro'}{'%S%'} x 3 . $port . "(" . $i . ") => " . $signal . ",\n";
                        }
                    }
		} else {
		    # signal is bus!
                    if ( $lang =~ m,^veri,io ) { #Verilog
                        $t .= $EH{'macro'}{'%S%'} x 3 . "." . $port . "[" . $i . "](" . $signal . "[" . $rcm->[$i] ."]),\n";
                    } else {
                        if ( $cast ) {
                            $t .= $EH{'macro'}{'%S%'} x 3 . $cast . "(" . $port . "(" . $i . ")) => " .
                                $signal . "(" . $rcm->[$i] ."),\n";
                        } else {
                            $t .= $EH{'macro'}{'%S%'} x 3 . $port . "(" . $i . ") => " .
                                $signal . "(" . $rcm->[$i] ."),\n";
                        }
                    }
		}
	    }
	}
    }
    if ( $signal eq "%OPEN%" ) {
        #TODO: Verilog???
        if ( $lang =~ m,^veri,io ) {
            $t =~ s,%OPEN%(\s*\[[:\w]+?\])?,,g; # Remove %OPEN%
        } else {
            $t =~ s,(?<=%OPEN%)\s*\([\s\w]+?\),,g; # Remove signal bus splices
        }
    }

    return $t;

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

    my %macros = %{$EH{'macro'}}; # Take predefined macro replacement set
    my $lang = lc($macros{'%LANGUAGE%'}); # Set default language
    my $p_lang = "";
    
    $macros{'%ENTYNAME%'} = $entity;
    if ( $instance ne "__COMMON__" and exists ( $hierdb{$instance}{'::arch'}  ) ) {
            $macros{'%ARCHNAME%'} = $hierdb{$instance}{'::arch'};
            if ( $hierdb{$instance}{'::lang'} ) {
                if ( exists( $EH{'template'}{lc($hierdb{$instance}{'::lang'})} ) ) {
                    $lang = lc($hierdb{$instance}{'::lang'}); # Change language
                }
            }
    } else {
        $macros{'%ARCHNAME%'} = $entity . $EH{'postfix'}{'POSTFIX_ARCH'};
        # For __COMMON__ header only, see below
    }
    if ( -r $filename and $EH{'outarch'} ne "COMB" ) {
	logtrc(INFO, "Architecture declaration file $filename will be overwritten!" );
    }

    # Add header
    my $tpg = $EH{'template'}{$lang}{'arch'}{'body'};

    $macros{'%VHDL_USE%'} = use_lib( "arch", $instance );
    #TODO_VERI: $macros{'%VERI_USE%'} = use_lib( "arch", $instance );

    my $et = replace_mac( $EH{'template'}{$lang}{'arch'}{'head'}, \%macros);    

    my %seenthis = ();
    my $contflag = 0;
    #
    # Go through all instances and generate a architecture for each !entity!
    #
    my @keys = ( $instance eq "__COMMON__" ) ? keys( %$ae ) : ( $instance );
    for my $i ( sort( @keys ) ) {
	
	if ( $i eq "W_NO_ENTITY" ) { next; }; # Should read __W_NO_INSTANCE !

        #
	# Do not write architecture for leaf cells ...
	# can be overwritten by setting $EH... to leaf ...
	if ( $EH{'output'}{'generate'}{'arch'} =~ m,noleaf,io and
	    $#{ [ $ae->{$i}{'::treeobj'}->daughters ] } < 0 ) {
	    next;
	}

	$contflag = 1;	
	
	my $aent = $ae->{$i}{'::entity'};
	if ( $aent =~ m,W_NO_ENTITY,io ) { next; }; # Should read __W_NO_ENTITY

	my $arch = $ae->{$i}{'::arch'};	

        #TODO: what to do if ilang != lang???
        #TODO: that will happen only case one file is written for everything ..
        my $ilang = lc( $hierdb{$i}{'::lang'} ||$EH{'macro'}{'%LANUAGE%'} );
        if ( $p_lang and $p_lang ne $ilang ) {
            logwarn( "ERROR: Language mix: $p_lang used, now $ilang" );
            $EH{'sum'}{'errors'}++;
        }
        $p_lang = $ilang;
        my $tcom = $EH{'output'}{'comment'}{$ilang} || $EH{'output'}{'comment'}{'default'} || "##" ;
        
	$macros{'%ENTYNAME%'} = $aent;
	$macros{'%ARCHNAME%'} = $arch . $EH{'postfix'}{'POSTFIX_ARCH'};
        $macros{'%VERILOG_INTF%'} = "\t" . $tcom . "\n\t" . $tcom . " Generated module "
                . $i . "\n\t" . $tcom . "\n"; 
	$macros{'%CONCURS%'} = "\t" . $tcom . " Generated Signal Assignments\n";
	$macros{'%CONSTANTS%'} = "\t" . $tcom . " Generated Constant Declarations\n";
	#
	# Collect components by looking through all our daughters
	#
	$macros{'%COMPONENTS%'} = "\t" . $tcom . " Generated Components\n";
	$macros{'%INSTANCES%'} = "\t" . $tcom . " Generated Instances and Port Mappings\n";

	my %seen = ();
        my %i_macros = ();
        my %sig2inst = ();
	my @in= ();
	my @out = ();
	#
	# Inform user about rewrite of architecture for this entity ...
	#
	if ( exists( $seenthis{$aent} ) ) {
	    logtrc( "INFO:4",  "Possibly rewriting architecture for entity $aent, instance $i!" );
	} else {
	    $seenthis{$aent} = 1;
	}

        # Is verilog -> get interface for this module
        if ( $ilang =~ m,^veri,io ) {
            my $intf = "";
            my $generics = "";
            ( $intf, $generics ) = mix_wr_get_interface( $entities{$aent}, $aent, $ilang, $tcom );
            $intf = $intf . "\t\t" . $tcom . " End of generated module header\n";
            $macros{'%VERILOG_INTF%'} .= $generics . $intf;
        }

	my $node = $ae->{$i}{'::treeobj'};
	for my $daughter ( sort( { $a->name cmp $b->name } $node->daughters ) ) {
	    my $d_name = $daughter->name;
	    my $d_enty = $hierdb{$d_name}{'::entity'};

	    #
	    # Component declaration, relies on results found in _write_entities
	    #
            #wig20030228: do not add empty generics or port lists
	    unless( exists( $seen{$d_enty} ) ) {
 
                unless ( exists( $entities{$d_enty}{'__PORTTEXT__'}{$ilang}  ) and
                        exists( $entities{$d_enty}{'__GENERICTEXT__'}{$ilang} ) ) {
                    # Have not made interface in that language, ...
                    my ( $d_port, $gt );
                    ( $d_port, $gt ) = mix_wr_get_interface( $entities{$d_enty}, $d_enty, $ilang, $tcom );
                    if ( is_comment( $d_port, $ilang ) ) {
                        $entities{$d_enty}{'__PORTTEXT__'}{$ilang} = $d_port;
                        # $gt = "\t\t" . $tcom . " No Generated Port for Entity $d_enty\n$gt";
                    } else {
                        $d_port = "\t\t" . $tcom . " Generated Port for Entity $d_enty\n" . $d_port;
                        $d_port =~ s/;(\s*$tcom.*\n)$/$1/io; #TODO ...
                        $d_port =~ s/;\n$/\n/io;
                        $d_port .= "\t\t" . $tcom . " End of Generated Port for Entity $d_enty\n";
                        $entities{$d_enty}{'__PORTTEXT__'}{$ilang} = $d_port;
                    }
                    if ( is_comment( $gt, $ilang ) ) {
                        $gt = "\t\t" . $tcom . " Generated Generics for Entity $d_enty\n" . $gt;            
                        $gt =~ s/;(\s*$tcom.*\n)$/$1/io;
                        $gt =~ s/;\n$/\n/io;
                        $gt .= "\t\t" . $tcom . " End of Generated Generics for Entity $d_enty\n";
                        # Store ports and generics for later reusal
                        $entities{$d_enty}{'__GENERICTEXT__'}{$ilang} = $gt;
                    } else {
                        $entities{$d_enty}{'__GENERICTEXT__'}{$ilang} = $gt;
                        # $gt = "\t\t" . $tcom . " No Generated Generics for Entity $e\n$gent";
                    }
                }
                # %COMPONENTS% are VHDL entities ..
                #wig20030711: do not print component if user sets %NO_COMP% flag in ::use
                if ( defined( $hierdb{$d_name}{'::use'}) and
                    $hierdb{$d_name}{'::use'} =~ m,(NO_COMP|__NOCOMPDEC__),o ) {
                        $macros{'%COMPONENTS%'} .= "\t\t" . $tcom . "__I_COMPONENT_NOCOMPDEC__ " .
                        $d_name . "\n\n";
                } else {
                    $macros{'%COMPONENTS%'} .= $EH{'macro'}{'%S%'} x  1 .
                        "component $d_enty" .
                        ( defined( $hierdb{$d_name}{'::descr'} ) ? ( $EH{'macro'}{'%S%'} .
                                $tcom . " " . $hierdb{$d_name}{'::descr'} ) : "" ) .
                        "\n" .
			( ( not is_vhdl_comment( $entities{$d_enty}{'__GENERICTEXT__'}{$ilang} ) ) ?
                            ( "\t\tgeneric (\n" . $entities{$d_enty}{'__GENERICTEXT__'}{$ilang} .
                                "\t\t);\n"
                            ) :
                            ( "\t\t" . $tcom . " No Generated Generics\n" .
                              $entities{$d_enty}{'__GENERICTEXT__'}{$ilang}
                            )
			) .
                        ( ( not is_vhdl_comment( $entities{$d_enty}{'__PORTTEXT__'}{$ilang} ) ) ?
                            ( "\t\tport (\n" . $entities{$d_enty}{'__PORTTEXT__'}{$ilang} .
                                "\t\t);\n"
                            ) :
                            ( "\t\t" . $tcom . " No Generated Port\n" .
                              $entities{$d_enty}{'__PORTTEXT__'}{$ilang}
                            )
                        ) .
			"\tend component;\n\t" . $tcom . " ---------\n\n";
                }
                $seen{$d_enty} = 1;
	    } else {
                unless ( $EH{'check'}{'inst'} =~ m,nomulti,io ) {
                    $macros{'%COMPONENTS%'} .=
                       "\t\t" . $tcom . "__I_COMPONENT_REUSE: multiple instantiations of component " .
                        $i . ", declaration for entity " . $d_enty . " already added!\n";
                    logtrc( "INFO,4", "INFO: multiple instantiations of entity $d_enty");
                }
	    }
	    #
	    # Instances: generate an instance port map for each of our children
	    # and returns a list of in/out signals
	    my( $imap, $r_in, $r_out );
	    ( $imap, $r_in, $r_out ) = gen_instmap( $d_name, $lang, $tcom );
	    $macros{'%INSTANCES%'} .= "%INST_" . $d_name . "%\n";
            $i_macros{'%INST_' . $d_name . '%'} = $imap;

            for my $s ( @$r_in, @$r_out ) {
                push( @{$sig2inst{$s}}, $d_name );
            }
	    push( @in, @$r_in );
	    push( @out, @$r_out );
            
	} # end of: for my $daughter

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
        #TODO: Do something with the return value of count_load_driver
        count_load_driver( $i, $aent, $hierdb{$i}{'::conn'}, \%aeport );
        my %sp_conflict = ();
        if ( $ilang =~ m,^vhdl,io ) { # Make VHDL internal signal ...
            %sp_conflict = signal_port_resolve( $aent, \%aeport );
        }
        
	my $signaltext;
	my $veridefs = "";
	if ( $ilang =~ m,^veri,io ) {
            $signaltext = "\t\t$tcom\n\t\t$tcom Generated Signal List\n\t\t$tcom\n";
	}else {
            $signaltext = "\t\t$tcom\n\t\t$tcom Generated Signal List\n\t\t$tcom\n";
	}
	for my $ii ( sort( keys( %aeport ) ) ) {
	    # $ii is signal name

            #
            # If there is no in or out, do nothing here ....
            #
            next unless ( exists( $aeport{$ii}{'in'} ) or exists( $aeport{$ii}{'out'} ) );

            # Skip "open" pseudo-signal
            next if ( $ii eq '%OPEN%' );
            
	    my $s = $conndb{$ii};
	    my $type = $s->{'::type'};
	    my $high = $s->{'::high'};
	    my $low = $s->{'::low'};
	    # The signal definition should be consistent here!
	    my $dt = "";

            # Using %HIGH%, %LOW%, %HIGH_BUS%, %LOW_BUS%
            if ( $ii =~ m,^\s*%(HIGH|LOW)_BUS,o ) {
		my $logicv = ( $1 eq 'HIGH' ) ? '1' : '0';
                if ( $ilang =~ m,^veri,io ) {
                    my $w = $high - $low + 1;
                    $macros{'%CONCURS%'} .= $EH{'macro'}{'%S%'} x 3 .
                        "assign " . $EH{'macro'}{$ii} . " = " . $w . "'b" . $logicv . ";\n";
                } else {
                    $macros{'%CONCURS%'} .= $EH{'macro'}{'%S%'} x 3 .
                        $EH{'macro'}{$ii} . " <= ( others => '$logicv' );\n";
                }
	    } elsif ( $ii =~ m,^\s*%(HIGH|LOW)%,o ) {
	    	my $logicv = ( $1 eq 'HIGH' ) ? '1' : '0';
                if ( $ilang =~ m,^veri,io ) {
                    $macros{'%CONCURS%'} .= $EH{'macro'}{'%S%'} x 3 .
                        "assign " . $EH{'macro'}{$ii} . " = 1'b" . $logicv . ";\n";
                } else {
                    $macros{'%CONCURS%'} .= $EH{'macro'}{'%S%'} x 3 .
                        $EH{'macro'}{$ii} . " <= '$logicv';\n";
                }
	    }

	    if ( defined( $high ) and defined( $low ) ) {
                if ( $ilang =~ m,^veri,io ) {
                    if ( $high =~ m/^\d+$/o and $low =~ m/^\d+$/o ) {
                        # if ( $low < $high ) {
                            $dt = "[" . $high . ":" . $low . "]"; #TODO: Consider all case in Verilog
                        # } elsif ( $low > $high ) {
                        #    $dt = "($high to $low . "]";
                        # } else {
                        #    $dt = " -- __W_SINGLE_BIT_BUS";
                        # }
                    } elsif ( $high ne '' ) {
                        if ( $high ne $low ) {
                            $dt = "[" . $high .":" . $low . "]"; # String used as high/low bound
                        } else {
                            $dt = "[" . $high . "] " . $tcom . " __W_HIGHLOW_EQUAL";
                        }
                    }
                } else {
                    if ( $high =~ m/^\d+$/o and $low =~ m/^\d+$/o ) {
                        if ( $low < $high ) {
                            $dt = "($high downto $low)";
                        } elsif ( $low > $high ) {
                            $dt = "($high to $low)";
                        } else {
                            $dt = " $tcom __W_SINGLE_BIT_BUS";
                        }
                    } elsif ( $high ne '' ) {
                        if ( $high ne $low ) {
                            $dt = "($high downto $low)"; # String used as high/low bound
                        } else {
                            $dt = "($high) $tcom __W_HIGHLOW_EQUAL";
                        }
                    }
                }
	    }
	    # Add constant definitions here to concurrent signals ....
	    if ( $s->{'::mode'} =~ m,C,io ) {
                my ( $s, $a, $d ) = _write_constant( $s, $type, $dt, $ilang );
                $signaltext .= $s; # add to signal declaration ...
                $veridefs .= $d;
                $macros{'%CONCURS%'} .= $a;  # add to signal assignment
                next;
	    }

	    # Generics and parameters: Not needed here
	    if ( $s->{'::mode'} =~ m,\s*[GP],io ) {
                next;
	    }

    	    # Now deal with the ports, that are read internally, too:
	    # Generate intermediate signal
            my $usesig = $ii;
	    if ( exists( $sp_conflict{$ii} ) ) {
                #VHDL, only ...
                $usesig = $sp_conflict{$ii};
                # Redo all generated maps of my subblocks to use the internal signal name ....
                for my $insts ( @{$sig2inst{$ii}} ) {
                    #TODO: is that the final idea? Maybe splitting gen_map
                    # in two parts makes it better
                    # Port name might be not equal signal name here (generated port!)
                    $i_macros{'%INST_' . $insts . '%'} =~
                        s!(\w*)(\s+=>\s+)$ii(\(|,|\n)!$1$2$sp_conflict{$ii}$3!g;
                        #bug20030424a: s!(\w*$ii\w*)(\s+=>\s+)$ii(\(|,|\n)!$1$2$sp_conflict{$ii}$3!g;
                }
	    }


            #TODO: is that the final idea? Maybe splitting gen_map
            # in two parts makes it better

	    # Add signal just if this signal is not routed up (outside) ..
	    # Inside the loop we look if the signal name equals the entity definition ..
	    #TODO: Handle bit slices!!! Bring that to subroutine!!!
	    my $pre = "";
	    my $post = "";
	    my $iconn = $hierdb{$i}{'::conn'};

            # Iterate through all signals connected here ...
            # Generate an assignment if
            #   -- signal not used internally
            #   -- signal name ne port name (if exists)
            # Add signal to this architecture signal list, if there is no
            #   port hooked to that signal
            #
            # Iterate through all ports connected to this signal
            # if ( exists( $iconn->{'in'}{$ii} ) ) { # Bingo, signal is connected to port
            # In has precedence:
            #TODO: What if both in and out exists?
            #   What if signal is connected to multiple ports:
	    # if ( exists( $aeport{$ii}{'in'} ) ) { # IN
            unless( $ii =~ m/%(HIGH|LOW|OPEN)(_BUS)?%/o ) {
		if ( exists( $iconn->{'in'}{$ii} ) ) {
		    foreach my $port ( keys( %{$iconn->{'in'}{$ii}} ) ) {
			if ( $usesig ne $port ) {
			    $pre = "";
			    $post = "$tcom __W_PORT_SIGNAL_MAP_REQ";
                            my $concurs = gen_concur_port( 'in', $i, $aent, $ii, $usesig, $port, $iconn, $aeport{$ii}, $ilang, $tcom );
			    $macros{'%CONCURS%'} .= $concurs;
			}
    		    }
		}
		if ( exists( $iconn->{'out'}{$ii} ) ) {
		    foreach my $port ( keys( %{$iconn->{'out'}{$ii}} ) ) {
			if ( $usesig ne $port ) {		    
			    $pre = "";
			    $post = "$tcom __W_PORT_SIGNAL_MAP_REQ";
                            my $concurs = gen_concur_port( 'out', $i, $aent, $ii, $usesig, $port, $iconn, $aeport{$ii}, $ilang, $tcom );
			    $macros{'%CONCURS%'} .= $concurs;
			}
		    }
		}
	    }

	    # Add signal definition if required:
            if ( $usesig ne $ii ) {
                # Use internally generated signalname ....
                $signaltext .= ( $ilang =~ m,^veri,io ) ?
                ( "\t\t\t" . $pre . "wire\t$dt\t$usesig\t; $post $tcom __W_BAD_BRANCH\n" ) :
                ( "\t\t\t" . $pre . "signal\t" . $usesig . "\t: " . $type . $dt . "; " . $post . "\n" );
            } elsif ( exists( $iconn->{'out'}{$ii} ) or
                                exists( $iconn->{'in'}{$ii} ) ) {
                unless( exists( $entities{$aent}{$ii} ) ) {
                    $signaltext .= ( $ilang =~ m,^veri,io ) ?
                        ( "\t\t\t" . $pre . "wire " . $dt . " " . $usesig . "; " . $post . "\n" ) :
                        ( "\t\t\t" . $pre . "signal\t" . $usesig . "\t: " . $type . $dt . "; " . $post . "\n" );
                }
            } else {
                # Not connected to upside world
                if ( $ilang =~ m,^veri,io ) {
                    $signaltext .= "\t\t\t" . $pre . "wire\t" . $dt . "\t" . $usesig . "; " . $post . "\n";
                } else {
                    $signaltext .= "\t\t\t" . $pre . "signal\t" . $usesig . "\t: " . $type. $dt . "; " . $post . "\n";
                }
            }

	}

	# End is near for write_architecture ...
	$signaltext .= "\t\t" . $tcom . "\n\t\t" . $tcom . " End of Generated Signal List\n\t\t" . $tcom . "\n";
	$macros{'%SIGNALS%'} = $signaltext;
        $macros{'%VERILOG_DEFINES%'} = $veridefs if ( $veridefs );
        if ( keys( %i_macros ) > 0 ) {
            $macros{'%INSTANCES%'} = replace_mac( $macros{'%INSTANCES%'}, \%i_macros );
        }
	$et .= replace_mac( $tpg, \%macros );

    }

    return unless ( $contflag ); #Print only if you found s.th. to print

    $et .=  $EH{'template'}{$lang}{'arch'}{'foot'};

    $et = replace_mac( $et, \%macros );

    $et = strip_empty( $et );

    #
    # Write here
    #
    my $fh = undef;
    unless( $fh = mix_utils_open( "$filename", $EH{'outarch'} ) ) {
        logwarn( "Cannot open file $filename to write architecture declarations: $!" );
        return;
    }

    mix_utils_print( $fh, $et );

    mix_utils_close( $fh, $filename );

}

#
# Print out constant definitions:
#
#  constant NAME : $TYPE := VALUE;
# Currently we pass through the value nearly literally!
#
# Special cases
#20030710: adding Verilog support ...
#
sub _write_constant ($$$;$) {
    my $s = shift; # ref to this signals definition ...
    my $type = shift; # type of this constant
    my $dt = shift; # has predefined (F downto T)
    my $lang = shift || $EH{'macro'}{'%LANGUAGE%'} || "vhdl";

    my $tcom = $EH{'output'}{'comment'}{$lang} || $EH{'output'}{'comment'}{'default'} || "##";
    
    my $t = ""; # Signal definitions
    my $sat = ""; # Signal assignments
    my $def = ""; # Take `defines
    my $comm = ""; # Comments
    my $width = "__E_WIDTH_CONST";

    unless( exists( $s->{'::out'}[0]{'rvalue'} ) ) {
            logwarn( "WARNING: Missung value definition for constant $s->{'::name'}" );
	    $t = "\t\t\t" . $tcom .  $s->{'::name'} . " <= __E_MISSING_CONST_VALUE;\n";
    } else {
	my $value = $s->{'::out'}[0]{'rvalue'};

        #
        #TODO: 
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
            if ( $3 eq "" ) {
                $value = $1 . " " . $4;
            }
            if ( $lang =~ m,^veri,io ) {
                logwarn( "WARNING: Cannot handle time constant $value in verilog mode!" );
                $EH{'sum'}{'warnings'}++;
            }
            #TODO: Check it type is time ...
        } elsif ( $value eq "0" or $value eq "1" ) {
            # Bind a vector to 0 or 1
            if ( $s->{'::type'} =~ m,_vector,io ) {
                if ( $lang =~ m,^veri,io ) {
                    $value =  "1'b" . $value; # Gives 1'b0 or 1'b1 ...
                } else {
                    $value = "( others => '$value' )"; ##VHDL, only
                }
            } else {
                if ( $lang =~ m,^veri,io ) {
                    $value =  "1'b" . $value; # Gives 1'b0 or 1'b1 ...
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
                $comm = " " . $tcom . " __I_ConvConstant: " . $value;
                my $w = $s->{'::high'} - $s->{'::low'} + 1; #Will complain if high/low not
                                # defined or not digits!
                    if ( $value =~ m,^\s*(\d+)#([_a-f\d]+)#,io ) {
                        if ( $1 == 16 ) {
                            $value = "0x" . $2;
                            $value = hex( $value );
                        } elsif ( $1 == 8 ) {
                            $value = "0" . $2;
                            $value = oct( $value );
                        } elsif ( $1 == 2 ) {
                            $value = oct( "0b" . $2 );
                        } else {
                            logwarn( "WARNING: Cannot cope with base $1 for constant $value!" );
                            $w = "";
                        }
                    }

                if ( $value =~ m,^\s*0, ) {
                    $value = oct( $value );
                }
                if ( $w ) {
                    $value = sprintf( "%0" . $w . "b", $value );
                    if ( length( $value ) > $w +2 ) {
                        logwarn( "WARNING: Constant value $comm to large for signal $s->{'::name'} of $w bits!" );
                        $comm = " " . $tcom . " __E_VECTOR_WIDTH " . $comm;
                    }
                    $width = $w; # Save width ....
                    if ( $lang =~ m,^veri,io ) {
                        $value = $w . "'b" . $value; ##TODO: Streamline that !!
                    } else {
                        $value = '"' . $value . '"';
                    }
                }
            
        } elsif ( $value =~ m,^\s*0x([0-9a-f]),io ) {
            # Convert 0xHEXV to 16#HEXV#
            $comm = " " . $tcom . " __I_ConvConstant2:" . $value;
                if ( $lang =~ m,^veri,io ) {
                    $value =~ s,^\s*0x,'h,;
                } else {
                    $value =~ s,^\s*0x,16#,;
                    $value =~ s,\s*$,#,;
                }
	} elsif ( $type =~ m,_vector,io ) {
            # Replace ' -> "
            $comm = " " . $tcom . " __I_VectorConv";
            $value =~ s,',",go;
            if ( $lang =~ m,^veri,io) {
                $value =~ s,['"],,go;
                # $value = "'d" . $value; # Decimal values assumed ...
                $value = "'b" . $value; # value should be of binary type!!
            }
	} else {
            $comm = " " . $tcom . " __I_ConstNoconv";
	}

        #!wig20030403: Use intermediate signal ...
        #!org: $t = "\t\t\tconstant $s->{'::name'} : $type$dt := $value;$comm\n";
        if ( $lang =~ m,^veri,io ) {
            $value =~ s,["],,g; # Quick hack ....
            #TODO: rework ident strategy ... e.g. mark with keywords ...
            $def = "`define " . $s->{'::name'} . "_c " . $value . " " . $comm . "\n";
            $t .= $EH{'macro'}{'%S%'} x 3 . "wire\t" . $dt . "\t" . $s->{'::name'} . ";\n";
            $sat = $EH{'macro'}{'%S%'} x 3 . "assign " . $s->{'::name'} . " = `" . $s->{'::name'} . "_c;\n";
        } else {
            $t = $EH{'macro'}{'%S%'} x 3 . "constant $s->{'::name'}_c : $type$dt := $value;$comm\n";
            $t .= $EH{'macro'}{'%S%'} x 3 . "signal $s->{'::name'} : $type$dt;\n";        
            $sat =  $EH{'macro'}{'%S%'} x 3 . "$s->{'::name'} <= $s->{'::name'}_c;\n";
        }        
    }

    return $t, $sat, $def;
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
    my $lang = shift || $EH{'macro'}{'%LANGUAGE%'};
    my $tcom = shift ||$EH{'output'}{'comment'}{$lang} || "##";

    my $concur = "";
    # Is this a splice?
    # Get bus width for signal and port
    my $sh = $conndb{$signal}{'::high'}; 
    my $sl = $conndb{$signal}{'::low'};
    my $ph = $entities{$enty}{$port}{'high'};
    my $pl = $entities{$enty}{$port}{'low'};
    unless( defined( $sh ) ) { $sh = ""; };
    unless( defined( $sl ) ) { $sl = ""; };
    unless( defined( $ph ) ) { $ph = ""; };
    unless( defined( $pl ) ) { $pl = ""; };

    # Get width for the connection in this instance:
    PS: for my $ps ( @{$conndb{$signal}{'::' . $mode}} ) {
        #DEBUG
        next PS if ( scalar( %$ps ) eq "0" ); #Should not happen, empty hash??
        unless( defined( $inst ) and defined( $port ) and
                defined( $ps->{'port'} ) and defined( $ps->{'inst'} ) ) {
                    logwarn("ERROR: missing definition $inst/$port, Contact maintainer!");
                    $EH{'sum'}{'errors'}++;
        }
        if ( $ps->{'port'} eq $port and
            $ps->{'inst'} eq $inst ) {
            my $tsh = $ps->{'sig_f'}; 
            my $tsl = $ps->{'sig_t'};
            my $tph = $ps->{'port_f'};
            my $tpl = $ps->{'port_t'};
            unless( defined( $tsh ) ) { $tsh = ""; };
            unless( defined( $tsl ) ) { $tsl = ""; };
            unless( defined( $tph ) ) { $tph = ""; };
            unless( defined( $tpl ) ) { $tpl = ""; };
            # Single bit assignment:
            my $type = "";
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

                #TODO: do not add (n downto m) if $tsh eq $sh and $tsl eq $sl
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
                    } else { #Strings or any other nonsense, order is up to user!
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
                                ( "[" . $tph . ":" . $tpl . "]" ) :
                                ( "(" . $tph . " downto " . $tpl . ")" );
                        } else {
                            $pslice = ( $lang =~ m,^veri,io ) ?
                                ( "[" . $tph . ":" . $tpl . "]" ) :
                                ( "(" . $tph . " to " . $tpl . ")" );
                        }
                    } else { #Strings or any other nonsense, order is up to user!
                         $pslice = ( $lang =~ m,^veri,io ) ?
                                ( "[" . $tph . ":" . $tpl . "]" ) :
                                ( "(" . $tph . " downto " . $tpl . ")" );
                    }
                } elsif ( $tph ne '' ) {
                    $tpwidth = 1;
                    if ( $ph eq '' and $pl eq '' and $tph eq '0' ) {
                    # Another exception: single bit port ... (0) -> 
                    # Autoreduce bus to bit port
                        $pslice = "";
                    } else {
                        $pslice = ( $lang =~ m,^veri,io ) ?
                                ( "[" . $tph . "]" ) :
                                ( "(" . $tph . ")" );
                    }
                }
            }

            #TODO: check this_port vs. this_signal width (if possible)
            if ( $tswidth >= 0 and $tpwidth >= 0 and $tpwidth != $tswidth ) {
                logwarn( "WARNING: Connection width mismatch for instance $inst, signal $signal, port $port: $tswidth vs. $tpwidth!");
                $EH{'sum'}{'warnings'}++;
            }
            
            # in:               SIGNAL <= PORT;
            # out (et al.)   PORT <= SIGNAL;
            if ( $lang =~ m,^veri,io ) {
                $concur .= "\t\t\t" . "assign\t" . $port . $pslice . " = " . $signal_n . $sslice . "; " . $type . "\n";
            } else {
                if ( $mode eq "in" ) {
                    $concur .=    "\t\t\t" . $signal_n . $sslice . " <= " . $port . $pslice . "; " . $type . "\n";
                } else {
                    $concur .=    "\t\t\t" . $port . $pslice . " <= " . $signal_n . $sslice . "; " . $type . "\n";
                }
            }
        }
    }

    unless( $concur ) {
        logwarn( "WARNING: Missing port/signal connection for instance $inst, signal $signal, port $port!" );
        $EH{'sum'}{'warnings'}++;
    }
    return $concur;
}

#
# Will return true if the input string is a comment, only
#
sub is_vhdl_comment ($) {
    my $text = shift;
    return( $text =~ m,\A(^\s*(--.*)?\n)*\Z,om );
}

#
# Return is $text contains only comment
# depending on $lang
#
sub is_comment ($$) {
    my $text = shift;
    my $lang = shift || lc( $EH{'macro'}{'%LANGUAGE%'} );

    # Retrieve the comment for that language ...
    my $tcom = $EH{'output'}{'comment'}{$lang} || $EH{'output'}{'comment'}{'default'};
    if( $tcom ) {
        return( $text =~ m,\A(^\s*($tcom.*)?\n)*\Z,om );
    } else {
        return 0;
    }
}
        
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
                
                if ( $EH{'check'}{'signal'} =~ m,open, ) {
                    # Add connect it to "open" here ....
                    add_conn( 
                        ( "::in" => "$inst/$s", "::name" => "%OPEN%" )
                    );
                    logtrc( "INFO:4", "Wiring signal $s to open, had no load in instance $inst!" );
                } else {
                    if ( $EH{'output'}{'warnings'} =~ m/load/io ) {
                        logwarn( "Warning: Signal $s does not have a load in instance $inst!" );
                    } else {
                        logtrc( "INFO:4", "Signal $s does not have a load in instance $inst!" );
                    }
                }
                $rinsig->{$s}{'load'} = 0;
                $conndb{$s}{'::comment'} .= "__W_MISSING_LOAD/$inst,";
            }
            unless( exists( $rinsig->{$s}{'driver'} ) ) {
                if ( $EH{'output'}{'warnings'} =~ m/driver/io ) {
                    logwarn( "Warning: Signal $s does not have a driver in instance $inst!" ) unless
                        ( $s =~ m/%(HIGH|LOW)(_BUS)?%/o );
                } else {
                    logtrc( "INFO:4", "Warning: Signal $s does not have a driver in instance $inst!" ) unless
                        ( $s =~ m/%(HIGH|LOW)(_BUS)?%/o );
                }
                $conndb{$s}{'::comment'} .= "__W_MISSING_DRIVER/$inst,";            
                $rinsig->{$s}{'driver'} = 0;
            } elsif ( $rinsig->{$s}{'driver'} > 1 ) {
                if ( $EH{'output'}{'warnings'} =~ m/driver/io ) {
                    logwarn( "Warning: Signal $s  has multiple drivers in instance $inst!" );
                } else {
                    logtrc( "INFO_4", "Warning: Signal $s  has multiple drivers in instance $inst!" );
                }
                $conndb{$s}{'::comment'} .= "__E_MULTIPLE_DRIVER/$inst,";
                $error_flag++;
            }
        }   
    }
    return $error_flag;

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
        logwarn( "Cannot check unknown entity $enty signal port mapping!" );
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
                    $map{$p} = $EH{'postfix'}{'PREFIX_SIG_INT'} . $p;
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
    my $efname = $EH{'outconf'};
    if ( $efname =~m/^(CONF|COMB)/o ) {
        my $confext = $EH{'postfix'}{'POSTFILE_CONF'};
        if ( $1 eq "COMB" ) {
            $confext = "";
        }
	# Write each configuration in a file of it's own
	for my $i ( sort( keys( %hierdb ) ) ) {
		# Skip it if it was seen before
		#TODO: sort by order of hierachy??

    		if ( $EH{'output'}{'generate'}{'conf'} =~ m,noleaf,io and
		    not $hierdb{$i}{'::treeobj'}->daughters ) {
		    next;
		}

		my $e = $hierdb{$i}{'::entity'};
                next if ( $e eq "W_NO_ENTITY" );
                
		unless ( exists( $seen{$e} ) ) {
		    # my %a; $a{$e} = %{$hierdb{$i}}; # Take one slice from the hierdb ...
		    $seen{$e} = 1;  #TODO ?????

                    #
                    # Simple attempt to define a filename:
                    # Take configuration name if that contains the entitiy name,
                    #  else use ENTY-c.vhd
                    #
                    my $filename;
                    my $e_fn = $e;
                    my $ce = $hierdb{$i}{'::config'};
                    #Changed 20030714a/Bug: change only trailing _ to - !!
                    if ( $EH{'output'}{'filename'} =~ m,allminus,o ) {
                        $ce =~ s,_,-,og;
                        $e_fn =~ s,_,-,og;
                    } elsif ( $EH{'output'}{'filename'} =~ m,useminus,i ) {
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
                    my $lang = lc( $hierdb{$i}{'::lang'} ) || $EH{'macro'}{'%LANGUAGE%'};
                    unless ( exists ( $EH{'template'}{$lang} ) ) {
                        logwarn( "WARNING: Illegal language $lang selected. Autoswitch to $EH{'macro'}{'%LANGUAGE%'}!" );
                        $lang = $EH{'macro'}{'%LANGUAGE%'};
                    }
                    next if ( $lang ne "vhdl" ); # No configuration to write if language ne VHDL

                    if ( $EH{'outconf'} eq "COMB" ) {
                        $filename = $e_fn . $confext . "." . $EH{'output'}{'ext'}{$lang};
                    } elsif ( substr( $ce, 0, length( $e_fn ) ) eq $e_fn ) {
                        $filename = $ce . $confext  . "." . $EH{'output'}{'ext'}{$lang};
                    } else {
                        $filename = $e_fn . $confext  . "." . $EH{'output'}{'ext'}{$lang};
                    }
		    _write_configuration( $i, $e, $filename, \%hierdb );
		}
	}
    } else {
	_write_configuration( "__COMMON__", "__COMMON__", $efname, \%hierdb );
    }

    return;

}

#
# Do the work:
#
sub _write_configuration ($$$$) {
    my $instance = shift;
    my $entity = shift;
    my $filename = shift;
    my $ae = shift;

    my %macros = %{$EH{'macro'}}; # Take predefined macro replacement set

    $macros{'%INSTNAME%'} = $instance;
    $macros{'%ARCHNAME%'} = $entity . $EH{'postfix'}{'POSTFIX_ARCH'};    
    $macros{'%CONFNAME%'} = $entity . $EH{'postfix'}{'POSTFIX_CONF'}; 

    if ( -r $filename and $EH{'outconf'} ne "COMB" ) {
	logtrc(INFO, "Configuration definition file $filename will be overwritten!" );
    }
    my $fh = undef;
    unless( $fh = mix_utils_open( $filename, $EH{'outconf'} ) ) {
        logwarn( "Cannot open file $filename to write configuration definitions: $!" );
        return;
    }

    # Add header
    my $tpg = $EH{'template'}{'vhdl'}{'conf'}{'body'};

    $macros{'%VHDL_USE%'} = use_lib( "conf", $instance );

    my $et = replace_mac( $EH{'template'}{'vhdl'}{'conf'}{'head'}, \%macros);    

    my %seenthis = ();

    #
    # Go through all instances and generate a configuration for each !entity!
    #TODO: or instance?
    #
    my @keys = ( $instance eq "__COMMON__" ) ? keys( %$ae ) : ( $instance );
    for my $i ( sort( @keys ) ) {

	# Do not write configurations for leaf cells ...
	#TODO: Check
	if ( $EH{'output'}{'generate'}{'conf'} =~ m,noleaf,io and
	    $hierdb{$i}{'::treeobj'}->daughters == 0  ) {
		next;
	}
	# Skip some internals
	if ( $i eq "W_NO_ENTITY" ) { next; };
	if ( $i eq "W_NO_CONFIG" ) { next; };
    
	my $aent = $ae->{$i}{'::entity'};

	if ( $aent eq "W_NO_ENTITY" ) { next; }
	
	$macros{'%ENTYNAME%'} = $aent;
	$macros{'%CONFNAME%'} = $ae->{$i}{'::config'} . $EH{'postfix'}{'POSTFIX_CONF'};
	$macros{'%ARCHNAME%'} = $ae->{$i}{'::arch'} . $EH{'postfix'}{'POSTFIX_ARCH'};

	#
	# Collect components by looking through all our daughters
	#
	$macros{'%CONFIGURATION%'} = "\t-- Generated Configuration\n";

	#
	# Inform user about rewrite of architecture for this entity ...
	#
	if ( exists( $seenthis{$aent} ) ) {
	    logwarn( "Possibly rewriting configuration for entity $aent, instance $i!" );
	} else {
	    $seenthis{$aent} = 1;
	}

	my $lang = lc ( $hierdb{$i}{'::lang'} || $EH{'macro'}{'%LANGUAGE%'} || 'vhdl' ) ;
        my $tcom = $EH{'output'}{'comment'}{$lang} || $EH{'output'}{'comment'}{'default'} || "##";
        
	my $node = $ae->{$i}{'::treeobj'};
	for my $daughter ( sort( { $a->name cmp $b->name } $node->daughters ) ) {
	    my $d_name = $daughter->name;
	    my $d_enty = $hierdb{$d_name}{'::entity'};
	    my $d_conf = $hierdb{$d_name}{'::config'};

            #
            # Comment out Verilog daughter's, subblocks
            #wig20030711: also if the configuration is W_NO_CONFIG and or %NO_CONFIGURATION%
            #
            my $pre = "";
            if ( $EH{'output'}{'generate'}{'conf'} !~ m,veri,io ) {
                if ( $ae->{$d_name}{'::lang'} =~ m,veri,io ) {
                    $pre = $tcom . " __I_NO_CONFIG_VERILOG " . $tcom;
                }
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
     
    $et .=  $EH{'template'}{'vhdl'}{'conf'}{'foot'};
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

provide project specific use commands

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
    foreach my $k ( @keys ) {
        next if ( $k =~ m,%\w+%, );
        next if ( $k eq "W_NO_ENTITY" );
        next if ( $k eq "W_NO_PARENT");

        if ( exists( $hierdb{$k}{'::use'} ) and $hierdb{$k}{'::use'} ) {
            my @u = split( /[,\s]+/, $hierdb{$k}{'::use'} );
            foreach my $u ( @u ) {
                # libs may be seperated by , and/or \s
                # $u := SEL:library.component ...
                next if ( $u =~ m,(%NCD%|%NO_COMPONENT_DECLARATION|NO_COMP|__NOCOMPDEC__),o ); 
                my $sel = lc( $EH{'output'}{'generate'}{'use'} );
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
    #
    # Create:   library foo;
    #               use foo.bar.all;
    #
    for my $l ( sort( keys( %libs ) ) ) {
        $all .= "library $l;\n";
        for my $p ( sort( keys( %{$libs{$l}} ) ) ) {
            $all .= "use $p.all;\n"; # Attach .all by default ....
        }
    }
    
    if ( $all ) {
        $all = "-- Generated use statements\n" . $all;
    } else {
        $all = $EH{'macro'}{'%VHDL_NOPROJ%'} . "/" . $type . "\n";
    }
    
    return $all;

}

1;

#!End