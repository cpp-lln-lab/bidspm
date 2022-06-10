function matlabbatch = setBachRename(varargin)
  %
  %
  % USAGE::
  %
  %   matlabbatch = setBachRename(matlabbatch, files, moveTo, patternReplace, overwriteDuplicate)
  %
  %
  % :returns: - :matlabbatch: (cell) The matlabbatch ready to run the spm job
  %
  % (C) Copyright 2022 CPP_SPM developers

  args = inputParser;

  isPatternReplaceStruct = @(x) isstruct(x) && all(ismember({'pattern', 'repl'}, fieldnames(x)));

  addRequired(args, 'matlabbatch', @iscell);
  addRequired(args, 'files', @iscell);
  addRequired(args, 'moveTo', @iscell);
  addRequired(args, 'patternReplace', isPatternReplaceStruct);
  addOptional(args, 'overwriteDuplicate', false, @islogical);

  parse(args, varargin{:});

  matlabbatch = args.Results.matlabbatch;
  files = args.Results.files;
  moveTo = args.Results.moveTo;
  patternReplace = args.Results.patternReplace;
  overwriteDuplicate = args.Results.overwriteDuplicate;

  file_move.files = files;

  file_move.action.moveren.moveto = moveTo;

  file_move.action.moveren.patrep = patternReplace;

  file_move.action.moveren.unique = overwriteDuplicate;

  matlabbatch{end + 1}.cfg_basicio.file_dir.file_ops.file_move = file_move;

end
