#ifndef MODWT_DENOISING_H
#define MODWT_DENOISING_H
#include "../lib/bit_exact/typedef.h"

struct modwt_obj_set{
    short *ca;
    short *cd;
};
typedef struct modwt_obj_set modwt_obj;


modwt_obj init_modwt_obj(long size);

void free_modwt_obj(modwt_obj wt);

void modwt(Word16 *input,modwt_obj output, Word16 *g,Word16 *h, Word16 level, long size, short coef_size);

#endif