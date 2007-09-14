# -*- perl -*---------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright Micronas GmbH, Inc. 2002.                                 |
# |     All Rights Reserved.                                              |
# |                                                                       |
# |                                                                       |
# | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF MICRONAS GMBH          |
# | The copyright notice above does not evidence any actual or intended   |
# | publication of such source code.                                      |
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# | Project:    Micronas - MIX                                            |
# | Modules:    $RCSfile: IO.pm,v $                                       |
# | Revision:   $Revision: 1.55 $                                          |
# | Author:     $Author: lutscher $                                         |
# | Date:       $Date: 2007/09/14 13:31:44 $                              |
# |                                         
# | Copyright Micronas GmbH, 2002                                         |
# |                                                                       |
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# | Changes:                                                              |
# | $Log: IO.pm,v $
# | Revision 1.55  2007/09/14 13:31:44  lutscher
# | added e-path to mix_utils_io_create_path()
# |
# | Revision 1.54  2007/07/17 11:40:47  lutscher
# | changed open_xls() to also take comma-separated list as sheetname argument
# |
# | Revision 1.53  2007/06/19 14:47:31  wig
# | Improved CVS writter, added #REF! error message.
# |
# | Revision 1.52  2007/03/05 12:58:38  wig
# | added ::descr and ::gen for -delta mode join cell
# |
# | Revision 1.51  2007/01/23 09:33:34  wig
# | Support delta mode for MIF files
# |
# | Revision 1.50  2006/11/21 16:51:09  wig
# | Improved generator execution (now in order!)
# |
# | Revision 1.48  2006/07/20 09:41:55  wig
# | Debugged -variant/-sel in combination with non mix-headers
# |
# | Revision 1.47  2006/07/12 15:23:40  wig
# | Added [no]sel[ect]head switch to xls2csv to support selection based on headers and variants.
# |
# | Revision 1.46  2006/07/05 09:58:28  wig
# | Added -variants to conn and io sheet parsing, rewrote open_infile interface (ordered)
# |
# | Revision 1.45  2006/07/04 13:13:49  wig
# |  	IO.pm : fixed convert_in call for i2c sheets
# |
# | Revision 1.44  2006/07/04 12:22:35  wig
# | Fixed TOP handling, -cfg FILE issue, ...
# |
# | Revision 1.43  2006/05/09 14:39:17  wig
# |  	MixParser.pm MixUtils.pm MixWriter.pm : improved constant assignments
# | 	Globals.pm IO.pm : improved limits, return value of write_delta_sheet
# |
# | Revision 1.42  2006/05/03 12:03:15  wig
# | Improved top handling, fixed generated format
# |
# | Revision 1.41  2006/04/24 12:41:52  wig
# | Imporved log message filter
# |
# | Revision 1.40  2006/04/12 15:36:36  wig
# | Updates for xls2csv added, new ooolib
# |
# | Revision 1.39  2006/04/10 15:50:08  wig
# | Fixed various issues with logging and global, added mif test case (report portlist)
# |
# | Revision 1.38  2006/03/16 14:10:34  wig
# | Fixed messages and [cut] problem 20060315a
# |
# | Revision 1.37  2006/03/14 14:18:13  lutscher
# | fixed bug
# |
# | Revision 1.36  2006/03/14 08:10:34  wig
# | No changes, got deleted accidently
# |
# | Revision 1.35  2005/11/22 11:00:48  wig
# | Minor fixes in Utils (20051121a, K: mkdir problem)
# |
# | Revision 1.34  2005/11/04 10:44:47  wig
# | Adding ::incom (keep CONN sheet comments) and improce portlist report format
# | ...........                                                           |
# |                                                                       |
# |                                                                       |
# +-----------------------------------------------------------------------+
package  Micronas::MixUtils::IO;
require Exporter;

@ISA=qw(Exporter);

@EXPORT  = qw(
	init_ole
	close_open_workbooks
	mix_utils_open_input
	open_infile
    open_xls
    open_sxc
	open_csv
	write_outfile
	write_xls
	write_sxc
	write_csv
	write_delta_sheet
	clean_temp_sheets
	mix_utils_io_create_path
);

@EXPORT_OK = qw();


our $VERSION = '1.0';

use strict;
use Cwd;
use File::Basename;

use Log::Log4perl qw(get_logger);

use Text::Diff;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

use Micronas::MixUtils qw( :DEFAULT %OPTVAL $eh replace_mac convert_in
			  select_variant two2one one2two);
use Micronas::MixUtils::InComments;
use Micronas::MixUtils::Globals;

# use ooolib;   -> Loaded on demand, only!
use Spreadsheet::ParseExcel;
#use Spreadsheet::WriteExcel;

# Prototypes
sub close_open_workbooks();
# sub _sheet ($$$);
# migrated to MixUtils.pm: sub mix_apply_conf ($$$);
sub mix_utils_open_input(@);
sub close_open_workbooks ();
sub mix_utils_mask_excel ($);
sub absolute_path ($);
sub useOoolib ();
sub _split_diff2xls ($$);
sub _join_split_lines ($);
sub _remove_empty_cols ($);
sub mix_utils_io_check_path ();
sub open_infile		($$$$);
sub open_xls		($$$$);
sub open_sxc		($$$$);
sub open_csv		($$$$);

#
# RCS Id, to be put into output templates
#
my $thisid          =      '$Id: IO.pm,v 1.55 2007/09/14 13:31:44 lutscher Exp $';#'  
my $thisrcsfile	    =      '$RCSfile: IO.pm,v $'; #'
my $thisrevision    =      '$Revision: 1.55 $'; #'  

# Revision:   $Revision: 1.55 $
$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?


my $ex = undef;

my $logger = get_logger( 'MIX::MixUtils::IO' );
# my $eh;			# imported from MixUtils.pm

###### extra block
{   # keep this stuff localy

    my %workbooks = ();
    my %newbooks = ();

####################################################################
## init_open_workbooks
## Remember all workbooks we opened
####################################################################
=head2 init_open_workbooks()

Remember all Excel or Star(\Open)-Office workbooks we opened

=cut

sub init_open_workbooks() {

    if(defined $ex) {
		foreach my $bk ( in( $ex->{'Workbooks'}) ) {
	    	$workbooks{$bk->{'Name'}} = $bk; # Remember that
		}
    } else {
		$logger->error( '__E_OLE', "\tUninitialized OLE! Cannot read/write XLS files" );
    }
    return;
}


####################################################################
## is_open_workbook
## test if parameter $workbook is a open workbook
####################################################################
=head2 is_open_workbook($)

test if parameter $workbook is a open workbook

=over 4

=item $workbook workbook to test

=back

=cut

sub is_open_workbook($) {

    if(defined $ex) {

	my $workbook = shift;

	for my $i ( keys( %workbooks ) ) {
	    if ( $i =~ m,^$workbook$,i ) {
		return $workbooks{$i};
	    }
	}

	for my $i ( keys( %newbooks ) ) {
	    if ( $i =~ m,^$workbook$,i ) {
		return $newbooks{$i};
	    }
	}
	return undef;
    }
}


####################################################################
## new_workbook
## Remember all workbooks we made 
####################################################################
=head2 new_workbook($$)

Remember all workbooks we made 

=over4

=item $workbook hash name
=item $book book name

=back

=cut

sub new_workbook($$) {

    if(defined $ex) {
        my $workbook = shift;
	my $book = shift;

	$newbooks{$workbook} = $book;
    }
}


####################################################################
## close_open_workbooks
## Finally, close all workbooks we opened while running along here
####################################################################

=head2 close_open_workbooks()

Finally, close all workbooks we opened while running along here

=cut

    sub close_open_workbooks() {
		if(defined $ex) {
	    	for my $i ( keys( %newbooks ) ) {
	        	$newbooks{$i}->Close or
	        		$logger->error( '__E_FILE_CLOSE', "\tCannot close $i workbook" );
	    	}
        }
    }


}   # end block (local workbooks)
###### extra block end


##############################################################################
## init_ole
## take CONF sheet  contents and transfer that into $eh (overloading values there)
##############################################################################

=head2 init_ole()

Start OLE server (to read ExCEL spread sheets in our case)
Returns a OLE handle or undef if that fails.

=cut

sub init_ole () {
    # Start Excel/OLE Server, do it in eval ....
    unless ( eval 'use Win32::OLE;' ) {
        # only done on Win32 and if needed ....
        eval 'use Win32::OLE::Const;
    	use Win32::OLE qw(in valof with);
        use Win32::OLE::Const \'Microsoft Excel\';
        use Win32::OLE::NLS qw(:DEFAULT :LANG :SUBLANG);
        my $lgid = MAKELANGID(LANG_ENGLISH, SUBLANG_DEFAULT);
        $Win32::OLE::LCID = MAKELCID($lgid);
        $Win32::OLE::Warn = 3;'; #'
		if ( $@ ) {
	    	$logger->error( '__E_USE_WIN32', "\tEval use Win32 failed: $@" );
	    	return undef();
    	}

		$ex = undef;
    	unless( $ex=Win32::OLE->GetActiveObject('Excel.Application') ) {
			# Try to start a new OLE server:
			unless ( $ex=Win32::OLE->new('Excel.Application', 'Quit' ) ) {
				$logger->fatal( '__F_OLE_EXCEL', "\tCannot get excel aplication: $!\n" );
				die; # REFACTOR CHECK
				return undef; # Did not work ...
			}
		}
		return $ex;
    } else {
		$logger->fatal( '__F_OLE_SERVER',  "\tCannot fire up OLE server, use Win32::OLE: $@\n" );
		die; # REFACTOR CHECK
		return undef;
    }
} # End of init_ole

##############################################################################
## mix_sheet_conf
## take CONF sheet  contents and transfer that into $eh (overloading values there)
##############################################################################

=head2 mix_sheet_conf( $rconf, $source)

Take array provided by the mix_utils_open_input function (excel, soffice or csv), search for
the MIXCFG tag. If found, convert that into $eh.

=over 4

=item $rconf Input Array
=item $source parameter unused

=back

=cut

sub mix_sheet_conf($$) {
    my $rconf = shift;    # Input array
    my $s = shift;        # Source

    ROW: for my $i ( @$rconf ) {
		for my $j ( 0..(scalar ( @$i ) - 3 ) ) {
	    	next unless ( $i->[$j] ); # Skip empty cells in this row
	    	if ( $i->[$j] eq 'MIXCFG' ) { #Try to read $ii+1 and $ii+2
				my $key = $i->[$j+1] || '__E_EXCEL.CONF.KEY';
				my $val = $i->[$j+2] || '__E_EXCEL.CONF.VALUE';
				mix_apply_conf( $key, $val, "EXCEL:$s" ); #Apply key/value
				next ROW;
	    	} else { # If row does not have MIXCFG in first cell, skip it.
				next ROW;
	    	}
		}
    }
}


####################################################################
## mix_utils_open_input
## open all input files and read in the worksheets needed
## do basic checks and conversion 
####################################################################
=head2 mix_utils_open_input(@)

Open all input files and read in their CONN, HIER and IO sheets
Returns two (three/four) arrays with hashes ...

=over 4

=item @in input

=back

=cut

sub mix_utils_open_input(@) {
    my @in = @_;

    my $aconn = [];
    my $ahier = [];
    my $aio = [];
    my $ai2c = [];

    for my $i ( @in ) {
		unless ( -r $i ) {
	    	$logger->error('__E_INFILE_READ', "\tFile $i cannot be read!");
	    	next;
		}

		my @conf;
		my $conn;
		my $hier;
		my $io;
		my $i2c;

		# maybe there is a CONF page?
		# Change CONF accordingly (will not be visible at upper world)
		# TODO : add plugin interface to read in whatever is needed ...
		@conf = open_infile( $i, $eh->get( 'conf.xls' ), $eh->get( 'conf.xxls' ), $eh->get( 'conf.req' ) );

		# Open connectivity sheet(s)
		$conn = open_infile( $i, $eh->get( 'conn.xls' ), $eh->get( 'conn.xxls' ),
			$eh->get( 'conn.req' ) . ',order,hash' );

		# Open hierachy sheets
		$hier = open_infile( $i, $eh->get( 'hier.xls' ), $eh->get( 'hier.xxls' ),
			$eh->get( 'hier.req' ) . ',order,hash' );

		# Open IO sheet (if available, not needed!)
		$io = open_infile( $i, $eh->get( 'io.xls' ), $eh->get( 'io.xxls'),
			$eh->get( 'io.req' ) . ',order,hash' );

		# Open I2C sheet (if available, not needed!)
		$i2c = open_infile( $i, $eh->get( 'i2c.xls' ), $eh->get( 'i2c.xxls' ),
			$eh->get( 'i2c.req' ) . ',order,hash' );

		# Did we get enough sheets:
		unless( $conn or @conf or $hier or $io or $i2c ) {
	    	$logger->error('__E_OPEN_INPUT', "\tNo input found in file $i!\n");
	    	next; # -> skip to next
		}

		# Parse the configuration ....
		# TODO : Should it be allowed to change the sheet names in the conf files?
		#		Then we would need to push that function up
		for my $c ( @conf ) {
	    	$eh->inc( 'conf.parsed' );
	    	# Apply it immediately
	    	mix_sheet_conf( $c, $eh->get( 'conf.xls' ) );
		}

		# Merge conn sheets:
		for my $c ( @$conn ) {
	    	$eh->inc( 'conn.parsed' );
 	    	my @norm_conn = convert_in( 'conn', $c->[1] ); # Normalize and read in
 	    	select_variant( \@norm_conn, 'CONN ' . $c->[0] );
	    	push( @$aconn, @norm_conn ); # Append
		}

		# Merge hier sheets:
		for my $c ( @$hier ) {
	    	$eh->inc( 'hier.parsed' );
	    	my @norm_hier = convert_in( 'hier', $c->[1] );
 	    	# Remove all lines not selected by our variant
	    	select_variant( \@norm_hier, 'HIER ' . $c->[0] );
	    	push( @$ahier,   @norm_hier );	# Append
		}

		for my $c ( @$io ) {
	    	$eh->inc( 'io.parsed' );
	    	my @norm_io = convert_in( 'io', $c->[1] );
	    	select_variant( \@norm_io, 'IO ' . $c->[0] );
	    	push( @$aio, @norm_io );   # Append
		}

		for my $c ( @$i2c ) {
	    	$eh->inc( 'i2c.parsed' );
	    	my @norm_i2c = convert_in( 'i2c', $c->[1] );
	    	select_variant( \@norm_i2c, 'I2C ' . $c->[0] );
	    	push(@$ai2c, @norm_i2c);
		}
    }

	mix_utils_io_del_abook(); # Remove all cached input data (only for excel currently),    
	# Here we do the final setup, all configuration known now.
	# Check if all directories exists -> create if not
	mix_utils_io_create_path();
	return( $aconn, $ahier, $aio, $ai2c);
	
} # End of mix_utils_open_input

=head2 mix_utils_io_create_path () {

Check if all required output directories exist.
Create if not.

Get list from $eh->get( 'XXXX.path' )!

Input: -
Output: -

Global: $eh
	output intermediate internal report
	  ....path
	output.mkdir

#!wig20051005

=cut

sub mix_utils_io_create_path () {

	my $select = $eh->get( 'output.mkdir' );
	
	for my $i ( qw( output intermediate internal report reg_shell.e_vr_ad) ) {
		next unless( defined $eh->get( $i . '.path' ) );
		
		unless( -d $eh->get( $i . '.path' ) ) {
			# need to create it ...
			my $dir = $eh->get( $i . '.path' );
			# Does select tell us to create it?
			if ( $select =~ m/\b(1|all|yes|auto|$i)\b/i ) {
				unless ( $dir =~ m,^/, ) { # relative path ....
					$dir = $eh->get( 'cwd' ) . '/' . $dir;
				}
				# Iterate over path ...
				my $cur = '';
				$dir =~ s,//+,/,og;
				for my $p ( split( /\//, $dir ) ) {
					$p = '/' unless( length( $p ) );
					$cur .= (( $cur ) ? '/' : '' ) . $p; # Merge path
					$cur =~ s,//+,/,og; # Remove multiple / (Cygwin does not like them)
					next if -d $cur;
					# Create it
					unless( mkdir( $cur ) ) {
						$logger->fatal( '__F_MKDIR', "\tCannot create $i directory $cur:" . $! );
						exit 1;
	    			}
				}
	    		$logger->info( '__I_MKDIR', "\tCreated $i directory " . $dir . "!" );
			} else {
				$logger->error( '__E_MKDIR', "\tMissing $i directory " . $dir . " not selected for creation!" );
			}
		}
	}
} # End of mix_utils_io_create_path

####################################################################
## open_infile
## maps call to correct open function
####################################################################
=head2 open_infile($$$$)

maps a call to correct open function

input:
=over 4
=item $filename name of file
=item $sheetname of worksheet (regular expression possible)
=item $xsheetname optional: ignore sheet matching thir expression
=item $flag flags (like mandatory, optional, ...)

output:

global: writes to $eh->set( 'sum.errors' )

=back

=cut

sub open_infile($$$$){
    my $file = shift;
    my $sheetname = shift;
    my $xsheetname = shift;
    my $flags = shift;

    if( $file=~ m/\.xls$/) { # read excel file
        return open_xls($file, $sheetname, $xsheetname, $flags);
    } elsif( $file=~ m/\.sxc$/) { # read soffice file
        return open_sxc($file, $sheetname, $xsheetname, $flags);
    } elsif( $file=~ m/\.csv$/) { # read comma seperated values
        return open_csv($file, $xsheetname, $sheetname, $flags);
    } else {
        $logger->error( '__E_FILE_EXTENSION', "\tUnknown file extension for file $file!" );
		return undef;
    }
} # End of open_infile


####################################################################
## open_xls
## open excel file and get contents
####################################################################
=head2 open_xls($$$$)

Open a excel file, select the appropriate worksheets and return

=over 4
=item $filename name of file
=item $sheet name of worksheet (can be comma-separated list)
=item $xsheet name of worksheets to exclude
=item $flag flags

=back

flags can be one of:
	mandatory	:= print warning if no matching sheet is detected
	optional	:= return silently, even if no matching sheet is available
	write		:= open for write
	hash		:= return data in hashref: \%data{sheetname} = [ ... ],
					otherwise data is returned in array of array
	order		:= in combination with hash: return array of hash ordered
					by appearance
=cut

{   # wrap around $oBook static variable ...
	# Cache opened xls-file
	my %aBook        = (); # xls-content
	
sub open_xls($$$$){
    my ($file, $sheetname, $xsheetname, $warn_flag)=@_;

    my $openflag = 0;
    my $isheet;
    my $oBook;

    my @sheets = ();

	unless( -r $file ) {
		$logger->error( '__E_FILE_READ', "\tCannot read <$file> in open_xls!" );
		return undef;
    }
    $file = absolute_path( $file );

    my $basename = basename( $file );
    my $ro = 1;
    if ( $warn_flag =~ m,write,io or $OPTVAL{'import'} or $OPTVAL{'init'} ) {
		$ro = 0;
    }

	unless( exists $aBook{$file} ) {
		# Need to read in again ...
		$aBook{$file} = Spreadsheet::ParseExcel::Workbook->Parse($file);
	}
	$oBook = $aBook{$file};
	
    unless( defined $oBook ) {
		$logger->error( '__E_FILE_OPEN', "\tOpening ExCEL File $file");
    }

    # Take all sheets matching the possible reg ex (or comma-seperated list) in $sheetname
    my @lsheetnames = split(/\,\s*/, $sheetname);
    foreach my $_sheetname (@lsheetnames) {
        for(my $i=0; $i < $oBook->{SheetCount} ; $i++) {
            $isheet = $oBook->{Worksheet}[$i];
            next if ( $xsheetname and $isheet->{Name} =~ m/^$xsheetname$/ );
            if ( $isheet->{Name} =~ m/^$_sheetname$/ ) {
                push( @sheets, $i );
        	}
        }
    };

    # return if no sheets where found
    if ( scalar( @sheets ) < 1 ) {
		if ( $warn_flag =~ m,mandatory,io ) {
	    	$logger->warn('__W_WORKSHEET', "\tCannot locate a worksheet matching $sheetname in $file");
		}
		return ();
    }

    my $cell = '';
    my @line = ();
    my @sheet = ();
    my @all = ();
    my %all = ();

	my $xls_warns = $eh->get( 'check.keywords.xlscell' ) || 0; #
    foreach my $sname ( @sheets ) {

		$isheet = $oBook->{Worksheet}[$sname];
		$logger->info( '__I_WORKSHEET', "\tReading worksheet " . $isheet->{Name} . " of $file" );
		my $maxdef_x = 0;

		for(my $y=$isheet->{MinRow}; defined $isheet->{MaxRow} && $y <= $isheet->{MaxRow}; $y++) {
			for(my $x =$isheet->{MinCol}; defined $isheet->{MaxCol} && $x <= $isheet->{MaxCol}; $x++) {
				$cell = $isheet->{Cells}[$y][$x];
				if(defined $cell) {
					my $v = $cell->Value;
					# Check Value: if cell contains #VALUE!, #NAME? or #NUM! alert user ...
					if ( $xls_warns and $v =~ m/$xls_warns/ ) {
						if ( $v eq 'GENERAL' ) {
							$logger->warn( '__W_XLS_REFS', "\tXLS cell " .
								Spreadsheet::ParseExcel::Utility::int2col( $x ) . ( $y + 1 ) . 
								" (R" . ( $y + 1 ) . "C" . ( $x + 1 ) . ", sheet " .
								$isheet->{Name} . ") dubious cell content: " . $v ) .
								" using: " . $cell->{'Val'};
							$v = $cell->{'Val'};
						} else {
							$logger->error( '__E_XLS_REFS', "\tXLS cell " .
								Spreadsheet::ParseExcel::Utility::int2col( $x ) . ( $y + 1 ) . 
								" (R" . ( $y + 1 ) . "C" . ( $x + 1 ) . ", sheet " .
								$isheet->{Name} . ") dubious cell content: " . $v );
						}
					}
					push(@line, $v);
					if ( defined( $v ) and $x > $maxdef_x ) {
						$maxdef_x = $x;
					}
				} else {
					push(@line, '');
				}
			}
	    	push(@sheet, [@line]);
	    	@line = ();
		}

		#!wig20031218: take away trainling empty lines ...
		if ( scalar( @sheet ) > 0 ) {
	    	while( not join( '', @{$sheet[-1]} ) ) {
				pop( @sheet );
	    	}
		}
		# Remove trailing empty cells
		for my $l ( @sheet ) {
			my $len = scalar( @$l );
			if ( $maxdef_x < $len - 1 ) {
				delete( @$l[($maxdef_x+1)..($len-1)] );
			}
		}
		
		if ( scalar( @sheet ) > 0 ) {
			if ( $warn_flag =~ m/\border\b/i ) {
				push( @all, [$isheet->{Name}, [ @sheet ]] );
			} elsif ( $warn_flag =~ m/\bhash\b/i ) {
				@{$all{$isheet->{Name}}} = @sheet;
			} else {
	    		push(@all, [@sheet]);
			}
		} else {
	    	$logger->warn( '__W_WORKSHEET_READ', "\tSheet $isheet->{Name} holds no content" );
		}

		@sheet = ();
    }
    
	if ( $warn_flag =~ m/\border\b/ ) {
		return \@all ;
	} elsif ( $warn_flag =~ m/\bhash\b/i ) {
		return \%all;
	} else {	
    	return(@all);
	}
} # End of open_xls

sub mix_utils_io_del_abook () {
	%aBook = ();
} 

} # wrap around $aBook, static variable

####################################################################
## open_sxc
## open star(/open) office file, parse content and return it
####################################################################
=head2 open_sxc($$$$)

Open a Star-Office calculator file, select the appropriate
worksheets and return

=over 4
=item $filename name of file
=item $sheet name of worksheet
=item $xsheetname ignore sheets matching this regular expression
=item $flag flags

=back

flags can be one of:
	mandatory	:= print warning if no matching sheet is detected
	optional	:= return silently, even if no matching sheet is available
	write		:= open for write
	hash		:= return data in hash: %data{sheetname} = [ ... ],
					otherwise data is returned in array of array

=cut

sub open_sxc($$$$) {
    my ($file, $sheetname, $xsheetname, $warn_flag)=@_;
    my $openflag = 0;

    unless(-r $file) {
		$logger->error( '__E_READ_FILE', "\tCannot read file $file!" );
		return undef;
    }
    unless(defined $sheetname) {
        $logger->error( '__E_READ_FILE',  "\tNo sheet defined to read from file $file!" );
		return undef;
    }

    # unzip $file in $path
    my $zip = Archive::Zip->new();
    unless($zip->read($file)==AZ_OK) {
		$logger->error( '__E_UNZIP_SXC', "\tCan't open zip file $file!" );
		return undef;
    }
    # extract content.xml file from archive
    my @content = readContent($zip);

    unless( defined $content[0]) {
		$logger->error( '__E_READ_SXC', "\tNo content found in file $file!" );
		return undef;
    }

    my @all = ();
    my %all = ();
    my @sheet = ();
    my @line = ();
    my @cell = ();

    my $isheet = 0;  # defined if we are "inside" a sheet
    my $irow = 0;    # defined if we are "inside" a row
    my $icell = 0;   # defined if inside a cell
    my $itext = 0;   # defined inside a text 

    my $repeat = 0;    # number of cell repeatings
    my $emptyLine = 1; # defined if a line is empty
    my $maxcells = 0;  # maximum number of cells per row

    if($sheetname eq "CONF") {
        $maxcells = 3;
    }

    for(my $i=0; defined $content[$i]; $i++) {
    	if( !$isheet && $content[$i]=~ m/^<table:table.*>/ 
	 		&& $content[$i]=~ m/ table:name=\"($sheetname)\"/) { # "
	 		# TODO : check if the above regular expression is o.k.
	 		unless ( $xsheetname and $1 =~ m/^$xsheetname$/ ) {
	    		$isheet = 1;  # entering sheet (only if not matching exclude)
	 		}
	  	} elsif($isheet) {
	    	if($content[$i] =~ m/^<\/table:table>/) {
	        	$isheet = 0;  # escape from sheet
	        	if ( $warn_flag =~ m/\border\b/i ) {
					push( @all, [$sheetname, [ @sheet ]] );
				} elsif ( $warn_flag =~ m/\bhash\b/i ) {
	        		@{$all{$sheetname}} = @sheet;
	        	} else {
					push(@all, [@sheet]);
				}
				@sheet = ();
	    	} elsif(!$irow && $content[$i] =~ m/^<table:table-row/) {
			if(!($content[$i]=~ m/\/>$/)) {
		    	$irow = 1;  # entering row
			}
	    } elsif($irow) {
	        if($content[$i]=~ m/^<\/table:table-row>/) {
		    $irow = 0;       # escape row
		    # strip empty cells from row
		    if( $maxcells < scalar(@line)) {
				if(join(" ", @line)=~ m/^::.*/) {
			    	while( !($line[-1]=~ m/^::.*$/)) {
						pop @line;
			    	}
			    	$maxcells = scalar(@line);
				} else {
			    	while($maxcells < scalar(@line)) {
						pop @line;
			    	}
				}
		    }
		    while( $maxcells > scalar(@line)) {
				push(@line, "");
			}

		    if(!$emptyLine) {
				push(@sheet, [@line]);
				# uncomment for debug output
				# print "Line ". (scalar(@sheet)-1) . ": ";
				# print join(' ; ', @line) ."\n";
		    }
		    @line = ();
		    $emptyLine = 1;
	    }
		# begin of new cell
		elsif(!$icell && $content[$i]=~ m/<table:table-cell/) {
		    $icell = 1;    # enter cell
		    $repeat = 1;   # repeating of cells
		    my $temp = $content[$i];
		    if($temp=~ s/^.* table:number-columns-repeated=\"//) { # "
			$temp =~ s/\".*//g; # "
			$repeat = $temp;
		    }
		    # empty cell
		    if($content[$i]=~ m/<table:table-cell.*\/>/) {
			$icell = 0;    # escape from cell
			for(my $j=0; $j<$repeat; $j++) {
			    push(@line, "");
			}
		    }
		} elsif($icell) {
		    # text entry
		    if($content[$i]=~ m/<\/table:table-cell>/) {
				$icell = 0;
				my $temp = join(" ", @cell);
				for my $j (0..$repeat-1) {
			    	push(@line, $temp);
				}
				@cell = ();
		    } elsif($content[$i]=~ m/<office:annotation.*/) {
			# skip annotation (not of interrest)
				do{
			    	$i++;
				} while(not $content[$i]=~ m/<\/office:annotation>/);
		    } elsif(!$itext && $content[$i]=~ m/<text:p>/) {
			# beginning of text entry
				$itext = 1;
		    } elsif($itext) {
				while($content[$i]=~ s/<text:s.*>/ /) {
			    	if(defined $content[$i+1]) {
						$i++;
						$content[$i] = $content[$i-1] . $content[$i];
			    	}
				}
				if($content[$i]=~ m/<text:a .*>/) {
			    	do {
						my $temp = $content[$i];
						$temp=~ s/<.*>//;
						$i++;
						$content[$i] = $temp . $content[$i];
			    	} while($content[$i]=~ s/<\/text:a>//);
				}
				if($content[$i] =~ s/<\/text:p>//) {
			    	$itext = 0;
			    	$content[$i] =~ s/\&amp;/\&/g;
			    	$content[$i] =~ s/\&apos;/'/g; #'
			    	$content[$i] =~ s/\&lt;/</g;
			    	$content[$i] =~ s/\&gt/>/g;
			    	push(@cell, $content[$i]);
			    	if( defined $content[$i]) { 
						$emptyLine = 0;
			    	}
				}
		    }
		}
	    }
	}
    }
    if ( scalar( @all ) < 1 and scalar( keys %all ) < 1 ) {
		if ( $warn_flag =~ m,mandatory,io ) {
	    	$logger->warn('__W_LOCATE_SHEET', "\tCannot locate a worksheet $sheetname in $file" );
		}
		return ();
    }
    if ( $warn_flag =~ m/\border\b/i ) {
    	return \@all;
    } elsif ( $warn_flag =~ m/\bhash\b/i ) {
    	return \%all;
    }
    return @all;
} # End of open_sxc


####################################################################
## open_csv
## open csv file and get contents
####################################################################
=head2 open_csv($$$$)

Open a csv file, select the appropriate worksheets and return

=over 4
=item $filename name of file
=item $sheet name of worksheet
=item $xsheetname  ignore sheets matching this regular expression
=item $flag flags

flags can be one of:
	mandatory	:= print warning if no matching sheet is detected
	optional	:= return silently, even if no matching sheet is available
	write		:= open for write
	hash		:= return data in hash: %data{sheetname} = [ ... ],
					otherwise data is returned in array of array

=back

=cut

sub open_csv($$$$) {

    my ($file, $sheetname, $xsheetname, $warn_flag)=@_;
    my $openflag = 0;

    my @all = ();
    my %all = ();
    my @sheet = ();
    my @line = ();

    my $sheetCount = 0;
    my $sheetsep = $eh->get( 'format.csv.sheetsep' );
    my $cellsep  = $eh->get( 'format.csv.cellsep' );
    my $quoting  = $eh->get( 'format.csv.quoting' );

    my $quoted = 0;
    my $char;
    my $lastchar = "";
    my $entry = "";

    unless( -r $file ) {
        $logger->error( '__E_READ_CSV', "\tCannot read <$file> in open_csv!" );
		return undef;
    }

    my $ro = 1;

    if ( $warn_flag =~ m/\bwrite\b/i or $OPTVAL{'import'} or $OPTVAL{'init'} ) {
		$ro = 0;
    }

    open(FILE, $file);
    my @input = <FILE>;
    close(FILE);

    # Take all sheets matching the possible reg ex in $sheetname
    for(my $i=0; defined $input[$i]; $i++) {
    	next if ( $xsheetname and $input[$i] =~ m/^$sheetsep($xsheetname)\s*$/);
		if( $input[$i] =~ m/^$sheetsep($sheetname)\s*$/) {
			my $thissheet = $1;
		
	    	$i++;
        	while( defined $input[$i] && not $input[$i]=~ m/^$sheetsep/) {

				for( my $j=0; $j<length($input[$i]); $j++) {

		    		$char=substr($input[$i], $j, 1);

		    		if( $quoted) {
		      		# inside quotas
		        		if( $char=~ m/^$quoting$/) {
			    			if( $lastchar=~ m/^\\$/) {
			      			# quoting character isn't a control sequence
								$entry = $entry . $char;
			    			} else {
			      			# leave quoting
			        			$quoted = 0;
			    			}
		        		} else {
			  			# character inside quotas
			    			if($char=~ m/^\n$/) { 
								$entry = $entry . " ";
			    			} elsif($char!~ m/^\\$/) {
								if($lastchar eq "\\") {
				    				$entry = $entry . "\\";
								}
								$entry = $entry . $char;
			    			}
						}
		    		} else {
		      		# outside quotas
		        		if( $char=~ m/^$cellsep$/) {
			  			# entry complete
			    			push(@line, $entry);
			    			$entry = '';
						} elsif( $char=~ m/^$quoting$/) {
			  			# enter quotas
			    		$quoted = 1;
					}
		    	}
		    	$lastchar = $char;
			}
			# push last entry and push whole line
			push(@line, $entry);
			$entry = '';
			push(@sheet, [@line]);
			@line = ();
			$i++;    # next line
	    }
	   	if ( $warn_flag =~ m/\border\b/i ) {
			push( @all, [$thissheet, [ @sheet ]] );
	   	} elsif ( $warn_flag =~ m/\bhash\b/i ) {
	    	$all{$thissheet} = \@sheet;
	    } else {
	    	push(@all, [@sheet]);
	    }
	    @sheet = ();
	}
    }

    # did we get some input?
    if ( scalar @all < 1 and scalar( keys %all ) < 1 ) {
		if ( $warn_flag =~ m/\bmandatory\b/i ) {
            $logger->warn('__W_READ_CSV_SHEET', "\tCannot read input from sheet: $sheetname in $file");
		}
		return ();
    }
    if ( $warn_flag =~ m/\border\b/i ) {
    	return \@all;
    } elsif ( $warn_flag =~ m/\bhash\b/i ) {
		return \%all;
	} else {
    	return (@all);
	}
} # End of open_csv


####################################################################
## absolute_path
## convert "normal" filename to absolute path, usable for OLE server
####################################################################
=head2 absolute_path($)

Take input file name with/out path name and convert it to absolute path
Replace all / (I prefer to use) by  \ (ExCEL needs)

=over 4
=item $file path of file

=back

=cut

sub absolute_path($) {

    my $file = shift;

    # Make filename a absolute one (we are on MS ground)
    # Has to start like N:\bla\blubber or N:/path/....

    if ( $eh->get( 'iswin' ) ) {
		if ( $file =~ m,^[\\/], ) {
	    	# Missing the letter for a drive
	    	$file = $eh->get( 'drive' ) . $file;
		} elsif ( $file !~ m,^\w:, ) {
	    	$file = $eh->get( 'cwd' ) . '/' . $file;
		}
    } elsif ( $file !~ m,^/, ) { # Does not start with /
		$file = $eh->get( 'cwd' ) . '/' . $file;
    }

	# Strip of cygwin home -> homedrive ...
	#  /cygdrive/X  -> X:/ ....
	#  cygwin can cope with both, while for excel c: is mandatory
	if ( $eh->get( 'iscygwin' ) ) {
		$file =~ s/$ENV{'HOME'}/$ENV{'HOMEDRIVE'}/;
		$file =~ s!/cygdrive/(\w)!$1:!;
	}

    return $file
}


####################################################################
## write_delta_sheet
## write delta intermediate data to excel sheet
####################################################################
=head2 write_delta_sheet($$$)

read in previous intermediate data, diff and print out only differences.

=over 4

=item $file filename
=item $type sheetname (CONN|HIER)
=item $ref_a reference to array with data

=back

=cut

sub write_delta_sheet($$$) {
    my $file = shift;
    my $sheet = shift;
    my $r_a = shift;

    # Fix path
    my $predir = '';
    if ( $eh->get( 'intermediate.path' ) ne '.' and not is_absolute_path( $file ) ) {
		# Prepend a directory name ...
		$predir = $eh->get( 'intermediate.path' ) . '/' ;
		$predir =~ s,[/\\]+$,/,; # Strip of extra trailing slashes / and \ ...
    }

    my @prev;

    # Read in intermediate from previous runs ...
	# map filename from xls -> csv if not on Windows!
	# TODO : shouldn't we for mapping on non MS-Win anyway?
	if ( not -r $predir . $file and $file =~ m/\.xls$/ and
		not ( $eh->get( 'iswin' ) or $eh->get( 'iscygwin' ) ) ) {
			# Try with csv intermediate
			$file =~ s/\.xls/.csv/;	
	}
	# If that file does not exist -> create a new one
	#!wig20051019: use cvs if available
	unless( -r $predir . $file ) {
		write_outfile( $file, $sheet, $r_a );
		return 0;
	}
		
    @prev = open_infile( $predir . $file, $sheet, '', 'mandatory,write');

    if(scalar( @prev ) < 1 ) {
        $logger->error( '__E_READ_DELTA',  "\tUnable to read input for delta mode from file $file!" );
		return 1;
    }

	#!wig20050926: join split lines before diff!
	_join_split_lines( $r_a );
	_join_split_lines( $prev[0] );

	#!wig20061115: remove all empty columns
	#	the '::shortname' syndrom
	if ( $eh->get( 'intermediate.delta' ) =~ m/\bpurgetable/ ) {
		_remove_empty_cols( $r_a );
		_remove_empty_cols( $prev[0] );
	}
	
    my @prevd = two2one( $prev[0] );
    my @currd = two2one( $r_a );
    if ( not $eh->get( 'iswin' ) and $file =~ m,.xls$, ) {
		# read in previously generated -mixed.xls file
		# -> map away \n and other whitespace ...
		#TAG: maybe we need to generalize that ... should be done if we are sure to
		#   not write xls output
		map( { s/,\s+/,/g } @prevd ); # Remove \n and such
		map( { s/,\s+/,/g } @currd );
		map( { s/@@@\s+/@@@/g } @prevd ); # Remove \n and such
		map( { s/@@@\s+/@@@/g } @currd );
    }
    
    my @colnhead = @{$r_a->[0]};

    # Print header to ... (usual things like options, ....)
    # TODO: Add that header to header definitions
    my $head =
"-------------------------------------------------------
-- ------------- delta mode for file $file ------------- --
--
-- Generated
--  by:  %USER%
--  on:  %DATE%
--  cmd: %ARGV%
--  delta mode (comment/space/sort/remove): " . $eh->get( 'output.delta' ) . "
--
-- ------------------------------------------------- --
-- ------------- CHANGES START HERE ------------- --
";
    $head = replace_mac( $head, $eh->get( 'macro' ) );

    #!wig20031217: ParseExcel does not deliver the \n (?), so we map those to nothing
    #  shouldn't matter to much ...
    # TODO: make that configurable ...
    # @currd = map( { s,\n,,g},  @currd );
     
    # Diff it ...
    my $diff = diff( \@currd, \@prevd,
                { STYLE => "Table",
                # STYLE => "Context",
                FILENAME_A => 'NEW', #TODO: get new file name in here!
                FILENAME_B => "OLD $file",
                CONTEXT => 0,
                # OUTPUT     => $fh,
                }
    );

    # Was there a difference? If yes, report and sum up.
    if ( $diff ) {
		my $niceform = 1; # Try to write in extended format ...
		if ( $currd[0] ne $prevd[0] ) { # Column headers have changed!!
	    	$logger->warn('__W_DELTA_SHEET', "\tSHEET_DIFF with different headers useless!");
	    	# Fall back to write delta in old format
	    	$niceform = 0;
		}

        my @h = split( /\n/, $head );
		@h = one2two( \@h );
		shift @h;
		$h[0][1] = $h[0][2] = $h[0][3] = "-- delta --";
		my @out = ();
		@out = split( /\n/, $diff );
		@out = one2two( \@out );
		my $difflines = shift( @out );
		my $r_delcols = [];

		push( @h, [ "--NR--", "--CONT--", "--NR--", "--CONT--" ] );
		if ( $niceform ) {
	    	# Convert into tabular format, mark changed cells !!
			push( @h, [ "HEADER",  @colnhead ] ); # Attach header line
	    	unshift( @h, [ "HEADER", @colnhead ] ); # Preped full header line
	    	my $colwidth = scalar( @{$h[0]} ); # Matrix has to be wide enough ...

			( my $ref_h, $r_delcols ) = _split_diff2xls( \@out, scalar( @h ) );

			push( @h, @$ref_h );
		} else {
	   		push( @h, [ '--COLUMN_MISMATCH--', '--COLUMN_MISMATCH--', '--COLUMN_MISMATCH--', '--COLUMN_MISMATCH--' ] );
	   		my $offset = scalar( @h );
			push( @$r_delcols, ( $offset . '/' . '1' ),
	    					( $offset . '/' . '2'),
	    					( $offset . '/' . '3'),
	    					( $offset . '/' . '4'),
	    					  );

			# Remove the @@@ signs from output ...
	    	for my $o ( @out ) {
				map( { s,@@@,,g } @$o );
	    	}
	    	# Usually we have four columns; try to match 1 against 3:
	    	for my $o ( 0..scalar(@out)-1 ) {
	    		if ( defined $out[$o][1] and defined $out[$o][3]
	    			and $out[$o][1] ne $out[$o][3] ) {
	    				push( @$r_delcols, ( $o+1+$offset . "/" . "2" ),
	    					( $o+1+$offset . "/" . "4") );
	    		}
	    	}
	    	push( @h, ( @out ) );
		}

		#!wig20050712: add a bottom --END-- line to seperate current contents
		#  from previous one (comes from copying data)
		push( @h, [ "--END--", "--END--", "--END--", "--END--" ] );
		push( @h, [ '','','','' ], [ '','','','' ], [ '','','','' ], [ '','','','' ] );
	
		write_outfile($file, "DIFF_" . $sheet, \@h, $r_delcols, $niceform);

		# One line has to differ (date)
		if ( $difflines > 0 ) {
			# REFACTOR: $logger->all()
	    	$logger->info( '__I_DELTA_SHEET', "\tDetected $difflines changes in intermediate sheet $sheet, in file $file");
		} 
		elsif ( $difflines == -1 ) {
	    	$logger->warn( '__W_DELTA_SHEET', "\tMissing changed date in intermediate sheet $sheet, in file $file");
		}
		return $difflines;
    } else {
		return -1;
    }
} # End of write_delta_sheet

#
# Iterate over conn sheets and try to merge back split lines (::in/::out)
#   This is required for getting correct diffs!
# Input: ref to array of arrays with data
#        replaces merged columns inline
#!wig20050926
#!wig20070305: join ::generate und ::descr, too
sub _join_split_lines ($) {
	my $dataref = shift;
	
	# Get header to column mappings
	my $head = $dataref->[0]; # Has to be first row!
	
	# Predefine columns of interest:
	# ::name, ::in, ::out
	my %cols = (
		'::name' => -1,
		'::in'	 => -1,
		'::out'  => -1,
		'::gen'  => -1,
		'::descr'=> -1,
	);
	
	for my $i ( 0.. (scalar(@$head) - 1 ) ) {
		if ( exists( $cols{$head->[$i]} ) ) {
			$cols{$head->[$i]} = $i;
		}
	} 	 
	
	# do nothing if we could not find the ::name column
	return if( $cols{'::name'} == -1 );
	
	my $lastname = '';
	my $lastline = 0;
	my @delete_me = ();
	# Iterate over all other lines:
	for my $i ( 1..(scalar( @$dataref ) - 1) ) {
		next unless exists( $dataref->[$i][$cols{'::name'}] );
		my $thisname = $dataref->[$i][$cols{'::name'}];
		if ( $thisname and $thisname eq $lastname ) { # Merge ::in and ::out if available!!
			for my $io ( qw( ::in ::out ) ) {
				if ( $cols{$io} > -1 and length( $dataref->[$i][$cols{$io}] ) > 0 ) {
					$dataref->[$lastline][$cols{$io}] .= ", " . $dataref->[$i][$cols{$io}]; 
				}
				# Sort it:
				$dataref->[$lastline][$cols{$io}] =~ s/,\s*,/, /og; # Remove extra \s
				$dataref->[$lastline][$cols{$io}] =
					join( ',', split( /,\s*/, $dataref->[$lastline][$cols{$io}] ) );			
			}
			# Simply append other columns:
			for my $others ( qw( ::gen ::descr ) ) {
				if ( $cols{$others} > -1 and length( $dataref->[$i][$cols{$others}] ) > 0 ) {
					$dataref->[$lastline][$cols{$others}] .= $dataref->[$i][$cols{$others}]; 
				}
			}

			# Remove this line now! Set it to all empty strings ..
			push( @delete_me, $i );
		} else { # Set new start:
			$lastname = $thisname;
			$lastline = $i;
		}
	}
	# Finally: remove the unspliced lines:
	for my $i ( reverse( @delete_me ) ) {
		splice( @$dataref, $i , 1 );
	}
} # End of _join_split_lines

#
# Iterate over sheets and remove all empty colums
#
# Input: ref to array of arrays with data
#        remove empty columns "inline" (no return)
#!wig20050926
sub _remove_empty_cols ($) {
	my $dataref = shift;
	
	# Get header to column mappings
	my $head = $dataref->[0]; # Has to be first row!

	# Delete all cols without contents
	my @empty = ( 0..(scalar( @$head ) - 1 ) ); 
	# Iterate over all other lines:
	my @left = ();
	for my $i ( 1..(scalar( @$dataref ) - 1) ) {
		for my $examine ( @empty ) {
			unless ( defined( $dataref->[$i]->[$examine] )
				and $dataref->[$i]->[$examine] ne ''  ) {
				# Cell is empty:
				push( @left, $examine );
			}
		}
		@empty = @left; # Hand over left columns
		last unless( scalar( @empty ) ); # Stop here, no empty cols.
		@left = ();
	}
	
	# Is there anything left
	if ( scalar( @empty ) ) {
		# Remove these columns (from higher to lower)
		for my $n ( reverse( @empty ) ) {
			$logger->warn( '__W_EMPTYCOLS', "\tRemove all empty column " .
				$dataref->[0]->[$n] );
			my $mindex = scalar( @{$dataref->[0]} ) - 1;
			for my $i ( 0..(scalar( @$dataref ) - 1 ) ) {
				my $dr = $dataref->[$i];
				# if $n is $width -> remove last element
				if ( $n == $mindex ) {
					@$dr = @$dr[0..($mindex-1)];
				} elsif ( $n == 0 and $mindex > 0 ) {
					@$dr = @$dr[1..$mindex];
				} else {
					@$dr = @$dr[0..($n-1),($n+1)..$mindex];
				}
			}
		}
	}
} # End of _remove_empty_cols	

#
# Take diff array and convert back to XLS format
#
# Input: reference to @out two-dim array
# Return: \@array: text to print
#         \@delcols: color info for XLS
#
#!wig20050714: split this from write_delta_sheet
sub _split_diff2xls ($$) {
		my $r_diffs = shift;
		my $offset  = shift; # Offset for coloring ...
		
		my @array = ();
		my @delcols = ();
		
	    # Now convert delta to two-line format ...
	    #   NEW ...
	    #   OLD ...
	    for my $nf ( @$r_diffs ) {
			my @newex = ();
			my @oldex = ();
			if ( scalar( @$nf ) == 4 ) {
		    	$newex[0] = 'NEW-' . $nf->[0]; # Prepend NEW-
		    	$oldex[0] = 'OLD-' . $nf->[2]; # Prepend OLD-
		    	push( @newex, split( /@@@/, $nf->[1] ) ) if $nf->[1];
		    	push( @oldex, split( /@@@/, $nf->[3] ) ) if $nf->[3];
		    	push( @array, [ @newex ] ) if ( scalar( @newex ) > 1  );
		    	push( @array, [ @oldex ] ) if ( scalar( @oldex ) > 1 );
		    	my $fn = scalar( @newex );
		    	my $fo = scalar( @oldex );
		    	my $min = ( $fn < $fo ) ? $fn : $fo;
		    	my $max = ( $fn < $fo ) ? $fo : $fn;
		    	for my $iii ( 0..$min-1 ) {
		    		# Compare two cells ...
					if ( $newex[$iii] ne $oldex[$iii] ) {
			    		push( @delcols , (scalar(@array) + $offset) . '/' . ( $iii + 1 ) );
					}
		    	}
		    	# Create colors for all newly created cells ....
		    	if ( $min < $max ) {
					for my $iii ( $min..$max ) {
						if ( defined( $newex[$iii] ) and $newex[$iii] or
							 defined( $oldex[$iii] ) and $oldex[$iii] ) {
			    				push( @delcols, (scalar( @array ) + $offset). '/' . ( $iii + 1 ) );
						}
					}
		    	} 
			} else {
		    	push( @array, $nf );
			}
	    }
	return( \@array, \@delcols );
}

####################################################################
## write_outfile
## write data into outfile
####################################################################
sub write_outfile($$$;$$) {

    my $file = shift;
    my $sheet = shift;
    my $r_a = shift;
    my $r_c = shift || undef;
    my $newold_flag = shift || undef;

	my $fout = lc( $eh->get( 'format.out' ));
    if( $fout eq 'xls' or ( $file=~ m/\.xls$/ &&
    	( $eh->get( 'iswin' ) or $eh->get( 'iscygwin' ) ) )) {
		write_xls($file, $sheet, $r_a, $r_c, $newold_flag);
    } elsif( $fout eq 'sxc' or $file=~ m/\.sxc$/) {
		write_sxc($file, $sheet, $r_a, $r_c);
    } elsif( $fout eq 'csv' or $file=~ m/\.csv$/ or
    		$file=~ m/\.xls$/) {
		$file=~ s/\.xls$/\.csv/;
		write_csv($file, $sheet, $r_a, $r_c);
    } else {
		$logger->warn( '__W_FILE_WRITE',  "\tUnknown outfile format for file $file" );
		return;
    }
    return;
} # End of write_outfile


####################################################################
## write_xls
## write intermediate data to excel sheet
####################################################################
=head2 write_xls($$$;$$)

this subroutine is self explanatory. The only important thing is,
that it will try to rotate older versions of the generated sheets.
E.g. sheet CONN will become O0_CONN while O0_CONN was shifted
to O1_CONN. The maximum number of all versions to keep is
defined by $eh->get( 'intermediate.keep' )

=over 4

=item $file filename
=item $type sheetname (CONN|HIER)
=item $ref_a reference to array with data
=item $ref_c mark the cells listed in this array
=item $newold_flag  : set if we got a regular newold diff

=back

=cut

sub write_xls($$$;$$) {

    my $file = shift;
    my $sheet = shift;
    my $r_a = shift;
    my $r_c = shift || undef;
    my $newold_flag = shift || 0;

    if( $eh->get( 'iswin' ) or $eh->get( 'iscygwin' ) or $eh->get( 'format.out' ) ) {
		my $book;
		my $newflag = 0;
		my $openflag = 0;
		my $sheetr = undef;

		# Add extension automatically
		unless ( $file =~ m/\.xls$/ ) {
	    	$file .= '.xls';
		}

		# Was OLE already started?
		unless( $ex ) {
	    	$ex = init_ole();
	    	unless( $ex ) {
				$logger->error( '__E_OLE_INIT', "\tCannot initialize OLE, intermediate file $file will be written as CSV" );
				$file=~ s/\.xls$/\.csv/;
				return write_csv($file, $sheet, $r_a);
	    	}
	    	init_open_workbooks();
		}

		# Write to other directory ...
		if ( $eh->get( 'intermediate.path' ) ne '.'
			 and not is_absolute_path( $file ) ) {
	    			$file = $eh->get( 'intermediate.path' ) . '/' . $file;
		}

		my $efile = absolute_path( $file );
		my $basename = basename( $file );
		( my $wfile = $efile ) =~ s,/,\\,g; # Windows32 ....

		$ex->{DisplayAlerts}=0 if ( $eh->get( 'script.excel.alerts' ) =~ m,off,io );

		if ( -r $file ) {
	    	# If it exists, it could be open, too?
	    	unless( $book = is_open_workbook( $basename ) ) {
				# Has not been opened up to now
				$logger->warn('__I_FILE_OVERWRITE', "\tFile $file already exists! Contents will be changed");
				$book = $ex->Workbooks->Open($wfile); #Needs correct PATH ... / or \ ...
				new_workbook( $basename, $book );
	    	} else {
				# Is the open thing at the right place?
				my $wbpath = dirname( $file ) || $eh->get( 'cwd' );
				if ( $wbpath eq "." ) {
		    		$wbpath = $eh->get( 'cwd' );
				} elsif ( not is_absolute_path( $wbpath ) ) {
		    		$wbpath = $eh->get( 'cwd' ) . '/' . $wbpath;
				}

				$wbpath =~ s/$ENV{HOME}/$ENV{HOMEDRIVE}/ if ( $eh->get( 'iscygwin' ) );
				$wbpath =~ s,/,\\,g; # Replace / -> \
				#Does our book have the right path?
				if ( $book->Path ne $wbpath ) {
				# Sometimes (win32 and cygwin) the same path has different cases ->
					if ( $^O =~ m/mswin/io and lc( $book->Path ) ne lc ( $wbpath ) ) {
		    			$logger->error('__E_FILE_XLS', "\tWorkbook $basename with different path (" . $book->Path .
			    			") already opened!");
					}
				}
			}
			$book->Activate;

			#
			# rotate old versions of $sheet to O$n_$sheet_O ...
			#
			my %sh = ();
			my $s_previous = undef;

			foreach my $sh ( in( $book->{'Worksheets'} ) ) {
				$sh{$sh->{'Name'}} = $sh; # Keep links
			}

			if ( $eh->get( 'intermediate.keep' ) ) {

				# Rotate sheets ...
				# Delete eldest one:
				my $max = $eh->get( 'intermediate.keep' );
				$logger->info('__I_WRITE_XLS', "\tRotating $max old sheets of $sheet!");
				if ( exists( $sh{ "O_" . $max . "_" . $sheet } ) ) {
		    		$sh{"O_" . $max . "_" . $sheet}->Delete;
				}
				if ( $max >= 2 ) {
		    		for my $n ( reverse( 2..$max ) ) {
						if ( exists( $sh{ "O_" . ( $n - 1 ) . "_" . $sheet } ) ) {
			    			$sh{"O_" . ( $n - 1 ) . "_" . $sheet}->{'Name'} =
							"O_" . $n . "_" . $sheet;
						}
		    		}
				}
				# Finally: Rename the latest/greatest ...
				if ( exists( $sh{ $sheet } ) ) {
		    		$s_previous = $sh{$sheet};
		    		$sh{$sheet}->{'Name'} = "O_1_" . $sheet;
				}
				# Copy previous format ....
				if ( $eh->get( 'intermediate.format' ) =~ m,prev,o and
		     			defined( $s_previous ) ) {
		    		unless( $s_previous->Copy($s_previous) ) { # Add in new sheet before
						$logger->info('__I_WRITE_XLS', "\tCannot copy previous sheet for $sheet! Create new one.");
					} else {
						$sheetr = $book->ActiveSheet();
						$sheetr->Unprotect;
						$sheetr->UsedRange->{'Value'} = (); #Will that delete contents?
						$sheetr->{'Name'} = $sheet;
					}
				}
			} else { # Delete contents or all of sheet ?
				if ( exists( $sh{ $sheet } ) ) {
		    		#Keep format if $eh->intermediate.format says so
		    		if ( $eh->get( 'intermediate.format' ) =~ m,prev,o ) {
						$sheetr = $sh{$sheet};
						$sheetr->Unprotect;
						$sheetr->UsedRange->{'Value'} = (); # Overwrite all used cells ...
		    		} else {
						$sh{$sheet}->Delete;
		    		}
				}
	    	}
		} else {
	    	# Create new workbook
	    	$book = $ex->Workbooks->Add();
	    	$book->SaveAs($wfile);
	    	$newflag=1;
		}

		unless( defined( $sheetr ) ) {
	    	# Create output worksheet:
	    	if ( $sheetr = $book->Worksheets->Add() ) {
	    		$sheetr->{'Name'} = $sheet;
	    	} else {
	    		$logger->error( '__E_WRITE_XLS', "\tCannot create worksheet $sheet in $file: $!");
	    		return; # Leave here ...
	    	}
		}

		$sheetr->Activate();
		$sheetr->Unprotect;

		mix_utils_mask_excel( $r_a );

		my $x=$#{$r_a->[0]}+1;
		my $y=$#{$r_a}+1;
		my $c1=$sheetr->Cells(1,1)->Address;
		my $c2=$sheetr->Cells($y,$x)->Address;
		my $rng=$sheetr->Range($c1.":".$c2);
	
		#!wig20050713: protect against ExCEL failures:
		eval '$rng->{Value}=$r_a;';
		if ( $@ ) {
	    	$logger->error( '__E_WRITE_XLS', "\tCannot write ExCEL $file:$sheet: $@" );
	    	$ex->{DisplayAlerts}=1;
	    	return;
    	}

		# Mark cells in that list in background color ..
		# Format: row/col
		if ( defined( $r_c ) ) {
	    	$rng->Interior->{Color} = mix_utils_rgb( 255, 255, 255 ); # Set back color to white
	    	# Deselect ...
	    	for my $cell ( @$r_c ) {
				my $x; my $y;
				( $y , $x ) = split( '/', $cell );
				if ( $x =~ m,^\d+$, and $y =~ m,^\d+$, ) {
		    		# my $ca=$sheetr->Cells($y,$x)->Address;
		    		my $cn = chr( $x + 64 ) . ( $y - 1 ); #Hope that helps ...
		    		my $co = chr( $x + 64 ) . $y;
		    		my ( $ncol, $ocol );
		    		if ( $newold_flag ) { # three colors:
		    			# first column blue
		    			# "new" lines red, old lines green, only changes get marked
		    			if ( $x == 1 ) { # blue to first column
							$ncol = $ocol = mix_utils_rgb( 0, 0, 255 );
		    			} else {
							$ocol = mix_utils_rgb( 0, 255, 0 );
							$ncol = mix_utils_rgb( 255, 0, 0 );
		    			}
		    		} else { # Print all in red in non-newold mode
		    			$ocol = $ncol = mix_utils_rgb( 255, 0, 0 );
		    		}
		    		$rng= $sheetr->Range($cn) if $newold_flag;
		    		$rng->Interior->{Color} = $ncol if $newold_flag;
		    		$rng =$sheetr->Range($co);
		    		$rng->Interior->{Color} = $ocol;

		    		# White background with a solid border
		    		#
		    		# $Chart->PlotArea->Border->{LineStyle} = xlContinuous;
		    		# $Chart->PlotArea->Border->{Color} = RGB(0,0,0);
		    		# $Chart->PlotArea->Interior->{Color} = RGB(255,255,255);
		    		# $rng->{BackColor}=0;
		    		# example: $workSheet->Range("A1:A6")->Interior->{ColorIndex} =XX;
				}
	    	}
		}

		if ( $eh->get( 'intermediate.format' ) =~ m,auto, ) {
	    	$rng->Columns->AutoFit;
		}

		$book->SaveAs($wfile);

		$ex->{DisplayAlerts}=1;

		return;
    } else {
		$file=~ s/\.xls$/\.csv/;
    	return write_csv($file, $sheet, $r_a);
    }
}

####################################################################
## write_sxc
## write intermediate data to Star(/Open) Office sheet
####################################################################

=head2 write_sxc($$$;$)

this subroutine is self explanatory. The only important thing is,
that it will try to rotate older versions of the generated sheets.
E.g. sheet CONN will become O0_CONN while O0_CONN was shifted
to O1_CONN. The maximum number of all versions to keep is
defined by $eh->get( 'intermediate.keep' )

=over 4

=item $file filename
=item $type sheetname (CONN|HIER)
=item $ref_a reference to array with data
=item $ref_c mark the cells listed in this array

=back

=cut

sub write_sxc($$$;$) {
    my $file = shift;
    my $sheet = shift;
    my $r_a = shift;
    my $r_c = shift || undef;

    my @content = ();

    my %settings = ();

    $settings{'sheetname'} = $sheet;        # name of new sheet
    $settings{'fontsize'} = 10;             # font size
    $settings{'justify'} = "left";          # text orientation
    $settings{'textcolor'} = "000000";      # text color
    $settings{'textbgcolor'} = "FFFFFF";    # background color
    $settings{'newflag'} = 0;

    unless( useOoolib() ) {
		$logger->error( '__E_WRITE_SXC', "\tCannot initialze oolib to write out intermediate file $file!");
		return;
    }

    my $zip = Archive::Zip->new();

    # Write to other directory ...
    if ( $eh->get( 'intermediate.path' ) ne '.' and not is_absolute_path( $file ) ) {
		$file = $eh->get( 'intermediate.path' ) . '/' . $file;
    }

    my $basename = basename( $file ); # s,.*[/\\],,; #Strip off / and \

    if ( -r $file ) {
		$logger->info('__I_WRITE_SXC', "\tFile $file already exists! Contents will be changed");

		# unzip $file in $path
		unless($zip->read($file)==AZ_OK) {
	    	$logger->error( '__E_WRITE_SXC', "\tCannot open zip file $file! Skip!" );
	    	return undef;
		}
		# extract content.xml file from archive
		@content = readContent($zip);

    	# rotate old versions of $sheet to O$n_$sheet_O ...
		my $s_previous = undef;

		my $isheet = 0;
		my $sheetname = ();

		# keep start line index of all sheets
		for(my $i=0; defined $content[$i]; $i++) {
	    	if( !$isheet && $content[$i]=~ m/<table:table table:name=\"/) { # " start of sheet
				$isheet = 1;
				$sheetname = $content[$i];
				$sheetname =~ s/<table:table table:name=\"//;	# "
				$sheetname = (split(/\"/, $sheetname))[0];		# "
				$settings{$sheetname} = $i;
	    	} elsif( $isheet && $content[$i]=~ m/<\/table:table>/) { # end of sheet
				$isheet= 0;
				$settings{$sheetname . '_end'} = $i+1;
				$sheetname = '';
	    	}
		}
		undef $isheet;
		undef $sheetname;

		if ( $eh->get( 'intermediate.keep' ) ) {
	    	# Rotate sheets ...
	    	# Delete eldest one:
	    	my $max = $eh->get( 'intermediate.keep' );
	    	$logger->info( '__I_WRITE_SXC', "\tRotating $max old sheets of $sheet!");
	    	if ( exists( $settings{ 'O_' . $max . '_' . $sheet } ) ) {
				# remove sheet 
				my $length = $settings{"O_".$max."_".$sheet."_end"}-$settings{"O_".$max."_".$sheet};
				for(my $i=0; $i<$length; $i++) {
		    		delete $content[$settings{"O_".$max."_".$sheet}+$i];
				}
	    	}
	    	if ( $max >= 2 ) {
				for my $n ( reverse( 2..$max ) ) {
		    		if ( exists( $settings{ "O_" . ( $n - 1 ) . "_" . $sheet } ) ) {
					# set new name
						my $oldname = "O_".( $n - 1 )."_".$sheet;
						my $newname = "O_" . $n . "_" . $sheet;
						$content[$settings{"O_" . ( $n - 1 ) . "_" . $sheet}]=~ s/$oldname/$newname/;
		    		}
				}
	    	}

	    	# Finally: Rename the latest/greatest ...
	    	if ( exists $settings{$sheet} ) {
				$s_previous = $settings{$sheet};
				my $newname = 'O_1_' . $sheet;
	        	$content[$settings{$sheet}]=~ s/$sheet/$newname/;
				$settings{'start'} = $s_previous;
				$settings{'stop'} = $s_previous;
	    	} else {   # set position of new sheet
	        	my $end = getDocumentEnd(\@content);
				$settings{'start'} = $end;
				$settings{'stop'} = $end;
	    	}

	    	# keep previous format
	    	if( $eh->get( 'intermediate.format' )=~ m,prev,o && defined $s_previous) {
				$settings{'tabStyle'} = getStyle($content[$s_previous]);
	    	}

		} else { # Delete contents or all of sheet ?
	    	if ( exists( $settings{ $sheet } ) ) {
				#Keep format if $eh->intermediate.format says so
				if ( $eh->get( 'intermediate.format' ) =~ m,prev,o ) {
		    		# get style -> use same style for new sheet
		    		$settings{'tabStyle'} = getStyle($content[$settings{$sheet}]);
				}
				$settings{'start'} = $settings{$sheet};
				$settings{'stop'} = $settings{$sheet."_end"};
	    	} else {
	        	my $end = getDocumentEnd(\@content);
				$settings{'start'} = $end;
				$settings{'stop'} = $end;
	    	}
		}
    } else {
		# Create new workbook
		# no warnings;
		$^W = 0;
		#OLD: oooInit('sxc');
		my $doc = new ooolib('sxc');
		$doc->oooSet('builddir', '.');
		$doc->oooSet('author', 'generated by MIX');
		$doc->oooGenerate($file);    # write output (too early?)

		# ooolib('sxc');
		# oooSet('builddir', '.');
		# oooSet('author', 'generated by MIX');
		# oooGenerate($file);    # write output (too early?)

		# TODO : Replace the below listed parts ...
		# use warnings;
		$^W = 1;

		if ( -d 'META-INF' ) { rmdir('META-INF') };
		unless($zip->read($file)==AZ_OK) {
	    	$logger->error( '__E_WRITE_SXC', "\tCreating openoffice calc file $file!" );
	    	return undef;
		}

		@content = readContent($zip);

		my $ibody = 0;

		# keep position of start and stop tags
		for(my $i=0; defined $content[$i]; $i++) {
	    	if(!$ibody && !defined $settings{'start'} && $content[$i]=~ m/^<office:body>$/) {
				$ibody = 1;
				$settings{'start'} = $i+1;
	    	} elsif($ibody && !defined $settings{'stop'} && $content[$i]=~ m/^<\/office:body>$/) {
				$ibody = 0;
				$settings{'stop'} = $i;
	    	}
		}
		undef $ibody;

		$settings{'tabStyle'} = getStyle($content[$settings{'start'}]);
		$settings{'defRowStyle'} = " table:style-name=\"ro1\" ";
		#	$settings{'defCellStyle'} = ;
		$settings{'newflag'} = 1;
    }

    # remove old content file from archive
    $zip->removeMember('content.xml');

    # Mark cells in that list in background color ..
    # Format: row/col
    if ( defined( $r_c ) ) {

		#	$rng->setBackgroundColor( mix_utils_rgb( 255, 255, 255 )); # Set back color to white

=head1 OLD

# REFACTOR: remove wig20060306

#	for my $cell ( @$r_c ) {

# 	    my $x;
#	    my $y;
#	    ( $y , $x ) = split( '/', $cell );

#	    if ( $x =~ m,^\d+$, and $y =~ m,^\d+$, ) {

#		my ($ncol, $ocol);

#		if ( $x == 1 ) {
#		    $ncol = $ocol = mix_utils_rgb( 0, 0, 255 );
#		} else {
#		    $ocol = mix_utils_rgb(0, 255, 0);
#		    $ncol = mix_utils_rgb(255, 0, 0);
#		}

	#	$rng = $sheetr->getCellRangeByPosition( $x+64, $y-1);
	#	$rng->setBackgroundColor($ncol);

	#	$rng = $sheetr->getCellRangeByPosition( $x+64, $y);
	#	$rng->setBackgroundColor($ocol);
#	    }
#	}

=cut

    }

    unless( defined $settings{'tabStyle'}) {
        $settings{'tabStyle'} = '';
    }
    unless ( defined $settings{'defColStyle'}) {
        $settings{'defColStyle'} = '';
    }
    unless( defined $settings{'defRowStyle'}) {
        $settings{'defRowStyle'} = '';
    }
    unless( defined $settings{'defCellStyle'}) {
        $settings{'defCellStyle'} = '';
    }

    writeContent( $r_a, \%settings, \@content);

    $zip->addFile('content.xml');
#    $zip->writeToFileNamed($file);
    $zip->overwriteAs($file);
    unlink 'content.xml';
    rmdir('META-INF');
    return 1;
} # End of write_sxc

# use ooolib on demand, only!
#
# Load ooolib
#
# Returns:
#	1  		<= o.k.
#   undef	<= not o.k.
# Sets $ooo_flag to remember first try outcome
#
{ 
	my $ooo_flag = 0; #static, tells me if we used ooolib already ....
	sub useOoolib () {

    	return 1 if ( $ooo_flag eq 1 );
    	return undef if ( $ooo_flag eq -1 );
    	if ( eval 'use ooolib;' ){
			$logger->fatal( '__F_USE_OOOLIB',  "\tCannot load ooolib module: $@\n" );
			# REFACTOR : Check if this fatal dies here
			$ooo_flag = -1;
			return undef;
    	}
    	$ooo_flag = 1;
    	return 1;
	} # End of useOoolib
}

# get document end tags position
sub getDocumentEnd($) {
    my $content = shift;

    for my $i (reverse(1..scalar(@$content))) {
        if($$content[$i] && $$content[$i]=~ m/^<\/office:body>$/) {
        	return $i;
		}
    }
} # End of getDocumentEnd


# get style from openoffice xml tag
sub getStyle($) {

    my $style = shift;

    if( $style =~ s/^.* table:style-name="// ) {	# "
		$style =~ s/".*>$//;		# "
		return ' table:style-name="' . $style . '" ';
    }
    return '';
} # End of getStyle


sub getDefaultStyle($) {

    my $style = shift;

    $style =~ s/^.* table:default-cell-style-name="//; # "
    $style =~ s/".*>$//; 	# "

    return $style;
} # End of getDefaultStyle


# unzip content.xml and split tags
sub readContent ($) {
    my $zip = shift;
    my @content = ();

    # extract content.xml file from archive
    @content = split(/>/, $zip->contents('content.xml'));
    map ( { $_ .= '>'; } @content );

    return @content;
} # End of readContent


sub writeContent($$$) {
    my $data = shift;
    my $settings = shift;
    my $content = shift;

    unless( open(DATA, '> content.xml') ) {
    	$logger->error( '__E_WRITE_CONTENT', "\tCannot open content.xml" );
    	return undef();
    }

    # output new style definitions

    # output content before sheet
    for(my $i=0; $i<$settings->{'start'}; $i++) {
 		# TODO : if not newflag count existing sheetstyles & add new one
 		print DATA @$content[$i];
    }

    # output new sheet
    print DATA "<table:table table:name=\"" . $settings->{'sheetname'} . "\"" . $settings->{'tabStyle'} . ">";

    # TODO : output column styles
    print DATA "<table:table-column" . $settings->{'defColStyle'} . " table:number-columns-repeated=\"3\" table:default-cell-style-name=\"Default\"/>";

    my $xmax = $#{$data->[0]}+1;
    my $ymax = $#{$data}+1;

    # One row at a time
    for( my $y=0; $y<=$ymax; $y++) {
		# One cell at a time down the row
		print DATA "<table:table-row".$settings->{'defRowStyle'}.">";
		for( my $x=0; $x<=$xmax; $x++) {
	    	if(defined $$data[$y][$x]) {
	        	$$data[$y][$x]=~ s/\&/\&amp;/g;
				$$data[$y][$x] =~ s/'/\&apos;/g; #'
				$$data[$y][$x] =~ s/</\&lt;/g;
				$$data[$y][$x] =~ s/>/\&gt;/g;
				print DATA "<table:table-cell>";
				print DATA "<text:p>" . $$data[$y][$x] . "</text:p>";
				print DATA "</table:table-cell>";
	    	} else {
				print DATA "<table:table-cell/>";
	    	}
		}
		print DATA "</table:table-row>";
    }

    # end table
    print DATA "</table:table>";

    # output content behind sheet
    my $clength = scalar(@$content);
    for(my $i=$settings->{'stop'}; $i<$clength; $i++) {
        if(defined @$content[$i]) {
	    	print DATA @$content[$i];
		}
    }

    close(DATA);

    return;
} # End of writeContent


####################################################################
## write_csv
## write intermediate data to csv file
####################################################################
=head2 write_csv($$$;$)

this subroutine is self explanatory. The only important thing is,
that it will try to rotate older versions of the generated sheets.
E.g. sheet CONN will become O0_CONN while O0_CONN was shifted
to O1_CONN. The maximum number of all versions to keep is
defined by $eh->get( 'intermediate.keep' )

#!wig20050125: adding quoting style "MS-EXCEL":
    -cover newlines
    -mask quoting character  ;" "" ";  (duplicate!)
    -mask seperator (quotes!)

=over 4

=item $file filename
=item $type sheetname (CONN|HIER)
=item $ref_a reference to array with data
=item $ref_c marks cells holding differences (usefull for ExCEL!)

=back

=cut

sub write_csv ($$$;$) {
    my $file  = shift;
    my $sheet = shift;
    my $r_a   = shift;
	my $r_c   = shift || undef(); #TODO: add some marker text to diff cells!

    my @data = ();
    my $openflag = 0;

    my ($start, $stop) = (0,0);
    my $xmax = $#{$r_a->[0]}+1;
    my $ymax = $#{$r_a}+1;

    my $cellsep = $eh->get( 'format.csv.cellsep' );
    my $quoting = $eh->get( 'format.csv.quoting' );
    my $style   = $eh->get( 'format.csv.style' );
	my $sheetm  = $eh->get( 'format.csv.sheetsep' );
	
    my $temp;

    # Write to other directory ...
    if ( $eh->get( 'intermediate.path' ) ne '.' and not is_absolute_path( $file ) ) {
 		$file = $eh->get( 'intermediate.path' ) . '/' . $file;
    }

    my $basename = basename( $file ); # s,.*[/\\],,; #Strip off / and \

    if ( -r $file ) {

    	my $max = $eh->get( 'intermediate.keep' );
		my $temp;
		my $osheet = 0;

		# If it exist and $sheetm ist set, try to recover original contenst ...
		if ( $sheetm ) {
    		open(FILE, "<$file");
			binmode FILE;
			# binmode(FILE, ":utf8");
			@data = <FILE>;
			close(FILE);

			for(my $i=0; $i<scalar(@data); $i++) {
	    		if($osheet==0 && $data[$i]=~ m/^$sheetm$sheet\s*$/) {
					$osheet = 1;
					$start = $i;
					delete $data[$i];
	    		} elsif( $osheet==1) {
					if($data[$i]=~ m/^$sheetm/) {
		    			$osheet = 0;
		    			$stop = $i;
					} else {
		    			delete $data[$i];
					}
	    		}
			}

			if($stop==0) {
	    		$start = scalar @data;
	    		$stop = $start;
        	}
    	}
    }

    # To support \n without \r on MS-Win, open in binmode
    unless( open(FILE , "> $file") ) {
    	$logger->error( '__E_WRITE_CSV', "\tCannot open $file for writting: $!" );
    	return undef;
    }
    
    binmode FILE;
	#!wig: enable UFT8: binmode(FILE, ":utf8");

    my $cr = ( $eh->get( 'iswin' ) ? "\r" : '' ) . "\n";

    # Previous data
    for(my $i=0; $i<$start; $i++) {
        if(defined $data[$i]) {
	    	print FILE $data[$i];
		}
    }

	if ( $sheetm ) {
    	print FILE $sheetm . $sheet . "\n";
	} else {
		$logger->info('__I_WRITE_CSV', "\tStart printing sheet $sheet, no seperator selected!" );
	}

    for(my $y=0; $y<$ymax; $y++) {
        for(my $x=0; $x<$xmax; $x++) {
	    	if(defined $$r_a[$y][$x] and $$r_a[$y][$x] ne "" ) {
			# Classic style -> single lines, remove new-lines!
			#Print non-empty cells:
			#'style'      => 'doublequote,auto,wrapnl,maxwidth',  # controll the CSV output
			# doublequote: mask quoting char by duplication! Else mask with \
			# autoquote: only quote if required (embedded whitespace)
			# wrapnl: wrap embedded new-line to space
			# masknl: replace newline by \\n
	        $temp = $$r_a[$y][$x];
			if ( $style =~ m/\bclassic\b/i ) {
		    	$temp =~ s/$quoting/\\$quoting/g if $quoting;
				$temp =~ s/^\n+//;	# remove leading newline
		    	$temp =~ s/.\n+/ /sg; # replace linefeed by space
		    	$temp = $quoting . $temp . $quoting;
			} else {
		    	if ( $style =~ m/\b(wrap|strip)nl\b/i ) {
					$temp =~ s/\s*[\r\n]/ /og; # Shwallow newlines and <cr>
		    	} elsif ( $style =~ m/\bmasknl\b/i ) {
					$temp =~ s/\n/\\n/og; #What to do with leading/trailing tabs?
					$temp =~ s/\r/\\r/og;
		    	}
		    	if ( $style =~ m/\b(stripna)\b/o ) {
	    		# Replace all non ASCII (non printables!) by spaces
	    			$temp =~ s/[[:cntrl:]]/ /go;
	    		}
		    	# elsif ( $EH{iswin} ) {
		    	# $temp =~ s/\n/\r/g; # Make the internal new-line a simple "nl"
		    	# }
		    	if ( $style =~ m/\bdoublequote\b/i ) {
					$temp =~ s/$quoting/$quoting$quoting/go;
		    	}
		    	if ( $style =~ m/autoquote/i ) {
					if ( $temp =~ m/($cellsep|$quoting|\n)/ ) {
			    		$temp = $quoting . $temp . $quoting;
					}
		    	}
			}
			print FILE $temp;
	    }
	    unless($x+1==$xmax) {
	        print FILE $cellsep;
	    }
	}
	# End of this line: Add a ^M for MS-Windows ...
	print FILE ( $cr );
    }

    # Previous data
    for(my $i=$start; $i<$stop; $i++) {
        if(defined $data[$i]) {
	    	print FILE $data[$i];
		}
    }

    close(FILE);

    return;
}


####################################################################
## clean_temp_sheets
## remove temporary and old sheets from workbook
####################################################################

=head2 clean_temp_sheets($)

subroutine removes old and diff sheets from excel files

=over 4

=item $file filename

=back

=cut

sub clean_temp_sheets($) {

    my $file = shift;

    if($file=~ m/.xls/) {
        clean_xls_sheets($file);
    }
    elsif($file=~ m/.sxc/) {
        clean_sxc_sheets($file);
    }
    elsif($file=~ m/.csv/) {
        clean_csv_sheets($file);
    }
}


####################################################################
## clean_temp_sheets
## remove temporary and old sheets from workbook
####################################################################
=head2 clean_excel_sheets($)

clean_excel_sheets () {

subroutine removes old and diff sheets from excel files

=over 4

=item $file filename

=back

=cut

sub clean_xls_sheets($) {

    my $file = shift;
    my $book;

    $logger->info('__I_CLEAN_XLS', "\tRemoving old and and diff sheets in file: $file");

    if( -r $file ) {

		my $basename = basename( $file ); # s,.*[/\\],,; #Strip off / and \

		# If it exists, it could be open, too?
		unless( $book = is_open_workbook( $basename ) ) {
	    	# No, not opened so far...
			if($file =~ m/.xls$/) {
				$book = $ex->Workbooks->Open(cwd() . "\\" . $file);
			}
		} else {
	    	# Is the open thing at the right place?
	    	my $wbpath = dirname( $file ) || $eh->get( 'cwd' );
	    	if ( $wbpath eq "." ) {
	        	$wbpath = $eh->get( 'cwd' );
	    	}
	    	$wbpath =~ s,/,\\,g; # Replace / -> \
	    	#Does our book have the right path?
	    	if ( defined $ex && $book->Path ne $wbpath) {
	        	$logger->error('__E_CLEAN_XLS', "\tWorkbook with different path already opened!");
	    	}
  		}

		my %sh = ();

		$ex->{DisplayAlerts}=0 if ( $eh->get( 'script.excel.alerts' ) =~ m,off,io );
		$book->Activate;

		# search for old sheets end remove them: O_ DIFF_ SheetN
		foreach my $sh (in( $book->{'Worksheets'} ) ) {
	    	if ( $sh->{'Name'} =~ /^O_/o or
				$sh->{'Name'} =~ /DIFF_/o or
				$sh->{'Name'} =~ /^Sheet\d+/o or
				$sh->{'Name'} =~ /^Tabelle\d+/o ) {
	        	$book->{Worksheets}->{$sh->{'Name'}}->Delete;
	    	}
        }
		$book->Save;
		$ex->{DisplayAlerts}=1;

		return;
    }

    $logger->warn('__W_CLEAN_XLS', "\tFile $file not found!");
    return;
} # End of clean_xls_sheets


####################################################################
## clean_soffice_sheets
## remove temporary and old sheets from workbook
####################################################################
=head2 clean_temp_sheets($)

clean_soffice_sheets () {

subroutine removes old and diff sheets from soffice files

=over 4

=item $file filename

=back

=cut

sub clean_sxc_sheets($) {
    my $file = shift;

    $logger->info('__I_CLEAN_SXC', "\tRemoving old and and diff sheets in file: $file");

    if( -r $file ) {

        my $zip = Archive::Zip->new();
		my $isheet = 0;
		my $sheetname = ();

        # unzip $file in $path
        unless($zip->read($file)==AZ_OK) {
	    	$logger->error( '__E_CLEAN_SXC', "\tCannot open zip file $file: $!" );
	    	return undef;
		}
		# extract content.xml file from archive
		my @content = readContent($zip);

		# keep start line index of all sheets
		for(my $i=0; defined $content[$i]; $i++) {
	    	if( not $isheet && $content[$i]=~ m/<table:table table:name=\"/) { #" start of sheet
				$sheetname = $content[$i];
				$sheetname =~ s/<table:table table:name=\"//;	#"
				$sheetname = (split(/\"/,$sheetname))[0];	#"
				if( $sheetname=~ m/^O_/ || $sheetname=~ m/DIFF_/) {
		  			$isheet = 1;
		  			delete $content[$i];
				}
	    	} elsif( $isheet) { # end of sheet
	        	if( $content[$i]=~ m/<\/table:table>/) {
		    		$isheet= 0;
				}
				delete $content[$i];
	    	}
		}

		unless( open(DATA,'> content.xml') ) {
			$logger->error('__E_CLEAN_SXC', "\tCannot open content.xml: $!" );
			return undef();
		}

		for my $i (0..scalar(@content)-1) {
	    	if(defined $content[$i]) {
	        	print DATA $content[$i];
	    	}
		}
		close(DATA) or $logger->error('__E_CLEAN_SXC', "\tCannot close content.xml: $!" );

		$zip->addFile('content.xml');
		$zip->overwriteAs($file);
		unlink( 'content.xml' ) or $logger->error( '__E_CLEAN_SXC', "\tCannot unling content.xml: $!" );

		return;
    }

    $logger->warn('__W_CLEAN_SXC', "\tFile $file not found!");
    return;
} # End of clean_sxc_sheets


####################################################################
## clean_csv_sheets
## remove temporary and old sheets from workbook
####################################################################
=head2 clean_csv_sheets($)

clean_temp_sheets () {

subroutine removes old and diff sheets from csv files

=over 4

=item $file filename

=back

=cut

sub clean_csv_sheets($) {
    my $file = shift;
    my $book;

    $logger->info( '__I_CLEAN_CSV', "\tRemoving old and and diff sheets in file: $file");

    if( -r $file ) {
		my $basename = basename( $file ); # s,.*[/\\],,; #Strip off / and \
		my @data;

		my $sheetO = $eh->get( 'format.csv.sheetsep' ) . 'O_';
		my $sheetDiff = $eh->get( 'format.csv.sheetsep' ) . 'DIFF_';

		my $itable = 1;

		# Read in previous content
		unless( open(FILE,"< $file") ) {
			$logger->error( '__E_CLEAN_CSV', "\tCannot open file $file: $!" );
			return undef();
		}
		@data = <FILE>;
		close(FILE) or $logger->error( '__E_CLEAN_CSV', "\tCannot close file $file: $!" );

		unless( open(FILE, "> $file") ) {
			$logger->error( '__E_CLEAN_CSV', "\tCannot open file $file for writting: $!" );
			return undef();
		}

		# search for old sheets end remove them
		my $max = scalar(@data);
		for(my $i=0; $i<$max; $i++) {
	    	if( $itable==1) {
	        	if( $data[$i] =~ /^$sheetO/ || $data[$i] =~ /^$sheetDiff/) {
		    		$itable = 0;
	        	} else {
		    		print FILE $data[$i];
				}
	    	} else {
	      		if( not($data[$i] =~ /^$sheetO/ || $data[$i] =~ /$sheetDiff/)) {
		  			$itable = 1;
		  			print FILE $data[$i];
	      		}
	    	}
        }
		close(FILE) or $logger->error( '__E_CLEAN_CSV', "\tCannot close file $file: $!" );

		return;
    }

    $logger->warn('__E_CLEAN_CSV', "\tFile $file not found!");
    return;
} # End of clean_csv_sheets


####################################################################
## mix_utils_rgb
## Convert RGB value to internal representation
####################################################################
=head2 mix_utils_rgb($$$)

Convert RGB value to internal representation

=over 4

=item red
=item blue
=item green

=back

=cut

sub mix_utils_rgb($$$) {
    return ( $_[0] | ($_[1] << 8) | ($_[2] << 16) );
}


####################################################################
## mix_utils_mask_excel
## Mask pure digits (esp. with . and/or , inside) for ExCEL!
## Otherwise these will get converted to dates :-(
## wig20030716: add a ' before a trailing ' ...
##!wig20050713: limit length of EXCEL cells to $eh->get('format.xls.maxcelllength')
####################################################################

=head2 mix_utils_mask_excel($)

Mask pure digits (esp. with . and/or , inside) for ExCEL!
Otherwise these will get converted to dates :-(

Additionally mask <nl> ...

=cut

sub mix_utils_mask_excel($) {
    my $r_a = shift;

	my $maxlength = $eh->get( 'format.xls.maxcelllength' ) + 20; # Leave 20bytes extra
	my $style = $eh->get( 'format.xls.style' ) || '';
	
    for my $i ( @$r_a ) {
		for my $ii ( @$i ) {
	    	unless( defined( $ii ) ) {
				$ii = '';
				next;
	    	} elsif ( length( $ii ) > $maxlength ) { #!wig20031215: 1200 will be accepted by Excel
				$logger->warn( '__W_MASK_XLS', "\tLimit length of cell to save $maxlength characters: " .
				substr( $ii, 0, 32 ) );
				$ii = substr( $ii, 0, $maxlength );
				substr( $ii, $maxlength - 9 , 9 ) = "__ERROR__"; # Attach __ERROR__ to string!
	    	}
	    	if ( $style =~ m/\b(wrap|strip)nl\b/o ) {
	    		# Replace \n by spaces
	    		$ii =~ s/[\n\r]+/ /go;
	    	} elsif ( $style =~ m/\b(masknl)\b/o ) {
	    		$ii =~ s/\n/\\n/go;
	    		$ii =~ s/\r/\\r/go;
	    	}
	    	if ( $style =~ m/\b(stripna)\b/o ) {
	    		# Replace all non ASCII (non printables!) by spaces
	    		$ii =~ s/[[:cntrl:]]/ /go;
	    	}
	    	
	    	$ii = "'" . $ii if ( $ii =~ m!^\s*[.,='"\d]! ); # Put a 'tick' in front of ExCEL special character  ....
		}
    }
} # End of mix_utils_mask_excel


# return 1
1;

#__END__

