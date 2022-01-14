Quality control
***************

.. automodule:: src.QA

.. Note::

   The illustrations in this section mix what the files created by each workflow
   and the functions and are called by it.
   In this sense they are not pure DAGs (directed acyclic graphs) as the ``*.m`` files
   mentioned in them already exist.

.. autofunction:: anatomicalQA
.. autofunction:: functionalQA

.. _fig_spatialPrepro-reports:
.. figure::  _static/bidsSpatialPrepro/out_report.png
   :align:   center

   workflows for QA as part of the spatial preprocessing workflow

.. autofunction:: computeDesignEfficiency
.. autofunction:: plotEvents
