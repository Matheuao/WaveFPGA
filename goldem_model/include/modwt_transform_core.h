/*
-- ============================================================================
--  modwt_transform_core.h
--
--  MODWT Transform Core 
--
--  Author       : Matheus Araújo de Oliveira
--  Organization : Federal University of Santa Catarina (UFSC)
--  Email        : matheusaop09@gmail.com
--  Last modified: 2026-02-25
--  Version      : 1.0
--  Description:
--  Compute the inverse and direct MODWT filter bank algorithm.
--  TODO: include the DWT filter bank algorithm.
--  License:
--    Free for academic and non-commercial research use.
--    Commercial use requires a separate commercial license agreement.
--    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
--
--  Copyright (c) 2026 Matheus Araújo de Oliveira
-- ============================================================================
*/

#ifndef MODWT_TRANSFORM_CORE_H
#define MODWT_TRANSFORM_CORE_H
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "../lib/bit_exact/include/typedef.h"
#include "../lib/bit_exact/include/basic_op.h"
#include "objects.h"


void modwt( Word16* input,
            modwt_obj* wt,
            Word16* g,
            Word16* h,
            Word16 level,
            Word16 coef_size);

void imodwt(Word16* ca,
            Word16* cd,
            imodwt_obj* wt,
            Word16* g,
            Word16 *h,
            Word16 level,
            Word16 coef_size);
#endif