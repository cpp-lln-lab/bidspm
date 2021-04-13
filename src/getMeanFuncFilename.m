function [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subLabel, opt)
  %
  % Get the filename and the directory of an mean functional file.
  %
  % USAGE::
  %
  %   [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subLabel, opt)
  %
  % :param BIDS:
  % :type BIDS: structure
  % :param subLabel:
  % :type subLabel: string
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  %
  % :returns: - :meanImage: (string)
  %           - :meanFuncDir: (string)
  %
  % (C) Copyright 2020 CPP_SPM developers

  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');
  runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{1});
  [boldFileName, subFuncDataDir] = getBoldFilename( ...
                                                   BIDS, ...
                                                   subLabel, sessions{1}, runs{1}, opt);

  prefix = getPrefix('mean', opt);

  meanImage = validationInputFile( ...
                                  subFuncDataDir, ...
                                  boldFileName, ...
                                  prefix);

  [meanFuncDir, meanImage, ext] = spm_fileparts(meanImage);
  meanImage = [meanImage ext];
end
