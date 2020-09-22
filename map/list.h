#ifndef __LIST_H__
#define __LIST_H__

#ifndef bool
typedef int	bool;
#endif

#ifndef true
#define true  1
#define false 0
#endif

/**
 * Generic double-linked list node.
 */
struct ListNode_T;
typedef struct ListNode_T {
    void *data;
    struct ListNode_T *prev;
    struct ListNode_T *next;
} ListNode;

/**
 * Double-linked list structure.
 */
typedef struct List_T
{
    ListNode *head;
    ListNode *tail;
} List;

/**
 * Callback function type used for determining equivalence between list element data.
 */
typedef bool (*ListComparatorCb)(void *, void *);

/**
 * Creates a new linked list.
 *
 * @return The created element list.
 */
List *listNew();

/**
 * Pushes data to the linked list.
 *
 * @param data The data to push.
 *
 * @return True on success, false on failure.
 */
bool listPush(List *list, void *data);

/**
 * Searches for an element in a linked list.
 *
 * The callback function is invoked for every element in the linked list in sequence. The function is expected to
 * return true if the element and the compare value are equal, false otherwise. The first occurrence of a `true` return
 * will terminate the search and return that element.
 *
 * @param list The list to iterate.
 * @param compare Optional value(s) to compare against. Can be NULL.
 * @param callback A function which accepts an element as parameter (void*) and the compare argument value and returns
 *                 true if they are equal or false if not.
 *
 * @return The found element, or NULL if the element was not found.
 */
void *listSearch(List *list, void * compare, ListComparatorCb callback);

/**
 * Removes an element from the list.
 *
 * The callback function is invoked for every element in the linked list in sequence. The function is expected to
 * return true if the element and the compare value are equal, false otherwise. The first occurrence of a `true` return
 * will terminate the search and result in the deletion of the corresponding element.
 *
 * @param list The list to remove from.
 * @param compare Optional value(s) to compare against. Can be NULL.
 * @param callback A function which accepts an element as parameter (void*) and the compare argument value and returns
 *                 true if the are equal, false if not.
 *
 * @return True on successful deletion, false otherwise.
 */
bool listDelete(List *list, void * compare, ListComparatorCb callback);

#endif //__LIST_H__
