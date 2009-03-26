###############################################################################
#  RCSId: $Id: RegViewBdCfg.pm,v 1.3 2009/03/26 14:58:47 lutscher Exp $
###############################################################################
#
#  Revision      : $Revision: 1.3 $                                  
#
#  Related Files :  Reg.pm
#
#  Author(s)     :  Thorsten Lutscher                                      
#  Email         :  thorsten.lutscher@micronas.com                          
#
#  Project       :  MIX                                                 
#
#  Creation Date :  25.03.2009
#
#  Contents      :  Module for creating command files for chip backdoor 
#                   configuration (FRC project)
#        
###############################################################################
#                               Copyright
###############################################################################
#
#       Copyright (C) 2009 Micronas GmbH, Munich, Germany 
#
#     All rights reserved. Reproduction in whole or part is prohibited
#          without the written permission of the copyright owner.
#
###############################################################################
#                                History
###############################################################################
#
#  $Log: RegViewBdCfg.pm,v $
#  Revision 1.3  2009/03/26 14:58:47  lutscher
#  some more features
#
#  Revision 1.2  2009/03/26 13:18:01  lutscher
#  small change
#
#  Revision 1.1  2009/03/26 12:44:53  lutscher
#  initial release
#
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
use Micronas::Reg;
use Micronas::RegDomain;
use Micronas::RegReg;
use Micronas::RegField;
use Micronas::MixUtils::RegUtils;

#------------------------------------------------------------------------------
# Private methods (of class Reg)
#------------------------------------------------------------------------------

# Main entry function of this module;
sub _gen_view_bdcfg {
	my $this = shift;
    my ($view_name, $lref_domains) = @_;

    if (!exists $OPTVAL{'hpaths'} or !exists $OPTVAL{'bsi'}) {
        _fatal("view \'$view_name\' requires options -hpaths <file> and -bsi <file>");
        return 0;
    };

    # register Perl module with mix
    if (not defined($eh->mix_get_module_info($0))) {
        $eh->mix_add_module_info("RegViewBdCdfg", '$Revision: 1.3 $ ', "Package to create backdoor configuration files for simulation");
    };
    
	# extend class data with data structure needed for code generation
    my $href_info = $eh->mix_get_module_info("RegViewBdCdfg");
 
    $this->global(
				  'debug'              => 0,
				  'file_nc'            => $eh->get("reg_shell.bd-cfg.ncsim_file_name"),
				  'file_axis'          => $eh->get("reg_shell.bd-cfg.axis_file_name"),
				  'header'             => "
Backdoor configuration register force file;
automatically generated by MIX ($0) for user $ENV{USER}  
view \'$view_name\' module \'RegViewBdCdfg\' version ".$href_info->{'version'}." 
"
              );

    # make list of domain names for generation if not passed as parameter
    if (!scalar(@$lref_domains)) {
        if (exists $OPTVAL{'domain'}) {
            push @$lref_domains, $OPTVAL{'domain'};
        } else {
            # add all domains except when specified as excluded
            my @lexclude_domains = split(/\s*,\s*/, $eh->get("reg_shell.exclude_domains"));
            my @lskipped = ();
            foreach my $href (@{$this->domains}) {
                if (!grep ($href->{'domain'}->{'name'} =~ m/$_/,  @lexclude_domains)) {
                    push @$lref_domains, $href->{'domain'}->{'name'};
                } else {
                    push @lskipped, $href->{'domain'}->{'name'};
                };
            };
            if (scalar @lskipped>0) {
                _info("skipping domains ",join(", ", @lskipped));
            };
        };
	};
    
    my %hpaths = ();
    my @lbsi = ();
    my @ltemp;

    # read file with hierarchical paths
    my $fh = new FileHandle $OPTVAL{'hpaths'}, "r";
    if (defined $fh) {
        while (<$fh>) 
          {
              @ltemp = split(/\s+/, $_);
              # extract bank number and hierarchical path for each line
              if ((scalar @ltemp == 2) and $ltemp[1] !~ m/##ignore##/) {
                  (my $bank = $ltemp[0]) =~ s/.+_bank_(\d+)$/$1/;
                  # key = bank-number in dec, value = hierarchical path to register-shell
                  $hpaths{$bank} = $ltemp[1];
              };
          };
        $fh->close();
    } else {
        _fatal("file ",$OPTVAL{'hpaths'}," could not be opened for reading");
        return 0;
    } 
    
    # read .bsi file
    $fh = new FileHandle $OPTVAL{'bsi'}, "r";
    if (defined $fh) {
        while (<$fh>) 
          {
              next if $_ =~ m/^\s*\/\//;
              chomp($_);
              @ltemp = split(/\s+\=\s+/, $_);
              if (scalar @ltemp == 2) {
                  $ltemp[1] =~ s/\;//;
                  if ($ltemp[1] =~ m/^0x[a-f0-9]+/i) { # convert from hex if necessary
                      $ltemp[1] = hex($ltemp[1]);
                  };
                  push @lbsi, join ("=",@ltemp);
              };  
          };
        $fh->close();
    } else {
        _fatal("file ",$OPTVAL{'bsi'}," could not be opened for reading");
        return 0;
    } 
    
    # make it so
    $this->_write_backdoor_config($lref_domains, \%hpaths, \@lbsi);
    
	return 1;
};

sub _write_backdoor_config {
    my ($this, $lref_domain_names, $href_hpaths, $lref_bsi) = @_;
   
    my ($domainname, $o_domain, $o_field, $o_reg, $reg_offset, $reg_value);
    my @ldomains;

    _info("generating files \'".$this->global->{"file_nc"}."\' and \'".$this->global->{"file_axis"}."\'...");
    my $dest_nc = new FileHandle $eh->get("output.path") . "/" . $this->global->{"file_nc"} , "w";
    my $dest_axis = new FileHandle $eh->get("output.path") . "/" . $this->global->{"file_axis"} , "w";
    
    print $dest_nc join("\n# ", split(/\n/, $this->global->{"header"})) . "\n";
    print $dest_axis join("\n\/\/ ", split(/\n/, $this->global->{"header"})) . "\n";

    # make list of domain objects
    foreach my $href (@{$this->domains}) {
        if (grep ($href->{domain}->name eq $_, @$lref_domain_names)) { 
            push @ldomains, $href->{'domain'};
		};
    };

    my $o_reg_last = undef;
    my $o_domain_last;
    foreach my $cmd_bsi (@{$lref_bsi}) {
        my ($path, $field_value) = split(/=/, $cmd_bsi);
        my ($device, $blockname, $fieldname) = split(/\./, $path);
        if (!defined $blockname or !defined $fieldname) {
            _error("\'$path\' in .bsi file is not a valid path name");
            next;
        };
        
        # find field
        $o_field = undef;
        foreach $o_domain (@ldomains) {
            
            $o_field = ($o_domain->find_field_by_name($fieldname))[0];
            if (defined $o_field) {
                print "> " . $o_domain->name, " $fieldname ". $o_field->name . "\n" if $this->global->{"debug"};
                # set field init value to value from bsi file, this way we can use Reg::get_reg_init() for the register-value
                $o_field->attribs("init" => $field_value);

                $o_reg = $o_domain->find_reg_by_field($o_field);
                # check if field belongs to a new register, if so, dump last register
                if (defined $o_reg_last) {
                    if ($o_reg != $o_reg_last) {
                        $reg_offset = $o_domain_last->get_reg_address($o_reg_last);
                        $reg_value = $o_reg_last->get_reg_init();
                        print $dest_nc $this->_get_nc_force_frc($o_domain_last, $o_reg_last, $reg_offset, $href_hpaths, $reg_value);
                        print $dest_axis $this->_get_axis_force_frc($o_domain_last, $o_reg_last, $reg_offset, $href_hpaths, $reg_value);
                        
                        $o_reg_last = $o_reg;
                    };
                } else {
                    $o_reg_last = $o_reg;
                };
                $o_domain_last = $o_domain;
                last; # exit loop and parse next bsi command
            };
        };
        $o_field or _warning("field \'$fieldname\' in .bsi file not found in database (register-master), may be in user-specified skipped domain");
    };
    
    # handle last register
    $reg_offset = $o_domain_last->get_reg_address($o_reg);
    $reg_value = $o_reg->get_reg_init();
    print $dest_nc $this->_get_nc_force_frc($o_domain_last, $o_reg, $reg_offset, $href_hpaths, $reg_value);
    print $dest_axis $this->_get_axis_force_frc($o_domain_last, $o_reg, $reg_offset, $href_hpaths, $reg_value);
    $dest_nc->close();
    $dest_axis->close();
};

# create a force command for FRC register-shell for ncsim
sub _get_nc_force_frc {
    my ($this, $o_domain, $o_reg, $offset, $href_hpaths, $value) = @_;

    my $bank_no = $o_domain->name;
    if ($bank_no =~ m/(\d+)$/) {
        # get the bank-number, in FRC RM it is postfixed to the domain-name (in decimal)
        $bank_no = $1;
        if (exists $href_hpaths->{$bank_no}) {
            my $hpath = $href_hpaths->{$bank_no};
            my $str = join(" ",
                           $eh->get("reg_shell.bd-cfg.ncsim_cmd"),
                           $hpath . ".write_reg_" . sprintf("%x", $offset) . ".reg_data_out_int",
                           "{'h"._val2hex($eh->get("reg_shell.datawidth"), $value)."};"
                          ) . "\n";
            $str .= join(" ",
                         $eh->get("reg_shell.bd-cfg.ncsim_cmd"),
                         $hpath . ".write_reg_" . sprintf("%x", $offset) . ".shadow_data_out_int",
                         "{'h"._val2hex($eh->get("reg_shell.datawidth"), $value)."};"
                        ) . "\n";
            return $str;
        };
    } else {
        _error("can't extract bank number from domain name \'",$o_domain->name,"\'"); 
    };
    return "";
};

# create a force command for FRC register-shell for axis
sub _get_axis_force_frc {
    my ($this, $o_domain, $o_reg, $offset, $href_hpaths, $value) = @_;
    
    my $bank_no = $o_domain->name;
    if ($bank_no =~ m/(\d+)$/) {
        # get the bank-number, in FRC RM it is postfixed to the domain-name (in decimal)
        $bank_no = $1;
        if (exists $href_hpaths->{$bank_no}) {
            my $hpath = $href_hpaths->{$bank_no};
            my $str = join(" ",
                           $hpath . ".write_reg_" . sprintf("%x", $offset) . ".reg_data_out_int",
                           "=",
                           $eh->get("reg_shell.datawidth")."'h"._val2hex($eh->get("reg_shell.datawidth"), $value)
                          ) . "\n";
            $str .= join(" ",
                         $hpath . ".write_reg_" . sprintf("%x", $offset) . ".shadow_data_out_int",
                         "=",
                         $eh->get("reg_shell.datawidth")."'h"._val2hex($eh->get("reg_shell.datawidth"), $value)
                        ) . "\n";
            return $str;
        };
    } else {
        _error("can't extract bank number from domain name \'",$o_domain->name,"\'"); 
    };
    return "";
};
1;
