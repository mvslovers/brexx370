#define __BMEM_H__

#include "printf.h"
#include "lstring.h"
#include "variable.h"
#include "irx.h"
#include "rxmvsext.h"

int __libc_arch = 0;

// this is needed to enable the linker to find printf
#define printf printf_
#define uintptr_t unsigned long

#define MALLOC(s, d)    malloc_or_die(s)
#define REALLOC(p, s)   realloc_or_die(p,s)
#define	FREE		    free_or_die

#define LFREESTR(s)	{if ((s).pstr) FREE((s).pstr); }

static	PLstr	varname;	        /* variable name of prev find	    */
static	Lstr	varidx;		        /* index of previous find	        */
Lstr	stemvaluenotfound;	        /* this is the value of a stem if   */

static  int     Rx_id;

static char line[80];
static int  linePos = 0;

#ifndef SVC
#define SVC
struct SVCREGS {
    int R0;
    int R1;
    int R15;
};
#endif

#ifndef MIN
# define MIN(a,b)	(((a)<(b))?(a):(b))
#endif
#ifndef MAX
# define MAX(a,b)	(((a)>(b))?(a):(b))
#endif

typedef struct shvblock     SHVBLOCK;
typedef struct envblock     ENVBLOCK;
typedef struct workblok_ext WRKBLKEXT;

typedef struct tidentinfo {
    int	id;
    int	stem;
    PBinLeaf leaf[1];
} IdentInfo;

void BRXSVC(int svc, struct SVCREGS *regs);

int fetch (ENVBLOCK *envblock, SHVBLOCK *shvblock);
int set   (ENVBLOCK *envblock, SHVBLOCK *shvblock);
int drop  (ENVBLOCK *envblock, SHVBLOCK *shvblock);
int next  (ENVBLOCK *envblock, SHVBLOCK *shbblock);

/* internal helper functions */
void *getEnvBlock ();
void _tput        (const char *data);
void _clearBuffer ();

/* needed brexx function */
void *malloc_or_die  (size_t size);
void *realloc_or_die (void *ptr, size_t size);
void  free_or_die    (void *ptr);

void Lsccpy (PLstr to, unsigned char *from);

int IRXEXCOM(char *irxid, void *parm2, void *parm3, SHVBLOCK *shvblock, ENVBLOCK *envblock, int *retVal) {

    int rc = 0;

    // first parameter must be 'IRXEXCOM'
    if (MEMCMP(irxid, "IRXEXCOM", 8) != 0) {
        rc = -1;
    }

    // second and third parameter must be equal
    if (rc == 0) {
        if (MEMCMP(parm2, parm3, 4) != 0) {
            rc = -1;
        }
    }

    // fourth parameter must not be NULL
    if (rc == 0) {
        if (shvblock == NULL) {
            rc = -1;
        }
    }

    // get ENVBLOCK
    if (rc == 0) {
        if (envblock == NULL) {
            envblock = getEnvBlock();
        }

        if (envblock == NULL) {
            rc = -1;
        }
    }

    // check
    if (rc == 0) {
        switch (shvblock->_shvblock_union1._shvblock_struct1._shvcode) {
            case 'F':
                rc = fetch(envblock, shvblock);
                break;

            case 'S':
                rc = set(envblock, shvblock);
                break;

            case 'D':
                rc = drop(envblock, shvblock);
                break;

            case 'N':
                rc = next(envblock, shvblock);
                break;

            default:
                printf("ERR> UNKNOWN SHVCODE GIVEN. => %c \n", shvblock->_shvblock_union1._shvblock_struct1._shvcode);
                rc = -1;
        }
    }

    _clearBuffer();

    return rc;
}

int fetch (ENVBLOCK *envblock, SHVBLOCK *shvblock) {
    int rc;
    int found;

    BinTree *vars;
    PBinLeaf varLeaf;

    Lstr lName;

    if (envblock != NULL) {
        vars = ((RX_ENVIRONMENT_CTX_PTR) envblock->envblock_userfield)->variables;
    } else {
        vars = NULL;
    }

    if (vars != NULL) {
        lName.pstr = shvblock->shvnama;
        lName.len = shvblock->shvnaml;
        lName.maxlen = shvblock->shvnaml;
        lName.type = LSTRING_TY;

        LASCIIZ(lName)

        varLeaf = BinFind(vars, &lName);
        found = (varLeaf != NULL);
        if (found) {
            MEMCPY(shvblock->shvvala, (LEAFVAL(varLeaf))->pstr, MIN(shvblock->shvbufl, (LEAFVAL(varLeaf))->len));
            shvblock->shvvall = MIN(shvblock->shvbufl, (LEAFVAL(varLeaf))->len);

            rc = 0;
        } else {
            rc = 8;
        }
    } else {
        rc = 12;
    }

    _clearBuffer();

    return rc;
}

int set   (ENVBLOCK *envblock, SHVBLOCK *shvblock) {
    int rc;
    int found;

    BinTree *vars;
    PBinLeaf varLeaf;

    Lstr lName;
    Lstr lValue;
    Lstr aux;

    Variable *var;

    if (envblock != NULL) {
        vars = ((RX_ENVIRONMENT_CTX_PTR) envblock->envblock_userfield)->variables;
    } else {
        vars = NULL;
    }

    if (vars != NULL) {

        lName.pstr = shvblock->shvnama;
        lName.len = shvblock->shvnaml;
        lName.maxlen = shvblock->shvnaml;
        lName.type = LSTRING_TY;

        lValue.pstr = shvblock->shvvala;
        lValue.len = shvblock->shvvall;
        lValue.maxlen = shvblock->shvvall;
        lValue.type = LSTRING_TY;

        varLeaf = BinFind(vars, &lName);
        found = (varLeaf != NULL);

        if (found) {
            /* Just copy the new value */
            Lstrcpy(LEAFVAL(varLeaf), &lValue);

            rc = 0;
        } else {
            /* added it to the tree */
            /* create memory */
            LINITSTR(aux)
            Lsccpy(&aux, shvblock->shvnama);
            LASCIIZ(aux)
            var = (Variable *) malloc_or_die(sizeof(Variable));
            LINITSTR(var->value)
            Lfx(&(var->value), lValue.len);
            var->exposed = NO_PROC;
            var->stem = NULL;

            varLeaf = BinAdd(vars, &aux, var);
            Lstrcpy(LEAFVAL(varLeaf), &lValue);

            rc = 0;
        }
    } else {
        rc = 12;
    }

    return rc;
}

int drop  (ENVBLOCK *envblock, SHVBLOCK *shvblock) {
    int rc = 0;
    int found = FALSE;

    BinTree *vars;
    PBinLeaf varLeaf;

    BinTree *literals;
    PBinLeaf litLeaf;

    IdentInfo *info = NULL;

    int proc_id;

    Lstr name;

    if (envblock != NULL) {
        literals  = ((RX_ENVIRONMENT_CTX_PTR) envblock->envblock_userfield)->literals;
        vars      = ((RX_ENVIRONMENT_CTX_PTR) envblock->envblock_userfield)->variables;
        proc_id   = ((RX_ENVIRONMENT_CTX_PTR) envblock->envblock_userfield)->proc_id;
        Rx_id     = proc_id;
    } else {
        rc = 28;
    }

    if (rc == 0) {
        if (vars != NULL) {
            name.pstr = shvblock->shvnama;
            name.len = shvblock->shvnaml;
            name.maxlen = shvblock->shvnaml;
            name.type = LSTRING_TY;

            LASCIIZ(name)

            if (literals != NULL) {
                litLeaf = BinFind(literals, &name);
                if (litLeaf != NULL) {
                    info = (IdentInfo*)(litLeaf->value);
                }
            }

            if (info->id == proc_id) {
                varLeaf = info->leaf[0];
                RxVarDel(vars, litLeaf, varLeaf);
            } else {
                varLeaf = RxVarFind(vars, litLeaf, &found);
                if (found) {
                    RxVarDel(vars, litLeaf, varLeaf);
                }
            }

            info->id = NO_CACHE;

        } else {
            rc = -1;
        }
    }

    _clearBuffer();

    return rc;
}

int next  (ENVBLOCK *envblock, SHVBLOCK *shvblock) {
    int rc;
    int found;

    BinTree *tree;
    PBinLeaf leaf;

    Lstr lName;

    if (envblock != NULL) {
        tree = envblock->envblock_userfield;
    } else {
        tree = NULL;
    }

    if (tree != NULL) {
        lName.pstr = shvblock->shvnama;
        lName.len = shvblock->shvnaml;
        lName.maxlen = shvblock->shvnaml;
        lName.type = LSTRING_TY;

        LASCIIZ(lName)

        leaf = BinFind(tree, &lName);
        found = (leaf != NULL);
        if (found) {
            MEMCPY(shvblock->shvvala, (LEAFVAL(leaf))->pstr, MIN(shvblock->shvbufl, (LEAFVAL(leaf))->len));
            shvblock->shvvall = MIN(shvblock->shvbufl, (LEAFVAL(leaf))->len);

            rc = 0;
        } else {
            rc = 8;
        }
    } else {
        rc = 12;
    }

    _clearBuffer();

    return rc;
}

void *_getEctEnvBk() {
    void **psa;           // PAS      =>   0 / 0x00
    void **ascb;          // PSAAOLD  => 548 / 0x224
    void **asxb;          // ASCBASXB => 108 / 0x6C
    void **lwa;           // ASXBLWA  =>  20 / 0x14
    void **ect;           // LWAPECT  =>  32 / 0x20
    void **ectenvbk;      // ECTENVBK =>  48 / 0x30

    psa = 0;
    ascb = psa[137];
    asxb = ascb[27];
    lwa = asxb[5];
    ect = lwa[8];

    ectenvbk = ect + 12;   // 12 * 4 = 48

    return ectenvbk;
}

void *getEnvBlock() {
    void **ectenvbk;
    ENVBLOCK *envblock;

    ectenvbk = _getEctEnvBk();
    envblock = *ectenvbk;

    if (envblock != NULL) {
        if (strncmp((char *) envblock->envblock_id, "ENVBLOCK", 8) == 0) {
            return envblock;
        } else {
            return NULL;
        }
    } else {
        return NULL;
    }
}

/* needed LSTRING functions */
void Lfx(const PLstr s, const size_t len) {
    size_t max;

    if (LISNULL(*s)) {
        LSTR(*s) = (unsigned char *) malloc_or_die((max = LNORMALISE(len)) + LEXTRA);
        memset(LSTR(*s), 0, max);
        LLEN(*s) = 0;
        LMAXLEN(*s) = max;
        LTYPE(*s) = LSTRING_TY;
    } else if (LMAXLEN(*s) < len) {
        LSTR(*s) = (unsigned char *) realloc_or_die(LSTR(*s), (max = LNORMALISE(len)) + LEXTRA);
        LMAXLEN(*s) = max;
    }
}

void Lsccpy(const PLstr to, unsigned char *from) {
    size_t len;

    if (!from)
        Lfx(to, len = 0);
    else {
        Lfx(to, len = strlen((const char *) from));
        MEMCPY(LSTR(*to), from, len);
    }
    LLEN(*to) = len;
    LTYPE(*to) = LSTRING_TY;
}

void Lstrcpy(const PLstr to, const PLstr from) {
    if (LISNULL(*to)) {
        Lfx(to, 31);
    }

    if (LLEN(*from) == 0) {
        LLEN(*to) = 0;
        LTYPE(*to) = LSTRING_TY;
    } else {
        if (LMAXLEN(*to) <= LLEN(*from)) Lfx(to, LLEN(*from));
        switch (LTYPE(*from)) {
            case LSTRING_TY:
                MEMCPY(LSTR(*to), LSTR(*from), LLEN(*from));
                break;

            case LINTEGER_TY:
                LINT(*to) = LINT(*from);
                break;

            case LREAL_TY:
                LREAL(*to) = LREAL(*from);
                break;
        }
        LTYPE(*to) = LTYPE(*from);
        LLEN(*to) = LLEN(*from);
    }
}

int _Lstrcmp(const PLstr a, const PLstr b) {
    int r;

    if ((r = MEMCMP(LSTR(*a), LSTR(*b), MIN(LLEN(*a), LLEN(*b)))) != 0)
        return r;
    else {
        if (LLEN(*a) > LLEN(*b))
            return 1;
        else if (LLEN(*a) == LLEN(*b)) {
            if (LTYPE(*a) > LTYPE(*b))
                return 1;
            else if (LTYPE(*a) < LTYPE(*b))
                return -1;
            return 0;
        } else
            return -1;
    }
}

/* mvs memory allocation */
void * _getmain       (size_t length) {
    long *ptr;

    struct SVCREGS registers;
    registers.R0 = ((int)length) + 12;
    registers.R1 = -1;
    registers.R15 = 0;

    BRXSVC(10, &registers);

    if (registers.R15 == 0) {
        ptr = (void *) (uintptr_t) registers.R1;
        ptr[0] = 0xDEADBEAF;
        ptr[1] = (((long) (ptr)) + 12);
        ptr[2] = length;
    } else {
        ptr = NULL;
    }

    return (void *) (((uintptr_t) (ptr)) + 12);
}

void   _freemain      (void *ptr) {
    struct SVCREGS registers;
    registers.R0 = 0;
    registers.R1 = (int) (uintptr_t) ptr;
    registers.R15 = -1;

    BRXSVC(10, &registers);
}

void * malloc_or_die  (size_t size) {
    void *nPtr;

    nPtr = _getmain(size);
    if (!nPtr) {
        _tput("ERR>   GETMAIN FAILED");
        return NULL;
    }

    return nPtr;
}

void * realloc_or_die (void *oPtr, size_t size) {
    void *nPtr;

    nPtr = _getmain(size);

    if (!nPtr) {
        _tput("ERR>   GETMAIN FAILED");
        return NULL;
    }

    return nPtr;

    /* TODO: added beacause get rid of failed realloc's */
    /*
    size++;

    ptr = realloc(ptr,size);

    if (!ptr) {
        Lstr lerrno;

        LINITSTR(lerrno)
        Lfx(&lerrno,31);

        Lscpy(&lerrno,strerror(errno));

        Lerror(ERR_REALLOC_FAILED,0);
        fprintf(stderr, "errno: %s\n",strerror(errno));

        LFREESTR(lerrno);
        raise(SIGSEGV);
    }

    return ptr;
    */
}

void   free_or_die    (void *ptr) {
    if (ptr != NULL) {
        _freemain(ptr);
    }
}

/* internal terminal i/o */
void _tput(const char *data) {
    struct SVCREGS registers;

    registers.R0 = strlen(data);
    registers.R1 = (unsigned int) data & 0x00FFFFFF;
    registers.R15 = 0;

    BRXSVC(93, &registers);
}

void _putchar(char character) {
    line[linePos] = character;
    linePos++;

    if (character ==  '\n' || linePos == 80) {
        _tput(line);
        bzero(line, 80);
        linePos = 0;
    }
}

void _clearBuffer() {
    if (linePos > 0) {
        _tput(line);
        bzero(line, 80);
        linePos = 0;
    }
}

/* other stuff to be checked  */
/* ------------------ RxVarFind ----------------------- */
PBinLeaf RxVarFind(const Scope scope, const PBinLeaf litleaf, bool *found)
{
    IdentInfo	*inf,*infidx;
    Scope	stemscope,curscope;
    BinTree *tree;
    PBinLeaf leaf,leafidx;
    PLstr	name,aux;
    int	i,cmp;
    size_t	l;

    name = &(litleaf->key);
    inf = (IdentInfo*)(litleaf->value);

    tree = scope;
    if (!inf->stem) {		/* simple variable */
        /* inline version of BinFind */
        /* leaf = BinFind(tree,name); */
        leaf = tree->parent;
        while (leaf != NULL) {
            cmp = _Lstrcmp(name, &leaf->key);
            if (cmp < 0)
                leaf = leaf->left;
            else
            if (cmp > 0) {
                if (leaf->isThreaded == FALSE) {
                    leaf = leaf->right;
                } else {
                    leaf = NULL;
                }
            }
            else
                break;
        }

        *found = (leaf != NULL);
        if (*found) {
            inf->id = Rx_id;
            inf->leaf[0] = leaf;
        }

        return leaf;
    } else {

        /* ======= first find array ======= */
        leafidx = inf->leaf[0];
        varname = &(leafidx->key);
        infidx = (IdentInfo*)(leafidx->value);
        if (Rx_id!=NO_CACHE && infidx->id==Rx_id) {
            leaf = infidx->leaf[0];
        } else {
/**
////			LASCIIZ(varname);
**/
            leaf = tree->parent;
            while (leaf != NULL) {
                cmp = _Lstrcmp(varname, &leaf->key);
                if (cmp < 0)
                    leaf = leaf->left;
                else
                if (cmp > 0) {
                    if (leaf->isThreaded == FALSE) {
                        leaf = leaf->right;
                    } else {
                        leaf = NULL;
                    }
                }
                else
                    break;
            }
            if (leaf) {
                infidx->id = Rx_id;
                infidx->leaf[0] = leaf;
            } else {
                infidx->id = NO_CACHE;
            }
        }

        /* construct index */
        LZEROSTR(varidx);
        curscope = scope;
        for (i=1; i<inf->stem; i++) {
            if (i!=1) {
                /* append a dot '.' */
                LSTR(varidx)[LLEN(varidx)] = '.';
                LLEN(varidx)++;
            }
            leafidx = inf->leaf[i];

            if (leafidx==NULL) continue;

            infidx = (IdentInfo*)(leafidx->value);
            aux = &(leafidx->key);
            if (infidx==NULL) {
                L2STR(aux);
                l = LLEN(varidx)+LLEN(*aux);
                if (LMAXLEN(varidx) <= l) Lfx(&varidx, l);
                MEMCPY(LSTR(varidx)+LLEN(varidx),LSTR(*aux),LLEN(*aux));
                LLEN(varidx) = l;
            } else
            if (Rx_id!=NO_CACHE && infidx->id==Rx_id) {
                register PLstr	lptr;
                leafidx = infidx->leaf[0];
                lptr = LEAFVAL(leafidx);
                L2STR(lptr);
                l = LLEN(varidx)+LLEN(*lptr);
                if (LMAXLEN(varidx) <= l) Lfx(&varidx, l);
                MEMCPY(LSTR(varidx)+LLEN(varidx),LSTR(*lptr),LLEN(*lptr));
                LLEN(varidx) = l;
            } else {
                /* search for aux-variable */
                tree = curscope;

                /* inline version of BinFind */
                /* leafidx = BinFind(tree,&aux); */
                leafidx = tree->parent;
                while (leafidx != NULL) {
                    cmp = _Lstrcmp(aux, &leafidx->key);
                    if (cmp < 0)
                        leafidx = leafidx->left;
                    else
                    if (cmp > 0) {
                        if (leafidx->isThreaded == FALSE) {
                            leafidx = leafidx->right;
                        } else {
                            leafidx = NULL;
                        }
                    }
                    else
                        break;
                }
                if (leafidx) {
                    register PLstr	lptr;
                    infidx->id = Rx_id;
                    infidx->leaf[0] = leafidx;
                    lptr = LEAFVAL(leafidx);
                    L2STR(lptr);
                    l = LLEN(varidx)+LLEN(*lptr);
                    if (LMAXLEN(varidx) <= l) Lfx(&varidx, l);
                    MEMCPY(LSTR(varidx)+LLEN(varidx),LSTR(*lptr),LLEN(*lptr));
                    LLEN(varidx) = l;
                } else {
                    Lupper(aux);
                    Lstrcat(&varidx,aux);
                }
            }
        }

        L2STR(&varidx);

        if (leaf==NULL) {
            *found = FALSE;
            Lstrcpy(&stemvaluenotfound,varname);
            Lstrcat(&stemvaluenotfound,&varidx);
            return NULL;
        }
        stemscope = ((Variable*)(leaf->value))->stem;
        if (stemscope==NULL) {
            if (!LISNULL(*LEAFVAL(leaf)))
                Lstrcpy(&stemvaluenotfound, LEAFVAL(leaf));
            else {
                Lstrcpy(&stemvaluenotfound,varname);
                Lstrcat(&stemvaluenotfound,&varidx);
            }
            *found = FALSE;
            return leaf;
        }

        tree = stemscope;
        /* inline version of BinFind */
        /* leafidx = BinFind(tree,&varidx); */
        leafidx = tree->parent;
        while (leafidx != NULL) {
            /* Inline version of Compare */
            {
                register unsigned char *a,*b;
                unsigned char *ae,*be;
                a = LSTR(varidx);
                ae = a + LLEN(varidx);
                b = LSTR(leafidx->key);
                be = b + LLEN(leafidx->key);
                for(;(a<ae) && (b<be) && (*a==*b); a++,b++) ;
                if (a==ae && b==be)
                    cmp = 0;
                else
                if (a<ae && b<be)
                    cmp = (*a<*b) ? -1 : 1 ;
                else
                    cmp = (a<ae) ? 1 : -1 ;
            }

            if (cmp < 0)
                leafidx = leafidx->left;
            else
            if (cmp > 0) {
                if (leafidx->isThreaded == FALSE) {
                    leafidx = leafidx->right;
                } else {
                    leafidx = NULL;
                }
            }
            else
                break;
        }

        if (leafidx==NULL) {	/* not found */
            *found = FALSE;
            if (!LISNULL(*LEAFVAL(leaf))) {
                Lstrcpy(&stemvaluenotfound, LEAFVAL(leaf));
            } else {
                Lstrcpy(&stemvaluenotfound,varname);
                Lstrcat(&stemvaluenotfound,&varidx);
            }
            return leaf;	/* return stem leaf */
        } else {
            *found = TRUE;
            return leafidx;
        }
    }
} /* RxVarFind */

/* ---------------- RxScopeFree ----------------- */
void RxScopeFree(Scope scope) {
    int	i;
    if (scope)
        BinDisposeLeaf(&(scope[0]),scope[0].parent,RxVarFree);
} /* RxScopeFree */

void RxVarFree(void *var) {
    Variable	*v;

    v = (Variable*)var;
    if (v->exposed==NO_PROC) {
        if (v->stem) {
            RxScopeFree(v->stem);
            FREE(v->stem);
        }
        LFREESTR(v->value);
        FREE(var);
    } else
    if (v->exposed == Rx_id-1)
        v->exposed = NO_PROC;
} /* RxVarFree */

/* --------------- RxVarDel ------------------- */
void RxVarDel(Scope scope, PBinLeaf litleaf, PBinLeaf varleaf)
{
    IdentInfo	*inf;
    Variable	*var;
    PLstr	name;
    BinTree *tree;

    name = &(litleaf->key);
    inf = (IdentInfo*)(litleaf->value);
    var = (Variable*)(varleaf->value);

    if (!inf->stem) {	/* ==== simple variable ==== */
        if (var->exposed>=0) {	/* --- free only data --- */
            if (!LISNULL(var->value)) {
                LFREESTR(var->value);
                LINITSTR(var->value);
                Lstrcpy(&(var->value),name);
            }
            if (var->stem)
                RxScopeFree(var->stem);
        } else {
            tree = scope;
            BinDel(tree,name,RxVarFree);
            inf->id = NO_CACHE;
        }
    } else {
/**
//		if (var->exposed>=0) {
**/
        LFREESTR(var->value);
        LINITSTR(var->value);
        Lstrcpy(&(var->value),varname);
        Lstrcat(&(var->value),&varidx);
/**
//		} else {
//				* find leaf of stem *
//			tree = scope + hashchar[ (byte)LSTR(*name)[0] ];
//			stemleaf = BinFind(tree,varname);
//			var = (Variable*)(stemleaf->value);
//				* find the actual bintree of variable *
//			tree = var->stem + hashchar[ (byte)LSTR(varidx)[0] ];
//			BinDel(tree,&varidx,RxVarFree);
//			inf->id = NO_CACHE;
//		}
**/
    }
} /* RxVarDel */

int toupper(int c)
{
    if(((c >= 'a') && (c <= 'i'))
       ||((c >= 'j') && (c <= 'r'))
       ||((c >= 's') && (c <= 'z')))
    {
        /* make uppercase */
        c+=0x40;
    }

    return c;
}

void Lupper( const PLstr s ) {
    size_t	i;
    L2STR(s);
    for (i=0; i<LLEN(*s); i++)
        //LSTR(*s)[i] = l2u[ (byte) LSTR(*s)[i] ];
        LSTR(*s)[i] = toupper((byte) LSTR(*s)[i]);
} /* Lupper */

void Lstrcat( const PLstr to, const PLstr from ) {
    size_t	l;

    if (LLEN(*from)==0) return;

    if (LLEN(*to)==0) {
        Lstrcpy( to, from );
        return;
    }

    L2STR(to);
    L2STR(from);

    l = LLEN(*to)+LLEN(*from);
    if (LMAXLEN(*to) < l)
        Lfx(to, MAX(l,LMAXLEN(*to) + 4095));
    MEMCPY( LSTR(*to) + LLEN(*to), LSTR(*from), LLEN(*from) );
    LLEN(*to) = l;
} /* Lstrcat */

/* dummy impls */
int  Lstrbeg (const PLstr str, const PLstr pre) {
    _tput("FOO> DUMMY LSTRBEG CALLED");
    return 0;
}

long Lwords  (const PLstr from) {
    _tput("FOO> DUMMY LWORDSCALLED");
    return 0;
}

void Lword   (const PLstr to, const PLstr from, long n) {
    _tput("FOO> DUMMY LWORD CALLED");
}

void L2str   (const PLstr s )
{
    _tput("FOO> DUMMY L2STR CALLED");
}

int  Lstrcmp (const PLstr a, const PLstr b) {
    return _Lstrcmp(a, b);
}

void Lcat    (const PLstr to, const char *from) {
    _tput("FOO> DUMMY LCAT CALLED");
}

void Lscpy   (const PLstr to, const char *from) {
    _tput("FOO> DUMMY Lscpy CALLED");
}

#ifdef __CROSS__
void BRXSVC(int svc, struct SVCREGS *regs) {

}
#endif

/*
*
*     Return Code Flags (Stored in SHVRET):
*
SHVCLEAN EQU   X'00' Execution was OK
SHVNEWV  EQU   X'01' Variable did not exist
SHVLVAR  EQU   X'02' Last variable transferred (for "N")
SHVTRUNC EQU   X'04' Truncation occurred during "Fetch"
SHVBADN  EQU   X'08' Invalid variable name
SHVBADV  EQU   X'10' Value too long
SHVBADF  EQU   X'80' Invalid function code (SHVCODE)
*/