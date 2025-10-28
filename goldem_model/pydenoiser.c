// pydenoiser.c
#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include "../include/denoising.h"

/* Wrapper simples para denoising(in_path, out_path, parameters*).
   Usa os parâmetros default (init_default_parameters).
   Assinatura Python: denoising(in_path: str, out_path: str) -> None
*/

static PyObject *py_denoising(PyObject *self, PyObject *args) {
    const char *in_path_c;
    const char *out_path_c;

    if (!PyArg_ParseTuple(args, "ss", &in_path_c, &out_path_c)) {
        return NULL; // PyArg_ParseTuple já setou exceção
    }

    parameters p;
    init_default_parameters(&p);

    /* free GIL */
    Py_BEGIN_ALLOW_THREADS
    denoising((char *)in_path_c, (char *)out_path_c, &p);
    Py_END_ALLOW_THREADS

    Py_RETURN_NONE;
}

static PyMethodDef DenoiserMethods[] = {
    {"denoising", (PyCFunction)py_denoising, METH_VARARGS,
     "denoising(in_path: str, out_path: str) -> None\n\n"
     "Reads PCM file in_path, performs denoising using default parameters\n"
     "and writes output to out_path."},
    {NULL, NULL, 0, NULL}
};


static struct PyModuleDef denoisermodule = {
    PyModuleDef_HEAD_INIT,
    "denoiser",   /* name of module */
    "Python wrapper for denoising function (C)", /* module doc */
    -1,
    DenoiserMethods
};

PyMODINIT_FUNC PyInit_denoiser(void) {
    return PyModule_Create(&denoisermodule);
}
