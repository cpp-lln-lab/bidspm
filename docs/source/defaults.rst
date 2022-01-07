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

Some more SPM options can be set in the :func:`src.defaults.spm_my_defaults.m`.

.. autofunction:: spm_my_defaults

auto-correlation modelisation
-----------------------------

Use of FAST and not AR1 for auto-correlation modelisation.

Using FAST does not seem to affect results on time series with "normal" TRs but
improves results when using sequences: it is therefore used by default in this
pipeline.

    | Olszowy, W., Aston, J., Rua, C. et al.
    | Accurate autocorrelation modeling substantially improves fMRI reliability.
    | Nat Commun 10, 1220 (2019).
    | https://doi.org/10.1038/s41467-019-09230-w

Note that if you wanted to change this setting you could do so
via the ``Software`` object of the BIDS stats model:

.. code-block:: json

    {
    "Name": "auditory",
    "BIDSModelVersion": "1.0.0",
    "Description": "contrasts to compute for the FIL MoAE dataset",
    "Input": {
        "task": "auditory"
    },
    "Nodes": [
        {
        "Level": "Run",
        "Name": "run_level",
        "Model": {
            "X": [
            "trial_type.listening"
            ],
            "Type": "glm",
            "Software": {
                "SPM": {
                    "SerialCorrelation": "AR(1)",
                    "HRFderivatives": "none"
                }
            }
        }
        }
    ]
    }

spm to BIDS filename conversion
===============================

.. autofunction:: set_spm_2_bids_defaults
