function matlabbatch = setBatchSmoothingFunc(matlabbatch, BIDS, opt, subLabel)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSmoothingFunc(matlabbatch, BIDS, opt, subLabel)
  %
  % :param matlabbatch:
  % :type  matlabbatch: structure
  %
  % :type  BIDS: structure
  % :param BIDS: dataset layout.
  %              See also: bids.layout, getData.
  %
  % :param opt: Options chosen for the analysis.
  %             See also: ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type  opt: structure
  %
  % :param subLabel:
  % :type  subLabel:
  %
  % :returns: - :matlabbatch: (structure)
  %
  %
  % See also: bidsSmoothing, setBatchSmoothing
  %
  % (C) Copyright 2019 CPP_SPM developers

  printBatchName('smoothing functional images', opt);

  opt.query.desc = 'preproc';
  opt.query.space = opt.space;
  opt = mniToIxi(opt);

  % identify sessions for this subject
  [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');

  allFiles = [];

  for iSes = 1:nbSessions

    [runs, nbRuns] = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

    for iRun = 1:nbRuns

      [fileName, subFuncDataDir] = getBoldFilename( ...
                                                   BIDS, ...
                                                   subLabel, sessions{iSes}, runs{iRun}, opt);

      % TODO remove this extra check
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
