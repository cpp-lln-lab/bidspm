function printProcessingSubject(iSub, subLabel, opt)
  %
  % USAGE::
  %
  %  printProcessingSubject(iSub, subLabel, opt)
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  msg = sprintf([ ...
                 ' PROCESSING SUBJECT No.: %i ' ...
                 'SUBJECT LABEL : %s \n'], ...
                iSub, subLabel);

  printToScreen(msg, opt, 'format', '*blue');

end
