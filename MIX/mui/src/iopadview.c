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
  NUM_COLS
};


static struct {
    char *title;
    char *type;
} header[] = {
    {"::ign", "text",},
    {"::comment", "text"},
    {"::class", "text"},
    {"::ispin", "text"},
    {"::pin", "text"},
    {"::pad", "text"},
    {"::type", "text"},
    {"::iocell", "text"},
    {"::port", "text"},
    {"::name", "text"},
    {"::muxopt", "text"},
};


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

	gtk_tree_view_column_set_title(col, header[i].title);

	// pack tree view column into tree view
	gtk_tree_view_append_column(GTK_TREE_VIEW(view), col);

	renderer = gtk_cell_renderer_text_new();

	// pack cell renderer into tree view column
	gtk_tree_view_column_pack_start(col, renderer, TRUE);

	// connect 'text' property of the cell renderer to
	// model column that contains the first name
	gtk_tree_view_column_add_attribute(col, renderer, header[i].type, i);
	i++;
    }

    // connect a cell data function
    // gtk_tree_view_column_set_cell_data_func(col, renderer, age_cell_data_func, NULL, NULL);

    //  model = create_iopoad_model();

    //    gtk_tree_view_set_model(GTK_TREE_VIEW(view), model);

    //    g_object_unref(model); // destroy model automatically with view

    gtk_tree_selection_set_mode(gtk_tree_view_get_selection(GTK_TREE_VIEW(view)), GTK_SELECTION_NONE);
    return view;
}


static GtkTreeModel* create_and_fill_model(void)
{
    GtkTreeStore  *treestore;
    GtkTreeIter    toplevel, child;

    //    treestore = gtk_tree_store_new(NUM_COLS, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_UINT);

    // Append a top level row and leave it empty
    //    gtk_tree_store_append(treestore, &toplevel, NULL);
    //    gtk_tree_store_set(treestore, &toplevel, COL_FIRST_NAME, "Maria", COL_LAST_NAME, "Incognito", -1);

    // Append a second top level row, and fill it with some data
    //    gtk_tree_store_append(treestore, &toplevel, NULL);
    //    gtk_tree_store_set(treestore, &toplevel, COL_FIRST_NAME, "Jane", COL_LAST_NAME, "Average", COL_YEAR_BORN, (guint) 1962, -1);

    // Append a child to the second top level row, and fill in some data
    //    gtk_tree_store_append(treestore, &child, &toplevel);
    //    gtk_tree_store_set(treestore, &child, COL_FIRST_NAME, "Janinita", COL_LAST_NAME, "Average", COL_YEAR_BORN, (guint) 1985, -1);

    return GTK_TREE_MODEL(treestore);
}


void age_cell_data_func(GtkTreeViewColumn *col, GtkCellRenderer *renderer, 
			GtkTreeModel *model, GtkTreeIter *iter, gpointer user_data)
{
    guint  year_born;
    guint  year_now = 2003; // to save code not relevant for the example
    gchar  buf[64];

    //    gtk_tree_model_get(model, iter, COL_YEAR_BORN, &year_born, -1);

    if (year_born <= year_now && year_born > 0)	{
      guint age = year_now - year_born;

      g_snprintf(buf, sizeof(buf), "%u years old", age);

      g_object_set(renderer, "foreground-set", FALSE, NULL); // print this normal
    }
    else {
	g_snprintf(buf, sizeof(buf), "age unknown");

	// make red
	g_object_set(renderer, "foreground", "Red", "foreground-set", TRUE, NULL);
    }

    g_object_set(renderer, "text", buf, NULL);
}
