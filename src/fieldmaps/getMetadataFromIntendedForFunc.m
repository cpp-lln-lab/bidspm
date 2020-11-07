% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function [totalReadoutTime, blipDir] = getMetadataFromIntendedForFunc(BIDS, fmapMetadata)
  %
  % Gets metadata of the associated bold file:
  % - finds the bold file a fmap is intended for, 
  % - parse its filename,
  % - get its metadata.
  %
  % USAGE::
  %
  %   [totalReadoutTime, blipDir] = getMetadataFromIntendedForFunc(BIDS, fmapMetadata)
  %
  % :param BIDS: BIDS layout returned by ``getData()``.
  % :type BIDS: structure
  % :param fmapMetadata:
  % :type fmapMetadata: structure
  %
  % :returns: :totalReadoutTime: (type) (dimension)
  %           :blipDir: (type) (dimension)
  %
  % At the moment the VDM is created based on the characteristics of the last
  % func file in the IntendedFor field
  %
  % .. TODO:
  %
  %    - if there are several func file for this fmap and they have different
  %    characteristic this may require creating a VDM for each

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
