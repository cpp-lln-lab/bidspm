% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function printProcessingSubject(groupName, iSub, subID)

  fprintf(1, [ ...
              ' PROCESSING GROUP: %s' ...
              'SUBJECT No.: %i ' ...
              'SUBJECT ID : %s \n'], ...
          groupName, iSub, subID);

end
