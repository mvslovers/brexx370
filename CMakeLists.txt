cmake_minimum_required(VERSION 3.13)
project(brexx C)

SET(CMAKE_C_STANDARD 90)
SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D__CROSS__")
#SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -O0 -fPIC -std=c89 -stdlib=libc++ -Wall")
SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fcommon")
SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -D__DEBUG__")

include_directories(inc)
include_directories(printf)
include_directories(map)
include_directories(fss)
include_directories(mvs)
include_directories(dynit)
include_directories(rac)
include_directories(regex)
include_directories(smf)
include_directories(metal)
include_directories(cross)

add_executable(brexx
        inc/addrlink.h
        inc/bintree.h
        inc/bmem.h
        inc/compile.h
        inc/config.h
        inc/dqueue.h
        inc/external.h
        inc/interpre.h
        inc/irx.h
        inc/ldefs.h
        inc/lerror.h
        inc/lmvs.h
        inc/lstring.h
        inc/mvssup.h
        inc/nextsymb.h
        inc/os.h
        inc/preload.h
        inc/rexx.h
        inc/rxdefs.h
        inc/rxexecio.h
        inc/rxmvs.h
        inc/rxmvsext.h
        inc/rxnje.h
        inc/rxrac.h
        inc/rxregex.h
        inc/rxtcp.h
        inc/rxvsamio.h
        inc/sarray.h
        inc/stack.h
        inc/trace.h
        inc/util.h
        inc/variable.h
        inc/rxtso.h
        lstring/abbrev.c
        lstring/abs.c
        lstring/add.c
        lstring/b2x.c
        lstring/bitand.c
        lstring/bitor.c
        lstring/bitxor.c
        lstring/bool.c
        lstring/c2d.c
        lstring/c2x.c
        lstring/center.c
        lstring/changest.c
        lstring/charin.c
        lstring/charout.c
        lstring/chars.c
        lstring/compare.c
        lstring/copies.c
        lstring/countstr.c
        lstring/d2c.c
        lstring/d2x.c
        lstring/datatype.c
        lstring/date.c
        lstring/dec.c
        lstring/delstr.c
        lstring/delword.c
        lstring/div.c
        lstring/equal.c
        lstring/errortxt.c
        lstring/expose.c
        lstring/filter.c
        lstring/format.c
        lstring/hashvalu.c
        lstring/inc.c
        lstring/index.c
        lstring/insert.c
        lstring/intdiv.c
        lstring/justify.c
        lstring/lastpos.c
        lstring/linein.c
        lstring/lineout.c
        lstring/lines.c
        lstring/lmath.c
        lstring/lower.c
        lstring/lstring.c
        lstring/mod.c
        lstring/mult.c
        lstring/neg.c
        lstring/overlay.c
        lstring/print.c
        lstring/read.c
        lstring/reradix.c
        lstring/reverse.c
        lstring/right.c
        lstring/round.c
        lstring/sign.c
        lstring/soundex.c
        lstring/space.c
        lstring/stderr.c
        lstring/strip.c
        lstring/sub.c
        lstring/substr.c
        lstring/subword.c
        lstring/time.c
        lstring/translat.c
        lstring/trunc.c
        lstring/upper.c
        lstring/verify.c
        lstring/word.c
        lstring/wordidx.c
        lstring/wordlen.c
        lstring/wordpos.c
        lstring/words.c
        lstring/write.c
        lstring/x2b.c
        lstring/x2c.c
        lstring/x2d.c
        lstring/xrange.c
        lstring/d2p.c
        lstring/p2d.c
        src/address.c
        src/addrlink.c
        src/bintree.c
        src/bmem.c
        src/brexx.c
        src/builtin.c
        src/compile.c
        src/dqueue.c
        src/error.c
        src/expr.c
        src/external.c
        src/hostenv.c
        src/interpre.c
        src/mvssup.c
        src/nextsymb.c
        src/preload.c
        src/rexx.c
        src/rexxfunc.c
        src/rxconv.c
        src/rxexecio.c
        src/rxfiles.c
        src/rxfss.c
        src/rxmath.c
        src/rxmvs.c
        src/rxnje.c
        src/rxstr.c
        src/rxrac.c
        src/rxregex.c
        src/rxtcp.c
        src/rxtso.c
        src/rxvsamio.c
        src/rxword.c
        src/stack.c
        src/template.c
        src/trace.c
        src/util.c
        src/variable.c
        dynit/dynit.h
        dynit/dynit.c
        dynit/svc99.h
        dynit/svc99.c
        fss/fss.h
        fss/fss.c
        rac/rac.h
        rac/rac.c
        cross/jccdummy.h
        cross/jccdummy.c
        map/hashing.h
        map/hashing.c
        map/hashmap.h
        map/hashmap.c
        map/list.h
        map/list.c
        smf/smf.h
        smf/smf.c
        regex/re.h
        regex/re.c )

add_library(irxexcom
        irx/irxexcom.c src/bintree.c metal/metal.c metal/metal.h printf/printf.c printf/printf.h)

add_library(irxinit
        irx/irxinit.c printf/printf.c printf/printf.h)

add_library(irxsay
        irx/irxsay.c printf/printf.c printf/printf.h)

add_library(metal
        metal/metal.c metal/metal.h printf/printf.c printf/printf.h)

if(UNIX AND NOT APPLE)
   target_link_libraries(brexx m)
endif()
