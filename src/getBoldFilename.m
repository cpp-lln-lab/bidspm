% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

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

  [BIDS, subID, sessionID, runID, opt] = deal(varargin{:});

  % get the filename for this bold run for this task
  boldFileName = getInfo(BIDS, subID, opt, 'Filename', sessionID, runID, 'bold');

  % get fullpath of the file
  % ASSUMPTION: the first file is the right one.
  boldFileName = unzipImgAndReturnsFullpathName(boldFileName);

  [subFuncDataDir, boldFileName, ext] = spm_fileparts(boldFileName);
  boldFileName = [boldFileName ext];

end
