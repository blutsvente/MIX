# -*- perl -*--------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright Micronas GmbH, Inc. 2002.                                 |
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
# | Project:    Micronas - MIX / I2CParser                                |
# | Modules:    $RCSfile: MixI2CParser.pm,v $                             |
# | Revision:   $Revision: 1.4 $                                          |
# | Author:     $Author: abauer $                                         |
# | Date:       $Date: 2003/12/23 13:25:20 $                              |
# |                                                                       |
# | Copyright Micronas GmbH, 2003                                         |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/Attic/MixI2CParser.pm,v 1.4 2003/12/23 13:25:20 abauer Exp $ |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# |    The functions here provide the parsing capabilites for the MIX     |
# |  project. Take a Array of information in some well-known format.      |
# |   MixI2CParser is spezialized in parsing the I2C description sheet    |
# |    Information about I2C Registers will be converted to connection    |
# |   and hierachy and added to the HIER and CONN databases accordingly.  |
# +-----------------------------------------------------------------------+
#

package Micronas::MixI2CParser;

require Exporter;

@ISA = qw( Exporter);
@EXPORT = qw( parse_i2c_init);            # symbols to export by default
@EXPORT_OK = qw();         # symbols to export on request

our $VERSION = '0.1'; #TODO: fill that from RCS ...

use strict;

# Caveat: relies on proper setting of base, pgmpath and dir in main program!
use lib "$main::base/";
use lib "$main::base/lib/perl";
use lib "$main::pgmpath/";
use lib "$main::pgmpath/lib/perl";
use lib "$main::dir/lib/perl";
use lib "$main::dir/../lib/perl";

use Log::Agent;
use Log::Agent::Priorities qw( :LEVELS);

use Micronas::MixUtils qw( %EH);
use Micronas::MixParser qw( %hierdb %conndb add_inst add_conn);
use Micronas::MixChecker;

####################################################################
## Prototypes:
####################################################################

sub parse_i2c_init($);


####################################################################
## Our local variables
####################################################################
#
# RCS Id, to be put into output templates
#

my $thisid		= 	'$Id: MixI2CParser.pm,v 1.4 2003/12/23 13:25:20 abauer Exp $';
my $thisrcsfile	        =	'$RCSfile: MixI2CParser.pm,v $';
my $thisrevision        =       '$Revision: 1.4 $';

$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?


####################################################################
## parse_i2c_init
## go through I2C sheet(s) and build instances and connections 
####################################################################

=head1

    parse_i2c_init ($)

    Go through data provided by IO sheet and generate instances and connections
    as defined there. Please see the MIX documentation for a description of the
    format. Several columns are required.

  Arg1: input Array

=cut

sub parse_i2c_init($) {

    my $r_i2c = shift;

    my $ehr = $EH{'i2c'}{'field'};

    foreach my $i (@$r_i2c) {

        next if ( $i->{'::ign'} =~ m,^\s*(#|\\),); # Skip comments, just in case they sneak in

        for my $j ( keys %$ehr) {
	    next unless ( $j =~ m/^::/ );
	    if ( not defined( $i->{$j} )) {
		next if( $ehr->{$j}[2] eq 0);
		$i->{$j} = $ehr->{$j}[3];
	    }
	    elsif( $ehr->{$i}[2] && $i->{$j} eq "") {
		$i->{$j} = $ehr->{$i}[3]; # Set to DEFAULT Value
	    }
	}
	add_interface($i);
    }
    return 0;
}


####################################################################
## add_interface
####################################################################

=head1
    add or merge i2c Interface and Register-block instance,
    build connections

 Arg1: $in hash reference, holding definitions

=cut

sub add_interface(%) {

    my $in = shift;

    my $name;
    my $type;

    # create a new instance in hierdb, create Interface first
    my $parent = $in->{'::interface'};
    $in->{'::inst'} = $parent;
    $in->{'::entity'} = $EH{'macro'}{'%IIC_IF%'} . $parent;
    $parent = add_inst( %$in);

    # only digits in ::sub? ->create new Register-block
    if( $in->{'::sub'}!~ m/^\s*(\d+)\s*$/ ) {
        logwarn( "WARNING: i2c sheet got bad ::sub entry $in->{'::sub'}, only digits allowed!" );
        $EH{'sum'}{'warnings'}++;
        return 1;
    }
    else {
	if( $in->{'::dir'}=~ m/rw/i) {
            $name = $EH{'macro'}{'%RWREG%'};
	    $type = "rdwr";
	}
	elsif( $in->{'::dir'}=~ m/w/i ) {
            $name = $EH{'macro'}{'%WREG%'};
	    $type = "wr";
	}
	elsif( $in->{'::dir'}=~ m/r/i) {
            $name = $EH{'macro'}{'%RREG%'};
	    $type = "rd";
	}
	else {
	    logwarn("WARNING: i2c sheet got bad ::dir entry <$in->{'::dir'}>, incorrect direction!");
	    $EH{'sum'}{'warnings'}++;
	    return 1;
	}
	$name = $name . sprintf( "%lx", $in->{'::sub'});

	$in->{'::inst'} = $name;
	$in->{'::entity'} = "iic_" . $EH{'i2c_cell'}{'type'} . "_reg_" . $type;
	$in->{'::parent'} = $parent;
	$name = add_inst(%$in);

	connect_subreg($in, $name, $parent);
    }

    # create transceiver unit
    create_transceiver($in, $parent);

    # create sync unit
    create_sync_block($in, $name, $parent);

    # create and connect "or"-block
    create_or_block($in, $name, $parent);

    return 0;
}


####################################################################
## create_sync_block
####################################################################

=head1

    create a new sync block and connect it

 Arg1: $in input data
 Arg2: $block register block to connect
 Arg3: $parent parent instance

=cut

sub create_sync_block($$) {

    my $in = shift;
    my $block = shift;
    my $parent = shift;

    my %conns;


    if( $in->{'::spec'}!~ m/nto/i) {

      # Transfer-mode specified, creating new sync block
        my $instance = $EH{'macro'}{'%IIC_SYNC%'} . $parent . "_" . $in->{'::spec'};
	$in->{'::inst'} = $instance;
	$in->{'::entity'} = $EH{'i2c_cell'}{'%IIC_SYNC%'};
	$in->{'::parent'} = $parent;
        $instance = add_inst(%$in);


#==> Connections

	    # connect to clock domain
	    %conns = ( '::name' => $in->{'::clock'},
		       '::in' => "$instance/clk, $parent/" . $in->{'::clock'}, );
 	    add_conn(%conns);

	    # connect asres/sync => ?
	    %conns = ( '::name' => $in->{'::reset'},
		       '::in' => "$instance/asres, $parent/" . $in->{'::reset'}, );
            add_conn(%conns);

	    # set_fast_active_i/sync => tf_en_wrFE
	    %conns = ( '::name' => "tf_en_wrFE",
	               '::in' => $instance . "/set_fast_active_i",
                       '::out' => $parent . "/tf_en_wr_FE_o", );
            add_conn(%conns);

	    # set_active_i/sync => tf_en_wrFF
	    %conns = ( '::name' => "tf_en_wrFF",
  	               '::in' => $instance . "/set_active_i",
	               '::out' => $parent . "/tf_en_wr_FF_o", );
	    add_conn(%conns);

	    # select_fast_i/sync => logic_1
	    %conns = ( '::name' => "%HIGH%", 
		       '::in' => $instance . "/select_fast_i", );
	    add_conn(%conns);

	    # connect vsync_i/sync => <::spec>_i
	    %conns = ( '::name' => $in->{'::spec'} . "_i",
		       '::in' => "$instance/vsync_i, $parent/" . $in->{'::spec'} . "_i", );
	    add_conn(%conns);

	    # select_i/sync => logic_1
	    %conns = ( '::name' => "%HIGH%",
		       '::in' => $instance . "/select_i", );
	    add_conn(%conns);

	    # load_shadow_o/sync -> takeover -> load_shadow_i/reg
	    %conns = ( '::name' => "sync_" . $in->{'::spec'},
		       '::in' => $block . "/load_shadow_i",
		       '::out' => $instance . "/load_shadow_o", );
	    add_conn(%conns);

	    # connect vxstat_o
	    %conns = ( '::name' => "stat_" . $in->{'::spec'} . "_" . $parent . "_iic_o",
		       '::out' => "$instance/vxstat_o, $parent/stat_"
		       . $in->{'::spec'} . "_" . $parent . "_iic_o" , );
	    add_conn(%conns);
    }
    else {
          # no Transfer-mode specified, sync block omitted
	    # load_shadow_i/reg -> logic_1;
	    %conns = ( '::name' => "%HIGH%", 
		       '::in' => $block . "/load_shadow_i", );
	    add_conn(%conns);
    }

    return 0;
}


####################################################################
## create_transceiver
####################################################################

=head1

    create a new transceiver unit and connect it

 Arg1: $in input data
 Arg2: $parent parent instance

=cut

sub create_transceiver($$) {

    my $in = shift;
    my $parent = shift;

    my $instance = $EH{'macro'}{'%IIC_TRANS%'} . $parent;
    my %conns;

    $in->{'::inst'} = $instance;
    $in->{'::entity'} = "iic_". $EH{'i2c_cell'}{'type'} . "_reg_rt";
    $in->{'::parent'} = $parent;
    $instance = add_inst(%$in);


#==> Generics

        # transceiver/sr_g => 0 (generic value)
        %conns = ( '::name' => $instance . "_sr_g",
		   '::in' => $instance . "/sr_g",
		   '::out' => "%PARAMETER%/0",
		   '::mode' => "P",
		   '::type' => "integer" );
        add_conn(%conns);

#==> Connections

	# transceiver/clk => clk_iic
	%conns = ( '::name' => "clk_iic",
		   '::in' => $instance . "/clk", );
	add_conn(%conns);

	# transceiver/reset => asres_iic
	%conns = ( '::name' => "asres_iic",
		   '::in' => $instance . "/reset", );
	add_conn(%conns);

	# transceiver/asres => asres_iic
	%conns = ( '::name' => "asres_iic",
		   '::in' => $instance . "/asres", );
	add_conn(%conns);

	# transceiver/iic_adr_data_i => iic_adr_data_i
	%conns = ( '::name' => "iic_adr_data_i",
		   '::in' => $instance . "/iic_adr_data_i", );
	add_conn(%conns);

	# transceiver/iic_en_i => iic_en_i
	%conns = ( '::name' => "iic_en_i",
		   '::in' => $instance . "/iic_en_i", );
	add_conn(%conns);

	# transceiver/adr_r_wn_ok_i => adr_r_wn_ok
	%conns = ( '::name' => "adr_r_wn_ok",
		   '::in' => $instance . "/adr_r_wn_ok_i", );
	add_conn(%conns);

	# transceiver/test_disbus_i => logic_0
	%conns = ( '::name' => "%LOW%",
		   '::in' => $instance . "/test_disbus_i", );
	add_conn(%conns);

	# transceiver/data_to_iic_i => data_reg_to_iic | std_ulogic_vector(0-15)
	%conns = ( '::name' => "data_reg_to_iic",
		   '::in' => $instance . "/data_to_iic_i(15:0)" );
	add_conn(%conns);

	# transceiver/i2c_ignore_lsd_i => ignore_lsb_i
	%conns = ( '::name' => "ignore_lsb_i",
		   '::in' => $instance . "/i2c_ignore_lsb_i", );
	add_conn(%conns);

	# transceiver/load_data_rd_i => load_data_rd
	%conns = ( '::name' => "load_data_rd",
		   '::in' => $instance . "/load_data_rd_i", );
	add_conn(%conns);

	# transceiver/iic_data_o => iic_if_$parent_data_o
	%conns = ( '::name' => "iic_if_" . $parent . "_data_o",
		   '::out' => $instance . "/iic_data_o", );
	add_conn(%conns);

	# transceiver/adr_or_data_o => adr_or_data
	%conns = ( '::name' => "adr_or_data",
		   '::out' => $instance . "/adr_or_data_o(15:0)", ); # std_ulogic_vector(0-15)
	add_conn(%conns);

	# transceiver/check_adr_o => check_adr
	%conns = ( '::name' => "check_adr",
		   '::out' => $instance . "/check_adr_o", );
	add_conn(%conns);

	# transceiver/adr_no_data_o => adr_no_data
	%conns = ( '::name' => "adr_no_data",
		   '::out' => $instance . "/adr_no_data_o", );
	add_conn(%conns);

	# transceiver/en_load_data_wr_o => en_load_data_wr
	%conns = ( '::name' => "en_load_data_wr",
		   '::out' => $instance . "/en_load_data_wr_o", );
	add_conn(%conns);

	# transceiver/iic_ignore_lsb_o => ignore_lsd
	%conns = ( '::name' => "ignore_lsb",
		   '::out' => $instance . "/iic_ignore_lsb_o", );
	add_conn(%conns);

    return 0;
}


####################################################################
## add_i2c_conn
####################################################################

=head1

  connect a subregister

 Arg1: $in - hash reference holding new definition
 Arg2: $name - Subregister name
 Arg3: $parent - Parent instance name

=cut

sub connect_subreg($$$) {

    my $in = shift;
    my $instance = shift;
    my $parent = shift;

    my %conns;
    my $subreg = sprintf("%lx", $in->{'::sub'});
    my $number;
    my $range = 0;


#==> Generics

        # ra_g - Subaddress
        %conns = ( '::name' => "p_" . $instance . "_ra_g",
		   '::in' => $instance . "/ra_g",
		   '::out' => "%PARAMETER%/" . $in->{'::sub'},
		   '::mode' => "P",
		   '::type' => "integer", );
        add_conn(%conns);

   	# sr_g
	%conns = ( '::name' => $instance . "",
		   '::in' => $instance . "/sr_g",
		   '::out' => "%PARAMETER%/0",
		   '::mode' => "P",
		   '::type' => "integer", );
        add_conn(%conns);

	# ais_g
	%conns = ( '::name' => $instance . "",
		   '::in' => $instance . "/ais_g",
		   '::out' => "%PARAMETER%/0",
		   '::mode' => "P",
		   '::type' => "integer", );
        add_conn(%conns);

        # hs_g
	%conns = ( '::name' => $instance . "",
		   '::in' => $instance . "/hs_g",
		   '::out' => "%PARAMETER%/0",
		   '::mode' => "P",
		   '::type' => "integer", );
        add_conn(%conns);

	# sh_g
	%conns = ( '::name' => $instance . "_sh_g",
		   '::in' => $instance . "/sh_g",
		   '::out' => "%PARAMETER%/1",
		   '::mode' => "P",
		   '::type' => "integer", );
        add_conn(%conns);

	# latch_g
	%conns = ( '::name' => $instance . "_latch_g",
		   '::in' => $instance . "/latch_g",
		   '::out' => "%PARAMETER%/0",
		   '::mode' => "P",
		   '::type' => "integer", );
        add_conn(%conns);


#==> Connections

	# subreg/clk => clk_iic
	%conns = ( '::name' => "clk_iic",
		   '::in' => $instance . "/clk", );
	add_conn(%conns);

	# subreg/reset => asres_iic
	%conns = ( '::name' => "asres_iic",
		   '::in' => $instance . "/reset", );
	add_conn(%conns);

	# subreg/asres => asres_iic
	%conns = ( '::name' => "asres_iic",
		   '::in' => $instance . "/asres", );
	add_conn(%conns);

	# subreg/adr_or_data_i => adr_or_data
	%conns = ( '::name' => "adr_or_data",
		   '::in' => $instance . "/adr_or_data_i(15:0)", );
	add_conn(%conns);

	# subreg/check_adr_i => check_adr
	%conns = ( '::name' => "check_adr",
		   '::in' => $instance . "/check_adr_i", );
	add_conn(%conns);

	# subreg/load_shadow_i => logic_1
	%conns = ( '::name' => "%HIGH%",
		   '::in' => $instance . "/load_shadow_i", );
#	add_conn(%conns);

	# subreg/ignore_lsb_i => ignore_lsb
	%conns = ( '::name' => "ignore_lsb",
		   '::in' => $instance . "/ignore_lsb_i", );
	add_conn(%conns);

	# subreg/ais_o => open
	%conns = ( '::name' => "%OPEN%",
		   '::out' => $instance . "/ais_o", );
	add_conn(%conns);

	# subreg/data_to_iic_o => data_reg<hex_subadr>_to_iic
	%conns = ( '::name' => "data_reg" . $subreg . "_to_iic",
		   '::out' => $instance . "/data_to_iic_o(15:0)", );
	add_conn(%conns);

	# subreg/load_data_rd_o => load_data_rd_reg<hex_subadr>
	%conns = ( '::name' => "load_data_rd_reg" . $subreg,
		   '::out' => $instance . "/load_data_rd_o", );
	add_conn(%conns);

	# subreg/adr_r_wn_ok_o => adr_r_wn_ok_reg<hex_subadr>
	%conns = ( '::name' => "adr_r_wn_ok_reg" . $subreg,
		   '::out' => $instance . "/adr_r_wn_ok_o", );
	add_conn(%conns);

#==> userdefined and directions specific connections

    if( $in->{'::dir'}=~ m/r/i) {
    # add r-specific generics

    # add r-specific connections
	# subreg/tf_en_rd_o => open
	%conns = ( '::name' => "%OPEN%",
		   '::out' => $instance . "/tf_ready_rd_i", );
	add_conn(%conns);
	# subreg/data_from_ext_i => 
	%conns = ( '::name' => "data_from_ext",
		   '::in' => $instance . "/data_from_ext_i(15:0)", );
	add_conn(%conns);

    # connect as read-register
        for my $i (keys %$in) {
	    if($i=~ m/^::b(:\d+)?$/ && $in->{$i}!~ m/^$/) {
		$range++;
	        if($i=~ m/^::b$/) {
		    $number = 1;
		}
		else {
		    $number= $i;
		    $number=~ s/^::b://;
		    $number++;
	        }
		%conns = ( '::name' => "reg_data_out_$subreg",
			   '::in' => $instance . "/data_from_ext_i($number)",
			   '::out' => $in->{$i}, );
		add_conn(%conns);
	    }
	}
    }

    elsif( $in->{'::dir'}=~ m/w/i) {
    # add w-specific generics
        # dor_g - Subaddress
        %conns = ( '::name' => $instance . "_dor_g",
		   '::in' => $instance . "/dor_g",
		   '::out' => "%PARAMETER%/0",
		   '::mode' => "P",
		   '::type' => "integer", );
	add_conn(%conns);

    # add w-specific connections
	# subreg/tf_ready_wr_i => logic_1
	%conns = ( '::name' => "%HIGH%",
		   '::in' => $instance . "/tf_ready_wr_i", );
	add_conn(%conns);
	# subreg/tf_en_wr_o => open
	%conns = ( '::name' => "%OPEN%",
		   '::out' => $instance . "/tf_en_wr_o", );
	add_conn(%conns);
        # subreg/en_load_data_wr_i => en_load_data_wr
        %conns = ( '::name' => "en_load_data_wr",
		   '::in' => $instance . "/en_load_data_wr_i", );
	add_conn(%conns);

	# subreg/reg_data_out_o => reg_data_out_<hex_subadr>
	%conns = ( '::name' => "reg_data_out_" . $subreg,
#		   '::type' => "std_ulogic_vector",
		   '::out' => $instance . "/reg_data_out_o(15:0)", );
	add_conn(%conns);

    # connect as write-register
        for my $i (keys %$in) {
	    if($i=~ m/^::b(:\d+)?$/ && defined $in->{$i} && $in->{$i}!~ m/^$/) {
		$range++;
	        if($i=~ m/^::b$/) {
		    $number = 1;
		}
		else {
		    $number= $i;
		    $number=~ s/^::b://;
		    $number++;
	        }
		%conns = ( '::name' => "reg_data_out_$subreg",
			   '::in' => $in->{$i},
			   '::out' => $instance . "/reg_data_out_$subreg($number)", );
		add_conn(%conns);
	    }
	}
    }
    elsif( $in->{'::dir'}=~ m/rw/i) {
    # connect as read-write-register
        for my $i (keys %$in) {
	    if($i=~ m/^::b(:\d+)?$/ && defined $in->{$i} && $in->{$i}!~ m/^$/) {
		$range++;
	        if($i=~ m/^::b$/) {
		    $number = 1;
		}
		else {
		    $number= $i;
		    $number=~ s/^::b:$//;
		    $number++;
	        }
		%conns = ( '::name' => "reg_data_out_$subreg",
			   '::in' => $in->{$i},
			   '::out' => $instance . "/reg_data_out_$subreg($number)", );
		add_conn(%conns);
	    }
	}
    }
    else {
        logwarn("WARNING: i2c sheet got bad ::dir entry <$in->{'::dir'}>, incorrect direction!");
	$EH{'sum'}{'warnings'}++;
	return 1;
    }

    # remember connected register-pins
    if(exists $hierdb{$instance}{'::crange'}) {
	$hierdb{$instance}{'::crange'} = $hierdb{$instance}{'::crange'} + $range;
	$range = $hierdb{$instance}{'::crange'};
    }
    else {
	$hierdb{$instance}{'::crange'} = $range;
    }

    delete $conndb{$instance . "_ur_g"};

    # ur_g - Registers width(?)
    %conns = ( '::name' => $instance . "_ur_g",
	       '::in' => $instance . "/ur_g",
	       '::out' => "%PARAMETER%/" . 2**$range,
	       '::mode' => "P",
	       '::type' => "integer", );
    add_conn(%conns);

    return 0;
}


####################################################################
## 
####################################################################

=head1

  create and connect a "or" block

 Arg1: $in - hash reference holding new definition
 Arg2: $name - Subregister name
 Arg3: $parent - Parent instance name

=cut

sub create_or_block($$$) {

    my $in = shift;
    my $subreg = shift;
    my $parent = shift;

    my $subadr = sprintf("%lx", $in->{'::sub'});

    # create new instance
    my %orblock = ( '::inst' => "or_" . $parent . "_block",
		    '::entity' => "or_" . $hierdb{$parent}{'::entity'} . "_block",
		    '::parent' => $parent, );
    my $instance = add_inst(%orblock);

    # connect adr_r_wn_ok
    %orblock = ( '::name' => "adr_r_wn_ok_reg" . $subadr,
		 '::in' => $instance . "/", );
#    add_conn(%orblock);
    # connect load_data_rd
    %orblock = ( '::namse' => "load_data_rd_reg" . $subadr,
		 '::in' => $instance . "/", );
#    add_conn(%orblock);
    # connect data_reg_to_iic
    %orblock = ( '::name' => "data_reg" . $subadr . "_to_iic",
		 '::in' => $instance . "/", );
#    add_conn(%orblock);

    return 0;
}
