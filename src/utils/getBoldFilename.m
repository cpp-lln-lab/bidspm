function [boldFileName, subFuncDataDir] = getBoldFilename(varargin)
  %
  % Get the filename and the directory of a bold file for a given session /
  % run.
  %
  % Unzips the file if necessary.
  %
  % USAGE::
  %
  %   [boldFileName, subFuncDataDir] = getBoldFilename(BIDS, subID, sessionID, runID, opt)
  %
  % :param BIDS:        returned by bids.layout when exploring a BIDS data set.
  % :type BIDS:         structure
  % :param subID:       label of the subject ; in BIDS lingo that means that for a file name
  %                     ``sub-02_task-foo_bold.nii`` the subID will be the string ``02``
  % :type subID:        string
  % :param sessionID:   session label (for `ses-001`, the label will be `001`)
  % :type sessionID:    string
  % :param runID:       run index label (for `run-001`, the label will be `001`)
  % :type runID:        string
  % :param opt:         Mostly used to find the task name.
  % :type opt:          structure
  %
  %
  % :returns: - :boldFileName: (string)
  %           - :subFuncDataDir: (string)
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  [BIDS, subLabel, sessionID, runID, opt] = deal(varargin{:});

  % get the filename for this bold run for this task
  boldFileName = getInfo(BIDS, subLabel, opt, 'Filename', sessionID, runID, 'bold');

  % TODO
  % throw an error that says what query actually failed to return a file
  % this might need some refacoring to be able to access the query from here even though
  % some part of it is in getInfo
  if isempty(boldFileName)
    msg = sprintf('No bold file found in:\n\t%s\nfor query:%s\n', ...
                  BIDS.pth, ...
                  createUnorderedList(opt.query));

    errorHandling(mfilename(), 'emptyInput', msg, false, true);
  end

  % in case files have been unzipped, we do it now
  fullPathBoldFileName = unzipImgAndReturnsFullpathName(boldFileName, opt);

  printToScreen(createUnorderedList(fullPathBoldFileName), opt);

  boldFileName = spm_file(fullPathBoldFileName, 'filename');
  subFuncDataDir = spm_file(fullPathBoldFileName, 'path');

end
