% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function opt = setDerivativesDir(opt)
    % derivativeDir sets the derivatives folder
    %
    %   opt = setDerivativesDir(opt)
    %
    % Parameters:
    %   opt: option structure
    %
    % Returns:
    %    opt: with the additional field derivativesDir

    if ~isfield(opt, 'derivativesDir') || isempty(opt.derivativesDir)
        opt.derivativesDir = fullfile(opt.dataDir, '..', 'derivatives', 'SPM12_CPPL');

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

    % Suffix output directory for the saved jobs
    opt.jobsDir = fullfile(opt.derivativesDir, 'JOBS', opt.taskName);

end
