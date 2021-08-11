function [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subLabel, opt, step)
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

  if nargin < 4
    step = 'mean';
  end

  if (isfield(opt.metadata, 'SliceTiming') && ...
      ~isempty(opt.metadata.SliceTiming)) || ...
          ~isempty(opt.sliceOrder)
    opt.query.desc = 'stc';
  end

  prefix = getPrefix(step, opt);

  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');
  runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{1});
  [boldFileName, subFuncDataDir] = getBoldFilename( ...
                                                   BIDS, ...
                                                   subLabel, sessions{1}, runs{1}, opt);

  meanImage = validationInputFile( ...
                                  subFuncDataDir, ...
                                  boldFileName, ...
                                  prefix);

  [meanFuncDir, meanImage, ext] = spm_fileparts(meanImage);
  meanImage = [meanImage ext];
end
