Docker
******

The recipe to build the docker image is in the ``Dockerfile``

Build docker image
==================

To build the image with with octave and SPM the `Dockerfile` just type::

    docker build -t cpp_spm:0.0.1 .

This will create an image with the tag name `cpp_spm_octave:0.0.1`

Run docker image
================

The following code would start the docker image and would map 2 folders one for
``output`` and one for ``code`` you want to run::

    docker run -it --rm \
    -v [output_folder]:/output \
    -v [code_folder]:/code cpp_spm:0.0.1

To test it you can copy the ``MoAEpilot_run.m`` file in the ``demos/MoAE`` folder on
your computer and then start running the docker and type::

    # to change to the code folder inside the container 
    # running the command 'ls' should show MoAEpilot_run.m and the content of 
    # the folder
    cd demos/MoAE 

    # To run the batch_download_run script
    octave --no-gui --eval MoAEpilot_run 

