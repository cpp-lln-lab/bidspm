function matlabbatch = setBatchCreateVDMs(matlabbatch, BIDS, opt, subLabel)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchCreateVDMs(matlabbatch, BIDS, opt, subLabel)
  %
  % :param matlabbatch:
  % :type  matlabbatch: structure
  %
  % :type  BIDS: structure
  % :param BIDS: dataset layout.
  %              See: bids.layout, getData.
  %
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  % :type  opt: structure
  %
  % :param subLabel: subject label
  % :type  subLabel: char
  %
  % :return: :matlabbatch: (structure) The matlabbatch ready to run the spm job
  %
  % TODO implement for 'phase12', 'fieldmap', 'epi'
  %

  % (C) Copyright 2020 bidspm developers

  printBatchName('create voxel displacement map', opt);

  [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');
  filter = opt.query;
  filter.sub = subLabel;
  filter.task =  opt.taskName;
  filter.suffix = 'bold';
  filter.prefix = 'mean_';
  refImage = bids.query(BIDS, 'data', filter);

  for iSes = 1:nbSessions

    filter = opt.query;
    filter.modality =  'fmap';
    filter.sub =  subLabel;
    filter.ses =  sessions{iSes};

    runs = bids.query(BIDS, 'runs', filter);

    for iRun = 1:numel(runs)

      filter.run = runs{iRun};
      filter.suffix = 'phasediff';
      filter.extension = '.nii';

      metadata = bids.query(BIDS, 'metadata', filter);

      bf = bids.File(metadata.IntendedFor);
      if any(ismember(opt.taskName, bf.entities.task))

        try
          [echotimes, isEPI, totReadTime, blipDir] = getMetadataForVDM(BIDS, filter);

        catch ME
          % until createVDM is fixed we skip it
          % and rethrow this error as a warning only
          if strcmp(ME.identifier, 'getMetadataFromIntendedForFunc:emptyReadoutTime')
            msg = ['Voxel displacement map creation requires a non empty value' ...
                   'for the TotalReadoutTime of the bold sequence they are matched to.\n', ...
                   'Creating voxel displacement maps is work in progress.\n', ...
                   'This is known issue\n.', ...
                   'Skipping for now.'];
            id = 'emptyReadoutTime';
            logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);
            continue
          else
            rethrow(ME);

          end
        end

        matlabbatch = setBatchComputeVDM(matlabbatch, 'phasediff', refImage);

        % TODO Move to getInfo ?
        matlabbatch{end}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.phase = ...
            bids.query(BIDS, 'data', filter);

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
