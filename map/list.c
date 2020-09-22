#include <stdlib.h>
#include <string.h>
#include "list.h"

List *listNew()
{
    List *list = (List *) malloc(sizeof(List));
    list->head = NULL;
    list->tail = NULL;

    return list;
}

bool listPush(List *list, void *data)
{
    // Create new node
    ListNode *newNode = malloc(sizeof(ListNode));
    newNode->data = data;
    newNode->next = NULL;
    newNode->prev = NULL;

    // If list is empty, the new node becomes the list's head
    if (list->head == NULL) {
        list->head = newNode;
    }

    // Attach to end of list
    if (list->tail != NULL) {
        // Set new node's "prev" to the old tail
        newNode->prev = list->tail;
        // Add new node as "next" of old tail
        list->tail->next = newNode;
    }
    // Set new node to be the list's new tail
    list->tail = newNode;

    return true;
}

void *listSearch(List *list, void * compare, ListComparatorCb callback)
{
    ListNode *node = list->head;

    while (node != NULL) {
        // Invoke callback and if result is true, return element
        if (callback(node->data, compare)) {
            return node->data;
        }
        node = node->next;
    }

    // Not found
    return NULL;
}

bool listDelete(List *list, void * compare, ListComparatorCb callback)
{
    ListNode *node = list->head;
    unsigned int deleted = 0;

    while (node != NULL) {
        if (callback(node->data, compare)) {
            // Set previous node's next pointer to next node
            // Set next node's previous pointer to previous node
            if (node->prev != NULL) node->prev->next = node->next;
            if (node->next != NULL) node->next->prev = node->prev;

            // Update list head and tail
            if (list->head == node) list->head = node->next;
            if (list->tail == node) list->tail = node->prev;

            // Delete current node
            free(node);

            return true;
        }
        node = node->next;
    }

    return false;
}
