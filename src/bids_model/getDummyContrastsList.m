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


  if isfield(node.DummyContrasts, 'Contrasts')

    dummyContrastsList = node.DummyContrasts.Contrasts;

  else

    assert(checkGroupBy(node));
    
    switch lower(node.Level)

      case 'run'
        
        dummyContrastsList = node.Model.X;

      case 'subject'

        % TODO relax those assumptions
        % assumptions
        assert(node.Model.X == 1);

        sourceNode = getSourceNode(model, node.Name);

        % TODO transfer to BIDS model as a get_contrasts_list method
        if isfield(sourceNode.DummyContrasts, 'Contrasts')
          dummyContrastsList = sourceNode.DummyContrasts.Contrasts;
        end
        
        case 'dataset'
          
        % TODO relax those assumptions
        % assumptions
        assert(node.Model.X == 1);

        sourceNode = getSourceNode(model, node.Name);

        % TODO transfer to BIDS model as a get_contrasts_list method
        
        % get DummyContrasts from previous level otherwise we go one level deeper
        % Assumes a model run --> subject --> dataset
        if isfield(sourceNode.DummyContrasts, 'Contrasts') 
          dummyContrastsList = sourceNode.DummyContrasts.Contrasts;
          
          
        elseif model.get_design_matrix('Name', sourceNode.Name) == 1
          sourceNode = getSourceNode(model, sourceNode.Name);
          
          dummyContrasts = model.get_dummy_contrasts('Name', sourceNode.Name);
          dummyContrastsList = dummyContrasts.Contrasts;
          
        end   
        
        for i = 1:numel(dummyContrastsList)
          
          % contrasts against baseline are renamed at the subject level
          dummyContrastsList{i} = rmTrialTypeStr(dummyContrastsList{i});
          
        end

    end

  end

end
