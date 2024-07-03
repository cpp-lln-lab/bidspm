function contrastName = constructContrastNameFromBidsEntity(cdtName, SPM, iSess)
  %
  % Try using bids ses and run info saved in the SPM to build a contrast name.
  %
  % USAGE::
  %
  %   contrastName = constructContrastNameFromBidsEntity(cdtName, SPM, iSess)
  %
  % If no information is foun
  % it falls back on using the the SPM session number
  %
  % :param SPM: content of SPM.mat
  % :type  SPM: struct
  %
  % :param cdtName: contrast basename
  % :type  cdtName: char
  %
  % :param iSess: SPM session
  % :type  iSess: int
  %

  % (C) Copyright 2022 bidspm developers
  ses = '';
  if isfield(SPM.Sess(iSess), 'ses')
    ses = SPM.Sess(iSess).ses;
  end
  run = '';
  if isfield(SPM.Sess(iSess), 'run')
    run = SPM.Sess(iSess).run;
  end

  contrastName = cdtName;
  if ~isempty(ses)
    contrastName = [contrastName '_ses-' ses];
  end
  if ~isempty(run)
    contrastName = [contrastName '_run-' run];
  end
  if isempty(ses) && isempty(run)
    contrastName =  [cdtName, '_', num2str(iSess)];
  end
end
