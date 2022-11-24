# Face repetition demo

## CLI commands

### Preprocessing

```bash
bidspm \
    /home/remi/github/bidspm/demos/face_repetition/outputs/raw \
    /home/remi/github/bidspm/demos/face_repetition/outputs/derivatives \
    subject \
    --action preprocess \
    --participant_label 01 \
    --space individual IXI549Space \
    --task facerepetition \
    --skip_validation
```

```bash
bidspm \
    /home/remi/github/bidspm/demos/face_repetition/outputs/raw \
    /home/remi/github/bidspm/demos/face_repetition/outputs/derivatives \
    subject \
    --action preprocess \
    --space individual IXI549Space \
    --anat_only \
    --skip_validation
```
