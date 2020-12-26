% (C) Copyright 2019 CPP BIDS SPM-pipeline developers
function conName = rmTrialTypeStr(conName)

  conName = strrep(conName, 'trial_type.', '');

end
