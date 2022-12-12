# Demos based on openneuro datasets

-   ds000001: one task, one session, several runs
-   ds000114: several tasks, several sessions, one or several runs depending on
    task
-   ds001168: resting state, several sessions, several acquisition, fieldmaps,
    physio data
-   ds002799: resting state and task, several sessions, with fmriprep data

## Download with datalad

All those data can be installed with
[datalad](http://handbook.datalad.org/en/latest/index.html).

Datalad datasets can be accessed via their siblings on:
https://github.com/OpenNeuroDatasets

Check the content of the `Makefile` to see the code snippets you need to run to
install those datasets.

Otherwise you can also get them by using the Datalad superdataset.

For example:

```bash
datalad install ///
cd datasets.datalad.org/
datalad install openneuro
datalad install openneuro/dsXXXXXX
cd openneuro/dsXXXXXX
# get rest data first subject
datalad get /openneuro/dsXXXXXX/sub-0001/func/sub-0001*
```

## NARPS: ds001734

More details here:

https://docs.google.com/spreadsheets/d/1FU_F6kdxOD4PRQDIHXGHS4zTi_jEVaUqY_Zwg0z6S64/edit#gid=1019165812&range=A51

TODO: add expected value to the model

```matlab
% compute euclidean distance to the indifference line defined by
% gain twice as big as losses
% https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
a = 0.5;
b = -1;
c = 0;
x = onsets{iRun}.gain;
y = onsets{iRun}.loss;
dist = abs(a * x + b * y + c) / (a^2 + b^2)^.5;
onsets{iRun}.EV = dist; % create an "expected value" regressor
```

TODO: transformers cannot yet be appled to confounds

```json
{
    "Description": "Time points with a framewise displacement (as calculated by fMRIprep) > 0.5 mm were censored (no interpolation) at the subject level GLM..",
    "Name": "Threshold",
    "Input": [
        "framewise_displacement"
    ],
    "Threshold": 0.5,
    "Binarize": true,
    "Output": [
        "thres_framewise_displacement"
    ]
},
```
