# -*- perl -*---------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright Micronas GmbH, Inc. 2002/2005.                            |
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
# | Project:    Micronas - MIX                                            |
# | Modules:    $RCSfile: ImportVerilogInclude.pm,v $                     |
# | Revision:   $Revision: 1.1 $                                          |
# | Author:     $Author: wig $                                            |
# | Date:       $Date: 2006/11/15 09:54:28 $                              |
# |                                                                       | 
# | Copyright Micronas GmbH, 2005/2006                                    |
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# | Changes:                                                              |
# # $Log: ImportVerilogInclude.pm,v $
# # Revision 1.1  2006/11/15 09:54:28  wig
# # Added ImportVerilogInclude module: read defines and replace in input data.
# #
# |                                                                       |
# +-----------------------------------------------------------------------+
package  Micronas::MixUtils::ImportVerilogInclude;

# @ISA=qw();
#
# @EXPORT  = qw();
# 
# @EXPORT_OK = qw();
#
our $VERSION = '1.0';

use strict;
# use vars qw( $ex ); # Gets OLE object

use Cwd;
use File::Basename;
use Log::Agent;
use FileHandle;
use Log::Log4perl qw(get_logger);

#
# RCS Id, to be put into output templates
#
my $thisid          =      '$Id: ImportVerilogInclude.pm,v 1.1 2006/11/15 09:54:28 wig Exp $';#'  
my $thisrcsfile	    =      '$RCSfile: ImportVerilogInclude.pm,v $'; #'
my $thisrevision    =      '$Revision: 1.1 $'; #'  

$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?

my $logger = get_logger( 'MIX::MixUtils::ImportVerilogInclude' );
#
#  storage for comments (with number before/after)
#	text	-> the text making up the comment (usually the whole line, joined)
#	type	-> conn|hier|...
#	pre		-> number of predecessor
#	post	-> successor line
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
	my $ref_member  = {
		'defines'	=>	'',
		'files'		=>  '',
	};
	
	# init data members w/ parameters from constructor call
	foreach (keys %params) {
		$ref_member->{$_} = $params{$_};
	};

	bless $ref_member, $class;
};

=head 4 import() import a list of verilog include files

	import verilog defines from file

=cut

sub import {
	my $self = shift;
	my $fref = shift;

	my @files = ();
	if ( ref( $fref ) eq 'ARRAY' ) {
		@files = @$fref;
	} else {
		$files[0] = $fref;
		push( @files, @_ );
	}
	
	# Iterate over all files:
	for my $f ( @files ) {
		chomp $f;
		# Split comma seperated
		for my $ff ( split( /,/, $f ) ) {
			if ( -r $ff ) {
				my $fh = new FileHandle;
				if ( $fh->open( "< $ff" ) ) {
					# Read in line by line ...
					$self->{'files'}{$ff} = 1;
					while( <$fh> ) {
						if ( m/^\s*`define \s+ (\w+) \s+ (.+)/x ) {
							$self->{'defines'}{$1} = $2;
						}
					}
				} else {
					$logger->error('__E_VINCLUDE_READ',
						"\tCannot open verilog include file $ff: " . $! );
				}
			} else {
				$logger->error('__E_VINCLUDE_READ',
					"\tCannot read verilog include file $ff!" );
			}
		}	 
	}	
} # End of import

=head 4 apply() find `<key> and replace by defined value

	apply()  Replace `foo if set

=cut

sub apply($$) {
	my $self = shift;
	my $data = shift;
	
	# Is $data a ref -> resolve
	if ( ref( $data ) eq 'ARRAY' ) {
		for my $d ( @$data ) {
			$self->apply( $d );
		}
	} elsif ( ref( $data ) eq 'HASH' ) {
		for my $d ( keys( %$data ) ) {
			$self->apply( $data->{$d} );
		}
	} elsif ( ref( $data ) ) {
		$logger->error('__E_VINCLUDE_APPLY', "\tCannot handle data type " .
			ref( $data ) . "!");
	} else {
		# Try to find `foo and replace it by the defines value
		if ( $data =~ m/`/ ) {
			while ( $data =~ m/`(\w+)/g ) {
				if ( exists $self->{'defines'}{$1} ) {
					my $define  = $1;
					my $replace = $self->{'defines'}{$1};
					$data =~ s/`$define/$replace/g;
				} else {
					$logger->warn( '__W_VINCLUDE_UKDEF',
						"\tunknown verilog define `$1, will not be resolved" );
				}
			}
		}
	}
	return;
} # End of apply

#
# Print out define
#
sub print ($$) {
	my $self = shift;
	my $define = shift;
	
	if ( exists $self->{'defines'}{$define} ) {
		print "define `$define " . $self->{'defines'}{$define} . "\n";
	} else {
		print "// define `$define <UK>\n";
	
	}
}

#
# Print out all define
#
sub printall ($) {
	my $self = shift;
	for my $define ( keys %{$self->{'defines'}} ) {
		print "define `$define " . $self->{'defines'}{$define} . "\n";	
	}
}

#
# Get value for define
#
sub get ($$) {
	my $self = shift;
	my $define = shift;
	
	if ( exists $self->{'defines'}{$define} ) {
		return $self->{'defines'}{$define};
	}
	return undef();
} # End of get

#
# getall
#
sub getall ($) {
	my $self = shift;

	return $self->{'defines'};

} # End of getall

#
# Convert defines to array
#
sub toconf ($) {
	my $self = shift;

	my @defines = ();
	
	my $defines = $self->getall();
	for my $d ( keys %$defines ) {
		push( @defines, [ 'MIXVINC', $d, $defines->{$d} ]);
	}
} # End of vin2conf
		
1;

#!End