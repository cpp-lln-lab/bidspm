Docker
******

Get image from docker hub
=========================

.. code-block:: bash

    docker pull cpplab/bidspm:latest


Build the docker image locally
==============================

If you want to build the docker image locally and not pull it from the docker hub:

.. code-block:: bash

    docker build . -f docker/Dockerfile -t cpplab/bidspm:latest

This will create an image with the tag name ``bidspm:latest``

Running ``make build_image`` will also build the ``stable`` version
and a version tagged image.

Run the docker image
====================

The following command would pull from our
`docker hub <https://hub.docker.com/repository/docker/cpplab/bidspm>`_
and start the docker image::

.. code-block:: bash

    docker run -it --rm cpplab/bidspm:latest

The following command would do do the same,
but it would also map 2 folders from your computer
and run preprocessing on your dataset
(assuming there is a task called ``auditory``):

.. code-block:: bash

    bids_dir=fullpath_to_bids_dataset
    output_dir=fullpath_to_your_output_folder

    docker run -it --rm \
        -v $bids_dir:/raw \
        -v $output_dir:/derivatives \
        cpplab/bidspm:latest \
            /raw \
            /derivatives \
            subject \
            --task auditory \
            --action preprocess \
            --fwhm 8

Similarly this would run the statistics provided you give a bids stats model file
and the path to the preprocessed data.

.. code-block:: bash

    bids_dir=fullpath_to_bids_dataset
    output_dir=fullpath_to_your_output_folder
    model=fullpath_to_your_bids_stats_model

    docker run -it --rm \
        -v $bids_dir:/raw \
        -v $output_dir:/derivatives \
        -v $model:/models/smdl.json \
        cpplab/bidspm:latest \
            /raw \
            /derivatives \
            subject \
            --action stats \
            --preproc_dir /derivatives/bidspm-preproc \
            --model_file /models/smdl.json \
            --fwhm 8
