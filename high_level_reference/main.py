import matplotlib.pyplot as plt
from scipy.io import wavfile
import numpy as np
import modwt_denoising as md
import utils

sample_rate, data = wavfile.read('../clean_audio_files/voice1.wav')
#sample_rate, data = wavfile.read('sweep_4k.wav')
noisy_input,noise = utils.noisy_data(data,5)

levels= 5
mother_wavelet = 'db5'
type_threshold = 'soft'

utils.SNR(data, noise)

out, ca, cd = md.w_denoising(noisy_input, mother_wavelet, levels, type_threshold)
wavfile.write('out.wav', sample_rate, out.astype(np.int16))
wavfile.write('noisy.wav', sample_rate, noisy_input.astype(np.int16))

utils.SDR(data,out)

plt.plot(out)
plt.show()