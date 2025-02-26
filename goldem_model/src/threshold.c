#include "../include/threshold.h"

void avg_estimator(Word16* inout, long size, Word16 k){
    
    Word32 y [size];
    Word32 y_tau = 0; // k must be less tha 15
    Word32 buffer = 0;
    long n;
    Word16 test;
    
    y[0] = 0;

    for (n = 1; n < size; n++){

        y_tau = L_shr(y[n-1], k);

        buffer = L_sub(y[n-1], y_tau);

        y[n] = L_add((Word32)inout[n], buffer);
    }

    for (n = 0; n < size; n++){
        inout[n] = (Word16) L_shr(y[n], k);
    }
}
