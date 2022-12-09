function [anatImage, anatDataDir] = getAnatFilename(varargin)
  %
  % Get the filename and the directory of some anat files for a given session and run.
  % Unzips the files if necessary.
  %
  % It several images are available it will take the first one it finds.
  %
  % USAGE::
  %
  %   [anatImage, anatDataDir] = getAnatFilename(BIDS, subLabel, opt, nbImgToReturn, tolerant)
  %
  % :param BIDS: dataset layout.
  %              See also: bids.layout, getData.
  % :type  BIDS: structure
  %
  % :param subLabel:
  % :type  subLabel:  char
  %
  % :param opt: Options chosen for the analysis.
  %             See also: ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type  opt:  structure
  %
  % :returns: - :anatImage: (string)
  %           - :anatDataDir: (string)
  %

  % (C) Copyright 2020 bidspm developers

  % TODO try to channel this function via getInfo ?

  args = inputParser;

  addRequired(args, 'BIDS', @isstruct);
  addRequired(args, 'opt', @isstruct);
  addRequired(args, 'subLabel', @ischar);
  addOptional(args, 'nbImgToReturn', 1);
  addOptional(args, 'tolerant', false, @islogical);

  parse(args, varargin{:});

  BIDS = args.Results.BIDS;
  opt = args.Results.opt;
  subLabel = args.Results.subLabel;
  nbImgToReturn = args.Results.nbImgToReturn;
  tolerant = args.Results.tolerant;

  checkAvailableSuffix(BIDS, subLabel, opt.bidsFilterFile.t1w, tolerant);
  if isfield(opt.bidsFilterFile.t1w, 'ses')
    checkAvailableSessions(BIDS, subLabel, opt.bidsFilterFile.t1w, tolerant);
  end

  filter = opt.bidsFilterFile.t1w;
  filter.extension = '.nii';
  filter.prefix = '';
  filter.sub = regexify(subLabel);

  % get all anat images for that subject fo that type
  anat = bids.query(BIDS, 'data', filter);

  if isempty(anat)

    msg = sprintf('No anat file for:\n%s\n\n', createUnorderedList(filter));

    errorHandling(mfilename(), 'noAnatFile', msg, tolerant, opt.verbosity);

  end

  if numel(anat) > nbImgToReturn
    msg = sprintf('More than %i anat file. Found: %i.\n\nTaking the first %i:%s\n', ...
                  nbImgToReturn, ...
                  numel(anat), ...
                  nbImgToReturn, ...
                  createUnorderedList(pathToPrint(anat(1:nbImgToReturn))));
    id = 'severalAnatFile';
    logger('WARNING', msg, 'id', id, 'filename', mfilename);
  end

  anatDataDir = '';
  anatImage = '';
  if isempty(anat)
    return
  end

  if nbImgToReturn == 1
    anat = anat{1};
  elseif nbImgToReturn == Inf
  else
    anat = anat(1:nbImgToReturn);
  end

  anatImage = unzipAndReturnsFullpathName(anat);

  msg = sprintf('  selecting anat file: %s', createUnorderedList(pathToPrint(anat)));
  logger('INFO', msg, 'options', opt, 'filaneme', mfilename);

  tmpDir = {};
  tmpImage = {};
  for iFile = 1:size(anatImage, 1)
    [tmpDir{end + 1, 1}, name, ext] = spm_fileparts(anatImage(iFile, :)); %#ok<*AGROW>
    tmpImage{end + 1, 1} = [name ext];
  end
  anatDataDir = tmpDir;
  anatImage = tmpImage;

  if size(anatImage, 1) == 1
    anatDataDir = char(anatDataDir);
    anatImage = char(anatImage);
  end

end

function checkAvailableSuffix(BIDS, subLabel, filter, tolerant)

  anatSuffixes = filter.suffix;

  filter = rmfield(filter, 'suffix');
  if isfield(filter, 'ses')
    filter = rmfield(filter, 'ses');
  end
  filter.sub = subLabel;
  availableSuffixes = bids.query(BIDS, 'suffixes', filter);

  containsSuffix = regexp(availableSuffixes, regexify(anatSuffixes), 'match');

  if all(cellfun('isempty', containsSuffix))

    msg = sprintf(['Requested anatomical suffix %s unavailable for subject %s.'...
                   '\nAll available suffixes:\n%s'], ...
                  anatSuffixes, ...
                  subLabel, ...
                  createUnorderedList(availableSuffixes));

    errorHandling(mfilename(), 'requestedSuffixUnvailable', msg, tolerant, false);

  end

end

function anatSession = checkAvailableSessions(BIDS, subLabel, filter, tolerant)

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
                     '\nAll available sessions:\n%s.'], ...
                    anatSession, ...
                    subLabel, ...
                    createUnorderedList(sessions));

      errorHandling(mfilename(), 'requestedSessionUnvailable', msg, tolerant, false);

    end

  else
    anatSession = sessions;

  end

  if  ~iscell(anatSession)
    anatSession = {anatSession};
  end

end
