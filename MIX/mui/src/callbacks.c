/**
 *
 *  File:    callbacks.c
 *  Project: Mui - MIX Userinterface
 *  Author:  Alexander Bauer <Alexander.Bauer@Micronas.com>
 *
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include "mainwindow.h"
#include "settings.h"
#include "support.h"
#include "callbacks.h"


void on_mainwin_destroy(GtkObject *object, gpointer user_data)
{

}

gboolean on_mainwin_delete_event(GtkWidget *widget, GdkEvent *event, gpointer user_data)
{
  return FALSE;
}

void on_new_file_item(GtkMenuItem *menuitem, gpointer user_data)
{
    if(create_file_dialog("New Project") != NULL) {
	// TODO: create new project
    }
}

void on_open_file_item(GtkMenuItem *menuitem, gpointer user_data)
{
    if(create_file_dialog("Open File") != NULL) {
	// TODO: open file
    }
}

void on_save_file_item(GtkMenuItem *menuitem, gpointer user_data)
{
    // TODO: save file
}

void on_save_file_as_item(GtkMenuItem *menuitem, gpointer user_data)
{
    if(create_file_dialog("Save File As") != NULL) {
	// TODO: save file under name 
    }
}

void on_app_quit_item(GtkMenuItem *menuitem, gpointer user_data)
{

}

void on_preferences_btn(GtkMenuItem *menuitem, gpointer user_data)
{
    show_preferences();
}

void on_about_item(GtkMenuItem *menuitem, gpointer user_data)
{
    create_about_dialog();
}

void on_usage1_activate(GtkMenuItem *menuitem, gpointer user_data)
{

}

void on_new_file_btn(GtkButton *button, gpointer user_data)
{
    if(create_file_dialog("New Project") != NULL) {
	// TODO: create new project
    }
}

void on_open_file_btn(GtkButton *button, gpointer user_data)
{
    if(create_file_dialog("Open Project") != NULL) {
	// TODO: open a project
    }
}

void on_save_file_btn(GtkButton *button, gpointer user_data)
{
    // TODO: save file
}

void on_save_file_as_btn(GtkButton *button, gpointer user_data)
{
    if(create_file_dialog("Save File As") != NULL) {
	// TODO: save file under name 
    }
}

void on_run_btn(GtkButton *button, gpointer user_data)
{

}

void on_editor_btn(GtkButton *button, gpointer user_data)
{

}

void on_spreadsheet_btn(GtkButton *button, gpointer user_data)
{

}

void on_strip_toggled(GtkToggleButton *togglebutton, gpointer user_data)
{

}

void on_bak_toggled(GtkToggleButton *togglebutton, gpointer user_data)
{

}

void on_dump_toggled(GtkToggleButton *togglebutton, gpointer user_data)
{

}

void on_verbose_toggled(GtkToggleButton *togglebutton, gpointer user_data)
{

}

void on_delta_toggled(GtkToggleButton *togglebutton, gpointer user_data)
{

}

void on_combine_toggled(GtkToggleButton *togglebutton, gpointer user_data)
{

}

void on_title_label_box_size_allocate(GtkWidget *widget, GdkRectangle *allocation, gpointer user_data)
{

}

void on_mixpath_btn_clicked(GtkButton *button, gpointer user_data)
{
    const char* path;
    if((path = create_directory_dialog())!=NULL) {
	GtkWidget *textentry;
	textentry = lookup_widget(get_preferences(), ("entry2"));
	gtk_entry_set_text((GtkEntry*)textentry, (const gchar*)path);
    }
}

void on_editor_btn_clicked(GtkButton *button, gpointer user_data)
{

    const char* path;
    if((path = create_file_dialog("select Program"))!=NULL) {
	GtkWidget *textentry;
	textentry = lookup_widget(get_preferences(), ("entry6"));
	gtk_entry_set_text((GtkEntry*)textentry, (const gchar*)path);
    }
}

void on_sheetedit_btn_clicked(GtkButton *button, gpointer user_data)
{
    const char* path;
    if((path = create_file_dialog("select Program"))!=NULL) {
	GtkWidget *textentry;
	textentry = lookup_widget(get_preferences(), ("entry7"));
	gtk_entry_set_text((GtkEntry*)textentry, (const gchar*)path);
    }
}

void on_mixLog_cancel_button_clicked(GtkButton *button, gpointer user_data)
{

}

void on_mixLog_ok_button_clicked(GtkButton *button, gpointer user_data)
{

}
