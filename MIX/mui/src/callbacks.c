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

#include <stdio.h>
#include <string.h>

#ifdef LINUX
#  include <linux/limits.h>
#else
#  define PATH_MAX 4096
#endif

#include "mainwindow.h"
#include "hierview.h"
#include "connview.h"
#include "iopadview.h"
#include "i2cview.h"
#include "settings.h"
#include "support.h"
#include "callbacks.h"

extern GtkTreeModel *conn_model;
extern GtkTreeModel *iopad_model;
extern GtkTreeModel *i2c_model;


void on_mainwin_destroy(GtkObject *object, gpointer user_data)
{
    int stage = mix_get_stage();

    // save project if needed
    if(mix_get_modified()) {
	if(create_quest_dialog("Warning", "\n  File has been modified!  \n  Save modifications?  \n") == TRUE)
	    if(!mix_writeSpreadsheet((const char*) mix_get_filename()))
		create_info_dialog("Error", "\n  Could not save File!  \n");
    }

    if(stage > MIX_NO_INIT) {
	mix_destroy();
	if(stage > MIX_INIT)
	    mix_free_filename();
    }
    gtk_main_quit();
}

gboolean on_mainwin_delete_event(GtkWidget *widget, GdkEvent *event, gpointer user_data)
{
    return FALSE;
}

void on_new_file_item(GtkMenuItem *menuitem, gpointer user_data)
{
    if(mix_get_stage() >= MIX_READ_IN) {
	mix_free_filename();
    }

    if(create_file_dialog("New Project") != NULL) {
	// create new project
	new_project();
    }
}

void on_open_file_item(GtkMenuItem *menuitem, gpointer user_data)
{
    open_project(create_file_dialog("Open Project"));
}

void on_save_file_item(GtkMenuItem *menuitem, gpointer user_data)
{
    if(mix_get_stage() < MIX_READ_IN) return;
    if(!mix_get_modified()) return;

    // save project to spreadsheet
    mix_writeSpreadsheet((const char*) mix_get_filename());
}

void on_save_file_as_item(GtkMenuItem *menuitem, gpointer user_data)
{
    if(mix_get_stage() < MIX_READ_IN) return;

    gboolean rc;
    const gchar *name = create_file_dialog("Save File As");

    if(name != NULL) {
	// save file under name 
	rc = mix_writeSpreadsheet(name);
	if(rc == FALSE) {
	    create_info_dialog("Error", "\n  Could not save File!  \n");
	}
    }
}

void on_app_quit_item(GtkMenuItem *menuitem, gpointer user_data)
{
    int stage = mix_get_stage();

    // save project if needed
    if(mix_get_modified()) {
	if(create_quest_dialog("Warning", "\n  File has been modified!  \n  Save modifications?  \n") == TRUE)
	    if(!mix_writeSpreadsheet((const char*) mix_get_filename()))
		create_info_dialog("Error", "\n  Could not save File!  \n");
    }

    if(stage > MIX_NO_INIT) {
	mix_destroy();
	if(stage > MIX_INIT)
	    mix_free_filename();
    }
    gtk_main_quit();
}

void on_preferences_item(GtkMenuItem *menuitem, gpointer user_data)
{
    show_preferences();
}

void on_about_item(GtkMenuItem *menuitem, gpointer user_data)
{
    create_about_dialog();
}

void on_usage1_activate(GtkMenuItem *menuitem, gpointer user_data)
{
    create_info_dialog("Sorry", "\n  No Help available yet!  \n");
}

void on_new_file_btn(GtkButton *button, gpointer user_data)
{
    if(create_file_dialog("New Project") != NULL) {
	// TODO: create new project
    }
}

void on_open_file_btn(GtkButton *button, gpointer user_data)
{
    open_project(create_file_dialog("Open Project"));
}

void on_save_file_btn(GtkButton *button, gpointer user_data)
{
    if(mix_get_stage() < MIX_READ_IN) return;
    if(!mix_get_modified()) return;

    // save project to spreadsheet
    mix_writeSpreadsheet((const char*) mix_get_filename());
}

void on_save_file_as_btn(GtkButton *button, gpointer user_data)
{
    if(mix_get_stage() < MIX_READ_IN) return;

    gboolean rc;
    const gchar *name = create_file_dialog("Save Project As");

    if(name != NULL) {
	// save file under name 
	rc = mix_writeSpreadsheet(name);
	if(rc == FALSE) {
	    create_info_dialog("Error", "\n  Could not save File!  \n");
	}
    }
}

void on_run_btn(GtkButton *button, gpointer user_data)
{
    char *mix_path = get_mix_path();
    if(mix_path == NULL) {
	// display dialog box
	create_info_dialog("Information" , "\n  You will have to specify where to find MIX!  \n"
                                           "\n             Select MIX directory first\n\n");	
	return;
    }
}

void on_editor_btn(GtkButton *button, gpointer user_data)
{
    char *editor = get_editor_path();
    if(editor == NULL) {
	//  display dialog box
	create_info_dialog("Information" , "\n  You will have to selected a editor first!  \n"
			                   "\n           Select a Texteditor first\n\n");
        return;
    }
    char command[PATH_MAX];
    sprintf(command, "%s&", editor);
    system((const char*)command);
}

void on_preferences_btn(GtkButton *button, gpointer user_data)
{
    show_preferences();
}

void on_notebook_switch_page(GtkNotebook *notebook, GtkNotebookPage *page, guint page_num, gpointer user_data)
{
    // int acview = get_current_page();
    //    GtkWidget *view;
    //    if(view_modified(acview))
    // TODO: rerun MIX stage-1 if actual page is modified

    // clear actual pag
    /*    view = get_view_child(get_current_page());
    if(view != NULL)
	gtk_widget_destroy(view);*/

    // recreate new selected view on every selection
    /*    switch(page_num) {
        case 0:
	    view = (GtkWidget*) create_hier_view();
	    gtk_widget_show_all(view);
	    gtk_container_add(GTK_CONTAINER(get_view_frame(0)), view);
	    set_view_child(view, page_num);
	    break;
        case 1:
	    view = (GtkWidget*) create_conn_view();
	    gtk_widget_show_all(view);
	    gtk_container_add(GTK_CONTAINER(get_view_frame(1)), view);
	    set_view_child(view, page_num);
	    break;
        case 2:
	    view = (GtkWidget*) create_iopad_view();
	    gtk_widget_show_all(view);
	    gtk_container_add(GTK_CONTAINER(get_view_frame(2)), view);
	    set_view_child(view, page_num);
	    break;
        case 3:
	    view = (GtkWidget*) create_i2c_view();
	    gtk_widget_show_all(view);
	    gtk_container_add(GTK_CONTAINER(get_view_frame(3)), view);
	    set_view_child(view, page_num);
	    break;
        case 4:
	    break;
        default:
	    create_info_dialog("internal Error", "\n  an Error while switching to to Page!  \n");
	    }*/
    set_current_page(page_num);
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
    if((path = create_directory_dialog()) != NULL) {
	GtkWidget *textentry;
	textentry = lookup_widget((GtkWidget*) button, ("entry2"));
	gtk_entry_set_text((GtkEntry*)textentry, (const gchar*)path);
    }
}

void on_editorpath_btn_clicked(GtkButton *button, gpointer user_data)
{
    const char* path;
    if((path = create_file_dialog("select Program"))!=NULL) {
	GtkWidget *textentry;
	textentry = lookup_widget((GtkWidget*) button, ("entry6"));
	gtk_entry_set_text((GtkEntry*)textentry, (const gchar*)path);
    }
}

void on_mixLog_cancel_button_clicked(GtkButton *button, gpointer user_data)
{

}

void on_mixLog_ok_button_clicked(GtkButton *button, gpointer user_data)
{

}

void on_hierTreeview_selection_received(GtkWidget *widget, GtkSelectionData *data, guint time, gpointer user_data)
{

}

void on_variEntry_changed(GtkEditable *editable, gpointer user_data)
{
    const gchar *text = gtk_entry_get_text(GTK_ENTRY(editable));
}

void on_instEntry_changed(GtkEditable *editable, gpointer user_data)
{
    const gchar *text = gtk_entry_get_text(GTK_ENTRY(editable));
}

void on_entityEntry_changed(GtkEditable *editable, gpointer user_data)
{
    const gchar *text = gtk_entry_get_text(GTK_ENTRY(editable));
}

void on_configEntry_changed(GtkEditable *editable, gpointer user_data)
{
    const gchar *text = gtk_entry_get_text(GTK_ENTRY(editable));
}

void on_commentEntry_changed(GtkEditable *editable, gpointer user_data)
{
    const gchar *text = gtk_entry_get_text(GTK_ENTRY(editable));
}

void on_mdeParentEntry_changed(GtkEditable *editable, gpointer user_data)
{
    const gchar *text = gtk_entry_get_text(GTK_ENTRY(editable));
}

void on_mdeInstEntry_changed(GtkEditable *editable, gpointer user_data)
{
    const gchar *text = gtk_entry_get_text(GTK_ENTRY(editable));
}

void on_mdeEntityEntry_changed(GtkEditable *editable, gpointer user_data)
{
    // TODO
    const gchar *text = gtk_entry_get_text(GTK_ENTRY(editable));
}

void on_genEntry_changed(GtkEditable *editable, gpointer user_data)
{
    // TODO
    const gchar *text = gtk_entry_get_text(GTK_ENTRY(editable));
}

void on_ignoreCheckbutton_toggled(GtkToggleButton *togglebutton, gpointer user_data)
{
    // TODO: set ignore value
    gboolean value = gtk_toggle_button_get_active(togglebutton);
}

void on_langComboEntry_changed(GtkEntry *entry, gpointer user_data)
{
    // TODO: set language
    const gchar *text = gtk_entry_get_text(entry);
}

void conn_edited_callback(GtkCellRendererText *cell, gchar *path_string, gchar *new_text, gpointer user_data)
{
    char col_name[32];
    guint column = GPOINTER_TO_UINT(g_object_get_data(G_OBJECT(cell), "column_index"));
    guint row = atoi(path_string);
    GtkTreePath *path = gtk_tree_path_new_from_string (path_string);
    GtkTreeIter iter;

    // if path exists, update cell content
    if(gtk_tree_model_get_iter(conn_model, &iter, path)) {
	conn_col_index_to_name(col_name, column);
	// put content to MIX
	mix_set_conn_value(col_name, row, new_text);
	gtk_tree_store_set(GTK_TREE_STORE(conn_model), &iter, column, new_text, -1);
    }

    gtk_tree_path_free(path);
}

void iopad_edited_callback(GtkCellRendererText *cell, gchar *path_string, gchar *new_text, gpointer user_data)
{
    char col_name[32];
    guint column = GPOINTER_TO_UINT(g_object_get_data(G_OBJECT(cell), "column_index"));
    guint row = atoi(path_string);
    GtkTreePath *path = gtk_tree_path_new_from_string (path_string);
    GtkTreeIter iter;

    if(gtk_tree_model_get_iter(iopad_model, &iter, path)) {
	iopad_col_index_to_name(col_name, column);
	// put content to MIX
	mix_set_iopad_value(col_name, row, new_text);
	gtk_tree_store_set(GTK_TREE_STORE(iopad_model), &iter, column, new_text, -1);
    }
    gtk_tree_path_free(path);
}

void i2c_edited_callback(GtkCellRendererText *cell, gchar *path_string, gchar *new_text, gpointer user_data)
{
    char col_name[32];
    guint column = GPOINTER_TO_UINT(g_object_get_data(G_OBJECT(cell), "column_index"));
    guint row = atoi(path_string);
    GtkTreePath *path = gtk_tree_path_new_from_string (path_string);
    GtkTreeIter iter;

    if(gtk_tree_model_get_iter(i2c_model, &iter, path)) {
	i2c_col_index_to_name(col_name, column);
	// put content to MIX
	mix_set_i2c_value(col_name, row, new_text);
	gtk_tree_store_set(GTK_TREE_STORE(i2c_model), &iter, column, new_text, -1);
    }
    gtk_tree_path_free(path);
}
