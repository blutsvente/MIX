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
# | Id           : $Id: mix_embedded.pl,v 1.3 2004/07/08 11:21:49 abauer Exp $     |
# | Name         : $Name:  $                                   |
# | Description  : $Description: simple wrapper script for embedding MIX $|
# | Parameters   : -                                                      | 
# | Version      : $Revision: 1.3 $                                       |
# | Mod.Date     : $Date: 2004/07/08 11:21:49 $                           |
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

use Micronas::MixUtils qw( mix_init %EH mix_getopt_header);
use Micronas::MixUtils::IO qw(init_ole mix_utils_open_input write_sum);
use Micronas::MixParser qw( %hierdb %conndb parse_conn_macros parse_conn_gen parse_hier_init parse_conn_init apply_conn_gen apply_hier_gen apply_conn_macros purge_relicts parse_mac add_portsig add_sign2hier);
use Micronas::MixIOParser;
use Micronas::MixI2CParser;
use Micronas::MixWriter;


#******************************************************************************
# Global Variables
#******************************************************************************

$::VERSION = '$Revision: 1.3 $'; # RCS Id
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


my ($r_connin, $r_ioin, $r_i2cin);


sub readSpreadsheet(@) {

    my $input = shift;

    my $r_hierin;
    my $r_connmacros;
    my( $r_conngen, $r_hiergen);

     #Fetches HIER, CONN, IO and I2C sheet(s)
    ( $r_connin, $r_hierin, $r_ioin, $r_i2cin) = mix_utils_open_input( $input);

    # parse Data
    $r_connmacros = parse_conn_macros( $r_connin);
    $r_conngen = parse_conn_gen( $r_connin);
    $r_hiergen = parse_conn_gen( $r_hierin);

    parse_hier_init( $r_hierin);
    parse_conn_init( $r_connin);
    parse_io_init( $r_ioin);
    parse_i2c_init( $r_i2cin);

    # Parse connectivity and convert to internal format
    apply_conn_macros( $r_connin, $r_connmacros);
    apply_hier_gen( $r_hiergen);
    apply_conn_gen( $r_conngen);

    # Get rid of some "artefacts"
    purge_relicts();

    # Replace %MAC% before output
    #    parse_mac();

    # Add conections and ports if needed (hierachy traversal)
    # Add connections to TOPLEVEL for connections without ::in or ::out
    # Replace OPEN and %OPEN%
    #    add_portsig();

    # Replace %MAC% before output
    #!do before signal expansion ..... parse_mac();

    # Get rid of some "artefacts", again (add_portsig and add_sign2hier might have
    # added something ....
    #    purge_relicts();

    # Add a list of all signals for each instance
    #    add_sign2hier();
}

#readSpreadsheet("/home/abauer/src/MIX/test/sxc_input/a_clk_i2c.sxc");

sub getIntFromEH($) {

    my @keys = shift;

}


sub getStringFromEH($) {

    my @keys = shift;

    return ;
}


#### Functions for creating a Hierarchical Tree
{  # keep the following stuff locally


    my $location;    # reference to location in Hash;
    my $stepInto;    # step down or don't


    # set location to TOPLEVEL
    sub initTreeWalk()
    {
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

	# step one level down if this Element got childs
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


sub getNumConnRows() {
    return (scalar $#{$r_connin});
}


sub getConnRow($) {

    my $row = shift;

    my @row = ();
		       
    push(@row, $r_connin->[$row]{'::ign'});
    push(@row, $r_connin->[$row]{'::gen'});
    push(@row, $r_connin->[$row]{'::bundle'});
    push(@row, $r_connin->[$row]{'::class'});
    push(@row, $r_connin->[$row]{'::clock'});
    push(@row, $r_connin->[$row]{'::type'});
    push(@row, $r_connin->[$row]{'::high'});
    push(@row, $r_connin->[$row]{'::low'});
    push(@row, $r_connin->[$row]{'::mode'});
    push(@row, $r_connin->[$row]{'::name'});
    push(@row, $r_connin->[$row]{'::out'});
    push(@row, $r_connin->[$row]{'::in'});
    push(@row, $r_connin->[$row]{'::descr'});
    push(@row, $r_connin->[$row]{'::comment'});

    return(@row);
}


sub getNumIOPadRows() {
    return (scalar $#{$r_ioin});
}


sub getIOPadRow($) {

    my $row = shift;

    my @row = ();
		       
    push(@row, $r_ioin->[$row]{'::ign'});
    push(@row, $r_ioin->[$row]{'::comment'});
    push(@row, $r_ioin->[$row]{'::class'});
    push(@row, $r_ioin->[$row]{'::ispin'});
    push(@row, $r_ioin->[$row]{'::pin'});
    push(@row, $r_ioin->[$row]{'::pad'});
    push(@row, $r_ioin->[$row]{'::type'});
    push(@row, $r_ioin->[$row]{'::iocell'});
    push(@row, $r_ioin->[$row]{'::port'});
    push(@row, $r_ioin->[$row]{'::name'});
    push(@row, $r_ioin->[$row]{'::muxopt'}); # TODO: get all n-th muxopt

    return(@row);
}


sub getNumI2CRows() {
    return (scalar $#{$r_i2cin});
}


sub getI2CRow($) {

    my $row = shift;

    my @row = ();
		       
    push(@row, $r_i2cin->[$row]{'::ign'});
    push(@row, $r_i2cin->[$row]{'::comment'});
    push(@row, $r_i2cin->[$row]{'::variants'});
    push(@row, $r_i2cin->[$row]{'::dev'});
    push(@row, $r_i2cin->[$row]{'::sub'});
    push(@row, $r_i2cin->[$row]{'::interface'});
    push(@row, $r_i2cin->[$row]{'::block'});
    push(@row, $r_i2cin->[$row]{'::dir'});
    push(@row, $r_i2cin->[$row]{'::spec'});
    push(@row, $r_i2cin->[$row]{'::clock'});
    push(@row, $r_i2cin->[$row]{'::reset'});
    push(@row, $r_i2cin->[$row]{'::busy'});
    push(@row, $r_i2cin->[$row]{'::init'});
    push(@row, $r_i2cin->[$row]{'::rec'});
    push(@row, $r_i2cin->[$row]{'::b'}); # TODO: get all n-th b

    return(@row);
}


1;

__END__
