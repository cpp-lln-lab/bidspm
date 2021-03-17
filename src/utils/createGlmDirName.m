% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

function glmDirName = createGlmDirName(opt, FWHM)
    
    glmDirName = ['task-', opt.taskName, ...
        '_space-' opt.space, ...
        '_FWHM-', num2str(FWHM)];
    
end