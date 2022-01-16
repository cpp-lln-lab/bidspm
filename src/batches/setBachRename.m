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

  p = inputParser;
  
  isPatternReplaceStruct = @(x) isstruct(x) && all(ismember({'pattern', 'repl'}, fieldnames(x)));

  addRequired(p, 'matlabbatch', @iscell);
  addRequired(p, 'files', @iscell);
  addRequired(p, 'moveTo', @iscell);
  addRequired(p, 'patternReplace', isPatternReplaceStruct);
  addOptional(p, 'overwriteDuplicate', false, @islogical)

  parse(p, varargin{:});
  
  matlabbatch = p.Results.matlabbatch;
  files = p.Results.files;
  moveTo = p.Results.moveTo;
  patternReplace = p.Results.patternReplace;
  overwriteDuplicate = p.Results.overwriteDuplicate;

  file_move.files = files;
  
  file_move.action.moveren.moveto = moveTo;

  file_move.action.moveren.patrep = patternReplace;

  file_move.action.moveren.unique = overwriteDuplicate;

  matlabbatch{end + 1}.cfg_basicio.file_dir.file_ops.file_move = file_move;

end
