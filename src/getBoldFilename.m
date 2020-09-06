function [fileName, subFuncDataDir] = getBoldFilename(varargin)

    [BIDS, subID, sessions, runs, opt] = deal(varargin{:});

    % get the filename for this bold run for this task
    fileName =  getInfo(BIDS, subID, opt, 'Filename', sessions, runs, 'bold');

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
