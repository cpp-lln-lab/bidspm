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

  SUPPORTED_TRANSFORMERS = {'Add', 'Subtract', 'Multiply', 'Divide', ...
                            'Filter', ...
                            'And', ...
                            'Rename', ...
                            'Delete', 'Select', ...
                            'Threshold'};

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
        [onset, duration] = applyTransformer(this_transformer, tsvContent,  inputs{i});
        newContent.(output{i}) = struct('onset', onset, 'duration', duration);
      end

    elseif ismember(lower(this_transformer.Name), {'rename', ...
                                                   'filter', ...
                                                   'and', 'or', ...
                                                   'delete', 'select', ...
                                                   'threshold'})
      tsvContent = applyTransformer(this_transformer, tsvContent);
      newContent = tsvContent;

    end

  end

end

function varargout = applyTransformer(transformer, tsvContent, inputs)

  if nargin < 3
    inputs = [];
  end

  transformerName = lower(transformer.Name);

  if ismember(transformerName, {'add', 'subtract', 'multiply', 'divide'})

    if iscell(inputs) && numel(inputs) == 1
      inputs = inputs{1};
    end

    tokens = regexp(inputs, '\.', 'split');

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

    switch transformerName

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

  %%
  inputs = getInput(transformer);
  outputs = getOutput(transformer);

  switch transformerName

    case 'filter'

      for i = 1:numel(inputs)

        tokens = regexp(inputs{i}, '\.', 'split');

        query = transformer.Query;
        if ~regexp(query, tokens{1})
          return
        end

        queryTokens = regexp(query, '==', 'split');
        if numel(queryTokens) > 1

          if iscellstr(tsvContent.(tokens{1}))
            idx = strcmp(queryTokens{2}, tsvContent.(tokens{1}));
          end

          if isnumeric(tsvContent.(tokens{1}))
            idx = tsvContent.(tokens{1}) == str2num(queryTokens{2});
          end

          tmp = zeros(size(tsvContent.onset));
          tmp(idx) = 1;
          tsvContent.(outputs{i}) = tmp;

        end

      end

      varargout = {tsvContent};

    case 'threshold'

      varargout = {threshold(transformer, tsvContent)};

    case 'rename'

      for i = 1:numel(inputs)
        tsvContent.(outputs{i}) = tsvContent.(inputs{i});
      end

      varargout = {tsvContent};

    case 'delete'

      for i = 1:numel(inputs)
        tsvContent = rmfield(tsvContent, inputs{i});
      end

      varargout = {tsvContent};

    case 'select'

      for i = 1:numel(inputs)
        tmp.(inputs{i}) = tsvContent.(inputs{i});
      end

      varargout = {tmp};

    case {'and', 'or'}

      for i = 1:numel(inputs)
        if iscellstr(tsvContent.(inputs{i}))
          tmp(:, i) = cellfun('isempty', tsvContent.(inputs{i}));
        else
          tmp(:, i) = logical(tsvContent.(inputs{i}));
        end
      end

      if strcmp(transformerName, 'and')
        tsvContent.(outputs{1}) = all(tmp, 2);
      elseif strcmp(transformerName, 'or')
        tsvContent.(outputs{1}) = any(tmp, 2);
      end

      varargout = {tsvContent};

    otherwise
      notImplemented(mfilename(), sprintf('Transformer %s not implemented', name), true);

  end

end

function tsvContent = threshold(transformer, tsvContent)

  inputs = getInput(transformer);
  outputs = getOutput(transformer);

  threshold = 0;
  binarize = false;
  above = true;
  signed = true;

  if isfield(transformer, 'Threshold')
    threshold = transformer.Threshold;
  end

  if isfield(transformer, 'Binarize')
    binarize = transformer.Binarize;
  end

  if isfield(transformer, 'Above')
    above = transformer.Above;
  end

  if isfield(transformer, 'Signed')
    signed = transformer.Signed;
  end

  for i = 1:numel(inputs)

    valuesToThreshold = tsvContent.(inputs{i});

    if ~signed
      valuesToThreshold = abs(valuesToThreshold);
    end

    if above
      idx = valuesToThreshold > threshold;
    else
      idx = valuesToThreshold < threshold;
    end

    tmp = zeros(size(tsvContent.(inputs{i})));
    tmp(idx) = tsvContent.(inputs{i})(idx);

    if binarize
      tmp(idx) = 1;
    end

    tsvContent.(outputs{i}) = tmp;
  end

end

function input = getInput(transformer)
  input = transformer.Input;
  if ~iscell(input)
    input = {input};
  end
end

function output = getOutput(transformer)
  if isfield(transformer, 'Output') && ~isempty(transformer.Output)
    output = transformer.Output;
    if ~iscell(output)
      output = {output};
    end
  else
    % will overwrite input columns
    output = getInput(transformer);
  end
end
