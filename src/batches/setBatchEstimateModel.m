% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchEstimateModel(matlabbatch, grpLvlCon)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchEstimateModel(matlabbatch, grpLvlCon)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param grpLvlCon:
  % :type grpLvlCon:
  %
  % :returns: - :matlabbatch: (structure)
  %

  switch nargin

    case 1

      printBatchName('estimate subject level fmri model');

      spmMatFile = cfg_dep( ...
                           'fMRI model specification SPM file', ...
                           substruct( ...
                                     '.', 'val', '{}', {1}, ...
                                     '.', 'val', '{}', {1}, ...
                                     '.', 'val', '{}', {1}), ...
                           substruct('.', 'spmmat'));

      matlabbatch = returnEstimateModelBatch(matlabbatch, spmMatFile);

    case 2

      printBatchName('estimate group level fmri model');

      for j = 1:size(grpLvlCon, 1)

        conName = rmTrialTypeStr(grpLvlCon{j});

        spmMatFile = { fullfile(rfxDir, conName, 'SPM.mat') };

        matlabbatch = returnEstimateModelBatch(matlabbatch, spmMatFile);

      end

  end

end

function matlabbatch = returnEstimateModelBatch(matlabbatch, spmMatFile)

  matlabbatch{end + 1}.spm.stats.fmri_est.method.Classical = 1;
  matlabbatch{end}.spm.stats.fmri_est.write_residuals = 1;
  matlabbatch{end}.spm.stats.fmri_est.spmmat = spmMatFile;

end
