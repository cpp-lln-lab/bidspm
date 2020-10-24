% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function file = inputFileValidation(dir, fileName, prefix)
    % file = inputFileValidation(dir, prefix, fileName)
    %
    % Checks if files exist. A prefix can be added.
    %
    % If the filet(s) exist(s), it returns a cell containing list of fullpath.
    
    if nargin < 3
        prefix = '';
    end
    
    file2Process = spm_select('FPList', dir, ['^' prefix fileName '$']);

    if isempty(file2Process)

        errorStruct.identifier = 'inputFileValidation:nonExistentFile';
        errorStruct.message = sprintf( ...
                                      'This file does not exist: %s', ...
                                      fullfile(dir, [prefix fileName '[.gz]']));
        error(errorStruct);

    else
        file{1, 1} = file2Process;

    end

end
