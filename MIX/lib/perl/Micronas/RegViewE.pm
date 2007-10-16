###############################################################################
#  RCSId: $Id: RegViewE.pm,v 1.24 2007/10/16 08:27:33 lutscher Exp $
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
#  Revision 1.24  2007/10/16 08:27:33  lutscher
#  added mic_extensions for generated code
#
#  Revision 1.23  2007/10/15 08:50:25  lutscher
#  changed the generated e-code for reglists
#
#  Revision 1.22  2007/09/20 13:11:17  lutscher
#  fixed code header
#
#  Revision 1.21  2007/09/20 08:59:18  lutscher
#  add some more code for vr_ad
#
#  Revision 1.20  2007/05/07 07:09:58  lutscher
#  small changes
#
#  Revision 1.19  2007/03/02 14:35:52  lutscher
#  fixed bug in write_extend_coverage()
#
#  Revision 1.18  2006/11/23 15:11:31  lutscher
#  changed coverage generation
#
#  Revision 1.17  2006/11/20 17:12:19  lutscher
#  major changes
#
#  Revision 1.16  2006/11/13 17:24:42  lutscher
#  added reg_shell.e_vr_ad parameters
#
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
	my $this = shift;
	my @ldomains;
	my $href;
	my $o_domain;
    
	# add global class members for static data
	$this->global(
                  'header'         => "  created automatically by $0\n  do not edit manually!!!\n\n<\'\n",
                  'footer'         => "\'>\n",
                  'suffix'         => ".e",
                  'reg_macro'	   => "reg_def",
                  'field_macro'	   => "reg_fld",
                  'hole_name'	   => "reserved_at_",
                  'mic_extensions' => "_MIC_VR_AD_EXTENSIONS_", # e-code macro to check if micronas extensions to vr_ad are present
                  'hole_access'    => "STANDARD", # "STANDARD" or "AUTO" || STANDARD permission of holes = "R", "AUTO"  permission of holes like the most in the register
				  'lexclude_cfg'   => [],           # list of registers to exclude from code generation
				 );
    
    # import regshell.<par> parameters from MIX package to class data; user can change these parameters in mix.cfg
    my $param;
	my @lmixparams = (
                      'reg_shell.datawidth',
                      'reg_shell.e_vr_ad.regfile_prefix',
                      'reg_shell.e_vr_ad.file_prefix',
                      'reg_shell.e_vr_ad.vplan_ref',    # if not %EMPTY%, will add coverage group with vplan_ref attribute
                      'reg_shell.e_vr_ad.cover_ign_read_to_write_only',
                      'reg_shell.e_vr_ad.cover_ign_write_to_read_only',
                      'reg_shell.e_vr_ad.field_naming', # see Globals.pm
                      'reg_shell.e_vr_ad.reg_naming',   # see Globals.pm
                      'reg_shell.e_vr_ad.path',         # output path
                      'reg_shell.exclude_regs',
					  'reg_shell.exclude_fields'
					 );
    
    # make shortcuts for parameters
	foreach $param (@lmixparams) {
		my ($main, $sub, $subsub) = split(/\./,$param);
		if (ref $eh->get("${main}.${sub}")) {
			$this->global($subsub => $eh->get("${main}.${sub}.${subsub}"));
			_info("setting parameter $param = ", $this->global->{$subsub});
		} elsif (defined $eh->get("${main}.${sub}")) {
			$this->global($sub => $eh->get("${main}.${sub}"));
			_info("setting parameter $param = ", $this->global->{$sub});
		} else {
			_error("parameter \'$param\' unknown");
		};
	};
    
	my $hole_name  = $this->global->{hole_name};
    
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
	if (!scalar(@ldomains)) {   # something to do ?
		_warning("no domains found to process, exiting");
	};
    
	# list of skipped registers and fields (put everything together in one list)
	if (exists($this->global->{'exclude_regs'})) {
		@{$this->global->{'lexclude_cfg'}} = split(/\s*,\s*/,$this->global->{'exclude_regs'});
	};
	if (exists($this->global->{'exclude_fields'})) {
		push @{$this->global->{'lexclude_cfg'}}, split(/\s*,\s*/,$this->global->{'exclude_fields'});
	};

    my $e_path = $this->global->{'path'};
	my $e_filename = join("_",$this->global->{'file_prefix'}, map {$_->{name}} @ldomains).$this->global->{'suffix'};
	open(E_FILE, ">${e_path}/${e_filename}") || logwarn("ERROR: could not open file \'${e_path}/$e_filename\' for writing");
	_info("generating file \'$e_filename\'");
	print E_FILE "\$Id:" . 
    "\$\n\nfile: $e_filename\n\n";
	print E_FILE $this->global->{'header'};
    
	my ($top_inst, $o_field, $o_reg, $cov);
	# $this->display();

	# iterate through domains   
	foreach $o_domain (@ldomains) {
        my $domain = $o_domain->name;
        my $domain_str = $this->global->{regfile_prefix}. "_". uc($domain);
        my $domain_max_offset = 4;
        my %hdef = ();
        my $reg_name;   
        my $reg_addr_str; 

        my $clone_number = $o_domain->clone->{'number'};
        my $clone_addr_spacing = 0;
        if ($clone_number > 0) {
            $clone_addr_spacing = 2**$o_domain->clone->{'addr_spacing'}; # convert from address-bits to bytes
        };
        #print E_FILE "\n-- domain $domain_str\n\n";
		# iterate through all registers of the domain
		foreach $o_reg (@{$o_domain->regs}) {            
			my $reg_access = "";
			my $reg_offset = $o_domain->get_reg_address($o_reg);
            if ($reg_offset > $domain_max_offset) {
                $domain_max_offset = $reg_offset;
            };
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
            # skip register defined by user
            if (grep ($_ eq $o_reg->name, @{$this->global->{'lexclude_cfg'}})) {
                _info("skipping register ", $o_reg->name);
                next;
            };

            my $reg_access_mode = $o_reg->get_reg_access_mode(); # W, R or RW
			$permission{"RW"} = 0;
			$permission{"R"} = 0;
			$permission{"W"} = 0;
             
            $reg_addr_str = "0x" . _val2hex($eh->get('reg_shell.addrwidth'), $reg_offset);
			if ($o_reg->{'definition'} eq '') {
                $reg_name = _clone_name($this->global->{'reg_naming'}, 0, 0, $domain, $o_reg->name);     
			} else {
                $reg_name = $o_reg->{'definition'}; 
                push @{$hdef{$reg_name}}, $reg_addr_str;
            };
			$ii =0;
            
			foreach $href (@{$o_reg->fields}) {
			    $o_field = $href->{'field'};
			    #next if $o_field->name =~ m/^UPD[EF]/; # skip UPD* regs		 
                # skip fields defined by user
                if (grep ($_ eq $o_field->name, @{$this->global->{'lexclude_cfg'}})) {
                    _info("skipping field ", $o_field->name);
                    next;
                };
			    $thefields[$ii]{name} 		  = _clone_name($this->global->{'field_naming'}, 0, 0, $domain, $reg_name, $o_field->name);
			    $thefields[$ii]{pos}  		  = $href->{'pos'};
			    $thefields[$ii]{size} 		  = $o_field->attribs->{'size'};
			    $thefields[$ii]{rw}   		  = uc($o_field->attribs->{'dir'});
			    $thefields[$ii]{init}         = "0x"._val2hex($o_field->attribs->{'size'}, $o_field->attribs->{'init'});
			    $permission{$thefields[$ii]{rw}}++;
			    $ii += 1;               
			};
			
			@thefields = reverse sort {$a->{'pos'} <=> $b->{'pos'}} @thefields;
            $upper = $eh->get('reg_shell.datawidth'); # initial value of the upper limit
            @thefields_and_theholes = ();
            
            foreach $value (sort {$permission{$a} cmp $permission{$b} }keys %permission){
                $perm = $value;
            };
            
            $ii =0;
            foreach $singlefield (@thefields) {
                $hole_size = $upper - ($singlefield->{pos} + $singlefield->{size});		
                
                if ($hole_size != 0) {
                    $theholes[$ii]{pos}  = $singlefield->{pos} + $singlefield->{size};
                    $theholes[$ii]{name} = $hole_name . $theholes[$ii]{pos};
                    $theholes[$ii]{size} = $upper - ($singlefield->{pos} + $singlefield->{size});
                    if ($this->global->{'hole_access'} eq "STANDARD"){
                        $theholes[$ii]{rw}   = "R";
                    }else{
                        $theholes[$ii]{rw}   = $perm;
                    };
                    $theholes[$ii]{init}  = "0x0";
                    $ii++;
                } 
                $upper  = $singlefield->{pos};
            };
            
            if ($upper != 0) {
                $theholes[$ii]{pos}  = 0;
                $theholes[$ii]{name} = $hole_name . "0";
                $theholes[$ii]{size} = $upper;
                if ($this->global->{'hole_access'} eq "STANDARD"){
                    $theholes[$ii]{rw}   = "R";
                }else{
                    $theholes[$ii]{rw}   = $perm;
                };
                $theholes[$ii]{init}  = "0x0";
                $ii++;
            } 
            
            @thefields_and_theholes = (@thefields,@theholes);
            @thefields_and_theholes = reverse sort {$a->{pos} <=> $b->{pos}} @thefields_and_theholes;
            
            if ($o_reg->{'definition'} eq '' || scalar(@{$hdef{$reg_name}})==1) {
                print E_FILE $this->global->{reg_macro}, " $reg_name";
                if ($o_reg->{'definition'} eq '') {
                    print E_FILE " $domain_str $reg_addr_str \{\n";
                } else {
                    print E_FILE " \{\n";
                };                
                foreach $singlefield (@thefields_and_theholes) {
                    if ($singlefield->{name} =~ m/$hole_name/i) {
                        $cov = "";
                    } else {
                        $cov = " : cov";
                    };
                    format E_FILE = 
   @<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<: uint(bits:@>) : @< : @<<<<<<<<< @<<<<<< ; -- lsb position @>> 
$this->global->{field_macro},$singlefield->{name},$singlefield->{size},$singlefield->{rw},$singlefield->{init},$cov, $singlefield->{pos} 
.
                    write E_FILE;
                };
                print E_FILE "};\n";
                my $is_cloned = 0;
                if (exists $o_reg->{'inst_n'}) {
                    $is_cloned = 1;
                };
                $this->write_extend_reg($reg_name, $reg_access_mode, $is_cloned); 
            };
        };
        
        my ($index, $n);
        foreach $reg_name (keys %hdef){
            $n = scalar(@{$hdef{$reg_name}});
            # output: list of regs instances
            printf E_FILE ("extend $domain_str vr_ad_reg_file {\n"); 
            printf E_FILE ("  %%%s_n:list of $reg_name vr_ad_reg;\n",lc($reg_name));
            printf E_FILE ("  keep soft %s_n.size() == $n;\n", lc($reg_name));
            printf E_FILE ("  post_generate() is also {\n");
            $index = 0;
            foreach $reg_addr_str (@{$hdef{$reg_name}}) {
                printf E_FILE ("    add_with_offset(%s,%s_n[%s]);\n",$reg_addr_str,lc($reg_name),$index++);
            };
            _info("generated a list of \'$reg_name\' vr_ad_reg with $n items");
            printf E_FILE ("  };\n");
            printf E_FILE ("};\n");
        };
        printf E_FILE ("\n\nextend vr_ad_reg_file_kind : [%s];\n\n", $domain_str );
        printf E_FILE ("extend $domain_str vr_ad_reg_file {\n");
        printf E_FILE ("  default_reset: bool;\n");
        printf E_FILE ("  keep soft default_reset;\n");
        printf E_FILE ("  post_generate() is also {\n");
        printf E_FILE ("    if default_reset { reset(); }\n  };\n");
        # note: the size of the reg_file is determined by the highest address; possibly also by addressing_width_in_bytes
        # but the current formula is pessimistic and should work, though wastes some space
        printf E_FILE ("  keep soft size == ".(${domain_max_offset} + $this->global->{'datawidth'}/8).";\n");
        printf E_FILE ("#ifdef ".$this->global->{'mic_extensions'}." then {\n");
        printf E_FILE ("  keep is_cloned == ".($clone_number > 0 ? "TRUE":"FALSE").";\n");
        printf E_FILE ("  keep soft n_instances == ${clone_number};\n");
        printf E_FILE ("  keep soft inst_addr_spacing == ${clone_addr_spacing};\n");
        printf E_FILE ("};\n"); 
        printf E_FILE ("};\n");
        
    }; # foreach $o_domain (@ldomains)
    
    print E_FILE $this->global->{'footer'};
    
    close(E_FILE);
    
    # disable mix error message
    $eh->set('conn.req', "optional");
};

# write e-code that extends the vr_ad_reg struct 
sub write_extend_reg {
    my ($this, $reg_name, $reg_access_mode, $is_cloned) = @_;
    my $ignore = "";
    if ($this->global->{'vplan_ref'} !~ m/%empty%/i) {
        print E_FILE "extend $reg_name vr_ad_reg {\n";
        print E_FILE "  cover reg_access (kind == $reg_name) using also vplan_ref = \"", $this->global->{'vplan_ref'},"\";\n";
        print E_FILE "};\n";
    };
    if ($is_cloned) {
        print E_FILE "#ifdef ".$this->global->{'mic_extensions'}." then {\n";
        print E_FILE "extend $reg_name vr_ad_reg {\n";
        print E_FILE "  keep is_cloned == ".($is_cloned ? "TRUE":"FALSE").";\n";
        print E_FILE "};\n";
        print E_FILE "};\n";
    };
    if ($reg_access_mode ne "RW") {
        # create cover ignores for direction if enabled by the user
        if ($reg_access_mode eq "W" and $this->global->{'cover_ign_read_to_write_only'} ) {
            $ignore = "READ";
        } else {
            if ($reg_access_mode eq "R" and $this->global->{'cover_ign_write_to_read_only'} ) {
                $ignore = "WRITE";
            };
        };
        if ($ignore ne "") {
            print E_FILE "extend vr_ad_reg {\n";
            print E_FILE "  cover reg_access (kind == $reg_name) is also {\n";
            print E_FILE "    item direction using also ignore = direction == ${ignore};\n";
            print E_FILE "  };\n";
            print E_FILE "};\n";
        };
    };
    print E_FILE "\n";
};

# end view: E_VR_AD
#------------------------------------------------------------------------------

1;
