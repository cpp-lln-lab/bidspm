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
  %              See also: bids.layout, getData.
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
  % .. TODO if there are several func file for this fmap and they have different
  %    characteristic this may require creating a VDM for each
  %
  % (C) Copyright 2020 CPP_SPM developers

  for  iFile = 1:size(fmapMetadata.IntendedFor)

    if iscell(fmapMetadata.IntendedFor)
      funcFile = fmapMetadata.IntendedFor{iFile};
    else
      funcFile = fmapMetadata.IntendedFor(iFile, :);
    end
    funcFile = spm_file(funcFile, 'filename');

    funcFile = bids.File(funcFile);

    filter.modality = 'func';
    filter.suffix = funcFile.suffix;
    filter.sub = regexify(funcFile.entities.sub);
    filter.ses = funcFile.entities.ses;
    filter.run = funcFile.entities.run;
    filter.extension = '.nii';
    filter.space = '';

    if ~isfield(funcFile.entities, 'acq')
      filter.acq = '';
    end

    funcMetadata = bids.query(BIDS, 'metadata', filter);

  end

  totalReadoutTime = getTotalReadoutTime(funcMetadata);

  % temporary for designing
  %   totalReadoutTime = 63;

  if isempty(totalReadoutTime)
    msg = ['Voxel displacement map creation requires a non empty value' ...
           'for the TotalReadoutTime of the bold sequence they are matched to.'];
    errorHandling(mfilename(), 'emptyReadoutTime', msg, false);
  end

  blipDir = getBlipDirection(funcMetadata);

end
