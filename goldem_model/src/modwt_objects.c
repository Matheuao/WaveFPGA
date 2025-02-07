#include"../include/modwt_objects.h"


modwt_obj* init_modwt_object(long size){

    modwt_obj *wt = (modwt_obj*) malloc(sizeof(modwt_obj));
    if(wt == NULL){
        printf("Error allocating memory for modwt object");
        exit(EXIT_FAILURE);
    }
   
    wt->ca = (Word16*) malloc(size * sizeof(Word16));
    wt->cd = (Word16*) malloc(size * sizeof(Word16));
    wt->size = size;

    if (wt->ca == NULL || wt->cd == NULL){
        printf("error in allocating memory for Ca and Cd coefficients of the wavelet");
        free(wt);
        exit(EXIT_FAILURE);
    }

    // iinitialize the object data with zeros
    for (int i = 0; i < size; i++) {
        wt->ca[i] = 0;
        wt->cd[i] = 0;
    }

    return wt;
}

void free_modwt_object(modwt_obj *wt){
    
    if(wt != NULL){
         // free object data
        free(wt->ca);
        free(wt->cd);
        // free the object itself
        free(wt);
    }
}

imodwt_obj* init_inverse_modwt_object(long size){

    imodwt_obj *wt = (imodwt_obj*) malloc(sizeof(imodwt_obj));
    if(wt == NULL){
        printf("Error allocating memory for modwt object");
        exit(EXIT_FAILURE);
    }
   
    wt->inv = (Word16*) malloc(size * sizeof(Word16));
    wt->size = size;

    if (wt->inv == NULL){
        printf("error in allocating memory for Ca and Cd coefficients of the wavelet");
        free(wt);
        exit(EXIT_FAILURE);
    }

    // iinitialize the object data with zeros
    for (int i = 0; i < size; i++) {
        wt->inv[i] = 0;
    }

    return wt;
}

void free_inverse_modwt_object(imodwt_obj *wt){
    
    if(wt != NULL){
         // free object data
        free(wt->inv);
        // free the object itself
        free(wt);
    }
}