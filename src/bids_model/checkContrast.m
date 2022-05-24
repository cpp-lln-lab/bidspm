function contrast = checkContrast(node, iCon)
  %
  % Validates contrast specification
  %
  % put some of that in bids.Model
  %
  % USAGE::
  %
  %     contrast = checkContrast(node, iCon)
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  if ~ismember(lower(node.Level), {'run', 'subject'}) && ~isTtest(node.Contrasts(iCon))
    notImplemented(mfilename(), ...
                   'Only t test implemented for Contrasts', ...
                   true);
    contrast = [];
    return
  end

  contrast = node.Contrasts(iCon);
  if iscell(contrast)
    contrast = contrast{1};
  end

  if ~isfield(contrast, 'Weights')
    msg = sprintf('No weights specified for Contrast %s of Node %s', ...
                  node.Contrasts(iCon).Name, node.Name);
    errorHandling(mfilename, 'weightsRequired', msg, false);
  end

  if numel(contrast.Weights) ~= numel(contrast.ConditionList)
    msg = sprintf('Number of Weights and Conditions unequal for Contrast %s of Node %s', ...
                  node.Contrasts(iCon).Name, node.Name);
    errorHandling(mfilename, 'numelWeightsConditionMismatch', msg, false);
  end

end
