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
 * File: user-interface.c - functions for building GUI elements
 * Project: Mui - Mix Userinterface
 * Author: Alexander Bauer, ifw02024@cd.fhm.edu
 *
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <sys/types.h>
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>

#include <gdk/gdkkeysyms.h>
#include <gtk/gtk.h>

#include "callbacks.h"
#include "user-interface.h"
#include "mix-interface.h"
#include "support.h"
#include "files.h"

#define GLADE_HOOKUP_OBJECT(component,widget,name) \
  g_object_set_data_full (G_OBJECT (component), name, \
    gtk_widget_ref (widget), (GDestroyNotify) gtk_widget_unref)

#define GLADE_HOOKUP_OBJECT_NO_REF(component,widget,name) \
  g_object_set_data (G_OBJECT (component), name, widget)

GtkWidget* create_mui(void) {
  GtkWidget *mui;
  GtkWidget *vbox2;
  GtkWidget *menubar1;
  GtkWidget *file_menu;
  GtkWidget *file_menu_menu;
  GtkWidget *new_file;
  GtkWidget *image224;
  GtkWidget *open_file;
  GtkWidget *image225;
  GtkWidget *save_file;
  GtkWidget *image226;
  GtkWidget *save_file_as;
  GtkWidget *image227;
  GtkWidget *before_history_item;
  GtkWidget *after_history_item;
  GtkWidget *quit1;
  GtkWidget *image228;
  GtkWidget *options1;
  GtkWidget *options1_menu;
  GtkWidget *preferences1;
  GtkWidget *image229;
  GtkWidget *help1;
  GtkWidget *help1_menu;
  GtkWidget *about1;
  GtkWidget *image230;
  GtkWidget *usage1;
  GtkWidget *image231;
  GtkWidget *toolbar1;
  GtkWidget *new_file_button;
  GtkWidget *open_file_button;
  GtkWidget *save_button;
  GtkWidget *save_as_button;
  GtkWidget *run_button;
  GtkWidget *tmp_toolbar_icon;
  GtkWidget *editor_button;
  GtkWidget *sheetedit_button;
  GtkWidget *fixed1;
  GtkWidget *list_input_entry;
  GtkWidget *list_import_entry;
  GtkWidget *button21;
  GtkWidget *radiobutton2;
  GSList *radiobutton2_group = NULL;
  GtkWidget *radiobutton1;
  GtkWidget *button22;
  GtkWidget *frame10;
  GtkWidget *fixed5;
  GtkWidget *entry5;
  GtkWidget *combo1;
  GList *combo1_items = NULL;
  GtkWidget *combo_entry1;
  GtkWidget *entry8;
  GtkWidget *combinebutton;
  GtkWidget *target_button;
  GtkWidget *leafcell_button;
  GtkWidget *label28;
  GtkWidget *label23;
  GtkWidget *label21;
  GtkWidget *label20;
  GtkWidget *frame9;
  GtkWidget *fixed2;
  GtkWidget *stripbutton;
  GtkWidget *bakbutton;
  GtkWidget *dumpbutton;
  GtkWidget *verbosebutton;
  GtkWidget *deltabutton;
  GtkWidget *label22;
  GtkObject *dbgLevelButton_adj;
  GtkWidget *dbgLevelButton;
  GtkWidget *listcfg_button;
  GtkWidget *label13;
  GtkWidget *hbox2;
  GtkWidget *frame3;
  GtkWidget *eventbox3;
  GtkWidget *modified_label;
  GtkWidget *frame8;
  GtkWidget *title_event_box;
  GtkWidget *title_hbox;
  GtkWidget *title_ellipses;
  GtkWidget *title_label_box;
  GtkWidget *title_label;
  GtkAccelGroup *accel_group;
  GtkTooltips *tooltips;

  tooltips = gtk_tooltips_new ();

  accel_group = gtk_accel_group_new ();

  mui = gtk_window_new (GTK_WINDOW_TOPLEVEL);
  gtk_widget_set_size_request (mui, 178, 0);
  gtk_window_set_title (GTK_WINDOW (mui), _("Mix - GUI"));
  gtk_window_set_default_size (GTK_WINDOW (mui), 592, 468);
  gtk_window_set_destroy_with_parent (GTK_WINDOW (mui), TRUE);

  vbox2 = gtk_vbox_new (FALSE, 0);
  gtk_widget_show (vbox2);
  gtk_container_add (GTK_CONTAINER (mui), vbox2);

  menubar1 = gtk_menu_bar_new ();
  gtk_widget_show (menubar1);
  gtk_box_pack_start (GTK_BOX (vbox2), menubar1, FALSE, FALSE, 0);

  file_menu = gtk_menu_item_new_with_mnemonic (_("_File"));
  gtk_widget_show (file_menu);
  gtk_container_add (GTK_CONTAINER (menubar1), file_menu);

  file_menu_menu = gtk_menu_new ();
  gtk_menu_item_set_submenu (GTK_MENU_ITEM (file_menu), file_menu_menu);

  new_file = gtk_image_menu_item_new_with_mnemonic (_("_New"));
  gtk_widget_show (new_file);
  gtk_container_add (GTK_CONTAINER (file_menu_menu), new_file);
  gtk_widget_add_accelerator (new_file, "activate", accel_group,
                              GDK_n, GDK_CONTROL_MASK,
                              GTK_ACCEL_VISIBLE);

  image224 = gtk_image_new_from_stock ("gtk-new", GTK_ICON_SIZE_MENU);
  gtk_widget_show (image224);
  gtk_image_menu_item_set_image (GTK_IMAGE_MENU_ITEM (new_file), image224);

  open_file = gtk_image_menu_item_new_with_mnemonic (_("_Open"));
  gtk_widget_show (open_file);
  gtk_container_add (GTK_CONTAINER (file_menu_menu), open_file);
  gtk_widget_add_accelerator (open_file, "activate", accel_group,
                              GDK_o, GDK_CONTROL_MASK,
                              GTK_ACCEL_VISIBLE);

  image225 = gtk_image_new_from_stock ("gtk-open", GTK_ICON_SIZE_MENU);
  gtk_widget_show (image225);
  gtk_image_menu_item_set_image (GTK_IMAGE_MENU_ITEM (open_file), image225);

  save_file = gtk_image_menu_item_new_with_mnemonic (_("_Save"));
  gtk_widget_show (save_file);
  gtk_container_add (GTK_CONTAINER (file_menu_menu), save_file);
  gtk_widget_add_accelerator (save_file, "activate", accel_group,
                              GDK_s, GDK_CONTROL_MASK,
                              GTK_ACCEL_VISIBLE);

  image226 = gtk_image_new_from_stock ("gtk-save", GTK_ICON_SIZE_MENU);
  gtk_widget_show (image226);
  gtk_image_menu_item_set_image (GTK_IMAGE_MENU_ITEM (save_file), image226);

  save_file_as = gtk_image_menu_item_new_with_mnemonic (_("Save-as"));
  gtk_widget_show (save_file_as);
  gtk_container_add (GTK_CONTAINER (file_menu_menu), save_file_as);

  image227 = gtk_image_new_from_stock ("gtk-save-as", GTK_ICON_SIZE_MENU);
  gtk_widget_show (image227);
  gtk_image_menu_item_set_image (GTK_IMAGE_MENU_ITEM (save_file_as), image227);

  before_history_item = gtk_menu_item_new ();
  gtk_widget_show (before_history_item);
  gtk_container_add (GTK_CONTAINER (file_menu_menu), before_history_item);
  gtk_widget_set_sensitive (before_history_item, FALSE);

  after_history_item = gtk_menu_item_new ();
  gtk_widget_show (after_history_item);
  gtk_container_add (GTK_CONTAINER (file_menu_menu), after_history_item);
  gtk_widget_set_sensitive (after_history_item, FALSE);

  quit1 = gtk_image_menu_item_new_with_mnemonic (_("_Quit"));
  gtk_widget_show (quit1);
  gtk_container_add (GTK_CONTAINER (file_menu_menu), quit1);
  gtk_widget_add_accelerator (quit1, "activate", accel_group,
                              GDK_q, GDK_CONTROL_MASK,
                              GTK_ACCEL_VISIBLE);

  image228 = gtk_image_new_from_stock ("gtk-quit", GTK_ICON_SIZE_MENU);
  gtk_widget_show (image228);
  gtk_image_menu_item_set_image (GTK_IMAGE_MENU_ITEM (quit1), image228);

  options1 = gtk_menu_item_new_with_mnemonic (_("_Options"));
  gtk_widget_show (options1);
  gtk_container_add (GTK_CONTAINER (menubar1), options1);

  options1_menu = gtk_menu_new ();
  gtk_menu_item_set_submenu (GTK_MENU_ITEM (options1), options1_menu);

  preferences1 = gtk_image_menu_item_new_with_mnemonic (_("_Preferences"));
  gtk_widget_show (preferences1);
  gtk_container_add (GTK_CONTAINER (options1_menu), preferences1);
  gtk_widget_add_accelerator (preferences1, "activate", accel_group,
                              GDK_p, GDK_CONTROL_MASK,
                              GTK_ACCEL_VISIBLE);

  image229 = gtk_image_new_from_stock ("gtk-properties", GTK_ICON_SIZE_MENU);
  gtk_widget_show (image229);
  gtk_image_menu_item_set_image (GTK_IMAGE_MENU_ITEM (preferences1), image229);

  help1 = gtk_menu_item_new_with_mnemonic (_("_Help"));
  gtk_widget_show (help1);
  gtk_container_add (GTK_CONTAINER (menubar1), help1);

  help1_menu = gtk_menu_new ();
  gtk_menu_item_set_submenu (GTK_MENU_ITEM (help1), help1_menu);

  about1 = gtk_image_menu_item_new_with_mnemonic (_("About"));
  gtk_widget_show (about1);
  gtk_container_add (GTK_CONTAINER (help1_menu), about1);
  gtk_widget_add_accelerator (about1, "activate", accel_group,
                              GDK_a, GDK_CONTROL_MASK,
                              GTK_ACCEL_VISIBLE);

  image230 = gtk_image_new_from_stock ("gtk-dialog-info", GTK_ICON_SIZE_MENU);
  gtk_widget_show (image230);
  gtk_image_menu_item_set_image (GTK_IMAGE_MENU_ITEM (about1), image230);

  usage1 = gtk_image_menu_item_new_with_mnemonic (_("_Usage"));
  gtk_widget_show (usage1);
  gtk_container_add (GTK_CONTAINER (help1_menu), usage1);
  gtk_widget_add_accelerator (usage1, "activate", accel_group,
                              GDK_u, GDK_CONTROL_MASK,
                              GTK_ACCEL_VISIBLE);

  image231 = gtk_image_new_from_stock ("gtk-help", GTK_ICON_SIZE_MENU);
  gtk_widget_show (image231);
  gtk_image_menu_item_set_image (GTK_IMAGE_MENU_ITEM (usage1), image231);

  file_dlg = gtk_file_selection_new(N_(""));
  gtk_window_set_transient_for(GTK_WINDOW(file_dlg), GTK_WINDOW(mui));
  gtk_window_set_destroy_with_parent(GTK_WINDOW(file_dlg), TRUE);
  gtk_file_selection_show_fileop_buttons(GTK_FILE_SELECTION(file_dlg));

  toolbar1 = gtk_toolbar_new ();
  gtk_widget_show (toolbar1);
  gtk_box_pack_start (GTK_BOX (vbox2), toolbar1, FALSE, FALSE, 0);
  gtk_toolbar_set_style (GTK_TOOLBAR (toolbar1), GTK_TOOLBAR_ICONS);

  new_file_button = gtk_toolbar_insert_stock (GTK_TOOLBAR (toolbar1),
                                "gtk-new",
                                _("New"),
                                NULL, NULL, NULL, -1);
  gtk_widget_show (new_file_button);

  open_file_button = gtk_toolbar_insert_stock (GTK_TOOLBAR (toolbar1),
                                "gtk-open",
                                _("Open"),
                                NULL, NULL, NULL, -1);
  gtk_widget_show (open_file_button);

  save_button = gtk_toolbar_insert_stock (GTK_TOOLBAR (toolbar1),
                                "gtk-save",
                                _("Save"),
                                NULL, NULL, NULL, -1);
  gtk_widget_show (save_button);

  save_as_button = gtk_toolbar_insert_stock (GTK_TOOLBAR (toolbar1),
                                "gtk-save-as",
                                _("Save as"),
                                NULL, NULL, NULL, -1);
  gtk_widget_show (save_as_button);

  gtk_toolbar_append_space (GTK_TOOLBAR (toolbar1));

  run_button = gtk_toolbar_insert_stock (GTK_TOOLBAR (toolbar1),
                                "gtk-execute",
                                _("Run Mix"),
                                NULL, NULL, NULL, -1);
  gtk_widget_show (run_button);

  gtk_toolbar_append_space (GTK_TOOLBAR (toolbar1));

  tmp_toolbar_icon = gtk_image_new_from_stock ("gtk-justify-left", gtk_toolbar_get_icon_size (GTK_TOOLBAR (toolbar1)));
  editor_button = gtk_toolbar_append_element (GTK_TOOLBAR (toolbar1),
                                GTK_TOOLBAR_CHILD_BUTTON,
                                NULL,
                                _("Editor"),
                                _("run Editor"), NULL,
                                tmp_toolbar_icon, NULL, NULL);
  gtk_label_set_use_underline (GTK_LABEL (((GtkToolbarChild*) (g_list_last (GTK_TOOLBAR (toolbar1)->children)->data))->label), TRUE);
  gtk_widget_show (editor_button);

  tmp_toolbar_icon = gtk_image_new_from_stock ("gtk-dnd-multiple", gtk_toolbar_get_icon_size (GTK_TOOLBAR (toolbar1)));
  sheetedit_button = gtk_toolbar_append_element (GTK_TOOLBAR (toolbar1),
                                GTK_TOOLBAR_CHILD_BUTTON,
                                NULL,
                                _("sheetedit_button"),
                                _("run Spreadsheet Editor"), NULL,
                                tmp_toolbar_icon, NULL, NULL);
  gtk_label_set_use_underline (GTK_LABEL (((GtkToolbarChild*) (g_list_last (GTK_TOOLBAR (toolbar1)->children)->data))->label), TRUE);
  gtk_widget_show (sheetedit_button);

  fixed1 = gtk_fixed_new ();
  gtk_widget_show (fixed1);
  gtk_box_pack_start (GTK_BOX (vbox2), fixed1, TRUE, TRUE, 0);

  list_input_entry = gtk_entry_new ();
  gtk_widget_show (list_input_entry);
  gtk_fixed_put (GTK_FIXED (fixed1), list_input_entry, 168, 16);
  gtk_widget_set_size_request (list_input_entry, 400, 24);
  gtk_tooltips_set_tip (tooltips, list_input_entry, _("list input Spreadsheet(s)"), NULL);

  list_import_entry = gtk_entry_new ();
  gtk_widget_show (list_import_entry);
  gtk_fixed_put (GTK_FIXED (fixed1), list_import_entry, 168, 56);
  gtk_widget_set_size_request (list_import_entry, 400, 24);
  gtk_tooltips_set_tip (tooltips, list_import_entry, _("list selected HDL file(s) to import"), NULL);

  button21 = gtk_button_new_with_mnemonic (_("input..."));
  gtk_widget_show (button21);
  gtk_fixed_put (GTK_FIXED (fixed1), button21, 104, 16);
  gtk_widget_set_size_request (button21, 60, 24);
  gtk_tooltips_set_tip (tooltips, button21, _("select input Sheet(s)"), NULL);

  radiobutton1 = gtk_radio_button_new_with_mnemonic (NULL, _("normal"));
  gtk_widget_show (radiobutton1);
  gtk_fixed_put (GTK_FIXED (fixed1), radiobutton1, 24, 18);
  gtk_widget_set_size_request (radiobutton1, 66, 20);
  gtk_tooltips_set_tip (tooltips, radiobutton1, _("use selected input Sheet(s)"), NULL);
  gtk_radio_button_set_group (GTK_RADIO_BUTTON (radiobutton1), radiobutton2_group);
  radiobutton2_group = gtk_radio_button_get_group (GTK_RADIO_BUTTON (radiobutton1));

  radiobutton2 = gtk_radio_button_new_with_mnemonic (NULL, _("import"));
  gtk_widget_show (radiobutton2);
  gtk_fixed_put (GTK_FIXED (fixed1), radiobutton2, 24, 58);
  gtk_widget_set_size_request (radiobutton2, 66, 20);
  gtk_tooltips_set_tip (tooltips, radiobutton2, _("generate Sheet from selected files"), NULL);
  gtk_radio_button_set_group (GTK_RADIO_BUTTON (radiobutton2), radiobutton2_group);
  radiobutton2_group = gtk_radio_button_get_group (GTK_RADIO_BUTTON (radiobutton2));

  button22 = gtk_button_new_with_mnemonic (_("select..."));
  gtk_widget_show (button22);
  gtk_fixed_put (GTK_FIXED (fixed1), button22, 104, 56);
  gtk_widget_set_size_request (button22, 60, 24);
  gtk_tooltips_set_tip (tooltips, button22, _("select HDL file(s)"), NULL);

  frame10 = gtk_frame_new (NULL);
  gtk_widget_show (frame10);
  gtk_fixed_put (GTK_FIXED (fixed1), frame10, 168, 176);
  gtk_widget_set_size_request (frame10, 416, 198);

  fixed5 = gtk_fixed_new ();
  gtk_widget_show (fixed5);
  gtk_container_add (GTK_CONTAINER (frame10), fixed5);

  entry5 = gtk_entry_new ();
  gtk_widget_show (entry5);
  gtk_fixed_put (GTK_FIXED (fixed5), entry5, 192, 72);
  gtk_widget_set_size_request (entry5, 208, 24);
  gtk_tooltips_set_tip (tooltips, entry5, _("select target Directory"), NULL);

  combo1 = gtk_combo_new ();
  combo1_items = g_list_append (combo1_items, "default");
  gtk_combo_set_popdown_strings (GTK_COMBO (combo1), combo1_items);
  g_object_set_data (G_OBJECT (GTK_COMBO (combo1)->popwin),
                     "GladeParentKey", combo1);
  gtk_widget_show (combo1);
  gtk_fixed_put (GTK_FIXED (fixed5), combo1, 128, 24);
  gtk_widget_set_size_request (combo1, 179, 25);

  combo_entry1 = GTK_COMBO (combo1)->entry;
  gtk_widget_show (combo_entry1);
  gtk_tooltips_set_tip (tooltips, combo_entry1, _("select build Variant"), NULL);
  gtk_entry_set_activates_default (GTK_ENTRY (combo_entry1), TRUE);

  combinebutton = gtk_check_button_new_with_mnemonic (_("combine"));
  gtk_widget_show (combinebutton);
  gtk_fixed_put (GTK_FIXED (fixed5), combinebutton, 40, 128);
  gtk_widget_set_size_request (combinebutton, 83, 20);
  gtk_tooltips_set_tip (tooltips, combinebutton, _("combine entity, architecture and configuration into one file"), NULL);

  target_button = gtk_button_new_with_mnemonic (_("select..."));
  gtk_widget_show (target_button);
  gtk_fixed_put (GTK_FIXED (fixed5), target_button, 128, 72);
  gtk_widget_set_size_request (target_button, 60, 24);
  gtk_tooltips_set_tip (tooltips, target_button, _("select target Directory"), NULL);

  leafcell_button = gtk_button_new_with_mnemonic (_("select..."));
  gtk_widget_show (leafcell_button);
  gtk_fixed_put (GTK_FIXED (fixed5), leafcell_button, 128, 112);
  gtk_widget_set_size_request (leafcell_button, 60, 24);
  gtk_tooltips_set_tip (tooltips, leafcell_button, _("select directory where leafcells are located"), NULL);

  entry8 = gtk_entry_new();
  gtk_widget_show(entry8);
  gtk_fixed_put(GTK_FIXED (fixed5), entry8, 192, 112);
  gtk_widget_set_size_request(entry8, 208, 24);

  label28 = gtk_label_new (_("leafcell Directory:"));
  gtk_widget_show (label28);
  gtk_fixed_put (GTK_FIXED (fixed5), label28, 16, 116);
  gtk_widget_set_size_request (label28, 104, 16);

  label23 = gtk_label_new (_("target Directory:"));
  gtk_widget_show (label23);
  gtk_fixed_put (GTK_FIXED (fixed5), label23, 16, 77);
  gtk_widget_set_size_request (label23, 104, 16);

  label21 = gtk_label_new (_("Variant:"));
  gtk_widget_show (label21);
  gtk_fixed_put (GTK_FIXED (fixed5), label21, 56, 29);
  gtk_widget_set_size_request (label21, 54, 16);

  label20 = gtk_label_new (_("Custom"));
  gtk_widget_show (label20);
  gtk_frame_set_label_widget (GTK_FRAME (frame10), label20);

  frame9 = gtk_frame_new (NULL);
  gtk_widget_show (frame9);
  gtk_fixed_put (GTK_FIXED (fixed1), frame9, 8, 104);
  gtk_widget_set_size_request (frame9, 156, 270);

  fixed2 = gtk_fixed_new ();
  gtk_widget_show (fixed2);
  gtk_container_add (GTK_CONTAINER (frame9), fixed2);

  stripbutton = gtk_check_button_new_with_mnemonic (_("drop old sheets"));
  gtk_widget_show (stripbutton);
  gtk_fixed_put (GTK_FIXED (fixed2), stripbutton, 8, 56);
  gtk_widget_set_size_request (stripbutton, 128, 20);
  gtk_tooltips_set_tip (tooltips, stripbutton, _("remove intermediate output"), NULL);

  bakbutton = gtk_check_button_new_with_mnemonic (_("keep old output"));
  gtk_widget_show (bakbutton);
  gtk_fixed_put (GTK_FIXED (fixed2), bakbutton, 8, 32);
  gtk_widget_set_size_request (bakbutton, 128, 20);
  gtk_tooltips_set_tip (tooltips, bakbutton, _("keep previous generated HDL output"), NULL);

  dumpbutton = gtk_check_button_new_with_mnemonic (_("dump"));
  gtk_widget_show (dumpbutton);
  gtk_fixed_put (GTK_FIXED (fixed2), dumpbutton, 8, 80);
  gtk_widget_set_size_request (dumpbutton, 64, 20);
  gtk_tooltips_set_tip (tooltips, dumpbutton, _("dump internal data (debugging only)"), NULL);

  verbosebutton = gtk_check_button_new_with_mnemonic (_("verbose"));
  gtk_widget_show (verbosebutton);
  gtk_fixed_put (GTK_FIXED (fixed2), verbosebutton, 8, 104);
  gtk_widget_set_size_request (verbosebutton, 80, 20);

  deltabutton = gtk_check_button_new_with_mnemonic (_("delta mode"));
  gtk_widget_show (deltabutton);
  gtk_fixed_put (GTK_FIXED (fixed2), deltabutton, 8, 8);
  gtk_widget_set_size_request (deltabutton, 101, 20);
  gtk_tooltips_set_tip (tooltips, deltabutton, _("enable delta mode"), NULL);

  label22 = gtk_label_new (_("Debug level:"));
  gtk_widget_show (label22);
  gtk_fixed_put (GTK_FIXED (fixed2), label22, 8, 144);
  gtk_widget_set_size_request (label22, 84, 16);

  dbgLevelButton_adj = gtk_adjustment_new (0, 0, 99, 1, 10, 10);
  dbgLevelButton = gtk_spin_button_new (GTK_ADJUSTMENT (dbgLevelButton_adj), 1, 0);
  gtk_widget_show (dbgLevelButton);
  gtk_fixed_put (GTK_FIXED (fixed2), dbgLevelButton, 96, 144);
  gtk_widget_set_size_request (dbgLevelButton, 39, 24);
  gtk_tooltips_set_tip (tooltips, dbgLevelButton, _("set Debug level"), NULL);
  gtk_spin_button_set_numeric (GTK_SPIN_BUTTON (dbgLevelButton), TRUE);

  listcfg_button = gtk_button_new_with_mnemonic (_("list config"));
  gtk_widget_show (listcfg_button);
  gtk_fixed_put (GTK_FIXED (fixed2), listcfg_button, 40, 208);
  gtk_widget_set_size_request (listcfg_button, 76, 27);
  gtk_tooltips_set_tip (tooltips, listcfg_button, _("print all predefined configuration options"), NULL);

  label13 = gtk_label_new (_("Debugging"));
  gtk_widget_show (label13);
  gtk_frame_set_label_widget (GTK_FRAME (frame9), label13);

  hbox2 = gtk_hbox_new (FALSE, 1);
  gtk_widget_show (hbox2);
  gtk_box_pack_start (GTK_BOX (vbox2), hbox2, FALSE, TRUE, 0);
  gtk_container_set_border_width (GTK_CONTAINER (hbox2), 2);

  frame3 = gtk_frame_new (NULL);
  gtk_widget_show (frame3);
  gtk_box_pack_start (GTK_BOX (hbox2), frame3, FALSE, TRUE, 0);
  gtk_frame_set_shadow_type (GTK_FRAME (frame3), GTK_SHADOW_IN);

  eventbox3 = gtk_event_box_new ();
  gtk_widget_show (eventbox3);
  gtk_container_add (GTK_CONTAINER (frame3), eventbox3);
  gtk_tooltips_set_tip (tooltips, eventbox3, _("File modified"), NULL);

  modified_label = gtk_label_new (_("*"));
  gtk_widget_show (modified_label);
  gtk_container_add (GTK_CONTAINER (eventbox3), modified_label);
  gtk_misc_set_padding (GTK_MISC (modified_label), 1, 0);

  frame8 = gtk_frame_new (NULL);
  gtk_widget_show (frame8);
  gtk_box_pack_start (GTK_BOX (hbox2), frame8, TRUE, TRUE, 0);
  gtk_frame_set_shadow_type (GTK_FRAME (frame8), GTK_SHADOW_IN);

  title_event_box = gtk_event_box_new ();
  gtk_widget_show (title_event_box);
  gtk_container_add (GTK_CONTAINER (frame8), title_event_box);

  title_hbox = gtk_hbox_new (FALSE, 2);
  gtk_widget_show (title_hbox);
  gtk_container_add (GTK_CONTAINER (title_event_box), title_hbox);
  gtk_container_set_border_width (GTK_CONTAINER (title_hbox), 2);

  title_ellipses = gtk_label_new (_("<"));
  gtk_widget_show (title_ellipses);
  gtk_box_pack_start (GTK_BOX (title_hbox), title_ellipses, FALSE, FALSE, 0);

  title_label_box = gtk_layout_new (NULL, NULL);
  gtk_widget_show (title_label_box);
  gtk_box_pack_start (GTK_BOX (title_hbox), title_label_box, TRUE, TRUE, 0);
  gtk_layout_set_size (GTK_LAYOUT (title_label_box), 1, 1);
  GTK_ADJUSTMENT (GTK_LAYOUT (title_label_box)->hadjustment)->step_increment = 0;
  GTK_ADJUSTMENT (GTK_LAYOUT (title_label_box)->vadjustment)->step_increment = 0;

  title_label = gtk_label_new (_("(Untitled)"));
  gtk_widget_show (title_label);
  gtk_layout_put (GTK_LAYOUT (title_label_box), title_label, 0, 0);
  gtk_widget_set_size_request (title_label, 0, 0);

  g_signal_connect ((gpointer) mui, "destroy",
                    G_CALLBACK (on_mainwin_destroy),
                    NULL);
  g_signal_connect ((gpointer) mui, "delete_event",
                    G_CALLBACK (on_mainwin_delete_event),
                    NULL);
  g_signal_connect ((gpointer) new_file, "activate",
                    G_CALLBACK (on_new_file_item),
                    NULL);
  g_signal_connect ((gpointer) open_file, "activate",
                    G_CALLBACK (on_open_file_item),
                    NULL);
  g_signal_connect ((gpointer) save_file, "activate",
                    G_CALLBACK (on_save_file_item),
                    NULL);
  g_signal_connect ((gpointer) save_file_as, "activate",
                    G_CALLBACK (on_save_file_as_item),
                    NULL);
  g_signal_connect ((gpointer) quit1, "activate",
                    G_CALLBACK (on_app_quit_item),
                    NULL);
  g_signal_connect ((gpointer) preferences1, "activate",
                    G_CALLBACK (on_preferences_button),
                    NULL);
  g_signal_connect ((gpointer) about1, "activate",
                    G_CALLBACK (on_about_item),
                    NULL);
  g_signal_connect ((gpointer) usage1, "activate",
                    G_CALLBACK (on_usage1_activate),
                    NULL);
  g_signal_connect ((gpointer) new_file_button, "clicked",
                    G_CALLBACK (on_new_file_button),
                    NULL);
  g_signal_connect ((gpointer) open_file_button, "clicked",
                    G_CALLBACK (on_open_file_button),
                    NULL);
  g_signal_connect ((gpointer) save_button, "clicked",
                    G_CALLBACK (on_save_file_button),
                    NULL);
  g_signal_connect ((gpointer) save_as_button, "clicked",
                    G_CALLBACK (on_save_file_as_button),
                    NULL);
  g_signal_connect ((gpointer) run_button, "clicked",
                    G_CALLBACK (on_run_button),
                    NULL);
  g_signal_connect ((gpointer) editor_button, "clicked",
                    G_CALLBACK (on_editor_button),
                    NULL);
  g_signal_connect ((gpointer) sheetedit_button, "clicked",
                    G_CALLBACK (on_sheeteditor_button),
                    NULL);
  g_signal_connect ((gpointer) button21, "clicked",
                    G_CALLBACK (on_input_clicked),
                    NULL);
  g_signal_connect ((gpointer) button22, "clicked",
                    G_CALLBACK (on_select_clicked),
                    NULL);
  g_signal_connect ((gpointer) listcfg_button, "clicked",
                    G_CALLBACK (on_list_configuration_button),
                    NULL);
  g_signal_connect ((gpointer) target_button, "clicked",
                    G_CALLBACK (on_target_button),
                    NULL);
  g_signal_connect ((gpointer) radiobutton2, "toggled",
                    G_CALLBACK (on_import_toggled),
                    NULL);
  g_signal_connect ((gpointer) combinebutton, "toggled",
                    G_CALLBACK (on_combine_toggled),
                    NULL);
  g_signal_connect ((gpointer) stripbutton, "toggled",
                    G_CALLBACK (on_strip_toggled),
                    NULL);
  g_signal_connect ((gpointer) bakbutton, "toggled",
                    G_CALLBACK (on_bak_toggled),
                    NULL);
  g_signal_connect ((gpointer) dumpbutton, "toggled",
                    G_CALLBACK (on_dump_toggled),
                    NULL);
  g_signal_connect ((gpointer) verbosebutton, "toggled",
                    G_CALLBACK (on_verbose_toggled),
                    NULL);
  g_signal_connect ((gpointer) deltabutton, "toggled",
                    G_CALLBACK (on_delta_toggled),
                    NULL);
  g_signal_connect ((gpointer) title_label_box, "size_allocate",
                    G_CALLBACK (on_title_label_box_size_allocate),
                    NULL);

  /* Store pointers to all widgets, for use by lookup_widget(). */
  GLADE_HOOKUP_OBJECT_NO_REF (mui, mui, "mui");
  GLADE_HOOKUP_OBJECT (mui, vbox2, "vbox2");
  GLADE_HOOKUP_OBJECT (mui, menubar1, "menubar1");
  GLADE_HOOKUP_OBJECT (mui, file_menu, "file_menu");
  GLADE_HOOKUP_OBJECT (mui, file_menu_menu, "file_menu_menu");
  GLADE_HOOKUP_OBJECT (mui, new_file, "new_file");
  GLADE_HOOKUP_OBJECT (mui, image224, "image224");
  GLADE_HOOKUP_OBJECT (mui, open_file, "open_file");
  GLADE_HOOKUP_OBJECT (mui, image225, "image225");
  GLADE_HOOKUP_OBJECT (mui, save_file, "save_file");
  GLADE_HOOKUP_OBJECT (mui, image226, "image226");
  GLADE_HOOKUP_OBJECT (mui, save_file_as, "save_file_as");
  GLADE_HOOKUP_OBJECT (mui, image227, "image227");
  GLADE_HOOKUP_OBJECT (mui, before_history_item, "before_history_item");
  GLADE_HOOKUP_OBJECT (mui, after_history_item, "after_history_item");
  GLADE_HOOKUP_OBJECT (mui, quit1, "quit1");
  GLADE_HOOKUP_OBJECT (mui, image228, "image228");
  GLADE_HOOKUP_OBJECT (mui, options1, "options1");
  GLADE_HOOKUP_OBJECT (mui, options1_menu, "options1_menu");
  GLADE_HOOKUP_OBJECT (mui, preferences1, "preferences1");
  GLADE_HOOKUP_OBJECT (mui, image229, "image229");
  GLADE_HOOKUP_OBJECT (mui, help1, "help1");
  GLADE_HOOKUP_OBJECT (mui, help1_menu, "help1_menu");
  GLADE_HOOKUP_OBJECT (mui, about1, "about1");
  GLADE_HOOKUP_OBJECT (mui, image230, "image230");
  GLADE_HOOKUP_OBJECT (mui, usage1, "usage1");
  GLADE_HOOKUP_OBJECT (mui, image231, "image231");
  GLADE_HOOKUP_OBJECT (mui, toolbar1, "toolbar1");
  GLADE_HOOKUP_OBJECT (mui, new_file_button, "new_file_button");
  GLADE_HOOKUP_OBJECT (mui, open_file_button, "open_file_button");
  GLADE_HOOKUP_OBJECT (mui, save_button, "save_button");
  GLADE_HOOKUP_OBJECT (mui, save_as_button, "save_as_button");
  GLADE_HOOKUP_OBJECT (mui, run_button, "run_button");
  GLADE_HOOKUP_OBJECT (mui, editor_button, "editor_button");
  GLADE_HOOKUP_OBJECT (mui, sheetedit_button, "sheetedit_button");
  GLADE_HOOKUP_OBJECT (mui, fixed1, "fixed1");
  GLADE_HOOKUP_OBJECT (mui, list_input_entry, "list_input_entry");
  GLADE_HOOKUP_OBJECT (mui, list_import_entry, "list_import_entry");
  GLADE_HOOKUP_OBJECT (mui, button21, "button21");
  GLADE_HOOKUP_OBJECT (mui, radiobutton2, "radiobutton2");
  GLADE_HOOKUP_OBJECT (mui, radiobutton1, "radiobutton1");
  GLADE_HOOKUP_OBJECT (mui, button22, "button22");
  GLADE_HOOKUP_OBJECT (mui, frame10, "frame10");
  GLADE_HOOKUP_OBJECT (mui, fixed5, "fixed5");
  GLADE_HOOKUP_OBJECT (mui, entry5, "entry5");
  GLADE_HOOKUP_OBJECT (mui, combo1, "combo1");
  GLADE_HOOKUP_OBJECT (mui, combo_entry1, "combo_entry1");
  GLADE_HOOKUP_OBJECT (mui, combinebutton, "combinebutton");
  GLADE_HOOKUP_OBJECT (mui, target_button, "target_button");
  GLADE_HOOKUP_OBJECT (mui, label23, "label23");
  GLADE_HOOKUP_OBJECT (mui, label21, "label21");
  GLADE_HOOKUP_OBJECT (mui, label20, "label20");
  GLADE_HOOKUP_OBJECT (mui, frame9, "frame9");
  GLADE_HOOKUP_OBJECT (mui, fixed2, "fixed2");
  GLADE_HOOKUP_OBJECT (mui, stripbutton, "stripbutton");
  GLADE_HOOKUP_OBJECT (mui, bakbutton, "bakbutton");
  GLADE_HOOKUP_OBJECT (mui, dumpbutton, "dumpbutton");
  GLADE_HOOKUP_OBJECT (mui, verbosebutton, "verbosebutton");
  GLADE_HOOKUP_OBJECT (mui, deltabutton, "deltabutton");
  GLADE_HOOKUP_OBJECT (mui, label22, "label22");
  GLADE_HOOKUP_OBJECT (mui, dbgLevelButton, "dbgLevelButton");
  GLADE_HOOKUP_OBJECT (mui, listcfg_button, "listcfg_button");
  GLADE_HOOKUP_OBJECT (mui, label13, "label13");
  GLADE_HOOKUP_OBJECT (mui, hbox2, "hbox2");
  GLADE_HOOKUP_OBJECT (mui, frame3, "frame3");
  GLADE_HOOKUP_OBJECT (mui, eventbox3, "eventbox3");
  GLADE_HOOKUP_OBJECT (mui, modified_label, "modified_label");
  GLADE_HOOKUP_OBJECT (mui, frame8, "frame8");
  GLADE_HOOKUP_OBJECT (mui, title_event_box, "title_event_box");
  GLADE_HOOKUP_OBJECT (mui, title_hbox, "title_hbox");
  GLADE_HOOKUP_OBJECT (mui, title_ellipses, "title_ellipses");
  GLADE_HOOKUP_OBJECT (mui, title_label_box, "title_label_box");
  GLADE_HOOKUP_OBJECT (mui, title_label, "title_label");
  GLADE_HOOKUP_OBJECT_NO_REF (mui, tooltips, "tooltips");

  gtk_window_add_accel_group (GTK_WINDOW (mui), accel_group);

  return mui;
}


GtkWidget* create_preferences(void) {
  GtkWidget *preferences;
  GtkWidget *dialog_vbox3;
  GtkWidget *fixed6;
  GtkWidget *entry2;
  GtkWidget *entry6;
  GtkWidget *entry7;
  GtkWidget *label27;
  GtkWidget *label26;
  GtkWidget *label25;
  GtkWidget *select_mixpath_button;
  GtkWidget *select_editor_button;
  GtkWidget *select_sheetedit_button;
  GtkWidget *dialog_action_area3;
  GtkWidget *preferences_ok_button;
  GtkWidget *alignment6;
  GtkWidget *hbox12;
  GtkWidget *image71;
  GtkWidget *label17;
  GtkTooltips *tooltips;

  tooltips = gtk_tooltips_new ();

  preferences = gtk_dialog_new ();
  gtk_widget_set_size_request (preferences, 360, 200);
  gtk_window_set_title (GTK_WINDOW (preferences), _("Preferences"));
  gtk_window_set_resizable (GTK_WINDOW (preferences), FALSE);
  gtk_window_set_destroy_with_parent (GTK_WINDOW (preferences), TRUE);

  dialog_vbox3 = GTK_DIALOG (preferences)->vbox;
  gtk_widget_show (dialog_vbox3);

  fixed6 = gtk_fixed_new ();
  gtk_widget_show (fixed6);
  gtk_box_pack_start (GTK_BOX (dialog_vbox3), fixed6, TRUE, TRUE, 0);

  entry2 = gtk_entry_new ();
  gtk_widget_show (entry2);
  gtk_fixed_put (GTK_FIXED (fixed6), entry2, 96, 32);
  gtk_widget_set_size_request (entry2, 158, 24);
  gtk_tooltips_set_tip (tooltips, entry2, _("specify path where Mix resides"), NULL);

  entry6 = gtk_entry_new ();
  gtk_widget_show (entry6);
  gtk_fixed_put (GTK_FIXED (fixed6), entry6, 96, 64);
  gtk_widget_set_size_request (entry6, 158, 24);

  entry7 = gtk_entry_new ();
  gtk_widget_show (entry7);
  gtk_fixed_put (GTK_FIXED (fixed6), entry7, 96, 96);
  gtk_widget_set_size_request (entry7, 158, 24);

  label27 = gtk_label_new (_("Sheeteditor:"));
  gtk_widget_show (label27);
  gtk_fixed_put (GTK_FIXED (fixed6), label27, 8, 100);
  gtk_widget_set_size_request (label27, 79, 16);

  label26 = gtk_label_new (_("Editor:"));
  gtk_widget_show (label26);
  gtk_fixed_put (GTK_FIXED (fixed6), label26, 24, 68);
  gtk_widget_set_size_request (label26, 54, 16);

  label25 = gtk_label_new (_("Mix Path:"));
  gtk_widget_show (label25);
  gtk_fixed_put (GTK_FIXED (fixed6), label25, 16, 40);
  gtk_widget_set_size_request (label25, 66, 16);

  select_mixpath_button = gtk_button_new_with_mnemonic (_("select..."));
  gtk_widget_show (select_mixpath_button);
  gtk_fixed_put (GTK_FIXED (fixed6), select_mixpath_button, 256, 32);
  gtk_widget_set_size_request (select_mixpath_button, 60, 24);

  select_editor_button = gtk_button_new_with_mnemonic (_("select..."));
  gtk_widget_show (select_editor_button);
  gtk_fixed_put (GTK_FIXED (fixed6), select_editor_button, 256, 64);
  gtk_widget_set_size_request (select_editor_button, 60, 24);

  select_sheetedit_button = gtk_button_new_with_mnemonic (_("select..."));
  gtk_widget_show (select_sheetedit_button);
  gtk_fixed_put (GTK_FIXED (fixed6), select_sheetedit_button, 256, 96);
  gtk_widget_set_size_request (select_sheetedit_button, 60, 24);

  dialog_action_area3 = GTK_DIALOG (preferences)->action_area;
  gtk_widget_show (dialog_action_area3);
  gtk_button_box_set_layout (GTK_BUTTON_BOX (dialog_action_area3), GTK_BUTTONBOX_END);

  preferences_ok_button = gtk_button_new ();
  gtk_widget_show (preferences_ok_button);
  gtk_dialog_add_action_widget (GTK_DIALOG (preferences), preferences_ok_button, GTK_RESPONSE_OK);
  GTK_WIDGET_SET_FLAGS (preferences_ok_button, GTK_CAN_DEFAULT);

  alignment6 = gtk_alignment_new (0.5, 0.5, 0, 0);
  gtk_widget_show (alignment6);
  gtk_container_add (GTK_CONTAINER (preferences_ok_button), alignment6);

  hbox12 = gtk_hbox_new (FALSE, 2);
  gtk_widget_show (hbox12);
  gtk_container_add (GTK_CONTAINER (alignment6), hbox12);

  image71 = gtk_image_new_from_stock ("gtk-ok", GTK_ICON_SIZE_BUTTON);
  gtk_widget_show (image71);
  gtk_box_pack_start (GTK_BOX (hbox12), image71, FALSE, FALSE, 0);

  label17 = gtk_label_new_with_mnemonic (_("_OK"));
  gtk_widget_show (label17);
  gtk_box_pack_start (GTK_BOX (hbox12), label17, FALSE, FALSE, 0);

  g_signal_connect ((gpointer) select_mixpath_button, "clicked",
                    G_CALLBACK (select_mixpath_button_clicked),
                    NULL);
  g_signal_connect ((gpointer) select_editor_button, "clicked",
                    G_CALLBACK (select_editor_button_clicked),
                    NULL);
  g_signal_connect ((gpointer) select_sheetedit_button, "clicked",
                    G_CALLBACK (select_sheetedit_button_clicked),
                    NULL);

  /* Store pointers to all widgets, for use by lookup_widget(). */
  GLADE_HOOKUP_OBJECT_NO_REF (preferences, preferences, "preferences");
  GLADE_HOOKUP_OBJECT_NO_REF (preferences, dialog_vbox3, "dialog_vbox3");
  GLADE_HOOKUP_OBJECT (preferences, fixed6, "fixed6");
  GLADE_HOOKUP_OBJECT (preferences, entry2, "entry2");
  GLADE_HOOKUP_OBJECT (preferences, entry6, "entry6");
  GLADE_HOOKUP_OBJECT (preferences, entry7, "entry7");
  GLADE_HOOKUP_OBJECT (preferences, label27, "label27");
  GLADE_HOOKUP_OBJECT (preferences, label26, "label26");
  GLADE_HOOKUP_OBJECT (preferences, label25, "label25");
  GLADE_HOOKUP_OBJECT (preferences, select_mixpath_button, "select_mixpath_button");
  GLADE_HOOKUP_OBJECT (preferences, select_editor_button, "select_editor_button");
  GLADE_HOOKUP_OBJECT (preferences, select_sheetedit_button, "select_sheetedit_button");
  GLADE_HOOKUP_OBJECT_NO_REF (preferences, dialog_action_area3, "dialog_action_area3");
  GLADE_HOOKUP_OBJECT (preferences, preferences_ok_button, "preferences_ok_button");
  GLADE_HOOKUP_OBJECT (preferences, alignment6, "alignment6");
  GLADE_HOOKUP_OBJECT (preferences, hbox12, "hbox12");
  GLADE_HOOKUP_OBJECT (preferences, image71, "image71");
  GLADE_HOOKUP_OBJECT (preferences, label17, "label17");
  GLADE_HOOKUP_OBJECT_NO_REF (preferences, tooltips, "tooltips");

  return preferences;
}

GtkTextBuffer* create_mixlog(void) {
  GtkWidget *mixLog;
  GtkWidget *dialog_vbox4;
  GtkWidget *scrolledwindow1;
  GtkWidget *textview1;
  GtkTextBuffer *buffer;
  GtkWidget *dialog_action_area4;
  GtkWidget *mixLog_ok_button;

  mixLog = gtk_dialog_new ();
  gtk_window_set_title (GTK_WINDOW (mixLog), _("Mix status"));
  gtk_window_set_default_size (GTK_WINDOW (mixLog), 460, 240);
  gtk_window_set_destroy_with_parent (GTK_WINDOW (mixLog), TRUE);
  gtk_dialog_set_has_separator (GTK_DIALOG (mixLog), FALSE);

  dialog_vbox4 = GTK_DIALOG (mixLog)->vbox;
  gtk_widget_show (dialog_vbox4);

  scrolledwindow1 = gtk_scrolled_window_new (NULL, NULL);
  gtk_widget_show (scrolledwindow1);
  gtk_box_pack_start (GTK_BOX (dialog_vbox4), scrolledwindow1, TRUE, TRUE, 0);

  textview1 = gtk_text_view_new();
  gtk_widget_show (textview1);
  buffer = gtk_text_view_get_buffer (GTK_TEXT_VIEW (textview1));
  gtk_text_view_set_cursor_visible((GtkTextView*)textview1, FALSE);
  gtk_text_view_set_editable ((GtkTextView*)textview1, FALSE);
  gtk_container_add (GTK_CONTAINER (scrolledwindow1), textview1);

  dialog_action_area4 = GTK_DIALOG (mixLog)->action_area;
  gtk_widget_show (dialog_action_area4);
  gtk_button_box_set_layout (GTK_BUTTON_BOX (dialog_action_area4), GTK_BUTTONBOX_END);

  mixLog_ok_button = gtk_button_new_from_stock ("gtk-ok");
  gtk_widget_show (mixLog_ok_button);
  gtk_dialog_add_action_widget (GTK_DIALOG (mixLog), mixLog_ok_button, GTK_RESPONSE_OK);
  GTK_WIDGET_SET_FLAGS (mixLog_ok_button, GTK_CAN_DEFAULT);

  g_signal_connect_swapped ((gpointer) mixLog_ok_button, "clicked",
                    G_CALLBACK (gtk_widget_destroy),
                    GTK_OBJECT(mixLog));

  /* Store pointers to all widgets, for use by lookup_widget(). */
  GLADE_HOOKUP_OBJECT_NO_REF (mixLog, mixLog, "mixLog");
  GLADE_HOOKUP_OBJECT_NO_REF (mixLog, dialog_vbox4, "dialog_vbox4");
  GLADE_HOOKUP_OBJECT (mixLog, scrolledwindow1, "scrolledwindow1");
  GLADE_HOOKUP_OBJECT (mixLog, textview1, "textview1");
  GLADE_HOOKUP_OBJECT_NO_REF (mixLog, dialog_action_area4, "dialog_action_area4");
  GLADE_HOOKUP_OBJECT (mixLog, mixLog_ok_button, "mixLog_ok_button");

  gtk_widget_show(mixLog);
  return buffer;
}


gint create_dialog(const char *title) {

    gint response;

    gtk_window_set_title(GTK_WINDOW(file_dlg), _(title));
    response = gtk_dialog_run(GTK_DIALOG(file_dlg));
    gtk_widget_hide(file_dlg);

    return response;
}


const char* create_open_dialog(const char* title) {

    gint response;

    response = create_dialog(title);
    gtk_widget_hide(file_dlg);
    if(response == GTK_RESPONSE_OK) {
    
	const char *os_filename;
	struct stat statvar;
	os_filename = gtk_file_selection_get_filename(GTK_FILE_SELECTION(file_dlg));

	// Todo: check if file exists	if(stat(os_filename, &statvar)!=0) return NULL;

	return os_filename;
    }
    return NULL;
}


const char* create_target_dialog() {

    gint response;

    response = create_dialog("select Directory");
    if(response == GTK_RESPONSE_OK) {
	int i;
        const char *os_filename;
        os_filename = gtk_file_selection_get_filename(GTK_FILE_SELECTION(file_dlg));
	DIR* dir = opendir(os_filename);
	if(dir!=NULL) {
	    closedir(dir);
	    return os_filename;
	}
    }
    return NULL;
}
