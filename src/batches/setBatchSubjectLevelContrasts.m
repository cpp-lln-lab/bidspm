% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subID, funcFWHM)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subID, funcFWHM)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param opt:
  % :type opt: structure
  % :param subID:
  % :type subID: string
  % :param funcFWHM:
  % :type funcFWHM:
  %
  % :returns: - :matlabbatch:
  %

  printBatchName('subject level contrasts specification');

  ffxDir = getFFXdir(subID, funcFWHM, opt);

  spmMatFile = cellstr(fullfile(ffxDir, 'SPM.mat'));

  % Create Contrasts
  contrasts = specifyContrasts(ffxDir, opt.taskName, opt);
  for icon = 1:size(contrasts, 2)
    consess{icon}.tcon.name = contrasts(icon).name; %#ok<*AGROW>
    consess{icon}.tcon.convec = contrasts(icon).C;
    consess{icon}.tcon.sessrep = 'none';
  end

  matlabbatch = setBatchContrasts(matlabbatch, spmMatFile, consess);

end
