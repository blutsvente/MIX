/* Copyright (C) 1991,92,95,96,97,98,99,2000,01 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

/**
 *
 * File: callbacks.c - callback functions for GUI elements
 * Project: Mui - Mix Userinterface
 * Author: Alexander Bauer, ifw02024@cd.fhm.edu
 *
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <gtk/gtk.h>

#include "callbacks.h"
#include "user-interface.h"
#include "mix-interface.h"
#include "support.h"


GtkWidget *preferences;


void on_mainwin_destroy(GtkObject *object, gpointer user_data) {

    /*if(modified) {
          show_quest_save_dialog();
      }*/

    gtk_main_quit();
}


gboolean on_mainwin_delete_event(GtkWidget *widget, GdkEvent *event, gpointer user_data) {
    return FALSE;
}


void on_new_file_item(GtkMenuItem *menuitem, gpointer user_data) {

}


void on_open_file_item(GtkMenuItem *menuitem, gpointer user_data) {
    const char* file = create_open_dialog("Open File");
}


void on_save_file_item(GtkMenuItem *menuitem, gpointer user_data) {

}


void on_save_file_as_item(GtkMenuItem *menuitem, gpointer user_data) {

}


void on_app_quit_item(GtkMenuItem *menuitem, gpointer user_data) {

    /*if(modified) {
          show_quest_save_dialog();
      }*/

    gtk_main_quit();
}


void on_preferences_button(GtkMenuItem *menuitem, gpointer user_data) {

    GtkWidget *mix_path_entry, *editor_path_entry, *sheetedit_path_entry;

    preferences = create_preferences();

    mix_path_entry = lookup_widget(preferences, ("entry2"));
    editor_path_entry = lookup_widget(preferences, ("entry6"));
    sheetedit_path_entry = lookup_widget(preferences, ("entry7"));

    // display paths
    gtk_entry_set_text((GtkEntry*)mix_path_entry, mix_path);
    gtk_entry_set_text((GtkEntry*)editor_path_entry, editor_path);
    gtk_entry_set_text((GtkEntry*)sheetedit_path_entry, sheetedit_path);

    if(gtk_dialog_run(GTK_DIALOG(preferences)) == GTK_RESPONSE_OK) {
	strcpy( mix_path, gtk_entry_get_text((GtkEntry*)mix_path_entry));
	strcpy( editor_path, gtk_entry_get_text((GtkEntry*)editor_path_entry));
	strcpy( sheetedit_path, gtk_entry_get_text((GtkEntry*)sheetedit_path_entry));

	save_config();
    }
    gtk_widget_destroy(preferences);
}


void on_about_item(GtkMenuItem *menuitem, gpointer user_data) {

}


void on_usage1_activate(GtkMenuItem *menuitem, gpointer user_data) {

}


void on_new_file_button(GtkButton *button, gpointer user_data) {

}


void on_open_file_button(GtkButton *button, gpointer user_data) {

    const char * file = create_open_dialog("Open File");
}


void on_save_file_button(GtkButton *button, gpointer user_data) {

}


void on_save_file_as_button(GtkButton *button, gpointer user_data) {
    create_open_dialog("Save File As");
}


void on_run_button(GtkButton *button, gpointer user_data) {

    FILE *output;
    output = run_mix();
    //    dialog_output(output);
    close(output);
}


void on_editor_button(GtkButton *button, gpointer user_data) {

    if(editor_path==NULL) {
	fprintf(stderr, "warning: no editor defined!\n");
	return;
    }
    char command[MAX_PATH_LENGTH];
    sprintf(command, "%s&", editor_path);
    system((const char*)command);
}


void on_sheeteditor_button(GtkButton *button, gpointer user_data) {

    if(sheetedit_path==NULL) {
	fprintf(stderr, "warning: no spreadsheet-editor defined!\n");
	return;
    }    
    char command[MAX_PATH_LENGTH];
    sprintf(command, "%s&", sheetedit_path);
    system((const char*)command);
}


void on_list_configuration_button(GtkButton *button, gpointer user_data) {

    if(mix_path==NULL) return;

    FILE *listing;
    char command[MAX_PATH_LENGTH];

    sprintf(command,"%s%s%s -listconf", mix_path, DIRECTORY_DELIMIT, MIX_NAME);
    listing = popen(command, "r");
    dialog_output(listing);
    close(listing);
}


void on_target_button(GtkButton *button, gpointer user_data) {

    const char *target;
    if((target = create_target_dialog())!=NULL) {
	GtkWidget *target_dir_entry = (GtkWidget*)lookup_widget(mui, ("entry5"));

	options.targetDir = target;
	gtk_entry_set_text((GtkEntry*) target_dir_entry, target);
    }
}


void on_leafcell_dir_button(GtkButton *button, gpointer user_data) {

    const char *target;
    if((target = create_target_dialog())!=NULL) {
	GtkWidget *target_dir_entry = (GtkWidget*)lookup_widget(mui, ("entry8"));

	options.leafcellDir = target;
	gtk_entry_set_text((GtkEntry*) target_dir_entry, target);
    }    
}


void on_import_toggled(GtkButton *button, gpointer user_data) {
    options.import = !options.import;
}


void on_input_clicked(GtkButton *button, gpointer user_data) {

    const char *input;
    if((input = create_open_dialog("input Spreadsheet"))!=NULL) {
	char buffer[4*MAX_PATH_LENGTH];
	strcpy(buffer, input);
	GtkWidget *input_entry = (GtkWidget*)lookup_widget(mui, ("list_input_entry"));
	input = gtk_entry_get_text((GtkEntry*) input_entry);
	sprintf(buffer, "%s %s", buffer, input);
	gtk_entry_set_text((GtkEntry*) input_entry, buffer);
    }
}


void on_select_clicked(GtkButton *button, gpointer user_data) {

    const char *import;
    if((import = create_open_dialog("import HDL File"))!=NULL) {
	char buffer[4*MAX_PATH_LENGTH];
	strcpy(buffer, import);
	GtkWidget *select_entry = (GtkWidget*)lookup_widget(mui, ("list_import_entry"));
	import = gtk_entry_get_text((GtkEntry*) select_entry);
	sprintf(buffer,"%s %s", buffer, import);
	gtk_entry_set_text((GtkEntry*) select_entry, buffer);
    }
}


void on_combine_toggled(GtkToggleButton *togglebutton, gpointer user_data) {
    options.combine = !options.combine;
}


void on_strip_toggled(GtkToggleButton *togglebutton, gpointer user_data) {
    options.strip = !options.strip;
}


void on_bak_toggled(GtkToggleButton *togglebutton, gpointer user_data) {
    options.bak = !options.bak;
}


void on_dump_toggled(GtkToggleButton *togglebutton, gpointer user_data) {
    options.dump = !options.dump;
}


void on_verbose_toggled(GtkToggleButton *togglebutton, gpointer user_data) {
    options.verbose = !options.verbose;
}


void on_delta_toggled(GtkToggleButton *togglebutton, gpointer user_data) {
    options.delta = !options.delta;
}


void on_title_label_box_size_allocate(GtkWidget *widget, GdkRectangle *allocation, gpointer user_data) {

}


void select_mixpath_button_clicked(GtkButton *button, gpointer user_data) {

    const char* path;
    if((path = create_target_dialog())!=NULL) {
	GtkWidget *textentry;
	textentry = lookup_widget(preferences, ("entry2"));
	gtk_entry_set_text((GtkEntry*)textentry, (const gchar*)path);
    }
}


void select_editor_button_clicked(GtkButton *button, gpointer user_data) {

    const char* path;
    if((path = create_open_dialog("select Program"))!=NULL) {
	GtkWidget *textentry;
	textentry = lookup_widget(preferences, ("entry6"));
	gtk_entry_set_text((GtkEntry*)textentry, (const gchar*)path);
    }
}


void select_sheetedit_button_clicked(GtkButton *button, gpointer user_data) {

    const char* path;
    if((path = create_open_dialog("select Program"))!=NULL) {
	GtkWidget *textentry;
	textentry = lookup_widget(preferences, ("entry7"));
	gtk_entry_set_text((GtkEntry*)textentry, (const gchar*)path);
    }
}


void preferences_ok_clicked(GtkButton *button, gpointer user_data) {
    /*
    GtkWidget *mix_path_entry, *editor_path_entry, *sheetedit_path_entry;

    mix_path_entry = lookup_widget(preferences, ("entry2"));
    editor_path_entry = lookup_widget(preferences, ("entry6"));
    sheetedit_path_entry = lookup_widget(preferences, ("entry7"));

    mix_path = gtk_entry_get_text((GtkEntry*)mix_path_entry);
    editor_path = gtk_entry_get_text((GtkEntry*)editor_path_entry);
    sheetedit_path = gtk_entry_get_text((GtkEntry*)sheetedit_path_entry);*/
}


void on_mixLog_ok_button_clicked(GtkButton *button, gpointer user_data) {

}

