# test_denoiser.py
import denoiser
import os

import numpy as np
import matplotlib.pyplot as plt

def plot_pcm(path, fs):
    data = np.fromfile(path, dtype=np.int16)
    t = np.arange(len(data)) / fs
    plt.plot(t, data)
    plt.xlabel("Tempo [s]")
    plt.ylabel("Amplitude")
    plt.title(f"Sinal PCM - {path}")
    plt.grid(True)
    plt.show()

# caminhos de exemplo (troque pelos seus arquivos)
in_path = "../input_output_data/clean_audio_files_pcm/sweep_4k.pcm"   # exemplo; ajuste conforme seu formato/uso
out_path = "../input_output_data/clean_audio_files_pcm/teste_wrapper.pcm"

denoiser.denoising(in_path, out_path)

result = plot_pcm(out_path, fs=8000)

