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
 * File: files.c - functions for file handling
 * Project: Mui - Mix Userinterface
 * Author: Alexander Bauer, ifw02024@cd.fhm.edu
 *
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include "files.h"


void open_file(char *filename) {

    // check if previous session is saved, if not ask user
    //Todo:    if(!check_save_file()) return;

    // Todo: add file History
    /* Move to the top of the history if already there. */
    /*    for(i=1; i<=files_history_size; ++i) {
        char *cur = files_history[i-1];

        if(!cur) break;
        if(!strcmp(name, cur)) {
	int j;*/

            /* Move the matching item to the top of the history list */
    /*            for(j=i; j>=2; --j)
                files_history[j-1] = files_history[j-2];
            files_history[0] = cur;
            update_files_history_menu();
            }
	}
    */
    
    if(filename[strlen(filename)-1] != '/') {
	//	gchar *text;
	//	gsize text_len;

	//	text = read_file(name, &text_len, &enc);
	//	if(text) {
	    //	    gtk_text_buffer_set_text(thebuffer, text, text_len);
	    //	    g_free(text);
	    //	    set_current_filename(name); 
	    /* block */ //{
		//		GtkTextIter start;
		//		gtk_text_buffer_get_start_iter(thebuffer, &start);
		//		gtk_text_buffer_place_cursor(thebuffer, &start);
		//		gtk_text_view_scroll_mark_onscreen(
						   //						   GTK_TEXT_VIEW(thetext),
						   //			   gtk_text_buffer_get_mark(GTK_TEXT_BUFFER(thebuffer), "insert"));
		//				   }
	    //	    gtk_text_buffer_set_modified(thebuffer, FALSE);
	    //	}
		return;
	    }
	    //    else {
	//	sprintf(name, "%s%s", name, &(const char)"mix.cfg");
	//   }
}
