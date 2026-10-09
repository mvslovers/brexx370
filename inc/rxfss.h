#ifndef __RXFSS_H__
#define __RXFSS_H__

/* what an RxFSS_ function returns before FSS INIT; __FSS raises error 69
 * for it. It was 8, which any other RC 8 would have hit as well (#386) */
#define FSS_NOT_INIT (-69)

int RxFSS_INIT(char **tokens);
int RxFSS_TERM(char **tokens);
int RxFSS_STATIC(char **tokens);
int RxFSS_RESET(char **tokens);
int RxFSS_TEXT(char **tokens);
int RxFSS_TEST(char **tokens);
int RxFSS_FIELD(char **tokens);
int RxFSS_SET(char **tokens);
int RxFSS_GET(char **tokens);
int RxFSS_REFRESH(char **tokens);
int RxFSS_SHOW(char **tokens);
int RxFSS_CHECK(char **tokens);

#endif
