function conImageFile = returnContrastImageFile(varargin)
  %
  % Return the contrast image file for the contrast name the user asked
  %
  % The search is regex based and any string (like 'foo') will be by default
  % regexified (into '^foo$').
  %
  % USAGE::
  %
  %     conImageFile = returnContrastImageFile(SPM, name, opt)
  %
  % :param SPM: fullpath to SPM.mat file or content of SPM.mat file
  % :type  SPM: structure or path
  %
  % :param name: name of the contrast of interest
  % :type  name: char
  %
  % :param opt: Options chosen.
  % :type  opt:  structure
  %
  % See also: printAvailableContrasts, getContrastNb
  %

  % (C) Copyright 2022 bidspm developers

  defaultOpt = struct('verbosity', 2);

  isStructOrFile = @(x) isstruct(x) || exist(x, 'file') == 2;

  args = inputParser;

  addRequired(args, 'SPM', isStructOrFile);
  addRequired(args, 'name', @ischar);
  addOptional(args, 'opt', defaultOpt, @istruct);

  parse(args, varargin{:});

  SPM = args.Results.SPM;
  if ~isstruct(SPM)
    SPM = load(SPM, 'SPM');
  end

  result.name = args.Results.name;
  opt = args.Results.opt;

  contrastNb = getContrastNb(result, opt, SPM);

  conImageFile = fullfile(SPM.swd, sprintf('con_%04.0f.nii', contrastNb));

end
