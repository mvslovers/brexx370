/*
 * $Id: dqueue.c,v 1.5 2008/07/15 07:40:25 bnv Exp $
 * $Log: dqueue.c,v $
 * Revision 1.5  2008/07/15 07:40:25  bnv
 * #include changed from <> to ""
 *
 * Revision 1.4  2008/07/14 13:08:42  bnv
 * MVS,CMS support
 *
 * Revision 1.3  2002/06/11 12:37:38  bnv
 * Added: CDECL
 *
 * Revision 1.2  2001/06/25 18:51:48  bnv
 * Header -> Id
 *
 * Revision 1.1  1998/07/02 17:34:50  bnv
 * Initial revision
 *
 */

#include "bmem.h"
#include "dqueue.h"

/* ------------- DQAdd2Head --------------- */
void __CDECL
DQAdd2Head( DQueue *queue, void *dat)
{
    DQueueElem *elem;

    elem = (DQueueElem *) MALLOC(sizeof(DQueueElem),"DQueueElem");
    elem->dat  = dat;
    elem->prev = NULL;
    elem->next = queue->head;
    if (queue->head) (queue->head)->prev = elem;

    queue->items++;
    queue->head = elem;
    if (queue->tail == NULL)
        queue->tail = elem;
} /* DQAdd2Head */

/* ------------- DQAdd2Tail --------------- */
void __CDECL
DQAdd2Tail( DQueue *queue, void *dat)
{
    DQueueElem *elem;

    elem = (DQueueElem *) MALLOC(sizeof(DQueueElem),"DQueueElem");
    elem->dat = dat;
    elem->prev = queue->tail;
    elem->next = NULL;
    if (queue->tail) (queue->tail->next) = elem;

    queue->items++;
    queue->tail = elem;
    if (queue->head == NULL)
        queue->head = elem;
} /* DQAdd2Tail */

/* ---------------- DQDel ------------------ */
void __CDECL
DQDel( DQueue *queue, DQueueElem *elem )
{
    if (elem==NULL) return;

    if (elem->prev)
        (elem->prev)->next = elem->next;
    else /* Must be head, if there is no previous */
        queue->head = elem->next;

    if (elem->next)
        (elem->next)->prev = elem->prev;
    else /* Must be tail, if there is no next */
        queue->tail = elem->prev;

    FREE(elem);

    queue->items--;
} /* DQDel */

/* ---------------- DQPop ------------------ */
void *
DQPop( DQueue *queue )
{
    static void *dat;

    if (!(queue->tail))
        return NULL;

    dat = (queue->tail)->dat;
    (queue->tail)->dat = NULL;

    DQDel(queue,queue->tail);
    return dat;
} /* DQPop */

/* --------------- DQFlush ----------------- */
void __CDECL
DQFlush( DQueue *queue, void (__CDECL *freefunc)(void *) )
{
    DQueueElem *elem,*tofree;

    elem = queue->head;
    while (elem) {
        tofree = elem;
        elem = elem->next;
        freefunc(tofree->dat);
        FREE(tofree);
    }
    queue->head = queue->tail = NULL;
    queue->items = 0;
} /* DQFlush */

/* ---------------- DQFind ----------------- *
DQueueElem *
DQFind( DQueue *queue, PLstr str )
{
    static DQueueElem *elem;

    elem = queue->head;
    while (elem) {
        if (Lstrcmp(elem->str, str)==0)
            break;
        elem = elem->next;
    }
    return elem;
} * DQFind */
