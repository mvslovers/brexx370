BREXX/370 Build Engine
======================

This folder contains the script, jcl, templates and Makefile needed to build
BREXX/370 on MVS/CE, TK4- and TK5. 

## Requirements

Before using this build engine you must have one of the following depending
on which version of MVS3.8j you have. 

### TK5

To use TK5 to build BREXX/370 you need to:

1. download the current version of TK5 and decompress
2. Run TK5 with `./mvs` in the TK5 folder and wait for it to boot
3. Either edit the `Makefile` and change the various TK5 settingS 
   to match your setup, or change them at runtime. e.g. 
   `make TK5FOLDER=/home/test/MVSCE` (this applies to all make steps)

### MVS/CE

To use MVS/CE to build BREXX/370 you need to:

1. download the current version of MVS/CE and decompress
2. Install hercules and make sure it is in your `$PATH`
3. Either edit the `Makefile` and change the various MVS/CE setting like 
   `MVSCEFOLDER` to match your setup, or change them at runtime:
   `make MVSCEFOLDER=/home/test/MVSCE` (this applies to all make steps)
4. Either edit the `Makefile`, comment out `SYSTEM=TK5` and uncomment
   `SYSTEM=MVSCE` or run make with `make SYSTEM=MVSCE` (this applies to all make steps)

### TK4-

To use TK4- to build BREXX/370 you need to:

1. download the current version of TK4- and decompress
2. Run TK4 with `./mvs` in the TK5 folder and wait for it to boot
3. Either edit the `Makefile` and change the various TK5 setting like 
   to match your setup, or change them at runtime. e.g. 
   `make TK4FOLDER=/home/test/MVSCE` (this applies to all make steps)
4. Either edit the `Makefile`, comment out `SYSTEM=TK5` and uncomment
   `SYSTEM=TK4-` or run make with `make SYSTEM=TK4-` (this applies to all make steps)

### JCC

JCC must be installed, it is the compiler used to build BREXX/370. It is 
available online at https://github.com/mvslovers/jcc. 

Wherever you install it make sure you either edit the `Makefile` and change the
`JCCFOLDER` variable to point at the appropriate location. 

### rdrprep

rdrprep also must be installed. You can download and install from github at
https://github.com/mvslovers/rdrprep.

### automvs

The `builder.py` script makes heavy use of the automvs pypi library. Install it
with `pip install automvs`. 

### Documentation

If you're building a release version (or when you run `make clean`) you 
need to also install the required libraries for sphinx:


```
pip install sphinx
pip install sphinx_rtd_theme
pip install rst2pdf
pip install sphinx_markdown_builder
```

## Remote

This build engine supports remote building of BREXX using the AUTOMVS rexx script.
You can obtain that script and instructions on how to install from here:

https://github.com/MVS-sysgen/automvs/tree/main/REXX

After install you can run it from hercules with `/s automvs` which will run
on the default port 9856. You can then enable remote building by uncommenting 
the `REMOTEPORT` line in the Makefile in the **Remote System** section and making sure the 
`TK5HOST` or `TK4HOST` ip address is set correctly.

You can also make remote builds, without editing the Makefile, from the 
command line after you've started AUTOMVS by passing the `REMOTEPORT` and 
`<system>HOST` arguments:

```
$ cd project/build
$ make SYSTEM=TK4 REMOTEPORT=9856 TK4HOST=testing.mainframe.tk5
$ make SYSTEM=TK4 REMOTEPORT=9856 TK4HOST=testing.mainframe.tk5 test
$ make SYSTEM=TK4 REMOTEPORT=9856 TK4HOST=testing.mainframe.tk5 release
```

:warning: Unlike the local builds, remote builds will not produce a final
ZIP file releases. This is due to the XMIT file being too large for the 
file read function and BREXX running out of memory.


## Makefile

The makefile contains multiple targets to build specific components. You can
run these make commands from the brexx370 root folder or from this build
folder.

Make options:

- `make` - Builds all components from source. Places assembled/linked items
  in `BREXX.BUILD.LOADLIB`.
- `make install` - Fully installs BREXX as well as uploading the supporting
  datasets BREXX.version.RXLIB, SAMPLES, RXLIB, PROCLIBs, etc.
- `make test` - Runs over 125 REXX tests against the newly built BREXX
- `make release` - This will generate the release XMI file and all 
  documentation, compressing them to BREXX.version.ZIP
- `make clean` - Will delete all obj, logs, jcl, objp, documentation, pdfs
  as well as all PDSs created as part of the build process. 
- `make documentation` - Will generate all the documation to `docs/build`. This
  step is included in the release step. 
- `make jcl` - Instead of building BREXX this recipe generates all the JCL 
  files that are typically generated by `builder.py` and places them in this
  folder. Each file is named after the step. This is typically used for 
  educational purposes.
- `make check` - Due to the way files are uploaded to the system, files that
  have lines that are longer than 80 columns wide will be truncated. To prevent
  this from happening accidentally this step checks all the files in `rxlib`, 
  `jcl`, `proclib`, `cmdlib`, and `samples` and fails if it identifies any lines
  longer than 80 characters. This step is included when running `make release`.

### Make arguments:

#### DEBUG

The build engine uses a python script. To turn on (very) verbose loging you can
pass make the argument `DEBUG=-d` to get verbose logging. This is very handy if
you're editing any of the JCL in the `templates/` folder

#### SYSTEM

Instead of editing the make file you can call make with `SYSTEM=<system>` to
build for a particular MVS3.8j.

## Folder Contents

- `Makefile`  - The make file used to build BREXX/370 components.
- `builder.py` - A python script that automates submitting JCL, changing 
  punchcard location, monitoring job step return codes, etc. It supports
  TK4-, TK5 and MVSCE.
- `rxmvsext.nam` - This file is used by JCC OBJSCAN to replace the short ESD
  names in GOFF files with longer names for use in C functions. Specifically
  this file is used by the `make rxmvsext.obj` step.
- `templates/` - This folder contains various JCL stubs with python format
  strings like `{version}`. Each file is read by `builder.py` when appropriate
  to make the JCL used to build various components.
- `old` - The old make file and shell scripts exist here for posterity. 
  
## Example Output

Here's some example output:

```
$ make rxmvsext.obj
# Assembling RXMVSEXT in to BREXX.BUILD.LOADLIB
python3 builder.py  -s MVSCE -f /MVSCE -u IBMUSER -p SYS1 --RXMVSEXT
 # Creating rxmvsext.punch
 # Submitting RXMVSEXT JCL
 # Waiting for RXMVSEXT to finish
 # RXMVSEXT finished
 # Completed!
 # Results:
 #
 # jobname  | procname | stepname | exitcode
 # -----------------------------------------
 # RXMVSEXT |          | MACLIB   | 0000
 # RXMVSEXT | ASM      | RXSVC    | 0000
 # RXMVSEXT | ASM      | RXABEND  | 0000
 # RXMVSEXT | ASM      | RXIKJ441 | 0000
 # RXMVSEXT | ASM      | RXINIT   | 0000
 # RXMVSEXT | ASM      | RXTERM   | 0000
 # RXMVSEXT | ASM      | RXTSO    | 0000
 # RXMVSEXT | ASM      | RXVSAM   | 0000
 # RXMVSEXT | ASM      | RXCPUTIM | 0000
 # RXMVSEXT | ASM      | RXCPCMD  | 0000
 # RXMVSEXT | ASM      | RXESTAE  | 0000
 # RXMVSEXT |          | PUNCHOUT | 0000
 # -----------------------------------------
 #
 # /project/build/rxmvsext.punch created
# creating rxmvsext.obj
```

## Container

To make building easier a docker container with all three MVS3.8j versions
mentioned above has been created. To use the docker container you can run one of the
following (make sure you're in the root of this repository):

**MVS/CE Build**

```
$ docker run -it --entrypoint /bin/bash -v $(pwd):/project mainframed767/brexx:latest
# cd project/build
# make SYSTEM=MVSCE
# make test SYSTEM=MVSCE
# make release SYSTEM=MVSCE
```

**TK5 Build**

Note: `/run.sh` starts TK5 silently. `/home/hercules/loaded.sh` will print a `.`
once a second and returns when TK5 is fully IPL'd.

```
$ docker run -it --entrypoint /bin/bash -v $(pwd):/project mainframed767/brexx:latest
# /run.sh /mvs-tk5/
# /home/hercules/loaded.sh
# cd project/build
# make
# make test
# make release
```

**TK4- Build**

Note: `/run.sh` starts TK4- silently. `/home/hercules/loaded.sh` will print a `.`
once a second and returns when TK5 is fully IPL'd.

```
$ docker run -it --entrypoint /bin/bash -v $(pwd):/project mainframed767/brexx:latest
# /run.sh /tk4-/
# /home/hercules/loaded.sh
# cd project/build
# make SYSTEM=TK4
# make SYSTEM=TK4 test
# make SYSTEM=TK4 release
```

## Build Failures

Occasionally the hercules emulator or the jcc compiler will crash which will cause
make to fail. Typically restarting tk4-/tk5 will fix the issue. 
