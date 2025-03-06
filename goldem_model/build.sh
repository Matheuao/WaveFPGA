#!/bin/bash

if [ ! -d "bin" ]; then
    mkdir bin
fi

gcc src/*.c lib/bit_exact/src/*.c -I include -I lib/bit_exact/include -o bin/modwt -lm

if [ $? -eq 0 ]; then
    echo "Compilation successful! The executable was generated in bin/modwt."

    echo -e "Runing the executable!\n"
    cd bin
    ./modwt
else
    echo "Compilation error!."
fi
