# Download with datalad

In case you use the python package for datalad, activate your virtual
environment (like conda).

```bash
conda activate datalad
```

Datalad datasets can be accessed via their siblings on:
https://github.com/OpenNeuroDatasets

Otherwise you can also get them by using the Datalad superdataset. For example:

```bash
datalad clone ///
cd datasets.datalad.org/
datalad install openneuro datalad
install openneuro/ds002790
cd openneuro/ds002790
# get rest data first subject
datalad get /derivatives/fmriprep/sub-0001/func/sub-0001*task-restingstate_acq-seq*\*
```

## ds000114

Multi-subject and multi-session dataset.

```bash
datalad clone https://github.com/OpenNeuroDatasets/ds000114.git
cd ds000114/
datalad get sub-0[12]/*/anat/*
datalad get sub-0[12]/*/func/*linebisection*
```

## ds000001

```bash
 datalad clone https://github.com/OpenNeuroDatasets/ds000001.git
 cd ds000001/
 datalad get sub-0[12]/anat/*T1w*
 datalad get sub-0[12]/func/*balloonanalogrisktask*
```

## ds001168

7T test-retest data set with fieldmaps

```bash
 datalad clone https://github.com/OpenNeuroDatasets/ds001168.git
 cd ds001168/
 datalad get sub-0[12]/ses*/anat/*
 datalad get sub-0[12]/ses*/func/*fullbrain*

```

## frmriprep output from ds002790

```bash
datalad clone ///
cd datasets.datalad.org/
datalad install openneuro datalad
install openneuro/ds002790
cd openneuro/ds002790
# get resting state data first 2 subjects from MNI space
ls derivatives/fmriprep/sub-000[12]/func/sub-000[12]_task-restingstate_acq-seq_*space-*MNI*_*
datalad get derivatives/fmriprep/sub-000[12]/func/sub-000[12]_task-restingstate_acq-seq_*space-*MNI*_*
# get their realignment parameters and other confounds
ls derivatives/fmriprep/sub-000[12]/func/sub-000[12]_task-restingstate_*confounds*
datalad get derivatives/fmriprep/sub-000[12]/func/sub-000[12]_task-restingstate_*confounds*
# get normalization parameters
ls derivatives/fmriprep/sub-000[12]/anat/*.h5
datalad get derivatives/fmriprep/sub-000[12]/anat/*.h5
# get anat data from MNI space
ls derivatives/fmriprep/sub-0001/anat/*MNI*desc*
datalad get derivatives/fmriprep/sub-0001/anat/*MNI*desc*
```