# setup.py
from setuptools import setup, Extension
import glob
import os
import io
import re

def collect_c_sources():
    # arquivos principais do seu projeto + wrapper
    patterns = [
        'pydenoiser.c',            # seu wrapper (obrigatório)
        'src/*.c',                 # código fonte do projeto
        'lib/bit_exact/src/*.c',   # fontes da lib externa
    ]
    files = []
    for p in patterns:
        files.extend(glob.glob(p))
    # remover duplicatas e normalizar
    files = sorted(set(os.path.normpath(f) for f in files))
    # Excluir arquivos que contenham uma função main (evita conflitos de símbolo main)
    filtered = []
    main_re = re.compile(r'\bint\s+main\s*\(')
    for f in files:
        try:
            with io.open(f, 'r', encoding='utf-8', errors='ignore') as fh:
                content = fh.read(4096)  # ler início do arquivo é suficiente na maioria dos casos
                if main_re.search(content):
                    print("setup.py: excluindo (contém main) ->", f)
                    continue
        except Exception:
            # se houve problema lendo, incluímos o arquivo (falhas de leitura não decisivas)
            pass
        filtered.append(f)
    return filtered

sources = collect_c_sources()

# include dirs (igual ao seu comando gcc)
include_dirs = [
    'include',
    'lib/bit_exact/include',
]

# Compilar como C; linkar com libm (-lm)
denoiser_module = Extension(
    name='denoiser',
    sources=sources,
    include_dirs=include_dirs,
    libraries=['m'],                 # link libm (math)
    extra_compile_args=['-O3', '-fPIC'],
    extra_link_args=[],              # geralmente não precisa de '-lm' aqui pois libraries=['m'] já cobre
    language='c',
)

setup(
    name='denoiser',
    version='0.1.0',
    description='Python wrapper for C denoising (modwt) implementation',
    ext_modules=[denoiser_module],
)
