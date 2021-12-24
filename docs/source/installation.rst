Installation
************

Dependencies
============

This SPM toolbox runs with Matlab and Octave.

============  ================   ======================
Dependencies  Minimum required   Used for testing in CI
============  ================   ======================
MATLAB        2014               2020  on Ubuntu 20.04
Octave        4.2.2              4.2.2 on Ubuntu 20.04
SPM12         7219               7771
============  ================   ======================

Some functionalities require some extra SPM toolbox to work: 
for example the ALI toolbox for brain lesion segmentation.

Octave compatibility
--------------------

The following features do not yet work with Octave:

-   anatomicalQA
-   functionalQA
-   slice_display toolbox

Installation
============

If you are only going to use this toolbox for a new analysis 
and you are not planning to edit the code base of CPP_SPM itself, we STRONGLY
suggest you use this `template repository <https://github.com/cpp-lln-lab/template_datalad_fMRI>`_ 
to create a new project with a basic structure of folders and with the CPP_SPM code already set up.

Otherwise you can clone the repo with all its dependencies 
with the following git command::

  git clone \
      --recurse-submodules \
      https://github.com/cpp-lln-lab/CPP_SPM.git

If you just need the code without the commit history download and unzip, 
you can fin the latest version from `HERE <https://github.com/cpp-lln-lab/CPP_SPM/releases>`_.

Initialization
==============

In general DO NOT ADD CPP SPM PERMANENTLY to your MATLAB / Octave path.

You just need to initialize for a given session with::

  initCppSpm()

This will add all the required folders to the path.

You can also remove CPP_SPM from the path with::

  uninitCppSpm()



