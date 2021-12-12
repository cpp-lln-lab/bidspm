function boldFileName = getBoldFilenameForFFX(varargin)
  %
  % Gets the filename for this bold run for this task for the FFX setup
  % and check that the file with the right prefix exist
  %
  % USAGE::
  %
  %   boldFileName = getBoldFilenameForFFX(BIDS, opt, subLabel, funcFWHM, iSes, iRun)
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
  
    query = struct( ...
             'sub',  subLabel, ...
             'ses', sessions{iSes}, ...
             'run', runs{iRun}, ...
             'suffix', 'bold', ...
             'prefix', '', ...
             'extension', {{'.nii', '.nii.gz'}});

    % use the extra query options specified in the options
    query = setFields(query, opt.query);
    query = removeEmptyQueryFields(query);

    boldFileName = bids.query(BIDS, 'data', query);
  

  if numel(boldFileName) > 1
    errorHandling(mfilename(), 'tooManyFiles', 'This should only get one file.', false, true);
  elseif isempty(boldFileName)
    msg = sprintf('No bold file found in:\n\t%s\nfor query:%s\n', ...
          BIDS.pth, ...
          createUnorderedList(opt.query));
    errorHandling(mfilename(), 'emptyInput', msg, false, true);  
  end
  
  % in case files have been unzipped, we do it now
  fullPathBoldFileName = unzipImgAndReturnsFullpathName(boldFileName{1}, opt);
  
  printToScreen(createUnorderedList(fullPathBoldFileName), opt);

  boldFileName = spm_file(fullPathBoldFileName, 'filename');
  subFuncDataDir = spm_file(fullPathBoldFileName, 'path');

  boldFileName = fullfile(subFuncDataDir, boldFileName);

end
