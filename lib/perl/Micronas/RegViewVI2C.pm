###############################################################################
#  RCSId: $Id: RegViewVI2C.pm,v 1.4 2009/12/14 10:58:18 lutscher Exp $
###############################################################################
#                                  
#  Related Files :  Mix.pm, Reg.pm
#
#  Author(s)     :  Thorsten Lutscher                                      
#  Email         :  thorsten.lutscher@tridentmicro.com                          
#
#  Project       :  mix                                                 
#
#  Creation Date :  15.02.2002
#
#  Contents      :  Register View generation for VisualI2C in XML format
#
###############################################################################
#                               Copyright
###############################################################################
#
#       Copyright (C) 2009 Trident Microsystems (Europe) GmbH, Munich, Germany 
#
###############################################################################
#                                History
###############################################################################
#
#  $Log: RegViewVI2C.pm,v $
#  Revision 1.4  2009/12/14 10:58:18  lutscher
#  changed copyright
#
#  Revision 1.3  2009/12/02 14:25:31  lutscher
#  moved a function to Reg.pm
#
#  Revision 1.2  2009/11/20 12:29:00  lutscher
#  some fixes, added mix_use_on_demand
#
#  Revision 1.1  2009/11/19 12:25:49  lutscher
#  initial release
#
#
#  
###############################################################################

package Micronas::Reg; # the class-name;

#------------------------------------------------------------------------------
# Used packages
#------------------------------------------------------------------------------
use strict;
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use lib "$Bin/lib";
use File::Basename;
use Micronas::MixUtils qw($eh %OPTVAL);
use Micronas::Reg;
use Micronas::RegDomain;
use Micronas::RegReg;
use Micronas::RegField;
use Micronas::RegViews;
use Micronas::MixUtils::RegUtils;
use IO::File;

#------------------------------------------------------------------------------
# Global variables
#------------------------------------------------------------------------------
our($debug, $this);

#------------------------------------------------------------------------------
# Methods
# First parameter passed to method is implicit and is the object reference 
# ($this) if the method # is called in <object> -> <method>() fashion.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# view: vi2c-xml
# Main entry function of this module;
# input: view-name, list ref. to domain names for which output is generated; if empty, 
# will consider ALL register space domains in the Reg object;
# output: 0 in case of non-recoverable error, 1 otherwise
sub _gen_view_vi2c {
    my $this = shift;
    my ($view_name, $lref_domains) = @_;
    
    unless( mix_use_on_demand('use XML::Writer; ') ) {
        _fatal( "Failed to load required modules for _gen_view_vi2c(): $@" );
        exit 1;
    };
    
    # check over which domains we want to iterate
    my @ldomains;
    if (scalar (@$lref_domains)) {
        # @$lref_domains not empty
        foreach my $o_domain (@$lref_domains) {
            push @ldomains, $this->find_domain_by_name_first($o_domain);
        };
    } else {
        # no domains specified -> use all
        foreach my $href (@{$this->domains}) {
            push @ldomains, $href;
        };
    };

    # store list of domains in class data
    $this->global('doc_domains' => \@ldomains);
    
    # set some non-default xml options
    # $eh->set('xml.type', "vi2c");
    # $eh->set('xml.file_prefix'=> lc($this->device));
    # $eh->set('xml.file_suffix'=> "vi2c");
    # $eh->set('xml.path'=> "vi2c");

    # check if a script to embed exists
    my $script;
    if ($eh->get('xml.vi2c.script') ne "" && ($script = new IO::File("<".$eh->get('xml.vi2c.script')))) {
        my @lscript;
        foreach my $line (<$script>) {
            push @lscript, $line;
        };
        $this->global('doc_script' => \@lscript);
        $script->close();
    } else {
        _warning ("vi2c_script \'".$eh->get('xml.vi2c.script')."\' not found");
    };
    
    # get the address-map to be used
    $this->global('doc_addrmap' => $this->try_addrmap_name($eh->get('xml.vi2c.addrmap')));
    
    my $filename = $eh->get('xml.path') . "/" . $eh->get('xml.file_prefix') . "-". lc($this->device)."-vi2c.". $eh->get('xml.file_suffix');
    my $doc = new IO::File(">".$filename);
    if (!$doc) {
        _error("could not open file \'$filename\' for writing");
        return 0;
    };
    
    $this->global('doc_handle' => $doc);
    
    # make it so
    return $this->_write_vi2c_xml_file($filename);
    $doc->close();
    $eh->inc("sum.hdlfiles");
};

# main function for generating the vi2c XML document
sub _write_vi2c_xml_file {
    my $this = shift;
    my ($filename) = @_;

    my $writer = XML::Writer->new(OUTPUT => $this->global->{'doc_handle'},NEWLINES =>0, NAMESPACES => 0, DATA_MODE => 1, DATA_INDENT =>4, ,PREFIX_MAP => {});    
    _info("Start writing XML-File for device \'",$this->device,"\' using address-map \'",$this->global->{'doc_addrmap'},"\'");

    # XML-declaration
    $writer->xmlDecl($eh->get('xml.characterencodingout'));

    $writer->comment("VI2C File. Automatically generated by MIX");
    
    # TopLevel
    $writer->startTag("VisualI2C", 
                      viewAsList => "true", 
                      editMode => "true",
                      horizontalScroll => "0",
                      verticalScroll => "0",
                      freeBackColor => "0xece9d8",
                      topline => "36");

    # write script from file
    if (exists $this->global->{'doc_script'}) {
        $writer->startTag("script", 
                          triggerOnOpen => "true",
                          triggerOnSave => "false",
                          triggerOnClose => "true",
                          triggerOnAutoReadChange => "false");
        foreach my $line (@{$this->global->{'doc_script'}}) {
            $writer->dataElement("line", $line);
        };
        $writer->endTag("script");
    };
    $writer->dataElement("name",basename $filename);

    # iterate through domains
    foreach my $o_domain (@{$this->domains}) {
        my $domainname=_clone_name($eh->get('xml.vi2c.domain_naming'),99,$o_domain->{'id'},$o_domain->{'name'}); # apply domain-naming rule
        # open the domain-element
        $writer->startTag("watchItem",
                          active=>"false", showActiveBox=>"true", showFreeChilds=>"false", showListChilds=>"false",
                          showName=>"true", readMode=>"notReadable", writeable=>"true", sideField=>"0", fromField=>"0x0",
                          toField=>"0x0", numberFormat=>"All Formats", nLines=>"1", watchType=>"Comment", dalVersion=>$eh->get('xml.vi2c.dalVersion'),
                          displayType=>"dump", I2CInterface=>$eh->get('xml.vi2c.I2CInterface'));
		
		$writer->dataElement("name", $domainname);
        
        # iterate through fiels of the domain
        foreach my $o_field (@{$o_domain->fields}) {
            my $o_reg = $o_field->reg;
            my $registername = $o_reg->name;
            my $fieldname = $o_field->name;
            $fieldname = _clone_name($eh->get('xml.vi2c.field_naming'),99,0,$domainname,$registername,$fieldname,$o_field->attribs->{'block'}); # apply field-naming rule

            # calculate the absolute register address
            my $reg_addr = $o_domain->get_reg_address($o_reg);
            if (!defined $reg_addr) {
                _error("could not determine address of register \'".$registername."\'");
                $reg_addr = 0;
            };
            $reg_addr += $this->get_domain_baseaddr($o_domain->name,  $this->global->{'doc_addrmap'});
            
            # get the field value range
            my @lrange = $o_field->get_value_range();

            # calc the graphical element type used for the field
            my $display_type;
            if ($o_field->attribs->{'dir'} !~ m/w/i) {
                $display_type = "dump";
            } else {
                $display_type = ($o_field->attribs->{'size'} == 1) ? "bit" : "scrollbar";
            };

            # open the field-element
            $writer->startTag("watchItem",
                              active => "false", showActiveBox => "true", showFreeChilds => "true", showListChilds => "true",
                              scriptName =>  "$fieldname", 
                              showName => "true",
                              readMode =>  $o_field->attribs->{'dir'} =~ m/r/i ? "onRequest" : "notReadable", 
                              writeable => $o_field->attribs->{'dir'} =~ m/w/i ? "true" : "false",
                              sideField =>  $o_field->attribs->{'nformat'} =~ m/s/i ? "1": "0",    # signed or not
                              fromField =>  "0x"._val2hex(32, $reg_addr),                          # absolute address
                              toField =>  "0x"._val2hex($o_reg->attribs->{'size'}, $o_reg->get_field_mask($o_field)),   # used bits mask
                              extra1Field => $eh->get('xml.vi2c.extra1Field'), 
                              extra2Field => $eh->get('xml.vi2c.extra2Field'),
                              length => "120", 
                              min => $lrange[0], max => $lrange[1], 
                              bit => "0", numberFormat => "Decimal", nLines => "1", watchType => $eh->get('xml.vi2c.watchType'),
                              dalVersion => $eh->get('xml.vi2c.dalVersion'), 
                              displayType => $display_type, 
                              I2CInterface => $eh->get('xml.vi2c.I2CInterface'));
            

            # define enums for 0/1, init values and name
            if ($o_field->attribs->{'size'} == 1) { $this->_element_bit_label($writer) };
            $this->_element_initValue($writer, $o_field);
            $writer->dataElement("name", $fieldname);

            # close the field-element
            $writer->endTag("watchItem");
        };

        # close the domain-element
        $writer->endTag("watchItem");
    };

    # footer
    $writer->emptyTag("winRect", 
                      top => "44", left => "112", bottom => "982", right => "758");
    
    # that's it
    $writer->endTag("VisualI2C");
    return 1;
};

sub _element_bit_label {
    my ($this, $writer) = @_;
    $writer->startTag("labels");

    $writer->dataElement("label", "0", value=>"0");
    $writer->dataElement("label", "1", value=>"1");
	$writer->endTag("labels");
};

sub _element_initValue {
    my ($this, $writer, $o_field) = @_;
    $writer->dataElement("initValue", $o_field->attribs->{'init'}, set=>"Default", priority=>"5");
    $writer->dataElement("initValue", $o_field->attribs->{'rec'}, set=>"Recommended", priority=>"5");
    $writer->dataElement("initValue", $o_field->attribs->{'init'},  set=>"User", priority=>"5");
};

1;
