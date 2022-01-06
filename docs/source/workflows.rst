Workflows
*********

Workflows typical run on all the subjects specified in the ``options`` structure.

Below is a list of the different workflows of the pipeline.

All parameters should be changed in the ``options`` structure.

See the :ref:`set-up` section.

.. Note::

   The illustrations in this section mix what the files created by each workflow
   and the functions and are called by it.
   In this sense they are not pure DAGs (directed acyclic graphs) as the ``*.m`` files
   mentioned in them already exist.


Preprocessing
=============

.. automodule:: src.workflows.preproc

Slice Time Correction
---------------------

.. autofunction:: bidsSTC

More info available on this page of the
`SPM wikibook <https://en.wikibooks.org/wiki/SPM/Slice_Timing>`_.

.. _fig_stc:
.. figure::  _static/bidsSTC/out.png
   :align:   center

   Slice timing correction workflow

----

Some comments from `here <http://mindhiveit.edu/node/109>`_ on STC, when
it should be applied

*At what point in the processing stream should you use it?*

*This is the great open question about slice timing, and it's not
super-answerable. Both SPM and AFNI recommend you do it before doing
realignment/motion correction, but it's not entirely clear why. The issue is
this:*

*If you do slice timing correction before realignment, you might look down your
non-realigned time course for a given voxel on the border of gray matter and
CSF, say, and see one TR where the head moved and the voxel sampled from CSF
instead of gray. This would results in an interpolation error for that voxel, as
it would attempt to interpolate part of that big giant signal into the previous
voxel. On the other hand, if you do realignment before slice timing correction,
you might shift a voxel or a set of voxels onto a different slice, and then
you'd apply the wrong amount of slice timing correction to them when you
corrected - you'd be shifting the signal as if it had come from slice 20, say,
when it actually came from slice 19, and shouldn't be shifted as much.*

*There's no way to avoid all the error (short of doing a four-dimensional
realignment process combining spatial and temporal correction - Remi's note:
fMRIprep does it), but I believe the current thinking is that doing slice timing
first minimizes your possible error. The set of voxels subject to such an
interpolation error is small, and the interpolation into another TR will also be
small and will only affect a few TRs in the time course. By contrast, if one
realigns first, many voxels in a slice could be affected at once, and their
whole time courses will be affected. I think that's why it makes sense to do
slice timing first. That said, here's some articles from the SPM e-mail list
that comment helpfully on this subject both ways, and there are even more if you
do a search for "slice timing AND before" in the archives of the list.*

Spatial Preprocessing
---------------------

Perform spatial preprocessing by running ``bidsSpatialPrepro``

.. autofunction:: bidsSpatialPrepro

The figures below show the ``bidsSpatialPrepro`` workflow as it would run using
realign and unwarp (default) and with normalization to SPM MNI space (``IXI549Space``).

.. _fig_spatialPrepro-anat:
.. figure::  _static/bidsSpatialPrepro/out_anat.png
   :align:   center

   Anatomical component of the spatial preprocessing workflow

.. _fig_spatialPrepro-func:
.. figure::  _static/bidsSpatialPrepro/out_func.png
   :align:   center

   Functional component of the spatial preprocessing workflow

.. autofunction:: bidsRealignReslice
.. autofunction:: bidsRealignUnwarp

Smoothing
---------

Perform smoothing of the functional data by running ``bidsSmoothing``

.. autofunction:: bidsSmoothing

.. _fig_smoothing:
.. figure::  _static/bidsSmoothing/out.png
   :align:   center

   Smoothing workflow

Others
------

.. autofunction:: bidsResliceTpmToFunc
.. autofunction:: bidsSegmentSkullStrip

.. _fig_segmentSkullstrip:
.. figure::  _static/bidsSegmentSkullstrip/out.png
   :align:   center

   Segment and skullstrip workflow

.. autofunction:: bidsWholeBrainFuncMask

Statistics
==========

.. automodule:: src.workflows.stats

Subject level analysis
----------------------

.. autofunction:: bidsFFX

.. _fig_FFX-specification:
.. figure::  _static/bidsFFX/out.png
   :align:   center

   Subject level GLM specification workflow

.. autofunction:: bidsConcatBetaTmaps

Group level analysis
--------------------

.. autofunction:: bidsRFX

Compute results
---------------

.. autofunction:: bidsResults

Region of interest analysis
===========================

.. automodule:: src.workflows.roi

.. autofunction::  bidsCreateROI
.. autofunction::  bidsRoiBasedGLM


HRF estimation
==============

Relies on the resting-state HRF toolbox.

.. automodule:: src.workflows

.. autofunction:: bidsRsHrf

Other
=====

.. autofunction:: bidsCopyInputFolder
.. autofunction:: bidsRename


Helper functions
================

To be used if you want to create a new workflow.

.. autofunction:: setUpWorkflow
.. autofunction:: saveAndRunWorkflow
.. autofunction:: cleanUpWorkflow
.. autofunction:: returnDependency
