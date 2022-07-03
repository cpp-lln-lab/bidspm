function copyFigures(BIDS, opt, subLabel)
  %
  % Copy the figures from spatial preprocessing into a separate folder.
  %
  % USAGE::
  %
  %   copyFigures(BIDS, opt, subLabel)
  %
  % :param BIDS: dataset layout.
  %              See also: bids.layout, getData.
  % :type  BIDS: structure
  %
  % :param opt: Options chosen for the analysis.
  %             See also: ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type  opt: structure
  %
  % :param subLabel: Subject label (for example `'01'`).
  % :type  subLabel: char
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  imgNb = copyGraphWindownOutput(opt, subLabel, 'realign');

  % loop through the figures outputed for unwarp: one per run
  if opt.realign.useUnwarp && ~opt.anatOnly

    runs = bids.query(BIDS, 'runs', ...
                      'sub', subLabel, ...
                      'task', opt.taskName, ...
                      'suffix', opt.bidsFilterFile.bold.suffix);

    nbRuns = size(runs, 2);
    if nbRuns == 0
      nbRuns = 1;
    end

    imgNb = copyGraphWindownOutput(opt, subLabel, 'unwarp', imgNb:(imgNb + nbRuns - 1));

  end

  imgNb = copyGraphWindownOutput(opt, subLabel, 'func2anatCoreg', imgNb); %#ok<NASGU>

end
