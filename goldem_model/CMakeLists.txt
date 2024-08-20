cmake_minimum_required(VERSION 3.22.1)
project(modwt_den C)
add_executable(modwt_den ../src/main.c ../src/file_io.c ../src/modwt_denoising.c ../lib/bit_exact/basic_op.c )
include_directories(../include ../lib/bit_exact)
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/bin)

