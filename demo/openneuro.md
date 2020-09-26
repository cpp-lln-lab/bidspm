
## ds000114

conda activate datalad
datalad clone https://github.com/OpenNeuroDatasets/ds000114.git
cd ds000114/
datalad get sub-0[12]/*/anat/*
datalad get sub-0[12]/*/func/*overtwordrepetition*

## ds000001

 datalad clone https://github.com/OpenNeuroDatasets/ds000001.git
 cd ds000001/
 datalad get sub-0[12]/anat/*T1w*
 datalad get sub-0[12]/func/*balloonanalogrisktask*
