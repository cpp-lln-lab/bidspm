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
  % :type BIDS:      structure
  %
  % :param subLabel:
  % :param subLabel:  char
  %
  % :type opt:
  % :param opt:      structure
  %
  % :returns: - :anatImage: (string)
  %           - :anatDataDir: (string)
  %
  % (C) Copyright 2020 CPP_SPM developers

  % TODO try to channel this function via getInfo ?

  checkAvailableSuffix(BIDS, subLabel, opt.bidsFilterFile.t1w);
  if isfield(opt.bidsFilterFile.t1w, 'ses')
    checkAvailableSessions(BIDS, subLabel, opt.bidsFilterFile.t1w);
  end

  filter = opt.bidsFilterFile.t1w;
  filter.extension = '.nii';
  filter.prefix = '';
  filter.sub = subLabel;

  % get all anat images for that subject fo that type
  anat = bids.query(BIDS, 'data', filter);

  if isempty(anat)

    msg = sprintf('No anat file for:\n%s\n\n', createUnorderedList(filter));

    errorHandling(mfilename(), 'noAnatFile', msg, false, opt.verbosity);

  end

  % TODO we take the first image of that suffix/session as the right one.
  % it could be required to take another one, or several and mean them...
  if numel(anat) > 1
    msg = sprintf('More than one anat file found:%s\n\nTaking the first one:\n\n %s\n', ...
                  createUnorderedList(pathToPrint(anat)), ...
                  pathToPrint(anat{1}));
    errorHandling(mfilename(), 'severalAnatFile', msg, true, opt.verbosity);
  end
  anat = anat{1};
  anatImage = unzipAndReturnsFullpathName(anat);

  msg = sprintf('  selecting anat file: %s\n', pathToPrint(anat));
  printToScreen(msg, opt);

  [anatDataDir, anatImage, ext] = spm_fileparts(anatImage);
  anatImage = [anatImage ext];
end

function checkAvailableSuffix(BIDS, subLabel, filter)

  anatSuffixes = filter.suffix;

  filter = rmfield(filter, 'suffix');
  filter.sub = subLabel;
  availableSuffixes = bids.query(BIDS, 'suffixes', filter);

  if ~strcmp(anatSuffixes, availableSuffixes)

    msg = sprintf(['Requested anatomical suffix %s unavailable for subject %s.'...
                   ' All available suffixes:\n%s'], ...
                  anatSuffixes, ...
                  subLabel, ...
                  createUnorderedList(availableSuffixes));

    errorHandling(mfilename(), 'requestedSuffixUnvailable', msg, false, false);

  end

end

function anatSession = checkAvailableSessions(BIDS, subLabel, filter)

  anatSession = filter.ses;

  filter = rmfield(filter, 'ses');
  filter.sub = subLabel;
  sessions = bids.query(BIDS, 'sessions', filter);
  if numel(sessions) == 0
    sessions = {''};
  end

  if ~isempty(anatSession)

    if all(~strcmp(anatSession, sessions))

      msg = sprintf(['Requested session %s for anatomical unavailable for subject %s.', ...
                     ' All available sessions:\n%s.'], ...
                    anatSession, ...
                    subLabel, ...
                    createUnorderedList(sessions));

      errorHandling(mfilename(), 'requestedSessionUnvailable', msg, false, false);

    end

  else
    anatSession = sessions;

  end

  if  ~iscell(anatSession)
    anatSession = {anatSession};
  end

end
