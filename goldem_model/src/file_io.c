#include <stdio.h>
#include <stdlib.h>
#include "../include/file_io.h"

long get_file_size(char *filename,short data_size){
    FILE *file = fopen(filename, "rb");

    if (file == NULL){
        printf("Error in open the file.\n");
        return -1;
    }
    
    fseek(file,0,SEEK_END);

    long size = ftell(file);
    fclose(file);

    size = size / (data_size); // data_size is in bytes, convert for bits

    return size;
}

void free_pcm_object(pcm_file_obj p){
    free(p.data);
}

pcm_file_obj init_pcm_file_object(char *path){

    pcm_file_obj p;

    p.size = get_file_size(path,sizeof(short));//change here for other data sizes

    p.data = (short*)malloc(p.size * sizeof(short));

    if (p.data == NULL) {
        printf("Error in alloc memory(init_pcm_file_object).\n");
        exit(1);
    }

    return p;
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

pcm_file_obj read_pcm(char *path, pcm_file_obj p){
    //TODO: multiples chanels, multiples data size
    FILE * ptrArq;

    ptrArq = fopen(path,"rb");
    if(ptrArq == NULL){
        printf("Error in open the pcm file");
    }
        
    fread(p.data,sizeof(short),p.size,ptrArq);
    
    fclose(ptrArq);
    return p;
}
void whrite_pcm(char *path, short* w_data, long size){
    //TODO: multiples chanels, multiples data size
    FILE * ptrArq;

    ptrArq = fopen(path,"wb");
    if(ptrArq == NULL){
        printf("Error in open the pcm file");
    }
    
    fwrite(w_data,sizeof(short),size,ptrArq);
    fclose(ptrArq);
}
//TODO:

//short whrite_pcm()
//short read_wav()
//short whrite_wav()