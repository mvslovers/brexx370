/*
 * $Id: rxmvs.h,v 1.2 2009/06/02 09:41:43 bnv Exp $
 * $Log: rxmvs.h,v $
 * Revision 1.2  2009/06/02 09:41:43  bnv
 * MVS/CMS corrections
 *
 * Revision 1.1  2008/07/15 14:57:11  bnv
 * Initial revision
 *
 *
 * Following sections contains name redefinitions for VM
 */
#ifndef __RXMVS_H
#define __RXMVS_H

#define BinDisposeLeaf BiDiLeaf
/* compile.c */
#define CompileCode CmpC
#define CompileCurClause CmpCuCl
#define CompileCodeLen CmpCoLn
#define CompileClause  CmpCl
#define CompileClauseItems  CmpClIt
#define CompileCodePtr  CmpCoPt
#define _CodeAddPtr _CoAdPt
#define _CodeAddDWord _CoAdDw
/*
 interpre.c & interpre.h
*/
#define RxInitInterStr RxInInStr
#define RxInitInterpret RxInIn
#define RxDoneInterpret RxDoIn
#define RxDoneInterpretStr RxDoInStr
#define I_trigger_space I_tr_space
#define I_trigger_literal I_tr_literal
/*
  Nextsymbol and Compile
*/
#define InitNextch InNech
#define InitNextSymbol InNeSymbol
#define symbolstr symbstr
#define symbolstat symbstat
#define symbolPrevBlank symbPrBl
#define symbolprevptr symbprptr
/*
 RxFunction
*/
#define RxRegFunctionDone RxReFnDn
#define RxRegFunction RxReFn
#define R_charlinein R_chlnin
#define R_charlineout R_chlnot
#define charlinein chlnin
#define charlineout chlnot
/*
  BUILTIN.C & VARIABLE.C
*/
#define RxVarFindName RxVarFName
#define RxVarDelName RxVarDeName
#define RxVarDelInd RxVarDeInd
#define RxVarExposeInd RxVarExInd
#define SystemPoolGet SysPlGet
#define SystemPoolSet SysPlSet

/*
 * cc370 maps external names to 8 uppercase characters ('_' -> '@').
 * Each pair below collided in its first 8 chars.
 */
#define _authorisedGranted AuthGrnt
#define _authorisedNative AuthNatv
#define BinPrintStemV BinPrStV
#define BinVarDumpV BinVDmpV
#define fssGetAlternateScreenHeight fssGAScH
#define fssGetAlternateScreenWidth fssGAScW
#define fssSetCurPos fssSCPos
#define fssSetCursor fssSCur
#define getIntegerV getIntV
#define getStemV0 getStmV0
#define R_isearchnn R_isrcnn
#define R_listdsiq R_lsdsiq
#define re_matchp re_mtchp
#define RxFileLoadDDN RxFLdDDN
#define RxFileLoadDSN RxFLdDSN
#define RxFSS_REFRESH RxFSSRFR
#define RxFSS_RESET RxFSSRST
#define RxFSS_TERM RxFSSTRM
#define RxFSS_TEST RxFSSTST
#define RxFSS_TEXT RxFSSTXT
#define RxNjeGetNetId RxNjeNId
#define RxNjeGetVersion RxNjeVer
#define RxPreLoaded RxPreLdd
#define setVariable2 setVar2
#define __ISPEXEC RxISPEXC            /* @@ISPEXE is libc370 ispexec() */

#endif
