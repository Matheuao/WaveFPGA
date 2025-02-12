#include <stdio.h>
#include <stdlib.h>
#include "../include/file_io.h"
#include "../include/modwt_multiresolution.h"

int main(void){
 
    char* in_file_name = "../../input_output_data/clean_audio_files_pcm/sweep_4k.pcm";
    char* root_path = "../../input_output_data/goldem_model_output";
    Word16 g[10] = { //high-pass coefficients quantized in 16 bit
        0x004D, 0x0123, 0xFF6F, 0xF8FB, 0xFD15,
        0x15EE, 0x0C87, 0xBE72, 0x36A7, 0xF182
    };
    Word16 h[10]= { //low-pass coefficients quantized in 16 bit
        0x0E7E, 0x36A7, 0x418E, 0x0C87, 0xEA12,
        0xFD15, 0x0705, 0xFF6F, 0xFEDD, 0x004D
    };

    //parameters:
    int levels=5;
    int coef_size = 10;

    pcm_file_obj *in = read_pcm(in_file_name);
    
    multiresolution_write(in->data, g, h, levels, in->size, coef_size, root_path, "ca_cd");

    free_pcm_file_object(in);

    printf("MODWT multiresolution tested, write ca and cd coefficientes\n");

    return 0;
};