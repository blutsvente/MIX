###############################################################################
#  RCSId: $Id: Reg.pm,v 1.1 2005/07/07 12:35:26 lutscher Exp $
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
use Micronas::MixUtils qw(%EH);
use Micronas::RegDomain;
use Micronas::RegReg;
use Micronas::RegField;
use Micronas::RegViews;

#use FindBin qw($Bin);
#use lib "$Bin";
#use lib "$Bin/..";
#use lib "$Bin/lib";

#------------------------------------------------------------------------------
# Class members
#------------------------------------------------------------------------------
our($debug) = 0;
our($VERSION) = '1.1';

# global constants and defaults; is mapped per reference into Reg objects
our(%hglobal) = 
  (
   # supported register-master types
   supported_register_master_type => ["VGCA", "FRCH"], 
   # generatable register views 
   supported_views => ["HDL-vrs"], 
   # attributes in register-master that do not belong to a field
   non_field_attributes => [qw(::ign ::sub ::interface ::inst ::width ::b:.* ::b ::addr ::dev ::vi2c ::default ::name ::type)],
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
# Methods
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
		$this->_map_register_master($hinput{database_type}, $hinput{register_master});
	} else {
		die "ERROR: unknown inputformat \'$this->{inputformat}\'";
	};
};

# generate a view of the register space
sub generate_view {
	my $this = shift;
	my $view = shift;

	if ($view eq "HDL-vrs") {
		$this->_gen_view_vrs();
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

# default display method
sub display {
	my $this = shift;
	my $dump  = Data::Dumper->new([$this]);
	$dump->Maxdepth(3);
	$dump->Sortkeys(1);
	print $dump->Dump;
};

#------------------------------------------------------------------------------
# Private methods
#------------------------------------------------------------------------------

# builds a register space object from a list in register-master format
# input: 1. string for input database type, accounts for different flavours of the register master
# 2. list of hashes, one for each row in the source sheet
# caveats: 
# two consecutive registers must have different names (::instance)
# two consecutive domains must have different names (::interface)
sub _map_register_master {
	my ($this, $database_type, $lref_rm) = @_;
	my($href_row, $marker, $rsize, $reg, $value, $fname, $fpos, $fsize, $domain, $offset, $msb, $msb_max, $lsb, $p, $new_fname, $usedbits, $baseaddr, $col_cnt);
	my($o_domain, $o_reg, $o_field) = (undef, undef, undef);
	my($href_marker_types, %hattribs, %hdefault_attribs, $m);

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
	$msb_max = $EH{'i2c'}{'_mult_max_'}{'::b'};

	# iterate each row
	foreach $href_row (@$lref_rm) {
		# skip lines to ignore
		next if (exists ($href_row->{"::ign"}) and $href_row->{"::ign"} =~ /.+/);
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
				$offset = ($value =~ /^0x/ ? hex($value): $value); next;
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
			
			if ($marker =~ m/::b(:(\d+))*$/) {
				if (defined $2) {
					$p = $msb_max - $2; # bit column numbering is reversed!
				} else {
					$p = $msb_max;
				};
				if ($value =~ m/(.+)\.(\d+)/) { # <field_name>.<bit> for mult-bit fields
					$fname = $1;
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
			print STDERR "WARNING: bad field \'$fname\' in register \'$reg\' in domain \'$domain\', must be continuous bit-slice\n";
		};

		# do not add "reserved" fields to database (boring)
		if ($fname !~ /reserved/i) {
			if (!ref($o_domain) or $domain ne $o_domain->name) {
				# check if domain already exists, otherwise create new domain
				$o_domain = $this->find_domain_by_name_first($domain);
				if (!ref($o_domain)) {
					$o_domain = Micronas::RegDomain->new(name => $domain);
					# BAUSTELLE set 'implementation' field
					
					# get base-address
					if ($database_type eq "VGCA") {
						$baseaddr = hex("0x1ebc0000");
					} else {
						if ($database_type eq "FRCH" and $domain =~ m/_(\d+)$/) {
							# in FRCH, they have pages of up to 256 Words each
							$baseaddr = $1 << 8;
						} else {
							print STDERR "ERROR: could not extract base address from ::interface value \'$domain\' in register master (database type is \'$database_type\')\n";
						};
					};
					# link domain object into register space object
					$this->domains(domain => $o_domain, baseaddr => $baseaddr);
				};
			};
			
			if(!ref($o_reg) or $reg ne $o_reg->name) {
				# add usedbits attribute to last register
				if (ref($o_reg)) {
					$o_reg->attribs(usedbits => $usedbits);
					$usedbits = 0;
				};

				# check if register already exists in domain, otherwise create new register object
				$o_reg = $o_domain->find_reg_by_address_first($offset);
				if (!ref($o_reg)) {
					$o_reg = Micronas::RegReg->new(name => $reg);
					$o_reg->attribs(size => $rsize);

					# link register object into domain
					$o_domain->regs($o_reg);
					$o_domain->addrmap(reg => $o_reg, offset => $offset);
				};
			};

			# compute bit-mask for register
			for (my $i=$fpos; $i < $fpos+$fsize; $i++) {
				$usedbits |= 1<<$i;
			}; 

			# create new field object
			$o_field = Micronas::RegField->new(name => $fname, reg => $o_reg);
			$o_field->attribs(%hattribs);
			$o_field->attribs(size => $fsize, lsb => $lsb);
			
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
	@$lref_rm = ();
};

1;
