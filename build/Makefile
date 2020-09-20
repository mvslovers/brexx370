#
# change the following variables to fit your needs
#

JCCFOLDER   := ../../jcc
RDRPREP     := rdrprep
TK4HOST     := localhost
TK4PORT     := 3505
TK4USER     := HERC01
TK4PASS     := CUL8TR
TK4PRINTER  := ../../tk4-test/prt/prt00e.txt
# by default it will send to MSGCLASS A or H, set
# CUSTOMCLASS below if you want to use a different class
CUSTOMCLASS := 

#
#
#

TARGET      := brexx.objp

OBJSCAN     := $(JCCFOLDER)/objscan
PRELINK     := wine $(JCCFOLDER)/prelink.exe
#PRELINK     := $(JCCFOLDER)/prelink
#CC          := $(JCCFOLDER)/jcc
CC          := wine $(JCCFOLDER)/jcc.exe
JCCINCS     := $(JCCFOLDER)/include
JCCOBJS     := $(JCCFOLDER)/objs
JCCLIBLIST  := $(JCCOBJS)/liblst.txt
NC          := nc
SLEEP       := 25

########################################

SRC_DIRS := ../src ../lstring ../rac ../dynit ../fss
INC_DIRS := $(JCCINCS) ../inc ../rac ../dynit ../fss ../cross
ASM_DIRS := ../mvs/asm
MAC_DIRS := ../mvs/maclib
VPATH = $(SRC_DIRS)

SRCS := $(shell find $(SRC_DIRS) -name *.c )
INCS := $(shell find $(INC_DIRS) -type d)
OBJS := $(addsuffix .obj, $(notdir $(basename $(SRCS))))

INC_FLAGS := $(addprefix -I,$(INC_DIRS))
D_FLAGS   := -D__MVS__
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

.PHONY: clean all install uninstall

all: $(TARGET)

$(TARGET): link

link: prelink
	@echo "# Generating link job using  USER=$(TK4USER) PASS=$(TK4PASS) MSGCLASS=$(CUSTOMCLASS)"
	@./link.sh brexx.objp $(TK4USER) $(TK4PASS) $(CUSTOMCLASS) > link.jcl
	@echo "# Converting to EBCDIC"
	@$(RDRPREP) link.jcl
	@echo "# Submiting  link job to reader at $(TK4HOST):$(TK4PORT)"
	@$(NC) -w1 $(TK4HOST) $(TK4PORT) < reader.jcl
ifeq ($(CUSTOMCLASS), A) 
	@echo "# Sleeping for $(SLEEP) seconds before checking job results" 
	@sleep $(SLEEP)
	@./rc.sh link.jcl $(TK4PRINTER)
else
	@echo "# Job submitted, check output spool on $(TK4HOST) for results"
endif
# tbd : all these grep stuff
	
assemble: prelink
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

prelink: $(OBJS)
	@echo "# prelinking JCC objects into brexx.objp"
	@$(PRELINK) -s $(JCCOBJS) brexx.objp $(OBJS) obj/rxmvsext.obj >> prelink.log 2>&1
	
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
	@sleep $(SLEEP)
	@echo "# Checking job results"
	./rc.sh clean.jcl $(TK4PRINTER)
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


