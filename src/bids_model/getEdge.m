function edge = getEdge(bm, field, value)
  %
  % USAGE::
  %
  %     edge = getEdge(bm, field, value)
  %
  %
  % field can be any of {'Source', 'Destination'}
  %
  % (C) Copyright 2022 CPP_SPM developers

  if ~ismember(field, {'Source', 'Destination'})
    error('Can only query Edges based on Source or Destination');
  end

  % TODO transfer to BIDS model as a get_source method
  if isempty(bm.Edges)
    bm = bm.get_edges_from_nodes;
  end

  for i = 1:numel(bm.Edges)
    if strcmp(bm.Edges{i}.(field), value)
      edge = bm.Edges{i};
      break
    end
  end

end
