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

  trialTypes = tsvContent.trial_type;
  trialTypesList = unique(trialTypes);

  for iTrans = 1:numel(transformers)

    % TODO make transformers more general
    % - assumes only trial types can be input
    %   (therefore means that transformations cannot be "chained")
    % - assumes transformations are only on onsets
    name = transformers(iTrans).Name;
    if ~ismember(name, SUPPORTED_TRANSFORMERS)
      notImplemented(mfilename(), sprintf('Transformer %s not implemented', name), true);
      newContent = struct([]);
      return
    end

    input = transformers(iTrans).Input;
    if ~iscell(input)
      input = {input};
    end

    if isfield(transformers(iTrans), 'Output') && ~isempty(transformers(iTrans).Output)
      output = transformers(iTrans).Output;
    end

    for i = 1:numel(input)

      % assume that we are dealing with column header if there is a "." in input
      if isColumnHeader(input{i})

        tokens = regexp(input{i}, '\.', 'split');

        if strcmp(tokens{1}, 'trial_type') && ismember(tokens{2}, trialTypesList)
          idx = find(strcmp(rmTrialTypeStr(input{i}), trialTypes));
          onsets = tsvContent.onset(idx);
        end

      end

      switch lower(name)

        case 'add'
          value = transformers(iTrans).Value;
          onsets = onsets + value;

        case 'subtract'
          value = transformers(iTrans).Value;
          onsets = onsets - value;

        case 'multiply'
          value = transformers(iTrans).Value;
          onsets = onsets * value;

        case 'divide'
          value = transformers(iTrans).Value;
          onsets = onsets / value;

        otherwise
          notImplemented(mfilename(), sprintf('Transformer %s not implemented', name), true);

      end

      newContent.(output{i}) = struct('onset', onsets, 'duration', tsvContent.duration(idx));

    end

  end

end

function status = isColumnHeader(someString)
  %
  % rough guess that we are dealing with something that comes from a TSV
  %

  status = ismember('.', someString);

end
