function  [cdtName, regIdx, status] = getRegressorIdx(cdtName, SPM, bidsSes)
  %
  % Gets from the SPM structure the regressors index corresponding
  % to the a condition convolved with the canonical HRF.
  % This can also look for non convolved conditions
  % to identify a confound regressor.
  %
  % Throws a warning if there is no regressor for that condition.
  %
  % USAGE::
  %
  %   [cdtName, regIdx, status] = getRegressorIdx(cdtName, SPM)
  %
  % :param cdtName: name of the condition to look for
  % :type  cdtName: char or cellstr
  %
  % :param SPM: content of SPM.mat
  % :type  SPM: structure
  %
  % :param bidsSes: bids session label
  % :type  bidsSes: char
  %
  % :returns:
  %
  % - :cdtName: (char) name of the condition stripped of any eventual
  %             ``'trial_type.'`` prefix
  % - :regIdx:  (logical) vector of the columns of the design matrix
  %             containing the regressor of interest
  % - :status:  (logical) is ``false`` if no regressor was found for that
  %             condition
  %
  %

  % (C) Copyright 2022 bidspm developers

  if nargin < 3
    bidsSes = '';
  end

  % in case the condition is of something like trial_type.foo
  tokens = regexp(cdtName, '\.', 'split');
  if numel(tokens) > 1
    cdtName = tokens{2};
  end

  % construct regexp pattern
  convolvedWithCanonicalHRF = ['^.* (' cdtName '\*bf\(1\))$'];
  nonConvolved = ['^.* ' cdtName '$'];

  pattern = [convolvedWithCanonicalHRF '|' nonConvolved];

  regIdx = regexp(SPM.xX.name', pattern, 'match');
  regIdx = ~cellfun('isempty', regIdx);

  if ~isempty(bidsSes)
    sessToKeep = ismember({SPM.Sess.ses}, bidsSes);
    columsnToKeep = cat(2, SPM.Sess(sessToKeep).col);
    tmp = false(size(regIdx));
    tmp(columsnToKeep) = regIdx(columsnToKeep);
    regIdx = tmp;
    clear tmp;
  end

  status = checkRegressorFound(regIdx, cdtName);

end

function status = checkRegressorFound(regIdx, cdtName)

  status = true;
  regIdx = find(regIdx);

  if all(~regIdx)
    status = false;
    msg = sprintf('No regressor found for condition "%s"', deregexify(cdtName));
    id = 'missingRegressor';
    logger('WARNING', msg, 'id', id, 'filename', mfilename());
  end

end
