/*
-- ============================================================================
--  modwt_multiresolution.h
--
--  MODWT multiresolution 
--
--  Author       : Matheus Araújo de Oliveira
--  Organization : Federal University of Santa Catarina (UFSC)
--  Email        : matheusaop09@gmail.com
--  Last modified: 2026-02-25
--  Version      : 1.0
--  Description:
--  Compute the bit exact n level NDWT filter bank algorithm. 
--  Goldem model for verification purposes.
--  TODO: include the DWT filter bank algorithm.
--
--  License:
--    Free for academic and non-commercial research use.
--    Commercial use requires a separate commercial license agreement.
--    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
--
--  Copyright (c) 2026 Matheus Araújo de Oliveira
-- ============================================================================
*/

#ifndef MODWT_MULTIRESOLUTION
#define MODWT_MULTIRESOLUTION
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../lib/bit_exact/include/typedef.h"
#include "file_io.h"
#include "modwt_transform_core.h"
#include "objects.h"

void multiresolution_component_write(Word16* in,
                           Word16* g,
                           Word16* h,
                           Word16 levels,
                           long input_size,
                           Word16 coef_size,
                           char* root_path,
                           char* component);

void modwt_dec( Word16* in, 
                modwt_dec_obj* wt_dec,
                Word16* g,
                Word16* h,
                Word16 levels,
                long input_size,
                Word16 coef_size);

void modwt_rec( modwt_dec_obj* wt_dec, 
                imodwt_obj* out,
                Word16* g,
                Word16* h,
                Word16 levels,
                long input_size,
                Word16 coef_size);

#endif