% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

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

  blipDir = 1;

  if isfield(metadata, 'PhaseEncodingDirection') && ...
      ~isempty(metadata.PhaseEncodingDirection)

    switch metadata.PhaseEncodingDirection

      case {'i', 'j', 'y'}
        blipDir = 1;
      case {'i-', 'j-', 'y-'}
        blipDir = -1;
      otherwise
        error('unknown phase encoding direction: %s', metadata.PhaseEncodingDirection);

    end

  end

end
