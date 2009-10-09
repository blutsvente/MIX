###############################################################################
#  RCSId: $Id: RegViewRTF.pm,v 1.2 2009/10/09 15:41:39 lutscher Exp $
###############################################################################
#
#  Revision      : $Revision: 1.2 $                                  
#
#  Related Files :  Reg.pm, RegOOUtils.pm
#
#  Author(s)     :  Thorsten Lutscher                                      
#  Email         :  thorsten.lutscher@tridentmicro.com                          
#
#  Project       :  MIX                                                 
#
#  Creation Date :  25.06.2009
#
#  Contents      :  generate Register view 'Rich Text Format'; based on RTF::Writer
#   
#   sub _gen_view_rtf
#   sub _rtf_rs_init
#   sub _rtf_dump_overview
#   sub _rtf_dump_detailed
#   sub _parse_rm_comment
#
###############################################################################
#                               Copyright
###############################################################################
#
#       Copyright (C) 2009 Trident Microsystems (Europe) , Munich, Germany 
#
#     All rights reserved. Reproduction in whole or part is prohibited
#          without the written permission of the copyright owner.
#
###############################################################################
#                                History
###############################################################################
#
#  $Log: RegViewRTF.pm,v $
#  Revision 1.2  2009/10/09 15:41:39  lutscher
#  added colors
#
#  Revision 1.1  2009/09/08 11:41:22  lutscher
#  initial release
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
# use Micronas::MixChecker qw(mix_check_case);
use Micronas::Reg;
use Micronas::RegDomain;
use Micronas::RegReg;
use Micronas::RegField;
#use Micronas::RegOOUtils;
#use Micronas::MixUtils::RegUtils;
#use Micronas::RegViews; # we use some methods from this package that are not bus-protocol dependent
use RTF::Writer;

#------------------------------------------------------------------------------
# Private methods (of class Reg)
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# view: rtf

# Main entry function; generate data structures for the MIX Parser for Register 
# shell generation;
# input: view-name, list ref. to domain names for which register views are generated; if empty, 
# register views for ALL register space domains in the Reg object are generated
# output: 0 in case of non-recoverable error, 1 otherwise
sub _gen_view_rtf {
	my $this = shift;
    my ($view_name, $lref_domains) = @_;
	my @ldomains;
	my $href;
	my $o_domain;
    my $infostr = "generated file(s) ";

    # init some parameters
    $this->_rtf_rs_init();

	# make list of domains for generation
	if (scalar (@$lref_domains)) {
        # user supplied domains
		foreach my $domain (@$lref_domains) {
			$o_domain = $this->find_domain_by_name_first($domain);
			if (ref($o_domain)) {
				push @ldomains, $this->find_domain_by_name_first($domain);
			} else {
				_error("unknown domain \'$domain\'");
			};
		};
	} else {
		foreach $href (@{$this->domains}) { 
            # all domains
			push @ldomains, $href;
		};
	};

   	my ($o_field, $o_reg, $n_domain, $ho, $hd);

	# iterate through all register domains
    $n_domain = 0;
	foreach $o_domain (@ldomains) {
        my $domainname = _clone_name($eh->get('reg_shell.rtf.domain_naming'),99,$n_domain++,$o_domain->{'name'}); # apply domain-naming rule
        if ($eh->get('reg_shell.rtf.join_docs')) {
            # one document for everything
            my $filename = $domainname . "." . $this->global->{'file_extension'};
            $ho = RTF::Writer->new_to_file($filename);
            $hd = $ho;
            $ho->prolog(%{$this->global->{'prolog'}});
            $infostr .= "$filename";
        } else {
            my $filename = $domainname ."-overview". "." . $this->global->{'file_extension'};
            $ho = RTF::Writer->new_to_file($filename);
            $ho->prolog(%{$this->global->{'prolog'}});
            $infostr .= "$filename";
            $filename = $domainname ."-detailed". "." . $this->global->{'file_extension'};
            $hd = RTF::Writer->new_to_file($filename);
            $hd->prolog(%{$this->global->{'prolog'}});
            $infostr .= ", $filename";
        };

        # create register overview
        $this->_rtf_dump_overview($ho, $o_domain, $domainname);

        # create detailed register list
        $this->_rtf_dump_detailed($hd, $o_domain, $domainname);
	};
    _info($infostr);
	1;
};

# init global parameters and import mix.cfg parameters
sub _rtf_rs_init {
    my $this =  shift;

   	# extend class data with data structure needed for code generation
	$this->global(
                  'file_extension' => "rtf",
                  'prolog' => { 
                               "title" => "SW-acccessible Control Register",
                               "operator" => $ENV{USER},
                               "company" => "Trident Microsystems",
                               "fonts" => ["Times New Roman", "Courier New", "Arial"],
                               "colors" => [undef, [192,192,192]] # not used yet
                              },
                  'lexclude_cfg' => []
				 );

    # register Perl module with mix
    if (not defined($eh->mix_get_module_info("RegViewRTF"))) {
        $eh->mix_add_module_info("RegViewRTF", '$Revision: 1.2 $ ', "Module to dump registers from Reg class object in Rich-Text-Format");
    };

	# list of skipped registers and fields (put everything together in one list)
	if ($eh->get('reg_shell.exclude_regs')) {
		@{$this->global->{'lexclude_cfg'}} = split(/\s*,\s*/,$eh->get('reg_shell.exclude_regs'));
	};
	if ($eh->get('reg_shell.exclude_fields')) {
		push @{$this->global->{'lexclude_cfg'}}, split(/\s*,\s*/,$eh->get('reg_shell.exclude_fields'));
	};


};


# create register overview
sub _rtf_dump_overview {
    my ($this, $h, $o_domain, $dname) = @_;
    my $o_reg;
    my $table = RTF::Writer::TableRowDecl->new('widths' => [2000, 800, 1200, 1200]);

    # Table Title
    $h->paragraph(\$eh->get("reg_shell.rtf.title_format"), "Overview of Control Register in Domain $dname",);

    # Header
    my $head_format = $eh->get("reg_shell.rtf.head_row_format");
    my $row_format = $eh->get("reg_shell.rtf.row_format");
    my $hex_symbol = $eh->get("reg_shell.rtf.hex_symbol");
    $h->row($table, 
            [\$head_format, "Register"], 
            [\$head_format, "R/W"], 
            [\$head_format, "Offset"], 
            [\$head_format, "Reset Value"]
           );

    # Table Rows -> iterate over all regs
    foreach $o_reg (@{$o_domain->regs}) {  
        if (grep ($_ eq $o_reg->name, @{$this->global->{'lexclude_cfg'}})) {
			_info("skipping register per user parameter: ", $o_reg->name);
			next;
		};
        $h->row($table, 
                [\$row_format, _clone_name($eh->get('reg_shell.rtf.reg_naming'),99,0,$dname, $o_reg->{'name'})],  # apply register-naming rule 
                [\$row_format, uc($o_reg->get_reg_access_mode())],
                [\$row_format, $hex_symbol._val2hex($eh->get('reg_shell.addrwidth'), $o_domain->get_reg_address($o_reg))],
                [\$row_format, $hex_symbol._val2hex($eh->get('reg_shell.datawidth'), $o_reg->get_reg_init())]
               );
    };
};

# create a detailed register description of all bitslices
sub _rtf_dump_detailed {    
    my ($this, $h, $o_domain, $dname) = @_;
    my ($o_reg, $o_field);
   
    # Iterate over all regs
    foreach $o_reg (@{$o_domain->regs}) {  
        next if (grep ($_ eq $o_reg->name, @{$this->global->{'lexclude_cfg'}}));
        if ($o_reg->to_document()) {
            my $table = RTF::Writer::TableRowDecl->new('widths' => [800, 2000, 600, 1200, 4200]);
            my $regname = _clone_name($eh->get('reg_shell.rtf.reg_naming'),99,0,$dname, $o_reg->{'name'});
            my $head_format = $eh->get("reg_shell.rtf.head_row_format");
            my $row_format = $eh->get("reg_shell.rtf.row_format");
            my $hex_symbol = $eh->get("reg_shell.rtf.hex_symbol");
            
            # Table Title
            $h->paragraph(\$eh->get("reg_shell.rtf.title_format"), "Register $regname (offset ".$hex_symbol._val2hex($eh->get('reg_shell.addrwidth'), $o_domain->get_reg_address($o_reg)).")");
            
            # Header
            $h->row($table, 
                    [\$head_format, "Bitslice"],
                    [\$head_format, "Name"],
                    [\$head_format, "R/W"],
                    [\$head_format, "Reset Value"],
                    [\$head_format, "Description"]                    
                   );

            # iterate over the fields
            my @lfields = ();
            my $i = 0;
            foreach my $href (@{$o_reg->fields}) {
                $o_field = $href->{'field'};
                if (grep ($_ eq $o_field->name, @{$this->global->{'lexclude_cfg'}})) {
                    _info("skipping field per user parameter: ", $o_field->name);
                    next;
                };

                $lfields[$i]{view}    = $o_field->attribs->{'view'};
                next if lc($lfields[$i]{view}) ne 'y'; # ignore this bitfield if it shouldn't be documented
                
                $lfields[$i]{'name'}     = _clone_name($eh->get('reg_shell.rtf.field_naming'),99,0,$o_domain->name, $o_reg->name, $o_field->name, $o_field->attribs->{'block'});
                $lfields[$i]{'pos'}     = $href->{'pos'}; # LSB position in register
                $lfields[$i]{'lsb'}     = $o_field->attribs->{'lsb'};
                $lfields[$i]{'size'}    = $o_field->attribs->{'size'};
                $lfields[$i]{'init'}    = $hex_symbol._val2hex($eh->get('reg_shell.datawidth'), $o_field->attribs->{'init'});
                $lfields[$i]{'msb'}     = $lfields[$i]{lsb} +  $lfields[$i]{size} - 1;
                $lfields[$i]{'range'}   = $lfields[$i]{'size'} == 1 ? "" : $this->_gen_vector_range($lfields[$i]{msb}, $lfields[$i]{lsb});
                $lfields[$i]{'api'}     = $o_field->attribs->{'api'} if (exists($o_field->attribs->{'api'}));     
                $lfields[$i]{'spec'}    = $o_field->attribs->{'spec'};         
                $lfields[$i]{'access'}  = $lfields[$i]{'spec'} =~ m/w1c/i ? "W1C" : uc($o_field->attribs->{'dir'});
                $lfields[$i]{'comment'} = $o_field->attribs->{'comment'};  
                $lfields[$i]{'rrange'}  = $this->_gen_vector_range($lfields[$i]{'pos'}+$lfields[$i]{'size'}-1, $lfields[$i]{'pos'});
                $i++;
                
            };
            @lfields = reverse sort {${$a}{pos} <=> ${$b}{pos}} @lfields;
  
            foreach my $field (@lfields) {
                print join("\t",$field->{'range'}, $field->{'name'}, $field->{'access'}, $field->{'init'}), "\n" if $this->global->{'debug'};
                my @ldescr = $this->_parse_rm_comment($field->{'comment'});
                $h->row($table,
                        [\$row_format, "$field->{'rrange'}"],
                        [\$row_format, "$field->{'name'}$field->{'range'}"],
                        [\$row_format, $field->{'access'}],
                        [\$row_format, $field->{'init'}],
                        #[\'\b\tab', "descr", \'\line\plain\tab', "bla"]
                        \@ldescr
                       );
            };
        } else {
            _info("skipping register because disabled by ::view value: ", $o_reg );
        };
    };
};

# this parses a field description in register-master format; note: does not cover all register-master format specifier,
# supported are:
# \b bold
# \i italic
# \x reset formats
# \t tab
# \* bullet
# the return value is a list that can be passed (as reference) to the row() command of the RTF Writer;
# the field elements are either plain text or references to scalars (for RTF format specifiers).
sub _parse_rm_comment {
    my ($this, $comment) = @_;
    my @lres;
    my $format;
    my $txt;
    my $row_format = $eh->get("reg_shell.rtf.row_format");
  
    my @ltemp = split(/\n/, $comment);
    # iterate each line of the original field description
    foreach my $str (@ltemp) {
        $format = $row_format;
        
        while ($str =~ /^((\\[\w|\*])+)([^\\]*)/ || $str =~ /((\\[\w|\*])+)/) {
            # print "$1";
            $txt = $3 || "";
            $str = $';    
            $format .= $1;
           
            # substitute register-master format specifiers with RTF
            $format =~ s/\\x/\\plain$row_format/;
            $format =~ s/\\t/\\tab/;
            $format =~ s/\\\*/\\bullet /;
            # print "format: ",$format, "\n";
            # print "text  : ",$txt, "\n";
            
            # push resulting format/text pair onto list
            push @lres, \"$format", $txt;
            $format = "";
            $txt = "";
        };
        # if there was no format specified, add the default format
        push @lres, \$row_format if (!scalar(@lres));
        # add any remaining stuff after last regexp match
        push @lres, $str if ($str);
        # add a newline
        push @lres, \'\line';
    };
    pop @lres if scalar(@lres);  # delete last \line command
    return @lres;
};
1;
