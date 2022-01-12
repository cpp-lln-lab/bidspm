function checkAllSessionsHaveSameNbRegressors(spmMatFile)
  %
  % USAGE::
  %
  %    checkAllSessionsHaveSameNbRegressors(spmMatFile)
  %
  % (C) Copyright 2022 CPP_SPM developers

  load(spmMatFile, 'SPM');

  nbRuns = numel(SPM.Sess);

  nbRegressorPerRun = [];
  for iRun = 1:nbRuns
    nbRegressorPerRun(iRun) = numel(SPM.Sess(iRun).col);
  end

  if numel(unique(nbRegressorPerRun)) > 1
    msg = sprintf('Runs have different number of regressort in SPM.mat:\n%s\n\n.', spmMatFile);
    id = 'differentNbRegressor';
    errorHandling(mfilename(), id, msg, false);
  end

end
