(bids_stats_model)=

# BIDS stats model JSON file

This file allows you to specify the GLM to run and which contrasts to compute.

It follows
[BIDS statistical model](https://bids-standard.github.io/stats-models/index.html).

This type of JSON file is a bit more complicated than the usual JSON files, you
might be acquainted with in BIDS. So make sure you have a read through the
[JSON 101](https://bids-standard.github.io/stats-models/json_101.html) page.

Then have a look at the
[walkthrough](https://bids-standard.github.io/stats-models/walkthrough-1.html)
that explains how to build a simple model.

## Create a default BIDS model for a dataset

```{eval-rst}
.. autofunction:: src.bids_model.createDefaultStatsModel
```

## Validate your model

### In Visual Studio Code

You can add those lines to the `.vscode/settings.json` of your project to help
you validate BIDS stats models as you write them.

```{literalinclude} ../../.vscode/settings.json
   :language: json
   :emphasize-lines: 2,3,4,5,6,7
```

### In the browser

Otherwise you can use
[the online validator](https://bids-standard.github.io/stats-models/validator.html)
and copy paste your model in it.

### Using the BIDS stats model python package

```bash
pip install bsmschema
```

```python
from bsmschema.models import BIDSStatsModel

BIDSStatsModel.parse_file('model-example_smdl.json')
```

## Loading and interacting with a BIDS stats model

You can use the `BidsModel` class to create a bids model instance and interact
with. This class inherits from bids-matlab {mat:class}`+bids.Model` class.

```{eval-rst}
.. autoclass:: src.bids_model.BidsModel
   :members:
```

There are also extra functions to interact with those models.

```{eval-rst}
.. autofunction:: src.bids_model.getContrastsList
.. autofunction:: src.bids_model.getDummyContrastsList
```

## CPP SPM implementation of the BIDS stats model

The model JSON file that describes:

-   out to prepare the regressors for the GLM: `Transformation`

Here are what the different section mean:

```json
"Input": {
    "space": "IXI549Space",
    "task": "motionloc"
}
```

This allows you to specify input images you want to include based on the BIDS
entities in their name, like the task (can be more than one) or the MNI space
your images are in (here `IXI549Space` is for SPM 12 typical MNI space.

The `Transformations` object allows you to define what you want to do to some
variables, before you put them in the design matrix. Here this shows how to
subtract 3 seconds from the event onsets of the conditions listed in the
`trial_type` columns of the `events.tsv` file, and put the output in a variable
called `motion` and `static`.

```json
"Transformations": {
    "Transformer": "cpp_spm",
    "Instructions": [
        {
            "Name": "Subtract",
            "Input": [
                "onset"
            ],
            "Value": 3,
            "Output": [
                "motion",
                "static"
            ]
        }
    ]
}
```

Then comes the model object,

`X` defines the variables that have to be put in the design matrix. Here
`trans_?` means any of the translation parameters (in this case `trans_x`,
`trans_y`, `trans_z`) from the realignment that are stored in `_confounds.tsv`
files. Similarly `*outlier*` means that any "scrubbing" regressors created by
fMRIprep or CPP SPM to detect motion outlier or potential dummy scans will be
included (those regressors are also in the `_confounds.tsv` files).

```{note}
Following standard Unix-style glob rules,
`*` is interpreted to match 0 or more alphanumeric characters,
and `?` is interpreted to match exactly one alphanumeric character.
```

`HRF` specifies which variables of X have to be convolved and what HRF model to
use to do so.

You can choose from:

-   `"spm"`
-   `"spm + derivative"`
-   `"spm + derivative + dispersion"`
-   `"fir"`

```json
"Model": {
    "Type": "glm",
    "X": [
        "motion",
        "static",
        "trans_?",
        "rot_?",
        "*outlier*"
    ],
    "HRF": {
        "Variables": [
            "motion",
            "static"
        ],
        "Model": "spm"
    }
```

## Examples

There are several examples of models in the
[model zoo](https://github.com/bids-standard/model-zoo) along with links to
their datasets.

Several of the :ref:`demos` have their own model and you can find several
"dummy" models (without corresponding data) used for testing
[in this folder](https://github.com/cpp-lln-lab/CPP_SPM/tree/dev/tests/dummyData/models).

An example of JSON file could look something like that:

```{literalinclude} ../../tests/dummyData/models/model-vislocalizer_smdl.json
   :language: json
```
