/**
 *
 *  File:    hierview.cpp
 *  Project: Mui - MIX Userinterface
 *  Author:  Alexander Bauer <Alexander.Bauer@Micronas.com>
 *
 */

#include <stdio.h>

#include "callbacks.h"
#include "support.h"
#include "hierview.h"

enum {
    HIER_IGN = 0,
    HIER_GEN,
    HIER_VAR,
    HIER_PAR,
    HIER_INST,
    HIER_LANG,
    HIER_ENT,
    HIER_ARC,
    HIER_CONF,
    HIER_USE,
    HIER_COM,
    HIER_DES,
    HIER_SNAME,
    HIER_DEF,
    HIER_HIER,
    HIER_DEB,
    HIER_SKIP,
    HIER_NUM_COLS
};

static struct {
    char *title;
    char *type;
    gboolean editable;
} header[] = {
    {"::ign", "text", TRUE},
    {"::gen", "text", TRUE},
    {"::variants", "text", TRUE},
    {"::parent", "text", TRUE},
    {"::inst", "text", TRUE},
    {"::lang", "text", TRUE},
    {"::entity", "text", TRUE},
    {"::arch", "text", TRUE},
    {"::config", "text", TRUE},
    {"::use", "text", TRUE},
    {"::comment", "text", TRUE},
    {"::descr", "text", TRUE},
    {"::shortname", "text", TRUE},
    {"::default", "text", TRUE},
    {"::hierarchy", "text", TRUE},
    {"::debug", "text", TRUE},
    {"::skip", "text", TRUE},
};

GtkTreeModel *hier_model;

static GtkTreeModel* create_hier_model(void);


// the following stuff is needed for the hierachy treeview

enum {
    HTREE_INST = 0,
    HTREE_NUM_COLS
};

/**
 * initialize a hier treeview
 */
static GtkWidget* init_hiertree();
/**
 * create the hierarchical tree
 */
static void create_hiertree();
/**
 * recursive function creates child elements
 */
static void create_childs();

/**
 * some globals
 */
GtkTreeStore *store;

/**
 * HierTree Detail entries
 */
GtkWidget *variEntry;
GtkWidget *instEntry;
GtkWidget *entityEntry;
GtkWidget *configEntry;
GtkWidget *commentEntry;
GtkWidget *mdeParentEntry;
GtkWidget *mdeInstEntry;
GtkWidget *mdeEntityEntry;
GtkWidget *genEntry;
GtkWidget *ignoreCheckbutton;


GtkWidget* create_hiertree_view(void)
{
    GtkWidget *detailsHbox;
    GtkWidget *scrolledwindow1;
    GtkWidget *hierTreeview;
    GtkWidget *detailsFrame;
    GtkWidget *detailsFixed;
    GtkWidget *instLabel;
    GtkWidget *entityLabel;
    GtkWidget *commentLabel;
    GtkWidget *configLabel;
    GtkWidget *variLabel;
    GtkWidget *langCombo;
    GList *langCombo_items = NULL;
    GtkWidget *langComboEntry;
    GtkWidget *langLabel;
    GtkWidget *mdeParentLabel;
    GtkWidget *mdeInstLabel;
    GtkWidget *mdeEntityLabel;
    GtkWidget *genLabel;
    GtkWidget *detailsLabel;
    GtkTooltips *tooltips;

    tooltips = gtk_tooltips_new();

    detailsHbox = gtk_hbox_new (FALSE, 0);
    gtk_widget_set_name (detailsHbox, "detailsHbox");

    scrolledwindow1 = gtk_scrolled_window_new (NULL, NULL);
    gtk_widget_set_name (scrolledwindow1, "scrolledwindow1");
    gtk_widget_show (scrolledwindow1);
    gtk_box_pack_start (GTK_BOX (detailsHbox), scrolledwindow1, TRUE, TRUE, 0);
    gtk_container_set_border_width (GTK_CONTAINER (scrolledwindow1), 1);

    hierTreeview = init_hiertree();
    gtk_widget_show (hierTreeview);
    gtk_container_add (GTK_CONTAINER (scrolledwindow1), hierTreeview);

    detailsFrame = gtk_frame_new (NULL);
    gtk_widget_set_name (detailsFrame, "detailsFrame");
    gtk_widget_show (detailsFrame);
    gtk_box_pack_start (GTK_BOX (detailsHbox), detailsFrame, TRUE, TRUE, 0);
    gtk_widget_set_size_request (detailsFrame, 2, -1);
    gtk_container_set_border_width (GTK_CONTAINER (detailsFrame), 2);

    detailsFixed = gtk_fixed_new ();
    gtk_widget_set_name (detailsFixed, "detailsFixed");
    gtk_widget_show (detailsFixed);
    gtk_container_add (GTK_CONTAINER (detailsFrame), detailsFixed);

    variEntry = gtk_entry_new ();
    gtk_widget_set_name (variEntry, "variEntry");
    gtk_widget_show (variEntry);
    gtk_fixed_put (GTK_FIXED (detailsFixed), variEntry, 72, 112);
    gtk_widget_set_size_request (variEntry, 158, 24);
    gtk_tooltips_set_tip (tooltips, variEntry, "Variant name", NULL);

    instEntry = gtk_entry_new ();
    gtk_widget_set_name (instEntry, "instEntry");
    gtk_widget_show (instEntry);
    gtk_fixed_put (GTK_FIXED (detailsFixed), instEntry, 72, 16);
    gtk_widget_set_size_request (instEntry, 158, 24);
    gtk_tooltips_set_tip (tooltips, instEntry, "Instance Name", NULL);

    entityEntry = gtk_entry_new ();
    gtk_widget_set_name (entityEntry, "entityEntry");
    gtk_widget_show (entityEntry);
    gtk_fixed_put (GTK_FIXED (detailsFixed), entityEntry, 72, 48);
    gtk_widget_set_size_request (entityEntry, 158, 24);
    gtk_tooltips_set_tip (tooltips, entityEntry, "Instance Entity name", NULL);

    configEntry = gtk_entry_new ();
    gtk_widget_set_name (configEntry, "configEntry");
    gtk_widget_show (configEntry);
    gtk_fixed_put (GTK_FIXED (detailsFixed), configEntry, 72, 80);
    gtk_widget_set_size_request (configEntry, 158, 24);
    gtk_tooltips_set_tip (tooltips, configEntry, "Instance Configuration name", NULL);

    instLabel = gtk_label_new ("Instance:");
    gtk_widget_set_name (instLabel, "instLabel");
    gtk_widget_show (instLabel);
    gtk_fixed_put (GTK_FIXED (detailsFixed), instLabel, 8, 20);
    gtk_widget_set_size_request (instLabel, 64, 16);

    entityLabel = gtk_label_new ("Entity:");
    gtk_widget_set_name (entityLabel, "entityLabel");
    gtk_widget_show (entityLabel);
    gtk_fixed_put (GTK_FIXED (detailsFixed), entityLabel, 29, 52);
    gtk_widget_set_size_request (entityLabel, 38, 16);

    commentEntry = gtk_entry_new ();
    gtk_widget_set_name (commentEntry, "commentEntry");
    gtk_widget_show (commentEntry);
    gtk_fixed_put (GTK_FIXED (detailsFixed), commentEntry, 256, 56);
    gtk_widget_set_size_request (commentEntry, 256, 48);
    gtk_tooltips_set_tip (tooltips, commentEntry, "a comment", NULL);

    mdeParentEntry = gtk_entry_new ();
    gtk_widget_set_name (mdeParentEntry, "mdeParentEntry");
    gtk_widget_show (mdeParentEntry);
    gtk_fixed_put (GTK_FIXED (detailsFixed), mdeParentEntry, 352, 152);
    gtk_widget_set_size_request (mdeParentEntry, 158, 24);
    gtk_tooltips_set_tip (tooltips, mdeParentEntry, "mde Parent Instance Name", NULL);

    mdeInstEntry = gtk_entry_new ();
    gtk_widget_set_name (mdeInstEntry, "mdeInstEntry");
    gtk_widget_show (mdeInstEntry);
    gtk_fixed_put (GTK_FIXED (detailsFixed), mdeInstEntry, 352, 120);
    gtk_widget_set_size_request (mdeInstEntry, 158, 24);
    gtk_tooltips_set_tip (tooltips, mdeInstEntry, "mde Instance Name", NULL);

    commentLabel = gtk_label_new ("Comment:");
    gtk_widget_set_name (commentLabel, "commentLabel");
    gtk_widget_show (commentLabel);
    gtk_fixed_put (GTK_FIXED (detailsFixed), commentLabel, 256, 40);
    gtk_widget_set_size_request (commentLabel, 64, 16);

    mdeEntityEntry = gtk_entry_new ();
    gtk_widget_set_name (mdeEntityEntry, "mdeEntityEntry");
    gtk_widget_show (mdeEntityEntry);
    gtk_fixed_put (GTK_FIXED (detailsFixed), mdeEntityEntry, 352, 184);
    gtk_widget_set_size_request (mdeEntityEntry, 158, 24);
    gtk_tooltips_set_tip (tooltips, mdeEntityEntry, "mde Entity Name", NULL);

    configLabel = gtk_label_new ("Config:");
    gtk_widget_set_name (configLabel, "configLabel");
    gtk_widget_show (configLabel);
    gtk_fixed_put (GTK_FIXED (detailsFixed), configLabel, 22, 84);
    gtk_widget_set_size_request (configLabel, 48, 16);

    variLabel = gtk_label_new ("Variant:");
    gtk_widget_set_name (variLabel, "variLabel");
    gtk_widget_show (variLabel);
    gtk_fixed_put (GTK_FIXED (detailsFixed), variLabel, 14, 116);
    gtk_widget_set_size_request (variLabel, 60, 16);

    langCombo = gtk_combo_new ();
    g_object_set_data (G_OBJECT (GTK_COMBO (langCombo)->popwin), "GladeParentKey", langCombo);
    gtk_widget_set_name (langCombo, "langCombo");
    gtk_widget_show (langCombo);
    gtk_fixed_put (GTK_FIXED (detailsFixed), langCombo, 72, 176);
    gtk_widget_set_size_request (langCombo, 72, 24);
    gtk_combo_set_value_in_list (GTK_COMBO (langCombo), TRUE, FALSE);
    gtk_combo_set_case_sensitive (GTK_COMBO (langCombo), TRUE);
    langCombo_items = g_list_append (langCombo_items, (gpointer) "VHDL");
    langCombo_items = g_list_append (langCombo_items, (gpointer) "Verilog");
    gtk_combo_set_popdown_strings (GTK_COMBO (langCombo), langCombo_items);
    g_list_free (langCombo_items);

    langComboEntry = GTK_COMBO (langCombo)->entry;
    gtk_widget_set_name (langComboEntry, "langComboEntry");
    gtk_widget_show (langComboEntry);
    gtk_entry_set_text (GTK_ENTRY (langComboEntry), "VHDL");

    langLabel = gtk_label_new ("Language:");
    gtk_widget_set_name (langLabel, "langLabel");
    gtk_widget_show (langLabel);
    gtk_fixed_put (GTK_FIXED (detailsFixed), langLabel, 5, 184);
    gtk_widget_set_size_request (langLabel, 64, 16);

    mdeParentLabel = gtk_label_new ("mde Parent:");
    gtk_widget_set_name (mdeParentLabel, "mdeParentLabel");
    gtk_widget_show (mdeParentLabel);
    gtk_fixed_put (GTK_FIXED (detailsFixed), mdeParentLabel, 274, 156);
    gtk_widget_set_size_request (mdeParentLabel, 72, 16);

    genEntry = gtk_entry_new ();
    gtk_widget_set_name (genEntry, "genEntry");
    gtk_widget_show (genEntry);
    gtk_fixed_put (GTK_FIXED (detailsFixed), genEntry, 72, 144);
    gtk_widget_set_size_request (genEntry, 158, 24);
    gtk_tooltips_set_tip (tooltips, genEntry, "Generator statement", NULL);

    mdeInstLabel = gtk_label_new ("mde Instance:");
    gtk_widget_set_name (mdeInstLabel, "mdeInstLabel");
    gtk_widget_show (mdeInstLabel);
    gtk_fixed_put (GTK_FIXED (detailsFixed), mdeInstLabel, 262, 124);
    gtk_widget_set_size_request (mdeInstLabel, 86, 16);

    mdeEntityLabel = gtk_label_new ("mde Entity:");
    gtk_widget_set_name (mdeEntityLabel, "mdeEntityLabel");
    gtk_widget_show (mdeEntityLabel);
    gtk_fixed_put (GTK_FIXED (detailsFixed), mdeEntityLabel, 279, 187);
    gtk_widget_set_size_request (mdeEntityLabel, 68, 16);

    genLabel = gtk_label_new ("Generator:");
    gtk_widget_set_name (genLabel, "genLabel");
    gtk_widget_show (genLabel);
    gtk_fixed_put (GTK_FIXED (detailsFixed), genLabel, 6, 148);
    gtk_widget_set_size_request (genLabel, 60, 16);

    ignoreCheckbutton = gtk_check_button_new_with_mnemonic ("Ignore");
    gtk_widget_set_name (ignoreCheckbutton, "ignoreCheckbutton");
    gtk_widget_show (ignoreCheckbutton);
    gtk_fixed_put (GTK_FIXED (detailsFixed), ignoreCheckbutton, 408, 16);
    gtk_widget_set_size_request (ignoreCheckbutton, 68, 20);
    gtk_tooltips_set_tip (tooltips, ignoreCheckbutton, "Ignore this Instance", NULL);

    detailsLabel = gtk_label_new ("Details");
    gtk_widget_set_name (detailsLabel, "detailsLabel");
    gtk_widget_show (detailsLabel);
    gtk_frame_set_label_widget (GTK_FRAME (detailsFrame), detailsLabel);

    g_signal_connect ((gpointer) hierTreeview, "selection_received", G_CALLBACK (on_hierTreeview_selection_received), NULL);
    g_signal_connect ((gpointer) variEntry, "changed", G_CALLBACK (on_variEntry_changed), NULL);
    g_signal_connect ((gpointer) instEntry, "changed", G_CALLBACK (on_instEntry_changed), NULL);
    g_signal_connect ((gpointer) entityEntry, "changed", G_CALLBACK (on_entityEntry_changed), NULL);
    g_signal_connect ((gpointer) configEntry, "changed", G_CALLBACK (on_configEntry_changed), NULL);
    g_signal_connect ((gpointer) commentEntry, "changed", G_CALLBACK (on_commentEntry_changed), NULL);
    g_signal_connect ((gpointer) mdeParentEntry, "changed", G_CALLBACK (on_mdeParentEntry_changed), NULL);
    g_signal_connect ((gpointer) mdeInstEntry, "changed", G_CALLBACK (on_mdeInstEntry_changed), NULL);
    g_signal_connect ((gpointer) mdeEntityEntry, "changed", G_CALLBACK (on_mdeEntityEntry_changed), NULL);
    g_signal_connect ((gpointer) genEntry, "changed", G_CALLBACK (on_genEntry_changed), NULL);
    g_signal_connect ((gpointer) ignoreCheckbutton, "toggled", G_CALLBACK (on_ignoreCheckbutton_toggled), NULL);
    g_signal_connect ((gpointer) langComboEntry, "changed", G_CALLBACK (on_langComboEntry_changed), NULL);

    /* Store pointers to all widgets, for use by lookup_widget(). */
    GLADE_HOOKUP_OBJECT_NO_REF (detailsHbox, detailsHbox, "detailsHbox");
    GLADE_HOOKUP_OBJECT (detailsHbox, detailsHbox, "detailsHbox");
    GLADE_HOOKUP_OBJECT (detailsHbox, scrolledwindow1, "scrolledwindow1");
    GLADE_HOOKUP_OBJECT (detailsHbox, hierTreeview, "hierTreeview");
    GLADE_HOOKUP_OBJECT (detailsHbox, detailsFrame, "detailsFrame");
    GLADE_HOOKUP_OBJECT (detailsHbox, detailsFixed, "detailsFixed");
    GLADE_HOOKUP_OBJECT (detailsHbox, variEntry, "variEntry");
    GLADE_HOOKUP_OBJECT (detailsHbox, instEntry, "instEntry");
    GLADE_HOOKUP_OBJECT (detailsHbox, entityEntry, "entityEntry");
    GLADE_HOOKUP_OBJECT (detailsHbox, configEntry, "configEntry");
    GLADE_HOOKUP_OBJECT (detailsHbox, instLabel, "instLabel");
    GLADE_HOOKUP_OBJECT (detailsHbox, entityLabel, "entityLabel");
    GLADE_HOOKUP_OBJECT (detailsHbox, commentEntry, "commentEntry");
    GLADE_HOOKUP_OBJECT (detailsHbox, mdeParentEntry, "mdeParentEntry");
    GLADE_HOOKUP_OBJECT (detailsHbox, mdeInstEntry, "mdeInstEntry");
    GLADE_HOOKUP_OBJECT (detailsHbox, commentLabel, "commentLabel");
    GLADE_HOOKUP_OBJECT (detailsHbox, mdeEntityEntry, "mdeEntityEntry");
    GLADE_HOOKUP_OBJECT (detailsHbox, configLabel, "configLabel");
    GLADE_HOOKUP_OBJECT (detailsHbox, variLabel, "variLabel");
    GLADE_HOOKUP_OBJECT (detailsHbox, langCombo, "langCombo");
    GLADE_HOOKUP_OBJECT (detailsHbox, langComboEntry, "langComboEntry");
    GLADE_HOOKUP_OBJECT (detailsHbox, langLabel, "langLabel");
    GLADE_HOOKUP_OBJECT (detailsHbox, mdeParentLabel, "mdeParentLabel");
    GLADE_HOOKUP_OBJECT (detailsHbox, genEntry, "genEntry");
    GLADE_HOOKUP_OBJECT (detailsHbox, mdeInstLabel, "mdeInstLabel");
    GLADE_HOOKUP_OBJECT (detailsHbox, mdeEntityLabel, "mdeEntityLabel");
    GLADE_HOOKUP_OBJECT (detailsHbox, genLabel, "genLabel");
    GLADE_HOOKUP_OBJECT (detailsHbox, ignoreCheckbutton, "ignoreCheckbutton");
    GLADE_HOOKUP_OBJECT (detailsHbox, detailsLabel, "detailsLabel");
    GLADE_HOOKUP_OBJECT_NO_REF (detailsHbox, tooltips, "tooltips");

    return detailsHbox;
}


GtkWidget* init_hiertree()
{
    GtkTreeModel        *model;
    GtkCellRenderer     *renderer;
    GtkWidget           *view;

    view = gtk_tree_view_new();

    // --- Column #1 ---
    renderer = gtk_cell_renderer_text_new ();
    gtk_tree_view_insert_column_with_attributes(GTK_TREE_VIEW (view), -1, "Name", renderer, "text", HTREE_INST, NULL);

    store = gtk_tree_store_new(HTREE_NUM_COLS, G_TYPE_STRING, G_TYPE_UINT);
    model = GTK_TREE_MODEL(store);

    gtk_tree_view_set_model(GTK_TREE_VIEW (view), model);

    g_object_unref(model); // destroy model automatically with view

    // create_hiertree();
    gtk_tree_view_set_rules_hint(GTK_TREE_VIEW(view), TRUE);

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
	gtk_tree_store_set(store, &iter, HTREE_INST, name, -1);

	if(mix_hasChilds())
	{
	    // recursive function creates children
	    create_childs(&iter);
	}
	mix_getNextName(name);
    }
}


void create_childs(GtkTreeIter *parent)
{
    char name[INSTANCE_NAME_LENGTH];
    GtkTreeIter iter;

    mix_getNextName(name);

    while(strlen(name)>0)
    {
	// create a new node
	gtk_tree_store_append(store, &iter, parent);
	gtk_tree_store_set(store, &iter, HTREE_INST, name, -1);

	if(mix_hasChilds())    
	{   // create a tree node with children
	    create_childs(&iter);
	}
	mix_getNextName(name);
    }
}


GtkWidget* create_hier_view()
{
    int i = 0;
    GtkTreeViewColumn *col;
    GtkCellRenderer *renderer;
    GtkWidget * view;

    view = gtk_tree_view_new();
    // --- Column #x ---
    while(i < HIER_NUM_COLS) {

	col = gtk_tree_view_column_new();

	gtk_tree_view_column_set_spacing(col, 1);
	gtk_tree_view_column_set_title(col, header[i].title);

	// pack tree view column into tree view
	gtk_tree_view_append_column(GTK_TREE_VIEW(view), col);

	renderer = gtk_cell_renderer_text_new();
	g_object_set(renderer, "editable", header[i].editable, NULL);
	g_object_set_data(G_OBJECT(renderer), "column_index", GUINT_TO_POINTER(i));
	g_signal_connect(renderer, "edited", (GCallback) hier_edited_callback, NULL);

	// pack cell renderer into tree view column
	gtk_tree_view_column_pack_start(col, renderer, TRUE);

	// connect 'text' property of the cell renderer to
	// model column that contains the first name
	gtk_tree_view_column_add_attribute(col, renderer, header[i].type, i);
	i++;
    }
    hier_model = (GtkTreeModel*) create_hier_model();

    gtk_tree_view_set_model(GTK_TREE_VIEW(view), hier_model);
    g_object_unref(hier_model);

    gtk_tree_view_set_rules_hint(GTK_TREE_VIEW(view), TRUE);
    gtk_tree_view_set_headers_clickable(GTK_TREE_VIEW(view), TRUE);
    gtk_tree_selection_set_mode(gtk_tree_view_get_selection(GTK_TREE_VIEW(view)), GTK_SELECTION_MULTIPLE);

    return view;
}


GtkTreeModel* create_hier_model(void)
{
    int i = 0;
    int numOfRows = mix_number_of_hier_rows();
    char ign[1024], gen[1024], var[1024], par[1024], inst[1024], lang[1024], ent[1024], arc[1024];
    char conf[1024], use[1024], com[1024], des[1024], sname[1024], def[1024], hier[1024], deb[1024], skip[1024];
    char *row[] = { ign, gen, var, par, inst, lang, ent, arc, conf, use, com, des, sname, def, hier, deb, skip};
    GtkTreeStore *treestore;
    GtkTreeIter toplevel;

    treestore = gtk_tree_store_new(HIER_NUM_COLS, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING,
				   G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING,
				   G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING,
				   G_TYPE_STRING, G_TYPE_STRING, G_TYPE_STRING);

    while(i < numOfRows) {
	mix_get_hier_row(i, row);

	// Append a top level row and leave it empty
	gtk_tree_store_append(treestore, &toplevel, NULL);
	gtk_tree_store_set(treestore, &toplevel, HIER_IGN, ign, HIER_GEN, gen, HIER_VAR, var, HIER_PAR, par,
			   HIER_INST, inst, HIER_LANG, lang, HIER_ENT, ent, HIER_ARC, arc, HIER_CONF, conf,
			   HIER_USE, use, HIER_COM, com, HIER_DES, des, HIER_SNAME, sname, HIER_DEF, def,
			   HIER_HIER, hier, HIER_DEB, deb, HIER_SKIP, skip, -1);

	i++;
    }

    return GTK_TREE_MODEL(treestore);
}
