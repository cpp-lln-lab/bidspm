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

  checkAvailableSuffix(BIDS, opt, subLabel, anatSuffix);
  anatSession = checkAvailableSessions(BIDS, subLabel, opt, anatSession);

  query =  struct('sub', subLabel, ...
                  'suffix', anatSuffix, ...
                  'extension', '.nii', ...
                  'prefix', '');
  if ~cellfun('isempty', anatSession)
    query.ses = anatSession;
  end
  if isfield(opt.query, 'desc')
    query.desc = opt.query.desc;
  end
  if isfield(opt.query, 'space')
    query.space = opt.query.space;
    if strcmp(query.space, 'MNI')
      query.space = 'IXI549Space';
    end
  end

  % get all anat images for that subject fo that type
  anat = bids.query(BIDS, 'data', query);

  if isempty(anat)

    msg = sprintf('No anat file for:\n- subject: %s\n- session: %s\n- type: %s.', ...
                  subLabel, ...
                  char(anatSession), ...
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

function checkAvailableSuffix(BIDS, opt, subLabel, anatType)

  availableSuffixes = bids.query(BIDS, 'suffixes', ...
                                 'sub', subLabel);

  if ~strcmp(anatType, availableSuffixes)

    printToScreen(strjoin(availableSuffixes, '; '), opt);

    msg = sprintf(['Requested anatomical suffix %s unavailable for subject %s.'...
                   ' All available types listed above.'], anatType);

    errorHandling(mfilename(), 'requestedSuffixUnvailable', msg, false, false);

  end

end

function anatSession = checkAvailableSessions(BIDS, subLabel, opt, anatSession)

  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');

  if ~isempty(anatSession)

    if all(~strcmp(anatSession, sessions))

      printToScreen(strjoin(sessions, '; '), opt);

      msg = sprintf(['Requested session %s for anatomical unavailable for subject %s.', ...
                     ' All available sessions listed above.'], ...
                    anatSession, ...
                    subLabel);

      errorHandling(mfilename(), 'requestedSessionUnvailable', msg, false, false);

    end

  else
    anatSession = sessions;

  end

  if  ~iscell(anatSession)
    anatSession = {anatSession};
  end

end
