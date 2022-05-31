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

  % one sample t-test at the group level
  designMatrix = opt.model.bm.get_design_matrix('Name', nodeName);
  if isnumeric(designMatrix) && designMatrix == 1

    contrastsList = getDummyContrastsList(nodeName, opt.model.bm);
    tmp = getContrastsList(nodeName, opt.model.bm);

    for j = 1:numel(tmp)
      contrastsList{end + 1} = tmp{j}.Name;
    end

    % 2 samples t-test at the group level
  elseif iscell(designMatrix)
    designMatrix = removeIntercept(designMatrix);
    if ismember(lower(designMatrix), {'group'})
      edge = getEdge(opt.model.bm, 'Destination', nodeName);
      contrastsList = edge.Filter.contrast;
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
