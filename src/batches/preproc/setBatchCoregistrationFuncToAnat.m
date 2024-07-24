function matlabbatch = setBatchCoregistrationFuncToAnat(matlabbatch, BIDS, opt, subLabel)
  %
  % Set the batch for coregistering the functional images
  % to the anatomical image.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchCoregistrationFuncToAnat(matlabbatch, BIDS, subLabel, opt)
  %
  % :param matlabbatch: list of SPM batches
  % :type  matlabbatch: structure
  %
  % :param BIDS: dataset layout.
  %              See: bids.layout, getData
  %
  % :type  BIDS: structure
  %
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  %
  % :type  opt: structure
  %
  % :param subLabel: subject label
  % :type  subLabel: char
  %
  % :return: matlabbatch, The matlabbatch ready to run the spm job
  % :rtype: structure
  %

  % (C) Copyright 2020 bidspm developers

  if opt.anatOnly
    return
  end

  printBatchName('coregister functional data to anatomical', opt);

  matlabbatch{end + 1}.spm.spatial.coreg.estimate.ref(1) = ...
   cfg_dep('Named File Selector: Anatomical(1) - Files', ...
           returnDependency(opt, 'selectAnat'), ...
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
              returnDependency(opt, 'realign'), ...
              substruct('.', meanImageToUse));

  % OTHER IMAGES : DEPENDENCY FROM REALIGNEMENT

  opt.query = opt.bidsFilterFile.bold;

  [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');

  runCounter = 1;

  for iSes = 1:nbSessions

    % get all runs for that subject for this session
    [~, nbRuns] = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

    for iRun = 1:nbRuns

      matlabbatch{end}.spm.spatial.coreg.estimate.other(runCounter) = ...
          cfg_dep([ ...
                   'Realign: Estimate & Reslice/Unwarp: Realigned Images (Sess ', ...
                   num2str(runCounter), ...
                   ')'], ...
                  returnDependency(opt, 'realign'), ...
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
