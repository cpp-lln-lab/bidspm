function bidsFFX(action, opt, funcFWHM)
  %
  % - builds the subject level fMRI model and estimates it.
  %
  % OR
  %
  % - compute the contrasts at the subject level.
  %
  % USAGE::
  %
  %  bidsFFX(action, funcFWHM, [opt])
  %
  % :param action: Action to be conducted:``specifyAndEstimate`` or ``contrasts``.
  % :type action: string
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  % :param funcFWHM: How much smoothing was applied to the functional
  %                  data in the preprocessing (Gaussian kernel size).
  % :type funcFWHM: scalar
  %
  % - ``specifyAndEstimate`` for fMRI design + estimate and
  % - ``contrasts`` to estimate contrasts.
  %
  % For unsmoothed data ``funcFWHM = 0``, for smoothed data ``funcFWHM = ... mm``.
  % In this way we can make multiple ffx for different smoothing degrees.
  %
  % (C) Copyright 2020 CPP_SPM developers

  if opt.glm.roibased.do
    message = sprintf( ...
                      ['The option opt.glm.roibased.do is set to true.\n', ...
                       ' Change the option to false to use this workflow or\n', ...
                       ' use the bidsRoiBasedGLM workflow to run roi based GLM.']);
    error(message);
  end

  [BIDS, opt] = setUpWorkflow(opt, 'subject level GLM');

  opt.jobsDir = fullfile(opt.dir.stats, 'JOBS', opt.taskName);

  if isempty(opt.model.file)
    opt = createDefaultModel(BIDS, opt);
  end

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel);

    matlabbatch = [];

    switch action

      case 'specifyAndEstimate'

        matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel, funcFWHM);

        p = struct( ...
                   'type', 'designmatrix', ...
                   'ext', '.png', ...
                   'sub', subLabel, ...
                   'task', opt.taskName, ...
                   'space', opt.space, ...
                   'desc', 'before estimation');

        matlabbatch = setBatchPrintFigure(matlabbatch, fullfile(getFFXdir(subLabel, ...
                                                                          funcFWHM, ...
                                                                          opt), ...
                                                                createFilename(p)));

        matlabbatch = setBatchEstimateModel(matlabbatch, opt);

        p.desc = 'after estimation';
        matlabbatch = setBatchPrintFigure(matlabbatch, fullfile(getFFXdir(subLabel, ...
                                                                          funcFWHM, ...
                                                                          opt), ...
                                                                createFilename(p)));

        batchName = ...
            ['specify_estimate_ffx_task-', opt.taskName, ...
             '_space-', opt.space, ...
             '_FWHM-', num2str(funcFWHM)];

        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        if opt.QA.glm.do
          plot_power_spectra_of_GLM_residuals( ...
                                              getFFXdir(subLabel, funcFWHM, opt), ...
                                              opt.metadata.RepetitionTime);

          deleteResidualImages(getFFXdir(subLabel, funcFWHM, opt));

        end

      case 'contrasts'

        matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subLabel, funcFWHM);

        batchName = ...
            ['contrasts_ffx_task-', opt.taskName, ...
             '_space-', opt.space, ...
             '_FWHM-', num2str(funcFWHM)];

        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

    end

  end

end
