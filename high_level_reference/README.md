
# High-Level Reference Model (Python)

This directory provides a floating-point reference implementation of the MODWT-based audio denoising algorithm in Python. It serves as a high-level model for validation and comparison against the bit-exact C and VHDL implementations.

## Requirements

- Python 3.7 or higher  
- Install dependencies via:

```bash
pip install -r requirements.txt
````

*(Typical dependencies include `numpy`, `scipy`, and `pywt`.)*

## Usage

To run the reference model, execute:

```bash
python main.py
```

By default, `main.py` will:

1. Load an input `.wav` file (configured in the script or via command-line arguments).
2. Apply the MODWT denoising algorithm.
3. Save the denoised output and generate diagnostic plots.

## Module Overview

* `modwt_denoising.py`
  Contains the core implementation of the MODWT denoising algorithm, including wavelet decomposition, thresholding, and reconstruction steps.

* `main.py`
  Orchestrates I/O, calls functions from `modwt_denoising.py`, and handles result saving and plotting.

## Citation

When using this reference model in your work, please cite:

```bibtex
@inproceedings{Oliveira_2024,
  author    = {Oliveira, Matheus and Gontijo, Walter and Noceti Filho, Sidnei and Batista, Eduardo},
  title     = {Audio Denoising with DWT/MODWT and FPGA Implementation},
  booktitle = {Proceedings of the XLII Brazilian Symposium on Telecommunications and Signal Processing (SBrT)},
  year      = {2024},
  address   = {Belém, Brazil},
  month     = {Oct},
  pages     = {1--5},
  url       = {https://doi.org/10.14209/sbrt.2024.1571036715},
  doi       = {10.14209/sbrt.2024.1571036715}
}
```

---

For questions, suggestions, or contributions, please open an issue or pull request in the main repository.

```

