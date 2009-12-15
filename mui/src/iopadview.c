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

#include "callbacks.h"
#include "iopadview.h"


enum {
  IOPAD_IGN = 0,
  IOPAD_CLASS,
  IOPAD_ISPIN,
  IOPAD_PIN,
  IOPAD_PAD,
  IOPAD_TYPE,
  IOPAD_IOCELL,
  IOPAD_PORT,
  IOPAD_NAME,
  IOPAD_COM,
  IOPAD_DEFAULT,
  IOPAD_DEBUG,
  IOPAD_SKIP,
  IOPAD_MUXOPT,
  IOPAD_NUM_COLS
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
    {"::comment", "text", TRUE},
    {"::default", "text", TRUE},
    {"::debug", "text", TRUE},
    {"::skip", "text", TRUE},
    {"::muxopt", "text", TRUE},
};


GtkTreeModel *iopad_model;

static GtkTreeModel* create_iopad_model(void);


GtkWidget* create_iopad_view(void)
{
    int i = 0;
    int loc_i;
    int num_cols = IOPAD_NUM_COLS + mix_number_of_iopad_headers() - 1;
    GtkTreeViewColumn   *col;
    GtkCellRenderer     *renderer;
    GtkWidget           *view;

    view = gtk_tree_view_new();
    // --- Column #X ---
    while(i < num_cols) {

	col = gtk_tree_view_column_new();

	loc_i = i > IOPAD_MUXOPT ? IOPAD_MUXOPT : i;
	gtk_tree_view_column_set_spacing(col, 1);
	gtk_tree_view_column_set_title(col, header[loc_i].title);

	// pack tree view column into tree view
	gtk_tree_view_append_column(GTK_TREE_VIEW(view), col);

	renderer = gtk_cell_renderer_text_new();
	g_object_set(renderer, "editable", header[loc_i].editable, NULL);
	g_object_set_data(G_OBJECT(renderer), "column_index", GUINT_TO_POINTER(i));
	g_signal_connect(renderer, "edited", (GCallback) iopad_edited_callback, NULL);

	// pack cell renderer into tree view column
	gtk_tree_view_column_pack_start(col, renderer, TRUE);

	// connect 'text' property of the cell renderer to
	// model column that contains the first name
	gtk_tree_view_column_add_attribute(col, renderer, header[loc_i].type, i);
	i++;
    }

    iopad_model = (GtkTreeModel*) create_iopad_model();

    gtk_tree_view_set_model(GTK_TREE_VIEW(view), iopad_model);

    g_object_unref(iopad_model); // destroy model automatically with view

    gtk_tree_view_set_rules_hint(GTK_TREE_VIEW(view), TRUE);
    gtk_tree_view_set_headers_clickable(GTK_TREE_VIEW(view), TRUE);
    gtk_tree_selection_set_mode(gtk_tree_view_get_selection(GTK_TREE_VIEW(view)), GTK_SELECTION_MULTIPLE);

    return view;
}


GtkTreeModel* create_iopad_model(void)
{
    int i = 0;
    int j = 0;
    int numOfPads = mix_number_of_iopad_rows();
    int numOfMux = mix_number_of_iopad_headers();
    int numOfHeaders = IOPAD_NUM_COLS + numOfMux - 1;
    char ign[1024], cls[1024], isp[1024], pin[1024], pad[1024], typ[1024], ioc[1024];
    char prt[1024], nam[1024], com[1024] , def[1024], deb[1024], skip[1024];
    char **mux;
    char *row[] = {skip, deb, def, com, nam, prt, ioc, typ, pad, pin, isp, cls, ign};
    GtkTreeStore  *treestore;
    GtkTreeIter    toplevel;
    GType *header_types;

    // dynamically allocate header
    mux = (char**) malloc(sizeof(char*) * numOfMux);
    while(i < numOfMux) {
	mux[i] = (char*) malloc(sizeof(char) * 1024);
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
    while(i < numOfPads) {

	mix_get_iopad_sta_row(i, row);
	mix_get_iopad_dyn_row(i, mux);

	// Append a top level row and leave it empty
	gtk_tree_store_append(treestore, &toplevel, NULL);
	gtk_tree_store_set(treestore, &toplevel, IOPAD_IGN, ign, IOPAD_CLASS, cls, IOPAD_ISPIN, isp, IOPAD_PIN,
			   pin, IOPAD_PAD, pad, IOPAD_TYPE, typ, IOPAD_IOCELL, ioc, IOPAD_PORT, prt, IOPAD_NAME,
			   nam, IOPAD_COM, com, IOPAD_DEFAULT, def, IOPAD_DEBUG, deb, IOPAD_SKIP, skip, - 1);
	// TODO: maybe find a nicer way to store this list
	j = IOPAD_MUXOPT;
	while(j < numOfHeaders) {
	    gtk_tree_store_set(treestore, &toplevel, j, mux[j - IOPAD_MUXOPT], -1);
	    j++;
	}
	i++;
    }
    i = 0;
    while(i < numOfMux) {
	free(mux[i]);
	i++;
    }
    free(mux);
    free(header_types);
    return GTK_TREE_MODEL(treestore);
}


void iopad_col_index_to_name(char *name, int column)
{
    if(column > 0 && column <= IOPAD_MUXOPT)
	strcpy(name, header[column].title);
    else if(column > IOPAD_MUXOPT)
	sprintf(name, "%s:%d", header[IOPAD_MUXOPT].title, column - IOPAD_MUXOPT);
    else
	strcpy(name, "unknown");
}
