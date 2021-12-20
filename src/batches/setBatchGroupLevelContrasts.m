function matlabbatch = setBatchGroupLevelContrasts(matlabbatch, opt, grpLvlCon, rfxDir)
  %
  % (C) Copyright 2019 CPP_SPM developers

  printBatchName('group level contrast estimation', opt);

  for j = 1:size(grpLvlCon.Contrasts, 1)

    conName = rmTrialTypeStr(grpLvlCon.Contrasts{j});

    spmMatFile = {fullfile(rfxDir, conName, 'SPM.mat')};

    consess{1}.tcon.name = 'GROUP';
    consess{1}.tcon.convec = 1;
    consess{1}.tcon.sessrep = 'none';

    matlabbatch = setBatchContrasts(matlabbatch, opt, spmMatFile, consess);

  end

end
