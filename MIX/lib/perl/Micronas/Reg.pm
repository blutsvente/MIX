###############################################################################
#  RCSId: $Id: Reg.pm,v 1.93 2009/12/02 14:28:51 lutscher Exp $
###############################################################################
#                                  
#  Related Files :  <none>
#
#  Author(s)     :  Thorsten Lutscher                                      
#  Email         :  thorsten.lutscher@micronas.com                          
#
#  Project       :  MIX                                                 
#
#  Creation Date :  27.06.2005
#
#  Contents      :  Top-level register space class; represents register space
#                   of a device and contains register domains; also contains
#                   most of the user API for dealing with register spaces
#
###############################################################################
#                               Copyright
###############################################################################
#
#       Copyright (C) 2005-2008 Micronas GmbH, Munich, Germany 
#
#     All rights reserved. Reproduction in whole or part is prohibited
#          without the written permission of the copyright owner.
#
###############################################################################
#                                History
###############################################################################
#
#  $Log: Reg.pm,v $
#  Revision 1.93  2009/12/02 14:28:51  lutscher
#  added try_addrmap_name(), cleaned up view generation dispatcher table
#
#  Revision 1.92  2009/11/19 12:49:28  lutscher
#  added top-level table input and vi2c-xml view
#
#  Revision 1.91  2009/09/08 11:41:36  lutscher
#  added view rtf
#
#  Revision 1.90  2009/08/12 07:40:47  lutscher
#  changes for view hdl-urac-rs
#
#  Revision 1.89  2009/06/25 15:10:08  lutscher
#  added view hdl-ihb-rs
#
#  Revision 1.88  2009/06/15 11:57:25  lutscher
#  added addrmaps member to Reg and RegDomain
#
#  Revision 1.87  2009/03/26 12:47:14  lutscher
#  added view bd-cfg
#
#  Revision 1.86  2009/03/19 09:16:36  lutscher
#  added view ip-xact-rgm
#
#  Revision 1.85  2009/02/16 15:40:35  lutscher
#  rem.debug print
#
#  Revision 1.84  2009/02/10 15:36:19  lutscher
#  added input.domain feature
#
#  Revision 1.83  2009/02/04 13:13:08  lutscher
#  changed handling of IP-XACT spirit:addressUnitBits element, changed import of YAML module to use use_on_demand, added default clock/reset for IP-XACT input
#
#  Revision 1.82  2009/01/16 16:19:47  lutscher
#  fixed default value for sub column in write2excel()
#
#  Revision 1.81  2009/01/15 14:03:45  lutscher
#  moved view generation out of parse_register_master
#
#  Revision 1.80  2008/12/10 15:40:36  lutscher
#  changed order of packing,cloning
#
#  Revision 1.79  2008/12/10 13:09:24  lutscher
#  various changes to write2excel
#
#  Revision 1.78  2008/11/11 15:44:26  lutscher
#  export parse_register_master()
#
#  Revision 1.77  2008/10/17 14:02:12  lutscher
#  fixed map_ipxact with regards to reset values for fields
#
#  Revision 1.76  2008/08/25 11:32:05  lutscher
#  fixed illegal object method call line 1479
#
#  Revision 1.75  2008/08/22 10:40:29  lutscher
#  added reg_shell.domain_naming
#
#  Revision 1.74  2008/08/19 13:14:58  lutscher
#  added translation of illegal domain names
#
#  Revision 1.73  2008/07/31 09:05:21  lutscher
#  added packing/unpacking feature for register-domains
#
#  Revision 1.72  2008/07/24 15:46:37  herburger
#  changed write2excel to write additional fieldparameters to register master
#
#  Revision 1.71  2008/07/22 15:39:36  herburger
#  changed data dumping in init
#
#  Revision 1.70  2008/07/18 15:54:19  herburger
#  added Math::BigInt to _map_register_master and _map_ipxact to allow the processing of large registers
#  changes in _map_ipxact
#  changes in write2excel
#
#  Revision 1.69  2008/07/14 12:00:58  herburger
#  added intermediate data dumper for transformed IPXACT data to Method init
#
#  Revision 1.68  2008/07/09 11:55:21  herburger
#  use path from globals for write2excel and writeYAML
#
#  Revision 1.67  2008/07/07 17:09:59  herburger
#  added FindBin to use relative paths
#
#  Revision 1.66  2008/07/07 14:44:42  lutscher
#  added _clone_name call for register-names in write2excel
#
#  Revision 1.65  2008/07/07 14:23:13  lutscher
#  added %B option for _clone_name()
#
#  Revision 1.64  2008/07/03 13:16:55  herburger
#  small changes in writeYAML
#
#  Revision 1.63  2008/07/03 11:01:06  herburger
#  new method (writeYAML) added
#
#  Revision 1.62  2008/06/30 11:58:53  herburger
#  small changes in write2excel
#
#  Revision 1.61  2008/06/26 15:54:34  herburger
#  added rules to change the fieldname
#
#  Revision 1.60  2008/06/23 12:54:20  herburger
#  added write2excel method, for dumping .xml
#
#  Revision 1.59  2008/06/23 09:17:12  lutscher
#  moved portlist report to dedicated function because it does not use the register object
#
#  Revision 1.58  2008/06/18 10:04:58  lutscher
#  fixed error messages for when no RM file
#
#  [hist deleted]
#  
###############################################################################

package Micronas::Reg;

#------------------------------------------------------------------------------
# Used packages
#------------------------------------------------------------------------------
require Exporter;
@ISA=qw(Exporter);
@EXPORT  = qw(
              parse_register_master
             );

use strict;
use FindBin;
use Log::Log4perl qw(get_logger);
use Micronas::MixUtils qw( mix_use_on_demand $eh %OPTVAL);
use Micronas::MixReport qw(mix_reg_report);
use Micronas::MixParser qw(mix_store_db);
use Math::BigInt;
# rest gets loaded on demand ...

my $logger = get_logger('MIX::Reg');

#------------------------------------------------------------------------------
# Hook function to MIX tool. Called by mix main script. Creates a Reg object
# and calls its init() function
# Input: reference to register-master data struct, optionally a XML database
# Returns undef or a reference to the Reg object
# Note: this subroutine is not a class member
#------------------------------------------------------------------------------
sub parse_register_master {
	my $r_i2c = shift;
    my $r_xml = shift || []; 
    my $r_rm_top = shift || []; # new: top-level register-master

	if (scalar @$r_i2c or scalar @$r_xml) {
	
		# Load modules on demand ...
        # removed:  use XML::Simple;
        unless( mix_use_on_demand('
                                  use Data::Dumper;
                                  use Micronas::RegDomain;
                                  use Micronas::RegReg;
                                  use Micronas::RegField;
                                  use Micronas::RegViews;
                                  use Micronas::RegViewIHB;
                                  use Micronas::RegViewURAC;
                                  use Micronas::RegViewRTF;
                                  use Micronas::RegViewE;
                                  use Micronas::RegViewSTL;
                                  use Micronas::RegViewRDL;
                                  use Micronas::RegViewClone;
                                  use Micronas::RegPacking;
                                  use Micronas::MixUtils::RegUtils;
                                  use Micronas::RegViewIPXACT;
                                  use Micronas::RegViewBdCfg;
                                  use Micronas::RegViewVI2C;'
                                 ) ) {
			$logger->fatal( '__F_LOADREGMD', "\tFailed to load required modules for parse_register_master(): $@" );
			exit 1;
		}
    
        my ($view, $o_space);
         
        #
        # create a new register-space object from input
        #        
        
        # get handle to new register object
        $o_space = Micronas::Reg->new(device => $eh->get('reg_shell.device'));
        
        # init register object from register-master
        if (scalar @$r_i2c) {
            $o_space->init(	 
                           'inputformat'     => "register-master", 
                           'database_type'   => $eh->get('i2c.regmas_type'),
                           'register_master' => $r_i2c,
                           'rm_top'          => $r_rm_top
                          );
        };
        # $o_space->display(); exit;
        # add to register-object from XML database
        if (scalar @$r_xml) {
            $o_space->init(	 
                           'inputformat'    => "ip-xact", 
                           'database_type'  => $eh->get('xml.type'),
                           'data'           => $r_xml
                          );
        };
        
        # set debug switch
        $o_space->global('debug' => exists $OPTVAL{'verbose'} ? 1 : 0);
        
        # check if register object should be cloned before view generation
        if ($eh->get('reg_shell.clone.number') > 0 or $o_space->global->{'has_rm_top'} == 1) {
            my $o_new_space = $o_space->_clone(); # module RegViewClone.pm 
            $o_space = $o_new_space;
        };

        # apply packing-mode if desired
        if ($eh->get('reg_shell.packing.mode') ne "none") {
            my $o_new_space = $o_space->_pack();
            $o_space = $o_new_space;
        };
        return $o_space;
    } else {
        # only create errors if neither file is present
        if (!scalar @$r_i2c ) {
            my $severity = ($eh->get('i2c.req') =~ m/\bmandatory/ ? '__E_REG_INIT':'__I_REG_INIT');
            my $msg = "\tRegister-master file empty or sheet matching \'" . $eh->get('i2c.xls') . "\' not found in any input file";
            if ($severity =~ m/^__E/) {
                $logger->error($severity, $msg);
            } else {
                $logger->info($severity, $msg);
            };
        };
        if (!scalar @$r_xml) {
            my $severity = ($eh->get('xml.req') =~ m/\bmandatory/ ? '__E_REG_INIT':'__I_REG_INIT');
            my $msg = "\tXML file not present or empty";
            if ($severity =~ m/^__E/) {
                $logger->error($severity, $msg);
            } else {
                $logger->info($severity, $msg);
            };
        };
	};
	return undef;
};

#------------------------------------------------------------------------------
# Class members
#------------------------------------------------------------------------------
# this variable is recognized by MIX and will be displayed
our($VERSION) = '$Revision: 1.93 $ ';  #'
$VERSION =~ s/\$//g;
$VERSION =~ s/Revision\: //;

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
					   device          => "<no device specified>", # device identifier
					   domains         => [],           # list with RegDomain objects
					   addrmaps        => [],           # list with RegAddrMap objects
                       default_addrmap => "default",    # name of default addressmap
					   global => {
                                  # supported input formats
                                  supported_input_formats => ["register-master", "ip-xact"],
                                  
                                  # supported register-master types (yes, they are not all the same)
                                  supported_register_master_type => ["VGCA", "FRCH", "AVFB"], 
                                  
                                  # generatable register views (dispatch table)
                                  # note: the report functions that use the old top-level register-master format
                                  # are commented out for now
                                  supported_views => 
                                  {
                                   "hdl-vgch-rs" => \&_gen_view_vgch_rs,   # VGCH project register shell
                                   "hdl-ihb-rs"  => \&_gen_view_ihb_rs,    # IHB (internal host bus) register shell
                                   "hdl-urac-rs" => \&_gen_view_urac_rs,   # URAC (universal register access bus) register shell
                                   "rtf"         => \&_gen_view_rtf,       # Rich-Text-Format for documentation
                                   "e_vr_ad"     => \&_gen_view_vr_ad,     # e-language macros
                                   "stl"         => \&_gen_view_stl,       # register test file in Socket Transaction Language format
                                   "rdl"         => \&_gen_view_rdl,       # Denali RDL representation of database (experimental)
                                   "ip-xact"     => \&_gen_view_ipxact,    # IP-XACT compliant XML output
                                   "ip-xact-rgm" => \&_gen_view_ipxact,    # IP-XACT XML for OVM reg_mem package

                                   # note: the functions from MixReport have to be reworked because of the new top-level
                                   # register-master format; this has been done for "cheader"

                                   # "portlist"    => \&mix_reg_report,          # documents portlist in mif file
                                   # "reglist"     => \&mix_reg_report,      # documents all registers in mif file
                                   "cheader"     => \&mix_reg_report,      # generates c header files                                  
                                   # "per"         => \&mix_reg_report,      # creates Lauterbach per file
                                   "perl"        => \&mix_reg_report,      # creates perl package
                                   
                                   "bd-cfg"      => \&_gen_view_bdcfg,     # command file for backdoor configuration (first use in FRC project)
                                   "vi2c-xml"    => \&_gen_view_vi2c,      # Visual I2C definition file
                                   "none"        => sub {}                 # generate nothing (useful for bypassing the dispatcher)
                                  },

                                  # attributes in register-master that do NOT belong to a field
                                  # note: the field name is retrieved from the ::b entries of the register-master
                                  non_field_attributes => [qw(::ign ::sub ::interface ::inst ::width ::b:.* ::b ::addr ::dev ::vi2c ::default ::name ::type ::definition ::clone)],
                                  
                                  has_rm_top => 0, # flag whether a top-level register-master has been read

                                  # language for HDL code generation, currently only Verilog supported
                                  lang     => "verilog",
                                                                    
                                  debug    => 0, # debug switch                                 
                                  version  => $VERSION  # Version of class package
                                 }
                      };

	# init data members w/ parameters from constructor call
	foreach (keys %params) {
		$ref_member->{$_} = $params{$_};
	};
	
    # init default addrmaps list (if not passed in constructor)
    if (scalar @{$ref_member->{addrmaps}} == 0) {
        my $o_addrmap = Micronas::RegAddrMap->new(name => $ref_member->{default_addrmap});
        push @{$ref_member->{addrmaps}}, $o_addrmap;
    };
	bless $ref_member, $this;
};

#------------------------------------------------------------------------------
# Class Methods
#------------------------------------------------------------------------------

# initialize object with input; depending on inputformat, calls appropriate
# function to fill register space object
# note: NOT automatically called by constructor; adds to the object, does not clear it
# input: hash, depends on inputformat but has at least key "inputformat"
sub init {
	my $this = shift;
	my %hinput = @_;
	my ($datastring, $datastring_ipxact_1_4);

    if (scalar (@{$hinput{rm_top}})) {
        # if a top-level description table was given, use it to init the Reg object
        $this->global->{has_rm_top} = 1;
        $this->_map_top_level_rm($hinput{rm_top});
    };

    if (!grep ($_ eq $hinput{inputformat}, @{$this->global->{supported_input_formats}})) {
        _fatal("input_format \'", $hinput{inputformat},"\' not supported");
        exit 1;
    } else {
        if ($hinput{inputformat} eq "register-master") {
            # call mapping function for register-master array
            if (!grep ($_ eq $hinput{database_type}, @{$this->global->{supported_register_master_type}})) {
                _fatal("database_type \'",$hinput{database_type},"\' not supported");
                exit 1;
            };
            if (!$this->_map_register_master($hinput{database_type}, $hinput{register_master})) {
                _fatal("aborting due to errors");
                exit 1;
            };
        };

	
        if ($hinput{inputformat} eq "ip-xact") {
            $datastring=join("\n", @{$hinput{data}});#join each line of the data array into one string
            
            unless( mix_use_on_demand('
                     	    use XML::Twig;
			    use XML::LibXSLT;
			    use XML::LibXML;'	
                                      
                                     ) ) {
                _fatal( "Failed to load required modules for processing XML data: $@" );
                exit 1;
            };
            
            # check version of xml-data and convert it to the right version if possible
            if (!($datastring_ipxact_1_4=$this->_check_version($hinput{database_type},$datastring))){
                _error("input file not in the correct format");
                exit 1;
            }            
            
            #if xml-data has been transformed, dump data
            if ($datastring ne $datastring_ipxact_1_4){
                
                my $dumpfile=$eh->get('dump');
                $dumpfile =~s/\.pld$/-transformed_1_4\.xml/;
                $dumpfile=$eh->get('intermediate.path')."/".$dumpfile;
                
                open (XMLDUMP, ">".$dumpfile);
                _info ("transformed xml file written to $dumpfile");
                print XMLDUMP $datastring_ipxact_1_4;
                close (XMLDUMP);
            }
            
            # #  	    #check input against schema, not workint at the moment
            #  	    if(!$this->_check_schema($hinput{database_type},$datastring_ipxact_1_4)){
            #  		exit 1;
            #  	    }            
            
            # call mapping function for ip-xact (XML) database
            $this->_map_ipxact($hinput{database_type},$datastring_ipxact_1_4);
                        
        };
    };
    
	# $this->display()
};

# generate all views of the register space
sub generate_all_views {
    my $this = shift;
    my ($view, $o_space, @ldomains);
    
    # get user-supplied list of domains
    @ldomains = ();
    if (exists $OPTVAL{'domain'}) {
        push @ldomains, $OPTVAL{'domain'};
    }
   
    foreach $view (split(/,\s*/, $eh->get('reg_shell.type'))) {
        $this->generate_view($view, $this->global->{supported_views}, \@ldomains);
    };
};

# generate a view of the register space
# !! this is the HOOK FUNCTION to call view-generating-methods in other packages/modules !!
# it uses a reference to a dispatch table to make the method calls;
# if you want to add new generators, edit the dispatch table "supported_views"
sub generate_view {
	my $this = shift;
	my ($view_name, $href_dispatch_table, $lref_domains) = @_;

    my $action = $href_dispatch_table->{lc($view_name)};
    if (ref($action) eq "CODE") {
        $this->$action($view_name, $lref_domains); 
    } else {
        _error("unrecognized view name \'$view_name'\ (mix parameter reg_shell.type); currently supported views: ".join(", ", sort keys %$href_dispatch_table). ".");
    };
};

# temp. function
#sub _check {
#    my ($this) = @_;
#    my (@ldomains);
#    my ($o_domain, $o_reg, $o_field, $href);
#    
#	foreach $href (@{$this->domains}) {
#        push @ldomains, $href->{'domain'};
#    };
#    foreach $o_domain (@ldomains) {
#        my $domain = $o_domain->name;
#        open(LOG, ">check_$domain.log") || die;    
#        foreach $o_reg (@{$o_domain->regs}) {
#            foreach $href (@{$o_reg->fields}) {
#                $o_field = $href->{'field'};
#                if ($o_field->attribs->{'spec'} =~ m/w1c/i and $o_field->attribs->{'dir'} !~ m/rw/i) {
#                    print LOG "ATT (w1c not rw) ", $o_field->name, "\n";
#                };
#                if ($o_field->attribs->{'spec'} =~ m/w1c/i and $o_field->attribs->{'size'} != 1) {
#                    print LOG "ATT (w1c > 1 bit)", $o_field->name, "\n";
#                };
#            };
#        };      
#        close LOG;
#    };
#};

# scalar object data access method
sub device {
	my $this = shift;
	if (@_) { $this->{device} = shift @_; };
	return $this->{device};
};
# scalar object data access method
sub default_addrmap {
	my $this = shift;
	if (@_) { $this->{device} = shift @_; };
	return $this->{default_addrmap};
};

# class data access method
sub global {
	my $this = shift;
	if (@_) { 
		my %hinput = @_;
		foreach (keys %hinput) {
			# transfer key->value pairs from parameters to class data hash
			$this->{global}->{$_} = $hinput{$_};
		};
	};
	return $this->{global};
};

# helper function to link a domain object with an address offset into the register-space
# input: RegDomain object, offset value, [optionally] address-map name
sub add_domain {
    my ($this, $o_domain, $offset, $addrmap) = @_;
    if (!defined $offset) { $offset = 0 };
    if (!defined $addrmap) { $addrmap = $this->{default_addrmap} };
    my $o_addrmap = $this->get_addrmap_by_name($addrmap);
    if (defined $o_addrmap) {
        $o_addrmap->add_node($o_domain, $offset);
    } else {
       _error("add_domain(): unknown address map \'$addrmap\'");
    };
    if (!grep ($_ eq $o_domain, @{$this->domains})) {  # add only if not already there
        $this->domains($o_domain);
    };
};

# method to create a new address-map object
sub add_addrmap {
    my ($this, $name, $granularity) = @_;
    my $o_addrmap = Micronas::RegAddrMap->new(name => $name, granularity => $granularity);
    push @{$this->{addrmaps}}, $o_addrmap;
};

# get address-map matching $name or return undef
sub get_addrmap_by_name {
    my ($this, $name) = @_;
    my @ltemp = grep($_->name eq $name, @{$this->{addrmaps}});
    if (scalar @ltemp) {
        return $ltemp[0];
    } else {
        return undef;
    };
};

# check if the address-map name exists and return it or - if not passed as parameter - return default address-map name 
sub try_addrmap_name {
    my $this = shift;
    my $name = shift || "";
    my $valid = 0;

    if ($name ne "") {
        foreach my $o_addrmap (@{$this->{'addrmaps'}}) {
            if ($o_addrmap->name eq $name) {
                $valid = 1;
                last;
            };
        };
        if (!$valid) {
            _error("specified address-map name \'".$name."\' does not exist, using default");
        } else {
            return $name;
        };
    };
    
    # return default map name
    return $this->{'default_addrmap'};
};

# add single domain to the register space or return ref. to the list of domain hashes
# input: none or RegDomain object
sub domains {
	my $this = shift;
	if (@_) {
		push @{$this->{domains}}, @_;
	};
	return $this->{domains};
};

# finds first domain in list that matches name and returns the object (or undef)
# input: domain name
sub find_domain_by_name_first {
	my $this = shift;
	my $name = shift;
	my $result = (grep ($_->{name} eq $name, @{$this->domains}))[0];
	
	if (ref($result)) {
		return $result;
	} else {
		return undef;
	};
};

# finds domain definition in list that matches name and returns the object (or undef)
# input: domain name
sub find_domain_by_definition {
	my $this = shift;
	my $name = shift;
	my $result = (grep ($_->{definition} eq $name, @{$this->domains}))[0];
	
	if (ref($result)) {
		return $result;
	} else {
		return undef;
	};
};


# get baseaddr for a given domain name
# input: domain name, [optionally] address-map name
# output: baseaddr value (or undef)
sub get_domain_baseaddr {
	my ($this, $name, $addrmap) = @_;
    if (!defined $addrmap) { $addrmap = $this->{default_addrmap} };
    my $o_addrmap = $this->get_addrmap_by_name($addrmap);
    my $result = undef;
    if (defined $o_addrmap) {
        my $o_domain = $this->find_domain_by_name_first($name);
        if (defined $o_domain) {
            $result = ($o_addrmap->get_object_address($o_domain))[0];
        };
	};
    return $result;
};

# default display method
sub display {
	my $this = shift;
	my $dump  = Data::Dumper->new([$this]);
	$dump->Maxdepth(0);
	$dump->Sortkeys(1);
	print $dump->Dump;
};


#Iterates through all fields of a register and gives back the direction of the register or 0 if register direction is not homogenous
#input: Ref to a register
#output Register Direction or 0
sub get_register_direction_from_fields{
    my ($this, $o_register)=@_;
    my $field;
    
    my $direction=$o_register->{'fields'}[0]{'field'}{'attribs'}{'dir'};#direction of the first field

    #iterate through fields
    foreach $field (@{$o_register->{'fields'}}){
        my $o_field=$field->{'field'};
        
        if ($direction ne $o_field->{'attribs'}->{'dir'}){#if direction not equal to  direction of the first field return 0
            return 0;
        }
    };
    return $direction;
};

#Iterates through all registers and gives back the max registerwidth
#input: nothing
#output: maximum registerwidth
sub get_max_regwidth{
    my ($this) = @_;
    my $regwidth=0;
    my ($domain,$o_domain,$o_register);

    foreach $o_domain (@{$this->domains}){#iterate through domains   
        foreach $o_register (@{$o_domain->{'regs'}}){#iterate through register
            $regwidth=$o_register->{'attribs'}->{'size'} if ($o_register->{'attribs'}->{'size'}>$regwidth);
            
        }
    }
    
    return $regwidth;
}


#------------------------------------------------------------------------------
# Private methods
#------------------------------------------------------------------------------

# builds a register space object from a list in register-master format
# input: 1. string for input database type, accounts for different flavours of the register master
# 2. list of hashes, one for each row in the source sheet
# output: 1 if successful, 0 otherwise
# caveats: 
# two consecutive registers must have different names (::instance)
# two consecutive domains must have different names (::interface)
sub _map_register_master {
    my ($this, $database_type, $lref_rm) = @_;
    my($href_row, $marker, $rsize, $reg, $value, $fname, $fpos, $fsize, $domain, $offset, $msb, $msb_max, $lsb, $p, $new_fname, $usedbits, $baseaddr, $col_cnt, $rdefinition, $rclone, $o_tmp);
    my($o_domain, $o_reg, $o_field) = (undef, undef, undef);
    my($href_marker_types, %hattribs, %hdefault_attribs, $m);
    my $result = 1;
    my ($old_usedbits, $i);
    my ($ivariant, $icomment);
    
    $usedbits = Math::BigInt->new(0); ##LU BAUSTELLE		
    $usedbits = 0;

    # get defaults for field attributes from $eh 
    $href_marker_types = $eh->get( 'i2c.field' );
    foreach $m (keys %{$href_marker_types}) {
        next unless ($m =~ m/^::/); 
        # filter out everything that is not needed for fields
        if (!grep ($m =~ /^$_$/, @{$this->global->{non_field_attributes}})) { 
            my $m_new = $m;
            $m_new =~ s/^:://;  # get rid of the leading ::
            $hdefault_attribs{$m_new} = $href_marker_types->{$m}[3];
        };
    };
    
    # get comment and variant patterns
    $ivariant = $eh->get('input.ignore.comments');
    $icomment = $eh->get('input.ignore.variant') || '#__I_VARIANT';

    # set the spreadsheet column where to extract domain information
    # default: domain information is taken from '::interface' column
    my $domain_column = $eh->get('input.domain');

    # highest bit specified in register-master
    $msb_max = $eh->get( 'i2c._mult_.::b' ) || _fatal("internal error (bad!)");

    # iterate each row
    foreach $href_row (@$lref_rm) {
	
        # skip lines to ignore
        next if (
                 exists ($href_row->{"::ign"}) 
                 and ($href_row->{"::ign"} =~ m/${icomment}/ or $href_row->{"::ign"} =~ m/${ivariant}/o )
                );
        next if (!scalar(%$href_row));

        $col_cnt = 0;
        $msb   = 0;
        $fname = "";
        $fpos  = 0;
        $msb   = 0;
        $lsb   = 99;
        $rsize = $eh->get('i2c.field.::width')->[3];
        $rdefinition = "";
        %hattribs = %hdefault_attribs;
        $rclone = $eh->get('i2c.field.::clone')->[3];
	
        # parse all columns
        foreach $marker (keys %$href_row) {
            $value = $href_row->{$marker};
            $value =~ s/^\s+//; # strip whitespaces
            $value =~ s/\s+$//;
            if ($value =~ m/^0x[a-f0-9]+/i) { # convert from hex if necessary
                $value = hex($value);
            };
            if ($value =~ m/^h[a-f0-9]+/i and $marker eq "::sub" or $marker eq "::init" or $marker eq "::rec" or $marker eq "::width") {
                # account for hex number format hxx
                if ($value =~ m/^h[a-f0-9]+/i) {
                    $value = hex(substr $value, 1, length($value)-1);
                };
            };
            if ($marker eq "::sub") {
				# every row requires a ::sub entry, so I use it to skip empty lines
                goto next_row if ($value eq "");
                $offset = $value;
				# account for special meaning of sub column in AVFB project
                if ($database_type eq "AVFB") {
                    $offset = $offset * 2; # transform to byte address
                };
                next;
            };
            # domain is taken from "::interface" or "::dev" column
            if ($marker eq $domain_column) {
                $domain = $value;
                $domain =~ s/[\.\!\@\#\$\%\^\&\*\(\)]/_/g; # replace illegal characters with underscore
                next;
            };
            if ($marker eq "::inst") {
                $reg = $value; next;
            };
            if ($marker eq "::width") {
                $rsize = $value; next;
            };
            if ($marker =~ m/^::def/) {
                # note: in the register-master, the definition column is intended as an identifier to handle
                # multiple instances of a register; at the moment there is no way to handle multiple instances
                # of a field
                $rdefinition = $value; next;
            };
            if ($marker =~ m/^::clone/) {
                $rclone = $value; next;
            };
            if ($marker =~ m/^::dev/ and $this->device eq '%EMPTY%') {
                $this->device($value);
                next;
            };
            if ($marker =~ m/::b(:(\d+))*$/) {
                if (defined $2) {
                    $p = $msb_max - $2; # bit column numbering is reversed!
                } else {
                    $p = $msb_max;
                };
                if ($value =~ m/(.+)\.(\d+)/) { # <field_name>.<bit> for mult-bit fields
                    $fname = $1;
                    $fname =~ s/^\s+//; # strip whitespaces
                    $fname =~ s/\s+$//;
                    if ($2 <= $lsb) {
                        $lsb = $2;
                        $fpos = $p;
                    }
                    if ($2 > $msb) {
                        $msb = $2;
                    };
                    $col_cnt++;
                } else {
                    if ($value ne "") { # <field_name> for 1-bit fields
                        $fname = $value;
                        $fpos = $p;
                        $lsb = 0;
                        $msb = 0;
                        $col_cnt++;
                    };
                };
				# print "$marker $value [$msb:$lsb] fpos $fpos p $p\n";
                next;
            };

            # remaining markers can be processed anonymously
            $marker =~ s/^:://;
            if (exists ($hattribs{$marker}) and $value ne "") {
                $hattribs{$marker} = $value;
            };
        };
        $fsize = $msb - $lsb + 1;
        if ($fsize != $col_cnt) {
            _error("bad field \'$fname\' in register \'$reg\' in domain \'$domain\', must be continuous bit-slice");
            $result = 0;
        };

        # do not add "reserved" fields to database (boring)
        if (lc($fname) ne "reserved") {
            if (!ref($o_domain) or $domain ne $o_domain->name) {
				# check if domain already exists, otherwise create new domain
                $o_domain = $this->find_domain_by_name_first($domain);
                if (!ref($o_domain)) {
                    $o_domain = Micronas::RegDomain->new(name => $domain);
                    # get base-address, for what it's worth
                    $baseaddr = 0;
                    if ($database_type eq "VGCA") {
                        $baseaddr = hex("0x1ebc0000");
                    }; 
                    if ($database_type eq "FRCH" and $domain =~ m/_(\d+)$/) {
                        # in FRCH, they have pages of up to 256 Words each
                        $baseaddr = $1 << 8;
                    };
					
                    # link domain object into register space object
                    $this->add_domain($o_domain, $baseaddr);
                };
            };
			
            if (!ref($o_reg) or $reg ne $o_reg->name) {
				# add usedbits attribute to last register
                if (ref($o_reg)) {
                    $o_reg->attribs('usedbits' => $usedbits);
                    $usedbits = 0;
                };

				# check if register already exists in domain, otherwise create new register object
                $o_reg = undef;
                foreach $o_tmp ($o_domain->find_reg_by_address_all($offset)) {
                    if ($o_tmp->name eq $reg) {
                        $o_reg = $o_tmp;
                        last;
                    } else {
                        _warning("registers \'$reg\' and \'".$o_tmp->name."\' are mapped to the same address \'$offset\' in domain");
                        $o_reg = undef;
                    };
                };
                if (!ref($o_reg)) {
                    $o_reg = Micronas::RegReg->new('name' => $reg, 'definition' => $rdefinition);
                    $o_reg->attribs('size' => $rsize, 'clone' => $rclone);

                    # link register object into domain
                    $o_domain->add_reg($o_reg, $offset);
                };
            };

            # compute bit-mask for registes
            for ($i=$fpos; $i < $fpos+$fsize; $i++) {
                $old_usedbits = Math::BigInt->new($usedbits);
                my $one=Math::BigInt->new(1);
                $usedbits = $usedbits | $one->blsft($i);
				# check for overlapping fields in same register
		
                unless ($usedbits->bcmp($old_usedbits)) {
                    $result = 0;
                    _error("overlapping fields in register \'$reg\'");
                    last;
                }; 
            };
	    
            # clip init value to field size
            if (exists $hattribs{'init'} and $fsize < 32) {
                $hattribs{'init'} = $hattribs{'init'} & ((1<<$fsize)-1);
            };
            # create new field object
            $o_field = Micronas::RegField->new('name' => $fname, 'reg' => $o_reg);
            $o_field->attribs(%hattribs);
            $o_field->attribs('size' => $fsize, 'lsb' => $lsb);
			# $o_field->display(); # DEBUG
            # link field into domain
            $o_domain->fields($o_field);
			
            # link field into register
            $o_reg->fields(field => $o_field, pos => $fpos);
        };
      next_row:
    };

	# don't forget to add usedbits attribute to last register
	if (ref($o_reg) and $usedbits != 0) {
		$o_reg->attribs(usedbits => $usedbits);
		$usedbits = 0;
	};
    #$this->display();
	return $result;
};

# inits the register-space object from a top-level register-master
# creates the domain objects and address map;
# returns 0 if there were errors;
sub _map_top_level_rm {
    my $this = shift;
    my $lref_rm_top = shift;
    my $result = 1;

    my ($ivariant, $icomment, $domain, $definition, $id, $dclone, $dclone_addr_spacing, %hattribs, @laddr);
    my ($o_domain, $o_addrmap);

    _info("parsing top-level register-master");
    # get number of ::addr columns
    my $n_addrmaps = $eh->get( 'top_level._mult_.::addr' ) || _fatal("internal error (bad!), ::addr column(s) required in top-level register-master");
    
    # device name
    my $device = $eh->get('reg_shell.device');
    if ($device eq "") { $device = "ASIC"; }; # need a default

    # get comment and variant patterns for filtering
    $ivariant = $eh->get('input.ignore.comments');
    $icomment = $eh->get('input.ignore.variant') || '#__I_VARIANT';
    
    # iterate each row
    foreach my $href_row (@$lref_rm_top) {
        # skip lines to ignore
        next if (
                 exists ($href_row->{"::ign"}) 
                 and ($href_row->{"::ign"} =~ m/${icomment}/ or $href_row->{"::ign"} =~ m/${ivariant}/o )
                );
        next if (!scalar(%$href_row));
        
        $definition = "";
        $domain = "";
        @laddr = ();
        %hattribs = ();
        $dclone = 0;

        # collect all row data
        foreach my $marker (keys %$href_row) {
            my $value = $href_row->{$marker};
            $value =~ s/^\s+//; # strip whitespaces
            $value =~ s/\s+$//;
            
            # convert hex numbers
            if (grep ($marker =~ m/$_/, qw (::addr ::id ::awidth ::clones ::clone_spacing))) {
                if ($value =~ m/^0x[a-f0-9]+/i) { # convert from hex if necessary
                    $value = hex($value);
                } elsif ($value =~ m/^h[a-f0-9]+/i) { # account for hex number format hxx
                    $value = hex(substr $value, 1, length($value)-1);
                };
                if ($value eq "") { # set undefined cell values
                    $value = 0;
                };
            };
            
            # replace illegal characters with underscore
            if (grep ($marker =~ m/$_/, qw(::client ::definition ::profile))) {
                $value =~ s/[\.\!\@\#\$\%\^\&\*\(\)]/_/g;
            };
            
            if ($marker eq "::client") {
                $domain = $value; next;
            };
            if ($marker =~ m/^::def/) {
                $definition = $value;
                next;
            };
            if ($marker eq "::id") {
                $id = $value; next;
            };
            if ($marker =~ m/^::clones/) {
                $dclone = $value; next;
            };
            if ($marker =~ m/^::clone_spac/) {
                $dclone_addr_spacing = $value; next;
            };
            if ($marker =~ m/::addr(:(\d+))*$/) {   # ::addr is a multi-column
                if (defined $2) {
                    $laddr[$2] = $value;
                } else {
                    $laddr[0] = $value;
                };
                next;
            };
            # remaining markers can be processed anonymously and will be collect in hattribs
            $marker =~ s/^:://;
            if (!exists ($hattribs{$marker}) and $value ne "") {
                $hattribs{$marker} = $value;
            };
        };
        
        if ($domain ne "") {
            # check if domain (instance) already exists, otherwise create new domain            
            $o_domain = $this->find_domain_by_name_first($domain);
            if (!ref($o_domain)) {
                $o_domain = Micronas::RegDomain->new(name => $domain, id => $id, definition => $definition, attribs => {%hattribs});
                # store some cloning information (note: the cloning itself is done in a later step,
                # also using config parameters)
                $o_domain->clone(number => $dclone, addr_spacing => $dclone_addr_spacing);
            };
            
            # link domain into address-maps (and create address-maps on the way if necessary)
            my $i=0;
            my $addrmap_name;            
            foreach my $addr (@laddr) {
                $addrmap_name = join("_", "amap", $device, $i);
                $i++;
                $o_addrmap = $this->get_addrmap_by_name($addrmap_name); 
                if (!ref($o_addrmap)) {
                    $this->add_addrmap($addrmap_name, 1);
                    if ($i == 1) { # use first address-map as default
                        $this->{'default_addrmap'} = $addrmap_name;
                    };
                    _info("created new address map \'$addrmap_name\'".($i==1 ? " (is new default address-map)" : ""));
                };
                $this->add_domain($o_domain, $addr, $addrmap_name);
            };
        };
    };
    # $this->display();
    return $result;
};


# sub _test_object{
#     my $this=shift;
#     my ($database_type, $data)=@_;


#     my $o_domain=Micronas::RegDomain->new(name => "DOMAINNAME");
#     $this->domains('domain' => $o_domain, 'baseaddr' => 15637248);

#     my $o_register=Micronas::RegReg->new(name => "REGISTERNAME");
#     $o_domain->regs($o_register);
#     $o_domain->addrmap(reg => $o_register, offset => 32);
    
#     my $o_field=Micronas::RegField->new(name => "FIELDNAME");
#     $o_register->fields('field'=>$o_field, 'pos' => 2);
		    
#     #add registerreference to field
#     $o_field->reg($o_register);
	
#     #link field object into domain
#     $o_domain->fields($o_field);
    
    
#}


# builds a register space object from XML format
# input: 1. string for input database type
# 2. String with XML-Data
# output: 1 if successful, 0 otherwise

sub _map_ipxact{
    my ($this)=shift;
    my ($database_type, $datastring)=@_;
    my (%domains, %registers, @registerindomain, @fieldinregister, $domain_register_field, $i);
    my ($tmpfield, $encoding);
    
    
    #use bigint;
    
    
    #use Encode;
    #$datastring = decode_utf8( $datastring );

    #####################################################################
    # TWIG Handlers Subroutines
    #####################################################################
    my $ipxact_domain=sub {
        my ( $twig, $elt )= @_; 
        my ( $domainname,$baseaddr,@registers,$register, $range, $width, $bitsinUnit);
        my ( $o_domain);
	
        ###########DOMAIN###########
        #get domainname and baseaddress
        $domainname = $elt->first_child('spirit:name')->text;
        $domainname =~ s/[\.\!\@\#\$\%\^\&\*\(\)]/_/g; # replace illegal characters with underscore
        $baseaddr = $elt->first_child('spirit:baseAddress')->text;
        $baseaddr = oct($baseaddr) if $baseaddr =~ m/^0/; # converts hex or oct into dec
	
        #create new domain
        $o_domain = Micronas::RegDomain->new(name => $domainname);

        #get addresswidth datawidth
        $range = $elt->first_child('spirit:range')->text; #2^$range
        $range = oct($range) if $range =~ m/^0/;
        $range = log($range)/log(2); #get range
        $width = $elt->first_child('spirit:width')->text;
	
        $eh->set('reg_shell.addrwidth',$range);
        $eh->set('reg_shell.regwidth',$width);
	
	
        #add domain to reg-object
        $this->add_domain($o_domain, $baseaddr);

	
        ###########REGISTERS###########
        #find register that belong to this domain

        @registers=$elt->children('spirit:register');
	
        #iterate through all registers
        foreach $register (@registers) {
            my ($registername, $offset,@fields, $field, $clone, $rsize, $usedbits, $registerreset, $rdescription);
            my ($o_register);

            $registername =  $register->first_child('spirit:name')->text;
            $offset = $register->first_child('spirit:addressOffset')->text;
            $offset=oct($offset) if $offset =~ m/^0/; #converts hex or oct into dec

            #create new register object
            $o_register = Micronas::RegReg->new(name => $registername);

            #get register description
            $rdescription = "";
            $rdescription = $register->first_child('spirit:description')->text if ($register->first_child('spirit:description'));

            $o_register->definition($rdescription);

            #link register object into domain
            $o_domain->add_reg($o_register, $offset);

            ###########register attributes

            #cloning information
            $clone=$eh->get('i2c.field.::clone')->[3];

            if ($register->children_count('spirit:parameters')) { #parameters exist
                my @registerparameters=$register->first_child('spirit:parameters')->children('spirit:parameter'); #list of all parameters

                foreach (@registerparameters) { #iterate through all parameters
		   
                    # 		    if ($parametername->text eq 'clone'){
                    # 			$clone=$parametername->next_sibling('spirit:value')->text;
			
                    # 		    }
                    my $parameter=$_->first_child('spirit:name');
                    my $parametername=$parameter->text;
                    my $parametervalue=$parameter->next_sibling('spirit:value')->text;
                    if ($parametername eq 'clone') {
                        $clone=$parametervalue;
                        next;
                    }
                    $o_register->attribs($parametername => $parametervalue);
                }
            }
            $o_register->attribs(clone => $clone);
	    
            #register size
            $rsize=$register->first_child('spirit:size')->text;

	    
            $usedbits=Math::BigInt->new(0);
	    
            #add atrributes to register
            $o_register->attribs(size => $rsize);
	    
            ###########FIELDS###########
            #find fields that belong  to this register/domain
            @fields=$register->children('spirit:field');
	    
            #iterate through all fields
            foreach $field (@fields) {
                my ($fieldname, $position, $fsize, $description, $reset, %access, %prettynames, @fieldparameters, $parameter, $frange);
                my ($o_field);

                $fieldname=$field->first_child('spirit:name')->text;
                $position=$field->first_child('spirit:bitOffset')->text;
                $position=oct($position) if $position =~ m/^0/; #converts hex or oct into dec

                #create new field object
                $o_field=Micronas::RegField->new(name=>$fieldname);

                #link field object into register/domain
                $o_register->fields(field=>$o_field,pos=>$position);
                $o_domain->fields($o_field);
                $o_field->reg($o_register);

                ############field attributes
                %access=reverse(%{$eh->get('xml.access')});
                %prettynames=reverse(%{$eh->get('xml.prettynames')});

                $description=$field->first_child('spirit:description')->text if $field->first_child('spirit:description');
		

                $fsize=$field->first_child('spirit:bitWidth')->text;
		

                $frange="0..".(2**$fsize-1);

                #field reset value
                $registerreset=$register->first_child('spirit:reset')->first_child('spirit:value')->text if ($register->first_child('spirit:reset'));
                $registerreset=Math::BigInt->new($registerreset)->as_int(); #for big integer number support
		
                # obtain the reset value of the field from the registers
                $reset=unpack("B32", pack("N", $registerreset>>$position)); #get resetvalue of register in binary shifted by position
                $reset=substr($reset,length($reset)-$fsize,$fsize); #field reset value
                $reset=unpack("N", pack("B32", substr("0" x 32 . $reset, -32))); #bin->dec
                $o_field->attribs(init=>$reset);
                
                # add other attributes; note: currently I don't know where the field clock/reset are specified in IP-XACT,
                # therefore we use default parameters
                $o_field->attribs(comment=>$description, clock => $eh->get('xml.clock'), reset => $eh->get('xml.reset'));
                $o_field->attribs(dir=>$access{$field->first_child('spirit:access')->text});
                $o_field->attribs(range=>$frange,size=>$fsize);
                #put remaining paramters to attributes
                @fieldparameters=();
                (@fieldparameters=$field->first_child('spirit:parameters')->children('spirit:parameter')) if ($field->first_child('spirit:parameters'));
		
                foreach $parameter (@fieldparameters) {
		    
                    my $parametername=$parameter->first_child('spirit:name')->text;
                    next if (grep($_ eq $parametername,@{$eh->get('xml.field_skipelements')}));
                    my $parametervalue=$parameter->first_child('spirit:value')->text;  
                    ($parametername=$prettynames{$parametername}) if (exists $prettynames{$parametername});
		    
                    #if access value equal write-1-to-clear write W1C to spec
                    if (lc($parametervalue) eq 'write-1-to-clear' and lc($parametername) eq 'access') {
                        $parametername="spec";
                        $parametervalue="W1C";
                        if ($o_field->{'attribs'}->{'spec'}) {
                            $parametervalue=$o_field->{'attribs'}->{'spec'}.",W1C";
                        }

                    }
                    # get reset value from field parameters
                    if (lc($parametername) eq 'value') {
                        $parametername = "init";
                        $parametervalue = hex($parametervalue) if ($parametervalue =~ m/^0x[a-f0-9]+/i); # convert from hex if necessary
                        $parametervalue = hex(substr $parametervalue, 1, length($parametervalue)-1) if ($parametervalue =~ m/^h[a-f0-9]+/i); # account for hex number format hxx
                    };
                    $o_field->attribs($parametername=>$parametervalue);
                };

                #add remaining fieldattributes with default values
                my %fieldattribs_default=%{$eh->get('i2c.field')};
                my $i;

                foreach $i (keys %fieldattribs_default) {
                    next unless ($i =~ m/^::/);
                    next if (grep($_ eq $i,@{$this->{'global'}->{'non_field_attributes'}}));
                    $i=~s/:://;
                    unless ( grep ($i eq $_,keys %{$o_field->{'attribs'}})) {
			
                        $o_field->attribs($i => $fieldattribs_default{"::".$i}[3]);
                    }
                }
	       
                unless (grep ($_ eq 'view' ,keys %{$o_field->{'attribs'}})) {
                    $o_field->attribs(view => 'Y');
                }

                #calculate usedbits
                for ($i=$position;$i<$position+$fsize;$i++) {
                    $usedbits->badd(2**$i);
		    
                }

            }
            $o_register->attribs(usedbits=>$usedbits);
	    
        }
	
        $twig->purge();         #free memory
    };

    #Handler to get the AddressunitBits field
    my $ipxact_addressunitbits = sub {
        my ( $twig, $elt )= @_; 
        my ( $bitsinUnit);

        $bitsinUnit=$elt->text;
        # ##LU the addressUnitBits element defines the number of data bits in each address increment of the address space,
        # so it is not the same as reg_shell.datawidth
        # $eh->set('reg_shell.datawidth',$bitsinUnit);
        if ($bitsinUnit != 8) {
            _warning("MIX does not support address increments other than 8-bit, but spirit:addressUnitBits specifies $bitsinUnit"); 
        };

        $twig->purge();         #free memory
    };
    


    #####################################################################
  

    my $twig=XML::Twig->new(twig_handlers =>
                            {
                             'spirit:addressBlock' => $ipxact_domain, #domain 
                             'spirit:addressUnitBits' => $ipxact_addressunitbits,
                            }
                           );   #create new Twig Object

    _info("start parsing XMLfile");
    if (!$twig->parse($datastring)) { #parse XMLString
        _error("parsing failed!");
        return 0;
    }
    ;

    $encoding = $twig->encoding()||"utf-8"; #get encoding
    $eh->set('xml.characterencodingin',$encoding);

    $twig->purge();             #Free memory


  
   
    #$this->display();
	

}
;

# checks if the XML-Data is in the right version, if not it tries to convert it to the right version
# input: 1. databasetype 
# 2. datastring with xml
# output: 0 if not in the correct format and not convertable to correct format
# or datastring in the correct format


sub _check_version{
    my ($this)=shift;
    my ($database_type, $datastring)=@_; 
    my ($ipxact_version,$ipxact_version_main, $ipxact_version_sub);
    
    #####################################################################
    # TWIG Handlers Subroutines
    #####################################################################
    my $rootelement = sub{
	my ( $twig, $elt )= @_; 
	my ($namespace, $ns_prefix);
	$namespace = $elt->namespace;
	$ns_prefix = $elt->ns_prefix;
	
	#check if xml is in ipxact format
	if ($ns_prefix eq 'spirit' and $namespace =~ m#http://www.spiritconsortium.org/XMLSchema/SPIRIT/#){
	    #is in IP-XACT format
	    
	    #check the version
	    $namespace =~ m#http://www.spiritconsortium.org/XMLSchema/SPIRIT/(\d\.\d)#;
	    $ipxact_version=$1;
	    $ipxact_version =~ m/(\d)\.(\d)/;
	    $ipxact_version_main=$1;
	    $ipxact_version_sub=$2;
	    
	    
	}else{
	    #not IP-XACT
	    $ipxact_version=0;
	}

	$twig->purge();#free memory
    };
    #####################################################################

    my $twig=XML::Twig->new(twig_handlers =>
			    {
				'level(0)' => $rootelement#matches root-element
				    
			    }
	);#create new Twig object    
    
    _info("checking version info");
     

    if (!$twig->parse($datastring)){#parse XMLString
	_error("parsing failed!");
	return 0;
    };

    my $xsltpath=$eh->get('xml.xslt_dir');#path to xslt files
    unless (-r $FindBin::Bin.$xsltpath){
	$xsltpath='/..'.$xsltpath;#maybe here
    }
   
    if ($ipxact_version eq "1.4"){#input IP-XACT 1.4
	_info("input file in IP-XACT 1.4 format");
	return $datastring;#return datastring unchanged

    }elsif ($ipxact_version == 0){#input not in ipxact format
	_info("input file not in IP-XACT format");
	return 0;#return 0
	
    }elsif ($ipxact_version =~ m/\d\.\d/){#input in other version
	_info("input file in IP-XACT $ipxact_version format");

	#try to transform into IP-XACT 1.4
	my $updatefile=$FindBin::Bin.$xsltpath."from".$ipxact_version."_to_1.4.xsl";
	
	if (-e $updatefile){
	    my ($parser, $xslt, $source, $style_doc, $stylesheet, $results, $result);
	    
	    #XSLTransformation
	    $parser = XML::LibXML->new();#new LibXML object
	    $xslt = XML::LibXSLT->new();#new LibXSLT object

	    $source = $parser ->parse_string($datastring);
	    $style_doc = $parser -> parse_file($updatefile);

	    $stylesheet = $xslt->parse_stylesheet($style_doc);

	    $results = $stylesheet->transform($source);
	    $result = $stylesheet->output_string($results);
	    
	    $result=~s#http://www.spiritconsortium.org/XMLSchema/SPIRIT/$ipxact_version#http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.4#g;

	    _info("file transformed from IP-XACT $ipxact_version to IP-XACT 1.4");
	    
	    return $result;

	}elsif(-e $FindBin::Bin.$xsltpath."from".$ipxact_version."_to_".$ipxact_version_main.".".++$ipxact_version_sub.".xsl"){
	    my ($parser, $xslt, $source, $style_doc, $stylesheet, $results, $result);
	    
	    #XSLTransformation
	    $parser = XML::LibXML->new();#new LibXML object
	    $xslt = XML::LibXSLT->new();#new LibXSLT object

	    $source = $parser ->parse_string($datastring);
	    $style_doc = $parser -> parse_file($FindBin::Bin.$xsltpath."from".$ipxact_version."_to_".$ipxact_version_main.".".$ipxact_version_sub.".xsl");
	    
	    $stylesheet = $xslt->parse_stylesheet($style_doc);

	    $results = $stylesheet->transform($source);
	    $result = $stylesheet->output_string($results);
	    
	    $result=~s#http://www.spiritconsortium.org/XMLSchema/SPIRIT/$ipxact_version#http://www.spiritconsortium.org/XMLSchema/SPIRIT/$ipxact_version_main.$ipxact_version_sub#g;

	    _info("file transformed from IP-XACT $ipxact_version to IP-XACT $ipxact_version_main.$ipxact_version_sub");
	    

	    #call _check_version recursively
	    $result=$this->_check_version($database_type,$result);
	    
	    return $result;
	}
	else{
	    _error("couldn't find an updatefile");
	    return 0;
	}
	    

    }
    
};
# validate the xml datastring against the schema
# input: 1. database type
# 2. datastring with xml-Data
# output: 1 if successfull 0 otherwise
# doesn't work at the moment, because XML::Validate::Xerces Modul isn't supported, maybe in the future

# sub _check_schema{
#     my ($this)=shift;
#     my ($database_type, $datastring)=@_; 
#     my ($validator,%error ,$schemafile);
    
#     eval {use XML::Validate::Xerces;};
#     die("could not find module XML::Validate::Xerces in _check_schema") if $@ ne "";

#     _info('checking file against Schema');

#     my $schemapath=$eh->get('xml.schema_dir');#path to schema files
    
    
#     unless (-r $FindBin::Bin.$schemapath){
# 	$schemapath='/..'.$schemapath;#maybe here
#     }
#     $schemafile=$FindBin::Bin.$schemapath."index.xsd";#schema

#     $datastring =~ s#http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.4/\w+\.xsd#$schemafile#gi;#substitute URL with local path to schema (doesn't work with URL)

#     $validator = new XML::Validate::Xerces();
    
#     if ($validator->validate($datastring)) {
# 	_info('XML-File is valid');
# 	$datastring =~ s#$schemafile#http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.4/index.xsd#gi;#substitute back
# 	return 1;
#     } else {
# 	$datastring =~ s#$schemafile#http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.4/index.xsd#gi;#substitute back
	
# 	%error= %{$validator->last_error()};
# 	_error($error{'message'}." in line ".$error{'line'}." column ".$error{'column'});
# 	return 0;
#     }


#};


# writes a excel file out of a Micronas::Reg Object
# input: 1. dumpfile to write excel to 
# output: 1 if successfull 0 otherwise

sub write2excel{
    my $this=shift;
    my ($dumpfile)=@_;

    my ( $workbook, $worksheet, $worksheetname, %columns, $i, $maxregisterwidth, $rowcounter, $registercounter,$columns_size,);
    my ($o_domain,$domain, $o_register,$o_field,$field,$domainname, $registername, $registeroffset,$registerwidth, $fieldname);
    
    my @skipparameter=('size', 'lsb');# parameters to skip when generating additional columns for register-master

    # import needed Modules
    unless( mix_use_on_demand('use Spreadsheet::WriteExcel;') ) {
	_fatal( "Failed to load required modules for dumping XML data to Excel: $@" );
	exit 1;
    }
    
    # get the path, to the tmp_excelfile
    $dumpfile =~ s/\.xml$/.xls/;#change xml file extension to xls
    $dumpfile = $eh->get('intermediate.path').'/'.$dumpfile;
    
    
    # create new excel file
    _info("start writing to Excel File: $dumpfile");
    
    if (!($workbook = Spreadsheet::WriteExcel->new($dumpfile))){
        _error( "Problems creating new Excel file: $!");
        return 0;
    }

    # get worksheet name
    $dumpfile =~ m/(\w+)-mixed\.xls$/;
    $worksheetname=$1;
    $worksheetname=substr($worksheetname,0,31);#sheetname can only be 31 characters long
    
    

    # Add a worksheet
    $worksheet = $workbook->add_worksheet($worksheetname);

    # Describes pre-defined columns with identifier => [column name, column description, position, comment, col-width, defaultvalue, sub that returns data for 
    # that column]; the position can be changed by user using parameter intermediate.xls_columns (see below and Globals.pm)
    # note: this is somehow redundant because there is cfg.i2c in Globals.pm; need to clean-up later and use a more OO approach for attributes in general
    %columns=(
          'ign'=>["::ign","#",0,"Ignore. If cell contains '#', row will be ignored.",6.57,"",sub {"";}],
	      'type'=>["::type","Register Type",1,"Not used (!?). Default is 'I2C'.",8.57,"I2C",sub {"I2C";}],
	      'dev'=>["::dev","Device Address",2,"Symbolic device (chip) address for board-level I2C bus.",8.57,"%EMPTY%",sub {return $this->{'device'};}],
	      'width'=>["::width","Register Width",3,"Width of HDL implementation of register. Default is 32.",6.14,$eh->get('reg_shell.regwidth'),sub {$registerwidth}],
	      'sub'=>["::sub","rel. Address",4,"Address offset of register in domain/register-shell. The 2nd meaning (with different value) is physical address for board-level I2C bus.",8.14,0,sub {$registeroffset;}],
	      'interface'=>["::interface","Domain Name",5,"Register domain name. Each domain has its register-shell implementation assigned to.",8.14,"%EMPTY%",sub {$domainname;}],
	      'inst'=>["::inst","Register Name",6,"Register name; Default is concatenation of ::block and ::sub but can be changed to have something more meaningful. Note: must be unique within one domain",13.43,"W_NO_INST",sub {$registername;}],
	      'dir'=>["::dir","Write / Read",7,"Bitfield access attribute from software point of view. One of R (read-only), W (write-only), RW (read or write). Note: If possible, do not assign different values for bitfields within one register.",8.57,"RW",sub {$o_field->{'attribs'}->{'dir'};}],
	      'spec'=>["::spec","Special Type",8,"Special bitfield attribute(s). If more than one, separate by ',' or ';'. Supported are at least:
SHA - shadowed field (also has ::update and ::sync column)
W1C - write-one-to-clear (typically IR status register)
USR - the register access is forwarded to the backend-logic; typically RAM-ports, special registers (used for HDL implementation)",8.57,"%EMPTY%",sub {$o_field->{'attribs'}->{'spec'};}],
	      'update'=>["::update","Update Enable",9,"One of Y or N. Specifies whether the shadowing of a bitfield is controlled by enable/force signals. Note: requires ::spec = SHA",6.14,"%OPEN%",sub {$o_field->{'attribs'}->{'update'};}],
	      'sync'=>["::sync","Update Signal",10,"Name of the signal that triggers a shadow update of the bitfield (for HDL implementation). This signal can e.g. be vertical-sync.",8.57,"NTO",sub {$o_field->{'attribs'}->{'sync'};}],
	      'clock'=>["::clock","Clock Domain",11,"Clock signal name of the backend logic's clock domain that receives the bitfield (in case of ::dir = W/RW) or generates the bitfield (in case of ::dir = R). Used for HDL implementation.",8.57,"%OPEN%",sub {$o_field->{'attribs'}->{'clock'};}],
	      'reset'=>["::reset","Reset Signal",12,"Reset signal name of the backend logic that receives the bitfield (in case of ::dir = W/RW) or generates the bitfield (in case of ::dir = R). Used for HDL implementation.",9.71,"%OPEN%",sub {$o_field->{'attribs'}->{'reset'};}],
          'b' => ["::b", "Bit", 13, "", 8.43,""],     
	      'init'=>["::init","Reset Value",14,"Default value of the bitfield that is loaded during reset.",8.57,0,sub {$o_field->{'attribs'}->{'init'};}],
	      'rec'=>["::rec","Recommended Value",15,"Recommended initial value of the bitfield; usually the same as ::init",8.57,0,sub {$o_field->{'attribs'}->{'rec'};}],
	      'range'=>["::range","Value Range",16,"Possible, but not necessarily meaningful value range for bitfield.",8.57,"%EMPTY%",sub {$o_field->{'attribs'}->{'range'};}],
	      'view'=>["::view","Visible",17,"One of Y or N. If N, bitfield is omitted from documentation.",4.29,"Y",sub {$o_field->{'attribs'}->{'view'}}],
	      'vi2c'=>["::vi2c","Watchltem",18,"Additional register attribute used for VisualI2C.",20.14,'GI2C_%WBitRegister',sub {"GI2C_".$registerwidth."BitRegister";}],
	      'name'=>["::name","Field Name",19,"Name of the bitfield. Note: must be unique within a domain.",13.29,"%EMPTY%",sub {$fieldname;}],
	      'comment'=>["::comment","Description",20,"for data sheet (more information on next sheet)
\\x = reset all formats to normal
\\b = bold
\\u = underline
\\o = overline
\\s = strikethrough
\\l = superscript
\\h = subscript
\\t = tab
\\\* = bullet",28.14,"",sub {$o_field->{'attribs'}->{'comment'};}],
	      'fgroup' => ["::fgroup","Functional Group",22,"Functional group that the register belongs to. Used to further distinguish IPs within a domain.",13,"%EMPTY%",sub {if ($o_field->{'attribs'}->{'fgroup'} eq '%EMPTY%'){return $domainname}else{return $o_field->{'attribs'}->{'fgroup'} }}],
	      'block' => ["::block","Block Name",23,"Function block name. Used to further distinguish IPs within a domain.",13,"%EMPTY%",sub {if ($o_field->{'attribs'}->{'block'} eq '%EMPTY%'){return $domainname}else{return $o_field->{'attribs'}->{'block'} }}],
	      'definition' => ["::definition","Instance Definition",24,"",13,"%EMPTY%",sub {return $o_register->{'definition'}}],
          'dummy' => ["::skip", "<blank>", 25, "",   4.29,   "", ""]
	);
    
    my @lxls_columns = split (/,/, $eh->get("intermediate.xls_columns"));
    
    # delete columns if not listed in intermediate.xls_columns
    my @lcolumns = keys %columns;
    foreach my $col (@lcolumns) {
        if (!grep {$_ eq $col} @lxls_columns) {
            delete $columns{$col};
            _info("write2excel(): removing column \'$col\' from xls-dump");
        };
    };

    # re-order columns according to intermediate.xls_columns
    my ($dummy_count, $dummy_pos);
    for ($i=0; $i<scalar(@lxls_columns); $i++) {
        if (exists $columns{$lxls_columns[$i]}) {
            if ($lxls_columns[$i] =~ m/dummy|split/) {
                $dummy_count++;
                $dummy_pos = $i;
                # insert dummy column
                foreach my $elem (@{$columns{"dummy"}}) {
                    push @{$columns{"dummy$dummy_count"}}, $elem;
                };
                $columns{"dummy$dummy_count"}->[2] =  $dummy_pos;
            } else {
                # assign new position to pre-defined column
                # print "> ",$lxls_columns[$i]," -> $i\n";
                $columns{$lxls_columns[$i]}->[2] = $i;
            };
        } else {
            _warning("write2excel(): xls column \'".$lxls_columns[$i]."\' specified in intermediate.xls_columns is unknown");
        };
    };
    delete $columns{"dummy"};

    # print join(", ", sort {$columns{$a}[2]<=>$columns{$b}[2]} keys %columns),"\n"; 
    # my $dump = Data::Dumper->new([%columns]); print $dump->Dump;
    # exit;
    #gets length of the hash
    # $columns_size=scalar keys %columns;

    #add the ::b columns
    
    $maxregisterwidth=$this->get_max_regwidth();
    
    my $bit_column = 0;
    $bit_column = $columns{"b"}->[2];
    # shift all other columns by number of bits in register
    foreach my $col (keys %columns) {
        if ($columns{$col}->[2] > $bit_column) {
            $columns{$col}->[2] += $maxregisterwidth-1;
        };
    };
    # clone ::b column for each bit in register
    for ($i=$maxregisterwidth-1; $i >=0; $i--) {
        foreach my $elem (@{$columns{"b"}}) { # copy the list for column b
            push @{$columns{"b$i"}}, $elem;
        };
        $columns{"b$i"}->[0] = "::b";
        $columns{"b$i"}->[1] = "Bit $i";
        $columns{"b$i"}->[2] = $bit_column + $maxregisterwidth -1 - $i;
    };
    delete $columns{"b"};
    
    # for ($i=($maxregisterwidth-1);$i>=0;$i--){
    #     $columns{"Bit$i"}=["::b","Bit$i",$columns_size+($maxregisterwidth-1-$i),0,8.43,"",""];
    # }
    #my $dump = Data::Dumper->new([%columns]); print $dump->Dump;

    #Define the different formats that are needed for xls generation
    my($heading,$headingcolor,$description,$descriptioncolor,$bitfieldfull,$bitfieldblank,$comment,$fieldformat,$fieldformat1,$fieldformat2);
    
    #format for the heading row
    $headingcolor=$workbook->set_custom_color(40,153,204,255);#pale blue
    $heading=$workbook->add_format(bold=>1,font=>'Arial',size=>10,bg_color=>$headingcolor);
    $heading->set_border();
    $heading->set_align('center');
    
    #format for the descriptionrow
    $descriptioncolor=$workbook->set_custom_color(41,0,0,128);#dark blue
    $description=$workbook->add_format(bold=>1,font=>'Arial',size=>10,color=>'yellow',bg_color=>$descriptioncolor);
    $description->set_rotation(90);
    $description->set_align('vcenter');
    $description->set_align('center');
    $description->set_border();

    #format for used bits in register
    $bitfieldfull=$workbook->add_format(font=>'Arial',size=>10,bg_color=>$workbook->set_custom_color(43,255,153,0));#light orange
    $bitfieldfull->set_border();
    $bitfieldfull->set_text_wrap();
    #format for empty fields in columns
    $bitfieldblank=$workbook->add_format(font=>'Arial',size=>10,bg_color=>$workbook->set_custom_color(42,255,255,0));#yellow
    $bitfieldblank->set_border();
    $bitfieldblank->set_text_wrap();

    #format 1 for the rows
    $fieldformat1=$workbook->add_format(font=>'Arial',size=>10,bg_color=>$workbook->set_custom_color(44,255,255,153));#light yellow
    $fieldformat1->set_text_wrap();
    $fieldformat1->set_border();
    
    #format 2 for the rows
    $fieldformat2=$workbook->add_format(font=>'Arial',size=>10,bg_color=>$workbook->set_custom_color(45,204,255,204));#light green
    $fieldformat2->set_text_wrap();
    $fieldformat2->set_border();

 

    $worksheet->set_row(0,12.75);#set row height of headingrow
    $worksheet->set_row(1,76.5);#set row height of descriptionrow

    $worksheet->freeze_panes(4,0);
    


    $rowcounter=4;#start in row 3
    $registercounter=0;
    
    $worksheet->write(2,0,"#");
    $worksheet->write(3,0,"#");


    # add additional entries to %columns
    # for additional field attributes from ip-xact
    foreach $o_domain (@{$this->domains}){#iterate through domains
        $domainname=$o_domain->{'name'};
        
        foreach $o_register (@{$o_domain->{'regs'}}){#iterate through register
            
            foreach $field (@{$o_register->{'fields'}}){#iterate through fields
                $o_field=$field->{'field'};  		    
                
                my %i2csheetdefinition=%{$eh->get('i2c.field')};
                my $i;
                
                foreach $i (keys %{$o_field->{'attribs'}}){ 		
                    next if (grep("::".$i eq $_,keys %i2csheetdefinition));
                    next if (grep($i eq $_,keys %columns));
                    next if (grep($i eq $_,@skipparameter));
                    next if (defined $columns{"fieldparameter_".$i});
		    		         
                    my $columnssize=scalar keys %columns;
                    $columns{"fieldparameter_".$i}=["fieldparameter_".$i, $i, $columnssize,"Additional Field from IP-XACT",13,"",sub {$o_field->{'attribs'}->{$i}}];
                                   
                }
            }
        }
    }
    

    # iterate through domains
    my $n_domain=0;
    foreach $o_domain (@{$this->domains}){
        # $domainname=_clone_name($eh->get('reg_shell.domain_naming'),99,$o_domain->{'id'},$o_domain->{'name'}); # apply domain-naming rule
        $domainname=_clone_name($eh->get('reg_shell.domain_naming'),99,$n_domain++,$o_domain->{'name'}); # apply domain-naming rule
        foreach $o_register (@{$o_domain->{'regs'}}){#iterate through register
            
            $registername   = _clone_name($eh->get('reg_shell.reg_naming'),99,0,$domainname,$o_register->{'name'});  # apply register-naming rule
            $registerwidth  = $o_register->{'attribs'}->{'size'};
            $registeroffset = $o_domain->get_reg_address($o_register);
            # $registeroffset = sprintf("0x%X",$registeroffset);
            $registeroffset = sprintf("%d",$registeroffset); # baustelle: make this configurable

            foreach $field (@{$o_register->{'fields'}}){#iterate through fields
                $o_field=$field->{'field'};
                
                # generate field name with naming scheme
                $fieldname=$o_field->{'name'};
                $fieldname= _clone_name($eh->get('reg_shell.field_naming'),99,0,$domainname,$registername,$fieldname,$o_field->attribs->{'block'});
                
                
                $fieldformat=($registercounter % 2) ? $fieldformat1 : $fieldformat2;#change format with every new register
                
                
                $worksheet->set_row ($rowcounter,12.75);#set rowheight to 12.75

                
                
                my @row;#array that contains all data from field, ready to write
                foreach (sort {$columns{$a}[2]<=>$columns{$b}[2]} keys %columns){#sort %columns by position
                    my ($ref_sub_value,$ref_sub_default,$default,$value);
                    
                    
                    
                    if (ref($columns{$_}[6]) eq 'CODE'){
                        $ref_sub_value=$columns{$_}[6];
                        $value=&$ref_sub_value();
                    }else{
                        $value=$columns{$_}[6];
                    }
                    
                    if (ref($columns{$_}[5]) eq 'CODE'){
                        $ref_sub_default=$columns{$_}[5];
                        $default=&$ref_sub_default();
                    }else{
                        $default=$columns{$_}[5];
                    }
                    
                    if ($_ =~ m/^b\d+/){
                        push @row, "";
                    }else{
                        push @row, ($value || $default);
                    }
                                                         
                }
                            
                
                $worksheet->write_row($rowcounter,0,\@row,$fieldformat);#write row
                                
                
                #write ::b fields
                my ($f_size,$f_lsb,$f_pos);#get the fieldsize, lsb and position of the field
                $f_size=$o_field->{'attribs'}->{'size'};
                $f_lsb=$o_field->{'attribs'}->{'lsb'};
                $f_pos=$field->{'pos'};
                
                #first write format to all ::b columns
                for ($i=0;$i<=$maxregisterwidth-1;$i++){
                    $worksheet->write_blank($rowcounter,$columns{"b$i"}[2],$bitfieldblank);
                }
                
                #write used bits
                for ($i=$f_pos;$i<$f_pos+$f_size;$i++){
                    $worksheet->write($rowcounter,$columns{"b$i"}[2],$fieldname.".".($f_lsb+$i-$f_pos),$bitfieldfull);
                }
                $rowcounter++;
                
            }
            $registercounter++;
        }
    }

    #Write Heading, Description and comment
    foreach (sort {$columns{$a}[2]<=>$columns{$b}[2]} keys %columns){#sort %columns by position
        $worksheet->write(0,$columns{$_}[2],$columns{$_}[0],$heading);#write heading row
        $worksheet->write(1,$columns{$_}[2],$columns{$_}[1],$description);#write description row
        $worksheet->write_comment(1,$columns{$_}[2],$columns{$_}[3]) if $columns{$_}[3];#write comments to description row
        
        if ($_ =~ m/^b\d+/){
            $worksheet->set_column($columns{$_}[2],$columns{$_}[2],$columns{$_}[4],undef,1,1);#add outline if bitcell
        }else{
            $worksheet->set_column($columns{$_}[2],$columns{$_}[2],$columns{$_}[4]);#else: no outline
        }
    }
    
    
    $workbook->close() or _error("Error creating file $dumpfile");

}



sub writeYAML(){
    my ($this, $dumpfile) = @_;
    
    $dumpfile =~ s/\.xml$/.dmp/;
    $dumpfile =~ s/\.xls$/.yaml/;
    # $dumpfile =~ s/(\.\w+)/-yaml$1/;
    
    $dumpfile = $eh->get('intermediate.path').'/'.$dumpfile;  
    
    
    unless( mix_use_on_demand('use YAML') ) {
        _fatal( "Failed to load required modules for dumping data to YAML: $@" );
        exit 1;
    }
    # eval{use YAML qw 'DumpFile'};
    # die("could not find module YAML in writeYAML") if $@ ne "";
    local $YAML::SortKeys = 0;
    
    
    _info("start dumping in YAML-Format to file $dumpfile");
    unless (YAML::DumpFile($dumpfile,$this->{'domains'})){
        _error("error in writing YAML-file");
        return 0;
    }
}
1;
