#define __STACK_C__

#include "lstring.h"
#include "stack.h"

#include "rexx.h"

/* ----------------- CreateStack ----------------------- */
void __CDECL
CreateStack( void )
{
	DQueue	*stck;

	stck = (DQueue*) MALLOC(sizeof(DQueue),"Stack");
	DQINIT(*stck);
	DQPUSH(&rxStackList,stck);
} /* CreateStack */

/* ----------------- DeleteStack ----------------------- */
void __CDECL
DeleteStack( void )
{
	DQueue *stck;
	stck = DQPop(&rxStackList);
	DQFlush(stck,_Lfree);
	FREE(stck);
} /* DeleteStack */

/* ----------------- Queue2Stack ----------------------- */
void __CDECL
Queue2Stack( PLstr str )
{
	DQueue *stck;
	stck = DQPEEK(&rxStackList);
	DQAdd2Head(stck,str);
} /* Queue2Stack */

/* ----------------- Push2Stack ----------------------- */
void __CDECL
Push2Stack( PLstr str )
{
	DQueue *stck;
	stck = DQPEEK(&rxStackList);
	DQAdd2Tail(stck,str);
} /* Push2Stack */

/* ----------------- PullFromStack ----------------------- */
PLstr __CDECL
PullFromStack( )
{
	DQueue *stck;
	stck = DQPEEK(&rxStackList);
	return (PLstr)DQPop(stck);
} /* PullFromStack */

/* ----------------- StackQueued ----------------------- */
long __CDECL
StackQueued( void )
{
	DQueue *stck;
	stck = DQPEEK(&rxStackList);
	return stck->items;
} /* StackQueued*/
