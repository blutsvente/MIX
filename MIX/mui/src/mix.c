/**
 *
 *  File:    mix.cpp - MIX Interface Class
 *  Project: Mui - MIX Userinterface
 *  Author:  Alexander Bauer <Alexander.Bauer@Micronas.com>
 *
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <stdio.h>
#include <stdlib.h>

#include "perlxsi.h"    // needed for dynamic Perl-module loading

#include "mix.h"

/* 1 = clean symbol table after each request, 0 = don't */
#ifndef DO_CLEAN
#define DO_CLEAN      0
#endif

#define CMD_LENGTH    1024

#define true          1
#define false         0

PerlInterpreter *my_perl = NULL;    // undef. reference if declared static

int mix_stage = MIX_NO_INIT;        // starting in stage "not initialized"

bool modified = false;              // project modified
char *filename = NULL;              // filename / name of spreadheed


bool mix_get_modified()
{
    return modified;
}


int mix_get_stage()
{
    return mix_stage;
}


char* mix_get_filename()
{
    return filename;
}


void mix_free_filename()
{
    if(filename != NULL) {
	free(filename);
	filename = NULL;
    }
}


int mix_init(const char* mix_path)
{

    if(mix_path == NULL) return ERROR;

    // allocate perl
    if((my_perl = perl_alloc())==NULL) {
	create_info_dialog("Error", "\n  Could not allocate Perl!  \n");
    	exit(1);
    }

    int exitstatus = 0;
    char mix_shell[CMD_LENGTH];

    // skriptname is "mix_embedded.pl"
    sprintf(mix_shell, "%s%c%s", mix_path, DIRECTORY_DELIMIT, "mix_embedded.pl");
    char *embedding[] = { "", (char*)mix_shell};

    perl_construct(my_perl);

    if((exitstatus = perl_parse(my_perl, xs_init, 2, embedding, NULL))!=0) {
	create_info_dialog("Error", "\n            Could not parse MIX!  \n  Maybe you specified the wrong Path?  \n");
	return ERROR;
    }

    PL_exit_flags |= PERL_EXIT_DESTRUCT_END;

    // run the perl script
    if((exitstatus = perl_run(my_perl))!=0) {
	create_info_dialog("Error", "\n  Error running MIX!  \n");
	mix_destroy();
	exit(1);
    }

    modified = false;
    mix_stage = MIX_INIT;
    return SUCCESS;
}


void mix_destroy()
{
    // deallocate perl
    PL_perl_destruct_level = 0;
    perl_destruct(my_perl);
    perl_free(my_perl);
    mix_stage = MIX_NO_INIT;
}


int mix_readSpreadsheet(const char* spreadsheet)
{
    char *args[] = { (char*)spreadsheet, NULL};
    // Todo: Fix passed argument
    call_argv("readSpreadsheet", G_DISCARD, args);
    mix_stage = MIX_READ_IN;

    filename = malloc(strlen(spreadsheet) + 1);
    strcpy(filename, spreadsheet);

    return SUCCESS;
}


int mix_writeSpreadsheet(const char* spreadsheet)
{
    char *args[] = { (char*)spreadsheet, NULL};
    // TODO: do some check, return false if file could not saved
    call_argv("writeSpreadsheet", G_DISCARD, args);

    return SUCCESS;
}


void mix_writeIntermediate(const char* file, const char* type)
{
    if(file==NULL) {
	file = "out";
    }
    if(type==NULL) {
	type = "auto";
    }
    char *args[] = { (char*)file, (char*)type, NULL};
    call_argv("mix_store_db", G_DISCARD, args);
}


void mix_generateEntities()
{
    char *args[] = { NULL};

    call_argv("generate_entities", G_DISCARD | G_NOARGS, args);
    mix_stage = MIX_GENERATED;
}


void mix_writeEntities()
{
    char *args[] = { NULL};

    if(mix_stage < MIX_GENERATED) mix_generateEntities();

    call_argv("write_entities", G_DISCARD | G_NOARGS, args);
}


void mix_writeArchitecture()
{
    char *args[] = { NULL};

    if(mix_stage < MIX_GENERATED) mix_generateEntities();

    call_argv("write_architecture", G_DISCARD | G_NOARGS, args);
}


void mix_writeConfiguration()
{
    char *args[] = { NULL};

    if(mix_stage < MIX_GENERATED) mix_generateEntities();

    call_argv("write_configuration", G_DISCARD | G_NOARGS, args);
}


MixSummary mix_getSummaries()
{
    MixSummary summaries;

    return summaries;
}


int mix_getIntFromEH(const char* keys[])
{
    return 0;
}


const char* mix_getStringFromEH(const char* keys[])
{
    return NULL;
}


bool mix_initTreeWalk()
{
    if(mix_stage < MIX_READ_IN) return false;


    dSP;                            /* initialize stack pointer      */
    ENTER;                          /* everything created after here */
    SAVETMPS;                       /* ...is a temporary variable.   */
    PUSHMARK(SP);                   /* remember the stack pointer    */
    PUTBACK;                        /* make local stack pointer global */
    call_pv("initTreeWalk", G_NOARGS); /* call the function             */
    SPAGAIN;                        /* refresh stack pointer         */

    if(POPi)                        /* pop integer value from stack */
    {                               /* double code below saves a temporary value */
	PUTBACK;
	FREETMPS;                   /* free that return value        */
	LEAVE;                      /* ...and the XPUSHed "mortal" args.*/
	return true;
    }
    else
    {
	PUTBACK;
	FREETMPS;                   /* free that return value        */
	LEAVE;                      /* ...and the XPUSHed "mortal" args.*/
	return false;
    }
}


bool mix_hasChilds()
{
    dSP;                            /* initialize stack pointer      */
    ENTER;                          /* everything created after here */
    SAVETMPS;                       /* ...is a temporary variable.   */
    PUSHMARK(SP);                   /* remember the stack pointer    */
    PUTBACK;                        /* make local stack pointer global */
    call_pv("hasChilds", G_NOARGS); /* call the function             */
    SPAGAIN;                        /* refresh stack                 */

    if(POPi)                        /* pop integer value from stack */
    {                               /* double code below saves a temporary value */
	PUTBACK;
	FREETMPS;                   /* free that return value        */
	LEAVE;                      /* ...and the XPUSHed "mortal" args.*/
	return true;
    }
    else
    {
	PUTBACK;
	FREETMPS;                   /* free that return value        */
	LEAVE;                      /* ...and the XPUSHed "mortal" args.*/
	return false;
    }
}


const char* mix_getNextName(char *name)
{
    dSP;
    ENTER;
    SAVETMPS;
    PUSHMARK(SP);
    PUTBACK;
    call_pv("getNextName", G_NOARGS);
    SPAGAIN;
    strcpy(name, POPp);
    PUTBACK;
    FREETMPS;
    LEAVE;
}

