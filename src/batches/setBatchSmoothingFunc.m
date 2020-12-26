% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSmoothingFunc(matlabbatch, BIDS, opt, subID, funcFWHM)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSmoothingFunc(matlabbatch, BIDS, opt, subID, funcFWHM)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param BIDS: BIDS layout returned by ``getData``.
  % :type BIDS: structure
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: string
  % :param subID:
  % :type subID:
  % :param funcFWHM:
  % :type funcFWHM:
  %
  % :returns: - :matlabbatch: (structure)
  %
  %

  printBatchName('smoothing functional images');

  prefix = getPrefix('smooth', opt);

  % identify sessions for this subject
  [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

  % clear previous matlabbatch and files
  allFiles = [];

  for iSes = 1:nbSessions        % For each session

    % get all runs for that subject across all sessions
    [runs, nbRuns] = getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

    % numRuns = group(iGroup).numRuns(iSub);
    for iRun = 1:nbRuns

      % get the filename for this bold run for this task
      [fileName, subFuncDataDir] = getBoldFilename( ...
                                                   BIDS, ...
                                                   subID, sessions{iSes}, runs{iRun}, opt);

      % check that the file with the right prefix exist
      files = validationInputFile(subFuncDataDir, fileName, prefix);

      % add the files to list
      allFilesTemp = cellstr(files);
      allFiles = [allFiles; allFilesTemp]; %#ok<AGROW>

    end
  end

  % Prefix = s+funcFWHM
  matlabbatch = setBatchSmoothing(matlabbatch, ...
                                  allFiles, ...
                                  funcFWHM, ...
                                  [spm_get_defaults('smooth.prefix'), num2str(funcFWHM)]);

end
