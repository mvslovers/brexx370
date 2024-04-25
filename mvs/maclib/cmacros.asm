#define ENDASM    /* no-op */
#define endasm    /* no-op */
#define startasm  STARTASM
#pragma linkage(STARTASM,OS)
#define R0  regs.r0
#define R1  regs.r1
#define R2  regs.r2
#define R3  regs.r3
#define R4  regs.r4
#define R5  regs.r5
#define R6  regs.r6
#define R7  regs.r7
#define R8  regs.r8
#define R9  regs.r9
#define R10 regs.r10
#define R11 regs.r11
#define R12 regs.r12
#define R13 regs.r13
#define R14 regs.r14
#define R15 regs.r15
#define  SVC(svcno)  SVCCALL((svcno+2560),&regs)
#define  ADDR(item)  ((int)&##item)
struct regset {
         int r0 ;
         int r1 ;
         int r2 ;
         int r3 ;
         int r4 ;
         int r5 ;
         int r6 ;
         int r7 ;
         int r8 ;
         int r9 ;
         int r10 ;
         int r11 ;
         int r12 ;
         int r13 ;
         int r14 ;
         int r15 ; } ;
struct regset regs;
extern int SVCCALL(int s, struct regset *x);
