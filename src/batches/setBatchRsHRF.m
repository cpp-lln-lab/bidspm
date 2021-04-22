function matlabbatch = setBatchRsHRF(matlabbatch, BIDS, opt, subLabel)
  %
  % Set the batch for realign / realign and reslice / realign and unwarp
  %
  % USAGE::
  %
  %   matlabbatch = setBatchRsHRF(matlabbatch, BIDS, opt, subLabel)
  %
  % :param matlabbatch: SPM batch
  % :type matlabbatch: structure
  % :param BIDS: BIDS layout returned by ``getData``.
  % :type BIDS: structure
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :type subLabel: string
  % :param subLabel: subject label
  %
  % :returns: - :matlabbatch: (structure) (dimension)
  %
  % (C) Copyright 2020 CPP_SPM developers

  msg = 'estimate HRF';

  printBatchName(msg);

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
        maskImg = getInfo(BIDS, subLabel, opt, 'filename', sessions{iSes}, runs{iRun}, 'mask');
        metadata = getInfo(BIDS, subLabel, opt, 'metadata', sessions{iSes}, runs{iRun}, 'bold');
      end

      boldImg{runCounter, 1} = fullfile(subFuncDataDir, boldFilename);

    end
  end

  vox_rsHRF.images = boldImg;

  vox_rsHRF.Denoising.generic = cell(1, 0);
  vox_rsHRF.Denoising.Detrend = 0;
  vox_rsHRF.Denoising.BPF = {};
  vox_rsHRF.Denoising.Despiking = 0;
  vox_rsHRF.Denoising.which1st = 3;

  vox_rsHRF.HRFE.hrfm = 2;
  vox_rsHRF.HRFE.TR = metadata.RepetitionTime;
  vox_rsHRF.HRFE.hrflen = 32;
  vox_rsHRF.HRFE.num_basis = NaN;
  vox_rsHRF.HRFE.mdelay = [4 8];
  vox_rsHRF.HRFE.cvi = 0;
  vox_rsHRF.HRFE.fmri_t = 1;
  vox_rsHRF.HRFE.fmri_t0 = 1;
  vox_rsHRF.HRFE.thr = 1;
  vox_rsHRF.HRFE.localK = 2;
  vox_rsHRF.HRFE.tmask = NaN;
  vox_rsHRF.HRFE.hrfdeconv = 1;

  vox_rsHRF.rmoutlier = 0;

  vox_rsHRF.mask = {maskImg};

  vox_rsHRF.connectivity = cell(1, 0);

  vox_rsHRF.outdir = {outputDir};

  vox_rsHRF.savedata.deconv_save = 0;
  vox_rsHRF.savedata.hrfmat_save = 1;
  vox_rsHRF.savedata.hrfnii_save = 1;
  vox_rsHRF.savedata.job_save = 0;

  vox_rsHRF.prefix = 'deconv_';

  matlabbatch{end + 1}.spm.tools.rsHRF.vox_rsHRF = vox_rsHRF;

end
