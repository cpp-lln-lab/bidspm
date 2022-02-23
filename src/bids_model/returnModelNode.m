function [node, iNode] = returnModelNode(model, nodeType)
  %
  % USAGE::
  %
  %   [node, iNode] = returnModelNode(model, nodeType)
  %
  %
  % (C) Copyright 2021 Remi Gau

  if ~ismember(lower(nodeType), {'run', 'subject', 'dataset'})
    msg = sprintf('Node type requested: %s.\nNode types can only be %s', ...
                  nodeType, ...
                  createUnorderedList({'run', 'subject', 'dataset'}));
    errorHandling(mfilename(), 'wrongNodeType', msg, false, true);
  end

  iNode = nan;
  node = {};

  nbNodes = numel(model.Nodes);

  if nbNodes == 1
    model.Nodes = {model.Nodes};
  end

  if iscell(model.Nodes)
    levels = cellfun(@(x) lower(x.Level), model.Nodes, 'UniformOutput', false);

  elseif isstruct(model.Nodes)
    levels = lower({model.Nodes.Level}');

  end

  idx = ismember(levels, lower(nodeType));

  if any(idx)

    if iscell(model.Nodes)
      node = model.Nodes{idx};
    elseif isstruct(model.Nodes)
      node = model.Nodes(idx);
    end

    iNode = find(idx);

  else
    msg = sprintf('could not find a model node of type %s', nodeType);
    errorHandling(mfilename(), 'missingModelNode', msg, false, true);

  end

end
