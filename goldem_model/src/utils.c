#include <stdio.h>
#include "../include/utils.h"

long get_file_size(const char *filename, const long unsigned int data_size){
    FILE *file = fopen(filename, "rb");

    if (file == NULL){
        printf("Error in open the file.\n");
        return -1;
    }
    
    fseek(file,0,SEEK_END);

    long size = ftell(file);
    fclose(file);

    size = size / data_size;

    return size;
}

//TODO:
//short read_pcm()
//short whrite_pcm()
//short read_wav()
//short whrite_wav()