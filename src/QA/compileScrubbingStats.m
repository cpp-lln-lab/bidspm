function compileScrubbingStats(statsFolder)
  %
  % Make a list of ``*_desc-confounds_timeseries.json``
  % and compile their results in a single tsv.
  %
  % USAGE::
  %
  %     compileScrubbingStats(statsFolder)
  %
  %

  % (C) Copyright 2023 Remi Gau

  files = spm_select('FPListRec', statsFolder, '.*_desc-confounds_timeseries\.json');

  output = struct('dir', [], 'file', [], ...
                  'NumberTimePoints', [],  'ProportionCensored', []);

  for i = 1:size(files, 1)

    thisFile = deblank(files(i, :));

    pth = spm_file(thisFile, 'path');
    pth = strsplit(pth, '/');
    output.dir{end + 1} = pth{end};

    output.file{end + 1} = spm_file(thisFile, 'basename');

    json = bids.util.jsondecode(thisFile);

    output.NumberTimePoints(end + 1) = json.NumberTimePoints;
    if isempty(json.ProportionCensored)
      json.ProportionCensored = nan;
    end
    output.ProportionCensored(end + 1) = json.ProportionCensored;
  end

  outputFilename = fullfile(statsFolder, 'desc-scrubbing_results.tsv');
  bids.util.tsvwrite(outputFilename, output);

end
