#include "../include/modwt_transform_core.h"

void modwt( Word16* input,
            modwt_obj* wt,
            Word16* g, 
            Word16* h, 
            Word16 level,  
            Word16 coef_size){
                    
    /*Perform the direct transform of the modwt (Maximun Overlap Discreate Wavelet Transform)*/
    
    long t,u;
    int n;
    
    Word32 ca_temp = 0,cd_temp = 0;
    //modwt_obj *output = init_modwt_object(size);

    // Remember that the FPGA design has a transitional state where the samples 
    // are delayed by the pipeline stages. The C implementation has a different 
    // transitional behavior, caused by the fact that multiplication and 
    // accumulation operations are performed at the beginning of the array, 
    // resulting in a circular transition.

    for (t= 0; t < wt->size; t++){
        u = t;
        ca_temp = L_mult(h[0],input[t]); 
        cd_temp = L_mult(g[0],input[t]);

        wt->ca[t] = extract_h(ca_temp);
        wt->cd[t] = extract_h(cd_temp);

        for (n = 1; n < coef_size; n++){

            u -=(long)pow(2.0,(double)(level-1)); 

            if (u < 0){ //circular transitional in the begining of the aray
                u = wt->size - 1;
            }

            ca_temp = L_mac(ca_temp, h[n],input[u]);
            cd_temp = L_mac(cd_temp, g[n],input[u]);

            wt->ca[t] = extract_h(ca_temp);
            wt->cd[t] = extract_h(cd_temp);
        }    
    }
}

void imodwt(Word16 *ca,
            Word16 *cd,
            imodwt_obj* wt,
            Word16 *g, 
            Word16 *h, 
            Word16 level,  
            Word16 coef_size){

    /*Perform the inverse transform of the modwt (Maximun Overlap Discreate Wavelet Transform)*/

    long t,u;
    int n;
    
    Word32 out_temp = 0;
    Word32 mult_ca = 0, mult_cd = 0;
    Word32 add_temp = 0;

    for(t = 0; t < wt->size; t++) {
        u = t;

        mult_ca = L_mult(h[0], ca[t]);
        mult_cd = L_mult(g[0], cd[t]);

        out_temp = L_add(mult_ca, mult_cd);
        wt->inv[t] = extract_h(out_temp);

        for(n = 1; n < coef_size; n++){
            u +=(long)pow(2.0,(double)(level-1));

            if(u > wt->size - 1){
                u = 0;
            }

            mult_ca = L_mult(h[n], ca[u]);
            mult_cd = L_mult(g[n], cd[u]);
            add_temp = L_add(mult_ca, mult_cd);
            out_temp = L_add(add_temp, out_temp);
            wt->inv[t] = extract_h(out_temp);
        }
    }
}
