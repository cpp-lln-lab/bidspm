Set up
******

Configuration of the pipeline
=============================

Options
-------

Most of the options you have chosen for your analysis will be set in a variable
``opt`` an Octave/Matlab structure.

The content of that structure can be defined:

- "at run" time in a script or a function (that we often label ``getOption``)
- in a separate json file that can be loaded with ``loadAndCheckOptions()``.

You can find examples of both in the ``demos`` folder. You can also find a
template function for ``getOption`` in the ``src/templates`` folder.

Set the task to analyze in the BIDS data set ``opt.taskName = 'auditory'``

Selecting groups and subjects
+++++++++++++++++++++++++++++

The way to select certain subjects is summarised in the documentation of the
``getSubjectList`` function.

.. automodule:: src.utils

.. autofunction:: getSubjectList
    :noindex:



BIDS model JSON files
---------------------

This files allow you to specify the GLM to run and which contrasts to run.
It follows `BIDS statistical model <https://docs.google.com/document/d/1bq5eNDHTb6Nkx3WUiOBgKvLNnaa5OMcGtD0AZ9yms2M/edit?usp=sharing)>`_

The model json file that describes:

-   out to prepare the regressors for the GLM: ``Transformation``
-   the design matrix: ``X``
-   the contrasts to compute: ``contrasts``

It also allows to specify those for different levels of the analysis:

-   run
-   session
-   subject
-   dataset

An example of json file could look something like that::

    {
        "Name": "Basic",
        "Description": "",
        "Input": {
            "task": "motionloc"
        },
        "Nodes": [
            {
                "Level": "Subject",
                "DummyContrasts": ["stim_type.motion", "stim_type.static"],
                "Contrasts": [
                    {
                        "Name": "motion_vs_static",
                        "ConditionList": ["stim_type.motion", "stim_type.static"],
                        "weights": [1, -1],
                        "type": "t"
                    }
                ]
            },
            {
                "Level": "Dataset",
                "DummyContrasts": [
                    "stim_type.motion",
                    "stim_type.static",
                    "motion_vs_static"
                ]
            }
        ]
    }


In brief this means:

-   at the subject level automatically compute the t contrast against baseline
    for the condition ``motion`` and ``static`` and compute the t-contrats for motion
    VS static with these given weights.
-   at the level of the data set (so RFX) do the t contrast of the ``motion``,
    ``static``, ``motion VS static``.

We are currently using this to run different subject level GLM models for our
univariate and multivariate analysis where in the first one we compute a con
image that averages the beta images of all the runs where as in the latter case
we get one con image for each run.
