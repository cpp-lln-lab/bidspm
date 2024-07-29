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

  bm = opt.model.bm;

  participants = bids.util.tsvread(fullfile(opt.dir.raw, 'participants.tsv'));

  groupColumnHdr = bm.getGroupColumnHdrFromGroupBy(nodeName, participants);
  availableGroups = getAvailableGroups(opt, groupColumnHdr);

  [groupGlmType, groupBy] =  bm.groupLevelGlmType(nodeName, participants);
  switch groupGlmType

    case 'one_sample_t_test'

      contrastsList = getContrastsListForFactorialDesign(opt, nodeName);

      if numel(groupBy) == 1 && ismember(lower(groupBy), {'contrast'})

        for j = 1:numel(contrastsList)

          spmMatFile = fullfile(getRFXdir(opt, nodeName, contrastsList{j}), 'SPM.mat');

          matlabbatch = setGroupContrast(matlabbatch, opt, spmMatFile, ...
                                         contrastsList{j}, ...
                                         1);

        end

      elseif numel(groupBy) == 2 && any(ismember(groupBy, fieldnames(participants)))

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

      edge = bm.get_edge('Destination', nodeName);
      contrastsList = edge.Filter.contrast;

      thisContrast = bm.get_contrasts('Name', nodeName);

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
            ConditionList{iCdt} =  strrep(ConditionList{iCdt}, [groupColumnHdr, '.'], '');
          end
          Weights = thisContrast{iCon}.Weights(I);

          % Create contrast vectors by what was passed in the model
          convec = zeros(size(availableGroups));
          for iGroup = 1:numel(availableGroups)
            index = strcmp(availableGroups{iGroup}, ConditionList);
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

      edge = bm.get_edge('Destination', nodeName);
      contrastsList = edge.Filter.contrast;

      for j = 1:numel(contrastsList)

        thisContrast = bm.get_contrasts('Name', nodeName);

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
