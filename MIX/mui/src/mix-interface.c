/* Copyright (C) 1991,92,95,96,97,98,99,2000,01 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

/**
 *
 * File: mix-interface.c - hold settings and run Mix
 * Project: Mui - Mix Userinterface
 * Author: Alexander Bauer, ifw02024@cd.fhm.edu
 *
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <stdio.h>
#include <errno.h>

#include <gtk/gtk.h>

#include "user-interface.h"
#include "mix-interface.h"


int load_config() {
    
    // if user-config exist use it, else use global
    FILE *config_file;
    char buffer[MAX_PATH_LENGTH];
   
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
        fprintf(stderr, "error: reading config file!\n");
	strcat(mix_path, "<none>");
	strcat(editor_path, "<none>");
	strcat(sheetedit_path, "<none>");
	save_config();
	return -1;
    }

    mix_path[0] = 0;
    editor_path[0] = 0;
    sheetedit_path[0] = 0;

    // read config paths
    fscanf(config_file, "MIX_PATH=%s EDITOR_PATH=%s SHEETEDIT_PATH=%s", mix_path, editor_path, sheetedit_path);

    fclose(config_file);

    return 0;
}

int save_config() {

    // write config parameters into users configuration file (~/.muirc)
    FILE *config_file;
    char config_path[MAX_PATH_LENGTH];
    int mix_path_length;

    // get users home directory
#ifndef G_OS_WIN32
    sprintf(config_path, "%s%s", getenv("HOME"), CONFIG_FILE_NAME);
// #else
    //   <get home dir from "HOMEDRIVE"+"HOMEPATH", "USERPROFILE" or simply "c:\">
#endif


    if((config_file = fopen(config_path, "w"))==NULL) {
	fprintf(stderr, "error: could not write configuration file!\n");
	return -1;
    }


    mix_path_length = strlen(mix_path);
    if(mix_path[mix_path_length-1]==DIRECTORY_DELIMIT) {
	mix_path[mix_path_length-1] = 0;
    }

    // write configuration paths
    fprintf(config_file, "MIX_PATH=%s\n", mix_path);
    fprintf(config_file, "EDITOR_PATH=%s\n", editor_path);
    fprintf(config_file, "SHEETEDIT_PATH=%s\n", sheetedit_path);

    fclose(config_file);
    return 0;
}

void new_session() {

    options.import = 0;
    options.combine = 0;
    options.strip = 0;
    options.bak = 0;    
    options.dump = 0;
    options.verbose = 0;
    options.delta = 0;
    options.dbglevel = 0;

    options.variant = "default";

    options.input = "";
    options.import_list = "";
    options.targetDir = "";
    options.leafcellDir = "";

    modified = 0;
}


FILE* run_mix() {

    FILE *log;
    char command[MAX_PATH_LENGTH];
    GtkWidget *list_input_entry, *list_import_entry, *variant_entry;

    list_input_entry = (GtkWidget*)lookup_widget(mui, ("list_input_entry"));
    list_import_entry = (GtkWidget*)lookup_widget(mui, ("list_import_entry"));
    variant_entry = (GtkWidget*)lookup_widget(mui, ("combo_entry1"));

    options.input = gtk_entry_get_text((GtkEntry*)list_input_entry);

    if(options.input==NULL || strlen(options.input)<=0) {
	// Todo: create dialog "no input selected"
	fprintf(stderr, "no input selected!\n");
	return NULL;
    }

    options.import_list = gtk_entry_get_text((GtkEntry*)list_import_entry);
    options.variant = gtk_entry_get_text((GtkEntry*)variant_entry);

    // turn off MIX banner
    sprintf(command, "%s%s%s -nobanner", mix_path, DIRECTORY_DELIMIT, MIX_NAME);

    // set file to use for import
    if(options.import && strlen(options.import_list)>0) {
	strcat(command, " -import ");
	strcat(command, options.import_list);
    }
    // combine entity and architecture into a single file
    if(options.combine) {
	strcat(command, " -combine");
    }
    // strip old intermediate sheets
    if(options.strip) {
	strcat(command, " -strip");
    }
    // generate backup of old files
    if(options.bak) {
	strcat(command, " -bak");
    }
    // dump internal data to file
    if(options.dump) {
	strcat(command, " -adump");
    }
    // give verbose output information
    if(options.verbose) {
	strcat(command, " -verbose");
    }
    // use delta mode or not
    if(!options.delta) {
	strcat(command, " -nodelta");
    }
    // append target path to command
    if(strlen(options.targetDir)>0) {
	strcat(command, " -dir ");
	strcat(command, options.targetDir);
    }
    // append leafcell path to command
    if(strlen(options.leafcellDir)>0) {
	strcat(command, " -lc ");
	strcat(command, options.leafcellDir);
    }

    // Todo: debug level

    // check which variant to build
    // Todo: read standart value(here called "default") from mix.cfg file
    if(strlen(options.variant)>0 && strcmp(options.variant, "default")!=0) {
	strcat(command, " -variant ");
	strcat(command, options.variant);
    }

    // append spreadsheet(s)       
    sprintf(command, "%s %s", command, options.input);

    printf("running command: %s\n", command);

    // run program and fetch the output stream
    log = popen(command, "r");

    return log;
}


void dialog_output(FILE *output) {

    char buffer[BUFFER_LENGTH];
    GtkTextBuffer *gtkbuffer;

    gtkbuffer = create_mixlog();

    if(output==NULL) {
    	gtk_text_buffer_insert_at_cursor(gtkbuffer, "Error: running Mix!", -1);       
	return;
    }

    // read until end of stream
    while(!feof(output)) {
	if(fgets(buffer, BUFFER_LENGTH, output)==NULL) break;
	gtk_text_buffer_insert_at_cursor(gtkbuffer, (gchar*)buffer, -1);
    }
    gtk_text_buffer_insert_at_cursor(gtkbuffer, "################# End of Logging #################", -1);
}
