
<!-- DO NOT EDIT MANUALLY -->
(faq)=
# Frequently Asked Questions
- [BIDS: What is a BIDS way to name and store Regions of Interest (ROIs)?](#bids:-what-is-a-bids-way-to-name-and-store-regions-of-interest-(rois))
- [General: How can I know that things are set up properly before I run an analysis?](#general:-how-can-i-know-that-things-are-set-up-properly-before-i-run-an-analysis)
- [General: How can I prevent from having SPM windows pop up all the time?](#general:-how-can-i-prevent-from-having-spm-windows-pop-up-all-the-time)
- [General: How can I run bidspm from the command line?](#general:-how-can-i-run-bidspm-from-the-command-line)
- [General: How can I run bidspm only certain files, like just the session `02` for example?](#general:-how-can-i-run-bidspm-only-certain-files,-like-just-the-session-`02`-for-example)
- [General: What happens if we run same code twice?](#general:-what-happens-if-we-run-same-code-twice)
- [How can I see what the transformation in the BIDS stats model will do to my events.tsv?](#how-can-i-see-what-the-transformation-in-the-bids-stats-model-will-do-to-my-eventstsv)
- [Results: How can I change which slices are shown in a montage?](#results:-how-can-i-change-which-slices-are-shown-in-a-montage)
- [SPM: How can get the data from some specific voxel in a nifti image?](#spm:-how-can-get-the-data-from-some-specific-voxel-in-a-nifti-image)
- [SPM: How can I use SPM image calculator (`imcalc`) to create a ROI?](#spm:-how-can-i-use-spm-image-calculator-(`imcalc`)-to-create-a-roi)
- [SPM: How can set the value of a specific voxel in a nifti image?](#spm:-how-can-set-the-value-of-a-specific-voxel-in-a-nifti-image)
- [SPM: How do I get the header of a nifti image?](#spm:-how-do-i-get-the-header-of-a-nifti-image)
- [SPM: How do I know which matlab function performs a given SPM process?](#spm:-how-do-i-know-which-matlab-function-performs-a-given-spm-process)
- [SPM: How do I merge 2 masks with SPM?](#spm:-how-do-i-merge-2-masks-with-spm)
- [SPM: What is the content of the SPM.mat file?](#spm:-what-is-the-content-of-the-spmmat-file)
- [Statistics: How can change the name of the folder of the subject level analysis?](#statistics:-how-can-change-the-name-of-the-folder-of-the-subject-level-analysis)
- [Statistics: How should I structure my data to run my statistical analysis?](#statistics:-how-should-i-structure-my-data-to-run-my-statistical-analysis)

<a name="bids:-what-is-a-bids-way-to-name-and-store-regions-of-interest-(rois)"></a>
## BIDS: What is a BIDS way to name and store Regions of Interest (ROIs)?

There is no "official" way to name ROI in BIDS, but you can apply BIDS naming
principles to name those.

The closest things to ROI naming are the `masks` for the
[BIDS derivatives](https://bids-specification.readthedocs.io/en/latest/05-derivatives/03-imaging.html#masks).

Here is an example from the :ref:`face repetition demo`::

```text
  bidspm-roi
  ├── group
  │   ├── hemi-L_space-MNI_label-V1d_desc-wang_mask.json
  │   ├── hemi-L_space-MNI_label-V1d_desc-wang_mask.nii
  │   ├── hemi-L_space-MNI_label-V1v_desc-wang_mask.json
  │   ├── hemi-L_space-MNI_label-V1v_desc-wang_mask.nii
  │   ├── hemi-R_space-MNI_label-V1d_desc-wang_mask.json
  │   ├── hemi-R_space-MNI_label-V1d_desc-wang_mask.nii
  │   ├── hemi-R_space-MNI_label-V1v_desc-wang_mask.json
  │   └── hemi-R_space-MNI_label-V1v_desc-wang_mask.nii
  └── sub-01
      └── roi
          ├── sub-01_hemi-L_space-individual_label-V1d_desc-wang_mask.nii
          ├── sub-01_hemi-L_space-individual_label-V1v_desc-wang_mask.nii
          ├── sub-01_hemi-R_space-individual_label-V1d_desc-wang_mask.nii
          └── sub-01_hemi-R_space-individual_label-V1v_desc-wang_mask.nii
```

ROIs that are defined in some MNI space are going to be the same across
subjects, so you could store a "group" folder (this is not BIDSy but is less
redundant than having a copy of the same file for each subject).

The `desc` entity (description) here is used to denotate the atlas the ROI taken
from, so if you are building yours from a localizer you might not need to use
it.

Ideally you would want to add a JSON file to add metadata about those ROIs.

You can use bids-matlab to help you create BIDS valid filenames.

```matlab
  >> name_spec.ext = '.nii';
  >> name_spec.suffix = 'mask';
  >> name_spec.entities = struct( ...
                                'hemi', 'R', ...
                                'space', 'MNI', ...
                                'label', 'V1v', ...
                                'desc', 'wang');
  >> file = bids.File(name_spec);
  >> file.filename

     hemi-R_space-MNI_label-V1v_desc-wang_mask.nii
```

<a name="general:-how-can-i-know-that-things-are-set-up-properly-before-i-run-an-analysis"></a>
## General: How can I know that things are set up properly before I run an analysis?

If you want to set things up but not let SPM actually run the batches you can
use the option:

`opt.dryRun = true()`

This can be useful when debugging. You may still run into errors when SPM jobman
takes over and starts running the batches, but you can at least see if the
batches will be constructed without error and then inspect with the SPM GUI to
make sure everything is fine.

<a name="general:-how-can-i-prevent-from-having-spm-windows-pop-up-all-the-time"></a>
## General: How can I prevent from having SPM windows pop up all the time?

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

<a name="general:-how-can-i-run-bidspm-from-the-command-line"></a>
## General: How can I run bidspm from the command line?

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

<a name="general:-how-can-i-run-bidspm-only-certain-files,-like-just-the-session-`02`-for-example"></a>
## General: How can I run bidspm only certain files, like just the session `02` for example?

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

<a name="general:-what-happens-if-we-run-same-code-twice"></a>
## General: What happens if we run same code twice?

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

<a name="how-can-i-see-what-the-transformation-in-the-bids-stats-model-will-do-to-my-eventstsv"></a>
## How can I see what the transformation in the BIDS stats model will do to my events.tsv?

You can use the `bids.util.plot_events` function to help you visualize what events will be used in your GLM.

If you want to vivualize the events file:

```matlab
bids.util.plot_events(path_to_events_files);
```

This assumes the events are listed in the `trial_type` column (though this can be
changed by the `trial_type_col` parameter).

If you want to see what events will be included in your GLM after the transformations
are applied:

```matlab
bids.util.plot_events(path_to_events_files, 'model_file', path_to_bids_stats_model_file);
```

This assumes the transformations to apply are in the root node eof the model.

In case you want to save the output after the transformation:

```matlab
% load the events and the stats model
data = bids.util.tsvread(path_to_events_files);
model = BidsModel('file', path_to_bids_stats_model_file);

% apply the transformation
transformers = model.Nodes{1}.Transformations.Instructions;
[new_content, json] = bids.transformers(transformers, data);

% save the new TSV for inspection to make sure it looks like what we expect
bids.util.tsvwrite(fullfile(pwd, 'new_events.tsv'), new_content);
```

<a name="results:-how-can-i-change-which-slices-are-shown-in-a-montage"></a>
## Results: How can I change which slices are shown in a montage?

> In `bidsspm(..., 'action', 'results', ...)`
> I get an image with the overlay of different slices.
> How can I change which slices are shown?

When you define your options the range of slices that are to be shown can be
changed like this (see `bidsResults` help section for more information):

```matlab
    % slices position in mm [a scalar or a vector]
    opt.results(1).montage.slices = -12:4:60;

    % slices orientation: can be 'axial' 'sagittal' or 'coronal'
    % axial is default
    opt.results(1).montage.orientation = 'axial';
```

<a name="spm:-how-can-get-the-data-from-some-specific-voxel-in-a-nifti-image"></a>
## SPM: How can get the data from some specific voxel in a nifti image?

### `spm_read_vols`

This can be done with the `spm_read_vols` function.

```matlab
% get header of Nifti images
header = spm_vol(path_to_image);
% get the data
data = spm_read_vols(header);
```

`data` is an array of size (x, y, z, t) with x, y and z being the spatial dimensions
and t being the temporal dimension.

You can access the data in any voxel by using the proper index.

### `spm_get_data`

```matlab
% get header of Nifti images
header = spm_vol(path_to_image);
% define voxels to return
XYZ = [10 20; ...
       20 25; ...
       39 10];
% get the data
data = spm_get_data(header, XYZ)
```

- `header`         - [1 x n] structure array of file headers with `n` being the number of volumes
- `XYZ`       - [3 x m] or [4 x m] location matrix {voxel}

- `data`      - [n x m] double values

<a name="spm:-how-can-i-use-spm-image-calculator-(`imcalc`)-to-create-a-roi"></a>
## SPM: How can I use SPM image calculator (`imcalc`) to create a ROI?

The image calculator utility is accessible in the SPM batch GUI:

`Batch --> SPM --> Util --> Image Calculator`

You can select the input image you want to use to create a ROI (like an atlas
for example), and then set the expression you want to use to only keep certain
voxels as part of the binary mask that will define your ROI.

If you want to keep voxels for your ROI that have a value of 51 or 52 or 53, you
would use the following expression:

```matlab
i1==51 || i1==52 || i1 == 53
```

If you save the batch and its job you will get an .m file that may contain
something like this.

```matlab
matlabbatch{1}.spm.util.imcalc.input = fullpath_to_the_image;
matlabbatch{1}.spm.util.imcalc.output = 'output';
matlabbatch{1}.spm.util.imcalc.outdir = {''};
matlabbatch{1}.spm.util.imcalc.expression = 'i1==51 || i1==52 || i1 == 53';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
```

<a name="spm:-how-can-set-the-value-of-a-specific-voxel-in-a-nifti-image"></a>
## SPM: How can set the value of a specific voxel in a nifti image?

This can be done with the `spm_write_vols` function.

```matlab
% get nifti header
header = spm_vol(path_to_image);

% get atlas content
content = spm_read_vols(header);

% set the voxel (1,1,1) to 0
x = 1;
y = 1;
z = 1;
content(x,y, z) = 0;

% prepare header for the output
new_header = header;
new_header.fname = 'changed_nifti.nii';

% write mask
spm_write_vol(new_header, content);
```

<a name="spm:-how-do-i-get-the-header-of-a-nifti-image"></a>
## SPM: How do I get the header of a nifti image?

### Getting the header

This can be done with the `spm_vol` function.

```matlab
% get header of Nifti images
header = spm_vol(path_to_image);
```

If the input image is a 4D nifti file, the structure `header` returned will have as many elements
as they are volumes in the file.

The fields of the structures are:

- `header.fname` - the filename of the image.
- `header.dim`   - the x, y and z dimensions of the volume
- `header.dt`    - A 1x2 array.  First element is datatype (see spm_type).
              The second is 1 or 0 depending on the endian-ness.
- `header.pinfo` - plane info for each plane of the volume.
  - `header.pinfo(1,:)` - scale for each plane
  - `header.pinfo((2,:)` - offset for each plane
                   The true voxel intensities of the jth image are given
                   by: `val*header.pinfo(1,j) + header.pinfo(2,j)`
  - `header.pinfo((3,:)` - offset into image (in bytes).
                   If the size of pinfo is 3x1, then the volume is assumed
                   to be contiguous and each plane has the same scalefactor
                   and offset.
- `header.mat`   - a 4x4 affine transformation matrix mapping from
              voxel coordinates to real world coordinates.
              This can also be directly accessed by `spm_get_space`.


### Voxel size

The voxel size are the 3 first values of the main diagonal of `header.mat`.
Get the value along the main diagonal of the matrix and stores it in a
temporary variable.

```matlab
temp = diag(header.mat);
```

Then we only keep the 3 first values of this diagonal to get the x, y, z dimension
of each voxel (in mm) of this image.

```matlab
% the "abs" is there to have the absolute value
VoxelsDimension = abs(temp(1:3));
```

### Getting the voxel subscripts of a given set of world space coordinates

```matlab
% world coordinate in mm
x = 0;
y = 0;
z = 0;
world_space_coordinates = [x; y; z; 1];

% Remember that if a matrix A performs a certain transformation,
% the matrix inv(A) will perform the reverse transformation
voxel_subscripts = inv(header.mat) * world_space_coordinates;

% we need to use 'round' to get a value that is not in between 2 voxels.
voxel_subscripts = round(voxel_subscripts(1:3));
```

### Getting the world space coordinate of a given voxel

```matlab
x = 1;
y = 1;
z = 1;

% We have to pad with an extra one to be able
% to multiply it with the transformation matrix.
voxel_subscripts = [x; y; z; 1];
world_space_coordinates = header.mat * voxel_subscripts;

% Only the three first value of this vector are of interest to us
world_space_coordinates = world_space_coordinates(1:3);
```

<a name="spm:-how-do-i-know-which-matlab-function-performs-a-given-spm-process"></a>
## SPM: How do I know which matlab function performs a given SPM process?

If you are looking for which SPM function does task X, click on the `help`
button in the main SPM menu window, then on the task X (e.g Results): the new
window will tell you the name of the function that performs the task you are
interested in (`spm_results_ui.m` in this case).

Another tip is that usually when you run a given process in SPM, the command
line will display the main function called.

For example clicking on the `Check Reg` button and selecting an image to view
display:

```matlab
SPM12: spm_check_registration (v6245)              13:42:08 - 30/10/2018
========================================================================
Display D:\SPM\spm12\canonical\avg305T1.nii,1
```

This tells you that this called the `spm_check_registration.m` matlab function.

You can also find other interesting suggestions in this discussion of the SPM
mailing list:
[SPM: Peeking under the hood -- how?](https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=ind1803&L=spm&P=R58295&1=spm&9=A&J=on&d=No+Match%3BMatch%3BMatches&z=4).

Once you have identified the you can then type either type `help function_name`
if you want some more information about this function or `edit function_name` if
you want to see the code and figure out how the function works.

<a name="spm:-how-do-i-merge-2-masks-with-spm"></a>
## SPM: How do I merge 2 masks with SPM?

Here is a code snippet to merge 2 masks:

```matlab
path_to_mask_1 = 'FIX_ME';
path_to_mask_2 = 'FIX_ME';

% get header of Nifti images
header_1 = spm_vol(path_to_mask_1);
header_2 = spm_vol(path_to_mask_2);

% if you want to make sure that images are in the same space
% and have same resolution
masks = char({path_to_mask_1; path_to_mask_2});
spm_check_orientations(spm_vol(masks));

% get data of Nifti images
mask_1 = spm_read_vols(header_1);
mask_2 = spm_read_vols(header_2);

% concatenate data along the 4th dimension
merged_mask = cat(4, mask_1, mask_2);

% keep any voxel that has some value along the 4th dimension
merged_mask = any(merged_mask, 4);

% create a new header of the final mask
merged_mask_header = header_1;
merged_mask_header.fname = 'new_mask.nii';

spm_write_vol(merged_mask_header, merged_mask);
```

Also good way to learn about some basic low level functions of SPM.

-   `spm_vol`: reads the header of a 3D or 4D Nifti images
-   `spm_read_vols`: given a header it will get the data of Nifti image
-   `spm_write_vol`: given a header and a 3D matrix, it will write a Nifti image

For more info about basic files, check the
[SPM wikibooks](https://en.wikibooks.org/wiki/SPM/Programming_intro#SPM_functions).

<a name="spm:-what-is-the-content-of-the-spmmat-file"></a>
## SPM: What is the content of the SPM.mat file?

This is here because SPM has the sad (and bad) Matlabic tradition of using variable names
that have often attempted to replicate the notation in the papers to make engineers
and the generally math enclined happy,
rather than the `TypicalLongVariableNames` that many programmers and new comers
would prefer to see to help with code readability.

Adapted from: http://andysbrainblog.blogspot.com/2013/10/whats-in-spmmat-file.html


### details on experiment


- `SPM.xY.RT`                - TR length (RT ="repeat time")
- `SPM.xY.P`                 - matrix of file names
- `SPM.xY.VY`                - (number of runs x 1) struct array of mapped image volumes (.nii file info)

- `SPM.modality`             - the data you're using (PET, FMRI, EEG)

- `SPM.stats.[modality].UFp` - critical F-threshold for selecting voxels over which the non-sphericity is estimated
                               (if required) [default: `0.001`]
- `SPM.stats.maxres`         - maximum number of residual images for smoothness estimation
- `SPM.stats.maxmem`         - maximum amount of data processed at a time (in bytes)

- `SPM.SPMid`                - version of SPM used

- `SPM.swd`                  - directory for SPM.mat and nii files. default is `pwd`


###  basis function


- `SPM.xBF.name`     - name of basis function
- `SPM.xBF.length`   - length in seconds of basis
- `SPM.xBF.order`    - order of basis set
- `SPM.xBF.T`        - number of subdivisions of TR
- `SPM.xBF.T0`       - first time bin (see slice timing)
- `SPM.xBF.UNITS`    - options: `'scans'` or `'secs'` for onsets
- `SPM.xBF.Volterra` - order of convolution
- `SPM.xBF.dt`       - length of time bin in seconds
- `SPM.xBF.bf`       - basis set matrix


### Session structure


Note that in SPM lingo sessions are equivalent to a runs in BIDS.

#### user-specified covariates/regressors


e.g. motion

- `SPM.Sess([session]).C.C`    - (n x c) double regressor (`c` is number of covariates, `n` is number of sessions)
- `SPM.Sess([session]).C.name` - names of covariates

#### conditions & modulators specified


i.e. input structure array

- `SPM.Sess([session]).U(condition).dt`:  - time bin length (seconds)
- `SPM.Sess([session]).U(condition).name` - names of conditions
- `SPM.Sess([session]).U(condition).ons`  - onset for condition's trials
- `SPM.Sess([session]).U(condition).dur`  - duration for condition's trials
- `SPM.Sess([session]).U(condition).u`    - (t x j) inputs or stimulus function matrix
- `SPM.Sess([session]).U(condition).pst`  - (1 x k) peri-stimulus times (seconds)

#### parameters/modulators specified


- `SPM.Sess([session]).U(condition).P`      - parameter structure/matrix
- `SPM.Sess([session]).U(condition).P.name` - names of modulators/parameters
- `SPM.Sess([session]).U(condition).P.h`    - polynomial order of modulating parameter (order of polynomial expansion where 0 is none)
- `SPM.Sess([session]).U(condition).P.P`    - vector of modulating values
- `SPM.Sess([session]).U(condition).P.P.i`  - sub-indices of `U(i).u` for plotting

#### scan indices for sessions


- `SPM.Sess([session]).row`

#### effect indices for sessions


- `SPM.Sess([session]).col`

#### F Contrast information for input-specific effects


- `SPM.Sess([session]).Fc`
- `SPM.Sess([session]).Fc.i`    - F Contrast columns for input-specific effects
- `SPM.Sess([session]).Fc.name` - F Contrast names for input-specific effects

- `SPM.nscan([session])` - number of scans per session (or if e.g. a t-test, total number of con*.nii files)


### global variate/normalization details


- `SPM.xGX.iGXcalc` - either `'none'` or `'scaling'`

For fMRI usually is `none` (no global normalization).
If global normalization is `scaling`, see `spm_fmri_spm_ui` for parameters that will then appear under `SPM.xGX`.


### design matrix information


- `SPM.xX.X`        - design matrix (raw, not temporally smoothed)
- `SPM.xX.name`     - cellstr of parameter names corresponding to columns of design matrix
- `SPM.xX.I`        - (nScan x 4) matrix of factor level indicators. first column is the replication number.
                      Other columns are the levels of each experimental factor.
- `SPM.xX.iH`       - vector of H partition (indicator variables) indices
- `SPM.xX.iC`       - vector of C partition (covariates) indices
- `SPM.xX.iB`       - vector of B partition (block effects) indices
- `SPM.xX.iG`       - vector of G partition (nuisance variables) indices

- `SPM.xX.K`        - cell. low frequency confound: high-pass cutoff (seconds)
- `SPM.xX.K.HParam` - low frequency cutoff value
- `SPM.xX.K.X0`     - cosines (high-pass filter)

- `SPM.xX.W`        - Optional whitening/weighting matrix used to give weighted least squares estimates (WLS).
                      If not specified `spm_spm` will set this to whiten the data
                      and render the OLS estimates maximum likelihood i.e. `W*W' inv(xVi.V)`.

- `SPM.xX.xKXs`     - space structure for K*W*X, the 'filtered and whitened' design matrix

  - `SPM.xX.xKXs.X`   - matrix of trials and betas (columns) in each trial
  - `SPM.xX.xKXs.tol` - tolerance
  - `SPM.xX.xKXs.ds`  - vectors of singular values
  - `SPM.xX.xKXs.u`   - u as in X u*diag(ds)*v'
  - `SPM.xX.xKXs.v`   - v as in X u*diag(ds)*v'
  - `SPM.xX.xKXs.rk`  - rank
  - `SPM.xX.xKXs.oP`  - orthogonal projector on X
  - `SPM.xX.xKXs.oPp` - orthogonal projector on X'
  - `SPM.xX.xKXs.ups` - space in which this one is embedded
  - `SPM.xX.xKXs.sus` - subspace

- `SPM.xX.pKX`      - pseudoinverse of K*W*X, computed by `spm_sp`
- `SPM.xX.Bcov`     - xX.pKX*xX.V*xX.pKX - variance-covariance matrix of parameter estimates
                      (when multiplied by the voxel-specific hyperparameter ResMS of the parameter estimates (ResSS/xX.trRV ResMS) )
- `SPM.xX.trRV`     - trace of R*V
- `SPM.xX.trRVRV`   - trace of RVRV
- `SPM.xX.erdf`     - effective residual degrees of freedom (`trRV^2/trRVRV`)
- `SPM.xX.nKX`      - design matrix (`xX.xKXs.X`) scaled for display (see `spm_DesMtx('sca',...` for details)
- `SPM.xX.sF`       - cellstr of factor names (columns in `SPM.xX.I`, i think)
- `SPM.xX.D`        - struct, design definition
- `SPM.xX.xVi`      - correlation constraints (see non-sphericity below)

- `SPM.xC`          - struct. array of covariate info


### header info


- `SPM.P` - a matrix of filenames

- `SPM.V` - a vector of structures containing image volume information.

  - `SPM.V.fname`      - the filename of the image.
  - `SPM.V.dim`        - the x, y and z dimensions of the volume
  - `SPM.V.dt`         - a (1 x 2) array. First element is datatype (see `spm_type`).
                         The second is 1 or 0 depending on the endian-ness.
  - `SPM.V.mat`        - a (4 x 4) affine transformation matrix mapping from voxel coordinates
                         to real world coordinates.
  - `SPM.V.pinfo`      - plane info for each plane of the volume.
  - `SPM.V.pinfo(1,:)` - scale for each plane
  - `SPM.V.pinfo(2,:)` - offset for each plane The true voxel intensities of the j<sup>`th`</sup> image are given by: `val*V.pinfo(1,j) + V.pinfo(2,j`)
  - `SPM.V.pinfo(3,:)` - offset into image (in bytes). If the size of pinfo is 3x1,
                         then the volume is assumed to be contiguous and each plane has the same scale factor and offset.


### structure describing intrinsic temporal non-sphericity


- `SPM.xVi.I`   - typically the same as `SPM.xX.I`
- `SPM.xVi.h`   - hyperparameters
- `SPM.xVi.V`   - xVi.h(1)*xVi.Vi{1} + ...
- `SPM.xVi.Cy`  - spatially whitened (used by ReML to estimate h)
- `SPM.xVi.CY`  - `<(Y - )*(Y - )'>` (used by `spm_spm_Bayes`)
- `SPM.xVi.Vi`  - array of non-sphericity components

    - defaults to `{speye(size(xX.X,1))}` - i.i.d.
    - specifying a cell array of constraints ((Qi)
    - These constraints invoke `spm_reml` to estimate hyperparameters assuming V is constant over voxels that provide a high precise estimate of xX.V

- `SPM.xVi.form` - form of non-sphericity (either `'none'` or `'AR(1)'` or `'FAST'`)

- `SPM.xX.V`     - Optional non-sphericity matrix. `CCov(e)sigma^2*V`.
  If not specified `spm_spm` will compute this using a 1st pass to identify significant voxels over which to estimate V.
  A 2nd pass is then used to re-estimate the parameters with WLS and save the ML estimates (unless xX.W is already specified).


### filtering information


- `SPM.K` - filter matrix or filtered structure

  - `SPM.K(s)`        - structure array containing partition-specific specifications
  - `SPM.K(s).RT`     - observation interval in seconds
  - `SPM.K(s).row`    - row of Y constituting block/partitions
  - `SPM.K(s).HParam` - cut-off period in seconds
  - `SPM.K(s).X0`     - low frequencies to be removed (DCT)

- `SPM.Y` - filtered data matrix


### masking information


- `SPM.xM`     - Structure containing masking information, or a simple column vector of thresholds corresponding to the images in VY.
- `SPM.xM.T`   - (n x 1) double - Masking index
- `SPM.xM.TH`  - (nVar x nScan) matrix of analysis thresholds, one per image
- `SPM.xM.I`   - Implicit masking (`0` --> none; `1` --> implicit zero/NaN mask)
- `SPM.xM.VM`  - struct array of mapped explicit mask image volumes
- `SPM.xM.xs`  - (1 x 1) struct ; cellstr description


### design information


self-explanatory names, for once

- `SPM.xsDes.Basis_functions` - type of basis function
- `SPM.xsDes.Number_of_sessions`
- `SPM.xsDes.Trials_per_session`
- `SPM.xsDes.Interscan_interval`
- `SPM.xsDes.High_pass_Filter`
- `SPM.xsDes.Global_calculation`
- `SPM.xsDes.Grand_mean_scaling`
- `SPM.xsDes.Global_normalisation`


### details on scanner data


e.g. smoothness

- `SPM.xVol` - structure containing details of volume analyzed

  - `SPM.xVol.M`    - (4 x 4) voxel --> mm transformation matrix
  - `SPM.xVol.iM`   - (4 x 4) mm --> voxel transformation matrix
  - `SPM.xVol.DIM`  - image dimensions - column vector (in voxels)
  - `SPM.xVol.XYZ`  - (3 x S) vector of in-mask voxel coordinates
  - `SPM.xVol.S`    - Lebesgue measure or volume (in voxels)
  - `SPM.xVol.R`    - vector of resel counts (in resels)
  - `SPM.xVol.FWHM` - Smoothness of components - FWHM, (in voxels)


### info on beta files


- `SPM.Vbeta` - struct array of beta image handles

  - `SPM.Vbeta.fname`   - beta nii file names
  - `SPM.Vbeta.descrip` - names for each beta file


### info on variance of the error

- `SPM.VResMS` - file struct of ResMS image handle

  - `SPM.VResMS.fname` - variance of error file name

### info on mask


- `SPM.VM` - file struct of Mask image handle

  - `SPM.VM.fname` - name of mask nii file


### contrast details


added after running contrasts

- `SPM.xCon` - Contrast definitions structure array. See also `spm_FcUtil.m` for structure, rules & handling.

  - `SPM.xCon.name` - Contrast name
  - `SPM.xCon.STAT` - Statistic indicator character (`'T'`, `'F'` or `'P'`)
  - `SPM.xCon.c`    - Contrast weights (column vector contrasts)
  - `SPM.xCon.X0`   - Reduced design matrix data (spans design space under Ho)

    - Stored as coordinates in the orthogonal basis of xX.X from spm_sp    (Matrix in SPM99b)
    - Extract using X0 `spm_FcUtil('X0', ...`

  - `SPM.xCon.iX0` - Indicates how contrast was specified:

    - If by columns for reduced design matrix then iX0 contains the column indices.
    - Otherwise, it's a string containing the `spm_FcUtil` 'Set' action:
      Usually one of `{'c','c+','X0'}` defines the indices of the columns that will not be tested. Can be empty.

  - `SPM.xCon.X1o` - Remaining design space data (X1o is orthogonal to X0)

    - Stored as coordinates in the orthogonal basis of xX.X from `spm_sp` (Matrix in SPM99b)
    - Extract using X1o `spm_FcUtil('X1o', ...`

  - `SPM.xCon.eidf` - Effective interest degrees of freedom (numerator df)

    - Or effect-size threshold for Posterior probability

  - `SPM.xCon.Vcon` - Name of contrast (for 'T's) or ESS (for 'F's) image
  - `SPM.xCon.Vspm` - Name of SPM image

<a name="statistics:-how-can-change-the-name-of-the-folder-of-the-subject-level-analysis"></a>
## Statistics: How can change the name of the folder of the subject level analysis?

This can be done by changing the `Name` of the run level `Nodes`
in the BIDS stats model.

If your `Nodes.Name` is one of the "default" values:

- `"run"`
- `"run level"`
- `"run_level"`
- `"run-level"`
- ...

like in the example below

```json
  "Nodes": [
    {
      "Level": "Run",
      "Name": "run_level",
    ...
```

then {func}`src.stats.subject_level.getFFXdir.m` will set the subject level folder to be named as follow:

```text
sub-subLabel
└── task-taskLabel_space-spaceLabel_FWHM-FWHMValue
```

However if your `Nodes.Name` is not one of the "default" values, like this

```json
  "Nodes": [
    {
      "Level": "Run",
      "Name": "parametric",
    ...
```

then the subject level folder to be named as follow:

```text
sub-subLabel
└── task-taskLabel_space-spaceLabel_FWHM-FWHMValue_node-parametric
```

<a name="statistics:-how-should-i-structure-my-data-to-run-my-statistical-analysis"></a>
## Statistics: How should I structure my data to run my statistical analysis?

The main thing to remember is that bidspm will read the events.tsv files from
your raw BIDS data set and will read the bold images from a `bidspm-preproc`
folder.

If your data was preprocessed with fmriprep, bidspm will first need to copy,
unzip and smooth the data into a `bidspm-preproc` folder

Here is an example of how the data is organized for the MoAE fmriprep demo and
what the `bidspm` BIDS call would look like.

```bash
├── inputs
│   ├── fmriprep                     # fmriprep preprocessed BIDS dataset
│   |   ├── dataset_description.json
│   │   └── sub-01
│   │       ├── anat
│   │       ├── figures
│   │       └── func
│   │           ├── sub-01_task-auditory_desc-confounds_timeseries.json
│   │           ├── sub-01_task-auditory_desc-confounds_timeseries.tsv
│   │           ├── sub-01_task-auditory_space-MNI152NLin6Asym_desc-brain_mask.json
│   │           ├── sub-01_task-auditory_space-MNI152NLin6Asym_desc-brain_mask.nii.gz
│   │           ├── sub-01_task-auditory_space-MNI152NLin6Asym_desc-preproc_bold.json
│   │           └── sub-01_task-auditory_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz
│   └── raw                          # raw BIDS dataset
│       ├── dataset_description.json
│       ├── README
│       ├── sub-01
│       │   ├── anat
│       │   │   └── sub-01_T1w.nii
│       │   └── func
│       │       ├── sub-01_task-auditory_bold.nii
│       │       └── sub-01_task-auditory_events.tsv
│       └── task-auditory_bold.json
├── models                            # models used to run the GLM
│   ├── model-MoAEfmriprep_smdl.json
│   ├── model-MoAEindividual_smdl.json
│   └── model-MoAE_smdl.json
├── options
└── outputs
    └── derivatives
        └── bidspm-preproc          # contains data taken from fmriprep and smoothed
            ├── dataset_description.json
            ├── README
            ├── jobs
            │   └── auditory
            │       └── sub-01
            └── sub-01
                ├── anat
                └── func
                    ├── sub-01_task-auditory_desc-confounds_timeseries.json
                    ├── sub-01_task-auditory_desc-confounds_timeseries.tsv
                    ├── sub-01_task-auditory_space-MNI152NLin6Asym_desc-brain_mask.json
                    ├── sub-01_task-auditory_space-MNI152NLin6Asym_desc-brain_mask.nii
                    ├── sub-01_task-auditory_space-MNI152NLin6Asym_desc-preproc_bold.json
                    ├── sub-01_task-auditory_space-MNI152NLin6Asym_desc-preproc_bold.nii
                    ├── sub-01_task-auditory_space-MNI152NLin6Asym_desc-smth8_bold.json
                    └── sub-01_task-auditory_space-MNI152NLin6Asym_desc-smth8_bold.nii
```

```matlab
WD = fileparts(mfilename('fullpath'));

subject_label = '01';

bids_dir = fullfile(WD, 'inputs', 'raw');
output_dir = fullfile(WD, 'outputs', 'derivatives');
preproc_dir = fullfile(output_dir, 'bidspm-preproc');

model_file = fullfile(pwd, 'models', 'model-MoAEfmriprep_smdl.json');

bidspm(bids_dir, output_dir, 'subject', ...
        'participant_label', {subject_label}, ...
        'action', 'stats', ...
        'preproc_dir', preproc_dir, ...
        'model_file', model_file, ...
        'fwhm', 8, ...
        'options', opt);
```

<hr>

Generated by [FAQtory](https://github.com/willmcgugan/faqtory)
