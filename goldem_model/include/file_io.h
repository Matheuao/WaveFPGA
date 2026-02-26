/*
-- ============================================================================
--  file_io.h
--
--  File input/output
--
--  Author       : Matheus Araújo de Oliveira
--  Organization : Federal University of Santa Catarina (UFSC)
--  Email        : matheusaop09@gmail.com
--  Last modified: 2026-02-25
--  Version      : 1.0
--  Description:
--  Deals with read/write pcm files.
--  TODO: extention to wav files.
--
--  License:
--    Free for academic and non-commercial research use.
--    Commercial use requires a separate commercial license agreement.
--    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
--
--  Copyright (c) 2026 Matheus Araújo de Oliveira
-- ============================================================================
*/

#ifndef UTILS_H
#define UTILS_H
#include <stdio.h>
#include <stdlib.h>

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