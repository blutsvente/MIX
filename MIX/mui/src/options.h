/**
 *
 *  File:    options.h
 *  Project: Mui - MIX Userinterface
 *  Author:  Alexander Bauer <Alexander.Bauer@Micronas.com>
 *
 */

#ifndef __OPTIONS_H_
#define __OPTIONS_H_


typedef struct Options_TAG {
    bool import, combine, strip, bak, dump, verbose, delta;
    unsigned short dbglevel;
    char *input, *import_list, *variant, *target_dir;
} Options;

    
#endif // __OPTIONS_H_
