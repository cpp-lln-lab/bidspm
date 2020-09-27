% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function opt = setDerivativesDir(opt)
    % derivativeDir = setDerivativeDir(opt)

    if ~isfield(opt, 'derivativesDir') || isempty(opt.derivativesDir)
        opt.derivativesDir = fullfile(opt.dataDir, '..', 'derivatives', 'SPM12_CPPL');
        return
    end

    try
        folders = split(opt.derivativesDir, filesep);
    catch
        % for octave
        folders = strsplit(opt.derivativesDir, filesep);
    end

    if ~strcmp(folders{end - 1}, 'derivatives') && ~strcmp(folders{end}, 'SPM12_CPPL')
        folders{end + 1} = 'derivatives';
        folders{end + 1} = 'SPM12_CPPL';
    end

    try
        tmp = join(folders, filesep);
        opt.derivativesDir = tmp{1};
    catch
        % for octave
        opt.derivativesDir = strjoin(folders, filesep);
    end

end
