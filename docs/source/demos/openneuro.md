# Openneuro based demos

```{include} ../../../demos/openneuro/README.md
   :parser: myst_parser.sphinx_
```
```{eval-rst}
.. mat:autofolder:: demos/openneuro/
```

## ds000001: Balloon analog risk

- [Source dataset](https://openneuro.org/datasets/ds000001)

### Features

-   one task
-   one session
-   several runs
-   parametric analysis

### Scripts

```{eval-rst}
.. autoscript:: demos/openneuro/ds000001_run.m
.. autoscript:: demos/openneuro/ds000001_smooth_run.m
.. autoscript:: demos/openneuro/ds000001_aroma_run.m
```

## ds000114: test-retest

- [Source dataset](https://openneuro.org/datasets/ds000114)

### Features

-   several tasks
-   several sessions
-   one or several runs depending on task
-   fmriprep data

### Scripts

```{eval-rst}
.. autoscript:: demos/openneuro/ds000114_run.m
```

## ds000224

- [Source dataset](https://openneuro.org/datasets/ds000224)

### Features

-   fmriprep data

### Scripts

```{eval-rst}
.. autoscript:: demos/openneuro/ds000224_run.m
```

## ds001168

- [Source dataset](https://openneuro.org/datasets/ds001168)

### Features

-   resting state
-   several sessions
-   several acquisition
-   fieldmaps
-   physio data

### Scripts

```{eval-rst}
.. autoscript:: demos/openneuro/ds001168_run.m
```

## ds001734: NARPS

- [Source dataset](https://openneuro.org/datasets/ds001734)

### Features

- one task
- one session
- several runs
- several groups
- \>100 participants
- fmriprep data

### Details

More details [here](https://docs.google.com/spreadsheets/d/1FU_F6kdxOD4PRQDIHXGHS4zTi_jEVaUqY_Zwg0z6S64/edit#gid=1019165812&range=A51).


<!-- TODO
add expected value to the model
-->

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

<!-- TODO
transformers cannot yet be appled to confounds
-->

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

### Scripts

```{eval-rst}
.. autoscript:: demos/openneuro/ds001734_run.m
```

## ds002799

- [Source dataset](https://openneuro.org/datasets/ds002799)

### Features

-   resting state and task
-   several sessions
-   fmriprep data

## ds003379

- [Source dataset](https://openneuro.org/datasets/ds003379)

### Features

-   checkerboard localizer
-   3 groups
-   fmriprep data

### Scripts

```{eval-rst}
.. autoscript:: demos/openneuro/ds003397_run.m
```
