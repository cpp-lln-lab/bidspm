% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function matlabbatch = setBatchSubjectLevelContrasts(opt, subID, funcFWHM, isMVPA)

    ffxDir = getFFXdir(subID, funcFWHM, opt, isMVPA);

    % Create Contrasts
    contrasts = specifyContrasts(ffxDir, opt.taskName, opt, isMVPA);

    matlabbatch = [];

    for icon = 1:size(contrasts, 2)
        matlabbatch{1}.spm.stats.con.consess{icon}.tcon.name = ...
            contrasts(icon).name;
        matlabbatch{1}.spm.stats.con.consess{icon}.tcon.convec = ...
            contrasts(icon).C;
        matlabbatch{1}.spm.stats.con.consess{icon}.tcon.sessrep = 'none';
    end

    matlabbatch{1}.spm.stats.con.spmmat = cellstr(fullfile(ffxDir, 'SPM.mat'));
    matlabbatch{1}.spm.stats.con.delete = 1;

end
