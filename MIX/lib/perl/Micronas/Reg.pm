###############################################################################
#  RCSId: $Id: Reg.pm,v 1.45 2008/04/24 10:11:44 herburger Exp $
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
#       Copyright (C) 2005 Micronas GmbH, Munich, Germany 
#
#     All rights reserved. Reproduction in whole or part is prohibited
#          without the written permission of the copyright owner.
#
###############################################################################
#                                History
###############################################################################
#
#  $Log: Reg.pm,v $
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
#  Revision 1.36  2007/02/07 15:37:50  mathias
#  domain information is read in from '::dev' column when
#  the config entry 'input.domain.dev' is set to 1
#
#  Revision 1.35  2007/01/26 08:13:59  lutscher
#  removed debug print
#
#  Revision 1.34  2007/01/25 10:24:56  lutscher
#  added clipping of ::init value to field size
#
#  Revision 1.33  2006/09/22 09:08:06  lutscher
#  added register attribute clone
#
#  Revision 1.32  2006/07/20 10:56:20  lutscher
#  added cloning feature
#
#  Revision 1.31  2006/07/12 14:43:13  lutscher
#
#  
###############################################################################

package Micronas::Reg;

#------------------------------------------------------------------------------
# Used packages
#------------------------------------------------------------------------------
use strict;

use Log::Log4perl qw(get_logger);
use Micronas::MixUtils qw( mix_use_on_demand $eh %OPTVAL );
# rest gets loaded on demand ...

# use Micronas::MixUtils::Globals qw( get_eh );

#use FindBin qw($Bin);
#use lib "$Bin";
#use lib "$Bin/..";
#use lib "$Bin/lib";

my $logger = get_logger( 'MIX::Reg' );
#------------------------------------------------------------------------------
# Hook function to MIX tool. Called by mix main script. Creates a Reg object
# and calls its init() function
# Input: reference to register-master data struct
# Returns undef or a reference to the Reg object
# Note: this subroutine is not a class member
#------------------------------------------------------------------------------
sub parse_register_master($) {
	my $r_i2c = shift;

	if (scalar @$r_i2c) {
		
		# Load modules on demand ...
        unless( mix_use_on_demand('
                                  use Data::Dumper;
                                  use XML::Simple;
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
			$logger->fatal( '__F_LOADREGMD', "\tFailed to load required modules for register_master: $@" );
			exit 1;
		}
        
        # get user-supplied list of domains
        my @ldomains = ();
        if (exists $OPTVAL{'domain'}) {
            push @ldomains, $OPTVAL{'domain'};
        }
             
        my ($view, $o_space);
        foreach $view (split(/,\s*/, $eh->get('reg_shell.type'))) {
            # get handle to new register object
            $o_space = Micronas::Reg->new();
   
            # init register object
            $o_space->init(	 
                           'inputformat'     => "register-master", 
                           'database_type'   => $eh->get( 'i2c.regmas_type' ),
                           'register_master' => $r_i2c
                          );
            
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
		if ( $eh->get('i2c.req') =~ m/\bmandatory/ ) {
			$logger->error('__E_REG_INIT', "\tRegister-master file empty or sheet matching \'" .
                      $eh->get('i2c.xls') . "\' in no input file found");
		} else {
			$logger->error('__I_REG_INIT', "\tRegister-master file empty or sheet matching \'" .
                      $eh->get('i2c.xls') . "\' in no input file found");
		}
	};
	return undef;
};

#------------------------------------------------------------------------------
# Class members
#------------------------------------------------------------------------------
# this variable is recognized by MIX and will be displayed
our($VERSION) = '$Revision: 1.45 $ ';  #'
$VERSION =~ s/\$//g;
$VERSION =~ s/Revision\: //;

# global constants and defaults; is mapped per reference into Reg objects
our(%hglobal) = 
  (
   # supported register-master types (yes, they are not all the same)
   supported_register_master_type => ["VGCA", "FRCH", "AVFB"], 

   # generatable register views (dispatch table)
   supported_views => 
   {
	"hdl-vgch-rs" => \&_gen_view_vgch_rs,      # VGCH project register shell (owner: Thorsten Lutscher)
	"e_vr_ad"     => \&_gen_view_vr_ad,        # e-language macros (owner: Thorsten Lutscher)
	"stl"         => \&_gen_view_stl,          # register test file in Socket Transaction Language format (owner: Thorsten Lutscher)
	"rdl"         => \&_gen_view_rdl,          # Denali RDL representation of database (experimental)
	"ip-xact"     => \&_gen_view_ipxact,       # IP-XACT compliant XML output
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
	} else {
		_fatal("unknown inputformat \'",$hinput{inputformat},"\'");
		exit 1;
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
        _error("unrecognized view name \'$view_name'\ (mix parameter reg_shell.type)");
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

1;
