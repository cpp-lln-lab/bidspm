Installation
************

Dependencies
============

This SPM toolbox runs with Matlab and Octave.

============  ================   =========================================
Dependencies  Minimum required   Used for testing in CI
============  ================   =========================================
MATLAB        2014               2022a on Ubuntu 22.04, Windowns and MacOS
Octave        6.4.0              6.4.0 on Ubuntu 22.04
SPM12         7219               7771
============  ================   =========================================

Some functionalities require some extra SPM toolbox to work:
for example the ALI toolbox for brain lesion segmentation.

Octave compatibility
--------------------

The following features do not yet work with Octave:

- :func:`anatQA`
- slice_display toolbox

Not (yet) tested with Octave:

- MACS toolbox workflow for model selection
- ALI toolbox workflow for model selection

Installation
============

If you are only going to use this toolbox for a new analysis
and you are not planning to edit the code base of bidspm itself, we STRONGLY
suggest you use this `template repository <https://github.com/cpp-lln-lab/template_datalad_fMRI>`_
to create a new project with a basic structure of folders and with the bidspm code already set up.

Otherwise you can clone the repo with all its dependencies
with the following git command:

.. code-block:: bash

  git clone --recurse-submodules https://github.com/cpp-lln-lab/bidspm.git

If you need the latest development, then you must clone from the ``dev`` branch:

Initialization
==============

.. warning::

  In general DO NOT ADD bidspm PERMANENTLY to your MATLAB / Octave path.

You just need to initialize for a given session with:

.. code-block:: matlab

  bidspm()

This will add all the required folders to the path.

You can also remove bidspm from the path with:

.. code-block:: matlab

  bidspm uninit

..  toctree::
    containers
    hpc
