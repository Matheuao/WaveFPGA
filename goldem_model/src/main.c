#include <stdio.h>
#include <stdlib.h>
#include "../include/denoising.h"

int main(void){
    char* in_path= "../../input_output_data/test_files/guitar4_snr10.pcm";
    char* out_path = "../../input_output_data/goldem_model_output/out.pcm";
    parameters p;

    init_default_parameters(&p);

    denoising(in_path, out_path, &p);

    printf("Denoising tested!");

    return 0;
};