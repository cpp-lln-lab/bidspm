% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSmoothing(BIDS, opt, subID, funcFWHM)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param BIDS: BIDS layout returned by ``getData``.
  % :type BIDS: structure
  % :param argin2: Options chosen for the analysis. See ``checkOptions()``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %

  printBatchName('smoothing functional images');

  prefix = getPrefix('smooth', opt);

  % identify sessions for this subject
  [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

  % clear previous matlabbatch and files
  matlabbatch = [];
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

  matlabbatch{1}.spm.spatial.smooth.data =  allFiles;
  % Define the amount of smoothing required
  matlabbatch{1}.spm.spatial.smooth.fwhm = [funcFWHM funcFWHM funcFWHM];
  matlabbatch{1}.spm.spatial.smooth.dtype = 0;
  matlabbatch{1}.spm.spatial.smooth.im = 0;

  % Prefix = s+funcFWHM
  matlabbatch{1}.spm.spatial.smooth.prefix = ...
      [spm_get_defaults('smooth.prefix'), num2str(funcFWHM)];

end
