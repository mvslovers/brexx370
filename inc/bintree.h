/*
 * $Id: bintree.h,v 1.4 2008/07/15 07:40:07 bnv Exp $
 * $Log: bintree.h,v $
 * Revision 1.4  2008/07/15 07:40:07  bnv
 * MVS, CMS support
 *
 * Revision 1.3  2002/06/11 12:37:56  bnv
 * Added: CDECL
 *
 * Revision 1.2  2001/06/25 18:52:04  bnv
 * Header -> Id
 *
 * Revision 1.1  1998/07/02 17:35:50  bnv
 * Initial revision
 *
 */

#ifndef __BINTREE_H__
#define __BINTREE_H__

#include "lstring.h"

#ifdef __BINTREE_C__
#	define	EXTERN
#else
#	define	EXTERN	extern
#endif

#define BALANCE_START	7
#define BALANCE_INC	8

typedef struct binleaf_st {
	Lstr	key;
	struct binleaf_st  *left, *right;
	void	*value;
    bool     isThreaded;
} BinLeaf;

typedef BinLeaf	*PBinLeaf;

typedef struct {
	PBinLeaf	parent;
	int	items;
	int	maxdepth;
	int	balancedepth;
} BinTree;

#define BINTREEINIT(t)	{(t).parent=NULL; (t).items=0; \
		(t).maxdepth=0; (t).balancedepth=BALANCE_START;}

/* =================== function prototypes =================== */
PBinLeaf __CDECL BinAdd( BinTree *tree, PLstr name, void *dat );
PBinLeaf __CDECL BinMin( PBinLeaf leaf );
PBinLeaf __CDECL BinMax( PBinLeaf leaf );
PBinLeaf __CDECL BinFind( BinTree *tree, PLstr name );
PBinLeaf __CDECL BinSuccessor( PBinLeaf leaf );
void	 __CDECL BinDisposeLeaf( BinTree *tree, PBinLeaf leaf,
		void (__CDECL *BinFreeData)(void *) );
void	 __CDECL BinDisposeTree( BinTree *tree,
		void (__CDECL *BinFreeData)(void *) );
void	 __CDECL BinDel( BinTree *tree, PLstr name,
		void (__CDECL *BinFreeData)(void *) );
void     __CDECL BinPrint(PBinLeaf leaf, PLstr filter);
void	 __CDECL BinBalance( BinTree *tree );
int      __CDECL BinVarDump(PLstr result, PBinLeaf leaf, PLstr filter,int mode,PLstr asclause);
int      __CDECL BinStemCount(PLstr misuse,PBinLeaf leaf,PLstr stem);

#undef EXTERN
#endif
