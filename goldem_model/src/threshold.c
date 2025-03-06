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

Word8 sgn(Word16 var){
    if(var > 0){
        return 1;
    }
    else if(var < 0){
        return -1;
    }
    else{
        return 0;
    }
}

void t_function(Word16* inout, Word16* lambda, long size, char s_h){    

    if(s_h == 's'){
        Word16 tmp,tmp2,tmp3;

        for(Word16 i = 0; i < size ; i++){
            tmp = abs(inout[i]) - lambda[i];
            tmp2 = tmp + abs(tmp);
            tmp3 = shr(tmp2,1);
            inout[i] = sgn(tmp3) * tmp3;
        }
    }
    else if(s_h == 'h'){
        for(Word16 i = 0; i < size; i ++){
            if(abs(inout[i]) > lambda[i]){
                inout[i] = inout[i];
            }
            else{
                inout[i] =  0;
            }
        }
    }

    else{
        printf("Invalid option. Available options are: 's' for soft threshold and 'h' for hard threshold.");
    }
}

void thresholding(Word16* inout, long size, char s_h, Word16 k, Word16 c){
    Word16 lambda[size];
    Word16 abs_sub_dj[size];
    Word16 avg_dj[size];
    Word32 tmp;
    long i;

    avg_estimator(inout, avg_dj, size, k);

    for(i = 0; i < size ; i++){
        abs_sub_dj[i] = abs (inout[i] - avg_dj[i]);
    }

    avg_estimator(abs_sub_dj, avg_dj, size, k);

    for(i = 0; i < size; i++){
        tmp = L_mult(avg_dj[i], c);
        lambda[i] = extract_h(tmp);
    }

    t_function(inout,lambda, size, s_h);
}
