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

  model = opt.model.bm;

  % Create Contrasts
  contrasts = specifyContrasts(SPM, model);

  consess = {};
  for icon = 1:size(contrasts, 2)
    if any(contrasts(icon).C)
      consess{end + 1}.tcon.name = contrasts(icon).name; %#ok<*AGROW>
      consess{end}.tcon.convec = contrasts(icon).C;
      consess{end}.tcon.sessrep = 'none';
    end
  end

  matlabbatch = setBatchContrasts(matlabbatch, opt, spmMatFile, consess);

end
