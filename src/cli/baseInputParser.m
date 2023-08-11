function args = baseInputParser()
  % Returns an input parser with the common arguments for all bids apps calls.
  %
  % Type ``bidspm help`` for more info.
  %

  % (C) Copyright 2023 bidspm developers
  args = inputParser;
  args.CaseSensitive = false;

  defaultAction = 'init';

  isLowLevelActionOrDir = @(x) (ismember(x, lowLevelActions()) || isdir(x));
  isChar = @(x) ischar(x);
  isCellStr = @(x) iscellstr(x);
  isFileOrStruct = @(x) isstruct(x) || exist(x, 'file') == 2;
  isPositiveScalar = @(x) isnumeric(x) && numel(x) == 1 && x >= 0;

  addOptional(args, 'bids_dir', pwd, isLowLevelActionOrDir);
  addOptional(args, 'output_dir', '', isChar);
  addOptional(args, 'analysis_level', 'subject', @(x) ismember(x, {'subject', 'dataset'}));

  addParameter(args, 'action', defaultAction, isChar);

  addParameter(args, 'participant_label', {}, isCellStr);
  addParameter(args, 'bids_filter_file', struct([]), isFileOrStruct);

  addParameter(args, 'verbosity', 2, isPositiveScalar);
  addParameter(args, 'options', struct([]), isFileOrStruct);

end
