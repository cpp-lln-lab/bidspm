function copyFigures(BIDS, opt, subLabel)
  %
  % Copy the figures from spatial preprocessing into a separate folder.
  %
  % USAGE::
  %
  %   copyFigures(BIDS, opt, subLabel)
  %
  % :param BIDS: BIDS layout returned by ``getData``.
  % :type BIDS: structure
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :param subLabel: Subject label (for example `'01'`).
  % :type subLabel: string
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  imgNb = copyGraphWindownOutput(opt, subLabel, 'realign');

  % loop through the figures outputed for unwarp: one per run
  if  opt.realign.useUnwarp

    runs = bids.query(BIDS, 'runs', ...
                      'sub', subLabel, ...
                      'task', opt.taskName, ...
                      'suffix', 'bold');

    nbRuns = size(runs, 2);
    if nbRuns == 0
      nbRuns = 1;
    end

    imgNb = copyGraphWindownOutput(opt, subLabel, 'unwarp', imgNb:(imgNb + nbRuns - 1));

  end

  imgNb = copyGraphWindownOutput(opt, subLabel, 'func2anatCoreg', imgNb); %#ok<NASGU>

end
