function opt = checkForPreviousSkullStripOutput(anatFile, BIDS, opt)
  %
  % to skip segmentation and skullstripping if done previously
  %
  %
  %
  % (C) Copyright 2022 CPP_SPM developers

  anatFile = bids.File(anatFile);
  filter = anatFile.entities;
  filter.modality = 'anat';

  filter.suffix = anatFile.suffix;
  filter.desc = 'biascor';
  filter.space = 'individual';
  biasCorrectedImage = bids.query(BIDS, 'data', filter);

  filter.suffix = 'probseg';
  filter = rmfield(filter, 'desc');
  tpm = bids.query(BIDS, 'data', filter);

  segmentationNotAlreadyDone = isempty(tpm) || isempty(biasCorrectedImage);

  % User options take precedence
  % if segmentation  / skullstrip was requested
  opt.segment.do = opt.segment.force || segmentationNotAlreadyDone;
  opt.skullstrip.do = opt.skullstrip.do || segmentationNotAlreadyDone;

end
