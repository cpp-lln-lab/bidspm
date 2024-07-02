Installation on a computing cluster
===================================

.. warning::

  If you are planning to use bidspm on a compute cluster,
  it may be easier to use a containerized version of it.
  The repository includes an Apptainer ``bidspm.def`` definition file
  to help.

  Please see the containers section of the documentation.

..

  For stand alone download
  https://www.fil.ion.ucl.ac.uk/spm/download/restricted/utopia/

  To use SPM docker
  https://github.com/spm/spm-docker

  See FAQ:
  https://en.wikibooks.org/wiki/SPM/Standalone#Frequently_Asked_Questions

This relies on the fact that SPM and CPM SPM are Octave compatible,
so you will be able to run most of bidspm on a high performance cluster (HPC)
without having to worry about MATLAB licenses.

Of course this assumes that Octave is available on your HPC.

Note that it should also be possible to precompile with MATLAB
all the things you want to run, but this is not shown here.

The pre-requisite steps are described in the example below that shows
how to set up bidspm on one of the HPC of the université catholique de Louvain.

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

5. Install bidspm

As before install and run an initialization:

.. code-block:: bash

  git clone \
    -b dev \
    --recurse-submodules \
    https://github.com/cpp-lln-lab/bidspm.git

.. warning::

  There are some warnings thrown during initialization::

    octave:1> initCppSpm
    warning: addpath: /home/users/r/g/rgau/bidspm/lib/spmup/utlilities/home/users/r/g/rgau/bidspm/lib/spm_2_bids: No such file or directory
    warning: called from initCppSpm at line 67 column 5
    warning: function /home/users/r/g/rgau/bidspm/lib/spmup/external/cubehelix.m shadows a core library function
    warning: called from initCppSpm at line 67 column 5
    warning: addpath: /home/users/r/g/rgau/bidspm/src/workflows/stats/home/users/r/g/rgau/bidspm/lib/spmup: No such file or directory

  As well as many warnings of the type::

    sh: makeinfo: command not found
    warning: doc_cache_create: unusable help text found in file 'analyze75info'
