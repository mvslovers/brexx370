Matrix and Integer Array functions
==================================

.. function:: ICREATE(elements,mode)

    Creates an integer array with the size elements. Returned is the 
    array number to be used to address the array with ISET and IGET. You 
    can have up to 64 integer arrays. Depending on the virtual storage 
    they may contain 1 million elements and more. Accessing integer 
    arrays is very fast as there is no overhead compared to STEM variables.
    
    :param elements: Number entries available 
    :param mode: The initialization type. If mode is not set the array remains uninitialized.

    +-----------------+----------------------------------------+
    | Mode            | Description                            |
    +=================+========================================+
    | Element-Number  | index of element                       |
    +-----------------+----------------------------------------+
    | NULL            | elements are set to 0                  |
    +-----------------+----------------------------------------+
    | DESCENT         | index of the element in reverse order  |
    +-----------------+----------------------------------------+
    | SUNDARAM        | prime numbers (Sundaram algorithm)     |
    +-----------------+----------------------------------------+
    | PRIME           | prime numbers (sieve of Erasthones)    |
    +-----------------+----------------------------------------+

.. function:: ISET(array-number,element-number,integer-value) 
    
    Sets a certain element of an array with an integer value.

.. function:: IGET(array-number,element-number)
    
    Gets (returns) a certain element of an array with an integer value.

.. function:: MCREATE(rows,columns)
    
    Creates a (Float) matrix with size `[rows x columns]`. Returned is the 
    Matrix number to be used in various matrix operations. You can have 
    up to 128 matrixes, depending on the virtual storage available. 
    Accessing a matrix is very fast as there is no overhead compared to 
    STEM variables.

.. function:: MSET(matrix-number,row,column,float-value)
    
    Sets a certain element of the matrix with a float value.

.. function:: MGET(matrix-number,row,column)
    
    Gets (returns) a certain element of the matrix.

.. function:: MMULTIPLY(matrix-number-1,matrix-number-2)
    
    Multiplies 2 matrices and creates a new matrix, which is returned. 
    Input matrices remain untouched. The format of matrix-1 is 
    `[rows x columns]`, therefore the format of matrix-2 must be 
    `[columns x rows]`. The format of the result matrix is rows x rows.

.. function:: MINVERT(matrix-number) 

    Inverts the given matrix and creates a new matrix, which is 
    returned. The input matrix must be squared and remains untouched. 
    The format of the result matrix remains the same as the input 
    matrix.

.. function:: MTRANSPOSE(matrix-number)
    
    Transposes the given matrix and creates a new matrix, which is 
    returned. The input matrix remains untouched. If the format of the 
    input matrix is [rows x columns] then the result matrix is 
    columns x rows.
    
.. function:: MCOPY(matrix-number)
    
    Copies the given matrix and creates a new matrix, which is returned. 
    The input matrix remains untouched. Formats of both matrices are equal.

.. function:: MNORMALISE(matrix-number,mode)
    
    Normalises the given matrix and creates a new matrix, which is 
    returned. The input matrix remains untouched. Formats of both 
    matrices are equal.

    +-----------+----------------------------------------------------------------+
    | Mode      | Description                                                    |
    +===========+================================================================+
    | STANDARD  | row is normalized to mean=0 variance=1                         |
    +-----------+----------------------------------------------------------------+
    | ROWS      | row value is divided by number of rows                         |
    +-----------+----------------------------------------------------------------+
    | MEAN      | row value is normalized to mean=0, variance remains unchanged  |
    +-----------+----------------------------------------------------------------+

.. function:: MDELROW(matrix-number,row-number[,row-number[,row-number...]])
    
    Copies the given matrix without the specified rows-to-delete as a 
    new matrix, which is returned. The input matrix remains untouched.

.. function:: MDELCOL(matrix-number,col-number[,col-number[,col-number...]])

    Copies the given matrix without the specified columns-to-delete as a 
    new matrix, which is returned. The input matrix remains untouched.

.. function:: MPROPERTY(matrix-number[,”FULL”/”BASIC”])
    
    Returns the properties of the given matrix in BREXX variables:

    +--------+------------------------------+
    | _rows  | number of rows of matrix     |
    +--------+------------------------------+
    | _cols  | number of columns of matrix  |
    +--------+------------------------------+

    If **FULL** is specified additionally the the following stem 
    variables are returned:

    +------------------------+---------------------------------------+
    | Stem                   | Description                           |
    +========================+=======================================+
    | _rowmean.column-i      | mean of rows of column-i              |
    +------------------------+---------------------------------------+
    | _rowvariance.column-i  | variance of rows of column-i          |
    +------------------------+---------------------------------------+
    | _rowlow.column-i       | lowest row value of column-i          |
    +------------------------+---------------------------------------+
    | _rowhigh.column-i      | highest row value of column-i         |
    +------------------------+---------------------------------------+
    | _rowsum.column-i       | sum of row value of column-i          |
    +------------------------+---------------------------------------+
    | _rowsqr.column-i       | sum of squared row value of column-i  |
    +------------------------+---------------------------------------+
    | _colsum.row-i          | sum of column values of row-i         |
    +------------------------+---------------------------------------+

.. function:: MSCALAR(matrix-number,number)
    
    Multiplies each element of a matrix with a number (float). The 
    result is stored in a new matrix, which is returned. The input 
    matrix remains untouched.

.. function:: MADD(matrix-number-1, matrix-number-2)
    
    Adds each element of a matrix-1 with the same element of matrix-2. 
    The result is stored in a new matrix, which is returned. The input 
    matrix remains untouched. Matrix-1 and matrix-2 must have the same 
    dimensions.

.. function:: MSUBTRACT(matrix-number-1, matrix-number-2)
    
    Subtracts each element of a matrix-2 from the same element of 
    matrix-1. The result is stored in a new matrix, which is returned. 
    The input matrix remains untouched. Matrix-1 and matrix-2 must have
    the same dimensions.

.. function:: MPROD(matrix-number-1, matrix-number-2)
    
    Multiplies each element of a matrix-1 with the same element of 
    matrix-2. The result is stored in a new matrix, which is returned. 
    The input matrix remains untouched. Matrix-1 and matrix-2 must have 
    the same dimensions.

.. function:: MSQR(matrix-number)
    
    Squares each element of the matrix. The result is stored in a new 
    matrix, which is returned. The input matrix remains untouched.

.. function:: MINSCOL(matrix-number,) 
    
    Inserts a new column as the first column. The initial first column 
    becomes the second column, etc. The result is stored in a new 
    matrix, which is returned. The input matrix remains untouched.

.. function:: MFREE([matrix-number/integer-array-number,“MATRIX”/”INTEGER-ARRAY”])
    
    Frees the storage of allocated matrices and/or integer arrays. If no 
    parameter is specified all allocations are freed. To release a 
    specific matrix or integer-array the matrix-number or 
    integer-array-number must be used as the first parameter, followed 
    by the type to release.