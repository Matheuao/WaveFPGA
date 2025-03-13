import utils as ut
import numpy as np
from scipy.io import wavfile

data_path = "../input_output_data/clean_audio_files/guitar4.wav"
out_path = "../input_output_data/test_files/guitar4_snr10.wav"

sample_rate, data = wavfile.read(data_path)
noisy, noise = ut.noisy_data(data, 10)


wavfile.write(out_path, sample_rate, noisy.astype(np.int16))