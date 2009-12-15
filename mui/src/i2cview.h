/**
 *
 *  File:    i2cview.h
 *  Project: Mui - MIX Userinterface
 *  Author:  Alexander Bauer <Alexander.Bauer@Micronas.com>
 *
 */

#ifndef __I2CVIEW_H_
#define __I2CVIEW_H_

#include <gtk/gtk.h>


GtkWidget* create_i2c_view();

void i2c_col_index_to_name(char *name, int column);


#endif // __I2CVIEW_H_
