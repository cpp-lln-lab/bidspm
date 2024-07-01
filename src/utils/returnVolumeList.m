function volumes = returnVolumeList(varargin)
  %
  % USAGE::
  %
  %   volumes = returnVolumeList(opt, boldFile)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See checkOptions.
  % :param boldFile:
  % :type boldFile: fullpath
  %
  % :return: :volumes: (cell string)
  %

  % (C) Copyright 2022 bidspm developers

  args = inputParser;

  isFile = @(x) exist(x, 'file');

  addRequired(args, 'opt', @isstruct);
  addRequired(args, 'boldFile', isFile);

  parse(args, varargin{:});

  opt = args.Results.opt;
  boldFile = args.Results.boldFile;

  if opt.glm.maxNbVols == Inf && isempty(opt.funcVolToSelect)

    volumes = {boldFile};

  else

    if opt.glm.maxNbVols ~= Inf
      volToSelect = 1:opt.glm.maxNbVols;
    elseif ~isempty(opt.funcVolToSelect)
      volToSelect = opt.funcVolToSelect;
    else
      error('WTF');
    end

    volumes = cellstr(spm_select('ExtFPList', ...
                                 spm_fileparts(boldFile), ...
                                 spm_file(boldFile, 'filename'), ...
                                 volToSelect));

  end

end
