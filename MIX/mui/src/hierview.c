/**
 *
 *  File:    hiertree.cpp
 *  Project: Mui - MIX Userinterface
 *  Author:  Alexander Bauer <Alexander.Bauer@Micronas.com>
 *
 */

#include <stdio.h>

#include "hierview.h"


enum {
    COL_NAME = 0,
    NUM_COLS
};


/**
 * create the hierarchical tree
 */
static void create_hiertree();

/**
 * recursive function creates child elements
 */
static void create_Childs();

/**
 * some globals
 */
GtkTreeStore *store;


GtkWidget* create_hier_view()
{
    GtkTreeViewColumn   *col;
    GtkTreeModel        *model;
    GtkCellRenderer     *renderer;
    GtkWidget           *view;

    view = gtk_tree_view_new();

    // --- Column #1 ---
    renderer = gtk_cell_renderer_text_new ();
    gtk_tree_view_insert_column_with_attributes(GTK_TREE_VIEW (view), -1, "Name", renderer, "text", COL_NAME, NULL);

    store = gtk_tree_store_new(NUM_COLS, G_TYPE_STRING, G_TYPE_UINT);
    model = GTK_TREE_MODEL(store);

    gtk_tree_view_set_model(GTK_TREE_VIEW (view), model);

    g_object_unref(model); // destroy model automatically with view

    create_hiertree();

    return view;
}


void create_hiertree()
{
    char name[INSTANCE_NAME_LENGTH];
    GtkTreeIter iter;

    // set tree generator to TOPLEVEL
    if(!mix_initTreeWalk()) return;

    mix_getNextName(name);

    while(strlen(name)>0)
    {
	//Fill the TreeView's model
	gtk_tree_store_append(store, &iter, NULL);
	gtk_tree_store_set(store, &iter, COL_NAME, name, -1);

	if(mix_hasChilds())
	{
	    // recursive function creates children
	    create_Childs(&iter);
	}
	mix_getNextName(name);
    }
}


void create_Childs(GtkTreeIter *parent)
{
    char name[INSTANCE_NAME_LENGTH];
    GtkTreeIter iter;

    mix_getNextName(name);

    while(strlen(name)>0)
    {
	// create a new node
	gtk_tree_store_append(store, &iter, parent);
	gtk_tree_store_set(store, &iter, COL_NAME, name, -1);

	if(mix_hasChilds())    
	{   // create a tree node with children
	    create_Childs(&iter);
	}
	mix_getNextName(name);
    }
}
