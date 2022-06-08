function dummyContrastsList = getDummyContrastsList(node, model)
  %
  % Get list of names of DummyContrast from this Node or gets its from the
  % previous Nodes
  %
  % USAGE::
  %
  %   dummyContrastsList = getDummyContrastsList(node, model)
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

  dummyContrastsList = {};

  if ischar(node)
    node = model.get_nodes('Name', node);
    if isempty(node)
      return
    end
  end

  if isfield(node.DummyContrasts, 'Contrasts')

    dummyContrastsList = node.DummyContrasts.Contrasts;

  else

    assert(checkGroupBy(node));

    switch lower(node.Level)

      case 'run'

        dummyContrastsList = node.Model.X;

      case 'subject'

        dummyContrastsList = getFromPreviousNode(model, node);

      case 'dataset'

        dummyContrastsList = getFromPreviousNode(model, node);

        for i = 1:numel(dummyContrastsList)

          % contrasts against baseline are renamed at the subject level
          tokens = regexp(dummyContrastsList{i}, '\.', 'split');
          if numel(tokens) > 1
            dummyContrastsList{i} = tokens{2};
          end

        end

    end

  end

end

function dummyContrastsList = getFromPreviousNode(model, node)

  % base case: we reach the root of the BIDS model graph
  % and there is no dummy contrasts anywhere
  % Note: this assumes the root is a Run level node
  if strcmp(node.Level, 'Run')
    dummyContrastsList = {};
    return
  end

  % TODO relax those assumptions
  % assumptions
  assert(node.Model.X == 1);

  sourceNode = model.get_source_node(node.Name);

  % TODO transfer to BIDS model as a get_contrasts_list method
  if isfield(sourceNode, 'DummyContrasts') && isfield(sourceNode.DummyContrasts, 'Contrasts')
    dummyContrastsList = sourceNode.DummyContrasts.Contrasts;
  else
    dummyContrastsList = getFromPreviousNode(model, sourceNode);
  end

end
