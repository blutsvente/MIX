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

    bool import;
    bool combine;
    bool strip;
    bool bak;
    bool dump;
    bool verbose;
    bool delta;
    char *input;
    char *import_list;
    char *variant;
    char *target_dir;
    unsigned short dbglevel;

} Options;

    
#endif // __OPTIONS_H_
