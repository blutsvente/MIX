/**
 *
 *  File:    main.cpp
 *  Project: Mui - MIX Userinterface
 *  Author:  Alexander Bauer <Alexander.Bauer@Micronas.com>
 *
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <stdio.h>

#include "mainwindow.h"
#include "settings.h"


int main(int argc, char *argv[])
{
    GtkWidget *mainWindow;

#ifdef ENABLE_NLS
    bindtextdomain(GETTEXT_PACKAGE, PACKAGE_LOCALE_DIR);
    bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
    textdomain(GETTEXT_PACKAGE);
#endif

    gtk_set_locale();
    gtk_init(&argc, &argv);

    // create and show main window
    mainWindow = (GtkWidget*) create_MainWindow();
    init_settings(mainWindow);
    gtk_widget_show(mainWindow);

    // read config file
    if(read_settings()!=0)
	    show_preferences();

    //    while(!get_mix_path())
	//    	if(!show_preferences()) return 0;

    // initialize MIX
    mix_init(get_mix_path());

    gtk_main();
    return 0;
}
