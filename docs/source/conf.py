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
    "sphinx_togglebutton",
    "myst_parser",
    "sphinxarg.ext",
]
matlab_src_dir = os.path.dirname(os.path.abspath("../../src"))
matlab_short_links = True
matlab_auto_link = "basic"
primary_domain = "mat"
autosummary_generate = True

# Add any paths that contain templates here, relative to this directory.
templates_path = ["_templates"]

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = [
    "**/examples/*",
    "**/images/*",
    "demo",
    "defaults",
    "examples",
    "images",
    "../lib/**/*.m",
    "tests/**/*.m",
]

suppress_warnings = ["myst.header", "myst.xref_missing"]

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = "sphinx"

# The master toctree document.
master_doc = "index"

bibtex_bibfiles = ["references.bib"]

source_suffix = [".rst", ".md"]

intersphinx_mapping = {
    "bids-matlab": ("https://bids-matlab.readthedocs.io/en/main", None),
    "nilearn": ("https://nilearn.github.io/stable", None),
}

# We recommend adding the following config value.
# Sphinx defaults to automatically resolve *unresolved* labels
# using all your Intersphinx mappings.
# This behavior has unintended side-effects,
# namely that documentations local references can
# suddenly resolve to an external location.
# See also:
# https://www.sphinx-doc.org/en/master/usage/extensions/intersphinx.html#confval-intersphinx_disabled_reftypes # noqa
# intersphinx_disabled_reftypes = ["*"]

coverage_show_missing_items = True

# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = "pydata_sphinx_theme"

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
# html_static_path = ["images"]

html_logo = "images/cpp_lab_logo.png"

html_theme_options = {
    "collapse_navigation": True,
    "show_toc_level": 5,
    "show_nav_level": 5,
    "navbar_align": "left",
    "header_links_before_dropdown": 6,
    "icon_links": [
        {
            "name": "github",
            "url": "https://github.com/cpp-lln-lab/bidspm.git",
            "icon": "fa-brands fa-square-github",
            "type": "fontawesome",
        }
    ],
    "secondary_sidebar_items": {
        "**/*": ["page-toc", "edit-this-page", "sourcelink"],
        "API": ["page-toc"],
        "general_information": ["page-toc"],
        "usage_notes": ["page-toc"],
        "configuration": ["page-toc"],
        "demos": ["page-toc"],
        "FAQ": ["page-toc"],
        "links_and_references": ["page-toc"],
        "CHANGELOG": ["page-toc"],
        "CONTRIBUTING": ["page-toc"],
    },
}


html_sidebars = {
    "**": ["sidebar-nav-bs"],
    "API": [],
    "general_information": [],
    "usage_notes": [],
    "configuration": [],
    "demos": [],
    "FAQ": [],
    "QA": [],
    "links_and_references": [],
    "CHANGELOG": [],
    "CONTRIBUTING": [],
}
