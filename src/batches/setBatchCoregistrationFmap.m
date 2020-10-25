% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function matlabbatch = setBatchCoregistrationFmap(opt, BIDS, subID)
    
    % TODO
    % assumes all the fieldmap relate to the current task
    % use the "for" metadata field
    
    % Create rough mean of the 1rst run to improve SNR for coregistration
    % TODO use the slice timed EPI if STC was used
    sessions = getInfo(BIDS, subID, opt, 'Sessions');
    runs = getInfo(BIDS, subID, opt, 'Runs', sessions{1});
    [fileName, subFuncDataDir] = getBoldFilename(BIDS, subID, sessions{1}, runs{1}, opt);
    
    spmup_basics(fullfile(subFuncDataDir, fileName), 'mean');
    
    refImage = fullfile(subFuncDataDir, ['mean_', fileName]);
    
    matlabbatch = [];
    
    % TODO Move to getInfo
    fmapFiles = spm_BIDS(BIDS, 'data', 'modality', 'fmap');
    
    for iRun = 1:size(fmapFiles, 1)
        
        % TODO only deals with phasdiff for the moment
        srcImage = strrep(fmapFiles{iRun}, 'phasediff', 'magnitude1');
        
        otherImages = cell(2,1);
        otherImages{1} = strrep(fmapFiles{iRun}, 'phasediff', 'magnitude2');
        otherImages{2} = fmapFiles{iRun};
        
        matlabbatch = setBatchCoregistrationGeneral(matlabbatch, refImage, srcImage, otherImages);
        
    end
    
    
end
