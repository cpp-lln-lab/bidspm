% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subID)
    % matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subID)
    %
    % Creates a batch to set an anat image
    % - image type = opt.anatReference.type (default = T1w)
    % - session to select the anat from = opt.anatReference.session (default = 1)
    %
    % We assume that the first anat of that type is the "correct" one
    
    fprintf(1, ' BUILDING SPATIAL JOB : SELECTING ANATOMCAL\n');

    [anatImage, anatDataDir] = getAnatFilename(BIDS, subID, opt);

    matlabbatch{end + 1}.cfg_basicio.cfg_named_file.name = 'Anatomical';
    matlabbatch{end}.cfg_basicio.cfg_named_file.files = { {fullfile(anatDataDir, anatImage)} };

end
