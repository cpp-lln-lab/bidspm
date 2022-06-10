.. _defaults:

Pipeline defaults
*****************

Defaults of the pipeline.

.. automodule:: src.defaults

checkOptions
============

.. autofunction:: checkOptions
.. autofunction:: setDirectories


.. autofunction:: defaultResultsStructure
.. autofunction:: defaultContrastsStructure

spm_my_defaults
===============

Some more SPM options can be set in the :func:`src.defaults.spm_my_defaults.m`.

.. autofunction:: spm_my_defaults


statistics defaults
===================

Note that some of the defaults value may be over-ridden by the content of the ``opt``
structure but also by the content of your BIDS stats model.

.. _auto_correlation_model:
auto-correlation modelisation
-----------------------------

Use of FAST :cite:p:`Olszowy2019` and not AR1 for auto-correlation modelisation.

Using FAST does not seem to affect results on time series with "normal" TRs but
improves results when using sequences: it is therefore used by default in this
pipeline.

Check the :ref:`the relevant section of the BIDS stats model <bids_stats_model_sofware>`
to know how to change this value.


SPM to BIDS filename conversion
===============================

.. autofunction:: set_spm_2_bids_defaults


list of defaults
================

.. only:: html

    .. literalinclude:: default_options.m
        :language: matlab
