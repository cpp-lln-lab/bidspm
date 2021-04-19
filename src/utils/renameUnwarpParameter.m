function renameUnwarpParameter(BIDS, subLabel, opt)
  %
  %
  % USAGE::
  %
  %    renameUnwarpParameter(BIDS, subLabel, opt)
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subLabel, opt);

  unwarpParam = spm_select('FPList', meanFuncDir, '^.*_uw.mat$');

  % TODO
  % this seems to mess up the way the entities are ordered:
  %
  % task-auditory_sub-01_desc-brain_unwarpparam.mat

  p = bids.internal.parse_filename(meanImage);
  p.entities.label = p.suffix;
  p.suffix = 'unwarpparam';
  p.ext = '.mat';
  newName = spm_file(unwarpParam, 'filename',  createFilename(p));

  movefile(unwarpParam, newName);

end
