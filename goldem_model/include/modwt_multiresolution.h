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