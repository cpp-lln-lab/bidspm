function conName = rmTrialTypeStr(conName)
  %
  % (C) Copyright 2019 CPP_SPM developers

  conName = strrep(conName, 'trial_type.', '');

end
