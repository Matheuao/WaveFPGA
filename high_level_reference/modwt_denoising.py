# References: 
#   D. Percival and A. Walden, Wavelet Methods for Time Series Analysis,
#   ser. Cambridge Series in Statistical and Probabilistic Mathematics.
#   Cambridge University Press, 2000
#
import numpy as np 
import math 
import json

def modwt(input, g, h, level):
# Generate the direct MODWT (Maximun Overlap Discreate Wavelet Transform)
# using a piramidal algotithm
#
# Parameters:
#    input (array-like)
#    g (array-like): high-pass wavelets coeficients
#    h (array-like): low-pass wavelets coeficients
#    level(int) : level of decomposition of the signal
# Returns:
#    ca (array-like):(approximation) low frequencies present in the signal
#    cd (array-like):(detail) high frequencies present in the signal

    ca = np.zeros(input.size)
    cd = np.zeros(input.size)
    

    for t in range(input.size):
        u = t
        
        ca[t] =  h[0] * input[t]
        cd[t] = g[0] * input[t]

        for n in range(1, h.size):
            
            u -= 2**(level-1)
           
            if u < 0 :
                u = input.size - 1

            ca[t] += h[n] * input[u] 
            cd[t] += g[n] * input[u]  
            
    return ca, cd


def imodwt(ca, cd, g, h, level):
# Generate the inverse MODWT (Maximun Overlap Discreate Wavelet Transform)
# using a piramidal algotithm
#
# Parameters:
#    ca (array-like): the decomposed aproximation coeficients
#    cd (array-like): the decomposed detail coeficientes
#    g (array-like): high-pass wavelets coeficients
#    h (array-like): low-pass wavelets coeficients
#    level(int) : level of decomposition of the signal
# Returns:
#    out (array-like)

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
#obtain the wavelet coefficients and modify them for MODWT
 
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
# aply the Universal Tresholding in the coeficients
    out = np.zeros(d_j.size)
    tmp = np.zeros(d_j.size)
    MAD= (math.sqrt(2) * np.median(np.abs(d_j - np.median(d_j))))/0.6745
    #MAD = (math.sqrt(2) * np.median(np.abs(d_j)))/0.6745
    lambda_j = MAD * math.sqrt(math.log(d_j.size)/(2**(level-1))) 
    
    #lambda_j = MAD * math.sqrt((2 * MAD**2)/((2**level)*math.log(d_j.size)))
    #lambda_j = np.sqrt(2 * MAD**2 / 2**level * np.log(len(d_j)))
    match type_threshold:
        case 'hard':
            for i in range(d_j.size):
                if abs(d_j[i]) > lambda_j:
                    out[i]= d_j[i]
                else:
                    out[i] = 0
                
        case 'soft':
            for i in range(d_j.size):
                tmp[i] = abs(d_j[i]) - lambda_j
                tmp[i] = (tmp[i] + abs(tmp[i]))/2
                out[i] = np.sign(d_j[i]) * tmp[i]
            
            #tmp = np.abs(d_j) - lambda_j
            #tmp = (tmp + np.abs(tmp))/2
            #tmp = np.sign(d_j) * tmp 
                
                
        case default:
            out = 0
            
    return out


    
def w_denoising(input, mother_wavelet, levels, type_threshold):
# Performs the modwt denoising in a 1 dimension signal
    ca = np.zeros((levels, input.size))
    cd = np.zeros((levels, input.size))
    inv = np.zeros((levels, input.size))
    output = np.zeros(input.size)

    g, h = w_coef(mother_wavelet)
        
    ca[0, :],cd[0, :] = modwt(input, g, h, 1)
    cd[0,:] = threhsold(cd[0,:], type_threshold,1)
    
    for i in range(1, levels):
        ca[i, :], cd[i, :] = modwt(ca[i-1,:],g,h,i+1)
        cd[i,:] = threhsold(cd[i,:], type_threshold, i+1)    

    inv[4, :] = imodwt(ca[levels-1,:],cd[levels-1,:], g, h, levels)

    for i in range(levels-2, -1, -1):
        inv[i,:] = imodwt(inv[i+1,:],cd[i,:],g,h,i+1)
    
    output = inv[0,:]

    return output,ca,cd
