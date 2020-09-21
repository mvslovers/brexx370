#define __VARIABLE_C__

#include "ldefs.h"
#include <string.h>
#include <stdlib.h>
#include "rxmvsext.h"

#include "lerror.h"
#include "lstring.h"

#include "rexx.h"
#include "trace.h"
#include "bintree.h"
#include "interpre.h"
#include "variable.h"

#include "map.h"

typedef
struct	tpoolfunc {
    int (*get)(PLstr,PLstr);
    int (*set)(PLstr,PLstr);
} TPoolFunc;

typedef map_t(Lstr) map_PLstr_t;

extern	int	_trace;		            /* from interpret.c		*/

static	PLstr	varname;	        /* variable name of prev find	    */
static	Lstr	varidx;		        /* index of previous find	        */
static	Lstr	int_varname;	    /* used for the old RxFindVar	    */
static	BinTree	PoolTree;	        /* external pools tree		        */
Lstr	stemvaluenotfound;	        /* this is the value of a stem if   */

#define INITIAL_MAP_SIZE 16
#define BLACKLIST_SIZE 8

char *RX_VAR_BLACKLIST[BLACKLIST_SIZE] = {"RC", "LASTCC", "SIGL", "RESULT", "SYSPREF", "SYSUID", "SYSENV", "SYSISPF"};

/* --- local function prototypes --- */
int checkNameLength(long lName);
int checkValueLength(long lValue);
int checkVariableBlacklist(PLstr name);
static int GlobalPoolGet(PLstr name, PLstr value);
static int GlobalPoolSet(PLstr name,PLstr value);
static int ClistPoolGet(PLstr name, PLstr value);
static int ClistPoolSet(PLstr name,PLstr value);


map_PLstr_t globalVariables;

/* -------------- RxInitVariables ---------------- */
void __CDECL
RxInitVariables(void)
{
    LINITSTR(int_varname)
    LINITSTR(varidx)
    LINITSTR(stemvaluenotfound);
    Lfx(&varidx,250);

    BINTREEINIT(PoolTree);

    map_init(&globalVariables);

    RxRegPool("GLOBAL", GlobalPoolGet, GlobalPoolSet);
    if (isEXEC()) {
        RxRegPool("CLIST", ClistPoolGet, ClistPoolSet);
    }
} /* RxInitVariables */

/* -------------- RxDoneVariables ---------------- */
void __CDECL
RxDoneVariables(void)
{
    LFREESTR(int_varname);
    LFREESTR(varidx);
    LFREESTR(stemvaluenotfound);

    map_deinit(&globalVariables);
    BinDisposeLeaf(&PoolTree,PoolTree.parent,FREE);
} /* RxDoneVariables */

/* ---------------- RxVarFree -------------------- */
void __CDECL
RxVarFree(void *var)
{
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
    if (v->exposed == _rx_proc-1)
        v->exposed = NO_PROC;
} /* RxVarFree */

/* ---------------- RxVarAdd ------------------ */
/* adds a variable only if it is does not exist	*/
/* if the variable is a stem then a call to     */
/* VarFind must be done first to initialise     */
/* several variables                            */
/* -------------------------------------------- */
PBinLeaf __CDECL
RxVarAdd(Scope scope, PLstr name, int hasdot, PBinLeaf stemleaf )
{
    Variable *var,*var2;
    BinTree	*tree;
    Lstr	aux;

    if (hasdot==0) {
        LINITSTR(aux);		/* create memory */
        Lstrcpy(&aux,name);
        LASCIIZ(aux);
        tree = scope;
        var = (Variable *)MALLOC(sizeof(Variable),"Var");
        LINITSTR(var->value);
        Lfx(&(var->value),1);
        var->exposed = NO_PROC;
        var->stem    = NULL;
        return BinAdd(tree,&aux,var);
    } else {
        /* and the "varidx" must have the index from	*/
        /* from VarFind					*/
        /* also "stemleaf" must be the stem of the leaf */

        if (stemleaf==NULL) {	/* we must create the stem */
            LINITSTR(aux);
            Lstrcpy(&aux,varname);
            LASCIIZ(aux);
            tree = scope;
            var = (Variable *)MALLOC(sizeof(Variable),"StemVar");
            LINITSTR(var->value);
            var->exposed = NO_PROC;
            var->stem    = RxScopeMalloc();
            BinAdd(tree,&aux,var);
        } else
            var = (Variable*)(stemleaf->value);

        LINITSTR(aux); Lfx(&aux,1);
        Lstrcpy(&aux,&varidx);	/* make a copy of idx */
        LASCIIZ(aux);

        if (var->stem==NULL)
            var->stem = RxScopeMalloc();
        tree = var->stem;
        var2 = (Variable *)MALLOC(sizeof(Variable),"IdxVar");
        LINITSTR(var2->value);
        if (LLEN(var->value))
            Lstrcpy(&(var2->value),&(var->value));
        else
            Lfx(&(var2->value),1);
        var2->exposed = NO_PROC;
        var2->stem    = NULL;
        return BinAdd(tree,&aux,var2);
    }
} /* RxVarAdd */

/* ------------------ RxVarFind ----------------------- */
/* Search for a variable in the variables scope		*/
/* On input:						*/
/*	scope	: scope to use				*/
/*		(for variables indexes it uses the	*/
/*		current scope _proc[_rx_proc].scope	*/
/*	litleaf	: variables litleaf			*/
/*	found	: if variable is found			*/
/* Returns:						*/
/*		: returns a BinLeaf of variable		*/
/*		when a) variable is found (found=TRUE)	*/
/*		b) variable is an array an the		*/
/*		actuall variable is not found		*/
/*		but the tree head exist (found=FALSE)	*/
/* ---------------------------------------------------- */
PBinLeaf __CDECL
RxVarFind(const Scope scope, const PBinLeaf litleaf, bool *found)
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
            cmp = STRCMP(LSTR(*name), LSTR(leaf->key));
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
        if (Rx_id!=NO_CACHE && infidx->id==Rx_id)
            leaf = infidx->leaf[0];
        else {
/**
////			LASCIIZ(varname);
**/
            leaf = tree->parent;
            while (leaf != NULL) {
                cmp = STRCMP(LSTR(*varname), LSTR(leaf->key));
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
            } else
                infidx->id = NO_CACHE;
        }

        /* construct index */
        LZEROSTR(varidx);
        curscope = _proc[_rx_proc].scope;
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
                    cmp = STRCMP(LSTR(*aux), LSTR(leafidx->key));
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
        if (_trace)
            if (_proc[_rx_proc].trace == intermediates_trace) {
                int	i;
                FPUTS("       >C>  ",STDERR);
                for (i=0;i<_nesting; i++) FPUTC(' ',STDERR);
                FPUTC('\"',STDERR);
                Lprint(STDERR,varname);
                Lprint(STDERR,&varidx);
                FPUTS("\"\n",STDERR);
            }

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
            if (!LISNULL(*LEAFVAL(leaf)))
                Lstrcpy(&stemvaluenotfound, LEAFVAL(leaf));
            else {
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

/* ------------------ RxVarFindName ------------------ */
PBinLeaf __CDECL
RxVarFindName(Scope scope, PLstr name, bool *found)
{
    Scope	stemscope;
    BinTree *tree;
    PBinLeaf leaf,leafidx;
    Lstr	aux;
    int	hasdot,start,stop;
    register unsigned char	*ch;

    /* search for a '.' except in the last character */
    ch = MEMCHR(LSTR(*name),'.',LLEN(*name)-1);
    if (ch)
        hasdot = (size_t)((unsigned char huge *)ch - (unsigned char huge *)LSTR(*name) + 1);
    else
        hasdot = 0;

    tree = scope;
    if (!hasdot) {		/* simple variable */
        leaf = BinFind(tree,name);
        *found = (leaf != NULL);
        return leaf;
    } else {
        LINITSTR(aux);
        varname = &int_varname;
        _Lsubstr(varname,name,1,hasdot);
        leaf = BinFind(tree,varname);

        LZEROSTR(varidx);
        LASCIIZ(*name);
        stop = hasdot+1;	/* after dot */
        ch++;
        while (1) {
            while (*ch=='.') {
                /* concatanate a dot '.' */
                L2STR(&varidx);
                LSTR(varidx)[LLEN(varidx)] = '.';
                LLEN(varidx)++;
                ch++; stop++;
            }
            if (!*ch) break;

            start = stop;	/* find next dot */
            while (*ch && *ch!='.') {
                ch++; stop++;
            }
            _Lsubstr(&aux,name,start,stop-start);
            /* search for variable */
            tree = scope;
            leafidx = BinFind(tree,&aux);

            if (leafidx)
                Lstrcat(&varidx,LEAFVAL(leafidx));
            else {
                Lupper(&aux);
                Lstrcat(&varidx,&aux);
            }
        }

        /* free strings */
        LFREESTR(aux);

        if (leaf==NULL) {
            *found = FALSE;
            Lstrcpy(&stemvaluenotfound,varname);
            Lstrcat(&stemvaluenotfound,&varidx);
            return NULL;
        }
        stemscope = ((Variable*)(leaf->value))->stem;

        if (stemscope==NULL) {
            if (!LISNULL(*LEAFVAL(leaf)))
                Lstrcpy(&stemvaluenotfound,LEAFVAL(leaf));
            else {
                Lstrcpy(&stemvaluenotfound,varname);
                Lstrcat(&stemvaluenotfound,&varidx);
            }
            *found = FALSE;
            return leaf;
        }

        tree = stemscope;
        leafidx = BinFind(tree,&varidx);

        if (leafidx==NULL) {	/* not found */
            *found = FALSE;
            if (!LISNULL(*LEAFVAL(leaf)))
                Lstrcpy(&stemvaluenotfound,LEAFVAL(leaf));
            else {
                Lstrcpy(&stemvaluenotfound,varname);
                Lstrcat(&stemvaluenotfound,&varidx);
            }
            return leaf;	/* return stem leaf */
        } else {
            *found = TRUE;
            return leafidx;
        }
    }
} /* RxVarFindName */

/* --------------- RxVarDel ------------------- */
void __CDECL
RxVarDel(Scope scope, PBinLeaf litleaf, PBinLeaf varleaf)
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

/* --------------- RxVarDelName ------------------- */
void __CDECL
RxVarDelName(Scope scope, PLstr name, PBinLeaf varleaf)
{
    IdentInfo	*inf;
    Variable	*var;
    BinTree *tree;
    PBinLeaf leaf;
    unsigned char	*ch;

    var = (Variable*)(varleaf->value);

    /* search for a dot '.' except in the last character */
    ch = MEMCHR(LSTR(*name),'.',LLEN(*name)-1);

    if (var->exposed>=0) {		/* --- free only data --- */
        LFREESTR(var->value);
        LINITSTR(var->value);
        Lstrcpy(&(var->value),name);
        if (var->stem)
            RxScopeFree(var->stem);
    } else
    if (ch) {
        LFREESTR(var->value);
        LINITSTR(var->value);
        Lstrcpy(&(var->value),varname);
        Lstrcat(&(var->value),&varidx);
    } else {
        tree = scope;
        BinDel(tree,name,RxVarFree);

        /* Search in the litterals tree to see if it exist */
        leaf = BinFind(&rxLitterals,name);
        if (leaf) {
            inf = (IdentInfo*)(leaf->value);
            inf->id = NO_CACHE;
        }
    }
} /* RxVarDelName */

/* ------------- RxVarDelInd ----------------- */
void __CDECL
RxVarDelInd(Scope scope, PLstr vars)
{
    Lstr	name;
    long	w,i;
    int	found;
    PBinLeaf	leaf;

    LINITSTR(name);
    w = Lwords(vars);
    for (i=1; i<=w; i++) {
        Lword(&name,vars,i);
        Lupper(&name);
        leaf = RxVarFindName(scope,&name,&found);
        if (found)
            RxVarDelName(scope,&name,leaf);
    }
    LFREESTR(name);
} /* RxVarDelInd */

/* -------------- RxVarExpose ----------------- */
PBinLeaf __CDECL
RxVarExpose(Scope scope, PBinLeaf litleaf)
{
    IdentInfo	*inf;
    Variable	*var, *stemvar;
    Scope	oldscope;
    BinTree *tree;
    PBinLeaf leaf, stemleaf;
    Lstr	aux;
    int	oldcurid;
    int	found;

    inf = (IdentInfo*)(litleaf->value);

    /* --- first test to see if it is allready exposed --- */
    leaf = RxVarFind(scope,litleaf,&found);
    if (found)
        return leaf;
    else {
        if (leaf) {	/* then it is an array and the head is only found */
            var = (Variable*)(leaf->value);
            if (var->exposed != NO_PROC)
                return leaf;	/* don't worry head is allready exposed */
        }
    }

    /* --- else search in the old scope for variable --- */
    oldscope = _proc[ _rx_proc-1 ].scope;

    /* --- change curid since we are dealing with old scope --- */
    oldcurid = Rx_id;
    Rx_id = NO_CACHE;		/* something that doesn't exist */
    leaf = RxVarFind(oldscope,litleaf,&found);
    Rx_id = oldcurid;

    if (!found) {
        /* added it to the tree */
        leaf = RxVarAdd(oldscope,
            &(litleaf->key),
            inf->stem,
            leaf);
        if (inf->stem) {
            Lstrcpy(LEAFVAL(leaf),varname);
            Lstrcat(LEAFVAL(leaf),&varidx);
        } else
            Lstrcpy(LEAFVAL(leaf),&(litleaf->key));
    }
    var = (Variable*)(leaf->value);
    if (var->exposed == NO_PROC)
        var->exposed = _rx_proc-1;	/* to who it belongs */

    /* === now create a node in the new variable scope === */

    if (inf->stem==0) {
        LINITSTR(aux);		/* create memory */
        Lstrcpy(&aux,&(litleaf->key));
        LASCIIZ(aux);
        tree = scope;
        return BinAdd(tree,&aux,var);
    } else {
        tree = scope;
        stemleaf = BinFind(tree,varname);
        if (!stemleaf) {
            LINITSTR(aux);
            Lstrcpy(&aux,varname);
            LASCIIZ(aux);
            stemvar = (Variable *)MALLOC(sizeof(Variable),"ExposedStemVar");
            LINITSTR(stemvar->value);
            stemvar->exposed = NO_PROC;
            stemvar->stem    = RxScopeMalloc();
            BinAdd(tree,&aux,stemvar);
        } else
            stemvar = (Variable*)(stemleaf->value);

        LINITSTR(aux);
        Lstrcpy(&aux,&varidx);	/* make a copy of idx */
        LASCIIZ(aux);

        if (stemvar->stem==NULL)
            stemvar->stem = RxScopeMalloc();

        tree = stemvar->stem;
        return BinAdd(tree,&aux,var);
    }
} /* RxVarExpose */

/* ------------- RxVarExposeInd ------------- */
void __CDECL
RxVarExposeInd(Scope scope, PLstr vars)
{
    Lstr	name;
    long	w,i;
    PBinLeaf	litleaf;

    LINITSTR(name);
    w = Lwords(vars);
    for (i=1; i<=w; i++) {
        Lword(&name,vars,i);
        Lupper(&name);
        litleaf = BinFind(&rxLitterals,&name);
        if (litleaf)
            RxVarExpose(scope,litleaf);
    }
    LFREESTR(name);
} /* RxVarExposeInd */

/* -------------- RxVarSet ------------------ */
void __CDECL
RxVarSet( Scope scope, PBinLeaf varleaf, PLstr value )
{
    IdentInfo	*inf;
    PBinLeaf	leaf;
    int	found;

    inf = (IdentInfo*)(varleaf->value);
    if (inf->id == Rx_id) {
        leaf = inf->leaf[0];
        Lstrcpy(LEAFVAL(leaf), value);
    } else {
        leaf = RxVarFind(scope,varleaf,&found);
        if (found)
            Lstrcpy(LEAFVAL(leaf), value);
        else {
            /* added it to the tree */
            leaf = RxVarAdd(scope,
                &(varleaf->key),
                inf->stem,
                leaf);
            Lstrcpy(LEAFVAL(leaf),value);

            if (inf->stem==0) {
                inf->id = Rx_id;
                inf->leaf[0] = leaf;
            }
        }
    }
} /* RxVarSet */

/* ----------------- RxSetSpecialVar ------------------- */
void __CDECL
RxSetSpecialVar( int rcsigl, long num )
{
    PBinLeaf	varleaf;
    Lstr		value;

    switch (rcsigl) {
        case RCVAR:
            varleaf = RCStr;
            break;
        case SIGLVAR:
            varleaf = siglStr;
            break;
    }

    LINITSTR(value)
    Lfx(&value,0);
    Licpy(&value,num);
    RxVarSet(_proc[_rx_proc].scope,varleaf,&value);
    LFREESTR(value)
} /* RxSetSpecialVar */

/* --------------- RxScopeMalloc ---------------- */
Scope __CDECL
RxScopeMalloc( void )
{
    static Scope	scope;

    scope = (Scope)MALLOC(sizeof(BinTree),"Scope");
    BINTREEINIT(scope[0]);
    return scope;
} /* RxScopeMalloc */

/* ---------------- RxScopeFree ----------------- */
void __CDECL
RxScopeFree(Scope scope)
{
    int	i;
    if (scope)
        BinDisposeLeaf(&(scope[0]),scope[0].parent,RxVarFree);
} /* RxScopeFree */

/* ================ VarTreeAssign ================ */
static void
VarTreeAssign(PBinLeaf leaf, PLstr str, size_t mlen)
{
    Variable	*v;

    if (!leaf) return;
    if (leaf->left)
        VarTreeAssign(leaf->left,str,mlen);
    if (leaf->right)
        VarTreeAssign(leaf->right,str,mlen);

    v = (Variable*)(leaf->value);
    if (LMAXLEN(v->value) > mlen) {
        LFREESTR(v->value);
        LINITSTR(v->value);
        Lfx(&(v->value),LLEN(*str));
    }
    Lstrcpy(&(v->value),str);
} /* VarTreeAssign */

/* ---------------- RxScopeAssign ---------------- */
void __CDECL
RxScopeAssign(PBinLeaf varleaf)
{
    int	i;
    size_t	mlen;
    PLstr	str;
    Variable *v;
    Scope	scope;

    v = (Variable*)(varleaf->value);
    scope = v->stem;
    if (!scope) return;
    str = &(v->value);

    /* determine minimum MAXLEN */
    mlen = LNORMALISE(LLEN(*str)) + LEXTRA;
    VarTreeAssign(scope[0].parent,str,mlen);
} /* RxScopeAssign */

/* ---------------- RxVar2Str ------------------- */
void __CDECL
RxVar2Str( PLstr result, PBinLeaf leaf, int option )
{
    Lstr	aux;
    Variable	*var;

    Lstrcat(result,&(leaf->key));
    Lcat(result,"=\"");

    var = (Variable*)(leaf->value);
    if (option==RVT_HEX) {
        LINITSTR(aux);
        if (!LISNULL(var->value)) {
            Lc2x(&aux,&(var->value));
            Lstrcat(result,&aux);
        }
        Lcat(result,"\"x");
        LFREESTR(aux);
    } else {
        if (!LISNULL(var->value))
            Lstrcat(result,&(var->value));
        Lcat(result,"\"");
    }
} /* RxVar2Str */

/* ---------------- RxScanVarTree --------------- */
static void
RxScanVarTree( PLstr result, PBinLeaf leaf, PLstr head, int depth, int option )
{
    Variable	*var;
    Lstr		aux;

    if (leaf==NULL) return;
    RxScanVarTree(result,leaf->left,head,depth+1,option);
    RxScanVarTree(result,leaf->right,head,depth+1,option);

    if (option==RVT_DEPTH) {
        LINITSTR(aux);	Lfx(&aux,1);
        Licpy(&aux,depth);
        Lstrcat(result,&aux);
        Lcat(result," ");
        LFREESTR(aux);
    }
    if (head)
        Lstrcat(result,head);

    RxVar2Str(result, leaf, option);

    Lcat(result,"\n");

    var = (Variable*)(leaf->value);
    if (var->stem)
        RxReadVarTree(result,var->stem,&(leaf->key),option);
} /* RxScanVarTree */

/* ---------------- RxReadVarTree --------------- */
void __CDECL
RxReadVarTree(PLstr result, Scope scope, PLstr head, int option)
{
    RxScanVarTree(result,scope[0].parent,head,0,option);
} /* RxReadVarTree */

/* ================ POOL functions =================== */

/* ----- GlobalPoolGet ----- */
static int
GlobalPoolGet(PLstr name, PLstr value)
{
    Lstr bla;
    PLstr tmp;

    L2STR(name);
    LASCIIZ(*name)

    tmp = map_get(&globalVariables, (const char*) LSTR(*name));

    if (tmp != NULL && !LISNULL(*tmp)) {
        Lstrcpy(value, tmp);
        return 0;
    } else {
        LZEROSTR(*value)
        return 0;
    }

} /* GlobalPoolGet */

/* ----- GlobalPoolSet ----- */
static int
GlobalPoolSet(PLstr name, PLstr value)
{
    L2STR(name);
    LASCIIZ(*name)

    return map_set(&globalVariables, (const char *) LSTR(*name), *value);

} /* GlobalPoolSet */

/* ----- ClistPoolGet ----- */
static int
ClistPoolGet(PLstr name, PLstr value)
{
    int rc = 0;
    void *wk;

    RX_IKJCT441_PARAMS_PTR params;

    /* do not handle special vars here */
    if (checkVariableBlacklist(name) != 0)
        return -1;

    /* NAME LENGTH < 1 OR > 252 */
    if (checkNameLength(name->len) != 0)
        return -2;

    params = malloc(sizeof(RX_IKJCT441_PARAMS));
    wk     = malloc(256);

    memset(wk,     0, sizeof(wk));
    memset(params, 0, sizeof(RX_IKJCT441_PARAMS));

    params->ecode    = 18;
    params->nameadr  = (char *)name->pstr;
    params->namelen  = name->len;
    params->valueadr = 0;
    params->valuelen = 0;
    params->wkadr    = wk;

    rc = call_rxikj441 (params);

    if (value->maxlen < params->valuelen) {
        Lfx(value,params->valuelen);
    }
    if (value->pstr != params->valueadr) {
        strncpy((char *)value->pstr,params->valueadr,params->valuelen);
    }

    value->len    = params->valuelen;
    value->maxlen = params->valuelen;
    value->type   = LSTRING_TY;

    free(wk);
    free(params);

    return rc;
} /* ClistPoolGet */

/* ----- ClistPoolSet ----- */
static int
ClistPoolSet(PLstr name, PLstr value)
{
    int rc = 0;
    void *wk;

    RX_IKJCT441_PARAMS_PTR params;

    /* convert numeric values to a string */
    if (value->type != LSTRING_TY) {
        L2str(value);
    }

    /* terminate all strings with a binary zero */
    LASCIIZ(*name);
    LASCIIZ(*value);

    /* do not handle special vars here */
    if (checkVariableBlacklist(name) != 0)
        return -1;

    /* NAME LENGTH < 1 OR > 252 */
    if (checkNameLength(name->len) != 0)
        return -2;

    /* VALUE LENGTH < 0 OR > 32767 */
    if (checkValueLength(value->len) != 0)
        return -3;

    params = malloc(sizeof(RX_IKJCT441_PARAMS));
    wk     = malloc(256);

    memset(wk,     0, sizeof(wk));
    memset(params, 0, sizeof(RX_IKJCT441_PARAMS)),

            params->ecode    = 2;
    params->nameadr  = (char *)name->pstr;
    params->namelen  = name->len;
    params->valueadr = (char *)value->pstr;
    params->valuelen = value->len;
    params->wkadr    = wk;

    rc = call_rxikj441(params);

    free(wk);
    free(params);

    return rc;

} /* ClistPoolSet */

/* -------------- PoolGet -------------- */
int __CDECL
RxPoolGet( PLstr pool, PLstr name, PLstr value )
{
    PBinLeaf leaf;
    int	poolnum;
    int	found;

    /* check to see if it is internal pool */
    if ( LTYPE(*pool)==LINTEGER_TY ||
        (LTYPE(*pool)==LSTRING_TY && _Lisnum(pool)==LINTEGER_TY)) {

        Lstr	str;
        poolnum = (int)Lrdint(pool);
        if (poolnum<0)
            poolnum = _rx_proc+poolnum;
        if (poolnum<0 || poolnum>_rx_proc)
            return 'P';

        /* search if it is a valid name */
        if (Ldatatype(name,'S')==0) {
            Lstrcpy(value,name);
            return 'F';
        }
        /* search in the appropriate scope */
        LINITSTR(str);	/* translate to upper case */
        Lstrcpy(&str,name); Lupper(&str);
        leaf = RxVarFindName(_proc[poolnum].scope,&str,&found);
        if (found) {
            Lstrcpy(value,LEAFVAL(leaf));
            LFREESTR(str);
            return 0;
        } else {
            /* search for dot except last character */
            if (MEMCHR(LSTR(str),'.',LLEN(str)-1)!=NULL)
                Lstrcpy(value,&stemvaluenotfound);
            else
                Lstrcpy(value,&str);
            LFREESTR(str);
            return 'F';
        }
    }

    /* nope search the Pool tree */
    leaf = BinFind(&PoolTree,pool);
    if (!leaf) return 'P';

    if (((TPoolFunc*)(leaf->value))->get)
        found = (((TPoolFunc*)(leaf->value))->get)(name,value);
    if (found) return 'F';
    return 0;
} /* PoolGet */

/* -------------- PoolSet -------------- */
int __CDECL
RxPoolSet( PLstr pool, PLstr name, PLstr value )
{
    PBinLeaf leaf;
    int	poolnum;
    int	found;

    /* check to see if it is internal pool */
    if (LLEN(*name)==0)
        Lerror(ERR_INCORRECT_CALL,0);
    if ( LTYPE(*pool)==LINTEGER_TY ||
        (LTYPE(*pool)==LSTRING_TY && _Lisnum(pool)==LINTEGER_TY)) {
        Lstr	str;
        poolnum = (int)Lrdint(pool);
        if (poolnum<0)
            poolnum = _rx_proc+poolnum;
        if (poolnum<0 || poolnum>_rx_proc)
            return 'P';
        /* search in the appropriate scope */
        LINITSTR(str);	/* translate to upper case */
        Lstrcpy(&str,name); Lupper(&str);
        leaf = RxVarFindName(_proc[poolnum].scope,&str,&found);

        /* set the new value */
        if (found) {
            /* Just copy the new value */
            Lstrcpy(LEAFVAL(leaf),value);
        } else {
            int	hasdot;
            /* search for dot except last character */
            hasdot = (MEMCHR(LSTR(str),'.',LLEN(str)-1)!=NULL);

            /* added it to the tree */
            leaf = RxVarAdd(_proc[poolnum].scope,
                &str, hasdot, leaf);
            Lstrcpy(LEAFVAL(leaf),value);
        }
        LFREESTR(str);
        return 0;
    }

    /* nope search the Pool tree */
    leaf = BinFind(&PoolTree,pool);
    if (!leaf) return 'P';

    if (((TPoolFunc*)(leaf->value))->set)
        found = (((TPoolFunc*)(leaf->value))->set)(name,value);
    if (found) return 'F';
    return 0;
} /* PoolSet */

/* ------------ RxRegPool -------------- */
int __CDECL
RxRegPool(char *poolname, int (*getf)(PLstr,PLstr),
            int (*setf)(PLstr,PLstr))
{
    Lstr	pn;
    TPoolFunc	*pf;

    LINITSTR(pn);
    Lscpy(&pn,poolname);
    Lupper(&pn);

    pf = (TPoolFunc*)MALLOC(sizeof(TPoolFunc),"PoolFunc");
    pf->get = getf;
    pf->set = setf;
    BinAdd(&PoolTree,&pn,pf);

    LFREESTR(pn);
    return 0;
} /* RxRegPool */

/* internal functions */
int checkNameLength(long lName)
{
    int rc = 0;
    if (lName < 1)
        rc = -1;
    if (lName > 252)
        rc =  1;

    return rc;
}

int checkValueLength(long lValue)
{
    int rc = 0;

    if (lValue == 0)
        rc = -1;
    if (lValue > 32767)
        rc =  1;

    return rc;
}

int checkVariableBlacklist(PLstr name)
{
    int rc = 0;
    int i  = 0;

    Lupper(name);

    for (i = 0; i < BLACKLIST_SIZE; ++i) {
        if (strcmp((char *)name->pstr,RX_VAR_BLACKLIST[i]) == 0)
            return -1;
    }

    return rc;
}
