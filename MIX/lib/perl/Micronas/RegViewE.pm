###############################################################################
#  RCSId: $Id: RegViewE.pm,v 1.2 2005/11/29 08:41:58 lutscher Exp $
###############################################################################
#                                  
#  Related Files :  Reg.pm
#
#  Author(s)     :  Emanuel Marconetti                                      
#  Email         :  emanuel.marconetti@micronas.com                          
#
#  Project       :  MIX                                                 
#
#  Creation Date :  30.06.2005
#
#  Contents      :  Utility functions to create e-code register space views
#                   from Reg class object
#        
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
#  $Log: RegViewE.pm,v $
#  Revision 1.2  2005/11/29 08:41:58  lutscher
#  fixed parsing of domain list
#
#  Revision 1.1  2005/11/23 13:23:17  lutscher
#  renamed from RegViewsE.pm
#
#  Revision 1.7  2005/11/08 14:31:53  marema
#  hole becomes hole_at_lsb
#
#  Revision 1.6  2005/11/08 12:27:35  lutscher
#  added debug flag checking
#
#  Revision 1.5  2005/11/08 11:37:06  lutscher
#  o fixed reg_offset conversion to hex
#  o added some code to import parameters from MIX
#  o increased width of field name column in template
#
#  Revision 1.4  2005/11/02 14:37:09  lutscher
#  now uses domain name instead of block attribute for code generation
#
#  Revision 1.3  2005/10/28 12:30:58  lutscher
#  some more fixes to make direction uppercase; removed an obsolete error message
#
#  Revision 1.2  2005/10/28 10:42:01  marema
#  fixed missing colon in printout
#
#  Revision 1.1  2005/09/16 13:57:27  lutscher
#  added register view E_VR_AD from Emanuel
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
use Micronas::MixParser qw( %hierdb %conndb add_inst add_conn );
use Micronas::Reg;
use Micronas::RegDomain;
use Micronas::RegReg;
use Micronas::RegField;

#use FindBin qw($Bin);
#use lib "$Bin";
#use lib "$Bin/..";
#use lib "$Bin/lib";

#------------------------------------------------------------------------------
# Private methods (of class Reg)
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# view: E_VR_AD

# Generate e-language macros containing bit-field declarations;
# input: domain name(s) for which the code is generated; if omitted, 
# one output is generated containing all register space domains in the Reg object
sub _gen_view_vr_ad {
	my $this = shift;
	my @ldomains;
	my $href;
	my $verbose = 0;
	my $o_domain;

	# add global class members for static data
	$this->global('E_FILE'      => {
									'header' => " created automatically by $0\n\n<\'\n",
									'footer' => "\'>\n",
									'prefix' => "regdef",
									'suffix' => ".e"
								   },
				  'REGISTER'	=>	{ 
									 'macro_prefix'	=> "reg_def",
									 'reg_prefix'	=> "MIC",
									},
				  'FIELD' 		=>	{ 
									 'hole_name'	=> "hole_at_",
									 'macro_prefix'	=> "reg_fld",
									 'lower_case'	=> "true",
									},
				 );

	# import regshell.<par> parameters from MIX package to class data; user can change these parameters in mix.cfg
	my $param;
	my @lmixparams = (
					  'reg_shell.addrwidth', 
					  'reg_shell.datawidth',
					 );
	foreach $param (@lmixparams) {
		my ($main, $sub) = split(/\./,$param);
		if (exists($EH{$main}{$sub})) {
			$this->global->{'REGISTER'}->{$sub} = $EH{$main}{$sub};
			_info("setting parameter $param = ", $this->global->{'REGISTER'}->{$sub}) if $this->global->{'debug'};
		} else {
			_error("parameter \'$param\' unknown");
			if (defined (%EH)) { $EH{'sum'}{'errors'}++;};
		};
	};


	my $reg_size   = $this->global->{REGISTER}->{datawidth};
	my $addr_size  = $this->global->{REGISTER}->{addrwidth};
	my $reg_def    = $this->global->{REGISTER}{macro_prefix};
	my $reg_prefix = $this->global->{REGISTER}{reg_prefix};
	my $hole_name  = $this->global->{FIELD}{hole_name};
	my $reg_fld    = $this->global->{FIELD}{macro_prefix};

	# make list of domains for generation
	if (scalar (@_)) {
		foreach my $domain (@_) {
			$o_domain = $this->find_domain_by_name_first($domain);
			if (ref($o_domain)) {
				push @ldomains, $this->find_domain_by_name_first($domain);
			};
		};
	} else {
		foreach $href (@{$this->domains}) {
			push @ldomains, $href->{'domain'};
		};
	};
	if (!scalar(@ldomains)) { # something to do ?
		_warning("no domains found to process, exiting");
	};

	my $e_filename = join("_",$this->global->{'E_FILE'}{'prefix'}, map {$_->{name}} @ldomains).$this->global->{'E_FILE'}{'suffix'};
	open(E_FILE, ">$e_filename") || logwarn("ERROR: could not open file \'$e_filename\' for writing");
	_info("generating file \'$e_filename\'");
	print E_FILE " file: $e_filename\n";
	print E_FILE $this->global->{'E_FILE'}{'header'};

	my ($top_inst, $o_field, $o_reg);
	
	# iterate through domains
	foreach $o_domain (@ldomains) {
		# iterate through all registers of the domain and add ports/instantiations
		foreach $o_reg (@{$o_domain->regs}) {
			my $reg_access = "";
			my $reg_offset = $o_domain->get_reg_address($o_reg);
			my @thefields = ();
			my @theholes = ();
			my @thefields_and_theholes = ();
			my $ii;
			my $singlefield;
			my $upper;
			my $hole_size;
						
			print E_FILE $reg_def, " ", uc($o_reg->name);
			print E_FILE " ", $reg_prefix, "_";
			
			$ii =0;
			foreach $href (@{$o_reg->fields}) {
				$o_field = $href->{'field'};
				next if $o_field->name =~ m/^UPD[EF]/; # skip UPD* regs
				# select type of register
				if ($reg_access eq "") {
					$reg_access = lc($o_field->attribs->{'dir'});
				};
				
				$thefields[$ii]{name} 		= lc($o_field->name);
				$thefields[$ii]{pos}  		= $href->{'pos'};
				$thefields[$ii]{size} 		= $o_field->attribs->{'size'};
				$thefields[$ii]{rw}   		= uc($reg_access);
				# $thefields[$ii]{parent_block}   = $o_field->attribs->{'block'};
				$thefields[$ii]{parent_block}   = $o_domain->name;
				
				$ii += 1;	
			};
			
			@thefields = reverse sort {${$a}{pos} <=> ${$b}{pos}} @thefields;
	
	        $upper = $reg_size;    # initial value of the upper limit
	        @thefields_and_theholes = ();
	
	        $ii =0;
	        foreach $singlefield (@thefields) {
		
				$hole_size = $upper - (${$singlefield}{pos} + ${$singlefield}{size});		

                if ($hole_size != 0) {
					$theholes[$ii]{pos}  = ${$singlefield}{pos} + ${$singlefield}{size};
					$theholes[$ii]{name} = $hole_name . $theholes[$ii]{pos};
                    $theholes[$ii]{size} = $upper - (${$singlefield}{pos} + ${$singlefield}{size});
                    $theholes[$ii]{rw}   = uc(${$singlefield}{rw});
			     $theholes[$ii]{parent_block}   = ${$singlefield}{parent_block};
			     $ii++;
			  } 
			  $upper     = ${$singlefield}{pos};
			}
			
                        if ($upper != 0) {
			     $theholes[$ii]{pos}  = 0;
			     $theholes[$ii]{name} = $hole_name . "0";
			     $theholes[$ii]{size} = $upper;
			     $theholes[$ii]{rw}   = "RW";
			     $theholes[$ii]{parent_block}   = "na";
			     $ii++;
			} 

                        @thefields_and_theholes = (@thefields,@theholes);
                        @thefields_and_theholes = reverse sort {${$a}{pos} <=> ${$b}{pos}} @thefields_and_theholes;


                        $ii =0;
			foreach $singlefield (@thefields_and_theholes) {
		                if ($ii == 0) {
					print E_FILE uc(${$singlefield}{parent_block}), " 0x", _val2hex($addr_size, $reg_offset), " {\n";
				}
				
format E_FILE =
    @<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<: uint(bits:@>) : @< : 0 : cov ; -- lsb position @>>
$reg_fld,${$singlefield}{name},${$singlefield}{size},${$singlefield}{rw},${$singlefield}{pos}
.
      write E_FILE ;
			$ii += 1;	
			};
            print E_FILE "};\n";
		};  
	};
	print E_FILE $this->global->{'E_FILE'}{'footer'};

close(E_FILE);

};

# end view: E_VR_AD
#------------------------------------------------------------------------------

1;
