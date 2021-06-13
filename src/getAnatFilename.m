function [anatImage, anatDataDir] = getAnatFilename(BIDS, subLabel, opt)
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
                    'sub',subLabel, ...
                    'ses',anatSession, ...
                    'type',anatSuffix);

  if isempty(anat)

    msgID = 'noAnatFile';

    msg = sprintf('No anat file for the subject: %s / session: %s/ type: %s.', ...
                  subLabel, ...
                  anatSession, ...
                  anatSuffix);

    getAnatError(msgID, msg);

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

  availableSuffixes = bids.query(BIDS, 'types', ...
                                 'sub', subLabel);

  if ~strcmp(anatType, availableSuffixes)

    disp(availableSuffixes);

    msgID = 'requestedSuffixUnvailable';
    msg = sprintf(['Requested anatomical suffix %s unavailable for subject %s.'...
                   ' All available types listed above.'], anatType);

    getAnatError(msgID, msg);

  end

end

function anatSession = checkAvailableSessions(BIDS, subLabel, opt, anatSession)

  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');

  if ~isempty(anatSession)

    if all(~strcmp(anatSession, sessions))

      disp(sessions);

      msgID = 'requestedSessionUnvailable';
      msg = sprintf(['Requested session %s for anatomical unavailable for subject %s.', ...
                     ' All available sessions listed above.'], ...
                    anatSession, ...
                    subLabel);

      getAnatError(msgID, msg);

    end

  else
    anatSession = sessions;

  end

end

function getAnatError(msgID, msg)

  errorStruct.identifier = sprintf('getAnatFilename:%s', msgID);
  errorStruct.message = msg;
  error(errorStruct);

end
