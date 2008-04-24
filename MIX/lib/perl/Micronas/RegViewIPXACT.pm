###############################################################################
#  RCSId: $Id: RegViewIPXACT.pm,v 1.1 2008/04/24 10:05:22 herburger Exp $
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
#  Revision 1.1  2008/04/24 10:05:22  herburger
#  *** empty log message ***
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
use XML::Writer;
use IO::File;



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
    
      
    
    # extend class data with data structure needed for code generation
    $this->global(
	'outputfile_suffix'	=>	"xml",
	'outputfile_name'	=>	"testdoc_ipxact",
	'NS_URI'		=>	{
					'spirit'	=> "http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.4",
					'schema'	=> "http://www.w3.org/2001/XMLSchema-instance",
					'schemalocation'=> "http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.4 http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.4/index.xsd" 
					},
	'versionedIdentifier'	=>	{
					'vendor'	=> "micronas.com",
					'library'	=> $eh->get("i2c.xls"),
					'name'		=> $eh->get("i2c.xls"),
					'version'	=> "0.1"
					},
	'characterencoding'	=>	"iso-8859-1",
	'access'		=>	{
					'R'		=> "read-only",
					'W'		=> "write-only",
					'RW'		=> "read-write"
					},
	'field_skipelements'	=>	[
					"comment",
					"dir",
					"size",
					"skip:1",
					"skip:3",
					],
	'ldomains'		=>	[]#List of Domains to generate
	);
    
    
  
    
 
   
   
    
    # check over which domains we want to iterate
    if (scalar (@$lref_domains)) {
	#@$lref_domains not empty
	foreach my $o_domain (@$lref_domains) {
	    push @{$this->global->{'ldomains'}}, $this->find_domain_by_name_first($o_domain);
	};
    } else {
	#No Domains specified -> use all
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
#################################
sub _write_ipxact2file{
    my $this=shift;

    my($o_domain, $o_register, $field, $o_field, $parameter);
    my($nsspirit,$nsschema, $schemalocation)=($this->global->{NS_URI}->{'spirit'},$this->global->{'NS_URI'}->{'schema'},$this->global->{'NS_URI'}->{'schemalocation'});
    
   
    ##Start Writing to File

    my $doc = new IO::File(">".$this->global->{'outputfile_name'}.".".$this->global->{'outputfile_suffix'});
    my $writer = new XML::Writer(OUTPUT => $doc,NEWLINES =>0, NAMESPACES =>1, DATA_MODE => 1, DATA_INDENT =>4,PREFIX_MAP => {$nsspirit=>"spirit", $nsschema=>"xsi"},UNSAFE=>1);

    #XML-Declaration
    $writer->xmlDecl($this->global->{'characterencoding'});

    $writer->comment("IP-XACT 1.4 File. Created by MIX");

    #TopLevel
    $writer->startTag([$nsspirit, "component"],[$nsschema,"schemaLocation"]=>"$schemalocation");
    

    #versionIdentifier

    $writer->dataElement([$nsspirit, "vendor"],$this->global->{'versionedIdentifier'}->{'vendor'});

    $writer->dataElement([$nsspirit, "library"],$this->global->{'versionedIdentifier'}->{'library'});

    $writer->dataElement([$nsspirit, "name"],$this->global->{'versionedIdentifier'}->{'name'});

    $writer->dataElement([$nsspirit, "version"],$this->global->{'versionedIdentifier'}->{'version'});

      
    
    $writer->startTag([$nsspirit, "memoryMaps"]);
    

    # Each Domain is one Memory Map with one Addressblock
    foreach $o_domain (@{$this->global->{'ldomains'}}){
	
	$writer->startTag([$nsspirit,"memoryMap"]);
	
	# Name of the Memory Map is the name of the domain
	$writer->dataElement([$nsspirit, "name"],$o_domain->{'name'});
	
	$writer->startTag([$nsspirit, "addressBlock"]);

	#Name of the Addressblock is the name of the domain
	$writer->dataElement([$nsspirit, "name"],$o_domain->{'name'});
	
	my $baseaddr=$this->get_domain_baseaddr($o_domain->{'name'});
	#baseaddress of the block
	$writer->dataElement([$nsspirit, "baseAddress"],$baseaddr);

	#range is the number of addressable units = 2^(Address Width)
	my $range=2**($eh->get("reg_shell.addrwidth"));

	$writer->dataElement([$nsspirit, "range"],$range);

	#bit width of a row
	
	$writer->dataElement([$nsspirit, "width"],$eh->get("reg_shell.datawidth"));

	#iterarte through all register
	foreach $o_register (@{$o_domain->{'regs'}}){
	    
	    $writer->startTag([$nsspirit, "register"]);

	    $writer->dataElement([$nsspirit, "name"],$o_register->{'name'});

	    $writer->dataElement([$nsspirit, "addressOffset"], $o_domain->get_reg_address($o_register));
	    
	    $writer->dataElement([$nsspirit, "size"], $o_register->{'attribs'}->{'size'});
	    
	    #iterate throug all fields
	    foreach $field (@{$o_register->{'fields'}}){
		$o_field=$field->{'field'};
		
		$writer->startTag([$nsspirit, "field"]);

		$writer->dataElement([$nsspirit, "name"],$o_field->{'name'});

		my $fielddescription = $o_field->{'attribs'}->{'comment'};
		
		######Caveat: fielddescription contains iso-8859-1 characters, if utf-8 is wanted, it has to be converted
		$writer->dataElement([$nsspirit, "description"],$fielddescription);

		$writer->dataElement([$nsspirit, "bitOffset"], $o_field->{'attribs'}->{'skip:3'});
		$writer->dataElement([$nsspirit, "bitWidth"], $o_field->{'attribs'}->{'skip:1'});

		my $access=$this->global->{'access'}->{$o_field->{'attribs'}->{'dir'}};
		$writer->dataElement([$nsspirit, "access"], $access);

		#Parameters Section
		$writer->startTag([$nsspirit, "parameters"]);

		foreach $parameter (keys %{$o_field->{'attribs'}}){
		    #fields to Skip
		    next if(grep($parameter eq $_,@{$this->global->{'field_skipelements'}}));
		    $writer->startTag([$nsspirit, "parameter"]);
		    $writer->dataElement([$nsspirit, "name"],$parameter);
		    $writer->dataElement([$nsspirit, "value"],$o_field->{'attribs'}->{$parameter});
		    $writer->endTag([$nsspirit, "parameter"]);

		}

		$writer->endTag([$nsspirit, "parameters"]);

		$writer->endTag([$nsspirit, "field"]);
	    }
			    
	    $writer->endTag([$nsspirit, "register"]);
	}

	$writer->endTag([$nsspirit, "addressBlock"]);
	
	$writer->endTag([$nsspirit, "memoryMap"]);
    }
    
    #EOF
    $writer->endTag([$nsspirit, "memoryMaps"]);

    $writer->endTag([$nsspirit, "component"]);
    $writer->end();#End Document, for error detection
    $doc->close();#Close File Handle
   
}
1;
