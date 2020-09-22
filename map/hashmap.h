#ifndef __HASHMAP_H__
#define __HASHMAP_H__

#include "list.h"

// Alias for code readability purposes
typedef List Bucket;

// Hash map data structure
typedef struct HashMap_T
{
    List *buckets;
    size_t size;
} HashMap;

// Generic key-value pair in the hash map
typedef struct HashMapPair_T
{
    char * key;
    void * data;
} HashMapPair;

/**
 * Creates a new hashmap.
 *
 * @param size The page size of the hasmap.
 *
 * @return The created hashmap.
 */
HashMap *hashMapNew(size_t size);

/**
 * Sets an entry in the hashmap, overriding any existing value.
 *
 * @param hashmap The hashmap to add to.
 * @param key The key of the entry to set.
 * @param data The data to set.
 *
 * @return True on success, false on failure.
 */
bool hashMapSet(HashMap *hashmap, char *key, void *data);

/**
 * Retrieves a value from the hashmap.
 *
 * @param hashmap The hashmap to retrieve from.
 * @param key The key of the value to retrieve.
 *
 * @return The value, or a null pointer if no value was found for the given key.
 */
void *hashMapGet(HashMap *hashmap, char *key);

/**
 * Checks if the hashmap contains a value for a given key.
 *
 * @param hashmap The hashmap to search.
 * @param key The key to search for.
 *
 * @return True if a value was found for the given key, false otherwise.
 */
bool hashMapHas(HashMap *hashmap, char *key);

/**
 * Removes a value from the hashmap.
 *
 * @param hashmap The hashmap to remove from.
 * @param key The key of the value to remove.1
 *
 * @return True on success, false on failure.
 */
bool hashMapDelete(HashMap *hashmap, char *key);

#endif //__HASHMAP_H__
