function onsetsTsvFile = onsetsMatToTsv(varargin)
  %
  % Takes an SPM _onset.mat file and converts it to a _onsets.mat file.
  %
  % Onsets are assumed to be in seconds.
  %
  % USAGE::
  %
  %   onsetTsvFile = onsetMatToTsv(onsetMatFile)
  %
  % :param onsetMatFile: obligatory argument.
  % :type onsetMatFile: fullpath
  %
  % :return: :onsetTsvFile: (path)
  %
  %

  % (C) Copyright 2022 bidspm developers

  args = inputParser;
  isFile = @(x) exist(x, 'file') == 2;
  addRequired(args, 'onsetsMatFile', isFile);
  parse(args, varargin{:});

  load(args.Results.onsetsMatFile, 'names', 'onsets', 'durations');

  tsvContent = struct('onset', [], 'duration', [], 'trial_type', {{}});

  if numel(names) == 0
    return
  end

  for iCond = 1:numel(names)
    tsvContent.trial_type = cat(1, tsvContent.trial_type, ...
                                repmat(names(iCond), numel(durations{iCond}), 1)); %#ok<*USENS>
    tsvContent.onset = cat(1, tsvContent.onset, transposeIfNecessary(onsets{iCond}));
    tsvContent.duration = cat(1, tsvContent.duration, transposeIfNecessary(durations{iCond}));
  end

  % Sort the onsets in right chronological order
  % and apply to other columns
  [tsvContent.onset, idx] = sort(tsvContent.onset);
  tsvContent.trial_type = tsvContent.trial_type(idx);
  tsvContent.duration = tsvContent.duration(idx);

  onsetsTsvFile = spm_file(args.Results.onsetsMatFile, 'ext', '.tsv');

  bids.util.tsvwrite(onsetsTsvFile, tsvContent);

end

function someVector = transposeIfNecessary(someVector)
  if size(someVector, 2) > 1
    someVector = someVector';
  end
end
