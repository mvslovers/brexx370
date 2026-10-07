//
// Created by PeterJ on 02.02.2023.
//

#ifndef BREXX_SARRAY_H
#define BREXX_SARRAY_H

/* -----------------------------------------------------------
 * String Array
 * -----------------------------------------------------------
 */
#include "lstring.h"

#define sarraymax 128
#define sswap(ix1,ix2) {swap=sindex[ix1]; \
          sindex[ix1]=sindex[ix2]; \
          sindex[ix2]=swap;}
#define sstring(ix) sindex[ix] + sizeof(int)
/* an entry as a string, '' for one never set (#172) */
#define sitem(ix) (sindex[ix] != NULL ? (const char *) sstring(ix) : "")
// fetch all string parameters of SARRAYs beginning with second parameter (is 1) (one is array index)
#define gets_all(delblank) {{int kint; for (kint = 1; kint < ARGN; kint++) {\
          if (((*((rxArg.a[kint]))).type) != LSTRING_TY)L2str(((rxArg.a[kint])));\
          ((*(rxArg.a[kint])).pstr)[((*(rxArg.a[kint])).len)] = '\0';\
          if ((*(rxArg.a[kint])).len==0) delblank=1;}}}
#define free_sitem(sname,from) {{int kint; for (kint = current; kint < sarrayhi[sname]; kint++) {\
            if (sindex[kint] == NULL) continue; FREE(sindex[kint]); sindex[kint] = NULL;}}}

#define move_sitem(current,ii) {if (current != ii) {if (sindex[current] == NULL) ; else FREE(sindex[current]); \
                               sindex[current] = sindex[ii]; sindex[ii] = NULL;}}
#define getRXVAR(into,varname,fromvar) { {int intix; \
            for (intix=fromvar-1; intix < ARGN; intix++) {\
                into[intix] = getIntegerV(varname, intix); \
                }                                    \
            }};

/* the string arrays themselves (rxsarray.c) */
extern char **sindex;
extern char *sarray[sarraymax];
extern int  sindxhi[sarraymax];
extern int  sarrayhi[sarraymax];

/* the string array functions S* (src/rxsarray.c, #302) */
void RxSArrayRegFunctions();

/* a string array number from the caller indexed sarray[] unchecked
 * (#302): get_snum() wants it inside the table, get_sname() also
 * created; error 40 otherwise. Lerror() does not return; the return is
 * for the reader (and the analysers). An element index ran past the
 * array as well (#172): get_sindex() wants 1 to the capacity of array
 * S. new_sarray() creates an array of n entries into N, error 40 when
 * the table is full. */
#define sarrayok(N)     ((N) >= 0 && (N) < sarraymax && sarray[N] != NULL)
#define get_snum(I,N)   { get_i0(I,N); \
                          if ((N) < 0 || (N) >= sarraymax) { Lerror(ERR_INCORRECT_CALL,0); return; } }
#define get_sname(I,N)  { get_i0(I,N); \
                          if (!sarrayok(N)) { Lerror(ERR_INCORRECT_CALL,0); return; } }
#define get_sindex(I,N,S) { get_i(I,N); \
                          if ((N) > sindxhi[S]) { Lerror(ERR_INCORRECT_CALL,0); return; } }
#define new_sarray(N,n) { (N) = sarray_new(n); if ((N) < 0) { \
                          Lfailure("String Array Stack stack full, no allocation occurred", "", "", "", ""); \
                          return; } }

/* sarray_new() makes an array of rows entries (at least 100) in the
 * first free slot and points sindex at it; -1 when the table is full.
 * The internal callers used R_screate(n), which took the caller's first
 * argument as the size when n was 0 (#172). sarray_room() grows array
 * sname to hold need entries, the new ones NULL, and points sindex at
 * it. */
int  sarray_new(int rows);
void sarray_room(int sname, int need);

void R_screate(int func);
void snew(int index,char *string,int llen);
void sset(int index,PLstr string);
void R_sset(int func) ;
void R_sget(int func);
void R_sswap(int func) ;
void R_sclc(int func) ;
void R_sfree(int func);
void R_slist(int func);
void bsort(int from,int to,int offset);
void sqsort(int first,int last, int offset,int level);
void sreverse(int sname) ;
void R_sqsort(int func) ;
void R_shsort(int func);
void R_sreverse(int func);
void R_sarray(int func) ;
void R_sread(int func);
void R_swrite(int func);
void R_ssearch(int func);
void R_schange(int func);
void R_scount(int func) ;
void R_sdrop(int func);
void R_ssubstr(int func);
void slstr(int sname);
void R_slstr(int func) ;
void R_sselect(int func);
void R_smerge(int func) ;

#endif //BREXX_SARRAY_H
