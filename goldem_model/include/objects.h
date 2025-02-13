#ifndef MODWT_OBJECTS_H
#define MODWT_OBJECTS_H

#include <stdio.h>
#include <stdlib.h>
#include"../lib/bit_exact/include/typedef.h"

typedef struct{
    Word16 *ca;
    Word16 *cd;
    long size;
} modwt_obj;

typedef struct{
    Word16 *inv;
    long size;
}imodwt_obj;

// (can, cd1, cd2, ...cdn)
typedef struct{
    Word16* ca;
    Word16* cd;
    Word16* inv;
    Word16 levels;
    long size;
}m_level_modwt_obj;

modwt_obj* init_modwt_object(long size);
void free_modwt_object(modwt_obj *wt);

imodwt_obj* init_inverse_modwt_object(long size);
void free_inverse_modwt_object(imodwt_obj *wt);

m_level_modwt_obj* init_m_level_modwt_objet(long size, Word16 levels);
void free_m_level_modwt(m_level_modwt_obj* wt);

#endif