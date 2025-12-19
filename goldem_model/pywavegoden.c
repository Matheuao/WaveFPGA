// pywavegoden.c
#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <numpy/arrayobject.h>
#include <stdlib.h>
#include <string.h>

/* Inclua aqui os headers do seu projeto (ajuste paths conforme include_dirs) */
#include "modwt_transform_core.h"   // deve conter Word16, modwt_obj, init_modwt_object, free_modwt_object, modwt(...)
#include "threshold.h"             // deve conter thresholding(...)

/*
 Expectativa:
 - Word16 é um tipo inteiro de 16 bits (ex: typedef short Word16;)
 - init_modwt_object(long size) retorna modwt_obj* com campos ca (Word16*), cd (Word16*) e size
 - free_modwt_object(modwt_obj*)
 - void modwt( Word16* input, modwt_obj* wt, Word16* g, Word16* h, Word16 level, Word16 coef_size);
 - void thresholding(Word16* buffer, long size, char s_h, Word16 k, Word16 c);
*/

/* Helper para converter e verificar array numpy int16 (read-only) */
static PyArrayObject* as_int16_array_readonly(PyObject *obj) {
    return (PyArrayObject*) PyArray_FROM_OTF(obj, NPY_INT16, NPY_ARRAY_IN_ARRAY);
}

/* Helper para obter um array int16 mutável (inout) */
static PyArrayObject* as_int16_array_inout(PyObject *obj) {
    return (PyArrayObject*) PyArray_FROM_OTF(obj, NPY_INT16, NPY_ARRAY_INOUT_ARRAY);
}

/* WaveGoden.modwt(input, g, h, level, coef_size) -> (ca_array, cd_array)
   input, g, h: array-like (convertidos para numpy int16)
   level, coef_size: integers
*/
static PyObject* py_modwt(PyObject *self, PyObject *args) {
    PyObject *input_obj = NULL, *g_obj = NULL, *h_obj = NULL;
    int level = 0;
    int coef_size = 0;

    if (!PyArg_ParseTuple(args, "OOOii", &input_obj, &g_obj, &h_obj, &level, &coef_size)) {
        return NULL;
    }

    PyArrayObject *arr_in = as_int16_array_readonly(input_obj);
    PyArrayObject *arr_g  = as_int16_array_readonly(g_obj);
    PyArrayObject *arr_h  = as_int16_array_readonly(h_obj);

    if (!arr_in || !arr_g || !arr_h) {
        Py_XDECREF(arr_in); Py_XDECREF(arr_g); Py_XDECREF(arr_h);
        PyErr_SetString(PyExc_TypeError, "Failed to convert input/g/h to numpy int16 arrays");
        return NULL;
    }

    npy_intp n_elems = PyArray_SIZE(arr_in);
    if (n_elems <= 0) {
        Py_DECREF(arr_in); Py_DECREF(arr_g); Py_DECREF(arr_h);
        PyErr_SetString(PyExc_ValueError, "input array must have positive length");
        return NULL;
    }

    /* ponteiros C */
    Word16 *input_data = (Word16*) PyArray_DATA(arr_in);
    Word16 *g_data = (Word16*) PyArray_DATA(arr_g);
    Word16 *h_data = (Word16*) PyArray_DATA(arr_h);
    long size = (long) n_elems;

    /* criar objeto modwt em C usando sua função init */
    modwt_obj *wt = init_modwt_object(size);
    if (wt == NULL) {
        Py_DECREF(arr_in); Py_DECREF(arr_g); Py_DECREF(arr_h);
        PyErr_SetString(PyExc_MemoryError, "init_modwt_object returned NULL");
        return NULL;
    }

    /* Chamar modwt (pode ser custoso -> liberar GIL) */
    Py_BEGIN_ALLOW_THREADS
    modwt(input_data, wt, g_data, h_data, (Word16)level, (Word16)coef_size);
    Py_END_ALLOW_THREADS

    /* Criar numpy arrays de saída (int16) e copiar wt->ca / wt->cd */
    npy_intp dims[1];
    dims[0] = (npy_intp) size;

    PyObject *ca_array = PyArray_SimpleNew(1, dims, NPY_INT16);
    PyObject *cd_array = PyArray_SimpleNew(1, dims, NPY_INT16);

    if (!ca_array || !cd_array) {
        Py_XDECREF(ca_array); Py_XDECREF(cd_array);
        free_modwt_object(wt);
        Py_DECREF(arr_in); Py_DECREF(arr_g); Py_DECREF(arr_h);
        PyErr_SetString(PyExc_MemoryError, "Could not allocate output numpy arrays");
        return NULL;
    }

    /* copiar dados (assumindo Word16 == int16) */
    memcpy(PyArray_DATA((PyArrayObject*)ca_array), wt->ca, size * sizeof(Word16));
    memcpy(PyArray_DATA((PyArrayObject*)cd_array), wt->cd, size * sizeof(Word16));

    /* liberar o objeto wt (memória alocada internamente) */
    free_modwt_object(wt);

    /* decref dos arrays de entrada */
    Py_DECREF(arr_in);
    Py_DECREF(arr_g);
    Py_DECREF(arr_h);

    /* retornar (ca, cd) como tupla */
    PyObject *ret = PyTuple_New(2);
    if (!ret) {
        Py_DECREF(ca_array); Py_DECREF(cd_array);
        PyErr_SetString(PyExc_RuntimeError, "Could not build return tuple");
        return NULL;
    }
    PyTuple_SET_ITEM(ret, 0, ca_array);  /* tuple steals ref */
    PyTuple_SET_ITEM(ret, 1, cd_array);
    return ret;
}

/* WaveGoden.threshold(arr, s_h: str (single char), k: int, c: int) -> arr (same numpy array, modified in-place)
   Ex.: WaveGoden.threshold(a, 'h', 16, 3)
*/
/*
static PyObject* py_threshold(PyObject *self, PyObject *args) {
    PyObject *arr_obj = NULL;
    const char *s_h_str = NULL;
    int k = 0;
    int c = 0;

    if (!PyArg_ParseTuple(args, "Osii", &arr_obj, &s_h_str, &k, &c)) {
        return NULL;
    }

    if (!s_h_str || strlen(s_h_str) < 1) {
        PyErr_SetString(PyExc_ValueError, "s_h must be a char string (e.g. 'h' or 'a')");
        return NULL;
    }
    char s_h = s_h_str[0];

    PyArrayObject *arr = as_int16_array_inout(arr_obj);
    if (!arr) {
        PyErr_SetString(PyExc_TypeError, "Failed to convert array to writable numpy int16 array");
        return NULL;
    }

    long n = (long) PyArray_SIZE(arr);
    Word16 *data = (Word16*) PyArray_DATA(arr);

    /* Chamar thresholding (liberar GIL se operação custosa) */
   /*
    Py_BEGIN_ALLOW_THREADS
    thresholding(data, n, s_h, (Word16)k, (Word16)c);
    Py_END_ALLOW_THREADS
    
    /* Retornar o mesmo array (incrementar refcount pois queremos return new ref) */
    /*
    PyObject *ret = PyArray_Return(arr); /* returns new ref */
   // return ret;

//}


/* Métodos do módulo */
static PyMethodDef WaveGodenMethods[] = {
    {"modwt", (PyCFunction)py_modwt, METH_VARARGS,
     "modwt(input, g, h, level, coef_size) -> (ca_array, cd_array)\n\n"
     "input, g, h: array-like (numpy arrays of dtype int16 recommended). level, coef_size: int.\n"
     "Returns tuple (ca, cd) as numpy int16 arrays."},
    /* Se quiser reativar threshold, descomente:
    {"threshold", (PyCFunction)py_threshold, METH_VARARGS,
     "threshold(arr, s_h, k, c) -> arr\n\n"
     "Apply thresholding in-place on arr (int16 numpy array). s_h is a single-char string."},
    */
    {NULL, NULL, 0, NULL}  /* sentinel */
};

/* módulo */
static struct PyModuleDef wavegodenmodule = {
    PyModuleDef_HEAD_INIT,
    "WaveGoden",
    "Wrappers for MODWT functions (modwt) using native C implementation",
    -1,
    WaveGodenMethods
};

PyMODINIT_FUNC PyInit_WaveGoden(void) {
    PyObject *m;
    m = PyModule_Create(&wavegodenmodule);
    if (m == NULL) return NULL;
    /* inicializar NumPy C API */
    import_array();  /* obrigatório; se falhar, causa erro e return NULL */
    return m;
}
