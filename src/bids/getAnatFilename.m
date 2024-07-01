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
  %             See checkOptions.
  % :type  opt:  structure
  %
  % :return: :anatImage: (string)
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

    msg = sprintf('No anat file for:\n%s\n\n', ...
                  bids.internal.create_unordered_list(filter));

    id = 'noAnatFile';
    if tolerant
      logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);
    else
      logger('ERROR', msg, 'id', id, 'filename', mfilename(), 'options', opt);
    end

  end

  if numel(anat) > nbImgToReturn

    tmp = anat(1:nbImgToReturn);
    tmp = strrep(tmp, [BIDS.pth filesep], '');
    tmp = bids.internal.format_path(tmp);
    msg = sprintf(['More than %i anat file in:\n%s.', ...
                   '\n\nFound: %i.\nTaking the first %i:%s'], ...
                  nbImgToReturn, ...
                  bids.internal.format_path(BIDS.pth), ...
                  numel(anat), ...
                  nbImgToReturn, ...
                  bids.internal.create_unordered_list(tmp));
    id = 'severalAnatFile';
    logger('WARNING', msg, 'id', id, 'filename', mfilename());
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

  msg = sprintf('  selecting anat file: %s', ...
                bids.internal.create_unordered_list(bids.internal.format_path(anat)));
  logger('DEBUG', msg, 'options', opt, 'filename', mfilename());

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
                  bids.internal.create_unordered_list(availableSuffixes));
    id = 'requestedSuffixUnvailable';
    if tolerant
      logger('WARNING', msg, 'id', id, 'filename', mfilename());
    else
      logger('ERROR', msg, 'id', id, 'filename', mfilename());
    end

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
                    bids.internal.create_unordered_list(sessions));
      id = 'requestedSessionUnvailable';
      if tolerant
        logger('WARNING', msg, 'id', id, 'filename', mfilename());
      else
        logger('ERROR', msg, 'id', id, 'filename', mfilename());
      end

    end

  else
    anatSession = sessions;

  end

  if  ~iscell(anatSession)
    anatSession = {anatSession};
  end

end
