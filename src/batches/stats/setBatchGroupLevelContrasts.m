function matlabbatch = setBatchGroupLevelContrasts(matlabbatch, opt, nodeName)
  %
  % USAGE::
  %
  %   matlabbatch = setBatchGroupLevelContrasts(matlabbatch, opt, nodeName)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  %
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  %
  % :type  opt: structure
  %
  % :param nodeName:
  % :type nodeName: char
  %
  % :return: matlabbatch
  %
  %
  %
  % See also: setBatchContrasts, specifyContrasts, setBatchSubjectLevelContrasts
  %

  % (C) Copyright 2019 bidspm developers

  printBatchName('group level contrast estimation', opt);

  % TODO refactor
  participants = bids.util.tsvread(fullfile(opt.dir.raw, 'participants.tsv'));
  [groupGlmType, designMatrix, groupBy] =  groupLevelGlmType(opt, nodeName, participants);

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

        % TODO make more general than just with group
      elseif all(ismember(lower(groupBy), {'contrast', 'group'}))
        % TODO make more general than just with group
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

    case 'one_way_anova'

      % T test for ANOVA
      %
      % Loop over the subject level contrasts passed
      % through the Edge filter.
      % Then generate the between group contrasts.

      designMatrix = removeIntercept(designMatrix);

      groups = unique(participants.(designMatrix{1}));

      edge = opt.model.bm.get_edge('Destination', nodeName);
      contrastsList = edge.Filter.contrast;

      thisContrast = opt.model.bm.get_contrasts('Name', nodeName);

      for j = 1:numel(contrastsList)

        spmMatFile = fullfile(getRFXdir(opt, ...
                                        nodeName, ...
                                        contrastsList{j}, ...
                                        '1WayANOVA'), ...
                              'SPM.mat');

        for iCon = 1:numel(thisContrast)

          % Sort conditions and weights
          [ConditionList, I] = sort(thisContrast{iCon}.ConditionList);
          for iCdt = 1:numel(ConditionList)
            ConditionList{iCdt} =  strrep(ConditionList{iCdt}, [designMatrix{1}, '.'], '');
          end
          Weights = thisContrast{iCon}.Weights(I);

          % Create contrast vectors by what was passed in the model
          convec = zeros(size(groups));
          for iGroup = 1:numel(groups)
            index = strcmp(groups{iGroup}, ConditionList);
            if any(index)
              convec(iGroup) = Weights(index);
            end
          end

          consess{iCon}.tcon.name = thisContrast{iCon}.Name;
          consess{iCon}.tcon.convec = convec;
          consess{iCon}.tcon.sessrep = 'none';
        end

        matlabbatch = setBatchContrasts(matlabbatch, opt, spmMatFile, consess);

      end

    case 'two_sample_t_test'

      designMatrix = removeIntercept(designMatrix);

      % TODO make more general than just with group
      if ismember(lower(designMatrix), {'group'})
        % TODO will this ignore the contrasts define at other levels
        % and not passed through the filter ?
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
      notImplemented(mfilename(), msg, opt);

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
