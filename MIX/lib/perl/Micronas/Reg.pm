###############################################################################
#  RCSId: $Id: Reg.pm,v 1.65 2008/07/07 14:23:13 lutscher Exp $
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
#  Revision 1.57  2008/06/16 16:33:16  lutscher
#  some clean-up
#
#  Revision 1.56  2008/06/16 16:01:11  megyei
#  Replaced option '-report <view>' by corresponding setting in mix.cg.
#
#  The config parameter reg_shell.type can now take all the views that were
#  previously defined by the -report option.
#
#  Revision 1.55  2008/06/05 12:05:19  herburger
#  changed module import
#
#  Revision 1.54  2008/06/05 09:07:24  herburger
#  changed Module import
#
#  Revision 1.53  2008/06/03 13:15:57  herburger
#  improved _check_version, some small changes in _map_ipxact
#
#  Revision 1.52  2008/05/28 14:15:36  herburger
#  added _check_schema
#
#  Revision 1.51  2008/05/28 13:54:40  herburger
#  Improved XML mapping & check for IP-XACT Version of input file
#
#  Revision 1.50  2008/05/19 12:56:52  herburger
#  Added function _map_ipxact, initial version for parsing xml files
#
#  Revision 1.49  2008/05/09 14:50:03  herburger
#  Added Function get_register_direction_from_fields()
#
#  Revision 1.48  2008/04/24 16:58:53  lutscher
#  some improvements to parse_register_master()
#
#  Revision 1.47  2008/04/24 13:07:34  lutscher
#  some clean-up
#
#  Revision 1.46  2008/04/24 12:03:04  lutscher
#  added input_format ip-xact, intermediate release
#
#  Revision 1.45  2008/04/24 10:11:44  herburger
#  *** empty log message ***
#
#  Revision 1.44  2008/04/14 07:50:28  wig
#  Only complain about missing I2C sheet if xls.i2c is set to mandatory.
#
#  Revision 1.43  2008/04/01 13:01:24  lutscher
#  changed info to error
#
#  Revision 1.42  2008/04/01 09:20:13  lutscher
#  changed generate_view() to use dispatch-table
#
#  Revision 1.41  2007/09/05 10:56:23  lutscher
#  set default clone.number to 0 because 1 will now force 1 clone
#
#  Revision 1.40  2007/08/10 08:39:52  lutscher
#  little changes
#
#  Revision 1.39  2007/05/24 09:30:21  lutscher
#  added hxxx number format to parser
#
#  Revision 1.38  2007/05/07 07:10:20  lutscher
#  small changes
#
#  Revision 1.37  2007/03/05 18:29:08  lutscher
#  fixed bug in _map_register_master() where the clipping of values may not be done for 32-bit fields
#
#  [hist deleted]
#  
###############################################################################

package Micronas::Reg;

#------------------------------------------------------------------------------
# Used packages
#------------------------------------------------------------------------------
use strict;

use Log::Log4perl qw(get_logger);
use Micronas::MixUtils qw( mix_use_on_demand $eh %OPTVAL );
use Micronas::MixReport qw(mix_reg_report);
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

	if (scalar @$r_i2c or scalar @$r_xml) {
	
		# Load modules on demand ...
        # removed:  use XML::Simple;
        unless( mix_use_on_demand('
                                  use Data::Dumper;
                                  use Micronas::RegDomain;
                                  use Micronas::RegReg;
                                  use Micronas::RegField;
                                  use Micronas::RegViews;
                                  use Micronas::RegViewE;
                                  use Micronas::RegViewSTL;
                                  use Micronas::RegViewRDL;
                                  use Micronas::RegViewClone;
                                  use Micronas::MixUtils::RegUtils;
                                  use Micronas::RegViewIPXACT;
				                                   '	
                                 ) ) {
			$logger->fatal( '__F_LOADREGMD', "\tFailed to load required modules for parse_register_master(): $@" );
			exit 1;
		}
        
        # get user-supplied list of domains
        my @ldomains = ();
        if (exists $OPTVAL{'domain'}) {
            push @ldomains, $OPTVAL{'domain'};
        }
             
        my ($view, $o_space);
        # for every view, create a new register-space object from input; ##LU this is not very nice,
        # but currently the generate functions manipulate at least the 'global' data-member and the 'eh' hash
        # which could have side-effects on subsequent generators
        foreach $view (split(/,\s*/, $eh->get('reg_shell.type'))) {
            # get handle to new register object
            $o_space = Micronas::Reg->new();
            
            # init register object from register-master
            if (scalar @$r_i2c) {
                $o_space->init(	 
                               'inputformat'     => "register-master", 
                               'database_type'   => $eh->get('i2c.regmas_type'),
                               'register_master' => $r_i2c
                              );
            };
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
			
            # check if register object should be cloned first
            if ($eh->get('reg_shell.clone.number') > 0) {
                my $o_new_space = $o_space->_clone(); # module RegViewClone.pm 
                $o_space = $o_new_space;
            };

            
            # make it so 
            $o_space->generate_view($view, $o_space->global->{supported_views}, \@ldomains);
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
our($VERSION) = '$Revision: 1.65 $ ';  #'
$VERSION =~ s/\$//g;
$VERSION =~ s/Revision\: //;

#global constants and defaults; is mapped per reference into Reg objects
our(%hglobal) = 
  (
   # supported input formats
   supported_input_formats => ["register-master", "ip-xact"],

   # supported register-master types (yes, they are not all the same)
   supported_register_master_type => ["VGCA", "FRCH", "AVFB"], 

   # generatable register views (dispatch table)
   supported_views => 
   {
    "hdl-vgch-rs" => \&_gen_view_vgch_rs,      # VGCH project register shell (owner: Thorsten Lutscher)
    "e_vr_ad"     => \&_gen_view_vr_ad,        # e-language macros (owner: Thorsten Lutscher)
    "stl"         => \&_gen_view_stl,          # register test file in Socket Transaction Language format (owner: Thorsten Lutscher)
    "rdl"         => \&_gen_view_rdl,          # Denali RDL representation of database (experimental)
    "ip-xact"     => \&_gen_view_ipxact,       # IP-XACT compliant XML output (owner: Gregor Herburger)
    # "portlist"    => \&mix_reg_report,             # documents portlist in mif file (owner: Thorsten Lutscher)
    "reglist"     => \&mix_reg_report,         # documents all registers in mif file (owner: Thorsten Lutscher)
    "header"      => \&mix_reg_report,         # generates c header files (owner: Thorsten Lutscher)
    "vctyheader"  => \&mix_reg_report,         # the same but top level addresses are taken from device.in file (owner: Thorsten Lutscher)
    "per"         => \&mix_reg_report,         # creates Lauterbach per file (owner: Thorsten Lutscher)
    "vctyper"     => \&mix_reg_report,         # the same but top level addresses are taken from device.in file (owner: Thorsten Lutscher)
    "perl"        => \&mix_reg_report,         # creates perl package (owner: Thorsten Lutscher)
    "vctyperl"    => \&mix_reg_report,         # the same but top level addresses are taken from device.in file (owner: Thorsten Lutscher)
    "none"        => sub {}                    # generate nothing (useful for bypassing the dispatcher)
   },

   # attributes in register-master that do NOT belong to a field
   # note: the field name is retrieved from the ::b entries of the register-master
   non_field_attributes => [qw(::ign ::sub ::interface ::inst ::width ::b:.* ::b ::addr ::dev ::vi2c ::default ::name ::type ::definition ::clone)],

   # language for HDL code generation, currently only Verilog supported
   lang => "verilog",

   # debug switch
   debug => 0,

   # Version of class package
   version => $VERSION
  );


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
					   device => "<no device specified>",
					   domains => [],
					   global => \%hglobal  # reference to class data
					  };
	# init data members w/ parameters from constructor call
	foreach (keys %params) {
		$ref_member->{$_} = $params{$_};
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
	    
#  	    #check input against schema
#  	    if(!$this->_check_schema($hinput{database_type},$datastring_ipxact_1_4)){
#  		exit 1;
#  	    }
	
	    # call mapping function for ip-xact (XML) database
	    $this->_map_ipxact($hinput{database_type},$datastring_ipxact_1_4);
	    
	};
    };
};

# generate a view of the register space
# !! this is the HOOK FUNCTION to call view-generating-methods in other packages/modules !!
# it uses a reference to a dispatch table to make the method calls;
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

# add single domain to the register space or return ref. to the list of domain hashes
# input: none or hash describing the domain mapping
# domain => ref. to domain
# baseaddr => base address of domain
sub domains {
	my $this = shift;
	if (@_) {
		my %hdomain = @_;
		push @{$this->{domains}}, \%hdomain;
	};
	return $this->{domains};
};

# finds first domain in list that matches name and returns the object (or undef)
# input: domain name
sub find_domain_by_name_first {
	my $this = shift;
	my $name = shift;
	my($result) = (grep ($_->{domain}->{name} eq $name, @{$this->domains}))[0];
	
	if (ref($result)) {
		return $result->{domain};
	} else {
		return undef;
	};
};

# get baseaddr for a given domain name
# input: domain name
# output: baseaddr value (or undef)
sub get_domain_baseaddr {
	my ($this, $name) = @_;

	my ($result) = (grep ($_->{domain}->{name} eq $name, @{$this->domains}))[0];
	if (ref($result)) {
		return $result->{baseaddr};
	} else {
		return undef;
	};
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

    # check whether domain information should be taken from '::dev' column
    # default: domain information is taken from '::interface' column
    my $domain_column = defined($eh->get('input.domain.dev')) ? '::dev' : '::interface';

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
                $domain = $value; next;
            }
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
                    $this->domains('domain' => $o_domain, 'baseaddr' => $baseaddr);
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
                    $o_domain->regs($o_reg);
                    $o_domain->addrmap('reg' => $o_reg, 'offset' => $offset);
                };
            };

            # compute bit-mask for registes
            for ($i=$fpos; $i < $fpos+$fsize; $i++) {
                $old_usedbits = $usedbits;
                $usedbits |= 1<<$i;
				# check for overlapping fields in same register
                if ($old_usedbits == $usedbits) {
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
# 2. Array with XML-Data
# output: 1 if successful, 0 otherwise

sub _map_ipxact{
    my ($this)=shift;
    my ($database_type, $datastring)=@_;
    my (%domains, %registers, @registerindomain, @fieldinregister, $domain_register_field);
    my ($tmpfield, $encoding);
    
    
    
    
    
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
	$baseaddr = $elt->first_child('spirit:baseAddress')->text;
	$baseaddr = oct($baseaddr) if $baseaddr =~ m/^0/;#converts hex or oct into dec

	#create new domain
	$o_domain = Micronas::RegDomain->new(name => $domainname);

	#get addresswidth datawidth
	$range = $elt->first_child('spirit:range')->text;#2^$range
	$range = oct($range) if $range =~ m/^0/;
	$range=log($range)/log(2);#get range
	$width = $elt->first_child('spirit:width')->text;
	
	$eh->set('reg_shell.addrwidth',$range);
	$eh->set('reg_shell.regwidth',$width);
	
	
	#add domain to reg-object
	$this->domains('domain' => $o_domain, 'baseaddr' => $baseaddr);

	
	###########REGISTERS###########
	#find register that belong to this domain

	@registers=$elt->children('spirit:register');
	
	#iterate through all registers
	foreach $register (@registers){
	    my ($registername, $offset,@fields, $field, $clone, $rsize, $usedbits, $registerreset, $rdescription);
	    my ($o_register);

	    $registername =  $register->first_child('spirit:name')->text;
	    $offset = $register->first_child('spirit:addressOffset')->text;
	    $offset=oct($offset) if $offset =~ m/^0/;#converts hex or oct into dec

	    #create new register object
	    $o_register = Micronas::RegReg->new(name => $registername);

	    #get register description
	    $rdescription = "";
	    $rdescription = $register->first_child('spirit:description')->text if ($register->first_child('spirit:description'));

	    $o_register->definition($rdescription);

	    #link register object into domain
	    $o_domain->regs($o_register);
	    $o_domain->addrmap(reg=>$o_register,offset=>$offset);

	    ###########register attributes

	    #cloning information
	    $clone=0;

	    if ($register->children_count('spirit:parameters')){#parameters exist
		my @registerparameters=$register->first_child('spirit:parameters')->children('spirit:parameter');#list of all parameters

		foreach (@registerparameters){#iterate through all parameters
		    my $parametername=$_->first_child('spirit:name');
		    if ($parametername->text eq 'clone'){
			$clone=$parametername->next_sibling('spirit:value')->text;
			$o_register->attribs(clone => $clone);
		    }
		}
	    }
	    #register size
	    $rsize=$register->first_child('spirit:size')->text;

	    #used bits
	    if ($register->first_child('spirit:reset')){
		if ($register->first_child('spirit:reset')->first_child('spirit:mask')){
		    $usedbits=$register->first_child('spirit:reset')->first_child('spirit:mask')->text;
		    $o_register->attribs(usedbits=>$usedbits);
		}
	    }
	    
	    #add atrributes to register
	    $o_register->attribs(size => $rsize);
	    
	    ###########FIELDS###########
	    #find fields that belong  to this register/domain
	    @fields=$register->children('spirit:field');
	    
	    #iterate through all fields
	    foreach $field (@fields){
		my ($fieldname, $position, $fsize, $description, $reset, %access, %prettynames, @fieldparameters, $parameter, $frange);
		my ($o_field);

		$fieldname=$field->first_child('spirit:name')->text;
		$position=$field->first_child('spirit:bitOffset')->text;
		$position=oct($position) if $position =~ m/^0/;#converts hex or oct into dec

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
		$registerreset=Math::BigInt->new($registerreset)->as_int();#for big integer number support
		
		$reset=unpack("B32", pack("N", $registerreset>>$position));#get resetvalue of register in binary shifted by position
		$reset=substr($reset,length($reset)-$fsize,$fsize);#field reset value
		$reset=unpack("N", pack("B32", substr("0" x 32 . $reset, -32)));#bin->dec

		$o_field->attribs(init=>$reset);
		$o_field->attribs(comment=>$description);
		$o_field->attribs(dir=>$access{$field->first_child('spirit:access')->text});
		$o_field->attribs(range=>$frange,size=>$fsize);
		#put remaining paramters to attributes
		@fieldparameters=();
		(@fieldparameters=$field->first_child('spirit:parameters')->children('spirit:parameter')) if ($field->first_child('spirit:parameters'));
			
		foreach $parameter (@fieldparameters){
		    
		    my $parametername=$parameter->first_child('spirit:name')->text;
		    next if (grep($_ eq $parametername,@{$eh->get('xml.field_skipelements')}));
		    my $parametervalue=$parameter->first_child('spirit:value')->text;  
		    ($parametername=$prettynames{$parametername})if (exists $prettynames{$parametername});
				    
		    $o_field->attribs($parametername=>$parametervalue);
		}
	    }
	}
	
	$twig->purge();#free memory
    };

    #Handler to get the AddressunitBits field
    my $ipxact_addressunitbits = sub {
	my ( $twig, $elt )= @_; 
	my ( $bitsinUnit);

	$bitsinUnit=$elt->text;
	$eh->set('reg_shell.datawidth',$bitsinUnit);
	
	$twig->purge();#free memory
    };
    


    #####################################################################
  

    my $twig=XML::Twig->new(twig_handlers =>
			    {
				'spirit:addressBlock' => $ipxact_domain, #domain 
				'spirit:addressUnitBits' => $ipxact_addressunitbits,
			    }
	);#create new Twig Object

    _info("start parsing XMLfile");
    if (!$twig->parse($datastring)){#parse XMLString
	_error("parsing failed!");
	return 0;
    };

    $encoding = $twig->encoding()||"utf-8";#get encoding
    $eh->set('xml.characterencodingin',$encoding);

    $twig->purge();#Free memory


  
   
    #$this->display();
	

};

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
    
    
    if ($ipxact_version eq "1.4"){#input IP-XACT 1.4
	_info("input file in IP-XACT 1.4 format");
	return $datastring;#return datastring unchanged

    }elsif ($ipxact_version == 0){#input not in ipxact format
	_info("input file not in IP-XACT format");
	return 0;#return 0
	
    }elsif ($ipxact_version =~ m/\d\.\d/){#input in other version
	_info("input file in IP-XACT $ipxact_version format");

	#try to transform into IP-XACT 1.4
	my $updatefile=$eh->get('xml.xslt_dir')."from".$ipxact_version."_to_1.4.xsl";
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

	}elsif(-e $eh->get('xml.xslt_dir')."from".$ipxact_version."_to_".$ipxact_version_main.".".++$ipxact_version_sub.".xsl"){
	    my ($parser, $xslt, $source, $style_doc, $stylesheet, $results, $result);
	    
	    #XSLTransformation
	    $parser = XML::LibXML->new();#new LibXML object
	    $xslt = XML::LibXSLT->new();#new LibXSLT object

	    $source = $parser ->parse_string($datastring);
	    $style_doc = $parser -> parse_file($eh->get('xml.xslt_dir')."from".$ipxact_version."_to_".$ipxact_version_main.".".$ipxact_version_sub.".xsl");
	    
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

# sub _check_schema{
#     my ($this)=shift;
#     my ($database_type, $datastring)=@_; 
#     my ($validator,%error ,$schemafile);
#     use XML::Validate::Xerces;
    
#     _info('checking file against Schema');
    
#     $schemafile=$eh->get('xml.schema_dir')."index.xsd";#schema
    
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


# };


# writes a excel file out of a Micronas::Reg Object
# input: 1. dumpfile to write excel to 
# output: 1 if successfull 0 otherwise

sub write2excel{
    my $this=shift;
    my ($dumpfile)=@_;

    my ( $workbook, $worksheet, $worksheetname, $path, %columns, $i, $registerwidth, $rowcounter, $fieldspec, $fieldcomment, $vi2cdata,$registercounter,$columns_size, $registeroffset, $view, $recommended, $domainname, $registername,  $fieldname);
    my ( $domain, $o_domain, $o_register, $field, $o_field);

    #import needed Modules
    unless( mix_use_on_demand('use Spreadsheet::WriteExcel;') ) {
	_fatal( "Failed to load required modules for dumping XML data to Excel: $@" );
	exit 1;
    }
    
    #get the path, to the tmp_excelfile
    $path =$eh->get('intermediate.path');
    $dumpfile =~ s/\.xml$/.xls/;#change xml file extension to xls
    $dumpfile = $path.'/'.$dumpfile;
    
    
    #create new excel file
    _info("start writing to Excel File, $dumpfile");
    
    if (!($workbook = Spreadsheet::WriteExcel->new($dumpfile))){
	_error( "Problems creating new Excel file: $!");
	 return 0;
    }

    #get worksheet name
    $dumpfile =~ m/^$path\/(\w+)-mixed\.xls/;
    $worksheetname=$1;
    $worksheetname=substr($worksheetname,0,31);#sheetname can only be 31 characters long
    

    # Add a worksheet
    $worksheet = $workbook->add_worksheet($worksheetname);

    #Describes the columns with identifier => [column name, column description, position, comment, col-width]
    %columns=('ign'=>["::ign","#",0,"Ignore. If cell contains '#', row will be ignored.",6.57],
	      'type'=>["::type","Register Type",1,"Not used (!?). Default is 'I2C'.",8.57],
	      'dev'=>["::dev","Device Address",2,"Symbolic device (chip) address for board-level I2C bus.",8.57],
	      'width'=>["::width","Register Width",3,"Width of HDL implementation of register. Default is 32.",6.14],
	      'sub'=>["::sub","rel. Address",4,"Address offset of register in domain/register-shell. The 2nd meaning (with different value) is physical address for board-level I2C bus.",8.14],
	      'interface'=>["::interface","Domain Name",5,"Register domain name. Each domain has its register-shell implementation assigned to.",8.14],
	      'inst'=>["::inst","Register Name",6,"Register name; Default is concatenation of ::block and ::sub but can be changed to have something more meaningful. Note: must be unique within one domain",13.43],
	      'dir'=>["::dir","Write / Read",7,"Bitfield access attribute from software point of view. One of R (read-only), W (write-only), RW (read or write). Note: If possible, do not assign different values for bitfields within one register.",8.57],
	      'spec'=>["::spec","Special Type",8,"Special bitfield attribute(s). If more than one, separate by ',' or ';'. Supported are at least:
SHA - shadowed field (also has ::update and ::sync column)
W1C - write-one-to-clear (typically IR status register)
USR - the register access is forwarded to the backend-logic; typically RAM-ports, special registers (used for HDL implementation)",8.57],
	      'update'=>["::update","Update Enable",9,"One of Y or N. Specifies whether the shadowing of a bitfield is controlled by enable/force signals. Note: requires ::spec = SHA",6.14],
	      'sync'=>["::sync","Update Signal",10,"Name of the signal that triggers a shadow update of the bitfield (for HDL implementation). This signal can e.g. be vertical-sync.",8.57],
	      'clock'=>["::clock","Clock Domain",11,"Clock signal name of the backend logic's clock domain that receives the bitfield (in case of ::dir = W/RW) or generates the bitfield (in case of ::dir = R). Used for HDL implementation.",8.57],
	      'reset'=>["::reset","Reset Signal",12,"Reset signal name of the backend logic that receives the bitfield (in case of ::dir = W/RW) or generates the bitfield (in case of ::dir = R). Used for HDL implementation.",9.71],
	      'init'=>["::init","Reset Value",13,"Default value of the bitfield that is loaded during reset.",8.57],
	      'rec'=>["::rec","Recommended Value",14,"Recommended initial value of the bitfield; usually the same as ::init",8.57],
	      'range'=>["::range","Value Range",15,"Possible, but not necessarily meaningful value range for bitfield.",8.57],
	      'view'=>["::view","Visible",16,"One of Y or N. If N, bitfield is omitted from documentation.",4.29],
	      'vi2c'=>["::vi2c","Watchltem",17,"Additional register attribute used for VisualI2C.",20.14],
	      'name'=>["::name","Field Name",18,"Name of the bitfield. Note: must be unique within a domain.",13.29],
	      'comment'=>["::comment","Description",19,"for data sheet (more information on next sheet)
\\x = reset all formats to normal
\\b = bold
\\u = underline
\\o = overline
\\s = strikethrough
\\l = superscript
\\h = subscript
\\t = tab
\\\* = bullet",28.14],
	);
    
    #gets length of the hash
    $columns_size=scalar keys %columns;

    #add the ::b columns
    $registerwidth=$eh->get('reg_shell.regwidth');
    for ($i=($registerwidth-1);$i>=0;$i--){
	$columns{"Bit$i"}=["::b","Bit$i",$columns_size+($registerwidth-1-$i),0,8.43];
    }
    
    
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

    foreach (sort {$columns{$a}[2]<=>$columns{$b}[2]} keys %columns){#sort %columns by position
	$worksheet->write(0,$columns{$_}[2],$columns{$_}[0],$heading);#write heading row
	$worksheet->write(1,$columns{$_}[2],$columns{$_}[1],$description);#write description row
	$worksheet->write_comment(1,$columns{$_}[2],$columns{$_}[3]) if $columns{$_}[3];#write comments to description row

	if ($_ =~ m/^Bit\d+/){
	    $worksheet->set_column($columns{$_}[2],$columns{$_}[2],$columns{$_}[4],undef,1,1);#add outline if bitcell
	}else{
	    $worksheet->set_column($columns{$_}[2],$columns{$_}[2],$columns{$_}[4]);#else: no outline
	}
    }


    $worksheet->set_row(0,12.75);#set row height of headingrow
    $worksheet->set_row(1,76.5);#set row height of descriptionrow

    $worksheet->freeze_panes(4,0);
    


    $rowcounter=4;#start in row 3
    $registercounter=0;
    
    $worksheet->write(2,0,"#");
    $worksheet->write(3,0,"#");
  
    foreach $domain (@{$this->domains}){#iterate through domains
	$o_domain=$domain->{'domain'};
	$domainname=$o_domain->{'name'};
	
	foreach $o_register (@{$o_domain->{'regs'}}){#iterate through register
	    $registername=$o_register->{'name'};
	    
	    foreach $field (@{$o_register->{'fields'}}){#iterate through fields

		$fieldformat=($registercounter % 2) ? $fieldformat1 : $fieldformat2;#change format with every new register
		$o_field=$field->{'field'};

		$worksheet->set_row ($rowcounter,12.75);#set rowheight to 12.75

		$worksheet->write_blank($rowcounter,$columns{'ign'}[2],$fieldformat);
		$worksheet->write($rowcounter,$columns{'type'}[2],"I2C",$fieldformat);
		$worksheet->write($rowcounter,$columns{'dev'}[2],$this->{device},$fieldformat);

		$worksheet->write($rowcounter,$columns{'width'}[2],$o_register->{'attribs'}->{'size'},$fieldformat);

		$registeroffset=$o_domain->get_reg_address($o_register);
		$registeroffset=sprintf("0x%X",$registeroffset);#convert to HEX
		$worksheet->write($rowcounter,$columns{'sub'}[2],$registeroffset,$fieldformat);

		$worksheet->write($rowcounter,$columns{'interface'}[2],$domainname ,$fieldformat);

		$worksheet->write($rowcounter,$columns{'inst'}[2],$registername,$fieldformat);

		$vi2cdata="GI2C_".$o_register->{'attribs'}->{'size'}."Bit_Register";
		$worksheet->write($rowcounter,$columns{'vi2c'}[2],$vi2cdata,$fieldformat);

		

		#write field data	
		$fieldcomment=$o_field->{'attribs'}->{'comment'};
		$fieldcomment=~s/%EMPTY%// if ($o_field->{'attribs'}->{'comment'});
		$fieldname=$o_field->{'name'};


		# generate field name with naming scheme
		$fieldname= _clone_name($eh->get('reg_shell.field_naming'),99,0,$domainname,$registername,$fieldname,$o_field->attribs->{'block'});
		
		
		$worksheet->write($rowcounter,$columns{'name'}[2],$fieldname,$fieldformat);
		$worksheet->write($rowcounter,$columns{'dir'}[2],$o_field->{'attribs'}->{'dir'},$fieldformat);
		
		$fieldspec=$o_field->{'attribs'}->{'spec'};
		$fieldspec=~s/%EMPTY%// if ($o_field->{'attribs'}->{'spec'});
		$worksheet->write($rowcounter,$columns{'spec'}[2],$fieldspec,$fieldformat);		

		$worksheet->write($rowcounter,$columns{'update'}[2],$o_field->{'attribs'}->{'update'},$fieldformat);
		$worksheet->write($rowcounter,$columns{'sync'}[2],$o_field->{'attribs'}->{'sync'},$fieldformat);
		
		$fieldcomment=$o_field->{'attribs'}->{'comment'};
		$fieldcomment=~s/%EMPTY%// if ($o_field->{'attribs'}->{'comment'});
		$worksheet->write($rowcounter,$columns{'comment'}[2],$fieldcomment,$fieldformat);
	

		$worksheet->write($rowcounter,$columns{'clock'}[2],$o_field->{'attribs'}->{'clock'},$fieldformat);
		$worksheet->write($rowcounter,$columns{'reset'}[2],$o_field->{'attribs'}->{'reset'},$fieldformat);
		$worksheet->write($rowcounter,$columns{'init'}[2],$o_field->{'attribs'}->{'init'},$fieldformat);

		$recommended=($o_field->{'attribs'}->{'rec'}) ? $o_field->{'attribs'}->{'rec'} : $o_field->{'attribs'}->{'init'};#if recommended not defined use init field
		$worksheet->write($rowcounter,$columns{'rec'}[2],$recommended,$fieldformat);
		$worksheet->write($rowcounter,$columns{'range'}[2],$o_field->{'attribs'}->{'range'},$fieldformat);

		$view=($o_field->{'attribs'}->{'view'})?$o_field->{'attribs'}->{'view'}:"Y";#if view not defined set to 'Y'
		$worksheet->write($rowcounter,$columns{'view'}[2],$view,$fieldformat);
	
		#write ::b fields
		my ($f_size,$f_lsb,$f_pos);#get the fieldsize, lsb and position of the field
		$f_size=$o_field->{'attribs'}->{'size'};
		$f_lsb=$o_field->{'attribs'}->{'lsb'};
		$f_pos=$field->{'pos'};
		
		#first write format to all ::b columns
		for ($i=0;$i<=$registerwidth-1;$i++){
		    $worksheet->write_blank($rowcounter,$columns{"Bit$i"}[2],$bitfieldblank);
		}

		#write used bits
		for ($i=$f_pos;$i<$f_pos+$f_size;$i++){
		    $worksheet->write($rowcounter,$columns{"Bit$i"}[2],$fieldname.".".($f_lsb+$i-$f_pos),$bitfieldfull);
		}
		$rowcounter++;

	    }
	    $registercounter++;
	}
    }
    $workbook->close() or _error("Error creating file $dumpfile");

}



sub writeYAML(){
    my ($this, $dumpfile) = @_;
    my ($path);
    
    
    $path=$eh->get('intermediate.path');
    $dumpfile =~ s/\.xml$/.dmp/;
    $dumpfile =~ s/mixed/yaml/;
    $dumpfile = $path.'/'.$dumpfile;

    use YAML qw 'DumpFile';
    local $YAML::SortKeys = 0;
    

    _info("start dumping in YAML-Format to file $dumpfile");
    unless (DumpFile($dumpfile,$this->{'domains'})){
	_error("error in writing YAML-file");
	return 0;
    }
    


    
}
1;
