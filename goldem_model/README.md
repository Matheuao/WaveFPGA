# MODWT FPGA Denoising

This project provides a hardware implementation of audio denoising using wavelets (MODWT) on FPGA. The repository includes bit-exact C models, high-level Python references, and synthesizable VHDL modules for use in real-time or offline audio processing systems.

## Build Instructions

To compile the C-based golden model, run:

```bash
bash build.sh
````

The executable will be generated at:

```
bin/modwt
```

This binary processes input `.wav` files and outputs the denoised signal for validation and comparison.

## Future Work

* **Python Integration**: Automate simulation runs, plotting, and statistical analysis via Python scripting.
* **Windowed Processing**: Implement ping-pong buffer-based processing to handle long-duration signals (e.g., several minutes of audio) in limited-memory environments.
* **DWT Golden Model**: Extend the bit-exact reference implementation to support DWT in addition to MODWT.

## License

This project is open-source and intended for academic and research purposes. For licensing or reuse in commercial products, please contact the authors.

## Citation

If you use this work in your research, please cite:

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

For contributions or issues, feel free to open a pull request or create an issue on GitHub.



