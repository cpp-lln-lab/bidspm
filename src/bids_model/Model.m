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

    % function obj = set.Edges(obj, edges)
    %   edges
    %   obj.Edges = edges;
    % end

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

    % function obj = get.Edges(obj)
    %   value = obj.Edges;
    % end

  end

end
