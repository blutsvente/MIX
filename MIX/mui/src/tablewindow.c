/**
 *
 *  File:    tablewindow.c
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

#include <gdk/gdkkeysyms.h>

#include "tablewindow.h"
#include "support.h"


GtkWidget* create_tableWindow(void)
{
    GtkWidget *tableWindow;
    GtkWidget *tableNotebook;
    GtkWidget *HierScrolledwindow;
    GtkWidget *HierTreeview;
    GtkWidget *hierLabel;
    GtkWidget *ConnScrolledwindow;
    GtkWidget *ConnTreeview;
    GtkWidget *connLabel;
    GtkWidget *IOScrolledwindow;
    GtkWidget *IOTreeview;
    GtkWidget *ioLabel;
    GtkWidget *I2CScrolledwindow;
    GtkWidget *I2CTreeview;
    GtkWidget *I2CLabel;
    GtkWidget *ConfScrolledwindow;
    GtkWidget *ConfTreeview;
    GtkWidget *confLabel;

    tableWindow = gtk_window_new (GTK_WINDOW_TOPLEVEL);
    gtk_widget_set_name (tableWindow, "tableWindow");
    gtk_window_set_title (GTK_WINDOW (tableWindow), _("Spreadsheet"));

    tableNotebook = gtk_notebook_new ();
    gtk_widget_set_name (tableNotebook, "tableNotebook");
    gtk_widget_show (tableNotebook);
    gtk_container_add (GTK_CONTAINER (tableWindow), tableNotebook);

    HierScrolledwindow = gtk_scrolled_window_new (NULL, NULL);
    gtk_widget_set_name (HierScrolledwindow, "HierScrolledwindow");
    gtk_widget_show (HierScrolledwindow);
    gtk_container_add (GTK_CONTAINER (tableNotebook), HierScrolledwindow);
    gtk_scrolled_window_set_policy (GTK_SCROLLED_WINDOW (HierScrolledwindow), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC);

    HierTreeview = gtk_tree_view_new ();
    gtk_widget_set_name (HierTreeview, "HierTreeview");
    gtk_widget_show (HierTreeview);
    gtk_container_add (GTK_CONTAINER (HierScrolledwindow), HierTreeview);
    gtk_tree_view_set_enable_search (GTK_TREE_VIEW (HierTreeview), FALSE);

    hierLabel = gtk_label_new (_("Hier"));
    gtk_widget_set_name (hierLabel, "hierLabel");
    gtk_widget_show (hierLabel);
    gtk_notebook_set_tab_label (GTK_NOTEBOOK (tableNotebook), gtk_notebook_get_nth_page (GTK_NOTEBOOK (tableNotebook), 0), hierLabel);

    ConnScrolledwindow = gtk_scrolled_window_new (NULL, NULL);
    gtk_widget_set_name (ConnScrolledwindow, "ConnScrolledwindow");
    gtk_widget_show (ConnScrolledwindow);
    gtk_container_add (GTK_CONTAINER (tableNotebook), ConnScrolledwindow);
    gtk_scrolled_window_set_policy (GTK_SCROLLED_WINDOW (ConnScrolledwindow), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC);

    ConnTreeview = gtk_tree_view_new ();
    gtk_widget_set_name (ConnTreeview, "ConnTreeview");
    gtk_widget_show (ConnTreeview);
    gtk_container_add (GTK_CONTAINER (ConnScrolledwindow), ConnTreeview);

    connLabel = gtk_label_new (_("Conn"));
    gtk_widget_set_name (connLabel, "connLabel");
    gtk_widget_show (connLabel);
    gtk_notebook_set_tab_label (GTK_NOTEBOOK (tableNotebook), gtk_notebook_get_nth_page (GTK_NOTEBOOK (tableNotebook), 1), connLabel);

    IOScrolledwindow = gtk_scrolled_window_new (NULL, NULL);
    gtk_widget_set_name (IOScrolledwindow, "IOScrolledwindow");
    gtk_widget_show (IOScrolledwindow);
    gtk_container_add (GTK_CONTAINER (tableNotebook), IOScrolledwindow);
    gtk_scrolled_window_set_policy (GTK_SCROLLED_WINDOW (IOScrolledwindow), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC);

    IOTreeview = gtk_tree_view_new ();
    gtk_widget_set_name (IOTreeview, "IOTreeview");
    gtk_widget_show (IOTreeview);
    gtk_container_add (GTK_CONTAINER (IOScrolledwindow), IOTreeview);

    ioLabel = gtk_label_new (_("IO"));
    gtk_widget_set_name (ioLabel, "ioLabel");
    gtk_widget_show (ioLabel);
    gtk_notebook_set_tab_label (GTK_NOTEBOOK (tableNotebook), gtk_notebook_get_nth_page (GTK_NOTEBOOK (tableNotebook), 2), ioLabel);

    I2CScrolledwindow = gtk_scrolled_window_new (NULL, NULL);
    gtk_widget_set_name (I2CScrolledwindow, "I2CScrolledwindow");
    gtk_widget_show (I2CScrolledwindow);
    gtk_container_add (GTK_CONTAINER (tableNotebook), I2CScrolledwindow);
    gtk_scrolled_window_set_policy (GTK_SCROLLED_WINDOW (I2CScrolledwindow), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC);

    I2CTreeview = gtk_tree_view_new ();
    gtk_widget_set_name (I2CTreeview, "I2CTreeview");
    gtk_widget_show (I2CTreeview);
    gtk_container_add (GTK_CONTAINER (I2CScrolledwindow), I2CTreeview);

    I2CLabel = gtk_label_new (_("I2C"));
    gtk_widget_set_name (I2CLabel, "I2CLabel");
    gtk_widget_show (I2CLabel);
    gtk_notebook_set_tab_label (GTK_NOTEBOOK (tableNotebook), gtk_notebook_get_nth_page (GTK_NOTEBOOK (tableNotebook), 3), I2CLabel);

    ConfScrolledwindow = gtk_scrolled_window_new (NULL, NULL);
    gtk_widget_set_name (ConfScrolledwindow, "ConfScrolledwindow");
    gtk_widget_show (ConfScrolledwindow);
    gtk_container_add (GTK_CONTAINER (tableNotebook), ConfScrolledwindow);
    gtk_scrolled_window_set_policy (GTK_SCROLLED_WINDOW (ConfScrolledwindow), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC);

    ConfTreeview = gtk_tree_view_new ();
    gtk_widget_set_name (ConfTreeview, "ConfTreeview");
    gtk_widget_show (ConfTreeview);
    gtk_container_add (GTK_CONTAINER (ConfScrolledwindow), ConfTreeview);

    confLabel = gtk_label_new (_("Conf"));
    gtk_widget_set_name (confLabel, "confLabel");
    gtk_widget_show (confLabel);
    gtk_notebook_set_tab_label (GTK_NOTEBOOK (tableNotebook), gtk_notebook_get_nth_page (GTK_NOTEBOOK (tableNotebook), 4), confLabel);

    // Store pointers to all widgets, for use by lookup_widget()
    GLADE_HOOKUP_OBJECT_NO_REF (tableWindow, tableWindow, "tableWindow");
    GLADE_HOOKUP_OBJECT (tableWindow, tableNotebook, "tableNotebook");
    GLADE_HOOKUP_OBJECT (tableWindow, HierScrolledwindow, "HierScrolledwindow");
    GLADE_HOOKUP_OBJECT (tableWindow, HierTreeview, "HierTreeview");
    GLADE_HOOKUP_OBJECT (tableWindow, hierLabel, "hierLabel");
    GLADE_HOOKUP_OBJECT (tableWindow, ConnScrolledwindow, "ConnScrolledwindow");
    GLADE_HOOKUP_OBJECT (tableWindow, ConnTreeview, "ConnTreeview");
    GLADE_HOOKUP_OBJECT (tableWindow, connLabel, "connLabel");
    GLADE_HOOKUP_OBJECT (tableWindow, IOScrolledwindow, "IOScrolledwindow");
    GLADE_HOOKUP_OBJECT (tableWindow, IOTreeview, "IOTreeview");
    GLADE_HOOKUP_OBJECT (tableWindow, ioLabel, "ioLabel");
    GLADE_HOOKUP_OBJECT (tableWindow, I2CScrolledwindow, "I2CScrolledwindow");
    GLADE_HOOKUP_OBJECT (tableWindow, I2CTreeview, "I2CTreeview");
    GLADE_HOOKUP_OBJECT (tableWindow, I2CLabel, "I2CLabel");
    GLADE_HOOKUP_OBJECT (tableWindow, ConfScrolledwindow, "ConfScrolledwindow");
    GLADE_HOOKUP_OBJECT (tableWindow, ConfTreeview, "ConfTreeview");
    GLADE_HOOKUP_OBJECT (tableWindow, confLabel, "confLabel");

    return tableWindow;
}

