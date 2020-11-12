% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function bidsGZipRawFolder(optSource, keepUnzippedNii)

  %
  % GZip the nii files in a ``raw`` bids folders from the. It will do it independently of the task.
  %
  % USAGE::
  %
  %   bidsGZipRawFolder([opt,] ...
  %                     [deleteUnzippedNii = true,] ...
  %                     [modalitiesToZip = {'anat', 'func', 'fmap'}])
  %
  % :param optSource: The structure that contains the options set by the user to run the batch
  %                   workflow for source processing
  % :type opt: structure
  % :param keepUnzippedNii: will keep the original ``.nii`` if set to ``true``. Default is false
  % :type keepUnzippedNii: boolean

  %% input variables default values
  
  optSource.dataDir = '/Users/barilari/Desktop/data_temp/raw_temp';

  if nargin < 2 || isempty(deleteUnzippedNii)
    % delete the original unzipped .nii
    keepUnzippedNii = false;
  end

  tic;
  
  printWorklowName('GZip data');
  
  rawDir = optSource.dataDir;

  unzippedNiifiles = cellstr(spm_select('FPListRec', rawDir, '^.*.nii$'));
  
  matlabbatch = setBatchGZip(unzippedNiifiles, keepUnzippedNii);

  spm_jobman('run', matlabbatch);
  
  toc;

