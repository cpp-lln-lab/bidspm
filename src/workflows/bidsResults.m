% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

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
  %             ``checkOptions`` and ``loadAndCheckOptions``.
  % :type opt: structure
  % :param funcFWHM: How much smoothing was applied to the functional
  %                  data in the preprocessing.
  % :type funcFWHM: scalar
  % :param conFWHM: How much smoothing will be applied to the contrast
  %                 images.
  % :type conFWHM: scalar
  %

  if nargin < 1
    opt = [];
  end
  
  [~, opt, group] = setUpWorkflow(opt, 'computing GLM results');

  matlabbatch = [];

  % loop trough the steps and more results to compute for each contrast
  % mentioned for each step
  for iStep = 1:length(opt.result.Steps)

    for iCon = 1:length(opt.result.Steps(iStep).Contrasts)

      % Depending on the level step we migh have to define a matlabbatch
      % for each subject or just on for the whole group
      switch opt.result.Steps(iStep).Level

        case 'run'
          warning('run level not implemented yet');

          % saveMatlabBatch(matlabbatch, 'computeFfxResults', opt, subID);

        case 'subject'

          matlabbatch = ...
              setBatchSubjectLevelResults( ...
                                          matlabbatch, ...
                                          group, ...
                                          funcFWHM, ...
                                          opt, ...
                                          iStep, ...
                                          iCon);

          % TODO
          % Save this batch in for each subject and not once for all

          batchName = 'compute_subject_level_results';

        case 'dataset'

          rfxDir = getRFXdir(opt, funcFWHM, conFWHM, contrastName);

          load(fullfile(rfxDir, 'SPM.mat'));

          results.dir = rfxDir;
          results.contrastNb = 1;
          results.label = 'group level';
          results.nbSubj = SPM.nscan;

          matlabbatch = setBatchResults(matlabbatch, opt, iStep, iCon, results);

          batchName = 'compute_group_level_results';

      end
    end

  end
  
  saveAndRunWorkflow(matlabbatch, batchName, opt);

  % move ps file
  % TODO

  % rename NIDM file
  % TODO

end


