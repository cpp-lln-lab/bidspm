function printAvailableContrasts(varargin)
  %
  % USAGE::
  %
  %     printAvailableContrasts(SPM, opt)
  %
  % :param SPM: fullpath to SPM.mat file or content of SPM.mat file
  % :type  SPM: structure or path
  %
  % :param opt: Options chosen.
  % :type  opt:  structure
  %
  % See also: returnContrastImageFile, getContrastNb
  %

  % (C) Copyright 2019 bidspm developers

  defaultOpt = struct('verbosity', 2);

  isStructOrFile = @(x) isstruct(x) || exist(x, 'file') == 2;

  args = inputParser;

  addRequired(args, 'SPM', isStructOrFile);
  addOptional(args, 'opt', defaultOpt, @isstruct);

  parse(args, varargin{:});

  SPM = args.Results.SPM;
  if ~isstruct(SPM)
    load(SPM, 'SPM');
  end

  opt = args.Results.opt;

  printToScreen('List of contrast in this SPM file\n', opt);
  printToScreen(createUnorderedList({SPM.xCon.name}), opt);
  printToScreen('\n', opt);

end
