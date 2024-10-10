#include <stdio.h>
#include <stdlib.h>
#include "../lib/bit_exact/typedef.h"
#include "../include/file_io.h"
#include "../include/modwt_denoising.h"

//#include "../lib/bit_exact/typedef.h"
//#include "../lib/bit_exact/basic_op.h"

//TODO:
//creat a struct whith the modwt coeficients and parameters
//
/* crate a modwt*/
/* create a imodwt*/
/* create a threhsold, sample by sample, exponential smothing*/
/* create delay function*/



int main(void){
    /*
    //char *in_file_name = "..//..//input_output_data/clean_audio_files_pcm/sweep_4k.pcm";
    //char *out_file_name ="..//..//input_output_data/goldem_model_output/out.pcm";
    char *in_file_name = "..//..//input_output_data/clean_audio_files_pcm/sweep_4k.pcm";
    char *ca_file_name ="ca.pcm";
    char *cd_file_name ="cd.pcm";
    //char *ca_file_name ="..//..//input_output_data/goldem_model_output/test_goldem_output/ca.pcm";
    //char *cd_file_name ="..//..//input_output_data/goldem_model_output/test_goldem_output/cd.pcm";
    Word16 g[10]; // get values
    Word16 h[10]; // get values

    //parameters:
    int level=5;
    //obj init:
    pcm_file_obj in_out;
    in_out = init_pcm_file_object(in_file_name);

    modwt_obj wt;
    wt = init_modwt_obj(in_out.size);



    in_out = read_pcm(in_file_name, in_out);

    modwt(in_out.data,wt,g,h,level,in_out.size,10);

    free_pcm_object(in_out);
    
    whrite_pcm(ca_file_name,wt.ca,in_out.size);
    whrite_pcm(cd_file_name,wt.cd,in_out.size);

    
    free_modwt_obj(wt);

    */

    printf("hello world!");
    
    return 0;
};