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
 * File: user-interface.c - functions for building GUI elements
 * Project: Mui - Mix Userinterface
 * Author: Alexander Bauer, ifw02024@cd.fhm.edu
 *
 */


GtkWidget *mui, *file_dlg;

GtkWidget* create_mui (void);
GtkWidget* create_fileselection (void);
GtkWidget* create_preferences (void);
GtkTextBuffer* create_mixlog (void);

gint create_dialog(const char *title);

const char* create_open_dialog(const char *title);
void create_save_as_dialog();

void create_input_dialog();
void create_select_dialog();

const char* create_target_dialog();

