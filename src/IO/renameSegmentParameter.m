function renameSegmentParameter(BIDS, subLabel, opt)
  %
  %
  % USAGE::
  %
  %    renameSegmentParameter(BIDS, subLabel, opt)
  %
  %

  % (C) Copyright 2020 bidspm developers

  opt = set_spm_2_bids_defaults(opt);

  [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);

  segmentParam = spm_select('FPList', anatDataDir, ['^.*', ...
                                                    spm_file(anatImage, 'basename'), ...
                                                    '_seg8.mat$']);

  newFilename = spm_2_bids(segmentParam, opt.spm_2_bids);

  newName = spm_file(segmentParam, 'filename',  newFilename);

  if ~isempty(segmentParam)
    movefile(segmentParam, newName);
  end

end
