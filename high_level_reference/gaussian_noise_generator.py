import numpy as np
from scipy.io import wavfile
import math


def noisy_data(data, snr_val):

    snr_lin = 10**(snr_val/10)
    power_signal = np.mean(abs(data)**2)
    var = power_signal/snr_lin
    noise = np.random.randn(data.size) * math.sqrt(var)

    noisy = data + noise

    SNR = 10 * np.log10(np.mean(abs(data**2)) / np.mean(abs(noise**2)))

    print(f"SNR = {SNR}")
    return noisy 







sample_rate, data = wavfile.read('sweep_4k.wav')

out=np.zeros(data.size)

out = noisy_data(data,5) 

wavfile.write('sweep_noisy.wav', sample_rate, out.astype(np.int16))