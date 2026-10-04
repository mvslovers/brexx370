#ifndef BREXX_RXLL_H
#define BREXX_RXLL_H

/* the linked list functions LL* and S2LL (src/rxll.c) */

#define llmax 32

struct node {
    int  *next;
    int  *previous;
    int  magic;
    char data[8];
};
struct root {
    int  *next;
    int  *previous;
    char name[16];
    char flags;
    char reserved[3];
    int  count;
    int  added;
    int  deleted;
    int  *last;
};
/* the lists; SUBMIT (rxmvs.c) writes one to the internal reader */
extern struct root *llist[llmax];

void RxLlRegFunctions();

#endif /* BREXX_RXLL_H */
