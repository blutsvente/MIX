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

#include "connview.h"


enum {
  COL_IGN = 0,
  COL_GEN,
  COL_BUNDLE,
  COL_CLASS,
  COL_CLOCK,
  COL_TYPE,
  COL_HIGH,
  COL_LOW,
  COL_MODE,
  COL_NAME,
  COL_SHORTNAME,
  COL_OUT,
  COL_IN,
  COL_DESC,
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
    {"::gen", "text", TRUE},
    {"::bundle", "text", TRUE},
    {"::class", "text", TRUE},
    {"::clock", "text", TRUE},
    {"::type", "text", TRUE},
    {"::high", "text", TRUE},
    {"::low", "text", TRUE},
    {"::mode", "text", TRUE},
    {"::name", "text", TRUE},
    {"::shortname", "text", TRUE},
    {"::out", "text", TRUE},
    {"::in", "text", TRUE},
    {"::descr", "text", TRUE},
    {"::comment", "text", TRUE},
    {"::default", "text", TRUE},
    {"::debug", "text", TRUE},
    {"::skip", "text", TRUE},
};

static GtkTreeModel* create_conn_model(void);


GtkWidget* create_conn_view(void)
{
    int i = 0;
    GtkTreeViewColumn   *col;
    GtkCellRenderer     *renderer;
    GtkWidget           *view;
    GtkTreeModel        *model;

    view = gtk_tree_view_new();
    // --- Column #X ---
    while(i < NUM_COLS) {

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

    model = (GtkTreeModel*) create_conn_model();

    gtk_tree_view_set_model(GTK_TREE_VIEW(view), model);

    g_object_unref(model); // destroy model automatically with view

    gtk_tree_view_set_rules_hint(GTK_TREE_VIEW(view), TRUE);
    gtk_tree_selection_set_mode(gtk_tree_view_get_selection(GTK_TREE_VIEW(view)), GTK_SELECTION_MULTIPLE);

    return view;
}


GtkTreeModel* create_conn_model(void)
{
    int i = 0;
    int numOfRows = mix_number_of_conn_rows();
    char ign[1024], gen[1024], bun[1024], cls[1024], clk[1024], type[1024], hig[1024], low[1024];
    char mode[1024], name[1024], sname[1024], out[1024], in[1024], des[1024], com[1024] ,def[1024], deb[1024], skip[1024];
    char *row[] = { ign, gen, bun, cls, clk, type, hig, low, mode, name, sname, out, in, des, com, def, deb, skip};
    GtkTreeStore  *treestore;
    GtkTreeIter    toplevel;

    treestore = gtk_tree_store_new(NUM_COLS, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING,
				             G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING,
				             G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING,
				             G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING);

    while(i < numOfRows) {
	mix_get_conn_row(i,row);

	// Append a top level row and leave it empty
	gtk_tree_store_append(treestore, &toplevel, NULL);
	gtk_tree_store_set(treestore, &toplevel, COL_IGN, ign, COL_GEN, gen, COL_BUNDLE, bun,
			   COL_CLASS, cls, COL_CLOCK, clk, COL_TYPE, type, COL_HIGH, hig, COL_LOW, low,
			   COL_MODE, mode, COL_NAME, name, COL_SHORTNAME, sname, COL_OUT, out, COL_IN, in, COL_DESC, des,
			   COL_COM, com, COL_DEFAULT, def, COL_DEBUG, deb, COL_SKIP, skip, -1);

	i++;
    }

    return GTK_TREE_MODEL(treestore);
}
