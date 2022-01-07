Docker
******

Build docker image locally
==========================

If you want to build the docker image locally and not pull it from the docker hub:

.. code-block:: bash

    docker build . -f docker/Dockerfile -t cpplab/cpp_spm:stable

This will create an image with the tag name ``cpp_spm:stable``

Running ``make docker_img`` will also build the ``stable`` version
and a ``latest`` version.

Run docker image
================

The following command would pull from our
`docker hub <https://hub.docker.com/repository/docker/cpplab/cpp_spm>`_
and start the docker image::

    docker run -it --rm cpplab/cpp_spm:latest

The image is set up to start Octave in the ``/code`` folder.

The following command would do do the same,
but it would also map 2 folders from your computer
to the ``output`` and ``code`` folder inside the container image:

.. code-block:: bash

    code_folder=fullpath_to_your_code
    output_folder=fullpath_to_your_output_folder

    docker run -it --rm \
        -v $output_folder:/output \
        -v $code_folder:/code \
        cpplab/cpp_spm:latest

For example, you could run the demos by doing this:

.. code-block:: bash

    code_folder=/home/remi/github/CPP_SPM/demos/MoAE

    docker run -it --rm \
        -v $code_folder:/code \
        cpplab/cpp_spm:latest

    # once inside the docker image
    moae_01_preproc
