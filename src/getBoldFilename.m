% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function [boldFileName, subFuncDataDir] = getBoldFilename(varargin)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %
  % [fileName, subFuncDataDir] = getBoldFilename(BIDS, opt, subID, sessionID, runID)
  %
  % Get the filename and the directory of a bold file for a given session /
  % run.
  % Unzips the file if necessary.

  [BIDS, subID, sessionID, runID, opt] = deal(varargin{:});

  % get the filename for this bold run for this task
  boldFileName = getInfo(BIDS, subID, opt, 'Filename', sessionID, runID, 'bold');

  % get fullpath of the file
  % ASSUMPTION: the first file is the right one.
  boldFileName = unzipImgAndReturnsFullpathName(boldFileName);

  [subFuncDataDir, boldFileName, ext] = spm_fileparts(boldFileName);
  boldFileName = [boldFileName ext];

end
