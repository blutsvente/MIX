/**
 *
 *  File:    settings.cpp
 *  Project: Mui - MIX Userinterface
 *  Author:  Alexander Bauer <Alexander.Bauer@Micronas.com>
 *
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <stdio.h>
#include <gtk/gtk.h>

#ifdef LINUX
#  include <linux/limits.h>
#else
#  define PATH_MAX 4096
#endif

#include "support.h"
#include "settings.h"


Settings settings = {NULL, NULL};

extern GtkWidget *mainWindow;


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
    if(fscanf(config_file, "MIX_PATH=%s\n", buffer)==1) {
	settings.mix_path = (char*) malloc(strlen(buffer)+1);
	if(!strcmp(buffer, "<none>"))
	    settings.mix_path = NULL;
	else
	    strcpy(settings.mix_path, buffer);
    }
    else
	settings.mix_path = NULL;

    if(fscanf(config_file, "EDITOR_PATH=%s", buffer)==1) {
	settings.editor_path = (char*) malloc(strlen(buffer)+1);
	if(!strcmp(buffer, "<none>"))
	    settings.editor_path = NULL;
	else
	    strcpy(settings.editor_path, buffer);
    }
    else
	settings.editor_path = NULL;

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
    if(settings.mix_path != NULL && strlen(settings.mix_path) > 0)
	fprintf(config_file, "MIX_PATH=%s\n", settings.mix_path);
    else
	fprintf(config_file, "MIX_PATH=<none>\n");

    if(settings.editor_path != NULL && strlen(settings.editor_path) > 0)
	fprintf(config_file, "EDITOR_PATH=%s\n", settings.editor_path);
    else
	fprintf(config_file, "EDITOR_PATH=<none>\n");

    fclose(config_file);
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

int show_preferences()
{
    int ret = 0;
    GtkWidget *preferences, *mix_path_entry, *editor_path_entry;

    preferences = (GtkWidget*) create_Preferences();

    mix_path_entry = (GtkWidget*) lookup_widget(preferences, ("entry2"));
    editor_path_entry = (GtkWidget*) lookup_widget(preferences, ("entry6"));

    // display paths
    if(settings.mix_path != NULL)
	gtk_entry_set_text((GtkEntry*)mix_path_entry, settings.mix_path);
    else
	gtk_entry_set_text((GtkEntry*)mix_path_entry, "<none>");

    if(settings.editor_path != NULL)
	gtk_entry_set_text((GtkEntry*)editor_path_entry, settings.editor_path);
    else
	gtk_entry_set_text((GtkEntry*)editor_path_entry, "<none>");

    gtk_window_set_transient_for((GtkWindow*)preferences,(GtkWindow*) mainWindow);

    if(gtk_dialog_run(GTK_DIALOG(preferences)) == GTK_RESPONSE_OK) {

	char *buffer = (char*) gtk_entry_get_text((GtkEntry*)mix_path_entry);
	int size;
	if(settings.mix_path != NULL) free(settings.mix_path);
	if(buffer != NULL && strcmp(buffer, "<none>") != 0 && strlen(buffer) > 0) {
	    size = strlen(buffer);
	    while(buffer[size-1] == DIRECTORY_DELIMIT) {
		buffer[size-1] = 0;
		size--;
	    }
	    settings.mix_path = (char*) malloc(size + 1);
	    strcpy( settings.mix_path, buffer);
	}
	else
	    settings.mix_path = NULL;

	buffer = (char*) gtk_entry_get_text((GtkEntry*)editor_path_entry);
	if(settings.editor_path != NULL) free(settings.editor_path);
	if(buffer != NULL && strcmp(buffer, "<none>") != 0 && strlen(buffer) > 0) {
	    settings.editor_path = (char*) malloc(strlen(buffer)+1);
	    strcpy( settings.editor_path, buffer);
	}
	else
	    settings.editor_path = NULL;

	write_settings();
	ret = 1;
    }
    else
	ret = 0;
    gtk_widget_destroy(preferences);
    return ret;
}

