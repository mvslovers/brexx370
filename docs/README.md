# BREXX/370 Documentation

The manuals of BREXX/370 are in `books/`, set in Typst with the
[bookmaster](https://github.com/mvslovers/bookmaster) template (the
submodule `books/bookmaster`):

| Number | Title | Source |
|---|---|---|
| ML03-0001 | BREXX/370 User's Guide | `books/ml03-0001.typ`, `books/guide/` |
| ML03-0002 | BREXX/370 Reference | `books/ml03-0002.typ`, `books/ref/` |
| ML03-0003 | BREXX/370 Library and Samples | `books/ml03-0003.typ`, `books/lib/` |

Read the Docs builds them as a site:
https://mvslovers.readthedocs.io/projects/brexx370/

## Building

You need [typst](https://github.com/typst/typst) 0.15.1 (the version CI
and Read the Docs pin) and the submodule:

```
git submodule update --init docs/books/bookmaster
make -C docs/books          # the three PDFs, ml03-000n-0.pdf
make -C docs/books site     # the web form, as Read the Docs builds it
```

The old Sphinx manual (`docs/source`, `docs/markdown`) was replaced by the
books; its last state is in the history.
