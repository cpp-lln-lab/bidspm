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
  % :param BIDS: dataset layout.
  %              See: bids.layout, getData.
  % :type BIDS: structure
  % :param fmapMetadata:
  % :type fmapMetadata: structure
  %
  % :return: totalReadoutTime: (type) (dimension)
  %           :blipDir: (type) (dimension)
  %
  % At the moment the VDM is created based on the characteristics of the last
  % func file in the IntendedFor field
  %
  % .. TODO if there are several func file for this fmap and they have different
  %    characteristic this may require creating a VDM for each
  %

  % (C) Copyright 2020 bidspm developers

  if ischar(fmapMetadata.IntendedFor)
    fmapMetadata.IntendedFor = cellstr(fmapMetadata.IntendedFor);
  end

  for  iFile = 1:numel(fmapMetadata.IntendedFor)

    funcFile = fmapMetadata.IntendedFor{iFile};

    funcFile = bids.File(funcFile);

    filter = funcFile.entities;

    filter.modality = 'func';
    filter.suffix = funcFile.suffix;
    filter.sub = regexify(funcFile.entities.sub);
    filter.extension = '.nii';
    filter.space = '';

    entitiesToSilence = {'ses', 'run', 'acq'};
    for i = 1:numel(entitiesToSilence)
      if ~isfield(funcFile.entities, entitiesToSilence{i})
        filter.(entitiesToSilence{i}) = '';
      end
    end

    funcMetadata = bids.query(BIDS, 'metadata', filter);

  end

  totalReadoutTime = getTotalReadoutTime(funcMetadata);

  % temporary for designing
  %   totalReadoutTime = 63;

  if isempty(totalReadoutTime)
    msg = ['Voxel displacement map creation requires a non empty value' ...
           'for the TotalReadoutTime of the bold sequence they are matched to.'];
    id = 'emptyReadoutTime';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  end

  blipDir = getBlipDirection(funcMetadata);

end
