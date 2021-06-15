function printProcessingSubject(iSub, subLabel, opt)
  %
  % (C) Copyright 2019 CPP_SPM developers

  msg = sprintf([ ...
                 ' PROCESSING SUBJECT No.: %i ' ...
                 'SUBJECT ID : %s \n'], ...
                iSub, subLabel);

  printToScreen(msg, opt);

end
