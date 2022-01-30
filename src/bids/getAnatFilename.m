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

  % TODO try to channel this function via getInfo ?

  if isfield(opt, 'taskName')
    opt = rmfield(opt, 'taskName');
  end

  opt.query.modality = 'anat';

  if isfield(opt.query, 'ses')
    opt.query = rmfield(opt.query, 'ses');
  end

  checkAvailableSuffix(BIDS, subLabel, opt.bidsFilterFile.t1w.suffix);
  anatSession = checkAvailableSessions(BIDS, subLabel, opt, opt.bidsFilterFile.t1w.ses);

  filter = opt.bidsFilterFile.t1w;
  filter.extension = '.nii';
  filter.prefix = '';
  if isfield(opt.query, 'desc')
    filter.desc = opt.query.desc;
  end

  % get all anat images for that subject fo that type
  anat = bids.query(BIDS, 'data', filter);

  if isempty(anat)

    msg = sprintf('No anat file for:\n- subject: %s\n- session: %s\n- type: %s.', ...
                  subLabel, ...
                  char(anatSession), ...
                  opt.bidsFilterFile.t1w.suffix);

    errorHandling(mfilename(), 'noAnatFile', msg, false, opt.verbosity);

  end

  % TODO we take the first image of that suffix/session as the right one.
  % it could be required to take another one, or several and mean them...
  if numel(anat) > 1
    msg = sprintf('More than one anat file found:%s\n\nTaking the first one:\n\n %s', ...
                  createUnorderedList(anat), ...
                  anat{1});
    errorHandling(mfilename(), 'severalAnatFile', msg, true, opt.verbosity);
  end
  anat = anat{1};
  anatImage = unzipAndReturnsFullpathName(anat);

  msg = sprintf('selecting anat file: %s\n', anat);
  printToScreen(msg, opt);

  [anatDataDir, anatImage, ext] = spm_fileparts(anatImage);
  anatImage = [anatImage ext];
end

function checkAvailableSuffix(BIDS, subLabel, anatType)

  availableSuffixes = bids.query(BIDS, 'suffixes', ...
                                 'sub', subLabel);

  if ~strcmp(anatType, availableSuffixes)

    msg = sprintf(['Requested anatomical suffix %s unavailable for subject %s.'...
                   ' All available types:\n%s'], ...
                  anatType, ...
                  subLabel, ...
                  createUnorderedList(availableSuffixes));

    errorHandling(mfilename(), 'requestedSuffixUnvailable', msg, false, false);

  end

end

function anatSession = checkAvailableSessions(BIDS, subLabel, opt, anatSession)

  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');

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
