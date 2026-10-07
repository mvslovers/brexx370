/* -------------------------------------------------------------------------------------
 * String arrays: SCREATE, SSET, SGET, the sorts, set operations, SCOPY,
 * SINSERT, SEXTRACT, ... Moved from rxmvs.c (#302). __SREAD and __SWRITE,
 * which fill a string array from a data set, stay there for now.
 * -------------------------------------------------------------------------------------
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include "rexx.h"
#include "rxdefs.h"
#include "rxmvsext.h"
#include "lstring.h"
#include "lerror.h"
#include "sarray.h"
#include "util.h"

extern Lstr LTMP[16];

char **sindex;
char *sarray[sarraymax];
int  sindxhi[sarraymax];
int  sarrayhi[sarraymax];

/* -------------------------------------------------------------------------------------
 * String Array
 * -------------------------------------------------------------------------------------
 */
int sarray_new(int rows) {
    int sname;

    if (rows < 100) rows = 100;
    for (sname = 0; sname < sarraymax; ++sname) {
        if (sarray[sname] == NULL) break;
    }
    if (sname >= sarraymax) return -1;  /* it took sarray[128], beside the table */

    sindex = MALLOC(rows * sizeof(char *), "SINDEX");
    memset(sindex, 0, rows * sizeof(char *));
    sarray[sname] = (char *) sindex;
    sindxhi[sname] = rows;
    sarrayhi[sname] = 0;
    return sname;
}

void sarray_room(int sname, int need) {
    int old = sindxhi[sname];

    if (need > old) {
        need += 100;
        sarray[sname] = REALLOC((void *) sarray[sname], need * sizeof(char *));
        memset(sarray[sname] + old * sizeof(char *), 0, (need - old) * sizeof(char *));
        sindxhi[sname] = need;
    }
    sindex = (char **) sarray[sname];
}

void R_screate(__unused int func) {
    int sname,imax;

    get_i(1,imax);
    new_sarray(sname, imax);
    Licpy(ARGR, sname);
}

void R_sresize(__unused int func) {
    int sname,imax,recs,old;
    get_sname(1, sname)
    get_i0(2,imax);
    recs=sarrayhi[sname];
    old=sindxhi[sname];

    if (imax<=recs) {
       Licpy(ARGR, 4);
       return;
    }

    /* the new entries were left as they came: SSET took them for set,
     * SFREE freed them (#172) */
    sarray[sname] = REALLOC((void *) sarray[sname], imax * sizeof(char *));
    if (imax > old)
        memset(sarray[sname] + old * sizeof(char *), 0, (imax - old) * sizeof(char *));
    sindxhi[sname]=imax;
    sarrayhi[sname]=recs;
    setIntegerVariable("sarrayhi", sarrayhi[sname]);
    setIntegerVariable("sarraymax",sindxhi[sname]);

    Licpy(ARGR, 0);
}

void snew(int index,char *string,int llen) {
    int mlen;
    if (llen<=0) mlen = (strlen(string) + 1 + 16) * sizeof(char) + sizeof(int);
    else mlen=llen;
    sindex[index] = MALLOC(mlen, "SSTRING");
    *sindex[index] = mlen;
    strcpy(sindex[index] + sizeof(int), string);
}

void sset(int index,PLstr string) {
    int mlen,mlen2;
    LASCIIZ(*string);
    mlen = (LLEN(*string) + 1 + 16) * sizeof(char) + sizeof(int);
    if (sindex[index] == 0) snew(index,LSTR(*string),mlen);
    else {
        mlen2 = (LLEN(*string) + 1) * sizeof(char) + sizeof(int);
        if (mlen2 > *sindex[index]) {
            FREE(sindex[index]);
            sindex[index] = MALLOC(mlen, "SSTRING");
            *sindex[index] = mlen;
        }
        strcpy(sindex[index] + sizeof(int), LSTR(*string));
    }
 }

void R_sset(__unused int func) {
    int sname,index,jj,values;
    get_sname(1, sname)
    sindex= (char **) sarray[sname];
    get_oiv(2,index,sarrayhi[sname]+1);
    /* index 0 wrote below the array, and nothing stopped a write past
     * its capacity (#172) */
    values = ARGN > 2 ? ARGN - 2 : 0;
    if (index < 1 || index - 1 + values > sindxhi[sname]) {
        Lerror(ERR_INCORRECT_CALL,0);
        return;
    }
    index--;
    /* a gap below index is set to '': the sorts and searches read every
     * entry up to the count */
    for (jj = sarrayhi[sname]; jj < index; ++jj) {
        if (sindex[jj] == NULL) snew(jj, "", 0);
    }
    for (jj = 2; jj < ARGN; ++jj) { // Allow adding of more than one value
       // dynamic get_s(jj)
       // if ((rxArg.a[jj])==((void*)0))Lerror(40, 0);
        if (((*((rxArg.a[jj]))).type)!=LSTRING_TY)L2str(((rxArg.a[jj])));
        sset(index,rxArg.a[jj]);
        index++;
    }
    if (index>sarrayhi[sname]) sarrayhi[sname]=index;
    Licpy(ARGR,0);
}
/* entry ix from offset offs on, '' when it is shorter (#172) */
static const char *sitemat(int ix, int offs) {
    const char *str = sitem(ix);

    return memchr(str, '\0', offs) != NULL ? "" : str + offs;
}

void R_sget(__unused int func) {
    int sname,index,start;
    get_sname(1, sname)
    get_sindex(2, index, sname)
    get_oiv(3,start,1);
    if (start < 1) {
        Lerror(ERR_INCORRECT_CALL,0);
        return;
    }
    sindex= (char **) sarray[sname];
    Lscpy(ARGR, sitemat(index - 1, start - 1));
 }

void R_sswap(__unused int func) {
    int sname, ix1, ix2;
    char * swap;
    get_sname(1, sname)
    get_sindex(2, ix1, sname)
    get_sindex(3, ix2, sname)
    ix1--;
    ix2--;
    sindex = (char **) sarray[sname];
    sswap(ix1,ix2);

    Licpy(ARGR,0);
}

void R_sclc(__unused int func) {
    int s1,s2,i1,i2;
    const char *sw1;
    get_sname(1, s1)
    get_sindex(2, i1, s1)
    get_sname(3, s2)
    get_sindex(4, i2, s2)
    i1--;
    i2--;

    sindex = (char **) sarray[s1];
    sw1 = sitem(i1);
    sindex = (char **) sarray[s2];
    Licpy(ARGR,strcmp(sw1,sitem(i2)));
}

void R_sfree(int func) {
    int sname,ii,jj, keep=0;
    char akeep;
    if (ARGN == 0 || func <0) {
        for (jj = 0; jj < sarraymax; ++jj) {
            if (sarray[jj] == 0) continue;
            sindex= (char **) sarray[jj];
            for (ii = 0; ii < sindxhi[jj]; ++ii) {
                if (sindex[ii] == 0) continue;
                FREE(sindex[ii]);
            }
            FREE(sindex);
            sarray[jj]=0;
        }
    } else {
        get_snum(1, sname);
        get_modev(2,akeep,'N');

        if (akeep=='K' || akeep=='R') keep=1;

        if (sarray[sname] != 0) {
            sindex = (char **) sarray[sname];
            for (ii = 0; ii < sindxhi[sname]; ++ii) {
                if (sindex[ii] == 0) continue;
                FREE(sindex[ii]);
                sindex[ii] = 0;
            }
            sarrayhi[sname]=0;
            if (keep==0) {
                FREE(sindex);
                sarray[sname]=0;
            }
        }
    }
    if (func!=-1) Lscpy(ARGR,0);
}

void R_slist(__unused int func) {
    int sname,ii,from,to;

    get_sname(1, sname)
    if (sname>sarraymax){
       printf("Source Arraynumber %d exceeds maximum %d\n",sname,sarraymax);
       Licpy(ARGR, -1);
       return;
    }
    sindex= (char **) sarray[sname];

    get_oiv(2,from,1);
    get_oiv(3,to,sarrayhi[sname]);

    if (from<1) from=1;
    if (to>sarrayhi[sname]) to=sarrayhi[sname];
    if (sname==0) ;
    else printf("     Entries of Source Array: %d\n",sname);
    if (ARGN==4) {
        get_s(4)
        LASCIIZ(*ARG4);
        printf("Entry   %s\n",LSTR(*ARG4));
    } else printf("Entry   Data\n");
    printf("-------------------------------------------------------\n");

    for (ii=from-1;ii<to;ii++) {
    //   printf("slist %d %dd  \n",ii+1,sindex[ii]);
        printf("%.5d   %s\n",ii+1,sstring(ii));
    }
    printf("%d Entries\n",to);
    Licpy(ARGR, 0);
}

/* the sorts compare from an offset on; past the end of an entry it
 * read the storage behind it (#172) */
#define sortstring(ix,offs) sitemat(ix,offs)

void bsort(int from,int to,int offset) {
   int ii,j,sm;
   char * sw;
    if (from>=to) return;
  //  printf("Bubble Sort %d %d \n",from,to);

    for (ii = from; ii <= to; ++ii) {
        sm = ii;
        for (j = ii + 1; j <= to; ++j) {
            if (strcmp(sortstring(j,offset), sortstring(sm,offset)) < 0) sm = j;
        }
        sw = sindex[ii];
        sindex[ii] = sindex[sm];
        sindex[sm] = sw;
    }
}

void shsort(int from,int to,int offset) {
    int i, j, k,complete;
    char *sw;
    i = from;
    j = to;
    k = (from + to) / 2;
    while (k>0) {
        for (;;) {
            complete=1;
            for (i = 0; i <= to-k; ++i) {
                j=i+k;
                if (strcmp(sortstring(i,offset),sortstring(j,offset))>0) {
                    sw = sindex[i];
                    sindex[i] = sindex[j];
                    sindex[j] = sw;
                    complete=0;
                }
            }
            if(complete) break;
        }
        k=k/2;
    }
}

void sqsort(int first,int last, int offset,int level){

    int i, j, pivot;
    char * swap;
    level++;
 //   printf("Quick level %d from %d to %d \n",level,first,last);
    if(first<last){
        pivot=(first+last)/2;
        pivot=first;
        i=first;
        j=last;
        while(i<j){
            while(strcmp(sortstring(i,offset), sortstring(pivot,offset)) <= 0 && i<last)
                i++;
            while(strcmp(sortstring(j,offset), sortstring(pivot,offset)) >0 && j>0)
                j--;
            if(i<j) {
                sswap(i, j);
   //             printf("Swap %d %d %d\n",i,j,pivot);
            }
        }
        if (j!=pivot) {
            sswap(j, pivot);
    //        printf("Swap Pivot %d %d\n", j, pivot);
        }
        if (j-1-first>25) sqsort(first,j-1,offset,level);
           else bsort(first,j-1,offset);
        if (last-j+1>25) sqsort(j + 1, last, offset,level);
        else bsort(j + 1, last, offset);
    }
}

void sreverse(int sname) {
    int shi,i, m;
    char *sw;

    sindex= (char **) sarray[sname];
    shi=sarrayhi[sname] - 1;
    if (shi < 1) {                /* an empty array swapped sindex[-1] (#172) */
        Licpy(ARGR,shi);
        return;
    }
    m=shi/2;
    for (i = 0; i <= m; ++i) {
        sw = sindex[i];
        sindex[i] = sindex[shi];
        sindex[shi] = sw;
        shi--;
    }
    Licpy(ARGR,shi);
}

void R_sqsort(__unused int func) {
    int sname,offset,from,to,tto,ffrom,split,justsplit,junks=1;
    char mode;

    get_sname(1, sname)
    get_modev(2,mode,'A');
    get_oiv(3,offset,1);
    get_oiv(4,from,1);
    if (offset < 1 || from < 1) {         /* both read below the entry or the array (#172) */
        Lerror(ERR_INCORRECT_CALL,0);
        return;
    }
    offset--;
    from--;
    sindex= (char **) sarray[sname];
    get_oiv(5,to,sarrayhi[sname]);
    if (to > sarrayhi[sname]) to = sarrayhi[sname];
    to--;
    get_oiv(6,split,1000);
    get_oiv(7,justsplit,0);

    tto=to;
    if (to>split || ARGN>=3) {
        ffrom = 0;
        split--;
        while (1) {
            tto = ffrom + split;
            if (tto > to) tto = to;
            sqsort(ffrom, tto,offset,0);
            junks++;
  //        printf("Split Sort %d %d\n",ffrom,tto);
            ffrom = tto + 1;
            if (ffrom>to) break;
         }
        junks--;     // one to high
    } else sqsort(from, to,offset,0);
    if (justsplit==1) ;     // do nothing sqsort(from, to,offset,0);
    else if (junks>1)sqsort(from, to,offset,0);
    /*
     else {
        printf("Perform split %d\n", junks);
        split++;     // adjust split +1
        taddr = MALLOC(sarrayhi[sname] * sizeof(char *),"Sort Temp");
        memset(taddr, 0, sarrayhi[sname]*sizeof(char *));


        for (k = 0; k < junks; k = k + 1) {
            for (i = 0; i <= to; i = i + split) {
                if (sindex[i] == 0) continue;
                 break;
            }
            if (sindex[i] == 0) break;

            clow = i;
            alow = clow + split;
            for (i = alow; i <= to; i = i + split) {
                if (sindex[i] == 0) continue;
                if (strcmp(sortstring(i, offset), sortstring(clow, offset)) <= 0) {
                    clow = i;
                }
            }
            for (i = clow; i < clow + split && i <= to; i++) {
                taddr[tmax++] = sindex[i];
          //      printf("temp %d %d %d %d \n",i,taddr[tmax-1],sindex[i],taddr);
                sindex[i] = 0;
            }
        }
        for (i = 0; i < tmax; i++) {
            sindex[i] = taddr[i];
        }
        printf("Transfer back %d\n",tmax);
        FREE(taddr);
    }
    */
    Licpy(ARGR,sarrayhi[sname]); // return number of sorted items
    if (mode=='D') sreverse(sname);       // ascending, do nothing
 }

void R_shsort(__unused int func) {
    int sname,offset;
    char mode;

    get_sname(1, sname)
    get_modev(2,mode,'A');
    get_oiv(3,offset,1);
    if (offset < 1) {
        Lerror(ERR_INCORRECT_CALL,0);
        return;
    }
    offset--;

    sindex= (char **) sarray[sname];
    shsort(0, sarrayhi[sname]-1,offset);

    Licpy(ARGR,sarrayhi[sname]); // return number of sorted items
    if (mode=='D') sreverse(sname);             // ascending, do nothing
}

void R_sreverse(__unused int func) {
    int sname;

    get_sname(1, sname)
    sindex= (char **) sarray[sname];

    Licpy(ARGR,sarrayhi[sname]-1); // return number of sorted items
    sreverse(sname);                        // reverse array order
}
void R_sarray(__unused int func) {
    int sname;

    get_oiv(1, sname,-1);
    if (sname>=sarraymax) Licpy(ARGR, -1);
    else if (sname<0) Licpy(ARGR, sarraymax);  // max sarray count
    else {
        sindex = (char **) sarray[sname];
        if (sindex == 0) Licpy(ARGR, -1); // return -1 array is not yet set
        else Licpy(ARGR, sarrayhi[sname]); // return number of sorted items
        setIntegerVariable("sarrayhi", sarrayhi[sname]);
        setIntegerVariable("sarraymax", sindxhi[sname]);
        setIntegerVariable("sarrayADDR", (int) sindex);
    }
}

void R_ssearch(__unused int func) {
    int sname,ii,from=1;
    char mode;
    get_sname(1, sname)
    sindex= (char **) sarray[sname];

    get_s(2);
    LASCIIZ(*ARG2);               // search string
    get_oiv(3,from,1);            // optional from parameter
    if (from < 1) from = 1;       // 0 read sindex[-1] (#172)
    if (from>sarrayhi[sname]) {
        Licpy(ARGR, 0) ;
        return;
    }
    from--;
    get_modev(4,mode,'C');        // case/nocase parameter

    if (mode=='N') {              // noCase  not case sensitive
        Lupper(ARG_OWN(2));
        for (ii = from; ii < sarrayhi[sname]; ii++) {
            Lscpy(ARGR,sstring(ii));
            LASCIIZ(*ARGR);
            Lupper(ARGR);
            if (strstr(LSTR(*ARGR), LSTR(*ARG2)) != NULL) goto found;
        }
    }
    else {     // CASE  case sensitive
        for (ii = from; ii < sarrayhi[sname]; ii++) {
            if (strstr(sstring(ii), LSTR(*ARG2)) != NULL) goto found;
        }
    }
    Licpy(ARGR, 0) ;
    return;
    found:
    Licpy(ARGR, ii+1);
}
// SUNIFY, Keep just one entry of an Array element, Array must be sorted!
void R_sunify(__unused int func) {
    int sname,ii,old,drop=0;
    get_sname(1, sname)
    sindex= (char **) sarray[sname];

    Lscpy(ARGR,"");     // preset empty element
    old=0;
    for (ii = 1; ii < sarrayhi[sname]; ii++) {
        if (strcmp(sstring(ii), sstring(old)) != 0) old = ii;  // strings are not equal
        else {  // strings are equal, drop it
           drop++;
           sset(ii, ARGR);
        }
    }
    Licpy(ARGR, drop);
}
void R_sintersect(__unused int func) {
    int s1,s2,ii,jj,set1,set2,setx,sety,nset, smax,count=0,cmp,lfj;
    char *sw1;

    get_sname(1, s1)
    get_sname(2, s2)

    set1 = sarrayhi[s1];
    set2 = sarrayhi[s2];
    if (set1 < set2) {
        setx = s1;
        sety = s2;
        smax = set1;
    } else {
        setx = s2;
        sety = s1;
        smax = set2;
    }
    new_sarray(nset, smax);
    lfj=0;
    for (ii = 0; ii < sarrayhi[setx]; ii++) {
        sindex= (char **) sarray[setx];
        sw1=sstring(ii);
        sindex= (char **) sarray[sety];
        for (jj = lfj; jj < sarrayhi[sety]; jj++) {
            cmp=strcmp(sw1, sstring(jj));
            if (cmp==0){
                sindex= (char **) sarray[nset];
                snew(count,sw1,0);
                count++;
                lfj=jj;
                break;
            }
            if (cmp<0) break;
        }
    }
    sarrayhi[nset]=count;
    Licpy(ARGR, nset);
}

void R_sdifference(__unused int func) {
    int s1,s2,ii,jj,set1,set2,nset, smax,count=0,cmp,lfnd=0;
    char *sw1;

    get_sname(1, s1)
    get_sname(2, s2)

    set1 = sarrayhi[s1];
    set2 = sarrayhi[s2];
    if (set1 < set2) smax=set1;
    else smax=set2;
    new_sarray(nset, smax);
    for (ii = 0; ii < sarrayhi[s1]; ii++) {
        sindex= (char **) sarray[s1];
        sw1=sstring(ii);
        sindex= (char **) sarray[s2];
        for (jj = lfnd; jj < sarrayhi[s2]; jj++) {
            cmp=strcmp(sw1, sstring(jj));
            if (cmp==0) goto dropItem;
            if (cmp<0) break;                // if item name in sarray s2 is larger than item of s1 then nothing else will appear, break loop for this item
        }
        sindex= (char **) sarray[nset];
        snew(count,sw1,0);
        count++;
        continue;
        dropItem:
        lfnd=jj;
    }
    sarrayhi[nset]=count;
    Licpy(ARGR, nset);
}


void R_schange(__unused int func) {
    int sname,ii,k,count=0,changed;
    Lstr source;
    LINITSTR(source);

    get_sname(1, sname)
    gets_all(k)   // fetch all following string parameters, k becomes 1, if an empty parameter is part of it (not needed here)

    sindex= (char **) sarray[sname];

    for (ii = 0; ii < sarrayhi[sname]; ii++) {
        changed=0;
        for (k = 1; k < ARGN; k=k+2) {
            if (strstr(sstring(ii), ((*(rxArg.a[k])).pstr))==0 || (*(rxArg.a[k])).len<1 ) continue;
            Lscpy(&source, sstring(ii));
            Lchangestr(ARGR, rxArg.a[k], &source, rxArg.a[k + 1]);
            changed = 1;
            for (k = k+2; k < ARGN; k=k+2) {
                if (strstr(LSTR(*ARGR), ((*(rxArg.a[k])).pstr))==0 || (*(rxArg.a[k])).len<1) continue;
                Lstrcpy(&source, ARGR);
                Lchangestr(ARGR, rxArg.a[k], &source, rxArg.a[k + 1]);
            }
            break;
        }
        if (changed==1) {
           sset(ii, ARGR);
           count++;
        }
    }
    LFREESTR(source);

    Licpy(ARGR, count);
}

// counts the occurrence of one or more strings in an array

void R_scount(__unused int func) {
    int sname,ii,k,count=0;

    get_sname(1, sname)
    gets_all(k)   // fetch all following string parameters, k becomes 1, if an empty parameter is part of it (not needed here)

    sindex= (char **) sarray[sname];

    for (ii = 0; ii < sarrayhi[sname]; ii++) {
         for (k = 1; k < ARGN; k++) {
             if (strstr(sstring(ii), ((*(rxArg.a[k])).pstr)) == 0) ;
             else count++;
         }
     }
    Licpy(ARGR, count);
}

void R_sdrop(__unused int func) {
    int sname,ii,k,mlen,current=0,delblank=0, from[99]={0};

    get_sname(1, sname)
    gets_all(delblank)   // fetch all following string parameters, delblank becomes 1, if an empty parameter is part of it
    getRXVAR(from,"sdrop.at.",2)  // fetch offset by rexx variable, if not there it is set to zero, store it in from[] array

    sindex= (char **) sarray[sname];

    for (ii = 0; ii < sarrayhi[sname]; ii++) {
        Lscpy(&LTMP[14], sstring(ii));
        for (k = 1; k < ARGN; k++) {
            if (delblank==1){
             // skip trailing blanks
                for (mlen = strlen(sstring(ii)); mlen>= 0; mlen--) {
                    if (mlen<1) break;
                    if (sindex[ii][sizeof(int) + mlen - 1] == ' ') sindex[ii][sizeof(int) + mlen - 1] = 0;
                    else break;
                }
                if (mlen<1) goto dropLine;
            }
            if (from[k]==0) {
               if (strstr(sstring(ii), ((*(rxArg.a[k])).pstr)) == NULL || (*(rxArg.a[k])).len < 1) continue;
               goto dropLine;
            } else {
               Lscpy(&LTMP[15],rxArg.a[k]->pstr);
               if (fndpos(&LTMP[15],&LTMP[14],from[k])!=from[k]) continue;
               goto dropLine;
            }
        }
        move_sitem(current,ii)
        current++;
        dropLine:;
    }

    free_sitem(sname,current)  // release storage of not needed items at the end of the arry

    sarrayhi[sname]=current;
    Licpy(ARGR, 0);
}

void R_skeep(__unused int func) {
    int sname, ii, k, current = 0, from[99]={0};

    get_sname(1, sname)
    gets_all(k)   // fetch all following string parameters, k becomes 1, if an empty parameter is part of it (not needed here)
    getRXVAR(from,"skeep.at.",2)  // fetch offset by rexx variable, if not there it is set to zero, store it in from[] array

    sindex= (char **) sarray[sname];

    for (ii = 0; ii < sarrayhi[sname]; ii++) {
        Lscpy(&LTMP[14], sstring(ii));
        for (k = 1; k < ARGN; k++) {
            if (from[k]==0) {
                if (strstr(sstring(ii), ((*(rxArg.a[k])).pstr)) == NULL || (*(rxArg.a[k])).len < 1) continue;
                goto keepLine;
            } else {
                Lscpy(&LTMP[15],rxArg.a[k]->pstr);
                if (fndpos(&LTMP[15],&LTMP[14],from[k])!=from[k]) continue;
                goto keepLine;
            }
           keepLine:
            move_sitem(current,ii)
            current++;     // item is already in position, no need to do anything, just increase next item index
            break;
        }
    }
    free_sitem(sname,current)  // release storage of not needed items at the end of the arry

    sarrayhi[sname]=current;
    Licpy(ARGR, 0);
}

void R_skeepand(__unused int func) {
    int sname,ii,k,current=0, from[99]={0};

    get_sname(1, sname)
    gets_all(k)   // fetch all following string parameters, k becomes 1, if an empty parameter is part of it (not needed here)
    getRXVAR(from,"skeep.at.",2)  // fetch offset by rexx variable, if not there it is set to zero, store it in from[] array

    sindex= (char **) sarray[sname];

    for (ii = 0; ii < sarrayhi[sname]; ii++) {
        Lscpy(&LTMP[14], sstring(ii));
        for (k = 1; k < ARGN; k++) {
            if (from[k] == 0) {
               if (strstr(sstring(ii), ((*(rxArg.a[k])).pstr)) == 0) goto DropLine;
            } else {
              Lscpy(&LTMP[15], rxArg.a[k]->pstr);
              if (fndpos(&LTMP[15], &LTMP[14], from[k])!=from[k]) goto DropLine;
            }
        }
        move_sitem(current,ii)
        current++;
        DropLine:;
    }
    free_sitem(sname,current)  // release storage of not needed items at the end of the arry

    sarrayhi[sname]=current;
    Licpy(ARGR, 0);
}

void R_ssubstr(__unused int func) {
    int sname,ii,sfrom,slen,s1;
    char mode='E';
    Lstr substr;
    get_sname(1, sname)
    sindex= (char **) sarray[sname];

    get_i(2, sfrom);
    get_oiv(3, slen,0);
    get_sv(4);
    if (ARGN==4) mode=LSTR(*ARG4)[0];

    LINITSTR(substr);
    Lfx(&substr,255);

    if (mode=='E' || mode=='e'){   // change in new array
        new_sarray(s1, sarrayhi[sname]);
        sindex= (char **) sarray[sname];
        for (ii = 0; ii < sarrayhi[sname]; ii++) {
            Lscpy(&substr,sstring(ii));
            _Lsubstr(ARGR,&substr,sfrom,slen);
            sindex= (char **) sarray[s1];     // switch to new array
            LSTR(*ARGR)[LLEN(*ARGR)]=0;
            snew(ii, LSTR(*ARGR), -1);
            sindex= (char **) sarray[sname];  // switch back to old array
        }
        sarrayhi[s1]=sarrayhi[sname];        // set arrayhi in new array
    } else {     // change in same array
        s1=sname;
        sindex= (char **) sarray[sname];
        for (ii = 0; ii < sarrayhi[sname]; ii++) {
            Lscpy(&substr, sstring(ii));
            _Lsubstr(ARGR, &substr, sfrom, slen);
            sset(ii, ARGR);
        }
    }
    LFREESTR(substr);
    Licpy(ARGR, s1);
}

void R_sword(__unused int func) {
    int sname,ii,sword,s1;
    char mode='E';

    get_sname(1, sname)
    sindex= (char **) sarray[sname];

    get_i(2, sword);
    get_sv(3);
    if (ARGN==3) mode=LSTR(*ARG3)[0];

    if (mode=='E' || mode=='e'){   // change in new array
        new_sarray(s1, sarrayhi[sname]);
        sindex= (char **) sarray[sname];
        for (ii = 0; ii < sarrayhi[sname]; ii++) {
            Lscpy(&LTMP[15],sstring(ii));
            Lword(ARGR, &LTMP[15], sword);
            sindex= (char **) sarray[s1];     // switch to new array
            LSTR(*ARGR)[LLEN(*ARGR)]=0;
            snew(ii, LSTR(*ARGR), -1);
            sindex= (char **) sarray[sname];  // switch back to old array
        }
        sarrayhi[s1]=sarrayhi[sname];        // set arrayhi in new array
    } else {     // change in same array
        s1=sname;
        sindex= (char **) sarray[sname];
        for (ii = 0; ii < sarrayhi[sname]; ii++) {
            Lscpy(&LTMP[15], sstring(ii));
            Lword(ARGR, &LTMP[15], sword);
            sset(ii, ARGR);
        }
    }
    Licpy(ARGR, s1);
}

void R_supper(__unused int func) {
    int sname,ii,s1;
    char mode='E';

    get_sname(1, sname)
    sindex= (char **) sarray[sname];

    get_sv(2);
    if (ARGN==2) mode=LSTR(*ARG2)[0];

    if (mode=='E' || mode=='e'){   // change in new array
        new_sarray(s1, sarrayhi[sname]);
        for (ii = 0; ii < sarrayhi[sname]; ii++) {
            sindex= (char **) sarray[sname];
            Lscpy(ARGR,sstring(ii));
            Lupper(ARGR);
            LSTR(*ARGR)[LLEN(*ARGR)]=0;
            sindex= (char **) sarray[s1];     // switch to new array
            snew(ii, LSTR(*ARGR), -1);
        }
        sarrayhi[s1]=sarrayhi[sname];        // set arrayhi in new array
    } else {     // change in same array
        s1=sname;
        sindex= (char **) sarray[sname];
        for (ii = 0; ii < sarrayhi[sname]; ii++) {
            Lscpy(ARGR, sstring(ii));
            Lupper(ARGR);
            sset(ii, ARGR);
        }
    }
    Licpy(ARGR, s1);
}

void slstr(int sname) {
    int ii;
    Lscpy(ARGR, sitem(0));        // empty array: sindex[0] is NULL (#172)
    if (sarrayhi[sname] == 0) return;
    Lcat(ARGR, ";");
    for (ii = 1; ii < sarrayhi[sname]; ii++) {
        Lcat(ARGR, sstring(ii));
        Lcat(ARGR, "\n");
    }
}

void R_slstr(__unused int func) {
    int sname;
    get_sname(1, sname)
    sindex = (char **) sarray[sname];
    slstr(sname);
}

void R_sselect(__unused int func) {
    int sname, s1, k, ii, jj = 0,llen, from[99] = {0}, to[99] = {0};
    Lstr temp;
    LINITSTR(temp);
    get_sname(1, sname)
    get_s(2);
    LASCIIZ(*ARG2);           // search string
    new_sarray(s1, sarrayhi[sname]);
    for (k = 2,ii=1; k <= ARGN; k++,ii++) {
        get_sv(k);
        from[ii] = getIntegerV("sselect.from.", ii);
        to[ii] = getIntegerV("sselect.length.", ii);
        if (to[ii] == 0) to[ii] = -1;
    }
    sindex = (char **) sarray[sname];
    for (ii = 0; ii < sarrayhi[sname]; ii++) {
        for (k = 1; k < ARGN; k++) {
            if (((*rxArg.a[k]).len)==0) continue;      // skip 0 len search
            if (from[k]==0) {
               if (strstr(sstring(ii), ((*(rxArg.a[k])).pstr)) != NULL) goto copy;
            } else {
                   Lscpy(&temp, sstring(ii));
                   _Lsubstr(ARGR, &temp, from[k], to[k]);
                   llen = LLEN(*ARGR);
                   LSTR(*ARGR)[llen] = '\0';     // set null terminator, not set by Lsubstr
                   if (strstr(LSTR(*ARGR), ((*(rxArg.a[k])).pstr)) != NULL) goto copy;
            }
        }
        continue;
      copy:
        Lscpy(ARGR, sstring(ii));
        LSTR(*ARGR)[strlen(sstring(ii))]=0;
        sindex = (char **) sarray[s1];
        snew(jj, LSTR(*ARGR), -1);
        jj++;
        sindex = (char **) sarray[sname];
    }

    LFREESTR(temp);
    sarrayhi[s1] = jj;
    Licpy(ARGR, s1);

}

void R_smerge(__unused int func) {
    int s1,s2,s3,i,ii=0,ji=0,smax;
    char *sw1, *sw2;
    get_sname(1, s1)
    get_sname(2, s2)
    smax=sarrayhi[s1]+sarrayhi[s2];
    sindex= (char **) sarray[s1];
    sqsort(0, sarrayhi[s1]-1,0,0);
    sindex= (char **) sarray[s2];
    sqsort(0, sarrayhi[s2]-1,0,0);
    new_sarray(s3, smax);               // save new sarray token

    /* the entry after the last one was read, past the capacity for a
     * full array (#172) */
    for (i = 0; i < smax; ++i) {
        sindex= (char **) sarray[s1];
        sw1 = ii < sarrayhi[s1] ? sstring(ii) : NULL;
        sindex= (char **) sarray[s2];
        sw2 = ji < sarrayhi[s2] ? sstring(ji) : NULL;
        sindex= (char **) sarray[s3];
        if (sw1 == NULL && sw2 == NULL) break;   /* both used up */
        if (sw2 == NULL || (sw1 != NULL && strcmp(sw1,sw2) < 0)) {
           snew(i,sw1,0);
           ii++;         // set to next entry
        } else {
           snew(i,sw2,0);
           ji++;         // set to next entry
        }
    }
    sarrayhi[s3]=i;
    Licpy(ARGR,s3); // return number of sorted items
}
/* ----------------------------------------------------------------------------
 * Copy an array into a new array
 *     SCOPY(source,[from],[to],[old-array-to append],[start-position (from-array],[length of substr])
 * ----------------------------------------------------------------------------
 */
void R_scopy(__unused int func) {
    int s1,s2,s3,s4,ii=0,from,to,count,n;
    char *sw1;
    size_t len;
    get_sname(1, s1)
    get_oiv(2,from,1);
    get_oiv(3,to,sarrayhi[s1]);
    get_oiv(4,s2,-1);
    get_oiv(5,s3,-1);
    get_oiv(6,s4,-1);
    if (from < 1) {                 // 0 read sindex[-1] (#172)
        Lerror(ERR_INCORRECT_CALL,0);
        return;
    }
    if (s3>0) s3 --;

    if(to>sarrayhi[s1]) to=sarrayhi[s1];
    n = to >= from ? to - from + 1 : 0;

    if (s2<0) {                     // create a new array
        new_sarray(s2, n);
    }  else {
        if (!sarrayok(s2)) { Lerror(ERR_INCORRECT_CALL,0); return; }  /* to append to */
        sarray_room(s2, sarrayhi[s2] + n);  // the new entries were not cleared (#172)
    }

    count=sarrayhi[s2];

    for (ii=from-1;ii<to;ii++) {
        sindex= (char **) sarray[s1];
        sw1=sstring(ii);
        sindex= (char **) sarray[s2];
        snew(count,sw1,0);

        if (s3>0) {
            /* from a start past the end it copied what lay behind the
             * entry, and strcpy() onto itself overlaps (#172) */
            sw1=sstring(count);
            len=strlen(sw1);
            if ((size_t) s3 >= len) sw1[0]='\0';
            else memmove(sw1, sw1 + s3, len - s3 + 1);
            if (s4>0 && (size_t) s4 <= strlen(sw1)) sw1[s4]='\0';
        }
        count++;
    }
    sarrayhi[s2]=count;
    Licpy(ARGR, s2);
}


/* ----------------------------------------------------------------------------
 * INSERT  n lines into an array after line x
 *       SINSERT(source-,after-lino,string)
 * ----------------------------------------------------------------------------
 */
void R_sinsert(__unused int func) {
    int s1,ii=0,from, ilines=1,smax;

    get_sname(1, s1)
    get_i0(2,from);
    get_i(3,ilines);

    smax=sarrayhi[s1];
    if (from>smax) from=smax;

    sarray_room(s1, smax + ilines);

    Lscpy(&LTMP[10],"");

    /* from smax on it moved sindex[smax] too, one past the capacity
     * when the array became full (#172) */
    for (ii= smax - 1; ii >= from; ii--) {  // insert empty lines by moving after lines
        sindex[ii+ilines]=sindex[ii];   // move pointer
        sindex[ii]=0;                   // clear out old address
    }

    for (ii=from; ii < from+ilines; ii++) {
        sset(ii,&LTMP[10])  ; // empty entries
    }
    sarrayhi[s1]= smax + ilines;               // modify highest set index

    Licpy(ARGR, 0);
}

/* ----------------------------------------------------------------------------
 * spaste  array into source-array after line-number
 *       SINSERT(source-array,after-lino,other-array)
 * ----------------------------------------------------------------------------
 */
void R_spaste(__unused int func) {
    int s1, s2, s1max, s2max, ii=0,jj=0,from,sinsert,sfrom;
    get_sname(1, s1)
    get_i0(2,from);
    get_sname(3, s2)

    s1max=sarrayhi[s1];
    s2max=sarrayhi[s2];

    Licpy(ARGR, 0);

    get_oiv(4,sfrom,1);
    if (sfrom < 1) {               // 0 read sindex[-1] (#172)
        Lerror(ERR_INCORRECT_CALL,0);
        return;
    }
    if (sfrom>s2max) return;
    get_oiv(5, sinsert, s2max);
    if (sfrom+sinsert > s2max) sinsert= s2max-sfrom+1;
    if (sinsert <= 0) return;
    sfrom--;       // index to offset
    if (from > s1max) from = s1max;  // a gap behind the count (#172)

    sarray_room(s1, s1max + sinsert);

    // shift the last n lines (number inserted), the remaining will be moved by moving the addresses
    for (ii= s1max - 1; ii >= from; ii--) {
        sindex[ii+sinsert]=sindex[ii];   // move pointer
        sindex[ii]=0;                  // clear out old address
    }

    for (ii=from, jj=0; ii < from+sinsert; ii++, jj++) {
        sindex= (char **) sarray[s2];
        Lscpy(&LTMP[10],sitem(jj+sfrom));   // s1 = s2: moved away
        sindex= (char **) sarray[s1];
        sset(ii,&LTMP[10])  ; // empty entries
    }
    sarrayhi[s1]= s1max + sinsert;               // modify highest set index

}

void R_sdel(__unused int func) {
    int sname,ii,from,dlines,current=0;

    get_sname(1, sname)
    get_i(2,from);                   // 0 moved into sindex[-1] (#172)
    get_i0(3,dlines);

    if (from>sindxhi[sname]) {
        printf(" %d exceeds maximum entries in Array %d\n",from,sname);
        Licpy(ARGR, 8);
        return;
    }
    /* past the count it set the count to from - 1 (#172) */
    if (dlines==0 || from>sarrayhi[sname]) goto deleteDone;
    from--;

    sindex= (char **) sarray[sname];
    current=from;
    for (ii = from+dlines; ii < sarrayhi[sname]; ii++) {
        move_sitem(current,ii)
        current++;
    }

    free_sitem(sname,current)  // release storage of not needed items at the end of the arry

    sarrayhi[sname]=current;
  deleteDone:
    Licpy(ARGR, 0);
}

/* ----------------------------------------------------------------------------
 * Extract from line to line  of an array into a new array
 *     Sextract(source,from,to)
 * ----------------------------------------------------------------------------
 */
void R_sextract(__unused int func) {
    int s1,s2,ii=0,from,to, count=0;
    char *sw1;
    get_sname(1, s1)
    get_i(2,from);
    get_oiv(3,to,sarrayhi[s1]);
    if (to > sarrayhi[s1]) to = sarrayhi[s1];   // read past the count (#172)

    new_sarray(s2, to >= from ? to - from + 1 : 0);

    for (ii=from-1;ii<to;ii++) {
        sindex= (char **) sarray[s1];
        sw1=sstring(ii);
        sindex= (char **) sarray[s2];
        snew(count,sw1,0);
        count++;
    }
    sarrayhi[s2]=count;
    Licpy(ARGR, s2);
}


void RxSArrayRegFunctions()
{
    RxRegFunction("SCREATE",    R_screate,      0);
    RxRegFunction("SRESIZE",    R_sresize,      0);
    RxRegFunction("SSET",       R_sset,         0);
    RxRegFunction("SGET",       R_sget,         0);
    RxRegFunction("SSWAP",      R_sswap,        0);
    RxRegFunction("SCLC",       R_sclc,         0);
    RxRegFunction("SFREE",      R_sfree,        0);
    RxRegFunction("SQSORT",     R_sqsort,       0);
    RxRegFunction("SHSORT",     R_shsort,       0);
    RxRegFunction("SREVERSE",   R_sreverse,     0);
    RxRegFunction("SMERGE",     R_smerge,       0);
    RxRegFunction("SSEARCH",    R_ssearch,      0);
    RxRegFunction("SCHANGE",    R_schange,      0);
    RxRegFunction("SCOUNT",     R_scount,       0);
    RxRegFunction("SDROP",      R_sdrop,        0);
    RxRegFunction("SKEEP",      R_skeep,        0);
    RxRegFunction("SKEEPAND",   R_skeepand,     0);
    RxRegFunction("SSUBSTR",    R_ssubstr,      0);
    RxRegFunction("SWORD",      R_sword,        0);
    RxRegFunction("SINTERSECT", R_sintersect,   0);
    RxRegFunction("SDIFFERENCE",R_sdifference,  0);
    RxRegFunction("SLSTR",      R_slstr,        0);
    RxRegFunction("SSELECT",    R_sselect,      0);
    RxRegFunction("SARRAY",     R_sarray,       0);
    RxRegFunction("SLIST",      R_slist,        0);
    RxRegFunction("SCOPY",      R_scopy,        0);
    RxRegFunction("SINSERT",    R_sinsert,      0);
    RxRegFunction("SPASTE",     R_spaste,      0);
    RxRegFunction("SDEL",       R_sdel,         0);
    RxRegFunction("SEXTRACT",   R_sextract,     0);
    RxRegFunction("SUPPER",     R_supper,       0);
    RxRegFunction("__SUNIFY",   R_sunify,       0);
} /* RxSArrayRegFunctions() */
