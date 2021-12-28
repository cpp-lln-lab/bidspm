function boldFilename = getBoldFilenameForFFX(varargin)
  %
  % Gets the filename for this bold run for this task for the FFX setup
  % and check that the file with the right prefix exist
  %
  % USAGE::
  %
  %   boldFilename = getBoldFilenameForFFX(BIDS, opt, subLabel, funcFWHM, iSes, iRun)
  %
  % :param BIDS:
  % :type BIDS: structure
  % :param opt:
  % :type opt: structure
  % :param subLabel:
  % :type subLabel: string
  % :param iSes:
  % :type iSes: integer
  % :param iRun:
  % :type iRun: integer
  %
  % :returns: - :boldFilename: (string)
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
  opt = mniToIxi(opt);

  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');

  runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

  % task details are passed in opt.query
  query = struct( ...
                 'prefix', '', ...
                 'sub',  subLabel, ...
                 'ses', sessions{iSes}, ...
                 'run', runs{iRun}, ...
                 'suffix', 'bold', ...
                 'extension', {{'.nii.*'}});

  % use the extra query options specified in the options
  query = setFields(query, opt.query);
  query = removeEmptyQueryFields(query);

  boldFilename = bids.query(BIDS, 'data', query);

  if numel(boldFilename) > 1
    disp(boldFilename);
    errorHandling(mfilename(), 'tooManyFiles', 'This should only get one file.', false, true);
  elseif isempty(boldFilename)
    msg = sprintf('No bold file found in:\n\t%s\nfor query:%s\n', ...
                  BIDS.pth, ...
                  createUnorderedList(opt.query));
    errorHandling(mfilename(), 'noFileFound', msg, false, true);
  end

  % in case files have been unzipped, we do it now
  fullPathBoldFilename = unzipAndReturnsFullpathName(boldFilename{1}, opt);

  printToScreen(createUnorderedList(fullPathBoldFilename), opt);

  boldFilename = spm_file(fullPathBoldFilename, 'filename');
  subFuncDataDir = spm_file(fullPathBoldFilename, 'path');

  boldFilename = fullfile(subFuncDataDir, boldFilename);

end
