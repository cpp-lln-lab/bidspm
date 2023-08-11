function [boldFilename, subFuncDataDir, metadata] = getBoldFilename(varargin)
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
  % :param opt: Options chosen for the analysis.
  %             See checkOptions.
  % :type opt:  structure
  %
  %
  % :returns: - :boldFilename: (string)
  %           - :subFuncDataDir: (string)
  %
  %

  % (C) Copyright 2020 bidspm developers

  [BIDS, subLabel, sessionID, runID, opt] = deal(varargin{:});

  % get the filename for this bold run for this task
  boldFilename = getInfo(BIDS, ...
                         subLabel, ...
                         opt, ...
                         'Filename', ...
                         sessionID, ...
                         runID, opt.bidsFilterFile.bold.suffix);

  if isempty(boldFilename)
    msg = sprintf('No bold file found in:\n\t%s\nfor filter:%s\n', ...
                  bids.internal.format_path(BIDS.pth), ...
                  bids.internal.create_unordered_list(opt.query));

    id = 'emptyInput';
    logger('WARNING', msg, 'filename', mfilename(), 'id', id);
    subFuncDataDir = [];
    metadata = [];
    return
  end

  % in case files have been unzipped, we do it now
  fullPathBoldFilename = unzipAndReturnsFullpathName(boldFilename, opt);

  msg = bids.internal.create_unordered_list(bids.internal.format_path(fullPathBoldFilename));
  logger('DEBUG', msg, 'options', opt, 'filename', mfilename());

  boldFilename = spm_file(fullPathBoldFilename, 'filename');
  subFuncDataDir = spm_file(fullPathBoldFilename, 'path');

  metadata = getInfo(BIDS, ...
                     subLabel, ...
                     opt, ...
                     'metadata', ...
                     sessionID, ...
                     runID, opt.bidsFilterFile.bold.suffix);

end
