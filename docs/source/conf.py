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
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.abspath("../.."))

# The full version, including alpha/beta/rc tags
with open("../../version.txt", encoding="utf-8") as version_file:
    release = version_file.read()

# -- Project information -----------------------------------------------------

project = "bidspm"
copyright = "2020, the bidspm pipeline dev team"
author = "the bidspm pipeline dev team"


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    "sphinx.ext.intersphinx",
    "sphinx.ext.autodoc",
    "sphinx.ext.coverage",
    "sphinxcontrib.matlab",
    "sphinxcontrib.mermaid",
    "sphinxcontrib.bibtex",
    "sphinx_copybutton",
    "myst_parser",
    "sphinxarg.ext",
]
matlab_src_dir = os.path.dirname(os.path.abspath("../../src"))
primary_domain = "mat"

# Add any paths that contain templates here, relative to this directory.
templates_path = ["_templates"]

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ["examples", "defaults", "demo", "images/*.md"]

suppress_warnings = ["myst.header", "myst.xref_missing"]

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = "sphinx"

# The master toctree document.
master_doc = "index"

bibtex_bibfiles = ["references.bib"]

# source_suffix = ['.rst', '.md']
source_suffix = ".rst"

intersphinx_mapping = {
    "bids-matlab": ("https://bids-matlab.readthedocs.io/en/latest", None)
}

coverage_show_missing_items = True

# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = "sphinx_rtd_theme"

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
# html_static_path = ["images"]

html_logo = "images/cpp_lab_logo.png"

html_theme_options = {
    "collapse_navigation": False,
    "display_version": False,
    "navigation_depth": 4,
}

html_sidebars = {
    "**": [
        "about.html",
        "navigation.html",
        "relations.html",  # needs 'show_related': True theme option to display
        "searchbox.html",
        "donate.html",
    ]
}
