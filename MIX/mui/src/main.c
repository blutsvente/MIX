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
#include "support.h"
#include "settings.h"


GtkWidget *mainWindow = NULL;


int main(int argc, char *argv[])
{

#ifdef ENABLE_NLS
    bindtextdomain(GETTEXT_PACKAGE, PACKAGE_LOCALE_DIR);
    bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
    textdomain(GETTEXT_PACKAGE);
#endif

    gtk_set_locale();
    gtk_init(&argc, &argv);

    // create and show main window
    mainWindow = (GtkWidget*) create_MainWindow();
    gtk_widget_show(mainWindow);

    // read config file
    if(read_settings()!=0)
	    show_preferences();

    while(!get_mix_path())
	if(!show_preferences()) return 0;

    // initialize MIX
    while(mix_init(get_mix_path()))
	if(!show_preferences()) return 0;

    // open cmd arg passed sheet
    if(argc > 1) {
	open_project((const char*) argv[1]);
    }

    gtk_main();
    return 0;
}
