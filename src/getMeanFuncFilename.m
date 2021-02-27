% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subID, opt)
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
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %
  % [anatImage, anatDataDir] = getAnatFilename(BIDS, subID, opt)
  %
  % Get the filename and the directory of an anat file for a given session /
  % run.
  % Unzips the file if necessary.

  sessions = getInfo(BIDS, subID, opt, 'Sessions');
  runs = getInfo(BIDS, subID, opt, 'Runs', sessions{1});
  [boldFileName, subFuncDataDir] = getBoldFilename( ...
                                                   BIDS, ...
                                                   subID, sessions{1}, runs{1}, opt);

  prefix = getPrefix('mean', opt);

  meanImage = validationInputFile( ...
                                  subFuncDataDir, ...
                                  boldFileName, ...
                                  prefix);

  [meanFuncDir, meanImage, ext] = spm_fileparts(meanImage);
  meanImage = [meanImage ext];
end
