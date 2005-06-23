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
# | Revision:   $Revision: 1.21 $                                          |
# | Author:     $Author: wig $                                         |
# | Date:       $Date: 2005/06/23 13:14:42 $                              |
# |                                                                       |
# | Copyright Micronas GmbH, 2002                                         |
# |                                                                       |
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# | Changes:                                                              |
# | $Log: IO.pm,v $
# | Revision 1.21  2005/06/23 13:14:42  wig
# | Update repository, not yet verified
# |
# | Revision 1.20  2005/04/14 06:53:01  wig
# | Updates: fixed import errors and adjusted I2C parser
# |
# | Revision 1.19  2005/01/31 12:40:36  wig
# |
# |  	IO.pm : minor corrections
# |
# | Revision 1.18  2005/01/26 14:01:46  wig
# | changed %OPEN% and -autoquote for cvs output
# |
# | Revision 1.17  2004/08/02 07:16:02  wig
# | Handle empty sheets ...
# |
# | Revision 1.16  2004/06/29 09:13:37  wig
# | minor fiexes /test mode
# |
# | Revision 1.15  2004/04/14 11:08:34  wig
# | minor code clearing
# |
# | Revision 1.14  2004/04/07 15:13:10  wig
# | Modified Files:
# | 	IO.pm : fixed delta mode xls on Solaris issue
# |
# | Revision 1.13  2004/03/25 11:21:57  wig
# | Added -verifyentity option
# |
# | Revision 1.12  2004/02/16 15:36:09  abauer
# | *** empty log message ***
# |
# | Revision 1.11  2003/12/22 08:33:30  wig
# | Added output.generate.xinout feature
# |
# | Revision 1.10  2003/12/18 16:49:45  wig
# | added OLE support
# |
# | Revision 1.9  2003/12/16 12:36:46  abauer
# | fixed csv: backslash before quota in cell
# |
# | Revision 1.8  2003/12/10 14:37:17  abauer
# | *** empty log message ***
# |
# | Revision 1.7  2003/12/10 10:17:33  abauer
# | *** empty log message ***
# |
# | Revision 1.6  2003/12/04 14:56:37  abauer
# | *** empty log message ***
# |
# | Revision 1.5  2003/12/03 14:14:47  abauer
# | *** empty log message ***
# |
# | Revision 1.4  2003/12/03 14:10:06  abauer
# | fixed overwrite of old csv-sheets
# |
# | Revision 1.3  2003/11/27 13:18:47  abauer
# | *** empty log message ***
# |
# | Revision 1.2  2003/11/27 10:46:56  abauer
# | *** empty log message ***
# |
# | Revision 1.1  2003/11/27 09:20:21  abauer                             |
# | *** empty log message ***                                             |
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
	write_sum
	clean_temp_sheets
        );

@EXPORT_OK = qw();


our $VERSION = '1.0';

use strict;
# use vars qw( $ex ); # Gets OLE object

=head 4 old

# Caveat: relies on proper setting of base, pgmpath and dir in main program!
use lib "$main::base/";
use lib "$main::base/lib/perl";
use lib "$main::pgmpath/";
use lib "$main::pgmpath/lib/perl";
use lib "$main::dir/lib/perl";
use lib "$main::dir/../lib/perl";

=cut

use Cwd;
use File::Basename;
use Log::Agent;
use Text::Diff;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use Micronas::MixUtils qw(:DEFAULT %OPTVAL %EH replace_mac convert_in
			  select_variant two2one one2two);

#TODO: Load these only if required ...
# use ooolib;   -> Loaded on demand, only!
use Spreadsheet::ParseExcel;
#use Spreadsheet::WriteExcel;


# Prototypes
sub close_open_workbooks();
sub write_delta_sheet ($$$);
sub _mix_apply_conf ($$$);
sub mix_utils_open_input(@);
sub close_open_workbooks ();
sub mix_utils_mask_excel ($);
sub absolute_path ($);
sub useOoolib ();

#
# RCS Id, to be put into output templates
#
my $thisid          =      '$Id: IO.pm,v 1.21 2005/06/23 13:14:42 wig Exp $';
my $thisrcsfile	    =      '$RCSfile: IO.pm,v $';
my $thisrevision    =      '$Revision: 1.21 $';

# Revision:   $Revision: 1.21 $
$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?


my $ex = undef;

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

    # unless( defined $ex ) {
    #	$ex = init_ole();
    # }
    if(defined $ex) {
	foreach my $bk ( in( $ex->{'Workbooks'}) ) {
	    $workbooks{$bk->{'Name'}} = $bk; # Remember that
	}
    } else {
	logwarn( "ERROR: Uninitialized OLE! Cannot read/write XLS files" );
	    $EH{'sum'}{'errors'}++;
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
	        $newbooks{$i}->Close or logwarn "ERROR: Cannot close $i workbook";
	    }
        }
    }


}   # end block (local workbooks)
###### extra block end


##############################################################################
## init_ole
## take CONF sheet  contents and transfer that into %EH (overloading values there)
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
        $Win32::OLE::Warn = 3;';
	if ( $@ ) {
	    logdie "FATAL: eval use Win32 failed: $@";
        }

	# no strict; # Switch off strict here ...

	$ex = undef;
        unless( $ex=Win32::OLE->GetActiveObject('Excel.Application') ) {
	# Try to start a new OLE server:
	    unless ( $ex=Win32::OLE->new('Excel.Application', 'Quit' ) ) {
		logdie "FATAL: Cannot get excel aplication: $!\n";
		return undef; # Did not work ...
	    }
	}
	# init_open_workbooks();
	return $ex;
    } else {
	logdie "FATAL: Cannot fire up OLE server, use Win32::OLE: $@\n";
	return undef;
    }
}

##############################################################################
## mix_sheet_conf
## take CONF sheet  contents and transfer that into %EH (overloading values there)
##############################################################################

=head2 mix_sheet_conf( $rconf, $source)

Take array provided by the mix_utils_open_input function (excel, soffice or csv), search for
the MIXCFG tag. If found, convert that into %EH.

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
	    if ( $i->[$j] eq "MIXCFG" ) { #Try to read $ii+1 and $ii+2
		my $key = $i->[$j+1] || '__E_ERROR.EXCEL_CONF.KEY';
		my $val = $i->[$j+2] || '__E_ERROR.EXCEL_CONF.VALUE';
		_mix_apply_conf( $key, $val, "EXCEL:$s" ); #Apply key/value
		next ROW;
	    } else { # If row does not have MIXCFG in first cell, skip it.
		next ROW;
	    }
	}
    }
}


#############################################################################
## _mix_apply_conf
## Similiar to MixUtils::mix_overload_conf!!
#############################################################################
=head2 _mix_apply_conf($$$)

apply configuration

=over 4
=item $key Key
=item $value Value
=item $source Source

=back

=cut

sub _mix_apply_conf($$$) {
    my $key = shift; # Key
    my $value = shift; # Value
    my $source = shift; # Source

    unless( $key and $value ) {
	    unless( $key ) { $key = ""; }
	    unless( $value ) { $value = ""; }
	    logwarn("Illegal key or value given in $source: key:$key val:$value\n");
	    return undef;
    }
    my $loga ='logtrc( "INFO", "Adding ' . $source . ' configuration ' . $key . "=" . $value . '");';
    my $logo ='logtrc( "INFO", "Overloading ' . $source . 'configuration ' . $key . "=" . $value . '");';
    $key =~ s,[^.%\w],,g; # Remove all characters not being ., % and \w ...
    $key =~ s/\./'}{'/og;
    $key = '{\'' . $key . '\'}';

    #TODO: Prevent overloading of non-scalar values!!
    my $e = "if ( exists( \$EH$key ) ) { \$EH$key = '$value'; $logo } else { \$EH$key = '$value'; $loga }";
    unless ( eval $e ) {
	    if ( $@ ) { # S.th. went wrong??
	        logwarn("Eval of configuration overload from $source $key=$value failed: $@");
	    }
    }
}


##############################################################################
## mix_overload_sheet
##
## take -sheet SHEET=MATCH_OP and transfer that into %EH (overloading values there)
##############################################################################
=head2 mix_overload_sheet($)

Started if option -sheet SHEET=match_op is given on command line. SHEET can be one of
<I hier>, <I conn>, <I vi2c> or <I conf>

=over 4

=item $sheets worksheets to process

=back
=over2

= item -sheet SHEET=match_op

Replace the default match operator for the sheet type. match_op can be any perl
regular expression.match_op shoud match the sheet names of the design descriptions.

=back

=cut

sub mix_overload_sheet($) {
    my $sheets = shift;

    my $e = "";
    my ( $key, $value );

    # %EH = ...
    #		'vi2c' => {
    #		'xls' => 'VI2C', ...

    for my $i ( @$sheets ) {
	( $key, $value ) = split( /=/, $i ); # Split key=value
	unless( $key and $value ) {
	    logwarn("Illegal argument for overload sheet given: $i\n");
	    next;
	}

	$key = lc( $key ); # $k := conn, hier, vi2c, conf, ...

	if ( exists( $EH{$key}{'xls'} ) ) {
	    logtrc( "INFO", "Overloading sheet match $i");
	    $EH{$key}{'xls'} = $value;
	} else {
	    logwarn( "Illegal sheet selector $key found in $i\n" );
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
	    	logwarn("WARNING: File $i does not exist!");
	    	$EH{'sum'}{'warnings'}++;
	    	next;
		}

		my @conf;
		my @conn;
		my @hier;
		my @io;
		my @i2c;

		# maybe there is a CONF page?
		# Change CONF accordingly (will not be visible at upper world)
		#TODO: add plugin interface to read in whatever is needed ...
		@conf = open_infile( $i, $EH{'conf'}{'xls'}, $EH{'conf'}{'req'} );

		# Open connectivity sheet(s)
		@conn = open_infile( $i, $EH{'conn'}{'xls'}, $EH{'conf'}{'req'} );
		# check and reset multiple fields ...
		# mix_utils_check_input_desc('conn');
		# Open hierachy sheets
		@hier = open_infile( $i, $EH{'hier'}{'xls'}, $EH{'conf'}{'req'} );
		# check and reset multiple fields ...
		# mix_utils_check_input_desc('hier');
		# Open IO sheet (if available, not needed!)
		@io = open_infile( $i, $EH{'io'}{'xls'}, $EH{'conf'}{'req'} );
		# check and reset multiple fields ...
		# mix_utils_check_input_desc('io');
		# Open I2C sheet (if available, not needed!)
		@i2c = open_infile( $i, $EH{'i2c'}{'xls'}, $EH{'conf'}{'req'} );
		# check and reset multiple fields ...
		# mix_utils_check_input_desc('i2c');

#
# reset muliple field counter
# check if we got the same number of fields as before
#

=head 2

sub mix_utils_check_input_desc ($) {
	my $name = shift;
	
	if ( $EH{$name}{'fields'}{'_mult_'} ) {
		# Have been here before!
		for my $k ( keys( %{$EH{$name}{'fields'}{'_mult_'}} ) ) {
			
}	

=cut

		if(!@conn && !@conf && !@hier && !@io && !@i2c) {
	    	logwarn("ERROR: no input found in file $i!\n");
	    	$EH{'sum'}{'errors'}++;
	    	next; # -> skip to next
		}

		for my $c ( @conf ) {
	    	$EH{'conf'}{'parsed'}++;
	    	# Apply it immediately
	    	mix_sheet_conf( $c, $EH{'conf'}{'xls'} );
		}

		for my $c ( @conn ) {
	    	$EH{'conn'}{'parsed'}++;
 	    	my @norm_conn = convert_in( "conn", $c ); # Normalize and read in
	    	push( @$aconn, @norm_conn ); # Append
		}

		for my $c ( @hier ) {
	    	$EH{'hier'}{'parsed'}++;
	    	my @norm_hier = convert_in( "hier", $c );
 	    	# Remove all lines not selected by our variant
	    	#TODO: Should we allow variants in the CONN sheet, too??
	    	select_variant( \@norm_hier );
	    	push( @$ahier,   @norm_hier );	# Append
		}

		for my $c ( @io ) {
	    	$EH{'io'}{'parsed'}++;
	    	my @norm_io = convert_in( "io", $c );
	    	push( @$aio,   @norm_io );   # Append
		}

		for my $c ( @i2c ) {
	    	$EH{'i2c'}{'parsed'}++;
	    	my @norm_i2c = convert_in( "i2c", $c);
	    	select_variant( \@norm_i2c);
	    	push(@$ai2c, @norm_i2c);
		}
    }

	mix_utils_io_del_abook(); # Remove all cached input data (only for excel currently),    
    return( $aconn, $ahier, $aio, $ai2c);
}


####################################################################
## open_infile
## maps call to correct open function
####################################################################
=head2 open_infile($$$)

maps a call to correct open function

=over 4
=item $filename name of file
=item $sheet name of worksheet
=item $flag flags

=back

=cut

sub open_infile($$$){

    my $file = shift;
    my $sheetname = shift;
    my $flags = shift;

    if($file=~ m/\.xls/) { # read excel file
        return open_xls($file, $sheetname, $flags);
    }
    elsif($file=~ m/\.sxc/) { # read soffice file
        return open_sxc($file, $sheetname, $flags);
    }
    elsif($file=~ m/\.csv/) { # read comma seperated values
        return open_csv($file, $sheetname, $flags);
    }
    else {
        logwarn "ERROR: Unknown file extension!\n";
	$EH{'sum'}{'errors'}++;
	return undef;
    }
}


####################################################################
## open_xls
## open excel file and get contents
####################################################################
=head2 open_xls($$$)

Open a excel file, select the appropriate worksheets and return

=over 4
=item $filename name of file
=item $sheet name of worksheet
=item $flag flags

=back

=cut

{   # wrap around $oBook static variable ...
	# Cache openeded xls-file
	my %aBook        = (); # xls-content
	
sub open_xls($$$){
    my ($file, $sheetname, $warn_flag)=@_;

    my $openflag = 0;
    my $isheet;
    my $oBook;

    my @sheets = ();

    #old: logdie "Cannot use Excel OLE interface!" unless($use_csv);
	#    $ex->{DisplayAlerts}=0 if ( $EH{'script'}{'excel'}{'alerts'} =~ m,off,io );

    unless( -r $file ) {
      logwarn( "cannot read <$file> in open_xls!" );
      $EH{'sum'}{'warnings'}++;
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
	
    if(!defined $oBook) {
      logwarn("ERROR: opening File $file");
    }

    # Take all sheets matching the possible reg ex in $sheetname
    for(my $i=0; $i < $oBook->{SheetCount} ; $i++) {
        $isheet = $oBook->{Worksheet}[$i];
	if ( $isheet->{Name} =~ m/^$sheetname$/ ) {
		push( @sheets, $i );
        }
    }

    # return if no sheets where found
    if ( scalar( @sheets ) < 1 ) {
	if ( $warn_flag =~ m,mandatory,io ) {
	    logwarn("Cannot locate a worksheet $sheetname in $file");
	    $EH{'sum'}{'warnings'}++;
	}
	return ();
    }

    my $cell = "";
    my @line = ();
    my @sheet = ();
    my @all = ();

    foreach my $sname ( @sheets ) {

	$isheet = $oBook->{Worksheet}[$sname];
	logtrc( "INFO:4", "Reading worksheet " . $isheet->{Name} . " of $file" );

        for(my $y=$isheet->{MinRow}; defined $isheet->{MaxRow} && $y <= $isheet->{MaxRow}; $y++) {
            for(my $x =$isheet->{MinCol}; defined $isheet->{MaxCol} && $x <= $isheet->{MaxCol}; $x++) {
                $cell = $isheet->{Cells}[$y][$x];
		if(defined $cell) {
		  push(@line, $cell->Value);  # $cell->Value || $cell->{Val} ?
		}
		else {
		  push(@line, "");
		}
            }
	    push(@sheet, [@line]);
	    # print "Line ". (scalar(@sheet)-1) . ": ";
	    # print join(' ; ', @line) ."\n";
	    @line = ();
        }
	#!wig20031218: take away trainling empty lines ...
	if ( scalar( @sheet ) > 0 ) {
	    while( not join( "", @{$sheet[-1]} ) ) {
		pop( @sheet );
	    }
	}
	if ( scalar( @sheet ) > 0 ) {
	    push(@all, [@sheet]);
	} else {
	    logwarn( "Sheet $isheet->{Name} holds no content (__FILE__/__LINE__)" );
	    $EH{'sum'}{'warnings'}++;
	}

	@sheet = ();
    }

    return(@all);

}

sub mix_utils_io_del_abook () {
	%aBook = ();
} 

} # wrap around $aBook, static variable

####################################################################
## open_sxc
## open star(/open) office file, parse content and return it
####################################################################
=head2 open_sxc($$$)

Open a Star-Office calculator file, select the appropriate
worksheets and return

=over 4
=item $filename name of file
=item $sheet name of worksheet_
=item $flag flags

=back

=cut

sub open_sxc($$$) {
    my ($file, $sheetname, $warn_flag)=@_;
    my $openflag = 0;

    unless(-r $file) {
	logwarn "ERROR: file $file not found!\n";
	return undef;
    }
    unless(defined $sheetname) {
        logwarn "ERROR: no sheet defined!\n";
	return undef;
    }

    # unzip $file in $path
    my $zip = Archive::Zip->new();
    unless($zip->read($file)==AZ_OK) {
	logwarn "ERROR: can't open zip file $file!\n";
	return undef;
    }
    # extract content.xml file from archive
    my @content = readContent($zip);

    if(!defined $content[0]) {
	logwarn "ERROR: no content found!\n";
	return undef;
    }

    my @all = ();
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
      if(!$isheet && $content[$i]=~ m/^<table:table.*>/ 
	 && $content[$i]=~ m/ table:name=\"$sheetname\"/) {
	    $isheet = 1;  # entering sheet
	}
	elsif($isheet) {
	    if($content[$i] =~ m/^<\/table:table>/) {
	        $isheet = 0;  # escape from sheet
		push(@all, [@sheet]);
		@sheet = ();
	    }
	    elsif(!$irow && $content[$i] =~ m/^<table:table-row/) {
		if(!($content[$i]=~ m/\/>$/)) {
		    $irow = 1;  # entering row
		}
	    }
	    elsif($irow) {
	        if($content[$i]=~ m/^<\/table:table-row>/) {
		    $irow = 0;       # escape row
		    # strip empty cells from row
		    if( $maxcells < scalar(@line)) {
			if(join(" ", @line)=~ m/^::.*/) {
			    while( !($line[-1]=~ m/^::.*$/)) {
				pop @line;
			    }
			    $maxcells = scalar(@line);
			}
			else {
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
		    if($temp=~ s/^.* table:number-columns-repeated=\"//) {
			$temp =~ s/\".*//g;
			$repeat = $temp;
		    }
		    # empty cell
		    if($content[$i]=~ m/<table:table-cell.*\/>/) {
			$icell = 0;    # escape from cell
			for(my $j=0; $j<$repeat; $j++) {
			    push(@line, "");
			}
		    }
		}
		elsif($icell) {
		    # text entry
		    if($content[$i]=~ m/<\/table:table-cell>/) {
			$icell = 0;
			my $temp = join(" ", @cell);
			for my $j (0..$repeat-1) {
			    push(@line, $temp);
			}
			@cell = ();
		    }
		    elsif($content[$i]=~ m/<office:annotation.*/) {
			# skip annotation (not of interrest)
			do{
			    $i++;
			} while(not $content[$i]=~ m/<\/office:annotation>/);
		    }
		    elsif(!$itext && $content[$i]=~ m/<text:p>/) {
			# beginning of text entry
			$itext = 1;
		    }
		    elsif($itext) {
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
    if ( scalar( @all ) < 1 ) {
	if ( $warn_flag =~ m,mandatory,io ) {
	    logwarn("Cannot locate a worksheet $sheetname in $file");
	    $EH{'sum'}{'warnings'}++;
	}
	return ();
    }
    return @all;
}


####################################################################
## open_csv
## open csv file and get contents
####################################################################
=head2 open_csv($$$)

Open a csv file, select the appropriate worksheets and return

=over 4
=item $filename name of file
=item $sheet name of worksheet
=item $flag flags

=back

=cut

sub open_csv($$$) {

    my ($file, $sheetname, $warn_flag)=@_;
    my $openflag = 0;

    my @all = ();
    my @sheet = ();
    my @line = ();

    my $sheetCount = 0;
    my $sheetsep = $EH{'format'}{'csv'}{'sheetsep'};
    my $cellsep = $EH{'format'}{'csv'}{'cellsep'};
    my $quoting = $EH{'format'}{'csv'}{'quoting'};

    my $quoted = 0;
    my $char;
    my $lastchar = "";
    my $entry = "";

    unless( -r $file ) {
        logwarn( "cannot read <$file> in open_csv!" );
	return undef;
    }

    my $ro = 1;

    if ( $warn_flag =~ m,write,io or $OPTVAL{'import'} or $OPTVAL{'init'} ) {
	$ro = 0;
    }

    open(FILE, $file);
    my @input = <FILE>;
    close(FILE);

    # Take all sheets matching the possible reg ex in $sheetname

    for(my $i=0; defined $input[$i]; $i++) {
	if( $input[$i] =~ m/^$sheetsep$sheetname/) {

	    $i++;
#	     print "SHEET: $sheetname\n";

            while( defined $input[$i] && not $input[$i]=~ m/^$sheetsep/) {

		for( my $j=0; $j<length($input[$i]); $j++) {

		    $char=substr($input[$i], $j, 1);

		    if( $quoted) {
		      # inside quotas
		        if( $char=~ m/^$quoting$/) {
			    if( $lastchar=~ m/^\\$/) {
			      # quoting character isn't a control sequence
				$entry = $entry . $char;
			    }
			    else {
			      # leave quoting
			        $quoted = 0;
			    }
		        }
			else {
			  # character inside quotas
			    if($char=~ m/^\n$/) { 
				$entry = $entry . " ";
			    }
			    elsif($char!~ m/^\\$/) {
				if($lastchar eq "\\") {
				    $entry = $entry . "\\";
				}
				$entry = $entry . $char;
			    }
			}
		    }
		    else {
		      # outside quotas
		        if( $char=~ m/^$cellsep$/) {
			  # entry complete
			    push(@line, $entry);
			    $entry = "";
			}
			elsif( $char=~ m/^$quoting$/) {
			  # enter quotas
			    $quoted = 1;
			}
		    }
		    $lastchar = $char;
		}
		# push last entry and push whole line
		push(@line, $entry);
		$entry = "";
		push(@sheet, [@line]);
	#	 print join(' ; ', @line) . "\n";
		@line = ();
		$i++;    # next line
	    }
	    push(@all, [@sheet]);
	    @sheet = ();
	}
    }

    # did we get some input?
    if ( scalar @all < 1 ) {
	if ( $warn_flag =~ m,mandatory,io ) {
            logwarn("Cannot read input from sheet: $sheetname in $file");
	    $EH{'sum'}{'warnings'}++;
	}
	return ();
    }

    return(@all );

}


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

    if ( $^O =~ m,win32,io ) {
	if ( $file =~ m,^[\\/], ) {
	    # Missing the letter for a drive
	    $file = $EH{'drive'} . $file;
	} elsif ( $file !~ m,^\w:, ) {
	    $file = $EH{'cwd'} . "/" . $file;
	}
	# $file =~ s,/,\\,go; #
    } elsif ( $file !~ m,^/, ) { # Does not start with /
	$file = $EH{'cwd'} . "/" . $file;
    }

    # Now done in different place ...
    # Convert / to \ :-(, otherwise OLE will get confused
    # As we will open Excel on MSWin only, there is no need to rethink that.
    #But: cygwin is different ...

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
    my $predir = "";
    if ( $EH{'intermediate'}{'path'} ne "." and not is_absolute_path( $file ) ) {
	# Prepend a directory name ...
	$predir = $EH{'intermediate'}{'path'} . "/" ;
	$predir =~ s,[/\\]+$,/,; # Strip of extra trailing slashes / and \ ...
    }

    my @prev;
    # Read in intermediate from previous runs ...
    @prev = open_infile( $predir . $file, $sheet, "mandatory,write");

    if(!@prev) {
        logwarn "ERROR: reading input for delta mode!";
	$EH{'sum'}{'errors'}++;
	return;
    }

    my @prevd = two2one( $prev[0] );
    my @currd = two2one( $r_a );
    if ( not $EH{'iswin'} and $file =~ m,.xls$, ) {
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
--  delta mode (comment/space/sort/remove): $EH{'output'}{'delta'}
--
-- ------------------------------------------------- --
-- ------------- CHANGES START HERE ------------- --
";
    $head = replace_mac( $head, $EH{'macro'} );

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
	    logwarn("WARNING: SHEET_DIFF with different headers useless!");
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
	my @delcols = ();

	push( @h, [ "--NR--", "--CONT--", "--NR--", "--CONT--" ] );
	if ( $niceform ) {
	    # Convert into tabular format, mark changed cells !!

	    push( @h, [ "HEADER",  @colnhead ] ); # Attach header line
	    unshift( @h, [ "HEADER", @colnhead ] ); # Preped full header line
	    my $colwidth = scalar( @{$h[0]} ); # Matrix has to be wide enough ...

	    # Now convert delta to two-line format ...
	    for my $nf ( @out ) {
		my @newex = ();
		my @oldex = ();
		if ( scalar( @$nf ) == 4 ) {
		    $newex[0] = "NEW-" . $nf->[0];
		    $oldex[0] = "OLD-" . $nf->[2];
		    push( @newex, split( /@@@/, $nf->[1] ) ) if $nf->[1];
		    push( @oldex, split( /@@@/, $nf->[3] ) ) if $nf->[3];
		    push( @h, [ @newex ] ) if ( scalar( @newex ) > 1  );
		    push( @h, [ @oldex ] ) if ( scalar( @oldex ) > 1 );
		    my $fn = scalar( @newex );
		    my $fo = scalar( @oldex );
		    my $min = ( $fn < $fo ) ? $fn : $fo;
		    my $max = ( $fn < $fo ) ? $fo : $fn;
		    for my $iii ( 0..$min-1 ) {
			if ( $newex[$iii] ne $oldex[$iii] ) {
			    push( @delcols , scalar(@h) . "/" . ( $iii + 1 ) );
			}
		    }
		    if ( $min < $max ) {
			for my $iii ( $min..$max ) {
			    push( @delcols, scalar( @h ) . "/" . ( $iii + 1 ) );
			}
		    } 
		} 
		else {
		    push( @h, $nf );
		}
	    }
	} 
	else {
	    # Remove the @@@ signs from output ...
	    for my $o ( @out ) {
		map( { s,@@@,,g } @$o );
	    }
	    push( @h, ( @out ) );
	}

	write_outfile($file, "DIFF_" . $sheet, \@h, \@delcols);

	# One line has to differ (date)
	if ( $difflines > 0 ) {

	    logwarn( "INFO: Detected $difflines changes in intermediate sheet $sheet, in file $file");
	} 
	elsif ( $difflines == -1 ) {
	    logwarn( "WARNING: Missing changed date in intermediate sheet $sheet, in file $file");
	}
	#TODO: Do not use logwarn here ...
	return $difflines;
    }
    else {
	return -1;
    }
}


####################################################################
## write_outfile
## write data into outfile
####################################################################
sub write_outfile($$$;$) {

    my $file = shift;
    my $sheet = shift;
    my $r_a = shift;
    my $r_c = shift || undef;

    if( $EH{'format'}{'out'}=~ m/^xls$/ || ($file=~ m/\.xls/ && $EH{'iswin'})) {
	write_xls($file, $sheet, $r_a, $r_c);
    }
    elsif( $EH{'format'}{'out'}=~ m/^sxc$/ || $file=~ m/\.sxc/) {
	write_sxc($file, $sheet, $r_a, $r_c);
    }
    elsif( $EH{'format'}{'out'}=~ m/^csv$/ || $file=~ m/\.csv/ || $file=~ m/\.xls/) {
	$file=~ s/\.xls$/\.csv/;
	write_csv($file, $sheet, $r_a, $r_c);
    }
    else {
	logwarn "unknown outfile format";
	return;
    }
    return;
}


####################################################################
## write_xls
## write intermediate data to excel sheet
####################################################################
=head2 write_xls($$$;$)

this subroutine is self explanatory. The only important thing is,
that it will try to rotate older versions of the generated sheets.
E.g. sheet CONN will become O0_CONN while O0_CONN was shifted
to O1_CONN. The maximum number of all versions to keep is
defined by $EH{'intermediate'}{'keep'}

=over 4

=item $file filename
=item $type sheetname (CONN|HIER)
=item $ref_a reference to array with data
=item $ref_c mark the cells listed in this array

=back

=cut

sub write_xls($$$;$) {

    my $file = shift;
    my $sheet = shift;
    my $r_a = shift;
    my $r_c = shift || undef;

    if( $EH{'iswin'} || $EH{'format'}{'out'}) {

	my $book;
	my $newflag = 0;
	my $openflag = 0;
	my $sheetr = undef;

	# Add extension
	unless ( $file =~ m/\.xls$/ ) {
	    $file .= ".xls";
	}

	# Was OLE already started?
	unless( $ex ) {
	# if( ( $^O=~ m/MSWin/ && join( " ", @ARGV)=~ m/\.xls/) || $EH{'format'}{'out'}=~ m/^xls$/ ) {
	    $ex = init_ole();
	    unless( $ex ) {
		logwarn( "ERROR: Cannot initialize OLE, intermediate file $file will written as CSV" );
		$file=~ s/\.xls$/\.csv/;
		return write_csv($file, $sheet, $r_a);
	    }
	    init_open_workbooks();
	}

	# Write to other directory ...
	if ( $EH{'intermediate'}{'path'} ne "." and not is_absolute_path( $file ) ) {
	    $file = $EH{'intermediate'}{'path'} . "/" . $file;
	}

	my $efile = absolute_path( $file );
	my $basename = basename( $file );
	( my $wfile = $efile ) =~ s,/,\\,g; # Windows32 ....

	# $ex->{DisplayAlerts}=0;
	$ex->{DisplayAlerts}=0 if ( $EH{'script'}{'excel'}{'alerts'} =~ m,off,io );

	if ( -r $file ) {
	    # If it exists, it could be open, too?
	    unless( $book = is_open_workbook( $basename ) ) {
		# No, not opened so far ....
		logwarn("File $file already exists! Contents will be changed");
		$book = $ex->Workbooks->Open($wfile); #Needs correct PATH ... / or \ ...
		new_workbook( $basename, $book );
	    } else {
		# Is the open thing at the right place?
		my $wbpath = dirname( $file ) || $EH{'cwd'};
		if ( $wbpath eq "." ) {
		    $wbpath = $EH{'cwd'};
		} elsif ( not is_absolute_path( $wbpath ) ) {
		    $wbpath = $EH{'cwd'} . "/" . $wbpath;
		}

		$wbpath =~ s,/,\\,g; # Replace / -> \
		#Does our book have the right path?
		if ( $book->Path ne $wbpath ) {
		    logwarn("ERROR: workbook $basename with different path (" . $book->Path .
			    ") already opened!");
		    $EH{'sum'}{'errors'}++;
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

	    if ( $EH{'intermediate'}{'keep'} ) {

		# Rotate sheets ...
		# Delete eldest one:
		my $max = $EH{'intermediate'}{'keep'};
		logwarn("Rotating $max old sheets of $sheet!");
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
		if ( $EH{'intermediate'}{'format'} =~ m,prev,o and
		     defined( $s_previous ) ) {
		    unless( $s_previous->Copy($s_previous) ) { # Add in new sheet before
			logwarn("Cannot copy previous sheet! Create new one.");
		    } else {
			$sheetr = $book->ActiveSheet();
			$sheetr->Unprotect;
			$sheetr->UsedRange->{'Value'} = (); #Will that delete contents?
			$sheetr->{'Name'} = $sheet;
		    }
		}
	    } else { # Delete contents or all of sheet ?
		if ( exists( $sh{ $sheet } ) ) {
		    #Keep format if EH.intermediate.format says so
		    if ( $EH{'intermediate'}{'format'} =~ m,prev,o ) {
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
	    # new_workbook( $basename, $book );
	    $newflag=1;
	}

	unless( defined( $sheetr ) ) {
	    # Create output worksheet:
	    $sheetr = $book->Worksheets->Add() || logwarn( "Cannot create worksheet $sheet in $file:$!");
	    $sheetr->{'Name'} = $sheet;
	}

	$sheetr->Activate();
	$sheetr->Unprotect;

	mix_utils_mask_excel( $r_a );

	my $x=$#{$r_a->[0]}+1;
	my $y=$#{$r_a}+1;
	my $c1=$sheetr->Cells(1,1)->Address;
	my $c2=$sheetr->Cells($y,$x)->Address;
	my $rng=$sheetr->Range($c1.":".$c2);
	$rng->{Value}=$r_a;

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
		    if ( $x == 1 ) {
			$ncol = $ocol = mix_utils_rgb( 0, 0, 255 );
		    } else {
			$ocol = mix_utils_rgb( 0, 255, 0 );
			$ncol = mix_utils_rgb( 255, 0, 0 );
		    }
		    $rng= $sheetr->Range($cn);
		    $rng->Interior->{Color} = $ncol;
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

	if ( $EH{'intermediate'}{'format'} =~ m,auto, ) {
	    $rng->Columns->AutoFit;
	}

	#TODO: pretty formating
	# $book->Save;

	$book->SaveAs($wfile);

	# $book->Close unless ( $openflag ); #TODO: only close if not open before ....

	$ex->{DisplayAlerts}=1;

	return;
    }
    else {
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
defined by $EH{'intermediate'}{'keep'}

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
	logwarn("ERROR: Cannot initialze oolib to write out intermediate file $file!");
	$EH{'sum'}{'errors'}++;
	return;
    }

    my $zip = Archive::Zip->new();

    # Write to other directory ...
    if ( $EH{'intermediate'}{'path'} ne "." and not is_absolute_path( $file ) ) {
	$file = $EH{'intermediate'}{'path'} . "/" . $file;
    }

    my $basename = basename( $file ); # s,.*[/\\],,; #Strip off / and \

    if ( -r $file ) {
	logwarn("File $file already exists! Contents will be changed");

	# unzip $file in $path
	unless($zip->read($file)==AZ_OK) {
	    logwarn "ERROR: can't open zip file $file!\n";
	    $EH{'sum'}{'errors'}++;
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
	    if( !$isheet && $content[$i]=~ m/<table:table table:name=\"/) { # start of sheet
		$isheet = 1;
		$sheetname = $content[$i];
		$sheetname =~ s/<table:table table:name=\"//;
		$sheetname = (split(/\"/, $sheetname))[0];
		$settings{"$sheetname"} = $i;
	    }
	    elsif( $isheet && $content[$i]=~ m/<\/table:table>/) { # end of sheet
		$isheet= 0;
		$settings{$sheetname . "_end"} = $i+1;
		$sheetname = "";
	    }
	}
	undef $isheet;
	undef $sheetname;

	if ( $EH{'intermediate'}{'keep'} ) {
	    # Rotate sheets ...
	    # Delete eldest one:
	    my $max = $EH{'intermediate'}{'keep'};
	    logwarn("Rotating $max old sheets of $sheet!");
	    if ( exists( $settings{ "O_" . $max . "_" . $sheet } ) ) {
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
	    if ( exists $settings{"$sheet"} ) {
		$s_previous = $settings{"$sheet"};
		my $newname = "O_1_" . $sheet;
	        $content[$settings{"$sheet"}]=~ s/$sheet/$newname/;
		$settings{'start'} = $s_previous;
		$settings{'stop'} = $s_previous;
	    }
	    else {   # set position of new sheet
	        my $end = getDocumentEnd(\@content);
		$settings{'start'} = $end;
		$settings{'stop'} = $end;
	    }

	    # keep previous format
	    if( $EH{'intermediate'}{'format'}=~ m,prev,o && defined $s_previous) {
		$settings{'tabStyle'} = getStyle($content[$s_previous]);
#		my $start = $settings{$sheet};
#		my $stop = $settings{$sheet . "_end"};
#		for my $i ($start..$stop) {
		    # get column styles
		    # get row styles
		    # get cell styles
#	      }
	    }

	} else { # Delete contents or all of sheet ?
	    if ( exists( $settings{ $sheet } ) ) {
		#Keep format if EH.intermediate.format says so
		if ( $EH{'intermediate'}{'format'} =~ m,prev,o ) {
		    # get style -> use same style for new sheet
		    $settings{'tabStyle'} = getStyle($content[$settings{$sheet}]);
		}
		$settings{'start'} = $settings{$sheet};
		$settings{'stop'} = $settings{$sheet."_end"};
	    }
	    else {
	        my $end = getDocumentEnd(\@content);
		$settings{'start'} = $end;
		$settings{'stop'} = $end;
	    }
	}
    }
    else {
	# Create new workbook
	# no warnings;
	$^W = 0;
	oooInit("sxc");
	oooSet("builddir", ".");
	oooSet("author", "generated by MIX");
	oooGenerate($file);    # write output
	# use warnings;
	$^W = 1;

	rmdir("META-INF");
	unless($zip->read($file)==AZ_OK) {
	    logwarn "ERROR: creating star office calculator file $file!\n";
	    return undef;
	}
	@content = readContent($zip);

	my $ibody = 0;

	# keep position of start and stop tags
	for(my $i=0; defined $content[$i]; $i++) {
	    if(!$ibody && !defined $settings{'start'} && $content[$i]=~ m/^<office:body>$/) {
		$ibody = 1;
		$settings{'start'} = $i+1;
	    }
	    elsif($ibody && !defined $settings{'stop'} && $content[$i]=~ m/^<\/office:body>$/) {
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
    $zip->removeMember("content.xml");

    # Mark cells in that list in background color ..
    # Format: row/col
    if ( defined( $r_c ) ) {

#	$rng->setBackgroundColor( mix_utils_rgb( 255, 255, 255 )); # Set back color to white

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
    }

    if(!defined $settings{'tabStyle'}) {
        $settings{'tabStyle'} = "";
    }
    if(!defined $settings{'defColStyle'}) {
        $settings{'defColStyle'} = "";
    }
    if(!defined $settings{'defRowStyle'}) {
        $settings{'defRowStyle'} = "";
    }
    if(!defined $settings{'defCellStyle'}) {
        $settings{'defCellStyle'} = "";
    }

    writeContent( $r_a, \%settings, \@content);

    $zip->addFile("content.xml");
#    $zip->writeToFileNamed($file);
    $zip->overwriteAs($file);
    unlink "content.xml";
    rmdir("META-INF");
    return 1;
}

# use ooolib on demand, only!
{ my $ooo_flag = 0; #static, tells me if we used ooolib already ....
sub useOoolib () {

    return 1 if ( $ooo_flag );
    if ( eval 'use ooolib;' ){
	logdie "ERROR: Cannot load ooolib module: $@\n";
	return undef;	
    }
    $ooo_flag = 1;
    return 1;
}
}

# get document end tags position
sub getDocumentEnd($) {
    my $content = shift;

    for my $i (reverse(1..scalar(@$content))) {
        if($$content[$i] && $$content[$i]=~ m/^<\/office:body>$/) {
	    return $i;
	}
    }
}


# get style from soffice xml tag
sub getStyle($) {

    my $style = shift;

    if($style =~ s/^.* table:style-name=\"//) {
        $style =~ s/\".*>$//;
	return " table:style-name=\"" . $style . "\" ";
    }
    return "";
}


sub getDefaultStyle($) {

    my $style = shift;

    $style =~ s/^.* table:default-cell-style-name=\"//;
    $style =~ s/\".*>$//; 

    return $style;
}


# unzip content.xml and split tags
sub readContent($) {
    my $zip = shift;
    my @content = ();

    # extract content.xml file from archive
    @content = split(/>/, $zip->contents("content.xml"));
    map ( { $_ .= ">"; } @content );

    return @content;
}


sub writeContent($$) {

    my $data = shift;
    my $settings = shift;
    my $content = shift;

    open(DATA, "> content.xml");

    # output new style definitions

    # output content before sheet
    for(my $i=0; $i<$settings->{'start'}; $i++) {
 	# Todo: if not newflag count existing sheetstyles & add new one
 	print DATA @$content[$i];
    }

    # output new sheet
    print DATA "<table:table table:name=\"" . $settings->{'sheetname'} . "\"" . $settings->{'tabStyle'} . ">";

    # Todo: output column styles

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
	    }
	    else {
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
}


####################################################################
## write_csv
## write intermediate data to csv file
####################################################################
=head2 write_csv($$$;$)

this subroutine is self explanatory. The only important thing is,
that it will try to rotate older versions of the generated sheets.
E.g. sheet CONN will become O0_CONN while O0_CONN was shifted
to O1_CONN. The maximum number of all versions to keep is
defined by $EH{'intermediate'}{'keep'}

#!wig20050125: adding quoting style "MS-EXCEL":
    -cover newlines
    -mask quoting character  ;" "" ";  (duplicate!)
    -mask seperator (quotes!)

=over 4

=item $file filename
=item $type sheetname (CONN|HIER)
=item $ref_a reference to array with data

=back

=cut

sub write_csv($$$) {

    my $file = shift;
    my $sheet = shift;
    my $r_a = shift;

    my @data = ();
    my $openflag = 0;

    my ($start, $stop) = (0,0);
    my $xmax = $#{$r_a->[0]}+1;
    my $ymax = $#{$r_a}+1;

    my $cellsep = $EH{'format'}{'csv'}{'cellsep'};
    my $quoting = $EH{'format'}{'csv'}{'quoting'};
    my $style = $EH{'format'}{'csv'}{'style'};

    my $temp;

    # Write to other directory ...
    if ( $EH{'intermediate'}{'path'} ne "." and not is_absolute_path( $file ) ) {
 	$file = $EH{'intermediate'}{'path'} . "/" . $file;
    }

    my $basename = basename( $file ); # s,.*[/\\],,; #Strip off / and \

    if ( -r $file ) {

        my $max = $EH{'intermediate'}{'keep'};
	my $sheetm = $EH{'format'}{'csv'}{'sheetsep'};

	my $temp;
	my $osheet = 0;

	# If it exists, it could be open, too?
        open(FILE, "<$file");
	binmode FILE;
	@data = <FILE>;
	close(FILE);

	for(my $i=0; $i<scalar(@data); $i++) {
	    if($osheet==0 && $data[$i]=~ m/$sheetm$sheet/) {
		$osheet = 1;
		$start = $i;
		delete $data[$i];
	    }
	    elsif( $osheet==1) {
		if($data[$i]=~ m/$sheetm/) {
		    $osheet = 0;
		    $stop = $i;
		}
		else {
		    delete $data[$i];
		}
	    }
	}

	if($stop==0) {
	    $start = scalar @data;
	    $stop = $start;
        }
    }

    # To support \n without \r on MS-Win, open in binmode
    open(FILE,">$file");
    binmode FILE;

    my $cr = ( $EH{iswin} ? "\r" : "" ) . "\n";

    # Previous data
    for(my $i=0; $i<$start; $i++) {
        if(defined $data[$i]) {
	    print FILE $data[$i];
	}
    }

	if ( $EH{'format'}{'csv'}{'sheetsep'} ) {
    	print FILE $EH{'format'}{'csv'}{'sheetsep'} . $sheet . "\n";
	} else {
		logsay("INFO: Start printing sheet $sheet, no seperator selected!" );
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
		if ( $style =~ m/\bclassic\b/io ) {
		    $temp =~ s/$quoting/\\$quoting/g if $quoting;
		    $temp =~ s/\S\n/ /g; # remove linefeed
		    $temp =~ s/\s\n/ /g; # bug here? why should newline always have a leading whitespace?
		    $temp = $quoting . $temp . $quoting;
		} else {
		    if ( $style =~ m/\bwrapnl\b/io ) {
			$temp =~ s/\s*\n/ /og; # Swallow newlines
		    } elsif ( $style =~ m/\bmasknl\b/io ) {
			$temp =~ s/\n/\\n/og; #What to do with leading/trailing tabs?
		    } # elsif ( $EH{iswin} ) {
		    # $temp =~ s/\n/\r/g; # Make the internal new-line a simple "nl"
		    # }
		    if ( $style =~ m/\bdoublequote\b/io ) {
			$temp =~ s/$quoting/$quoting$quoting/go;
		    }
		    if ( $style =~ m/autoquote/io ) {
			if ( $temp =~ m/($cellsep|$quoting|\n)/ ) {
			    $temp = $quoting . $temp . $quoting;
			}
		    }
		}
		#$temp =~ tr/\n//;
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

    logwarn("Removing old and and diff sheets in file: $file");

    if( -r $file ) {

	my $basename = basename( $file ); # s,.*[/\\],,; #Strip off / and \

	# If it exists, it could be open, too?
	unless( $book = is_open_workbook( $basename ) ) {
	      # No, not opened so far...
              if($file =~ m/.xls$/) {
		  $book = $ex->Workbooks->Open(cwd()."\\".$file);  # TODO !!!
	      }
	}
	else {
	    # Is the open thing at the right place?
	    my $wbpath = dirname( $file ) || $EH{'cwd'};
	    if ( $wbpath eq "." ) {
	        $wbpath = $EH{'cwd'};
	    }
	    $wbpath =~ s,/,\\,g; # Replace / -> \
	    #Does our book have the right path?
	    if ( defined $ex && $book->Path ne $wbpath) {
	        logwarn("ERROR: workbook with different path already opened!");
		$EH{'sum'}{'errors'}++;
	    }
  	}

	my %sh = ();

	$ex->{DisplayAlerts}=0 if ( $EH{'script'}{'excel'}{'alerts'} =~ m,off,io );
	$book->Activate;

	# search for old sheets end remove them: O_ DIFF_ SheetN
	foreach my $sh (in( $book->{"Worksheets"} ) ) {
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

    logwarn("File $file not found!");
    return;
}


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

    logwarn("Removing old and and diff sheets in file: $file");

    if( -r $file ) {

        my $zip = Archive::Zip->new();
	my $isheet = 0;
	my $sheetname = ();

        # unzip $file in $path
        unless($zip->read($file)==AZ_OK) {
	    logwarn "ERROR: can't open zip file $file!\n";
	    return undef;
	}
	# extract content.xml file from archive
	my @content = readContent($zip);

	# keep start line index of all sheets
	for(my $i=0; defined $content[$i]; $i++) {
	    if( !$isheet && $content[$i]=~ m/<table:table table:name=\"/) { # start of sheet
		$sheetname = $content[$i];
		$sheetname =~ s/<table:table table:name=\"//;
		$sheetname = (split(/\"/,$sheetname))[0];
		if( $sheetname=~ m/^O_/ || $sheetname=~ m/DIFF_/) {
		  $isheet = 1;
		  delete $content[$i];
		}
	    }
	    elsif( $isheet) { # end of sheet
	        if( $content[$i]=~ m/<\/table:table>/) {
		    $isheet= 0;
		}
		delete $content[$i];
	    }
	}

	open(DATA,">content.xml");

	for my $i (0..scalar(@content)-1) {
	    if(defined $content[$i]) {
	        print DATA $content[$i];
	    }
	}
	close(DATA);

	$zip->addFile("content.xml");
	$zip->overwriteAs($file);
	unlink "content.xml";

	return;
    }

    logwarn("File $file not found!");
    return;
}


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

    logwarn("Removing old and and diff sheets in file: $file");

    if( -r $file ) {

	my $basename = basename( $file ); # s,.*[/\\],,; #Strip off / and \
	my @data;

	my $sheetO = $EH{'format'}{'csv'}{'sheetsep'} . "O_";
	my $sheetDiff = $EH{'format'}{'csv'}{'sheetsep'} . "DIFF_";

	my $itable = 1;

	open(FILE,"<$file");
	@data = <FILE>;
	close(FILE);

	open(FILE, ">$file");

	# search for old sheets end remove them
	my $max = scalar(@data);
	for(my $i=0; $i<$max; $i++) {
	    if( $itable==1) {
	        if( $data[$i] =~ /^$sheetO/ || $data[$i] =~ /^$sheetDiff/) {
		    $itable = 0;
	        }
		else {
		    print FILE $data[$i];
		}
	    }
	    else {
	      if( not($data[$i] =~ /^$sheetO/ || $data[$i] =~ /$sheetDiff/)) {
		  $itable = 1;
		  print FILE $data[$i];
	      }
	    }
        }
	close(FILE);

	return;
    }

    logwarn("File $file not found!");
    return;
}


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
####################################################################

=head2 mix_utils_mask_excel($)

Mask pure digits (esp. with . and/or , inside) for ExCEL!
Otherwise these will get converted to dates :-(

=cut

sub mix_utils_mask_excel($) {
    my $r_a = shift;

    for my $i ( @$r_a ) {
	for my $ii ( @$i ) {
	    unless( defined( $ii ) ) {
		$ii = "";
		next;
	    } elsif ( length( $ii ) > 1200 ) { #!wig20031215: 1200 will be accepted by Excel
		logwarn( "WARNING: Limit length of cell to save 1200 characters: " .
			substr( $ii, 0, 32 ) );
		$EH{'sum'}{'warnings'}++;
		$ii = substr( $ii, 0, 1200 );
		substr( $ii, 1191, 9 ) = "__ERROR__"; # Attach __ERROR__ to string!
	    }
	    $ii = "'" . $ii if ( $ii =~ m!^\s*[.,='"\d]! ); # Put a 'tick' in front of ExCEL special character  ....
	}
    }
}


# return 1
1;

#__END__

