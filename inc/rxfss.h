#ifndef __RXFSS_H__
#define __RXFSS_H__

int RxFSS_INIT(char **tokens);
int RxFSS_TERM(char **tokens);
int RxFSS_STATIC(char **tokens);
int RxFSS_RESET(char **tokens);
int RxFSS_TEXT(char **tokens);
int RxFSS_FIELD(char **tokens);
int RxFSS_SET(char **tokens);
int RxFSS_GET(char **tokens);
int RxFSS_REFRESH(char **tokens);
int RxFSS_SHOW(char **tokens);
int RxFSS_CHECK(char **tokens);

#endif
