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

    input = getInput(transformers(iTrans));
    output = getOutput(transformers(iTrans));

    for i = 1:numel(input)

      [onset, duration] = applyTransformer(transformers(iTrans), input{i}, tsvContent);

      newContent.(output{i}) = struct('onset', onset, 'duration', duration);

    end

  end

end

function [onset, duration] = applyTransformer(transformer, input, tsvContent)

  if isColumnHeader(input, tsvContent)

    % if we are dealing with column header and there is a "." in input
    tokens = regexp(input, '\.', 'split');

    if strcmp(tokens{1}, 'trial_type')

      if numel(tokens) > 1 &&  ismember(tokens{2}, unique(tsvContent.trial_type))
        idx = find(strcmp(tokens{2}, tsvContent.trial_type));
        onset = tsvContent.onset(idx);
      end
    end

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
      query = transformer.Query;
      if ~regexp(query, tokens{1})
        return
      end
      if ~isempty(regexp(query, '==', 'match')) && iscellstr(tsvContent.(tokens{1}))
        queryTokens = regexp(query, '==', 'split');
        idx = strcmp(queryTokens{2}, tsvContent.(tokens{1}));
        onset = tsvContent.onset(idx);
      end

    otherwise
      notImplemented(mfilename(), sprintf('Transformer %s not implemented', name), true);

  end

  duration = tsvContent.duration(idx);

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

function status = isColumnHeader(someString, tsvContent)
  %
  % rough guess that we are dealing with something that comes from a TSV
  %

  status = ismember('.', someString) || ismember(someString, fieldnames(tsvContent));

end
