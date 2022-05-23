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
  %
  % See also: specifyContrasts, setBatchContrasts
  %
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
  for icon = 1:numel(contrasts)

    if any(contrasts(icon).C(:))

      con.name = contrasts(icon).name;
      con.convec = contrasts(icon).C;
      con.sessrep = 'none';

      switch contrasts(icon).type
        case 't'
          consess{end + 1}.tcon = con; %#ok<*AGROW>

        case 'F'
          consess{end + 1}.fcon = con; %#ok<*AGROW>
      end

    end

  end

  matlabbatch = setBatchContrasts(matlabbatch, opt, spmMatFile, consess);

end
