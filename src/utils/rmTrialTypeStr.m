function cdtName = rmTrialTypeStr(cdtName)
  %
  % removes the leading "trial_type." prefix from a string
  %
  % USAGE::
  %
  %   cdtName = rmTrialTypeStr(cdtName)
  %
  % :param cdtName: name of the condition
  % :type cdtName: char
  %
  % (C) Copyright 2019 CPP_SPM developers

  if iscell(cdtName)
    if numel(cdtName) > 1
      msg = sprintf('cell string input must have only 1 element. This one has: %i', ...
                    numel(cdtName));
      errorHandling(mfilename(), 'tooManyInputs', msg, false);
    end
    cdtName = cdtName{1};
  end

  if startsWith(cdtName, 'trial_type.')
    cdtName = strrep(cdtName, 'trial_type.', '');
  end

end
