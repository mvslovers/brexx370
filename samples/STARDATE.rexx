        say STDATE()
        say STDATE('XE', 89898.41 ,'SDW')
        say STDATE('SDW','12/31/2322','XU')
        say STDATE('XE','01.00','SDW')
        say STDATE('XE','01.00','SDW','BASE2')
        say STDATE('XE',2265.11,'SDW')
        say STDATE('SDW','01/01/2323','XU')
        say STDATE('SDW','05/15/2323','XU')
        /*
        say STDATE() 77073.77 for current date of 01/28/2024
        say STDATE( XE , 89898.41 , SDW ) 24/11/2036
        say SDATE( SDW , 12/31/2322 , XU ) 375997.26
        say STDATE('XE','01.00','SDW') 01/01/1947
        say STDATE('XE','01.00','SDW', BASE2 ) 01/01/2023
        say SDATE( XE ,2265.11, SDW ) 07/04/1949
        say SDATE( SDW , 01/01/2323 , XU ) 0.00
        say SDATE( SDW , 05/15/2323 , XU ) 367.1
         */
