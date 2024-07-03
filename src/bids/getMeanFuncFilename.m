function [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subLabel, opt)
  %
  % Get the filename and the directory of an mean functional file.
  %
  % USAGE::
  %
  %   [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subLabel, opt)
  %
  % :param BIDS: dataset layout.
  %              See: bids.layout, getData.
  %
  % :type BIDS: structure
  %
  % :param subLabel:
  % :type  subLabel: char
  %
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  %
  % :type  opt: structure
  %
  % :return: meanImage
  % :rtype: string
  %
  % :return: meanFuncDir
  % :rtype: string
  %

  % (C) Copyright 2020 bidspm developers

  opt.query.space = 'individual';
  opt.query.desc = 'mean';

  % TODO dead code that should be removed?
  % unless we want for this function to return the mean image in whatever space
  opt = mniToIxi(opt);

  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');
  runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{1});
  [meanImage, meanFuncDir] = getBoldFilename( ...
                                             BIDS, ...
                                             subLabel, sessions{1}, runs{1}, opt);

end
