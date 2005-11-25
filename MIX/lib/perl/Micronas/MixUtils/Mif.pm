# -*- perl -*---------------------------------------------------------------
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# |   Copyright Micronas GmbH, Inc. 2002/2005.                            |
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
# | Modules:    $RCSfile: Mif.pm,v $                                      |
# | Revision:   $Revision: 1.7 $                                          |
# | Author:     $Author: mathias $                                            |
# | Date:       $Date: 2005/11/25 13:30:07 $                              |
# |                                                                       | 
# | Copyright Micronas GmbH, 2005                                         |
# |                                                                       |
# +-----------------------------------------------------------------------+
#
# +-----------------------------------------------------------------------+
# |                                                                       |
# | Changes:                                                              |
# | $Log: Mif.pm,v $
# | Revision 1.7  2005/11/25 13:30:07  mathias
# | new routine _td_para implemented
# | it handles some more formatting directives
# |
# | Revision 1.6  2005/11/24 10:33:11  mathias
# | added "sub _td_para" again
# |
# | Revision 1.5  2005/11/07 13:18:13  mathias
# | added wrCell function
# |
# | Revision 1.4  2005/11/04 10:44:47  wig
# | Adding ::incom (keep CONN sheet comments) and improce portlist report format
# |
# | Revision 1.3  2005/10/19 08:19:20  wig
# | Extended portlist writer and Mif module
# |
# | Revision 1.2  2005/09/29 13:45:02  wig
# | Update with -report
# |
# | Revision 1.1  2005/09/14 14:40:06  wig
# | Startet report module (portlist)
# |                                                                       |
# |                                                                       |
# |                                                                       |
# +-----------------------------------------------------------------------+
package  Micronas::MixUtils::Mif;
require Exporter;

@ISA=qw(Exporter);

@EXPORT  = qw();

@EXPORT_OK = qw();

our $VERSION = '1.0';

use strict;
# use vars qw( $ex ); # Gets OLE object

use Cwd;
use File::Basename;
use Log::Agent;
use FileHandle;

# use Micronas::MixUtils qw(:DEFAULT %OPTVAL %EH replace_mac convert_in
# 			  select_variant two2one one2two);
use Micronas::MixUtils qw(%EH);

# Prototypes
# sub write_delta_sheet ($$$);

#
# RCS Id, to be put into output templates
#
my $thisid          =      '$Id: Mif.pm,v 1.7 2005/11/25 13:30:07 mathias Exp $';#'  
my $thisrcsfile	    =      '$RCSfile: Mif.pm,v $'; #'
my $thisrevision    =      '$Revision: 1.7 $'; #'  

$thisid =~ s,\$,,go; # Strip away the $
$thisrcsfile =~ s,\$,,go;
$thisrevision =~ s,^\$,,go;
( $VERSION = $thisrevision ) =~ s,.*Revision:\s*,,; #TODO: Is that a good idea?

#
# Create a new MIF file
#  default filename: DESIGN.mif
#  mode: read/write/delta
#
sub new {
	my $this = shift;
	my ( $class ) = ref( $this ) || $this;
	my %params = @_;

	# data member default values
	my $ref_member  = {
		'mode'	=>	'',
		'name'	=>	'',
		'text'	=>  '', # keep file contents
		'tables' => [], # keep intermediate data/tables
		'paraid' => [], # keep paragraph to id refs
		'_t_ref'	=> {},	# map tableid to tables
	};
	
	# init data members w/ parameters from constructor call
	foreach (keys %params) {
		$ref_member->{$_} = $params{$_};
	};

	bless $ref_member, $class;
};

=head 4 write() write results to file

	write() does not take arguments
	
=cut

sub write {
	my $this = shift;
	my $name = shift;
	
	if ( defined( $name ) ) {
		$this->{'name'} = $name;
	}

	# Open file and write contents ...
	my $fh = new FileHandle "> $this->{'name'}";
    if (defined $fh) {
    	my $t = '';
    	for my $i ( @{$this->{'tables'}} ) {
    		$t .= $i;
    	}
    	
    	my $p = '';
    	for my $i ( @{$this->{'paraid'}} ) {
    		$p .= $i;
    	}
    	$this->{'text'} =~ s/%MIFTABLES%/$t/;
    	$this->{'text'} =~ s/%PARAID%/$p/;
    	
        print $fh $this->{'text'} ;
        
        $fh->close;
    } else { # Print Error messages!
    	logwarn("ERROR: Cannot write report file $this->{'name'}: $!");
    	$EH{'sum'}{'errors'}++;
    }
}

#
# Initialize MIF file text:
#  %MIFTABLES% will be replaced by the real tables
#
sub template {
	my $self = shift;
	
	$self->{'text'} = "<MIFFile 5.50>

<Tbls 
# Generated table data:
%MIFTABLES%
> # end of Tbls

# <TextFlow 
#   <TFTag `A'>
#   <TFAutoConnect Yes>
# Generated Table references:
%PARAID%
#  <Para
#    <PgfTag `Body'>
#    <ParaLine
#      <ATbl 1>
#    >
#  >
# > # end of TextFlow

# End of MIFFile
";

	return;
} #End of template

#
# Add another table
#TODO:
#  effectively creates a data structure, which will be printed later on
#
#     <TblNumColumns 6>
# 	  <TblColumnWidth  34.0 mm>
#     <TblColumnWidth  13.53077 mm>
#     <TblColumnWidth  18.46923 mm>
#     <TblColumnWidth  70.0 mm>
#     <TblColumnWidth  19.0 mm>
#     <TblColumnWidth  25.46923 mm>
#
#  accepted parameters:
#    text 
sub start_table {
	my $self = shift;
	my $params = shift; # All arguments

#TODO: Add this to EH ...
  my %table = (
	'Title' => '__E_MISSING_TITLE',
	'Id' => scalar ( @{$self->{'tables'}} ) + 1,	# Automatically increase ID counter
	'Format' => 'PortList', #TODO: set to some generic value
	'Cols' => 6,				   # Default Table Columns
	'ColumnWidth' => [
		qw( 34.0 13.53077 18.46923 70.0 19.0 25.46923 )
		],
	'ColumnUnit' => 'mm',
	'TitlePgf' => "TableTitle",    # Default Table Format
	'TblTag'	=> 'PortList',	#TODO: make more generic!
	);

  # Title ....
  if ( ref( $params ) eq "HASH" ) {
	# Got a hash ...
	for my $i ( %$params ) {
		$table{$i} = $params->{$i};
	}	
  } else {
	$table{'Title'} = $params;
  }

  # Check if a table with that Id already exists:
  while ( exists $self->{'_t_ref'}{$table{'Id'}} ) {
	logwarn( "WARNING: need to increment TableID to prevent duplicate!" );
	$EH{'sum'}{'warnings'}++;
	$table{'Id'}++;
	# Stop at 10000!
	if ( $table{'Id'} > 10000 ) {
		logwarn( 'ERROR: cannot allocate an unused TableID <= 10000! Top here!' );
		$EH{'sum'}{'errors'}++;
		return undef();
	}
  }

  # Create a "table" start...
  my $table = "<Tbl 
  <TblID $table{Id}>
  # <TblFormat
  #   <TblTag `$table{Format}'>
  # >
  <TblTag `$table{TblTag}'>
  <TblNumColumns $table{Cols}>\n" .
  join( "", map { "  <TblColumnWidth $_ $table{'ColumnUnit'}>\n" }
  		@{$table{'ColumnWidth'}} ) .
"  <TblTitle 
    <TblTitleContent
      <Para
        <PgfTag `$table{TitlePgf}'>
        <ParaLine
          <String `$table{Title}'>
        >
      >
    > 
  > # end of TblTitle
";

my $paraid = "  <Para
    <PgfTag `Body'>
    <ParaLine
      <ATbl $table{'Id'}>
    >
  >
";
  # Store the new table and a link to it
  $self->{'_t_ref'}{$table{'Id'}} = scalar ( @{$self->{'tables'}} );
  push( @{$self->{'tables'}}, $table );
  push( @{$self->{'paraid'}}, $paraid );

  return $table{'Id'};
	
}

#
# Finalize "table"
# If $id is not set, apply to the last one
#
sub end_table {
	my $self = shift;
	my $id	= shift;
	
	$id = _map_tid( $self, $id );
	
	$self->{'tables'}[$id] .=  "> # end of Tbl\n";
	
}

#
# Return array number of table
#
# Input:
#	MIF object reference
#	id
# Output: slice number
#
sub _map_tid ($$) {
	my $self = shift;
	my $id 	= shift;
	
	if ( defined $id ) {
		if ( exists ( $self->{'_t_ref'}{$id} ) ) {
			$id = $self->{'_t_ref'}{$id};
		} else {
			$id = -1;
		}
	} else {  
		$id = -1;
	}
	return $id;
}
		
=head 4 adding a table head

	table_head( $t )

	creates
	
  <TblH
	$t
  > # end of TblH

=cut

# Print a table head
# If a table id is given, taken
sub table_head {
	my $self = shift;
	my $text = shift;
	my $id	 = shift;

	$id = _map_tid( $self, $id );
	
	$self->{'tables'}[$id] .= "<TblH\n" .
		$text . "> # end of TblH\n";
	return;

}

=head 4 adding a table body

	table_body( $t )
	
	creates
  <TblBody
	$t
  > # end of TblBody

=cut

# Print a table head
sub table_body {
	my $self = shift;
	my $text = shift;
	my $id	 = shift;
	
	$id = _map_tid( $self, $id );
	
	$self->{'tables'}[$id] .= "<TblBody\n" .
		$text . "> # end of TblBody\n";
	return;

}

# Start a table body
sub start_body {
	my $self = shift;
	my $id	= shift;
	
	$id = _map_tid( $self, $id );
	
	$self->{'tables'}[$id] .= "<TblBody\n";
	return;

}
# End table body
sub end_body {
	my $self = shift;
	my $id	= shift;
	
	$id = _map_tid( $self, $id );
	
	$self->{'tables'}[$id] .= "> # end of TblBody\n";
	return;

}

#
# Add a text to the last table!
#
sub add {
	my $self = shift;
	my $text = shift;
	my $id	= shift;
	
	$id = _map_tid( $self, $id );
	
	$self->{tables}[$id] .= $text;
	return;

}

=head 4 define a row

	Tr() -> create a table row!
#   <Row
#         <Row <RowWithNext Yes>
#    <Cell <CellContent <Para <PgfTag `xRegHeading'>	<ParaLine <String `Name'> > > > >
#    <Cell <CellContent <Para <PgfTag `xRegHeading'>	<ParaLine <String `Addr'> > > > >
#    <Cell <CellContent <Para <PgfTag `xRegHeading'>	<ParaLine <String `Mode'> > > > >
#    <Cell <CellContent <Para <PgfTag `xRegHeading'>	<ParaLine <String `Sync'> > > > >
#    <Cell <CellContent <Para <PgfTag `xRegHeading'>	<ParaLine <String `Reset'> > > > >
#    <Cell <CellContent <Para <PgfTag `xRegHeading'>	<ParaLine <String `Range'> > > > >
#    <Cell <CellContent <Para <PgfTag `xRegHeading'>	<ParaLine <String `Function'> > > > >
#   > # end of Row

Indent: 1 Tab
=cut

sub Tr {
	my $self = shift;
	my $params = shift;

	#TODO: Make that dependent on "context"
	my %cell = (
		'PgfTag' => "xRegHeading",
		'WithNext'	=> 0,
		'WithPrev' => 0, 
		'Text'	=> '__E_MISSING_ROWDATA',
		'Indent'	=> 1,
	);
	
	if ( ref( $params ) eq "HASH" ) {
		# hash with 	-> PgfTag
		#				-> Row data (array with strings)
		for my $i ( keys( %$params ) ) {
			$cell{$i} = $params->{$i};
		}
	} else {
		$cell{'Text'} = $params;
	}
	
	my $with = '';
	if ( $cell{'WithNext'} ) {
		$with .='<RowWithNext Yes> ';
	}
	if ( $cell{'WithPrev'} ) {
		$with .= '<RowWithPrev Yes> ';
	}
    my $t = "\t" x $cell{'Indent'} . "<Row $with\n" .
    		$cell{'Text'} . 
    		"\t" x $cell{'Indent'} . '> # end of Row' . "\n";

	return $t;
		
}

#
#    <Cell <CellContent <Para <PgfTag `xRegHeading'>	<ParaLine <String `Name'> > > > >
# Parameters:
#	PgfTag	(Paragraph format, default: CellBody)
#	String	(Cell contents, mandatory argument)
#	Columns (If set, this cell spans multiple columns, optional)
#   Indent  (Default: 2Tab)
#
sub td {
	my $self = shift;
	my $params = shift;

	my %cell = (
		'PgfTag'	=> 'CellBody',  # Default FrameMaker Format
		'String'	=> [ '__E_NO_STRING' ],
		'Columns'	=>	0,			# Do not span columns
		'Indent'	=>  2,	# Prepend two Tabs
	);
	
	if ( ref( $params ) eq "HASH" ) {
		for my $i ( keys %$params ) {
			if ( $i eq 'String' ) {
				if ( ref( $params->{$i} ) eq 'ARRAY' ) {
					$cell{$i} = $params->{$i};
				} else {
					$cell{$i}[0] = $params->{$i};
				}
			} else {
				$cell{$i} = $params->{$i};
			}
		}
	} else {
		$cell{'String'}[0] = $params;
	}

	# "String" argument is array -> iterate over all elements ...
	my $text = "";
	for my $s ( @{$cell{'String'}} ) {
		#TODO: encode $s for MIF
		my $cols = ( $cell{'Columns'} ) ? "<CellColumns $cell{'Columns'}> " : "";
		$s = _td_para( $s, $cell{'Indent'} );
		$text .= "\t" x $cell{'Indent'} .
				"<Cell $cols<CellContent <Para <PgfTag `" .
				$cell{'PgfTag'} . "'> $s > > >\n";
	}
	return $text;
}

#
#    <Cell <CellContent <Para <PgfTag `xRegHeading'>	<ParaLine <String `Name'> > > > >
# Parameters:
#	PgfTag	(Paragraph format, default: CellBody)
#	String	(Cell contents)
#	Columns (If set, this cell spans multiple columns, optional)
#   Indent  (Default: no indentation)
#
sub wrCell($$$)
{
    my ($self, $param, $indent) = @_;
    my $text = "";

    $indent ||= 2;    # Prepend two Tabs
    my %cell = ('PgfTag'	=> 'CellBody',      # Default FrameMaker Format
                'String'        => '__E_NO_STRING', # String, Cellname
                'Columns'       => 0,               # Do not span columns
                'Rows'          => 0,               # Do not span rows
                'Fill'          => 0,               # CellFill?
                'Separation'    => 0,               # CellSeparation?
                'Color'         => 0,               # background color
                'Indent'        => 0,               # Prepend <n> Tabs
               );

    if ( ref( $param ) eq "HASH" ) {
        $text .= "\t" x $indent if ($indent);
        $text .=  "<Cell ";
        $text .= "<CellRows " . $param->{Rows} . "> " if (exists($param->{Rows}));
        $text .= "<CellColumns " . $param->{Columns} . "> " if (exists($param->{Columns}));
        $text .= "<CellFill " . $param->{Fill} . '> ' if (exists($param->{Fill}));
        $text .= "<CellSeparation " . $param->{Separation} . '>' if (exists($param->{Separation}));
        $text .= "<CellColor `" . $param->{Color} . "'>" if (exists($param->{Color}));

        $text .= "<CellContent <Para <PgfTag `" . $param->{PgfTag} . "'> ";
        if (exists($param->{String})) {
            $text .= _td_para($param->{String}, $indent);
        } else {
            $text .= "<ParaLine >";
        }
        $text .= " > > > # end of Cell\n";
     } else {
        $cell{'String'} = $param;
    }
    return $text;
}

#
# Convert the string that goes into the table cell
# Esp. mask \n
#
sub _td_para_old()
{
    my $string = shift;
    my $indent = shift;

    my $parapre = '<ParaLine <String `';
    my $parasep = "'" . '> <Char HardReturn> > #End of ParaLine' . "\n" .
        "\t" x $indent . '<ParaLine <String `';
    my $paraend = "'> >";

    $string =~ s/\n/$parasep/g;
    $string = $parapre . $string . $paraend;

    return $string;
}

sub _td_para()
{
    my ($string, $indent) = @_;
    my $newstring = "";

    my $normal        = '<ParaLine <String `';
    my $bold          = '<ParaLine <Font <FWeight Bold> > <String `';
    my $underline     = '<ParaLine <Font <FUnderlining FSingle> > <String `';
    my $overline      = '<ParaLine <Font <Foverline 1> > <String `';
    my $strikethrough = '<ParaLine <Font <FStrike 1> > <String `';
    my $superscript   = '<ParaLine <Font <FPosition FSuperscript > > <String `';
    my $subscript     = '<ParaLine <Font <FPosition FSubscript > > <String `';
    my $bullet        = '<ParaLine <Char Bullet> > #End of ParaLine' . "\n";
    #\t = tab           =  ??? <TabStop ... weiss ich auch nciht.
    my $parasep       = "'" . '> > #End of ParaLine' . "\n";
    my $paraend       = "'> >";

    while ($string =~ m/^([^\\]*)\\([nbuoslh\*])(.*)/) {
        my $beg      = $1;
        my $modifier = $2;
        my $end      = $3;
        if ($modifier eq 'n') {                     # (hard) new line
            $newstring .= $normal . $beg . "'" . '> <Char HardReturn> > #End of ParaLine' . "\n";
            $string = $end;
        } elsif ($modifier =~ m/[*buoslh]/) {                # bold
            # first "normal" part
            if ($beg) {
                $newstring .= "\t" x $indent . $normal . $beg . $parasep;
            }
            if ($modifier eq '*') {
                $string = $end;
                $newstring .= "\t" x $indent . $bullet;
            } else {
                # looking for the end mark (\x) of the special part
                my $second = "";
                if ($end =~ m/^([^\\]+)\\x(.*)/) {
                    $end = $1;
                    $second = $2;
                }
                # special part of $string
                $newstring .= "\t" x $indent . $bold          . $end . $parasep if ($modifier eq 'b');
                $newstring .= "\t" x $indent . $underline     . $end . $parasep if ($modifier eq 'u');
                $newstring .= "\t" x $indent . $overline      . $end . $parasep if ($modifier eq 'o');
                $newstring .= "\t" x $indent . $strikethrough . $end . $parasep if ($modifier eq 's');
                $newstring .= "\t" x $indent . $superscript   . $end . $parasep if ($modifier eq 'l');
                $newstring .= "\t" x $indent . $subscript     . $end . $parasep if ($modifier eq 'h');
                $string = $second;
            }
        }
    }
    if ($string) {       # rest of the string
        $newstring .= "\t" x $indent . $normal . $string . $paraend;
    }

    return $newstring;
}

1;

#!End
