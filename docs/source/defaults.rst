Pipeline defaults
*****************

Defaults of the pipeline.

checkOptions
============

The defaults are handled mostly by those functions:

- :func:`src.defaults.checkOptions`
- :func:`src.defaults.setDirectories`
- :func:`src.defaults.defaultResultsStructure`
- :func:`src.defaults.defaultContrastsStructure`

spm_my_defaults
===============

Some more SPM options can be set in the :func:`src.defaults.spm_my_defaults`.

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


SPM to BIDS filename conversion
===============================

:func:`src.defaults.set_spm_2_bids_defaults`


list of defaults
================

.. only:: html

    .. literalinclude:: default_options.m
        :language: matlab
