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

Required options
++++++++++++++++

Set the task to analyze in the BIDS data set ``opt.taskName = 'auditory'``

Selecting groups and subjects
+++++++++++++++++++++++++++++

Set the group of subjects to analyze::  

    opt.groups = {'control', 'blind'};

If there are no groups (i.e subjects names are of the form ``sub-01`` for example)
or if you want to run all subjects of all groups then use::

    opt.groups = {''};
    opt.subjects = {[]};

If you have 2 groups (``cont`` and ``cat`` for example) the following will run
cont01, cont02, cat03, cat04::

    opt.groups = {'cont', 'cat'};
    opt.subjects = {[1 2], [3 4]};

If you have more than 2 groups but want to only run the subjects of 2 groups
then you can use::

    opt.groups = {'cont', 'cat'};
    opt.subjects = {[], []};

You can also directly specify the subject label for the participants you want to
run::

    opt.groups = {''};
    opt.subjects = {'01', 'cont01', 'cat02', 'ctrl02', 'blind01'};




BIDS model JSON files
---------------------

This files allow you to specify the GLM to run and which contrasts to run.
It follows the BIDS statistical model extension and as implemented by
`fitlins <https://fitlins.readthedocs.io/en/latest/model.html>`_

The model json file that describes:

-   out to prepare the regressors for the GLM: `Transformation`
-   the design matrix: `X`
-   the contrasts to compute: `contrasts`

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
        "Steps": [
            {
                "Level": "subject",
                "AutoContrasts": ["stim_type.motion", "stim_type.static"],
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
                "Level": "dataset",
                "AutoContrasts": [
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
image that averages the beta image of all the runs where as in the latter case
we get one con image for each run.