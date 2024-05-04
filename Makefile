# This makefile is a stub. To make changes to the build target or
# to change folders, etc edit the Makefile in ./build

# The REAMDE.md in ./build contains detailed instructions
# on how to build BREXX

# Forward targets to build/Makefile
%:
	@$(MAKE) -C build $@

# Define a default target to forward to build/Makefile
.DEFAULT_GOAL := all