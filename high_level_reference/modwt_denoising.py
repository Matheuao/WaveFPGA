# Author: Matheus A. de Oliveira
# References: 
#
#
#
import numpy as np 
import matplotlib.pyplot as plt
from scipy.io import wavfile
import math 
import json


def modwt(input, g, h, level):
    approximation = np.zeros(input.size)
    detail = np.zeros(input.size)
    

    for t in range(input.size):
        u = t
        
        approximation[t] =  h[0] * input[t]
        detail[t] = g[0] * input[t]

        for n in range(1, h.size):
            
            u -= 2**(level-1)
           
            if u < 0 :
                u = input.size - 1

            approximation[t] += h[n] * input[u] #low frequencies 
            detail[t] += g[n] * input[u]  #high frequencies 
            
    return approximation, detail

def imodwt(ca, cd, g, h, level):
    out = np.zeros(ca.size)

    for t in range(ca.size):
        u = t 

        out[t] = (h[0] * ca[t]) + (g[0] * cd[t])

        for n in range(1, h.size):
            u += 2**(level-1)
            
            if u > ca.size - 1:
                u = 0
            
            out[t] += (h[n] * ca[u]) + (g[n] * cd[u])

    return out


def w_coef(mother_wavelet):
    
    with open('coef_db.json', 'r') as json_file:
        coeficientes_carregados = json.load(json_file)
        low_coef = coeficientes_carregados[mother_wavelet]
    
    h = np.array(low_coef, dtype=float)
    g = np.zeros(h.size,dtype=float)
    for n in range(h.size): g[n]= ((-1)**(n+1) ) * h[g.size-n-1]

    h = h / math.sqrt(2)
    g = g / math.sqrt(2)

    return g, h

def threhsold(d_j, type_threshold, level):

    out = np.zeros(d_j.size)
    
    MAD= (math.sqrt(2) * np.median(abs(d_j - np.median(d_j))))

    lambda_j = MAD * math.sqrt(math.log(d_j.size)/(2**(level-1))) # rq 12 of the article

    match type_threshold:
        case 'hard':
            for i in range(d_j.size):
                if abs(d_j[i]) > lambda_j:
                    out[i]= d_j[i]
                else:
                    out[i] = 0
                
        case 'soft':
            for i in range(d_j.size):
                
                if d_j[i] > lambda_j:
                    out[i] = d_j[i] - lambda_j

                elif d_j[i] < lambda_j:
                    out[i] = d_j[i] + lambda_j

                elif abs(d_j[i]) == lambda_j:
                    out[i] = 0;

        case default:
            out = 0;
            
    return out


    
def w_denoising(input, mother_wavelet, levels, type_threshold):

    ca = np.zeros((levels, input.size))
    cd = np.zeros((levels, input.size))
    inv = np.zeros((levels, input.size))
    output = np.zeros(input.size)

    g, h = w_coef(mother_wavelet)
        
    ca[0, :],cd[0, :] = modwt(input, g, h, 1)
    
    for i in range(1, levels):
        ca[i, :], cd[i, :] = modwt(ca[i-1,:],g,h,i+1)    

    inv[4, :] = imodwt(ca[levels-1,:],cd[levels-1,:], g, h, levels)

    for i in range(levels-2, -1, -1):
        inv[i,:] = imodwt(inv[i+1,:],cd[i,:],g,h,i+1)
    
    output = inv[0,:]

    return output,ca,cd
"""
sample_rate, data = wavfile.read('sweep_4k.wav')
h, g = w_coef('db37')
ca1, cd1 = modwt(data, g, h, 1)
ca2, cd2 = modwt(ca1,g,h,2)
out1 = imodwt(ca2,cd2,g,h,2)
out2 = imodwt(out1,cd1,g,h,1)

wavfile.write('ca1.wav', sample_rate, ca1.astype(np.int16))
wavfile.write('cd1.wav', sample_rate, cd1.astype(np.int16))
wavfile.write('ca2.wav', sample_rate, ca2.astype(np.int16))
wavfile.write('cd2.wav', sample_rate, cd2.astype(np.int16))

wavfile.write('out1.wav', sample_rate, out1.astype(np.int16))
wavfile.write('out2.wav', sample_rate, out2.astype(np.int16))

plt.plot(out1)
plt.plot(data)
plt.show()

"""
sample_rate, data = wavfile.read('sweep_4k.wav')

levels= 5
mother_wavelet = 'db5'
type_threshold = 's'

#out, ca, cd = w_denoising(data, mother_wavelet, levels, type_threshold)
out = threhsold(data,'hardsd',1);

plt.plot(out)
plt.show()



## TODO
#implementar o threshold soft hard universal threhsold
#implementar funcoes de plot de dados
#checar o resultado do algoritmo com as funcoes em matlab e outras
#bibliotecas prontas
