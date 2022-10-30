function matlabbatch = setBatchSmoothingAnat(matlabbatch, BIDS, opt, subLabel)
  %
  % Creates a batch to smooth the anat files of a subject
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSmoothingAnat(matlabbatch, BIDS, opt, subLabel)
  %
  % :param matlabbatch:
  % :type  matlabbatch: structure
  %
  % :type  BIDS: structure
  % :param BIDS: dataset layout.
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

  % (C) Copyright 2022 bidspm developers

  printBatchName('smoothing anat images', opt);

  opt.query.space = opt.space;
  opt = mniToIxi(opt);

  % identify sessions for this subject
  [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');

  allFiles = [];

  for iSes = 1:nbSessions

    [runs, nbRuns] = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

    for iRun = 1:nbRuns

      opt.bidsFilterFile.t1w.ses = sessions{iSes};
      opt.bidsFilterFile.t1w.run = runs{iRun};

      fieldsToTransfer = {'space', 'desc', 'label', 'res'};
      for i = 1:numel(fieldsToTransfer)
        field = fieldsToTransfer{i};
        if isfield(opt.query, field)
          opt.bidsFilterFile.t1w.(field) = opt.query.(field);
        end
      end

      tolerant = true;
      nbImgToReturn = Inf;
      [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel, nbImgToReturn, tolerant);

      if isempty(anatImage)
        break
      end

      anatImage = cellstr(anatImage);
      anatDataDir = cellstr(anatDataDir);

      for iFile = 1:numel(anatImage)
        files{iFile, 1} = validationInputFile(anatDataDir{iFile}, ...
                                              anatImage{iFile}); %#ok<*AGROW>
      end

      % add the files to list
      allFilesTemp = cellstr(char(files));
      allFiles = [allFiles; allFilesTemp];

    end
  end

  % Prefix = FWHM
  matlabbatch = setBatchSmoothing(matlabbatch, ...
                                  opt, ...
                                  allFiles, ...
                                  opt.fwhm.func, ...
                                  [spm_get_defaults('smooth.prefix'), num2str(opt.fwhm.func)]);

end
