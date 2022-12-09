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
  %             See also: ``checkOptions()`` and ``loadAndCheckOptions()``.
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
  % :returns: - :boldFilename: (string)
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

  msg = ['  Bold file(s):', createUnorderedList(pathToPrint(fullPathBoldFilename))];
  logger('INFO', msg, opt, mfilename);

  boldFilename = spm_file(fullPathBoldFilename, 'filename');
  subFuncDataDir = spm_file(fullPathBoldFilename, 'path');

  boldFilename = fullfile(subFuncDataDir, boldFilename);

end
