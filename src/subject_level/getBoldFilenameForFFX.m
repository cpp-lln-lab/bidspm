% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function [boldFileName, prefix] = getBoldFilenameForFFX(varargin)
  % [boldFileName, prefix] = getBoldFilenameForFFX(BIDS, opt, subID, funcFWHM, iSes, iRun)
  %
  % get the filename for this bold run for this task for the FFX setup
  % and check that the file with the right prefix exist

  [BIDS, opt, subID, funcFWHM, iSes, iRun] =  deal(varargin{:});

  sessions = getInfo(BIDS, subID, opt, 'Sessions');

  runs = getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

  workflowType = 'FFX';
  if ~opt.realign.useUnwarp && strcmp(opt.space, 'individual')
     workflowType = 'FFX_unwarp-0_space-individual'; 
  elseif opt.realign.useUnwarp && strcmp(opt.space, 'individual')
     workflowType = 'FFX_space-individual';
  elseif ~opt.realign.useUnwarp && strcmp(opt.space, 'MNI')
     workflowType = 'FFX_unwarp-0';
  end
  prefix = getPrefix(workflowType, opt, funcFWHM);

  [fileName, subFuncDataDir] = getBoldFilename( ...
                                               BIDS, ...
                                               subID, sessions{iSes}, runs{iRun}, opt);

  boldFileName = validationInputFile( ...
                                     subFuncDataDir, ...
                                     fileName, ...
                                     prefix);

end
