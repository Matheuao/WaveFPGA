#include <stdio.h>
#include <stdlib.h>
#include "../include/file_io.h"
#include "../include/threshold.h"

int main(void){
 
    char* in_file_name = "../../input_output_data/test_files/ruido_gausiano.pcm";
    char* out_file_name = "../../input_output_data/test_files/media.pcm";

    pcm_file_obj* in = read_pcm(in_file_name);
   
    avg_estimator(in->data, in->size, 10);
    
    write_pcm(out_file_name, in->data, in->size);
    free_pcm_file_object(in);

    printf("Exponential Smoothing avarage tested\n");

    return 0;
};