pdshash: Procedure
  parse upper arg lib,member
  dsn=lib"("member")"
  fk1=open("'"dsn"'",'RT')
  if fk1<0 then return -1
  buffer=read(fk1,16000)
  hash=rhash(buffer)
  call close fk1
return hash
