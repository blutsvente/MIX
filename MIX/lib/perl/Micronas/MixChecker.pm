# -*- perl -*---------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# |
# |   Copyright Micronas GmbH, Inc. 2002. 
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
# | Project:    Micronas - MIX / Checker
# | Modules:    $RCSfile: MixChecker.pm,v $
# | Revision:   $Revision: 1.7 $
# | Author:     $Author: wig $
# | Date:       $Date: 2005/01/26 14:01:41 $
# |
# | Copyright Micronas GmbH, 2003
# | 
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/Micronas/MixChecker.pm,v 1.7 2005/01/26 14:01:41 wig Exp $                                                         |
# +-----------------------------------------------------------------------+
#
# The functions here provide the checking capabilites for the MIX project.
# Accepts the intermediate (aka. final connection and hierachy description)
# and check if everything against your company design guide lines
# Through plug-ins you can add checks at will
#
# +-----------------------------------------------------------------------+
# |
# | Changes:
# | $Log: MixChecker.pm,v $
# | Revision 1.7  2005/01/26 14:01:41  wig
# | changed %OPEN% and -autoquote for cvs output
# |
# | Revision 1.6  2004/04/14 11:08:32  wig
# | minor code clearing
# |
# | Revision 1.5  2003/11/27 09:08:56  abauer
# | *** empty log message ***
# |
# | Revision 1.4  2003/10/13 09:03:10  wig
# | Fixed misc. requests and bugs:
# | - do not wire open signals
# | - do not recreate ports alredy partially connected
# | - ExCEL cells kept unter 1024 characters, will be split if needed
# | ...
# |
# | Revision 1.3  2003/04/28 06:40:37  wig
# | Added %OPEN% (to allow ports without connection, use VHDL open keyword)
# | Started parseIO (not operational, would be a branch instead)
# | Fixed nreset2 issue (20030424a bug)
# |
# | Revision 1.2  2003/04/01 14:27:59  wig
# | Added IN/OUT Top Port Generation
# |
# | Revision 1.1  2003/02/25 08:06:52  wig
# | Checks are located here.
# |
# |
# +-----------------------------------------------------------------------+
package  Micronas::MixChecker;

require Exporter;

  @ISA = qw(Exporter);
  @EXPORT = qw(
    mix_check_case

    );            # symbols to export by default
  @EXPORT_OK = qw(
    );

our $VERSION = '0.01'; # TODO: use the RCS info

use strict;
# use vars qw();

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
use Log::Agent::Priorities qw(:LEVELS);
use Tree::DAG_Node; # tree base class

use Micronas::MixUtils qw( mix_store db2array %EH replace_mac);
use Micronas::MixUtils::IO;
use Micronas::MixParser qw( %hierdb %conndb );


#
# Prototypes
#
sub mix_check_case($$);
sub mix_check_wiring($$);

# Internal variable
my %mix_check_list = ();

#
# RCS Id, to be put into output templates
#
my $thisid		=	'$Id: MixChecker.pm,v 1.7 2005/01/26 14:01:41 wig Exp $';
my $thisrcsfile	=	'$RCSfile: MixChecker.pm,v $';
my $thisrevision   =      '$Revision: 1.7 $';

$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?

#
# Start checks
#

####################################################################
## mix_check_case
## if configuration says so, make everything lower or upper case!
## Or just inform about possible conflicts.
####################################################################

=head2

mix_check_case () {

Check if cases match. Depending on the value of the configuration value
<I check.name.$type> do the following:

=over 4

=item no

Do nothing. Keep case as is.

=item lc,check

Just check if everything is written in lower case. Report possible conflicts.
Write at INFO level for objects with bad cases, but without conflicts.
Write at WARNING level if a real case conflict is detected.

=item lc,force

Change all objects to lower case. Possible conflicts will get reported.
Conflicts will be resolved by brute force.


=back

You can add a "f" before uc or lc to imply that the first character will be in a
different case (t.b.d).

=cut

sub mix_check_case ($$) {
    my $type = shift;
    my $name = shift;

    unless( defined( $type ) ) {
        logwarn( "WARNING: mix_check_name called without appropriate type definition!" );
        return '';
    }

    unless( defined( $name ) ) {
        logwarn( "WARNING: mix_check_name called without appropriate name definition!" );
        return $name;
    }

    # mix internals ....
    #TODO: these have to be all uppercase!!
    if ( $name =~ m,^\s*(__|%)(.*)(__|%)$,o ) {
        if ( uc( $1 ) ne $1 ) {
            logtrc( "INFO:4", "Info: mix_check_name internal macro $1 not all upper case!" );
        }
        return $name;
    }
    #!wig20031008: adding macro replacement ...
    if ( $name =~ m,%, ) { # Has a %, maybe can be macro parsed ...
        $name = replace_mac( $name, $EH{'macro'} )
    }
        
    if ( $type eq "inst" and $name =~ m,^\s*W_NO_(PARENT|ENTITY|CONF),o ) {
        return $name;
    }
    
    my $check = $EH{'check'}{'name'}{$type};
    unless( exists( $mix_check_list{$type} ) ) {
        $mix_check_list{$type} = {};
    }
    my $list = $mix_check_list{$type}; # Reference to this type's list of names

    #
    # TODO: save all variants of spelling in mix_check_list?
    #
    
    if( $check ) {
        if ( $check =~ m,lc,o ) { # Get everything in lowercase ...
            if ( exists( $list->{ lc( $name ) } ) ) {
                if ( $list->{ lc( $name ) } ne $name ) { # Potential problem found ...
                    if ( $check =~ m,check,o ) {
                        logwarn( "WARNING: Got new element $name conflicting with $list->{lc($name)}!" );
                        $EH{'sum'}{'checkwarn'}++;
                    } elsif( $check =~ m,force,o ) {
                        logwarn( "WARNING: Forcing new element $name to lower case " . lc($name) . "!" );
                        $name = lc( $name );
                        $EH{'sum'}{'checkforce'}++;
                    }
                    # else ignore silentely ....
                }
                # else "have seen the same before, no issue"
            } else {
                if( $name ne lc( $name ) ) { 
                    if ( $check =~ m,force,o ) {
                        logwarn( "INFO: Forcing new $type element $name to lower case " . lc($name) . "!" );
                       $EH{'sum'}{'checkforce'}++;
                        $name = lc( $name );
                    } elsif ( $check =~ m,check,o ) {
                        logwarn( "INFO: Not all lowercase in new $type element $name!" );
                    }
                } # else { #no 'force to lc' or name is lc already.
                # }
                $list->{ lc( $name ) } = $name;
            }
        }
    }

    return $name;

}

####################################################################
## mix_check_wiring
## Micronas specific: see if _n signals are connected to ports not _n!
####################################################################

=head2

mix_check_wiring () {

Check is signals ending with _n are connected to non-_n ports!
If so, print a warning. This is controlled by a global configuration value.
More wiring sanity checks can be added.

=over 4

=item t.b.d.

Needs more options.


=back

Start this checker very late (after names have been resolved).
It might run into problems if there are still macros in the descriptions.

=cut

sub mix_check_wiring ($$) {

    my $conn_r = shift;

    for my $s ( keys( %$conn_r ) ) {
        # signal internal name -> $s
        # signal "real" name -> $conn_r->{$s}{'::name'}

        # 1. if signal is low active ( _n ) -> check all connected ports!
        if ( $s =~ m/_n$/io ) {
            check_n_ports( $s, $conn_r->{$s} );
        }
    }
}

sub check_n_ports ($$) {
    my $s = shift;
    my $s_r = shift;

    my $name = $s_r->{'::name'};
    if ( $name !~ m/_n$/io ) {
        logwarn( "WARNING: signal internal name $s level mismatch real name $name" );
        $EH{'sum'}{'checkconn'}++;
    }

    for my $p ( @{$s_r->{'::in'}}, @{$s_r->{'::out'}} ) {
        my $port = $p->{'port'};
        if ( $port !~ m/_n$/io ) {
            logwarn( "WARNING: signal $s connection mismatch for port $port, instance ".
                   $p->{'inst'} );
            $EH{'sum'}{'checkconn'}++;
        }
    }
}

1;

#!End
