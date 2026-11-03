Measurement of a full N pass over the variables of an exec (MVS-1559, #602).

- `test/tstnmeas.asm` (`[test.TSTNMEAS]`): times each N call with STCK through
  the IRXEXCOM routine behind the IRXEXTE and stores the sums in exec variables.
- `template.rexx`, `gen.sh`: the execs (kind I/S/L/V, sizes, passes). They are
  generated into `test/` and are not part of the suite.
- `runall.sh ENVFILE TAG`: runs the batches with `mbt run mvstest` against the
  target named in ENVFILE (needs `mbt test --mvs` first). Spools go to
  /tmp/nm1559/. `agg.py TAG...` reads them back.
- Memory is read from the step's VIRT in the job log: `memory('N')` probes with
  failing mallocs and writes a WTO traceback for each.
