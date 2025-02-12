#include"../include/modwt_multiresolution.h"

modwt_mres_obj* modwt_multiresolution(Word16* in,
                                      Word16* g,
                                      Word16* h,
                                      Word16 levels,
                                      long input_size,
                                      Word16 coef_size,
                                      char* component,
                                      char* config){
    //código                            
}

//ca_cd inv all (component)
//whrite, return (config)

void multiresolution_write(Word16* in,
                           Word16* g,
                           Word16* h,
                           Word16 levels,
                           long input_size,
                           Word16 coef_size,
                           char* component){
   
    char* ca_path = "path";
    char* cd_path = "path";
    char* inv_path = "path";

    modwt_obj* wt;
    char str_buffer[10];

    if (strcmp(component, "ca_cd") == 0){
        Word8 aux = 0;
        Word16 input_buffer[input_size];

        for(Word16 level = 1; level<= levels; level ++){
            sprintf(str_buffer, "%d", level);
            strcat(ca_path, str_buffer);
            strcat(cd_path, str_buffer);
            
            if(aux = 0){ // in is used only in the first decomposition level
                //wt = modwt(in, g, h, level, input_size, coef_size);
            }
            else{
                //copy ca for the input buffer
                for(int i = 0; i < input_size; i++){
                    input_buffer[i] = wt->ca[i];
                }
                // free the wt object inside the function modwt
                // the wt object is recreated
                free_modwt_object(wt);
                //wt = modwt(input_buffer, g, h, level, input_size, coef_size);
            }        
            
            write_pcm(ca_path, wt->ca, wt->size);
            write_pcm(cd_path, wt->cd, wt->size);
        }
        free_modwt_object(wt);    
    }

    else if (strcmp(component, "inv") == 0){
        // write the inverse coefficients
    }
    else if(strcmp(component, "all") == 0){

    }
    else{
        // component does not correspond whith the possibles match's
    }

}
modwt_mres_obj* multiresolution_ret(Word16* in,
                                    Word16* g,
                                    Word16* h,
                                    Word16 levels,
                                    long input_size,
                                    Word16 coef_size,
                                    char* component){
    // código
}