% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function matlabbatch = setBatchCreateVDMs(opt, BIDS, subID)

  % TODO
  % assumes all the fieldmap relate to the current task
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
      % Move to getInfo ?
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

      [echotimes, totReadTime, blipDir, isEPI] = getFmapMetadata(BIDS, ...
                                                                 subID, ...
                                                                 sessions{iSes}, ...
                                                                 runs{iRun});

      %                                                                totReadTime = 2;

      matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.et = echotimes;
      matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.tert = totReadTime;
      matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.blipdir = blipDir;
      matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.epifm = isEPI;

    end

  end

end

function varargout = getFmapMetadata(BIDS, subID, sessionID, runID)

  metadata = spm_BIDS(BIDS, 'metadata', ...
                      'modality', 'fmap', ...
                      'sub', subID, ...
                      'ses', sessionID, ...
                      'run', runID);

  % func run metadata: if the fmap is applied to several
  % runs we take the metadata of the first run it must
  % applied to
  if numel(metadata) > 1
    metadata = metadata{1};
  end

  echotimes = getEchoTimes(metadata);

  totalReadoutTime = getTotalReadoutTime(metadata);

  blipDir = getBlipDirection(metadata);

  isEPI = getFmapPulseSequenceType(metadata);

  varargout{1} = echotimes;
  varargout{2} = totalReadoutTime;
  varargout{3} = blipDir;
  varargout{4} = isEPI;

end

function echotimes = getEchoTimes(metadata)

  echotimes =  1000 * [ ...
                       metadata.EchoTime1, ...
                       metadata.EchoTime2]; % in milliseconds

end

function isEPI = getFmapPulseSequenceType(metadata)

  isEPI = 0;

  if isfield(metadata, 'PulseSequenceType') && ...
     sum(strfind(metadata.PulseSequenceType, 'EPI')) ~= 0

    isEPI = 1;
  end

end
