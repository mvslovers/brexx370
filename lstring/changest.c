/*
 * $Header: /home/bnv/tmp/brexx/lstring/RCS/changest.c,v 1.2 2000/02/07 11:21:35 bnv Exp $
 * $Log: changest.c,v $
 * Revision 1.2  2000/02/07 11:21:35  bnv
 * Corrected: The case where the old string has length equal to ZERO.
 *
 * Revision 1.1  1998/07/02 17:17:00  bnv
 * Initial revision
 *
 */

#include <lstring.h>

/* ----------------- Lchagestr ------------------- */
void
Lchangestr( const PLstr to, const PLstr oldstr,
	const PLstr str, const PLstr newstr)
{
	size_t	pos, foundpos;
	Lstr	tmp;

	if (LLEN(*oldstr)==0) {
		Lstrcpy(to,str);
		return;
	}

	Lfx(to,LLEN(*str));
	LZEROSTR(*to);

	LINITSTR(tmp);

	pos = 1;
	for (;;) {
		foundpos = Lindex(str,oldstr,pos);
		if (foundpos==0) break;
		if (foundpos!=1) {
			_Lsubstr(&tmp,str,pos,foundpos-pos);
			Lstrcat(to,&tmp);
		}
		Lstrcat(to,newstr);
		pos = foundpos + LLEN(*oldstr);
	}
	_Lsubstr(&tmp,str,pos,0);
	Lstrcat(to,&tmp);
	LFREESTR(tmp);
} /* Lchagestr */
