import matplotlib.pyplot as plt
import numpy as np
import os
import re

def noisy_data(data, snr_val):
# Generate a noisy signal by adding white Gaussian noise to the clean signal.
# 
# Parameters:
#    data (array-like): The clean signal data.
#    snr_val (float): The desired SNR value for the resulting noisy signal.
#
# Returns:
#    array-like: The noisy signal with the specified SNR.
#    array-like: The noise that contamined the clean signal
   

    snr_lin = 10**(snr_val/10)

    power_signal = np.mean(np.abs(data.astype(np.int64)) ** 2)
    var = power_signal / snr_lin
    noise = np.random.randn(data.size) * np.sqrt(var)

    noisy = data + noise 
    
    
    return noisy, noise

def SNR (clean, noise):
# Print the SNR (Signal to Noise Ratio) of the signal, also known as SNR in

    power_clean = np.mean(abs(clean.astype(np.int64)**2))
    power_noise = np.mean(np.abs(noise.astype(np.int64)**2))
    SNR = 10 * np.log10(power_clean / power_noise)
    print(f"SNR = {SNR}")

def SDR (clean, denoised):
    # Print the SDR (Signal to Distortion Ratio) of the signal, also known as SNR out
    distortion = clean - denoised
    power_clean = np.mean(abs(clean.astype(np.int64)**2))
    power_distortion = np.mean(abs(distortion.astype(np.int64)**2))
    SDR = 10 * np.log10(power_clean / power_distortion)
    print(f"SNR = {SDR}")

def hex_to_int16(caminho_arquivo):
    valores_16bits = []

    with open(caminho_arquivo, 'r') as f:
        linhas = [linha.strip() for linha in f if linha.strip()]
        
        for i in range(0, len(linhas) - 1):
            linha = linhas[i]
        
            hex_str = linha
            valor = int(hex_str, 16)
            
            if valor >= 32767:
                valor =  valor - 65538

            valores_16bits.append(valor)

        return valores_16bits
def delay(type = "modwt_multi_level", level=0, n_coeficient = 10):
    '''
    function that modeling the delay in each level of decompositon
    
    #para 2 niveis delay de 37
    #para 3 niveis delay de 77
    #para 4 niveis delay de 153
    #para 5 niveis delay de 301
    '''
    if type ==  "modwt_multi_level":
        d_previous = 0
        delay = 0

        for i in range(level,1,-1):
            index = i-2
            delay = 2 * (2 + ((2**index)*(n_coeficient-1))) 
            delay += d_previous
            d_previous = delay

    return delay + 15

def plot_inout(entrada, saida, delay = 15):

    # Converte para arrays numpy caso não sejam
    entrada = np.array(entrada)
    saida = np.array(saida)
    
    tam = len(saida)
    # Calcula a diferença
    diferenca = entrada[0:tam-delay] - saida[delay:tam]

    max_input = max(entrada)
    max_diference = max(diferenca)
    percent_dirence = (max_diference * 100) / max_input

    print(f"O maior valor da diferenca sinais:{max_diference}")
    print(f"maior valor do sainal de entrada:{max_input}")
    print(f"o erro equivale ha:{percent_dirence}% do sinal original")

    # Cria 3 subplots em colunas
    plt.figure(figsize=(12, 8))

    # Sinal de entrada
    plt.subplot(3, 1, 1)
    plt.plot(entrada[0:tam-delay], label='Entrada', color='blue')
    plt.ylabel('Valor')
    plt.title('Sinal de Entrada')
    plt.grid(True)

    # Sinal de saída
    plt.subplot(3, 1, 2)
    plt.plot(saida[delay:tam], label='Saída', color='green')
    plt.ylabel('Valor')
    plt.title('Sinal de Saída')
    plt.grid(True)

    # Diferença (Entrada - Saída)
    plt.subplot(3, 1, 3)
    plt.plot(diferenca, label='Diferença', color='red')
    plt.xlabel('Índice')
    plt.ylabel('Valor')
    plt.title('Diferença (Entrada - Saída)')
    plt.grid(True)

    plt.tight_layout()
    plt.show()

def denoising_tb(in_path = 'stimulus/sweep_20_4k_fs8k.hex', 
           out_path = 'stimulus/reconstruction_out.hex',
           levels = 5):


    saida = hex_to_int16(out_path)
    entrada = hex_to_int16(in_path)

    plot_inout(entrada, saida, delay = delay(level = levels))

def NDWT_reconstruction_tb(in_path = 'stimulus/sweep_20_4k_fs8k.hex', 
           out_path = 'stimulus/reconstruction_out.hex',
           levels = 5):


    saida = hex_to_int16(out_path)
    entrada = hex_to_int16(in_path)

    plot_inout(entrada, saida, delay = delay(level = levels))

def NDWT_decomposition_tb(stimulus_path = "stimulus"):
    """
    Lê e plota os coeficientes Ca_i e Cd_i contidos em stimulus_path.
    Espera arquivos no formato: Ca_1.hex, Cd_1.hex, Ca_2.hex, Cd_2.hex, ...
    """

    # Regex para identificar Ca_i e Cd_i
    pattern = re.compile(r'(Ca|Cd)_(\d+)\.hex')

    Ca_files = {}
    Cd_files = {}

    # Varre o diretório
    for fname in os.listdir(stimulus_path):
        match = pattern.match(fname)
        if match:
            kind, level = match.groups()
            level = int(level)
            full_path = os.path.join(stimulus_path, fname)

            if kind == 'Ca':
                Ca_files[level] = full_path
            else:
                Cd_files[level] = full_path

    levels = sorted(set(Ca_files.keys()) | set(Cd_files.keys()))
    n_levels = len(levels)

    if n_levels == 0:
        raise RuntimeError("Nenhum arquivo Ca_i ou Cd_i encontrado.")

    # Cria figura
    fig, axes = plt.subplots(
        n_levels, 2,
        figsize=(14, 2.5 * n_levels),
        sharex=False
    )

    if n_levels == 1:
        axes = np.array([axes])  # garante indexação consistente

    for i, level in enumerate(levels):
        # --- Ca ---
        if level in Ca_files:
            Ca = hex_to_int16(Ca_files[level])
            axes[i, 0].plot(Ca)
            axes[i, 0].set_title(f'Ca – Nível {level}')
            axes[i, 0].set_ylabel('Amplitude')
            axes[i, 0].grid(True)
        else:
            axes[i, 0].text(0.5, 0.5, 'Ausente', ha='center', va='center')
            axes[i, 0].set_title(f'Ca – Nível {level}')

        # --- Cd ---
        if level in Cd_files:
            Cd = hex_to_int16(Cd_files[level])
            axes[i, 1].plot(Cd)
            axes[i, 1].set_title(f'Cd – Nível {level}')
            axes[i, 1].grid(True)
        else:
            axes[i, 1].text(0.5, 0.5, 'Ausente', ha='center', va='center')
            axes[i, 1].set_title(f'Cd – Nível {level}')

    axes[-1, 0].set_xlabel('Índice')
    axes[-1, 1].set_xlabel('Índice')

    fig.suptitle('Coeficientes da Decomposição Wavelet', fontsize=16)
    plt.tight_layout(rect=[0, 0, 1, 0.97])
    plt.show()


#plot_wavelet_coeffs()
denoising_tb()