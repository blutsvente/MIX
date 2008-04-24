# -*- perl -*---------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright Micronas GmbH, 2002/2005.                                 |
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
# | Modules:    $RCSfile: Globals.pm,v $                                  |
# | Revision:   $Revision: 1.55 $                                         |
# | Author:     $Author: lutscher $                                            |
# | Date:       $Date: 2008/04/24 16:58:13 $                              |
# |                                                                       | 
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# |
# | Changes:
# | $Log: Globals.pm,v $
# | Revision 1.55  2008/04/24 16:58:13  lutscher
# | added key xml
# |
# | Revision 1.54  2008/04/01 12:48:34  wig
# | Added: optimizeportassign feature to avoid extra assign commands
# | added protoype for collapse_conn function allowing to merge signals
# |
# | Revision 1.53  2007/12/14 12:00:26  lutscher
# | added reg_shell.workaround parameter
# |
# | Revision 1.52  2007/11/15 13:09:20  wig
# | Extend intermediate.order description
# |
# | Revision 1.51  2007/09/17 12:40:13  wig
# | Started MixUtils/Header.pm, to be used for the ::col handling in future
# |
# | Revision 1.50  2007/09/14 13:29:45  lutscher
# | added e_vr_ad.path
# |
# | Revision 1.49  2007/09/05 10:56:23  lutscher
# | set default clone.number to 0 because 1 will now force 1 clone
# |
# | Revision 1.48  2007/08/23 08:42:33  lutscher
# | added return statement to mix_get_module_info()
# |
# | Revision 1.47  2007/08/10 09:00:15  lutscher
# | fixed default of clone.field_naming
# |
# | Revision 1.46  2007/08/10 08:53:24  lutscher
# | updated comments
# |
# | Revision 1.45  2007/08/09 09:56:54  lutscher
# | some reg_shell parameter updates
# |
# | Revision 1.44  2007/07/17 09:49:30  lutscher
# | added reg_shell parameter
# |
# | Revision 1.43  2007/06/19 14:47:31  wig
# | Improved CVS writter, added #REF! error message.
# |
# | Revision 1.42  2007/06/18 12:03:13  lutscher
# | added reg_shell.field_naming
# |
# | Revision 1.41  2007/05/03 11:47:06  lutscher
# | added reg_shell parameter
# |
# | Revision 1.40  2007/04/26 06:35:17  wig
# | Create emumux outside of module ifdef excludes
# |
# | Revision 1.39  2007/03/15 13:30:16  lutscher
# | added reg_shell parameter
# |
# | Revision 1.38  2007/03/03 17:24:06  wig
# | Updated testcase for case matches. Added filename serialization.
# |
# | Revision 1.36  2007/02/07 15:11:15  wig
# | fixed typo
# |  	Globals.pm
# |
# | Revision 1.35  2007/01/22 17:32:07  wig
# |  	MixParser.pm MixReport.pm : update -report portlist (seperate ports)
# | 	Globals.pm Mif.pm : updated -report portlist
# |
# | Revision 1.34  2007/01/22 17:26:53  wig
# | Prepare GLOBAL detection (ooffice created xls) and fixed numbering of i2c extra columns.
# |
# | Revision 1.33  2006/11/23 15:11:31  lutscher
# | changed coverage generation
# |
# | Revision 1.32  2006/11/21 16:51:09  wig
# | Improved generator execution (now in order!)
# |
# | Revision 1.31  2006/11/20 17:10:11  lutscher
# | added e_vr_ad parameters
# |
# | Revision 1.30  2006/11/16 15:22:50  wig
# | 	Globals.pm : added vinc_skip keyword
# |
# | Revision 1.29  2006/11/15 09:54:28  wig
# | Added ImportVerilogInclude module: read defines and replace in input data.
# |
# | Revision 1.28  2006/11/13 17:24:43  lutscher
# | added reg_shell.e_vr_ad parameters
# |
# | Revision 1.27  2006/11/09 11:12:53  wig
# |  	Globals.pm : delete some old lines
# |
# | Revision 1.26  2006/11/02 15:37:29  wig
# |  	Globals.pm : added basic caching to Globals.pm get/set/....
# |
# | Revision 1.25  2006/09/25 15:15:44  wig
# | Adding `foo support (rfe20060904a)
# |
# | Revision 1.24  2006/09/25 08:24:10  wig
# | Prepared emumux and `define
# |
# | ....
# |
# +-----------------------------------------------------------------------+
package  Micronas::MixUtils::Globals;
require Exporter;

@ISA=qw(Exporter);

@EXPORT  = qw();

@EXPORT_OK = qw( get_eh );

our $VERSION = '1.0';

use strict;
# use vars qw( $ex ); # Gets OLE object

use Cwd;
use File::Basename;
use Log::Log4perl qw(get_logger);
use FileHandle;

my $logger = get_logger('MIX::MixUtils::Globals');

#
# RCS Id, to be put into output templates
#
my $thisid          =      '$Id: Globals.pm,v 1.55 2008/04/24 16:58:13 lutscher Exp $'; 
my $thisrcsfile	    =      '$RCSfile: Globals.pm,v $';
my $thisrevision    =      '$Revision: 1.55 $';  

$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?

my $ehstore; # Reference to $eh

#
#  storage for global configuration parameters
#	read in from mix.cfg or through command line
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

	$ref_member->{'_get_cache_'} = (); # Initialize cache

	bless $ref_member, $class;
	$ehstore = $ref_member; # Save in global context ...
	
};

=head 4 get_eh() return a reference to the global $eh object

	return a reference to the global $eh object
	
=cut

sub get_eh () {
	
	if ( ref( $ehstore ) ) {
		return $ehstore;
	}

	# Not yet defined ... ignore it
	return undef();
	
} # End of get_eh

=head3 get(key)

get the config key value (or reference) for a given key

=cut

sub get ($$) {
	my $this	= shift;
	my $key		= shift;

	# Returned cached object ...
	if ( exists( $this->{'_get_cache_'}{$key} ) ) {
		return $this->{'_get_cache_'}{$key};
	}

	# Map key to hash keys a.b.c -> {a}{b}{c}
	my $e = $this->_key_hash($key); 
	my $ref = undef();
	$e = 'if ( exists( $this->{cfg}' . $e . ' ) ) { $ref = $this->{cfg}' . $e . '; }';
	eval $e;
	if ( $@ ) {
		$logger->warn( '__W_EVAL_CFG', "\tEvaluation of config key $key files: $@");
		$ref = undef();
	}
	
	# Put result into cache ...
	$this->{'_get_cache_'}{$key} = $ref;

	return $ref;
	
} # End of get

#
# Convert a.b.c to {a}{b}{c}
#
# Currently only \w, %, : and '.' are allowed chars in such a key
#
sub _key_hash ($$) {
	my $this	= shift;
	my $key		= shift;

	my $okey = $key;
	if ( $key =~ s,[^%:.\w],,og ) {
		# Warn user:
		$logger->warn( '__W_KEY2HASH', "\tIllegal character removed from eh key:" . $okey );
	}
	( my $k = ( "{'" . $key . "'}" )) =~ s/\./'}{'/g;
	return $k;
} # End of _key_hash

#
# Convert a.b.c..*d to {a}{b}{c.*d}
# Special: handle double dots and allow nearly any usable
#  character. Purpose is to allow usage of regular expressions
#  as keys.
# double will put a real dot into the key
# Mask metacharacters: {}
#
sub _key_hashre ($$) {
	my $this	= shift;
	my $key		= shift;

	my $okey = $key;
	# Find .. and mark
	$key =~ s/\.\./#DOTDOT#/g;
	$key =~ s/([{}])/\\$1/g; # Mask {}

	( my $k = ( "{'" . $key . "'}" )) =~ s/\./'}{'/g;
	$k =~ s/#DOTDOT#/./g;
	return $k;
} # End of _key_hashre

#
# accept a key ( a.b.c )
#    and stores $val under that key
# returns the stored value
#
sub set ($$$) {
	my $this	= shift;
	my $key		= shift;
	my $val		= shift;

	my $k = $this->_key_hash( $key );

	return $this->_set( $k, $key, $val );

} # End of set

#
# accept a regular expression as last part of key ( a.b.the[ab]..*end )
#   a single dot seperates the key parts, while a double dot is mapped
#   to a single dot in the regular expression.
#   The above key will yield $eh..{a}{b}{the[ab].*end} = <value>
#   To read back the re keys, use $eh->get{a}{b} and iterate over
#
# function returns the stored value
#
sub setre ($$$) {
	my $this	= shift;
	my $key		= shift;
	my $val		= shift;

	my $k = $this->_key_hashre( $key );

	return $this->_set( $k, $key, $val );

} # End of setre

#
# Common part of the set and setre functions
# Gets the converted key and assigns the value
#
sub _set ($$$$) {
	my $this	= shift;
	my $k		= shift;
	my $key		= shift;
	my $val		= shift;
	
	my $r = undef();	
	$key =~ s/'/\\'/g; # Mask '
	
	# Invalidate the cache! Currently do all of the cache!
	$this->{'_get_cache_'} = ();

	( my $logval = $val ) =~ s/\n/ /g; ;
	if ( length( $logval ) > 30 ) {
		$logval = substr( $val, 0, 30 ) . ' ...';
	} 
	my $loga ='$logger->debug( "__D_CFG_ADD", \'' . "\t" .
			'Adding configuration ' . $key . '=\' . $logval );'; # Add new
	my $logo ='$logger->debug( "__D_CFG_OVL", \'' . "\t" .
			'Overloading configuration ' . $key . '=\' . $logval );'; # Overload
	
	my $e = 'if ( exists( $this->{cfg}' . $k . ' ) ) { $r = $this->{cfg}' . $k . ' = $val; ' . $logo .
	    '} else { $r = $this->{cfg}' . $k . ' = $val; ' . $loga . ' }';
	eval $e;
	if ( $@ ) {
        $logger->error('__E_EVAL_CFG',
        	"\tE_MIX_GLOBALS: Evaluation of configuration $key=$val failed: $@") if ( $@ );
		return undef();
    }

	return $r;
} # End of set

=head3 inc(key)

increment a given config counter and return the new value

=cut

sub inc ($$$) {
	my $this = shift;
	my $key  = shift;
	my $flag = shift || 0; # If set, do postincrement
	
	# Invalidate this cache line:
	delete $this->{'_get_cache_'}{$key};

	my $k = $this->_key_hash( $key );
	
	my $pre  = ( $flag ) ? '' : '++';
	my $post = ( $flag ) ? '++' : '';
	my $e = $pre . '$this->{cfg}' . $k . $post . ';';
	my $r = eval $e;
	if ( $@ ) {
		$logger->error('__E_INC_CFGKEY', "\tIncrement for $key failed: $@");
		return undef();
	}

	return $r;
} # End of inc

=head3 postinc(key)

increment a given config counter and return the value set before
(post increment)

=cut

sub postinc ($$) {
	my $self = shift;
	my $key  = shift;
	
	$self->inc( $key, 1 ); # Run inc in post mode

} # End of postinc


#
# append to string and return result
#
# Input:
#	$key	config key
#	$val	value to append
#	$sep	seperator (opt.)
#
# Caveat: if this configuration did not exist or was empty,
#   you will see a leading $sep (if set)
# 
sub append ($$$$) {
	my $this = shift;
	my $key  = shift;
	my $val  = shift;
	my $sep  = shift; # Use this character as seperator

	return undef unless( defined( $val ) );

	# Invalidate this cache line:
	delete $this->{'_get_cache_'}{$key};

	my $k = $this->_key_hash( $key );
	return undef unless( defined( $k ) );

	# Was a seperator char/string set?	
	$sep = '' unless( defined ( $sep ) );
	$sep =~ s/"/\\"/g; # Mask 
	$val =~ s/"/\\"/g; # Mask "
	
	my $e = '$this->{cfg}' . $k . ' .= "'. $sep . $val . '";';
	my $r = eval $e;
	if ( $@ ) {
		$logger->error('__E_APP_CFGKEY', "\tappend for $key failed: $@");
		return undef();
	}

	return $r;
} # End of append
	
#
# comma-append to string and return result
#
# Caveat: if this configuration did not exist or was empty,
#   you will see a leading ,
# 
sub cappend ($$$) {
	my $this = shift;
	my $key  = shift;
	my $val  = shift;

	return $this->append( $key, $val, ',' );

} # End of cappend
	
# Perl module registration functions
# ---------------------------------------------------------------------------------------
# method to register a MIX module (package) into the Class Globals object;
# if 'version' is a RCS-style macro, the version number is automatically extracted;
# 'name' is stripped of any file extension and converted to lower case
sub mix_add_module_info {
    my ($this, $name, $version, $text) = @_;
    my $ref = $this->{'cfg'}->{'internal'};

    if ($version =~ /\$Revision\:/) {
        $version =~ s/\s*\$\s*//g;
        $version =~ s/Revision\:\s+//;
    };
    $name =~ s/\..*$//;
    if (!defined $text) { $text = "Mix module $name"; };

    if (exists ($ref->{lc($name)})) {
        $logger->warn("__W_PCKG","\tModule $name is already registered");
    };
    $name = lc($name);
    $ref->{$name} = { 
                     'version' => $version,
                     'text' => $text
                    };
};

# retrieve registered package information for module 'name'
# returns a hash reference or undef if the module does not exist
sub mix_get_module_info ($$) {
    my ($this, $name) = @_;
    my $ref = undef;
    $name = lc($name);
    $name =~ s/\..*$//;
    if (exists($this->{'cfg'}->{'internal'}->{$name})) {
        $ref = $this->{'cfg'}->{'internal'}->{$name};
    };
    return $ref;
};

# returns a hash reference with all module info or undef if there is no module info
# the hash has the form of:
# ( <module1> => ( version => <version>, text => <text> ),
#   <module2> => ( ... ),
#   ...)
sub mix_get_module_info_all ($) {
    my $this = @_;
    if (exists($this->{'cfg'}->{'internal'})) {
        return $this->{'cfg'}->{'internal'};
    } else {
        return undef;
    };
};
# ---------------------------------------------------------------------------------------

#
# Init the EH field ..
#
sub init ($) {
	my $this = shift;
	
	# HDL template (only placeholders here!)
	$this->{'cfg'}{'template'} = {
		'vhdl' =>{
	    	# Actual values are set in MixWriter
	    	'conf' => { 'head' => "## VHDL Configuration Template String t.b.d.", },
	    	'arch' => { 'head' => "## VHDL Architecture Template String t.b.d.", },
	    	'enty' => { 'head' => "## VHDL Entity Template String t.b.d.", },
		},
		'verilog' =>{
	    	'conf' => { 'head' => "## Verilog Configuration Template String t.b.d.", },
	    	'arch' => { 'head' => "## Verilog Architecture Template String t.b.d.", },
	    	'enty' => { 'head' => "## Verilog Entity Template String t.b.d.", },
	    	'wrap' => "## Verilog Wrapper Template String t.b.d.",
	    	'file' => "##Verilog File Template String t.b.d.",
		},
    };

	# HDL output creation config
	$this->{'cfg'}{'output'} = {
        'path' => '.',		   # Path to store backend data. Other values are a path, CWD or INPUT
        'path_include' => '.', # 2nd path for backend data (VHDL/Verilog include files)
		'mkdir'	=> 'auto',	# Should we create directories as needed? Available values
							#   are: auto|all|yes (do all), no (do not)
							# output, intermediate, report, internal (comma seperated, only create these)
		'filter' => {
			'file' => '',	# Do not print if the instance names matches one of the list (comma seperated)
							# A prepended (arch|enty|conf): selects only that file from being excluded
		},
		'order' => 'input',		# Field order := as in input or predefined
		'format' => 'ext',		# Output format derived from filename extension ???
		'filename' => 'useminus', # Convert _ to - in filenames
		'casefilename'	=> 'lc',  # Map all output filenames to lowercase
		'generate' => {
	    	'arch' => 'noleaf', # allowed keys: alt, [no]leaf, ...
	      	'enty' => 'noleaf', # no leaf cells: [no]leaf,alt,
	      	'conf' => 'noleaf', # one of: [leaf|noleaf],verilog
	      			  # create (no) leaf cells, default is "noleaf"
				      #   The verilog keyword will add configuration
				      #   records for verilog subblocks (who wants that?)
	      	'use' => 'enty',     # apply ::use libraries to entity files, if not specified otherwise
					# values: <enty|conf|arch|all>
			'top' => 'auto',	# Do not print out our top level (usually is TESTBENCH)
					# Allowed keys are: auto  -> print if TOP != %TESTBENCH% or if auto hierachy is enabled
					#					disable | no
					#					yes
	      	'inout' => 'mode,noxfix',	# Generate IO ports for %TOP% cell (or daughter of testbench)
					# controlled by ::mode I|O
					# noxfix: do not attach pre/postfix to signal names at %TOP%
            'xinout'  => '',       # list of comma seperated signals to exclude from automatic wiring to %TOP%
            '_re_xinout' => '',   # keeps converted content of xinout (internal use, only)
	      	# 'port' => 'markgenerated',	# attach a _gIO to generated ports ...
	      	'delta' => 0,	    	# allows to use mix.cfg to preset delta mode -> 0 is off, 1 is on
			'deltadesc' => 're=.*\.(v|vhd)',	# Regular expression for delta mode compare list
			'deltafiles' => [],	# Holds file list address 
	      	'bak' => 0,		# Create backup of output HDL files
	      	'combine' => 0,	# Combine enty,arch and conf into one file, -combine switch
	      	'portdescr' => '%::descr%',
	      		# Definitions for port map descriptions:
		      	#   %::descr% (contents of this signal's descr. field
		      	#	%::ininst% (list of load instances),
		      	#   %::outinst% (list of driving instances),
		      	#	%::inport%, %::outport%		list of in/out ports at this signal
		      	#	%::ininpo%, %::outinpo%		list of inst/port pairs
		      	#	%::comment%
			  	#   %::connnr  (signal number according to order generated/defined by sheets),
			  	#   ... all plain fields from conndb ( ::bundle, ::type, ...
	      	'portdescrlength' => 100, # Limit length of comment to 100 characters!
	      	'portdescrlines' => 10,   # Do not print > 10 port comment lines
	      	'portdescrindent' => '%CR%%S%%S%%S%%S%%S%',
		  	'portmapsort' => 'alpha', # How to sort port map; allowed values are:
		  			# alpha := sorted by port name (default)
		  			# input (ordered as listed in input files)
		  			# inout | outin: seperate in/out/inout seperately
		  			#    can be combined with the "input" key
		  			# ::COL : order as in column ::COL (alphanumeric!)
					# debug	:= print out sort criteria in comments
		  			
		  	# List of "logic" entities
			'logic' => 'wire(1:1),and(1:N),or(1:N),nand(1:N),xor(1:N),nor(1:N),not(1:1)',
			'_logicre_' => '', 		# internal usage!
			'_logiciocheck_' => {}, # internal usage!
			'logicmap' => 'uc',
				# uc|upper[case] -> create uppercase style logic (default)
				# lc|lower[case] -> create lowercase style logic
				# review		 -> add "AND 1" or "OR 0" 

	      	'fold' => 'signal',	# If set to [signal|hier], tries to collect ::comments, ::descr and ::gen
					# like TEXT_FOO_BAR (X10), if TEXT_FOO_BAR appears several times
					# TODO Implement for hier
          	'verilog' => '', # switches for Verilog generation, off by default, but see %UAMN% tag
                             #  useconfname := use VHDL config name as verilog module name; works for e.g. NcSim
            'verimap' => {
            	'modules'	=> '', # Set to perl-re matching the modules to warp within `define ....
            	'sigvalue'	=> 'ALL=0', # Default for signal values, format: module_re/port_re = val, ....
            	'select'	=> 'exclude_%::inst%', # Use this value as switch name
            	'options'	=> '',		# values: incfile (write alternative signal map into include file,
            },
            'emumux' => { # Insert muxes for the listed modules
            	# Alternative way is by using a "::emumux" column
            	# If ::emumux is defined, the values defined there are applied
            	#	if ::emumux is defined, but empty, take the definitions here
            	#	
            	#!wig20060907: currently only implemented for Verilog
            	'modules'	=> '', # Set to regular expression or comma seperated list to matching modules, setting this activates
            					   # the whole thing! A ! makes this module not matching.
            	'sigselect' => '', # Only signals matching this list are muxed, if empty defaults to .*
            	'select'    => 'emu_mux_%::inst%', # Use this value as select signal name
            	'define'	=> 'insert_emu_mux_%::inst%', # defined the name of the `define ...
            	'muxsnameo'	=> '%::name%_emux_s',	# multiplexer out signal name, from mux to port
            	'muxsnamei' => '%::name%_vc_s', 	# multiplexer in signal name (you access here!)
            	'options'	=> 'in',	# define extra (global) options like in | out | inout | leaf | nonleaf
            							# select=high, select=low, select=open (default for select signal)
            },
	      	'workaround' => {
            	'verilog' => 'dummyopen,optimizeassignport',
            		# dummyopen := create a dummy signal for open port splices 
            		# optimizeassignport := if possible, use port name instead of signale name (rfe20080323)
                    ,
                'magma' => 'useasmodulename_define', # If the %UAMN% tag is used, use defines!
                '_magma_def_' =>
'
`ifdef MAGMA
    `define %::entity%_inst_name %::entity%
`else
    `define %::entity%_inst_name %::config%
`endif
',   # This gets used by if the magma workaround is set ...
                '_magma_mod_'   => '`%::entity%_inst_name', # module name
                '_magma_uamn_' => '',   # Internal use, storage for generated defines
                'typecast'  => 'intsig', # 'portmap' would be more native, but does not work for Synopsys
                'std_log_typecast' => 'ignore', # will ignore typecast's for std_ulogic vs. std_logic ...
	   		},
    	},
		'ext' => {
			'vhdl' => 'vhd',
			'verilog' => 'v',
            'verilog_def' => 'vh', # Verilog include files (macros, parameters, etc.)
			'intermediate' => 'mixed', # not a real extension!
			'internal' => 'pld',
			'delta' => '.diff',	  # delta mode
			'verify' => '.ediff',   # verify against template ...
		},
		'comment' => { # Comment char(s) for output
			'vhdl' => '--',
			'verilog' => '//',
			'intermediate' => '#',
			'internal' => '#',
			'delta' => '#',
			'default' => '#',
			# TODO : Allow /* ... */ comments for Verilog to be accepted, too
		},
		'language' => { # Special switches to control details of the HDL generated
			'vhdl'	=>	'', # Unused 20051007
			'verilog'	=>	'', # Setting to 2001 will change generation of port and parameters
							# keys: [no]owire, 2001, [no|old]style, [no|old|2001]param,
		},
		# 'warnings' => 'load,drivers',	# Warn about missing loads/drivers
		'warnings' => '',
		'delta' => 'remove,ispace,comment,ihead', # Controlling delta output mode:
			    # (i|ignore)space:   (not) consider whitespace
			    # sort:    sort lines
			    # [i(gnore)]comment: do not remove all comments before compare
			    # [i(gnore)]head: ignore file header
			    # remove:  remove empyt diff files
                # ignorecase|ic: -> ignore case if set
                # isc|ignoresemicolon: -> ignore trailing semicolon
                # mapstd[logic]: -> ignore std_logic s. std_ulogic diffs! 
	};

	$this->{'cfg'}{'input'} = {
		'ext' =>	{
			'excel' =>	'xls',
	   		'soffice' => 'sxc',
	   		'oofice' => 'ods',
	   		'csv'   =>	'csv',
		},
		'header' => 'mix', # Recognize headers:
					#   mix -> take first line starting with ::col ::col2 ::ign
					#   any -> take first non comment line
					#	strict -> can be combined with mix, only ::COL allowed!
		'ignore' => {
			'comments' =>
				'^\s*(#|//|--)', #  if set to '::ignany', ignore row if any non white-space
							# character is set in the ::ign column
			'lines' =>		# Ignore lines starting with # or // or --
				'^\s*(#|//|--)', # Define lines to remove
			# TODO : move this to header.map
			'map'	=>		# Allow mappings: # -> ::ign if followed by another ::
				'hashtoign',
			# TODO : merge that with input.header!!!
			'columns'	=>	'nohead', # Defines handling of columns with no headerline
							#	nohead	:= ignore columns with empty header (default)
							#   mix		:= take first line starting with :: as header (default)
							#		,strict := only read in columns with ::FOO header (not default)
							#	any		:= take first non comment line as header line
							#	join	:= join all headless together into one ::extra
							#	extran	:= create a new header ::extra_N for each headless column
							#	skip::FOO	:= ignore columns with that header FOO 
			# TODO : define pragmas for controlled usage of comments:
			'pragma' => '', # comments will be printed/removed selectively
							# e.g.  __HDL__, __MIF__ 
			'variant' => '#__I_VARIANT', # Internally used to mark lines deselected by -variant
		}
    };
	$this->{'cfg'}{'internal'} = {
		'path' => '.',
		'order' => 'input',		# Field order := as in input or predefined
		'format' => 'perl', 	# Internal format := perl|xls|csv|xml ... (not used!)
    };
	$this->{'cfg'}{'intermediate'} = {
		'path'	=> '.',
		'order'	=> 'template', #!wig20060717: either "input" or "template"
				# Define order of columns for intermediate sheets!
				# template -> sort by order defined in input sheets (default)
				# input    -> print out in order column occur in input
				#!wig20071115: adding 'alpha' and the col:xxx or row:xxx
				# Default: col:template,row:alpha
		'keep'	=> '3',	# Number of old sheets to keep
		'delta' => 'purgetable', # Remove empty columns before applying diff
		'format'	=> 'prev', # One of: prev(ious), auto or n(o|ew)
			# If set, previous uses old sheet format, auto applies auto-format and the others do nothing.
		'strip'	=> '0',   # remove old and diff sheets
		'ext'	=> '', # default intermediate-output extension
		'intra'	=> '',	# if set create seperate conn sheets for instances:
		#	INTRA		-> CONN and INTRA
		#	TOP			-> CONN_<TOP> and CONN
		#	TOP,INTRA	-> CONN_<TOP> and CONN_INTRA
		#	INST[ANCE]	-> create one conn sheet for each instance, named: CONN_<instance>
		'instpre'	=>	'CONN_',	# prepend to CONN sheet name if 'intra' = 'inst'			
		'topmap' => 'ALL',	# Values: ALL or list of signals (comma seperated)
		# map (I,O,IO) signal modes of top to %TM_(I|O|IO)%
    };
	$this->{'cfg'}{'import'} = { # import mode control
   		'generate' => 'stripio', # remove trailing _i,_o from generated signal names
   		'order'	   => 'sort',	 # 'sort' (do sort) or 'input' (by input order)
   		'vinc'	   => '',		 # Reference to verilog import module
   		'vinc_skip' => 'include,define', # Words matching will not be replaced
	};
    	
	$this->{'cfg'}{'check'} = {
    	# Checks enable/disable: Usually the keywords to use are
	    # na|disable (or empty) -> do not check
		# check           -> check and print warnings
	    # force           -> check and force compliance
	    # Available (built-in) rules/check targets are:
	    #   lc (lower case everything), postfix, prefix,
		#   lc, lcfirst (make first lc), lcfirstuc (uc all but first lc)
		#   uc, ucfirst (make first uc), ucfirstlc (lc all but first uc)
	    # t.b.d.: uniq (make sure name apears only once)!
		# set check.namex.TYPE for selected excludes
		'name' => {
    		'all' => '',		  # Sets all others (if __default__ still in)
    		'pad'  => 'check,lc,__default__',
    		'conn' => 'check,lc,__default__', # check signal names ...
    		'enty' => 'check,lc,__default__',
    		'inst' => 'check,lc,__default__', # check instance names ...
    		'port' => 'check,lc,__default__',
    		'conf' => 'check,lc,__default__',
		},
		'namex' => { # Exclude list for check.name, use only to selectivly disable checks
			'all'  => '',
    		'pad'  => '',
    		'conn' => '',
    		'enty' => '',
    		'inst' => '',
    		'port' => '',
    		'conf' => '',
		},
		'keywords' => { #These keywords will trigger warnings and get replaced
    		'vhdl'	=> '(open|instance|entity|signal)',        # TODO Give me more keywords
    		'verilog' 	=> '(register|net|wire|in|out|inout)', # TODO give me more
    		'xlscell'	=> '^(#(VALUE|NAME|NUM|REF)[!?]|GENERAL)$',		# Indicates a problem with XLS macros/formulas
    					# Format is perl regular expression, should not be modified by user
		},
		'defs' => '',   # 'inst,conn',    # make sure elements are only defined once:
	    		    # posible values are: inst,conn
		'signal' => 'load,driver,check,top_open,top_nodriver,nonanbounds',
					# reads: checks if all signals have appr. loads
					# and drivers.
					#	nanbounds  := print warning if bounds are not numbers
					#!wig20060925: changed default to nonanbounds!
					# If "top_open" is in this list, will wire unused
					# signals to open.
					# If "top_nodriver" is set, will leave undriven ports open
					#	(required if you want to attach another signal to this port)
					# TODO: auto_low, auto_high: automatically ground/high undriven signals
				
		'inst' => 'nomulti',	# check and mark multiple instantiations
		# Verifiy modules against provided modules (mostly for entity checks)
    	'hdlout' => { # act. should be named "hdlout"
           	'mode' => "entity,leaf,generated,ignorecase", # check only LEAF cells -> LEAF
                      #  ignore case of filename -> ignorecase
                      # which objects: entity|module|arch[itecture]|conf[iguration]|all
                      #		module -> applies to verilog modules
                      # strategy: generated := compare generated object, only
                      #               inpath := report if there are extra modules found inpath
                      #               leaf := only for leaf cells
                      #               nonleaf := only non-leaf cells
                      #               dcleaf := dont care if leaf (all modules)
                      #               ignorecase|ic := ignore file name capitalization
           	'path' => '', # if set a PATH[:PATH], will check generated entities against entities found there
           	# the path will be available in ...'__path__'{PATH}
			'delta' => '', # define how the diffs are made, see output.delta for allowed keys
					# if it's empty, take output.delta contents
					# Additionl keys:
					#	mod[ule]head : only parse verilog headers, ignore body
            'filter' => { # TODO allow to remove less important lines from the diff of template vs. created
               	'entity' => '',
               	'arch' => '',
               	'conf' => '',
            },
            'extmask' => { # TODO mask HDL files seen by the verify parser ... t.b.d.
               	'entity' => '',
               	'arch' => '',
               	'conf' => '',
            },
        }, 
    };
    
    # Autmatically try conversion to TYPE from TYPE by using function ...
	$this->{'cfg'}{'typecast'} = { # add typecast functions ...
		'std_ulogic_vector' => {
	    	'std_logic_vector' => 'std_ulogic_vector( %signal% );' ,
		},
		'std_logic_vector' => {
	    	'std_ulogic_vector' => 'std_logic_vector( %signal% );' ,
		},
		'std_ulogic' => {
	    	'std_logic' => 'std_ulogic( %signal% );',
		},
		'std_logic' => {
	    	'std_ulogic' => 'std_logic( %signal% );',
		},
	};

	$this->{'cfg'}{'postfix'} = {
	    qw(
		    POSTFIX_PORT_OUT	_o
		    POSTFIX_PORT_IN		_i
		    POSTFIX_PORT_IO		_io
		    PREFIX_PORT_GEN		p_mix_
		    POSTFIX_PORT_GEN	_g%IO%
		    PREFIX_PAD_GEN		pad_
		    POSTFIX_PAD_GEN		%EMPTY%
		    PREFIX_IOC_GEN		ioc_
		    POSTFIX_IOC_GEN		%EMPTY%
		    PREFIX_SIG_INT		s_int_
            PREFIX_TC_INT       s_mix_tc_
		    POSTFIX_SIGNAL		_s
		    PREFIX_INSTANCE		i_
		    POSTFIX_INSTANCE	%EMPTY%
		    POSTFIX_ARCH		%EMPTY%
		    POSTFILE_ARCH		-a
		    POSTFIX_ENTY		%EMPTY%
		    POSTFILE_ENTY		-e
		    POSTFIX_CONF		%EMPTY%
		    POSTFILE_CONF		-c
		    PREFIX_CONST		mix_const_
		    PREFIX_GENERIC		mix_generic_
		    POSTFIX_GENERIC		_g
		    PREFIX_PARAMETER	mix_parameter_
		    PREFIX_KEYWORD		mix_key_
		    POSTFIX_CONSTANT	_c
		    POSTFIX_PARAMETER	_p
		    PREFIX_IIC_GEN		iic_if_
		    POSTFIX_IIC_GEN		_i
	        POSTFIX_IIC_OUT     _iic_o
	        POSTFIX_IIC_IN      _iic_i
		    POSTFIX_FIELD_OUT   _par_o
            POSTFIX_FIELD_IN    _par_i
		)
	};

	$this->{'cfg'}{'pad'} = {
		'name' => '%PREFIX_PAD_GEN%%::pad%',  # generated pad with prefix and ::pad
		    # '%PREFIX_PAD_GEN%%::name%',  # generated pad with prefix and ::name
		    # '%PREFIX_PAD_GEN%_%::pad%'
			qw(
	    	PAD_DEFAULT_DO	0
	    	PAD_ACTIVE_EN	 	1
	    	PAD_ACTIVE_PU	 	1
	    	PAD_ACTIVE_PD	 	1
			)
	};

	$this->{'cfg'}{'port'} = {
		'generate' => {   # Options related to generated port names. Please see also inout value
	    	'name' => 'postfix', # Take the postfix definitions: p_mix_SIGNAL_g[io], see descr. there
				  # signal := take the signal name, not post/prefix!
	    	'width' => 'auto',    # auto := find out number of required connections and generate that
				  # full := always generate a port for the full signal width
		},
	};

	$this->{'cfg'}{'iocell'} = {
        'embedded' => '',       # If set to 'pad', allows to create iocells with embedded pads aka.
                                # MIX will not try to create a pad.
		'name' => '%::iocell%_%::pad%',  # generated pad name with prefix and ::pad
		    # '%PREFIX_IOC_GEN%%::name%',  # generated pad name with prefix and ::name
		    # '%PREFIX_IOC_GEN%_%::pad%'
		'auto' => 'bus', 	# Generate busses if required autimatically ...
		'bus' => '_vector', # auto -> extend signals by _vector if required ....
		'defaultdir'	=> 'in', 	# Default signal direction to iocell (seen towards chip core!!)
		'in'	=> 'do,en,pu,pd,xout',	# List of inwards signals (towards chip core!!)
		'inout' => '__NOINOUT__',	# List of inout ports ...
		'out'	=> 'di,xin',		# List of outwards ports (towards chip core!!)
					# di is a chip input, driven by the iocell towards the core.
		'select' => 'onehot,auto', # Define select lines: onehot vs. bus vs. given
					# 
					# bus -> use signal in ::muxopt:0 column (first)
					# given  -> use signals as defined by the %SEL% lines,
					#     but calculate width 2^N ... -> 3 signals give a mux width of
					#  8 ... (alternativ take width argument from signal name
					# minimum -> wire bits only if used (minimal bus) t.b.d.
					# auto := choose width accordingly to wired io busses
					# const := use %SEL% defined width

	};

	#
    # parameters for register-view generation (e.g. for HDL register-shell)
    #
	$this->{'cfg'}{'reg_shell'} = 
      {
       'type'      => 'HDL-vgch-rs',       # type of register-view to be generated (see Reg.pm)
       'addrwidth' => 14,                  # default address bus width (byte-addresses)
       'datawidth' => 32,                  # default data bus width in bits
       'multi_clock_domains' => 1,         # if 1, generate separate register blocks for all clock domains
       'infer_clock_gating'  => 1,         # if 1, insert extra logic for power-saving
       'infer_sva'           => 1,         # if 1, insert SystemVerilog assertions into HDL-code
       'read_pipeline_lvl'   => 0,         # parameter that controls the read-pipelining
       # if 0, no read-pipelining will be inserted
       'read_multicycle'     => 0,         # can be one of [0,1,2,..] to insert delays for read-acknowledge
       'bus_clock' => "clk",               # default bus clock name
       'bus_reset' => "rst_n",             # default bus reset name
       'use_reg_name_as_prefix' => 0,      # [deprecated] if 1, prefix field names with register names
       'exclude_regs' => "",               # comma seperated list of register names to exclude from code generation
       'exclude_fields' => "",             # comma seperated list of field names to exclude from code generation	
       'add_takeover_signals' => 0,        # if 1, internal update signals are also routed to top-level ports
       'regshell_prefix'      => "rs",     # register-shell prefix
       'enforce_unique_addr'  => 1,        # if 1, allow only one register per address
       'infer_reset_syncer'   => 0,        # if 1, instantiates a reset synchronizer for asynchronous reset
       'field_naming'         => '%F',     # naming scheme for fields, see 'clone'
       'virtual_top_instance' => "testbench", # name of top-level instance where register-shell is instantiated (usually not used)
       # parameters for e_vr_ad view
       'e_vr_ad' => {
                     'path'             => "./e", # output dir for e-code
                     'regfile_prefix'   => 'MIC',
                     'file_prefix'      => 'regdef',
                     'vplan_ref'        => '%EMPTY%', # for automatic coverage generation
                     'field_naming'     => '%lF',  # see 'clone'
                     'reg_naming'       => '%uR',  # see 'clone'
                     'cover_ign_read_to_write_only' => 0, # for automatic coverage generation
                     'cover_ign_write_to_read_only' => 1  # for automatic coverage generation
                    },
       # parameters for STL view 
       'stl' => {
                 'initial_idle'  => 100,
                 'exclude_regs'  => "", # comma seperated list of registers to exclude from STL generation
                 'use_base_addr' => 0
                },
       
       # parameters for cloning register object
       # the naming goes according to placeholders:
       # %[<u|l>]<D|R|F|[<d>]N>
       # D domain name
       # R original name of register
       # F original name of field (only availabe in field_naming)
       # N decimal number; can be preceded by a number to fix the number of digits used in representation
       # u or l force upper/lowercase (optional)
       # e.g. 'scc_%2N_%uR' creates name scc_06_REG_X from original name reg_x in the 7th clone
       'clone' => {
                   'number'       => 0,          # number of clones
                   'addr_spacing' => 10,         # number of address bits reserved for every clone
                   'reg_naming'   => '%R_%N',    # naming scheme for cloned register
                   'field_naming' => '%F_%N',    # naming scheme for cloned field
                   'unique_clocks'=> 1           # if 1, uniquify clock names of clones
                  },
       'workaround' => "",                       # string parameter to specify workarounds, currently: platinumd
       
       # legacy parameters, not needed anymore!
       'cfg_module_prefix'    => "rs_cfg", # prefix for config register block
       'mode'             => 'lcport', # lcport -> map created port names to lowercase	
       'regwidth' => 32  # Default register width
      };
	#
    # Possibly read configuration details from the CONF sheet, see -conf option
    # 'conf' is a pseudo field, mainly used for dumping the actual configuration
    # to allow debugging
	$this->{'cfg'}{'conf'} = {
		'xls' => 'CONF',
		'xxls'	=> '',
		'req' => 'optional',
		'parsed' => 0,
		'field' => {},
	};

	#
	# Default xls sheet definitions
	#!wig20051011
	# 'default' allows to read in nearly arbitrary data and keep track of it
	# See below for more sophisticated fields.
	# The least common denominator is, that a header line ::foo ::bar is required
	#    and that the ::ign column should be the first
	#
    $this->{'cfg'}{'default'} = {
		'xls' => '.*',
		'req' => 'optional',
		'key' => '::ign', 		# Primary key to arbitrary data. Has to be set!!!
		'comments' => 'post',	# Keep comments -> pre|predecessor post|successor
		'parsed' => 0,
		'field' => {
	    	#Name   	=>	  	   		Inherits
	    	#					    		Multiple
	    	#						    		Required
	    	#							  		Defaultvalue
	    	#								    			PrintOrder
	    	#                           0   1   2	3       4
	    	'::ign' 		=> [ qw(	0	0	1	%NULL%	1 ) ],
	    	'::comment'	    => [ qw(	1	0	2	%EMPTY%	2 )],
	    	'::default'	    => [ qw(	1	1	0	%NULL%	0 )],
	    	'::debug'	    => [ qw(	1	0	0	%NULL%	0 )],
        	'::default'		=> [ qw(	1	1	0	%EMPTY%	0 )],	    
	    	'::skip'		=> [ qw(	0	1	0	%NULL% 	0 )],
	    	'nr'			=> 3,  # Number of next field to print
	    	'_mult_'		=> {},  # Internal counter for multiple fields
   	    	'_multorder_' 	=> 0, # Sort order for multiple fields -> left to right increases
	    						# 1 / RL -> left to right decreasing
	    						# xF -> map the first to ::head:0 (defaults: ::head)
		},
    };

    #
	# join -> for address_join.pl
	#!wig20051011
	#
	# ::ign	::client ::definition ::group ::group_id 
	# ::grp_awidth ::group_addr	::subwidth
	# ::sub	::cpu1_addr	::cpu2_addr	::xls_def
	#!wig20070913: adding ::client column	
    $this->{'cfg'}{'join'} = {
		'xls' => '.*',			# Include sheets listed here (after exclude got applied)
		'xxls'	=> '',			# Exclude sheets here (before include is applied)
		'req' => 'optional',
		'key' => '::ign', 		# Primary key to arbitrary data. Has to be set!!!
		'comments' => 'post',	# Keep comments -> pre|predecessor post|successor
		'parsed' => 0,
		'field' => {
	    	#Name   	=>	  	   		Inherits
	    	#					    		Multiple
	    	#						    		Required
	    	#							  		Defaultvalue
	    	#								    			PrintOrder
	    	#                           0   1   2	3       4
	    	'::ign' 		=> [ qw(	0	0	1	%NULL%	1 ) ],
	    	'::client'		=> [ qw(	0	0	1	%EMPTY%	2 ) ],
	    	'::definition'		=> [ qw(	0	0	1	%EMPTY%	3 ) ],
	    	'::group'		=> [ qw(	0	0	1	%EMPTY%	4 ) ],
	    	'::group_id'		=> [ qw(	0	0	1	%EMPTY%	5 ) ],
	    	'::grp_awidth'		=> [ qw(	0	0	1	%EMPTY%	6 ) ],
	    	'::group_addr'		=> [ qw(	0	0	1	%EMPTY%	7 ) ],
	    	'::subwidth'		=> [ qw(	0	0	1	%EMPTY%	8 ) ],
	    	'::sub'		=> [ qw(	0	0	1	%EMPTY%	9 ) ],
	    	'::cpu1_addr'		=> [ qw(	0	0	1	%EMPTY%	10 ) ],	    	
	    	'::cpu2_addr'		=> [ qw(	0	0	1	%EMPTY%	11 ) ],
	    	'::comment'	    => [ qw(	1	0	2	%EMPTY%	12 )],
	    	'::default'	    => [ qw(	1	1	0	%NULL%	0 )],
	    	'::debug'	    => [ qw(	1	0	0	%NULL%	0 )],
        	'::default'		=> [ qw(	1	1	0	%EMPTY%	0 )],	    
	    	'::skip'		=> [ qw(	0	1	0	%NULL% 	0 )],
	    	'nr'			=> 13,  # Number of next field to print
	    	'_mult_'		=> {},  # Internal counter for multiple fields
   	    	'_multorder_' 	=> 0, # Sort order for multiple fields -> left to right increases
	    						# 1 / RL -> left to right decreasing
	    						# xF -> map the first to ::head:0 (defaults: ::head)
		},
    };

    #
    # Definitions regarding the CONN sheets:
    #
    $this->{'cfg'}{'conn'} = {
		'xls'	=> 'CONN',		# Include only/all sheets matching this expression (after xxls exclude)
		'xxls'	=> '',			# Exclude sheets matching this regular expression (before include)
		'comments' => 'post',	# Keep comments -> pre|predecessor post|successor
		'req' => 'mandatory',
		'parsed' => 0,
		'key' => '::name', # Primary key to %conndb
		'field' => {
	    #Name   	=>			Inherits from template
	    #							Multiple
	    #								Required: 0 = no, 1=yes, 2= init to ""
	    #									Defaultvalue
	    #													PrintOrder
	    #                       0   1   2	3           	4
	    '::ign' 	=> 	[ qw(	0	0	1	%EMPTY% 		1 ) ],
	    '::gen'		=>	[ qw(	0	0	1	%EMPTY% 		2 ) ],
	    '::bundle'	=>	[ qw(	1	0	1	WARNING_NOT_SET	3 ) ],
	    '::class'	=>	[ qw(	1	0	1	WARNING_NOT_SET	4 ) ],
	    '::clock'	=> 	[ qw(	1	0	1	WARNING_NOT_SET	5 ) ],
	    '::type'	=> 	[ qw(	1	0	1	%SIGNAL%		6 ) ],
	    '::high'	=> 	[ qw(	1	0	0	%EMPTY% 		7 ) ],
	    '::low'		=> 	[ qw(	1	0	0	%EMPTY% 		8 )],
	    '::mode'	=> 	[ qw(	1	0	1	%DEFAULT_MODE%	9 )],
	    '::name'	=> 	[ qw(	0	0	1	ERROR_NO_NAME	10 )],
	    '::shortname'	=> [ qw(	0	0	0	%EMPTY% 	11 )],
	    '::out'		=> 	[ qw(	1	0	0	%SPACE% 		12 )],
	    '::in'		=> 	[ qw(	1	0	0	%SPACE% 		13 )],
	    '::descr'	=> 	[ qw(	1	0	0	%EMPTY% 		14 )],
	    '::comment'	=>	[ qw(	1	1	2	%EMPTY% 		15 )],
	    '::default'	=>	[ qw(	1	1	0	%EMPTY% 		0 )],
	    '::debug'	=>	[ qw(	1	0	0	%NULL%	        0 )],
	    '::skip'	=>	[ qw(	0	1	0	%NULL% 	        0 )],
	    'nr'		=>	16, # Number of next field to print
	    '_mult_'	=> {},  # Internal counter for multiple fields
	    '_multorder_' => 0, # Sort order for multiple fields -> left to right increases
	    					# 1 / RL -> left to right decreasing
	    					# xF -> map the first to ::head:0 (defaults: ::head)	    
		},
    };

    #
    #	 hierachy sheet basic definition
    #
    $this->{'cfg'}{'hier'} = {
        'xls' => 'HIER', 	# Include all sheets matching this regular expression (after exclude)
		'xxls'	=> '',		# Exclude sheets matching this regular expression (before include)
		'comments' => '',	# Keep comments -> pre|predecessor post|successor
		'req' => 'mandatory', # Default: mandatory -> has to read HIER sheet
							# Other valid keys: "optional"
							# If set to "auto(_flat)", MIX will inherit
							# all instance names from the ::in/::out conn sheet and
							# map them to be daughter of "testbench" ....
		'parsed' => 0,
		'key' => '::inst', # Primary key to %hierdb
		'options' => 'overload', # Options for parsing this type
							#   [no]overload: allow to redefine values (e.g.
							#	for redefinition of ::lang through macros)
		'field' => {
	    #Name   	=>				Inherits from template
	    #								Multiple
	    #									Required
	    #										Defaultvalue
	    #													PrintOrder
	    #                           0   1   2	3			 4
	    '::ign' 		=>	[ qw(	0	0	1	%EMPTY% 	 1 )],
	    '::gen'			=>	[ qw(	0	0	1	%EMPTY% 	 2 )],
	    '::variants'	=>	[ qw(	1	0	0	Default	     3 )],
	    '::parent'	    =>	[ qw(	1	0	1	W_NO_PARENT	 4 )],
	    '::inst'		=>	[ qw(	0	0	1	W_NO_INST	 5 )],
	    '::lang'		=>	[ qw(	1	0	0	%LANGUAGE%	 7 )],
	    '::entity'		=>	[ qw(	1	0	1	W_NO_ENTITY	 8 )],
	    '::arch'		=>	[ qw(	1	0	0	rtl			 9 )],
	    '::config'	    =>	[ qw(	1	0	1	%DEFAULT_CONFIG% 11 )],
	    '::use'			=>	[ qw(	1	0	0	%EMPTY%		10 )],
	    '::udc'			=>	[ qw(	1	0	0	%EMPTY%		-1 )],
	    '::comment'	    =>	[ qw(	1	0	2	%EMPTY%	    12 )],
	    '::descr'	    =>	[ qw(	1	0	0	%EMPTY%	    13 )],
	    '::shortname'	=>	[ qw(	0	0	0	%EMPTY%	     6 )],
	    '::default'	    =>	[ qw(	1	1	0	%EMPTY%	     0 )],
	    '::hierachy'	=>	[ qw(	1	0	0	%EMPTY%	     0 )],
	    '::debug'	    =>	[ qw(	1	0	0	%NULL%	     0 )],
	    '::skip'		=>	[ qw(	0	1	0	%NULL% 	     0 )],
	    'nr'			=> 14,  # Number of next field to print
	    '_mult_'		=> {},  # Internal counter for multiple fields
	    '_multorder_' 	=> 0, # Sort order for multiple fields -> left to right increases
	    					# 1 / RL -> left to right decreasing
	    					# xF -> map the first to ::head:0 (defaults: ::head)	    

	    					# Regarding Print order: -1 -> print at end if defined in input!
							#                         0 -> do not print
							#                         all newly defined fields will be added at end
		},	    
	};
	
    $this->{'cfg'}{'variant'} = 'Default'; # Select default as default variant :-)

    #
    # IO sheet basic definitions
    # PAD is he primary key (but pad names might be added on demand)
    #
    #
    $this->{'cfg'}{'io'} = {
		'xls' => 'IO',		  # Include sheets (after exclude)
		'xxls'	=> '',		  # Exclude sheets (before include)
		'comments' => '',	  # Keep comments -> pre|predecessor post|successor
		'req' => 'optional',  # optional|mandatory
		'parsed' => 0,        # counter incremented by MIX
		'cols' => 0,
		'field' => {
	    	#Name   	=>		    	Inherits
	    	#					    		Multiple
	    	#						    		Required
	    	#							   			Defaultvalue
	    	#								    					PrintOrder
	    	#                           0   1   2	3				4
	    	'::ign' 		=>	[ qw(	0	0	1	%EMPTY% 		1 )],
	    	'::class'		=>	[ qw(	1	0	1	WARNING_NOT_SET	2 )],
	    	'::ispin'		=>	[ qw(	0	0	1	%EMPTY%			3 )],
	    	'::pin'			=>	[ qw(	0	0	1	WARNING_PIN_NR	4 )],
	    	'::pad'			=>	[ qw(	0	0	1	WARNING_PAD_NR	5 )],
	    	'::type'		=>	[ qw(	1	0	1	DEFAULT_PIN		6 )],
	    	'::iocell'		=>	[ qw(	1	0	1	DEFAULT_IO		7 )],
	    	'::port'		=>	[ qw(	1	0	1	%EMPTY%			8 )],
	    	'::name'		=>	[ qw(	0	0	1	PAD_NAME		9 )],
	    	'::muxopt'		=>	[ qw(	1	1	1	%EMPTY%	        10 )],
	    	'::comment'		=>	[ qw(	1	0	2	%EMPTY%	        11 )],
        	'::default'		=>	[ qw(	1	1	0	%EMPTY%			0 )],	    
	    	'::debug'		=>	[ qw(	1	0	0	%NULL%	        0 )],
	    	'::skip'		=>	[ qw(	0	1	0	%NULL% 	        0 )],
	    	'nr'			=> 12,  # Number of next field to print
	    	'_mult_'		=> {},  # Internal counter for multiple fields
	    	'_multorder_' 	=> 0, # Sort order for multiple fields -> left to right increases
	    					# 1 / RL -> left to right decreasing
	    					# xF -> map the first to ::head:0 (defaults: ::head)	    
		},
	};
	
    #
    # I2C sheet basic definitions
    #
    $this->{'cfg'}{'i2c'} = {
		'xls' => 'I2C',		# Include sheets
		'xxls' => '',	# Exclude sheets
		'comments' => '',	# Keep comments -> pre|predecessor post|successor
		'regmas_type' => 'VGCA', # format of register-master, currently either VGCA or FRCH
		'req' => 'optional',
		'parsed' => 0,
		'cols' => 0,
		'field' => {
	    	#Name   	=>	  	        Inherits
	    	#					            Multiple
	    	#						            Required
	    	#							            Defaultvalue
	    	#								                    PrintOrder
	    	#                           0   1   2	3           4
	    	'::ign' 		=> [ qw(	0	0	1	%EMPTY%     1  )],
	    	'::variants'	=> [ qw(	1	0	0	Default	    2  )],
	    	'::inst'        => [ qw(    0   0   1   W_NO_INST   3  )],
	    	'::width'		=> [ qw(	0	0	0	16          4  )],
	    	'::dev'         => [ qw(    0   0   1   %EMPTY%     5  )],
	    	'::sub'         => [ qw(    0   0   1   %EMPTY%     6  )],
	    	'::interface'   => [ qw(    0   0   1   %EMPTY%     7  )],
	    	'::block'       => [ qw(    0   0   1   %EMPTY%     8  )],
	    	'::dir'         => [ qw(    0   0   1   RW          9  )],
	    	'::spec'        => [ qw(    0   0   0   %EMPTY%     10 )],
	    	'::clock'       => [ qw(    0   0   1   %OPEN%      11 )],
	    	'::reset'       => [ qw(    0   0   1   %OPEN%      12 )],
	    	'::busy'        => [ qw(    0   0   0   %EMPTY%     13 )],
			'::sync'        => [ qw(    0   0   0   NTO         14 )],
			'::update'      => [ qw(    0   0   0   %OPEN%      15 )],
	    	'::readDone'    => [ qw(    0   0   0   %EMPTY%     16 )],
	    	'::b'		    => [ qw(	0	1	1	%OPEN%      17 )],
	    	'::init'        => [ qw(    0   0   0   0           18 )],
	    	'::rec'         => [ qw(    0   0   0   0           19 )],
	    	'::range'	    => [ qw(	1	0	0	%EMPTY%     20 )],
			'::auto'        => [ qw(    0   0   0   0           21 )],
	    	'::comment'	    => [ qw(	1	1	2	%EMPTY%     22 )],
	    	'::default'	    => [ qw(	1	1	0	%EMPTY%     23 )],
	    	'::clone'	    => [ qw(	1	0	0	1           24 )],
	    	'nr'			=> 25,  # Number of next field to print
	    	'_mult_'		=> {},  # Internal counter for multiple fields
	   		'_multorder_' 	=> 0, # Sort order for multiple fields -> left to right increases
	    					# 1 / RL -> left to right decreasing
	    					# xF -> map the first to ::head:0 (defaults: ::head)
		},
    };
    #
    # XML database basic definitions (input and output)
    #
    $this->{'cfg'}{'xml'} = 
      {
       'type'   => 'spirit',   # format of register-master, currently either VGCA or FRCH
       'req'    => 'optional', # optional|mandatory        
       'parsed' => 0           # counter incremented by MIX
      };
    
    # VI2C Definitions:
    # ::ign	::type	::width	::dev	::sub	::addr
    # ::interface	::block	::inst	::dir	::auto	::sync
    # ::spec	::clock	::reset	::busy	::readDone	::new
    # ::b	::b	::b	::b	::b	::b	::b	::b	::b	::b	::b
    # ::b	::b	::b	::b	::b	::init	::rec	::range	::view
    # ::vi2c	::name	::comment
    $this->{'cfg'}{'vi2c'} = {
		'xls' => 'VI2C',	# Include sheets
		'xxls' => '',		# Exclude sheets
		'req' => 'optional',
		'key' => '::inst',
		'parsed' => 0,
		'field' => {
	    	#Name   	=>	  	   		Inherits
	    	#					    		Multiple
	    	#						    		Required
	    	#							  		Defaultvalue
	    	#								    			PrintOrder
	    	#                           0   1   2	3       4
	    	'::ign' 		=> [ qw(	0	0	1	%NULL%	1 ) ],
	    	'::type'		=> [ qw(	0	0	1	%TBD% 	2 ) ],
	    	'::variants'	=> [ qw(	1	0	0	Default	3 )],
	    	'::inst'		=> [ qw(	0	0	1	W_NO_INST 4 )],
	    	'::comment'	    => [ qw(	1	0	2	%EMPTY%	6 )],
	    	'::shortname'	=> [ qw(	0	0	0	%EMPTY%	5 )],
	    	'::b'			=> [ qw(	0	1	1	%NULL%	7 )],
	    	'::default'	    => [ qw(	1	1	0	%NULL%	0 )],
	    	'::hierachy'	=> [ qw(	1	0	0	%NULL%	0 )],
	    	'::debug'	    => [ qw(	1	0	0	%NULL%	0 )],
        	'::default'		=> [ qw(	1	1	0	%EMPTY%	0 )],	    
	    	'::skip'		=> [ qw(	0	1	0	%NULL% 	0 )],
	    	'nr'			=> 8,  # Number of next field to print
	    	'_mult_'		=> {},  # Internal counter for multiple fields
   	    	'_multorder_' 	=> 0, # Sort order for multiple fields -> left to right increases
	    						# 1 / RL -> left to right decreasing
	    						# xF -> map the first to ::head:0 (defaults: ::head)
	    
		},
    };
    $this->{'cfg'}{'macro'} = {
	    "%SPACE%" 	=> ' ',
	    "%EMPTY%"	=> '',
	    "%NULL%"	=> '0',
	    "%TAB%"		=> "\t",
	    "%CR%"		=> "\n",	# A carriage return
	    "%S%"		=> "\t",	# Output field ident ....
	    "%IOCR%"	=> ' ',		# Will be set to \n if we are writting ExCEL on MSWin32 ...
		"%ACOM%"	=> '--',	# comment, automatically set by language currently
	    "%SIGNAL%"	=> 'std_ulogic',
	    "%BUS_TYPE%"	=> 'std_ulogic_vector',
	    "%PAD_TYPE%"	=> '__E_DEFAULT_PAD__',	# Default pad entity
	    "%PAD_CLASS%"	=> 'PAD',	# Default pad class
	    "%IOCELL_TYPE%"	=> '__E_DEFAULT_IOCELL__', # Default iocell entity
	    "%IOCELL_SELECT_PORT%"	=> '__I_default_select', 		# Default iocell port
	    "%NOSEL%"		=>  '__I_NOSEL__', #internal: no mux select
	    "%NOSELPORT%"	=>  '__I_NOSELPORT__', #internal: name of not used sel port
	    "%IOCELL_CLK%"	=>  'CLK', # Default clk for iocells, may be changed by %REG(clkb)
	    "%DEFAULT_MODE%"	=> 'S',
	    "%LANGUAGE%"	=> lc('VHDL'), # Default language, could be verilog
	    "%DEFAULT_CONFIG%"	=>	"%::entity%_%::arch%_conf",
	    "%NO_CONFIG%"	=>	"NO_CONFIG", # Set this in ::conf if you want to not
									    # get configurations for this instance
	    "%NO_COMPONENT_DECLARATION%"	=>	"__NOCOMPDEC__",
	    "%NO_COMP%"		=>	"__NOCOMPDEC__", # If this keyword is found in ::use -> no component decl ..
	    "%NCD%"			=>	"__NOCOMPDEC__", # dito.
	    "%VHDL_USE_DEFAULT%"	=>
			"library IEEE;\nuse IEEE.std_logic_1164.all;\n",
			# "Library IEEE;\nUse IEEE.std_logic_1164.all;\nUse IEEE.std_logic_arith.all;",
	    "%VHDL_USE%"	=> "-- No project specific VHDL libraries", #Used internally
	    "%VHDL_NOPROJ%"	=> "-- No project specific VHDL libraries", # Overwrite this ...
	    "%VHDL_USE_ENTY%"	=>	"%VHDL_USE_DEFAULT%\n%VHDL_USE%",
	    "%VHDL_USE_ARCH%"	=>	"%VHDL_USE_DEFAULT%\n%VHDL_USE%",
	    "%VHDL_USE_CONF%"	=>	"%VHDL_USE_DEFAULT%\n%VHDL_USE%",
	    "%VHDL_HOOK_ENTY_HEAD%"	=>	'', # Hooks for user defined text, see ::udc!
   	    "%VHDL_HOOK_ENTY_BODY%"	=>	'',
   	    "%VHDL_HOOK_ENTY_FOOT%"	=>	'',
   	   	"%VHDL_HOOK_ARCH_HEAD%"	=>	'',
   	   	"%VHDL_HOOK_ARCH_DECL%" =>	'',
   	    "%VHDL_HOOK_ARCH_BODY%"	=>	'',
   	    "%VHDL_HOOK_ARCH_FOOT%"	=>	'',
   	    "%VHDL_HOOK_CONF_HEAD%"	=>	'',
   	    "%VHDL_HOOK_CONF_BODY%"	=>	'',
   	    "%VHDL_HOOK_CONF_FOOT%"	=>	'',
   	    '%VHDL_HOOK_INST_PRE%'	=>	'',
   	    '%VHDL_HOOK_INST_APP%'	=>	'',
   	    '%HEAD%'	=> '__HEAD__', # Used internally for ::udc
   	    '%BODY%'	=> '__BODY__', # Used internally for ::udc
   	    '%FOOT%'	=> '__FOOT__', # Used internally for ::udc
   	    '%DECL%'	=> '__DECL__', # Used internally for ::udc	
	    '%VERILOG_TIMESCALE%'	=>	'`timescale 1ns/10ps',
	    '%VERILOG_USE_ARCH%'	=>	'%EMPTY%',
	    '%VERILOG_DEFINES%'	=>	'// No user `defines in this module',  # Want to define s.th. globally?
		'%VERILOG_HOOK_HEAD%'	=>	'',
		'%VERILOG_HOOK_BODY%'	=>	'',
		'%VERILOG_HOOK_PARA%'	=>	'',
		'%VERILOG_HOOK_FOOT%'	=>	'',
		'%VERILOG_HOOK_INST_PRE%' =>	'',
		'%VERILOG_HOOK_INST_APP%' =>	'',		
        '%INT_VERILOG_DEFINES%'     =>    '', # Used internally
        '%INCLUDE%'     =>  '`include',   # Used internally for verilog include files in ::use!
        '%DEFINE%'      =>  '`define',     # Used internally for verilog defines in ::use!
        '%USEASMODULENAME%'  =>    '',  # If set in ::config column and obj. is Verilog -> module name
        '%UAMN%'     	=> '',                     # dito. but shorter to write !! Internal use only !!
	    '%OPEN%'		=> 'open',			#open signal
	    '%UNDEF%'		=> 'ERROR_UNDEF',	#should be 'undef',  #For debugging??  
	    '%UNDEF_1%'		=> 'ERROR_UNDEF_1',	#should be 'undef',  #For debugging??
	    '%UNDEF_2%'		=> 'ERROR_UNDEF_2',	#should be 'undef',  #For debugging??
	    '%UNDEF_3%'		=> 'ERROR_UNDEF_3',	#should be 'undef',  #For debugging??
	    '%UNDEF_4%'		=> 'ERROR_UNDEF_4',	#should be 'undef',  #For debugging??
	    '%TBD%'			=> '__W_TO_BE_DEFINED',
	    '%HIGH%'		=> lc('MIX_LOGIC1'),  # VHDL does not like leading/trailing __
	    '%LOW%'			=> lc('MIX_LOGIC0'),  # dito.
	    '%HIGH_BUS%'	=> lc('MIX_LOGIC1_BUS'), # dito.
	    '%LOW_BUS%'		=> lc('MIX_LOGIC0_BUS'), # dito.
	    '%CONST%'		=> '__CONST__', # Meta instance, used to apply constant values
        '%BUS%'         => '__BUS__', # Meta instance for bus connections
	    '%TOP%'			=> '__TOP__',	# Meta instance, TOP cell
	    '%TOP_ENTY%'	=> 'W_NO_ENTITY', # Please redefine that if you want to use TOP_ENTY
	    '%TOP_CONF%'	=> 'mixtop_conf',
	    '%AUTOENTY%'	=> '_e',	# Extension for automatically created entities
	    '%AUTOCONF%'	=> '_struct_conf',	# Extension or automatically created configs
	    '%TESTBENCH%'	=> 'TESTBENCH', # Default name for testbench
	    '%PARAMETER%'	=> '__PARAMETER__',	# Meta instance: stores paramter
	    '%GENERIC%'		=> '__GENERIC__', # Meta instance, stores generic default
	    '%IMPORT%'		=> '__IMPORT__', # Meta instance for import mode
	    '%IMPORT_I%'	=> 'I', # Meta instance for import mode
	    '%IMPORT_O%'	=> 'O', # Meta instance for import mode
	    '%IMPORT_CLK%'	=> '__IMPORT_CLK__', # import mode, default clk
	    '%IMPORT_BUNDLE%'   => '__IMPORT_BUNDLE__', #
	    '%BUFFER%'		=> 'buffer',
        '%TRISTATE%'    => 'tristate',
	    '%H%'			=> '$',		# 'RCS keyword saver ...
	    '%IIC_IF%'      => 'iic_if_', # prefix for i2c interface
	    '%RREG%'        => 'read_reg_', # prefix for i2c read registers
	    '%WREG%'        => 'write_reg_', # prefix for i2c write registers
	    '%RWREG%'       => 'read_write_reg_', # prefix for i2c read-write registers
	    '%IIC_TRANS%'   => 'transceiver_', # prefix for i2c transceiver
	    '%IIC_SYNC%'    => 'sync_', # prefix for i2c sync block
		'%PREFIX_IIC_GEN%'	=> 'iic_if_', # DUPLICATE to postfix!!!
		'%POSTFIX_IIC_OUT%' =>  '_iic_o', # DUPLICATE!!
	    '%POSTFIX_IIC_IN%'  =>  '_iic_i', # DUPLICATE!!
        '%TPYECAST_ENT%' 	=> '__TYPECAST_ENT__', # dummy typecast support entity
        '%TYPECAST_CONF%'	=> '__TYPECAST_CONF__', # dummy for typecast ...
        '%TM_I%'		=>	'I',	# reverse mappings for seperate intermediate CONN_TOP sheet
        '%TM_O%'		=>	'O',
        '%TM_IO%'		=>	'IO',
        '%TM_B%'		=>	'B',
        '%TM_T%'		=>	'T',
        '%TM_C%'		=>	'C',
        '%TM_G%'		=>	'G',
        '%TM_P%'		=>	'P',
        '%REG%'			=>	'__REG__',	# Internal! Define a verilog reg for leaf output
        # '%WIRE%'		=>	'__WIRE__',	# Conflicts with simple logic wire!!
    };

	#!wig20060424: adding limits for log messages:
    $this->{'cfg'}{'log'}{'limit'} = {
    	're'	=> {},	# A. tags match RE here, no defaults, user defined
    	'tag'	=> {	# B. Tag default filter (individual tags)
    		'F'	=> 100,
    		'E'	=> 100,
    		'W'	=> 200,
    		'I'	=> 200,
    		'D'	=> 100,
    		'A'	=> 100,
    	},
    	'level' => {	# C. Level filter (all messages in this level)
						# MIXCFG log.limit.level.F|E|W|I|D|A... <count>
						# Default: -1 for F and E, 100 for W, 200 for I, 500 for A.
						# D is not limited, because debug messages are not logged anyway.
    		'F'	=>   -1,
    		'E'	=>   -1,
    		'W'	=>  500,
    		'I'	=> 1000,
    		'D'	=>   -1,
    		'A'	=> 2000,
    	},
    	'test' => {
    	},
    };
    
	# Misc. settings:
	$this->{'cfg'}{'top'} = '%TOP%';	# Define top cell for hierachy

    # Counters and generic messages    
    $this->{'cfg'}{'ERROR'} = '__ERROR__';
    $this->{'cfg'}{'WARN'} = '__WARNING__';
    $this->{'cfg'}{'CONST_NR'} = 0;   # Some global counters
    $this->{'cfg'}{'GENERIC_NR'} = 0;
    $this->{'cfg'}{'TYPECAST_NR'} = 0;
    $this->{'cfg'}{'HIGH_NR'} = 0;
    $this->{'cfg'}{'LOW_NR'} = 0;
    $this->{'cfg'}{'OPEN_NR'} = 0; # Count opens ...
    $this->{'cfg'}{'DELTA_NR'} = 0;
    $this->{'cfg'}{'DELTA_INT_NR'} = 0;
    $this->{'cfg'}{'DELTA_VER_NR'} = 0;
 
	# Count number of messages logged in the fatal/error/warn/... category
   	$this->{'cfg'}{'logs'}	= {
   			'info'	=> 0,
   			'debug'	=> 0,
			'warn'	=>  0,
			'error'  => 0,
			'fatal'	 => 0,
	};

    $this->{'cfg'}{'sum'} = { # Counters for summary
 
		## Inventory
		'inst'     => 0,	# number of instances
		'conn'     => 0,	# number of connections
		'port'     => 0,	# number of ports
		'genport'  => 0, 	# number of generated ports

		'cmacros'  => 0,	# number of matched connection macro's

    	'hdlfiles' => 0,    # number of output files
		'noload'   => 0,   	# signals with missing loads ...
		'nodriver' => 0,	# signals without driver
		'multdriver' => 0,	# signals with multiple drivers
		'openports' => 0,

		'checkwarn' => 0,
		'checkforce' => 0,
		'checkunique' => 0,

        # Others values (e.g. verify_entity ...) will be created as needed.

        # Number of generated IO cells:
        # see init function in MixIOParser
        # 'io_cellandpad'  => 0,
        # 'io_cell_single' => 0,
        # 'io_pad_single'  => 0,

    };

    $this->{'cfg'}{'script'} = { # Set for pre and post execution script execution
		'pre' => '',
		'post' => '',
		'excel' => {
			'alerts' => 'off', # Switch off ExCEL display alerts; could be on, too...
		},
    };
    # Definitions for file formats
    $this->{'cfg'}{'format'} = { # in - out file settings
		'csv' => {
        	'cellsep' => ';',        # cell seperator
        	'sheetsep' => ':=:=:=>', # sheet seperator, set to empty string to supress
        	'quoting' => '"',    # quoting character
        	'style'   => 'doublequote,autoquote,nowrapnl,maxwidth',  # controll the CSV output
               # doublequote: mask quoting char by duplication! Else mask with \
               # autoquote: only quote if required (embedded whitespace)
               # wrapnl: wrap embedded new-line to space
               # masknl: replace newline by \\n
               # maxwidth: make all lines contain maxwidth - 1 seperators
			'delta'   => 'DIFF:', # Value to prepend in CSV file to changed cell
			'sortrange' => 1,	# If set to 0, do not sort range selectors.
			'maxcelllength' => 0,
			'mixhead' => 1, # Print MIX header (date, who did it, ...)
				# Possible values: 1 | 0 -> print head or not
				#		extra: nomulthead  -> do not print secondary header line for multiple columns
		},
		'xls' => {
       		'maxcelllength' => 500, # Limit number of characters in ExCEL cells
 			'style'	=>	'',		# Format the generated output
 				# stripnl:	replace <nl> by <sp> (also known as 'wrapnl')
 				# masknl:	replace newline by \\n
 				# stripna:	replace all non ASCII-Chars by <sp>
 			'mixhead' => 1, # Print MIX header (date, who did it, ...)
		},
		'sxc' => {
       	    'maxcelllength' => 500, # Limit number of characters in sxc cells
 			'style'	=>	'',		# Format the generated output
 			'mixhead' => 1,  # Print MIX header (date, who did it, ...)
		},
		'ods' => {
			'maxcelllength' => 500, # Limit number of characters in sxc cells
			'style'	=>	'',		# Format the generated output
			'mixhead' => 1,	# Print MIX header (date, who did it, ...)
		},
       'out' => '',
    };
    
	$this->{'cfg'}{'report'} = {
		'path'	=> '.',
		'delta'	=> '',		# If set, create a diff file instead of a new output
		'portlist'	=> {
			'name'	=>	'',	# Define report file name; 
							# 	if empty take name from $EH{out} ....
							#   INST := name of last instance + _portlist.mif
							#	ENTY := name of last entity + _portlist.mif
			'ext'	=>	'mif',
			'data'	=>	'port', # Print out port names, not signal names!
			'split' =>	'external::extc,instance',
					# Generate seperate portlist for
					#	external : if column ::external has content
					#		external::foo : use column ::foo as trigger
					#	instance : generate a table for each instance
					#	file[::(INST|ENTY)]
					#			 : generate a file for each instance(*)/entity
					#				combine with 'name' = INST or ENTY!!
			'format' => { # Overwrite the built in format (t.b.d.)
				'plist' => '',
				'elist' => '',
			},
			'sort' =>	'input', # or alpha or ::col ....
					# pinlist sort order. See portmapsort
			'comments' => '0,striphash',
					# Limit the number of comment lines to N; 0 -> unlimited
					# To switch off all, set report.portlist.comments=''
					# striphash  := remove leading # signs from the comments
		},
		'reglist'	=> {
			'crossref' => 'yes',	# Print crossrefs, set to "no"
		}, 				
	};

	#
	# Generate some data dynamically
	#

    $this->{'cfg'}{'iswin'} = $^O =~ m,^mswin,io;
    $this->{'cfg'}{'iscygwin'} = $^O =~ m,^cygwin,io;

    $this->{'cfg'}{'cwd'} = cwd() || '__E_CANNOT_GET_CWD';
    if ( $this->{'cfg'}{'iswin'} ) {
        ( $this->{'cfg'}{'drive'} = $this->{'cfg'}{'cwd'} ) =~ s,(^\w:).*,$1/,;
    } else {
        $this->{'cfg'}{'drive'} = '';
    }

	# Store commandline
	$this->{'cfg'}{'macro'}{'%ARGV%'} = "$0 " . join( " ", @ARGV );
	# Make commented version (replace % -> __ )
	( $this->{'cfg'}{'macro'}{'%CARGV%'} = $this->{'cfg'}{'macro'}{'%ARGV%'} ) =~
			s/%/_MP_/g; # Remove % to prevent expansion ...

    $this->{'cfg'}{'macro'}{'%VERSION%'} = $::VERSION;
    $this->{'cfg'}{'macro'}{'%0%'} = $FindBin::Script;
    $this->{'cfg'}{'macro'}{'%OS%'} = $^O;
    $this->{'cfg'}{'macro'}{'%DATE%'} = "" . localtime();    # Time in human readable form
    $this->{'cfg'}{'macro'}{'%STARTTIME%'} = time();    # Save start time
    $this->{'cfg'}{'macro'}{'%USER%'} = "__E_UNKNOWN_USERNAME";
    if ( $this->{'cfg'}{'iswin'} or $this->{'cfg'}{'iscygwin'} ) {
		if ( defined( $ENV{'USERNAME'} ) ) {
	        $this->{'cfg'}{'macro'}{'%USER%'} = $ENV{'USERNAME'};
		}
    } elsif ( defined( $ENV{'LOGNAME'} ) ) {
		$this->{'cfg'}{'macro'}{'%USER%'} = $ENV{'LOGNAME'} || $ENV{'USER'};
    }

    #
    # Define HOME:
    #
    if ( $this->{'cfg'}{'iswin'} ) { # not valid for cygwin! -> HOME below ...
		if ( defined( $ENV{'HOMEDRIVE'} ) and defined( $ENV{'HOMEPATH'} ) ) {
	    	$this->{'cfg'}{'macro'}{'%HOME%'} = $ENV{'HOMEDRIVE'} . $ENV{'HOMEPATH'};
		}elsif ( defined( $ENV{'USERPROFILE'} ) ) {
            $this->{'cfg'}{'macro'}{'%HOME%'} = $ENV{'USERPROFILE'};
		} else {
	    	$this->{'cfg'}{'macro'}{'%HOME%'} = "C:\\"; # TODO is that a good idea?
		} 
    } elsif ( defined( $ENV{'HOME'} ) ) {
		$this->{'cfg'}{'macro'}{'%HOME%'} = $ENV{HOME};
    } else {
		$this->{'cfg'}{'macro'}{'%HOME%'} = "/home/" . $ENV{'LOGNAME'};
    }

    #
    # Define PROJECT path
    #
    if ( $ENV{'PROJECT'} ) {
		$this->{'cfg'}{'macro'}{'%PROJECT%'} = $ENV{'PROJECT'};
    } else {
		$this->{'cfg'}{'macro'}{'%PROJECT%'} = "__I_NO_PROJECT_SET";
    }
    #
    # Define WORKAREA path
    #
    if ( $ENV{'WORKAREA'} ) {
		$this->{'cfg'}{'macro'}{'%WORKAREA%'} = $ENV{'WORKAREA'};
    } else {
		$this->{'cfg'}{'macro'}{'%WORKAREA%'} = "__I_NO_WORKAREA_SET";
    }
    #
    # Set %IOCR% to \n if intermediate is xls and we are on Win32
    if ( ( $this->{'cfg'}{'iswin'} or $this->{'cfg'}{'iscygwin'} ) and
    		$this->{'cfg'}{'macro'}{'%ARGV%'}=~ m/\.xls$/ ) {
        $this->{'cfg'}{'macro'}{'%IOCR%'} = "\n";
    }

} # End of init

=head3 print(key) prints the text string

	print out the contents of a given key
	will print the reference if the referenced
	value is not a string. 

=cut

sub print ($$) {
	my $self = shift;
	my $key	 = shift;
	
	my $k = $self->_key_hash( $key );

	print "$k"; # TODO : convert to element ....
	
}

#
# (recursive) print of configuration options values
#
sub _return_conf ($$$) {
	my $self = shift;
    my $name = shift;
    my $ref = shift;

    my @conf = ();
    if ( ref( $ref ) eq "HASH" ) {
		foreach my $i ( sort( keys %$ref )  ) {
			# Start into recursion
	    	push( @conf, $self->_return_conf( $name . '.' .$i, $ref->{$i} ) );
		}
    } elsif ( ref( $ref ) eq "ARRAY" ) {
		return ( [ "MIXNOCFG", $name, "ARRAY" ] );
    } elsif ( ref( $ref ) eq "Micronas::MixUtils::ImportVerilogInclude" ) {
    	push( @conf, $ref->toconf() );
    } elsif ( ref( $ref ) )  {
    	#!wig20061115: return configuration ...
		return ( [ "MIXNOCFG", $name, ( "REF: " . ref( $ref ))  ] );
    } else {
    	# No HASH or ARRAY -> remove \t and \n and return
		$ref =~ s,\n,\\n,go;
		$ref =~ s,\t,\\t,go;
		return ( [ 'MIXCFG', $name, $ref ] );
    }
    return @conf;
}
    
#
# Recursively return all configuration parameters ....
#
sub conf2array ($) {
	my $self = shift;
		
    my @configs = ();
    # (Recursively) retrieve the configuration settings:
    foreach my $i ( sort ( keys( %{$self->{'cfg'}} ) )  ) {
		push( @configs, $self->_return_conf( $i, $self->{'cfg'}{$i} ));
    }
    # Now print the current configuration
    # foreach my $i ( @configs ) {
	#	print( join( ' ', @$i ) . "\n" );
    #}
	return( @configs );
}

1;

#!End
