Methods section
***************

.. automodule:: src.reports

Dataset description
===================

Use the ``reportBIDS`` function to description of your dataset 
that can be used for your methods section

.. autofunction:: reportBIDS

Preprocessing & GLM
===================

This can be generated with the ``boilerplate`` function.

.. autofunction:: boilerplate

Output example - Preprocessing
------------------------------

.. literalinclude:: examples/preprocess.md
   :language: text

Output example - GLM subject level
----------------------------------

WIP

.. code-block:: text

    At the subject level, we performed a mass univariate analysis with a linear
    regression at each voxel of the brain, using generalized least squares with a
    global FAST model to account for temporal auto-correlation (Corbin et al, 2018)
    and a drift fit with discrete cosine transform basis (128 seconds cut-off).
    Image intensity scaling was done run-wide before statistical modeling such that
    the mean image will have mean intracerebral intensity of 100.

    We modeled the fMRI experiment in an event related design with regressors
    entered into the run-specific design matrix after convolving the onsets of each
    event with a canonical hemodynamic response function (HRF).

    Nuisance covariates included the 6 realignment parameters to account for
    residual motion artefacts.

    Contrast images were computed for the following condition and spatially smoothed
    using a 3D gaussian kernel (FWHM = {XX} mm).

.. todo:
    Table of conditions with duration of each event

.. todo:
    Table of constrast with weight

Output example - GLM Group level
--------------------------------

WIP

References
==========

.. literalinclude:: references.bib
   :language: bibtex
