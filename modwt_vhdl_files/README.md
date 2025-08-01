
# MODWT VHDL Implementation

This directory contains the synthesizable VHDL design files for the MODWT-based audio denoising algorithm, along with testbenches and a visualization script.

## Requirements

- GHDL (for VHDL elaboration & simulation)  
- GTKWave (for waveform viewing)  
- Python 3.7 or higher (for `visualizer.py`)  
- Python dependencies: install via  
  ```bash
  pip install numpy matplotlib scipy
````

## Simulation

To compile and run all VHDL sources and testbenches, execute:

```bash
bash run.sh
````

This script will:

1. Analyze and elaborate the design and testbench files.
2. Run simulations for each testbench in `testbench/`.
3. Generate `.ghw` waveform files in the working directory.

## Directory Structure

* `modwt_vhdl_files/`
  VHDL source files implementing the MODWT filter stages and data path.
* `testbench/`
  VHDL testbench files that instantiate the design under test and apply stimulus vectors.
* `visualizer.py`
  Python script to parse simulation output (`.ghw` or converted CSV) and plot input vs. output waveforms for analysis.

### Using the Visualizer

After running `run.sh`, generate CSV dumps from GHDL (if not automatic), then run:

```bash
python visualizer.py --input input_dump.csv --output output_dump.csv
```

This will display time-domain plots of the original and denoised signals.

## Future Extensions

* Add automated conversion from GHDL waveforms to CSV within `run.sh`.
* Integrate regression checks to validate denoising performance automatically.

## Citation

If you use this VHDL model in your research or projects, please cite:

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

For questions or contributions, open an issue or pull request in the main repository.

```

