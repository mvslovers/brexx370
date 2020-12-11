#define __BMEM_H__

#include "metal.h"
#include "printf.h"
#include "lstring.h"
#include "variable.h"
#include "irx.h"
#include "rxmvsext.h"

const int __libc_arch       = 0;

static	PLstr	varname;	        /* variable name of prev find	    */
static	Lstr	varidx;		        /* index of previous find	        */
static  Lstr	stemvaluenotfound;	        /* this is the value of a stem if   */

static  int     Rx_id;

#ifndef MIN
# define MIN(a,b)	(((a)<(b))?(a):(b))
#endif
#ifndef MAX
# define MAX(a,b)	(((a)>(b))?(a):(b))
#endif

typedef struct shvblock     SHVBLOCK;
typedef struct envblock     ENVBLOCK;
typedef struct tidentinfo {
    int	id;
    int	stem;
    PBinLeaf leaf[1];
} IdentInfo;

int fetch (ENVBLOCK *envblock, SHVBLOCK *shvblock);
int set   (ENVBLOCK *envblock, SHVBLOCK *shvblock);
int drop  (ENVBLOCK *envblock, SHVBLOCK *shvblock);
int next  (ENVBLOCK *envblock, SHVBLOCK *shvblock);

int IRXEXCOM(char *irxid, void *parm2, void *parm3, SHVBLOCK *shvblock, ENVBLOCK *envblock, int *retval) {
    int rc = 0;

    // first parameter must be 'IRXEXCOM'
    if (memcmp(irxid, "IRXEXCOM", 8) != 0) {
        rc = -1;
    }

    // second and third parameter must be equal
    if (rc == 0) {
        if (memcmp(parm2, parm3, 4) != 0) {
            rc = -1;
        }
    }

    // fourth parameter must not be NULL
    if (rc == 0) {
        if (!shvblock) {
            rc = -1;
        }
    }

    // get ENVBLOCK
    if (rc == 0) {
        if (!envblock) {
            envblock = _xregs(0);
        }

        if (!envblock || strncmp((char *) envblock->envblock_id, "ENVBLOCK", 8) != 0) {
            // rc = 28;
            // TODO: remove this in production release
            envblock = getEnvBlock();
        }
    }

    // check
    if (rc == 0) {
        if (shvblock->shvcode != 'N') {
            // reset pointer to last variable returned by 'N'
            ((RX_ENVIRONMENT_CTX_PTR) envblock->envblock_userfield)->lastLeaf = NULL;
        }

        switch (shvblock->shvcode) {
            case 'F':
                // reset pointer to last variable returned by 'N'
                ((RX_ENVIRONMENT_CTX_PTR) envblock->envblock_userfield)->lastLeaf = NULL;

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
                shvblock->shvret = shvbadf;
                rc = -1;
        }
    }

    /*
    if (retval) {
        *retval = rc;
    }
    */

    _clrbuf();

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
            memcpy(shvblock->shvvala, (LEAFVAL(varLeaf))->pstr, MIN(shvblock->shvbufl, (LEAFVAL(varLeaf))->len));
            shvblock->shvvall = MIN(shvblock->shvbufl, (LEAFVAL(varLeaf))->len);
            rc = 0;
        } else {
            rc = 8;
        }
    } else {
        rc = 12;
    }

    _clrbuf();

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
            //Lsccpy(&aux, shvblock->shvnama);
            Lscpy(&aux, shvblock->shvnama);
            LASCIIZ(aux)
            var = (Variable *) _malloc(sizeof(Variable));
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

    _clrbuf();

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
        //TODO: stallPtrList = ((RX_ENVIRONMENT_CTX_PTR) envblock->envblock_userfield)->stallPtr;  // verkette liste??
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

    _clrbuf();

    return rc;
}

int next  (ENVBLOCK *envblock, SHVBLOCK *shvblock) {
    int rc;

    bool found = FALSE;

    BinTree *vars;
    PBinLeaf varLeaf;
    PBinLeaf lastLeaf;

    if (envblock != NULL) {
        vars = ((RX_ENVIRONMENT_CTX_PTR) envblock->envblock_userfield)->variables;
        lastLeaf = (void *) (uintptr_t) ((RX_ENVIRONMENT_CTX_PTR) envblock->envblock_userfield)->lastLeaf;
    } else {
        vars = NULL;
    }

    if (vars != NULL) {
        if (lastLeaf == NULL) {
            varLeaf = BinMin(vars->parent);
        } else {
            varLeaf = BinSuccessor(lastLeaf);
        }

        found = (varLeaf != NULL);
        if (found) {
            int bytes;

            ((RX_ENVIRONMENT_CTX_PTR) envblock->envblock_userfield)->lastLeaf = varLeaf;

            // check size of buffer for variable name
            if (shvblock->shvuser < LLEN(varLeaf->key)) {
                bytes = shvblock->shvuser;
                shvblock->shvret = shvtrunc;
            } else {
                bytes = LLEN(varLeaf->key);
            }

            // copy variable name
            memcpy(shvblock->shvnama, LSTR(varLeaf->key), bytes);
            shvblock->shvnaml = LLEN(varLeaf->key);

            // check size of buffer for variable name
            if (shvblock->shvbufl < LLEN(*(LEAFVAL(varLeaf)))) {
                bytes = shvblock->shvbufl;
                shvblock->shvret = shvtrunc;
            } else {
                bytes = LLEN(*(LEAFVAL(varLeaf)));
            }

            // copy variable name
            memcpy(shvblock->shvvala, LSTR(*(LEAFVAL(varLeaf))), bytes);
            shvblock->shvvall = LLEN(*(LEAFVAL(varLeaf)));

            printf("FOO> %.*s=%.*s \n",   shvblock->shvnaml, (char *)shvblock->shvnama,
                   shvblock->shvvall, (char *) shvblock->shvvala);

            rc = 0;
        } else {
            // no more variables found

            // reset pointer to last variable returned by 'N'
            ((RX_ENVIRONMENT_CTX_PTR) envblock->envblock_userfield)->lastLeaf = NULL;

            // inform the caller
            shvblock->shvret = shvlvar;

            rc = 0;
        }
    } else {
        rc = 12;
    }

    _clrbuf();

    return rc;
}

void *getEctEnvBk() {
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

    ectenvbk = getEctEnvBk();
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

/* ---------------- NEEDED BREXX VARIABLE MANAGEMENT FUNCTIONS ----------------- */
void RxScopeFree(Scope scope) {
    if (scope)
        BinDisposeLeaf(&(scope[0]),scope[0].parent,RxVarFree);
} /* RxScopeFree */

PBinLeaf RxVarFind(Scope scope, PBinLeaf litleaf, bool *found)
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
