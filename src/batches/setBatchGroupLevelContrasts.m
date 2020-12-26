% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchGroupLevelContrasts(matlabbatch, grpLvlCon, rfxDir)

  printBatchName('group level contrast estimation');

  for j = 1:size(grpLvlCon, 1)

    conName = rmTrialTypeStr(grpLvlCon{j});

    spmMatFile = {fullfile(rfxDir, conName, 'SPM.mat')};

    consess{1}.tcon.name = 'GROUP';
    consess{1}.tcon.convec = 1;
    consess{1}.tcon.sessrep = 'none';

    matlabbatch = setBatchContrasts(matlabbatch, spmMatFile, consess);

  end

end
