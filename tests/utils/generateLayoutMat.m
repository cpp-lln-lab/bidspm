function generateLayoutMat
  %
  % generate layout.mat for faster loading
  %
  % (C) Copyright 2022 CPP_SPM developers

  opt.dir.raw = getDummyDataDir('raw');
  opt.dir.preproc = getDummyDataDir('preproc');

  if exist(fullfile(opt.dir.preproc, 'layout.mat'), 'file') == 0
    BIDS = bids.layout(opt.dir.raw);
    save(fullfile(opt.dir.raw, 'layout.mat'), 'BIDS');
    BIDSraw = BIDS;

    BIDS = bids.layout(opt.dir.preproc, 'use_schema', false);
    BIDS.raw = BIDSraw;
    save(fullfile(opt.dir.preproc, 'layout.mat'), 'BIDS');
  end

end
