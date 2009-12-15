# -*- perl -*---------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright 2002/2007 Trident Microsystems (Europe) GmbH, Germany
# |                                                                       |
# |                                                                       |
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# | Project:    Micronas - MIX                                            |
# | Modules:    $RCSfile: Base.pm,v $                                  |
# | Revision:   $Revision: 1.3 $                                         |
# | Author:     $Author: lutscher $                                            |
# | Date:       $Date: 2009/12/14 10:58:18 $                              |
# |                                                                       | 
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# |
# | Changes:
# | $Log: Base.pm,v $
# | Revision 1.3  2009/12/14 10:58:18  lutscher
# | changed copyright
# |
# | Revision 1.2  2007/03/08 09:24:31  wig
# | Minor update for Base.pm (renamed subs).
# |
# | Revision 1.1  2007/03/01 16:28:38  wig
# | Implemented emulation mux insertion
# |
# |
# +-----------------------------------------------------------------------+
package  Micronas::MixEDA::Base;
require Exporter;

@ISA=qw(Exporter);

@EXPORT  = qw();

@EXPORT_OK = qw();

### ID block
our $VERSION = '$Revision: 1.3 $ $Date: 2009/12/14 10:58:18 $ wilfried.gaensheimer@gaensheimer.de'; # VCS Id
$VERSION =~ s,\$,,go;
( our $VERSION_NR = $VERSION ) =~ s/(LastChanged)?(Revision|Date):\s+//g;
$VERSION_NR =~ s/\s+.*//;
our $ID = '$Id: Base.pm,v 1.3 2009/12/14 10:58:18 lutscher Exp $'; # VCS Id
$ID =~ s,\$,,go;

use strict;
use Cwd;
use Log::Log4perl qw(get_logger);
use FileHandle;
use File::Basename;
use Micronas::MixUtils qw( $eh );

my $logger = get_logger('MIX::MixEDA::Base');

#
# RCS Id, to be put into output templates
#
my $thisid          =      '$Id: Base.pm,v 1.3 2009/12/14 10:58:18 lutscher Exp $'; 
my $thisrcsfile	    =      '$RCSfile: Base.pm,v $';
my $thisrevision    =      '$Revision: 1.3 $';  

$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,;

# my $ehstore; # Reference to $eh

#
#  no special configuration for this module
#
sub new {
	my $this = shift;
	my ( $class ) = ref( $this ) || $this;
	my %params = ();
	if ( ref( $_[0] ) eq 'HASH' ) {
		%params = %{$_[0]};
	} else {
		%params = @_;
	}
	# data member default values
	my $ref_member  = {};
	
	# init data members w/ parameters from constructor call
	foreach (keys %params) {
		$ref_member->{$_} = $params{$_};
	};


	bless $ref_member, $class;
	
};

####################################################################
## hdl_isinteger
##  check if input is integer in HDL allowed syntax
####################################################################

=head2

hdl_isinteger ($$$) {

Finds out if input is valid integer. Print warning if not.

First try for integer:
	[W['B]]NN_NNN
	B := b o h d
	W := NN
	NN_NNN := depends on B

Input:
	instancename (instantiated component)
	generic (name of the generic)
	value (parameter value)

Return:
	1 if problem!
	
=cut

sub hdl_isinteger ($$$;$$) {
	my $self 	= shift;
	my $inst	= shift;
    my $entyref	= shift;
    my $generic = shift;
    my $val 	= shift;
    my $lang 	= shift || $eh->get( 'macro.%LANGUAGE%' );

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
    if ( $number ne '' ) {
        unless ( $number =~ m/^$set+$/ ) {
            $flag = 1;
        }
    } else {
        $flag = 1;
    }

	# TODO : Handle this at upper level    
    if ( $flag ) {
    	#!wig20051109: Check if type is string -> allow anything
    	if ( defined( $entyref ) and
    		  exists( $entyref->{'type'} ) ) {
    		 if ( $entyref->{'type'} =~ m/string/io ) {
    		 	$flag = 0;
    		 }
    	}
    	if ( $flag ) {
        	$logger->warn('__W_HDL_ISINTEGER', "\tApplied non-integer parameter $val for generic $generic at instance $inst!" );
    	}
    }
    return $flag;
} # End of hdl_isinteger

####################################################################
##  hdl_isreal
##  check if input is a real written in HDL
####################################################################

=head2

hdl_isreal ($$$$) {

Finds out if input is a valid real. Print warning if not.

First try for reals in form:
	+-N.N
	+-N.NeE
	
	and then all valid integers!
    (_mix_wr_isinteger)

Input:
   instancename (instantiated component)
   generic (name of the generic)
   value (parameter value)

Return:
	1 if problem!
	
=cut

sub hdl_isreal ($$$$) {
	my $self 	= shift;
	my $inst	= shift;
    my $entyref	= shift;
    my $generic = shift;
    my $val 	= shift;
    my $lang 	= shift || $eh->get( 'macro.%LANGUAGE%' );

	my $flag = 1;
	if ( $val =~ m/\s*[+-]?[\d.]+([eE][+-]?\d+)?\s*$/o ) {
		# o.k.
		$flag = 0;		
	}
    
    # Try if this is an integer
    if ( $flag ) {
    	$flag = $self->hdl_isinteger( $inst, $entyref, $generic, $val, $lang );
    }
    
    if ( $flag ) {
    	#!wig20051109: Check if type is string -> allow anything
    	if ( defined( $entyref ) and
    		  exists( $entyref->{'type'} ) ) {
    		 if ( $entyref->{'type'} =~ m/string/io ) {
    		 	$flag = 0;
    		 }
    	}
    	if ( $flag ) {
        	$logger->warn('__W_HDL_ISREAL', "\tApplied non-real parameter $val for generic $generic at instance $inst!" );
    	}
    }
    return $flag;
} # End of hdl_isreal

############################### sub libversion ######################
#
# Print out the version information (mostly used in testing)
#
sub libversion ($;$) {
	my $self = shift;
	my $variable = shift || 'VERSION_NR';
	
	if ( $variable eq 'VERSION' ) {
	        return $VERSION;
	} elsif ( $variable eq 'VERSION_NR' ) {
	        return $VERSION_NR;
	} elsif ( $variable eq 'ID' ) {
	        return $ID;
	} else {
	        return "ERROR: Unknown version requested: $variable";
	}
	return $variable;
} # End of libversion


###############################################################################
# Report lib version:
if ( scalar( @ARGV ) == 1 and $ARGV[0] =~ /-(lib)?version/ ) {
  print( '#' . $ID . "\n" );
}

# Return true in any case!
1;
1;

#!End
