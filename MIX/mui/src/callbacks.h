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
 * File: callbacks.h - callback functions for GUI elements
 * Project: Mui - Mix Userinterface
 * Author: Alexander Bauer, ifw02024@cd.fhm.edu
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

void on_preferences_button(GtkMenuItem *menuitem, gpointer user_data);

void on_about_item(GtkMenuItem *menuitem, gpointer user_data);

void on_usage1_activate(GtkMenuItem *menuitem, gpointer user_data);

void on_new_file_button(GtkButton *button, gpointer user_data);

void on_open_file_button(GtkButton *button, gpointer user_data);

void on_save_file_button(GtkButton *button, gpointer user_data);

void on_save_file_as_button(GtkButton *button, gpointer user_data);

void on_run_button(GtkButton *button, gpointer user_data);

void on_editor_button(GtkButton *button, gpointer user_data);

void on_sheeteditor_button(GtkButton *button, gpointer user_data);

void on_input_clicked(GtkButton *button, gpointer user_data);

void on_select_clicked(GtkButton *button, gpointer user_data);

void on_import_toggled(GtkButton *button, gpointer user_data);

void on_list_configuration_button(GtkButton *button, gpointer user_data);

void on_target_button(GtkButton *button, gpointer user_data);

void on_leafcell_dir_button(GtkButton *button, gpointer user_data);

void on_combine_toggled(GtkToggleButton *togglebutton, gpointer user_data);

void on_strip_toggled(GtkToggleButton *togglebutton, gpointer user_data);

void on_bak_toggled(GtkToggleButton *togglebutton, gpointer user_data);

void on_dump_toggled(GtkToggleButton *togglebutton, gpointer user_data);

void on_verbose_toggled(GtkToggleButton *togglebutton, gpointer user_data);

void on_delta_toggled(GtkToggleButton *togglebutton, gpointer user_data);

void on_title_label_box_size_allocate(GtkWidget *widget, GdkRectangle *allocation, gpointer user_data);

void select_mixpath_button_clicked(GtkButton *button, gpointer user_data);

void select_editor_button_clicked(GtkButton *button, gpointer user_data);

void select_sheetedit_button_clicked(GtkButton *button, gpointer user_data);

void preferences_cancel_clicked(GtkButton *button, gpointer user_data);

void preferences_apply_clicked(GtkButton *button, gpointer user_data);

void preferences_ok_clicked(GtkButton *button, gpointer user_data);

void on_mixLog_cancel_button_clicked(GtkButton *button, gpointer user_data);

void on_mixLog_ok_button_clicked(GtkButton *button, gpointer user_data);
