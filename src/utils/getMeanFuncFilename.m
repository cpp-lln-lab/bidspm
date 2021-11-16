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

  opt.query.space = 'individual';
  opt.query.desc = 'mean';

  % TODO
  % This seems like dead code that should be removed
  % unless we want for this function to return the mean image in whatever space
  if strcmp(opt.query.space, 'MNI')
    opt.query.space = 'IXI549Space';
  end

  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');
  runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{1});
  [meanImage, meanFuncDir] = getBoldFilename( ...
                                             BIDS, ...
                                             subLabel, sessions{1}, runs{1}, opt);

end
