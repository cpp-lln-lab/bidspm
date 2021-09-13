.. cpp_bids_spm documentation master file, created by
   sphinx-quickstart on Tue Oct 13 11:38:30 2020.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to CPP SPM BIDS pipeline documentation!
***********************************************

.. toctree::
   :maxdepth: 2
   :caption: Content

   set_up
   defaults
   demos
   workflows
   batches
   QA
   fieldmaps
   function_description
   method_section_boilerplate
   mancoreg
   docker
   contributing

This pipeline contains a set of functions to run fMRI analysis on a
`BIDS data set <https://bids.neuroimaging.io/>`_ using SPM12.

This can perform:

-   slice timing correction,
-   spatial preprocessing:

    -   realignment, coregistration `func` to `anat`, `anat` segmention,
        normalization to MNI space
    -   realignm and unwarp, coregistration `func` to `anat`, `anat` segmention

-   smoothing,
-   Quality analysis:

    -   for anatomical data
    -   for functional data
-   GLM at the subject level
-   GLM at the group level à la SPM (meaning using a summary statistics approach).

It can also prepare the data to run an MVPA analysis by running a GLM for each
subject on non-normalized images and get one beta image for each condition to be
used in the MVPA.


Assumptions
===========

At the moment this pipeline makes some assumptions:

-   it assumes that the dummy scans have been removed from the BIDS data set and
    it can jump straight into pre-processing,
-   it assumes the metadata for a given task are the same as those the first run
    of the first subject this pipeline is being run on,
-   it assumes that group are defined in the subject field (eg `sub-ctrl01`,
    `sub-blind01`, ...) and not in the `participants.tsv` file.



Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
