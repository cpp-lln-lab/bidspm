function dummyContrastsList = getDummyContrastsList(node, model)
  %
  % Get list of names of cummyContrast from this Node or gets its from the
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
  % nodeName
  %
  % :returns: - :matlabbatch: (structure)
  %
  % (C) Copyright 2022 CPP_SPM developers

  dummyContrastsList = {};

  if ischar(node)
    node = model.get_nodes('Name', node);
    if isempty(node)
      return
    end
  end

  if iscell(node)
    node = node{1};
  end

  lower(node.Level);

  if isfield(node.DummyContrasts, 'Contrasts')

    dummyContrastsList = node.DummyContrasts.Contrasts;

  else

    switch lower(node.Level)

      case 'run'
        % TODO this assumes "GroupBy": ["run", "subject"] or ["run", "session", "subject"]
        dummyContrastsList = node.Model.X;

      case 'subject'

        % TODO relax those assumptions

        % assumptions
        assert(checkGroupBy(node));
        assert(node.Model.X == 1);

        sourceNode = getSourceNode(model, node.Name);

        % TODO transfer to BIDS model as a get_contrasts_list method
        if isfield(sourceNode.DummyContrasts, 'Contrasts')
          dummyContrastsList = sourceNode.DummyContrasts.Contrasts;
        end

    end

  end

end
