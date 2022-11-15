function iSess = getSessionForRegressorNb(regIdx, SPM)
  %
  % Use the SPM Sess index for the contrast name
  %
  % USAGE::
  %
  %     iSess = getSessionForRegressorNb(regIdx, SPM)
  %
  %

  % (C) Copyright 2022 bidspm developers

  % TODO could be optimized

  for iSess = 1:numel(SPM.Sess)
    if ismember(regIdx, SPM.Sess(iSess).col)
      break
    end
  end
end
