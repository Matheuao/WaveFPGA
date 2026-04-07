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

## Performance Benchmarks

Only the first level of the NDWT was synthesized. The same SDC constraint file was used in all tests, with no timing violations observed.

### Design Overview

|  |  |
| :--- | :--- |
| **Flow Status**            | Successful          |
| **Quartus Version**        | 23.1std.0 Build 991 | 
| **Top-level Entity**       | transform_NDWT      | 
| **Device**                 | EP4CE115F29C7       | 
| **Family**                 | Cyclone IV E        | 
| **Timing Model**           | Final               | 

For all the tests: W1=W2=16, coefficient_size = 10
---

### Resource Utilization
#### NDWT Direct Transform (n_delay = 1):

| **OPTIMIZATION**                    | None                     | None           | Shared_multipliers |
| :---: | :---: | :---: | :---: |
| **PIPELINE_STAGES**                 | 0                        | 1              | 0             |
| Logic Elements                  | 1,689 / 114,480 ( 1 % )  | 1,913          | 1387          |
| Registers                       | 604                      | 1,218          | 620           |
| Pins                            | 51 / 529 (10%)           | 51             | 51            |
| Virtual Pins                    | 0                        | 0              | 0             |
| Memory Bits                     | 0 / 3,981,312 ( 0 % )    | 0              | 0             |
| Embedded Multipliers (9-bit)    | 0 / 532 ( 0 % )          | 0              | 0             |
| PLLs                            | 0 / 4 ( 0 % )            | 0              | 0             |

---

### Timing Results (Slow 1200mV, 85°C Model)
| **OPTIMIZATION**      | None      | None      | Shared_multipliers |
| :---: | :---: | :---: | :---: |
| **PIPELINE_STAGES**   | 0         | 1         | 0         |
| Fmax              | 96.01 MHz | 105.39 MHz| 101.77 MHz|
| Setup Slack       | 0.584 ns  | 1.511 ns  | 1.174 ns  |
| Setup TNS         | 0.000 ns  | 0.000 ns  | 0.000 ns  |
| Hold Slack        | 0.634 ns  | 0.427 ns  | 0.637 ns  |
| Hold TNS          | 0.000 ns  | 0.000 ns  | 0.000 ns  |

---

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

