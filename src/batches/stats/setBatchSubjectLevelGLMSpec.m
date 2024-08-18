function matlabbatch = setBatchSubjectLevelGLMSpec(varargin)
  %
  % Sets up the subject level GLM
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subLabel)
  %
  % :param matlabbatch:
  % :type  matlabbatch: structure
  %
  % :param BIDS: dataset layout.
  %              See: bids.layout, getData.
  %
  % :type  BIDS: structure
  %
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  % :type  opt: structure
  %
  % :param subLabel:
  % :type subLabel: char
  %
  % :return: matlabbatch
  % :rtype: structure
  %
  %

  % (C) Copyright 2019 bidspm developers
  [matlabbatch, BIDS, opt, subLabel] =  deal(varargin{:});

  if ~isfield(BIDS, 'raw')
    msg = sprintf(['Provide raw BIDS dataset path in opt.dir.raw .\n' ...
                   'It is needed to load events.tsv files.\n']);

    logger('ERROR', msg, 'filename', mfilename(), 'id', 'missingRawDir');
  end

  bm = opt.model.bm;

  printBatchName('specify subject level fmri model', opt);

  %% Specify GLM aspects that are the same across runs
  fmri_spec = struct('volt', 1, ...
                     'global', 'None');

  sliceOrder = returnSliceOrder(BIDS, opt, subLabel);

  filter = fileFilterForBold(opt, subLabel);
  TR = getAndCheckRepetitionTime(BIDS, filter);

  fmri_spec.timing.units = 'secs';
  fmri_spec.timing.RT = TR;

  % unique is used in case data was acquired multiband
  nbTimeBins = numel(unique(sliceOrder));
  fmri_spec.timing.fmri_t = nbTimeBins;

  % If no reference slice is given for STC,
  % then STC took the mid-volume as reference time point for the GLM.
  % When no STC was done, this is usually a good way to do it too.
  if isempty(opt.stc.referenceSlice)
    refBin = nbTimeBins / 2;
  else
    refBin = opt.stc.referenceSlice / TR;
  end
  refBin = floor(refBin);
  fmri_spec.timing.fmri_t0 = refBin;

  % Create ffxDir if it does not exist
  % If it exists, issue a warning that it has been overwritten
  ffxDir = getFFXdir(subLabel, opt);
  if ~opt.glm.roibased.do
    overwriteDir(ffxDir, opt);
  else
    if exist(fullfile(ffxDir, 'SPM.mat'), 'file')
      delete(fullfile(ffxDir, 'SPM.mat'));
    else
      spm_mkdir(ffxDir);
    end
  end

  msg = sprintf(' output dir:\n\t%s', bids.internal.format_path(ffxDir));
  logger('INFO', msg, 'options', opt, 'filename', mfilename());

  fmri_spec.dir = {ffxDir};

  fmri_spec.fact = struct('name', {}, 'levels', {});

  fmri_spec.mthresh = bm.getInclusiveMaskThreshold();

  fmri_spec.bases.hrf.derivs = bm.getHRFderivatives();

  fmri_spec.cvi = bm.getSerialCorrelationCorrection();

  %% List scans, onsets, confounds for each task / session / run
  subLabel = regexify(subLabel);

  [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');

  spmSess = struct('scans', '', 'onsetsFile', '', 'counfoundMatFile', '');
  spmSessCounter = 1;

  opt_for_query = opt;

  for iTask = 1:numel(opt.taskName)

    opt_for_query.query.task = opt_for_query.taskName{iTask};

    for iSes = 1:nbSessions

      [runs, nbRuns] = getInfo(BIDS, subLabel, opt_for_query, 'Runs', sessions{iSes});

      for iRun = 1:nbRuns

        if ~strcmp(runs{iRun}, '')
          msg = sprintf(' Processing run %s', runs{iRun});
          logger('INFO', msg, 'options', opt, 'filename', mfilename());
        end

        spmSess(spmSessCounter).scans = getBoldFilenameForFFX(BIDS, ...
                                                              opt_for_query, ...
                                                              subLabel, ...
                                                              iSes, ...
                                                              iRun);

        runDuration = getRunDuration(opt, spmSess(spmSessCounter).scans, TR);

        spec = struct('sub', subLabel, ...
                      'ses', sessions{iSes}, ...
                      'task', opt.taskName{iTask}, ...
                      'run', runs{iRun});
        onsetFilename = returnOnsetsFile(BIDS, opt, ...
                                         spec, ...
                                         runDuration);
        spmSess(spmSessCounter).onsetsFile = onsetFilename;

        % get confounds
        confoundsRegFile = getConfoundsRegressorFilename(BIDS, ...
                                                         opt_for_query, ...
                                                         subLabel, ...
                                                         sessions{iSes}, ...
                                                         runs{iRun});
        spmSess(spmSessCounter).counfoundMatFile = '';
        if ~isempty(confoundsRegFile)
          spmSess(spmSessCounter).counfoundMatFile = ...
           createAndReturnCounfoundMatFile(opt, confoundsRegFile);
        end

        spmSessCounter = spmSessCounter + 1;

      end
    end
  end

  % When doing model comparison
  % all runs must have same number of confound regressors
  % so we pad them with zeros if necessary
  spmSess = orderAndPadCounfoundMatFile(spmSess, opt);

  %% Add scans, onsets, confounds to the model specification batch
  for iSpmSess = 1:(spmSessCounter - 1)

    fmri_spec = setScans(opt, spmSess(iSpmSess).scans, fmri_spec, iSpmSess);

    fmri_spec.sess(iSpmSess).multi = cellstr(spmSess(iSpmSess).onsetsFile);

    fmri_spec.sess(iSpmSess).multi_reg = cellstr(spmSess(iSpmSess).counfoundMatFile);

    % multiregressor selection
    fmri_spec.sess(iSpmSess).regress = struct('name', {}, 'val', {});

    % multicondition selection
    fmri_spec.sess(iSpmSess).cond = struct('name', {}, 'onset', {}, 'duration', {});

    fmri_spec.sess(iSpmSess).hpf = bm.getHighPassFilter();

  end

  %%  convert mat files to tsv for quicker inspection and interoperability
  for iSpmSess = 1:(spmSessCounter - 1)
    if ~isempty(spmSess(iSpmSess).onsetsFile)
      onsetsMatToTsv(spmSess(iSpmSess).onsetsFile);
    end
    if ~isempty(spmSess(iSpmSess).counfoundMatFile)
      regressorsMatToTsv(spmSess(iSpmSess).counfoundMatFile);
    end
  end

  if opt.model.designOnly
    matlabbatch{end + 1}.spm.stats.fmri_design = fmri_spec;

  else
    node = bm.get_root_node();

    fmri_spec.mask = {getInclusiveMask(opt, node.Name, BIDS, subLabel)};
    matlabbatch{end + 1}.spm.stats.fmri_spec = fmri_spec;

  end

end

function sliceOrder = returnSliceOrder(BIDS, opt, subLabel)

  filter = fileFilterForBold(opt, subLabel);

  [name, version] = generatedBy(BIDS);
  tokens = strsplit(version, '.');
  % TODO implement differently for fmriprep >=20.2.4
  % https://fmriprep.org/en/stable/changes.html#october-04-2021
  skip = opt.stc.skip || ...
        (strcmp(name, 'fMRIPrep') && ...
         (str2num(tokens{1}) > 20 || ...
          str2num(tokens{1}) == 20 && str2num(tokens{2}) >= 4));  %#ok<*ST2NM>

  sliceOrder = [];
  if ~skip
    % Get slice timing information.
    % Necessary to make sure that the reference slice used for slice time
    % correction is the one we center our model on;

    % temporary silence warnings and only throw a single warning
    % after that if necessary
    oldVerbosity = opt.verbosity;
    opt.verbosity = 0;

    sliceOrder = getAndCheckSliceOrder(BIDS, opt, filter);

    opt.verbosity = oldVerbosity;
  end

  if isempty(sliceOrder) && ~opt.dryRun

    fileName = bids.query(BIDS, 'data', filter);
    hdr = spm_vol(fileName{1});

    % TODO we are assuming axial acquisition here
    sliceOrder = 1:hdr(1).dim(3);

    msg = ['\n\n', ...
           'Slice timing information was missing for at least one run,\n', ...
           'or was inconsistent across runs.', ...
           '\n', ...
           'Will be using the number of slices as the number of bins\n', ...
           'for temporal upsampling before convolution.', ...
           '\n', ...
           'If your data was processed with fMRIprep < 20.2.4, this is expected.\n'];
    % note that with multiband
    % this may lead to more time bins that used in reality at acquisition

    id = 'noSliceTimingInfoForGlm';
    logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);

  end

end

function runDuration = getRunDuration(opt, fullpathBoldFilename, TR)

  nvVols = getNbVols(opt, fullpathBoldFilename);
  runDuration = nvVols * TR;

end

function nbVols = getNbVols(opt, fullpathBoldFilename)
  if opt.glm.maxNbVols == Inf && isempty(opt.funcVolToSelect)
    try
      hdr = spm_vol(fullpathBoldFilename);
      nbVols = numel(hdr);
    catch
      nbVols = nan;
    end
    return
  end

  if opt.glm.maxNbVols ~= Inf
    nbVols = opt.glm.maxNbVols;
    return
  end

  if ~isempty(opt.funcVolToSelect)
    nbVols = numel(opt.funcVolToSelect);
    return
  end
  error('WTF');
end

function fmriSpec = setScans(opt, fullpathBoldFilename, fmriSpec, spmSessCounter)

  if opt.model.designOnly

    nbVols = getNbVols(opt, fullpathBoldFilename);
    if isnan(nbVols)
      warning('Could not open %s.\nExpected during testing.', fullpathBoldFilename);
      % TODO a value should be passed by user for this
      % hard coded value for test
      nbVols = 200;
    end

    fmriSpec.sess(spmSessCounter).nscan = nbVols;

  else

    fmriSpec.sess(spmSessCounter).scans = returnVolumeList(opt, fullpathBoldFilename);

  end

end

function onsetFilename = returnOnsetsFile(BIDS, opt, spec, runDuration)

  % get events file from raw data set and convert it to a onsets.mat file
  % store in the subject level GLM directory
  filter = fileFilterForBold(opt, spec.sub, 'events');
  filter.ses = spec.ses;
  filter.run = spec.run;
  filter.task = spec.task;

  tsvFile = bids.query(BIDS.raw, 'data', filter);

  % remove some entities in case the file is in the root of the dataset
  if isempty(tsvFile)
    fieldsToRemove = {'run', 'modality', 'ses', 'sub'};
    for i = 1:numel(fieldsToRemove)
      filter = rmfield(filter, fieldsToRemove{i});
      tsvFile = bids.query(BIDS.raw, 'data', filter);
      if ~isempty(tsvFile)
        assert(numel(tsvFile) == 1);
        break
      end
    end
  end

  if isempty(tsvFile)

    msg = sprintf('No events.tsv file found in:\n\t%s\nfor filter:%s\n', ...
                  BIDS.raw.pth, ...
                  bids.internal.create_unordered_list(filter));
    id = 'emptyInput';
    logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);

    onsetFilename = '';

    return
  end

  onsetFilename = createAndReturnOnsetFile(opt, ...
                                           spec.sub, ...
                                           tsvFile, ...
                                           runDuration);
end
