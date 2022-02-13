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
                            'And', 'Or', ...
                            'Rename', ...
                            'Delete', 'Select', 'Constant', 'Copy', ...
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

    if ismember(lower(this_transformer.Name), {'add', 'subtract', 'multiply', 'divide'})

      tsvContent = applyTransformer(this_transformer, tsvContent);
      newContent = tsvContent;

    else

      tsvContent = applyTransformer(this_transformer, tsvContent);
      newContent = tsvContent;

    end

  end

end

function varargout = applyTransformer(transformer, tsvContent)

  transformerName = lower(transformer.Name);

  inputs = getInput(transformer);
  outputs = getOutput(transformer);

  switch transformerName

    case {'add', 'subtract', 'multiply', 'divide'}

      varargout = {basicTransformers(transformer, tsvContent)};

    case 'filter'

      varargout = {filterTransformer(transformer, tsvContent)};

    case 'threshold'

      varargout = {thresholdTransformer(transformer, tsvContent)};

    case 'rename'

      for i = 1:numel(inputs)
        tsvContent.(outputs{i}) = tsvContent.(inputs{i});
        tsvContent = rmfield(tsvContent, inputs{i});
      end

      varargout = {tsvContent};

    case 'constant'

      value = 1;
      if isfield(transformer, 'Value')
        value = transformer.Value;
      end

      tsvContent.(outputs{1}) = ones(size(tsvContent.onset)) * value;

      varargout = {tsvContent};

    case 'copy'

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

      varargout = {andOrTransformer(transformer, tsvContent)};

    otherwise
      notImplemented(mfilename(), ...
                     sprintf('Transformer %s not implemented', transformer.Name), ...
                     true);

  end

end

function tsvContent = basicTransformers(transformer, tsvContent)

  inputs = getInput(transformer);
  outputs = getOutput(transformer);

  transformerName = lower(transformer.Name);

  for i = 1:numel(inputs)

    value = transformer.Value;

    switch transformerName

      case 'add'
        tmp = tsvContent.(inputs{i}) + value;

      case 'subtract'
        tmp = tsvContent.(inputs{i}) - value;

      case 'multiply'
        tmp = tsvContent.(inputs{i}) * value;

      case 'divide'
        tmp = tsvContent.(inputs{i}) / value;

    end

    tsvContent.(outputs{i}) = tmp;

  end

end

function tsvContent = filterTransformer(transformer, tsvContent)

  inputs = getInput(transformer);
  outputs = getOutput(transformer);

  if isfield(transformer, 'By')
    % TODO
    by = transformer.By;
  end

  for i = 1:numel(inputs)

    tokens = regexp(inputs{i}, '\.', 'split');

    query = transformer.Query;
    if isempty(regexp(query, tokens{1}, 'ONCE'))
      return
    end

    queryTokens = regexp(query, '==', 'split');
    if numel(queryTokens) > 1

      if iscellstr(tsvContent.(tokens{1}))
        idx = strcmp(queryTokens{2}, tsvContent.(tokens{1}));
        tmp(idx, 1) = tsvContent.(tokens{1})(idx);
        tmp(~idx, 1) = repmat({''}, sum(~idx), 1);
      end

      if isnumeric(tsvContent.(tokens{1}))
        idx = tsvContent.(tokens{1}) == str2num(queryTokens{2});
        tmp(idx, 1) = tsvContent.(tokens{1})(idx);
        tmp(~idx, 1) = nan;
      end

      tmp(idx, 1) = tsvContent.(tokens{1})(idx);
      tsvContent.(outputs{i}) = tmp;

    end

  end

end

function tsvContent = andOrTransformer(transformer, tsvContent)

  inputs = getInput(transformer);
  outputs = getOutput(transformer);

  for i = 1:numel(inputs)

    if iscellstr(tsvContent.(inputs{i}))
      tmp(:, i) = cellfun('isempty', tsvContent.(inputs{i}));

    else
      tmp2 = tsvContent.(inputs{i});
      tmp2(isnan(tmp2)) = 0;
      tmp(:, i) = logical(tmp2);

    end

  end

  switch lower(transformer.Name)
    case 'and'
      tsvContent.(outputs{1}) = all(tmp, 2);
    case 'or'
      tsvContent.(outputs{1}) = any(tmp, 2);
  end

end

function tsvContent = thresholdTransformer(transformer, tsvContent)

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

  if isfield(transformer, 'Input') && ~isempty(transformer.Input)
    input = transformer.Input;
  else
    input = {};
  end

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
