"""
-- ============================================================================
--  test.py
--
--  Test script cheat sheet
--
--  Author       : Matheus Araújo de Oliveira
--  Organization : Federal University of Santa Catarina (UFSC)
--  Email        : matheusaop09@gmail.com
--  Last modified: 2026-02-25
--  Version      : 1.0
--  Description:
--  Cheat sheet for test the implementation.
--
--  License:
--    Free for academic and non-commercial research use.
--    Commercial use requires a separate commercial license agreement.
--    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
--
--  Copyright (c) 2026 Matheus Araújo de Oliveira
-- ============================================================================
"""

import utils as ut
import numpy as np
from scipy.io import wavfile

data_path = "../input_output_data/clean_audio_files/guitar4.wav"
out_path = "../input_output_data/test_files/guitar4_snr10.wav"

sample_rate, data = wavfile.read(data_path)
noisy, noise = ut.noisy_data(data, 10)


wavfile.write(out_path, sample_rate, noisy.astype(np.int16))