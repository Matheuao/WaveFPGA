/*
-- ============================================================================
--  threshold.h
--
--  Threshold
--
--  Author       : Matheus Araújo de Oliveira
--  Organization : Federal University of Santa Catarina (UFSC)
--  Email        : matheusaop09@gmail.com
--  Last modified: 2026-02-25
--  Version      : 1.0
--  Description:
--  Implement the universal threshold algorithm with mean exponential smoothing,
--  to mimic real time behavior of the digital desing. Goldem model for verification 
--  purposes.
--
--  License:
--    Free for academic and non-commercial research use.
--    Commercial use requires a separate commercial license agreement.
--    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
--
--  Copyright (c) 2026 Matheus Araújo de Oliveira
-- ============================================================================
*/


#ifndef THRESHOLD_H
#define THRESHOLD_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../lib/bit_exact/include/typedef.h"
#include "../lib/bit_exact/include/basic_op.h"

void avg_estimator(Word16* in, Word16* out, long size, Word16 k);

void t_function(Word16* inout, Word16* lambda, long size, char s_h);

void thresholding(Word16* inout, long size, char s_h, Word16 k, Word16 c);

Word8 sgn(Word16 var);
#endif