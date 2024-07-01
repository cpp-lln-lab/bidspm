function boldFilename = getBoldFilenameForFFX(varargin)
  %
  % Gets the filename for this bold run for this task for the FFX setup
  % and check that the file with the right prefix exist
  %
  % USAGE::
  %
  %   boldFilename = getBoldFilenameForFFX(BIDS, opt, subLabel, funcFWHM, iSes, iRun)
  %
  % :param BIDS: dataset layout.
  %              See also: bids.layout, getData.
  % :type  BIDS: structure
  %
  % :param opt: Options chosen for the analysis.
  %             See checkOptions.
  % :type  opt: structure
  %
  % :param subLabel:
  % :type  subLabel: char
  %
  % :param iSes:
  % :type  iSes: integer
  %
  % :param iRun:
  % :type  iRun: integer
  %
  % :return: :boldFilename: (string)
  %
  %

  % (C) Copyright 2020 bidspm developers

  [BIDS, opt, subLabel, iSes, iRun] =  deal(varargin{:});

  [filter, opt] = fileFilterForBold(opt, subLabel);

  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');
  filter.ses = sessions{iSes};

  runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});
  filter.run = runs{iRun};

  boldFilename = bids.query(BIDS, 'data', filter);

  if numel(boldFilename) > 1
    id = 'tooManyFiles';
    msg = sprintf('This should only get one file. Got:%s', ...
                  bids.internal.create_unordered_list(boldFilename));
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  elseif isempty(boldFilename)
    msg = sprintf('No bold file found in:\n\t%s\nfor query:%s\n', ...
                  BIDS.pth, ...
                  bids.internal.create_unordered_list(opt.query));
    id = 'noFileFound';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());
  end

  % in case files have been unzipped, we do it now
  fullPathBoldFilename = unzipAndReturnsFullpathName(boldFilename{1}, opt);

  msg = ['  Bold file(s):', ...
         bids.internal.create_unordered_list(bids.internal.format_path(fullPathBoldFilename))];
  logger('INFO', msg, 'options', opt, 'filename', mfilename());

  boldFilename = spm_file(fullPathBoldFilename, 'filename');
  subFuncDataDir = spm_file(fullPathBoldFilename, 'path');

  boldFilename = fullfile(subFuncDataDir, boldFilename);

end
