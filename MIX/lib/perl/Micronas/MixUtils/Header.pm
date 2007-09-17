# -*- perl -*---------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright Micronas GmbH, 2007.                                      |
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
# | Modules:    $RCSfile: Header.pm,v $                                   |
# | Revision:   $Revision: 1.1 $                                         |
# | Author:     $Author: wig $                                            |
# | Date:       $Date: 2007/09/17 12:40:13 $                              |
# |                                                                       | 
# | Library dealing with the ::MIX style header lines in sheets           |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# |
# | Changes:
# | $Log: 
# |
# +-----------------------------------------------------------------------+
package  Micronas::MixUtils::Header;
# require Exporter;
#
# @ISA=qw(Exporter);

@EXPORT  = qw();

@EXPORT_OK = qw();

our $VERSION = '1.0';

use strict;
# use vars qw( $ex ); # Gets OLE object

use Cwd;
use File::Basename;
use Log::Log4perl qw(get_logger);
use FileHandle;

my $logger = get_logger('MIX::MixUtils::Header');

#
# RCS Id, to be put into output templates
#
my $thisid          =      '$Id: Header.pm,v 1.1 2007/09/17 12:40:13 wig Exp $'; 
my $thisrcsfile	    =      '$RCSfile: Header.pm,v $';
my $thisrevision    =      '$Revision: 1.1 $';  

$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?

=head1 Micronas::MixUtils::Header

package for MIX/Registermaster Header handling

One MIX header object per opened and written script
these objects share one format for each type of sheet
(e.g. CONN, HIER, JOIN, DEFAULT, ...)
The format description links to the $eh->get('<TYPE>.<.*>) data
structure.

public functions:
	->is_inherit()  1/0
	->is_multiple() 1/0
	->is_required() 1/0
	->get_default() -> return default value
	->print_order
	
	->add('::col', <PROP>)
		add a column
		<PROP> is either a string containing keys, a hashref ...
			keys: [no]inherit,[no]multiple,[no]required,default=text
			hashref inherit =>
	->delete('::col')
	->sorted(<KEY>)
		return order of columns when sorted by KEY
 		Possible sort orders: built-in,input,alpha

Interface:

- new  create a new object

=cut

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

1;
#!End
