#
# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright Cadence Design Systems, Inc. 2001.                        |
# |     All Rights Reserved.       Licensed Software.                     |
# |                                                                       |
# |                                                                       |
# | THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF CADENCE DESIGN SYSTEMS |
# | The copyright notice above does not evidence any actual or intended   |
# | publication of such source code.                                      |
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# | Project:    Micronas - IDEAS 2001                                     |
# | Modules:    $RCSfile:  TableIO.pm                                     |
# | Revision:   $Revision: 1.0                                            |
# | Author:     $Author:   John Armitage                                  |
# | Date:       $Date:     06/22/01                                       |
# |                                                                       |
# | Copyright Cadence Design Systems, 2001                                |
# |                                                                       |
# | $Header: /tools/mix/Development/CVS/MIX/lib/perl/CDS/TableIO.pm,v 1.1 2003/02/03 13:18:28 wig Exp $                                                         |
# +-----------------------------------------------------------------------+
#
# +-------------------------------------------------------------+
# |                                                             |
# | PROPRIETARY INFORMATION, PROPERTY OF CADENCE DESIGN SYSTEMS |
# |                                                             |
# +-------------------------------------------------------------+
#

package  CDS::TableIO;
@CDS::TableIO::ISA=qw(Exporter);
@CDS::TableIO::EXPORT=qw();
@CDS::TableIO::EXPORT_OK=qw(
			   &read_xls
			   &read_csv
			   &write_xls
			  );

use strict;
use vars qw($ex $use_csv);
use Log::Agent;
####################################################################
##
####################################################################
sub read_xls($$){
  my ($file, $sheetname)=@_;
  logdie "Cannot use Excel OLE interface!" unless($use_csv);
  $ex->{DisplayAlerts}=0;
  my $book  =$ex->Workbooks->Open({FileName=>$file.".xls", ReadOnly=>1});
#  my $book  =$ex->Workbooks->Open(
#				  $file.".xls",   # filename
#				  0,              # update links
#				  FALSE,          # readonly
#				  undef,          # format
#				  undef,          # password
#				  undef,          # writeResPassword
#				  TRUE,           # ingnoreReadOnlyRecommennded
#				  undef,          # origin
#				  FALSE,          # delimiter
#				  FALSE,          # editable
#				  FALSE           # notify
#				 );
#  my $sheet =$book->Worksheets($sheetnumber);
  $ex->ActiveWorkbook->Sheets($sheetname)->Activate;
  my $sheet =$book->ActiveSheet;
  my $row=$sheet->UsedRange->{Value};
  $book->Close;
  return($row);
}

sub write_xls($$$){
  my ($file, $sheetname, $rows)=@_;
  my $book  =$ex->Workbooks->Open($file.".xls");
  $ex->ActiveWorkbook->Sheets($sheetname)->Activate;
  my $sheet =$book->ActiveSheet;
  $sheet->Unprotect;
  $sheet->UsedRange->Delete;
  my $x=$#{$rows->[0]}+1;
  my $y=$#$rows;
  my $c1=$sheet->Cells(1,1)->Address;
  my $c2=$sheet->Cells($y,$x)->Address;
#  print "(Range $c1:$c2)";
  my $rng=$sheet->Range($c1.":".$c2);
  $rng->{Value}=$rows;
  $rng->Columns->AutoFit;
  $sheet->Protect;
  $book->Save;
  $book->Close;
}


####################################################################
##
####################################################################
sub read_csv($){
  my ($file, $sheetname)=@_;
  my @row;
  open(IN, "<".$file.".csv") || logdie "Could not open file $file!";
  while(<IN>){
    chomp;
    s/\cM$//;
    while(/;\"[^\"]+$/){
      my $l=<IN>;
      chomp($l);
      $l=~s/\cM$//;
      $_.=" ".$l;
    }
    my @col=split(/;/, substr($_, 0, length($_)-1));
    map{s/^"(.*)"$/$1/}@col;
    push(@row, \@col);
  }
  close(IN);
  return(\@row);
}

####################################################################
## BEGIN function
## trying to determine the type of interface
####################################################################
BEGIN {
  $use_csv=0;
  unless (eval "use Win32::OLE;"){
    eval{$ex=Win32::OLE->GetActiveObject('Excel.Application')};
    unless($@){    # Excel not installed
      if(defined $ex){
	$use_csv=1;
      } else {
	$use_csv=1 if($ex=Win32::OLE->new('Excel.Application', sub {$_[0]->Quit;}));
      }
    }
  }
  Win32::OLE->Option(Warn=>3) if($use_csv);
  1;
}

1;
