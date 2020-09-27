% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function writeReport(opt, action)
    
    opt = setDerivativesDir(opt);

    outputPath = fullfile(opt.derivativesDir, 'report', opt.taskName);
    if ~exist(outputPath, 'dir')
        mkdir(outputPath);
    end
    
    filename = sprintf( ...
        '%s_SPM12_CPPL_report-%s.md', ...
        datestr(now, 'yyyymmdd_HHMM'), ...
        action);
    
    fileId = fopen(fullfile(outputPath, filename), 'w+');
    
    if fileId == -1
        
        warning('Unable to write file %s. Will print to screen.', filename);
        
        fileId = 1;
        
    end
    
    switch lower(action)
        
        case 'stc'
            
            inputFile = 'slice_timing.txt';
            
            
    end
    
    inputPath = fullfile(fileparts(mfilename('fullpath')), 'inputs');
    boilerplateText = fileread(fullfile(inputPath, inputFile));
    
    
    fprintf(fileId, boilerplateText);
    
end