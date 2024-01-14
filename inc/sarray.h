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
#define sortstring(ix,offs) sindex[ix] + (sizeof(int) + offs)
// fetch all string parameters of SARRAYs beginning with second parameter (is 1) (one is array index)
#define gets_all(delblank) {{int kint; for (kint = 1; kint < ARGN; kint++) {\
          if (((*((rxArg.a[kint]))).type) != LSTRING_TY)L2str(((rxArg.a[kint])));\
          ((*(rxArg.a[kint])).pstr)[((*(rxArg.a[kint])).len)] = '\0';\
          if ((*(rxArg.a[kint])).len==0) delblank=1;}}}
#define free_sitem(sname,from) {{int kint; for (kint = current; kint < sarrayhi[sname]; kint++) {\
            if (sindex[kint] == NULL) continue; FREE(sindex[kint]); sindex[kint] = NULL;}}}

#define move_sitem(current,ii) {if (current != ii) {if (sindex[current] == NULL) ; else FREE(sindex[current]); \
                               sindex[current] = sindex[ii]; sindex[ii] = NULL;}}

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
