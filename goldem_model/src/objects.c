#include"../include/objects.h"


modwt_obj* init_modwt_object(long size){

    modwt_obj *wt = (modwt_obj*) malloc(sizeof(modwt_obj));
    if(wt == NULL){
        printf("Error allocating memory for modwt object");
        exit(EXIT_FAILURE);
    }
   
    wt->ca = (Word16*) malloc(size * sizeof(Word16));
    wt->cd = (Word16*) malloc(size * sizeof(Word16));
    wt->size = size;

    if (wt->ca == NULL){
        printf("error in allocating memory for Ca coefficients in the modwt object");
        free(wt->cd);
        free(wt);
        exit(EXIT_FAILURE);
    }
    if(wt->cd == NULL){
        printf("error in allocating memory for Cd coefficients in the modwt object");
        free(wt->ca);
        free(wt);
        exit(EXIT_FAILURE);
    }

    // iinitialize the object data with zeros
    for (long i = 0; i < size; i++) {
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
        printf("Error allocating memory for imodwt object");
        exit(EXIT_FAILURE);
    }
   
    wt->inv = (Word16*) malloc(size * sizeof(Word16));
    wt->size = size;

    if (wt->inv == NULL){
        printf("error in allocating memory for inv coefficients in the imodwt object");
        free(wt);
        exit(EXIT_FAILURE);
    }

    // iinitialize the object data with zeros
    for (long i = 0; i < size; i++) {
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

m_level_modwt_obj* init_m_level_modwt_objet(long size, Word16 levels){

    long i = 0;

    m_level_modwt_obj* wt = (m_level_modwt_obj*) malloc(sizeof(m_level_modwt_obj));
    if(wt == NULL){
        printf("Error allocating memory for multilevel modwt object");
        exit(EXIT_FAILURE);
    }
   
    wt->ca = (Word16*) malloc(size * sizeof(Word16));
    wt->cd = (Word16*) malloc(size * levels * sizeof(Word16));
    wt->inv = (Word16*) malloc(size * sizeof(Word16));
    
    wt->size = size;
    wt->levels =  levels;

    if (wt->ca == NULL){
        printf("error in allocating memory for Ca coefficients in the m_level");
        free(wt->cd);
        free(wt->inv);
        free(wt);
        exit(EXIT_FAILURE);
    }
    if (wt->cd == NULL){
        printf("error in allocating memory for Cd coefficients in the m_level");
        free(wt->ca);
        free(wt->inv);
        free(wt);
        exit(EXIT_FAILURE);
    }
    if (wt->inv == NULL){
        printf("error in allocating memory for Inv coefficients in the m_level");
        free(wt->cd);
        free(wt->ca);
        free(wt);
        exit(EXIT_FAILURE);
    }

    // iinitialize the object data with zeros

    for (i = 0; i < size; i++) {
        wt->inv[i] = 0;
        wt->ca[i] = 0; 
    }
    
    for(i = 0; i < (size * levels); i++){
        wt->cd[i] = 0;
    }

    return wt;
}

void free_m_level_modwt(m_level_modwt_obj* wt){
    free(wt->ca);
    free(wt->cd);
    free(wt->inv);
    free(wt);
}

