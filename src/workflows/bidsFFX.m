% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

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

  if nargin < 3
    opt = [];
  end

  [BIDS, opt, group] = setUpWorkflow(opt, 'subject level GLM');

  if isempty(opt.model.file)
    opt = createDefaultModel(BIDS, opt);
  end

  %% Loop through the groups, subjects, and sessions
  for iGroup = 1:length(group)

    groupName = group(iGroup).name;

    for iSub = 1:group(iGroup).numSub

      subID = group(iGroup).subNumber{iSub};

      printProcessingSubject(groupName, iSub, subID);

      matlabbatch = [];

      switch action

        case 'specifyAndEstimate'

          matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subID, funcFWHM);
          matlabbatch = setBatchPrintFigure(matlabbatch, [ ...
                                                          'sub-', subID, ...
                                                          '_task-', opt.taskName, ...
                                                          '_design_before_estimation']);
          matlabbatch = setBatchEstimateModel(matlabbatch);
          matlabbatch = setBatchPrintFigure(matlabbatch, [ ...
                                                          'sub-', subID, ...
                                                          '_task-', opt.taskName, ...
                                                          '_design_after_estimation']);

          batchName = ...
              ['specify_estimate_ffx_task-', opt.taskName, ...
               '_space-', opt.space, ...
               '_FWHM-', num2str(funcFWHM)];

          saveAndRunWorkflow(matlabbatch, batchName, opt, subID);

          plot_power_spectra_of_GLM_residuals( ...
                                              getFFXdir(subID, funcFWHM, opt), ...
                                              opt.metadata.RepetitionTime);

          deleteResidualImages(getFFXdir(subID, funcFWHM, opt));

          movefile(['sub-', subID, '_task-', opt.taskName, 'design_*'], ...
                   getFFXdir(subID, funcFWHM, opt));

        case 'contrasts'

          matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subID, funcFWHM);

          batchName = ...
              ['contrasts_ffx_task-', opt.taskName, ...
               '_space-', opt.space, ...
               '_FWHM-', num2str(funcFWHM)];

          saveAndRunWorkflow(matlabbatch, batchName, opt, subID);

      end

    end

  end

end
