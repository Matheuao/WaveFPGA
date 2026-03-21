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

| Parameter                | NDWT_v1              | NDWT_v2              |
|------------------------|---------------------|---------------------|
| Flow Status            | Successful          | Successful          |
| Quartus Version        | 23.1std.0 Build 991 | 23.1std.0 Build 991 |
| Top-level Entity       | transform_NDWT      | transform_NDWT      |
| Device                 | EP4CE75F29C7        | EP4CE75F29C7        |
| Family                 | Cyclone IV E        | Cyclone IV E        |
| Timing Model           | Final               | Final               |

---

### Resource Utilization

| Resource                        | NDWT_v1                  | NDWT_v2        |
|---------------------------------|--------------------------|----------------|
| Logic Elements                  | 1,659 / 75,408 (2%)      | 1,974          |
| Registers                       | 604                      | 1,218          |
| Pins                            | 50 / 427 (12%)           | 50             |
| Virtual Pins                    | 0                        | 0              |
| Memory Bits                     | 0 / 2,810,880 (0%)       | 0              |
| Embedded Multipliers (9-bit)    | 0 / 400 (0%)             | 0              |
| PLLs                            | 0 / 4 (0%)               | 0              |

---

### Timing Results (Slow 1200mV, 85°C Model)

| Metric            | NDWT_v1   | NDWT_v2   |
|-------------------|-----------|-----------|
| Fmax              | 96.04 MHz | 106.56 MHz|
| Setup Slack       | 0.588 ns  | 1.616 ns  |
| Setup TNS         | 0.000 ns  | 0.000 ns  |
| Hold Slack        | 0.434 ns  | 0.431 ns  |
| Hold TNS          | 0.000 ns  | 0.000 ns  |

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

