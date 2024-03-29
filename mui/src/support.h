/**
 *
 *  File:    support.h
 *  Project: Mui - MIX Userinterface
 *  Author:  Alexander Bauer <Alexander.Bauer@Micronas.com>
 *
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <gtk/gtk.h>


#define HIERVIEW     0
#define CONNVIEW     1
#define IOPADVIEW    2
#define I2CVIEW      3


/**
 * Standard gettext macros.
 */
#ifdef ENABLE_NLS
#  include <libintl.h>
#  undef _
#  define _(String) dgettext (PACKAGE, String)
#  ifdef gettext_noop
#    define N_(String) gettext_noop (String)
#  else
#    define N_(String) (String)
#  endif
#else
#  define textdomain(String) (String)
#  define gettext(String) (String)
#  define dgettext(Domain,Message) (Message)
#  define dcgettext(Domain,Message,Type) (Message)
#  define bindtextdomain(Domain,Directory) (Domain)
//#  define _(String) (String)
#  define N_(String) (String)
#endif


#define GLADE_HOOKUP_OBJECT(component,widget,name) \
  g_object_set_data_full (G_OBJECT (component), name, \
    gtk_widget_ref (widget), (GDestroyNotify) gtk_widget_unref)

#define GLADE_HOOKUP_OBJECT_NO_REF(component,widget,name) \
  g_object_set_data (G_OBJECT (component), name, widget)


void new_project();

void open_project(const char *filename);

/**
 * get index number of current page selected
 */
int get_current_page();
/**
 * set index number of current page 
 */
void set_current_page(int index);
/**
 * create the intial view
 */
void create_first_view(int index);

void destroy_all_views();

/**
 * This function returns a widget in a component created by Glade.
 * Call it with the toplevel widget in the component (i.e. a window/dialog),
 * or alternatively any widget in the component, and the name of the widget
 * you want returned.
 */
GtkWidget* lookup_widget(GtkWidget *widget, const gchar *widget_name);


/**
 * Use this function to set the directory containing installed pixmaps
 */
void add_pixmap_directory(const gchar *directory);


/**
* This is used to create the pixmaps used in the interface
*/
GtkWidget* create_pixmap(GtkWidget *widget, const gchar *filename);

/**
 * This is used to create the pixbufs used in the interface
 */
GdkPixbuf* create_pixbuf(const gchar *filename);

/** 
 * This is used to set ATK action descriptions
 */
void glade_set_atk_action_description(AtkAction *action, const gchar *action_name, const gchar *description);

