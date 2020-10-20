% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function opt = loadAndCheckOptions(opt)

    if isempty(opt)
    end
    
    if ischar(opt)
        opt = spm_jsonread(opt);
    end
    
    opt = checkOptions(opt);
    
    fprintf('options loaded and checked\n\n');
end
