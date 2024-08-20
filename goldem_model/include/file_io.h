#ifndef UTILS_H
#define UTILS_H

struct pcm_file_set{
    short *data;
    long size;
};
typedef struct pcm_file_set pcm_file_obj;

long get_file_size(char *filename, short data_size);

pcm_file_obj read_pcm(char *path, pcm_file_obj p);

pcm_file_obj init_pcm_file_object(char *path);

pcm_file_obj init_pcm_object(long size);

void free_pcm_object(pcm_file_obj p);

void whrite_pcm(char *path, short* w_data, long size);

#endif