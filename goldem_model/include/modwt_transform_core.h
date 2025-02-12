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