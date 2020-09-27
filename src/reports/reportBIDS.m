% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function reportBIDS(opt)
    
    opt = setDerivativesDir(opt);
    
    subj = [];
    sess = [];
    run = [];
    read_nii = true;
    output_path = fullfile(opt.derivativesDir, 'report');
    
    mkdir(output_path)

    bids.report(...
        opt.derivativesDir, ...
        subj, ...
        sess, ...
        run, ...
        read_nii, ...
        output_path);
    
end
