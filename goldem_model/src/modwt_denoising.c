#include <stdio.h>
#include <stdlib.h>
#include "../include/modwt_denoising.h"
#include "../lib/bit_exact/typedef.h"
#include "../lib/bit_exact/basic_op.h"

/*
modwt_obj modwt(short *input, short level, long size){
    modwt_obj wt;
    return; 
}
*/
modwt_obj* init_modwt_obj(long size, int levels){
    
    modwt_obj * wt = (modwt_obj*) malloc(levels* sizeof(modwt_obj));
    if(wt == NULL){
        printf("error in allocating memory on modwt_obj");
        return NULL;
    }

    int i;

    for (i=0; i<levels; i++){
        wt[i].ca=(short*) malloc(size*sizeof(short));
        wt[i].cd=(short*) malloc(size*sizeof(short));
    }

    if (wt[i].ca == NULL || wt[i].cd == NULL){
        printf("error in allocating memory on modwt_obj");
        
        for (i = 0;i < levels; i++) { 
                free(wt[i].ca);
                free(wt[i].cd);
            }
            free(wt);
            return NULL;
    }
    
    return wt;
}

void free_modwt_obj(modwt_obj * wt, int levels){
    int i;

    for (i = 0;i < levels; i++) { 
                free(wt[i].ca);
                free(wt[i].cd);
            }
    free(wt);
}