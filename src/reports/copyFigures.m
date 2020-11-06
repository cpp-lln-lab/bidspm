% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function copyFigures(BIDS, opt, subID)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
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
