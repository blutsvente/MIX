# -*- perl -*---------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# |
# |   Copyright Micronas GmbH, Inc. 2002/2005. 
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
# | Project:    Micronas - MIX / Report                                   |
# | Modules:    $RCSfile: MixReport.pm,v $                                |
# | Revision:   $Revision: 1.6 $                                               |
# | Author:     $Author: wig $                                                 |
# | Date:       $Date: 2005/10/24 12:10:30 $                                                   |
# |                                                                       |
# | Copyright Micronas GmbH, 2005                                         |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/MixReport.pm,v 1.6 2005/10/24 12:10:30 wig Exp $                                                             |
# +-----------------------------------------------------------------------+
#
# Write reports with details about the hierachy and connectivity of the
# generated nets/entities/....
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# | Changes:                                                              |
# | $Log: MixReport.pm,v $
# | Revision 1.6  2005/10/24 12:10:30  wig
# | added output.language.verilog = ansistyle,2001param
# |
# | Revision 1.5  2005/10/19 08:19:19  wig
# | Extended portlist writer and Mif module
# |
# | Revision 1.4  2005/10/18 15:27:53  wig
# | Primary releaseable vgch_join.pl
# |
# | Revision 1.3  2005/10/18 09:34:37  wig
# | Changes required for vgch_join.pl support (mainly to MixUtils)
# |
# | Revision 1.2  2005/09/29 13:45:02  wig
# | Update with -report
# |
# | Revision 1.1  2005/09/14 14:40:06  wig
# | Startet report module (portlist)
# |                                                                |
# |                                                                       |
# +-----------------------------------------------------------------------+

package Micronas::MixReport;

require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(
	mix_report
); # symbols to export by default

@EXPORT_OK = qw();

our $VERSION = '0.1';
#
# RCS Id, to be put into output templates
#
my $thisid		=	'$Id: MixReport.pm,v 1.6 2005/10/24 12:10:30 wig Exp $';
my $thisrcsfile	=	'$RCSfile: MixReport.pm,v $';
my $thisrevision   =      '$Revision: 1.6 $';

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
# use Data::Dumper;

use Log::Agent;
use Log::Agent::Priorities qw(:LEVELS);
# use Tree::DAG_Node; # tree base class

use Micronas::MixUtils qw(%EH %OPTVAL);
use Micronas::MixUtils::Mif;

#use FindBin qw($Bin);
#use lib "$Bin";
#use lib "$Bin/..";
#use lib "$Bin/lib";

#
# Prototypes
#
sub _mix_report_getport ($$);

#------------------------------------------------------------------------------
# Class members
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Constructor
# returns a hash reference to the data members of this class
# package; does NOT call the subclass constructors.
# Input: 1. device identifier (can be whatever)
#------------------------------------------------------------------------------

sub new {
	my $this = shift;
	my %params = @_;

	# data member default values
	my $ref_member  = {
					   # device => "<no device specified>",
					   # domains => [],
					   # global => \%hglobal  # reference to class data
					  };
	# init data members w/ parameters from constructor call
	foreach (keys %params) {
		$ref_member->{$_} = $params{$_};
	};

	bless $ref_member, $this;
};

#
# Do the reporting if requested ...
#
sub mix_report () {

	return unless ( exists $OPTVAL{'report'} );
	
	my $reports = join( ',', @{$OPTVAL{'report'}} );
	
	# portlist:
	if ( $reports =~ m/\bportlist\b/io ) {
		mix_rep_portlist();
	}
	if ( $reports =~ m/\breglist\b/io ) {
		mix_rep_reglist();
	}

}

#
# Report register list
# 
sub mix_rep_reglist () {
	
	return;

}

#
# Print a list of all I/O signals ....
#
sub mix_rep_portlist () {

	my $mif = new Micronas::MixUtils::Mif(
		'name' => ( $EH{'report'}{'path'} . '/' . "mix_portlist.mif" ),
	);
		
	$mif->template(); # Initialize it

	# If ::external column is set, make a seperate table for external
	my $exttrigger = '';
	my $elist = '';
	if ( $EH{'report'}{'portlist'}{'split'} =~ m/\bexternal(::\w+)?/ ) {
		$exttrigger = "::external";
		if ( defined $1 ) {
			$exttrigger = $1;
		}
		$elist = $mif->start_table(
			{	'Title' => 'External Portlist',
				'TblTag' => 'PortList' }
		);
	}
	
	my $plist = $mif->start_table( 'Portlist' );
	
	#
	# Prepare tablehead data:
	#
	my $headtext = $mif->td(
		{ 'PgfTag' => 'CellHeadingH9',
		  'String' => [
			  qw( Name Width Clock Description Source Destination )
		  ],
		}
	);

	if ( $elist ne '' ) {
		$mif->table_head( $mif->Tr($headtext), $elist );
		$mif->start_body( $elist );
	}
	
	$mif->table_head( $mif->Tr($headtext), $plist );
	$mif->start_body( $plist );
	
	# Iterate over all instances ...
	my $hierdb = \%Micronas::MixParser::hierdb;
	my $conndb = \%Micronas::MixParser::conndb;
	for my $instance ( sort keys( %$hierdb ) ) {
		next if ( $hierdb->{$instance}{'::entity'} eq 'W_NO_ENTITY' );
		next if ( $instance =~ m/^%\w+/ );
		
		my $link = $hierdb->{$instance};
		
		# Create a large table ...
		## Instance name:
		my $line = $mif->td(
			{ 'PgfTag' => 'CellHeadingH9',
			  'Columns' => 6, # Columns Span of all six cells
			  'String'  => "$link->{'::inst'} ($link->{'::entity'})",
			}
		);
		
		$mif->add( $mif->Tr($line), $plist );
		if ( $elist ne '' ) {
			$mif->add( $mif->Tr($line), $elist );
		}
		
		## Signals at that instance
		## TODO : sort order ..
		for my $signal ( sort keys( %{$link->{'::sigbits'}} ) ) {
			# Iterate over all signals ...
			my $signalname = $conndb->{$signal}{'::name'};
			my $connect = $link->{'::sigbits'}{$signal};
			my $high	= $conndb->{$signal}{'::high'};
			my $low		= $conndb->{$signal}{'::low'};
			my $clock	= $conndb->{$signal}{'::clock'};
			my $descr	= $conndb->{$signal}{'::descr'};
			# Check connectivity: in vs. out vs. IO vs ....
			#   Mark if not fully connected with a footnote -> (*)
			
			my $width = _mix_report_width( $high, $low );
			( my $full, my $mode ) = _mix_report_connect( $connect );
			unless ( $full ) {
				$width .= "(*)"; # Not fully connected!
			}
			my $in = _mix_report_getinst( $conndb->{$signal}{'::in'} );
			my $out = _mix_report_getinst( $conndb->{$signal}{'::out'} );
			
			$in = "(NO LOAD)" unless $in;
			$out = "(NO DRIVER)" unless $out;
			#TODO: Remember for later usage and sorting

			# Map signal name to port name:
			my $portname = $signalname;
			if ( $EH{'report'}{'portlist'}{'name'} =~ m/\bport\b/ ) {
				$portname = _mix_report_getport( $signalname, $link );
			}

			# If we split into internal/external list, decide which to take:
			my $tlist = $plist;
			if ( exists $conndb->{$signalname}{$exttrigger}
					and $conndb->{$signalname}{$exttrigger} ne '' ) {
				$tlist = $elist;
			}
			my $line = $mif->td(
				{ 'PgfTag' => 'CellBodyH9',
				  'String' => [
				  	$portname,
				  	$width,
				  	$clock,
				  	$descr,
				  	$out,
				  	$in
				  ]
				} );
			# Is this external?
			$mif->add( $mif->Tr(
					{ 'Text' => $line, 'WithPrev' => 0 }
			), $tlist );
		}
	}
	
	$mif->end_body( $plist );
	$mif->end_table( $plist );
	if ( $elist ne '' ) {
		$mif->end_body( $elist );
		$mif->end_table( $elist);
	}	
	
	$mif->write();
	
	return;

}

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
		logwarn( "__W_MIX_REPORT: Could not map signal " . $signal .
			" to portname for instance " . $link->{'::inst'} );
		$EH{'sum'}{'warnings'}++;
	} elsif ( scalar( @ports ) > 1 ) {
		# More than one port attached :-(
		logwarn( "__W_MIX_REPORT: Multiple ports connected to " . $signal .
			" at instance " . $link->{'::inst'} );
		$EH{'sum'}{'warnings'}++;
		$signal = join( ',', @ports );
	} else {
		$signal = $ports[0];
	}

	return $signal;

} # End ox _mix_report_getport

#
# Get list of connected instances ...
#TODO: Do not print constants and other pseudo instances
sub _mix_report_getinst ($) {
	my $ref = shift;
	
	my $instances = "";
	for my $i ( @$ref ) {
		$instances .= ", " . $i->{'inst'};
	}

	$instances =~ s/^, //;
	
	return $instances;
}

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
	
	if ( ( not defined( $high ) or $high eq "" ) and
		 ( not defined( $low ) or $low eq "" ) ) {
		 # single bit, no vector
		 	$width = "1";
	} elsif ( $low eq "0" ) {
		# $low is "0" -> width is $high 
		$width = $high;
	} elsif ( $low =~ m/^\d+$/o and $high =~ m/^\d+$/o ) {
		$width = $high - $low + 1;
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
	
	my $sfull = "";
	my $smode = "";
	
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
			$sfull = $full; $smode = $mode;
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