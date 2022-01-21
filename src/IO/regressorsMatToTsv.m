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

  p = inputParser;
  isFile = @(x) exist(x, 'file') == 2;
  addRequired(p, 'regressorsMatFile', isFile);
  parse(p, varargin{:});

  load(p.Results.regressorsMatFile, 'names', 'R');

  tsvContent = struct();

  for iReg = 1:numel(names) %#ok<*USENS>
    tsvContent.(names{iReg}) = R(:, iReg); %#ok<*NODEF>
  end

  regressorsTsvFile = spm_file(p.Results.regressorsMatFile, 'ext', '.tsv');

  bids.util.tsvwrite(regressorsTsvFile, tsvContent);

end
