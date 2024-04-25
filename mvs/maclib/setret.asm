         MACRO                                                          SET00010
&LBL     SETRET &L=RETURN,&RC=0                                         SET00020
.********************************************************************** SET00030
.***   SETRET INITIALIZES REG 15 WITH A RETURN CODE AND BRANCHES    *** SET00040
.***   TO A SPECIFIED LABEL OR THE DEFAULT LABEL OF RETURN.  IF     *** SET00050
.***   NO RETURN CODE IS SPECIFIED, A RETURN CODE OF 0 IS SET.      *** SET00060
.********************************************************************** SET00070
&LBL     LA    15,&RC                                                   SET00080
         B     &L                                                       SET00090
         MEND                                                           SET00100
