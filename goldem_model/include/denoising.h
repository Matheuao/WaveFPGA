/*
-- ============================================================================
--  denoising.h
--
--  Denoising goldem model implementation
--
--  Author       : Matheus Araújo de Oliveira
--  Organization : Federal University of Santa Catarina (UFSC)
--  Email        : matheusaop09@gmail.com
--  Last modified: 2026-02-25
--  Version      : 1.0
--  Description:
--  Compute the bit exact NDWT denoising. Goldem model for verification purposes.
--  TODO:Implement de DWT denoising
--  License:
--    Free for academic and non-commercial research use.
--    Commercial use requires a separate commercial license agreement.
--    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
--
--  Copyright (c) 2026 Matheus Araújo de Oliveira
-- ============================================================================
*/

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