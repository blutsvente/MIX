/**
 *
 *  File:    mainwindow.h
 *  Project: Mui - MIX Userinterface
 *  Author:  Alexander Bauer <Alexander.Bauer@Micronas.com>
 *
 */

#ifndef __MAINWINDOW_H_
#define __MAINWINDOW_H_

#include <gtk/gtk.h>


GtkWidget* create_MainWindow(void);
GtkWidget* create_Preferences(void);
GtkWidget* create_MixMonitor(void);

gint create_dialog(const char *title);
const char* create_file_dialog(const char* title);
const char* create_directory_dialog(void);

void create_about_dialog(void);


#endif
