function status = allRunsHaveSameNbConfounds(varargin)
  %
  % USAGE::
  %
  %   status = checkAllSessionsHaveSameNbConfounds(spmSess, opt)
  %
  % :param spmSess: obligatory argument.
  % :type spmSess: cell
  % :param opt: obligatory argument.
  % :type opt: structure
  %
  % :returns: - :status: (boolean)
  %
  % (C) Copyright 2022 CPP_SPM developers

  isSpmSessStruct = @(x) isstruct(x) && isfield(x, 'counfoundMatFile');

  p = inputParser;
  addRequired(p, 'spmSess', isSpmSessStruct);
  addRequired(p, 'opt', @isstruct);
  parse(p, varargin{:});
  spmSess = p.Results.spmSess;
  opt = p.Results.opt;

  status = true;

  if ~opt.glm.useDummyRegressor
    return
  end

  matFiles  = {spmSess.counfoundMatFile}';
  nbConfounds = [];
  for iRun = 1:numel(matFiles)
    load(matFiles{iRun}, 'names');
    nbConfounds(iRun) = numel(names);
  end

  if numel(unique(nbConfounds)) > 1
    status = false;
  end

end
