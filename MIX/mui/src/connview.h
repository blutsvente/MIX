/**
 *
 *  File:    iopadview.h
 *  Project: Mui - MIX Userinterface
 *  Author:  Alexander Bauer <Alexander.Bauer@Micronas.com>
 *
 */

#ifndef __IOPADVIEW_H_
#define __IOPADVIEW_H_

#include <gtk/gtk.h>


GtkWidget* create_conn_view();

void conn_col_index_to_name(char *name, int column);


#endif // __IOPADVIEW_H_
