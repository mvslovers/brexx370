#
# change the following variables to fit your needs
#

JCCFOLDER   := ../../jcc
RDRPREP     := rdrprep

# SYSTEM determines how you want to build BREXX
#
# You can either uncomment the line below or run make
# with make SYSTEM=TK4- (for example) to build for TK4-
#
# MVSCE:
#   If you select MVSCE you must have hercules installed
#   and make sure the MVSCEFOLDER is set to the folder
#   where you extracted the MVS/CE tar file. The rest of 
#   MVS/CE settings are defaults, change them to fit
#   your needs.
#
# TK5/TK4-:
#  To use TK5/TK4- you need to first IPL (boot) TK5/TK4-
#  before you use this makefile. Make sure the TK5FOLDER/TK4FOLDER
#  is set properly (depending on which one you use). Also the 
#  webserver must be enabled to use this make file.
#
# Remote systems:
#  Unfortunately remote systems aren't supported
#
# -----------------------
#SYSTEM      := MVSCE
SYSTEM      := TK5
#SYSTEM      := TK4-
# -----------------------
# MVS/CE Settings
# -----------------------
MVSCEHOST   := 127.0.0.1
MVSCEPORT   := 3505
MVSCEUSER   := IBMUSER
MVSCEPASS   := SYS1
MVSCEFOLDER := /MVSCE
# -----------------------
# TK5 Settings
# -----------------------
TK5HOST     := 127.0.0.1
TK5PORT     := 3505
TK5WEB      := 8038
TK5USER     := HERC01
TK5PASS     := CUL8TR
TK5FOLDER   := /mvs-tk5
# -----------------------
# TK4- Settings
# -----------------------
TK4HOST     := 127.0.0.1
TK4PORT     := 3505
TK4WEB      := 8038
TK4USER     := HERC01
TK4PASS     := CUL8TR
TK4FOLDER   := /tk4-
# -----------------------
# NJE38
# -----------------------
#
# NJE is not installed by default on MVS/CE or TK4-
# You need to install it for the build to succeed.
# To disable the warning message and build IRXNJE38
# uncoment this line:
# NJE=YES
#
# by default it will send to MSGCLASS A or H, set
# CUSTOMCLASS below if you want to use a different class
CUSTOMCLASS := A

# Uncomment this line if you want verbose console logging
#DEBUG       := -d

TARGET      := brexx.objp
XMI         := BREXX.RELEASE.V$(shell date +"%Y%m%d").XMI
#CC          := $(JCCFOLDER)/jcc
#OBJSCAN     := $(JCCFOLDER)/objscan
#PRELINK     := $(JCCFOLDER)/prelink
CC          := wine $(JCCFOLDER)/jcc.exe
OBJSCAN     := wine $(JCCFOLDER)/objscan.exe
PRELINK     := wine $(JCCFOLDER)/prelink.exe
JCCINCS     := $(JCCFOLDER)/include
JCCOBJS     := $(JCCFOLDER)/objs
JCCLIBLIST  := $(JCCOBJS)/liblst.txt
BUILDER    := python3 builder.py

########################################
SHELL := /bin/bash
VERSION=$(shell grep "VERSION " ../inc/rexx.h|awk  '{gsub(/"/, "", $$3); print $$3}')


SRC_DIRS := ../src ../lstring ../rac ../dynit ../fss ../map ../smf ../regex
INC_DIRS := $(JCCINCS) ../inc ../rac ../dynit ../fss ../map ../smf ../regex ../cross
ASM_DIRS := ../asm
MAC_DIRS := ../maclib
VPATH = $(SRC_DIRS)

RXMVSEXT := ../asm/rxsvc.hlasm \
            ../asm/rxabend.hlasm \
			../asm/rxikj441.hlasm \
			../asm/rxinit.hlasm \
			../asm/rxterm.hlasm \
			../asm/rxtso.hlasm \
			../asm/rxvsam.hlasm \
			../asm/rxcputim.hlasm \
			../asm/rxcpcmd.hlasm \
			../asm/rxestae.hlasm 

IRXVTOC_SRCS := $(shell find $(ASM_DIRS) -iname vtoc*.hlasm )

METAL_SRCS := ../metal/metal.c \
			  ../printf/printf.c  

METAL_OBJS := $(addsuffix .obj, $(notdir $(basename $(METAL_SRCS))))

#IRXEXCOM_SRCS := ../lstring/upper.c ../lstring/lstring.c ../src/bintree.c 
#IRXEXCOM_OBJS := $(addsuffix .obj, $(notdir $(basename $(IRXEXCOM_SRCS))))
# file and variable to denote these JCL only files were built successfully
IRXVTOC      := irxvtoc.dummy
IRXVSMIO	 := irxvsmio.dummy
IRXVSMTR	 := irxvsmtr.dummy
IRXISTAT	 := irxistat.dummy
MVSDUMP		 := mvsdump.dummy
IRXEXCOM     := irxexcom.dummy
IRXNJE38     := irxnje38.dummy
BREXXLNK     := brexx.dummy
RELEASE      := BREXX_CURRENT.XMIT

SRCS := $(shell find $(SRC_DIRS) -name *.c )
INCS := $(shell find $(INC_DIRS) -type d)
OBJS := $(addsuffix .obj, $(notdir $(basename $(SRCS))))

INC_FLAGS := $(addprefix -I,$(INC_DIRS))
D_FLAGS   := -D__MVS__
ifdef LEVEL
	D_FLAGS   := $(D_FLAGS) -DLEVEL="\"${LEVEL}\""
endif

ifeq ($(SYSTEM),TK5)
BUILDER := $(BUILDER) $(DEBUG) -s $(SYSTEM) -f $(TK5FOLDER) -u $(TK5USER) -p $(TK5PASS) 
else ifeq ($(SYSTEM),TK4-)
BUILDER := $(BUILDER) $(DEBUG) -s $(SYSTEM) -f $(TK4FOLDER) -u $(TK4USER) -p $(TK4PASS)
else ifeq ($(SYSTEM),MVSCE)
BUILDER := $(BUILDER) $(DEBUG) -s $(SYSTEM) -f $(MVSCEFOLDER) -u $(MVSCEUSER) -p $(MVSCEPASS)
else
	@echo "Unknown system specified: $(SYSTEM)"
	@exit 1
endif

CC_FLAGS  := $(INC_FLAGS) $(D_FLAGS) -o -fstk -list=list.out

JCC := $(CC) $(CC_FLAGS)
RM  := rm

ifeq ($(CUSTOMCLASS),)
CUSTOMCLASS = $(MSGCLASS)
endif

.PHONY: clean all install test release check jcl

all: $(TARGET) $(IRXVTOC) $(IRXVSMIO) $(IRXVSMTR) $(IRXISTAT) $(MVSDUMP) $(IRXEXCOM) $(IRXNJE38) $(BREXXLNK)

version: 
	touch ../src/brexx.c

jcl:
	$(BUILDER) --write_all

$(TARGET): $(OBJS) rxmvsext.obj
	@echo "# prelinking JCC objects into brexx.objp"
	@$(PRELINK) -s $(JCCOBJS) brexx.objp $(OBJS) rxmvsext.obj >> prelink.log 2>&1
	
%.obj: %.c
	@echo "# compiling " $<
	$(JCC) $< 

rxmvsext.obj: $(RXMVSEXT)
	@echo "# Assembling RXMVSEXT in to BREXX.BUILD.LOADLIB"
	$(BUILDER) --RXMVSEXT
	@echo "# creating rxmvsext.obj"
	@$(OBJSCAN) rxmvsext.punch rxmvsext.nam rxmvsext.obj >> rxmvsext_objscan.log 2>&1

$(IRXVTOC): $(IRXVTOC_SRCS)
	@echo "# Building IRXVTOC with: $(IRXVTOC_SRCS)"
	$(BUILDER) --IRXVTOC 
	@echo "This is a dummy file, delete me to rebuild IRXVTOC" > $(IRXVTOC)

$(IRXVSMIO): $(ASM_DIRS)/rxvsmio1.hlasm
	@echo "# Assembling IRXVSMIO in to BREXX.BUILD.LOADLIB"
	$(BUILDER) --IRXVSMIO
	@echo "This is a dummy file, delete me to rebuild IRXVSMIO" > $(IRXVSMIO)

$(IRXVSMTR): $(ASM_DIRS)/rxvsmio2.hlasm
	@echo "# Assembling IRXVSMTR in to BREXX.BUILD.LOADLIB"
	$(BUILDER) --IRXVSMTR
	@echo "This is a dummy file, delete me to rebuild IRXVSMTR" > $(IRXVSMTR)
	
$(IRXISTAT): $(ASM_DIRS)/rxpdstat.hlasm
	@echo "# Assembling IRXSTAT in to BREXX.BUILD.LOADLIB"
	$(BUILDER) --IRXISTAT
	@echo "This is a dummy file, delete me to rebuild IRXISTAT" > $(IRXISTAT)

$(MVSDUMP): $(ASM_DIRS)/mvsdump.hlasm
	@echo "# Assembling mvsdump in to BREXX.BUILD.LOADLIB"
	$(BUILDER) --MVSDUMP
	@echo "This is a dummy file, delete me to rebuild MVSDUMP" > $(MVSDUMP)

$(IRXNJE38): $(ASM_DIRS)/rxnje38.hlasm
ifeq ($(SYSTEM), TK5)
	@echo "# Assembling rxnje38 in to BREXX.BUILD.LOADLIB"
	$(BUILDER) --IRXNJE38
	@echo "This is a dummy file, delete me to rebuild MVSDUMP" > $(IRXNJE38)
else ifeq ($(NJE), YES)
	@echo "# Assembling rxnje38 in to BREXX.BUILD.LOADLIB"
	$(BUILDER) --IRXNJE38
	@echo "This is a dummy file, delete me to rebuild MVSDUMP" > $(IRXNJE38)
else
ifneq ($(NJE),YES)
ifeq ($(SYSTEM), TK4-)
	@echo '# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
	@echo '# '
	@echo '# IRXNJE38'
	@echo '# '
	@echo "# You're building BREXX without NJE Support!"
	@echo '# '
	@echo "# TK4- Requires NJE38 to be installed before building"
	@echo "# If NJE38 is installed, rerun make with:"
	@echo '# '
	@echo "#   make NJE=YES"
	@echo '# '
	@echo "# You can disable/ignore this message by creating the"
	@echo "# file irxnje38.dummy"
	@echo '# '
	@echo '# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
else ifeq ($(SYSTEM), MVSCE)
	@echo '# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
	@echo '# '
	@echo '# IRXNJE38'
	@echo '# '
	@echo "# You're building BREXX without NJE Support!"
	@echo '# '
	@echo "# MVSCE Requires NJE38 to be installed before building"
	@echo "# It can be installed with the TSO command:"
	@echo '# '
	@echo "# RX MVS INSTALL NJE38"
	@echo '# '
	@echo "# If NJE38 is installed, rerun make with:"
	@echo '# '
	@echo "#   make NJE=YES"
	@echo '# '
	@echo "# You can disable/ignore this message by creating the"
	@echo "# file irxnje38.dummy"
	@echo '# '
	@echo '# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
endif
endif
endif


SVC.punch GETSA.punch: $(ASM_DIRS)/svc.hlasm $(ASM_DIRS)/getsa.hlasm
	@echo "# Assembling SVC and GETSA"
	$(BUILDER) --METAL

metal.objp: ../metal/metal.c ../printf/printf.c SVC.punch GETSA.punch
	@echo "# Building Metal.objp"
	@echo "# Compiling ../metal/metal.c"
	@$(CC) $(INC_FLAGS) -I../metal -I../printf $(D_FLAGS) -o -fstk -list=list.metal.out -systemr ../metal/metal.c >> jcc.log 2>&1
	@echo "# Compiling ../printf/printf.c"
	@$(CC) $(INC_FLAGS) -I../metal -I../printf $(D_FLAGS) -o -fstk -list=list.printf.out -systemr ../printf/printf.c >> jcc.log 2>&1
	@echo "# Prelinking SVC.punch GETSA.punch $(METAL_OBJS) $(JCCFOLDER)/objs/ctype.obj"
	@$(PRELINK) -pre=MC -s NOLIB metal.objp SVC.punch GETSA.punch $(METAL_OBJS) $(JCCFOLDER)/objs/ctype.obj >> metal.prelink.log 2>&1

irxexcom.objp: ../lstring/upper.c ../lstring/lstring.c ../src/bintree.c ../irx/irxexcom.c 
	@echo "# Compiling ../lstring/upper.c"
	@$(CC) $(INC_FLAGS) $(D_FLAGS) -D__METAL_C__  -o -fstk -systemr ../lstring/upper.c >> jcc.log 2>&1
	@echo "# Compiling ../src/bintree.c"
	@$(CC) $(INC_FLAGS) $(D_FLAGS) -D__METAL_C__  -o -fstk -systemr ../src/bintree.c >> jcc.log 2>&1
	@echo "# Compiling ../irx/irxexcom.c"
	@$(CC) $(INC_FLAGS) -I../metal -I../printf $(D_FLAGS) -D__METAL_C__  -o -fstk -systemr ../irx/irxexcom.c >> jcc.log 2>&1
	@echo "# Prelinking irxexcom.objp with lstring.obj upper.obj bintree.obj irxexcom.obj"
	@$(PRELINK) -s NOLIB irxexcom.objp lstring.obj upper.obj bintree.obj irxexcom.obj  >> irxexcom.prelink.log 2>&1
	@$(RM) lstring.obj upper.obj bintree.obj irxexcom.obj

$(IRXEXCOM): irxexcom.objp metal.objp
	@echo "# Linking IRXEXCOM in to BREXX.BUILD.LOADLIB"
	$(BUILDER) --IRXEXCOM
	@echo "This is a dummy file, delete me to rebuild IRXEXCOM" > $(IRXEXCOM)


$(BREXXLNK): $(TARGET)
	$(BUILDER) --BREXX
	@echo "This is a dummy file, delete me to relink brexx.objp to BREXX.BUILD.LOADLIB" > $(BREXXLNK)

clean:
	@$(MAKE) -C ../docs clean
	@$(RM) -f *.obj *.objp *.out *.jcl *.dummy *.log *.punch *.XMIT NO_NJE38.txt *.zip *.ZIP *.pdf
	@$(RM) -rf html
	$(BUILDER) --CLEAN

install: check $(BREXXLNK) $(IRXVTOC) $(IRXVSMIO) $(IRXVSMTR) $(IRXISTAT) $(MVSDUMP) $(IRXEXCOM)
	$(BUILDER) --INSTALL

test: 
	$(BUILDER) --TESTS

check:
	$(BUILDER) --LENGTH

$(RELEASE): documentation
	$(BUILDER) --RELEASE

release: check $(BREXXLNK) $(IRXVTOC) $(IRXVSMIO) $(IRXVSMTR) $(IRXISTAT) $(MVSDUMP) $(IRXEXCOM) $(RELEASE) $(IRXNJE38)
	@echo "# Making BREXX.RELEASE.ZIP"
ifneq ("$(wildcard $(IRXNJE38))","")
	zip -r BREXX.$(VERSION).ZIP BREXX.$(VERSION).XMIT BREXX370_Users_Guide.pdf html
else
	@echo "This build of BREXX does not include NJE38 support" > NO_NJE38.txt
	zip -r BREXX.$(VERSION).ZIP BREXX.$(VERSION).XMIT BREXX370_Users_Guide.pdf NO_NJE38.txt html
endif

documentation:
	@ echo "# Building HTML documentation in docs/build/html"
	@$(MAKE) -C ../docs html
	@ echo "# Building PDF documentation in docs/build/pdf"
	@$(MAKE) -C ../docs pdf
	@ echo "# Building markdown documentation in docs/build/markdown"
	@$(MAKE) -C ../docs markdown
	@echo "# Copying BREXX370_Users_Guide.pdf to build folder"
	@cp ../docs/build/pdf/BREXX370_Users_Guide.pdf ./
	@echo "# Copying installation guide to build jcl folder"
	@cp ../docs/build/markdown/installation.md jcl/'$$'README.txt
	@echo "# Copying HTML documentation to build folder"
	@cp -r ../docs/build/html/ ./