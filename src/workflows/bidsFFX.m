% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function bidsFFX(action, opt, funcFWHM)
  % This scripts builds up the design matrix for each subject.
  % It has to be run in 2 separate steps (action). ::
  %
  %  bidsFFX(action, funcFWHM, opt)
  %
  % :param action: (string) ``specifyAndEstimate`` or ``contrasts``.
  % :param opt: (scalar) options (see checkOptions())
  % :param funcFWHM: (scalar) Gaussian kernel size applied to the functional data.
  %
  % ``specifyAndEstimate`` for fMRI design + estimate and
  % ``contrasts`` to estimate contrasts.
  %
  % For unsmoothed data  ``funcFWHM = 0``, for smoothed data ``funcFWHM = ... mm``.
  % In this way we can make multiple ffx for different smoothing degrees
  %

  % if input has no opt, load the opt.mat file
  if nargin < 3
    opt = [];
  end
  
  [BIDS, opt, group] = setUpWorkflow(opt, 'subject level GLM');

  %% Loop through the groups, subjects, and sessions
  for iGroup = 1:length(group)

    groupName = group(iGroup).name;

    for iSub = 1:group(iGroup).numSub

      subID = group(iGroup).subNumber{iSub};

      printProcessingSubject(groupName, iSub, subID);

      switch action

        case 'specifyAndEstimate'

          matlabbatch = setBatchSubjectLevelGLMSpec( ...
                                                    BIDS, opt, subID, funcFWHM);

          matlabbatch = setBatchFmriEstimate(matlabbatch);

          batchName = ...
            ['specify_estimate_ffx_task-', opt.taskName, ...
                           '_space-', opt.space, ...
                           '_FWHM-', num2str(funcFWHM)];

        case 'contrasts'

          matlabbatch = setBatchSubjectLevelContrasts(opt, subID, funcFWHM);

          batchName = ...
                          ['contrasts_ffx_task-', opt.taskName, ...
                           '_space-', opt.space, ...
                           '_FWHM-', num2str(funcFWHM)];

      end
      
      saveAndRunWorkflow(matlabbatch, batchName, opt, subID);

    end
    
  end

end
