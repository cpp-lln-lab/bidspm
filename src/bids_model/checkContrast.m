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
  % (C) Copyright 2022 bidspm developers

  bids.Model.validate_constrasts(node);

  if ~ismember(lower(node.Level), {'run', 'subject'}) && ~isTtest(node.Contrasts(iCon))
    notImplemented(mfilename(), ...
                   'Only t test implemented for Contrasts', ...
                   true);
    contrast = [];
    return
  end

  contrast = node.Contrasts{iCon};

end
