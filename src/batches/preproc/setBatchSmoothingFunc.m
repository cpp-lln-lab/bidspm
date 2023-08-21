function matlabbatch = setBatchSmoothingFunc(matlabbatch, BIDS, opt, subLabel)
  %
  % Creates a batch to smooth the bold files of a subject
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
  %             See checkOptions.
  % :type  opt: structure
  %
  % :param subLabel: subject label
  % :type  subLabel: char
  %
  % :returns: - :matlabbatch: (structure)
  %
  %
  % See also: bidsSmoothing, setBatchSmoothing
  %

  % (C) Copyright 2019 bidspm developers

  printBatchName('smoothing functional images', opt);

  desc = 'preproc';
  if isfield(opt.query, 'desc') && ~isempty(opt.query.desc)
    desc = opt.query.desc;
  end
  opt.query.desc = desc;
  opt.query.space = opt.space;
  opt = mniToIxi(opt);

  % identify sessions for this subject
  [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');

  allFiles = [];

  for iSes = 1:nbSessions

    [runs, nbRuns] = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

    for iRun = 1:nbRuns

      [fileName, subFuncDataDir] = getBoldFilename(BIDS, ...
                                                   subLabel, ...
                                                   sessions{iSes}, ...
                                                   runs{iRun}, ...
                                                   opt);
      if isempty(fileName)
        continue
      end

      for iFile = 1:size(fileName, 1)
        files{iFile, 1} = validationInputFile(subFuncDataDir(iFile, :), ...
                                              fileName(iFile, :)); %#ok<*AGROW>
      end

      % add the files to list
      allFilesTemp = cellstr(char(files));
      allFiles = [allFiles; allFilesTemp];

    end
  end

  % Prefix = s+funcFWHM
  matlabbatch = setBatchSmoothing(matlabbatch, ...
                                  opt, ...
                                  allFiles, ...
                                  opt.fwhm.func, ...
                                  [spm_get_defaults('smooth.prefix'), ...
                                   num2str(opt.fwhm.func)]);

end
