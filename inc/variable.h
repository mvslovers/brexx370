/*
 * $Id: variable.h,v 1.6 2008/07/15 07:40:07 bnv Exp $
 * $Log: variable.h,v $
 * Revision 1.6  2008/07/15 07:40:07  bnv
 * MVS, CMS support
 *
 * Revision 1.5  2006/01/26 10:30:14  bnv
 * Changed RxVar...Old() -> RxVar...Name()
 * Added: RxVarExposeInd
 *
 * Revision 1.4  2002/06/11 12:37:56  bnv
 * Added: CDECL
 *
 * Revision 1.3  2001/06/25 18:52:04  bnv
 * Header -> Id
 *
 * Revision 1.2  1999/11/29 14:58:00  bnv
 * Changed: Some defines
 *
 * Revision 1.1  1998/07/02 17:35:50  bnv
 * Initial revision
 *
 */

#ifndef __VARIABLE_H__
#define __VARIABLE_H__

#include "bintree.h"

/* ------------ some defines ------------------ */
#define NO_CACHE	-1
#define NO_PROC		-1

/* --- Read VarTree options --- */
#define RVT_NOTHING	0
#define RVT_DEPTH	1
#define RVT_HEX		2

#define LEAFVAL(leaf)	&(((Variable*)((leaf)->value))->value)

typedef BinTree *Scope;

typedef
struct tvariable {
	Lstr	value;
	Scope	stem;
	bool	exposed;
} Variable;

/* --------------- function prototypes ----------------- */
void	__CDECL RxInitVariables(void);
void	__CDECL RxDoneVariables(void);
void	__CDECL RxVarFree(void *var);
PBinLeaf __CDECL RxVarAdd(Scope scope, PLstr name, int hasdot,
			PBinLeaf stemleaf );
PBinLeaf __CDECL RxVarFind(const Scope scope, const PBinLeaf litleaf,
			bool *found);
PBinLeaf __CDECL RxVarFindName(Scope scope, PLstr name, bool *found);
PBinLeaf __CDECL RxVarFindNameDir(Scope scope, PLstr name, bool *found);
void	__CDECL RxVarDel(Scope scope, PBinLeaf litleaf, PBinLeaf varleaf);
void	__CDECL RxVarDelName(Scope scope, PLstr name, PBinLeaf varleaf);
void	__CDECL RxVarDelInd(Scope scope, PLstr vars);
PBinLeaf __CDECL RxVarExpose(Scope scope, PBinLeaf litleaf);
void	__CDECL RxVarExposeInd(Scope scope, PLstr vars);
void	__CDECL RxVarSet(Scope scope, PBinLeaf varleaf, PLstr value);
void	__CDECL RxSetSpecialVar(int,long);
Scope	__CDECL RxScopeMalloc( void );
void	__CDECL RxScopeFree(Scope scope);
void	__CDECL RxScopeAssign(PBinLeaf leaf);

void	__CDECL RxVar2Str( PLstr result, PBinLeaf leaf, int option );
void	__CDECL RxReadVarTree(PLstr result, Scope scope, PLstr head,
			int option);

int	__CDECL RxRegPool(char *poolname, int (*getf)(PLstr,PLstr),
                        int (*setf)(PLstr,PLstr));
int	__CDECL RxPoolGet(PLstr,PLstr,PLstr);
int	__CDECL RxPoolSet(PLstr,PLstr,PLstr);

#undef EXTERN
#endif
