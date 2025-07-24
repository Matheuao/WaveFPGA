import matplotlib.pyplot as plt
import numpy as np

def ler_2bytes_por_vez(caminho_arquivo):
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

def plot_inout(entrada, saida, delay = 301):
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
saida = ler_2bytes_por_vez('saida.hex')
entrada = ler_2bytes_por_vez('sweep_20_4k_fs8k.hex')

plot_inout(entrada, saida)

