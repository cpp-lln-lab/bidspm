% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function matlabbatch = setBatchCreateVDMs(opt, BIDS, subID)

  % TODO
  % assumes all the fieldmap relate to the current task
  % - use the "for" metadata field
  % - implement for 'phase12', 'fieldmap', 'epi'

  fprintf(1, ' FIELDMAP WORKFLOW: CREATING VDMs \n');

  [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

  runs = getInfo(BIDS, subID, opt, 'Runs', sessions{1});
  [fileName, subFuncDataDir] = getBoldFilename(BIDS, subID, sessions{1}, runs{1}, opt);
  refImage = validationInputFile(subFuncDataDir, fileName, 'mean_');

  matlabbatch = [];
  for iSes = 1:nbSessions

    runs = spm_BIDS(BIDS, 'runs', ...
                    'modality', 'fmap', ...
                    'sub', subID, ...
                    'ses', sessions{iSes});

    for iRun = 1:numel(runs)

      matlabbatch = setBatchComputeVDM(matlabbatch, 'phasediff', refImage);

      % TODO
      % - Move to getInfo
      fmapFiles = spm_BIDS(BIDS, 'data', ...
                           'modality', 'fmap', ...
                           'sub', subID, ...
                           'ses', sessions{iSes}, ...
                           'run', runs{iRun});

      phaseImage = fmapFiles{1};
      matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.phase = ...
          {phaseImage};

      magnitudeImage = strrep(phaseImage, 'phasediff', 'magnitude1');
      matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.magnitude = ...
          {magnitudeImage};

      metadata = spm_BIDS(BIDS, 'metadata', ...
                          'modality', 'fmap', ...
                          'sub', subID, ...
                          'ses', sessions{iSes}, ...
                          'run', runs{iRun});

      echotimes =  1000 * [ ...
                           metadata.EchoTime1, ...
                           metadata.EchoTime2]; % in milliseconds
      matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.et = echotimes;

      totalReadoutTime = getTotalReadoutTime(opt, BIDS, subID);
      matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.tert = totalReadoutTime;

    end

  end

end

function totalReadoutTime = getTotalReadoutTime(opt, BIDS, subID)

  metadata = spm_BIDS(BIDS, 'metadata', ...
                      'type', 'bold', ...
                      'sub', subID, ...
                      'task', opt.taskName);

  % func run metadata: if the fmap is applied to several
  % runs we take the metadata of the first run it must
  % applied to
  if numel(metadata) > 1
    metadata = metadata{1};
  end

  if isfield(metadata, 'TotalReadoutTime')
    totalReadoutTime = metadata.TotalReadoutTime;

  elseif isfield(metadata, 'RepetitionTime')
    totalReadoutTime = metadata.RepetitionTime;

  elseif isfield(metadata, 'EffectiveEchoSpacing')
    totalReadoutTime = (metadata.NumberOfEchos - 1) * ...
        metadata.EffectiveEchoSpacing;
  end

end
