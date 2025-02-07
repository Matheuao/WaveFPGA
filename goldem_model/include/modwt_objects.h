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

modwt_obj* init_modwt_object(long size);
void free_modwt_object(modwt_obj *wt);

imodwt_obj* init_inverse_modwt_object(long size);
void free_inverse_modwt_object(imodwt_obj *wt);

#endif