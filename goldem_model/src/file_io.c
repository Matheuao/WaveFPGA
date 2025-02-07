#include <stdio.h>
#include <stdlib.h>
#include "../include/file_io.h"

long get_file_size(char *filename,short data_size){
    /* 
        This function retrieves the size of a file (such as a PCM file) 
        in terms of the number of samples. The 'data_size' parameter 
        should represent the size of the data type in bytes (e.g., sizeof(short)) 
        to ensure an accurate result. The function calculates the total 
        number of samples based on the file size and the provided data size.

        Example usage:
        p->size = get_file_size(path, sizeof(short));

        This function opens the file, seeks to the end to determine its size, 
        and then calculates the number of samples by dividing the total size by the data size.
    */

    FILE *file = fopen(filename, "rb");

    if (file == NULL){
        printf("Error opening the file.\n");
        return -1;
    }
    
    fseek(file,0,SEEK_END);

    long size = ftell(file);
    fclose(file);

    size = size / (data_size); // data_size is in bytes, convert for bits

    return size;
}

pcm_file_obj* init_pcm_file_object(char *path){
    /*Initialization of a 16 bit pcm file object*/

    pcm_file_obj *p = (pcm_file_obj*) malloc(sizeof(pcm_file_obj));
    if(p == NULL){
        printf("Error allocating memory for pcm file object\n");
        exit(EXIT_FAILURE);
    }

    p->size = get_file_size(path, sizeof(short));//change here for other data sizes

    p->data = (short*)malloc(p->size * sizeof(short));

    if (p->data == NULL) {
        free(p);
        printf("Error in allocating memory for data in the pcm file object.\n");
        exit(EXIT_FAILURE);
    }
    // iinitialize a pcm file object with zeros
    for (int i = 0; i < p->size; i++) {
        p->data[i] = 0;
    }

    return p;
}

void free_pcm_file_object(pcm_file_obj *p){

    if(p != NULL){
       // free object data
       free(p->data);
       // free the object itself
       free(p); 
    }

}
pcm_file_obj init_pcm_object(long size){
    pcm_file_obj p;
    p.size = size;

    p.data = (short*)malloc(size * sizeof(short));

    if (p.data == NULL) {
        printf("Error in alloc memory (init_pcm_object).\n");
        exit(1);
    }

    return p;
}

void free_pcm_object(pcm_file_obj p){
    free(p.data);
}

pcm_file_obj* read_pcm(char *path){
    /* 
    This function reads a PCM file and dynamically allocates the necessary 
    memory to store the file's data. Therefore, it is essential to free 
    the allocated memory for the 'file' object after use. To do so, use
    the code below:

    pcm_file_obj *file = read_pcm_file(path);
    free_pcm_file_obj(file);  // free the object
    
    */

    //TODO: multiples chanels, multiples data size
    
    FILE *ptrArq;

    ptrArq = fopen(path,"rb");
    if(ptrArq == NULL){
        printf("Error in open the pcm file");
    }

    pcm_file_obj *file = init_pcm_file_object(path);
        
    fread(file->data,sizeof(short),file->size,ptrArq);
    fclose(ptrArq);

    return file;
}
void whrite_pcm(char *path, short *w_data, long size){
    //TODO: multiples chanels, multiples data size
    FILE *ptrArq = fopen(path,"wb");

    if(ptrArq == NULL){
        fprintf(stderr, "Error opening the pcm file: %s\n", path);
        return;
    }

    if(w_data == NULL){
        fprintf(stderr, "Invalid pointer (NULL).\n");
        fclose(ptrArq);
        return;
    }

    size_t written = fwrite(w_data, sizeof(short), size, ptrArq);
    
    if (written != size) {
        fprintf(stderr, "Error in writing data. Expecting: %ld, writed: %zu\n", size, written);
    }

    fclose(ptrArq);
}
//TODO:
//short read_wav()
//short whrite_wav()