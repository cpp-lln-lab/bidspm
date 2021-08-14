function matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subLabel)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subLabel, funcFWHM)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param opt:
  % :type opt: structure
  % :param subLabel:
  % :type subLabel: string
  %
  % :returns: - :matlabbatch:
  %
  % (C) Copyright 2019 CPP_SPM developers

  printBatchName('subject level contrasts specification', opt);

  ffxDir = getFFXdir(subLabel, opt);

  spmMatFile = cellstr(fullfile(ffxDir, 'SPM.mat'));

  % Create Contrasts
  contrasts = specifyContrasts(ffxDir, opt.taskName, opt);
  for icon = 1:size(contrasts, 2)
    consess{icon}.tcon.name = contrasts(icon).name; %#ok<*AGROW>
    consess{icon}.tcon.convec = contrasts(icon).C;
    consess{icon}.tcon.sessrep = 'none';
  end

  matlabbatch = setBatchContrasts(matlabbatch, opt, spmMatFile, consess);

end
