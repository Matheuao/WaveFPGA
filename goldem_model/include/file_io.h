#ifndef UTILS_H
#define UTILS_H

typedef struct {
    short *data;
    long size;
}pcm_file_obj;

long get_file_size(char *filename, short data_size);

pcm_file_obj* read_pcm(char *path);

pcm_file_obj* init_pcm_file_object(char *path);

void free_pcm_file_object(pcm_file_obj *p);

void write_pcm(char *path, short *w_data, long size);

#endif