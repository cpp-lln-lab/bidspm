% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function [boldFileName, subFuncDataDir] = getBoldFilename(varargin)
    % [fileName, subFuncDataDir] = getBoldFilename(BIDS, opt, subID, sessionID, runID)
    %
    % Get the filename and the directory of a bold file for a given session /
    % run.
    % Unzips the file if necessary.

    [BIDS, subID, sessionID, runID, opt] = deal(varargin{:});

    % get the filename for this bold run for this task
    boldFileName = getInfo(BIDS, subID, opt, 'Filename', sessionID, runID, 'bold');

    % get fullpath of the file
    % ASSUMPTION: the first file is the right one.
    boldFileName = unzipImgAndReturnsFullpathName(boldFileName);
    
    [subFuncDataDir, boldFileName, ext] = spm_fileparts(boldFileName);
    boldFileName = [boldFileName ext];

end
