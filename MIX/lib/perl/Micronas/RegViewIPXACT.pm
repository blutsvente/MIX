###############################################################################
#  RCSId: $Id: RegViewIPXACT.pm,v 1.16 2009/03/20 08:49:45 lutscher Exp $
###############################################################################
#                                  
#  Related Files :  Reg.pm
#
#  Author(s)     :  Gregor Herburger                                      
#  Email         :  Gregor.Herburger@micronas.com                          
#
#  Project       :  mix                                                 
#
#  Creation Date :  03.04.2008
#
#  Contents      :  Generate XML view of Reg objects 
#
###############################################################################
#                               Copyright
###############################################################################
#
#       Copyright (C) 2008 Micronas GmbH, Munich, Germany 
#
#     All rights reserved. Reproduction in whole or part is prohibited
#          without the written permission of the copyright owner.
#
###############################################################################
#                                History
###############################################################################
#
#  $Log: RegViewIPXACT.pm,v $
#  Revision 1.16  2009/03/20 08:49:45  lutscher
#  added xml parameters
#
#  Revision 1.15  2009/03/19 10:19:37  lutscher
#  fixed ip-xact view
#
#  Revision 1.14  2009/03/19 09:16:36  lutscher
#  added view ip-xact-rgm
#
#  Revision 1.13  2009/02/04 15:52:13  lutscher
#  changed use to use_on_demand
#
#  Revision 1.12  2008/11/11 10:08:33  lutscher
#  changed skipping of input columns
#
#  Revision 1.11  2008/07/22 15:38:03  herburger
#  small changes
#
#  Revision 1.10  2008/07/16 08:32:05  herburger
#  small changes
#
#  Revision 1.9  2008/07/09 12:02:21  herburger
#  changed filename generation
#
#  Revision 1.8  2008/07/07 17:09:15  herburger
#   added naming scheme to register name and field name
#
#  Revision 1.7  2008/07/03 11:02:55  herburger
#  small changes
#
#  Revision 1.6  2008/06/23 12:55:48  herburger
#  *** empty log message ***
#
#  Revision 1.5  2008/06/05 12:05:19  herburger
#  changed module import
#
#  Revision 1.4  2008/06/05 08:32:33  herburger
#  changed module import
#
#  Revision 1.3  2008/05/28 13:53:25  herburger
#  *** empty log message ***
#
#  Revision 1.2  2008/05/09 14:49:10  herburger
#  initial release
#
#
#  
###############################################################################

package Micronas::Reg; # the class-name

#------------------------------------------------------------------------------
# Used packages
#------------------------------------------------------------------------------
#use strict;
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use lib "$Bin/lib";
use Data::Dumper;
use Micronas::MixUtils qw($eh %OPTVAL);
use Micronas::Reg;
use Micronas::RegDomain;
use Micronas::RegReg;
use Micronas::RegField;
use Micronas::RegViews;
use Micronas::MixUtils::RegUtils;



#------------------------------------------------------------------------------
# Methods
# First parameter passed to method is implicit and is the object reference 
# ($this) if the method # is called in <object> -> <method>() fashion.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# view: IP-XACT
# Main entry function of this module;
# input: view-name, list ref. to domain names for which output is generated; if empty, 
# will consider ALL register space domains in the Reg object;
# output: 0 in case of non-recoverable error, 1 otherwise
sub _gen_view_ipxact {
    my $this = shift;
    my ($view_name, $lref_domains) = @_;

    unless( mix_use_on_demand('use IO::File;use XML::Writer; '	
	    ) ) {
	_fatal( "Failed to load required modules for _gen_view_ipxact(): $@" );
	exit 1;
    };
    
    # extend class data with data structure needed for code generation
    $this->global('ldomains'		=>	[]);	
       
    
    # check over which domains we want to iterate
    if (scalar (@$lref_domains)) {
        #@$lref_domains not empty
        foreach my $o_domain (@$lref_domains) {
            push @{$this->global->{'ldomains'}}, $this->find_domain_by_name_first($o_domain);
        };
    } else {
        #no domains specified -> use all
        foreach my $href (@{$this->domains}) {
            push @{$this->global->{'ldomains'}}, $href->{'domain'};
        };
    };

    #$this->display();

    #write ip-xact to file
    $this->_write_ipxact2file($view_name);    
}



##################################
# _write_ipxact2file
# 
##################################
sub _write_ipxact2file{
    my $this=shift;
    my $view_name = shift;

    my($o_domain, $o_register, $field, $o_field, $parameter, $for_rgm);
    my $doc;
    $for_rgm = 0;
    if ($view_name =~ m/rgm$/i) {
        $for_rgm = 1; # generate XML for the OVM reg_mem package
    };

    unless(mix_use_on_demand('use XML::Writer;')) {
        _fatal( "Failed to load required modules for _gen_view_ipxact(): $@" );
        exit 1;
    };
    # eval {use XML::Writer};
    # die("could not find module XML::Writer in _write_ipxact2file") if $@ ne "";

    ##check if a domain specified
    #if (!scalar @{$this->global->{'ldomains'}}){
	#no domains specified
	#_error("No Domain specified");
	#return 0;
    #}

    ##start writing to file
    my $filename=$eh->get('xml.path').'/'.join("_",$eh->get('xml.file_prefix'),map{$_->{'name'}}(@{$this->global->{'ldomains'}})).".".$eh->get('xml.file_suffix');
    
    if (-e $filename){
        #file exists
        if (!($doc = new IO::File(">".$filename))){
            _error("could not open file \'$filename\' for writing");
            return 0;
        }else {
            _info("opened file \'$filename\' for writing")
        }
    }else{
        #make new file
        if (!($doc = new IO::File(">".$filename))){
            _error("could not create file \'$filename\' for writing");
            return 0;
        }else {
            _info("creating file \'$filename\'")
        }
    }
    
    my($nsspirit,$nsschema, $schemalocation)=($eh->get('xml.NS_URI.spirit'),$eh->get('xml.NS_URI.schema'),$eh->get('xml.NS_URI.schemalocation'));
    my ($nsrgm, $nsrgm_schema, $nsrgm_schemalocation) = ($eh->get('xml.NS_RGM.vendorExtensions'),$eh->get('xml.NS_RGM.schema'),$eh->get('xml.NS_RGM.schemalocation'));

    ####start XML-Writer, write to $doc, use namespace and data mode, prefix map gives prefixes for namespace URLs
    my $writer;

    if (!$for_rgm) {
        $writer = XML::Writer->new(OUTPUT => $doc,NEWLINES =>0, NAMESPACES => 1, DATA_MODE => 1, DATA_INDENT =>4, ,PREFIX_MAP => {$nsspirit=>"spirit", $nsschema=>"xsi"});
    } else {
        $writer = XML::Writer->new(OUTPUT => $doc,NEWLINES =>0, NAMESPACES => 1, DATA_MODE => 1, DATA_INDENT =>4, ,PREFIX_MAP => {$nsspirit=>"spirit", $nsschema=>"xsi", $nsrgm=>"vendorExtensions"});
    };
    _info("Start Writing XML-File");
  
    
    #XML-declaration
    $writer->xmlDecl($eh->get('xml.characterencodingout'));

    $writer->comment("IP-XACT 1.4 File. Automatically generated by MIX");

    #TopLevel
    if (!$for_rgm) {
        $writer->startTag([$nsspirit, "component"], [$nsschema,"schemaLocation"]=>"$schemalocation");
    } else {
        $writer->startTag([$nsspirit, "component"], [$nsschema,"schemaLocation"]=>"$schemalocation", [$nsrgm,"schemaLocation"] => "$nsrgm_schemalocation");
    };

    #versionIdentifier

    $writer->dataElement([$nsspirit, "vendor"],$eh->get('xml.VLNV.vendor'));

    $writer->dataElement([$nsspirit, "library"],$eh->get('xml.VLNV.library'));

    $writer->dataElement([$nsspirit, "name"],$eh->get('xml.VLNV.name'));

    $writer->dataElement([$nsspirit, "version"],$eh->get('xml.VLNV.version'));

      
    
    $writer->startTag([$nsspirit, "memoryMaps"]);
    
    my $domainname;
    my $domain_max_offset = 4;
    my $addr_offset;

    # each domain is one memory map with one addressblock
    foreach $o_domain (@{$this->global->{'ldomains'}}){
        _info("generating IP-XACT code for domain ",$o_domain->name);
        $writer->startTag([$nsspirit,"memoryMap"]);
        
        
        # name of the memory map is the name of the domain
        $domainname=$o_domain->{'name'};
        $writer->dataElement([$nsspirit, "name"],$o_domain->{'name'});
        
        $writer->startTag([$nsspirit, "addressBlock"]);
        
        #name of the addressblock is the name of the domain
        $writer->dataElement([$nsspirit, "name"],$o_domain->{'name'});
        
        # print the definition into displayName if definition exists
        $writer->dataElement([$nsspirit, "displayName"],$o_domain->{'definition'}) if ($o_domain->{'definition'});
        
        #baseaddress of the block
        my $baseaddr=$this->get_domain_baseaddr($o_domain->{'name'});
        $writer->dataElement([$nsspirit, "baseAddress"],$baseaddr);
        
        #range is the number of addressable units = 2^(Address Width)
        my $range=2**($eh->get("reg_shell.addrwidth"));
        $writer->dataElement([$nsspirit, "range"],$range);
        
        #bit width of a row
        $writer->dataElement([$nsspirit, "width"],$this->get_max_regwidth());
        
        $writer->dataElement([$nsspirit, "usage"],"register");
        
        #iterate through all registers
        foreach $o_register (@{$o_domain->{'regs'}}){
            
            $writer->startTag([$nsspirit, "register"]);
            
            my $registername=_clone_name($eh->get('reg_shell.reg_naming'),99,0,$domainname,$o_register->{'name'}); 

            $writer->dataElement([$nsspirit, "name"],$registername);
            
            # print the Definition into displayName if definition exists
            $writer->dataElement([$nsspirit, "displayName"],$o_register->{'definition'}) if ($o_register->{'definition'});
            
            $addr_offset = $o_domain->get_reg_address($o_register);
            $writer->dataElement([$nsspirit, "addressOffset"], $addr_offset);
            if ($addr_offset > $domain_max_offset) {
                $domain_max_offset = $addr_offset;
            };

            $writer->dataElement([$nsspirit, "size"], $o_register->{'attribs'}->{'size'});
            
            #direction of the register derived from field directions
            my $registerdirection=$o_register->get_reg_access_mode();
            if ($registerdirection and !$for_rgm){#Print only if exists
                $writer->dataElement([$nsspirit, "access"],$eh->get('xml.access.'.$registerdirection));
            }
            
            #reset value of register, derived from fields
            $writer->startTag([$nsspirit, "reset"]);
            $writer->dataElement([$nsspirit, "value"],$o_register->get_reg_init());
            $writer->dataElement([$nsspirit, "mask"],$o_register->{'attribs'}->{'usedbits'});
            $writer->endTag([$nsspirit, "reset"]);
            
            #iterate through all fields
            foreach $field (@{$o_register->{'fields'}}){
                $o_field=$field->{'field'};
                
                $writer->startTag([$nsspirit, "field"]);
                
                my $fieldname=$o_field->{'name'};
                $fieldname= _clone_name($eh->get('reg_shell.field_naming'),99,0,$domainname,$registername,$fieldname,$o_field->attribs->{'block'});
                
                $writer->dataElement([$nsspirit, "name"],$fieldname);
                
                # print the definition into displayName if definition exists
                $writer->dataElement([$nsspirit, "displayName"],$o_field->{'definition'}) if ($o_field->{'definition'});
                
                
                my $fielddescription = $o_field->{'attribs'}->{'comment'};
                ######Caveat: fielddescription contains iso-8859-1 characters, if utf-8 is wanted, it has to be converted
                $writer->dataElement([$nsspirit, "description"],$fielddescription) if $fielddescription;
                
                $writer->dataElement([$nsspirit, "bitOffset"], $field->{'pos'});
                $writer->dataElement([$nsspirit, "bitWidth"], $o_field->{'attribs'}->{'size'});
                
              
                my $access = $eh->get('xml.access.'.$o_field->{'attribs'}->{'dir'});
                my $access_policy = "";
                if ($o_field->{'attribs'}->{'spec'} =~ m/W1C/) {
                    $access_policy = "RW1C"; # BAUSTELLE add more types (UNKNOWN, USER, ...)
                };

                if (!$for_rgm) {
                    $writer->dataElement([$nsspirit, "access"], $access);
                    
                    #parameters section (all that have not been extracted above)
                    $writer->startTag([$nsspirit, "parameters"]);
                    
                    foreach $parameter (keys %{$o_field->{'attribs'}}){
                        #fields to skip
                        # ##LU changed this to match the skipelements without the trailing :\d of the multiple column identifiers
                        my $parameter_strip_mul = $parameter;
                        $parameter_strip_mul =~ s/\:\d+$//;
                        next if(grep ($parameter_strip_mul eq $_, @{$eh->get('xml.field_skipelements')}));
                        
                        # make substitution if defined by user
                        if (defined $eh->get('xml.prettynames.'.$parameter)){
                            $parametername=$eh->get('xml.prettynames.'.$parameter);
                        }else{
                            $parametername=$parameter;
                        }
                        
                        #create for each value in the field object an parameter field
                        $writer->startTag([$nsspirit, "parameter"]);
                        $writer->dataElement([$nsspirit, "name"],$parametername);
                        $writer->dataElement([$nsspirit, "value"],$o_field->{'attribs'}->{$parameter});
                        $writer->endTag([$nsspirit, "parameter"]);
                    }
                    
                    $writer->endTag([$nsspirit, "parameters"]);
                } else {
                    # add either access or access_policy element
                    if ($access_policy eq "") {
                        $writer->dataElement([$nsspirit, "access"], $access);
                    };
                    $writer->startTag([$nsspirit, "vendorExtensions"]);
                    if ($access_policy ne "") {
                        $writer->dataElement([$nsrgm, "access_policy"], $access_policy);
                    };
                    $writer->dataElement([$nsrgm, "collect_coverage"], $eh->get('xml.collect_coverage'));
                    $writer->dataElement([$nsrgm, "hdl_path"], $eh->get('xml.hdl_path'));
                    $writer->endTag([$nsspirit, "vendorExtensions"]);
                };
                $writer->endTag([$nsspirit, "field"]);
            }
            
            #parameters for register element
            if (!$for_rgm) {
                $writer->startTag([$nsspirit, "parameters"]);
                
                $writer->startTag([$nsspirit, "parameter"]);
                $writer->dataElement([$nsspirit, "name"],"clone");
                $writer->dataElement([$nsspirit, "value"],$o_register->{'attribs'}->{'clone'});
                $writer->endTag([$nsspirit, "parameter"]);
                
                $writer->endTag([$nsspirit, "parameters"]);
            } else {
                $writer->startTag([$nsspirit, "vendorExtensions"]);
                $writer->dataElement([$nsrgm, "type"], _clone_name($eh->get('xml.register_type_naming'),99,0,$domainname,$registername));
                $writer->dataElement([$nsrgm, "hdl_path"], $eh->get('xml.hdl_path'));
                $writer->endTag([$nsspirit, "vendorExtensions"]);
            };
            $writer->endTag([$nsspirit, "register"]);
        }
        
	
        if ($for_rgm) {
            # vendor extension for addressBlock element
            $writer->startTag([$nsspirit, "vendorExtensions"]);
            $writer->dataElement([$nsrgm, "type"], _clone_name($eh->get('xml.addressBlock_type_naming'),99,0,$domainname));
            $writer->endTag([$nsspirit, "vendorExtensions"]);
        };

        $writer->endTag([$nsspirit, "addressBlock"]);
        
        $writer->dataElement([$nsspirit, "addressUnitBits"],$eh->get('reg_shell.datawidth'));
        
        $writer->endTag([$nsspirit, "memoryMap"]);
    }
    
    #EOF
    $writer->endTag([$nsspirit, "memoryMaps"]);

    if ($for_rgm) {
        # vendor extension for root element
        $writer->startTag([$nsspirit, "vendorExtensions"]);
        $writer->dataElement([$nsrgm, "type"], _clone_name($eh->get('xml.component_type_naming'),99,0,$domainname));
        $writer->dataElement([$nsrgm, "size"], "0x"._val2hex(32, (${domain_max_offset} + $eh->get('reg_shell.datawidth')/8)));
        $writer->endTag([$nsspirit, "vendorExtensions"]);
    };
    
    $writer->endTag([$nsspirit, "component"]);
    $writer->end();#end document, for error detection
    $doc->close();#close file handle
    
}
1;
