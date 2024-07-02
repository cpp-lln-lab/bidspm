<!-- the section below is automatically generated.

If you want to modify the questions:
- please edit the files in the `faq` folder in the doc

-->

# General

## Can I use parallelization with bidspm?

You can use parallelization with bidspm.
The main way to do so is to use `parfor` loops in your code
when running the `preprocess`, `smooth` or `stats` actions.

For example, if you want to run the `preprocess` action on a list of subjects,

```matlab
subjects = {'01', '02', '03', '04', '05'};
parfor i = 1:length(subjects)
    bidspm(bids_dir, output_dir, ...
           'participant_label', subjects(i), ...
           'action', 'preprocess', ...
           'task', {'tasnName'}, ...
           'space', {'IXI549Space'});
end
```

## How can I know that things are set up properly before I run an analysis?

If you want to set things up but not let SPM actually run the batches you can
use the option:

`opt.dryRun = true()`

This can be useful when debugging. You may still run into errors when SPM jobman
takes over and starts running the batches, but you can at least see if the
batches will be constructed without error and then inspect with the SPM GUI to
make sure everything is fine.

## How can I prevent from having SPM windows pop up all the time?

Running large number of batches when the GUI of MATLAB is active can be
annoying, as SPM windows will always pop up and become active instead of running
in the background like most users would prefer to.

One easy solution is to add a `spm_my_defaults` function with the following
content in the MATLAB path, or in the directory where you are running your
scripts or command from.

```matlab
function spm_my_defaults

  global defaults

  defaults.cmdline = true;

end
```

This should be picked up by bidspm and SPM upon initialization and ensure that
SPM runs in command line mode.

## How can I run bidspm from the command line?

You can use the Python CLI of bidspm to run many functionalities from the
terminal.

See the README to see how to install it.

You can also run your matlab script from within your terminal without starting
the MATLAB graphic interface.

For this you first need to know where is the MATLAB application. Here are the
typical location depending on your operating system (where `XXx` corresponds to
the version you use).

-   Windows: `C:\Program Files\MATLAB\R20XXx\bin\matlab.exe`
-   Mac: `/Applications/Matlab_R20XXx.app/bin/matlab`
-   Linux: `/usr/local/MATLAB/R20XXx/bin/matlab`

You can then launch MATLAB from a terminal in a command line only with the
following arguments: `-nodisplay -nosplash -nodesktop`

So on Linux for example:

```bash
/usr/local/MATLAB/R2017a/bin/matlab -nodisplay -nosplash -nodesktop
```

If you are on Mac or Linux, we would recommend adding those aliases to your
`.bashrc` or wherever else you keep your aliases.

```bash
matlab=/usr/local/MATLAB/R20XXx/bin/matlab
matlabcli='/usr/local/MATLAB/R20XXx/bin/matlab -nodisplay -nosplash -nodesktop'
```

## How can I run bidspm only certain files, like just the session `02` for example?

Currently there are 2 ways of doing this.

-   using the `bids_filter_file` parameter or an equivalent
    `bids_filter_file.json` file or its counterpart field `opt.bidsFilterFile`
-   using the `opt.query` option field.

On the long run the plan is to use only the `bids_filter_file`, but for now both
possibilities should work.

### `bids filter file`

This is similar to the way you can "select" only certain files to preprocess
with
[fmriprep](https://fmriprep.org/en/stable/faq.html#how-do-i-select-only-certain-files-to-be-input-to-fmriprep).

You can use a `opt.bidsFilterFile` field in your options to define a typical
images "bold", "T1w" in terms of their BIDS entities. The default value is:

```matlab
struct('fmap', struct('modality', 'fmap'), ...
       'bold', struct('modality', 'func', 'suffix', 'bold'), ...
       't2w',  struct('modality', 'anat', 'suffix', 'T2w'), ...
       't1w',  struct('modality', 'anat', 'space', '', 'suffix', 'T1w'), ...
       'roi',  struct('modality', 'roi', 'suffix', 'mask'));
```

Similarly when using the bidspm you can use the argument `bids_filter_file` to
pass a structure or point to a JSON file that would also define typical images
"bold", "T1w"...

The default content in this case would be:

```json
{
    "fmap": { "datatype": "fmap" },
    "bold": { "datatype": "func", "suffix": "bold" },
    "t2w": { "datatype": "anat", "suffix": "T2w" },
    "t1w": { "datatype": "anat", "space": "", "suffix": "T1w" },
    "roi": { "datatype": "roi", "suffix": "mask" }
}
```

So if you wanted to run your analysis on say run `02` and `05` of session `02`,
you would define a json file this file like this:

```json
{
    "fmap": { "datatype": "fmap" },
    "bold": {
        "datatype": "func",
        "suffix": "bold",
        "ses": "02",
        "run": ["02", "05"]
    },
    "t2w": { "datatype": "anat", "suffix": "T2w" },
    "t1w": { "datatype": "anat", "space": "", "suffix": "T1w" },
    "roi": { "datatype": "roi", "suffix": "mask" }
}
```

### `opt.query`

You can select a subset of your data by using the `opt.query`.

This will create a "filter" that bids-matlab will use to only "query" and
retrieve the subset of files that match the requirement of that filter

In "pure" bids-matlab it would look like:

```matlab
  BIDS = bids.layout(path_to_my_dataset)
  bids.query(BIDS, 'data', opt.query)
```

So if you wanted to run your analysis on say run `02` and `05` of session `02`,
you would define your filter like this:

```matlab
  opt.query.ses = '02'
  opt.query.run = {'02', '05'}
```

## What happens if we run same code twice?

In the vast majority of cases, if you have not touched anything to your options,
you will overwrite the output.

Two exceptions that actually have time stamps and are not over-written:

-   The `matlabbatches` saved in the `jobs` folders as `.m` and `.json` files.
-   If you have saved your options with `saveOptions` (which is the case for
    most of bidspm actions), then the output `.json` file is saved with a time
    stamp too.

In most of other cases if you don't want to overwrite previous output, you will
have to change the output directory.

For the preprocess action, in general you would have to specify a different
`output_dir`.

For the statistics workflows, you have a few more choices as the name of the
output folders includes information that comes from the options and / or the
BIDS stats model.

The output folder name (generated by `getFFXdir()` for the subject level and by
`getRFXdir()` for the dataset level) should include:

-   the FWHM used on the BOLD images
-   info specified in the `Inputs` section of the BIDS stats model JSON file
    (like the name of the task or the MNI space of the input images)
-   the name of the run level node if it is not one of the default one (like
    `"run level"`).

```bash
  $ ls demos/MoAE/outputs/derivatives/bidspm-stats/sub-01/stats

  # Folder name for a model on the auditory task in SPM's MNI space
  # on data smoothed with a 6mm kernel
  task-auditory_space-IXI549Space_FWHM-6
```

See
[this question for more details](#statistics:-how-can-change-the-name-of-the-folder-of-the-subject-level-analysis).

---

Generated by [FAQtory](https://github.com/willmcgugan/faqtory)
