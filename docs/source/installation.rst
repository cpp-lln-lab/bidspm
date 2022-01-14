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
-   rsHRF workflow

Not (yet) tested with Octave:

- MACS toolbox workflow for model selection
- ALI toolbox workflow for model selection

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

If you need the latest development, then you must clone from the ``dev`` branch::

  git clone \
      -b dev \
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

Installation on a computing cluster
===================================


.. 
  
  For stand alone download
  https://www.fil.ion.ucl.ac.uk/spm/download/restricted/utopia/

  To use SPM docker
  https://github.com/spm/spm-docker

  See FAQ:
  https://en.wikibooks.org/wiki/SPM/Standalone#Frequently_Asked_Questions

This relies on the fact that SPM and CPM SPM are Octave compatible,
so you will be able to run most of CPP SPM on a high performance cluster (HPC)
without having to worry about MATLAB licenses.

Of course this assumes that Octave is available on your HPC.

Note that it should also be possible to precompile with MATLAB
all the things you want to run, but this is not shown here.

The pre-requisite steps are described in the example below that shows
how to set up CPP SPM on one of the HPC of the université catholique de Louvain.

1. SSH into the HPC

Assumes that you have set things up properly. For the UCLouvain see the documentation
`on this website <https://support.ceci-hpc.be/doc/index.html>`_
(which has some good info about using HPC in general).

If you have everything set up it should be almost as easy as opening a terminal
and typing:

.. code-block:: bash

  ssh lemaitre3

2. Get SPM

You can simply clone the latest version of SPM from github with:

.. code-block:: bash

  git clone https://github.com/spm/spm12.git --depth 1

3. Load the Octave modules

This first step might be different on your HPC,
so you might have to figure out what the equivalent modules are called on your HPC
(in the UCLouvain case you can find the relevant module by typing ``module spider octave``)

Once you have found the modules load them:

.. code-block:: bash

  module load releases/2018b
  module load Octave/4.4.1-foss-2018b

4. Recompile SPM for Octave

You need to recompile SPM to make sure it works with Octave.
This relies on running the following Make commands:

.. code-block:: bash

  make -C spm12/src PLATFORM=octave distclean
  make -C spm12/src PLATFORM=octave
  make -C spm12/src PLATFORM=octave install

5. Add SPM to the path

In the example below ``$`` shows when you are in the bash terminal and
``octave:1>`` shows when you are in the Octave terminal.

Launch Octave:

.. code-block:: bash

  $ octave

  GNU Octave, version 4.4.1
  Copyright (C) 2018 John W. Eaton and others.
  This is free software; see the source code for copying conditions.
  There is ABSOLUTELY NO WARRANTY; not even for MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE.  For details, type 'warranty'.

  Octave was configured for "x86_64-pc-linux-gnu".

  Additional information about Octave is available at https://www.octave.org.

  Please contribute if you find this software useful.
  For more information, visit https://www.octave.org/get-involved.html

  Read https://www.octave.org/bugs.html to learn how to submit bug reports.
  For information about changes from previous versions, type 'news'.

Add the SPM12 folder to the path and save the path:

.. code-block:: matlab

  octave:1> addpath(fullfile(pwd, 'spm12'))
  octave:2> savepath
  octave:3> exit

5. Install CPP SPM

As before install and run an initialization:

.. code-block:: bash

  git clone \
    -b dev \
    --recurse-submodules \
    https://github.com/cpp-lln-lab/CPP_SPM.git

.. warning::

  There are some warnings thrown during initialization::

    octave:1> initCppSpm
    warning: addpath: /home/users/r/g/rgau/CPP_SPM/lib/spmup/utlilities/home/users/r/g/rgau/CPP_SPM/lib/spm_2_bids: No such file or directory
    warning: called from initCppSpm at line 67 column 5
    warning: function /home/users/r/g/rgau/CPP_SPM/lib/spmup/external/cubehelix.m shadows a core library function
    warning: called from initCppSpm at line 67 column 5
    warning: addpath: /home/users/r/g/rgau/CPP_SPM/src/workflows/stats/home/users/r/g/rgau/CPP_SPM/lib/spmup: No such file or directory

  As well as many warnings of the type::

    sh: makeinfo: command not found
    warning: doc_cache_create: unusable help text found in file 'analyze75info'
