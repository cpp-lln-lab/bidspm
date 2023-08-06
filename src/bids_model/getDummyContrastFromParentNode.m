function dummyContrastsList = getDummyContrastFromParentNode(model, node)
  %
  % USAGGE::
  %
  %   dummyContrastsList = getDummyContrastFromParentNode(model, node)
  %
  % :param node:
  % :type  node: struct
  %
  % :param model:
  % :type  model: BidsModel object
  %

  % (C) Copyright 2023 bidspm developers

  % Base case: we reach the root of the BIDS model graph
  % and there is no dummy contrasts anywhere before.
  % Note: this assumes the root is a Run level node
  if strcmp(node.Level, 'Run')
    dummyContrastsList = {};
    return
  end

  sourceNode = model.get_source_node(node.Name);

  % TODO transfer to BIDS model as a get_contrasts_list method
  if isfield(sourceNode, 'DummyContrasts') && isfield(sourceNode.DummyContrasts, 'Contrasts')
    dummyContrastsList = sourceNode.DummyContrasts.Contrasts;
  else
    dummyContrastsList = getDummyContrastFromParentNode(model, sourceNode);
  end

  filter = getFilter(model, sourceNode.Name, node.Name);
  if ~isempty(filter)
    if iscell(dummyContrastsList{1})
      toKeep = ismember(dummyContrastsList{1}, filter.contrast);
      dummyContrastsList(1) = dummyContrastsList{1}(toKeep);
    else
      toKeep = ismember(dummyContrastsList, filter.contrast);
      dummyContrastsList = dummyContrastsList(toKeep);
    end

  end

end

function filter = getFilter(model, source, destination)
  filter = {};
  edge = model.get_edge('Destination', destination);
  assert(strcmpi(edge.Source, source));
  if isfield(edge, 'Filter')
    filter = edge.Filter;
  end
end
