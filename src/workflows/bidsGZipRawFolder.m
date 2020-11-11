% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function bidsGZipRawFolder(opt, deleteUnzippedNii, modalitiesToZip)

  %
  % GZip the nii files in a ``raw`` bids folders from the. It will do it independently of the task.
  %
  % USAGE::
  %
  %   bidsGZipRawFolder([opt,] ...
  %                     [deleteUnzippedNii = true,] ...
  %                     [modalitiesToZip = {'anat', 'func', 'fmap'}])
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  % :param deleteUnzippedNii: will delete the original ``.nii`` if set to ``true``
  % :type deleteUnzippedNii: boolean
  % :param modalitiesToZip:
  % :type modalitiesToZip: cell
  
  %% input variables default values

  if nargin < 3 || isempty(modalitiesToZip)
    % Will only copy those modalities if they exist
    modalitiesToZip = {'anat', 'func', 'fmap'};
  end

  if nargin < 2 || isempty(deleteUnzippedNii)
    % delete the original zipped nii.gz
    deleteUnzippedNii = true;
  end

  % if input has no opt, load the opt.mat file
  if nargin < 1 || isempty(opt)
    opt = [];
  end
  opt = loadAndCheckOptions(opt);

  cleanCrash();

  printWorklowName('GZip data');
  
  rawDir = opt.dataDir;

  unzippedNiifiles = spm_select('FPListRec', rawDir, '^.*.nii$');
  
  
  
