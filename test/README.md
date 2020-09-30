# Testing

In this folder is a collection of rexx script to test Brexx/370. They have been modified from https://github.com/adesutherland/CMS-370-BREXX/tree/master/tests.

## Usage

Upload a rexx script to your dataset/pds of choice then execute it with `rx [rexx script]`.

## Automation

Included in this folder is a script to automatically generate the JCL needed to test all these scripts. 

### Requirements

Before using following these steps you need to ensure you have an EBCDIC reader setup in hercules and that rdrprep is installed:

* type the following in the hercules console:
    1. `detach c`
    2. `attach c 3505 3506 sockdev ebcdic trunc eof`

**OR**

* Run the following curl commands from your linux prompt:
    1. `curl -d "command=detach+c" -X POST http://localhost:8038/cgi-bin/tasks/syslog`
    2. `curl -d "command=attach+c+3505+3506+sockdev+ebcdic+trunc+eof" -X POST http://localhost:8038/cgi-bin/tasks/syslog`

* Install `rdrprep`
    1. `git clone https://github.com/mvslovers/rdrprep.git`
    2. `cd rdrprep`
    3. `make && sudo make install`

With that done you can run automate the build.

### Automate

1. Run the script `tests.sh` and send it to a file: `./tests.sh > tests.jcl`
1. Prep the file with `rdrprep`: `rdrprep tests.jcl`
1. Submit the job to tk4-: `nc -w1 localhost 3506 < reader.jcl`

The output will be located in your tk4- printer folder: `prt/prt00e.txt` which you can open with a text editor.

To quickly verify the testing results you can use the `rc.sh` script in the `build` folder:

```
../build/rc.sh tests.jcl path/to/tk4-/prt/prt00e.txt
```


To view the output in tk4- queue you can pass arguments to the script:

```
./tests.sh HERC01 CUL8TR H > tests.jcl
```

### Test One

Instead of testing all scripts, you may test one rexx script with `test_one.sh`. It takes the name of a rexx script and uploads/executes it to tk4-. The script acts the same as the automation one. 

```bash
./test_one.sh copies.rexx > tests.jcl
rdrprep tests.jcl
nc -w1 localhost 3505 < reader.jcl
```

To view the output from the script in the queue you can pass it the following argumen:

```
./test_one.sh copies.rexx HERC01 CUL8TR H > tests.jcl
```
