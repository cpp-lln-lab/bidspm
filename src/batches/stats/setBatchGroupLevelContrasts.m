function matlabbatch = setBatchGroupLevelContrasts(matlabbatch, opt, nodeName)
  %
  % USAGE::
  %
  %   matlabbatch = setBatchGroupLevelContrasts(matlabbatch, opt, nodeName)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See  also: checkOptions
  % :type opt: structure
  %
  % :param nodeName:
  % :type nodeName: char
  %
  % :returns: - :matlabbatch:
  %
  %
  %
  % See also: setBatchContrasts, specifyContrasts, setBatchSubjectLevelContrasts
  %
  % (C) Copyright 2019 CPP_SPM developers

  printBatchName('group level contrast estimation', opt);

  [groupGlmType, designMatrix, groupBy] =  groupLevelGlmType(opt, nodeName);

  switch groupGlmType

    case 'one_sample_t_test'

      contrastsList = getContrastsListForFactorialDesign(opt, nodeName);

      if all(ismember(lower(groupBy), {'contrast'}))

        for j = 1:numel(contrastsList)

          spmMatFile = fullfile(getRFXdir(opt, nodeName, contrastsList{j}), 'SPM.mat');

          matlabbatch = setGroupContrast(matlabbatch, opt, spmMatFile, ...
                                         contrastsList{j}, ...
                                         1);

        end

      elseif all(ismember(lower(groupBy), {'contrast', 'group'}))

        participants = bids.util.tsvread(fullfile(opt.dir.raw, 'participants.tsv'));

        groupColumnHdr = groupBy{ismember(lower(groupBy), {'group'})};
        availableGroups = unique(participants.(groupColumnHdr));

        for j = 1:numel(contrastsList)

          for iGroup = 1:numel(availableGroups)

            thisGroup = availableGroups{iGroup};
            rfxDir = getRFXdir(opt, nodeName, contrastsList{j}, thisGroup);
            spmMatFile = fullfile(rfxDir, 'SPM.mat');

            matlabbatch = setGroupContrast(matlabbatch, opt, spmMatFile, ...
                                           contrastsList{j}, ...
                                           1);

          end

        end

      end

    case 'two_sample_t_test'

      designMatrix = removeIntercept(designMatrix);

      if ismember(lower(designMatrix), {'group'})
        % TODO will this ignore the contrasts define at other levels and not
        % passed through the filter ?
        edge = opt.model.bm.get_edge('Destination', nodeName);
        contrastsList = edge.Filter.contrast;
      end

      for j = 1:numel(contrastsList)

        thisContrast = opt.model.bm.get_contrasts('Name', nodeName);

        spmMatFile = fullfile(getRFXdir(opt, nodeName, contrastsList{j}), 'SPM.mat');

        if ~opt.dryRun
          assert(exist(spmMatFile, 'file') == 2);
        end

        for iCon = 1:numel(thisContrast)
          consess{iCon}.tcon.name = thisContrast{iCon}.Name;
          consess{iCon}.tcon.convec = thisContrast{iCon}.Weights;
          consess{iCon}.tcon.sessrep = 'none';
        end

        matlabbatch = setBatchContrasts(matlabbatch, opt, spmMatFile, consess);

      end

    otherwise
      msg = sprintf('Node %s has has model type I cannot handle.\n', nodeName);
      notImplemented(mfilename(), msg, true);

  end

end

function matlabbatch = setGroupContrast(matlabbatch, opt, spmMatFile, name, weights)

  if ~opt.dryRun
    assert(exist(spmMatFile, 'file') == 2);
  end

  consess{1}.tcon.name = name;
  consess{1}.tcon.convec = weights;
  consess{1}.tcon.sessrep = 'none';

  matlabbatch = setBatchContrasts(matlabbatch, opt, spmMatFile, consess);

end
