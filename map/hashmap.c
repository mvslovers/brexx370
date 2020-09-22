#include <stdlib.h>
#include <string.h>
#include "hashing.h"
#include "hashmap.h"

// ====================================================================================================================
//  NON-API UTILITY FUNCTIONS
// ====================================================================================================================

/**
 * [NON-API] Creates a new hashmap pair.
 *
 * @param hash The hash key.
 * @param key The key.
 * @param data The data.
 *
 * @return The created hashmap pair.
 */
HashMapPair *_hm_createPair(char *key, void *data)
{
    HashMapPair *pair = (HashMapPair *) malloc(sizeof(HashMapPair));
    pair->data = data;
    pair->key = malloc(strlen(key) + 1);
    strcpy(pair->key, key);

    return pair;
}

/**
 * [NON-API] Comparator function used when searching a list. Compares two elements to determine equivalence.
 *
 * @param element The search iteration element.
 * @param compare The search key.
 *
 * @return The item list, or a null pointer.
 */
bool _hm_bucketComparatorFunction(void *element, void *compare)
{
    char *searchKey = (char *) compare;
    HashMapPair *pair = (HashMapPair *) element;

    return strcmp(pair->key, searchKey) == 0;
}

/**
 * [NON-API] Utility method for retrieving the bucket for a given hash without out-of-bounds access.
 *
 * @param hashmap The hashmap.
 * @param hash The item key hash.
 *
 * @return The item list, or a null pointer.
 */
Bucket *_hm_getBucket(HashMap *hashmap, char *key)
{
    unsigned long int hash = hashKey(key);
    unsigned long int index = hash % hashmap->size;

    return &hashmap->buckets[index];
}

/**
 * [NON-API] Utility method for retrieving a pair from the hashmap by key.
 *
 * @param hashmap The hashmap.
 * @param hash The item key hash.
 *
 * @return The item list, or a null pointer.
 */
HashMapPair *_hm_getPair(HashMap *hashmap, char *key)
{
    Bucket *bucket = _hm_getBucket(hashmap, key);

    return listSearch(bucket, key, _hm_bucketComparatorFunction);
}

// ====================================================================================================================
//  HASHMAP API FUNCTIONS
// ====================================================================================================================

HashMap *hashMapNew(size_t size)
{
    HashMap *hashmap = (HashMap *) malloc(sizeof(HashMap));
    size_t bucketSize = sizeof(Bucket);
    hashmap->size = size;
    hashmap->buckets = calloc(size, bucketSize);

    return hashmap;
}

void *hashMapGet(HashMap *hashmap, char *key)
{
    HashMapPair *pair = _hm_getPair(hashmap, key);

    return (pair != NULL)
           ? pair->data
           : NULL;
}

bool hashMapHas(HashMap *hashmap, char *key)
{
    return _hm_getPair(hashmap, key) != NULL;
}

bool hashMapSet(HashMap *hashmap, char *key, void *data)
{
    // Get the bucket for this hash
    Bucket *bucket = _hm_getBucket(hashmap, key);
    HashMapPair *pair = listSearch(bucket, key, _hm_bucketComparatorFunction);

    // Pair already exists. Replace value
    if (pair != NULL) {
        pair->data = data;

        return true;
    }

    // Pair does not exist. Push to bucket
    bool success = listPush(bucket, _hm_createPair(key, data));

    return success;
}

bool hashMapDelete(HashMap *hashmap, char *key)
{
    Bucket *bucket = _hm_getBucket(hashmap, key);

    return listDelete(bucket, key, _hm_bucketComparatorFunction);
}
