function status = noSPMmat(varargin)
  %
  % USAGE::
  %
  %   status = noSPMmat(opt, subLabel, spmMatFile)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See checkOptions.
  % :param subLabel:
  % :type subLabel: char
  % :param spmMatFile:
  % :type spmMatFile: path
  %
  % :returns: - :status: (boolean)
  %

  % (C) Copyright 2022 bidspm developers

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
                  bids.internal.format_path(spm_fileparts(args.Results.spmMatFile)));
    id = 'noSpecifiedModel';
    logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', args.Results.opt);

  end

end
