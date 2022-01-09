function status = noSPMmat(varargin)
  %
  % USAGE::
  %
  %   status = noSPMmat(opt, subLabel, spmMatFile)
  %
  % :param opt:
  % :type opt: structure
  % :param subLabel:
  % :type subLabel: string
  % :param spmMatFile:
  % :type spmMatFile: path
  %
  % :returns: - :status: (boolean)
  %
  % (C) Copyright 2022 CPP_SPM developers

  p = inputParser;

  addRequired(p, 'opt', @isstruct);
  addRequired(p, 'subLabel', @ischar);
  addRequired(p, 'spmMatFile', @ischar);

  parse(p, varargin{:});

  status = false;

  if ~(exist(p.Results.spmMatFile, 'file') == 2)

    status = true;

    msg = sprintf(['No SPM.mat found for subject %s in folder:\n%s\n', ...
                   'Run bidsFFX(''specify'', opt)\n'], ...
                  p.Results.subLabel, ...
                  spm_fileparts(p.Results.spmMatFile));
    errorHandling(mfilename(), 'noSpecifiedModel', msg, true, p.Results.opt.verbosity);

  end

end
