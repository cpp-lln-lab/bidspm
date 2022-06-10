function regressorsTsvFile = regressorsMatToTsv(varargin)
  %
  % Takes an SPM _desc-confounds_regressors.mat file
  % and converts it to a _desc-confounds_regressors.tsv file.
  %
  % USAGE::
  %
  %   regressorsTsvFile = regressorsMatToTsv(regressorsMatFile)
  %
  % :param regressorsMatFile: obligatory argument.
  % :type regressorsMatFile: fullpath
  %
  % :returns: - :regressorsTsvFile: (path)
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  args = inputParser;
  isFile = @(x) exist(x, 'file') == 2;
  addRequired(args, 'regressorsMatFile', isFile);
  parse(args, varargin{:});

  load(args.Results.regressorsMatFile, 'names', 'R');

  tsvContent = struct();

  for iReg = 1:numel(names) %#ok<*USENS>
    tsvContent.(names{iReg}) = R(:, iReg); %#ok<*NODEF>
  end

  regressorsTsvFile = spm_file(args.Results.regressorsMatFile, 'ext', '.tsv');

  bids.util.tsvwrite(regressorsTsvFile, tsvContent);

end
