function renameSegmentParameter(BIDS, subLabel, opt)
  %
  %
  % USAGE::
  %
  %    renameSegmentParameter(BIDS, subLabel, opt)
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  [anatImage, anatDataDir] = getAnatFilename(BIDS, subLabel, opt);

  segmentParam = spm_select('FPList', anatDataDir, ['^.*', ...
                                                    spm_file(anatImage, 'basename'), ...
                                                    '_seg8.mat$']);

  p = bids.internal.parse_filename(anatImage);
  p.entities.label = p.suffix;
  p.suffix = 'segparam';
  p.ext = '.mat';
  newName = spm_file(segmentParam, 'filename',  createFilename(p));

  movefile(segmentParam, newName);

end
