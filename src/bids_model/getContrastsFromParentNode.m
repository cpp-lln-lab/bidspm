function contrastsList = getContrastsFromParentNode(model, node)
  %
  % Recursively look for contrasts at previous levels
  %
  % UISAGE::
  %
  %     contrastsList = getContrastsFromParentNode(model, node)
  %

  % (C) Copyright 2022 bidspm developers

  contrastsList = {};

  sourceNode = model.get_source_node(node.Name);

  if isempty(sourceNode)
    % we reached the root node
    return
  end

  % TODO transfer to BIDS model as a get_contrasts_list method
  if isfield(sourceNode, 'Contrasts') && ~isempty(sourceNode.Contrasts)
    for i = 1:numel(sourceNode.Contrasts)
      if isTtest(sourceNode.Contrasts{i}) % only contrast can be forwarded
        contrastsList{end + 1} = checkContrast(sourceNode, i);
      end
    end

    % go one level deeper
  elseif isnumeric(sourceNode.Model.X) && sourceNode.Model.X == 1
    contrastsList = getContrastsFromParentNode(model, sourceNode);

  end

end
