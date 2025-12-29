#include "../include/denoising.h"

Word16 buffer_g[10] = { //high-pass coefficients quantized in 16 bit
    0x004D, 0x0123, 0xFF6F, 0xF8FB, 0xFD15,
    0x15EE, 0x0C87, 0xBE72, 0x36A7, 0xF182
};

Word16 buffer_h[10]= { //low-pass coefficients quantized in 16 bit
    0x0E7E, 0x36A7, 0x418E, 0x0C87, 0xEA12,
    0xFD15, 0x0705, 0xFF6F, 0xFEDD, 0x004D
};

Word16 buffer_c[5] ={
    0x0007, 0x0004, 0x0003, 0x0002, 0x0001
};
void init_default_parameters(parameters* p){
    p->g = buffer_g;
    p->h = buffer_h;
    p->cj = buffer_c;
    p->coef_size =  10;
    p->input_size = WINDOW;
    p->k = 16;
    p->levels = 5;
    p->s_h = 'h';
}

void denoising_write(char* in_path, char* out_path, parameters* p){

    long i;
    pcm_file_obj *in = read_pcm(in_path);
    modwt_dec_obj *wt_m = init_modwt_dec_object(in->size, p->levels);

    Word16 *buffer = (Word16*)malloc(in->size * sizeof(Word16));

    modwt_dec(in->data, wt_m, p->g, p->h, p->levels, in->size, p->coef_size);

    for(int n = 0; n < p->levels; n++){
        for (i = 0; i < in->size; i ++){
            buffer[i]= wt_m->cd[i + (n * in->size)];
        }

        thresholding(buffer, in->size, p->s_h, p->k, p->cj[n]);
        
        for(i = 0; i < in->size; i++){
            wt_m->cd[i + (n * in->size)] = buffer[i];
        }
    }
    free(buffer);

    imodwt_obj* iwt = init_inverse_modwt_object(in->size);
    modwt_rec(wt_m, iwt, p->g, p->h, p->levels, in->size, p->coef_size);

    write_pcm(out_path, iwt->inv, in->size);
    
    free_pcm_file_object(in);
    free_modwt_dec_object(wt_m);
    free_inverse_modwt_object(iwt);
}

void denoising(pcm_file_obj* in, Word16* out, parameters* p){
    long i;
    modwt_dec_obj *wt_m = init_modwt_dec_object(in->size, p->levels);

    Word16 *buffer = (Word16*)malloc(in->size * sizeof(Word16));

    modwt_dec(in->data, wt_m, p->g, p->h, p->levels, in->size, p->coef_size);

    for(int n = 0; n < p->levels; n++){
        for (i = 0; i < in->size; i ++){
            buffer[i]= wt_m->cd[i + (n * in->size)];
        }

        thresholding(buffer, in->size, p->s_h, p->k, p->cj[n]);
        
        for(i = 0; i < in->size; i++){
            wt_m->cd[i + (n * in->size)] = buffer[i];
        }
    }
    free(buffer);
    
    imodwt_obj* iwt = init_inverse_modwt_object(in->size);
    modwt_rec(wt_m, iwt, p->g, p->h, p->levels, in->size, p->coef_size);

    for(i = 0; i < in->size; i++){
        out[i] = iwt->inv[i];
    }
    free_modwt_dec_object(wt_m);
    free_inverse_modwt_object(iwt);
}

