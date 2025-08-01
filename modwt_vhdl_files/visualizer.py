import matplotlib.pyplot as plt
import numpy as np

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
    #para 2 niveis delay de 37
    #para 3 niveis delay de 77
    #para 4 niveis delay de 153
    #para 5 niveis delay de 301

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

    
# Exemplo de uso
saida = hex_to_int16('stimulus/saida.hex')
entrada = hex_to_int16('stimulus/sweep_20_4k_fs8k.hex')

plot_inout(entrada, saida, delay = delay(level = 5))
