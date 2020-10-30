% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function blipDir = getBlipDirection(metadata)

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
