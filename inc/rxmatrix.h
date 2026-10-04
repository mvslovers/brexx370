#ifndef BREXX_RXMATRIX_H
#define BREXX_RXMATRIX_H

/* the matrix functions M* (src/rxmatrix.c) */
void RxMatrixRegFunctions();
/* MFREE; func < 0 frees every matrix and integer array (RxMvsTerminate) */
void R_mfree(int func);

#endif /* BREXX_RXMATRIX_H */
