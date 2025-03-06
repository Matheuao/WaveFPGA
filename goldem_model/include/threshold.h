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