function matlabbatch = setBatchRenameSegmentParameter(varargin)
  %
  %
  % USAGE::
  %
  %   matlabbatch = setBachRenameSegmentParameter(matlabbatch, opt)
  %
  % :param matlabbatch: matlabbatch to append to.
  % :type  matlabbatch: cell
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See  also: checkOptions
  %
  %
  % :returns: - :matlabbatch: (cell) The matlabbatch ready to run the spm job
  %
  % (C) Copyright 2022 CPP_SPM developers

  args = inputParser;

  addRequired(args, 'matlabbatch', @iscell);
  addRequired(args, 'opt', @isstruct);

  parse(args, varargin{:});

  matlabbatch = args.Results.matlabbatch;
  opt = args.Results.opt;

  printBatchName('rename segmentation parameter file', opt);

  cfg_fileparts.files(1) = cfg_dep('Segment: Seg Params', ...
                                   returnDependency(opt, 'segment'), ...
                                   substruct('.', 'param', '()', {':'}));

  matlabbatch{end + 1}.cfg_basicio.file_dir.cfg_fileparts = cfg_fileparts;

  files = cfg_dep('Segment: Seg Params', ...
                  returnDependency(opt, 'segment'), ...
                  substruct('.', 'param', '()', {':'}));

  moveTo = cfg_dep('Get Pathnames: Directories (unique)', ...
                   substruct('.', ...
                             'val', '{}', {numel(matlabbatch)}, '.', ...
                             'val', '{}', {1}, '.', ...
                             'val', '{}', {1}), ...
                   substruct('.', 'up'));

  % TODO: adapt in case suffix is not T1w
  patternReplace(1).pattern = 'T1w';
  patternReplace(1).repl = 'label-T1w';
  patternReplace(2).pattern = 'seg8';
  patternReplace(2).repl = 'segparam';

  matlabbatch = setBachRename(matlabbatch, files, moveTo, patternReplace);

end
