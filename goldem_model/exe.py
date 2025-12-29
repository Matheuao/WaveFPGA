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
import numpy as np
import matplotlib.pyplot as plt

def plot_modwt_coeffs(ca, cd, levels=None, title=None, figsize=(12, 2.5)):
    """
    Plota coeficientes MODWT (CA e CD) de forma estética.

    Parâmetros
    ----------
    ca : np.ndarray (N,)
        Coeficientes de aproximação final
    cd : np.ndarray (L, N)
        Coeficientes de detalhe por nível (L = número de níveis)
    levels : int, opcional
        Número de níveis a serem plotados (default: todos)
    title : str, opcional
        Título geral da figura
    figsize : tuple
        Tamanho base da figura (largura, altura por subplot)
    """

    ca = np.asarray(ca)
    cd = np.asarray(cd)

    if cd.ndim != 2:
        raise ValueError("cd deve ser um array 2D com shape (levels, N)")

    n_levels, N = cd.shape

    if levels is None or levels > n_levels:
        levels = n_levels

    total_plots = levels + 1  # CA + CDs
    fig, axes = plt.subplots(
        total_plots,
        1,
        sharex=True,
        figsize=(figsize[0], figsize[1] * total_plots)
    )

    if total_plots == 1:
        axes = [axes]

    # Plot CA (aproximação)
    axes[0].plot(ca, linewidth=1)
    axes[0].set_ylabel("CA")
    axes[0].grid(True, alpha=0.3)

    # Plot CDs (detalhes)
    for i in range(levels):
        axes[i + 1].plot(cd[i], linewidth=1)
        axes[i + 1].set_ylabel(f"CD {i+1}")
        axes[i + 1].grid(True, alpha=0.3)

    axes[-1].set_xlabel("Amostras")

    if title:
        fig.suptitle(title, fontsize=14)

    plt.tight_layout()
    if title:
        plt.subplots_adjust(top=0.95)

    plt.show()


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
#ca, cd = WG.modwt(input, g_int16, h_int16, level, coef_size)
#inv = WG.imodwt(ca,cd,g_int16,h_int16, level, coef_size)
#print("ca.shape =", ca.shape, "cd.shape =", cd.shape)

#plot_pcm(inv,8000)


ca, cd = WG.modwt_dec(input, g_int16, h_int16, 5, 10)

res = WG.modwt_rec(ca,cd,g_int16,h_int16,5,10)
plot_pcm(res,8000)

#print(ca.shape)      # (N,)
#print(cd.shape) 

#plot_modwt_coeffs(ca,cd)



