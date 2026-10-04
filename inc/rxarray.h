#ifndef BREXX_RXARRAY_H
#define BREXX_RXARRAY_H

/*
 * The numeric array families: matrices (src/rxmatrix.c) and the integer,
 * bit and fixed-string arrays (src/rxiarray.c). Their tables, and the bounds
 * checks of #171 for the arrays.
 */
#define matrixmax 128
#define ivectormax 64
#define sfvectormax 16
#define svectormax 16

/* matrices (rxmatrix.c) */
extern double *matrix[matrixmax];
extern int    matrows[matrixmax], matcols[matrixmax], fmaxrows[matrixmax];
extern int    matrixname, curmatrixname, mdebug;

/* integer, bit and fixed-string arrays (rxiarray.c) */
extern int    *ivector[ivectormax], ivrows[ivectormax], iarrayhi[ivectormax],
              ivcols[ivectormax], ivnum;
extern char   *bitarray[ivectormax];
extern int    arrayrows[ivectormax];
extern char   *sfvector[sfvectormax];
extern int    sfvrows[sfvectormax], svslen[sfvectormax];

/* ----------------------------------------------------------------------------
 * Bounds of the integer, bit and fixed-string arrays (#171): an array number
 * must be inside its table and created, a row or index inside the array.
 * Anything else is Error 40 instead of an access past the array.
 * ----------------------------------------------------------------------------
 */
#define arrayerror          { Lerror(ERR_INCORRECT_CALL,0); return; }
#define get_ivname(I,N)     { get_i0(I,N); \
                              if ((N) < 0 || (N) >= ivectormax || ivector[N] == NULL) arrayerror }
#define check_ivrow(V,R)    { if ((R) < 1 || (R) > ivrows[V] * ivcols[V]) arrayerror }
#define check_imcell(V,R,C) { if ((R) < 1 || (R) > ivrows[V] || (C) < 1 || (C) > ivcols[V]) arrayerror }
#define get_bitname(I,N)    { get_i0(I,N); \
                              if ((N) < 0 || (N) >= ivectormax || bitarray[N] == NULL) arrayerror }
#define check_bitindex(A,X) { if ((X) < 1 || (X) > arrayrows[A]) arrayerror }
#define get_sfname(I,N)     { get_i0(I,N); \
                              if ((N) < 0 || (N) >= sfvectormax || sfvector[N] == NULL) arrayerror }
#define check_sfrow(V,R)    { if ((R) < 1 || (R) > sfvrows[V]) arrayerror }

#endif /* BREXX_RXARRAY_H */
