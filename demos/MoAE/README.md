# Mother of All Experiments

This "Mother of All Experiments" is based on the block design of SPM.

In the `options` folder has several examples of how to encode the options of
your analysis in a json file.

In the `models` shows the BIDS statistical model used to run the GLM of this
demo.

You can use the makefile to run all the main scripts with `make all`

## CLI commands

### Create model

```bash
bidspm \
    /home/remi/github/bidspm/demos/MoAE/inputs/raw \
    /home/remi/github/bidspm/demos/MoAE/outputs/derivatives \
     dataset \
    --action default_model \
    --space IXI549Space \
    --task auditory \
    --verbosity 2 \
    --ignore transformations
```

### Preprocessing

```bash
bidspm \
    /home/remi/github/bidspm/demos/MoAE/inputs/raw \
    /home/remi/github/bidspm/demos/MoAE/outputs/derivatives \
    subject \
    --action preprocess \
    --participant_label 01 \
    --space individual IXI549Space \
    --task auditory \
    --verbosity 2 \
    --fwhm 6 \
    --ignore unwarp slicetiming
```

### GLM

```bash
bidspm \
    /home/remi/github/bidspm/demos/MoAE/inputs/raw \
    /home/remi/github/bidspm/demos/MoAE/outputs/derivatives \
    subject \
    --action stats \
    --preproc_dir /home/remi/github/bidspm/demos/MoAE/outputs/derivatives/bidspm-preproc \
    --model_file /home/remi/github/bidspm/demos/MoAE/models/model-MoAE_smdl.json \
    --fwhm 6
```

## Docker commands

### Preproc

```bash
docker run -it --rm \
    -v /home/remi/github/bidspm/demos/MoAE/inputs/raw:/raw \
    -v /home/remi/github/bidspm/demos/MoAE/outputs/derivatives:/derivatives \
    cpplab/bidspm:stable \
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
    -v /home/remi/github/bidspm/demos/MoAE/inputs/raw:/raw \
    -v /home/remi/github/bidspm/demos/MoAE/outputs/derivatives:/derivatives \
    -v /home/remi/github/bidspm/demos/MoAE/models:/models \
    cpplab/bidspm:latest \
        /raw \
        /derivatives \
        subject \
        --action stats \
        --preproc_dir /derivatives/bidspm-preproc \
        --model_file /models/model-MoAE_smdl.json \
        --fwhm 6
```
