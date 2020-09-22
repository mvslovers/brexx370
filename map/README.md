# Hashmap

A simple generic hashmap, and double linked list, implementation in C.

## Usage

All hash map API functions are prefixed as `hashMap*`.

```c
#include "hashmap.h"

// The larger the better
size_t size = 50;

HashMap *map = hashMapNew(size);

// Insertion/Setting
hashMapSet(map, "libname", "hashmap");
hashMapSet(map, "author", "mech");
hashMapset(map, "author", "mecha"); // Overrides
hashMapSet(map, "foo", "bar");

// Removal
hashMapDelete(map, "foo");

// Retrieval
hashMapGet(map, "libname"); // "hashmap"
hashMapGet(map, "author"); // "mecha"

// Existence check
hashMapHas(map, "libname"); true
hashMapHas(map, "foo"); // false
```
