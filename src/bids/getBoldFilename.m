function [boldFilename, subFuncDataDir] = getBoldFilename(varargin)
  %
  % Get the filename and the directory of a bold file for a given session /
  % run.
  %
  % Unzips the file if necessary.
  %
  % USAGE::
  %
  %   [boldFilename, subFuncDataDir] = getBoldFilename(BIDS, subLabel, sessionID, runID, opt)
  %
  % :param BIDS: dataset layout.
  %              See also: bids.layout, getData.
  % :type BIDS:         structure
  %
  % :param subLabel:    label of the subject ; in BIDS lingo that means that for a file name
  %                     ``sub-02_task-foo_bold.nii`` the subLabel will be the string ``02``
  % :type subLabel:      char
  %
  % :param sessionID:   session label (for `ses-001`, the label will be `001`)
  % :type sessionID:    char
  %
  % :param runID:       run index label (for `run-001`, the label will be `001`)
  % :type runID:        char
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See  also: checkOptions
  % :type opt:          structure
  %
  %
  % :returns: - :boldFilename: (string)
  %           - :subFuncDataDir: (string)
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  [BIDS, subLabel, sessionID, runID, opt] = deal(varargin{:});

  % get the filename for this bold run for this task
  boldFilename = getInfo(BIDS, ...
                         subLabel, ...
                         opt, ...
                         'Filename', ...
                         sessionID, ...
                         runID, opt.bidsFilterFile.bold.suffix);

  % TODO throw an error that says what query actually failed to return a file
  % this might need some refacoring to be able to access the query from here even though
  % some part of it is in getInfo
  if isempty(boldFilename)
    msg = sprintf('No bold file found in:\n\t%s\nfor filter:%s\n', ...
                  pathToPrint(BIDS.pth), ...
                  createUnorderedList(opt.query));

    errorHandling(mfilename(), 'emptyInput', msg, false, true);
  end

  % in case files have been unzipped, we do it now
  fullPathBoldFilename = unzipAndReturnsFullpathName(boldFilename, opt);

  printToScreen(createUnorderedList(pathToPrint(fullPathBoldFilename)), opt);

  boldFilename = spm_file(fullPathBoldFilename, 'filename');
  subFuncDataDir = spm_file(fullPathBoldFilename, 'path');

end
