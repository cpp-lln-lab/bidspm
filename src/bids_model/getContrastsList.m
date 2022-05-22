function contrastsList = getContrastsList(node, model)
  %
  % Get list of names of Contrast from this Node or gets its from the
  % previous Nodes
  %
  % USAGE::
  %
  %   contrastsList = getContrastsList(node, model)
  %
  % :param node: node name or node content
  % :type node: char or structure
  %
  % :param model:
  % :type model: BIDS stats model object
  %
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  contrastsList = {};

  if ischar(node)
    node = model.get_nodes('Name', node);
    if isempty(node)
      return
    end
  end

  if iscell(node)
    node = node{1};
  end

  if isfield(node, 'Contrasts')

    for i = 1:numel(node.Contrasts)
      contrastsList{end + 1} = checkContrast(node, i);
    end

  else

    switch lower(node.Level)

      case 'subject'

        % TODO relax those assumptions

        % assumptions
        assert(checkGroupBy(node));
        assert(node.Model.X == 1);

        sourceNode = getSourceNode(model, node.Name);

        % TODO transfer to BIDS model as a get_contrasts_list method
        if isfield(sourceNode, 'Contrasts')
          for i = 1:numel(sourceNode.Contrasts)
            contrastsList{end + 1} = checkContrast(sourceNode, i);
          end
        end

      case 'dataset'

        % TODO relax those assumptions

        % assumptions
        assert(checkGroupBy(node));
        assert(node.Model.X == 1);

        sourceNode = getSourceNode(model, node.Name);

        % TODO transfer to BIDS model as a get_contrasts_list method
        if isfield(sourceNode, 'Contrasts')
          for i = 1:numel(sourceNode.Contrasts)
            contrastsList{end + 1} = checkContrast(sourceNode, i);
          end

          % go one level deeper
        elseif sourceNode.Model.X == 1
          sourceNode = getSourceNode(model, sourceNode.Name);

          for i = 1:numel(sourceNode.Contrasts)
            contrastsList{end + 1} = checkContrast(sourceNode, i);
          end

        end

    end

  end

end
