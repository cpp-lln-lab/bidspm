Pipeline defaults
*****************

Defaults of the pipeline.

----

.. automodule:: src.defaults

checkOptions
============

.. autofunction:: checkOptions

spm_my_defaults
===============

Some more SPM options can be set in the ``spm_my_defaults.m``.

auto-correlation modelisation
-----------------------------

Use of FAST and not AR1 for auto-correlation modelisation.

Using FAST does not seem to affect results on time series with "normal" TRs but
improves results when using sequences: it is therefore used by default in this
pipeline.

> Olszowy, W., Aston, J., Rua, C. et al. Accurate autocorrelation modeling
> substantially improves fMRI reliability. Nat Commun 10, 1220 (2019).
> https://doi.org/10.1038/s41467-019-09230-w

.. autofunction:: spm_my_defaults
