function srcMetadata = collectSrcMetadata(srcMetadata, metadata)
  % (C) Copyright 2023 bidspm developers
  for iFile = 1:numel(metadata)

    if isfield(metadata{iFile}, 'RepetitionTime')
      srcMetadata.RepetitionTime(end + 1) = metadata{iFile}.RepetitionTime;
    else
      srcMetadata.RepetitionTime(end + 1) = nan;
    end

    if isfield(metadata{iFile}, 'SliceTimingCorrected')
      srcMetadata.SliceTimingCorrected(end + 1) = metadata{iFile}.SliceTimingCorrected;
    else
      srcMetadata.SliceTimingCorrected(end + 1) = false;
    end

    if isfield(metadata{iFile}, 'StartTime')
      srcMetadata.StartTime(end + 1) = metadata{iFile}.StartTime;
    else
      srcMetadata.StartTime(end + 1) = nan;
    end

  end
end
