/*-----------------------------------------------------------------------------
|  Copyright (c) 2012-2013, Tommy Sprinkle (tommy@tommysprinkle.com)  
|
|  All rights reserved. Redistribution and use in source and binary forms, 
|  with or without modification, are permitted provided that the following 
|  conditions are met:
|
|    * Redistributions of source code must retain the above copyright notice, 
|      this list of conditions and the following disclaimer. 
|    * Redistributions in binary form must reproduce the above copyright  
|      notice, this list of conditions and the following disclaimer in the  
|      documentation and/or other materials provided with the distribution. 
|    * Neither the name of the author nor the names of its contributors may  
|      be used toendorse or promote products derived from this software  
|      without specific prior written permission. 
|
|   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS  
|   "AS IS" AND ANYEXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT  
|   LIMITED TO, THE IMPLIED WARRANTIESOF MERCHANTABILITY AND FITNESS  
|   FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENTSHALL THE 
|   COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
|   INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
|   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
|   SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
|   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
|   STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)  
|   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
|   OF THE POSSIBILITY OF SUCH DAMAGE.
-----------------------------------------------------------------------------*/

//---------------------------------------------------------------
// TSO - C Routine Interface
//
// created by:
// Tommy Sprinkle - tommy@tommysprinkle.com
// December, 2012
//
// extended by:
// Mike Grossmann - mike.grossmann.de@gmail.com
// June, 2019
//---------------------------------------------------------------

#include "rxtso.h"
#include "rxmvsext.h"

//----------------------------------------
// Basic  TPUT
//----------------------------------------
void tput(char *data, int length)
{
    RX_SVC_PARAMS params;

    params.SVC = 93;
    params.R0 = length;
    params.R1 = (unsigned int) data & 0x00FFFFFF;

    call_rxsvc(&params);
}


//----------------------------------------
// Basic  TGET
//----------------------------------------
int tget(char *data, int length)
{
    RX_SVC_PARAMS params;

    params.SVC = 93;
    params.R0 = length;
    params.R1 = ((unsigned int) data & 0x00FFFFFF) | 0x80000000;

    call_rxsvc(&params);

    return params.R1;
}

//----------------------------------------
// STFSMODE - 0 = off, 1 = on
//----------------------------------------
void stfsmode(int action)
{
    RX_SVC_PARAMS params;

    params.SVC = 94;
    params.R0 = 0x12000000;
    if (action)
        params.R1 = 0xC0000000;
    else
        params.R1 = 0;

    call_rxsvc(&params);
}

//----------------------------------------
// STTMPMD
//----------------------------------------
void sttmpmd(int action)
{
    RX_SVC_PARAMS params;

    params.SVC = 94;
    params.R0 = 0x14000000;
    if (action)
        params.R1 = 0x80000000;
    else
        params.R1 = 0;

    call_rxsvc(&params);
}

//----------------------------------------
// STLINENO
//----------------------------------------
void stlineno(int line)
{
    RX_SVC_PARAMS params;

    params.SVC = 94;
    params.R0 = 0x13000000;
    params.R1 = line;

    call_rxsvc(&params);
}

//----------------------------------------
// TPUT - Full Screen Write
//----------------------------------------
int tput_fullscr(char *data, int len)
{
    RX_SVC_PARAMS params;

    struct tput_params
    {
        unsigned short asid;
        unsigned short buf_size;
        unsigned int   flags_addr;
        unsigned int   userId;
        unsigned int   flags2;

    };

    struct tput_params tputParams;

    tputParams.asid       = 0;
    tputParams.buf_size   = len;
    tputParams.flags_addr = ((unsigned int) data & 0x00FFFFFF) | 0x03000000;
    tputParams.userId     = 0;
    tputParams.flags2     = 0x81000000;

    params.SVC = 93;
    params.R0  = ((unsigned int) data & 0x00FFFFFF) | 0x80000000;
    params.R1  = (int)&tputParams;

    call_rxsvc(&params);

    return params.R15;
}

//----------------------------------------
// TGET  ASIS
//----------------------------------------
int tget_asis(char *data, int len)
{
    RX_SVC_PARAMS params;

    params.SVC = 93;
    params.R0 = len;
    params.R1 = ((unsigned int) data & 0x00FFFFFF) | 0x81000000;

    call_rxsvc(&params);

    return params.R1;
}

//----------------------------------------
// TGET  ASIS NOWAIT
//----------------------------------------
int tget_nowait(char *data, int len)
{
    RX_SVC_PARAMS params;

    params.SVC = 93;
    params.R0 = len;
    params.R1 = ((unsigned int) data & 0x00FFFFFF) | 0x91000000;

    call_rxsvc(&params);

    return params.R1;
}

//----------------------------------------
// GTTERM
//----------------------------------------
void gtterm(RX_GTTERM_PARAMS_PTR paramsPtr)
{
    RX_SVC_PARAMS params;

    params.SVC = 94;
    params.R0  = (17 << 24);
    params.R1  = (unsigned)paramsPtr;

    call_rxsvc(&params);
}

//----------------------------------------
// Translate a byte into a 3270 compatable byte
//----------------------------------------
int xlate3270(int byte) {
    static char tbl3270[] =
            {0x40, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7,
             0xC8, 0xC9, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F,
             0x50, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 0xD7,
             0xD8, 0xD9, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F,
             0x60, 0x61, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7,
             0xE8, 0xE9, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F,
             0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7,
             0xF8, 0xF9, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F
            };


    if (byte > 63 || byte < 0)
        return 0;

    return tbl3270[byte];
}




