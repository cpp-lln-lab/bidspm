# Demos based on openneuro datasets

-   ds000001: one task, one session, several runs
-   ds000114: several tasks, several sessions,
    one or several runs depending on task
-   ds001168: resting state, several sessions, several acquisition, fieldmaps,
    physio data
-   ds002799: resting state and task, several sessions, with fmriprep data

## Download with datalad

All those data can be installed with
[datalad](http://handbook.datalad.org/en/latest/index.html).

Datalad datasets can be accessed via their siblings on:
https://github.com/OpenNeuroDatasets

Check the content of the `Makefile` to see the code snippets you need to run
to install those datasets.

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
