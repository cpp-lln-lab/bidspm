function conName = rmTrialTypeStr(conName)
  %
  % (C) Copyright 2019 CPP_SPM developers

  if iscell(conName)
    conName = conName{1};
  end

  conName = strrep(conName, 'trial_type.', '');

end
