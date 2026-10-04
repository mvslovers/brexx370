/* -------------------------------------------------------------------------------------
 * Linked lists: LLCREATE, LLADD, LLGET, ... and S2LL/LL2S, the conversion
 * from and to a string array. Moved from rxmvs.c (#302).
 * -------------------------------------------------------------------------------------
 */
#include <stdio.h>
#include <string.h>
#include "rxll.h"
#include "rexx.h"
#include "rxdefs.h"
#include "rxmvsext.h"
#include "lstring.h"
#include "lerror.h"
#include "sarray.h"

#define llMagic	  0xCAFEBABE

struct root *llist[llmax];
struct node *llistcur[llmax];
int llchecked=-1;    // last checked Linked List
#define linknode(predecessor,node,successor) {predecessor->next= (int *) node; \
                               node->next=successor;\
                               node->previous= (int *) predecessor;}
#define updatenode(node,predecessor,successor) {node->next=successor;\
                               node->previous= (int *) predecessor;}
/* a list number from the caller must name a created list: it indexed
 * llist[] unchecked, LLGET(-1) or LLGET(32) read beside the array.
 * llcheck() reports it; Lerror() does not return, the return is for
 * the reader (and the analysers) */
#define llvalid(l) ((l) >= 0 && (l) < llmax && llist[l] != NULL)
#define getllname(list) { get_i0(1, list); \
                          if (!llvalid(list)) { llcheck(list); return; } }
#define CHECK_BIT(var,pos) ((var) & (1<<(pos)))
#define llADDRreturn(addr) {if (llist[llname]->flags == 0) Licpy(ARGR,(long) addr); \
                            else {sprintf(sNumber, "%x", (unsigned) addr); \
                            Lscpy(ARGR, sNumber);}              \
                            return;}

struct node* llSetADDR(const PLstr address, int llname) {
    struct node *addr;
      if (llist[llname]->flags == 0) addr = (struct node *) Lrdint(address);
     else {
        Lx2d(ARGR, address, 0);    /* using ARGR as temp field for conversion */
        addr = (struct node *) Lrdint(ARGR);
    }
    if (addr == NULL) Lerror(ERR_INCORRECT_CALL,0);
    else if ((unsigned) addr->magic!=llMagic) {
       Lfailure ("Invalid Linked List entry address", LSTR(*address), "", "", "");
    }
    return addr;
}
/* the list's name, cut to its 15 characters; strcpy() ran past it */
static void llSetName(int llname, const PLstr name) {
    snprintf(llist[llname]->name, sizeof(llist[llname]->name), "%.*s",
             (int) LLEN(*name), (const char *) LSTR(*name));
}

int llcheck(int llname) {
    char sllname[16];
    if (llname < 0 || llname >= llmax) {
        snprintf(sllname, sizeof(sllname), "%d", llname);
        Lfailure("invalid Linked List specified: ", sllname, "", "", "");
        return -1;
    }
    if (llist[llname] == 0) {
        snprintf(sllname, sizeof(sllname), "%d", llname);
        Lfailure("Linked List not yet initialised: ", sllname, "", "", "");
        return -1;
    }
    llchecked=llname;     // successfully checked
    return 0;
}

void R_llcreate(__unused int func) {
    int llname;

    for (llname = 0; llname < llmax; ++llname) {
        if (llist[llname] == 0) break;
    }
    if (llname >= llmax) {     /* it took llist[32], beside the array */
        Lfailure ( "Linked List Stack stack full, no allocation occurred","","","","");
        return;
    }
    llist[llname] = MALLOC(sizeof(struct root),"LLROOT");
    memset(llist[llname],0,sizeof(struct root));
    if (ARGN==0) strcpy(llist[llname]->name, "UNNAMED");
    else {
        get_s(1)
        LASCIIZ(*ARG1);
        llSetName(llname, ARG1);
    }
    llistcur[llname]= (struct node *) llist[llname];
    llist[llname]->next=0 ;
    llist[llname]->previous=0 ;
    llist[llname]->last=0 ;
    llist[llname]->count=0 ;
    llist[llname]->added=0 ;
    llist[llname]->deleted=0 ;
    llist[llname]->flags= 0;

    Licpy(ARGR,llname);
}
struct node * llnew(int llname,char * record) {
    struct node *new = NULL, *current;

    current = (struct node *) llist[llname]->last;
    if (current == NULL) current = (struct node *) llist[llname];
    new = MALLOC(sizeof(struct node) + strlen(record), "LLENTRY");
    new->next = NULL;
    new->magic = llMagic;
    strcpy(new->data, record);
    linknode(current, new, NULL);

    llistcur[llname] = new;
    llist[llname]->last = (int *) new;
    llist[llname]->count++;
    llist[llname]->added++;
    return new;
}
void unlinkll(struct node *current,int llname) {
    struct node *fwd, *prev;
    if (llist[llname]->count <= 1) {  // if 1: this is the last entry, just about to be deleted
        llist[llname]->next = NULL;
        llist[llname]->previous = NULL;
        llist[llname]->last = NULL;
        llistcur[llname]= (struct node *) llist[llname];
        if (llist[llname]->count < 1) return ;
        goto setstats;
    }
    // 1. save pointer of element to delete
    fwd = (struct node *) current->next;
    prev = (struct node *) current->previous;
    // 2. link previous element to succeeding element (referred to by element to delete)
    //    if there is no previous element, link referred element to LL root
    if (llistcur[llname]->previous == (int *) llist[llname]) llist[llname]->next = (int *) fwd;
    else prev->next = (int *) fwd;
    // 3. link succeeding element to previous element (referred to by element to delete)
    if (fwd != NULL) fwd->previous = (int *) prev;
    // 4. set new active element
    if ((struct root *) prev == llist[llname]) prev = NULL;
    if (prev == NULL) llistcur[llname] = (struct node *) llist[llname]->next;
    else if (fwd == NULL) {
        llistcur[llname] = (struct node *) prev;
        llist[llname]->last = (int *) prev;
    } else llistcur[llname] = (struct node *) fwd;

    setstats:
    llist[llname]->count--;
    llist[llname]->deleted++;
}

void R_lladd(__unused int func) {
    struct node *new = NULL;
    int llname;
    char sNumber[32];

    getllname(llname);
    get_s(2);
    LASCIIZ(*ARG2);

    new=llnew(llname, (char *)LSTR(*ARG2));
    llADDRreturn(new);
}
void R_llinsert(int func) {
    struct node *new = NULL, *current,*prev;
    int llname ;
    char sNumber[32];

    getllname(llname);

    if (ARGN==3) llistcur[llname]= llSetADDR(ARG3,llname);  // address provided as input
    current=llistcur[llname];
    if (current->next==NULL && llist[llname]->next==NULL) {
        R_lladd(func) ;
        return;
    }
    LASCIIZ(*ARG2)
    new = MALLOC(sizeof(struct node)+LLEN(*ARG2)+16,"LLENTRY");
    new->magic=llMagic;
    strcpy(new->data, (const char *) LSTR(*ARG2));
    if ((int *) current==llist[llname]->next) prev = (struct node *) llist[llname];  // old record was first record
    else prev = (struct node *) current->previous;
    linknode(prev, new, (int *) current);
    current->previous= (int *) new;
    llistcur[llname] = (struct node *) new;
    llist[llname]->count++;
    llist[llname]->added++;
    llADDRreturn(new);
}
void R_llget(__unused int func) {
    struct node *iaddr;
    int llname,mode=0;

    getllname(llname)

    iaddr = llistcur[llname];
    if (ARGN > 1) {
        Lupper(ARG_OWN(2));
        if (strncmp((const char *) ARG2->pstr, "FIRST",3)     == 0) llistcur[llname] = (struct node *) llist[llname]->next;
        else if (strncmp((const char *) ARG2->pstr, "LAST",2) == 0) llistcur[llname] = (struct node *) llist[llname]->last;
        else if (strncmp((const char *) ARG2->pstr, "LIFO",4) == 0) {
            llistcur[llname] = (struct node *) llist[llname]->last;
            mode=1;
        }
        else if (strncmp((const char *) ARG2->pstr, "FIFO",4) == 0) {
            llistcur[llname] = (struct node *) llist[llname]->next;
            mode=1;
        }
        else if (strncmp((const char *) ARG2->pstr, "NEXT",2) == 0) llistcur[llname] = (struct node *) iaddr->next;
        else if (strncmp((const char *) ARG2->pstr, "PREVIOUS",2) == 0) {
            if (iaddr==(struct node *) -1) llistcur[llname] = (struct node *) llist[llname]->last;
            else llistcur[llname] = (struct node *) iaddr->previous;
        }else llistcur[llname] = llSetADDR(ARG2,llname);
    } else {    // just one argument
      if (iaddr==(struct node *) llist[llname]) llistcur[llname]= (struct node *) iaddr->next;     // sits currently on position 0, display first record then
      else if (iaddr==(struct node *) -1) {   // position behind last record, don't change current element ,just print the last record
          iaddr= (struct node *) llist[llname]->last;
          Lscpy(ARGR,iaddr->data);
          return;
      }
    }
    if (llistcur[llname] == NULL || llist[llname]->next==NULL) Lscpy(ARGR, "$$EMPTY$$");
    else {
        Lscpy(ARGR, llistcur[llname]->data);
        if (mode==1) unlinkll(llistcur[llname],llname);
    }
 // return also new current pointer, this allows faster break out at "end of Linked List" reached
    if (llistcur[llname]==(struct node *)  llist[llname])setIntegerVariable("llcurrent", 0);
    else setIntegerVariable("llcurrent", (int) llistcur[llname]);
}

void R_llentry(__unused int func) {
    struct node *iaddr;
    int llname;

    getllname(llname);

    iaddr=llistcur[llname];
    printf("---------------------------------------------\n");
    printf("Linked List Entry %d (%s)\n",llname, llist[llname]->name);
    printf("---------------------------------------------\n");
    printf("Address  %x \n",(unsigned) llistcur[llname]);
    printf("Data     %s \n",llistcur[llname]->data);
    printf("Next     %x \n",(unsigned) llistcur[llname]->next);
    if (llistcur[llname]->previous==(int *)llist[llname])  printf("Previous %x \n",0);
    else printf("Previous %x \n",(unsigned) llistcur[llname]->previous);
}

void R_lllist(__unused int func) {
    struct node *current;
    int llname,count=0, from,tto;

    getllname(llname);

    get_oi(2,from);
    get_oi(3,tto);

    current= (struct node *) llist[llname]->next;
    printf("     Entries of Linked List: %d (%s)\n",llname,llist[llname]->name);
    printf("Entry Entry Address     Next    Previous      Data\n");
    printf("-------------------------------------------------------\n");
    while (current!= NULL) {
        count++;
        if ((count>=from) && ((tto>0 && count<=tto) || tto==0)) {
            printf("%5d ", count);
            printf("%10x ", (unsigned) current);
            printf(" %10x ", (unsigned) current->next);
            if (current->previous == (int *) llist[llname]) printf(" %10x", 0);
            else printf(" %10x", (unsigned) current->previous);
            printf("   %s \n", current->data);
        }
        current = (struct node *) current->next;
    }
    printf("Linked List address  %x       \n",(unsigned) llist[llname]);
    printf("Linked List contains %d Entries\n",count);
    printf("       List counter  %d Entries\n",llist[llname]->count);
    if ((int) llist[llname]==(int) llistcur[llname]) printf("Current active Entry %x \n",0);
    else printf("Current active Entry %x \n",(unsigned) llistcur[llname]);
    Licpy(ARGR,count);
    return ;
}

void R_llsearch(__unused int func) {
    struct node *current;
    int llname;

    getllname(llname);
    get_s(2)
    LASCIIZ(*ARG2);

    if (ARGN==3) {
        llistcur[llname] = llSetADDR(ARG3, llname);  // address provided as input
        current=llistcur[llname];
    } else current= (struct node *) llist[llname]->next;

    Licpy(ARGR,0);
    while (current!= NULL) {
        if (strstr(current->data,LSTR(*ARG2)) != NULL) {
           Licpy(ARGR, (long) current);
           break;
        }
        current = (struct node *) current->next;
    }
}

void R_ll2s(__unused int func) {
    struct node *current;
    int llname,count, from,tto,sname;

    getllname(llname);

    get_oi(2,from);
    get_oi(3,tto);
    get_oiv(4,sname,-1);
    if (sname<0) {
        R_screate(llist[llname]->count);
        sname = LINT(*ARGR);
    } else

    sindex= (char **) sarray[sname];
    count=sarrayhi[sname];

    current= (struct node *) llist[llname]->next;
    while (current!= NULL) {
       if ((count>=from) && ((tto>0 && count<=tto) || tto==0)) {
           snew(count,current->data,-1);
           count++;
        }
        current = (struct node *) current->next;
    }
    sarrayhi[sname] = count;
    Licpy(ARGR,sname);
}

void R_llcopy(__unused int func) {
    struct node *current;
    int ll1,ll2,count=0, from,tto;

    getllname(ll1);

    get_oi(2,from);
    from--;
    get_oi(3,tto);
    tto--;
    get_oiv(4,ll2,-1);
    get_sv(5);

    if (ll2<0) {
       R_llcreate(0);
       ll2 = LINT(*ARGR);
    }
    if (!llvalid(ll2)) { llcheck(ll2); return; }

    if (ARGN==5) llSetName(ll2, ARG5);

    current= (struct node *) llist[ll1]->next;
    while (current!= NULL) {
        if ((count>=from) && ((tto>0 && count<=tto) || tto<=0)) {
           llnew(ll2,current->data);
        }
        count++;
        current = (struct node *) current->next;
    }
    Licpy(ARGR,ll2);
}

void R_s2ll(__unused int func) {
    int sname,llname,ii,from,to;

    get_i0(1, sname);
    if (sname < 0 || sname >= sarraymax) { Lerror(ERR_INCORRECT_CALL, 0); return; }
    sindex= (char **) sarray[sname];
    get_oiv(2,from,1);
    get_oiv(3,to,sarrayhi[sname]);
    get_oiv(4,llname,-1);
    get_sv(5);

    if (llname<0) {
        R_llcreate(0);
        llname = LINT(*ARGR);
    }
    if (!llvalid(llname)) { llcheck(llname); return; }
    if (ARGN==5) llSetName(llname, ARG5);

    for (ii=from-1;ii<to;ii++) {
        llnew(llname,sstring(ii));
    }
    Licpy(ARGR, llname);
}

void R_lldetails(__unused int func) {
    struct node *current;
    int llname,count=0;
    char sNumber[32];

    getllname(llname);

    if (ARGN==2) {
        LASCIIZ(*ARG2);
        Lupper(ARG_OWN(2));
        if (LSTR(*ARG2)[0]=='C') Licpy(ARGR, (int) llist[llname]->count);
        else if (LSTR(*ARG2)[0]=='A') Licpy(ARGR, (int) llist[llname]->added);
        else if (LSTR(*ARG2)[0]=='D') Licpy(ARGR, (int) llist[llname]->deleted);
        else if (LSTR(*ARG2)[0]=='L') {
            current = (struct node *) llist[llname]->next;
            while (current != NULL) {
                count++;
                current = (struct node *) current->next;
            }
            Licpy(ARGR, count);
        }
        else if (LSTR(*ARG2)[0]=='F') {
            current = (struct node *) llist[llname]->next;
            while (current != NULL) {
                count++;
                current = (struct node *) current->next;
            }
            printf("Attributes of Linked List %d (%s)\n", llname,llist[llname]->name);
            printf("-------------------------------------------------------\n");
            printf("Entry Count     %d\n", llist[llname]->count);
            printf("     Listed     %d\n", count);
            printf("      Added     %d\n", llist[llname]->added);
            printf("    Deleted     %d\n", llist[llname]->deleted);
            snprintf(sNumber, sizeof(sNumber), "%x",(unsigned) llistcur[llname]);
            printf("Current Pointer %s\n", sNumber);
        }
    }
    else Licpy(ARGR, (int) llist[llname]->count);
}

void R_llset(__unused int func) {
    struct node *current;
    int llname, count;
    char mode, sNumber[32];

    getllname(llname)

    if (ARGN == 1) mode = 'N';
    else {
        Lupper(ARG_OWN(2));
        if (strncmp(LSTR(*ARG2), "POSITION", 2) == 0) mode = 'O';
        else if (strncmp(LSTR(*ARG2), "AMODE", 2)==0) {
            Lupper(ARG_OWN(3));
            if (strncmp(LSTR(*ARG3), "HEX", 2)== 0) llist[llname]->flags=1;
            else llist[llname]->flags=0;
            Licpy(ARGR,llist[llname]->flags);
            return;
        }
        else mode = LSTR(*ARG2)[0];
    }
    if (mode=='F') {                                                    // set to FIRST entry
        current= (struct node *) llist[llname];
        if (current==NULL) goto setfailed;
        if ((int *) current->next == NULL) llistcur[llname]=NULL;
        else llistcur[llname] = (struct node *) current->next;
    } else if (mode=='N') {                                             // set to NEXT entry
        current=llistcur[llname];
        if (current==NULL) goto setfailed;
        if ((int *) current->next == NULL) llistcur[llname]=NULL;
        else llistcur[llname] = (struct node *) current->next;
    }  else if (mode=='P') {                                            // set to PREVIOUS entry
        current=llistcur[llname];
        if (current==NULL) goto setfailed;
        if (current->previous==(int *)llist[llname]) llistcur[llname]=NULL;
        else llistcur[llname]= (struct node *) current->previous;
    } else if (mode=='C') {                                             // return CURRENT entry
    } else if (mode=='L') {                                             // set to LAST entry
        llistcur[llname]= (struct node *) llist[llname]->last;
    } else if (mode=='O') {                                             // POSITION to n.th entry
        if (ARGN!=3) Lfailure ("Record Number missing", "", "", "", "");
        count= Lrdint(ARG3);
        current= (struct node *) llist[llname];
        if (current==NULL) goto setfailed;
        if ((int *) current->next == NULL) goto setfailed;
        if (count<0) current= (struct node *) -1;     // position 0, sets prior to first record, -1 after last record
        else if (count>0) {   // locate record position
            current = (struct node *) current->next;
            count--;
            while (current != NULL && count > 0) {
                current = (struct node *) current->next;
                count--;
            }
        }
        if (current == NULL) llistcur[llname] = (struct node *) llist[llname]->last;
        else llistcur[llname] = current;
    } else if (mode=='A') {                                             // set to given entry ADDRESS
        if (ARGN!=3) Lfailure ("Linked List address missing", "", "", "", "");
        llistcur[llname]= llSetADDR(ARG3,llname);
    }
    llADDRreturn(llistcur[llname]);

    setfailed:
    Licpy(ARGR,-8);
    return ;
}
void R_llfree(__unused int func) {
    struct node *current,*todel;
    int llname;

    getllname(llname);

    current= (struct node *) llist[llname];
    if (current==NULL) {
        Licpy(ARGR,-8);
        return;
    }
    current= (struct node *) current->next;
    while (current!= NULL) {
        todel=current;
        current = (struct node *) current->next;
        FREE(todel);
    }
    FREE(llist[llname]);
    llist[llname] = NULL;      /* it stayed, for every later call to use */
    llistcur[llname] = NULL;
    Licpy(ARGR,0);
}

void R_llclear(__unused int func) {
    struct node *current,*todel;
    int llname;

    getllname(llname);

    current= (struct node *) llist[llname];
    if (current==NULL) {
        Licpy(ARGR,-8);
        return;
    }
    current= (struct node *) current->next;
    while (current!= NULL) {
        todel=current;
        current = (struct node *) current->next;
        FREE(todel);
    }
    llistcur[llname]= (struct node *) llist[llname];
    llist[llname]->next=0;
    llist[llname]->previous=0;
    llist[llname]->last=0;
    llist[llname]->count=0;
    llist[llname]->added=0;
    llist[llname]->deleted=0;
    llist[llname]->flags=0;

    Licpy(ARGR,0);
}

void R_lldel(__unused int func) {
    struct node *current;
    int llname;
    char sNumber[32];

    getllname(llname)

    if (ARGN==2) llistcur[llname]= llSetADDR(ARG2,llname);  // address provided as input
    current=llistcur[llname];
    if (current==NULL || llist[llname]->count < 1) {
        Licpy(ARGR,-8);
        return ;
    }
    unlinkll(current,llname);                // unlink element, new current element is set
    FREE(current);                       // now free memory of element to delete
    llADDRreturn(llistcur[llname]);
 }
void R_lldelink(__unused int func) {
    struct node *current;
    int llname ;
    char sNumber[32];

    getllname(llname) ;

    if (ARGN==2) llistcur[llname]=llSetADDR(ARG2,llname);  // address provided as input
    current=llistcur[llname];
    if (current==NULL) {
        Licpy(ARGR,-8);
        return ;
    }
    unlinkll(current,llname);
    current->next= (int *) -1;
    current->previous= (int *) -1;

    llADDRreturn(current);
}

void R_lllink(__unused int func) {
    struct node *tolink, *current,*prev;
    int llname;
    char sNumber[32];

    getllname(llname);

    tolink=llSetADDR(ARG2,llname);
    if (ARGN==3) {
        current=llSetADDR(ARG3,llname);
        snprintf(sNumber, sizeof(sNumber), "%x",(unsigned) current);
        if ((int) current->next == -1 || (int) current->previous == -1 ) Lfailure ("Linked List target address inactive, or do not belong to List: ", sNumber, "", "", "");
        llistcur[llname] = current;  // target address provided as input
    }
    if (llist[llname]->next==NULL) {  // empty llist
        linknode(llist[llname],tolink,NULL);
    } else {
        current = llistcur[llname];
        if (current == NULL) current = (struct node *) llist[llname];  // if no current element set it to first element

        if (current == (struct node *) llist[llname]) {  // old record was first record
            linknode(llist[llname], tolink, (int *) current);
            updatenode(current,llist[llname],NULL);
        } else {
            prev = (struct node *) current->previous;
            linknode(prev, tolink, (int *) current);
        }
    }
    llistcur[llname]= (struct node *) tolink;
    llist[llname]->count++;
    llADDRreturn(llistcur[llname]);
  }


void RxLlRegFunctions()
{
    RxRegFunction("LLCREATE",   R_llcreate,     0);
    RxRegFunction("LLADD",      R_lladd,        0);
    RxRegFunction("LLDEL",      R_lldel,        0);
    RxRegFunction("LLDELINK",   R_lldelink,     0);
    RxRegFunction("LLLINK",     R_lllink,       0);
    RxRegFunction("LLGET",      R_llget,        0);
    RxRegFunction("LLSET",      R_llset,        0);
    RxRegFunction("LLINSERT",   R_llinsert,     0);
    RxRegFunction("LLENTRY",    R_llentry,      0);
 //   RxRegFunction("LLENTRY2",   R_llentry2,     0);  // just for testing purposes!
    RxRegFunction("LLLIST",     R_lllist,       0);
    RxRegFunction("LLDETAILS",  R_lldetails,    0);
    RxRegFunction("LLFREE",     R_llfree,       0);
    RxRegFunction("LLCLEAR",    R_llclear,      0);
    RxRegFunction("LLCOPY",     R_llcopy,       0);
    RxRegFunction("LLSEARCH",   R_llsearch,     0);
    RxRegFunction("LL2S",       R_ll2s,         0);
    RxRegFunction("S2LL",       R_s2ll,         0);
} /* RxLlRegFunctions() */
