function contrastsList = getContrastsList(model, node, extraVar)
  %
  % Get list of names of Contrast from this Node
  % or gets its from the previous Nodes
  %
  % USAGE::
  %
  %   contrastsList = getContrastsList(model, node)
  %
  % :param node: node name or node content
  % :type node: char or structure
  %
  % :param model:
  % :type model: BIDS stats model object
  %
  % :return: contrastsList (cellstr)
  %

  % (C) Copyright 2022 bidspm developers

  if nargin < 3
    extraVar = {};
  end

  contrastsList = {};

  if ischar(node)
    node = model.get_nodes('Name', node);
    if isempty(node)
      return
    end
  end

  % check current Node
  if isfield(node, 'Contrasts')

    for i = 1:numel(node.Contrasts)
      contrastsList{end + 1} = checkContrast(model, node, i); %#ok<*AGROW>
    end

    % check previous Nodes recursively
  else

    switch lower(node.Level)

      case {'subject', 'dataset'}

        % TODO relax those assumptions

        % assumptions
        assert(checkGroupBy(node, extraVar));
        assert(node.Model.X == 1);

        contrastsList = getContrastsFromParentNode(model, node);

    end

  end

end
