function onsetFileName = createAndReturnOnsetFile(opt, subID, funcFWHM, boldFileName, isMVPA)
    % onsetFileName = createAndReturnOnsetFile(opt, boldFileName, prefix, isMVPA)
    %
    % gets the tsv onset file based on the bold file name (removes any prefix)
    %
    % convert the tsv files to a mat file to be used by SPM

    prefix = getPrefix('FFX', opt, funcFWHM);
    if strcmp(opt.space, 'T1w')
        prefix = getPrefix('FFX_space-T1w', opt, funcFWHM);
    end

    [funcDataDir, boldFileName] = spm_fileparts(boldFileName{1});

    tsvFile = strrep(boldFileName, '_bold', '_events.tsv');
    tsvFile = strrep(tsvFile, prefix, '');
    tsvFile = fullfile(funcDataDir, tsvFile);

    onsetFileName = convertOnsetTsvToMat(opt, tsvFile, isMVPA);

    % move file into the FFX directory
    [~, filename, ext] = spm_fileparts(onsetFileName);
    ffxDir = getFFXdir(subID, funcFWHM, opt, isMVPA);
    copyfile(onsetFileName, ffxDir);

    onsetFileName = fullfile(ffxDir, [filename ext]);

end
