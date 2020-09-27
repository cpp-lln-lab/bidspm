% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function opt = setDerivativesDir(opt)
    % derivativeDir = setDerivativeDir(opt)

    if ~isfield(opt, 'derivativesDir') || isempty(opt.derivativesDir)
        opt.derivativesDir = fullfile(opt.dataDir, '..', 'derivatives', 'SPM12_CPPL');
        return
    end

    folders = split(opt.derivativesDir, filesep);

    if ~strcmp(folders{end - 1}, 'derivatives') && ~strcmp(folders{end}, 'SPM12_CPPL')
        folders{end + 1} = 'derivatives';
        folders{end + 1} = 'SPM12_CPPL';
    end

    tmp = join(folders, filesep);
    opt.derivativesDir = tmp{1};

end
