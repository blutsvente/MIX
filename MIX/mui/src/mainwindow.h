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


/**
 * create main window
 */
GtkWidget* create_MainWindow(void);
/**
 * get reference og hierTreeview widget
 */
GtkWidget* get_hierTreeview();
/**
 * get reference og connMatrixview widget
 */
GtkWidget* get_connMatrixview();
/**
 * get reference og iopadTableview widget
 */
GtkWidget* get_iopadTableview();
/**
 * get reference og i2cTableview widget
 */
GtkWidget* get_i2cTableview();

/**
 * create preference window and return reference
 */
GtkWidget* create_Preferences(void);
/**
 * create logging window and return reference
 */
GtkWidget* create_MixMonitor(void);

/**
 * create file/dir selection dialog box
 */
gint create_dialog(const char *title);
const char* create_file_dialog(const char* title);
const char* create_directory_dialog(void);

/**
 * create about dialog box
 */
void create_about_dialog(void);

/**
 * create info dialog box
 */
void create_info_dialog(char *title, char *message);


#endif
