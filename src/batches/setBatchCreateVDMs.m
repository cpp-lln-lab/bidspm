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

      [echotimes, isEPI, totReadTime, blipDir] = getMetadataForVDM(BIDS, ...
                                                                   subID, ...
                                                                   sessions{iSes}, ...
                                                                   runs{iRun});

      matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.et = echotimes;
      matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.tert = totReadTime;
      matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.blipdir = blipDir;
      matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.epifm = isEPI;

    end

  end

end

function varargout = getMetadataForVDM(BIDS, subID, sessionID, runID)

  % get metadata fmap and its associated func files
  fmapMetadata = spm_BIDS(BIDS, 'metadata', ...
                          'modality', 'fmap', ...
                          'sub', subID, ...
                          'ses', sessionID, ...
                          'run', runID);
  if numel(fmapMetadata) > 1
    fmapMetadata = fmapMetadata{1};
  end

  echotimes = getEchoTimes(fmapMetadata);

  isEPI = checkFmapPulseSequenceType(fmapMetadata);

  varargout{1} = echotimes;
  varargout{2} = isEPI;

  [totalReadoutTime, blipDir] = getMetadataFromIntendedForFunc(BIDS, fmapMetadata);

  varargout{3} = totalReadoutTime;
  varargout{4} = blipDir;

end

function echotimes = getEchoTimes(fmapMetadata)

  echotimes =  1000 * [ ...
                       fmapMetadata.EchoTime1, ...
                       fmapMetadata.EchoTime2]; % in milliseconds

end

function isEPI = checkFmapPulseSequenceType(fmapMetadata)

  isEPI = 0;

  if isfield(fmapMetadata, 'PulseSequenceType') && ...
     sum(strfind(fmapMetadata.PulseSequenceType, 'EPI')) ~= 0

    isEPI = 1;
  end

end

function [totalReadoutTime, blipDir] = getMetadataFromIntendedForFunc(BIDS, fmapMetadata)
  % get metadata of the associated bold file
  % find bold file this fmap is intended for, parse its filename and get its
  % metadata

  % At the moment the VDM is created based on the characteristics of the last
  % func file in the IntendedFor field

  % TODO
  % - if there are several func file for this fmap and they have different
  % characteristic this may require creating a VDM for each

  for  iFile = 1:size(fmapMetadata.IntendedFor)

    if iscell(fmapMetadata.IntendedFor)
      filename = fmapMetadata.IntendedFor{iFile};
    else
      filename = fmapMetadata.IntendedFor(iFile, :);
    end
    filename = spm_file(filename, 'filename');

    fragments = bids.internal.parse_filename(filename);

    funcMetadata = spm_BIDS(BIDS, 'metadata', ...
                            'modality', 'func', ...
                            'type', fragments.type, ...
                            'sub', fragments.sub, ...
                            'ses', fragments.ses, ...
                            'run', fragments.run, ...
                            'acq', fragments.acq);

  end

  totalReadoutTime = getTotalReadoutTime(funcMetadata);

  % temporary for designing
  %   totalReadoutTime = 63;

  if isempty(totalReadoutTime)
    errorStruct.identifier = 'getMetadataForVDM:emptyReadoutTime';
    errorStruct.message = [ ...
                           'Voxel displacement map creation requires a non empty value' ...
                           'for the TotalReadoutTime of the bold sequence they are matched to.'];
    error(errorStruct);
  end

  blipDir = getBlipDirection(funcMetadata);

end
