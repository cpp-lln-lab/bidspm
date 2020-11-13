% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function bidsDefaceAnat(optSource)

  %
  % Deface any nii files in a ``raw/../anat`` bids folder.
  %
  % USAGE::
  %
  %   bidsDefaceAnat(optSource)
  %
  % :param optSource: The structure that contains the options set by the user to run the batch
  %                   workflow for source processing
  % :type opt: structure

  %% input variables default values

  optSource.dataDir = '/Users/barilari/Desktop/data_temp/raw_temp';
  
  rawDir = optSource.dataDir;
  
  spm_BIDS(rawDir,'nii')

  anatVolumesList = cellstr(spm_select('FPListRec', rawDir, '^.*.nii$'));
  
  matlabbatch = setBatchDeface(anatVolumesList);

  spm_jobman('run', matlabbatch);
  
  % DELETE THE OLD ANAT FILE
  
  % RENAME THE NEW DELETING THE DEAFULT PREFIX 'anon_*.nii'
  
end