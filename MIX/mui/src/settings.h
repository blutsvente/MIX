/**
 *
 *  File:    settings.h
 *  Project: Mui - MIX Userinterface
 *  Author:  Alexander Bauer <Alexander.Bauer@Micronas.com>
 *
 */

#ifndef __SETTINGS_H_
#define __SETTINGS_H_


//#ifdef LINUX
#define CONFIG_FILE_NAME "/.muirc"
#define DIRECTORY_DELIMIT '/'
//endif
//#ifdef WIN32
// #define DIRECTORY_DELIMIT '\\'
//#endif


/**
 * initialize settings
 */
int init_settings(GtkWidget *window);

GtkWidget* get_mainwindow();

/**
 * read settings from file
 */
int read_settings();
/**
 * write settings into file
 */
int write_settings();

char *get_mix_path();
char *get_editor_path();

int show_preferences();

/**
 * MIX settings
 */
typedef struct Settings_TAG {

    char *mix_path;
    char *editor_path;

} Settings;


#endif // __SETTINGS_H_
