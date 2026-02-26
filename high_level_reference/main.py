"""
-- ============================================================================
--  main.py
--
--  Main file for the high reference
--
--  Author       : Matheus Araújo de Oliveira
--  Organization : Federal University of Santa Catarina (UFSC)
--  Email        : matheusaop09@gmail.com
--  Last modified: 2026-02-25
--  Version      : 1.0
--  Description:
--  Main file the for call fuctions.
--  TODO: incorporate this project into the golden model.
--
--  License:
--    Free for academic and non-commercial research use.
--    Commercial use requires a separate commercial license agreement.
--    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
--
--  Copyright (c) 2026 Matheus Araújo de Oliveira
-- ============================================================================
"""

import matplotlib.pyplot as plt
from scipy.io import wavfile
import numpy as np
import modwt_denoising as md
import utils

sample_rate, data = wavfile.read('../input_output_data/clean_audio_files/guitar1.wav')
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