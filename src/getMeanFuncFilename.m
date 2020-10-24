function [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subID, opt)
    % [anatImage, anatDataDir] = getAnatFilename(BIDS, subID, opt)
    %
    % Get the filename and the directory of an anat file for a given session /
    % run.
    % Unzips the file if necessary.
    
    sessions = getInfo(BIDS, subID, opt, 'Sessions');
    runs = getInfo(BIDS, subID, opt, 'Runs', sessions{1});
    [boldFileName, subFuncDataDir] = getBoldFilename( ...
                                                 BIDS, ...
                                                 subID, sessions{1}, runs{1}, opt);

    prefix= getPrefix('smoothing_space-individual', opt);
                                             
    meanImage = validationInputFile(...
        subFuncDataDir, ...
        boldFileName, ...
        ['mean' prefix]);
                                             
    [meanFuncDir, meanImage, ext] = spm_fileparts(meanImage);
    meanImage = [meanImage ext];
end