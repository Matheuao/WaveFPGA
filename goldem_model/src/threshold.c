#include "../include/threshold.h"

void avg_estimator(Word16* in, Word16* out, long size, Word16 k){
    
    Word32 y [size];
    Word32 y_tau = 0; // k must be less tha 15
    Word32 buffer = 0;
    long n;
    Word16 test;
    
    y[0] = 0;
    out[0] = 0;

    for (n = 1; n < size; n++){

        y_tau = L_shr(y[n-1], k);
        buffer = L_sub(y[n-1], y_tau);

        y[n] = L_add((Word32)in[n], buffer);

        out[n] = (Word16) L_shr(y[n], k);
    }

}

void t_function(Word16* in, Word16* out, long size, char s_h){    
}
/*
void thresholding(Word16* inout, long size, char s_h){
    Word16 lambda;
    Word16 d_j[size];
    Word16 avg_d_j[size];
    long i;

    for(i = 0; i<)

    avg
}
    */