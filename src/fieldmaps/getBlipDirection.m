function blipDir = getBlipDirection(metadata)
  %
  % Gets the total read out time of a sequence.
  %
  % USAGE::
  %
  %   blipDir = getBlipDirection(metadata)
  %
  % :param metadata: image metadata
  % :type metadata: strcuture
  %
  % :returns: - :blipDir:
  %
  % Used to create the voxel dsiplacement map (VDM) from the fieldmap
  %
  % (C) Copyright 2020 bidspm developers

  blipDir = 1;

  if isfield(metadata, 'PhaseEncodingDirection') && ...
      ~isempty(metadata.PhaseEncodingDirection)

    switch metadata.PhaseEncodingDirection

      case {'i', 'j', 'y'}
        blipDir = 1;

      case {'i-', 'j-', 'y-'}
        blipDir = -1;

      otherwise
        msg = sprintf('unknown phase encoding direction: %s', metadata.PhaseEncodingDirection);
        id = 'unknownPhaseEncodingDirection';
        errorHandling(mfilename(), id, msg, false);

    end

  end

end
