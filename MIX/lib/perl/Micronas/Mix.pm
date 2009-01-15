###############################################################################
#  RCSId: $Id: Mix.pm,v 1.4 2009/01/15 14:03:45 lutscher Exp $
###############################################################################
#                                  
#  Related Files :  Mix and Reg packages
#
#  Author(s)     :  Thorsten Lutscher / Wilfried Gaensheimer                                     
#  Email         :  thorsten.lutscher@micronas.com                          
#
#  Project       :  MIX                                                 
#
#  Creation Date :  11.11.2008
#
#  Contents      :  This is meant as a wrapper for all MIX packages; it simplifies
#                   writing of software that uses MIX; example usage: mix_1.pl or
#                   gen_bmu.pl (from project mic32)
#
#  Public variables:
#  %OPTVAL
#  $eh
#  Public functions:
#  sub read_input 
#  sub parse_macros 
#  sub parse_hier 
#  sub parse_conn 
#  sub parse_io 
#  sub parse_registers 
#  sub gen_modules 
#  sub write_output 
#  sub display 
#
###############################################################################
#                               Copyright
###############################################################################
#
#       Copyright (C) 2008 Micronas GmbH, Munich, Germany 
#
#     All rights reserved. Reproduction in whole or part is prohibited
#          without the written permission of the copyright owner.
#
###############################################################################
#                                History
###############################################################################
#
#  $Log: Mix.pm,v $
#  Revision 1.4  2009/01/15 14:03:45  lutscher
#  moved view generation out of parse_register_master
#
#  Revision 1.3  2009/01/15 12:04:25  lutscher
#  fixed typo
#
#  Revision 1.2  2008/12/10 13:08:35  lutscher
#  no changes
#
#  Revision 1.1  2008/11/11 15:44:31  lutscher
#  initial release
#
#  
###############################################################################

package Micronas::Mix; # the class-name

require Exporter;
@ISA=qw(Exporter);
@EXPORT  = qw(
              $eh
              %OPTVAL
              read_input 
              parse_macros 
              parse_hier 
              parse_conn 
              parse_io 
              parse_registers 
              gen_modules 
              write_output 
              display 
             );

#------------------------------------------------------------------------------
# Used packages
#------------------------------------------------------------------------------
use strict;
use Cwd;
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use lib "$Bin/lib";
use lib "$Bin/lib/perl";
use lib getcwd() . "/lib/perl";
use lib getcwd() . "/../lib/perl";
use Getopt::Long qw(GetOptions);
use Data::Dumper;
# use Pod::Text;
use Log::Log4perl qw(:easy get_logger :levels);

# our own modules
use Micronas::MixUtils qw( $eh %OPTVAL mix_init mix_getopt_header write_sum );
use Micronas::MixUtils::IO qw( mix_utils_open_input );
use Micronas::MixUtils::Globals;
use Micronas::MixParser;
use Micronas::MixIOParser;
use Micronas::Reg qw ( parse_register_master );
use Micronas::MixWriter;
use Micronas::MixReport;

#------------------------------------------------------------------------------
# Class members
#------------------------------------------------------------------------------
# define static members here

# version of this package, extracted from RCS macros
our($VERSION) = '$Revision: 1.4 $ ';  #'
$VERSION =~ s/\$//g;
$VERSION =~ s/Revision\: //;

our($logger);

#------------------------------------------------------------------------------
# Constructor
# returns a hash reference to the data members of this class
# package; does NOT call the subclass constructors.
# Input: hash for setting member variables (optional)
#------------------------------------------------------------------------------
sub new {
	my $this = shift;
	my %params = @_;

	# data member default values
	my $ref_member  = {                      
                       # debug switch
                       'debug' => 0,
                       
                       # Version of class package
                       'version' => $VERSION,

                       # options
                       'options' => [], # ref to list

                       #
                       # the fields below will be populated by our object methods
                       #

                       # connectivity input
                       'connin' => [], # ref to list                       
                       # hierarchy input
                       'hierin' => [], # ref to list
                       # IO spec input
                       'ioin' => [], # ref to list
                       # IP-XACT register spec. input
                       'xmlin' => [], # ref to list
                       # register-master input
                       'regin' => [], # ref to list
                       # resulting register space object
                       'reg' => undef  # ref to Micronas::Reg object
                      };

	# init data members w/ parameters from constructor call
	foreach (keys %params) {
		$ref_member->{$_} = $params{$_};
	};
   
    _init($ref_member->{options});

	bless $ref_member, $this;
};

#------------------------------------------------------------------------------
# Methods
# First parameter passed to method is implicit and is the object reference 
# ($this) if the method # is called in <object> -> <method>() fashion.
#------------------------------------------------------------------------------

# init mix, get commandline parameters; takes list of possible options as argument
sub _init {
    my ($options) = @_;
    # Global access to logging and environment
    #
    my ($is_init) = 0;
    if ( -r $FindBin::Bin . '/mixlog.conf' ) {
        Log::Log4perl->init( $FindBin::Bin . '/mixlog.conf' );
        $is_init = 1;
    }
    # Local overload:
    if ( -r getcwd() . '/mixlog.conf' ) {
        Log::Log4perl->init( getcwd() . '/mixlog.conf' );
        $is_init = 1;
    }
    $logger = get_logger('MIX'); # Start with MIX namespace
    if (!$is_init) {
        $logger->warn("__W_MIX\t","could not find a \'mixlog.conf\' file");
    };

    #
    # Step 0: Init the global $eh (imported into this namespace)
    #
    mix_init();
    
    #
    # Step 1: Read arguments, option processing,
    # parse command line, print banner, print help (if requested),
    # set quiet, verbose
    #

    mix_getopt_header(@${options}); # @{$this->{options}});

    # remaining arguments should be input files
    if ( $#ARGV < 0 ) { # Need at least one file
        $logger->fatal('__F_MISSARG', 'No input file specified!');
        exit 1;
    };
};

#
# Step 2: Open input files one by one and retrieve the tables
# Do a first simple conversion from Excel arrays into array of hashes
#
sub read_input {
    my $this = shift;
    ($this->{connin}, $this->{hierin}, $this->{ioin}, $this->{regin}, $this->{xmlin}) =  mix_utils_open_input( @ARGV );
};

#
# Step 3: Retrieve generator statements (generators, macros) from the input data
# The information will be removed from the input data fields (masking ::comment field)
# 
sub parse_macros {
    my $this = shift;
    $this->{connmacros} = parse_conn_macros($this->{connin});
    $this->{conngen}    = parse_conn_gen($this->{connin});
    $this->{hiergen}    = parse_conn_gen($this->{hierin});
};

#
# Step 4: Initialize Hierachy DB and convert to internal format
#
sub parse_hier {
    my $this = shift;
    parse_hier_init($this->{hierin});
};

#
# Step 5: Parse connectivity and convert to internal format
#
sub parse_conn {
    my $this = shift;
    parse_conn_init($this->{connin});
};

#
# Step 6: Parse IO specification convert to internal format
#
sub parse_io {
    my $this = shift;
    parse_io_init($this->{ioin});
};

#
# Step 7: build register-space object
#
sub parse_registers {
    my $this = shift;
    $this->{reg} = parse_register_master($this->{regin}, $this->{xmlin});
}; 

#
# Step 8: generate register views from register-space object
#
sub gen_register_views {
    my $this = shift;
    $this->{reg}->generate_all_views();
};

#
# Step 9: generate all modules
#
sub gen_modules {
    my $this = shift;
        
    apply_conn_macros($this->{connin}, $this->{connmacros} );
    apply_hier_gen($this->{hiergen});
    apply_conn_gen($this->{conngen});
    
    #
    # Get rid of some "artefacts"
    #
    purge_relicts();
    
    #
    # Replace %MAC% before output
    #
    parse_mac();
    
    #
    # Add conections and ports if needed (hierachy traversal)
    # Add connections to TOPLEVEL for connections without ::in or ::out
    # Replace OPEN and %OPEN% 
    #
    add_portsig();
    
    #
    # Get rid of some "artefacts", again (add_portsig and add_sign2hier might have
    # added something ....
    #
    purge_relicts();
    
    #
    # Add a list of all signals for each instance
    #
    add_sign2hier();
    
    #
    # Checks go here ...
    #
    
    #
    # Backend jobs ...located here because I want to dump it with -adump!
    #
    generate_entities();
};

#
# Step LAST: write out all Verilog/VHDL and reports
# returns exit status
# 
sub write_output {
    my $this = shift;
       
    # Dump intermediate data
    # mix_store_db knows which data to dump
    #
    mix_store_db( "out", "auto", {reg => $this->{reg}} );
    
    #
    # -report option
    #
    mix_report();
    
    #
    # BACKEND add for debugging:
    #
    write_entities();
    
    write_architecture();
    
    write_configuration();
    
    my $status = ( write_sum() ) ? 1 : 0; # If write_sum returns > 0 -> exit status 1
    return $status;
};

# display method for debugging (every class should have one)
sub display {
	my $this = shift;
	my $dump  = Data::Dumper->new([$this]);
	$dump->Sortkeys(1);
	print $dump->Dump;
};

1;
