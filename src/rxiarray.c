/* -------------------------------------------------------------------------------------
 * Integer arrays (ICREATE, ISET, IGET, ..., the integer matrices IM*),
 * fixed-string arrays (SF*), BITARRAY, PRIME, and the conversions from a
 * string array S2IARRAY and S2HASH. Moved from rxmvs.c (#302).
 * -------------------------------------------------------------------------------------
 */
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <strings.h>
#include "rxiarray.h"
#include "rxarray.h"
#include "rexx.h"
#include "rxdefs.h"
#include "rxmvsext.h"
#include "lstring.h"
#include "lerror.h"
#include "sarray.h"

/* the integer, bit and fixed-string arrays; limits, the matrix tables
 * and the bounds checks of #171 are in rxarray.h */
int    *ivector[ivectormax],ivrows[ivectormax],iarrayhi[ivectormax], ivcols[ivectormax],ivnum=0;
char   *bitarray[ivectormax];
int    arrayrows[ivectormax];
char   *sfvector[sfvectormax];
int    sfvrows[sfvectormax],svslen[sfvectormax];

void R_bitarray(__unused int func) {
    int arrayname, rows, index, bytex, bitx, i, iv;
    get_s(1)
    LASCIIZ(*ARG1);
    Lupper(ARG_OWN(1));
    if (strcmp((const char *) ARG1->pstr, "CREATE") == 0) {
        get_i(2, rows);
        for (arrayname = 0; arrayname < ivectormax; ++arrayname) {
            if (bitarray[arrayname] == 0) break;
        }
        if (arrayname >= ivectormax) Lfailure("Bit Array stack full, no allocation occurred", "", "", "", "");
        arrayrows[arrayname] = rows;
        bitarray[arrayname] = MALLOC((rows + 7) / 8, "BitArray");  // one bit per element
        memset(bitarray[arrayname], 0, (rows + 7) / 8);
        if (bitarray[arrayname] == 0) Lfailure("Storage stack full, no allocation occurred", "", "", "", "");
        Licpy(ARGR, arrayname);
        return;
    } else if (strcmp((const char *) ARG1->pstr, "SET") == 0) {
        get_bitname(2, arrayname);
        iv = 1;
        get_i(3, index);
        check_bitindex(arrayname, index);
        if (ARGN == 4) {
            get_i0(4, iv);
            if (iv != 0 && iv != 1) iv = 1;
        }
        index--;
        bytex = index / 8;
        bitx = index % 8;
        if (iv == 1) bitarray[arrayname][bytex] = bitarray[arrayname][bytex] | (1 << bitx);
        else bitarray[arrayname][bytex] = bitarray[arrayname][bytex] & ~(1 << bitx);
    } else if (strcmp((const char *) ARG1->pstr, "DUMP") == 0) {
        get_bitname(2, arrayname);
        get_i(3, index);
        check_bitindex(arrayname, index);
        index--;
        bytex = index / 8;
        bitx = index % 8;
        printf("Dump of Array element %d, Bit contained in Byte %d position %d\n", index, bytex, bitx);
        for (i = 7; 0 <= i; i--) {
            printf("%c", (bitarray[arrayname][bytex] & (1 << i)) ? '1' : '0');
        }
        printf("\n");
        Licpy(ARGR, 0);
    } else if (strcmp((const char *) ARG1->pstr, "GET") == 0) {
        get_bitname(2, arrayname);
        get_i(3, index);
        check_bitindex(arrayname, index);
        index--;
        bitx=index%8;
        Licpy(ARGR, (bitarray[arrayname][index / 8] & (1 << bitx)) >> bitx);
    }
}
void R_sfcreate(__unused int func) {
    int vname, rows, slen;
    get_i(1,rows);
    get_i(2,slen);
    for (vname = 0; vname < sfvectormax; ++vname) {
        if (sfvector[vname] == 0) break;
    }
    if (vname >= sfvectormax) {
        vname = -8;
        goto sc8;
    }
    sfvrows[vname] = rows;
    svslen[vname] = slen+1;   // +1 for succeedign hex 0
    sfvector[vname] = (char *) MALLOC(rows * sizeof(char) * svslen[vname], "F-STRING Vector");
    memset(sfvector[vname], 0, rows * sizeof(char) * svslen[vname]);  // unset rows read as ""
    sc8:
    Licpy(ARGR,vname);
}
void R_sfset(__unused int func) {
    int vname,row,slen,offset;
    get_sfname(1,vname);
    get_i(2,row);
    check_sfrow(vname,row);
    slen=LLEN(*ARG3);
    if (slen>svslen[vname]-1) slen=svslen[vname]-1;
    offset=(row-1)*svslen[vname];
    memcpy(&sfvector[vname][offset], LSTR(*ARG3), slen);
    sfvector[vname][offset + slen] = '\0';
    Licpy(ARGR,0);
}
void R_sfget(__unused int func) {
    int vname,row;
    get_sfname(1,vname);
    get_i(2,row);
    check_sfrow(vname,row);
    Lscpy(ARGR,&sfvector[vname][(row - 1) * svslen[vname]]);
}
void R_sffree(__unused int func) {
    int vname;
    get_sfname(1,vname);
    FREE(sfvector[vname]);
    sfvector[vname] = NULL;
    Licpy(ARGR,0);
}
int sundaram(int iv,int lim,int one) {
    int j, i, k = 0, mid, current, xlim,bytex,bitx;
    char *noprime;
    xlim = (lim * 8);
    if (lim>1000000) xlim=xlim+lim;
    noprime= MALLOC((xlim + 1)/8, "Sundaram BitArray");
    memset(noprime,0,(xlim + 1)/8);

    mid = xlim / 2;
    for (j = 1; j <= mid; ++j) {
        for (i = 1; i <= j; ++i) {
            current = i + j + (2 * i * j);
            if (current > xlim) break;
            current--;
            bytex = current / 8;
            bitx = current % 8;
            noprime[bytex] = noprime[bytex] | (1 << bitx);
        }
    }
    if (one < 0) {
        i = 0;
        ivector[iv][i++] = 2;
        for (j = 1; j <= xlim; ++j) {
            bitx=(j-1)%8;
            current=(noprime[(j-1)/8] & (1 << bitx)) >> bitx;
            if (current == 1) continue;
            ivector[iv][i++] = j * 2 + 1;
            if (i >= lim) break;
        }
    } else {
        if (lim==1) i=2;     // sub prime 2, no need to go through table
        else {
            i = 1;
            for (j = 1; j <= xlim; ++j) {
                bitx=(j-1)%8;
                current=(noprime[(j-1)/8] & (1 << bitx)) >> bitx;
                if (current == 1) continue;
                if (++i < lim) continue;
                k = j * 2 + 1;
                break;
            }
            i = k;
        }
    }
    FREE(noprime);
    return i;
}
#define ivaddr(vname,row) ivector[vname][row-1]
#define imaddr(vname,row,col) ivector[vname][(row-1)*ivcols[vname]+(col-1)]

/* allocate an integer array of rows elements (at least one), -8 if the
 * table is full */
static int ivnew(int rows) {
    int vname;

    if (rows < 1) rows = 1;
    for (vname = 0; vname < ivectormax; ++vname) {
        if (ivector[vname] == NULL) break;
    }
    if (vname >= ivectormax) return -8;
    iarrayhi[vname] = 0;
    ivrows[vname] = rows;
    ivcols[vname] = 1;
    ivector[vname] = (int *) MALLOC(rows * sizeof(int), "INT Vector");
    return vname;
}

void R_icreate(__unused int func) {
    int vname,ii,jj,jm,jr,rows;
    char option=' ';

    get_i(1,rows);

    if (ARGN >1) option = l2u[(byte)LSTR(*ARG2)[0]];

    vname = ivnew(rows);
    if (vname < 0) goto ic8;
    if (option=='E') {
        iarrayhi[vname]=rows;
        for (ii = 0; ii < rows; ++ii) {
            ivector[vname][ii] = ii+1;
        }
    } else if (option=='N'){
        iarrayhi[vname]=rows;
        for (ii = 0; ii <rows; ++ii) {
            ivector[vname][ii] = 0;
        }
    } else if (option=='D'){
        jj=rows;
        iarrayhi[vname]=rows;
        for (ii = 0; ii <rows; ++ii, jj--) {
            ivector[vname][ii] = jj;
        }
    } else if (option=='F'){      // fibonacci
        ivector[vname][0] = 1;
        if (rows > 1) ivector[vname][1] = 1;
        iarrayhi[vname]=rows;
        for (ii = 2; ii <rows; ++ii) {
            if (ii<46) ivector[vname][ii] = ivector[vname][ii-2]+ivector[vname][ii-1];
            else ivector[vname][ii] =0;
        }
    } else if (option=='S') {
        iarrayhi[vname]=rows;
        for (ii = 0; ii <rows; ++ii) {
            ivector[vname][ii] = 0;
        }
        sundaram(vname,rows,-1);
    } else if (option=='P'){
        ivector[vname][0] = 2;
        ii=0;
        for (jj = 3; ; jj=jj+2) {
            for (jm = 0;jm<ii; ++jm) {
                jr=(int) ivector[vname][jm];
                if (jj%jr==0) goto isnoprim;
            }
            ii++;
            if (ii<ivrows[vname]) {
                ivector[vname][ii] = jj;
                iarrayhi[vname]=ii;
            }
            else break;
            isnoprim: continue;
        }
    }
    ic8:
    Licpy(ARGR,vname);
}
void R_iset(__unused int func) {
    int vname,row;
    get_ivname(1,vname);
    get_oiv(2, row, iarrayhi[vname] + 1);
    check_ivrow(vname,row);

    ivaddr(vname,row) = Lrdint(ARG3);
    if (row > iarrayhi[vname]) iarrayhi[vname]=row;
    Licpy(ARGR,0);
}

void
R_isearch(__unused int func) {
    int vname,value,ii,from;
    get_ivname(1,vname);
    value=Lrdint(ARG2);           // value can be negativ
    get_oiv(3,from,1);               // optional from parameter  -1, will be set by ivaddr macro
    Licpy(ARGR, 0) ;        // default
    if (from > iarrayhi[vname]) return;
    for (ii = from; ii <= iarrayhi[vname]; ii++) {
        if (ivaddr(vname, ii) == value) goto ifound;
    }
    return;                         // nothing found, return default 0
  ifound:
    Licpy(ARGR,ii);
}
void R_isearchnn(__unused int func) {
    int vname,ii,from;
    get_ivname(1,vname);
    get_oiv(2,from,1);            // optional from parameter  -1, will be set by ivaddr macro

    Licpy(ARGR, 0) ;     // default
    if (from > iarrayhi[vname]) return;
    for (ii = from; ii <= iarrayhi[vname]; ii++) {
        if (ivaddr(vname, ii) > 0) goto ifound;
    }
    return;                       // nothing found, return default 0
    ifound:
    Licpy(ARGR,ii);
}

void R_i2s(__unused int func) {
    int iname,ii,sname;
    get_ivname(1, iname);

    new_sarray(sname, iarrayhi[iname]);  // sindex points to it

    for (ii=0; ii < iarrayhi[iname]; ii++) {
        Licpy(ARGR,ivector[iname][ii]);
        L2STR(ARGR);
        LSTR(*ARGR)[LLEN(*ARGR)]=0;
        snew(ii,LSTR(*ARGR),-1);
    }
    sarrayhi[sname] = iarrayhi[iname];
    Licpy(ARGR,sname);
}

void R_imset(__unused int func) {
    int vname,row, col;
    get_ivname(1,vname);
    get_i(2, row);
    get_i(3, col);
    check_imcell(vname,row,col);

    imaddr(vname,row,col)=Lrdint(ARG4);
    Licpy(ARGR, imaddr(vname,row,col));

    row=row*ivcols[vname];
 //   if (row > iarrayhi[vname]) iarrayhi[vname]=row;
}

void R_imadd(__unused int func) {
    int vname,row, col;
    get_ivname(1,vname);
    get_i(2, row);
    get_i(3, col);
    check_imcell(vname,row,col);

    imaddr(vname,row,col) = imaddr(vname,row,col)+Lrdint(ARG4);
    Licpy(ARGR,imaddr(vname,row,col));

    row=row*ivcols[vname];
 //   if (row > iarrayhi[vname]) iarrayhi[vname]=row;

}

void R_imsub(__unused int func) {
    int vname,row, col;
    get_ivname(1,vname);
    get_i(2, row);
    get_i(3, col);
    check_imcell(vname,row,col);

    imaddr(vname,row,col) = imaddr(vname,row,col)-Lrdint(ARG4);
    Licpy(ARGR, imaddr(vname,row,col));

    row=row*ivcols[vname];
  //  if (row > iarrayhi[vname]) iarrayhi[vname]=row;
}

void R_imget(__unused int func) {
    int vname,row, col;
    get_ivname(1,vname);
    get_i(2, row);
    get_i(3, col);
    check_imcell(vname,row,col);

    Licpy(ARGR,imaddr(vname,row,col));
}

void R_iminfix(__unused int func) {
    int i1,i2,ii,rowcol;
    char mode;
    get_ivname(1,i1);
    get_ivname(2,i2);
    get_i(3,rowcol);
    get_modev(4,mode,'R');
    // the vector must fit the row (mode R) or the column of the matrix
    if (mode=='R') check_imcell(i1,rowcol,iarrayhi[i2])
    else           check_imcell(i1,iarrayhi[i2],rowcol)
    if (mode=='R')
         for (ii = 1; ii <= iarrayhi[i2]; ii++) {
             imaddr(i1, rowcol, ii) = (int) ivaddr(i2,ii);
         }
    else for (ii = 1; ii <= iarrayhi[i2]; ii++) {
             imaddr(i1, ii,rowcol) = (int) ivaddr(i2,ii);
        }

    Licpy(ARGR,0);
}

void R_iadd(__unused int func) {
    int vname,row;
    get_ivname(1,vname);
    get_oiv(2, row, iarrayhi[vname] + 1);
    check_ivrow(vname,row);

    ivaddr(vname,row)=ivaddr(vname,row)+Lrdint(ARG3);
    if (row > iarrayhi[vname]) iarrayhi[vname]=row;
    Licpy(ARGR,ivaddr(vname,row));
}

void R_isub(__unused int func) {
    int vname,row;
    get_ivname(1,vname);
    get_oiv(2, row, iarrayhi[vname] + 1);
    check_ivrow(vname,row);

    ivaddr(vname,row)=ivaddr(vname,row)-Lrdint(ARG3);
    if (row > iarrayhi[vname]) iarrayhi[vname]=row;
    Licpy(ARGR,ivaddr(vname,row));
}

void R_iget(__unused int func) {
    int vname,row;
    get_ivname(1,vname);
    get_i(2,row);
    check_ivrow(vname,row);
    Licpy(ARGR,ivaddr(vname,row));
}

void R_icmp(__unused int func) {
    int s1,s2,i1,i2;

    get_ivname(1,s1);
    get_i(2,i1);
    check_ivrow(s1,i1);
    get_ivname(3,s2);
    get_i(4,i2);
    check_ivrow(s2,i2);

    if (ivaddr(s1,i1) > ivaddr(s2, i2)) Licpy(ARGR, 1);
    else   if (ivaddr(s1,i1) ==ivaddr(s2,i2)) Licpy(ARGR,0);
    else Licpy(ARGR,-1); ;
}

void R_iappend(__unused int func) {
    int in,i1,i2,ii,jj;
    get_ivname(1,i1);
    get_ivname(2,i2);

 // copy first array
    in = ivnew(iarrayhi[i1] + iarrayhi[i2]);
    if (in < 0) {
        Licpy(ARGR, in);
        return;
    }

    for (ii=0; ii < iarrayhi[i1]; ii++) {
        ivector[in][ii]= (int) ivector[i1][ii];
    }
    iarrayhi[in]=iarrayhi[i1];
 // append second array
    for (ii=0, jj=iarrayhi[in]; ii < iarrayhi[i2]; ii++, jj++) {
        ivector[in][jj]= (int) ivector[i2][ii];
    }
    iarrayhi[in]=iarrayhi[i1]+iarrayhi[i2];
    Licpy(ARGR,in);
}

void R_isort(__unused int func) {

    int vname, i, j, to, k, complete, sw;
    char mode;
    get_ivname(1, vname);
    get_modev(2, mode, 'A');

    to = iarrayhi[vname] - 1;
    if (to < 0) {               // empty: nothing to sort or reverse
        Licpy(ARGR, to);
        return;
    }
    i = 0;
    j = to;
    k = j / 2;
    while (k > 0) {
        for (;;) {
            complete = 1;
            for (i = 0; i <= to - k; ++i) {
                j = i + k;
                if (ivector[vname][i] > ivector[vname][j]) {
                    sw = ivector[vname][i];
                    ivector[vname][i] = ivector[vname][j];
                    ivector[vname][j] = sw;
                    complete = 0;
                }
            }
            if (complete) break;
        }
        k = k / 2;
    }
    if (mode == 'D') {
        k = to / 2;
        for (i = 0; i <= k; ++i,j--) {
            sw = ivector[vname][i];
            ivector[vname][i] = ivector[vname][j];
            ivector[vname][j] = sw;
        }
    }
    Licpy(ARGR, to);
}

void R_imcreate(__unused int func) {
    int in,i1,i2,ii;
    get_i(1,i1);
    get_i(2,i2);

    in = ivnew(i1*i2);
    if (in < 0) {
        Licpy(ARGR, in);
        return;
    }
    ivrows[in]=i1;
    ivcols[in]=i2;
    for (ii=0; ii < i1*i2; ii++) {
        ivector[in][ii]= 0;
    }
    iarrayhi[in]=i1*i2;

    Licpy(ARGR,in);
}

void R_iarray(__unused int func) {
    int vname;
    char mode;

    get_ivname(1,vname);
    get_modev(2,mode,' ');
    if (mode=='C') Licpy(ARGR, ivcols[vname]);
    else if (mode=='R') Licpy(ARGR, ivrows[vname]);  // number of rows
    else Licpy(ARGR, iarrayhi[vname]);               // number of elements
}
void R_prime(__unused int func) {
    int i;
    get_i0(1,i);
    i=sundaram(-1,i,1);
    Licpy(ARGR,i);
}
/* ----------------------------------------------------------------------------
 * Copy an array into a new integer array
 * ----------------------------------------------------------------------------
 */
void R_s2iarray(__unused int func) {
    int s1,i1,ii=0;
    get_i0(1, s1);
    /* the source must be a created string array: it indexed sarray[]
     * unchecked */
    if (s1 < 0 || s1 >= sarraymax || sarray[s1] == NULL) arrayerror

    sindex = (char **) sarray[s1];

    i1 = ivnew(sarrayhi[s1]);
    if (i1 < 0) {
        Licpy(ARGR, i1);
        return;
    }
     for (ii=0;ii<sarrayhi[s1];ii++) {
        ivector[i1][ii]= atoi(sstring(ii));
    }
    iarrayhi[i1]=ii;

    Licpy(ARGR, i1);
}

/* ----------------------------------------------------------------------------
 * Copy an hash integer array from a string array
 * ----------------------------------------------------------------------------
 */
uint32_t FNVhash(const void* key, uint32_t h) {
    int ii,len=0;
    const uint8_t* data;

    len=strlen(key);
    h ^= 2166136261UL;
    data = (const uint8_t*)key;
    for(ii = 0; ii < len; ii++) {
        h ^= data[ii];
        h *= 16777619;
    }
    return h;
}

char * trim(char *c) {
    char * e = c + strlen(c) - 1;
    while(*c && isspace((unsigned char) *c)) c++;
    while(e > c && isspace((unsigned char) *e)) *e-- = '\0';
 //   printf("trim '%s'\n",c);
    return c;
}

void R_s2hash(__unused int func) {
    int s1,i1,ii=0;
    get_i0(1, s1);
    /* the source must be a created string array: it indexed sarray[]
     * unchecked */
    if (s1 < 0 || s1 >= sarraymax || sarray[s1] == NULL) arrayerror

    sindex = (char **) sarray[s1];

    i1 = ivnew(sarrayhi[s1]);
    if (i1 < 0) {
        Licpy(ARGR, i1);
        return;
    }
    for (ii=0;ii<sarrayhi[s1];ii++) {
        ivector[i1][ii]= (int) FNVhash(trim(sstring(ii)),1234);
    }
    iarrayhi[i1]=ii;

    Licpy(ARGR, i1);
}


void RxIArrayRegFunctions()
{
    RxRegFunction("S2IARRAY",   R_s2iarray,     0);
    RxRegFunction("S2HASH",     R_s2hash,       0);
    RxRegFunction("ICREATE",    R_icreate,      0);
    RxRegFunction("ISEARCH",    R_isearch,      0);
    RxRegFunction("ISEARCHNN",  R_isearchnn,    0);
    RxRegFunction("IMCREATE",   R_imcreate,     0);
    RxRegFunction("IGET",       R_iget,         0);
    RxRegFunction("ISET",       R_iset,         0);
    RxRegFunction("ICMP",       R_icmp,         0);
    RxRegFunction("IMGET",      R_imget,        0);
    RxRegFunction("IMSET",      R_imset,        0);
    RxRegFunction("ISORT",      R_isort,        0);
    RxRegFunction("IMADD",      R_imadd,        0);
    RxRegFunction("IMSUB",      R_imsub,        0);
    RxRegFunction("IMINFIX",    R_iminfix,      0);
    RxRegFunction("IADD",       R_iadd,         0);
    RxRegFunction("ISUB",       R_isub,         0);
    RxRegFunction("I2S",        R_i2s,          0);
    RxRegFunction("IAPPEND",    R_iappend,      0);
    RxRegFunction("IARRAY",     R_iarray,       0);
    RxRegFunction("SFCREATE",   R_sfcreate,     0);
    RxRegFunction("SFGET",      R_sfget,        0);
    RxRegFunction("SFSET",      R_sfset,        0);
    RxRegFunction("SFFREE",     R_sffree,       0);
    RxRegFunction("BITARRAY",   R_bitarray,     0);
    RxRegFunction("PRIME",      R_prime,        0);
} /* RxIArrayRegFunctions() */
