#ifndef DENOISING_H
#define DENOISING_H

#include "modwt_multiresolution.h"
#include "threshold.h"

#define WINDOW 80000


extern Word16 buffer_g[10];

extern Word16 buffer_h[10];

extern Word16 buffer_c[5];

typedef struct{
    Word16* g;
    Word16* h;
    Word16 levels;
    long input_size;
    Word16 coef_size;
    char s_h;
    Word16 k;
    Word16* cj; 
} parameters;

void init_default_parameters(parameters* p);

void denoising_write(char* in_path, char* out_path, parameters* p);
void denoising(pcm_file_obj* in, Word16* out, parameters* p);

#endif