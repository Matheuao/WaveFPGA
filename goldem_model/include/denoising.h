#ifndef DENOISING_H
#define DENOISING_H

#include "modwt_multiresolution.h"
#include "threshold.h"

Word16 buffer_g[10] = { //high-pass coefficients quantized in 16 bit
    0x004D, 0x0123, 0xFF6F, 0xF8FB, 0xFD15,
    0x15EE, 0x0C87, 0xBE72, 0x36A7, 0xF182
};

Word16 buffer_h[10]= { //low-pass coefficients quantized in 16 bit
    0x0E7E, 0x36A7, 0x418E, 0x0C87, 0xEA12,
    0xFD15, 0x0705, 0xFF6F, 0xFEDD, 0x004D
};

Word16 buffer_c[5] ={
    0x0007, 0x0004, 0x0003, 0x0002, 0x0001
};
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

void init_parameters(parameters* p);

void denoising(Word16* in, Word16* out, parameters* p);

#endif