BREXX/270 Samples
==================

This folder contains various rexx scripts that demonstrates how to use 
BREXX/370. 

It is included in the install and is typically installed to:

`BREXX.$RELEASE.SAMPLES`

A member that is a job, not a REXX script, is a file with the extension
`.jcl` and a name of `$$` and six characters (`$$CREKEY.jcl`); the SMP
package takes the name without the extension as the member name of
`BREXX.SAMPLIB`, and `scripts/stagelibs.py` checks the convention.
