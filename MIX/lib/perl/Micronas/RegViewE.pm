###############################################################################
#  RCSId: $Id: RegViewE.pm,v 1.15 2006/07/05 13:24:22 roettger Exp $
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
#  Revision 1.15  2006/07/05 13:24:22  roettger
#  small change
#
#  Revision 1.14  2006/07/04 12:57:51  roettger
#  fixed access attribute for holes to 'R'
#
#  Revision 1.13  2006/07/04 08:49:56  lutscher
#  changed the upper/lower-case conversions as before
#
#  Revision 1.12  2006/06/26 13:48:47  roettger
#  added config
#
#  Revision 1.11  2006/06/23 14:44:41  lutscher
#  fixed typo
#
#  Revision 1.10  2006/06/23 14:15:43  lutscher
#  convert names to lowercase
#
#  Revision 1.9  2006/06/23 12:46:47  lutscher
#  small change
#
#  Revision 1.8  2006/06/12 10:05:01  roettger
#  added, output with definition in register list
#
#  Revision 1.7  2006/05/30 15:00:49  roettger
#  fixed acess attribute for holes to prevent false coverage holes
#
#  Revision 1.6  2006/03/14 14:21:19  lutscher
#  made changes for new eh access and logger functions
#
#  Revision 1.5  2006/03/03 10:26:34  lutscher
#  removed coverage for reserved fields
#
#  Revision 1.4  2005/12/21 12:26:23  lutscher
#  changed hole_name
#
#  Revision 1.3  2005/12/21 12:03:01  lutscher
#  o fixed access direction of holes to be R
#  o added field reset values from database (was set to 0)
#
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
use Micronas::MixUtils qw($eh);
use Micronas::MixParser qw( %hierdb %conndb add_inst add_conn );
use Micronas::Reg;
use Micronas::RegDomain;
use Micronas::RegReg;
use Micronas::RegField;
use Micronas::MixUtils::RegUtils;

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
        my $holes_permission = "STANDARD";        # "STANDARD" or "AUTO" || STANDARD permission of holes = "R", 
	                                          # "AUTO"  permission of holes like the most in the register
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
									 'hole_name'	=> "reserved_at_",
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
		if ($eh->get("${main}.${sub}")) {
			$this->global->{'REGISTER'}->{$sub} = $eh->get("${main}.${sub}");
			_info("setting parameter $param = ", $this->global->{'REGISTER'}->{$sub}) if $this->global->{'debug'};
		} else {
			_error("parameter \'$param\' unknown");
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
	my $my_reg_file_name = uc(join("_",$reg_prefix, map {$_->{name}} @ldomains));

	my $e_filename = join("_",$this->global->{'E_FILE'}{'prefix'}, map {$_->{name}} @ldomains).$this->global->{'E_FILE'}{'suffix'};
	open(E_FILE, ">$e_filename") || logwarn("ERROR: could not open file \'$e_filename\' for writing");
	_info("generating file \'$e_filename\'");
	print E_FILE "\n\n\n file: $e_filename\n\n\n\n";
	print E_FILE $this->global->{'E_FILE'}{'header'};

	my ($top_inst, $o_field, $o_reg, $cov);
	
	# iterate through domains

	my %def = ();
	my $aa;
	my $bb;
	my $ee;
   
	foreach $o_domain (@ldomains) {
	    foreach $o_reg (@{$o_domain->regs}) {
		$def{$o_reg->{'definition'}}{definition} ='';	
	    };
	};
        
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
			
			my %permission = ();
			my $perm;
			my $value;

			$permission{"RW"} = 0;
			$permission{"R"} = 0;
			$permission{"W"} = 0;
		
			if ($o_reg->{'definition'} eq '') {
                # convert register name to upper case because it is an enum type in e
			    print E_FILE $reg_def, " ", uc($o_reg->name);
			    print E_FILE " ", $reg_prefix, "_";
			};
			$ii =0;
			
		    
			
			foreach $href (@{$o_reg->fields}) {
			    $o_field = $href->{'field'};
			    next if $o_field->name =~ m/^UPD[EF]/; # skip UPD* regs
			    
			    $thefields[$ii]{name} 		  = lc($o_field->name);
			    $thefields[$ii]{pos}  		  = $href->{'pos'};
			    $thefields[$ii]{size} 		  = $o_field->attribs->{'size'};
			    $thefields[$ii]{rw}   		  = uc($o_field->attribs->{'dir'});
			    $thefields[$ii]{parent_block} = $o_domain->name;
			    $thefields[$ii]{init}         = "0x"._val2hex($o_field->attribs->{'size'}, $o_field->attribs->{'init'});
			    $permission{$thefields[$ii]{rw}}++;
			    $ii += 1;
			  
			};
			
			@thefields = reverse (sort ({${$a}{pos} <=> ${$b}{pos}} @thefields));
			$upper = $reg_size;    # initial value of the upper limit
			@thefields_and_theholes = ();
			
			foreach $value (sort {$permission{$a} cmp $permission{$b} }keys %permission){
			    $perm = $value;
			};
			
			$ii =0;
			foreach $singlefield (@thefields) {
			    
			    $hole_size = $upper - (${$singlefield}{pos} + ${$singlefield}{size});		
			    
			    if ($hole_size != 0) {
				$theholes[$ii]{pos}  = ${$singlefield}{pos} + ${$singlefield}{size};
				$theholes[$ii]{name} = $hole_name . $theholes[$ii]{pos};
				$theholes[$ii]{size} = $upper - (${$singlefield}{pos} + ${$singlefield}{size});
				if ($holes_permission eq "STANDARD"){
				    $theholes[$ii]{rw}   = "R";
				}else{
				    $theholes[$ii]{rw}   = $perm;
				};
				$theholes[$ii]{parent_block}   = ${$singlefield}{parent_block};
				$theholes[$ii]{init}  = "0x0";
				$ii++;
			    } 
			    $upper     = ${$singlefield}{pos};
			};
			
			if ($upper != 0) {
			    $theholes[$ii]{pos}  = 0;
			    $theholes[$ii]{name} = $hole_name . "0";
			    $theholes[$ii]{size} = $upper;
			    if ($holes_permission eq "STANDARD"){
				$theholes[$ii]{rw}   = "R";
			    }else{
				$theholes[$ii]{rw}   = $perm;
			    };
			    $theholes[$ii]{parent_block}   = "na";
			    $theholes[$ii]{init}  = "0x0";
			    $ii++;
			} 
			
			@thefields_and_theholes = (@thefields,@theholes);
			@thefields_and_theholes = reverse sort {${$a}{pos} <=> ${$b}{pos}} @thefields_and_theholes;
			
		
			$ii =0;
			$bb =0;
			$aa = 0;
			foreach $singlefield (@thefields_and_theholes) {
			    if ($o_reg->{'definition'} eq '') {
				if ($ii == 0) {
				    print E_FILE uc(${$singlefield}{parent_block}), " 0x", _val2hex($addr_size, $reg_offset), " {\n";
				};
				if (${$singlefield}{name} =~ m/$hole_name/i) {
				    $cov = "";
				} else {
				    $cov = " : cov";
				};
				format E_FILE = 
   @<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<: uint(bits:@>) : @< : @<<<<<<<<< @<<<<<< ; -- lsb position @>> 
$reg_fld,${$singlefield}{name},${$singlefield}{size},${$singlefield}{rw},${$singlefield}{init},$cov, ${$singlefield}{pos} 
.
                                write E_FILE ;
                                $ii += 1;	
                              }else{  
                                  if ($def{$o_reg->{'definition'}}{definition} eq '') {
                                    if (${$singlefield}{name} =~ m/$hole_name/i) {
				       $cov = "";
      				    } else {
				        $cov = " : cov";
				    };
                                    # reg - save
                                    $def{$o_reg->{'definition'}}{fields}[$bb]{name} = ${$singlefield}{name};
                                    $def{$o_reg->{'definition'}}{fields}[$bb]{size} = ${$singlefield}{size};
                                    $def{$o_reg->{'definition'}}{fields}[$bb]{rw} = ${$singlefield}{rw};
                                    $def{$o_reg->{'definition'}}{fields}[$bb]{init} = ${$singlefield}{init};
                                    $def{$o_reg->{'definition'}}{fields}[$bb]{cov} = $cov;
                                    $def{$o_reg->{'definition'}}{fields}[$bb]{pos} = ${$singlefield}{pos};
                                    $bb += 1;    
                                  };
                                  if (${$singlefield}{pos} == 0){
                                    # save every instance of reg with address
                                    foreach $ee(0..$#{ $def{$o_reg->{'definition'}}{list} }){
                                       $aa = $ee + 1;
                                    };
                                    $def{$o_reg->{'definition'}}{definition} = $o_reg->{'definition'};
                                    $def{$o_reg->{'definition'}}{list}[$aa]{MY_REG} = $o_reg->{'definition'};
                                    $def{$o_reg->{'definition'}}{list}[$aa]{MY_REG_FILE} =  $reg_prefix . "_" . uc(${$singlefield}{parent_block});
                                    $def{$o_reg->{'definition'}}{list}[$aa]{address} = "0x" . _val2hex($addr_size, $reg_offset);
                                  };
                              }; 
                        };
                        if ($o_reg->{'definition'} eq '') {
                            print E_FILE "};\n"; 
                        };
                };
        };
        
        my $cc;
        my $dd;
        my $valus;
        
        

        foreach $cc (keys %def){
          if ($cc ne ''){
            # output: regdef
            print E_FILE $reg_def, " ", $def{$cc}{list}[0]{MY_REG}, " {\n";
            for $dd(0..$#{ $def{$cc}{fields} } ) {
               printf E_FILE ("   %-7s %-33s : uint(bits:%2s) ", $reg_fld,$def{$cc}{fields}[$dd]{name}, $def{$cc}{fields}[$dd]{size});
               printf E_FILE (": %-2s : %-10s %-7s ;", $def{$cc}{fields}[$dd]{rw}, $def{$cc}{fields}[$dd]{init},$def{$cc}{fields}[$dd]{cov});
               printf E_FILE (" -- lsb position %3s\n", $def{$cc}{fields}[$dd]{pos});
            };
            print E_FILE "}; \n";
            # output: list of regs instances
            printf  E_FILE ("extend %s vr_ad_reg_file {\n",$def{$cc}{list}[0]{MY_REG_FILE}); 
            foreach $ee(0..$#{ $def{$cc}{list} } ){
                $valus = $ee;
            };  
            printf E_FILE ("  %%%s_n[%s]:list of %s vr_ad_reg;\n",lc($def{$cc}{list}[0]{MY_REG}),($valus+1),$def{$cc}{list}[0]{MY_REG});
            printf E_FILE ("  post_generate() is also {\n");
            for $dd(0..$#{ $def{$cc}{list} } ) {
               printf E_FILE ("    add_with_offset(%s,%s_n[%s]);\n",$def{$cc}{list}[$dd]{address},lc($def{$cc}{list}[0]{MY_REG}),$dd);
            };
            _info("Generated a list of ", $def{$cc}{list}[0]{MY_REG}, " with ", ($valus+1), " items");
            printf E_FILE ("  };\n");
            printf E_FILE ("};\n");
          };
    
        };


      printf E_FILE ("\n\nextend vr_ad_reg_file_kind : [%s];\n", $my_reg_file_name );
      print E_FILE $this->global->{'E_FILE'}{'footer'};

     close(E_FILE);
};

# end view: E_VR_AD
#------------------------------------------------------------------------------

1;
