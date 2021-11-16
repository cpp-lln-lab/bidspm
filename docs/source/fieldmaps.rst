Fieldmaps
*********

In a nutshell, the information we need to create a VDM in SPM (see ``calculate VDM`` module in SPM batch):

    - ``blip direction``
    - ``echo time``
    - ``total EPI readout time``

Inferring ``blip direction`` and ``echo time`` from a dataset that has sufficient metadata is usually simple.

But ``total EPI readout time`` is not mentioned, so it has to be computed from the information we have,
it is not entirely clear how (see the comments with a lot of ``???`` in ``getTotalReadoutTime``).

Things that are yet unclear:
    - is it actually possible to compute total EPI readout time that SPM needs
      from the info in a typical dataset with fieldmaps like ``openneuro/ds001168``?
    - If it is not then that is an issue because it means some BIDS dataset are not usable with SPM.

Things to keep an eye on: the code from this `repo <https://github.com/nipreps/sdcflows>`_
from the fMRIprep team could have answers for us.

.. automodule:: src.workflows

.. autofunction:: bidsCreateVDM

.. automodule:: src.batches

.. autofunction:: setBatchCoregistrationFmap
.. autofunction:: setBatchCreateVDMs

.. automodule:: src.fieldmaps

.. autofunction:: getBlipDirection
.. autofunction:: getMetadataFromIntendedForFunc
.. autofunction:: getTotalReadoutTime
.. autofunction:: getVdmFile
