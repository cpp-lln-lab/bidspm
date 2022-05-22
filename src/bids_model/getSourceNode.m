function sourceNode = getSourceNode(bm, destinationName)
  % (C) Copyright 2022 CPP_SPM developers

  % TODO transfer to BIDS model as a get_source method
  if ~isfield(bm, 'Edges') || isempty(bm.Edges)
    bm = bm.get_edges_from_nodes;
  end

  for i = 1:numel(bm.Edges)
    if strcmp(bm.Edges{i}.Destination, destinationName)
      source = bm.Edges{i}.Source;
      break
    end
  end

  sourceNode = bm.get_nodes('Name', source);

  if iscell(sourceNode)
    sourceNode = sourceNode{1};
  end

end
