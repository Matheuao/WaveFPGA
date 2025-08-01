# Wavelet Denoising on FPGA

This repository contains the implementation of wavelet-based noise reduction techniques on FPGA for audio signal denoising. The full study, including methodology, experimental results, and discussion, is available in the following paper:

[Audio Denoising with DWT/MODWT and FPGA Implementation](https://doi.org/10.14209/sbrt.2024.1571036715)

## Repository Structure

- `goldem_model/`  
  C implementation of the MODWT algorithm with bit-exact behavior, matching the hardware implementation.

- `high_level_reference/`  
  Python implementation of the MODWT in floating point, used as a high-level reference model.

- `input_output_data/`  
  Audio `.wav` files used for validation and testing across different stages of the project.

- `modwt_vhdl_files/`  
  VHDL files containing the digital design of the MODWT implemented for FPGA.

- `old_vhd/`  
  Legacy VHDL files retained for reference purposes, not currently used in the project.

## Citation

If you use this work in your research or publications, please cite the following paper:

```bibtex
@inproceedings{Oliveira_2024,
    author = {Oliveira, Matheus and Gontijo, Walter and Noceti Filho, Sidnei and Batista, Eduardo},
    booktitle = {Anais do XLII Simpósio Brasileiro de Telecomunicações e Processamento de Sinais (SBrT)}, 
    year = {2024},
    address ={Belém, Brasil},
    month = {Oct},
    pages = {1-5},
    url = {https://doi.org/10.14209/sbrt.2024.1571036715},
    title = {Denoising de Áudio com DWT/MODWT e Implementação em FPGA},
    doi = {10.14209/sbrt.2024.1571036715}
    }
```

