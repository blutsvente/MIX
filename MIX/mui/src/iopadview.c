/**
 *
 *  File:    iopadview.c
 *  Project: Mui - MIX Userinterface
 *  Author:  Alexander Bauer <Alexander.Bauer@Micronas.com>
 *
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include "iopadview.h"


enum {
  COL_IGN = 0,
  COL_CLASS,
  COL_ISPIN,
  COL_PIN,
  COL_PAD,
  COL_TYPE,
  COL_IOCELL,
  COL_PORT,
  COL_NAME,
  COL_MUXOPT,
  COL_COM,
  COL_DEFAULT,
  COL_DEBUG,
  COL_SKIP,
  NUM_COLS
};


static struct {
    char *title;
    char *type;
    gboolean editable;
} header[] = {
    {"::ign", "text", TRUE},
    {"::class", "text", TRUE},
    {"::ispin", "text", TRUE},
    {"::pin", "text", TRUE},
    {"::pad", "text", TRUE},
    {"::type", "text", TRUE},
    {"::iocell", "text", TRUE},
    {"::port", "text", TRUE},
    {"::name", "text", TRUE},
    {"::muxopt", "text", TRUE},
    {"::comment", "text", TRUE},
    {"::default", "text", TRUE},
    {"::debug", "text", TRUE},
    {"::skip", "text", TRUE},
};


static GtkTreeModel* create_iopad_model(void);


GtkWidget* create_iopad_view(void)
{
    int i = 0;
    int num_ext_cols = 0;
    GtkTreeViewColumn   *col;
    GtkCellRenderer     *renderer;
    GtkWidget           *view;
    GtkTreeModel        *model;

    view = gtk_tree_view_new();
    // --- Column #X ---
    while(i < NUM_COLS + num_ext_cols) {

	col = gtk_tree_view_column_new();

	gtk_tree_view_column_set_spacing(col, 1);
	gtk_tree_view_column_set_title(col, header[i].title);

	// pack tree view column into tree view
	gtk_tree_view_append_column(GTK_TREE_VIEW(view), col);

	renderer = gtk_cell_renderer_text_new();
	g_object_set(renderer, "editable", header[i].editable, NULL);

	// pack cell renderer into tree view column
	gtk_tree_view_column_pack_start(col, renderer, TRUE);

	// connect 'text' property of the cell renderer to
	// model column that contains the first name
	gtk_tree_view_column_add_attribute(col, renderer, header[i].type, i);
	i++;
    }

    model = (GtkTreeModel*) create_iopad_model();

    gtk_tree_view_set_model(GTK_TREE_VIEW(view), model);

    g_object_unref(model); // destroy model automatically with view

    gtk_tree_view_set_rules_hint(GTK_TREE_VIEW(view), TRUE);
    gtk_tree_selection_set_mode(gtk_tree_view_get_selection(GTK_TREE_VIEW(view)), GTK_SELECTION_MULTIPLE);

    return view;
}


GtkTreeModel* create_iopad_model(void)
{
    int i = 0;
    int numOfPads = mix_number_of_iopad_rows();
    char ign[1024], cls[1024], isp[1024], pin[1024], pad[1024], typ[1024], ioc[1024], prt[1024], nam[1024], mux[1024];
    char com[1024] , def[1024], deb[1024], skip[1024];
    char *row[] = { ign, cls, isp, pin, pad, typ, ioc, prt, nam, mux, com, def, deb, skip};
    GtkTreeStore  *treestore;
    GtkTreeIter    toplevel;

    treestore = gtk_tree_store_new(NUM_COLS, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING,
				             G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING,
				             G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING);

    while(i < numOfPads) {

	mix_get_iopad_row(i, row);

	// Append a top level row and leave it empty
	gtk_tree_store_append(treestore, &toplevel, NULL);
	gtk_tree_store_set(treestore, &toplevel, COL_IGN, ign, COL_CLASS, cls, COL_ISPIN, isp, 
			   COL_PIN, pin, COL_PAD, pad, COL_TYPE, typ, COL_IOCELL, ioc, COL_PORT, prt, COL_NAME, nam, COL_MUXOPT, mux, COL_COM, com, COL_DEFAULT, def, COL_DEBUG, deb, COL_SKIP, skip,-1);

	i++;
    }

    return GTK_TREE_MODEL(treestore);
}
