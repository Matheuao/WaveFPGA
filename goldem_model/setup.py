# setup.py
from setuptools import setup, Extension
import glob
import os
import io
import re
import numpy

def collect_c_sources():
    # arquivos principais do seu projeto + wrapper
    patterns = [
        'pywavegoden.c',          # wrapper novo
        'src/*.c',                # código fonte do projeto
        'lib/bit_exact/src/*.c',  # fontes da lib externa
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
                content = fh.read(4096)
                if main_re.search(content):
                    print("setup.py: excluindo (contém main) ->", f)
                    continue
        except Exception:
            pass
        filtered.append(f)
    return filtered

sources = collect_c_sources()

include_dirs = [
    'include',
    'lib/bit_exact/include',
    numpy.get_include(),   # necessário para NumPy C API
]

# Se precisar linkar libs adicionais, adicione em libraries=[]
wavegoden_module = Extension(
    name='WaveGoden',
    sources=sources,
    include_dirs=include_dirs,
    libraries=['m'],                 # link libm (math)
    extra_compile_args=['-O3', '-fPIC'],
    extra_link_args=[],
    language='c',
)

setup(
    name='WaveGoden',
    version='0.1.0',
    description='Python wrapper for MODWT (modwt)(C implementation)',
    ext_modules=[wavegoden_module],
)
