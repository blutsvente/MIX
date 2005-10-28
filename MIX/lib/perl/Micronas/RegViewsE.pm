###############################################################################
#  RCSId: $Id: RegViewsE.pm,v 1.2 2005/10/28 10:42:01 marema Exp $
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
#  Contents      :  Utility functions to create different register space views
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
#  $Log: RegViewsE.pm,v $
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

	# add global class members
	$this->global('E_FILE'      => {
					'header' => " created automatically by $0\n\n<\'\n",
					'footer' => "\'>\n",
					'prefix' => "regdef_",
					'suffix' => ".e"
					},
			'REGISTER'	=>	{ 
									 'size'		=> 32,
									 'macro_prefix'	=> "reg_def",
									 'reg_prefix'	=> "MIC",
									},
				  'FIELD' 		=>	{ 
									 'hole_name'	=> "hole",
									 'macro_prefix'	=> "reg_fld",
									 'lower_case'	=> "true",
									},
				 );

	my $reg_size   = $this->global->{REGISTER}{size};
	my $reg_def    = $this->global->{REGISTER}{macro_prefix};
	my $reg_prefix = $this->global->{REGISTER}{reg_prefix};
	my $hole_name  = $this->global->{FIELD}{hole_name};
	my $reg_fld    = $this->global->{FIELD}{macro_prefix};

	# make list of domains for generation
	if (scalar (@_)) {
		foreach my $domain (@_) {
			push @ldomains, $this->find_domain_by_name_first($domain);
		};
	} else {
		foreach $href (@{$this->domains}) {
			push @ldomains, $href->{'domain'};
		};
	};
	my $e_filename = $this->global->{'E_FILE'}{'prefix'}.join("_",map {$_->{name}} @ldomains).$this->global->{'E_FILE'}{'suffix'};
	open(E_FILE, ">$e_filename") || logwarn("ERROR: could not open file \'$e_filename\' for writing");
	print E_FILE " file: $e_filename\n";
	print E_FILE $this->global->{'E_FILE'}{'header'};

	my ($top_inst, $o_domain, $o_field, $o_reg);
	
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
				} else {
					if (lc($o_field->attribs->{'dir'}) ne $reg_access) {
						logwarn("ERROR: register \'".$o_reg->name."\': all fields in one register must have same 'dir' attribute\n"); next;
					};
				};
				
				$thefields[$ii]{name} 		= lc($o_field->name);
				$thefields[$ii]{pos}  		= $href->{'pos'};
				$thefields[$ii]{size} 		= $o_field->attribs->{'size'};
				$thefields[$ii]{rw}   		= $reg_access;
				$thefields[$ii]{parent_block}   = $o_field->attribs->{'block'};
				
				$ii += 1;	
			};
			
			@thefields = reverse sort {${$a}{pos} <=> ${$b}{pos}} @thefields;
	
	        $upper = $reg_size;    # initial value of the upper limit
	        @thefields_and_theholes = ();
	
	        $ii =0;
	        foreach $singlefield (@thefields) {
		
				$hole_size = $upper - (${$singlefield}{pos} + ${$singlefield}{size});		

                if ($hole_size != 0) {
					$theholes[$ii]{name} = $hole_name;
					$theholes[$ii]{pos}  = ${$singlefield}{pos} + ${$singlefield}{size};
                    $theholes[$ii]{size} = $upper - (${$singlefield}{pos} + ${$singlefield}{size});
                    $theholes[$ii]{rw}   = ${$singlefield}{rw};
			     $theholes[$ii]{parent_block}   = ${$singlefield}{parent_block};
			     $ii++;
			  } 
			  $upper     = ${$singlefield}{pos};
			}
			
                        if ($upper != 0) {
			     $theholes[$ii]{name} = $hole_name;
			     $theholes[$ii]{pos}  = 0;
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
					print E_FILE uc(${$singlefield}{parent_block}), " 0x", $reg_offset, " {\n";
				}
				
format E_FILE =
    @<<<<<< @<<<<<<<<<<<<<<<<<: uint(bits:@>) : @< : 0 : cov ; -- lsb position @>>
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
