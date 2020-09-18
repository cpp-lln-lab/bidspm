% (C) Copyright 2020 Agah Karakuzu
% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function retval = isOctave
    % Return: true if the environment is Octave.
    persistent cacheval   % speeds up repeated calls

    if isempty (cacheval)
        cacheval = (exist ('OCTAVE_VERSION', 'builtin') > 0);
    end

    retval = cacheval;
end
