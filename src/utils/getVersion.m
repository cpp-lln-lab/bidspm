function versionNumber = getVersion()
    try
        versionNumber = fileread(fullfile(fileparts(mfilename('fullpath')), ...
            '..', '..', 'version.txt'));
    catch
        versionNumber = 'v0.0.3';
    end
end
