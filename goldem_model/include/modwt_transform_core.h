#ifndef MODWT_TRANSFORM_CORE_H
#define MODWT_TRANSFORM_CORE_H
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "../lib/bit_exact/include/typedef.h"
#include "../lib/bit_exact/include/basic_op.h"
#include "modwt_objects.h"


modwt_obj* modwt(Word16 *input, Word16 *g,Word16 *h, Word16 level, long size, Word16 coef_size);

imodwt_obj* imodwt(Word16 *ca, Word16 *cd, Word16 *g, Word16 *h, Word16 level, long size, Word16 coef_size);
#endif