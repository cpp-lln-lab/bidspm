% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function totalReadoutTime = getTotalReadoutTime(metadata)

  % TODO
  % double check this section

  totalReadoutTime = '';

  % apparently this comes from the functional metadata ???
  if isfield(metadata, 'TotalReadoutTime') && ~isempty(metadata.TotalReadoutTime)
    totalReadoutTime = metadata.TotalReadoutTime;

    %   % from spmup: apparently this comes from the fmap metadata
    %   elseif isfield(metadata, 'PixelBandwidth') && ~isempty(metadata.PixelBandwidth)
    %     totalReadoutTime = 1 / fieldmap_param.PixelBandwidth * 1000;
    %     warning('PixelBandwidth is not a valid BIDS term.');
    %
    %   % apparently this comes from the functional metadata ???
    %   elseif isfield(metadata, 'RepetitionTime') && ~isempty(metadata.RepetitionTime)
    %     totalReadoutTime = metadata.RepetitionTime;
    %
    %   % apparently this comes from the functional metadata ???
    %   elseif isfield(metadata, 'EffectiveEchoSpacing') && ~isempty(metadata.NumberOfEchos)
    %     totalReadoutTime = (metadata.NumberOfEchos - 1) * ...
    %       metadata.EffectiveEchoSpacing;

  end

end
