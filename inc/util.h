#ifndef BREXX_UTIL_H
#define BREXX_UTIL_H
#include "rxmvsext.h"

typedef enum quotation { UNQUOTED, PARTIALLY_QUOTED, FULL_QUOTED } QuotationType;

QuotationType CheckQuotation(const char *sDSName);
int getDatasetName(RX_ENVIRONMENT_CTX_PTR pEnvironmentCtx,  const char *datasetNameIn, char datasetNameOut[54 + 1]);
void splitDSN(PLstr dsn, PLstr member, PLstr fromDSN);
int  createDataset(char *sNAME, char *sMODE, char *sRECFM, unsigned int uiLRECL, unsigned int uiBLKSIZE,
                   unsigned int uiDIR, unsigned int uiPRI, unsigned int uiSEC);
long getFileSize(FILE *pFile);
int IsReturnCode(char * input);
void DumpHex(const unsigned char* data, size_t size);

void ebcdicToAscii(unsigned char *s, unsigned int length);

#endif //BREXX_UTIL_H
