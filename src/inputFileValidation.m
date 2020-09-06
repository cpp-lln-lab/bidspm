function file = inputFileValidation(dir, prefix, fileName)
    file2Process = spm_select('FPList', dir, ['^' prefix fileName '$']);
    
    
    
    if isempty(file2Process)
        
        errorStruct.identifier = 'inputFileValidation:nonExistentFile';
        errorStruct.message = sprintf(...
            'This file does not exist: %s', ...
            fullfile(dir, [prefix fileName '[.gz]']));
        error(errorStruct);
        
    else
        file{1, 1} = file2Process;
        
    end
    
end
