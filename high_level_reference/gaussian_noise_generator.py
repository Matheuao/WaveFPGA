import numpy as np
from scipy.io import wavfile
import math


def noisy_data(data, snr_val):
# Generate a noisy signal by adding white Gaussian noise to the clean signal.
# 
# Parameters:
#    data (array-like): The clean signal data.
#    snr_val (float): The desired SNR value for the resulting noisy signal.
#
# Returns:
#    array-like: The noisy signal with the specified SNR.
   

    snr_lin = 10**(snr_val/10)

    power_signal = np.mean(np.abs(data.astype(np.int64)) ** 2)
    var = power_signal / snr_lin
    noise = np.random.randn(data.size) * np.sqrt(var)

    noisy = data + noise 
    
    SNR = 10 * np.log10(np.mean(abs(data.astype(np.int64)**2)) / np.mean(abs(noise.astype(np.int64)**2)))
    print(f"SNR = {SNR}")
    return noisy 


sample_rate, data = wavfile.read('sweep_4k.wav')

out=np.zeros(data.size)

out = noisy_data(data,10.5) 

wavfile.write('sweep_noisy.wav', sample_rate, out.astype(np.int16))