function newContent = applyTransformersToEventsTsv(varargin)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   newContent = applyTransformersToEventsTsv(tsvContent, transformers)
  %
  % :param tsvContent:
  % :type tsvContent: structure
  % :param transformers:
  % :type transformers: structure
  %
  % :returns: - :newContent: (structure)
  %
  % Example::
  %
  % (C) Copyright 2022 CPP_SPM developers

  SUPPORTED_TRANSFORMERS = {'Add', 'Subtract', 'Multiply', 'Divide', 'Filter'};

  p = inputParser;

  default_transformers = 'transformers';

  addRequired(p, 'tsvContent', @isstruct);
  addOptional(p, 'transformers', default_transformers, @isstruct);

  parse(p, varargin{:});

  tsvContent = p.Results.tsvContent;
  transformers = p.Results.transformers;

  if isempty(transformers) || isempty(tsvContent)
    newContent = struct([]);
    return
  end

  for iTrans = 1:numel(transformers)

    % TODO make transformers more general
    % - assumes inputs can only be from TSV?
    %   (therefore means that transformations cannot be "chained")
    % - assumes transformations are only on onsets
    if ~ismember(transformers(iTrans).Name, SUPPORTED_TRANSFORMERS)
      notImplemented(mfilename(), ...
                     sprintf('Transformer %s not implemented', transformers(iTrans).Name), ...
                     true);
      newContent = struct([]);
      return
    end

    inputs = getInput(transformers(iTrans));
    output = getOutput(transformers(iTrans));

    for i = 1:numel(inputs)
      [onset, duration] = applyTransformer(transformers(iTrans), inputs{i}, tsvContent);
      newContent.(output{i}) = struct('onset', onset, 'duration', duration);
    end

  end

end

function [onset, duration] = applyTransformer(transformer, inputs, tsvContent)

  if iscell(inputs) && numel(inputs) == 1
    input = inputs{1};
  elseif ischar(inputs)
    input = inputs;
  end

  tokens = regexp(input, '\.', 'split');

  % mostly assuming we are dealing with inputs from events TSV
  if numel(tokens) > 1 && ...
      ismember(tokens{1}, fieldnames(tsvContent)) && ...
      ismember(tokens{2}, unique(tsvContent.(tokens{1})))

    idx = find(strcmp(tokens{2}, tsvContent.(tokens{1})));
    onset = tsvContent.onset(idx);
    duration = tsvContent.duration(idx);

  end

  switch lower(transformer.Name)

    case 'add'
      value = transformer.Value;
      onset = onset + value;

    case 'subtract'
      value = transformer.Value;
      onset = onset - value;

    case 'multiply'
      value = transformer.Value;
      onset = onset * value;

    case 'divide'
      value = transformer.Value;
      onset = onset / value;

    case 'filter'

      onset = zeros(size(tsvContent.onset));
      duration = [];

      query = transformer.Query;
      if ~regexp(query, tokens{1})
        return
      end

      queryTokens = regexp(query, '==', 'split');
      if numel(queryTokens) > 1

        if iscellstr(tsvContent.(tokens{1}))
          idx = strcmp(queryTokens{2}, tsvContent.(tokens{1}));
          onset(idx) = 1;
        end

        if isnumeric(tsvContent.(tokens{1}))
          idx = tsvContent.(tokens{1}) == str2num(queryTokens{2});
          onset(idx) = 1;
        end

      end

    otherwise
      notImplemented(mfilename(), sprintf('Transformer %s not implemented', name), true);

  end

end

function input = getInput(transformer)
  input = transformer.Input;
  if ~iscell(input)
    input = {input};
  end
end

function output = getOutput(transformer)
  output = {};
  if isfield(transformer, 'Output') && ~isempty(transformer.Output)
    output = transformer.Output;
    if ~iscell(output)
      output = {output};
    end
  end
end
