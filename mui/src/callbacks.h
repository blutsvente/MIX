/**
 *
 *  File:    callbacks.h
 *  Project: Mui - MIX Userinterface
 *  Author:  Alexander Bauer <Alexander.Bauer@Micronas.com>
 *
 */

#include <gtk/gtk.h>


void on_mainwin_destroy(GtkObject *object, gpointer user_data);

gboolean on_mainwin_delete_event(GtkWidget *widget, GdkEvent *event, gpointer user_data);

void on_new_file_item(GtkMenuItem *menuitem, gpointer user_data);

void on_open_file_item(GtkMenuItem *menuitem, gpointer user_data);

void on_save_file_item(GtkMenuItem *menuitem, gpointer user_data);

void on_save_file_as_item(GtkMenuItem *menuitem, gpointer user_data);

void on_app_quit_item(GtkMenuItem *menuitem, gpointer user_data);

void on_preferences_item(GtkMenuItem *menuitem, gpointer user_data);

void on_about_item(GtkMenuItem *menuitem, gpointer user_data);

void on_usage1_activate(GtkMenuItem *menuitem, gpointer user_data);

void on_new_file_btn(GtkButton *btn, gpointer user_data);

void on_open_file_btn(GtkButton *btn, gpointer user_data);

void on_save_file_btn(GtkButton *btn, gpointer user_data);

void on_save_file_as_btn(GtkButton *btn, gpointer user_data);

void on_run_btn(GtkButton *btn, gpointer user_data);

void on_editor_btn(GtkButton *btn, gpointer user_data);

void on_spreadsheet_btn(GtkButton *btn, gpointer user_data);

void on_preferences_btn(GtkButton *btn, gpointer user_data);

void on_notebook_switch_page(GtkNotebook *notebook, GtkNotebookPage *page, guint page_num, gpointer user_data);

void on_strip_toggled(GtkToggleButton *btn, gpointer user_data);

void on_bak_toggled(GtkToggleButton *btn, gpointer user_data);

void on_dump_toggled(GtkToggleButton *btn, gpointer user_data);

void on_verbose_toggled(GtkToggleButton *btn, gpointer user_data);

void on_delta_toggled(GtkToggleButton *btn, gpointer user_data);

void on_combine_toggled(GtkToggleButton *btn, gpointer user_data);

void on_title_label_box_size_allocate(GtkWidget *widget, GdkRectangle *allocation, gpointer user_data);

void on_mixpath_btn_clicked(GtkButton *button, gpointer user_data);

void on_editorpath_btn_clicked(GtkButton *btn, gpointer user_data);

void on_mixLog_cancel_btn_clicked(GtkButton *btn, gpointer user_data);

void on_mixLog_ok_btn_clicked(GtkButton *btn, gpointer user_data);

void on_hierTreeview_selection_received(GtkWidget *widget, GtkSelectionData *data, guint time, gpointer user_data);

void on_variEntry_changed(GtkEditable *editable, gpointer user_data);

void on_instEntry_changed(GtkEditable *editable, gpointer user_data);

void on_entityEntry_changed(GtkEditable *editable, gpointer user_data);

void on_configEntry_changed(GtkEditable *editable, gpointer user_data);

void on_commentEntry_changed(GtkEditable *editable, gpointer user_data);

void on_mdeParentEntry_changed(GtkEditable *editable, gpointer user_data);

void on_mdeInstEntry_changed(GtkEditable *editable, gpointer user_data);

void on_mdeEntityEntry_changed(GtkEditable *editable, gpointer user_data);

void on_genEntry_changed(GtkEditable *editable, gpointer user_data);

void on_ignoreCheckbutton_toggled(GtkToggleButton *togglebutton, gpointer user_data);

void on_langComboEntry_changed(GtkEntry *entry, gpointer user_data);

void hier_edited_callback(GtkCellRendererText *cell, gchar *path_string, gchar *new_text, gpointer user_data);

void conn_edited_callback(GtkCellRendererText *cell, gchar *path_string, gchar *new_text, gpointer user_data);

void iopad_edited_callback(GtkCellRendererText *cell, gchar *path_string, gchar *new_text, gpointer user_data);

void i2c_edited_callback(GtkCellRendererText *cell, gchar *path_string, gchar *new_text, gpointer user_data);
