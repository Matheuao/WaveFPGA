#include"../include/modwt_multiresolution.h"
/*
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
*/
//ca_cd inv all (component)
//whrite, return (config)

void multiresolution_write(Word16* in,
                           Word16* g,
                           Word16* h,
                           Word16 levels,
                           long input_size,
                           Word16 coef_size,
                           char* root_path,
                           char* component){
    
    int i = 0;
    char root[100];
    char ca_path[100];
    char cd_path[100];
    char inv_path[100];
    char buffer[3];
    char str_buffer[10];
    
    strcpy(root,root_path);
    
    //char* ca_path = strcat(root,"/ca");
    //char* cd_path = strcat(root,"/cd");
    //char* inv_path = strcat(root,"/inv");

    if (strcmp(component, "ca_cd") == 0){
        Word8 aux = 0;
        Word16 input_buffer[input_size];

        modwt_obj* wt = init_modwt_object(input_size); 

        for(Word16 level = 1; level<= levels; level ++){
            sprintf(str_buffer, "%d", level);
            
            // copying root path
            strcpy(ca_path, root);
            strcpy(cd_path, root);

            // concat the coefficient type
            strcat(ca_path,"/ca");
            strcat(cd_path,"/cd");
            
            // concat the decomposition level
            strcat(ca_path, str_buffer);
            strcat(cd_path, str_buffer);

            // concat the .pcm extension
            strcat(ca_path, ".pcm");
            strcat(cd_path, ".pcm");

            //in the end the strings pahts are like this: root/ca1.pcm
            
            if(aux == 0){ // in is used only in the first decomposition level
                modwt(in, wt, g, h, level, coef_size);
                aux = 1;
            }
            else{
            
                for(i = 0; i < input_size; i++){
                    input_buffer[i] = wt->ca[i];
                }
        
                modwt(input_buffer,wt, g, h, level, coef_size);
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