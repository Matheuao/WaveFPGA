#!/bin/bash

# Verifica se o diretório bin existe, se não, cria
if [ ! -d "bin" ]; then
    mkdir bin
fi

# Comando para compilar o projeto
gcc src/*.c lib/bit_exact/src/*.c -I include -I lib/bit_exact/include -o bin/modwt -lm

# Verifica se a compilação foi bem-sucedida
if [ $? -eq 0 ]; then
    echo "Compilation successful! The executable was generated in bin/modwt."
else
    echo "Compilation error!."
fi
