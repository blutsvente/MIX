# -*- perl -*---------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# | 
# |   Copyright 2002 Trident Microsystems (Europe) GmbH, Germany
# | 
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# | Project:    Micronas - MIX / IOParser
# | Modules:    $RCSfile: MixIOParser.pm,v $ 
# | Revision:   $Revision: 1.23 $
# | Author:     $Author: lutscher $
# | Date:       $Date: 2009/12/14 10:58:17 $
# | 
# | 
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/MixIOParser.pm,v 1.23 2009/12/14 10:58:17 lutscher Exp $
# +-----------------------------------------------------------------------+
#
# The functions here provide the parsing capabilites for the MIX project.
# Take a matrix of information in some well-known format and convert it into
# intermediate format and/or source code files
# MixIOParser is spezialized in parsing the IO description sheet
# Information about IOcells and Pads will be converted to connection
# and hierachy and added to the HIER and CONN databases accordingly.
#

# +-----------------------------------------------------------------------+
# |
# | Changes:
# | $Log: MixIOParser.pm,v $
# | Revision 1.23  2009/12/14 10:58:17  lutscher
# | changed copyright
# |
# | Revision 1.22  2008/11/11 10:17:31  lutscher
# | initial release
# |
# | Revision 1.1  2008/11/11 10:13:55  lutscher
# | initial release
# |
# | Revision 1.20  2006/10/17 09:25:52  wig
# |  	MixIOParser.pm : fixed $eh-> code reference problem
# |
# | Revision 1.19  2006/07/12 15:23:40  wig
# | Added [no]sel[ect]head switch to xls2csv to support selection based on headers and variants.
# |
# | Revision 1.18  2006/03/14 08:10:34  wig
# | No changes, got deleted accidently
# |
# | Revision 1.17  2005/01/26 14:01:42  wig
# | changed %OPEN% and -autoquote for cvs output
# |
# | Revision 1.16  2004/04/14 11:08:32  wig
# | minor code clearing
# |
# | Revision 1.15  2004/04/05 09:19:13  wig
# | Reset winCVS
# |
# | Revision 1.14  2004/03/30 11:05:57  wig
# | fixed: IOparser handling of bit ports vs. bus signals
# |
# | Revision 1.13  2003/12/23 13:25:20  abauer
# | added i2c parser
# |
# | Revision 1.12  2003/12/04 14:56:31  abauer
# | corrected cvs problems
# |
# | Revision 1.11  2003/08/13 09:09:20  wig
# | Minor bug fixes
# | Added -given mode for iocell.select (MDE-D)
# |
# | Revision 1.10  2003/08/11 07:16:23  wig
# | Added typecast
# | Fixed Verilog issues
# |
# | Revision 1.9  2003/07/29 15:48:04  wig
# | Lots of tiny issued fixed:
# | - Verilog constants
# | - IO port
# | - reconnect
# |
# | Revision 1.8  2003/07/17 12:10:42  wig
# | fixed minor bugs:
# | - Verilog `define before module
# | - Verilog open
# | - signals(NN) in IO-Parser failed (bad reg-ex)
# |
# | Revision 1.4  2003/06/05 14:48:01  wig
# | Releasing alpha IO-Parser
# |
# | Revision 1.3  2003/06/04 15:52:43  wig
# | intermediate release, before releasing alpha IOParser
# |
# | Revision 1.2  2003/04/28 06:40:37  wig
# | Added %OPEN% (to allow ports without connection, use VHDL open keyword)
# | Started parseIO (not operational, would be a branch instead)
# | Fixed nreset2 issue (20030424a bug)
# |
# | Revision 1.1  2003/04/01 14:30:19  wig
# | Primary Version of IOParser. Will be the place to read/evalute IO sheets
# |
# |
# +-----------------------------------------------------------------------+

package Micronas::MixIOParser;

require Exporter;

  @ISA = qw(Exporter);
  @EXPORT = qw( parse_io_init );            # symbols to export by default
  @EXPORT_OK = qw();         # symbols to export on request
  # %EXPORT_TAGS = tag => [...];  

our $VERSION = '0.1'; #TODO: fill that from RCS ...

use strict;

use Log::Log4perl qw(get_logger);
use Micronas::MixParser;
use Micronas::MixUtils qw( $eh ); # We need only access to $eh

# Prototypes:
sub parse_io_init ($);
sub get_select_sigs ($);
sub _mix_iop_init();

####################################################################
#
# Our global variables
#  hierdb <- hierachy
#  conndb <- connection matrix

####################################################################
#
# Our local variables

#
# RCS Id, to be put into output templates
#
my $thisid		=	'$Id: MixIOParser.pm,v 1.23 2009/12/14 10:58:17 lutscher Exp $';
my $thisrcsfile	=	'$RCSfile: MixIOParser.pm,v $';
my $thisrevision   =      '$Revision: 1.23 $';

$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?

my $logger = get_logger( 'MIX::MixIOParser' );

####################################################################
## parse_io_init
## go through IO sheet(s) and build instances and connections 
####################################################################

=head2

parse_io_init ($) {

Go through data provided by IO sheet and generate instances and connections
as defined there. Please see the MIX documentation for a description of the
format. Several columns are required.

=cut

sub parse_io_init ($) {
    my $ref = shift;

    my $sel = 0;
    my $selsignals = undef;

    _mix_iop_init(); # initialize some configuration variables ...

    my $icomms	= $eh->get( 'input.ignore.comments' );
	my $ivar	= $eh->get( 'input.ignore.variant' ) || '#__I_VARIANT';   
    foreach my $i ( @$ref ) {
       	# next unless ( $i->[$i] ); # Skip if input field is empty
        next if ( $i->{'::ign'} =~ m,$icomms,o );
        next if ( $i->{'::ign'} =~ m,$ivar,o );

        if ( $i->{'::class'} =~ m,%SEL%,o ) { # Got a selector definition line ...
            # Retrieve selector signal names from the ::muxopt columns
            $selsignals = get_select_sigs( $i );
        } elsif ( $i->{'::class'} =~ m,%NOSEL%,o ) {
            # %NOSEL% is equivalent to a %SEL% with a count of one!
            $selsignals = {
                '::muxopt' => '%NOSEL%',
                '__NR__' => 1,
                '__PORT__' => '%NOSELPORT%',
            };
        }elsif ( $selsignals ) {
            # if this has got ::pad and ::iocell -> create pad and iocell
            if ( $i->{'::pad'} and $i->{'::iocell'} ) {
                if ( $i->{'::type'} ) {
                    mix_iop_padioc( $i );
                    $eh->inc( 'sum.io_cellandpad' );
                } else {
                    # only an iocell -> ignore pad ...
                    unless ( $eh->get( 'iocell.embedded' ) =~ m,\bpad\b,io ) {
                        $logger->warn( '__W_PARSE_IO', "\tMissing pad cell type for iocell " . $i->{'::iocell'} .
                             ", creating single iocell!" );
                    }
                    $eh->inc( 'sum.io_cell_single' );
                }
                mix_iop_iocell( $i, $selsignals );
            } elsif ( $i->{'::pad'} ) {
                # only pad -> no iocell defined -> to create
                mix_iop_pad( $i );
                $eh->inc( 'sum.io_pad_single' );
            } else {
                # Upps, empty line???
                # At least ::pad HAS TO BE DEFINED!
                # TODO : linenum does not reflect excel line number!
                # Should get a counter in the input data aka _l_ _n_ ...
                $logger->error( '__E_PARSE_IO', "\tNeither ::pad nor ::iocell defined in IO input sheet, skipped!" );
            }
        } else { # We need selsignals ...
            $logger->error( '__E_PARSE_IO', "\tMissing SEL line in input for parse_io_init, skipped!" );
        }
    }
    return 0;
} # End of parse_io_init

    
#
# Read in a line from the input and create an appropriate IOCELL
# Input: hash_ref with input description, hashref with muxopt's
#
sub mix_iop_iocell ($$) {
    my $r_h = shift;
    my $r_sel = shift;

    my %d = %$r_h; # Copy input data ...

    if ( $r_h->{'::pad'} !~ m,^\s*(\d+)\s*$, ) {
        $logger->warn( '__W_IOCELL', "\tBad ::pad entry $r_h->{'::pad'}, only digits allowed!" );
        return 1;
    }
    $d{'::inst'} = $eh->get( 'iocell.name' ); # Name is defined by rule configured in $eh

    if ( $r_h->{'::iocell'} ) {
        # $d{'::inst'} = $r_h->{'::iocell'} . "_" . $d{'::inst'};
        $d{'::entity'} = $r_h->{'::iocell'};
    } else {
        $d{'::entity'} = $eh->get( 'macro.%IOCELL_TYPE%' ) . "_" . $d{'::inst'};
    }

    $d{'::class'} = $r_h->{'::class'} || '%PAD_CLASS%';
    $d{'::_muxwidth_'} = $r_sel->{'__NR__'} || 0; # Set the current multiplexer width ...

    # $d{'::comment'} = $r_h->{'::comment'} || "";

    # Parent and all other attributes have to come from macros!!
    $d{'::inst'} = add_inst( %d ); # instance name might be changed

    #
    # Now to the connections ...
    #

    #
    # Go through the ::port / ::muxopt matrix for this pad/iocell ...
    # The select line might be changed by %SEL(....)
    #
    my $t_sel = mix_iop_connioc( $d{'::inst'}, $r_h, $r_sel );

    #
    # Do the SEL signals
    # Models a 1-hot architecture, besides if "bus" flag is set
    #
    if ( $t_sel->{'__NR__'} > 1 ) {
        # We actually have > 1 ::muxopt column ...
        
        my $port = $t_sel->{'__PORT__'} || '%IOCELL_SELECT_PORT%'; # Default port name to select.

        if ( $eh->get( 'iocell.select' ) =~ m,bus,io ) {
            # Attach a select bus of appropriate width coding the select
            # bits into a binary presentation. Requires internal
            # decoding of the select signal.
            my %s = ();
            if ( $eh->get( 'iocell.select' ) =~ m,auto,io ) {
                # Get min. required width of select bus:
                # will work up to 2048 ... at least
                $s{'::high'} = int( log( $t_sel->{'__NR__'} ) / log( 2 ) + 0.9999 ); 
            } else {
                $s{'::high'} = int( log( $r_sel->{'__NR__'} ) / log( 2 ) + 0.9999 );
            }
            $s{'::low'} = 0;

            # Take signal name of ::muxopt (0 column) to be select bus name
            ( $s{'::name'} = $t_sel->{'::muxopt'} ) =~ s,(\.\d+|\(\d+\))$,,;
            $s{'::in'} = $d{'::inst'} . "/" . $port;
 
            $s{'::type'} = "%BUS_TYPE%"; ##How do we define the type?
            $s{'::mode'} = ""; # Don't care (automatically generated later on or inherited)
            $s{'::class'} = "";
            $s{'::clock'} = "";
            $s{'::ign'} = "";
            $s{'::gen'} = "";
            $s{'::comment'} = "__IO_MuxSelBus ";

            #Will we need more information??
            add_conn( %s );

        # } elsif ( $eh->get( 'iocell.select' ) =~ m,given,io ) { # Take as many signals as found   
        } else {
            for my $s ( keys( %$t_sel ) ) {
                next if ( $s =~ m,^__, );
                my %s = ();
                $s{'::in'} = $d{'::inst'} . "/" . $port;
    
                # Get the number from muxopt:N ...
                my $n = 0;
                if ( $s eq "::muxopt" ) {
                    $n = 0;
                } elsif ( $s =~ m,:(\d+), ) {
                    $n = $1;
                }
                my $signal;
                my $nr;
                # select signal is SIGNAL(N) ... or SIGNAL.N
                if ( $t_sel->{$s} =~ m,(.+)\.(\d+), or
                    $t_sel->{$s} =~ m,(.+)\((\d+)\), ) {
                    $signal = $1;
                    $nr = "=(". $2 . ")";
                } else {
                    $signal = $t_sel->{$s};
                    $nr = "";
                }
                $s{'::name'} = $signal;
                $s{'::in'} .= "(" . $n . ")" . $nr;
        
                $s{'::low'} = ""; # Don't care
                $s{'::high'} = ""; # Don't care
                # $s{'::type'} = ""; ##How do we define the type? --> Take default for signal
                #!wig20041228: remove ::type from input definition ..
                if ( exists $s{'::type'} ) { delete $s{'::type'}; };
                $s{'::mode'} = ""; # Don't care (automatically generated later on or inherited)
                $s{'::class'} = "";
                $s{'::clock'} = "";
                $s{'::ign'} = "";
                $s{'::gen'} = "";
                $s{'::comment'} = "__IO_MuxSel ";
                
                #TODO: Will we need more information??

                add_conn( %s );
            }
        }
    }
}

#
# Connect iocells: wire iocell <-> core (defined by ::muxopt matrix)
# Returns: changed select line
#
sub mix_iop_connioc ($$$) {
    my $inst = shift;
    my $r_h = shift;
    my $r_sel = shift;

    my @pins = split( /[,\s]+/, $r_h->{'::port'} );
    my $clock = "%IOCELL_CLK%";

    my %tsel = %$r_sel; # Keep muxopt options, possibly reduce by missing
    
    # Check pin names ....
    foreach my $p ( @pins ) {
        if ( $p =~ s,%reg\(\s*(\w+)\s*\),,io ) {
            $clock = $1; #Setting default clock ....
        }
    }

    my $r_cols = $r_sel;
    if ( $eh->get( 'iocell.select' ) =~ m,given,io ) { # Don't worry about mismatch of
        # select signal and muxopt width ....
        $r_cols = get_select_sigs( $r_h );
    }
    #     foreach my $s ( grep( /^::muxopt/, keys( %$r_h ) ) ) {
    #         $r_cols-> = $r_h;
    # }

    # Iterate through all ::muxopt:N ...
    foreach my $s ( keys( %$r_cols ) ) {
        next if ( $s =~ m,^__, );

        # Remove select line if no data defined in this matrix cell
        unless( exists( $r_h->{$s} ) and defined( $r_h->{$s} ) ) {
            if ( $eh->get( 'iocell.select' ) =~ m,auto,io ) {
                delete( $tsel{$s} );
                $tsel{'__NR__'}--;
                next;
            } else {
                $logger->error( '__E_CONNIOC', "\tMissing muxopt definition for $s, pad nr. $r_h->{'::pad'}!" );
                next;
            }
        }
        if ( $r_h->{$s} =~ m,^\s*$, ) {
            if ( $eh->get( 'iocell.select' ) =~ m,auto,io ) {
                delete( $tsel{$s} );
                $tsel{'__NR__'}--;
                next;
            }
        }

        my $n = 0; # Get number of select lines ...
        if ( $s eq "::muxopt" ) {
            $n = 0;
        } elsif ( $s =~ m,:(\d+), ) {
            $n = $1;
        }

        # ::muxopt cell contents ... seperated by ,
        my @c = split( /,/, $r_h->{$s} );
        map( { s,\s+,,g }  @c ); # Get rid of all kind of whitespace

        if ( scalar( @c ) > scalar( @pins ) ) {
            $logger->warn( '__W_CONNIOC', "\t::muxopt $s has too many signals defined. Pad $r_h->{'::pad'} has " .
                         scalar( @pins ) . "!" );
        } elsif ( scalar( @c ) < scalar( @pins ) ) {
            $logger->info( '__I_CONNIOC', "\tMuxopt $s not completely defined for pad $r_h->{'::pad'}!" );
        }

        # Connect pin with signal ....
        foreach my $c ( 0..(scalar( @c ) - 1 ) ) {
            my %d = ();
            my $tclk = $clock; # Default clock signal
            my $name = "__E_MISSINGPADNAME"; #TODO: Use internal names
            my $num = "__E_MISSINGPADNUM"; #TODO:

            #TODO: If signal name satys unique for all cells, fold muxed output
            # to single bit!
            #TODO: Consider empty connections as "no connect", depending on
            #   input/di -> fold to single bit       wire to open??
            #  output/do -> don't connect ...?? wire to high/low ??
            # Also addextra input mux if signal comes from several iocells!!
            unless ( $c[$c] ) { # Empty cell
                $logger->warn( '__W_CONNIOC', "\tEmpty ::muxopt cell line not implemented!" );
                next;
            }

            # Strip off %COMB ...
            if ( $c[$c] =~ s,%comb\s*$,,io ) {
                $logger->warn( '__W_CONNIOC', "\t%comb not implemented now by MIX!");
            }

            # Get clk for this signal
            if ( $c[$c] =~ s,%reg\(\s*(\w+)\s*\),,io ) {
                $tclk = $1;
            }

            # Locally override select signal ...
            # Caveat: this will work for one-hot, only!
            if ( $c[$c] =~ s,%sel\(\s*(\w+)\s*\),,io ) {
                my $locsel = $1;
                if ( $eh->get( 'iocell.select' ) =~ m,onehot, ) {
                    $tsel{$s} = $locsel;
                    $logger->info( '__I_CONNIOC', "\tLocal %SEL% override by %sel($locsel)!" );
                } else {
                    $logger->warn( '__W_CONNIOC', "\tLocal %SEL% override by %sel($locsel) works in one-hot select mode, only!" );
                }
            }

            # Accept ´0´, ´1´  ..
            if ( $c[$c] =~ m,^\s*'?([01])'?, ) {
                $name = ( $1 eq '1' ) ? '%HIGH%' : '%LOW%';
                $num = undef;
            } elsif ( $c[$c] =~ m,(.+)\.(\d+)$, or $c[$c] =~ m,(.+)\((\d+)\)$, ) {
                # signal.N or signal(N)
                $name = $1;
                $num = $2;
            } elsif ( $c[$c] ) {
                # signal
                $name = $c[$c];
                $num = undef;
            } else {
                $logger->warn( '__W_CONNIOC', "\tEmpty ::muxopt cell contents " . $c[$c] . " not matching MIX rules!" );
                next;  # Empty input line
            }
                
            $d{'::name'} = $name;
            $d{'::class'} = $r_h->{'::class'} || "";
            $d{'::low'} = ""; # Don't care
            $d{'::high'} = ""; # Don't care
            # Determine direction this connection is driving; defaults to ::in
            my $io = mix_iop_getdir( $inst, $pins[$c] );

            # In/out

            #
            # Extend busses automatically ...
            #
            if ( defined( $num ) ) {
                # Is such a signal already defined?
                my $aprop = mix_p_retcprop ($name, "::high,::low,::type" );

                #
                #TODO: Ugly trick to get connection to internal, not predefined busses right:
                # If we see a connection to a signal with bit N and the bus does not have a bit N
                # so far, expand HIGH (and even set LOW to 0 if not set already, redefine
                # std_ulogic to std_ulogic_vector and alert user ....
                #
                if ( defined( $aprop ) ) { # Signal exists already ...
                    my %change_to = ();
                    # Is the type o.k.?
                    my $t = defined( $aprop->{'::type'} ) ? $aprop->{'::type'} : "";
                    unless ( $t and $t =~ m,_vector$, ) {
                        # ::type should become vector!
                        if ( $eh->get( 'iocell.auto' ) =~ m,bus, ) {
                            $change_to{'::type'} = $t . $eh->get( 'iocell.bus' );
                        }
                    }
                    my $h = defined( $aprop->{'::high'} ) ? $aprop->{'::high'}  : "";
                    if ( $h ne "" and $h =~ m,^(\d+)$, ) {
                        if ( $h < $num ) {
                            $change_to{'::high'} = $num;
                        }
                    } elsif ( $h eq "" ) {
                        $change_to{'::high'} = $num;
                    } else {
                        $change_to{'::high'} = $h;
                    }
                    my $l = defined( $aprop->{'::low'} ) ? $aprop->{'::low'}  : "";
                    if ( $l ne "" and $l =~ m,^(\d+)$, ) {
                        if ( $l > $num ) {
                            $change_to{'::low'} = $num;
                        }
                    } elsif ( $l eq "" ) {
                        $change_to{'::low'} = $num;
                    } else {
                        $change_to{'::low'} = $l;
                    }
                   
                    mix_p_updateconn( $name, \%change_to );

                } else {
                    #New signal, set properties
                    $d{'::type'} = $eh->get( 'macro.%BUS_TYPE%' );
                    $d{'::high'} = $num;
                    $d{'::low'} = $num;
                }
 
                if ( $io =~ m,^in,io ) {
                    $d{'::in'} = $inst . "/" . $pins[$c] . "(" . $n . ")" . "=(" . $num . ")";
                } else {
                    $d{'::out'} = $inst . "/" . $pins[$c] . "(" . $n . ")" . "=(" . $num . ")";
                }
            } else {
                if ( $io =~ m,^in,io ) {
                    $d{'::in'} = $inst . "/" . $pins[$c] . "(" . $n . ")";
                } else {
                    $d{'::out'} = $inst . "/" . $pins[$c] . "(" . $n . ")";
                }
            }

            $d{'::mode'} = ""; # Don't care (automatically generated later on or inherited)
            $d{'::clock'} = $tclk;
            $d{'::ign'} = "";
            $d{'::gen'} = "";
            $d{'::comment'} = "__IO_MuxedPort ";
        
            add_conn( %d );
        }
    }
    if ( $eh->get( 'iocell.select' ) =~ m,given,io ) {
        # Return what we got
        return $r_sel;
    } else {
        # Possibly changed select lines ....
        return \%tsel;
    }
}


{ # io direction logic -> see $eh->get( 'iocell.in' ) and .... out
#
# Only the ::out's have to be defined, all other signals default to ::in
#
my %io_iore = (
        'in'    => '(.*)',
        'out' => '(di)',
              );

sub _mix_iop_init() {

    for my $i ( qw( in inout out ) ) {
        if ( $eh->get( 'iocell.' . $i ) ) {
            $io_iore{$i} = '(' . join( '|', split( /[,\s]+/, $eh->get( 'iocell.' . $i ) ) ) . ')';
        }
    }

    # Number of generated IO cells:
    $eh->set( 'sum.io_cellandpad' , 0 );
    $eh->set( 'sum.io_cell_single', 0 );
    $eh->set( 'sum.io_pad_single' , 0 );

}
    
#
# mix_iop_getdir
# Return in or out, depending on assumed direction of the pin for this
# instance
#

sub mix_iop_getdir ($$) {
    my $inst = shift;
    my $name  = shift;

    for my $i ( qw( out inout in ) ) {
        if ( $name =~ m,^$io_iore{$i}$, ) {
            return ( $i );
        }
    }

    # Still here ?
    $logger->warn( '__W_IOP_GETDIR', "\tPort $name in iocell $inst has undefined direction, applied default!" );
    
    return( $eh->get( 'iocell.defaultdir' ) || 'in' );

}    

} # End of mix_iop_getdir

#
# Retrieve and convert pad data from input line, create instance ...
# Connections are created by appropriate macros
# Keywords: ::pad, ::type, ::class, ::iocell, ::ispin, ::pin
#
# Returns: name of generated pad
#
sub mix_iop_padioc ($) {
    my $r_h = shift;

    my %d = %$r_h; #Transfer all data from input field to PAD
    
    # Pad name
    if ( $r_h->{'::pad'} !~ m,^\s*(\d+)\s*$, ) {
        $logger->warn( '__W_PADIOC', "\tBad ::pad entry $r_h->{'::pad'}, only digits allowed!" );
        return 1;
    }
    # Define name of this pad:
    $d{'::inst'} = $eh->get( 'pad.name' ); # %::name% or %PREFIX_PAD_GEN%_%::pad%

    # Pad entitiy is defined by the ::type IO field!
    if ( $r_h->{'::type'} ) {
        $d{'::entity'} = $r_h->{'::type'};
        #!wig20041228: rename ::type .... to avoid conflicts with signal ::type
        $r_h->{'::__padtype__'} = $r_h->{'::type'};
        delete $r_h->{'::type'};
    } else {
        $logger->warn( '__W_PADIOC', "\tMissing ::type entry for pad $r_h->{'::pad'}!" );
        $d{'::entity'} = '%PAD_TYPE%';
    }

    # Is "::class" defined?
    $d{'::class'} = $r_h->{'::class'} || '%PAD_CLASS%';

    # Some things we add to the ::comments field:
    foreach my $i ( qw( ::comment ::iocell ::ispin ::pin ) ) {
        if ( exists( $r_h->{$i} ) and $r_h->{$i} ) {
            $d{'::comment'} .= "# $i: $r_h->{$i}";
        }
    }
    # Finally: add this pad ...
    #Caveat: parent and other information has to come from macros defined in the
    # hierachy sheet.
    return ( add_inst( %d ) );
}

#
# Retrieve and convert pad data from input line, create instance ...
# Connections are created by appropriate macros
# Keywords: ::pad, ::type, ::class, ::iocell, ::ispin, ::pin
#
sub mix_iop_pad ($) {
    my $r_h = shift;

    # Make a pad cell ...
    my $name = mix_iop_padioc( $r_h );

    my $nosel = {
        '::muxopt' => '%NOSEL%',
        '__NR__' => 1,
        '__PORT__' => '%NOSELPORT%',
    };

    # Connect PAD with core ... no IO cell involved here .
    mix_iop_connioc( $name , $r_h, $nosel );
    
    return;

}

#
# retrieve list of select signals from muxopt columns and
# name of select port ...
# returns ref->hash: ::muxopt[:N] => NAME
#
sub get_select_sigs ($) {
    my $r = shift;

    my %s = ();
    my $n = 0;
    foreach my $k ( keys( %$r ) ) {
        if ( $k =~ m,^::muxopt, ) {
            if ( defined( $r->{$k} ) and $r->{$k} ) {
                if ( $r->{$k} =~  m,(\w+)\.(\d+), ) {
                    #  signal.N -> signal(N)
                    $s{$k} = $1 . "(" . $2 . ")";
                } else {
                    $s{$k} = $r->{$k};
                }
                $n++;
            }
        } elsif ( $k =~ m,^::port, ) {
            if ( defined( $r->{$k} ) and $r->{$k} ) {
                $s{'__PORT__'} = $r->{$k};
            }
        }
    }

    $s{'__NR__'} = $n;

    if ( $n == 0 ) {
        $logger->warn('__W_SELECT_SIGS', "\tNo muxopt column filled with select signals detected!");
    } elsif ( $n == 1 ) {
        $logger->info('__I_SELECT_SIGS', "\tOnly one muxopt column found!");
    }
    return \%s;
}
 
1;

#!End
