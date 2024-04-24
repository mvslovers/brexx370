#ifndef __JCCDUMMY_H
#define __JCCDUMMY_H
#if __CROSS__

char* _style;
void ** entry_R13;

int __get_ddndsnmemb (int handle, char * ddn, char * dsn,
                      char * member, char * serial, unsigned char * flags);

#endif
#endif //__JCCDUMMY_H
