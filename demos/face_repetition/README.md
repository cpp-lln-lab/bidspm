# Face repetition demo

## CLI commands

### Preprocessing

```bash
bidspm \
    $PWD/outputs/raw \
    $PWD/outputs/derivatives \
    subject \
    --action preprocess \
    --participant_label 01 \
    --space individual IXI549Space \
    --task facerepetition \
    --skip_validation \
    --dummy_scans 5
```

```bash
bidspm \
    $PWD/outputs/raw \
    $PWD/outputs/derivatives \
    subject \
    --action preprocess \
    --space individual IXI549Space \
    --anat_only \
    --skip_validation
```
