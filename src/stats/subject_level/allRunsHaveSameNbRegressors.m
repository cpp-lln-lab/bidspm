function allRunsHaveSameNbRegressors(spmMat)
  %
  % USAGE::
  %
  %    allRunsHaveSameNbRegressors(spmMatFile)

  % (C) Copyright 2022 bidspm developers
  if isstruct(spmMat)
    SPM = spmMat;
  elseif exist(spmMat, 'file')
    load(spmMat, 'SPM');
  end

  nbRuns = numel(SPM.Sess);

  nbRegressorPerRun = [];
  for iRun = 1:nbRuns
    nbRegressorPerRun(iRun) = numel(SPM.Sess(iRun).col);
  end

  if numel(unique(nbRegressorPerRun)) > 1
    msg = sprintf('Runs have different number of regressors in SPM.mat:\n%s\n\n.', spmMat);
    id = 'differentNbRegressor';
    logger('ERROR', msg, 'id', id, 'filename', mfilename);
  end

end
