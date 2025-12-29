// pywavegoden.c
#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <numpy/arrayobject.h>
#include <stdlib.h>
#include <string.h>

/* Inclua aqui os headers do seu projeto (ajuste paths conforme include_dirs) */
#include "modwt_transform_core.h"   // deve conter Word16, modwt_obj, init_modwt_object, free_modwt_object, modwt(...)
#include "threshold.h"             // deve conter thresholding(...)
#include "modwt_multiresolution.h"
#include "file_io.h"
#include "denoising.h"
#include "objects.h"

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

static PyObject* py_imodwt(PyObject *self, PyObject *args) {
    PyObject *ca_obj = NULL, *cd_obj = NULL, *g_obj = NULL, *h_obj = NULL;
    int level = 0;
    int coef_size = 0;

    if (!PyArg_ParseTuple(args, "OOOOii", &ca_obj, &cd_obj, &g_obj, &h_obj, &level, &coef_size)) {
        return NULL;
    }

    PyArrayObject *arr_ca = as_int16_array_readonly(ca_obj);
    PyArrayObject *arr_cd = as_int16_array_readonly(cd_obj);
    PyArrayObject *arr_g  = as_int16_array_readonly(g_obj);
    PyArrayObject *arr_h  = as_int16_array_readonly(h_obj);

    if (!arr_ca || !arr_cd || !arr_g || !arr_h) {
        Py_XDECREF(arr_ca); Py_XDECREF(arr_cd); Py_XDECREF(arr_g); Py_XDECREF(arr_h);
        PyErr_SetString(PyExc_TypeError, "Failed to convert ca/cd/g/h to numpy int16 arrays");
        return NULL;
    }

    npy_intp n_ca = PyArray_SIZE(arr_ca);
    npy_intp n_cd = PyArray_SIZE(arr_cd);
    if (n_ca <= 0 || n_cd <= 0 || n_ca != n_cd) {
        Py_DECREF(arr_ca); Py_DECREF(arr_cd); Py_DECREF(arr_g); Py_DECREF(arr_h);
        PyErr_SetString(PyExc_ValueError, "ca and cd must be non-empty arrays with same length");
        return NULL;
    }

    long size = (long) n_ca;
    Word16 *ca_data = (Word16*) PyArray_DATA(arr_ca);
    Word16 *cd_data = (Word16*) PyArray_DATA(arr_cd);
    Word16 *g_data  = (Word16*) PyArray_DATA(arr_g);
    Word16 *h_data  = (Word16*) PyArray_DATA(arr_h);

    /* criar objeto inverse modwt em C usando sua função init */
    imodwt_obj *iwt = init_inverse_modwt_object(size);
    if (iwt == NULL) {
        Py_DECREF(arr_ca); Py_DECREF(arr_cd); Py_DECREF(arr_g); Py_DECREF(arr_h);
        PyErr_SetString(PyExc_MemoryError, "init_inverse_modwt_object returned NULL");
        return NULL;
    }

    /* Chamar imodwt (pode ser custoso -> liberar GIL) */
    Py_BEGIN_ALLOW_THREADS
    imodwt(ca_data, cd_data, iwt, g_data, h_data, (Word16)level, (Word16)coef_size);
    Py_END_ALLOW_THREADS

    /* criar numpy array de saída e copiar iwt->inv */
    npy_intp dims[1];
    dims[0] = (npy_intp) iwt->size;

    PyObject *inv_array = PyArray_SimpleNew(1, dims, NPY_INT16);
    if (!inv_array) {
        free_inverse_modwt_object(iwt);
        Py_DECREF(arr_ca); Py_DECREF(arr_cd); Py_DECREF(arr_g); Py_DECREF(arr_h);
        PyErr_SetString(PyExc_MemoryError, "Could not allocate output numpy array for inverse");
        return NULL;
    }

    memcpy(PyArray_DATA((PyArrayObject*)inv_array), iwt->inv, iwt->size * sizeof(Word16));

    /* liberar objeto iwt */
    free_inverse_modwt_object(iwt);

    /* decref arrays de entrada */
    Py_DECREF(arr_ca);
    Py_DECREF(arr_cd);
    Py_DECREF(arr_g);
    Py_DECREF(arr_h);

    /* retornar inv_array (new reference) */
    return inv_array;
}

/* WaveGoden.modwt_dec(input, g, h, levels, coef_size) -> (ca, cd) */
static PyObject* py_modwt_dec(PyObject *self, PyObject *args) {
    PyObject *input_obj = NULL, *g_obj = NULL, *h_obj = NULL;
    int levels = 0;
    int coef_size = 0;

    if (!PyArg_ParseTuple(args, "OOOii",
                          &input_obj, &g_obj, &h_obj,
                          &levels, &coef_size)) {
        return NULL;
    }

    PyArrayObject *arr_in = as_int16_array_readonly(input_obj);
    PyArrayObject *arr_g  = as_int16_array_readonly(g_obj);
    PyArrayObject *arr_h  = as_int16_array_readonly(h_obj);

    if (!arr_in || !arr_g || !arr_h) {
        Py_XDECREF(arr_in); Py_XDECREF(arr_g); Py_XDECREF(arr_h);
        PyErr_SetString(PyExc_TypeError,
                        "Failed to convert input/g/h to numpy int16 arrays");
        return NULL;
    }

    npy_intp size = PyArray_SIZE(arr_in);
    if (size <= 0) {
        Py_DECREF(arr_in); Py_DECREF(arr_g); Py_DECREF(arr_h);
        PyErr_SetString(PyExc_ValueError,
                        "input array must have positive length");
        return NULL;
    }

    Word16 *input_data = (Word16*) PyArray_DATA(arr_in);
    Word16 *g_data     = (Word16*) PyArray_DATA(arr_g);
    Word16 *h_data     = (Word16*) PyArray_DATA(arr_h);

    /* criar objeto de decomposição */
    modwt_dec_obj *wt_m = init_modwt_dec_object((long)size, levels);
    if (!wt_m) {
        Py_DECREF(arr_in); Py_DECREF(arr_g); Py_DECREF(arr_h);
        PyErr_SetString(PyExc_MemoryError,
                        "init_modwt_dec_object returned NULL");
        return NULL;
    }

    /* chamar modwt_dec (liberar GIL) */
    Py_BEGIN_ALLOW_THREADS
    modwt_dec(input_data, wt_m, g_data, h_data,
              levels, (long)size, coef_size);
    Py_END_ALLOW_THREADS

    /* criar array ca (1D) */
    npy_intp ca_dims[1] = { size };
    PyObject *ca_array = PyArray_SimpleNew(1, ca_dims, NPY_INT16);

    /* criar array cd (2D: levels x size) */
    npy_intp cd_dims[2] = { levels, size };
    PyObject *cd_array = PyArray_SimpleNew(2, cd_dims, NPY_INT16);

    if (!ca_array || !cd_array) {
        Py_XDECREF(ca_array); Py_XDECREF(cd_array);
        free_modwt_dec_object(wt_m);
        Py_DECREF(arr_in); Py_DECREF(arr_g); Py_DECREF(arr_h);
        PyErr_SetString(PyExc_MemoryError,
                        "Could not allocate output numpy arrays");
        return NULL;
    }

    /* copiar dados */
    memcpy(PyArray_DATA((PyArrayObject*)ca_array),
           wt_m->ca,
           size * sizeof(Word16));

    memcpy(PyArray_DATA((PyArrayObject*)cd_array),
           wt_m->cd,
           size * levels * sizeof(Word16));

    /* liberar objeto C */
    free_modwt_dec_object(wt_m);

    /* decref entradas */
    Py_DECREF(arr_in);
    Py_DECREF(arr_g);
    Py_DECREF(arr_h);

    /* retornar (ca, cd) */
    PyObject *ret = PyTuple_New(2);
    PyTuple_SET_ITEM(ret, 0, ca_array);
    PyTuple_SET_ITEM(ret, 1, cd_array);

    return ret;
}

/* WaveGoden.modwt_rec(ca, cd, g, h, levels, coef_size) -> inv */
static PyObject* py_modwt_rec(PyObject *self,
                              PyObject *args,
                              PyObject *kwargs) {
    PyObject *ca_obj = NULL, *cd_obj = NULL;
    PyObject *g_obj = NULL, *h_obj = NULL;
    int levels = 0;
    int coef_size = 0;

    static char *kwlist[] = {
        "ca", "cd", "g", "h", "levels", "coef_size", NULL
    };

    if (!PyArg_ParseTupleAndKeywords(
            args, kwargs, "OOOOii", kwlist,
            &ca_obj, &cd_obj, &g_obj, &h_obj,
            &levels, &coef_size)) {
        return NULL;
    }

    PyArrayObject *arr_ca = as_int16_array_readonly(ca_obj);
    PyArrayObject *arr_cd = as_int16_array_readonly(cd_obj);
    PyArrayObject *arr_g  = as_int16_array_readonly(g_obj);
    PyArrayObject *arr_h  = as_int16_array_readonly(h_obj);

    if (!arr_ca || !arr_cd || !arr_g || !arr_h) {
        Py_XDECREF(arr_ca); Py_XDECREF(arr_cd);
        Py_XDECREF(arr_g);  Py_XDECREF(arr_h);
        PyErr_SetString(PyExc_TypeError,
                        "Failed to convert inputs to numpy int16 arrays");
        return NULL;
    }

    /* checagens de forma */
    if (PyArray_NDIM(arr_ca) != 1 || PyArray_NDIM(arr_cd) != 2) {
        PyErr_SetString(PyExc_ValueError,
                        "ca must be 1D and cd must be 2D (levels, size)");
        goto fail;
    }

    npy_intp size = PyArray_SIZE(arr_ca);
    npy_intp *cd_dims = PyArray_DIMS(arr_cd);

    if (cd_dims[0] != levels || cd_dims[1] != size) {
        PyErr_SetString(PyExc_ValueError,
                        "cd shape must be (levels, size)");
        goto fail;
    }

    Word16 *ca_data = (Word16*) PyArray_DATA(arr_ca);
    Word16 *cd_data = (Word16*) PyArray_DATA(arr_cd);
    Word16 *g_data  = (Word16*) PyArray_DATA(arr_g);
    Word16 *h_data  = (Word16*) PyArray_DATA(arr_h);

    /* criar objetos C */
    modwt_dec_obj *wt_dec =
        init_modwt_dec_object((long)size, levels);

    imodwt_obj *iwt =
        init_inverse_modwt_object((long)size);

    if (!wt_dec || !iwt) {
        PyErr_SetString(PyExc_MemoryError,
                        "Failed to allocate MODWT objects");
        goto fail_alloc;
    }

    /* copiar ca e cd para o objeto wt_dec */
    memcpy(wt_dec->ca, ca_data, size * sizeof(Word16));
    memcpy(wt_dec->cd, cd_data, size * levels * sizeof(Word16));

    /* chamar modwt_rec */
    Py_BEGIN_ALLOW_THREADS
    modwt_rec(wt_dec, iwt, g_data, h_data,
              levels, (long)size, coef_size);
    Py_END_ALLOW_THREADS

    /* criar array de saída */
    npy_intp dims[1] = { size };
    PyObject *inv_array = PyArray_SimpleNew(1, dims, NPY_INT16);

    if (!inv_array) {
        PyErr_SetString(PyExc_MemoryError,
                        "Failed to allocate output array");
        goto fail_alloc;
    }

    memcpy(PyArray_DATA((PyArrayObject*)inv_array),
           iwt->inv,
           size * sizeof(Word16));

    /* liberar objetos C */
    free_modwt_dec_object(wt_dec);
    free_inverse_modwt_object(iwt);

    Py_DECREF(arr_ca);
    Py_DECREF(arr_cd);
    Py_DECREF(arr_g);
    Py_DECREF(arr_h);

    return inv_array;

fail_alloc:
    if (wt_dec) free_modwt_dec_object(wt_dec);
    if (iwt) free_inverse_modwt_object(iwt);

fail:
    Py_XDECREF(arr_ca);
    Py_XDECREF(arr_cd);
    Py_XDECREF(arr_g);
    Py_XDECREF(arr_h);
    return NULL;
}


/* Métodos do módulo */
static PyMethodDef WaveGodenMethods[] = {
    {"modwt", (PyCFunction)py_modwt, METH_VARARGS,
     "modwt(input, g, h, level, coef_size) -> (ca, cd)"},

    {"imodwt", (PyCFunction)py_imodwt, METH_VARARGS,
     "imodwt(ca, cd, g, h, level, coef_size) -> inv"},

    {"modwt_dec", (PyCFunction)py_modwt_dec, METH_VARARGS,
     "modwt_dec(input, g, h, levels, coef_size) -> (ca, cd)\n\n"
     "cd is returned as a 2D array with shape (levels, size)."},
     
    {"modwt_rec", (PyCFunction)py_modwt_rec, METH_VARARGS | METH_KEYWORDS,
     "modwt_rec(ca, cd, g, h, levels, coef_size) -> inv\n\n"
      "Reconstruct signal from MODWT multiresolution coefficients."},

    {NULL, NULL, 0, NULL}
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
