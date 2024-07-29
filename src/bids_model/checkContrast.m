function contrast = checkContrast(model, node, iCon)
  %
  % Validates contrast specification
  %
  %
  % USAGE::
  %
  %     contrast = checkContrast(model, node, iCon)
  %
  %

  % TODO put some of that in bids.Model

  % (C) Copyright 2022 bidspm developers

  model.validate_constrasts(node);

  if ismember(lower(node.Level), {'session'}) && ~isTtest(node.Contrasts(iCon))
    notImplemented(mfilename(), 'Only t test implemented for Contrasts');
    contrast = [];
    return
  end

  contrast = node.Contrasts{iCon};

end
