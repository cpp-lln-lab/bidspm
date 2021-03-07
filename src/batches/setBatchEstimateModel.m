% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchEstimateModel(matlabbatch, opt, grpLvlCon)
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

    case 2

      printBatchName('estimate subject level fmri model');

      spmMatFile = cfg_dep( ...
                           'fMRI model specification SPM file', ...
                           substruct( ...
                                     '.', 'val', '{}', {1}, ...
                                     '.', 'val', '{}', {1}, ...
                                     '.', 'val', '{}', {1}), ...
                           substruct('.', 'spmmat'));

      matlabbatch = returnEstimateModelBatch(matlabbatch, spmMatFile, opt);

    case 3

      printBatchName('estimate group level fmri model');

      for j = 1:size(grpLvlCon, 1)

        conName = rmTrialTypeStr(grpLvlCon{j});

        spmMatFile = { fullfile(opt.rfxDir, conName, 'SPM.mat') };

        % no QA at the group level GLM:
        %   since there is no autocorrelation to check for
        opt.glmQA.do = false();

        matlabbatch = returnEstimateModelBatch(matlabbatch, spmMatFile, opt);

      end

  end

end

function matlabbatch = returnEstimateModelBatch(matlabbatch, spmMatFile, opt)

  matlabbatch{end + 1}.spm.stats.fmri_est.method.Classical = 1;
  matlabbatch{end}.spm.stats.fmri_est.spmmat = spmMatFile;

  writeResiduals = true();
  if ~opt.glmQA.do
    writeResiduals = false();
  end
  matlabbatch{end}.spm.stats.fmri_est.write_residuals = writeResiduals;

end
