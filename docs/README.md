# BREXX/370 Documentation

This folder contains the BREXX/370 documentation. the `source/` folder
contains all documentation for BREXX/370.

## Requirements

To build the documentation you need the make command, python 3, Sphinx, 
the Sphinx Read the Docs theme, pip, and rst2pdf. Once make and 
python 3 and pip are installed you can install the remaining 
requirements with:

```
pip install sphinx
pip install sphinx_rtd_theme
pip install rst2pdf
pip install sphinx_markdown_builder
```

## Generate HTML documentation

To generate the HTML documentation use the command `make html` in this
folder. This will generate html based documentation in 
`buid/html/`. Opening `index.html` in that folder will open the 
documentation. This has already been done and the newly generated
documentation placed in `doc/`.

## Generate PDF documentation

To generate the PDF documentation use the command `make pdf`. This uses
rst2pdf and the styles/templates `cover.tmpl`, `cover.yaml` and `style.yaml` to generate
the PDF file. The generated PDF file will be located in 
`build/pdf/BREXX370_Users_Guide.pdf`

### Sphinx Warnings

Sphinx warns about duplicate entries. These can safely be ignored.

### rst2pdf Warnings

rst2pdf warns about duplicate entries and text beeing too wide. These can safely be ignored.