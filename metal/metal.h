#ifndef __METAL_H
#define __METAL_H

#define FALSE     0
#define TRUE      1

#define AUX_MEM_HEADER_ID	  0xDEADBEAF

#define AUX_MEM_HEADER_LENGTH 12
#define JCC_MEM_HEADER_LENGTH 16
#define MVS_PAGE_SIZE         4096

typedef int                 bool;
typedef unsigned char       byte;
typedef unsigned short      hword;
typedef unsigned long       fword;
typedef unsigned long long  dword;
typedef unsigned long       uintptr_t;

// external assembler functions
void * GETSA();                             // retunr pointer to current save area
void   SVC(int svc,                         // call given svc
           int *R0,
           int *R1,
           int *R15);

// bare metal functions
void  *_xregs    (unsigned int reg);           // return register value
void   _tput     (char *data);                 // put text line to terminal
void   _putchar  (char character);             // tbd
void   _clrbuf   (void);                       // write outstanding data to terminal
void  *_getm     (size_t size);                // get some main storage
void   _freem    (void *ptr);                  // free some main storage
bool   _ismetal  (void *ptr);                  // check if memory is "metal" memory
size_t _msize    (void *ptr);                  // return length of allocated "metal" memory
void  *_malloc   (size_t size);                // convenience function for __getm
void  *_realloc  (void *oldPtr, size_t size);  // convenience function for __getm+memcpy+__freem
void   _free     (void *ptr);                  // convenience function for __freem
void   _dump     (void *data,
                  size_t size,
                  char *heading);              // dump some memory in hex format
int    _upper    (int c);                      // convert a single char to upper case


#endif //__METAL_H
