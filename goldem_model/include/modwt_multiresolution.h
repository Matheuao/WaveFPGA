#ifndef MODWT_MULTIRESOLUTION
#define MODWT_MULTIRESOLUTION
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../lib/bit_exact/include/typedef.h"
#include "file_io.h"
#include "modwt_transform_core.h"
#include "objects.h"

typedef struct{
    Word16* ca_data;
    Word16* cd_data;
    Word16* inv_data;
    long size;
    Word16 levels;
}modwt_mres_obj;



modwt_mres_obj* modwt_multiresolution(Word16* in,
                                      Word16* g,
                                      Word16* h,
                                      Word16 levels,
                                      long input_size,
                                      Word16 coef_size,
                                      char * root_path,
                                      char* component,
                                      char* config);

void multiresolution_write(Word16* in,
                           Word16* g,
                           Word16* h,
                           Word16 levels,
                           long input_size,
                           Word16 coef_size,
                           char* root_path,
                           char* component);

modwt_mres_obj* multiresolution_ret(Word16* in,
                                    Word16* g,
                                    Word16* h,
                                    Word16 levels,
                                    long input_size,
                                    Word16 coef_size,
                                    char* component);

#endif