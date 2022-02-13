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

  SUPPORTED_TRANSFORMERS = {'Add', 'Subtract', 'Multiply', 'Divide', 'Filter', 'And'};

  p = inputParser;

  default_transformers = 'transformers';

  isStructOrCell = @(x) isstruct(x) || iscell(x);

  addRequired(p, 'tsvContent', @isstruct);
  addOptional(p, 'transformers', default_transformers, isStructOrCell);

  parse(p, varargin{:});

  tsvContent = p.Results.tsvContent;
  transformers = p.Results.transformers;

  if isempty(transformers) || isempty(tsvContent)
    newContent = struct([]);
    return
  end

  for iTrans = 1:numel(transformers)

    if iscell(transformers)
      this_transformer = transformers{iTrans};
    elseif isstruct(transformers)
      this_transformer = transformers(iTrans);
    end

    if ~ismember(this_transformer.Name, SUPPORTED_TRANSFORMERS)
      notImplemented(mfilename(), ...
                     sprintf('Transformer %s not implemented', this_transformer.Name), ...
                     true);
      return
    end

    inputs = getInput(this_transformer);
    output = getOutput(this_transformer);

    if ismember(lower(this_transformer.Name), {'add', 'subtract', 'multiply', 'divide'})
      for i = 1:numel(inputs)
        [onset, duration] = applyTransformer(this_transformer, inputs{i}, tsvContent);
        newContent.(output{i}) = struct('onset', onset, 'duration', duration);
      end

    elseif ismember(lower(this_transformer.Name), {'filter', 'and', 'or'})
      tsvContent = applyTransformer(this_transformer, inputs, tsvContent);
      newContent = tsvContent;
    end

  end

end

function varargout = applyTransformer(transformer, inputs, tsvContent)

  if iscell(inputs) && numel(inputs) == 1
    input = inputs{1};
  else
    input = inputs;
  end

  tokens = regexp(input, '\.', 'split');

  if ismember(lower(transformer.Name), {'add', 'subtract', 'multiply', 'divide'})

    % TODO assumes transformations are only on onsets
    % TODO assumes we are dealing with inputs from events TSV
    if numel(tokens) > 1 && ...
        ismember(tokens{1}, fieldnames(tsvContent)) && ...
        ismember(tokens{2}, unique(tsvContent.(tokens{1})))

      idx = find(strcmp(tokens{2}, tsvContent.(tokens{1})));

    else
      return

    end

    onset = tsvContent.onset(idx);
    duration = tsvContent.duration(idx);

    value = transformer.Value;

    switch lower(transformer.Name)

      case 'add'
        onset = onset + value;

      case 'subtract'
        onset = onset - value;

      case 'multiply'
        onset = onset * value;

      case 'divide'
        onset = onset / value;

    end

    varargout = {onset, duration};
    return

  end

  output = getOutput(transformer);

  switch lower(transformer.Name)

    case 'filter'

      query = transformer.Query;
      if ~regexp(query, tokens{1})
        return
      end

      queryTokens = regexp(query, '==', 'split');
      if numel(queryTokens) > 1

        tsvContent.(output{1}) = zeros(size(tsvContent.onset));

        if iscellstr(tsvContent.(tokens{1}))
          idx = strcmp(queryTokens{2}, tsvContent.(tokens{1}));
        end

        if isnumeric(tsvContent.(tokens{1}))
          idx = tsvContent.(tokens{1}) == str2num(queryTokens{2});
        end

        tsvContent.(output{1})(idx) = 1;

      end

      varargout = {tsvContent};

      %     case 'and'
      %       tokens

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
