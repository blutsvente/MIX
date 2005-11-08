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
# | Modules:    $RCSfile: InComments.pm,v $                                      |
# | Revision:   $Revision: 1.4 $                                          |
# | Author:     $Author: wig $                                            |
# | Date:       $Date: 2005/11/08 08:06:55 $                              |
# |                                                                       | 
# | Copyright Micronas GmbH, 2005                                         |
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# | Changes:                                                              |
# | $Log: InComments.pm,v $
# | Revision 1.4  2005/11/08 08:06:55  wig
# | Added some documentation and example (register shell)
# |
# | Revision 1.3  2005/11/04 10:44:47  wig
# | Adding ::incom (keep CONN sheet comments) and improce portlist report format
# |
# | Revision 1.2  2005/10/18 09:34:37  wig
# | Changes required for vgch_join.pl support (mainly to MixUtils)
# |
# | Revision 1.1  2005/10/13 09:09:46  wig
# | Added intermediate CONN sheet split
# |
# |                                                                       |
# +-----------------------------------------------------------------------+
package  Micronas::MixUtils::InComments;
require Exporter;

@ISA=qw(Exporter);

@EXPORT  = qw();

@EXPORT_OK = qw();

our $VERSION = '1.0';

use strict;
# use vars qw( $ex ); # Gets OLE object

use Cwd;
use File::Basename;
use Log::Agent;
use FileHandle;

#
# RCS Id, to be put into output templates
#
my $thisid          =      '$Id: InComments.pm,v 1.4 2005/11/08 08:06:55 wig Exp $';#'  
my $thisrcsfile	    =      '$RCSfile: InComments.pm,v $'; #'
my $thisrevision    =      '$Revision: 1.4 $'; #'  

$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?

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
		'text'	=>	'',
		'type'	=>	'',
		'relation' => '',
		'pre'	=>	'',
		'post'	=>	'',
	};
	
	# init data members w/ parameters from constructor call
	foreach (keys %params) {
		$ref_member->{$_} = $params{$_};
	};

	bless $ref_member, $class;
};

=head 4 print() prints the text string

	print() does not take arguments

=cut

sub print {
	my $this = shift;
	
	return $this->{'text'};
	
}

=head 4 mode returns the pre/post mode valid for this comment

	mode() returns the relation of this comment to the calling object

=cut

sub mode {
	my $this = shift;
	
	if ( $this->{'relation'} ) {
		return $this->{'relation'};
	} elsif ( $this->{'pre'} ) {
		return $this->{'pre'};
	} elsif ( $this->{'post'} ) {
		return $this->{'post'};
	}
	
	return undef();

}
	
1;

#!End