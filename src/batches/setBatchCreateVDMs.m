function matlabbatch = setBatchCreateVDMs(matlabbatch, BIDS, opt, subLabel)
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

  printBatchName('create voxel displacement map', opt);

  [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');

  runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{1});
  [fileName, subFuncDataDir] = getBoldFilename(BIDS, subLabel, sessions{1}, runs{1}, opt);
  refImage = validationInputFile(subFuncDataDir, fileName, 'mean_');

  for iSes = 1:nbSessions

    filter = opt.query;
    filter.modality =  'fmap';
    filter.sub =  subLabel;
    filter.ses =  sessions{iSes};

    runs = bids.query(BIDS, 'runs', filter);

    for iRun = 1:numel(runs)

      filter.run = runs{iRun};
      filter.suffix = 'phasediff';

      metadata = bids.query(BIDS, 'metadata', filter);

      if strfind(metadata.IntendedFor, opt.taskName)

        matlabbatch = setBatchComputeVDM(matlabbatch, 'phasediff', refImage);

        % TODO
        % Move to getInfo ?
        matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.phase = ...
            bids.query(BIDS, 'data', filter);

        [echotimes, isEPI, totReadTime, blipDir] = getMetadataForVDM(BIDS, filter);

        filter.suffix = 'magnitude1';
        matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.magnitude = ...
            bids.query(BIDS, 'data', filter);

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

function varargout = getMetadataForVDM(BIDS, filter)

  % get metadata fmap and its associated func files
  fmapMetadata = bids.query(BIDS, 'metadata', filter);

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
