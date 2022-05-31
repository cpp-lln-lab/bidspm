function matlabbatch = setBatchEstimateModel(matlabbatch, opt, nodeName, contrastsList)
  %
  % Set up the estimate model batch for run/subject or group level GLM
  %
  % USAGE::
  %
  %   matlabbatch = setBatchEstimateModel(matlabbatch, opt)
  %   matlabbatch = setBatchEstimateModel(matlabbatch, opt, nodeName, contrastsList)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  %
  % :param opt:
  % :type opt: structure
  %
  % :param nodeName:
  % :type nodeName: char
  %
  % :param contrastsList:
  % :type contrastsList: cell string
  %
  %
  % :returns: - :matlabbatch: (structure)
  %
  % (C) Copyright 2019 CPP_SPM developers

  switch nargin

    % run  / subject level
    case 2

      printBatchName('estimate subject level fmri model', opt);

      spmMatFile = cfg_dep( ...
                           'fMRI model specification SPM file', ...
                           substruct( ...
                                     '.', 'val', '{}', {1}, ...
                                     '.', 'val', '{}', {1}, ...
                                     '.', 'val', '{}', {1}), ...
                           substruct('.', 'spmmat'));

      matlabbatch = returnEstimateModelBatch(matlabbatch, spmMatFile, opt);

      % group level
    case 4

      if ischar(contrastsList)
        contrastsList = cellstr(contrastsList);
      end

      printBatchName('estimate group level fmri model', opt);

      for j = 1:size(contrastsList)

        spmMatFile = { fullfile(getRFXdir(opt, nodeName, contrastsList{j}), 'SPM.mat') };

        % no QA at the group level GLM:
        %   since there is no autocorrelation to check for
        opt.QA.glm.do = false();

        matlabbatch = returnEstimateModelBatch(matlabbatch, spmMatFile, opt);

        matlabbatch = setBatchPrintFigure(matlabbatch, opt, ...
                                          fullfile(spm_fileparts(spmMatFile{1}), ...
                                                   designMatrixFigureName(opt, ...
                                                                          'after estimation')));
      end

  end

end

function matlabbatch = returnEstimateModelBatch(matlabbatch, spmMatFile, opt)

  matlabbatch{end + 1}.spm.stats.fmri_est.method.Classical = 1;
  matlabbatch{end}.spm.stats.fmri_est.spmmat = spmMatFile;

  writeResiduals = true();
  if ~opt.QA.glm.do || ~opt.glm.keepResiduals
    writeResiduals = false();
  end
  matlabbatch{end}.spm.stats.fmri_est.write_residuals = writeResiduals;

end
