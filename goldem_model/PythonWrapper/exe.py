# test_denoiser.py
import denoiser
import os

# caminhos de exemplo (troque pelos seus arquivos)
in_path = "../../input_output_data/clean_audio_files_pcm/sweep_4k.pcm"   # exemplo; ajuste conforme seu formato/uso
out_path = "../../input_output_data/clean_audio_files_pcm/teste_wrapper.pcm"

if not os.path.exists(in_path):
    print("Arquivo de entrada não existe:", in_path)
else:
    print("Chamando denoising...")
    denoiser.denoising(in_path, out_path)
    print("Pronto. Saída escrita em:", out_path)
