/**
 *
 *  File:    settings.cpp
 *  Project: Mui - MIX Userinterface
 *  Author:  Alexander Bauer <Alexander.Bauer@Micronas.com>
 *
 */

#include <stdio.h>
#include <gtk/gtk.h>

#ifdef LINUX
#  include <linux/limits.h>
#else
#  define PATH_MAX 4096
#endif

#include "support.h"
#include "settings.h"


Settings settings;
GtkWidget *preferences = NULL;


int read_settings()
{
    // if user-config exist use it, else use global
    FILE *config_file;
    char buffer[PATH_MAX];
   
#ifndef G_OS_WIN32

    sprintf(buffer, "%s%s", getenv("HOME"), "/.muirc");

#else

    const char* home = getenv("HOMEDRIVE");
    if(home!=NULL)
	sprintf(buffer, "%s%s%s", homedrv, getenv("HOMEPATH"), "\mui.cfg");
    else if((home=getenv("USERPROFILE"))!=NULL)
	sprintf(buffer, "%s%s", home, "\mui.cfg");
    else
	buffer = "c:\mui.cfg";

#endif

    if((config_file = fopen(buffer, "r"))==NULL) {
	return -1;
    }

    // read config paths
    if(fscanf(config_file, "MIX_PATH=%s", buffer)>0) {
	settings.mix_path = (char*) malloc(strlen(buffer)+1);
	strcpy(settings.mix_path, buffer);
    }
    else
	settings.mix_path = NULL;

    if(fscanf(config_file, "EDITOR_PATH=%s", buffer)>0) {
	settings.editor_path = (char*) malloc(strlen(buffer)+1);
	strcpy(settings.editor_path, buffer);
    }
    else
	settings.editor_path = NULL;

    if(fscanf(config_file, "SHEETEDIT_PATH=%s", buffer)>0) {
	settings.sheetedit_path = (char*) malloc(strlen(buffer)+1);
	strcpy(settings.sheetedit_path, buffer);
    }
    else
	settings.sheetedit_path = NULL;

    fclose(config_file);

    return 0;
}


int write_settings()
{
    // write config parameters into users configuration file (~/.muirc)
    FILE *config_file;
    char config_path[PATH_MAX];

    // get users home directory
    // #ifndef G_OS_WIN32
    sprintf(config_path, "%s%s", getenv("HOME"), CONFIG_FILE_NAME);
    /* #else
       <get home dir from "HOMEDRIVE"+"HOMEPATH", "USERPROFILE" or simply "c:\">
       #endif
     */


    if((config_file = fopen(config_path, "w"))==NULL) {
	fprintf(stderr, "error: could not write configuration file!\n");
	return -1;
    }

    // write configuration paths
    if(settings.mix_path!=NULL)
	fprintf(config_file, "MIX_PATH=%s\n", settings.mix_path);
    if(settings.editor_path!=NULL)
	fprintf(config_file, "EDITOR_PATH=%s\n", settings.editor_path);
    if(settings.sheetedit_path!=NULL)
	fprintf(config_file, "SHEETEDIT_PATH=%s\n", settings.sheetedit_path);

    close(config_file);
    return 0;
}

char* get_mix_path()
{
    return settings.mix_path;
}

char* get_editor_path()
{
    return settings.editor_path;
}

char* get_sheetedit_path()
{
    return settings.sheetedit_path;
}

void show_preferences()
{
    GtkWidget *mix_path_entry, *editor_path_entry, *sheetedit_path_entry;

    // TODO: set window to top-level
    if(preferences != NULL) {
	gdk_window_raise(GTK_WIDGET(preferences)->window);
	return;
    }
    preferences = (GtkWidget*) create_Preferences();

    mix_path_entry = (GtkWidget*) lookup_widget(preferences, ("entry2"));
    editor_path_entry = (GtkWidget*) lookup_widget(preferences, ("entry6"));
    sheetedit_path_entry = (GtkWidget*) lookup_widget(preferences, ("entry7"));

    // display paths
    if(settings.mix_path != NULL)
	gtk_entry_set_text((GtkEntry*)mix_path_entry, settings.mix_path);
    else
	gtk_entry_set_text((GtkEntry*)mix_path_entry, "<none>");

    if(settings.editor_path != NULL)
	gtk_entry_set_text((GtkEntry*)editor_path_entry, settings.editor_path);
    else
	gtk_entry_set_text((GtkEntry*)editor_path_entry, "<none>");

    if(settings.sheetedit_path != NULL)
	gtk_entry_set_text((GtkEntry*)sheetedit_path_entry, settings.sheetedit_path);
    else
	gtk_entry_set_text((GtkEntry*)sheetedit_path_entry, "<none>");

    if(gtk_dialog_run(GTK_DIALOG(preferences)) == GTK_RESPONSE_OK) {

	char *buffer = (char*) gtk_entry_get_text((GtkEntry*)mix_path_entry);

	if(buffer != NULL) {
	    free(settings.mix_path);
	    settings.mix_path = (char*) malloc(strlen(buffer+1));
	    strcpy( settings.mix_path, buffer);
	}

	buffer = (char*) gtk_entry_get_text((GtkEntry*)editor_path_entry);
	if(buffer != NULL) {
	    free(settings.editor_path);
	    settings.editor_path = (char*) malloc(strlen(buffer+1));
	    strcpy( settings.editor_path, buffer);
	}

	buffer = (char*) gtk_entry_get_text((GtkEntry*)sheetedit_path_entry);
	if(buffer != NULL) {
	    free(settings.sheetedit_path);
	    settings.sheetedit_path = (char*) malloc(strlen(buffer+1));
	    strcpy( settings.sheetedit_path, buffer);
	}

	write_settings();
    }
    gtk_widget_destroy(preferences);
    preferences = NULL;
}

GtkWidget* get_preferences()
{
    return preferences;
}
