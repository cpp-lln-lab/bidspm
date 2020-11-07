% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function [boldFileName, prefix] = getBoldFilenameForFFX(varargin)
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
  % [boldFileName, prefix] = getBoldFilenameForFFX(BIDS, opt, subID, funcFWHM, iSes, iRun)
  %
  % get the filename for this bold run for this task for the FFX setup
  % and check that the file with the right prefix exist

  [BIDS, opt, subID, funcFWHM, iSes, iRun] =  deal(varargin{:});

  sessions = getInfo(BIDS, subID, opt, 'Sessions');

  runs = getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

  prefix = getPrefix('FFX', opt, funcFWHM);

  [fileName, subFuncDataDir] = getBoldFilename( ...
                                               BIDS, ...
                                               subID, sessions{iSes}, runs{iRun}, opt);

  boldFileName = validationInputFile( ...
                                     subFuncDataDir, ...
                                     fileName, ...
                                     prefix);

end
