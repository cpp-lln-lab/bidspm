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

  args = inputParser;

  addRequired(args, 'opt', @isstruct);
  addRequired(args, 'subLabel', @ischar);
  addRequired(args, 'spmMatFile', @ischar);

  parse(args, varargin{:});

  status = false;

  % could be refactored with an equivalent function of group level result
  if ~(exist(args.Results.spmMatFile, 'file') == 2)

    status = true;

    msg = sprintf(['No SPM.mat found for subject %s in folder:\n%s\n', ...
                   'Run bidsFFX(''specify'', opt)\n'], ...
                  args.Results.subLabel, ...
                  spm_fileparts(args.Results.spmMatFile));
    errorHandling(mfilename(), 'noSpecifiedModel', msg, true, args.Results.opt.verbosity);

  end

end
