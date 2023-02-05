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

#define sarraymax 35
#define sswap(ix1,ix2) {swap=sindex[ix1]; \
          sindex[ix1]=sindex[ix2]; \
          sindex[ix2]=swap;}
#define sstring(ix) sindex[ix] + sizeof(int)
#define sortstring(ix,offs) sindex[ix] + (sizeof(int) + offs)

char **sindex;
char *sarray[sarraymax];
int  sindxhi[sarraymax];
int  sarrayhi[sarraymax];

void R_screate(int func);
void snew(int index,char *string,int llen);
void sset(int index,PLstr string);
void R_sset(int func) ;
void R_sget(int func);
void R_sconc(int func);
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
void R_snumber(int func);
void slstr(int sname);
void R_slstr(int func) ;
void R_sselect(int func);
void R_smerge(int func) ;

#endif //BREXX_SARRAY_H
