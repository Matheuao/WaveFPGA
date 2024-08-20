#include <stdio.h>
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

/*typedef struct{
    Word16 *input;
    Word16 *Ca;
    Word16 *Cd;
    Word16 *inv;
    Word8 level;
    long size;
    Word8 type_threshold;
} modwt_data;
*/

int main(void){
    char *in_file_name = "..//..//input_output_data/clean_audio_files_pcm/sweep_4k.pcm";
    char *out_file_name ="..//..//input_output_data/goldem_model_output/out.pcm";
    int levels=5;
    int i;
    short *out;
    pcm_file_obj in_out;
    in_out = init_pcm_file_object(in_file_name);

    modwt_obj *wt;
    wt = init_modwt_obj(in_out.size, levels);

    in_out = read_pcm(in_file_name, in_out);

    for(i=0;i<in_out.size;i++){
        wt[1].ca[i]=in_out.data[i]/2;
        printf("wt[1].ca[%d]=%d\n",i,wt[1].ca[i]);
    }
    
    whrite_pcm(out_file_name,wt[1].ca,in_out.size);

    free_pcm_object(in_out);
    free_modwt_obj(wt,levels);
    
    return 0;
};