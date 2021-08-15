function boldFileName = getBoldFilenameForFFX(varargin)
  %
  % Gets the filename for this bold run for this task for the FFX setup
  % and check that the file with the right prefix exist
  %
  % USAGE::
  %
  %   boldFileName = getBoldFilenameForFFX(BIDS, opt, subID, funcFWHM, iSes, iRun)
  %
  % :param BIDS:
  % :type BIDS: structure
  % :param opt:
  % :type opt: structure
  % :param subID:
  % :type subID: string
  % :param iSes:
  % :type iSes: integer
  % :param iRun:
  % :type iRun: integer
  %
  % :returns: - :boldFileName: (string)
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  [BIDS, opt, subLabel, iSes, iRun] =  deal(varargin{:});

  opt.query.modality = 'func';

  if opt.fwhm.func > 0
    opt.query.desc = ['smth' num2str(opt.fwhm.func)];
  else
    opt.query.desc = 'preproc';
  end

  % TODO refactor this acroos all functions
  opt.query.space = opt.space;
  if ismember('MNI', opt.query.space)
    idx = strcmp(opt.query.space, 'MNI');
    opt.query.space{idx} = 'IXI549Space';
  end

  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');

  runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

  [fileName, subFuncDataDir] = getBoldFilename( ...
                                               BIDS, ...
                                               subLabel, sessions{iSes}, runs{iRun}, opt);

  % TODO remove this validation
  boldFileName = validationInputFile(subFuncDataDir, fileName);

end
