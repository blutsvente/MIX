/**
 *
 *  File:    support.c
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

#include <gtk/gtk.h>

#include "mix.h"
#include "support.h"


int current_page = 0;


void new_project()
{
    // run MIX using empty template
}

void open_project(const char *filename)
{
    GtkWidget *view;

    if(filename != NULL) {
	if(mix_readSpreadsheet(filename) != SUCCESS) {
	    create_info_dialog("Error", "\n  Could not read Spreadsheeet  \n");
	}
	else {
	    destroy_all_views();

	    // create new views
	    view = (GtkWidget*) create_hier_view();
	    gtk_widget_show_all(view);
	    gtk_container_add(GTK_CONTAINER(get_view_frame(0)), view);
	    set_view_child(view, 0);

	    view = (GtkWidget*) create_conn_view();
	    gtk_widget_show_all(view);
	    gtk_container_add(GTK_CONTAINER(get_view_frame(1)), view);
	    set_view_child(view, 1);

	    view = (GtkWidget*) create_iopad_view();
	    gtk_widget_show_all(view);
	    gtk_container_add(GTK_CONTAINER(get_view_frame(2)), view);
	    set_view_child(view, 2);

	    //	    view = (GtkWidget*) create_i2c_view();
	    //	    gtk_widget_show_all(view);
	    //	    gtk_container_add(GTK_CONTAINER(get_view_frame(3)), view);
	    //	    set_view_child(view, 3);
	}
    }
}

int get_current_page()
{
    return current_page;
}

void set_current_page(int index)
{
    current_page = index;
}

void create_first_view(int index)
{
    GtkWidget *view;
    switch(index) {
	case HIERVIEW:
	    view = (GtkWidget*) create_hier_view();
	    break;
        case CONNVIEW: 
	    view = (GtkWidget*) create_conn_view();
	    break;
        case IOPADVIEW:
	    view = (GtkWidget*) create_iopad_view();
	    break;
        case I2CVIEW:
	    view = (GtkWidget*) create_i2c_view();
	    break;
        default:
	    return;
    }
    gtk_widget_show_all(view);
    gtk_container_add(GTK_CONTAINER(get_view_frame(index)), view);
    set_view_child(view, index);
}

void destroy_all_views()
{
    GtkWidget *view = (GtkWidget*) get_view_child(0);
    if(view != NULL)
	gtk_widget_destroy(view);

    view = (GtkWidget*) get_view_child(1);
    if(view != NULL)
	gtk_widget_destroy(view);

    view = (GtkWidget*) get_view_child(2);
    if(view != NULL)
	gtk_widget_destroy(view);

    view = (GtkWidget*) get_view_child(3);
    if(view != NULL)
	gtk_widget_destroy(view);
}

GtkWidget* lookup_widget(GtkWidget *widget, const gchar *widget_name)
{
    GtkWidget *parent, *found_widget;

    for(;;) {
	if(GTK_IS_MENU (widget))
	    parent = gtk_menu_get_attach_widget(GTK_MENU (widget));
	else
	    parent = widget->parent;
	if(!parent)
	    parent = (GtkWidget*) g_object_get_data(G_OBJECT (widget), "GladeParentKey");
	if(parent == NULL)
	    break;
	widget = parent;
    }

    found_widget = (GtkWidget*) g_object_get_data(G_OBJECT (widget), widget_name);
    if(!found_widget)
	g_warning ("Widget not found: %s", widget_name);
    return found_widget;
}

static GList *pixmaps_directories = NULL;

void add_pixmap_directory(const gchar *directory)
{
    pixmaps_directories = g_list_prepend (pixmaps_directories, g_strdup (directory));
}

static gchar* find_pixmap_file(const gchar *filename)
{
    GList *elem;

    // We step through each of the pixmaps directory to find it
    elem = pixmaps_directories;
    while(elem) {
	gchar *pathname = g_strdup_printf("%s%s%s", (gchar*)elem->data, G_DIR_SEPARATOR_S, filename);
	if(g_file_test (pathname, G_FILE_TEST_EXISTS))
        return pathname;
	g_free (pathname);
	elem = elem->next;
    }
    return NULL;
}

GtkWidget* create_pixmap(GtkWidget *widget, const gchar *filename)
{
    gchar *pathname = NULL;
    GtkWidget *pixmap;

    if(!filename || !filename[0])
	return gtk_image_new();

    pathname = find_pixmap_file(filename);

    if(!pathname) {
	g_warning("Couldn't find pixmap file: %s", filename);
	return gtk_image_new();
    }

    pixmap = gtk_image_new_from_file(pathname);
    g_free(pathname);
    return pixmap;
}

GdkPixbuf* create_pixbuf(const gchar *filename)
{
    gchar *pathname = NULL;
    GdkPixbuf *pixbuf;
    GError *error = NULL;

    if(!filename || !filename[0])
	return NULL;

    pathname = find_pixmap_file(filename);

    if(!pathname) {
	g_warning("Couldn't find pixmap file: %s", filename);
	return NULL;
    }

    pixbuf = gdk_pixbuf_new_from_file(pathname, &error);
    if(!pixbuf) {
	fprintf(stderr, "Failed to load pixbuf file: %s: %s\n", pathname, error->message);
	g_error_free (error);
    }
    g_free (pathname);
    return pixbuf;
}

void glade_set_atk_action_description(AtkAction *action, const gchar *action_name, const gchar *description)
{
    gint n_actions, i;

    n_actions = atk_action_get_n_actions(action);
    for(i = 0; i < n_actions; i++) {
	if(!strcmp(atk_action_get_name(action, i), action_name))
	    atk_action_set_description(action, i, description);
    }
}

