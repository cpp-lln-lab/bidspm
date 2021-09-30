function matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subLabel, funcFWHM)
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
  % :param funcFWHM:
  % :type funcFWHM:
  %
  % :returns: - :matlabbatch:
  %
  % (C) Copyright 2019 CPP_SPM developers

  printBatchName('subject level contrasts specification');

  ffxDir = getFFXdir(subLabel, funcFWHM, opt);

  spmMatFile = cellstr(fullfile(ffxDir, 'SPM.mat'));

  load(spmMatFile{1}, 'SPM');

  model = spm_jsonread(opt.model.file);

  % Create Contrasts
  contrasts = specifyContrasts(ffxDir, opt.taskName, opt);
  for icon = 1:size(contrasts, 2)
    consess{icon}.tcon.name = contrasts(icon).name; %#ok<*AGROW>
    consess{icon}.tcon.convec = contrasts(icon).C;
    consess{icon}.tcon.sessrep = 'none';
  end

  matlabbatch = setBatchContrasts(matlabbatch, spmMatFile, consess);

end
