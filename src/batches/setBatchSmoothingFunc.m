function matlabbatch = setBatchSmoothingFunc(matlabbatch, BIDS, opt, subID)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSmoothingFunc(matlabbatch, BIDS, opt, subID)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param BIDS: BIDS layout returned by ``getData``.
  % :type BIDS: structure
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: string
  % :param subID:
  % :type subID:
  %
  % :returns: - :matlabbatch: (structure)
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  printBatchName('smoothing functional images', opt);

  % identify sessions for this subject
  [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

  allFiles = [];

  for iSes = 1:nbSessions

    [runs, nbRuns] = getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

    for iRun = 1:nbRuns

      opt.query.desc = 'preproc';
      opt.query.space = opt.space;
      if ismember('MNI', opt.query.space)
        idx = strcmp(opt.query.space, 'MNI');
        opt.query.space{idx} = 'IXI549Space';
      end
      [fileName, subFuncDataDir] = getBoldFilename( ...
                                                   BIDS, ...
                                                   subID, sessions{iSes}, runs{iRun}, opt);

      % check input file
      for iFile = 1:size(fileName, 1)
        files{iFile, 1} = validationInputFile(subFuncDataDir(iFile, :), fileName(iFile, :));
      end

      % add the files to list
      allFilesTemp = cellstr(char(files));
      allFiles = [allFiles; allFilesTemp]; %#ok<AGROW>

    end
  end

  % Prefix = s+funcFWHM
  matlabbatch = setBatchSmoothing(matlabbatch, ...
                                  opt, ...
                                  allFiles, ...
                                  opt.fwhm.func, ...
                                  [spm_get_defaults('smooth.prefix'), num2str(opt.fwhm.func)]);

end
