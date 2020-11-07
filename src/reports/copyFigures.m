% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function copyFigures(BIDS, opt, subID)
  %
  % Copy the figures from spatial preprocessing into a separate folder.
  %
  % USAGE::
  %
  %   copyFigures(BIDS, opt, subID)
  %
  % :param BIDS: BIDS layout returned by ``getData``.
  % :type BIDS: structure
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :param subID: Subject label (for example `'01'`).
  % :type subID: string
  %
  %
  
  imgNb = copyGraphWindownOutput(opt, subID, 'realign');

  % loop through the figures outputed for unwarp: one per run
  if  opt.realign.useUnwarp

    runs = bids.query(BIDS, 'runs', ...
                      'sub', subID, ...
                      'task', opt.taskName, ...
                      'type', 'bold');

    nbRuns = size(runs, 2);
    if nbRuns == 0
      nbRuns = 1;
    end

    imgNb = copyGraphWindownOutput(opt, subID, 'unwarp', imgNb:(imgNb + nbRuns - 1));

  end

  imgNb = copyGraphWindownOutput(opt, subID, 'func2anatCoreg', imgNb); %#ok<NASGU>

end
