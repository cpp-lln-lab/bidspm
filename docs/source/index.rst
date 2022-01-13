.. cpp_bids_spm documentation master file, created by
   sphinx-quickstart on Tue Oct 13 11:38:30 2020.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to CPP SPM documentation!
*********************************

.. toctree::
   :maxdepth: 1
   :caption: Content

   installation
   set_up
   defaults
   demos
   architecture
   preprocessing
   fieldmaps
   statistics
   QA
   method_section_boilerplate
   mancoreg
   docker
   links_and_references


This is a Matlab / Octave toolbox to perform MRI data analysis on a
`BIDS data set <https://bids.neuroimaging.io>`_ using SPM12.

Features
========

Preprocessing
-------------

If your data is fairly "typical" (for example whole brain coverage functonal
data with one associated anatomical scan for each subject), you might be better
off running `fmriprep <https://fmriprep.org/en/stable>`_ on your data.

If you have more exotic data that can't be handled well by fmriprep then CPP_SPM
has some automated workflows to perform amongst other things:

-   slice timing correction

-   fieldmaps processing and voxel displacement map creation (work in progress)

-   spatial preprocessing:

    -   realignment OR realignm and unwarp
    -   coregistration `func` to `anat`,
    -   `anat` segmentation and skull stripping
    -   (optional) normalization to SPM's MNI space

-   smoothing

All preprocessed outputs are saved as BIDS derivatives with BIDS compliant
filenames.

Statistics
----------

The model specification are done via the
`BIDS stats model <https://docs.google.com/document/d/1bq5eNDHTb6Nkx3WUiOBgKvLNnaa5OMcGtD0AZ9yms2M/edit?usp=sharing)>`_
and can be used to perform:

-   whole GLM at the subject level
-   whole brain GLM at the group level à la SPM (meaning using a summary
    statistics approach).
-   ROI based GLM (using marsbar)
-   model selection (with the MACS toolbox)

Quality control
---------------

-   anatomical data
-   functional data (work in progress)
-   GLM auto-correlation check

It can also prepare the data to run an MVPA analysis by running a GLM for each
subject on non-normalized images and get one beta image for each condition to be
used in the MVPA.


Assumptions
===========

At the moment this pipeline makes some assumptions:

-   it assumes that the dummy scans have been removed from the BIDS data set and
    it can jump straight into pre-processing,

Citation
========

.. code-block:: bibtex

    @software{CPP_SPM,
        author = {Gau, Rémi and Barilari, Marco and Battal, Ceren and Rezk, Mohamed and Collignon, Olivier and Gurtubay, Ane and Falagiarda, Federica and MacLean, Michèle and Cerpelloni, Filippo},
        license = {GPL-3.0},
        title = {{CPP SPM}},
        url = {https://github.com/cpp-lln-lab/CPP_SPM},
        version = {1.1.3dev}
    }

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
