function volumes = returnVolumeList(varargin)
  %
  % USAGE::
  %
  %   volumes = returnVolumeList(opt, boldFile)
  %
  % :param opt:
  % :type opt: structure
  % :param boldFile:
  % :type boldFile: fullpath
  %
  % :returns: - :volumes: (cell string)
  %
  % (C) Copyright 2022 CPP_SPM developers

  p = inputParser;

  isFile = @(x) exist(x, 'file');

  addRequired(p, 'opt', @isstruct);
  addRequired(p, 'boldFile', isFile);

  parse(p, varargin{:});

  opt = p.Results.opt;
  boldFile = p.Results.boldFile;

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
