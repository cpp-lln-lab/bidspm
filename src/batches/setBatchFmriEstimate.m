% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchFmriEstimate(matlabbatch)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchFmriEstimate(matlabbatch)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  %
  % :returns: - :matlabbatch: (structure)
  %

  printBatchName('estimate subject level fmri model');

  matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep( ...
                                                        'fMRI model specification SPM file', ...
                                                        substruct( ...
                                                                  '.', 'val', '{}', {1}, ...
                                                                  '.', 'val', '{}', {1}, ...
                                                                  '.', 'val', '{}', {1}), ...
                                                        substruct('.', 'spmmat'));

  matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
  matlabbatch{2}.spm.stats.fmri_est.write_residuals = 1;

end
