function renameSegmentParameter(BIDS, subLabel, opt)
  %
  %
  % USAGE::
  %
  %    renameSegmentParameter(BIDS, subLabel, opt)
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);

  segmentParam = spm_select('FPList', anatDataDir, ['^.*', ...
                                                    spm_file(anatImage, 'basename'), ...
                                                    '_seg8.mat$']);

  p = bids.internal.parse_filename(anatImage);
  p.entities.label = p.suffix;
  p.use_schema = false;
  p.suffix = 'segparam';
  p.ext = '.mat';
  newName = spm_file(segmentParam, 'filename',  bids.create_filename(p));

  movefile(segmentParam, newName);

end
