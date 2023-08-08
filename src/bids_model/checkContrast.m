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

  BidsModel.validate_constrasts(node);

  if ~ismember(lower(node.Level), {'run', 'session', 'subject'}) && ...
          ~isTtest(node.Contrasts(iCon))
    notImplemented(mfilename(), 'Only t test implemented for Contrasts');
    contrast = [];
    return
  end

  contrast = node.Contrasts{iCon};

end
