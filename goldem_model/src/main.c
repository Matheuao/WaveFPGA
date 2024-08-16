#include <stdio.h>
#include "../include/utils.h"
#include "../lib/bit_exact/typedef.h"
#include "../lib/bit_exact/basic_op.h"

//TODO:
//creat a struct whith the modwt coeficients and parameters
//
/* crate a modwt*/
/* create a imodwt*/
/* create a threhsold, sample by sample, exponential smothing*/
/* create delay function*/
typedef struct{
    Word16 *input;
    Word16 *Ca;
    Word16 *Cd;
    Word16 *inv;
    Word8 level;
    long size;
    Word8 type_threshold;
} modwt_data;

int main(void){
    const char *in_file_name = "..//..//clean_audio_files_pcm/sweep_4k.pcm";
    const char *out_file_name ="out.pcm";

    FILE * ptrArqIn;
    FILE * ptrArqOut;

    modwt_data wt;
    wt.size = get_file_size(in_file_name, sizeof(Word16)*8);
 

    /*
    ptrArqIn = fopen(in_file_name,"rb");
    if(ptrArqIn == NULL){
        printf("error in open the input file");
    }
    fread(&amostra,sizeof(short),1,ptrArqIn);

    ptrArqOut = fopen(out_file_name,"wb");
    if(ptrArqOut == NULL){
        printf("error in open the output file");
    }
    */
    //wt.Ca = input;
    

    

    return 0;
};