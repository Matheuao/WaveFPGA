# test_denoiser.py
# exemplo_modwt.py
import numpy as np
import WaveGoden as WG # type: ignore
import os

import matplotlib.pyplot as plt

def plot_pcm(data, fs):
    #data = np.fromfile(path, dtype=np.int16)
    t = np.arange(len(data)) / fs
    plt.plot(t, data)
    plt.xlabel("Tempo [s]")
    plt.ylabel("Amplitude")
    plt.title(f"Sinal PCM ")
    plt.grid(True)
    plt.show()

def read_pcm_mono(path, dtype=np.int16):
    """
    Lê um arquivo .pcm mono (raw) e retorna um numpy.ndarray 1D com o tipo especificado.
    dtype default: np.int16 (16-bit signed little-endian).
    """
    if not os.path.isfile(path):
        raise FileNotFoundError(f"Arquivo não encontrado: {path}")
    try:
        data = np.fromfile(path, dtype=dtype)
    except Exception as e:
        raise IOError(f"Erro ao ler {path}: {e}")
    return data

def write_pcm_mono(path, data, dtype=np.int16):
    """
    Escreve um numpy.ndarray 1D em formato .pcm raw com o dtype especificado.
    Não adiciona cabeçalho — formato raw.
    """
    arr = np.asarray(data, dtype=dtype)
    # garantir diretório
    os.makedirs(os.path.dirname(path), exist_ok=True)
    try:
        arr.tofile(path)
    except Exception as e:
        raise IOError(f"Erro ao escrever {path}: {e}")

# caminhos de exemplo (troque pelos seus arquivos)
in_path = "../input_output_data/clean_audio_files_pcm/sweep_4k.pcm"   # exemplo; ajuste conforme seu formato/uso
#out_path = "../input_output_data/clean_audio_files_pcm/teste_wrapper.pcm"

# exemplo: sinal simples
x = np.arange(0, 1024, dtype=np.int16)  # exemplo de input
# filtros g, h (exemplo simples) -> substitua pelos seus buffers (Word16)
#g = np.array([77, 291, -145, -1805, -2459, -75, 3207, 318, -1774, 77], dtype=np.int16)
#h = np.array([3710, 13959, 16782, 3207, -6014, -75, 1797, -145, -291, 77], dtype=np.int16)

g_hex = [
    0x004D, 0x0123, 0xFF6F, 0xF8FB, 0xFD15,
    0x15EE, 0x0C87, 0xBE72, 0x36A7, 0xF182
]

h_hex = [
    0x0E7E, 0x36A7, 0x418E, 0x0C87, 0xEA12,
    0xFD15, 0x0705, 0xFF6F, 0xFEDD, 0x004D
]

# Converte hex -> uint16 (sempre válido)
g_uint16 = np.array(g_hex, dtype=np.uint16)
h_uint16 = np.array(h_hex, dtype=np.uint16)

# Reinterpreta como int16 sem alterar bits
g_int16 = g_uint16.view(np.int16)
h_int16 = h_uint16.view(np.int16)

print("G int16:", g_int16)
print("H int16:", h_int16)


level = 1
coef_size = 10

input = read_pcm_mono(in_path)
ca, cd = WG.modwt(input, g_int16, h_int16, level, coef_size)
print("ca.shape =", ca.shape, "cd.shape =", cd.shape)



plot_pcm(ca,8000)



