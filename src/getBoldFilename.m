% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function [fileName, subFuncDataDir] = getBoldFilename(varargin)
    % [fileName, subFuncDataDir] = getBoldFilename(BIDS, opt, subID, sessionID, runID)

    [BIDS, subID, sessionID, runID, opt] = deal(varargin{:});

    % get the filename for this bold run for this task
    fileName =  getInfo(BIDS, subID, opt, 'Filename', sessionID, runID, 'bold');

    % get fullpath of the file
    fileName = fileName{1};
    [subFuncDataDir, file, ext] = spm_fileparts(fileName);
    % get filename of the orginal file (drop the gunzip extension)
    if strcmp(ext, '.gz')
        fileName = file;
    elseif strcmp(ext, '.nii')
        fileName = [file ext];
    end

end
