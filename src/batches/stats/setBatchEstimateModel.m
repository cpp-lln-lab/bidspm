function matlabbatch = setBatchEstimateModel(matlabbatch, opt, tmp, contrastsList, groups)
  %
  % Set up the estimate model batch for run/subject or group level GLM
  %
  % USAGE::
  %
  %   % for subject level
  %   matlabbatch = setBatchEstimateModel(matlabbatch, opt, subLabel)
  %
  %   % for group level
  %   matlabbatch = setBatchEstimateModel(matlabbatch, opt, nodeName, contrastsList, groups)
  %
  % :param matlabbatch:
  % :type  matlabbatch: structure
  %
  % :type  opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See checkOptions.
  %
  % :param nodeName:
  % :type  nodeName: char
  %
  % :param contrastsList:
  % :type  contrastsList: cell string
  %
  %
  % :return: :matlabbatch: (structure)
  %

  % (C) Copyright 2019 bidspm developers

  switch nargin

    % run  / subject level
    case 3

      subLabel = tmp;

      outputDir = getFFXdir(subLabel, opt);

      printBatchName('estimate subject level fmri model', opt);

      if iscell(matlabbatch)
        opt.orderBatches.specify = 1;

        spmMatFile = cfg_dep('fMRI model specification SPM file', ...
                             substruct('.', 'val', '{}', {opt.orderBatches.specify}, ...
                                       '.', 'val', '{}', {1}, ...
                                       '.', 'val', '{}', {1}), ...
                             substruct('.', 'spmmat'));

      elseif ischar(matlabbatch) && isdir(matlabbatch)
        spmMatFile = {fullfile(outputDir, 'SPM.mat')};
        matlabbatch = {};
      end

      matlabbatch = returnEstimateModelBatch(matlabbatch, spmMatFile, opt);

      opt.orderBatches.estimate = numel(matlabbatch);
      matlabbatch = setBatchGoodnessOfFit(matlabbatch, opt);

      matlabbatch = setBatchInformationCriteria(matlabbatch, opt, outputDir);

      % group level
    case 5

      nodeName = tmp;

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
        opt.orderBatches.estimate = numel(matlabbatch);
        matlabbatch = setBatchGoodnessOfFit(matlabbatch, opt);
        matlabbatch = setBatchInformationCriteria(matlabbatch, opt, rfxDir);

        matlabbatch{end + 1}.spm.stats.review.spmmat = spmMatFile; %#ok<*AGROW>
        matlabbatch{end}.spm.stats.review.display.matrix = 1;
        matlabbatch{end}.spm.stats.review.print = false;

        matlabbatch = setBatchPrintFigure(matlabbatch, opt, ...
                                          fullfile(spm_fileparts(spmMatFile{1}), ...
                                                   designMatrixFigureName(opt, ...
                                                                          'after estimation')));
      end

    otherwise

      error('Should have 3 or 5 inputs...');

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
