#! /usr/bin/perl -w
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

# +-----------------------------------------------------------------------+
# | Id           : $Id: mix_embedded.pl,v 1.9 2004/08/05 14:04:47 abauer Exp $     |
# | Name         : $Name:  $                                    |
# | Description  : $Description: simple wrapper script for embedding MIX $|
# | Parameters   : -                                                      | 
# | Version      : $Revision: 1.9 $                                       |
# | Mod.Date     : $Date: 2004/08/05 14:04:47 $                           |
# | Author       : $Author: abauer $                                      |
# | Email        : $Email: Alexander.Bauer@micronas.com$                  |
# |                                                                       |
# | Copyright (c)2002 Micronas GmbH. All Rights Reserved.                 |
# | MIX proprietary and confidential information.                         |
# |                                                                       |
# +-----------------------------------------------------------------------+

# +-----------------------------------------------------------------------+
# | Changes:
# +-----------------------------------------------------------------------+

# --------------------------------------------------------------------------

#******************************************************************************
# Other required packages
#******************************************************************************

use strict;
use Cwd;
use File::Basename;
use Getopt::Long qw(GetOptions);
use Pod::Text;

use vars qw($pgm $base $pgmpath $dir);

$dir = "";
($^O=~/Win32/) ? ($dir=getcwd())=~s,/,\\,g : ($dir=getcwd());

BEGIN{
    ($^O=~/Win32/) ? ($dir=getcwd())=~s,/,\\,g : ($dir=getcwd());

    ($pgm=$0) =~s;^.*(/|\\);;g;
    if ( $0 =~ m,[/\\],o ) { #$0 has path ...
        ($base=$0) =~s;^(.*)[/\\]\w+[/\\][\w\.]+$;$1;g;
        ($pgmpath=$0) =~ s;^(.*)[/\\][\w\.]+$;$1;g;
    } else {
        ( $base = $dir ) =~ s,^(.*)[/\\][\w\.]+$,$1,g;
        $pgmpath = $dir;
    }
}

# Todo: get appropriate MIX path from config file

use lib "$base/";
use lib "$base/lib/perl";
use lib "$pgmpath/";
use lib "$pgmpath/lib/perl";
use lib "$dir/lib/perl";
use lib "$dir/../lib/perl";
#TODO: Which "use lib path" if $0 was found in PATH?

use Log::Agent;
use Log::Agent::Priorities qw(:LEVELS);
use Log::Agent::Driver::File;

use Micronas::MixUtils qw( mix_init %EH mix_getopt_header db2array);
use Micronas::MixUtils::IO qw(init_ole mix_utils_open_input write_sum write_outfile);
use Micronas::MixParser qw( %hierdb %conndb parse_conn_macros parse_conn_gen parse_hier_init parse_conn_init apply_conn_gen apply_hier_gen apply_conn_macros purge_relicts parse_mac add_portsig add_sign2hier);
use Micronas::MixIOParser;
use Micronas::MixI2CParser;
use Micronas::MixWriter;


#******************************************************************************
# Global Variables
#******************************************************************************

$::VERSION = '$Revision: 1.9 $'; # RCS Id
$::VERSION =~ s,\$,,go;

mix_init(); # load Presets ....

mix_getopt_header( qw(
		      dir=s
		      out=s
		      outenty=s
		      outarch=s
		      outconf=s
		      combine!
		      top=s
		      variant=s
		      adump!
		      conf=s@
		      sheet=s@
		      listconf
		      delta!
		      strip!
		      bak!
		      init
		      import=s@
		      ));


my ($r_hierin, $r_connin, $r_ioin, $r_i2cin);
my ($n_ioin_ext, $n_i2cin_ext);


sub readSpreadsheet(@) {

    my $input = shift;

     # fetch HIER, CONN, IO and I2C sheet(s)
    ( $r_connin, $r_hierin, $r_ioin, $r_i2cin) = mix_utils_open_input( $input);
}


sub writeSpreadsheet($) {

    my $filename = shift;

    # TODO: build arrays from input hashes
#    write_outfile($filename, "HIER", db2array($r_hierin, "HIER", undef));
#    write_outfile($filename, "CONN", db2array($r_connin, "CONN", undef));
#    write_outfile($filename, "IO", db2array($r_ioin, "IO", undef));
#    write_outfile($filename, "CONF", db2array($r_i2cin, "CONF", undef));
}


sub hash2array() {

    # - generate header
    # - append rows

#    return ;
}


#### Functions for creating a Hierarchical Tree
{  # keep the following stuff locally


    my $location;    # reference to location in Hash;
    my $stepInto;    # step down or don't

    # TODO: parse hierarchical tree and build a 'real' tree
    #       or optional implement a other way of passing it to the GUI


    # set location to TOPLEVEL
    sub initTreeWalk()
    {
        $location = $hierdb{'TESTBENCH'}{'::treeobj'}->root;
        # get root node
	$location = $hierdb{'TESTBENCH'};
	if(!defined($location))
	{
	    print("TESTBENCH not found!\n");
	    return 0;
	}
        $location = $hierdb{'TESTBENCH'}{'::treeobj'}->root;

	if(!defined($location))
	{
	    print("NULL\n");
	    return 0;
	}
	$stepInto = 1;
	return 1;
    }


    # if location has childs return true else false
    sub hasChilds()
    {
	if( $location->daughters && $stepInto==1)
	{
	    return 1;
	}
	else
	{
	    return 0;
	}
    }


    # returns the Name of the next Element if exists; if location
    # got childs step into level below. if no more childs goto
    # mother and return undef;
    sub getNextName()
    {
	my @daughters = $location->daughters;

	# step one level down if thi
        $location = $hierdb{'TESTBENCH'}{'::treeobj'}->root;
	if( @daughters && $stepInto==1)
	{
	    # go to left field in level below
	    $location = $daughters[0];
	    return $location->name;
	}

	my $last_location = $location;
	$location = $location->right_sister;

	if( $location) # got more elems
	{
	    $stepInto = 1;
	    return $location->name;
	}
	else
	{
	    $stepInto = 0;    # prevent from steping down again
	    $location = $last_location->mother;    # set old location
	    return defined;
	}
    }
}


sub getInstLang($) {

    my $name = shift;

    my $temp = $hierdb{$name}{'::lang'};

    print "Instance: $name -> $temp\n";

    return $temp;
}


sub getNumHierRows() {
    return (scalar $#{$r_hierin});
}


sub getHierRow($) {

    my $row = shift;

    my @row = ();

    if(exists($r_hierin->[$row]{'::ign'})) {
      push(@row, $r_hierin->[$row]{'::ign'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_hierin->[$row]{'::gen'})) {
      push(@row, $r_hierin->[$row]{'::gen'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_hierin->[$row]{'::variants'})) {
      push(@row, $r_hierin->[$row]{'::variants'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_hierin->[$row]{'::parent'})) {
      push(@row, $r_hierin->[$row]{'::parent'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_hierin->[$row]{'::inst'})) {
      push(@row, $r_hierin->[$row]{'::inst'});
    }
    else{
      push(@row,"");
    }
    if(exists($r_hierin->[$row]{'::lang'})) {
      push(@row, $r_hierin->[$row]{'::lang'});
    }
    else{
      push(@row,"");
    }
    if(exists($r_hierin->[$row]{'::entity'})) {
      push(@row, $r_hierin->[$row]{'::entity'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_hierin->[$row]{'::arch'})) {
      push(@row, $r_hierin->[$row]{'::arch'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_hierin->[$row]{'::config'})) {
      push(@row, $r_hierin->[$row]{'::config'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_hierin->[$row]{'::use'})) {
      push(@row, $r_hierin->[$row]{'::use'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_hierin->[$row]{'::comment'})) {
      push(@row, $r_hierin->[$row]{'::comment'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_hierin->[$row]{'::descr'})) {
      push(@row, $r_hierin->[$row]{'::descr'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_hierin->[$row]{'::shortname'})) {
      push(@row, $r_hierin->[$row]{'::shortname'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_hierin->[$row]{'::default'})) {
      push(@row, $r_hierin->[$row]{'::default'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_hierin->[$row]{'::hierarchy'})) {
      push(@row, $r_hierin->[$row]{'::hierarchy'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_hierin->[$row]{'::debug'})) {
      push(@row, $r_hierin->[$row]{'::debug'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_hierin->[$row]{'::skip'})) {
      push(@row, $r_hierin->[$row]{'::skip'});
    }
    else {
      push(@row,"");
    }

    return(@row);
}


sub setHierValue($$$) {

    my $data = shift;
    my $row = shift;
    my $column = shift;

    if(!defined($column)) {
      $column = "";
    }
    if(!defined($data)) {
      $data = "";
    }

    if(exists($r_hierin->[$row]{$column})) {
      $r_hierin->[$row]{$column} = $data;
    }
}


sub getNumConnRows() {
    return (scalar $#{$r_connin});
}


sub getConnRow($) {

    my $row = shift;

    my @row = ();

    if(exists($r_connin->[$row]{'::ign'})) {
      push(@row, $r_connin->[$row]{'::ign'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_connin->[$row]{'::gen'})) {
      push(@row, $r_connin->[$row]{'::gen'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_connin->[$row]{'::bundle'})) {
      push(@row, $r_connin->[$row]{'::bundle'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_connin->[$row]{'::class'})) {
      push(@row, $r_connin->[$row]{'::class'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_connin->[$row]{'::clock'})) {
      push(@row, $r_connin->[$row]{'::clock'});
    }
    else{
      push(@row,"");
    }
    if(exists($r_connin->[$row]{'::type'})) {
      push(@row, $r_connin->[$row]{'::type'});
    }
    else{
      push(@row,"");
    }
    if(exists($r_connin->[$row]{'::high'})) {
      push(@row, $r_connin->[$row]{'::high'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_connin->[$row]{'::low'})) {
      push(@row, $r_connin->[$row]{'::low'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_connin->[$row]{'::mode'})) {
      push(@row, $r_connin->[$row]{'::mode'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_connin->[$row]{'::name'})) {
      push(@row, $r_connin->[$row]{'::name'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_connin->[$row]{'::shortname'})) {
      push(@row, $r_connin->[$row]{'::shortname'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_connin->[$row]{'::out'})) {
      push(@row, $r_connin->[$row]{'::out'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_connin->[$row]{'::in'})) {
      push(@row, $r_connin->[$row]{'::in'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_connin->[$row]{'::descr'})) {
      push(@row, $r_connin->[$row]{'::descr'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_connin->[$row]{'::comment'})) {
      push(@row, $r_connin->[$row]{'::comment'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_connin->[$row]{'::default'})) {
      push(@row, $r_connin->[$row]{'::default'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_connin->[$row]{'::debug'})) {
      push(@row, $r_connin->[$row]{'::debug'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_connin->[$row]{'::skip'})) {
      push(@row, $r_connin->[$row]{'::skip'});
    }
    else {
      push(@row,"");
    }

    return(@row);
}

sub setConnValue($$$) {

    my $data = shift;
    my $row = shift;
    my $column = shift;

    if(!defined($column)) {
      $column = "";
    }
    if(!defined($data)) {
      $data = "";
    }

    if(exists($r_connin->[$row]{$column})) {
      $r_connin->[$row]{$column} = $data;
    }
}

sub getNumIOPadHeaders{
    return ($EH{'io'}{'cols'} + 1);
}

sub getNumIOPadRows() {
    return (scalar $#{$r_ioin});
}

sub get_sta_IOPadRow($) {

    my $row = shift;

    my @row = ();

    if(exists($r_ioin->[$row]{'::ign'})) {
      push(@row, $r_ioin->[$row]{'::ign'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_ioin->[$row]{'::class'})) {
      push(@row, $r_ioin->[$row]{'::class'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_ioin->[$row]{'::ispin'})) {
      push(@row, $r_ioin->[$row]{'::ispin'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_ioin->[$row]{'::pin'})) {
      push(@row, $r_ioin->[$row]{'::pin'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_ioin->[$row]{'::pad'})) {
      push(@row, $r_ioin->[$row]{'::pad'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_ioin->[$row]{'::type'})) {
      push(@row, $r_ioin->[$row]{'::type'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_ioin->[$row]{'::iocell'})) {
      push(@row, $r_ioin->[$row]{'::iocell'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_ioin->[$row]{'::port'})) {
      push(@row, $r_ioin->[$row]{'::port'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_ioin->[$row]{'::name'})) {
      push(@row, $r_ioin->[$row]{'::name'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_ioin->[$row]{'::comment'})) {
      push(@row, $r_ioin->[$row]{'::comment'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_ioin->[$row]{'::default'})) {
      push(@row, $r_ioin->[$row]{'::default'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_ioin->[$row]{'::debug'})) {
      push(@row, $r_ioin->[$row]{'::debug'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_ioin->[$row]{'::skip'})) {
      push(@row, $r_ioin->[$row]{'::skip'});
    }
    else {
      push(@row,"");
    }

    return(@row);
}

sub get_dyn_IOPadRow($) {

    my $row = shift;
    my $num_dyn_cols = $EH{'io'}{'cols'} + 1;
    my @row = ();

    for(my $i=$num_dyn_cols; $i >= 0; $i--) {

	if($i == 0 && exists($r_ioin->[$row]{'::muxopt'})) {
	    push(@row, $r_ioin->[$row]{'::muxopt'});
	}
	elsif($i > 0 && exists($r_ioin->[$row]{'::muxopt:' . $i})) {
	    push(@row, $r_ioin->[$row]{'::muxopt:' . $i});
	}
	else {
	    push(@row, "");
	}
    }

    return(@row);
}

sub setIOPadValue($$$) {

    my $data = shift;
    my $row = shift;
    my $column = shift;


    if(!defined($column)) {
      $column = "";
    }
    if(!defined($data)) {
      $data = "";
    }

    if(exists($r_ioin->[$row]{$column})) {
      $r_ioin->[$row]{$column} = $data;
    }
}

sub getNumI2CHeaders{
    return ($EH{'i2c'}{'cols'} + 1);
}

sub getNumI2CRows() {
    return (scalar $#{$r_i2cin});
}

sub get_sta_I2CRow($) {

    my $row = shift;

    my @row = ();

    if(exists($r_i2cin->[$row]{'::ign'})) {
      push(@row, $r_i2cin->[$row]{'::ign'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_i2cin->[$row]{'::comment'})) {
      push(@row, $r_i2cin->[$row]{'::comment'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_i2cin->[$row]{'::variants'})) {
      push(@row, $r_i2cin->[$row]{'::variants'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_i2cin->[$row]{'::dev'})) {
      push(@row, $r_i2cin->[$row]{'::dev'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_i2cin->[$row]{'::sub'})) {
      push(@row, $r_i2cin->[$row]{'::sub'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_i2cin->[$row]{'::interface'})) {
      push(@row, $r_i2cin->[$row]{'::interface'});    }
    else {
      push(@row,"");
    }
    if(exists($r_i2cin->[$row]{'::block'})) {
      push(@row, $r_i2cin->[$row]{'::block'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_i2cin->[$row]{'::dir'})) {
      push(@row, $r_i2cin->[$row]{'::dir'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_i2cin->[$row]{'::spec'})) {
      push(@row, $r_i2cin->[$row]{'::spec'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_i2cin->[$row]{'::clock'})) {
      push(@row, $r_i2cin->[$row]{'::clock'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_i2cin->[$row]{'::reset'})) {
      push(@row, $r_i2cin->[$row]{'::reset'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_i2cin->[$row]{'::busy'})) {
      push(@row, $r_i2cin->[$row]{'::busy'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_i2cin->[$row]{'::init'})) {
      push(@row, $r_i2cin->[$row]{'::init'});
    }
    else {
      push(@row,"");
    }
    if(exists($r_i2cin->[$row]{'::rec'})) {
      push(@row, $r_i2cin->[$row]{'::rec'});
    }
    else {
      push(@row,"");
    }

    return(@row);
}

sub get_dyn_I2CRow($) {

    my $row = shift;
    my $num_dyn_cols = $EH{'i2c'}{'cols'} + 1;
    my @row = ();

    for(my $i=$num_dyn_cols; $i >= 0; $i--) {
	if($i == 0 && exists($r_i2cin->[$row]{'::b'})) {
	    push(@row, $r_i2cin->[$row]{'::b'});
	}
	elsif($i > 0 && exists($r_i2cin->[$row]{'::b:' . $i})) {
	    push(@row, $r_i2cin->[$row]{'::b:' . $i});
	}
	else {
	    push(@row, "");
	}
    }

    return(@row);
}

sub setI2CValue($$$) {

    my $data = shift;
    my $row = shift;
    my $column = shift;

    if(!defined($column)) {
      $column = "";
    }
    if(!defined($data)) {
      $data = "";
    }

    if(exists($r_i2cin->[$row]{$column})) {
      $r_i2cin->[$row]{$column} = $data;
    }
    else {
      print "mui error: attemp to set column: $column in row: $row, which does not exist!\n";
    }
}

1;

__END__
