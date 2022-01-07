function status = isTtest(structure)
  %
  % (C) Copyright 2021 Remi Gau

  status = true;
  if isfield(structure, 'Test') && ~strcmp(structure.Test, 't')
    status = false;
    msg = 'Only t test supported for contrasts';
    errorHandling(mfilename(), 'notImplemented', msg, true, true);
  end
end
