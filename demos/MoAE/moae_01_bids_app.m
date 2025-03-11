% # MoAE demo
%
% This script shows how to use the bidspm BIDS app
%
% - **Download**
%
%   -  download the dataset from the FIL for the block design SPM tutorial
%
% - **Preprocessing**
%
%   - copies the necessary data from the raw to the derivative folder,
%   - runs spatial preprocessing
%
%   those are otherwise handled by the workflows:
%
%   - :func:`bidsCopyInputFolder`
%   - :func:`bidsSpatialPrepro`
%
% - **Stats**
%
%   This will run the subject level GLM and contrasts on it of the MoaE dataset
%
%   - GLM specification + estimation
%   - compute contrasts
%   - show results
%
%   that are otherwise handled by the workflows
%
%   - :func:`bidsFFX`
%   - :func:`bidsResults`
%
% .. note::
%
%   Results might be a bit different from those in the SPM manual as some
%   default options are slightly different in this pipeline
%   (e.g use of FAST instead of AR(1), motion regressors added)
%
%
% type `bidspm help` or `bidspm('action', 'help')`
% or see this page: https://bidspm.readthedocs.io/en/stable/bids_app_api.html
% for more information on what parameters are obligatory or optional
%

%  (C) Copyright 2022 Remi Gau

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

% ## Initialize bidspm

this_dir = fileparts(mfilename('fullpath'));

addpath(fullfile(this_dir, '..', '..'));

bidspm();

% ## Download the dataset

download_data = true;
clean = false;
download_moae_ds(download_data, clean);

% If the `tree` command is installed on your computer, you view it:

system('tree inputs/raw');

% ## Preprocessing
%
% This will run:
%
% - copy the input dataset into a derivative one
% - write a summary description of the data set
% - do slice time correction (if not ignored and if slice timing is specified)
% - realign the functional data (and apply unwarping - if not ignored)
% - coregister the functional to the anatomical one
% - segmentation the anatomical data
% - skullstripping the anatomical data and creation of brain mask in native space
% - normalization to SPM MNI space (IXI549Space)
% - smooth the data

% You can type `bidspm help` to get more info
% on the arguments and parameters needed by the bidspm app.
%
% But it follows the general pattern of any bidsapp:
%
% ```matlab
% bidspm(bids_dir, output_dir, analysis_level, ...)
% ```

bidspm help;

% where the raw bids data is;
bids_dir = fullfile(this_dir, 'inputs', 'raw');

% where we want to output it;
% the data will be saved there in bidspm-preproc subfolder;
output_dir = fullfile(this_dir, 'outputs', 'derivatives');

% the subject we want to analyse;
subject_label = '01';

VERBOSITY = 3;

% bidspm(bids_dir, output_dir, 'subject', ...
%        'participant_label', {subject_label}, ...
%        'action', 'preprocess', ...
%        'task', 'auditory', ...
%        'ignore', {'unwarp', 'slicetiming'}, ...
%        'space', {'IXI549Space'}, ...
%        'fwhm', 6, ...
%        'verbosity', VERBOSITY);

% ## Stats

% for the stats we need to specify where the preprocessed data is;
preproc_dir = fullfile(output_dir, 'bidspm-preproc');

% ### BIDS stats model
%
% The model specification as well as the contrasts to compute
% are defined in a BIDS stats model:
% https://bids-standard.github.io/stats-models/

model_file = fullfile(pwd, 'models', 'model-MoAE_smdl.json');

system('cat models/model-MoAE_smdl.json');

% ### Specify the result to show
%
% Running bidspm for the stats will perform:
%
% - model specification and estimation
% - contrasts computation
% - displaying the results
%
% Hence we need to specify in the options which results
% we want to view and how we want to save it.
%
% The results of a given contrat can be saved as:
% - an png image
% - a SPM montage of slices
% - a thresholded statistical map
% - a binary mask
% - an NIDM results zip file
% - a table of labelled activations

bidspm(bids_dir, output_dir, 'subject', ...
       'participant_label', {subject_label}, ...
       'action', 'results', ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'space', {'IXI549Space'}, ...
       'concatenate', false, ...
       'fwhm', 6, ...
       'verbosity', VERBOSITY);
