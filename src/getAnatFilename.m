function [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel)
  %
  % Get the filename and the directory of an anat file for a given session and run.
  % Unzips the file if necessary.
  %
  % It several images are available it will take the first one it finds.
  %
  % USAGE::
  %
  %   [anatImage, anatDataDir] = getAnatFilename(BIDS, subLabel, opt)
  %
  % :param BIDS:
  % :type BIDS:         structure
  % :param subLabel:
  % :param subLabel:    string
  % :type opt:
  % :param opt:         structure
  %
  % :returns: - :anatImage: (string)
  %           - :anatDataDir: (string)
  %
  % (C) Copyright 2020 CPP_SPM developers

  anatSuffix = opt.anatReference.type;
  anatSession = opt.anatReference.session;

  checkAvailableSuffix(BIDS, subLabel, anatSuffix);
  anatSession = checkAvailableSessions(BIDS, subLabel, opt, anatSession);

  % get all anat images for that subject fo that type
  anat = bids.query(BIDS, 'data', ...
                    'sub', subLabel, ...
                    'ses', anatSession, ...
                    'suffix', anatSuffix);

  if isempty(anat)

    msg = sprintf('No anat file for the subject: %s / session: %s/ type: %s.', ...
                  subLabel, ...
                  anatSession, ...
                  anatSuffix);

    errorHandling(mfilename(), 'noAnatFile', msg, false, false);

  end

  % TODO
  % we take the first image of that suffix/session as the right one.
  % it could be required to take another one, or several and mean them...
  anat = anat{1};
  anatImage = unzipImgAndReturnsFullpathName(anat);

  [anatDataDir, anatImage, ext] = spm_fileparts(anatImage);
  anatImage = [anatImage ext];
end

function checkAvailableSuffix(BIDS, subLabel, anatType)

  availableSuffixes = bids.query(BIDS, 'suffixes', ...
                                 'sub', subLabel);

  if ~strcmp(anatType, availableSuffixes)

    disp(availableSuffixes);

    msg = sprintf(['Requested anatomical suffix %s unavailable for subject %s.'...
                   ' All available types listed above.'], anatType);

    errorHandling(mfilename(), 'requestedSuffixUnvailable', msg, false, false);

  end

end

function anatSession = checkAvailableSessions(BIDS, subLabel, opt, anatSession)

  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');

  if ~isempty(anatSession)

    if all(~strcmp(anatSession, sessions))

      disp(sessions);

      msg = sprintf(['Requested session %s for anatomical unavailable for subject %s.', ...
                     ' All available sessions listed above.'], ...
                    anatSession, ...
                    subLabel);

      errorHandling(mfilename(), 'requestedSessionUnvailable', msg, false, false);

    end

  else
    anatSession = sessions;

  end

end
