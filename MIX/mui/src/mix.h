/* Copyright (C) 1991,92,95,96,97,98,99,2000,01 Free Software Foundation, Inc.
 * This file is part of the GNU C Library.
 *
 * The GNU C Library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * The GNU C Library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with the GNU C Library; if not, write to the Free
 * Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 * 02111-1307 USA.
 *
 *
 * File: mix.h - MIX Interface
 * Project: Mui - MIX Userinterface
 * Author: Alexander Bauer, Alexander.Bauer@Micronas.com / ifw02024@cs.fhm.edu
 * 
 * Note: implementation as Class isn't possible, because of including
 *       perl.h and EXTERN.h in mix.h causes segfaults
 *
 */

#ifndef __MIX_H_
#define __MIX_H_

#include <EXTERN.h>
#include <perl.h>


#ifndef G_OS_WIN32                // character seperating directory levels
#define DIRECTORY_DELIMIT '/'
#else
#define DIRECTORY_DELIMIT '\\'
#endif

#define INSTANCE_NAME_LENGTH 1024

#define SUCCESS 0
#define ERROR -1

#define TOPLEVEL 0
#define TESTBENCH 0


/**
 * Structure holding MIX summaries
 */
typedef struct MixSummary {

    int warnings; /*!< MIX Warnings */
    int errors; /*!< MIX Errors */
    int inst; /*!< Number of Instances located */
    int conn; /*!< Number of Connections located */
    int genport; /*!< Number of generated Ports */
    int cmacros; /*!< Number of Macros */
    int noload; /*!< Signal without Load */
    int nodriver; /*!< Number of missing Signals */
    int multidriver; /*!< Number of multiple Signal assignments */
    int openports; /*!< Number of Open Ports */
    int checkwarn; /*!< */
    int checkforce; /*!<  */
    int checkunique; /*!<  */
    int changedFiles; /*!< Number of changed Files */
    int changedIntermediate; /*!< Number of changes in Intermediate File */

    /**
     * parsed sheets
     */
    struct {
	int conf; /*!< Number of Configurations Sheets read */
	int hier; /*!< Number of Hierrarchy Sheets read */
	int conn; /*!< Number of Connection Sheets read */
	int io; /*!< Number of IO Sheets read */
	int i2c; /*!< Number of I2C Sheets read */
    } parsed;
} MixSummary;


/**
 * allocate and trigger a MIX Object
 * @param mix_path Absolute PATH of MIXs Toplevel Directory
 */
int mix_init(const char* mix_path);

/**
 * Destructor
 * destroy the MIX Object
 */
void mix_destroy();

/**
 * Read Spreadsheet, extract all needfull sheets and normalize them.
 * @param spreadsheet Spreadsheetname
 * @return Error code
 */
void mix_readSpreadsheet(const char* spreadsheet);

/**
 * Write Project into Spreadsheet. This will write all changes made to the open Project.
 * @param spreadsheet Spreadsheetname
 * @return Error code
 */
int mix_writeSpreadsheet(const char* spreadsheet);


/**
 * Write intermediate Data
 * @param file filename
 * @param type can be auto,xls,csv,internal;
 */
void mix_writeIntermediate(const char* file, const char* type);

/**
 * generate Entities
 */
void mix_generateEntities();


/**
 * Write Entities into output file(s)
 */
void mix_writeEntities();
/**
 * Write Architecture into output file(s)
 */
void mix_writeArchitecture();
/**
 * Write Configuration into output file(s)
 */
void mix_writeConfiguration();

/**
 * Get MIX's summaries. 
 * See @see mixSum Structure Documentation for Details
 * @return MIX runtime summaries
 */
MixSummary mix_getSummaries();


/**
 * Get Integer Value from the EH settings structure
 * @param key Name of Value
 * @return Integer Value
 */
int mix_getIntFromEH(const char* keys[]);
/**
 * Get String from the EH settings structure
 * @param key Name of String
 * @return character String
 */
const char* mix_getStringFromEH(const char* keys[]);


/**
 * Set location in hierachical Tree to TOPLEVEL
 */
bool mix_initTreeWalk();
/**
 * Does this location have childs
 * @return true if it does; false if not
 */
bool mix_hasChilds();
/**
 * Get the Name of the Next Element, if there are none
 * return NULL
 * @return Name of the next Element
 */
const char* mix_getNextName(char *name);


#endif // __MIX_H_
