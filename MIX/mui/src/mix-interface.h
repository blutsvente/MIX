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

#ifndef _MIX_INTERFACE_H
#define _MIX_INTERFACE_H 1

#include <stdio.h>

#define BUFFER_LENGTH 256
#define MAX_PATH_LENGTH 1024

#define MIX_NAME "mix_0.pl"

//#ifdef LINUX
#define CONFIG_FILE_NAME "/.muirc"
#define DIRECTORY_DELIMIT '/'
//endif
//#ifdef WIN32
// #define DIRECTORY_DELIMIT '\'
//#endif


/**
 * structure holding settings
 */
struct {
    unsigned int import, combine, strip, bak, dump, verbose, delta, dbglevel;
    const char *input, *import_list, *variant, *targetDir, *leafcellDir;
} options;

unsigned int modified;

// Mix-path, Editor and Spreadsheet-Editor path's
char mix_path[MAX_PATH_LENGTH], editor_path[MAX_PATH_LENGTH], sheetedit_path[MAX_PATH_LENGTH];


/**
 * read config paths and other settings from file
 * @return: 0 on success
 */
int load_config();
/**
 * save config paths and other settings to file
 * @return: 0 on success
 */
int save_config();

void new_session();

/**
 * run Mix using parameters
 * @return: 0 on success
 */
FILE* run_mix();

void dialog_output(FILE *output);

#endif
