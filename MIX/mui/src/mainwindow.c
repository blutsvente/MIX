/**
 *
 *  File:    mainwindow.c
 *  Project: Mui - MIX Userinterface
 *  Author:  Alexander Bauer <Alexander.Bauer@Micronas.com>
 *
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <dirent.h>

#include <gdk/gdkkeysyms.h>

#include "support.h"
#include "callbacks.h"
#include "mainwindow.h"


/**
 * local callback
 */
static void about_destroy(GtkWidget *w, gpointer d);

gboolean about_dialog_open = 0;
GtkWidget *file_dialog, *about_dialog;
GtkWidget *mainview[4];
GtkWidget *childview[4];

static char *about_title = "About MIX User Interface";
static char *about_text1 = "\n          Graphical MIX User Interface written by:  \n"
                             "   Alexander Bauer <alexander.bauer@micronas.com>   \n\n"
                             "   For questions on MIX contact Wilfried Gaensheimer  \n"
                             "           <wilfried.gaensheimer@micronas.com>\n";
static char *about_text2 = "See Documentation for details\n";



GtkWidget* create_MainWindow(void)
{
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
    GtkWidget *preferences;
    GtkWidget *notebook1;
    GtkWidget *vbox4;
    GtkWidget *hier_toolbar;
    GtkWidget *add_hier_button;
    GtkWidget *del_hier_button;
    GtkWidget *hpaned3;
    GtkWidget *scrolledwindow5;
    GtkWidget *label29;
    GtkWidget *vbox3;
    GtkWidget *conn_toolbar;
    GtkWidget *add_conn_button;
    GtkWidget *del_conn_button;
    GtkWidget *hpaned2;
    GtkWidget *fixed22;
    GtkWidget *scrolledwindow4;
    GtkWidget *viewport2;
    GtkWidget *label30;
    GtkWidget *vbox6;
    GtkWidget *toolbar8;
    GtkWidget *add_iopad_button;
    GtkWidget *del_iopad_button;
    GtkWidget *scrolledwindow3;
    GtkWidget *label31;
    GtkWidget *vbox5;
    GtkWidget *toolbar7;
    GtkWidget *add_i2c_regblock_button;
    GtkWidget *del_i2c_regblock_button;
    GtkWidget *scrolledwindow2;
    GtkWidget *label32;
    GtkWidget *fixed12;
    GtkWidget *frame13;
    GtkWidget *fixed13;
    GtkWidget *checkbutton7;
    GtkWidget *checkbutton8;
    GtkWidget *checkbutton9;
    GtkWidget *checkbutton10;
    GtkWidget *checkbutton11;
    GtkWidget *label43;
    GtkObject *spinbutton2_adj;
    GtkWidget *spinbutton2;
    GtkWidget *button43;
    GtkWidget *label44;
    GtkWidget *frame14;
    GtkWidget *fixed14;
    GtkWidget *entry15;
    GtkWidget *combo2;
    GtkWidget *entry16;
    GtkWidget *entry17;
    GtkWidget *label46;
    GtkWidget *checkbutton12;
    GtkWidget *label47;
    GtkWidget *label45;
    GtkWidget *button45;
    GtkWidget *button44;
    GtkWidget *label48;
    GtkWidget *label33;
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

    tooltips = gtk_tooltips_new();

    accel_group = gtk_accel_group_new();

    mui = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_widget_set_name(mui, "mui");
    gtk_widget_set_size_request(mui, 178, 0);
    gtk_window_set_title( GTK_WINDOW(mui), "MIX - GUI");
    gtk_window_set_default_size( GTK_WINDOW(mui), 592, 468);
    gtk_window_set_destroy_with_parent( GTK_WINDOW(mui), TRUE);

    vbox2 = gtk_vbox_new(FALSE, 0);
    gtk_widget_set_name(vbox2, "vbox2");
    gtk_widget_show(vbox2);
    gtk_container_add( GTK_CONTAINER(mui), vbox2);

    menubar1 = gtk_menu_bar_new();
    gtk_widget_set_name(menubar1, "menubar1");
    gtk_widget_show(menubar1);
    gtk_box_pack_start( GTK_BOX(vbox2), menubar1, FALSE, FALSE, 0);

    file_menu = gtk_menu_item_new_with_mnemonic("_File");
    gtk_widget_set_name(file_menu, "file_menu");
    gtk_widget_show(file_menu);
    gtk_container_add( GTK_CONTAINER(menubar1), file_menu);

    file_menu_menu = gtk_menu_new();
    gtk_widget_set_name(file_menu_menu, "file_menu_menu");
    gtk_menu_item_set_submenu( GTK_MENU_ITEM(file_menu), file_menu_menu);

    new_file = gtk_image_menu_item_new_with_mnemonic("_New");
    gtk_widget_set_name(new_file, "new_file");
    gtk_widget_show(new_file);
    gtk_container_add( GTK_CONTAINER(file_menu_menu), new_file);
    gtk_widget_add_accelerator(new_file, "activate", accel_group, GDK_n, GDK_CONTROL_MASK, GTK_ACCEL_VISIBLE);

    image224 = gtk_image_new_from_stock("gtk-new", GTK_ICON_SIZE_MENU);
    gtk_widget_set_name(image224, "image224");
    gtk_widget_show(image224);
    gtk_image_menu_item_set_image( GTK_IMAGE_MENU_ITEM(new_file), image224);

    open_file = gtk_image_menu_item_new_with_mnemonic("_Open");
    gtk_widget_set_name(open_file, "open_file");
    gtk_widget_show(open_file);
    gtk_container_add( GTK_CONTAINER(file_menu_menu), open_file);
    gtk_widget_add_accelerator(open_file, "activate", accel_group, GDK_o, GDK_CONTROL_MASK, GTK_ACCEL_VISIBLE);

    image225 = gtk_image_new_from_stock("gtk-open", GTK_ICON_SIZE_MENU);
    gtk_widget_set_name(image225, "image225");
    gtk_widget_show(image225);
    gtk_image_menu_item_set_image( GTK_IMAGE_MENU_ITEM(open_file), image225);

    save_file = gtk_image_menu_item_new_with_mnemonic("_Save");
    gtk_widget_set_name(save_file, "save_file");
    gtk_widget_show(save_file);
    gtk_container_add( GTK_CONTAINER(file_menu_menu), save_file);
    gtk_widget_add_accelerator(save_file, "activate", accel_group, GDK_s, GDK_CONTROL_MASK, GTK_ACCEL_VISIBLE);

    image226 = gtk_image_new_from_stock("gtk-save", GTK_ICON_SIZE_MENU);
    gtk_widget_set_name(image226, "image226");
    gtk_widget_show(image226);
    gtk_image_menu_item_set_image( GTK_IMAGE_MENU_ITEM(save_file), image226);

    save_file_as = gtk_image_menu_item_new_with_mnemonic("Save-as");
    gtk_widget_set_name(save_file_as, "save_file_as");
    gtk_widget_show(save_file_as);
    gtk_container_add( GTK_CONTAINER(file_menu_menu), save_file_as);

    image227 = gtk_image_new_from_stock("gtk-save-as", GTK_ICON_SIZE_MENU);
    gtk_widget_set_name(image227, "image227");
    gtk_widget_show(image227);
    gtk_image_menu_item_set_image( GTK_IMAGE_MENU_ITEM(save_file_as), image227);

    before_history_item = gtk_menu_item_new();
    gtk_widget_set_name(before_history_item, "before_history_item");
    gtk_widget_show(before_history_item);
    gtk_container_add( GTK_CONTAINER(file_menu_menu), before_history_item);
    gtk_widget_set_sensitive(before_history_item, FALSE);

    after_history_item = gtk_menu_item_new();
    gtk_widget_set_name(after_history_item, "after_history_item");
    gtk_widget_show(after_history_item);
    gtk_container_add( GTK_CONTAINER(file_menu_menu), after_history_item);
    gtk_widget_set_sensitive(after_history_item, FALSE);

    quit1 = gtk_image_menu_item_new_with_mnemonic("_Quit");
    gtk_widget_set_name(quit1, "quit1");
    gtk_widget_show(quit1);
    gtk_container_add( GTK_CONTAINER(file_menu_menu), quit1);
    gtk_widget_add_accelerator(quit1, "activate", accel_group, GDK_q, GDK_CONTROL_MASK,	GTK_ACCEL_VISIBLE);

    image228 = gtk_image_new_from_stock("gtk-quit", GTK_ICON_SIZE_MENU);
    gtk_widget_set_name(image228, "image228");
    gtk_widget_show(image228);
    gtk_image_menu_item_set_image( GTK_IMAGE_MENU_ITEM(quit1), image228);

    options1 = gtk_menu_item_new_with_mnemonic("_Options");
    gtk_widget_set_name(options1, "options1");
    gtk_widget_show(options1);
    gtk_container_add( GTK_CONTAINER(menubar1), options1);

    options1_menu = gtk_menu_new();
    gtk_widget_set_name(options1_menu, "options1_menu");
    gtk_menu_item_set_submenu( GTK_MENU_ITEM(options1), options1_menu);

    preferences1 = gtk_image_menu_item_new_with_mnemonic("_Preferences");
    gtk_widget_set_name(preferences1, "preferences1");
    gtk_widget_show(preferences1);
    gtk_container_add( GTK_CONTAINER(options1_menu), preferences1);
    gtk_widget_add_accelerator(preferences1, "activate", accel_group, GDK_p, GDK_CONTROL_MASK, GTK_ACCEL_VISIBLE);

    image229 = gtk_image_new_from_stock("gtk-properties", GTK_ICON_SIZE_MENU);
    gtk_widget_set_name(image229, "image229");
    gtk_widget_show(image229);
    gtk_image_menu_item_set_image( GTK_IMAGE_MENU_ITEM(preferences1), image229);

    help1 = gtk_menu_item_new_with_mnemonic("_Help");
    gtk_widget_set_name(help1, "help1");
    gtk_widget_show(help1);
    gtk_container_add( GTK_CONTAINER(menubar1), help1);

    help1_menu = gtk_menu_new();
    gtk_widget_set_name(help1_menu, "help1_menu");
    gtk_menu_item_set_submenu( GTK_MENU_ITEM(help1), help1_menu);

    about1 = gtk_image_menu_item_new_with_mnemonic("About");
    gtk_widget_set_name(about1, "about1");
    gtk_widget_show(about1);
    gtk_container_add( GTK_CONTAINER(help1_menu), about1);
    gtk_widget_add_accelerator(about1, "activate", accel_group, GDK_a, GDK_CONTROL_MASK, GTK_ACCEL_VISIBLE);

    image230 = gtk_image_new_from_stock("gtk-dialog-info", GTK_ICON_SIZE_MENU);
    gtk_widget_set_name(image230, "image230");
    gtk_widget_show(image230);
    gtk_image_menu_item_set_image( GTK_IMAGE_MENU_ITEM(about1), image230);

    usage1 = gtk_image_menu_item_new_with_mnemonic("_Usage");
    gtk_widget_set_name(usage1, "usage1");
    gtk_widget_show(usage1);
    gtk_container_add( GTK_CONTAINER(help1_menu), usage1);
    gtk_widget_add_accelerator(usage1, "activate", accel_group, GDK_u, GDK_CONTROL_MASK, GTK_ACCEL_VISIBLE);

    file_dialog = gtk_file_selection_new(N_(""));
    gtk_file_selection_show_fileop_buttons(GTK_FILE_SELECTION(file_dialog));
    gtk_window_set_transient_for(GTK_WINDOW(file_dialog), GTK_WINDOW(mui));
    gtk_window_set_destroy_with_parent(GTK_WINDOW(file_dialog), TRUE);

    image231 = gtk_image_new_from_stock("gtk-help", GTK_ICON_SIZE_MENU);
    gtk_widget_set_name(image231, "image231");
    gtk_widget_show(image231);
    gtk_image_menu_item_set_image( GTK_IMAGE_MENU_ITEM(usage1), image231);

    toolbar1 = gtk_toolbar_new();
    gtk_widget_set_name(toolbar1, "toolbar1");
    gtk_widget_show(toolbar1);
    gtk_box_pack_start( GTK_BOX(vbox2), toolbar1, FALSE, FALSE, 0);
    gtk_container_set_border_width( GTK_CONTAINER(toolbar1), 1);
    gtk_toolbar_set_style( GTK_TOOLBAR(toolbar1), GTK_TOOLBAR_ICONS);

    new_file_button = gtk_toolbar_insert_stock( GTK_TOOLBAR(toolbar1), "gtk-new", "New", NULL, NULL, NULL, -1);
    gtk_widget_set_name(new_file_button, "new_file_button") ;
    gtk_widget_show(new_file_button);

    open_file_button = gtk_toolbar_insert_stock( GTK_TOOLBAR(toolbar1), "gtk-open", "Open", NULL, NULL, NULL, -1);
    gtk_widget_set_name(open_file_button, "open_file_button");
    gtk_widget_show(open_file_button);

    save_button = gtk_toolbar_insert_stock( GTK_TOOLBAR(toolbar1), "gtk-save", "Save", NULL, NULL, NULL, -1);
    gtk_widget_set_name(save_button, "save_button");
    gtk_widget_show(save_button);

    save_as_button = gtk_toolbar_insert_stock( GTK_TOOLBAR(toolbar1), "gtk-save-as", "Save as",NULL, NULL, NULL, -1);
    gtk_widget_set_name(save_as_button, "save_as_button");
    gtk_widget_show(save_as_button);

    gtk_toolbar_append_space( GTK_TOOLBAR(toolbar1));

    run_button = gtk_toolbar_insert_stock( GTK_TOOLBAR(toolbar1), "gtk-execute", "Run Mix", NULL, NULL, NULL, -1);
    gtk_widget_set_name(run_button, "run_button");
    gtk_widget_show(run_button);

    gtk_toolbar_append_space( GTK_TOOLBAR(toolbar1));

    tmp_toolbar_icon = gtk_image_new_from_stock("gtk-justify-left", gtk_toolbar_get_icon_size( GTK_TOOLBAR(toolbar1)));
    editor_button = gtk_toolbar_append_element( GTK_TOOLBAR(toolbar1), GTK_TOOLBAR_CHILD_BUTTON, NULL, "Editor", "run Editor", NULL, tmp_toolbar_icon, NULL, NULL);
    gtk_label_set_use_underline( GTK_LABEL(((GtkToolbarChild*)(g_list_last( GTK_TOOLBAR(toolbar1)->children)->data))->label), TRUE);
    gtk_widget_set_name(editor_button, "editor_button");
    gtk_widget_show(editor_button);
    
    gtk_toolbar_append_space( GTK_TOOLBAR(toolbar1));

    preferences = gtk_toolbar_insert_stock( GTK_TOOLBAR(toolbar1), "gtk-properties", "open preferences", NULL, NULL, NULL, -1);
    gtk_widget_set_name(preferences, "preferences");
    gtk_widget_show(preferences);

    gtk_toolbar_append_space( GTK_TOOLBAR(toolbar1));

    notebook1 = gtk_notebook_new();
    gtk_widget_set_name(notebook1, "notebook1");
    gtk_widget_show(notebook1);
    gtk_box_pack_start( GTK_BOX(vbox2), notebook1, TRUE, TRUE, 0);

    /* HIERVIEW */
    vbox4 = gtk_vbox_new(FALSE, 0);
    gtk_widget_set_name(vbox4, "vbox4");
    gtk_widget_show(vbox4);
    gtk_container_add( GTK_CONTAINER(notebook1), vbox4);

    hier_toolbar = gtk_toolbar_new();
    gtk_widget_set_name(hier_toolbar, "hier_toolbar");
    gtk_widget_show(hier_toolbar);
    gtk_box_pack_start( GTK_BOX(vbox4), hier_toolbar, FALSE, FALSE, 0);
    gtk_container_set_border_width( GTK_CONTAINER(hier_toolbar), 1);
    gtk_toolbar_set_style( GTK_TOOLBAR(hier_toolbar), GTK_TOOLBAR_ICONS);

    tmp_toolbar_icon = gtk_image_new_from_stock("gtk-add", gtk_toolbar_get_icon_size( GTK_TOOLBAR(hier_toolbar)));
    add_hier_button = gtk_toolbar_append_element( GTK_TOOLBAR(hier_toolbar),
						  GTK_TOOLBAR_CHILD_BUTTON,
						  NULL,
						  "",
						  "add a new hierarchical element", NULL,
						  tmp_toolbar_icon, NULL, NULL);
    gtk_label_set_use_underline( GTK_LABEL(((GtkToolbarChild*)(g_list_last( GTK_TOOLBAR(hier_toolbar)->children)->data))->label), TRUE);
    gtk_widget_set_name(add_hier_button, "add_hier_button");
    gtk_widget_show(add_hier_button);
    gtk_widget_set_size_request(add_hier_button, 24, 24);

    tmp_toolbar_icon = gtk_image_new_from_stock("gtk-remove", gtk_toolbar_get_icon_size( GTK_TOOLBAR(hier_toolbar)));
    del_hier_button = gtk_toolbar_append_element( GTK_TOOLBAR(hier_toolbar),
						  GTK_TOOLBAR_CHILD_BUTTON,
						  NULL,
						  "",
						  "remove a hierarchical element", NULL,
						  tmp_toolbar_icon, NULL, NULL);
    gtk_label_set_use_underline( GTK_LABEL(((GtkToolbarChild*)(g_list_last( GTK_TOOLBAR(hier_toolbar)->children)->data))->label), TRUE);
    gtk_widget_set_name(del_hier_button, "del_hier_button");
    gtk_widget_show(del_hier_button);
    gtk_widget_set_size_request(del_hier_button, 24, 24);

    hpaned3 = gtk_hpaned_new();
    gtk_widget_set_name(hpaned3, "hpaned3");
    gtk_widget_show(hpaned3);
    gtk_box_pack_start( GTK_BOX(vbox4), hpaned3, TRUE, TRUE, 0);
    gtk_paned_set_position( GTK_PANED(hpaned3), 320);

    scrolledwindow5 = gtk_scrolled_window_new(NULL, NULL);
    gtk_widget_set_name(scrolledwindow5, "scrolledwindow5");
    gtk_widget_show(scrolledwindow5);
    gtk_paned_pack1( GTK_PANED(hpaned3), scrolledwindow5, FALSE, TRUE);
    gtk_scrolled_window_set_policy (GTK_SCROLLED_WINDOW (scrolledwindow5), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC);

    // store reference to drawing hier area
    mainview[0] =  GTK_WIDGET(scrolledwindow5);
    childview[0] = NULL;

    label29 = gtk_label_new("Hierarchy");
    gtk_widget_set_name(label29, "label29");
    gtk_widget_show(label29);
    gtk_notebook_set_tab_label( GTK_NOTEBOOK(notebook1), gtk_notebook_get_nth_page( GTK_NOTEBOOK(notebook1), 0), label29);

    /* CONNVIEW */
    vbox3 = gtk_vbox_new(FALSE, 0);
    gtk_widget_set_name(vbox3, "vbox3");
    gtk_widget_show(vbox3);
    gtk_container_add( GTK_CONTAINER(notebook1), vbox3);

    conn_toolbar = gtk_toolbar_new();
    gtk_widget_set_name(conn_toolbar, "conn_toolbar");
    gtk_widget_show(conn_toolbar);
    gtk_box_pack_start( GTK_BOX(vbox3), conn_toolbar, FALSE, FALSE, 0);
    gtk_container_set_border_width( GTK_CONTAINER(conn_toolbar), 1);
    gtk_toolbar_set_style( GTK_TOOLBAR(conn_toolbar), GTK_TOOLBAR_ICONS);

    tmp_toolbar_icon = gtk_image_new_from_stock("gtk-add", gtk_toolbar_get_icon_size( GTK_TOOLBAR(conn_toolbar)));
    add_hier_button = gtk_toolbar_append_element( GTK_TOOLBAR(conn_toolbar),
						  GTK_TOOLBAR_CHILD_BUTTON,
						  NULL,
						  "",
						  "add a new connection", NULL,
						  tmp_toolbar_icon, NULL, NULL);
    gtk_label_set_use_underline( GTK_LABEL(((GtkToolbarChild*)(g_list_last( GTK_TOOLBAR(conn_toolbar)->children)->data))->label), TRUE);
    gtk_widget_set_name(add_hier_button, "add_hier_button");
    gtk_widget_show(add_hier_button);
    gtk_widget_set_size_request(add_hier_button, 24, 24);

    tmp_toolbar_icon = gtk_image_new_from_stock("gtk-remove", gtk_toolbar_get_icon_size( GTK_TOOLBAR(conn_toolbar)));
    del_conn_button = gtk_toolbar_append_element( GTK_TOOLBAR(conn_toolbar),
						  GTK_TOOLBAR_CHILD_BUTTON,
						  NULL,
						  "",
						  "remove a connection", NULL,
						  tmp_toolbar_icon, NULL, NULL);
    gtk_label_set_use_underline( GTK_LABEL(((GtkToolbarChild*)(g_list_last( GTK_TOOLBAR(conn_toolbar)->children)->data))->label), TRUE);
    gtk_widget_set_name(del_conn_button, "del_conn_button");
    gtk_widget_show(del_conn_button);
    gtk_widget_set_size_request(del_conn_button, 24, 24);

    hpaned2 = gtk_hpaned_new();
    gtk_widget_set_name(hpaned2, "hpaned2");
    gtk_widget_show(hpaned2);
    gtk_box_pack_start( GTK_BOX(vbox3), hpaned2, TRUE, TRUE, 0);
    gtk_paned_set_position( GTK_PANED(hpaned2), 0);

    fixed22 = gtk_fixed_new();
    gtk_widget_set_name(fixed22, "fixed22");
    gtk_widget_show(fixed22);
    gtk_paned_pack1( GTK_PANED(hpaned2), fixed22, FALSE, TRUE);

    scrolledwindow4 = gtk_scrolled_window_new(NULL, NULL);
    gtk_widget_set_name(scrolledwindow4, "scrolledwindow4");
    gtk_widget_show(scrolledwindow4);
    gtk_paned_pack2( GTK_PANED(hpaned2), scrolledwindow4, TRUE, TRUE);
    gtk_scrolled_window_set_policy (GTK_SCROLLED_WINDOW (scrolledwindow4), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC);

    mainview[1] = GTK_WIDGET(scrolledwindow4);
    childview[1] = NULL;

    label30 = gtk_label_new("Connections");
    gtk_widget_set_name(label30, "label30");
    gtk_widget_show(label30);
    gtk_notebook_set_tab_label( GTK_NOTEBOOK(notebook1), gtk_notebook_get_nth_page( GTK_NOTEBOOK(notebook1), 1), label30);

    /* IOPADVIEW */
    vbox6 = gtk_vbox_new(FALSE, 0);
    gtk_widget_set_name(vbox6, "vbox6");
    gtk_widget_show(vbox6);
    gtk_container_add( GTK_CONTAINER(notebook1), vbox6);

    toolbar8 = gtk_toolbar_new();
    gtk_widget_set_name(toolbar8, "toolbar8");
    gtk_widget_show(toolbar8);
    gtk_box_pack_start( GTK_BOX(vbox6), toolbar8, FALSE, FALSE, 0);
    gtk_container_set_border_width( GTK_CONTAINER(toolbar8), 1);
    gtk_toolbar_set_style( GTK_TOOLBAR(toolbar8), GTK_TOOLBAR_ICONS);

    tmp_toolbar_icon = gtk_image_new_from_stock("gtk-add", gtk_toolbar_get_icon_size( GTK_TOOLBAR(toolbar8)));
    add_iopad_button = gtk_toolbar_append_element( GTK_TOOLBAR(toolbar8),
						   GTK_TOOLBAR_CHILD_BUTTON,
						   NULL,
						   "add IO Pad",
						   "add new IO Pad", NULL,
						   tmp_toolbar_icon, NULL, NULL);
    gtk_label_set_use_underline( GTK_LABEL(((GtkToolbarChild*)(g_list_last( GTK_TOOLBAR(toolbar8)->children)->data))->label), TRUE);
    gtk_widget_set_name(add_iopad_button, "add_iopad_button");
    gtk_widget_show(add_iopad_button);
    gtk_widget_set_size_request(add_iopad_button, 24, 24);

    tmp_toolbar_icon = gtk_image_new_from_stock("gtk-remove", gtk_toolbar_get_icon_size( GTK_TOOLBAR(toolbar8)));
    del_iopad_button = gtk_toolbar_append_element( GTK_TOOLBAR(toolbar8),
						   GTK_TOOLBAR_CHILD_BUTTON,
						   NULL,
						   "remove IO Pad",
						   "remove IO Pad", NULL,
                                tmp_toolbar_icon, NULL, NULL);
    gtk_label_set_use_underline( GTK_LABEL(((GtkToolbarChild*)(g_list_last( GTK_TOOLBAR(toolbar8)->children)->data))->label), TRUE);
    gtk_widget_set_name(del_iopad_button, "del_iopad_button");
    gtk_widget_show(del_iopad_button);
    gtk_widget_set_size_request(del_iopad_button, 24, 24);

    scrolledwindow3 = gtk_scrolled_window_new (NULL, NULL);
    gtk_widget_set_name (scrolledwindow3, "scrolledwindow3");
    gtk_widget_show (scrolledwindow3);
    gtk_box_pack_start (GTK_BOX (vbox6), scrolledwindow3, TRUE, TRUE, 0);
    gtk_scrolled_window_set_policy (GTK_SCROLLED_WINDOW (scrolledwindow3), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC);

    mainview[2] = GTK_WIDGET(scrolledwindow3);
    childview[2] = NULL;

    label31 = gtk_label_new("IO-Pads");
    gtk_widget_set_name(label31, "label31");
    gtk_widget_show(label31);
    gtk_notebook_set_tab_label( GTK_NOTEBOOK(notebook1), gtk_notebook_get_nth_page( GTK_NOTEBOOK(notebook1), 2), label31);

    /* I2CVIEW */
    vbox5 = gtk_vbox_new(FALSE, 0);
    gtk_widget_set_name(vbox5, "vbox5");
    gtk_widget_show(vbox5);
    gtk_container_add( GTK_CONTAINER(notebook1), vbox5);

    toolbar7 = gtk_toolbar_new();
    gtk_widget_set_name(toolbar7, "toolbar7");
    gtk_widget_show(toolbar7);
    gtk_box_pack_start( GTK_BOX(vbox5), toolbar7, FALSE, FALSE, 0);
    gtk_container_set_border_width( GTK_CONTAINER(toolbar7), 1);
    gtk_toolbar_set_style( GTK_TOOLBAR(toolbar7), GTK_TOOLBAR_ICONS);

    tmp_toolbar_icon = gtk_image_new_from_stock("gtk-add", gtk_toolbar_get_icon_size( GTK_TOOLBAR(toolbar7)));
    add_i2c_regblock_button = gtk_toolbar_append_element( GTK_TOOLBAR(toolbar7),
							  GTK_TOOLBAR_CHILD_BUTTON,
							  NULL,
							  "add I2C Registerblock",
							  "add a new I2C Registerblock", NULL,
							  tmp_toolbar_icon, NULL, NULL);
    gtk_label_set_use_underline( GTK_LABEL(((GtkToolbarChild*)(g_list_last( GTK_TOOLBAR(toolbar7)->children)->data))->label), TRUE);
    gtk_widget_set_name(add_i2c_regblock_button, "add_i2c_regblock_button");
    gtk_widget_show(add_i2c_regblock_button);
    gtk_widget_set_size_request(add_i2c_regblock_button, 24, 24);

    tmp_toolbar_icon = gtk_image_new_from_stock("gtk-remove", gtk_toolbar_get_icon_size( GTK_TOOLBAR(toolbar7)));
    del_i2c_regblock_button = gtk_toolbar_append_element( GTK_TOOLBAR(toolbar7),
							  GTK_TOOLBAR_CHILD_BUTTON,
							  NULL,
							  "Remove I2C Registerblock",
							  "remove a I2C Registerblock", NULL,
							  tmp_toolbar_icon, NULL, NULL);
    gtk_label_set_use_underline( GTK_LABEL(((GtkToolbarChild*)(g_list_last( GTK_TOOLBAR(toolbar7)->children)->data))->label), TRUE);
    gtk_widget_set_name(del_i2c_regblock_button, "del_i2c_regblock_button");
    gtk_widget_show(del_i2c_regblock_button);
    gtk_widget_set_size_request(del_i2c_regblock_button, 24, 24);

    scrolledwindow2 = gtk_scrolled_window_new (NULL, NULL);
    gtk_widget_set_name(scrolledwindow2, "scrolledwindow2");
    gtk_widget_show(scrolledwindow2);
    gtk_box_pack_start(GTK_BOX(vbox5), scrolledwindow2, TRUE, TRUE, 0);
    gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scrolledwindow2), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC);

    mainview[3] = GTK_WIDGET(scrolledwindow2);
    childview[3] = NULL;

    label32 = gtk_label_new("I2C");
    gtk_widget_set_name(label32, "label32");
    gtk_widget_show(label32);
    gtk_notebook_set_tab_label( GTK_NOTEBOOK(notebook1), gtk_notebook_get_nth_page( GTK_NOTEBOOK(notebook1), 3), label32);
    gtk_label_set_justify( GTK_LABEL(label32), GTK_JUSTIFY_FILL);

    /* CONFVIEW */
    fixed12 = gtk_fixed_new();
    gtk_widget_set_name(fixed12, "fixed12");
    gtk_widget_show(fixed12);
    gtk_container_add( GTK_CONTAINER(notebook1), fixed12);

    frame13 = gtk_frame_new(NULL);
    gtk_widget_set_name(frame13, "frame13");
    gtk_widget_show(frame13);
    gtk_fixed_put( GTK_FIXED(fixed12), frame13, 16, 24);
    gtk_widget_set_size_request(frame13, 156, 272);

    fixed13 = gtk_fixed_new();
    gtk_widget_set_name(fixed13, "fixed13");
    gtk_widget_show(fixed13);
    gtk_container_add( GTK_CONTAINER(frame13), fixed13);

    checkbutton7 = gtk_check_button_new_with_mnemonic("drop old sheets");
    gtk_widget_set_name(checkbutton7, "checkbutton7");
    gtk_widget_show(checkbutton7);
    gtk_fixed_put( GTK_FIXED(fixed13), checkbutton7, 8, 56);
    gtk_widget_set_size_request(checkbutton7, 128, 20);
    gtk_tooltips_set_tip(tooltips, checkbutton7, "remove intermediate output", NULL);

    checkbutton8 = gtk_check_button_new_with_mnemonic("keep old output");
    gtk_widget_set_name(checkbutton8, "checkbutton8");
    gtk_widget_show(checkbutton8);
    gtk_fixed_put( GTK_FIXED(fixed13), checkbutton8, 8, 32);
    gtk_widget_set_size_request(checkbutton8, 128, 20);
    gtk_tooltips_set_tip(tooltips, checkbutton8, "keep previous generated HDL output", NULL);

    checkbutton9 = gtk_check_button_new_with_mnemonic("dump");
    gtk_widget_set_name(checkbutton9, "checkbutton9");
    gtk_widget_show(checkbutton9);
    gtk_fixed_put( GTK_FIXED(fixed13), checkbutton9, 8, 80);
    gtk_widget_set_size_request(checkbutton9, 64, 20);
    gtk_tooltips_set_tip(tooltips, checkbutton9, "dump internal data(debugging only)", NULL);

    checkbutton10 = gtk_check_button_new_with_mnemonic("verbose");
    gtk_widget_set_name(checkbutton10, "checkbutton10");
    gtk_widget_show(checkbutton10);
    gtk_fixed_put( GTK_FIXED(fixed13), checkbutton10, 8, 104);
    gtk_widget_set_size_request(checkbutton10, 80, 20);

    checkbutton11 = gtk_check_button_new_with_mnemonic("delta mode");
    gtk_widget_set_name(checkbutton11, "checkbutton11");
    gtk_widget_show(checkbutton11);
    gtk_fixed_put( GTK_FIXED(fixed13), checkbutton11, 8, 8);
    gtk_widget_set_size_request(checkbutton11, 101, 20);
    gtk_tooltips_set_tip(tooltips, checkbutton11, "enable delta mode", NULL);

    label43 = gtk_label_new("Debug level:");
    gtk_widget_set_name(label43, "label43");
    gtk_widget_show(label43);
    gtk_fixed_put( GTK_FIXED(fixed13), label43, 8, 144);
    gtk_widget_set_size_request(label43, 84, 16);

    spinbutton2_adj = gtk_adjustment_new(0, 0, 99, 1, 10, 10);
    spinbutton2 = gtk_spin_button_new( GTK_ADJUSTMENT(spinbutton2_adj), 1, 0);
    gtk_widget_set_name(spinbutton2, "spinbutton2");
    gtk_widget_show(spinbutton2);
    gtk_fixed_put( GTK_FIXED(fixed13), spinbutton2, 96, 144);
    gtk_widget_set_size_request(spinbutton2, 39, 24);
    gtk_tooltips_set_tip(tooltips, spinbutton2, "set Debug level", NULL);
    gtk_spin_button_set_numeric( GTK_SPIN_BUTTON(spinbutton2), TRUE);

    button43 = gtk_button_new_with_mnemonic("list config");
    gtk_widget_set_name(button43, "button43");
    gtk_widget_show(button43);
    gtk_fixed_put( GTK_FIXED(fixed13), button43, 40, 208);
    gtk_widget_set_size_request(button43, 76, 27);
    gtk_tooltips_set_tip(tooltips, button43, "print all predefined configuration options", NULL);

    label44 = gtk_label_new("Debugging");
    gtk_widget_set_name(label44, "label44");
    gtk_widget_show(label44);
    gtk_frame_set_label_widget( GTK_FRAME(frame13), label44);

    frame14 = gtk_frame_new(NULL);
    gtk_widget_set_name(frame14, "frame14");
    gtk_widget_show(frame14);
    gtk_fixed_put( GTK_FIXED(fixed12), frame14, 184, 88);
    gtk_widget_set_size_request(frame14, 416, 208);

    fixed14 = gtk_fixed_new();
    gtk_widget_set_name(fixed14, "fixed14");
    gtk_widget_show(fixed14);
    gtk_container_add( GTK_CONTAINER(frame14), fixed14);

    entry15 = gtk_entry_new();
    gtk_widget_set_name(entry15, "entry15");
    gtk_widget_show(entry15);
    gtk_fixed_put( GTK_FIXED(fixed14), entry15, 128, 64);
    gtk_widget_set_size_request(entry15, 202, 24);
    gtk_tooltips_set_tip(tooltips, entry15, "select target Directory", NULL);

    combo2 = gtk_combo_new();
    g_object_set_data(G_OBJECT( GTK_COMBO(combo2)->popwin), "GladeParentKey", combo2);
    gtk_widget_set_name(combo2, "combo2");
    gtk_widget_show(combo2);
    gtk_fixed_put( GTK_FIXED(fixed14), combo2, 128, 16);
    gtk_widget_set_size_request(combo2, 179, 25);

    entry16 = GTK_COMBO(combo2)->entry;
    gtk_widget_set_name(entry16, "entry16");
    gtk_widget_show(entry16);
    gtk_tooltips_set_tip(tooltips, entry16, "select build Variant", NULL);
    gtk_entry_set_activates_default( GTK_ENTRY(entry16), TRUE);

    entry17 = gtk_entry_new();
    gtk_widget_set_name(entry17, "entry17");
    gtk_widget_show(entry17);
    gtk_fixed_put( GTK_FIXED(fixed14), entry17, 128, 112);
    gtk_widget_set_size_request(entry17, 202, 24);

    label46 = gtk_label_new("leafcell Directory:");
    gtk_widget_set_name(label46, "label46");
    gtk_widget_show(label46);
    gtk_fixed_put( GTK_FIXED(fixed14), label46, 16, 116);
    gtk_widget_set_size_request(label46, 104, 16);

    checkbutton12 = gtk_check_button_new_with_mnemonic("combine");
    gtk_widget_set_name(checkbutton12, "checkbutton12");
    gtk_widget_show(checkbutton12);
    gtk_fixed_put( GTK_FIXED(fixed14), checkbutton12, 152, 152);
    gtk_widget_set_size_request(checkbutton12, 83, 20);
    gtk_tooltips_set_tip(tooltips, checkbutton12, "combine entity, architecture and configuration into one file", NULL);

    label47 = gtk_label_new("Variant:");
    gtk_widget_set_name(label47, "label47");
    gtk_widget_show(label47);
    gtk_fixed_put( GTK_FIXED(fixed14), label47, 56, 21);
    gtk_widget_set_size_request(label47, 54, 16);

    label45 = gtk_label_new("target Directory:");
    gtk_widget_set_name(label45, "label45");
    gtk_widget_show(label45);
    gtk_fixed_put( GTK_FIXED(fixed14), label45, 16, 69);
    gtk_widget_set_size_request(label45, 104, 16);

    button45 = gtk_button_new_with_mnemonic("select...");
    gtk_widget_set_name(button45, "button45");
    gtk_widget_show(button45);
    gtk_fixed_put( GTK_FIXED(fixed14), button45, 328, 112);
    gtk_widget_set_size_request(button45, 60, 24);
    gtk_tooltips_set_tip(tooltips, button45, "select directory where leafcells are located", NULL);

    button44 = gtk_button_new_with_mnemonic("select...");
    gtk_widget_set_name(button44, "button44");
    gtk_widget_show(button44);
    gtk_fixed_put( GTK_FIXED(fixed14), button44, 328, 64);
    gtk_widget_set_size_request(button44, 60, 24);
    gtk_tooltips_set_tip(tooltips, button44, "select target Directory", NULL);

    label48 = gtk_label_new("Custom");
    gtk_widget_set_name(label48, "label48");
    gtk_widget_show(label48);
    gtk_frame_set_label_widget( GTK_FRAME(frame14), label48);
  
    label33 = gtk_label_new("Config");
    gtk_widget_set_name(label33, "label33");
    gtk_widget_show(label33);
    gtk_notebook_set_tab_label( GTK_NOTEBOOK(notebook1), gtk_notebook_get_nth_page( GTK_NOTEBOOK(notebook1), 4), label33);

    hbox2 = gtk_hbox_new(FALSE, 0);
    gtk_widget_set_name(hbox2, "hbox2");
    gtk_widget_show(hbox2);
    gtk_box_pack_start( GTK_BOX(vbox2), hbox2, FALSE, TRUE, 0);

    frame3 = gtk_frame_new(NULL);
    gtk_widget_set_name(frame3, "frame3");
    gtk_widget_show(frame3);
    gtk_box_pack_start( GTK_BOX(hbox2), frame3, FALSE, TRUE, 0);
    gtk_frame_set_shadow_type( GTK_FRAME(frame3), GTK_SHADOW_IN);

    eventbox3 = gtk_event_box_new();
    gtk_widget_set_name(eventbox3, "eventbox3");
    gtk_widget_show(eventbox3);
    gtk_container_add( GTK_CONTAINER(frame3), eventbox3);
    gtk_tooltips_set_tip(tooltips, eventbox3, "File modified", NULL);

    modified_label = gtk_label_new("*");
    gtk_widget_set_name(modified_label, "modified_label");
    gtk_widget_show(modified_label);
    gtk_container_add( GTK_CONTAINER(eventbox3), modified_label);
    gtk_misc_set_padding( GTK_MISC(modified_label), 1, 0);

    frame8 = gtk_frame_new(NULL);
    gtk_widget_set_name(frame8, "frame8");
    gtk_widget_show(frame8);
    gtk_box_pack_start( GTK_BOX(hbox2), frame8, TRUE, TRUE, 0);
    gtk_frame_set_shadow_type( GTK_FRAME(frame8), GTK_SHADOW_IN);

    title_event_box = gtk_event_box_new();
    gtk_widget_set_name(title_event_box, "title_event_box");
    gtk_widget_show(title_event_box);
    gtk_container_add( GTK_CONTAINER(frame8), title_event_box);

    title_hbox = gtk_hbox_new(FALSE, 2);
    gtk_widget_set_name(title_hbox, "title_hbox");
    gtk_widget_show(title_hbox);
    gtk_container_add( GTK_CONTAINER(title_event_box), title_hbox);
    gtk_container_set_border_width( GTK_CONTAINER(title_hbox), 2);

    title_ellipses = gtk_label_new("<");
    gtk_widget_set_name(title_ellipses, "title_ellipses");
    gtk_widget_show(title_ellipses);
    gtk_box_pack_start( GTK_BOX(title_hbox), title_ellipses, FALSE, FALSE, 0);

    title_label_box = gtk_layout_new(NULL, NULL);
    gtk_widget_set_name(title_label_box, "title_label_box");
    gtk_widget_show(title_label_box);
    gtk_box_pack_start( GTK_BOX(title_hbox), title_label_box, TRUE, TRUE, 0);
    gtk_layout_set_size( GTK_LAYOUT(title_label_box), 1, 1);
    GTK_ADJUSTMENT( GTK_LAYOUT(title_label_box)->hadjustment)->step_increment = 0;
    GTK_ADJUSTMENT( GTK_LAYOUT(title_label_box)->vadjustment)->step_increment = 0;

    title_label = gtk_label_new("(Untitled)");
    gtk_widget_set_name(title_label, "title_label");
    gtk_widget_show(title_label);
    gtk_layout_put( GTK_LAYOUT(title_label_box), title_label, 0, 0);
    gtk_widget_set_size_request(title_label, 48, 16);

    g_signal_connect((gpointer) mui, "destroy", G_CALLBACK(on_mainwin_destroy), NULL);
    g_signal_connect((gpointer) mui, "delete_event", G_CALLBACK(on_mainwin_delete_event), NULL);
    g_signal_connect((gpointer) new_file, "activate", G_CALLBACK(on_new_file_item), NULL);
    g_signal_connect((gpointer) open_file, "activate", G_CALLBACK(on_open_file_item), NULL);
    g_signal_connect((gpointer) save_file, "activate", G_CALLBACK(on_save_file_item), NULL);
    g_signal_connect((gpointer) save_file_as, "activate", G_CALLBACK(on_save_file_as_item), NULL);
    g_signal_connect((gpointer) quit1, "activate", G_CALLBACK(on_app_quit_item), NULL);
    g_signal_connect((gpointer) preferences1, "activate", G_CALLBACK(on_preferences_item), NULL);
    g_signal_connect((gpointer) about1, "activate", G_CALLBACK(on_about_item), NULL);
    g_signal_connect((gpointer) usage1, "activate", G_CALLBACK(on_usage1_activate), NULL);
    g_signal_connect((gpointer) new_file_button, "clicked", G_CALLBACK(on_new_file_btn), NULL);
    g_signal_connect((gpointer) open_file_button, "clicked", G_CALLBACK(on_open_file_btn), NULL);
    g_signal_connect((gpointer) save_button, "clicked", G_CALLBACK(on_save_file_btn), NULL);
    g_signal_connect((gpointer) save_as_button, "clicked", G_CALLBACK(on_save_file_as_btn), NULL);
    g_signal_connect((gpointer) run_button, "clicked", G_CALLBACK(on_run_btn), NULL);
    g_signal_connect((gpointer) editor_button, "clicked", G_CALLBACK(on_editor_btn), NULL);
    g_signal_connect((gpointer) preferences, "clicked", G_CALLBACK(on_preferences_btn), NULL);
    g_signal_connect((gpointer) notebook1, "switch-page", G_CALLBACK(on_notebook_switch_page), NULL);    
    g_signal_connect((gpointer) checkbutton7, "toggled", G_CALLBACK(on_strip_toggled), NULL);
    g_signal_connect((gpointer) checkbutton8, "toggled", G_CALLBACK(on_bak_toggled), NULL);
    g_signal_connect((gpointer) checkbutton9, "toggled", G_CALLBACK(on_dump_toggled), NULL);
    g_signal_connect((gpointer) checkbutton10, "toggled", G_CALLBACK(on_verbose_toggled), NULL);
    g_signal_connect((gpointer) checkbutton11, "toggled", G_CALLBACK(on_delta_toggled), NULL);
    g_signal_connect((gpointer) checkbutton12, "toggled", G_CALLBACK(on_combine_toggled), NULL);
    g_signal_connect((gpointer) title_label_box, "size_allocate", G_CALLBACK(on_title_label_box_size_allocate), NULL);

    // Store pointers to all widgets, for use by lookup_widget()
    GLADE_HOOKUP_OBJECT_NO_REF(mui, mui, "mui");
    GLADE_HOOKUP_OBJECT(mui, vbox2, "vbox2");
    GLADE_HOOKUP_OBJECT(mui, menubar1, "menubar1");
    GLADE_HOOKUP_OBJECT(mui, file_menu, "file_menu");
    GLADE_HOOKUP_OBJECT(mui, file_menu_menu, "file_menu_menu");
    GLADE_HOOKUP_OBJECT(mui, new_file, "new_file");
    GLADE_HOOKUP_OBJECT(mui, image224, "image224");
    GLADE_HOOKUP_OBJECT(mui, open_file, "open_file");
    GLADE_HOOKUP_OBJECT(mui, image225, "image225");
    GLADE_HOOKUP_OBJECT(mui, save_file, "save_file");
    GLADE_HOOKUP_OBJECT(mui, image226, "image226");
    GLADE_HOOKUP_OBJECT(mui, save_file_as, "save_file_as");
    GLADE_HOOKUP_OBJECT(mui, image227, "image227");
    GLADE_HOOKUP_OBJECT(mui, before_history_item, "before_history_item");
    GLADE_HOOKUP_OBJECT(mui, after_history_item, "after_history_item");
    GLADE_HOOKUP_OBJECT(mui, quit1, "quit1");
    GLADE_HOOKUP_OBJECT(mui, image228, "image228");
    GLADE_HOOKUP_OBJECT(mui, options1, "options1");
    GLADE_HOOKUP_OBJECT(mui, options1_menu, "options1_menu");
    GLADE_HOOKUP_OBJECT(mui, preferences1, "preferences1");
    GLADE_HOOKUP_OBJECT(mui, image229, "image229");
    GLADE_HOOKUP_OBJECT(mui, help1, "help1");
    GLADE_HOOKUP_OBJECT(mui, help1_menu, "help1_menu");
    GLADE_HOOKUP_OBJECT(mui, about1, "about1");
    GLADE_HOOKUP_OBJECT(mui, image230, "image230");
    GLADE_HOOKUP_OBJECT(mui, usage1, "usage1");
    GLADE_HOOKUP_OBJECT(mui, image231, "image231");
    GLADE_HOOKUP_OBJECT(mui, toolbar1, "toolbar1");
    GLADE_HOOKUP_OBJECT(mui, new_file_button, "new_file_button");
    GLADE_HOOKUP_OBJECT(mui, open_file_button, "open_file_button");
    GLADE_HOOKUP_OBJECT(mui, save_button, "save_button");
    GLADE_HOOKUP_OBJECT(mui, save_as_button, "save_as_button");
    GLADE_HOOKUP_OBJECT(mui, run_button, "run_button");
    GLADE_HOOKUP_OBJECT(mui, editor_button, "editor_button");
    GLADE_HOOKUP_OBJECT(mui, preferences, "preferences");
    GLADE_HOOKUP_OBJECT(mui, notebook1, "notebook1");
    GLADE_HOOKUP_OBJECT(mui, vbox4, "vbox4");
    GLADE_HOOKUP_OBJECT(mui, hier_toolbar, "hier_toolbar");
    GLADE_HOOKUP_OBJECT(mui, add_hier_button, "add_hier_button");
    GLADE_HOOKUP_OBJECT(mui, del_hier_button, "del_hier_button");
    GLADE_HOOKUP_OBJECT(mui, hpaned3, "hpaned3");
    GLADE_HOOKUP_OBJECT(mui, scrolledwindow5, "scrolledwindow5");
    GLADE_HOOKUP_OBJECT(mui, label29, "label29");
    GLADE_HOOKUP_OBJECT(mui, vbox3, "vbox3");
    GLADE_HOOKUP_OBJECT(mui, conn_toolbar, "conn_toolbar");
    GLADE_HOOKUP_OBJECT(mui, add_hier_button, "add_hier_button");
    GLADE_HOOKUP_OBJECT(mui, del_conn_button, "del_conn_button");
    GLADE_HOOKUP_OBJECT(mui, hpaned2, "hpaned2");
    GLADE_HOOKUP_OBJECT(mui, fixed22, "fixed22");
    GLADE_HOOKUP_OBJECT(mui, scrolledwindow4, "scrolledwindow4");
    GLADE_HOOKUP_OBJECT(mui, label30, "label30");
    GLADE_HOOKUP_OBJECT(mui, vbox6, "vbox6");
    GLADE_HOOKUP_OBJECT(mui, toolbar8, "toolbar8");
    GLADE_HOOKUP_OBJECT(mui, add_iopad_button, "add_iopad_button");
    GLADE_HOOKUP_OBJECT(mui, del_iopad_button, "del_iopad_button");
    GLADE_HOOKUP_OBJECT(mui, scrolledwindow3, "scrolledwindow3");
    GLADE_HOOKUP_OBJECT(mui, label31, "label31");
    GLADE_HOOKUP_OBJECT(mui, vbox5, "vbox5");
    GLADE_HOOKUP_OBJECT(mui, toolbar7, "toolbar7");
    GLADE_HOOKUP_OBJECT(mui, add_i2c_regblock_button, "add_i2c_regblock_button");
    GLADE_HOOKUP_OBJECT(mui, del_i2c_regblock_button, "del_i2c_regblock_button");
    GLADE_HOOKUP_OBJECT(mui, label32, "label32");
    GLADE_HOOKUP_OBJECT(mui, fixed12, "fixed12");
    GLADE_HOOKUP_OBJECT(mui, scrolledwindow2, "scrolledwindow2");
    GLADE_HOOKUP_OBJECT(mui, frame13, "frame13");
    GLADE_HOOKUP_OBJECT(mui, fixed13, "fixed13");
    GLADE_HOOKUP_OBJECT(mui, checkbutton7, "checkbutton7");
    GLADE_HOOKUP_OBJECT(mui, checkbutton8, "checkbutton8");
    GLADE_HOOKUP_OBJECT(mui, checkbutton9, "checkbutton9");
    GLADE_HOOKUP_OBJECT(mui, checkbutton10, "checkbutton10");
    GLADE_HOOKUP_OBJECT(mui, checkbutton11, "checkbutton11");
    GLADE_HOOKUP_OBJECT(mui, label43, "label43");
    GLADE_HOOKUP_OBJECT(mui, spinbutton2, "spinbutton2");
    GLADE_HOOKUP_OBJECT(mui, button43, "button43");
    GLADE_HOOKUP_OBJECT(mui, label44, "label44");
    GLADE_HOOKUP_OBJECT(mui, frame14, "frame14");
    GLADE_HOOKUP_OBJECT(mui, fixed14, "fixed14");
    GLADE_HOOKUP_OBJECT(mui, entry15, "entry15");
    GLADE_HOOKUP_OBJECT(mui, combo2, "combo2");
    GLADE_HOOKUP_OBJECT(mui, entry16, "entry16");
    GLADE_HOOKUP_OBJECT(mui, entry17, "entry17");
    GLADE_HOOKUP_OBJECT(mui, label46, "label46");
    GLADE_HOOKUP_OBJECT(mui, checkbutton12, "checkbutton12");
    GLADE_HOOKUP_OBJECT(mui, label47, "label47");
    GLADE_HOOKUP_OBJECT(mui, label45, "label45");
    GLADE_HOOKUP_OBJECT(mui, button45, "button45");
    GLADE_HOOKUP_OBJECT(mui, button44, "button44");
    GLADE_HOOKUP_OBJECT(mui, label48, "label48");
    GLADE_HOOKUP_OBJECT(mui, label33, "label33");
    GLADE_HOOKUP_OBJECT(mui, hbox2, "hbox2");
    GLADE_HOOKUP_OBJECT(mui, frame3, "frame3");
    GLADE_HOOKUP_OBJECT(mui, eventbox3, "eventbox3");
    GLADE_HOOKUP_OBJECT(mui, modified_label, "modified_label");
    GLADE_HOOKUP_OBJECT(mui, frame8, "frame8");
    GLADE_HOOKUP_OBJECT(mui, title_event_box, "title_event_box");
    GLADE_HOOKUP_OBJECT(mui, title_hbox, "title_hbox");
    GLADE_HOOKUP_OBJECT(mui, title_ellipses, "title_ellipses");
    GLADE_HOOKUP_OBJECT(mui, title_label_box, "title_label_box");
    GLADE_HOOKUP_OBJECT(mui, title_label, "title_label");
    GLADE_HOOKUP_OBJECT_NO_REF(mui, tooltips, "tooltips");

    gtk_window_add_accel_group( GTK_WINDOW(mui), accel_group);

    return mui;
}


GtkWidget* get_view_frame(int index)
{
    if(index < 4)
	return mainview[index];
    return NULL;
}


void set_view_child(GtkWidget *child, int index)
{
    childview[index] = child;
}


GtkWidget* get_view_child(int index)
{
    if(index < 4)
	return childview[index];
    return NULL;
}


GtkWidget* create_Preferences(void)
{
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
    GtkWidget *dialog_action_area3;
    GtkWidget *preferences_cancel_button;
    GtkWidget *alignment4;
    GtkWidget *hbox10;
    GtkWidget *image69;
    GtkWidget *label15;
    GtkWidget *preferences_ok_button;
    GtkWidget *alignment6;
    GtkWidget *hbox12;
    GtkWidget *image71;
    GtkWidget *label17;
    GtkTooltips *tooltips;

    tooltips = gtk_tooltips_new();

    preferences = gtk_dialog_new();
    gtk_widget_set_name(preferences, "preferences");
    gtk_widget_set_size_request(preferences, 360, 200);
    gtk_window_set_title( GTK_WINDOW(preferences), "Preferences");
    gtk_window_set_resizable( GTK_WINDOW(preferences), FALSE);
    gtk_window_set_destroy_with_parent( GTK_WINDOW(preferences), TRUE);

    dialog_vbox3 = GTK_DIALOG(preferences)->vbox;
    gtk_widget_set_name(dialog_vbox3, "dialog_vbox3");
    gtk_widget_show(dialog_vbox3);

    fixed6 = gtk_fixed_new();
    gtk_widget_set_name(fixed6, "fixed6");
    gtk_widget_show(fixed6);
    gtk_box_pack_start( GTK_BOX(dialog_vbox3), fixed6, TRUE, TRUE, 0);

    entry2 = gtk_entry_new();
    gtk_widget_set_name(entry2, "entry2");
    gtk_widget_show(entry2);
    gtk_fixed_put( GTK_FIXED(fixed6), entry2, 96, 32);
    gtk_widget_set_size_request(entry2, 158, 24);
    gtk_tooltips_set_tip(tooltips, entry2, "path to MIX directory", NULL);

    entry6 = gtk_entry_new();
    gtk_widget_set_name(entry6, "entry6");
    gtk_widget_show(entry6);
    gtk_fixed_put( GTK_FIXED(fixed6), entry6, 96, 64);
    gtk_widget_set_size_request(entry6, 158, 24);

    label26 = gtk_label_new("Editor:");
    gtk_widget_set_name(label26, "label26");
    gtk_widget_show(label26);
    gtk_fixed_put( GTK_FIXED(fixed6), label26, 24, 68);
    gtk_widget_set_size_request(label26, 54, 16);

    label25 = gtk_label_new("Mix Path:");
    gtk_widget_set_name(label25, "label25");
    gtk_widget_show(label25);
    gtk_fixed_put( GTK_FIXED(fixed6), label25, 16, 40);
    gtk_widget_set_size_request(label25, 66, 16);

    select_mixpath_button = gtk_button_new_with_mnemonic("select...");
    gtk_widget_set_name(select_mixpath_button, "select_mixpath_button");
    gtk_widget_show(select_mixpath_button);
    gtk_fixed_put( GTK_FIXED(fixed6), select_mixpath_button, 256, 32);
    gtk_widget_set_size_request(select_mixpath_button, 60, 24);

    select_editor_button = gtk_button_new_with_mnemonic("select...");
    gtk_widget_set_name(select_editor_button, "select_editor_button");
    gtk_widget_show(select_editor_button);
    gtk_fixed_put( GTK_FIXED(fixed6), select_editor_button, 256, 64);
    gtk_widget_set_size_request(select_editor_button, 60, 24);

    dialog_action_area3 = GTK_DIALOG(preferences)->action_area;
    gtk_widget_set_name(dialog_action_area3, "dialog_action_area3");
    gtk_widget_show(dialog_action_area3);
    gtk_button_box_set_layout( GTK_BUTTON_BOX(dialog_action_area3), GTK_BUTTONBOX_END);

    preferences_cancel_button = gtk_button_new();
    gtk_widget_set_name(preferences_cancel_button, "preferences_cancel_button");
    gtk_widget_show(preferences_cancel_button);
    gtk_dialog_add_action_widget( GTK_DIALOG(preferences), preferences_cancel_button, GTK_RESPONSE_CANCEL);
    GTK_WIDGET_SET_FLAGS(preferences_cancel_button, GTK_CAN_DEFAULT);

    alignment4 = gtk_alignment_new(0.5, 0.5, 0, 0);
    gtk_widget_set_name(alignment4, "alignment4");
    gtk_widget_show(alignment4);
    gtk_container_add( GTK_CONTAINER(preferences_cancel_button), alignment4);

    hbox10 = gtk_hbox_new(FALSE, 2);
    gtk_widget_set_name(hbox10, "hbox10");
    gtk_widget_show(hbox10);
    gtk_container_add( GTK_CONTAINER(alignment4), hbox10);

    image69 = gtk_image_new_from_stock("gtk-cancel", GTK_ICON_SIZE_BUTTON);
    gtk_widget_set_name(image69, "image69");
    gtk_widget_show(image69);
    gtk_box_pack_start( GTK_BOX(hbox10), image69, FALSE, FALSE, 0);

    label15 = gtk_label_new_with_mnemonic("_Cancel");
    gtk_widget_set_name(label15, "label15");
    gtk_widget_show(label15);
    gtk_box_pack_start( GTK_BOX(hbox10), label15, FALSE, FALSE, 0);

    preferences_ok_button = gtk_button_new();
    gtk_widget_set_name(preferences_ok_button, "preferences_ok_button");
    gtk_widget_show(preferences_ok_button);
    gtk_dialog_add_action_widget( GTK_DIALOG(preferences), preferences_ok_button, GTK_RESPONSE_OK);
    GTK_WIDGET_SET_FLAGS(preferences_ok_button, GTK_CAN_DEFAULT);

    alignment6 = gtk_alignment_new(0.5, 0.5, 0, 0);
    gtk_widget_set_name(alignment6, "alignment6");
    gtk_widget_show(alignment6);
    gtk_container_add( GTK_CONTAINER(preferences_ok_button), alignment6);

    hbox12 = gtk_hbox_new(FALSE, 2);
    gtk_widget_set_name(hbox12, "hbox12");
    gtk_widget_show(hbox12);
    gtk_container_add( GTK_CONTAINER(alignment6), hbox12);

    image71 = gtk_image_new_from_stock("gtk-ok", GTK_ICON_SIZE_BUTTON);
    gtk_widget_set_name(image71, "image71");
    gtk_widget_show(image71);
    gtk_box_pack_start( GTK_BOX(hbox12), image71, FALSE, FALSE, 0);

    label17 = gtk_label_new_with_mnemonic("_OK");
    gtk_widget_set_name(label17, "label17");
    gtk_widget_show(label17);
    gtk_box_pack_start( GTK_BOX(hbox12), label17, FALSE, FALSE, 0);

    g_signal_connect((gpointer) select_mixpath_button, "clicked", G_CALLBACK(on_mixpath_btn_clicked), NULL);
    g_signal_connect((gpointer) select_editor_button, "clicked", G_CALLBACK(on_editorpath_btn_clicked), NULL);

    // Store pointers to all widgets, for use by lookup_widget()
    GLADE_HOOKUP_OBJECT_NO_REF(preferences, preferences, "preferences");
    GLADE_HOOKUP_OBJECT_NO_REF(preferences, dialog_vbox3, "dialog_vbox3");
    GLADE_HOOKUP_OBJECT(preferences, fixed6, "fixed6");
    GLADE_HOOKUP_OBJECT(preferences, entry2, "entry2");
    GLADE_HOOKUP_OBJECT(preferences, entry6, "entry6");
    GLADE_HOOKUP_OBJECT(preferences, label26, "label26");
    GLADE_HOOKUP_OBJECT(preferences, label25, "label25");
    GLADE_HOOKUP_OBJECT(preferences, select_mixpath_button, "select_mixpath_button");
    GLADE_HOOKUP_OBJECT(preferences, select_editor_button, "select_editor_button");
    GLADE_HOOKUP_OBJECT_NO_REF(preferences, dialog_action_area3, "dialog_action_area3");
    GLADE_HOOKUP_OBJECT(preferences, preferences_cancel_button, "preferences_cancel_button");
    GLADE_HOOKUP_OBJECT(preferences, alignment4, "alignment4");
    GLADE_HOOKUP_OBJECT(preferences, hbox10, "hbox10");
    GLADE_HOOKUP_OBJECT(preferences, image69, "image69");
    GLADE_HOOKUP_OBJECT(preferences, label15, "label15");
    GLADE_HOOKUP_OBJECT(preferences, preferences_ok_button, "preferences_ok_button");
    GLADE_HOOKUP_OBJECT(preferences, alignment6, "alignment6");
    GLADE_HOOKUP_OBJECT(preferences, hbox12, "hbox12");
    GLADE_HOOKUP_OBJECT(preferences, image71, "image71");
    GLADE_HOOKUP_OBJECT(preferences, label17, "label17");
    GLADE_HOOKUP_OBJECT_NO_REF(preferences, tooltips, "tooltips");

    return preferences;
}


GtkWidget* create_MixMonitor(void)
{
    GtkWidget *mixLog;
    GtkWidget *dialog_vbox4;
    GtkWidget *scrolledwindow1;
    GtkWidget *textview1;
    GtkWidget *dialog_action_area4;
    GtkWidget *mixLog_cancel_button;
    GtkWidget *mixLog_ok_button;

    mixLog = gtk_dialog_new();
    gtk_widget_set_name(mixLog, "mixLog");
    gtk_window_set_title( GTK_WINDOW(mixLog), "Mix status");
    gtk_window_set_default_size( GTK_WINDOW(mixLog), 460, 240);
    gtk_window_set_destroy_with_parent( GTK_WINDOW(mixLog), TRUE);
    gtk_dialog_set_has_separator( GTK_DIALOG(mixLog), FALSE);

    dialog_vbox4 = GTK_DIALOG(mixLog)->vbox;
    gtk_widget_set_name(dialog_vbox4, "dialog_vbox4");
    gtk_widget_show(dialog_vbox4);

    scrolledwindow1 = gtk_scrolled_window_new(NULL, NULL);
    gtk_widget_set_name(scrolledwindow1, "scrolledwindow1");
    gtk_widget_show(scrolledwindow1);
    gtk_box_pack_start( GTK_BOX(dialog_vbox4), scrolledwindow1, TRUE, TRUE, 0);

    textview1 = gtk_text_view_new();
    gtk_widget_set_name(textview1, "textview1");
    gtk_widget_show(textview1);
    gtk_container_add( GTK_CONTAINER(scrolledwindow1), textview1);

    dialog_action_area4 = GTK_DIALOG(mixLog)->action_area;
    gtk_widget_set_name(dialog_action_area4, "dialog_action_area4");
    gtk_widget_show(dialog_action_area4);
    gtk_button_box_set_layout( GTK_BUTTON_BOX(dialog_action_area4), GTK_BUTTONBOX_END);

    mixLog_cancel_button = gtk_button_new_from_stock("gtk-cancel");
    gtk_widget_set_name(mixLog_cancel_button, "mixLog_cancel_button");
    gtk_widget_show(mixLog_cancel_button);
    gtk_dialog_add_action_widget( GTK_DIALOG(mixLog), mixLog_cancel_button, GTK_RESPONSE_CANCEL);
    GTK_WIDGET_SET_FLAGS(mixLog_cancel_button, GTK_CAN_DEFAULT);

    mixLog_ok_button = gtk_button_new_from_stock("gtk-ok");
    gtk_widget_set_name(mixLog_ok_button, "mixLog_ok_button");
    gtk_widget_show(mixLog_ok_button);
    gtk_dialog_add_action_widget( GTK_DIALOG(mixLog), mixLog_ok_button, GTK_RESPONSE_OK);
    GTK_WIDGET_SET_FLAGS(mixLog_ok_button, GTK_CAN_DEFAULT);

    //    g_signal_connect((gpointer) mixLog_cancel_button, "clicked", G_CALLBACK(on_mixLog_cancel_btn_clicked), NULL);
    //    g_signal_connect((gpointer) mixLog_ok_button, "clicked", G_CALLBACK(on_mixLog_ok_btn_clicked), NULL);

    // Store pointers to all widgets, for use by lookup_widget()
    GLADE_HOOKUP_OBJECT_NO_REF(mixLog, mixLog, "mixLog");
    GLADE_HOOKUP_OBJECT_NO_REF(mixLog, dialog_vbox4, "dialog_vbox4");
    GLADE_HOOKUP_OBJECT(mixLog, scrolledwindow1, "scrolledwindow1");
    GLADE_HOOKUP_OBJECT(mixLog, textview1, "textview1");
    GLADE_HOOKUP_OBJECT_NO_REF(mixLog, dialog_action_area4, "dialog_action_area4");
    GLADE_HOOKUP_OBJECT(mixLog, mixLog_cancel_button, "mixLog_cancel_button");
    GLADE_HOOKUP_OBJECT(mixLog, mixLog_ok_button, "mixLog_ok_button");

    return mixLog;
}


gint create_dialog(const char *title)
{
    gint response;

    gtk_window_set_title(GTK_WINDOW(file_dialog), title);
    response = gtk_dialog_run(GTK_DIALOG(file_dialog));
    gtk_widget_hide(file_dialog);

    return response;
}


const char* create_file_dialog(const char *title) {

    gint response;

    response = create_dialog(title);
    gtk_widget_hide(file_dialog);
    if(response == GTK_RESPONSE_OK) {
    
	const char *os_filename;
	struct stat statvar;
	os_filename = gtk_file_selection_get_filename(GTK_FILE_SELECTION(file_dialog));

	// Todo: check if file exists	if(stat(os_filename, &statvar)!=0) return NULL;

	return os_filename;
    }
    return NULL;
}


const char* create_directory_dialog() {

    gint response;

    response = create_dialog("select Directory");
    if(response == GTK_RESPONSE_OK) {
	int i;
        const char *os_filename;
        os_filename = gtk_file_selection_get_filename(GTK_FILE_SELECTION(file_dialog));
	DIR* dir = opendir(os_filename);
	if(dir!=NULL) {
	    closedir(dir);
	    return os_filename;
	}
    }
    return NULL;
}


void create_about_dialog(void)
{
  GtkWidget *button, *l1, *l2;

  if (about_dialog_open) {
    gdk_window_raise(GTK_WIDGET(about_dialog)->window);
    return;
  }

  about_dialog = gtk_dialog_new();
  gtk_window_set_title(GTK_WINDOW(about_dialog), about_title);
  gtk_window_set_policy(GTK_WINDOW(about_dialog), FALSE, FALSE, TRUE);
  gtk_signal_connect(GTK_OBJECT(about_dialog), "destroy", GTK_SIGNAL_FUNC(about_destroy), NULL);

  l1 = gtk_label_new(about_text1);
  gtk_box_pack_start(GTK_BOX(GTK_DIALOG(about_dialog)->vbox), l1, TRUE, TRUE, 0);
  gtk_widget_show(l1);

  l2 = gtk_label_new(about_text2);
  gtk_box_pack_start(GTK_BOX(GTK_DIALOG(about_dialog)->vbox), l2, TRUE, TRUE, 0);
  gtk_widget_show(l2);

  button = gtk_button_new_with_label("Ok");
  gtk_signal_connect_object(GTK_OBJECT(button), "clicked", GTK_SIGNAL_FUNC(gtk_widget_destroy), GTK_OBJECT(about_dialog));
  gtk_box_pack_start(GTK_BOX(GTK_DIALOG(about_dialog)->action_area), button, FALSE, FALSE, 0);
  gtk_widget_set_usize(button, 90, 22);

  gtk_widget_show(button);
  gtk_widget_show(about_dialog);

  about_dialog_open = TRUE;

  return;
}


void about_destroy(GtkWidget *w, gpointer d)
{
  about_dialog_open = FALSE;

  gtk_widget_destroy(GTK_WIDGET(w));

  return;
}


void create_info_dialog(char *title, char *message)
{
    GtkWidget *info_dialog, *label;

    info_dialog = gtk_dialog_new();

    info_dialog = gtk_dialog_new_with_buttons( title, GTK_WINDOW(get_mainwindow()),
                                         GTK_DIALOG_DESTROY_WITH_PARENT,
                                         GTK_STOCK_OK,
                                         GTK_RESPONSE_ACCEPT,
                                         NULL);

    label = gtk_label_new(message);
    gtk_box_pack_start(GTK_BOX(GTK_DIALOG(info_dialog)->vbox), label, TRUE, TRUE, 0);
    gtk_widget_show(label);

    gtk_widget_show(info_dialog);

    gtk_dialog_run(GTK_DIALOG(info_dialog));
    gtk_widget_destroy(info_dialog);
}
