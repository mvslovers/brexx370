#ifndef __RAC_H
#define __RAC_H

typedef unsigned char   uint8_t;

typedef struct {
    uint8_t byte[3];
} uint24_t;

typedef struct {
    unsigned char   xbyte;
    uint24_t        uint24ptr;
} uint24xptr_t;

typedef struct {
    void *installation_params;
    void *entity_profile;
    void *class;
    void *volser;

    void *old_volser;
    void *appl;
    void *acee;
    void *owner;

    void *dummy[4];

    void *access_level;
    void *access_level_parms;

} RAC_AUTH_PARMS, *P_RAC_AUTH_PARMS;

typedef struct {
    unsigned char length;
    char  name[8];
} CLASS, *P_CLASS;

int rac_status();
int rac_user_auth(char *userName, char *password);
int rac_facility_check(char *className, char *facilityName, char *attributeName);
#endif //__RAC_H
