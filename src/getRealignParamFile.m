% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function realignParamFile = getRealignParamFile(opt, fullpathBoldFileName, funcFWHM)

    [prefix, motionRegressorPrefix] = getPrefix('FFX', opt, funcFWHM);
    if strcmp(opt.space, 'individual')
        [prefix, motionRegressorPrefix] = getPrefix('FFX_space-individual', opt, funcFWHM);
    end

    if strcmp(prefix, 'r')
        prefix = 'rsub-';
        motionRegressorPrefix = 'sub-';
    end

    [funcDataDir, boldFileName] = spm_fileparts(fullpathBoldFileName);

    realignParamFile = ['rp_', strrep(boldFileName, prefix, motionRegressorPrefix), '.txt'];    
    realignParamFile = validationInputFile(funcDataDir, realignParamFile);

end
