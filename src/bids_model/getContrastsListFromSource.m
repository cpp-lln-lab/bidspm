function contrastsList = getContrastsListFromSource(node, model)
  %
  % Recursively look for contrasts at previous levels
  %
  % UISAGE::
  %
  %     contrastsList = getContrastsListFromSource(node, model)
  %

  % (C) Copyright 2022 bidspm developers

  contrastsList = {};

  sourceNode = model.get_source_node(node.Name);

  if isempty(sourceNode)
    % we reached the root node
    return
  end

  % TODO transfer to BIDS model as a get_contrasts_list method
  if isfield(sourceNode, 'Contrasts')
    for i = 1:numel(sourceNode.Contrasts)
      if isTtest(sourceNode.Contrasts{i}) % only contrast can be forwarded
        contrastsList{end + 1} = checkContrast(sourceNode, i);
      end
    end

    % go one level deeper
  elseif isnumeric(sourceNode.Model.X) && sourceNode.Model.X == 1
    contrastsList = getContrastsListFromSource(sourceNode, model);

  end

end
