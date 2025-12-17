#include <stdio.h>
#include <stdlib.h>
#include "../include/file_io.h"
#include "../include/objects.h"
#include "../include/modwt_transform_core.h"



int main(void){
 
    char *in_file_name = "../../input_output_data/clean_audio_files_pcm/sweep_4k.pcm";

    char *ca_file_name ="../../input_output_data/goldem_model_output/ca.pcm";
    char *cd_file_name ="../../input_output_data/goldem_model_output/cd.pcm";
    
    Word16 g[10] = { //high-pass coefficients quantized in 16 bit
        0x004D, 0x0123, 0xFF6F, 0xF8FB, 0xFD15,
        0x15EE, 0x0C87, 0xBE72, 0x36A7, 0xF182
    };
    Word16 h[10]= { //low-pass coefficients quantized in 16 bit
        0x0E7E, 0x36A7, 0x418E, 0x0C87, 0xEA12,
        0xFD15, 0x0705, 0xFF6F, 0xFEDD, 0x004D
    };

    //parameters:
    int level=1;

    pcm_file_obj *in = read_pcm(in_file_name);

    modwt_obj* wt = init_modwt_object(in->size);

    modwt(in->data, wt, g, h, level,10);
    
    free_pcm_file_object(in);

    write_pcm(ca_file_name, wt->ca, wt->size);
    write_pcm(cd_file_name, wt->cd, wt->size);

    free_modwt_object(wt);
    
    printf("Direct transform tested\n");

    return 0;
};