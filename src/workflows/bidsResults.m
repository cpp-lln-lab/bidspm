% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function bidsResults(opt, funcFWHM, conFWHM)
  %
  % Computes the results for a series of contrast that can be
  % specified at the run, subject or dataset step level (see contrast specification
  % following the BIDS stats model specification).
  %
  % USAGE::
  %
  %  bidsResults([opt], funcFWHM, conFWHM)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  % :param funcFWHM: How much smoothing was applied to the functional
  %                  data in the preprocessing (Gaussian kernel size).
  % :type funcFWHM: scalar
  % :param conFWHM: How much smoothing will be applied to the contrast
  %                 images (Gaussian kernel size).
  % :type conFWHM: scalar
  %

  [~, opt] = setUpWorkflow(opt, 'computing GLM results');

  matlabbatch = [];

  % TOD0
  % if it does not exist create the default "result" field from the BIDS model file

  % loop trough the steps and more results to compute for each contrast
  % mentioned for each step
  for iStep = 1:length(opt.result.Steps)

    % Depending on the level step we migh have to define a matlabbatch
    % for each subject or just on for the whole group
    switch opt.result.Steps(iStep).Level

      case 'run'
        warning('run level not implemented yet');

        % saveMatlabBatch(matlabbatch, 'computeFfxResults', opt, subID);

      case 'subject'

        % For each subject
        for iSub = 1:numel(opt.subjects)

          subLabel = opt.subjects{iSub};

          for iCon = 1:length(opt.result.Steps(iStep).Contrasts)

            matlabbatch = ...
                setBatchSubjectLevelResults( ...
                                            matlabbatch, ...
                                            opt, ...
                                            subLabel, ...
                                            funcFWHM, ...
                                            iStep, ...
                                            iCon);

          end

        end

        batchName = sprintf('compute_sub-%s_results', subLabel);

        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

      case 'dataset'

        results.dir = getRFXdir(opt, funcFWHM, conFWHM);
        results.contrastNb = 1;
        results.label = 'group level';

        load(fullfile(results.dir, 'SPM.mat'));
        results.nbSubj = SPM.nscan;

        for iCon = 1:length(opt.result.Steps(iStep).Contrasts)

          matlabbatch = setBatchResults(matlabbatch, opt, iStep, iCon, results);

        end

        batchName = 'compute_group_level_results';

        saveAndRunWorkflow(matlabbatch, batchName, opt);

      otherwise

        error('This BIDS model does not contain an analysis step I understand.');

    end

  end

  % move ps file
  % TODO

  % rename NIDM file
  % TODO

end
