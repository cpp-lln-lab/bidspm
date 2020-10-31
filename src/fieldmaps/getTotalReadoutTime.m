% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function totalReadoutTime = getTotalReadoutTime(metadata)
  %
  % Gets the total read out time of a sequence.
  %
  % USAGE::
  %
  %   totalReadoutTime = getTotalReadoutTime(metadata)
  %
  % :param metadata: image metadata
  % :type metadata: strcuture
  %
  % :returns: - :totalReadoutTime: (float) in millisecond
  %
  % Used to create the voxel dsiplacement map (VDM) from the fieldmap
  %

  totalReadoutTime = '';

  % apparently this comes from the functional metadata to create the VDM
  if isfield(metadata, 'TotalReadoutTime') && ~isempty(metadata.TotalReadoutTime)
    totalReadoutTime = metadata.TotalReadoutTime;

    % TODO
    % double check this section
    % this was in spmup but I don't remember where I got this from
    %
    %   % from spmup: apparently this comes from the fmap metadata
    %   %  but PixelBandwidth is not is not a valid BIDS term
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

    %% Phase enconded lines (PELines) and ReadOutTime

    % PELines = ((BaseResolution * PartialFourier)/iPat) + ((iPat-1)/iPAT) * ReferenceLines) =
    % ReadoutDuration = PELines * InterEchoSpacing

    % GRAPPA=iPAT4 ; Partial Fourrier=6/8 ; 48 sli ; TE=25ms ; Res=0.75 mm
    % Bandwidth Per Pixel Phase Encode = 15.873

    %% According to Robert Trampel

    % For distortion correction: ignore Partial Fourrier and references lines
    % BaseResolution/iPAT = PELines

    % Effective echo spacing: 2 ways to calculate, should be the same
    % 1/(Bandwidth Per Pixel Phase Encode * Reconstructed phase lines) -->  0.246 ms
    % echo spacing (syngo) / iPAT

    % SPM Total readout time = 1/"Bandwidth Per Pixel Phase Encode", stored in
    % DICOM tag (0019, 1028) --> 63 ms

  end

end
