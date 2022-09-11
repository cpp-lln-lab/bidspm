function matlabbatch = setBatchRsHRF(matlabbatch, BIDS, opt, subLabel)
  %
  % Set the batch for realign / realign and reslice / realign and unwarp
  %
  % USAGE::
  %
  %   matlabbatch = setBatchRsHRF(matlabbatch, BIDS, opt, subLabel)
  %
  % :param matlabbatch: SPM batch
  % :type  matlabbatch: structure
  %
  % :param BIDS: dataset layout.
  %              See also: bids.layout, getData.
  % :type  BIDS: structure
  %
  % :param opt: Options chosen for the analysis.
  %             See also: ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type  opt: structure
  %
  % :type  subLabel: char
  % :param subLabel: subject label
  %
  % :returns: - :matlabbatch: (structure) (dimension)
  %
  % (C) Copyright 2020 bidspm developers

  msg = 'estimate HRF';

  printBatchName(msg, opt);

  [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');

  runCounter = 1;

  for iSes = 1:nbSessions

    % get all runs for that subject across all sessions
    [runs, nbRuns] = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

    for iRun = 1:nbRuns

      [boldFilename, subFuncDataDir] = getBoldFilename( ...
                                                       BIDS, ...
                                                       subLabel, ...
                                                       sessions{iSes}, ...
                                                       runs{iRun}, ...
                                                       opt);

      if iSes == 1 && iRun == 1
        outputDir = subFuncDataDir;
        metadata = getInfo(BIDS, subLabel, opt, 'metadata', sessions{iSes}, runs{iRun}, 'bold');

        tmp = opt;
        tmp.query = rmfield(tmp.query, 'desc');
        maskImg = getInfo(BIDS, subLabel, tmp, 'filename', sessions{iSes}, runs{iRun}, 'mask');
        assert(not(isempty(maskImg)));
      end

      boldImg{runCounter, 1} = fullfile(subFuncDataDir, boldFilename);

    end
  end

  vox_rsHRF = opt.toolbox.rsHRF.vox_rsHRF;

  vox_rsHRF.images = boldImg;
  vox_rsHRF.HRFE.TR = metadata.RepetitionTime;
  vox_rsHRF.mask = {maskImg};
  vox_rsHRF.outdir = {outputDir};

  matlabbatch{end + 1}.spm.tools.rsHRF.vox_rsHRF = vox_rsHRF;

end
