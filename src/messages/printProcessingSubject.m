function printProcessingSubject(iSub, subLabel, opt)
  %
  % USAGE::
  %
  %  printProcessingSubject(iSub, subLabel, opt)
  %
  %

  % (C) Copyright 2019 bidspm developers

  msg = sprintf(['PROCESSING SUBJECT No.: %i ' ...
                 'SUBJECT LABEL : %s'], ...
                iSub, subLabel);

  logger('INFO', msg, 'options', opt, 'filaneme', mfilename);

end
