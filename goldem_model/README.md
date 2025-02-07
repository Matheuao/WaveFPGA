para compilar basta ir até o diretório src e digitar o seguinte comando

gcc *.c ../lib/bit_exact/src/*.c -I ../include -I ../lib/bit_exact/include -o modwt -lm


//TODO:
//creat a struct whith the modwt coeficients and parameters
//
/* crate a modwt*/
/* create a imodwt*/
/* create a threhsold, sample by sample, exponential smothing*/
/* create delay function*/


---- fil_io ------

get_file_size -ok
read_pcm  - ok
whrite_pcm -ok
init_pcm_file_object -ok
free_pcm_file_object -ok

init_pcm_object
free_pcm_object

-----modwt_denoising----
init_modwt_obj
free_modwt_obj
modwt


tokei output 07/01/2025
===============================================================================
 Language            Files        Lines         Code     Comments       Blanks
===============================================================================
 C                      11         3718         1824         1472          422
 C Header                7          177          109           29           39
 CMake                  11          356          235           54           67
 D                       3          174          174            0            0
 JSON                    1         1482         1482            0            0
 Makefile                1          287          155           63           69
 Markdown                2           42            0           29           13
 Python                  3          242          120           56           66
 Plain Text              6          350            0          291           59
 TypeScript              2            4            4            0            0
 VHDL                   16         1510          860           69          581
 XML                     4          136          136            0            0
 YAML                    1          289          275            2           12
===============================================================================
 Total                  68         8767         5374         2065         1328                                                                     ===============================================================================