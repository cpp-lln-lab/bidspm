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

  bf = bids.File(anatImage);
  bf.entities.label = bf.suffix;

  bf.suffix = 'segparam';
  bf.extension = '.mat';

  newName = spm_file(segmentParam, 'filename',  bf.filename);

  if ~isempty(segmentParam)
    movefile(segmentParam, newName);
  end

end
