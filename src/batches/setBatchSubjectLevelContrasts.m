% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSubjectLevelContrasts(opt, subID, funcFWHM)
  
  printBatchName('subject level contrasts specification');

  ffxDir = getFFXdir(subID, funcFWHM, opt);

  % Create Contrasts
  contrasts = specifyContrasts(ffxDir, opt.taskName, opt);

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
