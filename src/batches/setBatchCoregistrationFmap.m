% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function matlabbatch = setBatchCoregistrationFmap(opt, BIDS, subID)

    [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

    % Create rough mean of the 1rst run to improve SNR for coregistration
    % TODO use the slice timed EPI if STC was used
    runs = getInfo(BIDS, subID, opt, 'Runs', sessions{1});
    [fileName, subFuncDataDir] = getBoldFilename(BIDS, subID, sessions{1}, runs{1}, opt);
    
    spmup_basics(fullfile(subFuncDataDir, fileName), 'mean');
    
    refImage = fullfile(subFuncDataDir, ['mean_', fileName]);

    matlabbatch = [];
    
    
    
    
    
%     for iSes = 1:nbSessions
% 
%         matlabbatch = setBatchCoregistrationGeneral(matlabbatch, refImage, src, other);
% 
%     end

end
