function matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subLabel)
  %
  % set batch for run and subject level contrasts
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSubjectLevelContrasts(matlabbatch, opt, subLabel, funcFWHM)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  %
  % :param opt:
  % :type opt: structure
  %
  % :param subLabel:
  % :type subLabel: string
  %
  % :returns: - :matlabbatch:
  %
  % (C) Copyright 2019 CPP_SPM developers

  printBatchName('subject level contrasts specification', opt);

  spmMatFile = fullfile(getFFXdir(subLabel, opt), 'SPM.mat');
  if noSPMmat(opt, subLabel, spmMatFile)
    return
  end

  load(spmMatFile, 'SPM');

  model = spm_jsonread(opt.model.file);

  % Create Contrasts
  contrasts = specifyContrasts(SPM, model);
  for icon = 1:size(contrasts, 2)
    consess{icon}.tcon.name = contrasts(icon).name; %#ok<*AGROW>
    consess{icon}.tcon.convec = contrasts(icon).C;
    consess{icon}.tcon.sessrep = 'none';
  end

  matlabbatch = setBatchContrasts(matlabbatch, opt, spmMatFile, consess);

end
