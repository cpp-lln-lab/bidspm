% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchFmriEstimate(matlabbatch)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
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
