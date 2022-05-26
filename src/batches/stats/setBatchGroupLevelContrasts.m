function matlabbatch = setBatchGroupLevelContrasts(matlabbatch, opt, nodeName)
  %
  % USAGE::
  %
  %   matlabbatch = setBatchGroupLevelContrasts(matlabbatch, opt, nodeName)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  %
  % :param opt:
  % :type opt: structure
  %
  % :param nodeName:
  % :type nodeName: string
  %
  % :returns: - :matlabbatch:
  %
  %
  %
  % See also: setBatchContrasts, specifyContrasts, setBatchSubjectLevelContrasts
  %
  % (C) Copyright 2019 CPP_SPM developers

  printBatchName('group level contrast estimation', opt);

  % average at the group level
  if opt.model.bm.get_design_matrix('Name', nodeName) == 1

    contrastsList = getDummyContrastsList(nodeName, opt.model.bm);
    tmp = getContrastsList(nodeName, opt.model.bm);

    for j = 1:numel(tmp)
      contrastsList{end + 1} = tmp{j}.Name;
    end

  end

  for j = 1:numel(contrastsList)

    spmMatFile = fullfile(getRFXdir(opt, nodeName, contrastsList{j}), 'SPM.mat');

    consess{1}.tcon.name = contrastsList{j};
    consess{1}.tcon.convec = 1;
    consess{1}.tcon.sessrep = 'none';

    matlabbatch = setBatchContrasts(matlabbatch, opt, spmMatFile, consess);

  end

end
