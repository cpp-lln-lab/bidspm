function matlabbatch = setBatchSubjectLevelGLMSpec(varargin)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param BIDS:
  % :type BIDS: structure
  % :param opt:
  % :type opt: structure
  % :param subLabel:
  % :type subLabel: string
  %
  % :returns: - :argout1: (structure) (matlabbatch)
  %
  % (C) Copyright 2019 CPP_SPM developers

  [matlabbatch, BIDS, opt, subLabel] =  deal(varargin{:});

  printBatchName('specify subject level fmri model', opt);

  % Check the slice timing information is not in the metadata and not added
  % manually in the opt variable.
  % Necessary to make sure that the reference slice used for slice time
  % correction is the one we center our model on
  sliceOrder = getSliceOrder(opt);

  if isempty(sliceOrder) && ~opt.dryRun
    % no slice order defined here so we fall back on using the number of
    % slice in the first bold image to set the number of time bins
    % we will use to upsample our model during regression creation
    fileName = bids.query(BIDS, 'data', ...
                          'sub', subLabel, ...
                          'suffix', 'bold', ...
                          'extension', '.nii');
    hdr = spm_vol(fileName{1});
    % we are assuming axial acquisition here
    sliceOrder = 1:hdr(1).dim(3);
  end

  matlabbatch{end + 1}.spm.stats.fmri_spec.timing.units = 'secs';

  % get TR from metadata
  TR = opt.metadata.RepetitionTime;
  matlabbatch{end}.spm.stats.fmri_spec.timing.RT = TR;

  % number of times bins
  nbTimeBins = numel(unique(sliceOrder));
  matlabbatch{end}.spm.stats.fmri_spec.timing.fmri_t = nbTimeBins;

  % If no reference slice is given for STC, then STC took the mid-volume
  % time point to do the correction.
  % When no STC was done, this is usually a good way to do it too.
  if isempty(opt.stc.referenceSlice)
    refBin = floor(nbTimeBins / 2);
  else
    refBin = opt.stc.referenceSlice / opt.metadata.RepetitionTime;
  end
  matlabbatch{end}.spm.stats.fmri_spec.timing.fmri_t0 = refBin;

  % Create ffxDir if it doesnt exist
  % If it exists, issue a warning that it has been overwritten
  ffxDir = getFFXdir(subLabel, opt);
  if exist(ffxDir, 'dir') %
    msg = sprintf('overwriting directory: %s \n', ffxDir);
    errorHandling(mfilename(), 'overWritingDir', msg, true, opt.verbosity);
    rmdir(ffxDir, 's');
    spm_mkdir(ffxDir);
  end
  matlabbatch{end}.spm.stats.fmri_spec.dir = {ffxDir};

  matlabbatch{end}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});

  matlabbatch{end}.spm.stats.fmri_spec.bases.hrf.derivs = opt.model.hrfDerivatives;

  matlabbatch{end}.spm.stats.fmri_spec.volt = 1;

  matlabbatch{end}.spm.stats.fmri_spec.global = 'None';

  matlabbatch{end}.spm.stats.fmri_spec.mask = {''};

  % The following lines are commented out because those parameters
  % can be set in the spm_my_defaults.m
  %                 matlabbatch{end}.spm.stats.fmri_spec.cvi = 'AR(1)';

  % identify sessions for this subject
  [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');

  sesCounter = 1;
  for iSes = 1:nbSessions

    % get all runs for that subject across all sessions
    [runs, nbRuns] = ...
        getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

    for iRun = 1:nbRuns

      % get functional files
      fullpathBoldFileName = getBoldFilenameForFFX(BIDS, opt, subLabel, iSes, iRun);

      printToScreen(sprintf('%s\n', fullpathBoldFileName), opt);

      matlabbatch{end}.spm.stats.fmri_spec.sess(sesCounter).scans = ...
          {fullpathBoldFileName};

      % get stimuli onset time file
      query = struct( ...
                     'sub',  subLabel, ...
                     'task', opt.taskName, ...
                     'ses', sessions{iSes}, ...
                     'run', runs{iRun}, ...
                     'suffix', 'events', ...
                     'extension', '.tsv');
      tsvFile = bids.query(BIDS, 'data', query);
      fullpathOnsetFileName = createAndReturnOnsetFile(opt, ...
                                                       subLabel, ...
                                                       tsvFile);

      matlabbatch{end}.spm.stats.fmri_spec.sess(sesCounter).multi = ...
          cellstr(fullpathOnsetFileName);

      % get confounds
      matlabbatch{end}.spm.stats.fmri_spec.sess(sesCounter).multi_reg = {''};
      confoundsRegFile = getConfoundsRegressorFilename(BIDS, ...
                                                       opt, ...
                                                       subLabel, ...
                                                       sessions{iSes}, ...
                                                       runs{iRun});
      if ~isempty(confoundsRegFile)
        counfoundMatFile = createAndReturnCounfoundMatFile(opt, subLabel, confoundsRegFile);
        matlabbatch{end}.spm.stats.fmri_spec.sess(sesCounter).multi_reg = ...
            cellstr(counfoundMatFile);
      end

      % multiregressor selection
      matlabbatch{end}.spm.stats.fmri_spec.sess(sesCounter).regress = ...
          struct('name', {}, 'val', {});

      % multicondition selection
      matlabbatch{end}.spm.stats.fmri_spec.sess(sesCounter).cond = ...
          struct('name', {}, 'onset', {}, 'duration', {});

      % The following lines are commented out because those parameters
      % can be set in the spm_my_defaults.m
      %  matlabbatch{end}.spm.stats.fmri_spec.sess(ses_counter).hpf = 128;

      sesCounter = sesCounter + 1;

    end
  end

end
