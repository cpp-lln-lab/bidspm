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
  % :returns: - :onsetTsvFile: (path)
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  p = inputParser;
  isFile = @(x) exist(x, 'file') == 2;
  addRequired(p, 'onsetsMatFile', isFile);
  parse(p, varargin{:});

  load(p.Results.onsetsMatFile, 'names', 'onsets', 'durations');

  tsvContent = struct('onset', [], 'duration', [], 'trial_type', {{}});

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

  onsetsTsvFile = spm_file(p.Results.onsetsMatFile, 'ext', '.tsv');

  bids.util.tsvwrite(onsetsTsvFile, tsvContent);

end

function someVector = transposeIfNecessary(someVector)
  if size(someVector, 2) > 1
    someVector = someVector';
  end
end
