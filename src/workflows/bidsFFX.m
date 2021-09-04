function bidsFFX(action, opt)
  %
  % - builds the subject level fMRI model and estimates it.
  %
  % OR
  %
  % - compute the contrasts at the subject level.
  %
  % USAGE::
  %
  %  bidsFFX(action, [opt])
  %
  % :param action: Action to be conducted:``specifyAndEstimate`` or ``contrasts``.
  % :type action: string
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % - ``specifyAndEstimate`` for fMRI design + estimate and
  % - ``contrasts`` to estimate contrasts.
  %
  % (C) Copyright 2020 CPP_SPM developers

  % TODO: add a way to design model only with no data (see specific spm module
  % model only

  % TODO split model specification from model estimation

  if numel(opt.space) > 1
    disp(opt.space);
    msg = sprintf('GLMs can only be run in one space at a time.\n');
    errorHandling(mfilename(), 'tooManySpaces', msg, false, opt.verbosity);
  end

  if opt.glm.roibased.do
    msg = sprintf(['The option opt.glm.roibased.do is set to true.\n', ...
                   ' Change the option to false to use this workflow or\n', ...
                   ' use the bidsRoiBasedGLM workflow to run roi based GLM.']);
    errorHandling(mfilename(), 'roiGLMTrue', msg, false, opt.verbosity);
  end

  if ~ismember(action, {'specifyAndEstimate', 'contrasts'})
    msg = sprintf('action must be *specifyAndEstimate* or *contrasts*.\n%s was given.', action);
    errorHandling(mfilename(), 'unknownAction', msg, false, opt.verbosity);
  end

  opt.pipeline.type = 'stats';
  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'subject level GLM');

  if isempty(opt.model.file)
    opt = createDefaultModel(BIDS, opt);
  end

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = {};

    switch action

      case 'specifyAndEstimate'

        matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel);

        p = struct( ...
                   'suffix', 'designmatrix', ...
                   'ext', '.png', ...
                   'use_schema', false, ...
                   'entities', struct( ...
                                      'sub', subLabel, ...
                                      'task', opt.taskName, ...
                                      'space', opt.space, ...
                                      'desc', 'before estimation'));

        matlabbatch = setBatchPrintFigure(matlabbatch, opt, fullfile(getFFXdir(subLabel, opt), ...
                                                                     bids.create_filename(p)));

        matlabbatch = setBatchEstimateModel(matlabbatch, opt);

        p.entities.desc = 'after estimation';
        matlabbatch = setBatchPrintFigure(matlabbatch, opt, fullfile(getFFXdir(subLabel, opt), ...
                                                                     bids.create_filename(p)));

        batchName = ...
            ['specify_estimate_ffx_task-', opt.taskName, ...
             '_space-', char(opt.space), ...
             '_FWHM-', num2str(opt.fwhm.func)];

        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        if ~opt.dryRun && opt.QA.glm.do

          plot_power_spectra_of_GLM_residuals( ...
                                              getFFXdir(subLabel, opt), ...
                                              opt.metadata.RepetitionTime);

          deleteResidualImages(getFFXdir(subLabel, opt));

        end

      case 'contrasts'

        matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subLabel);

        batchName = ...
            ['contrasts_ffx_task-', opt.taskName, ...
             '_space-', char(opt.space), ...
             '_FWHM-', num2str(opt.fwhm.func)];

        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

    end

  end

end
