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
# | Revision:   $Revision: 1.14 $                                         |
# | Author:     $Author: lutscher $                                            |
# | Date:       $Date: 2005/07/18 08:41:55 $                              |
# |                                                                       |
# | Copyright Micronas GmbH, 2003                                         |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/Attic/MixI2CParser.pm,v 1.14 2005/07/18 08:41:55 lutscher Exp $ |
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

=head 4 old

# Caveat: relies on proper setting of base, pgmpath and dir in main program!
use lib "$main::base/";
use lib "$main::base/lib/perl";
use lib "$main::pgmpath/";
use lib "$main::pgmpath/lib/perl";
use lib "$main::dir/lib/perl";
use lib "$main::dir/../lib/perl";

=cut

use Log::Agent;
use Log::Agent::Priorities qw( :LEVELS);

use Micronas::MixUtils qw( %EH );
use Micronas::MixParser qw( %hierdb %conndb add_inst add_conn );
use Micronas::MixChecker;
use Micronas::Reg;

####################################################################
## Prototypes:
sub parse_i2c_init($);
sub add_interface ($);
sub create_transceiver ($$);
sub create_sync_block ($$$);
sub connect_subreg ($$$);
sub create_or_block ($$$$@);
sub mix_i2c_collect_init ($$$$);
sub _mix_i2c_is_consecutive ($$);
sub _mix_i2c_overlap ($$$$$);
sub mix_i2c_init_assign ();
####################################################################


####################################################################
## Our local variables
####################################################################
#
# RCS Id, to be put into output templates
#

my $thisid		= 	'$Id: MixI2CParser.pm,v 1.14 2005/07/18 08:41:55 lutscher Exp $';
my $thisrcsfile	        =	'$RCSfile: MixI2CParser.pm,v $';
my $thisrevision        =       '$Revision: 1.14 $'; #'

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

    Go through data provided by I2C sheet and generate instances and connections
    as defined there. Please see the MIX documentation for a description of the
    format. Several columns are required.

  Arg1: input Array

=cut

sub parse_i2c_init($) {

    my $r_i2c = shift;
	
	if (scalar @$r_i2c) {
		my($o_space) = Micronas::Reg->new();

		if (grep($_ eq $EH{'reg_shell'}{'type'}, @{$o_space->global->{supported_views}})) {
			# init register module for generation of register-shell
			$o_space->init(	 
						   inputformat => "register-master", 
						   database_type => $EH{i2c}{regmas_type},
						   register_master => $r_i2c
						  );
			# make it so
			$o_space->generate_view($EH{'reg_shell'}{'type'});
		} else {
			# use this module for generation of register-shell
			my $ehr = $EH{'i2c'}{'field'};
			
		foreach my $i (@$r_i2c) {

			next if ( $i->{'::ign'} =~ m,^\s*(#|\\),); # Skip comments, just in case they sneak in
											  
			# Fill up input field
			for my $j ( keys %$ehr) {
	    	next unless ( $j =~ m/^::/ );
	    	if ( not defined( $i->{$j} )) {
				next if( $ehr->{$j}[2] eq 0);
				$i->{$j} = $ehr->{$j}[3];
	    	} elsif( $ehr->{$i}[2] && $i->{$j} eq "") {
				$i->{$j} = $ehr->{$i}[3]; # Set to DEFAULT Value
	    	}
		}
		add_interface($i);
    }
    # assign all init values now:
    mix_i2c_init_assign();
	};
	};
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

sub add_interface($) {

    my $in = shift;

    my $name;
    my $type;
    my $transceiver;

    # create a new instance in hierdb, create Interface first -> parent
    my $parent = $in->{'::interface'};
    #ORG: $in->{'::inst'} = $parent;
    $in->{'::inst'} = $EH{'reg_shell'}{'top_name'}; # Defines name for instance!
	$in->{'::entity'} = '%PREFIX_IIC_GEN%' . $in->{'::interface'}; #TODO: make more flexible
    $parent = add_inst( %$in);

    # only digits in ::sub? ->create new Register-block
    if( $in->{'::sub'}!~ m/^\s*(\d+)\s*$/ ) {
        logwarn( "WARNING: i2c sheet got bad ::sub entry $in->{'::sub'}, only digits allowed!" );
        $EH{'sum'}{'warnings'}++;
        return 1;
    } else {
      $name = $in->{'::interface'} . "_";
	  if( $in->{'::dir'}=~ m/rw/i) {
        $name .= $EH{'macro'}{'%RWREG%'};
	    $type = "rdwr";
	  } elsif( $in->{'::dir'}=~ m/w/i ) {
        $name .= $EH{'macro'}{'%WREG%'};
	    $type = "wr";
	  } elsif( $in->{'::dir'}=~ m/r/i) {
        $name .= $EH{'macro'}{'%RREG%'};
	    $type = "rd";
	  } else {
	    logwarn("WARNING: i2c sheet got bad ::dir entry <$in->{'::dir'}>, incorrect direction!");
	    $EH{'sum'}{'warnings'}++;
	    return 1;
	  }
	  $name = $name . sprintf( "%lx", $in->{'::sub'}); # Print HEX extension (subaddress) ...

	  $in->{'::inst'} = $name;
	  $in->{'::entity'} = "iic_" . $EH{'reg_shell'}{'type'} . "_reg_" . $type; #TODO: flex
	  $in->{'::parent'} = $parent;
	  $name = add_inst(%$in);

	  connect_subreg($in, $name, $parent);
    }

    # create transceiver unit
    $transceiver = create_transceiver($in, $parent); # Change call

    # create sync unit
    create_sync_block($in, $name, $parent); # Change interface -> parent!

    # create and connect "or"-block
    create_or_block($in, $name, $parent, $transceiver);

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

sub create_sync_block($$$) {

    my $in = shift;
    my $block = shift;
    my $parent = shift;

    my %conns;

	#TODO: prepare sync_block wiring
	my %sync_conn = (
		'clk'   => 'clk',
		'asres' => 'asres',
	);
	
    if( $in->{'::spec'}!~ m/nto/i) {

      # Transfer-mode specified, creating new sync block
      my $instance = $in->{'::interface'} . "_" . $EH{'macro'}{'%IIC_SYNC%'} .
      			 $parent . "_" . $in->{'::spec'};
	  $in->{'::inst'} = $instance;
	  $in->{'::entity'} = $EH{'reg_shell'}{'%IIC_SYNC%'};
	  $in->{'::parent'} = $parent;
      $instance = add_inst(%$in);

	  #==> Connections

	  # connect to clock domain
	  %conns = ( '::name' => $in->{'::clock'},
		         '::in' => $instance . "/" . $sync_conn{'clk'} . 
					", " . $parent . "/" . $in->{'::clock'}, );
 	  add_conn(%conns);

	  # connect asres/sync => ?
	  %conns = ( '::name' => $in->{'::reset'},
		         '::in' => $instance . "/" . $sync_conn{'asres'} .
		         	", " . $parent . "/" . $in->{'::reset'}, );
      add_conn(%conns);

	  # set_fast_active_i/sync => tf_en_wrFE
	  %conns = ( '::name' => "tf_en_wrFE_" . $parent,
	             '::in' => $instance . "/set_fast_active_i",
                 '::out' => $parent . "/tf_en_wr_FE_o", );
      add_conn(%conns);

	  # set_active_i/sync => tf_en_wrFF
	  %conns = ( '::name' => "tf_en_wrFF_" . $parent,
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
	  %conns = ( '::name' => "sync_" . $in->{'::spec'} .
	  				"_" . $parent,
		         '::in' => $block . "/load_shadow_i",
		         '::out' => $instance . "/load_shadow_o", );
	  add_conn(%conns);

	  # connect vxstat_o
	  %conns = ( '::name' => "stat_" . $in->{'::spec'} . "_" . $parent . "%POSTFIX_IIC_OUT%" , # "_iic_o"
		         '::out' => "$instance/vxstat_o, $parent/stat_"
		        . $in->{'::spec'} . "_" . $parent . "%POSTFIX_IIC_OUT%" ); # -> _iic_o
	  add_conn(%conns);
    } else {
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
    $in->{'::entity'} = "iic_". $EH{'reg_shell'}{'type'} . "_reg_rt";
    $in->{'::parent'} = $parent;
    $instance = add_inst(%$in);


#==> Generics

    # transceiver/sr_g => 0 (generic value)
    %conns = ( '::name' => $instance . "_sr_g",
		   '::in' => $instance . "/sr_g",
		   '::out' => "%PARAMETER%/0",
		   '::mode' => "P",
		   '::type' => "integer", );
    add_conn(%conns);

#==> Connections

	# transceiver/clk => clk_iic; input signal
	%conns = ( '::name' => "clk_iic",
	     	   '::in' => $instance . "/clk" . ", " . $parent,
	     	  );
	add_conn(%conns);

	# transceiver/reset => asres_iic
	%conns = ( '::name' => "asres_iic",
		       '::in' => $instance . "/reset" . ", " . $parent,
		     );
	add_conn(%conns);

	# transceiver/asres => asres_iic
	%conns = ( '::name' => "asres_iic",
		       '::in' => $instance . "/asres",
		     );
	add_conn(%conns);

	# transceiver/iic_adr_data_i => iic_adr_data_i
	%conns = ( '::name' => "iic_adr_data_i",
		       '::in' => "$parent/iic_adr_data_i, $instance/iic_adr_data_i", );
	add_conn(%conns);

	# transceiver/iic_en_i => iic_en_i
	%conns = ( '::name' => "iic_en_i",
		       '::in' => "$parent/iic_en_i, $instance/iic_en_i", );
	add_conn(%conns);

	#adr_r_wn_ok_i , load_data_rd_i

	# transceiver/test_disbus_i => logic_0
	%conns = ( '::name' => "%LOW%",
		       '::in' => $instance . "/test_disbus_i", );
	add_conn(%conns);

	# transceiver/i2c_ignore_lsb_i => ignore_lsb_i
	%conns = ( '::name' => "ignore_lsb_i",
		   '::in' => "$parent/ignore_lsb_i, $instance/i2c_ignore_lsb_i", );
	add_conn(%conns);

	# transceiver/iic_data_o => iic_if_$parent_data_o
	%conns = ( '::name' => "iic_if_" . $parent . "_data_o",
		   '::out' => "$parent/iic_if_" . $parent .
		   		"_data_o, $instance/iic_data_o", );
	add_conn(%conns);

	# transceiver/adr_or_data_o => adr_or_data
	%conns = ( '::name' => "adr_or_data_" . $parent,
		   '::out' => $instance . "/adr_or_data_o", # std_ulogic_vector(0-15) 
		   '::low' => 0,
		   '::high' => $EH{'reg_shell'}{'regwidth'} - 1, );
	add_conn(%conns);

	# transceiver/check_adr_o => check_adr
	%conns = ( '::name' => "check_adr_" . $parent,
		   '::out' => $instance . "/check_adr_o", );
	add_conn(%conns);

	# transceiver/adr_no_data_o => adr_no_data
	%conns = ( '::name' => "adr_no_data_" . $parent,
		   '::out' => $instance . "/adr_no_data_o", );
	add_conn(%conns);

	# transceiver/en_load_data_wr_o => en_load_data_wr
	%conns = ( '::name' => "en_load_data_wr_" . $parent,
		   '::out' => $instance . "/en_load_data_wr_o", );
	add_conn(%conns);

	# transceiver/iic_ignore_lsb_o => ignore_lsd
	%conns = ( '::name' => "ignore_lsb_" . $parent,
		   '::out' => $instance . "/iic_ignore_lsb_o", );
        add_conn(%conns);

    # selected_o port
    %conns = ( '::name' => "selected_" . $parent,
		'::out' => $instance . "/selected_o", );
    	add_conn(%conns);

    return $instance;
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

    my %conns = ();
    my $subreg = sprintf("%lx", $in->{'::sub'});
    my $number;
    my $range = 0;

	my $width = $in->{'::width'} || $EH{'reg_shell'}{'regwidth'};
#==> Generics

    # ra_g - Subaddress
    %conns = ( '::name' => "p_" . $instance . "_ra_g",
	   '::in' => $instance . "/ra_g",
	   '::out' => "%PARAMETER%/" . $in->{'::sub'},
	   '::mode' => "P",
	   '::type' => "integer", );
    add_conn(%conns);

   	# sr_g - "0"
	%conns = ( '::name' => $instance . "",
	   '::in' => $instance . "/sr_g",
	   '::out' => "%PARAMETER%/0",
	   '::mode' => "P",
	   '::type' => "integer", );
    add_conn(%conns);

	# ais_g = "0"
	%conns = ( '::name' => $instance . "",
	   '::in' => $instance . "/ais_g",
	   '::out' => "%PARAMETER%/0",
	   '::mode' => "P",
	   '::type' => "integer", );
    add_conn(%conns);

    # hs_g = "0"
	%conns = ( '::name' => $instance . "",
	   '::in' => $instance . "/hs_g",
	   '::out' => "%PARAMETER%/0",
	   '::mode' => "P",
	   '::type' => "integer", );
    add_conn(%conns);

	# sh_g = "1"
	%conns = ( '::name' => $instance . "_sh_g",
		   '::in' => $instance . "/sh_g",
		   '::out' => "%PARAMETER%/1",
		   '::mode' => "P",
		   '::type' => "integer", );
        add_conn(%conns);

	# latch_g = "0"
	%conns = ( '::name' => $instance . "_latch_g",
		   '::in' => $instance . "/latch_g",
		   '::out' => "%PARAMETER%/0",
		   '::mode' => "P",
		   '::type' => "integer", );
        add_conn(%conns);


#==> Connections
	#TODO: link to ::clk from register-master!!
	# subreg/clk => clk_iic (global)
	%conns = ( '::name' => "clk_iic",
	    '::in' => $instance . "/clk", );
	add_conn(%conns);

	# subreg/reset => asres_iic (glocal)
	%conns = ( '::name' => "asres_iic",
		   '::in' => $instance . "/reset", );
	add_conn(%conns);

	# subreg/asres => asres_iic (global)
	%conns = ( '::name' => "asres_iic",
		   '::in' => $instance . "/asres", );
	add_conn(%conns);

	# subreg/check_adr_i => check_adr (inter-block)
	%conns = ( '::name' => "check_adr_" . $parent,
		   '::in' => $instance . "/check_adr_i", );
	add_conn(%conns);

	# subreg/load_shadow_i => logic_1 (fixed)
	%conns = ( '::name' => "%HIGH%",
		   '::in' => $instance . "/load_shadow_i", );
#	add_conn(%conns);

	# subreg/ignore_lsb_i => ignore_lsb (inter-block -> transceiver)
	%conns = ( '::name' => "ignore_lsb_" . $parent,
		   '::in' => "$instance/ignore_lsb_i", );
	add_conn(%conns);

	# subreg/ais_o => open (fixed)
	%conns = ( '::name' => "%OPEN_" . $EH{'OPEN_NR'}++ . "%",
		   '::out' => "$parent/ais_" . $in->{'::interface'} . "_o , $instance/ais_o", );
	add_conn(%conns);


	# subreg/load_data_rd_o => load_data_rd_reg<hex_subadr> (inter-block)
	%conns = ( '::name' => "load_data_rd_reg" . $subreg . "_" . $parent,
		   '::in' => "or_$parent" . "_block_load/load_data_rd_reg$subreg" . "_i",
		   '::out' => $instance . "/load_data_rd_o_" . $parent, );
	add_conn(%conns);

	# subreg/adr_r_wn_ok_o => adr_r_wn_ok_reg<hex_subadr>
	%conns = ( '::name' => "adr_r_wn_ok_reg" . $subreg . "_" . $parent,
		   '::in' => "or_$parent" . "_block_adr/adr_r_wn_ok_reg$subreg" . "_i",
		   '::out' => $instance . "/adr_r_wn_ok_o", );
	add_conn(%conns);

	# subreg/data_to_iic_o => data_reg<hex_subadr>_to_iic
	%conns = ( '::name' => "data_reg" . $subreg . "_to_iic_" . $parent,
		   '::in' => "or_" . $parent . "_block_data/data_reg$subreg" . "_to_iic_i", #!wig: remove (15:0) -> automatic
		   '::out' => $instance . "/data_to_iic_o", #!wig: remove (15:0) -> automatic
		   '::low' => 0,
		   '::high' => $width - 1, );
	add_conn(%conns);

#==> userdefined and directions specific connections

    if( $in->{'::dir'}=~ m/w/i) { #wig: !!matches "RW", too!!!
    	# add w-specific generics
        # dor_g - Subaddress
        %conns = ( '::name' => $instance . "_dor_g",
		   '::in' => $instance . "/dor_g",
		   '::out' => "%PARAMETER%/0",
		   '::mode' => "P",
		   '::type' => "integer", );
		add_conn(%conns);

    	# add w-specific connections
		# subreg/tf_ready_wr_i => logic_1 (fixed)
		%conns = ( '::name' => "%HIGH%",
		   '::in' => $instance . "/tf_ready_wr_i", );
		add_conn(%conns);
		# subreg/tf_en_wr_o => open (fixed)
		%conns = ( '::name' => "%OPEN_" . $EH{'OPEN_NR'}++ . "%",
		   '::out' => $instance . "/tf_en_wr_o", );
		add_conn(%conns);
        # subreg/en_load_data_wr_i => en_load_data_wr
        %conns = ( '::name' => "en_load_data_wr_" . $parent,
		   '::in' => $instance . "/en_load_data_wr_i", );
		add_conn(%conns);

		# subreg/reg_data_out_o => reg_data_out_<hex_subadr> (block to func. block)
		%conns = ( '::name' => "reg_data_out_" . $subreg . "_" . $parent,
		   '::type' => "std_ulogic_vector",
		   '::out' => $instance . "/reg_data_out_o", #!wig: remove (15:0)
		   '::low' => 0,
		   '::high' => $width - 1, );
		add_conn(%conns);

		# subreg/adr_or_data_i => adr_or_data
		%conns = ( '::name' => "adr_or_data_" . $parent,
		   '::in' => $instance . "/adr_or_data_i", #!wig: remove??? (15:0)
		   '::high' => $width - 1,
		   '::low'  => 0,
		   );
		add_conn(%conns);

    	# connect as write-register
		# my $prefix = $in->{'::block'} . "_" . $in->{'::sub'} . "%POSTFIX_IIC_OUT%"; # _iic_o;
		my $prefix = "reg_data_out_o"; #TODO_ flex
		my $pin;
		my $blocksig;
		my @bits = (); # Store used bits ....
		
		%conns = ( '::name' => "reg_data_out_$subreg",
			   		'::out' => $instance . "/$prefix",
			   		'::high' => $width - 1,
			   		'::low' => "0",
			    );
		add_conn( %conns );
		
    	for my $i (sort(keys %$in)) {
			if($i=~ m/^::b(:\d+)?$/ && defined $in->{$i} && $in->{$i}!~ m/^$/) {
				$range++;
	        	if($i=~ m/^::b(:(\d+))?$/) {
		    		$number = $2 || 0;
				}

	        	# Accept SIGNAL(N) or SIGNAL.N
	        	if ( $in->{$i} =~ m/(.+)\((.+)\)/ or $in->{$i} =~ m/(.+)\.(.+)/ ) {
	        		$pin = "($2)=";
	        		$blocksig = $1;
	        	} else {
	        		$blocksig = $in->{$i};
	        		$pin = "=";
	        	}
	        	if ( $EH{'reg_shell'}{'mode'} =~ m/\blcport\b/io ) {
	        		$blocksig = lc( $blocksig );
	        	}
	        	$blocksig =~ s/^\s+//;
	        	$blocksig =~ s/\s+$//;
	        	#TODO: ERROR CHECKING (typos, illegal chars, ...)
				#OLD: $pin = $in->{$i};
				#OLD: $pin =~ s/^.*\(//;
				#OLD: $pin =~ s/\)$//;
				# Create register to block wire:
				my $linkn = $EH{'reg_shell'}{'regwidth'} - $number - 1;
				%conns = ( '::name' => "reg_data_out_$subreg",
			   		'::out' => $parent . "/" . $blocksig . $pin . "(" . $linkn . ")," .
			              $instance . "/$prefix($linkn)=($linkn)",
			   		'::comment' => "in:" . $in->{$i} ."$pin; in: $parent/$prefix($number); ",
			  	);
			  	push( @bits, $linkn);
				add_conn(%conns);
	  		}
    	}
     	mix_i2c_collect_init( $instance, $width, $in->{'::init'}, \@bits );
    	
	} elsif( $in->{'::dir'}=~ m/r/i) {
    	# add r-specific generics

    	# add r-specific connections
		# subreg/tf_ready_rd_i => open
		%conns = ( '::name' => "%OPEN_" . $EH{'OPEN_NR'}++ . "%",
		       '::in' => $instance . "/tf_ready_rd_i", );
		add_conn(%conns);

		# subreg/tf_en_rd_o => open
		%conns = ( '::name' => "%OPEN_" . $EH{'OPEN_NR'}++ . "%",
		       '::out' => $instance . "/tf_en_rd_o", );
		add_conn(%conns);

		# subreg/data_from_ext_i => 
		%conns = ( '::name' => "data_$subreg" . "_from_ext_" . $parent,
		   '::in' => $instance . "/data_from_ext_i", #!wig: remove (15:0) -> automatic
		   '::low' => 0,
		   '::high' => $width - 1, );
		add_conn(%conns);

		# subreg/adr_or_data_i => adr_or_data
		%conns = ( '::name' => "adr_or_data_" . $parent,
		   '::in' => $instance . "/adr_or_data_i",
		   '::low' => 0,
		   '::high' => $width - 1, #!wig: addrwidth!!!
		  );
		add_conn(%conns);

    	# connect as read-register
		#ORG: my $prefix = $in->{'::block'} . "_" . $in->{'::sub'} . "%POSTFIX_IIC_IN%"; # _iic_i
		my $prefix = "data_from_ext_i"; #TODO: flex
		my $pin;
		my $blocksig;
		my $bits = '0' x $width; # used bit positions ...
		my @bits = (); # Store used bits ....

		%conns = ( '::name' => "reg_data_in_$subreg",
			   		'::out' => $instance . "/$prefix",
			   		'::high' => $width - 1,
			   		'::low' => "0",
			    );
		add_conn( %conns );
	
    	for my $i (sort(keys %$in)) {
        	#TODO: check this vs. the _max_multi_ number of columns
	    	if ($i=~ m/^::b(:(\d+))?$/ && $in->{$i}!~ m/^$/) {
				$range++;
				# MIX ::b column number:
	        	if($i=~ m/^::b(:(\d+))?$/) {
		    		$number = $2 || "0" ;
				}

	        	# Accept   SIGNAL(N) or SIGNAL.N
	        	if ( $in->{$i} =~ m/(.+)\((.+)\)/ or $in->{$i} =~ m/(.+)\.(.+)/ ) {
	        		$pin = "($2)=";
	        		$blocksig = $1;
	        	} else {
	        		$blocksig = $in->{$i};
	        		$pin = "=";
	        	}
	        	if ( $EH{'reg_shell'}{'mode'} =~ m/\blcport\b/io ) {
	        		$blocksig = lc( $blocksig );
	        	}
	        	$blocksig =~ s/^\s+//;
	        	$blocksig =~ s/\s+$//;
	        	#TODO: ERROR CHECKING (typos, illegal chars, ...)
	        	#OLD: $pin = $in->{$i};
				#OLD: $pin =~ s/^.*\(//;
				#OLD: $pin =~ s/\)$//;
				# Create register to block wire:
				my $linkn = $EH{'reg_shell'}{'regwidth'} - $number - 1;
				%conns = ( '::name' => "reg_data_in_$subreg",
			           '::in' => "$instance/$prefix($linkn)=($linkn)," .
			   		   $parent . "/" . $blocksig . $pin . "(" . $linkn . ")",
				);
				push( @bits, $linkn);
				add_conn(%conns);
	    	}
		}
    	mix_i2c_collect_init( $instance, $width, $in->{'::init'}, \@bits );
    } elsif ( $in->{'::dir'}=~ m/rw/i) {
		#TODO: 
		%conns = ( '::name' => "reg_data_in_$subreg",
		   '::in' => "$instance/reg_data_in_$subreg", );
		add_conn(%conns);

		%conns = ( '::name' => "reg_data_out_$subreg",
		   '::out' => "$instance/reg_data_out_$subreg", );
		add_conn(%conns);

    	# connect as read-write-register
		logwarn("ERROR: I2C RW-Registers not implemented yet!");
		$EH{'sum'}{'errors'}++;
=head1
		my $prefix = $in->{'::block'} . "_" . $in->{'::sub'} . "_iic_io";
        for my $i (keys %$in) {
	    if($i=~ m/^::b(:\d+)?$/ && defined $in->{$i} && $in->{$i}!~ m/^$/) {
		$range++;
	        if($i=~ m/^::b$/) {
		    $number = 0;
		}
		else {
		    $number= $i;
		    $number=~ s/^::b:$//;
	        }
		%conns = ( '::name' => "reg_data_io_$subreg",
			   '::in' => $in->{$i},
			   '::out' => "$parent/$prefix($number), $instance/$prefix($number)",
	                   '::low' => "0",
	                   '::high' => "15",);
		add_conn(%conns);
	    }
	}
=cut
    } else {
        logwarn("WARNING: i2c sheet got bad ::dir entry <$in->{'::dir'}>, incorrect direction!");
		$EH{'sum'}{'warnings'}++;
		return 1;
    }

    # remember connected register-pins
    if(exists $hierdb{$instance}{'::crange'}) {
		$hierdb{$instance}{'::crange'} = $hierdb{$instance}{'::crange'} + $range;
		$range = $hierdb{$instance}{'::crange'};
    } else {
		$hierdb{$instance}{'::crange'} = $range;
    }

	# init value create:

	# Redo this connection:
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

sub create_or_block($$$$@) {

    my $in = shift;
    my $subreg = shift;
    my $parent = shift;
    my $transceiver = shift;

    my $subadr = sprintf("%lx", $in->{'::sub'});

    # create new instance
    my %orblock = ( '::inst' => "or_" . $parent . "_block_load",
		    '::entity' => "or_" . $hierdb{$parent}{'::entity'} . "_block",
		    '::parent' => $parent, );
    my $instance = add_inst(%orblock);

    # connect adr_r_wn_ok
    %orblock = ( '::name' => $parent . "_adr_r_wn_ok",
		 '::in' => "$transceiver/adr_r_wn_ok_i",
		 '::out' => "$instance/adr_r_wn_ok_o", );
    add_conn(%orblock);

    # create new instance
    %orblock = ( '::inst' => "or_" . $parent . "_block_load",
		    '::entity' => "or_" . $hierdb{$parent}{'::entity'} . "_block",
		    '::parent' => $parent, );
    $instance = add_inst(%orblock);

    # connect load_data_rd
    %orblock = ( '::name' => $parent . "_load_data_rd",
		 '::in' => "$transceiver/load_data_rd_i",
		 '::out' => "$instance/load_data_rd_o", );
    add_conn(%orblock);

    # create new instance
    %orblock = ( '::inst' => "or_" . $parent . "_block_data",
		    '::entity' => "or_" . $hierdb{$parent}{'::entity'} . "_block",
		    '::parent' => $parent, );
    $instance = add_inst(%orblock);

    # connect data_reg_to_iic
    %orblock = ( '::name' => $parent . "_data_reg_to_iic",
		 '::in' => "$transceiver/data_to_iic_i",
		 '::out' => "$instance/data_reg_to_iic_o",
		 '::low' => "0",
		 '::high' => $in->{'::width'}, );
    add_conn(%orblock);

    return 0;
}

#
# add another init value to this register
# input: bit position from: ... to: ...
# init value:
#
# Arguments:
#   registername
#   initvalue from current line
#   array-ref with numbers of connected bits from this line
# 
# Checks: was there already s.th there?
#   remember all connected registers
#    -> hierdb{__i2c_init__}, __i2c_connected__ (test string, bit number = "1" string pos.)
#
sub mix_i2c_collect_init ($$$$) {
	my $reg = shift;
	my $width = shift;
	my $init = shift;
	my $bitr = shift;

	return unless ( scalar( @$bitr )); # Not a single bit:
	
	# Previous value:
	my $conreg = $hierdb{$reg}{'__i2c_connected__'} || ( '0' x $width );
	my $initreg = $hierdb{$reg}{'__i2c_init__'} || 0;

	# are the bits in one, consecutive row?
	my ( $ok, $min, $max ) =  _mix_i2c_is_consecutive( $width, $bitr );
	# overlay init and bit mask
	if ( $ok eq "1" ) { # o.k.
		( $ok , $conreg, $initreg ) = _mix_i2c_overlap( $conreg, $initreg, $init, $min, $max ); 
	}
	
	if ( $ok eq "1" ) {
		$hierdb{$reg}{'__i2c_connected__'} = $conreg;
		$hierdb{$reg}{'__i2c_init__'} = $initreg;
	} else {
		logwarn( "ERROR: init value for $reg assign failed!" );
		$EH{'sum'}{'errors'}++;
	}
}

#
# are all bits in one consecutive row?
#
sub _mix_i2c_is_consecutive ($$) {
		my $rw = shift;
		my $bitr = shift;
		
		my $t = '0' x $rw;
		my $min = $rw;
		my $max = 0;
		my $flag = 1;
		# Put a "one" at each connected slice
		foreach ( @$bitr ) {
			if ( $_ >= $rw or $_ < 0 ) {
				# Ignore bits outside of range ...
				logwarn( "ERROR: i2c register illegal connection $_ -gt $rw" );
				$EH{'sum'}{'errors'}++;
				$flag = "EOUT";
				next;
			}
			if ( $min > $_ ) { $min = $_; };
			if ( $max < $_ ) { $max = $_; };
			
			substr( $t, $_, 1 ) = "1";
		}
		$t =~ s/^0+//;
		$t =~ s/0+$//;
		if ( index( $t, "0" ) >= 0 ) { # Still 0 in :-(
			return ( 0, $min, $max );
		}
		return( $flag, $min, $max );
}

#
# add up to create init value
# remember which positions had already a value assigned
# return: flag (ne zero if s.th. goes wrong), new connection list, new init value
# 
sub _mix_i2c_overlap ($$$$$) {
	my $conreg = shift;
	my $initreg = shift;
	my $init = shift;
	my $min = shift;
	my $max = shift;
	
	my $flag = 1;

	foreach my $i ( $min..$max ) {
		if ( substr( $conreg, $i, 1 ) eq "1" ) {
			# Already wired!
			logwarn( "ERROR: duplicate initvals assigned in i2c" );
			$EH{'sum'}{'errors'}++;
			$flag = "EDUPL";
		}
		substr( $conreg, $i, 1 ) = "1"; # Set it now
	}
	if( $flag eq "1" ) {
		$initreg += $init << $min;
	}
	return ( $flag, $conreg, $initreg );
}

#
# Iterate over all collected init values and create the appropriate
# parameter assignment
#
sub mix_i2c_init_assign () {

	for my $i ( keys( %hierdb ) ) {
		if ( exists $hierdb{$i}{'__i2c_init__'} ) {
			my %conns = ( '::name' => $i . "_dor_g",
	    		'::in' => $i . "/dor_g",
	    		'::out' => "%PARAMETER%/" . $hierdb{$i}{'__i2c_init__'},
	    		'::mode' => "P",
	    		'::type' => "integer",
	    		'::comment' => "# Generated i2c init value",
	    		);
    		add_conn(%conns);
    		# If a write register, assign "open" to all open bits ...
    		#TODO: my $bv = $hierdb{$i}{'__i2c_connected__'};
    		# find all "0" in $bv ....
		}
	}
}

#!End
