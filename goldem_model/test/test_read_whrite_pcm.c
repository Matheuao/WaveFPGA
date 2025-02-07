#include <stdio.h>
#include <stdlib.h>
#include "../include/file_io.h"


int main(void){
 
    char *in_file_name = "../../input_output_data/clean_audio_files_pcm/sweep_4k.pcm";
    char *out_file_name ="../../input_output_data/goldem_model_output/ca.pcm";
   
    pcm_file_obj *in = read_pcm(in_file_name);

    whrite_pcm(out_file_name ,in->data, in->size);
    
    free_pcm_file_object(in);

    printf("Read and write a pcm file successfully\n");

    return 0;
};