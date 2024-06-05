#
# change the following variables to fit your needs
#

JCCFOLDER   := ../../../jcc
RDRPREP     := rdrprep
TK4HOST     := 192.168.0.102
TK4PORT     := 3506
TK4USER     := IBMUSER
TK4PASS     := SYS1
TK4PRINTER  := ../../../tk4-test/prt/prt00e.txt
# by default it will send to MSGCLASS A or H, set
# CUSTOMCLASS below if you want to use a different class
CUSTOMCLASS := A

#
#
#

TARGET      := brexx.objp
FTP_PORT    := 21021
CC          := $(JCCFOLDER)/jcc
OBJSCAN     := $(JCCFOLDER)/objscan
PRELINK     := $(JCCFOLDER)/prelink
#CC          := wine $(JCCFOLDER)/jcc.exe
#OBJSCAN     := wine $(JCCFOLDER)/objscan.exe
#PRELINK     := wine $(JCCFOLDER)/prelink.exe
JCCINCS     := $(JCCFOLDER)/include
JCCOBJS     := $(JCCFOLDER)/objs
JCCLIBLIST  := $(JCCOBJS)/liblst.txt
ASSEMBLE    := python3 assemble.py
NC          := nc
SLEEP       := 25

########################################
SHELL := /bin/bash
VERSION=$(shell grep "VERSION " ../../inc/rexx.h|awk  '{gsub(/"/, "", $$3); print $$3}')

SRC_DIRS := ../../src ../../lstring ../../rac ../../dynit ../../fss ../../map ../../smf ../../regex
INC_DIRS := $(JCCINCS) ../../inc ../../rac ../../dynit ../../fss ../../map ../../smf ../../regex ../../cross
ASM_DIRS := ../../asm
MAC_DIRS := ../../maclib
VPATH = $(SRC_DIRS)

SRCS := $(shell find $(SRC_DIRS) -name *.c )
INCS := $(shell find $(INC_DIRS) -type d)
OBJS := $(addsuffix .obj, $(notdir $(basename $(SRCS))))

INC_FLAGS := $(addprefix -I,$(INC_DIRS))
D_FLAGS   := -D__MVS__
ifdef LEVEL
	D_FLAGS   := $(D_FLAGS) -DLEVEL="\"${LEVEL}\""
endif

CC_FLAGS  := $(INC_FLAGS) $(D_FLAGS) -o -fstk -list=list.out

JCC := $(CC) $(CC_FLAGS)
RM  := rm

# Set the MSGCLASS to A if we have a local printer
MSGCLASS = H
ifneq ("$(wildcard $(TK4PRINTER))","")
MSGCLASS = A
endif

ifeq ($(CUSTOMCLASS),)
CUSTOMCLASS = $(MSGCLASS)
endif

.PHONY: clean all install uninstall test release unrelease

all: version link

version: 
	touch ../../src/brexx.c
	
link: $(TARGET)
	@echo "# Generating link job using  USER=$(TK4USER) PASS=$(TK4PASS) MSGCLASS=$(CUSTOMCLASS)"
	@./link.sh brexx.objp $(TK4USER) $(TK4PASS) $(CUSTOMCLASS) > link.jcl
	@echo "# Converting to EBCDIC"
	@$(RDRPREP) link.jcl
	@echo "# Submiting  link job to reader at $(TK4HOST):$(TK4PORT)"
	@$(NC) -w1 $(TK4HOST) $(TK4PORT) < reader.jcl
ifeq ($(CUSTOMCLASS), X) 
	@echo "# Sleeping for $(SLEEP) seconds before checking job results" 
	@sleep $(SLEEP)
	@./rc.sh link.jcl $(TK4PRINTER)
else
	@echo "# Job submitted, check output spool on $(TK4HOST) for results"
endif
	
assemble: $(TARGET)
	@echo "# Generating JCL from $(ASM_DIRS) $(MAC_DIRS) MSGCLASS=$(CUSTOMCLASS)"
	@./assemble-link.sh $(ASM_DIRS) $(MAC_DIRS) brexx.objp $(CUSTOMCLASS) > assemble-link.jcl
	@echo "# Converting to EBCDIC"
	@$(RDRPREP) assemble-link.jcl
	@echo "# Submiting to reader at $(TK4HOST):$(TK4PORT)"
	@$(NC) -w1 $(TK4HOST) $(TK4PORT) < reader.jcl
ifeq ($(CUSTOMCLASS), A) 
	@echo "# Sleeping for $(SLEEP) seconds before checking job results" 
	@sleep $(SLEEP)
	@echo "# Checking job results"
	@echo "# Job RC"
	@./rc.sh assemble-link.jcl $(TK4PRINTER)
else
	@echo "# Job submitted, check output spool on $(TK4HOST) for results"
endif

$(TARGET): $(OBJS)
	@echo "# prelinking JCC objects into brexx.objp"
	$(PRELINK) -s $(JCCOBJS) brexx.objp $(OBJS) obj/rxmvsext.obj >> prelink.log 2>&1
	
%.obj: %.c
	@echo "# compiling " $<
	@$(JCC) $< >> jcc.log 2>&1

clean:
	@$(RM) -f *.obj brexx.objp jcc.log list.out prelink.log *.jcl
	@./clean.sh $(TK4USER) $(TK4PASS) $(CUSTOMCLASS) > clean.jcl
	@$(RDRPREP) clean.jcl
	@$(NC) -w1 $(TK4HOST) $(TK4PORT) < reader.jcl
ifeq ($(CUSTOMCLASS), A) 
	@echo "# Sleeping for $(SLEEP) seconds before checking job results"
#	@sleep $(SLEEP)
	@echo "# Checking job results"
#	./rc.sh clean.jcl $(TK4PRINTER)
endif
	@$(RM) -f *.jcl


install: link 
	@echo "# Installing Brexx/370 with USER=$(TK4USER) PASS=$(TK4PASS) MSGCLASS=$(CUSTOMCLASS)"
	@./install.sh $(TK4USER) $(TK4PASS) $(CUSTOMCLASS) > install.jcl
	@echo "# Converting to EBCDIC"
	@$(RDRPREP) install.jcl
	@echo "# Submiting install job to reader at $(TK4HOST):$(TK4PORT)"
	@$(NC) -w1 $(TK4HOST) $(TK4PORT) < reader.jcl
ifeq ($(CUSTOMCLASS), A) 
	@echo "# Sleeping for $(SLEEP) seconds before checking job results"
	@sleep $(SLEEP)
	@echo "# Checking job results"
	@./rc.sh install.jcl $(TK4PRINTER)
else
	@echo "# Job submitted, check output spool on $(TK4HOST) for results"
endif

uninstall:
	@echo "# Uninstalling Brexx/370 with USER=$(TK4USER) PASS=$(TK4PASS) MSGCLASS=$(CUSTOMCLASS)"
	@$(RM) -f *.obj brexx.objp jcc.log list.out prelink.log *.jcl
	@./clean.sh $(TK4USER) $(TK4PASS) $(CUSTOMCLASS) uninstall > clean.jcl
	@$(RDRPREP) clean.jcl
	@echo "# Submiting install job to reader at $(TK4HOST):$(TK4PORT)"
	@$(NC) -w1 $(TK4HOST) $(TK4PORT) < reader.jcl
ifeq ($(CUSTOMCLASS), A) 
	@echo "# Sleeping for $(SLEEP) seconds before checking job results"
	@sleep $(SLEEP)
	@echo "# Checking job results"
	./rc.sh clean.jcl $(TK4PRINTER)
endif
	@$(RM) -f *.jcl

test: 
	@echo "# Testing Brexx/370 install using ./test.sh USER=$(TK4USER) PASS=$(TK4PASS) MSGCLASS=$(CUSTOMCLASS)"
	@./test.sh $(TK4USER) $(TK4PASS) $(CUSTOMCLASS) > test.jcl
	@echo "# Converting to EBCDIC"
	@$(RDRPREP) test.jcl
	@echo "# Submiting  link job to reader at $(TK4HOST):$(TK4PORT)"
	@$(NC) -w1 $(TK4HOST) $(TK4PORT) < reader.jcl
ifeq ($(CUSTOMCLASS), A) 
	@echo "# Sleeping for $(SLEEP) seconds before checking job results" 
	@sleep $(SLEEP)
	@./rc.sh test.jcl $(TK4PRINTER)
else
	@echo "# Job submitted, check output spool on $(TK4HOST) for results"
endif

release: link
	@echo "# Creating Brexx/370 release with USER=$(TK4USER) PASS=$(TK4PASS) MSGCLASS=$(CUSTOMCLASS)"
	@./release.sh $(TK4USER) $(TK4PASS) $(CUSTOMCLASS) > release.jcl
	@echo "# Converting to EBCDIC"
	@$(RDRPREP) release.jcl
	@echo "# Submiting release job to reader at $(TK4HOST):$(TK4PORT)"
	@$(NC) -w1 $(TK4HOST) $(TK4PORT) < reader.jcl
ifeq ($(CUSTOMCLASS), A) 
	@echo "# Sleeping for $(SLEEP) seconds before checking job results"
	@sleep $(SLEEP)
	@echo "# Checking job results"
	@./rc.sh release.jcl $(TK4PRINTER)
	@echo "# Enabling TK4- FTP server"
	@curl -s -o /dev/null -d "command=/s+ftpd,srvport=$(FTP_PORT)" -X POST http://localhost:8038/cgi-bin/tasks/syslog
	@sleep $(SLEEP)
	@echo "# Downloading release XMIT: BREXX.$(VERSION).XMIT"
	@wget --quiet "ftp://$(TK4USER):$(TK4PASS)@localhost:$(FTP_PORT)/BREXX.$(VERSION).XMIT"
	@mkdir BREXX370_$(VERSION)
	@cp BREXX.$(VERSION).XMIT BREXX370_$(VERSION)
	@cp ../mvs/install/docs/*.* BREXX370_$(VERSION)
	@echo "# Compressing files"
	@zip -r BREXX370.$(VERSION).zip BREXX370_$(VERSION)/* >> zip.log
	@echo "# File BREXX370.$(VERSION).zip ready for upload"
else
	@echo "# Job submitted, check output spool on $(TK4HOST) for results"
endif

unrelease:
	@echo "# Unreleasing Brexx/370 with USER=$(TK4USER) PASS=$(TK4PASS) MSGCLASS=$(CUSTOMCLASS)"
	@$(RM) -f *.obj brexx.objp jcc.log list.out *.log *.jcl *.txt *.rexx *.zip *.clist
	@$(RM) -rf BREXX.$(VERSION).XMIT* BREXX370_$(VERSION)
	@./clean.sh $(TK4USER) $(TK4PASS) $(CUSTOMCLASS) unrelease > clean.jcl
	@$(RDRPREP) clean.jcl
	@echo "# Submiting install job to reader at $(TK4HOST):$(TK4PORT)"
	@$(NC) -w1 $(TK4HOST) $(TK4PORT) < reader.jcl
ifeq ($(CUSTOMCLASS), A) 
	@echo "# Sleeping for $(SLEEP) seconds before checking job results"
	@sleep $(SLEEP)
	@echo "# Checking job results"
	./rc.sh clean.jcl $(TK4PRINTER)
endif
	@$(RM) -f *.jcl
