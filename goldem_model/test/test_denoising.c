#include <stdio.h>
#include <stdlib.h>
#include "../include/denoising.h"

int main(void){
    char* in_path= "../../input_output_data/test_files/guitar4_snr10.pcm";
    char* out_path = "../../input_output_data/goldem_model_output/out.pcm";
    parameters p;
    pcm_file_obj *in = read_pcm(in_path);
    Word16 *out = (Word16*)malloc(in->size * sizeof(Word16));

    init_default_parameters(&p);

    denoising(in, out, &p);

    write_pcm(out_path, out, in->size);

    free(out);
    free_pcm_file_object(in);

    printf("Denoising tested!");

    return 0;
};