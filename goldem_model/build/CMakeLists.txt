cmake_minimum_required(VERSION 3.10)

# Nome do projeto
project(modwt_den C)

# Defina a versão do C
set(CMAKE_C_STANDARD 99)

# Diretório de arquivos de cabeçalho
include_directories(..\\include)

# Diretório de bibliotecas externas
link_directories(..\\lib)

# Encontre todos os arquivos .c em src e test
file(GLOB_RECURSE SRC_FILES ../src/*.c)
file(GLOB_RECURSE TEST_FILES ../test/*.c)

# Adicionar os arquivos de origem do projeto
add_executable(modwt_den ${SRC_FILES})

set_target_properties(modwt_den PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/../bin)

# Vincular as bibliotecas externas se necessário
# target_link_libraries(meu_programa nome_da_biblioteca)

# Adicionar executável para testes
add_executable(tests ${TEST_FILES})

# Definir diretório de saída para o executável de testes
set_target_properties(tests PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/test_bin)

# Vincular as bibliotecas externas aos testes, se necessário
# target_link_libraries(tests nome_da_biblioteca)

# Opcional: Adicione um comando para rodar os testes
enable_testing()
add_test(NAME modwt_den_test COMMAND tests)