
Download with datalad

In case you use the python package for datalad, activate your virtual environment (like conda).

```bash
conda activate datalad
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
