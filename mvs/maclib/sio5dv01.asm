***********************************************************************
**                                                                   **
**       DEFINE THE MAXIMUM BLOCKSIZE FOR ALL THE DEVICES            **
**                                                                   **
**       IF YOU HAVE MULTIPLE DISK DEVICES, PLEASE MAKE SURE         **
**       THAT THE BLOCKSIZE YOU SELECT IS COMPATIBLE FOR ALL         **
**       THESE DEVICES.. FOR EXAMPLE IF YOU HAVE 3350'S AND          **
**       AND 3380'S SELECT A BLOCKSIZE OF ABOUT 6K OR 9K.            **
**       USING THE DEFAULT BLOCKSIZES IN THIS CASE MAY CAUSE         **
**       PROBLEMS FOR THE SORTOUT (SORT) FILES AND THE SYSUT2        **
**       (IEBGENER) FILES SINCE THE MAX BLOCKSIZE FOR A 3350         **
**       IS 19069.                                                   **
**                                                                   **
***********************************************************************
         SIO5DVT DEVICE=3330,BLKSIZE=13030,BUFNUM=(SPACE,65536)
         SIO5DVT DEVICE=3340,BLKSIZE=08368,BUFNUM=(SPACE,65536)
         SIO5DVT DEVICE=3350,BLKSIZE=19069,BUFNUM=(TRACKS,3)
         SIO5DVT DEVICE=3375,BLKSIZE=17600,BUFNUM=(TRACKS,3)
         SIO5DVT DEVICE=3380,BLKSIZE=23476,BUFNUM=(TRACKS,2)
         SIO5DVT DEVICE=3420,BLKSIZE=32760,BUFNUM=(NUMBER,5)
         SIO5DVT DEVICE=3480,BLKSIZE=32760,BUFNUM=(NUMBER,5)
         END
