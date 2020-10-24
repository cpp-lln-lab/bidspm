% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function realignParamFile = getRealignParamFile(fullpathBoldFileName, prefix)

    [funcDataDir, boldFileName] = spm_fileparts(fullpathBoldFileName);
    
    if nargin > 1
        boldFileName = strrep(boldFileName, [prefix 'sub-'], 'sub-');
    end

    realignParamFile = ['rp_.*' boldFileName, '.txt'];    
    realignParamFile = validationInputFile(funcDataDir, realignParamFile);

end
