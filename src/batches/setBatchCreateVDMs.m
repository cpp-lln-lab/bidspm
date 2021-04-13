function matlabbatch = setBatchCreateVDMs(matlabbatch, BIDS, opt, subID)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchCreateVDMs(matlabbatch, BIDS, opt, subID)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param BIDS: BIDS layout returned by ``getData``.
  % :type BIDS: structure
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  % :param subID: subject ID
  % :type subID: string
  %
  % :returns: - :matlabbatch: (structure) The matlabbatch ready to run the spm job
  %
  % TODO
  % - implement for 'phase12', 'fieldmap', 'epi'
  %
  % (C) Copyright 2020 CPP_SPM developers

  printBatchName('create voxel displacement map');

  [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

  runs = getInfo(BIDS, subID, opt, 'Runs', sessions{1});
  [fileName, subFuncDataDir] = getBoldFilename(BIDS, subID, sessions{1}, runs{1}, opt);
  refImage = validationInputFile(subFuncDataDir, fileName, 'mean_');

  for iSes = 1:nbSessions

    runs = bids.query(BIDS, 'runs', ...
                      'modality', 'fmap', ...
                      'sub', subID, ...
                      'ses', sessions{iSes});

    for iRun = 1:numel(runs)

      metadata = bids.query(BIDS, 'metadata', ...
                            'modality', 'fmap', ...
                            'sub', subID, ...
                            'ses', sessions{iSes}, ...
                            'run', runs{iRun});

      if strfind(metadata.IntendedFor, opt.taskName)

        matlabbatch = setBatchComputeVDM(matlabbatch, 'phasediff', refImage);

        % TODO
        % Move to getInfo ?
        fmapFiles = bids.query(BIDS, 'data', ...
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

        defaultsval = matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval;
        defaultsval.et = echotimes;
        defaultsval.tert = totReadTime;
        defaultsval.blipdir = blipDir;
        defaultsval.epifm = isEPI;
        matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval = defaultsval;

      end

    end

  end

end

function varargout = getMetadataForVDM(BIDS, subID, sessionID, runID)

  % get metadata fmap and its associated func files
  fmapMetadata = bids.query(BIDS, 'metadata', ...
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
