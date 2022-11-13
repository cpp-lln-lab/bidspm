% (C) Copyright 2022 Remi Gau

% # BIDS filenames
%
% Ideally we would like to have the same pipeline for statistical analysis
% whether our data was preprocessed with SPM or with fmriprep.
%
% ## BIDS filenames
%
% Ideally we would like to have the same pipeline for statistical analysis
% whether our data was preprocessed with SPM or with fmriprep (for example).
%
% This is possible under the condition that the input files
% for the statistical analysis are BIDS compliant:
% meaning that they follow the typical pattern of BIDS files:
%
% - pseudo "regular expression" : `entity-label(_entity-label)+_suffix.extension`
%
%
% - `entity`, `label`, `suffix`, `extension` are alphanumeric only (no special character): `()+`
%   - suffixes can be: `T1w` or `bold` but not `T1w_skullstripped` (no underscore allowed)
%
%
% - entity and label are separated by a dash:
%   `entity-label --> ()+-()+`
%   - you can have: `sub-01` but not `sub-01-blind`
%
%
% - entity-label pairs are separated by an underscore:
%   `entity-label(_entity-label)+ --> ()+-()+(_()+-()+)+`
%
%
% - **prefixes are not a thing in official BIDS names**
%
% BIDS has a number of (https://bids-specification.readthedocs.io/en/stable/99-appendices/04-entity-table.html)
% (`sub`, `ses`, `task`...) that must come in a specific order for each data type.
%
% BIDS derivatives adds a few more entities (`desc`, `space`, `res`...)
% and suffixes (`pseg`, `dseg`, `mask`...)
% that can be used to name and describe preprocessed data.

% The toolbox BIDS Matlab has some function to help you create bids valid names.

% ## Note: octave notebook
%
% If you are running in an octave notebook.
%
% ### Graphic output
%
% When using on Binder some of the SPM graphic output will not be generated,
% as SPM takes this environment as being command line only.
%
% ### Running the demo locally
%
% **If you are running this notebook locally AND if SPM is not the in Octave path**
%
% Run the following cell with the appropriate path for your computer.
%
% **Note:**
% SPM will need to be compiled to work for Octave
% for some parts of this demo to work.

% addpath('/home/remi/matlab/SPM/spm12');

this_dir = fileparts(mfilename('fullpath'));

addpath(fullfile(this_dir, '..', '..'));

bidspm();

file_spec = struct('entities', struct('run', '01', ...
                                      'sub', '01', ...
                                      'task', 'visMotionLocalizer'), ...
                   'suffix', 'bold', ...
                   'ext', '.nii');

bidsFile = bids.File(file_spec);
bidsFile.filename;

% If not enough information is provided, BIDS matlab should hopefully help you figure out what is missing.

file_spec = struct('entities', struct('run', '01', ...
                                      'sub', '01', ...
                                      'task', 'visMotionLocalizer'), ...
                   'suffix', 'events', ...
                   'ext', '.tsv');

bidsFile = bids.File(file_spec);
bidsFile.filename;

file_spec.modality = 'func';
bidsFile = bids.File(file_spec);
bidsFile.filename;

% Entities must have a specific order to be BIDS valid.
% You can ignore those rules by not using the bids schema.

file_spec = struct('entities', struct('run', '01', ...
                                      'sub', '01', ...
                                      'task', 'visMotionLocalizer'), ...
                   'suffix', 'bold', ...
                   'ext', '.nii', ...
                   'use_schema', false);

bidsFile = bids.File(file_spec);
bidsFile.filename;

% ## Typical SPM filenames
%
% SPM typically adds prefixes to filenames and concatenates them.
%
% - `r` for realigned or resliced
% - `w` for warped (often means normalized in MNI space)
% - `a` for slice time corrected images
% - `u` for unwarped
% - `s` for smoothed
% - `c1` for grey matter tissue probability maps
% - ...

% typical gray matter probabilistic segmentation;
file_spec = struct('entities', struct('sub', '01'), ...
                   'suffix', 'T1w', ...
                   'ext', '.nii', ...
                   'prefix', 'c1');

bidsFile = bids.File(file_spec);
bidsFile.filename;

% typical preprocessed data in native space;
file_spec = struct('entities', struct('run', '01', ...
                                      'sub', '01', ...
                                      'task', 'visMotionLocalizer'), ...
                   'suffix', 'bold', ...
                   'ext', '.nii', ...
                   'prefix', 'ua');

bidsFile = bids.File(file_spec);
bidsFile.filename;

% typical smoothed preprocessed data in MNI space;
file_spec = struct('entities', struct('run', '01', ...
                                      'sub', '01', ...
                                      'task', 'visMotionLocalizer'), ...
                   'suffix', 'bold', ...
                   'ext', '.nii', ...
                   'prefix', 'swua');

bidsFile = bids.File(file_spec);
bidsFile.filename;

% ## BIDS derivatives filenames
% But those SPM files are not BIDS valid because official valid BIDS files don't have prefixes.
%
% So SPM output must be renamed to be able to create BIDS valid output datasets.

% space: can specify if this image is in MNI space or individual space;
% desc: description can give more info about what is this file about:;
% "preproc" --> "preprocessed";
file_spec = struct('entities', struct('sub', '01', ...
                                      'run', '01', ...
                                      'task', 'visMotionLocalizer', ...
                                      'space', 'MNI', ...
                                      'desc', 'preproc'), ...
                   'suffix', 'bold', ...
                   'ext', '.nii');

bidsFile = bids.File(file_spec);
bidsFile.filename;

% It can be a pain to create the right map
% between a specific SPM type of output and "the right" BIDS equivalent.
%
% So easier to use (https://github.com/cpp-lln-lab/spm_2_bids)
% which will also try to use the "proper" MNI space name
% (`IXI594Sapce` is the one used by most of SPM).

input_name = 'wc1sub-01_T1w.nii';
output_name = spm_2_bids(input_name);

input_name = 'uasub-01_task-visMotionLocalizer_run-01_bold.nii';
output_name = spm_2_bids(input_name);

input_name = 'wuasub-01_task-visMotionLocalizer_run-01_bold.nii';
output_name = spm_2_bids(input_name);

% spm_2_bids contains a certain list of default mapping to use
% for renaming but you can also add some extra or modify the defaults.
%
% bidspm comes with its own preset `spm_2_bids` renaming map.

opt = checkOptions(struct());
opt = set_spm_2_bids_defaults(opt);

input_name = 'wc1sub-01_T1w.nii';
output_name = spm_2_bids(input_name, opt.spm_2_bids);

input_name = 'uasub-01_task-visMotionLocalizer_run-01_bold.nii';
output_name = spm_2_bids(input_name, opt.spm_2_bids);

input_name = 'wuasub-01_task-visMotionLocalizer_run-01_bold.nii';
output_name = spm_2_bids(input_name, opt.spm_2_bids);

opt.fwhm.func = 6;
input_name = 'swuasub-01_task-visMotionLocalizer_run-01_bold.nii';
output_name = spm_2_bids(input_name, opt.spm_2_bids);

% ### `bidsRename`
%
% The `bidsRename` workflow uses this to rename all "SPM files" at the end of each step.

demo_dir = fullfile(pwd, '..', 'MoAE');

opt.taskName = 'auditory';

opt.dir.derivatives = fullfile(demo_dir, 'outputs', 'derivatives');
opt.dir.preproc = fullfile(opt.dir.derivatives, 'bidspm-preproc');

opt = checkOptions(opt);

bidsRename(opt);

% Example of the end of spatial preprocessing
%
% ```matlab
%   if ~opt.realign.useUnwarp
%     opt.spm_2_bids = opt.spm_2_bids.add_mapping('prefix', opt.spm_2_bids.realign, ...
%                                                 'name_spec', opt.spm_2_bids.cfg.preproc);
%
%     opt.spm_2_bids = opt.spm_2_bids.add_mapping('prefix', , ...
%                                                 'name_spec', opt.spm_2_bids.cfg.preproc);
%     opt.spm_2_bids = opt.spm_2_bids.flatten_mapping();
%   end
%
%   bidsRename(opt);
% ```
