###############################################################################
#  RCSId: $Id: Reg.pm,v 1.19 2006/02/28 11:33:27 lutscher Exp $
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
#  Revision 1.19  2006/02/28 11:33:27  lutscher
#  added view RDL
#
#  Revision 1.18  2006/01/18 13:05:44  lutscher
#  changed handling of different registers at same address
#
#  Revision 1.17  2006/01/13 13:39:08  lutscher
#  added AVFB register master type
#
#  Revision 1.16  2005/12/09 15:02:15  lutscher
#  small changes
#
#  Revision 1.15  2005/12/09 13:13:48  lutscher
#  moved hook function called by mix_0.pl from MixI2CParser.pm to here; now called parse_register_master()
#
#  Revision 1.14  2005/11/29 08:45:45  lutscher
#  added get_domain_baseaddr() and view: none
#
#  Revision 1.13  2005/11/23 13:58:30  mathias
#  do not remove data structure when register list should be reported
#
#  Revision 1.12  2005/11/23 13:31:30  lutscher
#  added RegViewSTL.pm
#
#  Revision 1.11  2005/11/23 13:24:32  lutscher
#  some changes for -report, added STL view
#
#  Revision 1.10  2005/11/10 14:40:05  lutscher
#  added setting of definition class member of fields and check for decimal/hexadecimal from ::sub column in register master
#
#  Revision 1.9  2005/11/09 13:36:56  lutscher
#  added domain command line parameter
#
#  Revision 1.8  2005/11/09 13:00:14  lutscher
#  fixed Perl warning
#
#  Revision 1.7  2005/11/09 12:42:49  lutscher
#  added whitespace removal and promoted a warning to error
#
#  Revision 1.6  2005/11/08 13:10:38  lutscher
#  added check for overlapping registers
#
#  Revision 1.5  2005/10/26 13:57:14  lutscher
#  set debug to 0
#
#  Revision 1.4  2005/10/14 11:30:07  lutscher
#  intermedate checkin (stable, but fully functional)
#
#  Revision 1.3  2005/09/16 13:57:27  lutscher
#  added register view E_VR_AD from Emanuel
#
#  Revision 1.2  2005/07/18 08:40:59  lutscher
#  o fixed parser for register-master sheet
#  o changed global parameter _mult_max_ -> _mult_
#
#  Revision 1.1  2005/07/07 12:35:26  lutscher
#  Reg: register space class; represents register space
#  of a device and contains register domains; also contains
#  most of the user API for dealing with register spaces.
#  Contains subclasses (see Reg.pm).
#
#  
###############################################################################

package Micronas::Reg;

#------------------------------------------------------------------------------
# Used packages
#------------------------------------------------------------------------------
use strict;
use Data::Dumper;
use Micronas::MixUtils qw(%EH %OPTVAL);
use Micronas::RegDomain;
use Micronas::RegReg;
use Micronas::RegField;
use Micronas::RegViews;
use Micronas::RegViewE;
use Micronas::RegViewSTL;
use Micronas::RegViewRDL;
use Micronas::MixUtils::RegUtils;

#use FindBin qw($Bin);
#use lib "$Bin";
#use lib "$Bin/..";
#use lib "$Bin/lib";

#------------------------------------------------------------------------------
# Hook function to MIX tool. Called by mix main script. Creates a Reg object
# and calls its init() function
# Input: reference to register-master data struct
# Returns 1 (always pass control back to caller)
# Note: this subroutine is not a class member
#------------------------------------------------------------------------------
sub parse_register_master($) {
	my $r_i2c = shift;

	if (scalar @$r_i2c) {
		my($o_space) = Micronas::Reg->new();
		
		if (grep($EH{'reg_shell'}{'type'} =~ m/$_/i, @{$o_space->global->{supported_views}})) {
			# init register module for generation of register-shell
			$o_space->init(	 
						   'inputformat'     => "register-master", 
						   'database_type'   => $EH{i2c}{regmas_type},
						   'register_master' => $r_i2c
						  );

			# set debug switch
			$o_space->global('debug' => exists $OPTVAL{'verbose'} ? 1 : 0);
			
			# make it so
			$o_space->generate_view($EH{'reg_shell'}{'type'});
		};
	} else {
		_warning("register-master file empty or specified sheet \'$EH{'i2c'}{'xls'}\' in file not found");
	};
	return 1;
};

#------------------------------------------------------------------------------
# Class members
#------------------------------------------------------------------------------
# this variable is recognized by MIX and will be displayed
our($VERSION) = '$Revision: 1.19 $ ';  #'
$VERSION =~ s/\$//g;
$VERSION =~ s/Revision\: //;

# global constants and defaults; is mapped per reference into Reg objects
our(%hglobal) = 
  (
   # supported register-master types (yes, they are not all the same)
   supported_register_master_type => ["VGCA", "FRCH", "AVFB"], 

   # generatable register views 
   supported_views => [
					   "HDL-vgch-rs",   # VGCH project register shell (Thorsten Lutscher)
					   "E_VR_AD",       # e-language macros (Emanuel Marconetti)
					   "STL",           # register test file in Socket Transaction Language format
					   "RDL",           # Denali RDL representation of database (experimental)
					   "none"           # do nothing
					  ],

   # attributes in register-master that do NOT belong to a field
   # note: the field name is retrieved from the ::b entries of the register-master
   non_field_attributes => [qw(::ign ::sub ::interface ::inst ::width ::b:.* ::b ::addr ::dev ::vi2c ::default ::name ::type)],

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
		die "ERROR: database_type \'$hinput{database_type}\' not supported" if (!grep ($_ eq $hinput{database_type}, @{$this->global->{supported_register_master_type}}));
		$this->_map_register_master($hinput{database_type}, $hinput{register_master}) || die "aborting due to errors\n";
	} else {
		die "ERROR: unknown inputformat \'$this->{inputformat}\'";
	};
};

# generate a view of the register space
# !! this is the HOOK FUNCTION to call view-generating-methods in other packages/modules !!
sub generate_view {
	my $this = shift;
	my $view = shift;

	my @ldomains = ();
	if (exists $OPTVAL{'domain'}) {
		push @ldomains, $OPTVAL{'domain'};
	}

	if (lc($view) eq "hdl-vgch-rs") {
		$this->_gen_view_vgch_rs(@ldomains); # module RegViews.pm
	} elsif (lc($view) eq "e_vr_ad") {
		$this->_gen_view_vr_ad(@ldomains);   # module RegViewE.pm
	} elsif (lc($view) eq "stl") {
		$this->_gen_view_stl(@ldomains);     # module RegViewSTL.pm
	} elsif (lc($view) eq "rdl") {
		$this->_gen_view_rdl(@ldomains);     # module RegViewRDL.pm
 	} elsif ($view =~ m/none/i) {
		return; # do nothing
	} else {
		die "ERROR: generation of view \'$view\' is not supported";
	};
};

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
	$dump->Maxdepth(4);
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
	my($href_row, $marker, $rsize, $reg, $value, $fname, $fpos, $fsize, $domain, $offset, $msb, $msb_max, $lsb, $p, $new_fname, $usedbits, $baseaddr, $col_cnt, $fdefinition, $o_tmp);
	my($o_domain, $o_reg, $o_field) = (undef, undef, undef);
	my($href_marker_types, %hattribs, %hdefault_attribs, $m);
	my $result = 1;
	my ($old_usedbits, $i);
	$usedbits = 0;

	# get defaults for field attributes from %EH 
	$href_marker_types = $EH{'i2c'}{'field'};
	foreach $m (keys %{$href_marker_types}) {
		next unless ($m =~ m/^::/); 
		# filter out everything that is not needed for fields
		if (!grep ($m =~ /^$_$/, @{$this->global->{non_field_attributes}})) { 
			my $m_new = $m;
			$m_new =~ s/^:://; # get rid of the leading ::
			$hdefault_attribs{$m_new} = $href_marker_types->{$m}[3];
		};
	};

	# highest bit specified in register-master
	$msb_max = $EH{'i2c'}{'_mult_'}{'::b'} || die "ERROR: internal error (bad!)";

	# iterate each row
	foreach $href_row (@$lref_rm) {
		# skip lines to ignore
		next if (exists ($href_row->{"::ign"}) and ($href_row->{"::ign"} =~ m,^(#|//|\w+),));
		next if (!scalar(%$href_row));

		$col_cnt = 0;
		$msb   = 0;
		$fname = "";
		$fpos  = 0;
		$msb   = 0;
		$lsb   = 99;
		$rsize = $EH{i2c}{field}{'::width'}[3];		
		%hattribs = %hdefault_attribs;

		# parse all columns
		foreach $marker (keys %$href_row) {
			$value = $href_row->{$marker};
			$value =~ s/^\s+//; # strip whitespaces
			$value =~ s/\s+$//;
			if ($marker eq "::sub") {
				# every row requires a ::sub entry, so I use it to skip empty lines
				goto next_row if ($value eq "");
				if ($value =~ m/^0x/i) {
					$offset = hex($value); 
				} else {
					$offset = $value;
				};
				# account for special meaning of sub column in AVFB project
				if ($database_type eq "AVFB") {
					$offset = $offset * 2; # transform to byte address
				};
				next;
			};
			if ($marker eq "::interface") {
				$domain = $value; next;
			} 
			if ($marker eq "::inst") {
				$reg = $value; next;
			};
			if ($marker eq "::width") {
				$rsize = $value;
			};
			if ($marker =~ m/^::def/) {
				$fdefinition = $value;
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
			print STDERR "ERROR: bad field \'$fname\' in register \'$reg\' in domain \'$domain\', must be continuous bit-slice\n";
			$result = 0;
		};

		# do not add "reserved" fields to database (boring)
		if ($fname !~ /reserved/i) {
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
			
			if(!ref($o_reg) or $reg ne $o_reg->name) {
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
						print STDERR "WARNING: registers \'$reg\' and \'".$o_tmp->name."\' are mapped to the same address in domain\n";
						$o_reg = undef;
					};
				};
				if (!ref($o_reg)) {
					$o_reg = Micronas::RegReg->new('name' => $reg);
					$o_reg->attribs('size' => $rsize);

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
					print STDERR "ERROR: overlapping fields in register \'$reg\'\n";
					last;
				}; 
			};

			# create new field object
			$o_field = Micronas::RegField->new('name' => $fname, 'definition' => $fdefinition, 'reg' => $o_reg);
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

	# free some memory
        my $reports = "";
        $reports = join( ',', @{$OPTVAL{'report'}} ) if (exists($OPTVAL{'report'}));
	@$lref_rm = () unless ($reports =~ m/\breglist\b/io);
	return $result;
};

1;
