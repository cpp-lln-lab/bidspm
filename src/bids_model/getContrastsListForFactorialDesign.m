function contrastsList = getContrastsListForFactorialDesign(opt, nodeName)
  %
  % assuming a GroupBy that contains at least "contrast"
  %
  % we try to grab the contrasts list from the Edge.Filter
  % otherwise we dig in this in Node
  % or the previous one to find the list of contrasts
  %
  % USAGE::
  %
  %   contrastsList = getContrastsListForFactorialDesign(opt, nodeName)
  %
  %

  % (C) Copyright 2022 bidspm developers

  % assuming we want to only average / comparisons at the group level
  participants = bids.util.tsvread(fullfile(opt.dir.raw, 'participants.tsv'));

  bm = opt.model.bm;

  groupGlmType =  bm.groupLevelGlmType(nodeName, participants);

  if ismember(groupGlmType, {'one_sample_t_test', 'one_way_anova'})

    edge = bm.get_edge('Destination', nodeName);

    if isfield(edge, 'Filter') && ...
        isfield(edge.Filter, 'contrast')  && ...
        ~isempty(edge.Filter.contrast)

      contrastsList = edge.Filter.contrast;

    else

      % this assumes DummyContrasts exist
      contrastsList = getDummyContrastsList(bm, nodeName, participants);

      node = bm.get_nodes('Name', nodeName);

      % if no specific dummy contrasts mentioned also include all contrasts from previous levels
      % or if contrasts are mentioned we grab them
      if ~isfield(node.DummyContrasts, 'Contrasts') || isfield(node, 'Contrasts')
        tmp = getContrastsList(bm, nodeName, columns);
        for i = 1:numel(tmp)
          contrastsList{end + 1} = tmp{i}.Name;
        end
      end

    end

  else

    commonMsg = sprintf('for the dataset level node: "%s"', nodeName);
    msg = sprintf(['Models other than group average / comparisons ', ...
                   'not implemented yet %s'], commonMsg);
    notImplemented(mfilename(), msg, opt);

    contrastsList = {};

  end

end
