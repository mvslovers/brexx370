        say copies('-',60)
        say "Create a Float Array"
        say copies('-',60)
         f1=fcreate(100)
         do i=1 to 51    /* I * PI / Euler */
            call fset(f1,i,i*3.14/0.5772156649)
         end
         call flist(f1,,,"Float Array")
        say copies('-',60)
        say "After some float operations"
        say copies('-',60)
         do i=1 to 51    /* I * PI / Euler */
            say right(i,3,'0') fget(f1,i)*fget(f1,random(1,50))
         end
