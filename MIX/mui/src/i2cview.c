/**
 *
 *  File:    i2cview.c
 *  Project: Mui - MIX Userinterface
 *  Author:  Alexander Bauer <Alexander.Bauer@Micronas.com>
 *
 */


#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include "i2cview.h"


enum {
    COL_IGN = 0,
    COL_COM,
    COL_VAR,
    COL_DEV,
    COL_SUB,
    COL_INT,
    COL_BLOCK,
    COL_DIR,
    COL_SPEC,
    COL_CLOCK,
    COL_RESET,
    COL_BUSY,
    COL_INIT,
    COL_REC,
    COL_B,
    NUM_COLS
};


static struct {
    char *title;
    char *type;
    gboolean editable;
} header[] = {
    {"::ign", "text", TRUE},
    {"::comment", "text", TRUE},
    {"::variants", "text", TRUE},
    {"::dev", "text", TRUE},
    {"::sub", "text", TRUE},
    {"::interface", "text", TRUE},
    {"::block", "text", TRUE},
    {"::dir", "text", TRUE},
    {"::spec", "text", TRUE},
    {"::clock", "text", TRUE},
    {"::reset", "text", TRUE},
    {"::busy", "text", TRUE},
    {"::init", "text", TRUE},
    {"::rec", "text", TRUE},
    {"::b", "text", TRUE},
};


static GtkTreeModel* create_i2c_model(void);


GtkWidget* create_i2c_view()
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

    model = (GtkTreeModel*) create_i2c_model();

    gtk_tree_view_set_model(GTK_TREE_VIEW(view), model);

    g_object_unref(model); // destroy model automatically with view

    gtk_tree_view_set_rules_hint(GTK_TREE_VIEW(view), TRUE);
    gtk_tree_selection_set_mode(gtk_tree_view_get_selection(GTK_TREE_VIEW(view)), GTK_SELECTION_MULTIPLE);

    return view;
}


GtkTreeModel* create_i2c_model(void)
{
    int i = 0;
    int numOfRows = mix_number_of_i2c_rows();
    char ign[1024], com[1024], var[1024], dev[1024], sub[1024], inter[1024], blk[1024], dir[1024], spc[1024], clk[1024], rst[1024], bsy[1024], init[1024], rec[1024], b[1024];
    char *row[] = {ign, com, var, dev, sub, inter, blk, dir, spc, clk, rst, bsy, init, rec, b};
    GtkTreeStore  *treestore;
    GtkTreeIter    toplevel;

    treestore = gtk_tree_store_new(NUM_COLS, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING,
				             G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING,
				             G_TYPE_STRING ,G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING);

    while(i < numOfRows) {

	mix_get_i2c_row(i, row);

	// Append a top level row and leave it empty
	gtk_tree_store_append(treestore, &toplevel, NULL);
        gtk_tree_store_set(treestore, &toplevel, COL_IGN, ign, COL_COM, com, COL_VAR, var, COL_DEV, dev, COL_SUB, sub,
			   COL_INT, inter, COL_BLOCK, blk, COL_DIR, dir, COL_SPEC, spc, COL_CLOCK, clk, COL_RESET, rst,
			   COL_BUSY, bsy, COL_INIT, init, COL_REC, rec, COL_B, b, -1);

	i++;
    }

    return GTK_TREE_MODEL(treestore);
}
