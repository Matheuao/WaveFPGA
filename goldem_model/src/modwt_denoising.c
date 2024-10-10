#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "../include/modwt_denoising.h"
#include "../lib/bit_exact/typedef.h"
#include "../lib/bit_exact/oper32b.h"
#include "../lib/bit_exact/basic_op.h"


void modwt(Word16 *input,modwt_obj output, Word16 *g,Word16 *h, Word16 level, long size, short coef_size){
    long t,u;
    int n;
    
    Word32 ca_temp = 0,cd_temp = 0;
    
    for (t=0; t < size; t++){
        u = t;
        ca_temp = L_mult(h[0],input[t]); 
        cd_temp = L_mult(g[0],input[t]);

        for (n = 1; n < coef_size; n++){

            u -=(long)pow(2.0,(double)level); //checar se isso aqui da bom

            if (u < 0){
                u = size - 1;
            }

            ca_temp = L_mac(ca_temp, h[n],input[u]);
            cd_temp = L_mac(cd_temp, g[n],input[u]);

            output.ca[t] = extract_h(ca_temp);
            output.cd[t] = extract_h(cd_temp);
        }    
    }
}

modwt_obj init_modwt_obj(long size){

    modwt_obj wt;
    modwt_obj null;
    
    wt.ca = (Word16*) malloc(size * sizeof(Word16));
    wt.cd = (Word16*) malloc(size * sizeof(Word16));

    if (wt.ca == NULL || wt.cd == NULL){
        printf("error in allocating memory on modwt_obj");
        free(wt.ca);
        free(wt.cd);
        return null;
    }

    return wt;

    /*
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

    */
}

void free_modwt_obj(modwt_obj wt){
   free(wt.ca);
   free(wt.cd);
    /*int i;

    for (i = 0;i < levels; i++) { 
        free(wt[i].ca);
        free(wt[i].cd);
    }
    free(wt);*/
}