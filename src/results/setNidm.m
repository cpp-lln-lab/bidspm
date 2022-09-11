function export = setNidm(export, result)
  %
  % Handles the NIDM results aspect of the result batches
  %
  % USAGE::
  %
  %   export = setNidm(export, result)
  %
  %
  % (C) Copyright 2019 bidspm developers

  if result.nidm

    nidm.modality = 'FMRI';

    if strcmp(result.space, 'individual')
      nidm.refspace = 'subject';

    elseif isMni(result.space)
      if strcmp(result.space, 'IXI549Space')
        nidm.refspace = 'ixi';
      else
        nidm.refspace = 'mni';
      end

    else
      [~, allowedSpaces] = isMni(result.space);
      msg = sprintf(['Unknown space for NIDM resuts "%s".\n', ...
                     'Allowed spaces are:\n'], result.space, strjoin(allowedSpaces));
      id = 'unknownNidmSpace';
      errorHandling(mfilename(), id, msg, false, true);

    end

    % TODO this needs fixing for between group contrasts
    nidm.group(1).nsubj = result.nbSubj;
    nidm.group(1).label = result.label;

    export{end + 1}.nidm = nidm;

  end

end
