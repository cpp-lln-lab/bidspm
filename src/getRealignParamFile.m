function realignParamFile = getRealignParamFile(opt, fullpathBoldFileName, funcFWHM)

    [prefix, motionRegressorPrefix] = getPrefix('FFX', opt, funcFWHM);
    if strcmp(opt.space, 'T1w')
        [prefix, motionRegressorPrefix] = getPrefix('FFX_space-T1w', opt, funcFWHM);
    end

    [funcDataDir, boldFileName] = spm_fileparts(fullpathBoldFileName{1});

    realignParamFile = strrep(boldFileName, prefix, motionRegressorPrefix);
    realignParamFile = ['rp_', realignParamFile, '.txt'];
    realignParamFile = fullfile(funcDataDir, realignParamFile);

    if ~exist(realignParamFile, 'file')
        errorStruct.identifier = 'getRealignParamFile:nonExistentFile';
        errorStruct.message = sprintf('%s\n%s', ...
            'This realignment file does not exist:', ...
            realignParamFile);
        error(errorStruct);
    end
end
