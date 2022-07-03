function matlabbatch = setBatchEstimateModel(matlabbatch, opt, nodeName, contrastsList, groups)
  %
  % Set up the estimate model batch for run/subject or group level GLM
  %
  % USAGE::
  %
  %   matlabbatch = setBatchEstimateModel(matlabbatch, opt)
  %   matlabbatch = setBatchEstimateModel(matlabbatch, opt, nodeName, contrastsList, groups)
  %
  % :param matlabbatch:
  % :type  matlabbatch: structure
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See  also: checkOptions
  %
  % :param nodeName:
  % :type  nodeName: char
  %
  % :param contrastsList:
  % :type  contrastsList: cell string
  %
  %
  % :returns: - :matlabbatch: (structure)
  %
  % (C) Copyright 2019 CPP_SPM developers

  switch nargin

    % run  / subject level
    case 2

      printBatchName('estimate subject level fmri model', opt);

      spmMatFile = cfg_dep('fMRI model specification SPM file', ...
                           substruct( ...
                                     '.', 'val', '{}', {1}, ...
                                     '.', 'val', '{}', {1}, ...
                                     '.', 'val', '{}', {1}), ...
                           substruct('.', 'spmmat'));

      matlabbatch = returnEstimateModelBatch(matlabbatch, spmMatFile, opt);

      % group level
    case 5

      if ischar(contrastsList)
        contrastsList = cellstr(contrastsList);
      end

      if ischar(groups)
        groups = cellstr(groups);
      end

      assert(numel(contrastsList) == numel(groups));

      printBatchName('estimate group level fmri model', opt);

      for j = 1:size(contrastsList)

        rfxDir = getRFXdir(opt, nodeName, contrastsList{j}, groups{j});
        spmMatFile = { fullfile(rfxDir, 'SPM.mat') };

        assert(exist(spmMatFile{1}, 'file') == 0);

        % no QA at the group level GLM:
        %   since there is no autocorrelation to check for
        opt.QA.glm.do = false();

        matlabbatch = returnEstimateModelBatch(matlabbatch, spmMatFile, opt);

        matlabbatch{end + 1}.spm.stats.review.spmmat = spmMatFile;
        matlabbatch{end}.spm.stats.review.display.matrix = 1;
        matlabbatch{end}.spm.stats.review.print = false;

        matlabbatch = setBatchPrintFigure(matlabbatch, opt, ...
                                          fullfile(spm_fileparts(spmMatFile{1}), ...
                                                   designMatrixFigureName(opt, ...
                                                                          'after estimation')));
      end

    otherwise

      error('Should have 2 or 5 inputs...');

  end

end

function matlabbatch = returnEstimateModelBatch(matlabbatch, spmMatFile, opt)

  matlabbatch{end + 1}.spm.stats.fmri_est.method.Classical = 1;
  matlabbatch{end}.spm.stats.fmri_est.spmmat = spmMatFile;

  writeResiduals = false();
  if opt.glm.keepResiduals || opt.QA.glm.do
    writeResiduals = true();
  end
  matlabbatch{end}.spm.stats.fmri_est.write_residuals = writeResiduals;

end
