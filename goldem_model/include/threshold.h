#ifndef THRESHOLD_H
#define THRESHOLD_H

#include <stdio.h>
#include <stdlib.h>
#include "../lib/bit_exact/include/typedef.h"
#include "../lib/bit_exact/include/basic_op.h"

void avg_estimator(Word16* inout, long size, Word16 k);

void t_function(Word16* inout, char s_h);

void thresholding(Word16* inout, char s_h);

#endif