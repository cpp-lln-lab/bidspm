% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function [boldFileName, prefix] = getBoldFilenameForFFX(varargin)
  %
  % Gets the filename for this bold run for this task for the FFX setup
  % and check that the file with the right prefix exist
  %
  % USAGE::
  %
  %   [boldFileName, prefix] = getBoldFilenameForFFX(BIDS, opt, subID, funcFWHM, iSes, iRun)
  %
  % :param BIDS:
  % :type BIDS: structure
  % :param opt:
  % :type opt: structure
  % :param subID:
  % :type subID: string
  % :param funcFWHM:
  % :type funcFWHM: scalar
  % :param iSes:
  % :type iSes: integer
  % :param iRun:
  % :type iRun: integer
  %
  % :returns: - :boldFileName: (string)
  %           - :prefix: (srting)
  %
  %

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
