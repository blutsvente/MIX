# ooolib - This perl library is built to create OpenOffice.org documents.
# Copyright (C) 2003  Joseph Colton

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# You can contact me by email at joseph@colton.byuh.edu.
package ooolib;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

require Exporter;

@ISA=qw(Exporter);

@EXPORT  = qw(
	      oooData
	      oooSpecial
	      oooInit
	      oooSet
	      oooGenerate
	      oooError);

# API Function Calls
sub oooData;          # Formats input with current options
sub oooSpecial;       # Adds special data to the document: brakes, tables?
sub oooInit;          # Takes type as arg and clears out data
sub oooSet;           # arg1 variable name, arg2 value/data
sub oooGenerate;      # arg1 filename|null returns filename
sub oooError;         # returns last error message

# Internal function calls
sub oooWriteMeta;     # Writes the meta.xml file
sub oooWriteContent;  # Writes the content.xml file
sub oooWriteStyles;   # Writes the styles.xml file
sub oooWriteMimetype; # Writes the mimetype file
sub oooWriteSettings; # Writes the settings file
sub oooWriteManifest; # Writes the META-INF/manifest.xml file
sub oooTimeStamp;     # Returns a timestamp of the form yyyy-mm-ddThh:mm:ss
sub oooDateTime;      # Returns the date and time: yyyy, mm, dd, hh, mm, ss
sub oooCleanText;     # Replaces special characters in a string
sub oooCellUpdate;    # Updates max values and current values for x and y
sub oooCellCheck;     # Tests to make sure the x and y values are legal
sub oooStyleName;     # Returns the name of the style to use

# Library internal variables
my($MINX, $MINY, $MAXX, $MAXY);
$MINX = $MINY = 1;
$MAXX = $MAXY = 32000;
my ($version, %options, %cellhash, @documenttext, @keywords);
$version="0.1.5";

##################
# Function Calls #
##################
sub oooStyleName {
    # Returns the name of the style to use
    my($style) = @_;
    my($i, $b, $u, $j, $idx, $stylenum);
    my($it, $bt, $ut, $jt, $prop);
    my($tc, $tb, $tct, $tbt); # Text color/background
    my($ts, $tst); # text size tag

    unless($options{init}) {
	$errormessage = "Please run oooInit first";
	return "error";
    }

    # Uses these numbers to keep track of which styles have been created
    $j = $options{justify};
    $b = $options{bold};
    $i = $options{italic};
    $u = $options{underline};
    $tc = $options{textcolor};
    $tb = $options{textbgcolor};
    $ts = $options{textsize};

    if ($style =~ /^h/ && $j eq "left") {
	return $style;
    }
    if ($j eq "left" && $b eq "off" &&
	$i eq "off" && $u eq "off" &&
	$tc eq "000000" && $tb eq "FFFFFF" &&
	$ts eq $options{textsize_default}) {
	# Nothing special needs to be done
	return $style;
    }

    # A style needs to be looked up or created
    $idx = "$style $j $b $i $u $tc $tb $ts";
    if ($style =~ /^h/) {$idx = "$style $j";}
    if ($options{$idx}) {return $options{$idx};}

    $stylenum = "P$options{nextstyle}";
    $options{nextstyle}++;
    $options{$idx} = $stylenum;

    if ($options{justify} eq "left") {$jt = "fo:text-align=\"start\" style:justify-single-word=\"false\" ";}
    if ($options{justify} eq "right") {$jt = "fo:text-align=\"end\" style:justify-single-word=\"false\" ";}
    if ($options{justify} eq "center") {$jt = "fo:text-align=\"center\" style:justify-single-word=\"false\" ";}
    if ($options{justify} eq "block") {$jt = "fo:text-align=\"justify\" style:justify-single-word=\"false\" ";}

    if ($options{bold} eq "on") {
	$bt = "fo:font-weight=\"bold\" style:font-weight-asian=\"bold\" style:font-weight-complex=\"bold\" ";	
    } else {
	$bt = "";
    }

    if ($options{italic} eq "on") {
	$it = "fo:font-style=\"italic\" style:font-style-asian=\"italic\" style:font-style-complex=\"italic\" ";
    } else {
	$it = "";
    }

    if ($options{underline} eq "on") {
	$ut = "style:text-underline=\"single\" style:text-underline-color=\"font-color\" ";
    } else {
	$ut = "";
    }
    
    if ($tc ne "000000") {
	$tct = "fo:color=\"#$tc\" ";
    } else {
	$tct = "";
    }

    if ($tb ne "FFFFFF") {
	$tbt = "style:text-background-color=\"#$tb\" ";
    } else {
	$tbt = "";
    }

    if ($ts ne $options{textsize_default}) {
	$tst = "fo:font-size=\"${ts}pt\" ";
    } else {
	$tst = "";
    }

    if ($style =~ /^h/) {
	push(@autostyles, "<style:style style:name=\"$stylenum\" style:family=\"paragraph\" style:parent-style-name=\"$style\">");
	push(@autostyles, "<style:properties ${jt}/>");
	push(@autostyles, "</style:style>");
    } else {
	push(@autostyles, "<style:style style:name=\"$stylenum\" style:family=\"paragraph\" style:parent-style-name=\"$style\">");
	push(@autostyles, "<style:properties ${tct}${tbt}${tst}${bt}${it}${ut}${jt}/>");
	push(@autostyles, "</style:style>");
    }

    return $stylenum;
}

sub oooSpecial {
    # Adds special data to the document: brakes, tables?
    my($style) = shift(@_);
    unless($options{init}) {
	$errormessage = "Please run oooInit first";
	return "error";
    }
    unless($style) {
	$errormessage = "This function requires at least one argument";
	return "error";
    }

    # Styles
    if ($style eq "pagebreak") {
	if ($options{pagebreak}) {
	    my($stylenum);
	    $stylenum = $options{pagebreak};
	    push(@documenttext, "<text:p text:style-name=\"$stylenum\"/>");
	} else {
	    my($stylenum);
	    $stylenum = "P$options{nextstyle}";
	    $options{nextstyle}++;
	    $options{pagebreak} = $stylenum;
	    push(@autostyles, "<style:style style:name=\"$stylenum\" style:family=\"paragraph\" style:parent-style-name=\"Standard\">");
	    push(@autostyles, "<style:properties fo:break-before=\"page\"/>");
	    push(@autostyles, "</style:style>");
	    push(@documenttext, "<text:p text:style-name=\"$stylenum\"/>");
	}
	return "ok";
    } elsif ($style eq "list-ordered") {
	my($stylenum, $listnum, $text);
	($listnum, $text) = @_;
	$text = &oooCleanText($text);

	if ($listnum =~ /^L[0-9]+$/) {
	    # Good listnum
	    $stylenum = $options{$listnum};
	    unless($stylenum) {
		$errormessage = "Invalid list number \"$listnum\".";
		return "error";
	    }
	    push(@documenttext, "<text:ordered-list text:style-name=\"$listnum\" text:continue-numbering=\"true\">");
	    push(@documenttext, "<text:list-item>");
	    push(@documenttext, "<text:p text:style-name=\"$stylenum\">$text</text:p>");
	    push(@documenttext, "</text:list-item>");
	    push(@documenttext, "</text:ordered-list>");
	    return $listnum;
	} else {
	    # Needs a listnum
	    $stylenum = "P$options{nextstyle}";
	    $options{nextstyle}++;
	    $listnum = "L$options{nextlist}";
	    $options{nextlist}++;
	    $options{$listnum} = $stylenum;
	    # The style
	    push(@autostyles, "<style:style style:name=\"$stylenum\" style:family=\"paragraph\" style:parent-style-name=\"Standard\" style:list-style-name=\"$listnum\"/>");

	    # The list information
	    push(@autolists, "<text:list-style style:name=\"$listnum\">");
	    push(@autolists, "<text:list-level-style-number text:level=\"1\" text:style-name=\"Numbering Symbols\" style:num-suffix=\".\" style:num-format=\"1\">");
	    push(@autolists, "<style:properties text:min-label-width=\"0.499cm\"/>");
	    push(@autolists, "</text:list-level-style-number>");
	    push(@autolists, "<text:list-level-style-number text:level=\"2\" text:style-name=\"Numbering Symbols\" style:num-suffix=\".\" style:num-format=\"1\">");
	    push(@autolists, "<style:properties text:space-before=\"0.501cm\" text:min-label-width=\"0.499cm\"/>");
	    push(@autolists, "</text:list-level-style-number>");
	    push(@autolists, "<text:list-level-style-number text:level=\"3\" text:style-name=\"Numbering Symbols\" style:num-suffix=\".\" style:num-format=\"1\">");
	    push(@autolists, "<style:properties text:space-before=\"1cm\" text:min-label-width=\"0.499cm\"/>");
	    push(@autolists, "</text:list-level-style-number>");
	    push(@autolists, "<text:list-level-style-number text:level=\"4\" text:style-name=\"Numbering Symbols\" style:num-suffix=\".\" style:num-format=\"1\">");
	    push(@autolists, "<style:properties text:space-before=\"1.501cm\" text:min-label-width=\"0.499cm\"/>");
	    push(@autolists, "</text:list-level-style-number>");
	    push(@autolists, "<text:list-level-style-number text:level=\"5\" text:style-name=\"Numbering Symbols\" style:num-suffix=\".\" style:num-format=\"1\">");
	    push(@autolists, "<style:properties text:space-before=\"2cm\" text:min-label-width=\"0.499cm\"/>");
	    push(@autolists, "</text:list-level-style-number>");
	    push(@autolists, "<text:list-level-style-number text:level=\"6\" text:style-name=\"Numbering Symbols\" style:num-suffix=\".\" style:num-format=\"1\">");
	    push(@autolists, "<style:properties text:space-before=\"2.501cm\" text:min-label-width=\"0.499cm\"/>");
	    push(@autolists, "</text:list-level-style-number>");
	    push(@autolists, "<text:list-level-style-number text:level=\"7\" text:style-name=\"Numbering Symbols\" style:num-suffix=\".\" style:num-format=\"1\">");
	    push(@autolists, "<style:properties text:space-before=\"3.001cm\" text:min-label-width=\"0.499cm\"/>");
	    push(@autolists, "</text:list-level-style-number>");
	    push(@autolists, "<text:list-level-style-number text:level=\"8\" text:style-name=\"Numbering Symbols\" style:num-suffix=\".\" style:num-format=\"1\">");
	    push(@autolists, "<style:properties text:space-before=\"3.502cm\" text:min-label-width=\"0.499cm\"/>");
	    push(@autolists, "</text:list-level-style-number>");
	    push(@autolists, "<text:list-level-style-number text:level=\"9\" text:style-name=\"Numbering Symbols\" style:num-suffix=\".\" style:num-format=\"1\">");
	    push(@autolists, "<style:properties text:space-before=\"4.001cm\" text:min-label-width=\"0.499cm\"/>");
	    push(@autolists, "</text:list-level-style-number>");
	    push(@autolists, "<text:list-level-style-number text:level=\"10\" text:style-name=\"Numbering Symbols\" style:num-suffix=\".\" style:num-format=\"1\">");
	    push(@autolists, "<style:properties text:space-before=\"4.502cm\" text:min-label-width=\"0.499cm\"/>");
	    push(@autolists, "</text:list-level-style-number>");
	    push(@autolists, "</text:list-style>");

	    # Text for the document
	    push(@documenttext, "<text:ordered-list text:style-name=\"$listnum\">");
	    push(@documenttext, "<text:list-item>");
	    push(@documenttext, "<text:p text:style-name=\"$stylenum\">$text</text:p>");
	    push(@documenttext, "</text:list-item>");
	    push(@documenttext, "</text:ordered-list>");
	    return $listnum;
	}
    }

    $errormessage = "I did not understand the oooSpecial style";
    return "error";
}

sub oooData {
    my($style, $origtext) = @_;
    my($text, $stylename);

    unless($options{init}) {
	$errormessage = "Please run oooInit first";
	return "error";
    }
    unless($style) {
	$errormessage = "This function requires at least two arguments";
	return "error";
    }
    
    if ($origtext) {
	$text = &oooCleanText($origtext);
    } else {
	$text = "";
    }

    if ($style eq "h") {
	$stylename = &oooStyleName("Heading");
	push(@documenttext, "<text:p text:style-name=\"$stylename\">$text</text:p>");
    } elsif ($style =~ /^h([1-9])/) {
	$stylename = &oooStyleName("Heading $1");
	push(@documenttext, "<text:h text:style-name=\"$stylename\" text:level=\"$1\">$text</text:h>");
    } elsif ($style eq "default") {
	$stylename = &oooStyleName("Standard");
	if ($text) {
	    # Default Text
	    push(@documenttext, "<text:p text:style-name=\"$stylename\">$text</text:p>");
	} else {
	    # Blank line
	    push(@documenttext, "<text:p text:style-name=\"$stylename\"/>");
	}
    } elsif ($style eq "textbody") {
	# textbody does some special formatting stuff.
	my(@paragraphs, $paragraph, @lines, $line);
	$stylename = &oooStyleName("Text body");

	if ($text) {
	    # A paragraph with text
	    @paragraphs = split(/\n/, $text);
	    foreach $paragraph (@paragraphs) {
		# Send Begin Paragraph tag
		unless($paragraph) {next;}
		push(@documenttext, "<text:p text:style-name=\"$stylename\">");
		@lines = split(/\. +/, $paragraph);
		$line = join(". <text:s/>", @lines);
		push(@documenttext, $line);
		push(@documenttext, "</text:p>");
	    }
	} else {
	    # This is a blank paragraph tag.
	    push(@documenttext, "<text:p text:style-name=\"$stylename\"/>");
	}
    } elsif ($style eq "cell-float") {
	my($x, $y);
	$x = $cellhash{x};
	$y = $cellhash{y};

	$cellhash{"$x $y type"} = "float";
	$cellhash{"$x $y value"} = $text;
	$cellhash{"$x $y format"} = "";

	&oooCellUpdate;
    } elsif ($style eq "cell-text") {
	my($x, $y);
	$x = $cellhash{x};
	$y = $cellhash{y};

	$cellhash{"$x $y type"} = "text";
	$cellhash{"$x $y value"} = $text;
	$cellhash{"$x $y format"} = "";

	&oooCellUpdate;
    } elsif ($style eq "cell-skip") {
	# Does not do anything to the cell, just skips it
	&oooCellUpdate;
    } elsif ($style eq "anothertype") {
	# Add more types here.
    }

    return "ok";
}

sub oooError {
    # returns last error message if any
    if ($errormessage) {
	return $errormessage;
    } else {
	return "No error messages.";
    }
}

sub oooCellUpdate {
    # Updates max values and current values for x and y

    if ($cellhash{x} > $cellhash{xmax}) {$cellhash{xmax} = $cellhash{x};}
    if ($cellhash{y} > $cellhash{ymax}) {$cellhash{ymax} = $cellhash{y};}

    $cellhash{x} += $cellhash{xauto};
    $cellhash{y} += $cellhash{yauto};
    
    &oooCellCheck;
}

sub oooCellCheck {
    # Tests to make sure the x and y values are legal
    if ($cellhash{x} < $MINX) {$cellhash{x} = $MINX;}
    if ($cellhash{y} < $MINY) {$cellhash{y} = $MINY;}
    if ($cellhash{x} > $MAXX) {$cellhash{x} = $MAXX;}
    if ($cellhash{y} > $MAXY) {$cellhash{y} = $MAXY;}
}

sub oooCleanText {
    my($text) = @_;
    $text =~ s/\&/\&amp;/g;
    $text =~ s/'/\&apos;/g;
    $text =~ s/</\&lt;/g;
    $text =~ s/>/\&gt;/g;
    return $text;
}

sub oooInit {
    # Initialize data and clean out variables
    my($type, $opt) = @_;
    unless($type) {
	$errormessage = "You must select the document type: sxw | sxc";
	return "error";
    }
    if ($type ne "sxw" && $type ne "sxc") {
	$errormessage = "Invalid type \"$type\", valid types: sxw | sxc";
	return "error";
    }

    # Clean out data variables
    undef(%options);
    undef(@documenttext);
    undef(@keywords);
    undef(%cellhash);
    undef($errormessage);
    undef(@autostyles);
    undef(@autolists);

    if ($opt) {
	if ($opt eq "debug") {$options{debug} = 1;}
    }

    # Set default values
    $cellhash{x} = 1;
    $cellhash{y} = 1;
    $cellhash{xmax} = 1;
    $cellhash{ymax} = 1;

    # Formatting
    $options{nextstyle} = 1;
    $options{nextlist} = 1;
    $options{justify} = "left";
    $options{bold} = "off";
    $options{italic} = "off";
    $options{underline} = "off";
    $options{textcolor} = "000000";
    $options{textbgcolor} = "FFFFFF";
    $options{textsize} = "12";
    $options{textsize_default} = "12";
    $options{textsize_min} = "6";
    $options{textsize_max} = "96";

    # Used for auto-incrementing cells after giving values
    $cellhash{xauto} = 0;
    $cellhash{yauto} = 0;

    # User defined meta variables
    $options{"info1 name"} = "Info 1";
    $options{"info2 name"} = "Info 2";
    $options{"info3 name"} = "Info 3";
    $options{"info4 name"} = "Info 4";

    # Set all knowns
    $options{init} = "init";
    $options{type} = $type;
    $options{time} = time;
    $options{pid} = $$;

    return "ok";
}

sub oooSet {
    # Set variables in the options hash
    my($name) = shift(@_);
    
    unless($options{init}) {
	$errormessage = "Please run oooInit first";
	return "error";
    }
    unless($name) {
	$errormessage = "Usage: \&oooSet(\"name\", arg2, arg3, etc.);";
	return "error";
    }

    if ($name eq "title") {
	my($value) = shift(@_);
	$options{title} = &oooCleanText($value);
    } elsif ($name eq "author") {
	my($value) = shift(@_);
	$options{author} = &oooCleanText($value);
    } elsif ($name eq "subject") {
	my($value) = shift(@_);
	$options{subject} = &oooCleanText($value);
    } elsif ($name eq "comments") {
	my($value) = shift(@_);
        $options{comments} = &oooCleanText($value);
    } elsif ($name eq "builddir") {
	my($value) = shift(@_);
	$options{builddir} = $value;
    } elsif ($name eq "keyword") {
	my($value);
	while(@_) {
	    $value = shift(@_);
	    push(@keywords, &oooCleanText($value));
	}
    } elsif ($name =~ /^meta([1-4])-name$/) {
	my($value) = shift(@_);
	$options{"info$1 name"} = &oooCleanText($value);
    } elsif ($name =~ /^meta([1-4])-value$/) {
	my($value) = shift(@_);
	$options{"info$1 value"} = &oooCleanText($value);
    } elsif ($name eq "cell-loc") {
        # Set the writing cell
	my($x, $y) = @_;
	$cellhash{x} = $x;
	$cellhash{y} = $y;
	&oooCellCheck;
    } elsif ($name eq "cell-left") {
	# Subtract 1 from x
	$cellhash{x}--;
	&oooCellCheck;
    } elsif ($name eq "cell-right") {
	# Add 1 to x
	$cellhash{x}++;
	&oooCellCheck;
    } elsif ($name eq "cell-up") {
	# Subtract 1 from y
	$cellhash{y}--;
	&oooCellCheck;
    } elsif ($name eq "cell-down") {
	# Add 1 to y
	$cellhash{y}++;
	&oooCellCheck;
    } elsif ($name eq "cell-auto") {
	# Set the auto-increment values.
	my($x, $y) = @_;
	$cellhash{xauto} = $x;
	$cellhash{yauto} = $y;
    } elsif ($name eq "justify") {
	# Set the justification of the text
	my($value) = @_;
	if ($value eq "right" ||
	    $value eq "left" ||
	    $value eq "center" ||
	    $value eq "block") {
	    $options{justify} = $value;
	}
    } elsif ($name eq "bold") {
	# Adjust the bold properties
	my($value) = @_;
	if ($value eq "on" ||
	    $value eq "off") {
	    $options{bold} = $value;
	}
    } elsif ($name eq "italic") {
	# Adjust the italic properties
	my($value) = @_;
	if ($value eq "on" ||
	    $value eq "off") {
	    $options{italic} = $value;
	}
    } elsif ($name eq "underline") {
	# Adjust the underline properties
	my($value) = @_;
	if ($value eq "on" ||
	    $value eq "off") {
	    $options{underline} = $value;
	}
    } elsif ($name eq "text-color") {
	# Set the text color RRGGBB
	my($value) = @_;
	if ($value =~ /^[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]$/) {
	    $options{textcolor} = $value;
	    return "ok";
	} else {
	    if ($value eq "default") {
		# Defaults back to black
		$options{textcolor} = "000000";
	    } elsif ($value eq "red") {
		# red = FF0000
		$options{textcolor} = "FF0000";
	    } elsif ($value eq "green") {
		# Green = 00FF00
		$options{textcolor} = "00FF00";
	    } elsif ($value eq "blue") {
		# Blue eq 0000FF
		$options{textcolor} = "0000FF";
	    } elsif ($value eq "black") {
		# Defaults back to black
		$options{textcolor} = "000000";
	    } elsif ($value eq "white") {
		# White = FFFFFF
		$options{textcolor} = "FFFFFF";
	    } else {
		$errormessage = "Is \"$value\" a color?";
		return "error";
	    }
	    return "ok";
	}
    } elsif ($name eq "text-bgcolor") {
	# Set the background color for text RRGGBB
	my($value) = @_;
	if ($value =~ /^[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]$/) {
	    $options{textbgcolor} = $value;
	    return "ok";
	} else {
	    if ($value eq "default") {
		# Defaults back to black
		$options{textbgcolor} = "000000";
	    } elsif ($value eq "red") {
		# red = FF0000
		$options{textbgcolor} = "FF0000";
	    } elsif ($value eq "green") {
		# Green = 00FF00
		$options{textbgcolor} = "00FF00";
	    } elsif ($value eq "blue") {
		# Blue eq 0000FF
		$options{textbgcolor} = "0000FF";
	    } elsif ($value eq "black") {
		# Defaults back to black
		$options{textbgcolor} = "000000";
	    } elsif ($value eq "white") {
		# White = FFFFFF
		$options{textbgcolor} = "FFFFFF";
	    } else {
		$errormessage = "Is \"$value\" a color?";
		return "error";
	    }
	    return "ok";
	}
    } elsif ($name eq "text-size") {
	my($value) = @_;
	if ($value =~ /^[0-9]+$/) {
	    if ($value >= $options{textsize_min} &&
		$value <= $options{textsize_max}) {
		$options{textsize} = $value;
	    } 
	} else {
	    if ($value eq "default") {
		$options{textsize} = $options{textsize_default};
	    } else {
		$errormessage = "Only digits are allowed, not \"$value\".";
		return "error";
	    }
	}
    }
    return "ok";
    
}

sub oooGenerate {
    # Create the document and return a filename
    my($filename) = @_;
    unless($options{init}) {
	$errormessage = "Please run oooInit first";
	return "error";
    }

    my($cdloc, $builddir, $type);
    $builddir = $options{builddir};
    $type = $options{type};
    
    unless($builddir) {
	$errormessage = "Builddir not selected";
	return "error";
    }
    unless($type) {
	$errormessage = "Document type not selected";
	return "error";
    }

    if ($filename) {
	my(@parts) = split(/\./, $filename);
	my($ext) = pop(@parts);
	if ($ext ne $options{type}) {
	    $filename = "$filename.$type";
	}
    } else {
	my($time, $pid);
	$time = time;
	$pid = $$;
	$filename = "${time}${pid}.${type}";
    }

    # Create the files
    if ($options{debug}) {print "Writing XML\n";}
    &oooWriteMimetype($builddir, $type);
    &oooWriteContent($builddir, $type);
    &oooWriteStyles($builddir, $type);
    &oooWriteMeta($builddir, $type);
    &oooWriteSettings($builddir, $type);
    &oooWriteManifest($builddir, $type);

    $cdloc = "cd $builddir";

    if ($options{debug}) {print "Writing $type\n";}

    my $zip = Archive::Zip->new();
    $zip->addFile("mimetype");
    $zip->addFile("content.xml");
    $zip->addFile("styles.xml");
    $zip->addFile("meta.xml");
    $zip->addFile("settings.xml");
    $zip->addDirectory("MIME-INF");
    $zip->addFile("manifest.xml");
    die 'write error' unless $zip->writeToFileNamed( $filename) == AZ_OK;
    undef $zip;

    # Clean up
    if ($options{debug}) {
	print "Halting Clean-up\n";
    } else {
	unlink("$builddir/mimetype");
	unlink("$builddir/content.xml");
	unlink("$builddir/styles.xml");
	unlink("$builddir/meta.xml");
	unlink("$builddir/settings.xml");
	unlink("$builddir/META-INF/manifest.xml");
	rmdir("$builddir/META-INF");
	rmdir("$builddir/MIME-INF");
    }

    # Return the filename
    return "$builddir/$filename";
}

# SXC specific function calls
sub ooosxcCellLocation {
    # Set the writing cell
    my($x, $y) = @_;
    $cellx=$x;
    $celly=$y;
    if ($cellx <= 0) {$cellx = 1;}
    if ($celly <= 0) {$celly = 1;}
}

sub ooosxcCellLeft {
    # Subtract 1 from cellx
    $cellx--;
    if ($cellx <= 0) {$cellx = 1;}
}

sub ooosxcCellRight {
    # Add 1 to cellx
    $cellx++;
}

sub ooosxcCellUp {
    # Subtract 1 from celly
    $celly--;
    if ($celly <= 0) {$celly = 1;}
}

sub ooosxcCellDown {
    # Add 1 to celly
    $celly++;
}


# Functions to write files
sub oooWriteMimetype {
    # This writes the mimetype file
    my($mimefile, $builddir, $type);
    ($builddir, $type) = @_;
    unless($builddir) {return;}

    $mimefile = "$builddir/mimetype";

    # Open file for writing
    open(DATA, "> $mimefile");
    if ($type eq "sxw") {
	print DATA "application/vnd.sun.xml.writer";
    } elsif ($type eq "sxc") {
	print DATA "application/vnd.sun.xml.calc";
    }
    close(DATA);
}

sub oooWriteContent {
    # Writes the content.xml file
    my($contentfile, $line, $builddir, $type);
    ($builddir, $type) = @_;
    unless($builddir) {return;}

    $contentfile = "$builddir/content.xml";

    # Open file for writing
    open(DATA, "> $contentfile");

    if ($type eq "sxw") {
	# Encoding information
	print DATA "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	
	# DOCTYPE information
	print DATA "<!DOCTYPE office:document-content PUBLIC \"-//OpenOffice.org//DTD OfficeDocument 1.0//EN\" \"office.dtd\">";
	
	# Information about reading this file
	print DATA "<office:document-content xmlns:office=\"http://openoffice.org/2000/office\" xmlns:style=\"http://openoffice.org/2000/style\" xmlns:text=\"http://openoffice.org/2000/text\" xmlns:table=\"http://openoffice.org/2000/table\" xmlns:draw=\"http://openoffice.org/2000/drawing\" xmlns:fo=\"http://www.w3.org/1999/XSL/Format\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:number=\"http://openoffice.org/2000/datastyle\" xmlns:svg=\"http://www.w3.org/2000/svg\" xmlns:chart=\"http://openoffice.org/2000/chart\" xmlns:dr3d=\"http://openoffice.org/2000/dr3d\" xmlns:math=\"http://www.w3.org/1998/Math/MathML\" xmlns:form=\"http://openoffice.org/2000/form\" xmlns:script=\"http://openoffice.org/2000/script\" office:class=\"text\" office:version=\"1.0\">";
	
	# No scripts
	print DATA "<office:script/>";
	
	# Fonts
	print DATA "<office:font-decls>";
	print DATA "<style:font-decl style:name=\"Tahoma\" fo:font-family=\"Tahoma\"/>";
	print DATA "<style:font-decl style:name=\"Tahoma1\" fo:font-family=\"Tahoma\" style:font-pitch=\"variable\"/>";
	print DATA "<style:font-decl style:name=\"Times New Roman\" fo:font-family=\"&apos;Times New Roman&apos;\" style:font-family-generic=\"roman\" style:font-pitch=\"variable\"/>";
	print DATA "</office:font-decls>";
	
	# Styles line bold, center, etc.
	if (@autostyles) {
	    my($autostyle);
	    print DATA "<office:automatic-styles>";
	    foreach $autostyle (@autostyles) {
		if ($options{debug}) {
		    print DATA "$autostyle\n";
		} else {
		    print DATA "$autostyle";
		}
	    }
	    foreach $autostyle (@autolists) {
		if ($options{debug}) {
		    print DATA "$autostyle\n";
		} else {
		    print DATA "$autostyle";
		}
	    }
	    print DATA "</office:automatic-styles>";
	} else {
	    # No automatic styles
	    print DATA "<office:automatic-styles/>";
	}

	# Body of context
	print DATA "<office:body>";
	
	print DATA "<text:sequence-decls>";
	print DATA "<text:sequence-decl text:display-outline-level=\"0\" text:name=\"Illustration\"/>";
	print DATA "<text:sequence-decl text:display-outline-level=\"0\" text:name=\"Table\"/>";
	print DATA "<text:sequence-decl text:display-outline-level=\"0\" text:name=\"Text\"/>";
	print DATA "<text:sequence-decl text:display-outline-level=\"0\" text:name=\"Drawing\"/>";
	print DATA "</text:sequence-decls>";
	
	# Text
	if (@documenttext) {
	    foreach $line (@documenttext) {
		if ($options{debug}) {
		    print DATA "$line\n";
		} else {
		    print DATA "$line";
		}
	    }
	} else {
	    print DATA "<text:p text:style-name=\"Standard\"/>";
	}
	
	print DATA "</office:body>";
	print DATA "</office:document-content>";
    } elsif ($type eq "sxc") {
	# Encoding information
	print DATA "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	
	# DOCTYPE information
	print DATA "<!DOCTYPE office:document-content PUBLIC \"-//OpenOffice.org//DTD OfficeDocument 1.0//EN\" \"office.dtd\">";
	
	# Information about decoding XML
	print DATA "<office:document-content xmlns:office=\"http://openoffice.org/2000/office\" xmlns:style=\"http://openoffice.org/2000/style\" xmlns:text=\"http://openoffice.org/2000/text\" xmlns:table=\"http://openoffice.org/2000/table\" xmlns:draw=\"http://openoffice.org/2000/drawing\" xmlns:fo=\"http://www.w3.org/1999/XSL/Format\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:number=\"http://openoffice.org/2000/datastyle\" xmlns:svg=\"http://www.w3.org/2000/svg\" xmlns:chart=\"http://openoffice.org/2000/chart\" xmlns:dr3d=\"http://openoffice.org/2000/dr3d\" xmlns:math=\"http://www.w3.org/1998/Math/MathML\" xmlns:form=\"http://openoffice.org/2000/form\" xmlns:script=\"http://openoffice.org/2000/script\" office:class=\"spreadsheet\" office:version=\"1.0\">";
	
	# Script information tag?
	print DATA "<office:script/>";
	
	# Fonts
	print DATA "<office:font-decls>";
	
	print DATA "<style:font-decl style:name=\"Tahoma\" fo:font-family=\"Tahoma\" style:font-pitch=\"variable\"/>";
	print DATA "<style:font-decl style:name=\"Arial\" fo:font-family=\"Arial\" style:font-family-generic=\"swiss\" style:font-pitch=\"variable\"/>";
	
	print DATA "</office:font-decls>";
	
	# Styles
	print DATA "<office:automatic-styles>";
	
	# Resize on column width
	print DATA "<style:style style:name=\"co1\" style:family=\"table-column\">";
	print DATA "<style:properties fo:break-before=\"auto\" style:column-width=\"2.267cm\"/>";
	print DATA "</style:style>";
	
	print DATA "<style:style style:name=\"ro1\" style:family=\"table-row\">";
	print DATA "<style:properties fo:break-before=\"auto\"/>";
	print DATA "</style:style>";
	
	print DATA "<style:style style:name=\"ta1\" style:family=\"table\" style:master-page-name=\"Default\">";
	print DATA "<style:properties table:display=\"true\"/>";
	print DATA "</style:style>";
	
	print DATA "</office:automatic-styles>";
	
	# Beginning of document content
	print DATA "<office:body>";
	
	print DATA "<table:table table:name=\"Sheet1\" table:style-name=\"ta1\">";
	print DATA "<table:table-column table:style-name=\"co1\" table:number-columns-repeated=\"3\" table:default-cell-style-name=\"Default\"/>";
	
	my($x, $y);
	# One row at a time
	for($y=1;$y<=$cellhash{ymax};$y++) {
	    # One cell at a time down the row
	    print DATA "<table:table-row table:style-name=\"ro1\">";
	    for($x=1;$x<=$cellhash{xmax};$x++) {
		$celltype = $cellhash{"$x $y type"};
		$value = $cellhash{"$x $y value"};
		if ($celltype eq "text") {
		    print DATA "<table:table-cell>";
		    print DATA "<text:p>$value</text:p>";
		    print DATA "</table:table-cell>";
		} elsif ($celltype eq "float") {
		    print DATA "<table:table-cell table:value-type=\"float\" table:value=\"$value\">";
		    print DATA "<text:p>$value</text:p>";
		    print DATA "</table:table-cell>";
		} else {
		    print DATA "<table:table-cell/>";
		}
	    }
	    print DATA "</table:table-row>";
	}
	
	
	# Closing document
	print DATA "</table:table>";
	print DATA "</office:body>";
	print DATA "</office:document-content>";
    }
    close(DATA);
}

sub oooWriteMeta {
    # Writes the meta.xml file
    my($metafile, $keyword, $builddir, $type);
    ($builddir, $type) = @_;
    unless($builddir) {return;}

    $metafile = "$builddir/meta.xml";
    $metadate = &oooTimeStamp;
    
    open(DATA, "> $metafile");
    
    # Encoding Information
    print DATA "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
    
    # DOCTYPE line
    print DATA "<!DOCTYPE office:document-meta PUBLIC \"-//OpenOffice.org//DTD OfficeDocument 1.0//EN\" \"office.dtd\">";
    
    # Information about decoding the document and XML
    print DATA "<office:document-meta xmlns:office=\"http://openoffice.org/2000/office\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:meta=\"http://openoffice.org/2000/meta\" office:version=\"1.0\">";
    
    # Beginning of the meta information
    print DATA "<office:meta>";
    print DATA "<meta:generator>ooolib $version Generator</meta:generator>";

    # Load information from hash to local variables
    my($title, $comments, $subject, $author);
    $title = $options{title};
    $comments = $options{comments};
    $subject = $options{subject};
    $author = $options{author};

    print DATA "<dc:title>$title</dc:title>";
    print DATA "<dc:description>$comments</dc:description>";
    print DATA "<dc:subject>$subject</dc:subject>";
    print DATA "<meta:initial-creator>$author</meta:initial-creator>";
    print DATA "<meta:creation-date>$metadate</meta:creation-date>";
    print DATA "<dc:creator>$author</dc:creator>";
    print DATA "<dc:date>$metadate</dc:date>";
    print DATA "<meta:keywords>";
    foreach $keyword (@keywords) {
	print DATA "<meta:keyword>$keyword</meta:keyword>";
    }
    print DATA "</meta:keywords>";
    
    # Document Language
    print DATA "<dc:language>en-US</dc:language>";
    
    # This is the document version number
    print DATA "<meta:editing-cycles>1</meta:editing-cycles>";
    
    # Time the document has been worked on.
    print DATA "<meta:editing-duration>PT0S</meta:editing-duration>";
    
    # This is user defined variables.
    my($i);
    for ($i=1;$i<=4;$i++) {
	my($name, $value);
	if ($options{"info$i value"}) {
	    $name = $options{"info$i name"};
	    $value = $options{"info$i value"};
	    print DATA "<meta:user-defined meta:name=\"$name\">$value</meta:user-defined>";	
	} else {
	    $name = $options{"info$i name"};
	    print DATA "<meta:user-defined meta:name=\"$name\"/>";
	}
    }

    # Statistical Data
    if ($type eq "sxw") {
	print DATA "<meta:document-statistic meta:table-count=\"0\" meta:image-count=\"0\" meta:object-count=\"0\" meta:page-count=\"1\" meta:paragraph-count=\"1\" meta:word-count=\"0\" meta:character-count=\"0\"/>"; # For text
    } elsif ($type eq "sxc") {
	my($cellcount) = $cellhash{ymax} * $cellhash{xmax};
	print DATA "<meta:document-statistic meta:table-count=\"1\" meta:cell-count=\"$cellcount\"/>"; # For spreadsheets
    }
    
    print DATA "</office:meta>";
    print DATA "</office:document-meta>";
    
    close(DATA);
}

sub oooWriteStyles {
    # Writes the styles.xml file
    my($stylefile, $builddir, $type);
    ($builddir, $type) = @_;
    unless($builddir) {return;}

    $stylefile = "$builddir/styles.xml";
    
    open(DATA, "> $stylefile");

    if ($type eq "sxw") {
	print DATA "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	
	print DATA "<!DOCTYPE office:document-styles PUBLIC \"-//OpenOffice.org//DTD OfficeDocument 1.0//EN\" \"office.dtd\">";
	print DATA "<office:document-styles xmlns:office=\"http://openoffice.org/2000/office\" xmlns:style=\"http://openoffice.org/2000/style\" xmlns:text=\"http://openoffice.org/2000/text\" xmlns:table=\"http://openoffice.org/2000/table\" xmlns:draw=\"http://openoffice.org/2000/drawing\" xmlns:fo=\"http://www.w3.org/1999/XSL/Format\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:number=\"http://openoffice.org/2000/datastyle\" xmlns:svg=\"http://www.w3.org/2000/svg\" xmlns:chart=\"http://openoffice.org/2000/chart\" xmlns:dr3d=\"http://openoffice.org/2000/dr3d\" xmlns:math=\"http://www.w3.org/1998/Math/MathML\" xmlns:form=\"http://openoffice.org/2000/form\" xmlns:script=\"http://openoffice.org/2000/script\" office:version=\"1.0\">";
	print DATA "<office:font-decls>";
	print DATA "<style:font-decl style:name=\"Tahoma\" fo:font-family=\"Tahoma\"/>";
	print DATA "<style:font-decl style:name=\"Tahoma1\" fo:font-family=\"Tahoma\" style:font-pitch=\"variable\"/>";
	print DATA "<style:font-decl style:name=\"Times New Roman\" fo:font-family=\"&apos;Times New Roman&apos;\" style:font-family-generic=\"roman\" style:font-pitch=\"variable\"/>";
	print DATA "</office:font-decls>";
	print DATA "<office:styles>";
	print DATA "<style:default-style style:family=\"graphics\">";
	print DATA "<style:properties draw:start-line-spacing-horizontal=\"0.283cm\" draw:start-line-spacing-vertical=\"0.283cm\" draw:end-line-spacing-horizontal=\"0.283cm\" draw:end-line-spacing-vertical=\"0.283cm\" style:use-window-font-color=\"true\" style:font-name=\"Times New Roman\" fo:font-size=\"12pt\" fo:language=\"en\" fo:country=\"US\" style:font-name-asian=\"Tahoma\" style:font-size-asian=\"12pt\" style:language-asian=\"ja\" style:country-asian=\"JP\" style:font-name-complex=\"Tahoma1\" style:font-size-complex=\"12pt\" style:language-complex=\"none\" style:country-complex=\"none\" style:text-autospace=\"ideograph-alpha\" style:line-break=\"strict\" style:writing-mode=\"lr-tb\">";
	print DATA "<style:tab-stops/>";
	print DATA "</style:properties>";
	print DATA "</style:default-style>";
	print DATA "<style:default-style style:family=\"paragraph\">";
	print DATA "<style:properties style:use-window-font-color=\"true\" style:font-name=\"Times New Roman\" fo:font-size=\"12pt\" fo:language=\"en\" fo:country=\"US\" style:font-name-asian=\"Tahoma\" style:font-size-asian=\"12pt\" style:language-asian=\"ja\" style:country-asian=\"JP\" style:font-name-complex=\"Tahoma1\" style:font-size-complex=\"12pt\" style:language-complex=\"none\" style:country-complex=\"none\" fo:hyphenate=\"false\" fo:hyphenation-remain-char-count=\"2\" fo:hyphenation-push-char-count=\"2\" fo:hyphenation-ladder-count=\"no-limit\" style:text-autospace=\"ideograph-alpha\" style:punctuation-wrap=\"hanging\" style:line-break=\"strict\" style:tab-stop-distance=\"1.251cm\" style:writing-mode=\"page\"/>";
	print DATA "</style:default-style>";
	print DATA "<style:style style:name=\"Standard\" style:family=\"paragraph\" style:class=\"text\"/>";
	print DATA "<style:style style:name=\"Text body\" style:family=\"paragraph\" style:parent-style-name=\"Standard\" style:class=\"text\">";
	print DATA "<style:properties fo:margin-top=\"0cm\" fo:margin-bottom=\"0.212cm\"/>";
	print DATA "</style:style>";
	print DATA "<style:style style:name=\"List\" style:family=\"paragraph\" style:parent-style-name=\"Text body\" style:class=\"list\">";
	print DATA "<style:properties style:font-name-asian=\"Tahoma\"/>";
	print DATA "</style:style>";
	print DATA "<style:style style:name=\"Caption\" style:family=\"paragraph\" style:parent-style-name=\"Standard\" style:class=\"extra\">";
	print DATA "<style:properties fo:margin-top=\"0.212cm\" fo:margin-bottom=\"0.212cm\" fo:font-size=\"10pt\" fo:font-style=\"italic\" style:font-name-asian=\"Tahoma\" style:font-size-asian=\"10pt\" style:font-style-asian=\"italic\" style:font-size-complex=\"10pt\" style:font-style-complex=\"italic\" text:number-lines=\"false\" text:line-number=\"0\"/>";
	print DATA "</style:style>";
	print DATA "<style:style style:name=\"Index\" style:family=\"paragraph\" style:parent-style-name=\"Standard\" style:class=\"index\">";
	print DATA "<style:properties style:font-name-asian=\"Tahoma\" text:number-lines=\"false\" text:line-number=\"0\"/>";
	print DATA "</style:style>";
	print DATA "<text:outline-style>";
	print DATA "<text:outline-level-style text:level=\"1\" style:num-format=\"\"/>";
	print DATA "<text:outline-level-style text:level=\"2\" style:num-format=\"\"/>";
	print DATA "<text:outline-level-style text:level=\"3\" style:num-format=\"\"/>";
	print DATA "<text:outline-level-style text:level=\"4\" style:num-format=\"\"/>";
	print DATA "<text:outline-level-style text:level=\"5\" style:num-format=\"\"/>";
	print DATA "<text:outline-level-style text:level=\"6\" style:num-format=\"\"/>";
	print DATA "<text:outline-level-style text:level=\"7\" style:num-format=\"\"/>";
	print DATA "<text:outline-level-style text:level=\"8\" style:num-format=\"\"/>";
	print DATA "<text:outline-level-style text:level=\"9\" style:num-format=\"\"/>";
	print DATA "<text:outline-level-style text:level=\"10\" style:num-format=\"\"/>";
	print DATA "</text:outline-style>";
	print DATA "<text:footnotes-configuration style:num-format=\"1\" text:start-value=\"0\" text:footnotes-position=\"page\" text:start-numbering-at=\"document\"/>";
	print DATA "<text:endnotes-configuration style:num-format=\"i\" text:start-value=\"0\"/>";
	print DATA "<text:linenumbering-configuration text:number-lines=\"false\" text:offset=\"0.499cm\" style:num-format=\"1\" text:number-position=\"left\" text:increment=\"5\"/>";
	print DATA "</office:styles>";
	print DATA "<office:automatic-styles>";
	print DATA "<style:page-master style:name=\"pm1\">";
	print DATA "<style:properties fo:page-width=\"20.999cm\" fo:page-height=\"29.699cm\" style:num-format=\"1\" style:print-orientation=\"portrait\" fo:margin-top=\"2cm\" fo:margin-bottom=\"2cm\" fo:margin-left=\"2cm\" fo:margin-right=\"2cm\" style:writing-mode=\"lr-tb\" style:footnote-max-height=\"0cm\">";
	print DATA "<style:footnote-sep style:width=\"0.018cm\" style:distance-before-sep=\"0.101cm\" style:distance-after-sep=\"0.101cm\" style:adjustment=\"left\" style:rel-width=\"25%\" style:color=\"#000000\"/>";
	print DATA "</style:properties>";
	print DATA "<style:header-style/>";
	print DATA "<style:footer-style/>";
	print DATA "</style:page-master>";
	print DATA "</office:automatic-styles>";
	print DATA "<office:master-styles>";
	print DATA "<style:master-page style:name=\"Standard\" style:page-master-name=\"pm1\"/>";
	print DATA "</office:master-styles>";
	print DATA "</office:document-styles>";
	
    } elsif ($type eq "sxc") {
	print DATA "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	
	print DATA "<!DOCTYPE office:document-styles PUBLIC \"-//OpenOffice.org//DTD OfficeDocument 1.0//EN\" \"office.dtd\">";
	print DATA "<office:document-styles xmlns:office=\"http://openoffice.org/2000/office\" xmlns:style=\"http://openoffice.org/2000/style\" xmlns:text=\"http://openoffice.org/2000/text\" xmlns:table=\"http://openoffice.org/2000/table\" xmlns:draw=\"http://openoffice.org/2000/drawing\" xmlns:fo=\"http://www.w3.org/1999/XSL/Format\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:number=\"http://openoffice.org/2000/datastyle\" xmlns:svg=\"http://www.w3.org/2000/svg\" xmlns:chart=\"http://openoffice.org/2000/chart\" xmlns:dr3d=\"http://openoffice.org/2000/dr3d\" xmlns:math=\"http://www.w3.org/1998/Math/MathML\" xmlns:form=\"http://openoffice.org/2000/form\" xmlns:script=\"http://openoffice.org/2000/script\" office:version=\"1.0\">";
	print DATA "<office:font-decls>";
	print DATA "<style:font-decl style:name=\"Lucida Sans Unicode\" fo:font-family=\"&apos;Lucida Sans Unicode&apos;\" style:font-pitch=\"variable\"/>";
	print DATA "<style:font-decl style:name=\"MS P ゴシック\" fo:font-family=\"&apos;MS P ゴシック&apos;\" style:font-pitch=\"variable\"/>";
	print DATA "<style:font-decl style:name=\"Tahoma\" fo:font-family=\"Tahoma\" style:font-pitch=\"variable\"/>";
	print DATA "<style:font-decl style:name=\"Arial\" fo:font-family=\"Arial\" style:font-family-generic=\"swiss\" style:font-pitch=\"variable\"/>";
	print DATA "</office:font-decls>";
	
	print DATA "<office:styles>";
	print DATA "<style:default-style style:family=\"table-cell\">";
	print DATA "<style:properties style:decimal-places=\"2\" style:font-name=\"Arial\" fo:language=\"en\" fo:country=\"US\" style:font-name-asian=\"Lucida Sans Unicode\" style:language-asian=\"ja\" style:country-asian=\"JP\" style:font-name-complex=\"Tahoma\" style:language-complex=\"none\" style:country-complex=\"none\" style:tab-stop-distance=\"0.5inch\"/>";
	print DATA "</style:default-style>";
	print DATA "<number:number-style style:name=\"N0\" style:family=\"data-style\">";
	print DATA "<number:number number:min-integer-digits=\"1\"/>";
	print DATA "</number:number-style>";
	print DATA "<number:currency-style style:name=\"N104P0\" style:family=\"data-style\" style:volatile=\"true\">";
	print DATA "<number:currency-symbol number:language=\"en\" number:country=\"US\">\$</number:currency-symbol>";
	print DATA "<number:number number:decimal-places=\"2\" number:min-integer-digits=\"1\" number:grouping=\"true\"/>";
	print DATA "</number:currency-style>";
	print DATA "<number:currency-style style:name=\"N104\" style:family=\"data-style\">";
	print DATA "<style:properties fo:color=\"#ff0000\"/>";
	print DATA "<number:text>-</number:text>";
	print DATA "<number:currency-symbol number:language=\"en\" number:country=\"US\">\$</number:currency-symbol>";
	print DATA "<number:number number:decimal-places=\"2\" number:min-integer-digits=\"1\" number:grouping=\"true\"/>";
	print DATA "<style:map style:condition=\"value()&gt;=0\" style:apply-style-name=\"N104P0\"/>";
	print DATA "</number:currency-style>";
print DATA "<style:style style:name=\"Default\" style:family=\"table-cell\">";
	print DATA "<style:properties style:font-name-asian=\"MS P ゴシック\"/>";
	print DATA "</style:style>";
	print DATA "<style:style style:name=\"Result\" style:family=\"table-cell\" style:parent-style-name=\"Default\">";
	print DATA "<style:properties fo:font-style=\"italic\" style:text-underline=\"single\" style:text-underline-color=\"font-color\" fo:font-weight=\"bold\"/>";
	print DATA "</style:style>";
	print DATA "<style:style style:name=\"Result2\" style:family=\"table-cell\" style:parent-style-name=\"Result\" style:data-style-name=\"N104\"/>";
	print DATA "<style:style style:name=\"Heading\" style:family=\"table-cell\" style:parent-style-name=\"Default\">";
	print DATA "<style:properties fo:text-align=\"center\" style:text-align-source=\"fix\" fo:font-size=\"16pt\" fo:font-style=\"italic\" fo:font-weight=\"bold\"/>";
	print DATA "</style:style>";
	print DATA "<style:style style:name=\"Heading1\" style:family=\"table-cell\" style:parent-style-name=\"Heading\">";
	print DATA "<style:properties fo:direction=\"ltr\" style:rotation-angle=\"90\"/>";
	print DATA "</style:style>";
	print DATA "</office:styles>";
	print DATA "<office:automatic-styles>";
	print DATA "<style:page-master style:name=\"pm1\">";
	print DATA "<style:properties style:writing-mode=\"lr-tb\"/>";
	print DATA "<style:header-style>";
	print DATA "<style:properties fo:min-height=\"0.2957inch\" fo:margin-left=\"0inch\" fo:margin-right=\"0inch\" fo:margin-bottom=\"0.0984inch\"/>";
	print DATA "</style:header-style>";
	print DATA "<style:footer-style>";
	print DATA "<style:properties fo:min-height=\"0.2957inch\" fo:margin-left=\"0inch\" fo:margin-right=\"0inch\" fo:margin-top=\"0.0984inch\"/>";
	print DATA "</style:footer-style>";
	print DATA "</style:page-master>";
	print DATA "<style:page-master style:name=\"pm2\">";
	print DATA "<style:properties style:writing-mode=\"lr-tb\"/>";
	print DATA "<style:header-style>";
	print DATA "<style:properties fo:min-height=\"0.2957inch\" fo:margin-left=\"0inch\" fo:margin-right=\"0inch\" fo:margin-bottom=\"0.0984inch\" fo:border=\"0.0346inch solid \#000000\" fo:padding=\"0.0071inch\" fo:background-color=\"\#c0c0c0\">";
	print DATA "<style:background-image/>";
	print DATA "</style:properties>";
	print DATA "</style:header-style>";
	print DATA "<style:footer-style>";
	print DATA "<style:properties fo:min-height=\"0.2957inch\" fo:margin-left=\"0inch\" fo:margin-right=\"0inch\" fo:margin-top=\"0.0984inch\" fo:border=\"0.0346inch solid \#000000\" fo:padding=\"0.0071inch\" fo:background-color=\"\#c0c0c0\">";
	print DATA "<style:background-image/>";
	print DATA "</style:properties>";
	print DATA "</style:footer-style>";
	print DATA "</style:page-master>";
	print DATA "</office:automatic-styles>";
	print DATA "<office:master-styles>";
	print DATA "<style:master-page style:name=\"Default\" style:page-master-name=\"pm1\">";
	print DATA "<style:header>";
	print DATA "<text:p>";
	print DATA "<text:sheet-name>???</text:sheet-name>";
	print DATA "</text:p>";
	print DATA "</style:header>";
	print DATA "<style:header-left style:display=\"false\"/>";
	print DATA "<style:footer>";
	print DATA "<text:p>Page <text:page-number>1</text:page-number>";
	print DATA "</text:p>";
	print DATA "</style:footer>";
	print DATA "<style:footer-left style:display=\"false\"/>";
	print DATA "</style:master-page>";
	print DATA "<style:master-page style:name=\"Report\" style:page-master-name=\"pm2\">";
	print DATA "<style:header>";
	print DATA "<style:region-left>";
	print DATA "<text:p>";
	print DATA "<text:sheet-name>???</text:sheet-name> (<text:title>???</text:title>)</text:p>";
	print DATA "</style:region-left>";
	print DATA "<style:region-right>";
	print DATA "<text:p>";

	# Date
	my($yyyy, $mm, $dd, $h, $m, $s) = &oooDateTime;
	print DATA "<text:date style:data-style-name=\"N2\" text:date-value=\"${yyyy}-${mm}-${dd}\">${yyyy}/${mm}/${dd}</text:date>, <text:time>${h}:${m}:${s}</text:time>";
	
	print DATA "</text:p>";
	print DATA "</style:region-right>";
	print DATA "</style:header>";
	print DATA "<style:header-left style:display=\"false\"/>";
	print DATA "<style:footer>";
	print DATA "<text:p>Page <text:page-number>1</text:page-number> / <text:page-count>99</text:page-count>";
	print DATA "</text:p>";
	print DATA "</style:footer>";
	print DATA "<style:footer-left style:display=\"false\"/>";
	print DATA "</style:master-page>";
	print DATA "</office:master-styles>";
	print DATA "</office:document-styles>";
    }
    close(DATA);
}

sub oooWriteSettings {
    # Writes the settings.xml file
    my($setfile, $builddir, $type);
    ($builddir, $type) = @_;
    unless($builddir) {return;}

    $setfile = "$builddir/settings.xml";
    
    open(DATA, "> $setfile");

    if ($type eq "sxw") {
	print DATA "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	
	print DATA "<!DOCTYPE office:document-settings PUBLIC \"-//OpenOffice.org//DTD OfficeDocument 1.0//EN\" \"office.dtd\">";
	print DATA "<office:document-settings xmlns:office=\"http://openoffice.org/2000/office\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:config=\"http://openoffice.org/2001/config\" office:version=\"1.0\">";
	print DATA "<office:settings>";
	print DATA "<config:config-item-set config:name=\"view-settings\">";
	print DATA "<config:config-item config:name=\"ViewAreaTop\" config:type=\"int\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"ViewAreaLeft\" config:type=\"int\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"ViewAreaWidth\" config:type=\"int\">19846</config:config-item>";
	print DATA "<config:config-item config:name=\"ViewAreaHeight\" config:type=\"int\">10691</config:config-item>";
	print DATA "<config:config-item config:name=\"ShowRedlineChanges\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"ShowHeaderWhileBrowsing\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"ShowFooterWhileBrowsing\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"InBrowseMode\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item-map-indexed config:name=\"Views\">";
	print DATA "<config:config-item-map-entry>";
	print DATA "<config:config-item config:name=\"ViewId\" config:type=\"string\">view2</config:config-item>";
	print DATA "<config:config-item config:name=\"ViewLeft\" config:type=\"int\">3002</config:config-item>";
	print DATA "<config:config-item config:name=\"ViewTop\" config:type=\"int\">3002</config:config-item>";
	print DATA "<config:config-item config:name=\"VisibleLeft\" config:type=\"int\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"VisibleTop\" config:type=\"int\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"VisibleRight\" config:type=\"int\">19844</config:config-item>";
	print DATA "<config:config-item config:name=\"VisibleBottom\" config:type=\"int\">10689</config:config-item>";
	print DATA "<config:config-item config:name=\"ZoomType\" config:type=\"short\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"ZoomFactor\" config:type=\"short\">100</config:config-item>";
	print DATA "<config:config-item config:name=\"IsSelectedFrame\" config:type=\"boolean\">false</config:config-item>";
	print DATA "</config:config-item-map-entry>";
	print DATA "</config:config-item-map-indexed>";
	print DATA "</config:config-item-set>";
	print DATA "<config:config-item-set config:name=\"configuration-settings\">";
	print DATA "<config:config-item config:name=\"AddParaTableSpacing\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"PrintReversed\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"LinkUpdateMode\" config:type=\"short\">1</config:config-item>";
	print DATA "<config:config-item config:name=\"CharacterCompressionType\" config:type=\"short\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"PrintSingleJobs\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"UpdateFromTemplate\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"PrintPaperFromSetup\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"PrintLeftPages\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"PrintTables\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"ChartAutoUpdate\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"PrintControls\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"PrinterSetup\" config:type=\"base64Binary\">";
	print DATA "fAL+/0VQU09OIFBNLTc3MEMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARVBTT04gUE0tNzcwQwAAAAAAAAAAAAAAAAAAAAAAAAAWAAEAwgEAAAAAAAABAAhSAAAEdAAAM1ROVwEACABFUFNPTiBQTS03NzBDAAAAAAAAAAAAAAAAAAAAAAAAAAAEJAKUACYBD4uABwEACQCaCzQIAAABAAcAaAECAAAAaAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAABAAAAIQEAAAAAAAAAAAAARExMTmFtZTE2PUVQSUdVSjNRLkRMTAAAAAAAAAAAAABETExOYW1lMzI9RVBJREEyMzAuRExMAAAAAAAAAAAAAEVQU09OIFBNLTc3MEMAAAAAAAAAAAAAAAAAAAAAAAAAAAMCAGgBaAEBAAAAAAAAAAABAAAJAEwLgQ9MC4EPZABoAWgBoAtxECoAKgAqAMYAoAtxECoAKgAqAMYAAAAAABQAAAAAAAAAAAAyAAAA/wAAAAAAAAAAAAAAAAABAAAAAAACAAAAAgAAAAEAAQAGAAYAAgAAAAAAAAACAAAAAAAAAAAAAAAAAAUAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0CJoLAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA</config:config-item>";
	print DATA "<config:config-item config:name=\"PrintAnnotationMode\" config:type=\"short\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"ApplyUserData\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"FieldAutoUpdate\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"SaveVersionOnClose\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"SaveGlobalDocumentLinks\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"IsKernAsianPunctuation\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"AlignTabStopPosition\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"CurrentDatabaseDataSource\" config:type=\"string\"/>";
	print DATA "<config:config-item config:name=\"PrinterName\" config:type=\"string\">EPSON PM-770C</config:config-item>";
	print DATA "<config:config-item config:name=\"PrintFaxName\" config:type=\"string\"/>";
	print DATA "<config:config-item config:name=\"PrintRightPages\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"AddParaTableSpacingAtStart\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"PrintProspect\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"PrintGraphics\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"CurrentDatabaseCommandType\" config:type=\"int\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"PrintPageBackground\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"CurrentDatabaseCommand\" config:type=\"string\"/>";
	print DATA "<config:config-item config:name=\"PrintDrawings\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"PrintBlackFonts\" config:type=\"boolean\">false</config:config-item>";
	print DATA "</config:config-item-set>";
	print DATA "</office:settings>";
	print DATA "</office:document-settings>";
    } elsif ($type eq "sxc") {
	print DATA "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	
	print DATA "<!DOCTYPE office:document-settings PUBLIC \"-//OpenOffice.org//DTD OfficeDocument 1.0//EN\" \"office.dtd\">";
	
	print DATA "<office:document-settings xmlns:office=\"http://openoffice.org/2000/office\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:config=\"http://openoffice.org/2001/config\" office:version=\"1.0\">";
	
	print DATA "<office:settings>";
	
	print DATA "<config:config-item-set config:name=\"view-settings\">";
	print DATA "<config:config-item config:name=\"VisibleAreaTop\" config:type=\"int\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"VisibleAreaLeft\" config:type=\"int\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"VisibleAreaWidth\" config:type=\"int\">2258</config:config-item>";
	print DATA "<config:config-item config:name=\"VisibleAreaHeight\" config:type=\"int\">451</config:config-item>";
	print DATA "<config:config-item-map-indexed config:name=\"Views\">";
	print DATA "<config:config-item-map-entry>";
	print DATA "<config:config-item config:name=\"ViewId\" config:type=\"string\">View1</config:config-item>";
	print DATA "<config:config-item-map-named config:name=\"Tables\">";
	print DATA "<config:config-item-map-entry config:name=\"Sheet1\">";
	print DATA "<config:config-item config:name=\"CursorPositionX\" config:type=\"int\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"CursorPositionY\" config:type=\"int\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"HorizontalSplitMode\" config:type=\"short\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"VerticalSplitMode\" config:type=\"short\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"HorizontalSplitPosition\" config:type=\"int\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"VerticalSplitPosition\" config:type=\"int\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"ActiveSplitRange\" config:type=\"short\">2</config:config-item>";
	print DATA "<config:config-item config:name=\"PositionLeft\" config:type=\"int\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"PositionRight\" config:type=\"int\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"PositionTop\" config:type=\"int\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"PositionBottom\" config:type=\"int\">0</config:config-item>";
	print DATA "</config:config-item-map-entry>";
	print DATA "</config:config-item-map-named>";
	print DATA "<config:config-item config:name=\"ActiveTable\" config:type=\"string\">";
	print DATA "Sheet1</config:config-item>";
	print DATA "<config:config-item config:name=\"HorizontalScrollbarWidth\" config:type=\"int\">270</config:config-item>";
	print DATA "<config:config-item config:name=\"ZoomType\" config:type=\"short\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"ZoomValue\" config:type=\"int\">100</config:config-item>";
	print DATA "<config:config-item config:name=\"PageViewZoomValue\" config:type=\"int\">60</config:config-item>";
	print DATA "<config:config-item config:name=\"ShowPageBreakPreview\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"ShowZeroValues\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"ShowNotes\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"ShowGrid\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"GridColor\" config:type=\"long\">12632256</config:config-item>";
	print DATA "<config:config-item config:name=\"ShowPageBreaks\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"HasColumnRowHeaders\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"HasSheetTabs\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"IsOutlineSymbolsSet\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"IsSnapToRaster\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"RasterIsVisible\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"RasterResolutionX\" config:type=\"int\">1000</config:config-item>";
	print DATA "<config:config-item config:name=\"RasterResolutionY\" config:type=\"int\">1000</config:config-item>";
	print DATA "<config:config-item config:name=\"RasterSubdivisionX\" config:type=\"int\">1</config:config-item>";
	print DATA "<config:config-item config:name=\"RasterSubdivisionY\" config:type=\"int\">1</config:config-item>";
	print DATA "<config:config-item config:name=\"IsRasterAxisSynchronized\" config:type=\"boolean\">true</config:config-item>";
	print DATA "</config:config-item-map-entry>";
	print DATA "</config:config-item-map-indexed>";
	print DATA "</config:config-item-set>";
	print DATA "<config:config-item-set config:name=\"configuration-settings\">";
	print DATA "<config:config-item config:name=\"ShowZeroValues\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"ShowNotes\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"ShowGrid\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"GridColor\" config:type=\"long\">12632256</config:config-item>";
	print DATA "<config:config-item config:name=\"ShowPageBreaks\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"LinkUpdateMode\" config:type=\"short\">3</config:config-item>";
	print DATA "<config:config-item config:name=\"HasColumnRowHeaders\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"HasSheetTabs\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"IsOutlineSymbolsSet\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"IsSnapToRaster\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"RasterIsVisible\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"RasterResolutionX\" config:type=\"int\">1000</config:config-item>";
	print DATA "<config:config-item config:name=\"RasterResolutionY\" config:type=\"int\">1000</config:config-item>";
	print DATA "<config:config-item config:name=\"RasterSubdivisionX\" config:type=\"int\">1</config:config-item>";
	print DATA "<config:config-item config:name=\"RasterSubdivisionY\" config:type=\"int\">1</config:config-item>";
	print DATA "<config:config-item config:name=\"IsRasterAxisSynchronized\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"AutoCalculate\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"PrinterName\" config:type=\"string\">EPSON PM-770C</config:config-item>";
	print DATA "<config:config-item config:name=\"PrinterSetup\" config:type=\"base64Binary\">";
	print DATA "fAL+/0VQU09OIFBNLTc3MEMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARVBTT04gUE0tNzcwQwAAAAAAAAAAAAAAAAAAAAAAAAAWAAEAwgEAAAAAAAABAAhSAAAEdAAAM1ROVwEACABFUFNPTiBQTS03NzBDAAAAAAAAAAAAAAAAAAAAAAAAAAAEJAKUACYBD4uABwEACQCaCzQIAAABAAcAaAECAAAAaAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAABAAAAIQEAAAAAAAAAAAAARExMTmFtZTE2PUVQSUdVSjNRLkRMTAAAAAAAAAAAAABETExOYW1lMzI9RVBJREEyMzAuRExMAAAAAAAAAAAAAEVQU09OIFBNLTc3MEMAAAAAAAAAAAAAAAAAAAAAAAAAAAMCAGgBaAEBAAAAAAAAAAABAAAJAEwLgQ9MC4EPZABoAWgBoAtxECoAKgAqAMYAoAtxECoAKgAqAMYAAAAAABQAAAAAAAAAAAAyAAAA/wAAAAAAAAAAAAAAAAABAAAAAAACAAAAAgAAAAEAAQAGAAYAAgAAAAAAAAACAAAAAAAAAAAAAAAAAAUAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0CJoLAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA</config:config-item>";
	print DATA "<config:config-item config:name=\"ApplyUserData\" config:type=\"boolean\">true</config:config-item>";
	print DATA "<config:config-item config:name=\"CharacterCompressionType\" config:type=\"short\">0</config:config-item>";
	print DATA "<config:config-item config:name=\"IsKernAsianPunctuation\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"SaveVersionOnClose\" config:type=\"boolean\">false</config:config-item>";
	print DATA "<config:config-item config:name=\"UpdateFromTemplate\" config:type=\"boolean\">false</config:config-item>";
	print DATA "</config:config-item-set>";
	print DATA "</office:settings>";
	print DATA "</office:document-settings>";
    }
    close(DATA);
}

sub oooWriteManifest {
    # Writes the META-INF/manifest.xml file
    my($manfile, $builddir, $type);
    ($builddir, $type) = @_;
    unless($builddir) {return;}

    unless (-d "$builddir/META-INF") {
	mkdir("$builddir/META-INF");
    }
    $manfile = "$builddir/META-INF/manifest.xml";
    
    open(DATA, "> $manfile");

    print DATA "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    
    # DOCTYPE line
    print DATA "<!DOCTYPE manifest:manifest PUBLIC \"-//OpenOffice.org//DTD Manifest 1.0//EN\" \"Manifest.dtd\">\n";
    
    # Reading information
    print DATA "<manifest:manifest xmlns:manifest=\"http://openoffice.org/2001/manifest\">\n";
    
    # Mime type
    if ($type eq "sxw") {
	print DATA "<manifest:file-entry manifest:media-type=\"application/vnd.sun.xml.writer\" manifest:full-path=\"/\"/>\n";
    } elsif ($type eq "sxc") {
	print DATA " <manifest:file-entry manifest:media-type=\"application/vnd.sun.xml.calc\" manifest:full-path=\"/\"/>\n";
    }
    
    # For pictures
    print DATA " <manifest:file-entry manifest:media-type=\"\" manifest:full-path=\"Pictures/\"/>\n";
    
    # Contents File
    print DATA " <manifest:file-entry manifest:media-type=\"text/xml\" manifest:full-path=\"content.xml\"/>\n";
    
    # Styles File
    print DATA " <manifest:file-entry manifest:media-type=\"text/xml\" manifest:full-path=\"styles.xml\"/>\n";
    
    # Meta File
    print DATA " <manifest:file-entry manifest:media-type=\"text/xml\" manifest:full-path=\"meta.xml\"/>\n";
    
    # Settings File
    print DATA " <manifest:file-entry manifest:media-type=\"text/xml\" manifest:full-path=\"settings.xml\"/>\n";
    
    # End of file
    print DATA "</manifest:manifest>\n";
}

sub oooTimeStamp {
    # Returns a timestamp of the form yyyy-mm-ddThh:mm:ss
    my($datestamp);
    my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime(time);
    $datestamp = sprintf("%04d-%02d-%02dT%02d:%02d:%02d",
			 $year+1900,$mon+1,$mday,$hour,$min,$sec);
    return $datestamp;
}

sub oooDateTime {
    # Returns the date and time: yyyy, mm, dd, hh, mm, ss
    my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime(time);
    return ($year+1900,$mon+1,$mday,$hour,$min,$sec);
}

#####################################
# End of the ooolib.pl Perl Library #
#####################################
1;
