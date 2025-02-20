#include <stdio.h>
#include <stdlib.h>
#include "../include/file_io.h"
#include "../include/modwt_multiresolution.h"

int main(void){
 
    char* in_file_name = "../../input_output_data/clean_audio_files_pcm/sweep_4k.pcm";
    char* modwt_dec_ca_path = "../../input_output_data/goldem_model_output/ca.pcm";
    char* modwt_dec_cd_path = "../../input_output_data/goldem_model_output/cd_todos.pcm";


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
    modwt_dec_obj *wt_m = init_modwt_dec_object(in->size, levels);

    modwt_dec(in->data, wt_m, g, h, levels, in->size, coef_size);
    free_pcm_file_object(in);

    write_pcm(modwt_dec_ca_path, wt_m->ca, wt_m->size);
    write_pcm(modwt_dec_cd_path, wt_m->cd, (wt_m->size * wt_m->levels));

    free_modwt_dec_object(wt_m);

    printf("MODWT decomposition tested, ca and cd coefficients written\n");

    return 0;
};