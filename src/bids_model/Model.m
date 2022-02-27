classdef Model
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  properties

    content = ''

    Name = 'REQUIRED'
    Description = 'RECOMMENDED'
    BIDSModelVersion = 'REQUIRED'
    Input = 'REQUIRED'
    Nodes = 'REQUIRED'
    Edges = 'RECOMMENDED'

  end

  properties (SetAccess = private)
    tolerant = true
    verbose = false

  end

  methods

    function obj = Model(varargin)

      args = inputParser;

      is_file = @(x) exist(x, 'file');

      args.addParameter('file', false, is_file);
      args.addParameter('tolerant', obj.tolerant, @islogical);
      args.addParameter('verbose', obj.verbose, @islogical);

      args.parse(varargin{:});

      obj.tolerant = args.Results.tolerant;
      obj.verbose = args.Results.verbose;

      if ~isempty(args.Results.file)

        obj;

        obj.content = bids.util.jsondecode(args.Results.file);

        if ~isfield(obj.content, 'Name')
          error('Name required');
        else
          obj.Name = obj.content.Name;
        end

        if isfield(obj.content, 'Description')
          obj.Description = obj.content.Description;
        end

        if ~isfield(obj.content, 'BIDSModelVersion')
          error('BIDSModelVersion required');
        else
          obj.BIDSModelVersion = obj.content.BIDSModelVersion;
        end

        if ~isfield(obj.content, 'Input')
          error('Input required');
        else
          obj.Input = obj.content.Input;
        end

        if ~isfield(obj.content, 'Nodes')
          error('Nodes required');
        else
          obj.Nodes = obj.content.Nodes;
        end

        obj;

        if isfield(obj.content, 'Edges')
          obj.Edges = obj.content.Edges;
          % TODO when no Edges assume all Nodes follow each other
        end
      end

    end

    %% Setters
    function obj = set.Name(obj, name)
      obj.Name = name;
    end

    function obj = set.Description(obj, desc)
      obj.Description = desc;
    end

    function obj = set.BIDSModelVersion(obj, version)
      obj.BIDSModelVersion = version;
    end

    function obj = set.Input(obj, input)
      obj.Input = input;
    end

    function obj = set.Nodes(obj, nodes)
      obj.Nodes = nodes;
    end

    function obj = set.Edges(obj, edges)
      obj.Edges = edges;
    end

    %% Getters
    function value = get.Name(obj)
      value = obj.Name;
    end

    function value = get.Input(obj)
      value = obj.Input;
    end

    function value = get.Nodes(obj)
      value = obj.Nodes;
    end

    function value = get_nodes(obj, varargin)
      if isempty(varargin)
        value = obj.Nodes;
      else

        value = {};

        allowed_levels = @(x) all(ismember(lower(x), {'run', 'session', 'subject', 'dataset'}));

        args = inputParser;
        args.addParameter('Level', '', allowed_levels);
        args.addParameter('Name', '');
        args.parse(varargin{:});

        Level = lower(args.Results.Level);
        if ~strcmp(Level, '')
          if ischar(Level)
            Level = {Level};
          end
          idx = cellfun(@(x) ismember(Level, lower(x.Level)), obj.Nodes, 'UniformOutput', false);
        end

        Name = lower(args.Results.Name);
        if ~strcmp(Name, '')
          if ischar(Name)
            Name = {Name};
          end
          idx = cellfun(@(x) ismember(Name, lower(x.Name)), obj.Nodes, 'UniformOutput', false);
        end

        % TODO merge idx when both Level and Name are passed as parameters
        idx = find(cellfun(@(x) x == 1, idx));
        for i = 1:numel(idx)
          value{end + 1} = obj.Nodes{idx};
        end

      end
    end

    %% Write
    function write(obj, filename)
      bids.util.mkdir(fileparts(filename));
      bids.util.jsonencode(filename, obj.content);
    end

  end

end
