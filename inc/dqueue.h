/*
 * $Id: dqueue.h,v 1.4 2008/07/15 07:40:07 bnv Exp $
 * $Log: dqueue.h,v $
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

#ifndef __DEQUEUE_H__
#define __DEQUEUE_H__

#include "lstring.h"

/* ============= type definitions ================= */
typedef struct dequeue_elem_st {
	void	*dat;
	struct dequeue_elem_st	*prev, *next;
} DQueueElem;

typedef struct {
	long		items;
	DQueueElem	*head;
	DQueueElem	*tail;
} DQueue;

#define DQINIT(q)	{(q).items=0; (q).head=NULL; (q).tail=NULL;}
#define DQQUEUE(q,s)	DQAdd2Head(q,s)
#define DQPUSH(q,s)	DQAdd2Tail(q,s)
#define DQPEEK(q)	(((q)->tail)->dat)

/* ============= function prototypes ============= */
void	__CDECL DQAdd2Head( DQueue *queue, void *dat);
void	__CDECL DQAdd2Tail( DQueue *queue, void *dat);
void		*DQPop( DQueue *queue );
void	__CDECL DQDel( DQueue *queue, DQueueElem *elem );
void	__CDECL DQFlush( DQueue *queue, void (__CDECL *freefunc)(void *) );

/*DQueueElem *	DQFind( DQueue *queue, PLstr str );*/

#endif
