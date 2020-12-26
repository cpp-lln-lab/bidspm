% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSubjectLevelGLMSpec(varargin)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSubjectLevelGLMSpec(matlabbatch, BIDS, opt, subID, funcFWHM)
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param argin2: Options chosen for the analysis. See ``checkOptions()``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %

  [matlabbatch, BIDS, opt, subID, funcFWHM] =  deal(varargin{:});

  printBatchName('specify subject level fmri model');

  % Check the slice timing information is not in the metadata and not added
  % manually in the opt variable.
  % Necessary to make sure that the reference slice used for slice time
  % correction is the one we center our model on
  sliceOrder = getSliceOrder(opt, 0);

  if isempty(sliceOrder)
    % no slice order defined here so we fall back on using the number of
    % slice in the first bold imageBIDS, opt, subID, funcFWHM, iSes, iRun
    % to set the number of time bins we will use to upsample our model
    % during regression creation
    fileName = bids.query(BIDS, 'data', ...
                          'sub', subID, ...
                          'type', 'bold');
    fileName = strrep(fileName{1}, '.gz', '');
    hdr = spm_vol(fileName);
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

  refBin = floor(nbTimeBins / 2);
  matlabbatch{end}.spm.stats.fmri_spec.timing.fmri_t0 = refBin;

  % Create ffxDir if it doesnt exist
  % If it exists, issue a warning that it has been overwritten
  ffxDir = getFFXdir(subID, funcFWHM, opt);
  if exist(ffxDir, 'dir') %
    warning('overwriting directory: %s \n', ffxDir);
    rmdir(ffxDir, 's');
    mkdir(ffxDir);
  end
  matlabbatch{end}.spm.stats.fmri_spec.dir = {ffxDir};

  matlabbatch{end}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});

  matlabbatch{end}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];

  matlabbatch{end}.spm.stats.fmri_spec.volt = 1;

  matlabbatch{end}.spm.stats.fmri_spec.global = 'None';

  matlabbatch{end}.spm.stats.fmri_spec.mask = {''};

  % The following lines are commented out because those parameters
  % can be set in the spm_my_defaults.m
  %                 matlabbatch{end}.spm.stats.fmri_spec.cvi = 'AR(1)';

  % identify sessions for this subject
  [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

  sesCounter = 1;
  for iSes = 1:nbSessions

    % get all runs for that subject across all sessions
    [runs, nbRuns] = ...
        getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

    for iRun = 1:nbRuns

      % get functional files
      [fullpathBoldFileName, prefix]  = ...
          getBoldFilenameForFFX(BIDS, opt, subID, funcFWHM, iSes, iRun);

      disp(fullpathBoldFileName);

      matlabbatch{end}.spm.stats.fmri_spec.sess(sesCounter).scans = ...
          {fullpathBoldFileName};

      % get stimuli onset time file
      tsvFile = getInfo(BIDS, subID, opt, 'filename', ...
                        sessions{iSes}, ...
                        runs{iRun}, ...
                        'events');
      fullpathOnsetFileName = createAndReturnOnsetFile(opt, ...
                                                       subID, ...
                                                       tsvFile, ...
                                                       funcFWHM);

      matlabbatch{end}.spm.stats.fmri_spec.sess(sesCounter).multi = ...
          cellstr(fullpathOnsetFileName);

      % get realignment parameters
      realignParamFile = getRealignParamFile(fullpathBoldFileName, prefix);
      matlabbatch{end}.spm.stats.fmri_spec.sess(sesCounter).multi_reg = ...
          cellstr(realignParamFile);

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
