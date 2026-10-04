/* -------------------------------------------------------------------------------------
 * Matrices: MCREATE, MSET, MGET, MMULTIPLY, MINVERT, ... and MFREE, which
 * also frees integer arrays. Moved from rxmvs.c (#302).
 * -------------------------------------------------------------------------------------
 */
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "rxmatrix.h"
#include "rxarray.h"
#include "rexx.h"
#include "rxdefs.h"
#include "rxmvsext.h"
#include "lstring.h"
#include "lerror.h"

#define matOffset(ix,rowi,coli) {ix=((rowi-1)*matcols[matrixname]+(coli-1));}
#define matOffset2(mname,ix,rowi,coli) {ix=((rowi-1)*matcols[mname]+(coli-1));}
#define mcheck(m0) { if (curmatrixname!=m0) Matrixcheck(m0);}

double *matrix[matrixmax];
int    fmaxrows[matrixmax];
int    matrows[matrixmax], matcols[matrixmax],matrixname=0,curmatrixname=-1,mdebug;

int Matrixcheck(int matrixname) {
    char sNumber[16];
    char sNumber2[8];

    if (curmatrixname==matrixname) return 0;
    if (matrixname>matrixmax) {
        sprintf(sNumber,"%d",matrixname);
        sprintf(sNumber2,"%d",matrixmax);
        Lfailure ( "Matrix ",sNumber,"exceeds maximum of ",sNumber2,"");
    }
    if (matrix[matrixname] == 0) {
        sprintf(sNumber,"%d",matrixname);
        Lfailure ( "Matrix ",sNumber,"is not defined","","");
    }
    curmatrixname=matrixname;
    return 0;
}

void setMatrixStem(char *sName, int mname,int stemi, double fValue)
{
    char sStem[32];
    char sValue[32];

    if (stemi<0) sprintf(sStem,"%s.%d",sName,mname);
    else  sprintf(sStem,"%s.%d.%d",sName,mname,stemi);
    sprintf(sValue,"%f",fValue);
    setVariable(sStem,sValue);
}

int mcreate(int rows, int cols) {
    int matrixname,size;
    for (matrixname = 0; matrixname <= matrixmax; ++matrixname) {
        if (matrix[matrixname] == 0) break;
    }
    if (matrixname > matrixmax) Lfailure ( "Matrix stack full, no allocation occurred","","","","");
    matrows[matrixname]=rows;
    matcols[matrixname]=cols;
    size=rows*cols*sizeof(double);
    matrix[matrixname] =MALLOC(size,"Matrix");
    if (matrix[matrixname]==0) Lfailure ( "Storage stack full, no allocation occurred","","","","");
    curmatrixname=matrixname;
    if (mdebug==1) printf("Matrix create %d %d %d size %d AT %d\n",matrixname,rows,cols,size,(int) matrix[matrixname]);
    return matrixname;
}
void R_mcreate(__unused int func) {
    int matrixname,rows,cols;
    get_i(1,rows);    // Number of rows, rows run from 1 to rows, if rows=1 it's a 1-dimensional vector of columns
    get_i(2,cols);
    matrixname= mcreate(rows, cols) ;
    if (ARGN==3) {
        get_s(3);
        LASCIIZ(*ARG3)
        if (mdebug==1) printf("Matrix created %d %s Dimension %d,%d\n",matrixname,LSTR(*ARG3),rows,cols);
    } else if (mdebug==1) printf("Matrix created %d Dimension %d,%d\n",matrixname,rows,cols);
    Licpy(ARGR,matrixname);
}
void R_mfree(int func) {
    int ii;
 // func<0, final cleanup
    curmatrixname = -1;
    if (ARGN == 0 || func<0) {
        for (ii = 0; ii < matrixmax; ++ii) {
            if (matrix[ii] == 0) continue;
            FREE(matrix[ii]);
            matrix[ii] = 0;
        }
        for (ii = 0; ii < ivectormax; ++ii) {
            if (ivector[ii] == 0) continue;
            FREE(ivector[ii]);
            ivector[ii] = 0;
        }
        return;
    }
    get_s(2);
    get_i0(1, ii);
    LASCIIZ(*ARG2)
    Lupper(ARG_OWN(2));
    if (LSTR(*ARG2)[0] == 'I') {
        if (ii < 0 || ii >= ivectormax || ivector[ii] == NULL) {
            Lerror(ERR_INCORRECT_CALL, 0);
            return;
        }
        FREE(ivector[ii]);   // Free ivector
        ivector[ii] = 0;
    } else if (LSTR(*ARG2)[0] == 'M') {
        if (ii < 0 || ii >= matrixmax) return;
        if (mdebug == 1) printf("Matrix freed %d\n", ii);
        FREE(matrix[ii]);    // Free Matrix
        matrix[ii] = 0;
    }
}
void R_mset(__unused int func) {
    int matrixname,row,col,indx;
    get_i0(1,matrixname);
    mcheck(matrixname);
    get_i(2,row);
    get_i(3,col);

    matOffset(indx,row,col);
    matrix[matrixname][indx] = Lrdreal(ARG4);

    if (row>fmaxrows[matrixname]) fmaxrows[matrixname]=row;

    Licpy(ARGR,0);
}
void R_mget(__unused int func) {
    int matrixname,row,col,indx;
    get_i0(1,matrixname);
    mcheck(matrixname);
    get_i(2,row);
    get_i(3,col);
    matOffset(indx,row,col);
    Lrcpy(ARGR,  (matrix[matrixname])[indx]);
}
double mmean(int matrixname, int col, int mrow) {
    double mean=0;
    int i,indx;
    if (mrow<=1) return 0;
    for (i = 1; i<=mrow; i++) {
        matOffset(indx,i,col);
        mean=mean+(matrix[matrixname])[indx];
    }
    return mean/mrow;
}
double mhighv(int matrixname, int col, int mrow) {
    double high;
    int i,indx;
    if (mrow<=1) return 0;
    matOffset(indx,1,col);
    high=(matrix[matrixname])[indx];
    for (i = 2; i<=mrow; i++) {
        matOffset(indx,i,col);
        if ((matrix[matrixname])[indx]>high) {
            high=(matrix[matrixname])[indx];
        }
    }
    return high;
}
double mlowv(int matrixname, int col, int mrow) {
    double low;
    int i,indx;
    if (mrow<=1) return 0;
    matOffset(indx,1,col);
    low=(matrix[matrixname])[indx];
    for (i = 2; i<=mrow; i++) {
        matOffset(indx,i,col);
        if ((matrix[matrixname])[indx]<low) low=(matrix[matrixname])[indx];
    }
    return low;
}
double mvariance(int matrixname, int col, int mrow,int meanflag,double meanin) {
    double variance=0,mean=0,temp;
    int i,indx;
    if (mrow<=1) return 0;
    if (meanflag==1) mean=meanin;
    else mean=mmean(matrixname, col, mrow);
    for (i = 1; i<=mrow; i++) {
        matOffset(indx,i,col);
        temp= (matrix[matrixname][indx])-mean;
        variance=variance+temp*temp;
    }
    return sqrt(variance/(mrow-1));
}
int mcopy(int m0){
    int i,j,rows, cols,indx,m1;
    rows=matrows[m0];
    cols=matcols[m0];

    m1= mcreate(rows, cols);
    for (i = 1; i <=rows; i++) {
        for (j = 1; j <= cols; j++) {
            matOffset2(m1,indx,i,j);
            matrix[m1][indx] = matrix[m0][indx];
        }
    }
    return m1;
}
// Insert Column
void R_minscol(__unused int func){
    int i,j,rows, cols,indx,indx2,m1,m2;
    double setf;
    if (ARGN!=2) Lerror(ERR_INCORRECT_CALL,0);
    get_i0(1,m2);

    setf = Lrdreal(ARG2);

    mcheck(m2);

    rows=matrows[m2];
    cols=matcols[m2];

    m1= mcreate(rows, cols+1);
    for (i = 1; i <=rows; i++) {
        matOffset2(m1,indx,i,1);
        matrix[m1][indx] = setf;
    }
    for (i = 1; i <=rows; i++) {
        for (j = 1; j <= cols; j++) {
            matOffset2(m1,indx,i,j+1);
            matOffset2(m2,indx2,i,j);
            matrix[m1][indx] = matrix[m2][indx2];
        }
    }
    Licpy(ARGR,m1);
}
void R_mscalar(__unused int func){
    int i,rows, cols,m1,m2;
    double factor;
    get_i0(1,m2);
    mcheck(m2);
    rows=matrows[m2];
    cols=matcols[m2];
    factor = Lrdreal(ARG2);     /* not L2REAL(): the caller's (#305) */

    m1=mcreate(rows, cols);
    for (i = 0; i<(rows)*(cols); i++) {
        matrix[m1][i] = matrix[m2][i]*factor;
    }
    Licpy(ARGR,m1);
}
void R_mnormalise(__unused int func) {
    int matrixname,m2,i,j,indx,mrows,mcols,divisor=1;
    double mean, variance;
    char option='A';
    get_i0(1,m2);
    if (ARGN >1) option = l2u[(byte)LSTR(*ARG2)[0]];
    else option='S';
    mcheck(m2);
    mrows=matrows[m2];
    mcols=matcols[m2];
    matrixname= mcopy(m2);
    // step 1 calculate mean and variance of array
    for (j = 1; j<=mcols; j++) {
        mean= mmean(m2, j, mrows);
        variance= mvariance(m2, j, mrows,1,mean);
        if (mdebug==1) printf("mean/variance %d %f %f\n",j,mean,variance);
        if (variance==0 && option=='S') goto noVariance;
        if (option=='L') {
            // divisor=pow((int) 10,(int)log(fabs(mhighv(m2,j,mrows))));
            mean=mhighv(m2,j,mrows);
            mean=fabs(mean);
            mean=log10(mean);
            divisor=(int) mean;
            divisor=pow(10,divisor);
        }
        else divisor=1;

        for (i = 1; i<=mrows; i++) {
            matOffset(indx,i,j);
            if (option=='M') (matrix[matrixname][indx])=matrix[matrixname][indx]-mean;
            else if (option=='R') (matrix[matrixname][indx])=matrix[matrixname][indx]/mrows;
            else if (option=='L') {if (divisor>1) (matrix[matrixname][indx])=matrix[matrixname][indx]/(double) divisor;}
            else (matrix[matrixname][indx])=(matrix[matrixname][indx]-mean)/variance;  // option Standard
        }
        noVariance:
        setMatrixStem("_rowvariance",matrixname,j,mvariance(matrixname, j, mrows,0,0));
        setMatrixStem("_rowmean",matrixname,j,mmean(matrixname, j, mrows));
        setMatrixStem("_rowfactor",matrixname,j,(double) divisor);
    }
    Licpy(ARGR,matrixname);
}
void R_mmultiply(__unused int func) {
    int m1,m2,m3,row2,col2,row3,col3,ix1,ix2;
    int i,j,k;
    double sum;
    get_i0(1,m2);
    get_i0(2,m3);
    mcheck(m2);
    mcheck(m3);
    row2=matrows[m2];
    col2=matcols[m2];
    row3=matrows[m3];
    col3=matcols[m3];

    if (col2 != row3) {
        printf("Matrix Multiplication is not possible.\n");
        printf("Matrix 1 dimension :,%d x %d\n",row2,col2);
        printf("Matrix 2 dimension :,%d x %d\n",row3,col3);
        Licpy(ARGR,8);
        return;
    }
    m1= mcreate(row2, col3);
    for (i = 1; i <=row2; i++) {
        for (j = 1; j <= col3; j++) {
            sum=0;
            for (k = 1; k <=row3; k++) {
                matOffset2(m2,ix1,i,k);
                matOffset2(m3,ix2,k,j);
                sum = sum + matrix[m2][ix1]*matrix[m3][ix2];
            }
            matOffset2(m1,ix1,i,j);
            matrix[m1][ix1] = sum;
        }
    }
    Licpy(ARGR, m1);
}
void R_msubtract(__unused int func) {
    int m1,m2,m3,row2,col2,row3,col3,ix1;
    int i,j;
    get_i0(1,m2);
    get_i0(2,m3);
    mcheck(m2);
    mcheck(m3);
    row2=matrows[m2];
    col2=matcols[m2];
    row3=matrows[m3];
    col3=matcols[m3];

    if (row2 != row3 || col2 != col3) {
        printf("Matrix Subtraction is not possible.\n");
        printf("Matrix 1 dimension :,%d x %d\n",row2,col2);
        printf("Matrix 2 dimension :,%d x %d\n",row3,col3);
        Licpy(ARGR,8);
        return;
    }
    m1= mcreate(row2, col2);
    for (i = 1; i <=row2; i++) {
        for (j = 1; j <= col2; j++) {
            matOffset2(m1,ix1,i,j);  // can be used for all 3 matrixes
            matrix[m1][ix1]=matrix[m2][ix1]-matrix[m3][ix1];
        }
    }
    Licpy(ARGR, m1);
}
void R_madd(__unused int func) {
    int m1,m2,m3,row2,col2,row3,col3,ix1;
    int i,j;
    get_i0(1,m2);
    get_i0(2,m3);
    mcheck(m2);
    mcheck(m3);
    row2=matrows[m2];
    col2=matcols[m2];
    row3=matrows[m3];
    col3=matcols[m3];

    if (row2 != row3 || col2 != col3) {
        printf("Matrix Addition is not possible.\n");
        printf("Matrix 1 dimension :,%d x %d\n",row2,col2);
        printf("Matrix 2 dimension :,%d x %d\n",row3,col3);
        Licpy(ARGR,8);
        return;
    }
    m1= mcreate(row2, col2);
    for (i = 1; i <=row2; i++) {
        for (j = 1; j <= col2; j++) {
            matOffset2(m1,ix1,i,j);  // can be used for all 3 matrixes
            matrix[m1][ix1]=matrix[m2][ix1]+matrix[m3][ix1];
        }
    }
    Licpy(ARGR, m1);
}
void R_mprod(__unused int func) {
    int m1,m2,m3,row2,col2,row3,col3,ix1;
    int i,j;
    get_i0(1,m2);
    get_i0(2,m3);
    mcheck(m2);
    mcheck(m3);
    row2=matrows[m2];
    col2=matcols[m2];
    row3=matrows[m3];
    col3=matcols[m3];

    if (row2 != row3 || col2 != col3) {
        printf("Matrix/Matrix Product is not possible.\n");
        printf("Matrix 1 dimension :,%d x %d\n",row2,col2);
        printf("Matrix 2 dimension :,%d x %d\n",row3,col3);
        Licpy(ARGR,8);
        return;
    }
    m1= mcreate(row2, col2);
    for (i = 1; i <=row2; i++) {
        for (j = 1; j <= col2; j++) {
            matOffset2(m1,ix1,i,j);  // can be used for all 3 matrixes
            matrix[m1][ix1]=matrix[m2][ix1]*matrix[m3][ix1];
        }
    }
    Licpy(ARGR, m1);
}
void R_msqr(__unused int func) {
    int m1,m2,row2,col2,ix1;
    int i,j;
    double msum=0.0, msqr=0.0;
    get_i0(1,m2);
    mcheck(m2);
    row2=matrows[m2];
    col2=matcols[m2];

    m1= mcreate(row2, col2);
    for (i = 1; i <=row2; i++) {
        msum=0;
        msqr=0;
        for (j = 1; j <= col2; j++) {
            matOffset2(m1,ix1,i,j);  // can be used for all 3 matrixes
            msum=msum+matrix[m2][ix1];
            matrix[m1][ix1]=matrix[m2][ix1]*matrix[m2][ix1];
            msqr=msqr+matrix[m1][ix1];
        }
        setMatrixStem("_rowsum",m1,i,msum);
        setMatrixStem("_rowsqr",m1,i,msqr);
    }
    Licpy(ARGR, m1);
}
void R_mtranspose(__unused int func) {
    int m1,m2,row2,col2,ix1,ix2;

    int i,j;
    get_i0(1,m2);
    mcheck(m2);
    row2=matrows[m2];
    col2=matcols[m2];

    m1= mcreate(col2,row2);
    for (i = 1; i <=row2; i++) {
        for (j = 1; j <= col2; j++) {
            matOffset2(m1,ix1,j,i);
            matOffset2(m2,ix2,i,j);
            matrix[m1][ix1] = matrix[m2][ix2];
        }
    }
    Licpy(ARGR,m1);
}
void R_minvert(__unused int func) {
    int m1,m2,row2,col2,ix1,ix2,ix3;
    int i,j,k,ij,reorder[1000];
    double max,hi,hr,hv[1000];
    get_i0(1, m2)
    mcheck(m2);
    row2=matrows[m2];
    col2=matcols[m2];
    if (col2 != row2) {
        printf("Matrix inversion not possible!\n");
        Licpy(ARGR,8);
        return;
    }
    m1=mcopy(m2);
    for (i = 1; i <=row2; i++) {
        reorder[i]=i;
    }
    for (j = 1; j <=row2; j++) {
        matOffset2(m1,ix1,j,i);
        max=fabs(matrix[m1][ix1]);
        ij=j;
        for (i = 1; i <=row2; i++) {
            matOffset2(m1,ix1,i,j);
            if (fabs(matrix[m1][ix1] > max)) {
                max=fabs(matrix[m1][ix1]);
                ij=i;
            }
        }
        if (max==0) Lfailure("Matrix is singular","","","","");;
        if (ij > j) {
            for (k = 1; k <=row2; k++) {
                matOffset2(m1,ix1,j,k);
                matOffset2(m1,ix2,ij,k);
                hi=matrix[m1][ix1];
                matrix[m1][ix1]=matrix[m1][ix2] ;
                matrix[m1][ix2]=hi;
            }
            hi=reorder[j];
            reorder[j]=reorder[ij];
            reorder[ij]=hi;
        }
        matOffset2(m1,ix1,j,j);
        hr=1/matrix[m1][ix1];
        for (i = 1; i <=row2; i++) {
            matOffset2(m1,ix2,i,j);
            matrix[m1][ix2]= matrix[m1][ix2] * hr;
        }
        matrix[m1][ix1]=hr;
        for (k = 1; k <=row2; k++) {
            if (k==j) continue;
            matOffset2(m1,ix2,j,k);
            for (i=1; i <=row2; i++) {
                if (i==j) continue;
                matOffset2(m1,ix1,i,k);
                matOffset2(m1,ix3,i,j);
                matrix[m1][ix1]= matrix[m1][ix1] - matrix[m1][ix3] * matrix[m1][ix2];
            }
            matrix[m1][ix2]= -hr * matrix[m1][ix2];
        }
    }
    for (i = 1; i <=row2; i++) {
        for (k = 1; k <=row2; k++) {
            matOffset2(m1,ix1,i,k);
            hv[reorder[k]]=matrix[m1][ix1];
        }
        for (k = 1; k <=row2; k++) {
            matOffset2(m1,ix1,i,k);
            matrix[m1][ix1]=hv[k];
        }
    }
    Licpy(ARGR, m1);
}

void R_mcopy(__unused int func) {
    int m1,m2;
    get_i0(1,m2);
    mcheck(m2);
    m1=mcopy(m2);
    Licpy(ARGR, m1);
}
void R_mdelcol(__unused int func) {
    int m1,m2,j,i,k,skip,col,ix1,ix2,rows,cols,dcols[32]={0};
    get_i0(1,m2);
    get_i(2,skip);    // at least one skip column required
    mcheck(m2);
    rows=matrows[m2];
    cols=matcols[m2];
    if (ARGN>33) Lerror(ERR_INCORRECT_CALL,0);
    k=0;
    for (i=1; i<ARGN; i++) {
        j=Lrdint(rxArg.a[i]);
        if (j>cols || j<1) continue;
        dcols[k] = j;
        k=k+1;
    }
    m1=mcreate(rows,cols-k);    // new column range, k is number of deleted rows
    col=0;
    for (j = 1; j <= cols; j++) {
        skip=0;
        for (k = 0; k < ARGN; k++) {
            if(j!=dcols[k]) continue;
            skip=1;
            break;
        }
        if (skip==1) if (mdebug==1) printf("DELeted %d \n",j);
        if (skip==1) continue;
        col=col+1;
        for (i = 1; i <=rows; i++) {
            matOffset2(m1,ix1,i,col);
            matOffset2(m2,ix2,i,j);
            matrix[m1][ix1] = matrix[m2][ix2];
        }
    }
    Licpy(ARGR, m1);
}
void R_mdelrow(__unused int func) {
    int m1,m2,j,i,k,skip,row,ix1,ix2,rows,cols,drows[32]={0};
    get_i0(1,m2);
    get_i(2,skip);    // at least one skip column required
    mcheck(m2);
    rows=matrows[m2];
    cols=matcols[m2];
    if (ARGN>33) Lerror(ERR_INCORRECT_CALL,0);
    k=0;
    for (i=1; i<ARGN; i++) {
        j=Lrdint(rxArg.a[i]);
        if (j>rows || j<1) continue;
        drows[k] = j;
        k=k+1;
    }
    m1=mcreate(rows-k,cols);    // new column range, k is number of deleted rows
    row=0;
    for (i = 1; i <=rows; i++) {
        skip=0;
        for (k = 0; k < ARGN; k++) {
            if(i!=drows[k]) continue;
            skip=1;
            break;
        }
        if (skip==1) continue;
        row=row+1;
        for (j = 1; j <= cols; j++) {
            matOffset2(m1,ix1,row,j);
            matOffset2(m2,ix2,i,j);
            matrix[m1][ix1] = matrix[m2][ix2];
        }
    }
    Licpy(ARGR, m1);
}
void R_mproperty(__unused int func) {
    int m1,j,i,indx,mrows,mcols;
    double mean,variance,msum=0;
    get_i0(1,m1);
    mcheck(m1);
    mrows=matrows[m1];
    mcols=matcols[m1];

    if (ARGN>1) {
        for (j = 1; j <= mcols; j++) {
            mean = mmean(m1, j, mrows);
            variance = mvariance(m1, j, mrows, 1, mean);
            setMatrixStem("_rowmean", m1, j, mean);
            setMatrixStem("_rowvariance", m1, j, variance);
            setMatrixStem("_rowlow",m1,j,mlowv(m1, j, mrows));
            setMatrixStem("_rowhigh",m1,j,mhighv(m1, j, mrows));
            msum=0;
            for (i = 1; i <= mrows; i++) {
                matOffset2(m1, indx, i, j);
                msum = msum + (matrix[m1][indx]);
            }
            setMatrixStem("_rowsum", m1, j, msum);
            setMatrixStem("_rowsqr", m1, j, msum * msum);
        }
        // sum up cols per row
        for (i = 1; i <= mrows; i++) {
            msum=0;
            for (j = 1; j <= mcols; j++) {
                matOffset2(m1, indx, i, j);
                msum = msum + (matrix[m1][indx]);
            }
            setMatrixStem("_colsum", m1, i, msum);
            setMatrixStem("_colsqr", m1, i, msum * msum);
        }
    }
    setMatrixStem("_rows",m1,-1,mrows);
    setMatrixStem("_cols",m1,-1,mcols);
    setMatrixStem("_mrows",m1,-1,fmaxrows[m1]);
}
void R_mused(__unused int func) {
    int ii,ct=0,size=0;
    printf("Matrices Rows   Cols   Size\n");
    printf("---------------------------\n");
    for (ii = 0; ii <=matrixmax; ++ii) {
        if (matrix[ii]==0) continue;
        ct++;
        size=size+matrows[ii]*matcols[ii]*sizeof(double);
        printf("%3d    %6d %6d %6d\n",ii,matrows[ii],matcols[ii],(int) (matrows[ii]*matcols[ii]*sizeof(double)));
    }
    printf("Active %d, Total Size %dK\n",ct,size/1024);
}

void RxMatrixRegFunctions()
{
    RxRegFunction("MCREATE",    R_mcreate,      0);
    RxRegFunction("MDELCOL",    R_mdelcol,      0);
    RxRegFunction("MDELROW",    R_mdelrow,      0);
    RxRegFunction("MGET",       R_mget,         0);
    RxRegFunction("MSET",       R_mset,         0);
    RxRegFunction("MNORMALISE", R_mnormalise,   0);
    RxRegFunction("MMULTIPLY",  R_mmultiply,    0);
    RxRegFunction("MTRANSPOSE", R_mtranspose,   0);
    RxRegFunction("MCOPY",      R_mcopy,        0);
    RxRegFunction("MINVERT",    R_minvert,      0);
    RxRegFunction("MPROPERTY",  R_mproperty,    0);
    RxRegFunction("MSCALAR",    R_mscalar,      0);
    RxRegFunction("MADD",       R_madd,         0);
    RxRegFunction("MSUBTRACT",  R_msubtract,    0);
    RxRegFunction("MPROD",      R_mprod,        0);
    RxRegFunction("MSQR",       R_msqr,         0);
    RxRegFunction("MINSCOL",    R_minscol,      0);
    RxRegFunction("MFREE",      R_mfree,        0);
    RxRegFunction("MUSED",      R_mused,        0);
} /* RxMatrixRegFunctions() */
