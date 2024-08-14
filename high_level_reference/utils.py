import numpy as np
import json
import pywt # just to get the coeficients in a json file


def get_coef_json(wavelet_name,coef_json_path):
# Get the mother wavelet coeficients and store in a json file
#
# Parameters:
#   wavelet_name(string), examples:'db', 'sym', 'coif'
#   coef_json_path(string), examples: 'coef_db.json'
#
    var = wavelet_name
    dados = {}

    for i in range(1,38): 
        var = wavelet_name + str(i)
        coef = pywt.Wavelet(var) 
        dados[var]=coef.dec_lo

    print(dados)    

    with open(coef_json_path, 'w', encoding='utf-8') as arquivo:
        json.dump(dados, arquivo, ensure_ascii=False, indent=4)



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

