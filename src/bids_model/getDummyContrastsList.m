function dummyContrastsList = getDummyContrastsList(model, node)
  %
  % Get list of names of DummyContrast from this Node or gets its from the
  % previous Nodes
  %
  % USAGE::
  %
  %   dummyContrastsList = getDummyContrastsList(model, mode)
  %
  % :param node: node name or node content
  % :type node: char or structure
  %
  % :param model:
  % :type model: BIDS stats model object
  %
  % :return: dummyContrastsList (cellstr)
  %

  % (C) Copyright 2022 bidspm developers

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

      case {'session', 'subject'}

        dummyContrastsList = getDummyContrastFromParentNode(model, node);

      case 'dataset'

        dummyContrastsList = getDummyContrastFromParentNode(model, node);

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
