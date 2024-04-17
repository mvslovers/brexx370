# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
#import os
#import sys
#sys.path.insert(0, os.path.abspath('.'))




# -- Project information -----------------------------------------------------

project = 'BREXX/370'
copyright = '2023, Peter Jacob (pej), Mike Großmann (mig)'
author = 'Peter Jacob (pej), Mike Großmann (mig)'

# The full version, including alpha/beta/rc tags
with open("../../inc/rexx.h", 'r') as rexx_header:
    for l in rexx_header.readlines():
        if "#define VERSION" in l:
            #define VERSION         "V2R5M1"
            release = l.split()[2].strip('"')
            break


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
# extensions = [ 
#     'sphinx_rtd_theme',
#     'rinoh.frontend.sphinx',
# ]
extensions = [ 
    'sphinx_rtd_theme',
    'rst2pdf.pdfbuilder',
]

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'sphinx_rtd_theme'

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']

# For PDF document formatting
version = release
pdf_documents = [('index', # master document
                    u'BREXX370_Users_Guide', # name of the generated pdf
                    u'BREXX/370 User\'s Guide', # title of the pdf
                    u'BREXX Team'),] # authors
pdf_stylesheets = ['xcode','kerning','cover.yaml','style.yaml']
pdf_use_coverpage = True
pdf_cover_template = 'cover.tmpl'
# rinoh_documents = [dict(
#                         doc='index',                   # top-level file (index.rst)
#                         target='BREXX370_Users_Guide', # output file (BREXX370_Users_Guide.pdf)
#                         logo='_static/brexx370.png',   
#                         template='brexx.rtt',
#                         title='BREXX/370 User\'s Guide',
#                         subtitle='Release: {version}'.format(version=release),
#                        )
#                   ]   
