# Mother of All Experiments

This "Mother of All Experiments" is based on the block design of SPM.

In the `options` folder has several examples of how to encode the options of
your analysis in a json file.

In the `models` shows the BIDS statistical model used to run the GLM of this
demo.

You can use the makefile to run all the main scripts with `make all`

## CLI commands

### Preprocessing

```bash
bidspm \
    $PWD/inputs/raw \
    $PWD/outputs/derivatives \
    subject \
    --action preprocess \
    --participant_label 01 \
    --space individual IXI549Space \
    --task auditory \
    --verbosity 2 \
    --fwhm 6 \
    --ignore unwarp slicetiming
```

### Smoothing

To smooth directly an fmriprep dataset

```bash
bidspm \
    $PWD/inputs/fmriprep \
    $PWD/outputs/derivatives \
    subject \
    --action smooth \
    --participant_label 01 \
    --space '^.*MNI.*$' \
    --task auditory \
    --verbosity 2 \
    --fwhm 6
```

### Create model

```bash
bidspm \
    $PWD/inputs/raw \
    $PWD/outputs/derivatives \
     dataset \
    --action default_model \
    --space IXI549Space \
    --task auditory \
    --verbosity 2 \
    --ignore transformations
```

### GLM

```bash
bidspm \
    $PWD/inputs/raw \
    $PWD/outputs/derivatives \
    subject \
    --action stats \
    --preproc_dir $PWD/outputs/derivatives/bidspm-preproc \
    --model_file $PWD/models/model-MoAE_smdl.json \
    --fwhm 6
```

```bash
bidspm \
    $PWD/inputs/raw \
    $PWD/outputs/derivatives \
    subject \
    --action stats \
    --preproc_dir $PWD/outputs/derivatives/bidspm-preproc \
    --model_file $PWD/outputs/derivatives/models/model-defaultAuditory_smdl.json \
    --fwhm 6
```

## Docker commands

### Preproc

```bash
docker run -it --rm \
    -v $PWD/inputs/raw:/raw \
    -v $PWD/outputs/derivatives:/derivatives \
    cpplab/bidspm:latest \
        /raw \
        /derivatives \
        subject \
        --task auditory \
        --action preprocess \
        --fwhm 8
```

### Stats

```bash
docker run -it --rm \
    -v $PWD/inputs/raw:/raw \
    -v $PWD/outputs/derivatives:/derivatives \
    -v $PWD/models:/models \
    cpplab/bidspm:latest \
        /raw \
        /derivatives \
        subject \
        --action stats \
        --preproc_dir /derivatives/bidspm-preproc \
        --model_file /models/model-MoAE_smdl.json \
        --fwhm 6
```
