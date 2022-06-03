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

  [groupGlmType, designMatrix] =  groupLevelGlmType(opt, nodeName);

  switch groupGlmType

    case 'one_sample_t_test'

      contrastsList = getDummyContrastsList(nodeName, opt.model.bm);
      tmp = getContrastsList(nodeName, opt.model.bm);

      for j = 1:numel(tmp)
        contrastsList{end + 1} = tmp{j}.Name;
      end

      for j = 1:numel(contrastsList)

        spmMatFile = fullfile(getRFXdir(opt, nodeName, contrastsList{j}), 'SPM.mat');

        consess{1}.tcon.name = contrastsList{j};
        consess{1}.tcon.convec = 1;
        consess{1}.tcon.sessrep = 'none';

        matlabbatch = setBatchContrasts(matlabbatch, opt, spmMatFile, consess);

      end

    case 'two_sample_t_test'

      designMatrix = removeIntercept(designMatrix);

      if ismember(lower(designMatrix), {'group'})
        edge = opt.model.bm.get_edge('Destination', nodeName);
        contrastsList = edge.Filter.contrast;
      end

      for j = 1:numel(contrastsList)

        thisContrast = opt.model.bm.get_contrasts('Name', nodeName);

        spmMatFile = fullfile(getRFXdir(opt, nodeName, contrastsList{j}), 'SPM.mat');

        consess{1}.tcon.name = thisContrast.Name;
        consess{1}.tcon.convec = thisContrast.Weights;
        consess{1}.tcon.sessrep = 'none';

        matlabbatch = setBatchContrasts(matlabbatch, opt, spmMatFile, consess);

      end

    otherwise
      msg = sprintf('Node %s has has model type I cannot handle.\n', nodeName);
      notImplemented(mfilename(), msg, true);

  end

end
