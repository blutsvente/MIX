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

#include "callbacks.h"
#include "i2cview.h"


enum {
    I2C_IGN = 0,
    I2C_COM,
    I2C_VAR,
    I2C_DEV,
    I2C_SUB,
    I2C_INT,
    I2C_BLOCK,
    I2C_DIR,
    I2C_SPEC,
    I2C_CLOCK,
    I2C_RESET,
    I2C_BUSY,
    I2C_INIT,
    I2C_REC,
    I2C_B,
    I2C_NUM_COLS
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


GtkTreeModel *i2c_model;


static GtkTreeModel* create_i2c_model(void);


GtkWidget* create_i2c_view()
{
    int i = 0;
    int loc_i;
    int num_cols = I2C_NUM_COLS + mix_number_of_i2c_headers() - 1;
    GtkTreeViewColumn   *col;
    GtkCellRenderer     *renderer;
    GtkWidget           *view;

    view = gtk_tree_view_new();
    // --- Column #X ---
    while(i < num_cols) {

	col = gtk_tree_view_column_new();

	loc_i = i > I2C_B ? I2C_B : i;
	gtk_tree_view_column_set_spacing(col, 1);
	gtk_tree_view_column_set_title(col, header[loc_i].title);

	// pack tree view column into tree view
	gtk_tree_view_append_column(GTK_TREE_VIEW(view), col);

	renderer = gtk_cell_renderer_text_new();
	g_object_set(renderer, "editable", header[loc_i].editable, NULL);
	g_object_set_data(G_OBJECT(renderer), "column_index", GUINT_TO_POINTER(i));
	g_signal_connect(renderer, "edited", (GCallback) i2c_edited_callback, NULL);

	// pack cell renderer into tree view column
	gtk_tree_view_column_pack_start(col, renderer, TRUE);

	// connect 'text' property of the cell renderer to
	// model column that contains the first name
	gtk_tree_view_column_add_attribute(col, renderer, header[loc_i].type, i);
	i++;
    }

    i2c_model = (GtkTreeModel*) create_i2c_model();

    gtk_tree_view_set_model(GTK_TREE_VIEW(view), i2c_model);

    g_object_unref(i2c_model); // destroy model automatically with view

    gtk_tree_view_set_rules_hint(GTK_TREE_VIEW(view), TRUE);
    gtk_tree_view_set_headers_clickable(GTK_TREE_VIEW(view), TRUE);
    gtk_tree_selection_set_mode(gtk_tree_view_get_selection(GTK_TREE_VIEW(view)), GTK_SELECTION_MULTIPLE);

    return view;
}


GtkTreeModel* create_i2c_model(void)
{
    int i = 0;
    int j = 0;
    int numOfRows = mix_number_of_i2c_rows();
    int numOfB = mix_number_of_i2c_headers();
    int numOfHeaders = I2C_NUM_COLS + numOfB - 1;
    char ign[1024], com[1024], var[1024], dev[1024], sub[1024], inter[1024], blk[1024], dir[1024], spc[1024], clk[1024], rst[1024], bsy[1024], init[1024], rec[1024];
    char **b;
    char *row[] = {ign, com, var, dev, sub, inter, blk, dir, spc, clk, rst, bsy, init, rec};
    GtkTreeStore  *treestore;
    GtkTreeIter    toplevel;
    GType *header_types;

    // dynamically allocate header
    b = (char**) malloc(sizeof(char*) * numOfB);
    while(i < numOfB) {
	b[i] = (char*) malloc(numOfHeaders * sizeof(G_TYPE_STRING));
	i++;
    }
    header_types = (GType*) malloc(numOfHeaders * sizeof(G_TYPE_STRING));

    i = 0;
    while(i < numOfHeaders) {
	header_types[i] = G_TYPE_STRING;
	i++;
    }
    treestore = gtk_tree_store_newv(numOfHeaders, header_types);

    i = 0;
    while(i < numOfRows) {

	mix_get_i2c_sta_row(i, row);
	mix_get_i2c_dyn_row(i, b);

	// Append a top level row and leave it empty
	gtk_tree_store_append(treestore, &toplevel, NULL);
        gtk_tree_store_set(treestore, &toplevel, I2C_IGN, ign, I2C_COM, com, I2C_VAR, var, I2C_DEV, dev,
			   I2C_SUB, sub, I2C_INT, inter, I2C_BLOCK, blk, I2C_DIR, dir, I2C_SPEC, spc,
			   I2C_CLOCK, clk, I2C_RESET, rst, I2C_BUSY, bsy, I2C_INIT, init, I2C_REC, rec, -1);
	//	g_error_free(error);

	j = I2C_B;
	while(j < numOfHeaders) {
	    gtk_tree_store_set(treestore, &toplevel, j, b[j - I2C_B], -1);
	    j++;
	}

	i++;
    }

    i = 0;
    while(i < numOfB) {
	free(b[i]);
	i++;
    }
    free(b);
    free(header_types);
    return GTK_TREE_MODEL(treestore);
}


void i2c_col_index_to_name(char *name, int column)
{
    if(column > 0 && column <= I2C_B)
	strcpy(name, header[column].title);
    else if(column > I2C_B)
	sprintf(name, "%s:%d", header[I2C_B].title, column - I2C_B);
    else
	strcpy(name, "unknown");
}
