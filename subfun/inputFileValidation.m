function files = inputFileValidation(subFuncDataDir, prefix, fileName)
file2Process = spm_select('FPList', subFuncDataDir, ['^' prefix fileName '$']);
if isempty(file2Process)
    error('This file does not exist: %s', ...
        fullfile(subFuncDataDir,[prefix fileName '[.gz]']))
else
    files{1,1} = file2Process;
end
end