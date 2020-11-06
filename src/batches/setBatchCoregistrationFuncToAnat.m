% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchCoregistrationFuncToAnat(matlabbatch, BIDS, subID, opt)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %
  
  printBatchName('coregister functional data to anatomical');

  matlabbatch{end + 1}.spm.spatial.coreg.estimate.ref(1) = ...
      cfg_dep('Named File Selector: Anatomical(1) - Files', ...
              substruct( ...
                        '.', 'val', '{}', {opt.orderBatches.selectAnat}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}), ...
              substruct('.', 'files', '{}', {1}));

  % SOURCE IMAGE : DEPENDENCY FROM REALIGNEMENT
  % Mean Image
  meanImageToUse = 'meanuwr';
  otherImageToUse = 'uwrfiles';
  if ~opt.realign.useUnwarp
    meanImageToUse = 'rmean';
    otherImageToUse = 'cfiles';
  end

  matlabbatch{end}.spm.spatial.coreg.estimate.source(1) = ...
      cfg_dep('Realign: Estimate & Reslice/Unwarp: Mean Image', ...
              substruct( ...
                        '.', 'val', '{}', {opt.orderBatches.realign}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}), ...
              substruct('.', meanImageToUse));

  % OTHER IMAGES : DEPENDENCY FROM REALIGNEMENT

  [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

  runCounter = 1;

  for iSes = 1:nbSessions

    % get all runs for that subject for this session
    [~, nbRuns] = getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

    for iRun = 1:nbRuns

      matlabbatch{end}.spm.spatial.coreg.estimate.other(runCounter) = ...
          cfg_dep([ ...
                   'Realign: Estimate & Reslice/Unwarp: Realigned Images (Sess ', ...
                   num2str(runCounter), ...
                   ')'], ...
                  substruct( ...
                            '.', 'val', '{}', {opt.orderBatches.realign}, ...
                            '.', 'val', '{}', {1}, ...
                            '.', 'val', '{}', {1}, ...
                            '.', 'val', '{}', {1}), ...
                  substruct( ...
                            '.', 'sess', '()', {runCounter}, ...
                            '.', otherImageToUse));

      runCounter = runCounter + 1;

    end

  end

  % The following lines are commented out because those parameters
  % can be set in the spm_my_defaults.m
  % matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
  % matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
  % matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.tol = ...
  % [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
  % matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

end
