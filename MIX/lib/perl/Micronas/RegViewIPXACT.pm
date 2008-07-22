###############################################################################
#  RCSId: $Id: RegViewIPXACT.pm,v 1.11 2008/07/22 15:38:03 herburger Exp $
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
    $this->_write_ipxact2file();
    
}



##################################
# _write_ipxact2file
# 
##################################
sub _write_ipxact2file{
    my $this=shift;

    my($o_domain, $o_register, $field, $o_field, $parameter);
    my($nsspirit,$nsschema, $schemalocation)=($eh->get('xml.NS_URI.spirit'),$eh->get('xml.NS_URI.schema'),$eh->get('xml.NS_URI.schemalocation'));
    my $doc;


    


    eval {use XML::Writer};
    die("could not find module XML::Writer in _write_ipxact2file") if $@ ne "";

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
	    _info("opening file \'$filename\'")
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

    
    ####start XML-Writer, write to $doc, use namespace and data mode, prefix map gives prefixes for namespace URLs
    my $writer = new XML::Writer(OUTPUT => $doc,NEWLINES =>0, NAMESPACES =>1, DATA_MODE => 1, DATA_INDENT =>4, ,PREFIX_MAP => {$nsspirit=>"spirit", $nsschema=>"xsi"});
    _info("Start Writing XML-File");
  
    
    

    #XML-declaration
    $writer->xmlDecl($eh->get('xml.characterencodingout'));

    $writer->comment("IP-XACT 1.4 File. Automatically generated by MIX");

    #TopLevel
    $writer->startTag([$nsspirit, "component"],[$nsschema,"schemaLocation"]=>"$schemalocation");
    

    #versionIdentifier

    $writer->dataElement([$nsspirit, "vendor"],$eh->get('xml.VLNV.vendor'));

    $writer->dataElement([$nsspirit, "library"],$eh->get('xml.VLNV.library'));

    $writer->dataElement([$nsspirit, "name"],$eh->get('xml.VLNV.name'));

    $writer->dataElement([$nsspirit, "version"],$eh->get('xml.VLNV.version'));

      
    
    $writer->startTag([$nsspirit, "memoryMaps"]);
    

    # each domain is one memory map with one addressblock
    foreach $o_domain (@{$this->global->{'ldomains'}}){
	_info("generating IP-XACT code for domain ",$o_domain->name);
	$writer->startTag([$nsspirit,"memoryMap"]);
	

	# name of the memory map is the name of the domain
	my $domainname=$o_domain->{'name'};
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

	#iterarte through all register
	foreach $o_register (@{$o_domain->{'regs'}}){
	    
	    $writer->startTag([$nsspirit, "register"]);

	    my $registername=_clone_name($eh->get('reg_shell.reg_naming'),99,0,$domainname,$o_register->{'name'}); 
	    
	    $writer->dataElement([$nsspirit, "name"],$registername);

	    # print the Definition into displayName if definition exists
	    $writer->dataElement([$nsspirit, "displayName"],$o_register->{'definition'}) if ($o_register->{'definition'});

	    $writer->dataElement([$nsspirit, "addressOffset"], $o_domain->get_reg_address($o_register));
	    
	    $writer->dataElement([$nsspirit, "size"], $o_register->{'attribs'}->{'size'});

	    #direction of the register derived from field directions
	    my $registerdirection=$o_register->get_reg_access_mode();
	    if ($registerdirection){#Print only if exists
		$writer->dataElement([$nsspirit, "access"],$eh->get('xml.access.'.$registerdirection));
	    }
	    	    
	    #reset value of register, derived from fields
	    $writer->startTag([$nsspirit, "reset"]);
	    $writer->dataElement([$nsspirit, "value"],$o_register->get_reg_init());
	    $writer->dataElement([$nsspirit, "mask"],$o_register->{'attribs'}->{'usedbits'});
	    $writer->endTag([$nsspirit, "reset"]);

	    #iterate throug all fields
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

		my $access=$eh->get('xml.access.'.$o_field->{'attribs'}->{'dir'});
		$writer->dataElement([$nsspirit, "access"], $access);

		#parameters section
		$writer->startTag([$nsspirit, "parameters"]);

		foreach $parameter (keys %{$o_field->{'attribs'}}){
		    #fields to skip
		    next if(grep($parameter eq $_,@{$eh->get('xml.field_skipelements')}));

		    
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

		$writer->endTag([$nsspirit, "field"]);
	    }
	    
	    #parameters for register element
	    $writer->startTag([$nsspirit, "parameters"]);
	    
	    $writer->startTag([$nsspirit, "parameter"]);
	    $writer->dataElement([$nsspirit, "name"],"clone");
	    $writer->dataElement([$nsspirit, "value"],$o_register->{'attribs'}->{'clone'});
	    $writer->endTag([$nsspirit, "parameter"]);
	    
	    $writer->endTag([$nsspirit, "parameters"]);
			    
	    $writer->endTag([$nsspirit, "register"]);
	}

	
	$writer->endTag([$nsspirit, "addressBlock"]);

	$writer->dataElement([$nsspirit, "addressUnitBits"],$eh->get('reg_shell.datawidth'));

	$writer->endTag([$nsspirit, "memoryMap"]);
    }
    
    #EOF
    $writer->endTag([$nsspirit, "memoryMaps"]);

    $writer->endTag([$nsspirit, "component"]);
    $writer->end();#end document, for error detection
    $doc->close();#close file handle
    
}
1;
