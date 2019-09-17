function files = inputFileValidation(dir, prefix, fileName)
file2Process = spm_select('FPList', dir, ['^' prefix fileName '$']);
if isempty(file2Process)
    error('This file does not exist: %s', ...
        fullfile(dir,[prefix fileName '[.gz]']))
else
    files{1,1} = file2Process;
end
end