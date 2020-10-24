% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function files = validationInputFile(dir, fileName, prefix)
    % file = validationInputFile(dir, prefix, fileName)
    %
    % Checks if files exist. A prefix can be added.
    %
    % If the filet(s) exist(s), it returns a cell containing list of fullpath.
    
    if nargin < 3
        prefix = '';
    end
    
    files = spm_select('FPList', dir, ['^' prefix fileName '$']);

    if isempty(files)

        errorStruct.identifier = 'validationInputFile:nonExistentFile';
        errorStruct.message = sprintf( ...
                                      'This file does not exist: %s', ...
                                      fullfile(dir, [prefix fileName '[.gz]']));
        error(errorStruct);
        
    end

end
