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

  load(spmMatFile{1}, 'SPM');

  model = spm_jsonread(opt.model.file);

  % Create Contrasts
  contrasts = specifyContrasts(SPM, opt.taskName, model);
  for icon = 1:size(contrasts, 2)
    consess{icon}.tcon.name = contrasts(icon).name; %#ok<*AGROW>
    consess{icon}.tcon.convec = contrasts(icon).C;
    consess{icon}.tcon.sessrep = 'none';
  end

  matlabbatch = setBatchContrasts(matlabbatch, opt, spmMatFile, consess);

end
