#ifndef MODWT_DENOISING_H
#define MODWT_DENOISING_H

struct modwt_obj_set{
    short *ca;
    short *cd;
};
typedef struct modwt_obj_set modwt_obj;

modwt_obj* init_modwt_obj(long size, int levels);
void free_modwt_obj(modwt_obj * wt, int levels);

#endif